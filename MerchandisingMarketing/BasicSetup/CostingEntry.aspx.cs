using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.MerchandisingMarketing.BasicSetup
{
    // একটি PO-র Costing লাইন (প্রতি ডজন হিসাবে)
    [Serializable]
    public class CostLine
    {
        public string Category { get; set; }
        public string ItemName { get; set; }
        public string Unit { get; set; }
        public decimal ConsDzn { get; set; }
        public decimal WastePct { get; set; }
        public decimal Rate { get; set; }

        public decimal AmountDzn { get { return ConsDzn * (1m + WastePct / 100m) * Rate; } }
    }

    public partial class CostingEntry : System.Web.UI.Page
    {
        SqlConnection con;
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();

        // Category value (DB-তে যা সেভ হবে) | Display text
        private static readonly string[][] Categories = new[]
        {
            new[] { "Fabric", "Fabric" },
            new[] { "Trims", "Trims & Accessories" },
            new[] { "Print/Embroidery", "Print / Embroidery" },
            new[] { "Wash", "Wash" },
            new[] { "CM", "CM (Cutting & Making)" },
            new[] { "Commercial", "Commercial / Overhead" },
            new[] { "Other", "Other" }
        };

        private int CurrentUserId
        {
            get { return Session["UserID"] != null ? Convert.ToInt32(Session["UserID"]) : 1; }
        }

        private string CurrentUserName
        {
            get { return Session["UserName"] != null ? Convert.ToString(Session["UserName"]) : "User"; }
        }

        // PO list cache: [0]=POID [1]=PONo [2]=StyleNo [3]=BuyerName [4]=POQty
        private List<string[]> POList
        {
            get { return ViewState["POList"] as List<string[]> ?? new List<string[]>(); }
            set { ViewState["POList"] = value; }
        }

        // ============================================================
        // PAGE LOAD
        // ============================================================
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            lblUser.Text = CurrentUserName;

            ddlCat.Items.Clear();
            foreach (string[] c in Categories) ddlCat.Items.Add(new ListItem(c[1], c[0]));

            NewCosting();
            LoadPOList();
            FillBuyers();
            LoadCostingDropdown();

            int qc;
            if (int.TryParse(Request.QueryString["costingid"], out qc) && qc > 0)
            {
                ListItem it = ddlCosting.Items.FindByValue(qc.ToString());
                if (it != null)
                {
                    ddlCosting.ClearSelection();
                    it.Selected = true;
                    LoadCosting(qc);
                }
            }
        }

        protected void Page_PreRender(object sender, EventArgs e)
        {
            RefreshSummary();
        }

        // ============================================================
        // HELPERS
        // ============================================================
        private void ShowAlert(string msg)
        {
            string safe = (msg ?? "").Replace("'", "").Replace("\r", "").Replace("\n", " ");
            ScriptManager.RegisterStartupScript(this, this.GetType(), Guid.NewGuid().ToString("N"),
                "alert('" + safe + "');", true);
        }

        private void CloseConnection()
        {
            if (con != null && con.State == ConnectionState.Open) con.Close();
        }

        private object NullIfEmpty(string s)
        {
            return string.IsNullOrWhiteSpace(s) ? (object)DBNull.Value : s.Trim();
        }

        private decimal DecOrZero(string s) { decimal d; return decimal.TryParse(s, out d) ? d : 0m; }
        private int IntOrZero(string s) { int v; return int.TryParse(s, out v) ? v : 0; }
        private string GetStr(object o) { return o == null || o == DBNull.Value ? "" : o.ToString(); }

        private static SqlParameter P(string name, object value) { return new SqlParameter(name, value ?? DBNull.Value); }

        private static SqlParameter PD(string name, decimal value)
        {
            SqlParameter p = new SqlParameter(name, SqlDbType.Decimal);
            p.Precision = 18;
            p.Scale = 4;
            p.Value = value;
            return p;
        }

        private SqlCommand Proc(string name, SqlTransaction tx = null)
        {
            SqlCommand c = new SqlCommand(name, con, tx);
            c.CommandType = CommandType.StoredProcedure;
            return c;
        }

        private DataTable ProcTable(string name, params SqlParameter[] ps)
        {
            DataTable dt = new DataTable();
            try
            {
                con = conn.openConnection();
                using (SqlCommand c = Proc(name))
                {
                    if (ps != null && ps.Length > 0) c.Parameters.AddRange(ps);
                    new SqlDataAdapter(c).Fill(dt);
                }
            }
            finally { CloseConnection(); }
            return dt;
        }

        private static void SelectDDL(DropDownList ddl, string value)
        {
            if (ddl == null) return;
            ListItem item = ddl.Items.FindByValue(value);
            if (item != null) { ddl.ClearSelection(); item.Selected = true; }
            else if (ddl.Items.Count > 0) ddl.SelectedIndex = 0;
        }

        private static bool IsFlatCategory(string cat) { return cat == "CM" || cat == "Commercial"; }

        // ============================================================
        // COSTING HEADER (new / open existing)
        // ============================================================
        private void NewCosting()
        {
            hfCostingId.Value = "0";
            txtCostingNo.Text = "(Auto Generated)";
            txtCostingDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
            txtRemarks.Text = "";
            txtProfit.Text = "10";
            txtComm.Text = "5";
            txtTarget.Text = "0";
            SetOrderQty(0);
            BindCost(new List<CostLine>());
        }

        private void SetOrderQty(int qty)
        {
            hfOrderQty.Value = qty.ToString();
            txtOrderQty.Text = qty.ToString("N0");
        }

        protected void btnNew_Click(object sender, EventArgs e)
        {
            NewCosting();
            if (ddlCosting.Items.Count > 0) ddlCosting.SelectedIndex = 0;
            ResetSelection();
        }

        private void LoadCostingDropdown()
        {
            try
            {
                DataTable dt = ProcTable("Costing_GetList");
                ddlCosting.Items.Clear();
                ddlCosting.Items.Add(new ListItem("-- New Costing --", "0"));
                foreach (DataRow r in dt.Rows)
                    ddlCosting.Items.Add(new ListItem(GetStr(r["Display"]), GetStr(r["CostingID"])));
            }
            catch (Exception ex)
            {
                CloseConnection();
                ShowAlert("Costing list load error: " + ex.Message);
            }
        }

        protected void ddlCosting_SelectedIndexChanged(object sender, EventArgs e)
        {
            int id = IntOrZero(ddlCosting.SelectedValue);
            if (id <= 0) { NewCosting(); ResetSelection(); return; }
            LoadCosting(id);
        }

        private void LoadCosting(int costingId)
        {
            try
            {
                DataTable m = ProcTable("Costing_GetMaster", P("@CostingID", costingId));
                if (m.Rows.Count == 0) { ShowAlert("Costing not found!"); return; }
                DataRow r = m.Rows[0];

                hfCostingId.Value = costingId.ToString();
                txtCostingNo.Text = GetStr(r["CostingNo"]);
                txtCostingDate.Text = Convert.ToDateTime(r["CostingDate"]).ToString("yyyy-MM-dd");
                txtRemarks.Text = GetStr(r["Remarks"]);
                txtProfit.Text = Convert.ToDecimal(r["ProfitPct"]).ToString("0.##");
                txtComm.Text = Convert.ToDecimal(r["CommissionPct"]).ToString("0.##");
                txtTarget.Text = Convert.ToDecimal(r["TargetFobDzn"]).ToString("0.##");

                List<CostLine> rows = new List<CostLine>();
                DataTable dt = ProcTable("Costing_GetLines", P("@CostingID", costingId));
                foreach (DataRow l in dt.Rows)
                {
                    rows.Add(new CostLine
                    {
                        Category = GetStr(l["Category"]),
                        ItemName = GetStr(l["ItemName"]),
                        Unit = GetStr(l["Unit"]),
                        ConsDzn = Convert.ToDecimal(l["ConsDzn"]),
                        WastePct = Convert.ToDecimal(l["WastePct"]),
                        Rate = Convert.ToDecimal(l["Rate"])
                    });
                }
                BindCost(rows);

                // Buyer → Style → PO ড্রপডাউন সিলেক্ট
                string buyer = GetStr(r["BuyerName"]), style = GetStr(r["StyleNo"]);
                int poId = Convert.ToInt32(r["POID"]);
                SelectDDL(ddlBuyer, buyer);
                FillStyles(buyer);
                SelectDDL(ddlStyle, style);
                FillPOs(buyer, style);
                SelectDDL(ddlPO, poId.ToString());
                LoadPOContext(poId);
            }
            catch (Exception ex)
            {
                CloseConnection();
                ShowAlert("Costing load error: " + ex.Message);
            }
        }

        // ============================================================
        // BUYER → STYLE → PO  (cascade)
        // ============================================================
        private void LoadPOList()
        {
            try
            {
                Dictionary<int, string[]> map = new Dictionary<int, string[]>();
                for (int st = 0; st <= 3; st++)
                {
                    DataTable dt = ProcTable("POEntry_GetPOList", P("@Search", null), P("@POStatus", st));
                    foreach (DataRow r in dt.Rows)
                    {
                        int id = Convert.ToInt32(r["POID"]);
                        if (map.ContainsKey(id)) continue;
                        map[id] = new[] { id.ToString(), GetStr(r["PONo"]), GetStr(r["StyleNo"]), GetStr(r["BuyerName"]), GetStr(r["POQty"]) };
                    }
                }
                POList = map.Values.ToList();
            }
            catch (Exception ex)
            {
                CloseConnection();
                ShowAlert("PO list load error: " + ex.Message);
            }
        }

        private void FillBuyers()
        {
            ddlBuyer.Items.Clear();
            ddlBuyer.Items.Add(new ListItem("-- Select Buyer --", ""));
            foreach (string b in POList.Select(x => x[3]).Distinct().OrderBy(x => x))
                ddlBuyer.Items.Add(new ListItem(b, b));
            FillStyles("");
        }

        private void FillStyles(string buyer)
        {
            ddlStyle.Items.Clear();
            ddlStyle.Items.Add(new ListItem("-- Select Style --", ""));
            if (buyer.Length > 0)
                foreach (string s in POList.Where(x => x[3] == buyer).Select(x => x[2]).Distinct().OrderBy(x => x))
                    ddlStyle.Items.Add(new ListItem(s, s));
            FillPOs("", "");
        }

        private void FillPOs(string buyer, string style)
        {
            ddlPO.Items.Clear();
            ddlPO.Items.Add(new ListItem("-- Select PO --", "0"));
            if (buyer.Length > 0 && style.Length > 0)
                foreach (string[] p in POList.Where(x => x[3] == buyer && x[2] == style).OrderByDescending(x => Convert.ToInt32(x[0])))
                    ddlPO.Items.Add(new ListItem(p[1] + " | " + p[4] + " pcs", p[0]));
        }

        private void ClearContext()
        {
            hfPOId.Value = "0";
            hfStyleId.Value = "0";
            SetOrderQty(0);
            pnlEntry.Visible = false;
        }

        private void ResetSelection()
        {
            ddlBuyer.SelectedIndex = 0;
            FillStyles("");
            ClearContext();
        }

        protected void ddlBuyer_SelectedIndexChanged(object sender, EventArgs e)
        {
            FillStyles(ddlBuyer.SelectedValue);
            ClearContext();
        }

        protected void ddlStyle_SelectedIndexChanged(object sender, EventArgs e)
        {
            FillPOs(ddlBuyer.SelectedValue, ddlStyle.SelectedValue);
            ClearContext();
        }

        protected void ddlPO_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadPOContext(IntOrZero(ddlPO.SelectedValue));
        }

        // PO সিলেক্ট করলে StyleID ও Order Qty লোড
        private void LoadPOContext(int poId)
        {
            if (poId <= 0) { ClearContext(); return; }

            try
            {
                DataTable dt = ProcTable("POEntry_GetPOHeader", P("@POID", poId));
                if (dt.Rows.Count == 0) { ShowAlert("PO not found!"); return; }

                hfPOId.Value = poId.ToString();
                hfStyleId.Value = IntOrZero(GetStr(dt.Rows[0]["StyleID"])).ToString();

                int total = 0;
                DataTable q = ProcTable("POEntry_GetPOColorSize", P("@POID", poId));
                foreach (DataRow dr in q.Rows) total += Convert.ToInt32(dr["Qty"]);
                if (total == 0)
                {
                    string[] meta = POList.FirstOrDefault(x => x[0] == poId.ToString());
                    if (meta != null) total = IntOrZero(meta[4]);
                }
                SetOrderQty(total);

                pnlEntry.Visible = true;
            }
            catch (Exception ex)
            {
                CloseConnection();
                ShowAlert("Load error: " + ex.Message);
            }
        }

        // ============================================================
        // GRID
        // ============================================================
        private List<CostLine> ReadCost()
        {
            List<CostLine> list = new List<CostLine>();
            foreach (GridViewRow row in gvCost.Rows)
            {
                if (row.RowType != DataControlRowType.DataRow) continue;
                Literal lc = row.FindControl("litCat") as Literal;
                if (lc == null) continue;

                list.Add(new CostLine
                {
                    Category = lc.Text,
                    ItemName = ((Literal)row.FindControl("litItem")).Text,
                    Unit = ((Literal)row.FindControl("litUnit")).Text,
                    ConsDzn = DecOrZero(((TextBox)row.FindControl("txtConsRow")).Text),
                    WastePct = DecOrZero(((TextBox)row.FindControl("txtWasteRow")).Text),
                    Rate = DecOrZero(((TextBox)row.FindControl("txtRateRow")).Text)
                });
            }
            return list;
        }

        private void BindCost(List<CostLine> rows)
        {
            gvCost.DataSource = rows;
            gvCost.DataBind();
        }

        protected void btnAdd_Click(object sender, EventArgs e)
        {
            if (IntOrZero(hfPOId.Value) <= 0) { ShowAlert("Select Buyer, Style and PO first."); return; }

            string cat = ddlCat.SelectedValue;
            string item = txtItem.Text.Trim();
            if (item.Length == 0) { ShowAlert("Enter Item / Description."); return; }

            decimal cons = DecOrZero(txtCons.Text);
            string unit = ddlUnit.SelectedValue;
            if (IsFlatCategory(cat) && cons <= 0m) { cons = 1m; unit = "Dzn"; }
            if (cons <= 0m) { ShowAlert("Enter Consumption per Dzn."); return; }

            List<CostLine> rows = ReadCost();
            if (rows.Any(x => x.Category == cat && string.Equals(x.ItemName, item, StringComparison.OrdinalIgnoreCase)))
            { ShowAlert("This item is already added in the same category."); return; }

            rows.Add(new CostLine
            {
                Category = cat,
                ItemName = item,
                Unit = unit,
                ConsDzn = cons,
                WastePct = DecOrZero(txtWaste.Text),
                Rate = DecOrZero(txtRate.Text)
            });
            BindCost(rows);

            txtItem.Text = txtCons.Text = txtWaste.Text = txtRate.Text = "";
        }

        // Fabric Booking থেকে ফেব্রিক Cons এনে বসানো (Rate ইউজার বসাবে)
        protected void btnImportFab_Click(object sender, EventArgs e)
        {
            int poId = IntOrZero(hfPOId.Value);
            if (poId <= 0) { ShowAlert("Select Buyer, Style and PO first."); return; }

            try
            {
                DataTable dt = ProcTable("Costing_GetFabricFromBooking", P("@POID", poId));
                if (dt.Rows.Count == 0) { ShowAlert("No booked fabric found for this PO."); return; }

                List<CostLine> rows = ReadCost();
                int added = 0;
                foreach (DataRow r in dt.Rows)
                {
                    string name = GetStr(r["FabricCode"]);
                    string fn = GetStr(r["FabricName"]);
                    if (fn.Length > 0) name += " - " + fn;
                    name += " (" + GetStr(r["PartName"]) + ")";

                    if (rows.Any(x => x.Category == "Fabric" && x.ItemName == name)) continue;

                    rows.Add(new CostLine
                    {
                        Category = "Fabric",
                        ItemName = name,
                        Unit = "Kg",
                        ConsDzn = Convert.ToDecimal(r["KgPerDzn"]),
                        WastePct = Convert.ToDecimal(r["LossPct"]) + Convert.ToDecimal(r["ExtraCutPct"]),
                        Rate = 0m
                    });
                    added++;
                }
                BindCost(rows);
                ShowAlert(added > 0
                    ? added + " fabric line(s) imported. Now enter the fabric Rate per Kg."
                    : "Fabric lines already imported.");
            }
            catch (Exception ex)
            {
                CloseConnection();
                ShowAlert("Fabric import error: " + ex.Message);
            }
        }

        protected void gvCost_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int idx;
            if (!int.TryParse(Convert.ToString(e.CommandArgument), out idx)) return;

            List<CostLine> rows = ReadCost();
            if (idx < 0 || idx >= rows.Count) return;

            if (e.CommandName == "RemoveRow")
            {
                rows.RemoveAt(idx);
            }
            else if (e.CommandName == "CopyRow")
            {
                CostLine s = rows[idx];
                rows.Insert(idx + 1, new CostLine
                {
                    Category = s.Category,
                    ItemName = s.ItemName,
                    Unit = s.Unit,
                    ConsDzn = s.ConsDzn,
                    WastePct = s.WastePct,
                    Rate = s.Rate
                });
            }
            else return;

            BindCost(rows);
        }

        // ============================================================
        // SUMMARY  (server side — JS live হিসাবের সাথে একই ফর্মুলা)
        // ============================================================
        private void CalcSummary(List<CostLine> rows, out decimal totalCost, out decimal fobDzn)
        {
            totalCost = rows.Sum(x => x.AmountDzn);
            decimal profit = totalCost * DecOrZero(txtProfit.Text) / 100m;
            decimal pre = totalCost + profit;
            decimal comm = DecOrZero(txtComm.Text);
            fobDzn = comm < 100m ? pre / (1m - comm / 100m) : pre;
        }

        private void RefreshSummary()
        {
            List<CostLine> rows = ReadCost();
            Func<string, decimal> cat = c => rows.Where(x => x.Category == c).Sum(x => x.AmountDzn);

            lblCatFabric.Text = cat("Fabric").ToString("N4");
            lblCatTrims.Text = cat("Trims").ToString("N4");
            lblCatEmb.Text = cat("Print/Embroidery").ToString("N4");
            lblCatWash.Text = cat("Wash").ToString("N4");
            lblCatCM.Text = cat("CM").ToString("N4");
            lblCatCom.Text = cat("Commercial").ToString("N4");
            lblCatOther.Text = cat("Other").ToString("N4");

            decimal total, fob;
            CalcSummary(rows, out total, out fob);
            decimal profit = total * DecOrZero(txtProfit.Text) / 100m;
            decimal comm = fob - (total + profit);
            decimal fobPc = fob / 12m;
            decimal target = DecOrZero(txtTarget.Text);

            lblTotalCost.Text = total.ToString("N4");
            lblProfitAmt.Text = profit.ToString("N4");
            lblCommAmt.Text = comm.ToString("N4");
            lblFobDzn.Text = fob.ToString("N2");
            lblFobPc.Text = fobPc.ToString("N4");
            lblOrderValue.Text = (fobPc * IntOrZero(hfOrderQty.Value)).ToString("N2");

            if (target > 0m)
            {
                decimal d = target - fob;
                lblVariance.Text = (d >= 0m ? "+" : "") + d.ToString("N2");
                lblVariance.CssClass = d >= 0m ? "pos" : "neg";
            }
            else { lblVariance.Text = "-"; lblVariance.CssClass = ""; }
        }

        // ============================================================
        // SAVE
        // ============================================================
        protected void btnSave_Click(object sender, EventArgs e)
        {
            DateTime cdate;
            if (!DateTime.TryParse(txtCostingDate.Text, out cdate)) { ShowAlert("Enter Costing Date."); return; }

            int poId = IntOrZero(hfPOId.Value);
            int styleId = IntOrZero(hfStyleId.Value);
            if (poId <= 0) { ShowAlert("Select Buyer, Style and PO first."); return; }

            List<CostLine> rows = ReadCost();
            if (rows.Count == 0) { ShowAlert("Add at least one cost line."); return; }

            string poNo = "", styleNo = "", buyer = ddlBuyer.SelectedValue;
            string[] meta = POList.FirstOrDefault(x => x[0] == poId.ToString());
            if (meta != null) { poNo = meta[1]; styleNo = meta[2]; buyer = meta[3]; }

            decimal totalCost, fobDzn;
            CalcSummary(rows, out totalCost, out fobDzn);

            int costingId = IntOrZero(hfCostingId.Value);
            int newId = costingId;
            string newNo = "";

            try
            {
                con = conn.openConnection();
                using (SqlTransaction tx = con.BeginTransaction())
                {
                    try
                    {
                        using (SqlCommand c = Proc("Costing_SaveMaster", tx))
                        {
                            c.Parameters.Add(P("@CostingID", costingId));
                            c.Parameters.Add(P("@CostingDate", cdate.Date));
                            c.Parameters.Add(P("@POID", poId));
                            c.Parameters.Add(P("@StyleID", styleId));
                            c.Parameters.Add(P("@PONo", NullIfEmpty(poNo)));
                            c.Parameters.Add(P("@StyleNo", NullIfEmpty(styleNo)));
                            c.Parameters.Add(P("@BuyerName", NullIfEmpty(buyer)));
                            c.Parameters.Add(P("@OrderQty", IntOrZero(hfOrderQty.Value)));
                            c.Parameters.Add(PD("@ProfitPct", DecOrZero(txtProfit.Text)));
                            c.Parameters.Add(PD("@CommissionPct", DecOrZero(txtComm.Text)));
                            c.Parameters.Add(PD("@TargetFobDzn", DecOrZero(txtTarget.Text)));
                            c.Parameters.Add(PD("@TotalCostDzn", totalCost));
                            c.Parameters.Add(PD("@FobDzn", fobDzn));
                            c.Parameters.Add(P("@Remarks", NullIfEmpty(txtRemarks.Text)));
                            c.Parameters.Add(P("@UserID", CurrentUserId));
                            using (SqlDataReader rd = c.ExecuteReader())
                            {
                                if (rd.Read())
                                {
                                    newId = Convert.ToInt32(rd["CostingID"]);
                                    newNo = Convert.ToString(rd["CostingNo"]);
                                }
                            }
                        }

                        using (SqlCommand c = Proc("Costing_ClearLines", tx))
                        {
                            c.Parameters.Add(P("@CostingID", newId));
                            c.ExecuteNonQuery();
                        }

                        int sort = 0;
                        foreach (CostLine l in rows)
                        {
                            sort++;
                            using (SqlCommand c = Proc("Costing_SaveLine", tx))
                            {
                                c.Parameters.Add(P("@CostingID", newId));
                                c.Parameters.Add(P("@Category", l.Category));
                                c.Parameters.Add(P("@ItemName", l.ItemName));
                                c.Parameters.Add(P("@Unit", NullIfEmpty(l.Unit)));
                                c.Parameters.Add(PD("@ConsDzn", l.ConsDzn));
                                c.Parameters.Add(PD("@WastePct", l.WastePct));
                                c.Parameters.Add(PD("@Rate", l.Rate));
                                c.Parameters.Add(PD("@AmountDzn", l.AmountDzn));
                                c.Parameters.Add(P("@SortOrder", sort));
                                c.ExecuteNonQuery();
                            }
                        }
                        tx.Commit();
                    }
                    catch
                    {
                        try { tx.Rollback(); } catch { }
                        throw;
                    }
                }
                CloseConnection();

                LoadCostingDropdown();
                SelectDDL(ddlCosting, newId.ToString());
                LoadCosting(newId);
                ShowAlert("Costing saved. Costing No: " + newNo);
            }
            catch (Exception ex)
            {
                CloseConnection();
                ShowAlert("Save error: " + ex.Message);
            }
        }
    }
}