using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.MasterConfiguration.BuyerManagement
{
    // এক Booking No-র নিচে একাধিক Buyer / Style / PO-র Fabric Booking লাইন।
    // নিজস্ব BkLine class ব্যবহার করা হয়েছে (POID/Style/Buyer সহ) — FabRow-র উপর নির্ভরশীল নয়।
    [Serializable]
    public class BkLine
    {
        public const string AllSizes = "ALL";

        public int POID { get; set; }
        public int StyleID { get; set; }
        public string PONo { get; set; }
        public string StyleNo { get; set; }
        public string BuyerName { get; set; }

        public string ColorCode { get; set; }
        public string PartName { get; set; }
        public string SizeCode { get; set; }
        public string FabricCode { get; set; }
        public string FabricName { get; set; }
        public string GSM { get; set; }
        public string FabForm { get; set; }
        public string Dia { get; set; }
        public string PartSize { get; set; }
        public string Ply { get; set; }
        public string YarnDyed { get; set; }

        public decimal KgDzn { get; set; }
        public decimal YdDzn { get; set; }
        public decimal RateDzn { get; set; }
        public int Qty { get; set; }
        public decimal LossPct { get; set; }
        public decimal ExtraPct { get; set; }
        public bool IsBooked { get; set; }

        public decimal KgPc { get { return KgDzn / 12m; } }
        public decimal YdPc { get { return YdDzn / 12m; } }
        public decimal RatePc { get { return RateDzn / 12m; } }

        public static decimal AllowanceFactorOf(decimal loss, decimal extra) { return 1m + (loss + extra) / 100m; }
        public static decimal PlyFactorOf(string part, string ply) { return (part == "Cuff" && ply == "Double") ? 2m : 1m; }

        private decimal Factor { get { return AllowanceFactorOf(LossPct, ExtraPct) * PlyFactorOf(PartName, Ply); } }
        public decimal TotalKg { get { return Qty * KgPc * Factor; } }
        public decimal TotalYd { get { return Qty * YdPc * Factor; } }
        public decimal Amount { get { return Qty * RatePc; } }
    }

    public partial class FabricBooking : System.Web.UI.Page
    {
        SqlConnection con;
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();

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
            NewBooking();
            LoadPOList();
            FillBuyers();
            LoadBookingDropdown();

            int qb;
            if (int.TryParse(Request.QueryString["bookingid"], out qb) && qb > 0)
            {
                ListItem it = ddlBooking.Items.FindByValue(qb.ToString());
                if (it != null)
                {
                    ddlBooking.ClearSelection();
                    it.Selected = true;
                    LoadBooking(qb);
                }
            }
        }

        protected void Page_PreRender(object sender, EventArgs e)
        {
            RefreshFabAmounts();
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

        private static List<string> GetChecked(CheckBoxList cbl)
        {
            List<string> l = new List<string>();
            foreach (ListItem li in cbl.Items) if (li.Selected) l.Add(li.Value);
            return l;
        }

        private static decimal DznFrom(string dznText, string pcText)
        {
            decimal dzn, pc;
            decimal.TryParse(dznText, out dzn);
            decimal.TryParse(pcText, out pc);
            if (dzn <= 0m && pc > 0m) dzn = pc * 12m;
            return dzn;
        }

        private static bool PartNeedsSize(string part)
        {
            return part == "Collar" || part == "Cuff" || part == "Flat Knit Bottom";
        }

        private static string Key(string color, string size) { return color + "\t" + size; }

        // ============================================================
        // BOOKING HEADER (new / open existing)
        // ============================================================
        private void NewBooking()
        {
            hfBookingId.Value = "0";
            txtBookingNo.Text = "(Auto Generated)";
            txtBookingDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
            txtRemarks.Text = "";
            BindFab(new List<BkLine>());
        }

        protected void btnNew_Click(object sender, EventArgs e)
        {
            NewBooking();
            if (ddlBooking.Items.Count > 0) ddlBooking.SelectedIndex = 0;
            ResetSelection();
        }

        private void LoadBookingDropdown()
        {
            try
            {
                DataTable dt = ProcTable("FabricBooking_GetList");
                ddlBooking.Items.Clear();
                ddlBooking.Items.Add(new ListItem("-- New Booking --", "0"));
                foreach (DataRow r in dt.Rows)
                    ddlBooking.Items.Add(new ListItem(GetStr(r["Display"]), GetStr(r["BookingID"])));
            }
            catch (Exception ex)
            {
                CloseConnection();
                ShowAlert("Booking list load error: " + ex.Message);
            }
        }

        protected void ddlBooking_SelectedIndexChanged(object sender, EventArgs e)
        {
            int id = IntOrZero(ddlBooking.SelectedValue);
            if (id <= 0) { NewBooking(); ResetSelection(); return; }
            LoadBooking(id);
        }

        private void LoadBooking(int bookingId)
        {
            try
            {
                DataTable m = ProcTable("FabricBooking_GetMaster", P("@BookingID", bookingId));
                if (m.Rows.Count == 0) { ShowAlert("Booking not found!"); return; }

                hfBookingId.Value = bookingId.ToString();
                txtBookingNo.Text = GetStr(m.Rows[0]["BookingNo"]);
                txtBookingDate.Text = Convert.ToDateTime(m.Rows[0]["BookingDate"]).ToString("yyyy-MM-dd");
                txtRemarks.Text = GetStr(m.Rows[0]["Remarks"]);

                List<BkLine> rows = new List<BkLine>();
                DataTable dt = ProcTable("FabricBooking_GetLines", P("@BookingID", bookingId));
                foreach (DataRow r in dt.Rows)
                {
                    rows.Add(new BkLine
                    {
                        POID = Convert.ToInt32(r["POID"]),
                        StyleID = Convert.ToInt32(r["StyleID"]),
                        PONo = GetStr(r["PONo"]),
                        StyleNo = GetStr(r["StyleNo"]),
                        BuyerName = GetStr(r["BuyerName"]),
                        ColorCode = GetStr(r["ColorCode"]),
                        PartName = GetStr(r["PartName"]),
                        SizeCode = GetStr(r["SizeCode"]),
                        FabricCode = GetStr(r["FabricCode"]),
                        FabricName = GetStr(r["FabricName"]),
                        GSM = GetStr(r["GSM"]),
                        FabForm = GetStr(r["FabricForm"]),
                        Dia = GetStr(r["Dia"]),
                        PartSize = GetStr(r["PartSize"]),
                        Ply = GetStr(r["Ply"]),
                        YarnDyed = GetStr(r["YarnDyed"]),
                        KgDzn = Convert.ToDecimal(r["KgPerDzn"]),
                        YdDzn = Convert.ToDecimal(r["YdPerDzn"]),
                        RateDzn = Convert.ToDecimal(r["RatePerDzn"]),
                        Qty = Convert.ToInt32(r["Qty"]),
                        LossPct = Convert.ToDecimal(r["LossPct"]),
                        ExtraPct = Convert.ToDecimal(r["ExtraCutPct"]),
                        IsBooked = Convert.ToBoolean(r["IsBooked"])
                    });
                }
                BindFab(rows);
                ResetSelection();
            }
            catch (Exception ex)
            {
                CloseConnection();
                ShowAlert("Booking load error: " + ex.Message);
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
            pnlEntry.Visible = false;
        }

        // Buyer/Style/PO সিলেকশন রিসেট (গ্রিডের লাইন অক্ষত)
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

        // PO সিলেক্ট করলে Style Fabrics / Colors / Sizes ও PO-র তথ্য লোড
        private void LoadPOContext(int poId)
        {
            if (poId <= 0) { ClearContext(); return; }

            try
            {
                DataTable dt = ProcTable("POEntry_GetPOHeader", P("@POID", poId));
                if (dt.Rows.Count == 0) { ShowAlert("PO not found!"); return; }
                DataRow r = dt.Rows[0];

                int styleId = IntOrZero(GetStr(r["StyleID"]));
                hfPOId.Value = poId.ToString();
                hfStyleId.Value = styleId.ToString();

                Dictionary<string, int> qty = GetQtyMap(poId);
                List<string> colors = new List<string>();
                foreach (string k in qty.Keys)
                {
                    string c = k.Split('\t')[0];
                    if (!colors.Contains(c)) colors.Add(c);
                }
                if (colors.Count == 0) colors = GetFirstColumn("POEntry_GetStyleColors", styleId);
                List<string> sizes = GetFirstColumn("POEntry_GetStyleSizes", styleId);
                DataTable fabs = ProcTable("POEntry_GetStyleFabrics", P("@StyleID", styleId));

                cblFabColors.Items.Clear();
                cblFabSizes.Items.Clear();
                cblFabrics.Items.Clear();
                foreach (string c in colors) cblFabColors.Items.Add(new ListItem(c, c));
                foreach (string s in sizes) cblFabSizes.Items.Add(new ListItem(s, s));
                foreach (DataRow dr in fabs.Rows)
                {
                    string code = GetStr(dr["FabricCode"]);
                    string name = GetStr(dr["FabricName"]);
                    cblFabrics.Items.Add(new ListItem(code + (name.Length > 0 ? " - " + name : ""), code));
                }

                pnlEntry.Visible = true;
            }
            catch (Exception ex)
            {
                CloseConnection();
                ShowAlert("Load error: " + ex.Message);
            }
        }

        private List<string> GetFirstColumn(string procName, int styleId)
        {
            List<string> list = new List<string>();
            DataTable dt = ProcTable(procName, P("@StyleID", styleId));
            foreach (DataRow dr in dt.Rows)
            {
                string v = GetStr(dr[0]);
                if (v.Length > 0 && !list.Contains(v)) list.Add(v);
            }
            return list;
        }

        private Dictionary<string, int> GetQtyMap(int poId)
        {
            Dictionary<string, int> m = new Dictionary<string, int>();
            DataTable dt = ProcTable("POEntry_GetPOColorSize", P("@POID", poId));
            foreach (DataRow dr in dt.Rows)
                m[Key(GetStr(dr["ColorCode"]), GetStr(dr["SizeCode"]))] = Convert.ToInt32(dr["Qty"]);
            return m;
        }

        private static int QtyFor(Dictionary<string, int> m, string color, string size)
        {
            if (string.IsNullOrEmpty(size) || size == BkLine.AllSizes)
            {
                int t = 0;
                foreach (KeyValuePair<string, int> kv in m)
                    if (kv.Key.StartsWith(color + "\t")) t += kv.Value;
                return t;
            }
            int q;
            return m.TryGetValue(Key(color, size), out q) ? q : 0;
        }

        // ============================================================
        // GRID
        // ============================================================
        private List<BkLine> ReadFab()
        {
            List<BkLine> list = new List<BkLine>();
            foreach (GridViewRow row in gvFab.Rows)
            {
                if (row.RowType != DataControlRowType.DataRow) continue;
                Literal lc = row.FindControl("litFabColor") as Literal;
                if (lc == null) continue;

                BkLine r = new BkLine();
                r.POID = IntOrZero(((HiddenField)row.FindControl("hfPOIdRow")).Value);
                r.StyleID = IntOrZero(((HiddenField)row.FindControl("hfStyleIdRow")).Value);
                r.PONo = ((HiddenField)row.FindControl("hfPONoRow")).Value;
                r.StyleNo = ((HiddenField)row.FindControl("hfStyleNoRow")).Value;
                r.BuyerName = ((HiddenField)row.FindControl("hfBuyerRow")).Value;
                r.ColorCode = lc.Text;
                r.PartName = ((Literal)row.FindControl("litFabPart")).Text;
                r.SizeCode = ((Literal)row.FindControl("litFabSize")).Text;
                r.FabricCode = ((Literal)row.FindControl("litFabCode")).Text;
                r.FabricName = ((HiddenField)row.FindControl("hfFabName")).Value;
                r.GSM = ((TextBox)row.FindControl("txtFabGsm")).Text.Trim();
                r.FabForm = ((DropDownList)row.FindControl("ddlFabFormRow")).SelectedValue;
                r.Dia = ((TextBox)row.FindControl("txtFabDiaRow")).Text.Trim();
                r.PartSize = ((TextBox)row.FindControl("txtFabPartSizeRow")).Text.Trim();
                r.Ply = ((DropDownList)row.FindControl("ddlFabPlyRow")).SelectedValue;
                r.YarnDyed = ((DropDownList)row.FindControl("ddlFabYarnRow")).SelectedValue;
                r.KgDzn = DznFrom(((TextBox)row.FindControl("txtFabKgDzn")).Text, ((TextBox)row.FindControl("txtFabKgPc")).Text);
                r.YdDzn = DznFrom(((TextBox)row.FindControl("txtFabYdDzn")).Text, ((TextBox)row.FindControl("txtFabYdPc")).Text);
                r.RateDzn = DznFrom(((TextBox)row.FindControl("txtFabRateDzn")).Text, ((TextBox)row.FindControl("txtFabRatePc")).Text);
                r.Qty = IntOrZero(((TextBox)row.FindControl("txtFabQty")).Text.Trim());
                r.LossPct = DecOrZero(((TextBox)row.FindControl("txtFabLoss")).Text.Trim());
                r.ExtraPct = DecOrZero(((TextBox)row.FindControl("txtFabExtra")).Text.Trim());
                r.IsBooked = ((CheckBox)row.FindControl("chkBookFab")).Checked;
                list.Add(r);
            }
            return list;
        }

        private void BindFab(List<BkLine> rows)
        {
            gvFab.DataSource = rows;
            gvFab.DataBind();
        }

        protected void gvFab_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType != DataControlRowType.DataRow) return;
            BkLine r = e.Row.DataItem as BkLine;
            if (r == null) return;
            SelectDDL((DropDownList)e.Row.FindControl("ddlFabFormRow"), r.FabForm ?? "");
            SelectDDL((DropDownList)e.Row.FindControl("ddlFabPlyRow"), r.Ply ?? "");
            SelectDDL((DropDownList)e.Row.FindControl("ddlFabYarnRow"),
                      string.IsNullOrEmpty(r.YarnDyed) ? "No" : r.YarnDyed);
        }

        protected void btnAddFab_Click(object sender, EventArgs e)
        {
            int poId = IntOrZero(hfPOId.Value);
            int styleId = IntOrZero(hfStyleId.Value);
            if (poId <= 0) { ShowAlert("Select Buyer, Style and PO first."); return; }

            List<string> colors = GetChecked(cblFabColors);
            List<string> fabrics = GetChecked(cblFabrics);
            List<string> sizes = GetChecked(cblFabSizes);
            string part = ddlFabPart.SelectedValue;

            if (colors.Count == 0) { ShowAlert("Select at least one Color."); return; }
            if (fabrics.Count == 0) { ShowAlert("Select at least one Fabric."); return; }
            if (part.Length == 0) { ShowAlert("Select a Part."); return; }
            if (sizes.Count == 0) sizes.Add(BkLine.AllSizes);

            decimal kgDzn = DznFrom(txtFabKgDzn.Text, txtFabKgPc.Text);
            decimal ydDzn = DznFrom(txtFabYdDzn.Text, txtFabYdPc.Text);
            decimal rateDzn = DznFrom(txtFabRateDzn.Text, txtFabRatePc.Text);
            decimal lossPct = DecOrZero(txtFabLoss.Text);
            decimal extraPct = DecOrZero(txtFabExtra.Text);

            if (kgDzn <= 0m && ydDzn <= 0m)
            { ShowAlert("Enter Consumption (Kg or Yds), then click Add."); return; }

            string poNo = "", styleNo = "", buyer = ddlBuyer.SelectedValue;
            string[] meta = POList.FirstOrDefault(x => x[0] == poId.ToString());
            if (meta != null) { poNo = meta[1]; styleNo = meta[2]; buyer = meta[3]; }

            DataTable fabInfo = ProcTable("POEntry_GetStyleFabrics", P("@StyleID", styleId));
            List<BkLine> rows = ReadFab();
            Dictionary<string, int> qtyMap = GetQtyMap(poId);
            int added = 0;

            foreach (string color in colors)
                foreach (string code in fabrics)
                    foreach (string size in sizes)
                    {
                        if (rows.Any(x => x.POID == poId && x.ColorCode == color && x.FabricCode == code && x.PartName == part && x.SizeCode == size)) continue;

                        string name = "", gsm = "";
                        foreach (DataRow dr in fabInfo.Rows)
                            if (GetStr(dr["FabricCode"]) == code)
                            {
                                name = GetStr(dr["FabricName"]);
                                gsm = GetStr(dr["GSM"]);
                                break;
                            }

                        rows.Add(new BkLine
                        {
                            POID = poId,
                            StyleID = styleId,
                            PONo = poNo,
                            StyleNo = styleNo,
                            BuyerName = buyer,
                            ColorCode = color,
                            PartName = part,
                            SizeCode = size,
                            FabricCode = code,
                            FabricName = name,
                            GSM = gsm,
                            FabForm = ddlFabForm.SelectedValue,
                            Dia = txtFabDia.Text.Trim(),
                            PartSize = txtFabPartSize.Text.Trim(),
                            Ply = ddlFabPly.SelectedValue,
                            YarnDyed = ddlFabYarnDyed.SelectedValue,
                            KgDzn = kgDzn,
                            YdDzn = ydDzn,
                            RateDzn = rateDzn,
                            LossPct = lossPct,
                            ExtraPct = extraPct,
                            Qty = QtyFor(qtyMap, color, size),
                            IsBooked = true
                        });
                        added++;
                    }

            BindFab(rows);
            cblFabColors.ClearSelection();
            cblFabrics.ClearSelection();
            cblFabSizes.ClearSelection();
            ddlFabForm.SelectedIndex = 0;
            ddlFabPly.SelectedIndex = 0;
            ddlFabYarnDyed.SelectedValue = "No";
            txtFabDia.Text = txtFabPartSize.Text = "";
            txtFabKgDzn.Text = txtFabKgPc.Text = txtFabYdDzn.Text = txtFabYdPc.Text =
                txtFabRateDzn.Text = txtFabRatePc.Text = txtFabLoss.Text = txtFabExtra.Text = "";

            if (added == 0)
                ShowAlert("Selected color / fabric / part / size combination(s) already added for this PO.");
        }

        protected void gvFab_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int idx;
            if (!int.TryParse(Convert.ToString(e.CommandArgument), out idx)) return;

            List<BkLine> rows = ReadFab();
            if (idx < 0 || idx >= rows.Count) return;

            if (e.CommandName == "RemoveRow")
            {
                rows.RemoveAt(idx);
            }
            else if (e.CommandName == "CopyRow")
            {
                BkLine s = rows[idx];
                rows.Insert(idx + 1, new BkLine
                {
                    POID = s.POID,
                    StyleID = s.StyleID,
                    PONo = s.PONo,
                    StyleNo = s.StyleNo,
                    BuyerName = s.BuyerName,
                    ColorCode = s.ColorCode,
                    PartName = s.PartName,
                    SizeCode = s.SizeCode,
                    FabricCode = s.FabricCode,
                    FabricName = s.FabricName,
                    GSM = s.GSM,
                    FabForm = s.FabForm,
                    Dia = s.Dia,
                    PartSize = s.PartSize,
                    Ply = s.Ply,
                    YarnDyed = s.YarnDyed,
                    KgDzn = s.KgDzn,
                    YdDzn = s.YdDzn,
                    RateDzn = s.RateDzn,
                    LossPct = s.LossPct,
                    ExtraPct = s.ExtraPct,
                    Qty = s.Qty,
                    IsBooked = s.IsBooked
                });
            }
            else return;

            BindFab(rows);
        }

        protected void btnSyncFabQty_Click(object sender, EventArgs e)
        {
            List<BkLine> rows = ReadFab();
            Dictionary<int, Dictionary<string, int>> cache = new Dictionary<int, Dictionary<string, int>>();
            foreach (BkLine r in rows)
            {
                if (!cache.ContainsKey(r.POID)) cache[r.POID] = GetQtyMap(r.POID);
                r.Qty = QtyFor(cache[r.POID], r.ColorCode, r.SizeCode);
            }
            BindFab(rows);
        }

        private void RefreshFabAmounts()
        {
            decimal sKg = 0m, sYd = 0m, sAmt = 0m;
            foreach (GridViewRow row in gvFab.Rows)
            {
                if (row.RowType != DataControlRowType.DataRow) continue;
                if (row.FindControl("txtFabQty") == null) continue;

                decimal kgPc = DznFrom(((TextBox)row.FindControl("txtFabKgDzn")).Text, ((TextBox)row.FindControl("txtFabKgPc")).Text) / 12m;
                decimal ydPc = DznFrom(((TextBox)row.FindControl("txtFabYdDzn")).Text, ((TextBox)row.FindControl("txtFabYdPc")).Text) / 12m;
                decimal ratePc = DznFrom(((TextBox)row.FindControl("txtFabRateDzn")).Text, ((TextBox)row.FindControl("txtFabRatePc")).Text) / 12m;
                int qty = IntOrZero(((TextBox)row.FindControl("txtFabQty")).Text.Trim());

                decimal f = BkLine.AllowanceFactorOf(
                    DecOrZero(((TextBox)row.FindControl("txtFabLoss")).Text),
                    DecOrZero(((TextBox)row.FindControl("txtFabExtra")).Text));
                f *= BkLine.PlyFactorOf(((Literal)row.FindControl("litFabPart")).Text,
                                        ((DropDownList)row.FindControl("ddlFabPlyRow")).SelectedValue);
                decimal tk = qty * kgPc * f, ty = qty * ydPc * f, am = qty * ratePc;
                ((Label)row.FindControl("lblFabTotalKg")).Text = tk.ToString("N2");
                ((Label)row.FindControl("lblFabTotalYd")).Text = ty.ToString("N2");
                ((Label)row.FindControl("lblFabAmt")).Text = am.ToString("N2");
                sKg += tk; sYd += ty; sAmt += am;
            }
            lblFabSumKg.Text = sKg.ToString("N2");
            lblFabSumYd.Text = sYd.ToString("N2");
            lblFabSumAmt.Text = sAmt.ToString("N2");
        }

        // ============================================================
        // VALIDATE + SAVE
        // ============================================================
        private bool ValidateFab(List<BkLine> rows)
        {
            foreach (BkLine fr in rows)
            {
                if (!fr.IsBooked) continue;

                string tag = fr.PONo + " / " + fr.ColorCode + " / " + fr.PartName + " / " + fr.FabricCode
                           + (fr.SizeCode != BkLine.AllSizes ? " / " + fr.SizeCode : "");

                if (string.IsNullOrWhiteSpace(fr.FabForm))
                { ShowAlert("Fabric booking [" + tag + "]: select Fabric Form (Open / Tube)."); return false; }
                if (string.IsNullOrWhiteSpace(fr.Dia))
                { ShowAlert("Fabric booking [" + tag + "]: enter Dia."); return false; }
                if (PartNeedsSize(fr.PartName) && string.IsNullOrWhiteSpace(fr.PartSize))
                { ShowAlert("Fabric booking [" + tag + "]: enter " + fr.PartName + " size."); return false; }
                if (fr.PartName == "Cuff" && string.IsNullOrWhiteSpace(fr.Ply))
                { ShowAlert("Fabric booking [" + tag + "]: select Cuff Single or Double."); return false; }
                if (fr.KgDzn <= 0m && fr.YdDzn <= 0m)
                { ShowAlert("Fabric booking [" + tag + "]: enter consumption (Kg or Yds)."); return false; }
            }
            return true;
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            DateTime bdate;
            if (!DateTime.TryParse(txtBookingDate.Text, out bdate)) { ShowAlert("Enter Booking Date."); return; }

            List<BkLine> rows = ReadFab();
            if (rows.Count == 0) { ShowAlert("Add at least one fabric booking line."); return; }
            if (!ValidateFab(rows)) return;

            int bookingId = IntOrZero(hfBookingId.Value);
            int newId = bookingId;
            string newNo = "";

            try
            {
                con = conn.openConnection();
                using (SqlTransaction tx = con.BeginTransaction())
                {
                    try
                    {
                        using (SqlCommand c = Proc("FabricBooking_SaveMaster", tx))
                        {
                            c.Parameters.Add(P("@BookingID", bookingId));
                            c.Parameters.Add(P("@BookingDate", bdate.Date));
                            c.Parameters.Add(P("@Remarks", NullIfEmpty(txtRemarks.Text)));
                            c.Parameters.Add(P("@UserID", CurrentUserId));
                            using (SqlDataReader rd = c.ExecuteReader())
                            {
                                if (rd.Read())
                                {
                                    newId = Convert.ToInt32(rd["BookingID"]);
                                    newNo = Convert.ToString(rd["BookingNo"]);
                                }
                            }
                        }

                        using (SqlCommand c = Proc("FabricBooking_ClearLines", tx))
                        {
                            c.Parameters.Add(P("@BookingID", newId));
                            c.ExecuteNonQuery();
                        }

                        int sort = 0;
                        foreach (BkLine fr in rows)
                        {
                            sort++;
                            using (SqlCommand c = Proc("FabricBooking_SaveLine", tx))
                            {
                                c.Parameters.Add(P("@BookingID", newId));
                                c.Parameters.Add(P("@POID", fr.POID));
                                c.Parameters.Add(P("@StyleID", fr.StyleID));
                                c.Parameters.Add(P("@PONo", NullIfEmpty(fr.PONo)));
                                c.Parameters.Add(P("@StyleNo", NullIfEmpty(fr.StyleNo)));
                                c.Parameters.Add(P("@BuyerName", NullIfEmpty(fr.BuyerName)));
                                c.Parameters.Add(P("@ColorCode", fr.ColorCode));
                                c.Parameters.Add(P("@PartName", string.IsNullOrEmpty(fr.PartName) ? "Body" : fr.PartName));
                                c.Parameters.Add(P("@SizeCode", string.IsNullOrEmpty(fr.SizeCode) ? BkLine.AllSizes : fr.SizeCode));
                                c.Parameters.Add(P("@FabricCode", fr.FabricCode));
                                c.Parameters.Add(P("@FabricName", NullIfEmpty(fr.FabricName)));
                                c.Parameters.Add(P("@GSM", NullIfEmpty(fr.GSM)));
                                c.Parameters.Add(P("@FabricForm", NullIfEmpty(fr.FabForm)));
                                c.Parameters.Add(P("@Dia", NullIfEmpty(fr.Dia)));
                                c.Parameters.Add(P("@PartSize", NullIfEmpty(fr.PartSize)));
                                c.Parameters.Add(P("@Ply", NullIfEmpty(fr.Ply)));
                                c.Parameters.Add(P("@YarnDyed", string.IsNullOrEmpty(fr.YarnDyed) ? "No" : fr.YarnDyed));
                                c.Parameters.Add(PD("@KgPerDzn", fr.KgDzn));
                                c.Parameters.Add(PD("@YdPerDzn", fr.YdDzn));
                                c.Parameters.Add(PD("@RatePerDzn", fr.RateDzn));
                                c.Parameters.Add(P("@Qty", fr.Qty));
                                c.Parameters.Add(PD("@LossPct", fr.LossPct));
                                c.Parameters.Add(PD("@ExtraCutPct", fr.ExtraPct));
                                c.Parameters.Add(PD("@TotalKg", fr.TotalKg));
                                c.Parameters.Add(PD("@TotalYd", fr.TotalYd));
                                c.Parameters.Add(PD("@Amount", fr.Amount));
                                c.Parameters.Add(P("@IsBooked", fr.IsBooked));
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

                LoadBookingDropdown();
                SelectDDL(ddlBooking, newId.ToString());
                LoadBooking(newId);
                ShowAlert("Fabric booking saved. Booking No: " + newNo);
            }
            catch (Exception ex)
            {
                CloseConnection();
                ShowAlert("Save error: " + ex.Message);
            }
        }
    }
}
