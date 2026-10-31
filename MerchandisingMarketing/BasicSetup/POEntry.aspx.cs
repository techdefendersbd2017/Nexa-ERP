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
    // One row of the Embellishment Work Order grid
    public class EmbRow
    {
        public string ColorCode { get; set; }
        public string EmbType { get; set; }
        public string Description { get; set; }
        public string Placement { get; set; }
        public string Supplier { get; set; }
        public int Qty { get; set; }
        public decimal Rate { get; set; }
        public decimal Amount { get; set; }
    }

    public partial class POEntry : System.Web.UI.Page
    {
        // ============================================================
        // CONNECTION
        // ============================================================
        SqlConnection con;
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();

        // Color x Size matrix (in-memory form of the grid)
        private class MatrixData
        {
            public List<string> Colors = new List<string>();
            public List<string> Sizes = new List<string>();
            public Dictionary<string, int> Qty = new Dictionary<string, int>();
        }
        private MatrixData _bindMatrix;
        private static string Key(string color, string size) { return color + "\t" + size; }

        private int CurrentUserId
        {
            get
            {
                if (Session["UserID"] != null) return Convert.ToInt32(Session["UserID"]);
                return 1;
            }
        }

        private string CurrentUserName
        {
            get
            {
                if (Session["UserName"] != null) return Convert.ToString(Session["UserName"]);
                return "User";
            }
        }

        // ============================================================
        // PAGE LOAD / PRE-RENDER
        // ============================================================
        protected void Page_Load(object sender, EventArgs e)
        {
            // HTML readonly (NOT the server ReadOnly property) so JS can still update the value and it posts back
            txtPOQty.Attributes["readonly"] = "readonly";
            txtTotalValue.Attributes["readonly"] = "readonly";

            if (!IsPostBack)
            {
                lblUser.Text = CurrentUserName;
                txtPODate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                txtPONo.Text = GeneratePONo();
                pnlList.Visible = true;
                pnlEntry.Visible = false;
                hfPOId.Value = "0";
                hfStyleId.Value = "0";
                ViewState["POID"] = null;
                LoadPOList();
            }
        }

        // Every render: refresh row/column totals, PO Qty, Total Value, Fabric/Acc qty, Embellishment amount
        protected void Page_PreRender(object sender, EventArgs e)
        {
            if (!pnlEntry.Visible) return;

            decimal price = DecOrZero(txtUnitPrice.Text);
            int total = RefreshMatrixTotals(price);

            txtPOQty.Text = total.ToString();
            txtTotalValue.Text = (total * price).ToString("N2");

            int styleId;
            if (int.TryParse(hfStyleId.Value, out styleId) && styleId > 0)
            {
                int last = ViewState["LastQty"] != null ? Convert.ToInt32(ViewState["LastQty"]) : -1;
                if (last != total)
                {
                    LoadFabricGrid(styleId);
                    LoadAccGrid(styleId);
                    ViewState["LastQty"] = total;
                }
            }

            RefreshEmbAmounts();
        }

        // ============================================================
        // HELPERS
        // ============================================================
        private void ShowAlert(string msg)
        {
            string safe = (msg ?? "").Replace("'", "").Replace("\r", "").Replace("\n", " ");
            ScriptManager.RegisterStartupScript(this, this.GetType(),
                Guid.NewGuid().ToString("N"),
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

        private object NullIfZero(string s)
        {
            int v;
            if (int.TryParse(s, out v) && v > 0) return v;
            return DBNull.Value;
        }

        private object DateOrNull(string s)
        {
            DateTime d;
            if (DateTime.TryParse(s, out d)) return d;
            return DBNull.Value;
        }

        private decimal DecOrZero(string s)
        {
            decimal d;
            return decimal.TryParse(s, out d) ? d : 0m;
        }

        private int IntOrZero(string s)
        {
            int v;
            return int.TryParse(s, out v) ? v : 0;
        }

        private string GetStr(object o) => o == null || o == DBNull.Value ? "" : o.ToString();

        // ============================================================
        // PO STATUS HELPERS
        // ============================================================
        public string GetPOStatusCss(object v)
        {
            int s = IntOrZero(GetStr(v));
            switch (s)
            {
                case 0: return "bg-secondary";
                case 1: return "bg-info";
                case 2: return "bg-primary";
                case 3: return "bg-warning text-dark";
                case 4: return "bg-success";
                case 5: return "bg-danger";
                default: return "bg-secondary";
            }
        }

        public string GetPOStatusText(object v)
        {
            int s = IntOrZero(GetStr(v));
            switch (s)
            {
                case 0: return "Draft";
                case 1: return "Confirmed";
                case 2: return "Running";
                case 3: return "Shipped";
                case 4: return "Closed";
                case 5: return "Cancelled";
                default: return "Draft";
            }
        }

        // ============================================================
        // PO LIST
        // ============================================================
        private void LoadPOList()
        {
            try
            {
                con = conn.openConnection();
                string query = @"
                    SELECT  p.POID, p.PONo, p.PODate,
                            s.StyleNo,
                            ISNULL(b.BuyerName,'') AS BuyerName,
                            p.POQty, p.Currency, p.UnitPrice,
                            p.POStatus
                    FROM    dbo.POHeader p
                    LEFT JOIN dbo.StyleMaster s ON s.StyleID = p.StyleID
                    LEFT JOIN dbo.Buyer b       ON b.BuyerID = s.BuyerID
                    WHERE   ISNULL(p.IsActive,1) = 1";

                string search = txtSearch.Text.Trim();
                if (search.Length > 0)
                    query += " AND (p.PONo LIKE @Q OR p.BuyerPORef LIKE @Q)";

                int status = -1;
                int.TryParse(ddlStatusFilter.SelectedValue, out status);
                if (status >= 0)
                    query += " AND p.POStatus = @POStatus";

                query += " ORDER BY p.POID DESC";

                using (SqlCommand c = new SqlCommand(query, con))
                {
                    if (search.Length > 0)
                        c.Parameters.AddWithValue("@Q", "%" + search + "%");
                    if (status >= 0)
                        c.Parameters.AddWithValue("@POStatus", status);

                    SqlDataAdapter da = new SqlDataAdapter(c);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    GridView1.DataSource = dt;
                    GridView1.DataBind();
                }
                CloseConnection();
            }
            catch (Exception ex)
            {
                CloseConnection();
                ShowAlert("List load error: " + ex.Message);
            }
        }

        // ============================================================
        // LIST PANEL EVENTS
        // ============================================================
        protected void btnAddNew_Click(object sender, EventArgs e)
        {
            ClearForm();
            LoadStyleDropdown();
            pnlList.Visible = false;
            pnlEntry.Visible = true;
            ViewState["POID"] = null;
            hfPOId.Value = "0";
            ShowAlert("New PO Entry form opened.");
        }

        protected void btnSearch_Click(object sender, EventArgs e) { LoadPOList(); }

        protected void btnClearFilter_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            ddlStatusFilter.SelectedIndex = 0;
            LoadPOList();
        }

        protected void btnBackToList_Click(object sender, EventArgs e)
        {
            pnlEntry.Visible = false;
            pnlList.Visible = true;
            LoadPOList();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ClearForm();
            ShowAlert("Form reset.");
        }

        // ============================================================
        // STYLE DROPDOWN
        // ============================================================
        private void LoadStyleDropdown()
        {
            try
            {
                con = conn.openConnection();
                string sql = @"
                    SELECT s.StyleID,
                           s.StyleNo + ' - ' + ISNULL(s.StyleName,'') +
                           ' (' + ISNULL(b.BuyerName,'') + ')' AS DisplayText
                    FROM   dbo.StyleMaster s
                    LEFT JOIN dbo.Buyer b ON b.BuyerID = s.BuyerID
                    WHERE  s.IsActive = 1
                    ORDER BY s.StyleNo";
                using (SqlCommand c = new SqlCommand(sql, con))
                {
                    SqlDataAdapter da = new SqlDataAdapter(c);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlStyle.DataSource = dt;
                    ddlStyle.DataTextField = "DisplayText";
                    ddlStyle.DataValueField = "StyleID";
                    ddlStyle.DataBind();
                    ddlStyle.Items.Insert(0, new ListItem("-- Select Style --", "0"));
                }
                CloseConnection();
            }
            catch (Exception ex)
            {
                CloseConnection();
                ShowAlert("Style load error: " + ex.Message);
            }
        }

        // ============================================================
        // STYLE SELECT → SNAPSHOT
        // ============================================================
        protected void ddlStyle_SelectedIndexChanged(object sender, EventArgs e)
        {
            // style changed → old matrix / embellishment no longer valid
            BindMatrix(new MatrixData());
            BindEmb(new List<EmbRow>());
            ViewState["LastQty"] = null;

            int styleId;
            if (!int.TryParse(ddlStyle.SelectedValue, out styleId) || styleId == 0)
            {
                hfStyleId.Value = "0";
                ClearStyleSnapshot();
                ClearStyleLists();
                gvFabric.DataSource = null; gvFabric.DataBind();
                gvAcc.DataSource = null; gvAcc.DataBind();
                return;
            }

            hfStyleId.Value = styleId.ToString();
            LoadStyleSnapshot(styleId);
            PopulateStyleLists(styleId);
        }

        private void LoadStyleSnapshot(int styleId)
        {
            try
            {
                con = conn.openConnection();

                string sql = @"
                    SELECT s.StyleNo, s.StyleName, s.StyleStatus, s.RevisionNo,
                           s.TargetPrice, s.Currency, s.KnitWoven,
                           s.FabricType, s.SpecGSM, s.SpecComposition,
                           s.SeasonYear,
                           ISNULL(b.BuyerName,'')  AS BuyerName,
                           ISNULL(sn.SeasonName,'') AS SeasonName,
                           ISNULL(br.BrandName,'')  AS BrandName,
                           ISNULL(ag.AgentName,'')  AS AgentName,
                           ISNULL(u.UserName,'')    AS MerchName
                    FROM   dbo.StyleMaster s
                    LEFT JOIN dbo.Buyer  b  ON b.BuyerID  = s.BuyerID
                    LEFT JOIN dbo.Season sn ON sn.SeasonID = s.SeasonID
                    LEFT JOIN dbo.Brand  br ON br.BrandID  = s.BrandID
                    LEFT JOIN dbo.Agent  ag ON ag.AgentID  = s.AgentID
                    LEFT JOIN dbo.AppUser  u  ON u.UserID    = s.MerchandiserID
                    WHERE  s.StyleID = @ID";

                using (SqlCommand c = new SqlCommand(sql, con))
                {
                    c.Parameters.AddWithValue("@ID", styleId);
                    using (SqlDataReader r = c.ExecuteReader())
                    {
                        if (!r.Read())
                        {
                            ShowAlert("Style not found!");
                            r.Close();
                            CloseConnection();
                            return;
                        }

                        lblStyleNoName.Text = GetStr(r["StyleNo"]) + " — " + GetStr(r["StyleName"]);
                        lblBuyer.Text = GetStr(r["BuyerName"]);
                        lblBrand.Text = GetStr(r["BrandName"]);
                        lblAgent.Text = GetStr(r["AgentName"]);
                        lblSeason.Text = GetStr(r["SeasonName"]) + " / " + GetStr(r["SeasonYear"]);
                        lblMerch.Text = GetStr(r["MerchName"]);
                        lblKnitWoven.Text = GetStr(r["KnitWoven"]);
                        lblFabric.Text = GetStr(r["FabricType"]) + " / " + GetStr(r["SpecGSM"]);
                        lblComposition.Text = GetStr(r["SpecComposition"]);
                        lblTargetPrice.Text = GetStr(r["Currency"]) + " " + GetStr(r["TargetPrice"]);
                        lblStyleRev.Text = GetStr(r["RevisionNo"]);

                        string rawStatus = GetStr(r["StyleStatus"]);
                        string displayStatus;
                        switch (rawStatus)
                        {
                            case "A": displayStatus = "Active"; break;
                            case "D": displayStatus = "Draft"; break;
                            case "I": displayStatus = "Inactive"; break;
                            case "C": displayStatus = "Closed"; break;
                            default: displayStatus = rawStatus; break;
                        }
                        lblStyleStatus.Text = displayStatus;
                        lblStyleStatus.CssClass = "badge " + (rawStatus == "A" ? "bg-success" : "bg-secondary");

                        btnSave.Enabled = (rawStatus == "A");
                        if (rawStatus != "A")
                            ShowAlert("⚠️ Style is not Active. PO cannot be saved.");

                        imgFront.Visible = false;
                        imgBack.Visible = false;
                        imgSketch.Visible = false;
                    }
                }
                CloseConnection();
            }
            catch (Exception ex)
            {
                CloseConnection();
                ShowAlert("Snapshot error: " + ex.Message);
            }
        }

        // ============================================================
        // STYLE COLOR / SIZE LISTS (multi-select dropdowns)
        // ============================================================
        private List<string> GetStyleCodes(string sql, int styleId)
        {
            List<string> list = new List<string>();
            con = conn.openConnection();
            using (SqlCommand c = new SqlCommand(sql, con))
            {
                c.Parameters.AddWithValue("@ID", styleId);
                using (SqlDataReader r = c.ExecuteReader())
                {
                    while (r.Read())
                    {
                        string v = GetStr(r[0]);
                        if (v.Length > 0 && !list.Contains(v)) list.Add(v);
                    }
                }
            }
            CloseConnection();
            return list;
        }

        private List<string> GetStyleColors(int styleId)
        {
            return GetStyleCodes(@"SELECT ColorCode FROM dbo.StyleColor
                                   WHERE StyleID=@ID AND ISNULL(IsActive,1)=1
                                   ORDER BY SortOrder, StyleColorID", styleId);
        }

        private List<string> GetStyleSizes(int styleId)
        {
            return GetStyleCodes(@"SELECT SizeCode FROM dbo.StyleSize
                                   WHERE StyleID=@ID AND ISNULL(IsActive,1)=1
                                   ORDER BY SortOrder, StyleSizeID", styleId);
        }

        private void PopulateStyleLists(int styleId)
        {
            try
            {
                List<string> colors = GetStyleColors(styleId);
                List<string> sizes = GetStyleSizes(styleId);

                cblColors.Items.Clear();
                cblEmbColors.Items.Clear();
                cblSizes.Items.Clear();
                foreach (string c in colors)
                {
                    cblColors.Items.Add(new ListItem(c, c));
                    cblEmbColors.Items.Add(new ListItem(c, c));
                }
                foreach (string s in sizes)
                    cblSizes.Items.Add(new ListItem(s, s));
            }
            catch (Exception ex)
            {
                CloseConnection();
                ShowAlert("Color/Size load error: " + ex.Message);
            }
        }

        private void ClearStyleLists()
        {
            cblColors.Items.Clear();
            cblSizes.Items.Clear();
            cblEmbColors.Items.Clear();
        }

        private static List<string> GetChecked(CheckBoxList cbl)
        {
            List<string> l = new List<string>();
            foreach (ListItem li in cbl.Items) if (li.Selected) l.Add(li.Value);
            return l;
        }

        // ============================================================
        // COLOR x SIZE MATRIX
        // ============================================================
        private MatrixData ReadMatrix()
        {
            MatrixData m = new MatrixData();

            foreach (RepeaterItem it in rptSizeHead.Items)
            {
                Literal l = it.FindControl("litSize") as Literal;
                if (l != null) m.Sizes.Add(l.Text);
            }

            foreach (RepeaterItem row in rptMatrix.Items)
            {
                Literal lc = row.FindControl("litColor") as Literal;
                if (lc == null) continue;
                string color = lc.Text;
                m.Colors.Add(color);

                Repeater cells = row.FindControl("rptCells") as Repeater;
                if (cells == null) continue;
                for (int j = 0; j < cells.Items.Count && j < m.Sizes.Count; j++)
                {
                    TextBox tb = cells.Items[j].FindControl("txtCell") as TextBox;
                    m.Qty[Key(color, m.Sizes[j])] = tb != null ? IntOrZero(tb.Text.Trim()) : 0;
                }
            }
            return m;
        }

        private void BindMatrix(MatrixData m)
        {
            // matrix needs at least one color AND one size
            if (m.Colors.Count == 0 || m.Sizes.Count == 0)
            {
                m.Colors.Clear();
                m.Sizes.Clear();
            }

            _bindMatrix = m;

            rptSizeHead.DataSource = m.Sizes;
            rptSizeHead.DataBind();
            rptSizeFoot.DataSource = m.Sizes;
            rptSizeFoot.DataBind();
            rptMatrix.DataSource = m.Colors;
            rptMatrix.DataBind();

            bool has = m.Colors.Count > 0;
            pnlMatrix.CssClass = has ? "" : "d-none";
            lblMatrixEmpty.Visible = !has;
        }

        protected void rptMatrix_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem) return;
            if (_bindMatrix == null) return;

            string color = (string)e.Item.DataItem;
            ((Literal)e.Item.FindControl("litColor")).Text = color;
            ((LinkButton)e.Item.FindControl("btnRemoveColor")).CommandArgument = color;

            List<string> cells = new List<string>();
            foreach (string size in _bindMatrix.Sizes)
            {
                int q;
                _bindMatrix.Qty.TryGetValue(Key(color, size), out q);
                cells.Add(q > 0 ? q.ToString() : "");
            }
            Repeater rc = (Repeater)e.Item.FindControl("rptCells");
            rc.DataSource = cells;
            rc.DataBind();
        }

        protected void rptMatrix_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "RemoveColor") return;
            MatrixData m = ReadMatrix();
            m.Colors.Remove(Convert.ToString(e.CommandArgument));
            BindMatrix(m);
            SyncEmbDefaults();
        }

        protected void rptSizeHead_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "RemoveSize") return;
            MatrixData m = ReadMatrix();
            m.Sizes.Remove(Convert.ToString(e.CommandArgument));
            BindMatrix(m);
        }

        // recompute row / column / grand totals on the server (also what is saved), returns total pcs
        private int RefreshMatrixTotals(decimal price)
        {
            int grand = 0;
            int sizeCount = rptSizeHead.Items.Count;
            int[] colTot = new int[sizeCount];

            foreach (RepeaterItem row in rptMatrix.Items)
            {
                Repeater cells = row.FindControl("rptCells") as Repeater;
                if (cells == null) continue;
                int rowTot = 0;
                for (int j = 0; j < cells.Items.Count && j < sizeCount; j++)
                {
                    TextBox tb = cells.Items[j].FindControl("txtCell") as TextBox;
                    int q = tb != null ? IntOrZero(tb.Text.Trim()) : 0;
                    rowTot += q;
                    colTot[j] += q;
                }
                grand += rowTot;
                ((Label)row.FindControl("lblRowTotal")).Text = rowTot.ToString("N0");
                ((Label)row.FindControl("lblRowValue")).Text = (rowTot * price).ToString("N2");
            }

            for (int j = 0; j < rptSizeFoot.Items.Count && j < sizeCount; j++)
                ((Label)rptSizeFoot.Items[j].FindControl("lblColTotal")).Text = colTot[j].ToString("N0");

            lblGrandQty.Text = grand.ToString("N0");
            lblGrandValue.Text = (grand * price).ToString("N2");
            return grand;
        }

        // ADD button (Qty & Price tab)
        protected void btnAddQty_Click(object sender, EventArgs e)
        {
            MatrixData m = ReadMatrix();

            List<string> colors = MergeSelection(cblColors, m.Colors);
            List<string> sizes = MergeSelection(cblSizes, m.Sizes);

            if (colors.Count == 0 || sizes.Count == 0)
            {
                ShowAlert("Select at least one Color and one Size, then click Add.");
                return;
            }

            m.Colors = colors;
            m.Sizes = sizes;
            BindMatrix(m);

            cblColors.ClearSelection();
            cblSizes.ClearSelection();
        }

        // selected items + already-existing items, kept in Style order
        private static List<string> MergeSelection(CheckBoxList cbl, List<string> existing)
        {
            List<string> result = new List<string>();
            foreach (ListItem li in cbl.Items)
                if (li.Selected || existing.Contains(li.Value)) result.Add(li.Value);
            foreach (string x in existing)
                if (!result.Contains(x)) result.Add(x);
            return result;
        }

        private static int ColorTotal(MatrixData m, string color)
        {
            int t = 0;
            foreach (string s in m.Sizes)
            {
                int q;
                if (m.Qty.TryGetValue(Key(color, s), out q)) t += q;
            }
            return t;
        }

        // ============================================================
        // FABRIC GRID
        // ============================================================
        private void LoadFabricGrid(int styleId)
        {
            int poQty = IntOrZero(txtPOQty.Text);
            try
            {
                con = conn.openConnection();
                string sql = @"
                    SELECT  FabricCode, FabricName, Composition, GSM, ColorName,
                            Consumption, WastagePercent, UnitCode
                    FROM    dbo.StyleFabric
                    WHERE   StyleID = @ID
                    ORDER BY SortOrder, StyleFabricID";

                using (SqlCommand c = new SqlCommand(sql, con))
                {
                    c.Parameters.AddWithValue("@ID", styleId);

                    DataTable dt = new DataTable();
                    dt.Columns.Add("FabricCode", typeof(string));
                    dt.Columns.Add("FabricName", typeof(string));
                    dt.Columns.Add("Composition", typeof(string));
                    dt.Columns.Add("GSM", typeof(string));
                    dt.Columns.Add("ColorName", typeof(string));
                    dt.Columns.Add("Consumption", typeof(decimal));
                    dt.Columns.Add("Unit", typeof(string));
                    dt.Columns.Add("TotalQty", typeof(decimal));

                    using (SqlDataReader r = c.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            decimal cons = r["Consumption"] != DBNull.Value ? Convert.ToDecimal(r["Consumption"]) : 0m;
                            DataRow dr = dt.NewRow();
                            dr["FabricCode"] = GetStr(r["FabricCode"]);
                            dr["FabricName"] = GetStr(r["FabricName"]);
                            dr["Composition"] = GetStr(r["Composition"]);
                            dr["GSM"] = GetStr(r["GSM"]);
                            dr["ColorName"] = GetStr(r["ColorName"]);
                            dr["Consumption"] = cons;
                            dr["Unit"] = GetStr(r["UnitCode"]);
                            dr["TotalQty"] = poQty * cons;
                            dt.Rows.Add(dr);
                        }
                    }

                    gvFabric.DataSource = dt;
                    gvFabric.DataBind();
                }
                CloseConnection();
            }
            catch (Exception ex)
            {
                CloseConnection();
                ShowAlert("Fabric grid error: " + ex.Message);
            }
        }

        // ============================================================
        // ACCESSORIES GRID
        // ============================================================
        private void LoadAccGrid(int styleId)
        {
            int poQty = IntOrZero(txtPOQty.Text);
            try
            {
                con = conn.openConnection();
                string sql = @"
                    SELECT  ItemCode, ItemName, AccTypeName, SizeColor,
                            Consumption, UnitCode, WastagePercent, Supplier
                    FROM    dbo.StyleAccessories
                    WHERE   StyleID = @ID
                    ORDER BY SortOrder, StyleAccID";

                using (SqlCommand c = new SqlCommand(sql, con))
                {
                    c.Parameters.AddWithValue("@ID", styleId);

                    DataTable dt = new DataTable();
                    dt.Columns.Add("ItemCode", typeof(string));
                    dt.Columns.Add("ItemName", typeof(string));
                    dt.Columns.Add("ItemType", typeof(string));
                    dt.Columns.Add("SizeColor", typeof(string));
                    dt.Columns.Add("Consumption", typeof(decimal));
                    dt.Columns.Add("Unit", typeof(string));
                    dt.Columns.Add("WastagePercent", typeof(decimal));
                    dt.Columns.Add("TotalQty", typeof(decimal));

                    using (SqlDataReader r = c.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            decimal cons = r["Consumption"] != DBNull.Value ? Convert.ToDecimal(r["Consumption"]) : 0m;
                            decimal waste = r["WastagePercent"] != DBNull.Value ? Convert.ToDecimal(r["WastagePercent"]) : 0m;
                            DataRow dr = dt.NewRow();
                            dr["ItemCode"] = GetStr(r["ItemCode"]);
                            dr["ItemName"] = GetStr(r["ItemName"]);
                            dr["ItemType"] = GetStr(r["AccTypeName"]);
                            dr["SizeColor"] = GetStr(r["SizeColor"]);
                            dr["Consumption"] = cons;
                            dr["Unit"] = GetStr(r["UnitCode"]);
                            dr["WastagePercent"] = waste;
                            dr["TotalQty"] = poQty * cons * (1 + waste / 100m);
                            dt.Rows.Add(dr);
                        }
                    }

                    gvAcc.DataSource = dt;
                    gvAcc.DataBind();
                }
                CloseConnection();
            }
            catch (Exception ex)
            {
                CloseConnection();
                ShowAlert("Accessories grid error: " + ex.Message);
            }
        }

        // ============================================================
        // EMBELLISHMENT WORK ORDER
        // ============================================================
        private List<EmbRow> ReadEmb()
        {
            List<EmbRow> list = new List<EmbRow>();
            foreach (GridViewRow row in gvEmb.Rows)
            {
                if (row.RowType != DataControlRowType.DataRow) continue;
                Literal lc = row.FindControl("litEmbColor") as Literal;
                if (lc == null) continue;

                EmbRow r = new EmbRow();
                r.ColorCode = lc.Text;
                r.EmbType = ((DropDownList)row.FindControl("ddlEmbType")).SelectedValue;
                r.Description = ((TextBox)row.FindControl("txtEmbDesc")).Text.Trim();
                r.Placement = ((DropDownList)row.FindControl("ddlEmbPlace")).SelectedValue;
                r.Supplier = ((TextBox)row.FindControl("txtEmbSupplier")).Text.Trim();
                r.Qty = IntOrZero(((TextBox)row.FindControl("txtEmbQty")).Text.Trim());
                r.Rate = DecOrZero(((TextBox)row.FindControl("txtEmbRate")).Text.Trim());
                r.Amount = r.Qty * r.Rate;
                list.Add(r);
            }
            return list;
        }

        private void BindEmb(List<EmbRow> rows)
        {
            foreach (EmbRow r in rows) r.Amount = r.Qty * r.Rate;
            gvEmb.DataSource = rows;
            gvEmb.DataBind();
        }

        protected void gvEmb_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType != DataControlRowType.DataRow) return;
            EmbRow r = e.Row.DataItem as EmbRow;
            if (r == null) return;
            SelectDDL((DropDownList)e.Row.FindControl("ddlEmbType"), r.EmbType ?? "");
            SelectDDL((DropDownList)e.Row.FindControl("ddlEmbPlace"), r.Placement ?? "");
        }

        protected void btnAddEmb_Click(object sender, EventArgs e)
        {
            List<string> selected = GetChecked(cblEmbColors);
            if (selected.Count == 0)
            {
                ShowAlert("Select at least one Color, then click Add.");
                return;
            }

            List<EmbRow> rows = ReadEmb();
            MatrixData m = ReadMatrix();
            int added = 0;
            foreach (string color in selected)
            {
                if (rows.Any(x => x.ColorCode == color)) continue;
                rows.Add(new EmbRow { ColorCode = color, EmbType = "", Description = "", Placement = "", Supplier = "", Qty = ColorTotal(m, color), Rate = 0m });
                added++;
            }

            BindEmb(rows);
            cblEmbColors.ClearSelection();

            if (added == 0)
                ShowAlert("Selected color(s) already added. Use the copy icon on a row to add another embellishment for the same color.");
        }

        protected void gvEmb_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int idx;
            if (!int.TryParse(Convert.ToString(e.CommandArgument), out idx)) return;

            List<EmbRow> rows = ReadEmb();
            if (idx < 0 || idx >= rows.Count) return;

            if (e.CommandName == "RemoveRow")
            {
                rows.RemoveAt(idx);
            }
            else if (e.CommandName == "CopyRow")
            {
                EmbRow src = rows[idx];
                rows.Insert(idx + 1, new EmbRow
                {
                    ColorCode = src.ColorCode,
                    EmbType = "",
                    Description = "",
                    Placement = "",
                    Supplier = src.Supplier,
                    Qty = src.Qty,
                    Rate = 0m
                });
            }
            else return;

            BindEmb(rows);
        }

        // after a color row is removed from the qty matrix, keep embellishment rows as they are (user decides)
        private void SyncEmbDefaults() { }

        private void RefreshEmbAmounts()
        {
            decimal total = 0m;
            foreach (GridViewRow row in gvEmb.Rows)
            {
                if (row.RowType != DataControlRowType.DataRow) continue;
                TextBox q = row.FindControl("txtEmbQty") as TextBox;
                TextBox r = row.FindControl("txtEmbRate") as TextBox;
                Label a = row.FindControl("lblEmbAmt") as Label;
                if (q == null || r == null || a == null) continue;
                decimal amt = IntOrZero(q.Text.Trim()) * DecOrZero(r.Text.Trim());
                a.Text = amt.ToString("N2");
                total += amt;
            }
            lblEmbTotal.Text = total.ToString("N2");
        }

        private void LoadEmbFromPO(int poId)
        {
            List<EmbRow> rows = new List<EmbRow>();
            try
            {
                con = conn.openConnection();
                using (SqlCommand c = new SqlCommand(@"
                    SELECT ColorCode, EmbType, Description, Placement, Supplier, Qty, Rate
                    FROM   dbo.POEmbellishment
                    WHERE  POID=@ID
                    ORDER BY SortOrder, EmbID", con))
                {
                    c.Parameters.AddWithValue("@ID", poId);
                    using (SqlDataReader r = c.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            rows.Add(new EmbRow
                            {
                                ColorCode = GetStr(r["ColorCode"]),
                                EmbType = GetStr(r["EmbType"]),
                                Description = GetStr(r["Description"]),
                                Placement = GetStr(r["Placement"]),
                                Supplier = GetStr(r["Supplier"]),
                                Qty = r["Qty"] != DBNull.Value ? Convert.ToInt32(r["Qty"]) : 0,
                                Rate = r["Rate"] != DBNull.Value ? Convert.ToDecimal(r["Rate"]) : 0m
                            });
                        }
                    }
                }
                CloseConnection();
            }
            catch (Exception ex)
            {
                CloseConnection();
                ShowAlert("Embellishment load error: " + ex.Message);
            }
            BindEmb(rows);
        }

        // ============================================================
        // GRIDVIEW : EDIT / DELETE
        // ============================================================
        protected void GridView1_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int poId;
            if (!int.TryParse(Convert.ToString(e.CommandArgument), out poId)) return;

            if (e.CommandName == "EditRow")
            {
                pnlList.Visible = false;
                pnlEntry.Visible = true;
                LoadPOForEdit(poId);
                ShowAlert("PO loaded for editing.");
            }
            else if (e.CommandName == "DeleteRow")
            {
                DeletePO(poId);
            }
        }

        private void DeletePO(int poId)
        {
            try
            {
                con = conn.openConnection();
                using (SqlCommand c = new SqlCommand(
                    "UPDATE dbo.POHeader SET IsActive=0, UpdatedBy=@U, UpdatedDate=GETDATE() WHERE POID=@ID", con))
                {
                    c.Parameters.AddWithValue("@U", CurrentUserId);
                    c.Parameters.AddWithValue("@ID", poId);
                    c.ExecuteNonQuery();
                }
                CloseConnection();
                ShowAlert("PO deactivated successfully.");
                LoadPOList();
            }
            catch (Exception ex)
            {
                CloseConnection();
                ShowAlert("Delete error: " + ex.Message);
            }
        }

        // ============================================================
        // LOAD PO FOR EDIT
        // ============================================================
        private void LoadPOForEdit(int poId)
        {
            try
            {
                hfActiveTab.Value = "#qty-tab";
                LoadStyleDropdown();

                con = conn.openConnection();
                using (SqlCommand c = new SqlCommand(
                    "SELECT * FROM dbo.POHeader WHERE POID=@ID AND ISNULL(IsActive,1)=1", con))
                {
                    c.Parameters.AddWithValue("@ID", poId);
                    using (SqlDataReader r = c.ExecuteReader())
                    {
                        if (!r.Read())
                        {
                            ShowAlert("PO not found!");
                            r.Close();
                            CloseConnection();
                            return;
                        }

                        ViewState["POID"] = poId;
                        hfPOId.Value = poId.ToString();
                        hfStyleId.Value = GetStr(r["StyleID"]);

                        txtPONo.Text = GetStr(r["PONo"]);
                        txtPODate.Text = r["PODate"] != DBNull.Value
                            ? Convert.ToDateTime(r["PODate"]).ToString("yyyy-MM-dd") : "";
                        txtBuyerPORef.Text = GetStr(r["BuyerPORef"]);
                        SelectDDL(ddlPOType, GetStr(r["POType"]));
                        SelectDDL(ddlPOStatus, r["POStatus"] != DBNull.Value ? r["POStatus"].ToString() : "0");
                        SelectDDL(ddlStyle, GetStr(r["StyleID"]));

                        txtPOQty.Text = GetStr(r["POQty"]);
                        txtUnitPrice.Text = r["UnitPrice"] != DBNull.Value
                            ? Convert.ToDecimal(r["UnitPrice"]).ToString("N2") : "0";
                        SelectDDL(ddlCurrency, GetStr(r["Currency"]));
                        txtTotalValue.Text = r["TotalValue"] != DBNull.Value
                            ? Convert.ToDecimal(r["TotalValue"]).ToString("N2") : "0";

                        SelectDDL(ddlShipMode, GetStr(r["ShipMode"]));
                        SelectDDL(ddlIncoterms, GetStr(r["Incoterms"]));
                        txtPOL.Text = GetStr(r["POL"]);
                        txtPOD.Text = GetStr(r["POD"]);
                        txtShipDate.Text = r["ShipDate"] != DBNull.Value
                            ? Convert.ToDateTime(r["ShipDate"]).ToString("yyyy-MM-dd") : "";
                        txtDeliveryDate.Text = r["DeliveryDate"] != DBNull.Value
                            ? Convert.ToDateTime(r["DeliveryDate"]).ToString("yyyy-MM-dd") : "";
                        SelectDDL(ddlPartial, GetStr(r["PartialShipment"]));
                        SelectDDL(ddlTranship, GetStr(r["Transhipment"]));
                        txtForwarder.Text = GetStr(r["FreightForwarder"]);
                        txtLCNo.Text = GetStr(r["LCNo"]);
                        SelectDDL(ddlInspection, GetStr(r["InspectionType"]));
                        txtRemarks.Text = GetStr(r["Remarks"]);

                        SelectDDL(ddlPaymentTerms, GetStr(r["PaymentTerms"]));
                        txtAdvance.Text = GetStr(r["AdvancePct"]);
                        txtBalance.Text = GetStr(r["BalancePct"]);
                        SelectDDL(ddlBankCharge, GetStr(r["BankChargeBear"]));
                    }
                }
                CloseConnection();

                int styleId;
                if (int.TryParse(hfStyleId.Value, out styleId) && styleId > 0)
                {
                    LoadStyleSnapshot(styleId);
                    PopulateStyleLists(styleId);
                    LoadMatrixFromPO(poId, styleId);
                    LoadEmbFromPO(poId);
                    ViewState["LastQty"] = null;   // PreRender reloads Fabric / Accessories
                }
            }
            catch (Exception ex)
            {
                CloseConnection();
                ShowAlert("Load error: " + ex.Message);
            }
        }

        private void LoadMatrixFromPO(int poId, int styleId)
        {
            try
            {
                DataTable saved = new DataTable();
                con = conn.openConnection();
                using (SqlCommand c = new SqlCommand(
                    "SELECT ColorCode, SizeCode, Qty FROM dbo.POColorSize WHERE POID=@ID", con))
                {
                    c.Parameters.AddWithValue("@ID", poId);
                    new SqlDataAdapter(c).Fill(saved);
                }
                CloseConnection();

                List<string> styleColors = GetStyleColors(styleId);
                List<string> styleSizes = GetStyleSizes(styleId);

                MatrixData m = new MatrixData();
                HashSet<string> savedColors = new HashSet<string>();
                HashSet<string> savedSizes = new HashSet<string>();
                foreach (DataRow dr in saved.Rows)
                {
                    string color = GetStr(dr["ColorCode"]);
                    string size = GetStr(dr["SizeCode"]);
                    savedColors.Add(color);
                    savedSizes.Add(size);
                    m.Qty[Key(color, size)] = Convert.ToInt32(dr["Qty"]);
                }

                foreach (string c in styleColors) if (savedColors.Contains(c)) m.Colors.Add(c);
                foreach (string c in savedColors) if (!m.Colors.Contains(c)) m.Colors.Add(c);
                foreach (string s in styleSizes) if (savedSizes.Contains(s)) m.Sizes.Add(s);
                foreach (string s in savedSizes) if (!m.Sizes.Contains(s)) m.Sizes.Add(s);

                BindMatrix(m);
            }
            catch (Exception ex)
            {
                CloseConnection();
                ShowAlert("Saved qty load error: " + ex.Message);
            }
        }

        // ============================================================
        // SAVE PO
        // ============================================================
        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!ValidatePO()) return;

            int styleId;
            if (!int.TryParse(hfStyleId.Value, out styleId) || styleId == 0)
            {
                ShowAlert("Please select a Style!");
                return;
            }

            int poId = 0;
            if (ViewState["POID"] != null)
                poId = Convert.ToInt32(ViewState["POID"]);

            MatrixData matrix = ReadMatrix();
            List<EmbRow> embRows = ReadEmb();

            int poQty = 0;
            foreach (string color in matrix.Colors)
                poQty += ColorTotal(matrix, color);

            decimal unitPrice = DecOrZero(txtUnitPrice.Text);
            decimal totalValue = poQty * unitPrice;

            try
            {
                con = conn.openConnection();
                using (SqlTransaction tx = con.BeginTransaction())
                {
                    try
                    {
                        // 1. PO Header
                        using (SqlCommand c = new SqlCommand("sp_SaveUpdatePOHeader", con, tx))
                        {
                            c.CommandType = CommandType.StoredProcedure;
                            c.Parameters.Add("@POID", SqlDbType.Int).Value = poId;
                            c.Parameters.Add("@PONo", SqlDbType.NVarChar, 30).Value = txtPONo.Text.Trim();
                            c.Parameters.Add("@PODate", SqlDbType.Date).Value = DateOrNull(txtPODate.Text);
                            c.Parameters.Add("@BuyerPORef", SqlDbType.NVarChar, 50).Value = NullIfEmpty(txtBuyerPORef.Text);
                            c.Parameters.Add("@POType", SqlDbType.NVarChar, 30).Value = NullIfEmpty(ddlPOType.SelectedValue);
                            c.Parameters.Add("@StyleID", SqlDbType.Int).Value = styleId;
                            c.Parameters.Add("@Currency", SqlDbType.NVarChar, 5).Value = NullIfEmpty(ddlCurrency.SelectedValue);
                            c.Parameters.Add("@UnitPrice", SqlDbType.Decimal).Value = unitPrice;
                            c.Parameters.Add("@POQty", SqlDbType.Int).Value = poQty;
                            c.Parameters.Add("@TotalValue", SqlDbType.Decimal).Value = totalValue;
                            c.Parameters.Add("@ShipMode", SqlDbType.NVarChar, 20).Value = NullIfEmpty(ddlShipMode.SelectedValue);
                            c.Parameters.Add("@Incoterms", SqlDbType.NVarChar, 10).Value = NullIfEmpty(ddlIncoterms.SelectedValue);
                            c.Parameters.Add("@POL", SqlDbType.NVarChar, 100).Value = NullIfEmpty(txtPOL.Text);
                            c.Parameters.Add("@POD", SqlDbType.NVarChar, 100).Value = NullIfEmpty(txtPOD.Text);
                            c.Parameters.Add("@ShipDate", SqlDbType.Date).Value = DateOrNull(txtShipDate.Text);
                            c.Parameters.Add("@DeliveryDate", SqlDbType.Date).Value = DateOrNull(txtDeliveryDate.Text);
                            c.Parameters.Add("@PartialShipment", SqlDbType.NVarChar, 20).Value = NullIfEmpty(ddlPartial.SelectedValue);
                            c.Parameters.Add("@Transhipment", SqlDbType.NVarChar, 20).Value = NullIfEmpty(ddlTranship.SelectedValue);
                            c.Parameters.Add("@FreightForwarder", SqlDbType.NVarChar, 150).Value = NullIfEmpty(txtForwarder.Text);
                            c.Parameters.Add("@LCNo", SqlDbType.NVarChar, 50).Value = NullIfEmpty(txtLCNo.Text);
                            c.Parameters.Add("@InspectionType", SqlDbType.NVarChar, 30).Value = NullIfEmpty(ddlInspection.SelectedValue);
                            c.Parameters.Add("@Remarks", SqlDbType.NVarChar, 500).Value = NullIfEmpty(txtRemarks.Text);
                            c.Parameters.Add("@PaymentTerms", SqlDbType.NVarChar, 50).Value = NullIfEmpty(ddlPaymentTerms.SelectedValue);
                            c.Parameters.Add("@AdvancePct", SqlDbType.Decimal).Value = DecOrZero(txtAdvance.Text);
                            c.Parameters.Add("@BalancePct", SqlDbType.Decimal).Value = DecOrZero(txtBalance.Text);
                            c.Parameters.Add("@BankChargeBear", SqlDbType.NVarChar, 10).Value = NullIfEmpty(ddlBankCharge.SelectedValue);
                            c.Parameters.Add("@POStatus", SqlDbType.Int).Value = IntOrZero(ddlPOStatus.SelectedValue);
                            c.Parameters.Add("@UserID", SqlDbType.Int).Value = CurrentUserId;

                            SqlParameter outId = new SqlParameter("@NewPOID", SqlDbType.Int);
                            outId.Direction = ParameterDirection.Output;
                            c.Parameters.Add(outId);

                            c.ExecuteNonQuery();

                            poId = Convert.ToInt32(outId.Value);
                        }

                        // 2. Color × Size (unit price = PO unit price)
                        using (SqlCommand c = new SqlCommand("DELETE FROM dbo.POColorSize WHERE POID=@ID", con, tx))
                        {
                            c.Parameters.AddWithValue("@ID", poId);
                            c.ExecuteNonQuery();
                        }
                        foreach (string color in matrix.Colors)
                        {
                            foreach (string size in matrix.Sizes)
                            {
                                int qty;
                                if (!matrix.Qty.TryGetValue(Key(color, size), out qty) || qty <= 0) continue;

                                using (SqlCommand c = new SqlCommand(@"
                                    INSERT INTO dbo.POColorSize (POID, ColorCode, SizeCode, Qty, UnitPrice, LineTotal)
                                    VALUES (@ID, @Color, @Size, @Qty, @Price, @Total)", con, tx))
                                {
                                    c.Parameters.AddWithValue("@ID", poId);
                                    c.Parameters.AddWithValue("@Color", color);
                                    c.Parameters.AddWithValue("@Size", size);
                                    c.Parameters.AddWithValue("@Qty", qty);
                                    c.Parameters.AddWithValue("@Price", unitPrice);
                                    c.Parameters.AddWithValue("@Total", qty * unitPrice);
                                    c.ExecuteNonQuery();
                                }
                            }
                        }

                        // 3. Embellishment work order
                        using (SqlCommand c = new SqlCommand("DELETE FROM dbo.POEmbellishment WHERE POID=@ID", con, tx))
                        {
                            c.Parameters.AddWithValue("@ID", poId);
                            c.ExecuteNonQuery();
                        }
                        int sort = 0;
                        foreach (EmbRow er in embRows)
                        {
                            sort++;
                            using (SqlCommand c = new SqlCommand(@"
                                INSERT INTO dbo.POEmbellishment
                                    (POID, ColorCode, EmbType, Description, Placement, Supplier, Qty, Rate, Amount, SortOrder)
                                VALUES (@ID, @Color, @Type, @Desc, @Place, @Sup, @Qty, @Rate, @Amt, @Sort)", con, tx))
                            {
                                c.Parameters.AddWithValue("@ID", poId);
                                c.Parameters.AddWithValue("@Color", er.ColorCode);
                                c.Parameters.AddWithValue("@Type", er.EmbType);
                                c.Parameters.AddWithValue("@Desc", NullIfEmpty(er.Description));
                                c.Parameters.AddWithValue("@Place", NullIfEmpty(er.Placement));
                                c.Parameters.AddWithValue("@Sup", NullIfEmpty(er.Supplier));
                                c.Parameters.AddWithValue("@Qty", er.Qty);
                                c.Parameters.AddWithValue("@Rate", er.Rate);
                                c.Parameters.AddWithValue("@Amt", er.Qty * er.Rate);
                                c.Parameters.AddWithValue("@Sort", sort);
                                c.ExecuteNonQuery();
                            }
                        }

                        // 4. Fabric snapshot
                        using (SqlCommand c = new SqlCommand("DELETE FROM dbo.POFabric WHERE POID=@ID", con, tx))
                        {
                            c.Parameters.AddWithValue("@ID", poId);
                            c.ExecuteNonQuery();
                        }
                        using (SqlCommand c = new SqlCommand(@"
                            INSERT INTO dbo.POFabric (POID, FabricCode, FabricName, Composition, GSM, ColorName,
                                                      Consumption, WastagePercent, UnitCode, TotalQty, IsBooked)
                            SELECT @ID, FabricCode, FabricName, Composition, GSM, ColorName,
                                   Consumption, ISNULL(WastagePercent,0), UnitCode,
                                   Consumption * @POQty, 1
                            FROM   dbo.StyleFabric WHERE StyleID = @StyleID", con, tx))
                        {
                            c.Parameters.AddWithValue("@ID", poId);
                            c.Parameters.AddWithValue("@StyleID", styleId);
                            c.Parameters.AddWithValue("@POQty", poQty);
                            c.ExecuteNonQuery();
                        }

                        // 5. Accessories snapshot
                        using (SqlCommand c = new SqlCommand("DELETE FROM dbo.POAccessories WHERE POID=@ID", con, tx))
                        {
                            c.Parameters.AddWithValue("@ID", poId);
                            c.ExecuteNonQuery();
                        }
                        using (SqlCommand c = new SqlCommand(@"
                            INSERT INTO dbo.POAccessories (POID, ItemCode, ItemName, AccTypeName, SizeColor,
                                                            Consumption, UnitCode, WastagePercent, Supplier, TotalQty, IsBooked)
                            SELECT @ID, ItemCode, ItemName, AccTypeName, SizeColor,
                                   Consumption, UnitCode, ISNULL(WastagePercent,0), Supplier,
                                   Consumption * @POQty * (1 + ISNULL(WastagePercent,0)/100.0), 1
                            FROM   dbo.StyleAccessories WHERE StyleID = @StyleID", con, tx))
                        {
                            c.Parameters.AddWithValue("@ID", poId);
                            c.Parameters.AddWithValue("@StyleID", styleId);
                            c.Parameters.AddWithValue("@POQty", poQty);
                            c.ExecuteNonQuery();
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

                ViewState["POID"] = poId;
                hfPOId.Value = poId.ToString();

                ShowAlert("PO saved successfully. ID = " + poId);
                pnlEntry.Visible = false;
                pnlList.Visible = true;
                LoadPOList();
            }
            catch (SqlException ex)
            {
                CloseConnection();
                if (ex.Number == 2627) ShowAlert("PO No already exists!");
                else ShowAlert("Save error: " + ex.Message);
            }
            catch (Exception ex)
            {
                CloseConnection();
                ShowAlert("Save error: " + ex.Message);
            }
        }

        private bool ValidatePO()
        {
            if (string.IsNullOrWhiteSpace(txtPONo.Text)) { ShowAlert("PO No is required."); return false; }
            if (string.IsNullOrWhiteSpace(txtPODate.Text)) { ShowAlert("PO Date is required."); return false; }
            if (string.IsNullOrWhiteSpace(hfStyleId.Value) || hfStyleId.Value == "0")
            { ShowAlert("Select a Style first."); return false; }

            MatrixData m = ReadMatrix();
            int total = 0;
            foreach (string color in m.Colors) total += ColorTotal(m, color);
            if (total <= 0)
            { ShowAlert("Add Colors & Sizes and enter order quantity in the Color x Size grid."); return false; }

            foreach (EmbRow er in ReadEmb())
            {
                if (string.IsNullOrWhiteSpace(er.EmbType))
                { ShowAlert("Select Embellishment Type for color " + er.ColorCode + "."); return false; }
            }
            return true;
        }

        // ============================================================
        // CLEAR FORM
        // ============================================================
        private void ClearForm()
        {
            ViewState["POID"] = null;
            ViewState["LastQty"] = null;
            hfPOId.Value = "0";
            hfStyleId.Value = "0";
            hfActiveTab.Value = "#qty-tab";

            txtPONo.Text = GeneratePONo();
            txtPODate.Text = DateTime.Today.ToString("yyyy-MM-dd");
            txtBuyerPORef.Text = "";
            ddlPOType.SelectedIndex = 0;
            ddlPOStatus.SelectedIndex = 0;
            ddlStyle.SelectedIndex = -1;

            txtPOQty.Text = "0";
            txtUnitPrice.Text = "0.00";
            ddlCurrency.SelectedValue = "USD";
            txtTotalValue.Text = "0.00";

            ddlShipMode.SelectedIndex = 0;
            ddlIncoterms.SelectedIndex = 0;
            txtPOL.Text = "Chattogram";
            txtPOD.Text = "";
            txtShipDate.Text = "";
            txtDeliveryDate.Text = "";
            ddlPartial.SelectedIndex = 0;
            ddlTranship.SelectedIndex = 0;
            txtForwarder.Text = "";
            txtLCNo.Text = "";
            ddlInspection.SelectedIndex = 0;
            txtRemarks.Text = "";

            ddlPaymentTerms.SelectedIndex = 0;
            txtAdvance.Text = "0";
            txtBalance.Text = "100";
            ddlBankCharge.SelectedIndex = 0;

            btnSave.Enabled = true;
            ClearStyleSnapshot();
            ClearStyleLists();

            BindMatrix(new MatrixData());
            BindEmb(new List<EmbRow>());
            lblEmbTotal.Text = "0.00";
            gvFabric.DataSource = null; gvFabric.DataBind();
            gvAcc.DataSource = null; gvAcc.DataBind();
        }

        private void ClearStyleSnapshot()
        {
            lblStyleNoName.Text = lblBuyer.Text = lblBrand.Text = lblAgent.Text = "—";
            lblSeason.Text = lblMerch.Text = lblKnitWoven.Text = lblFabric.Text = "—";
            lblComposition.Text = lblTargetPrice.Text = "—";
            lblStyleRev.Text = "00";
            lblStyleStatus.Text = "—";
            lblStyleStatus.CssClass = "badge bg-secondary";
            imgFront.Visible = imgBack.Visible = imgSketch.Visible = false;
        }

        // ============================================================
        // AUTO PO NO
        // ============================================================
        private string GeneratePONo()
        {
            try
            {
                con = conn.openConnection();
                using (SqlCommand c = new SqlCommand(
                    "SELECT ISNULL(MAX(POID),0)+1 FROM dbo.POHeader", con))
                {
                    int next = Convert.ToInt32(c.ExecuteScalar());
                    CloseConnection();
                    return "PO-" + DateTime.Now.Year + "-" + next.ToString("D5");
                }
            }
            catch
            {
                CloseConnection();
                return "PO-" + DateTime.Now.ToString("yyyyMMddHHmmss");
            }
        }

        // ============================================================
        // DDL HELPER
        // ============================================================
        private static void SelectDDL(DropDownList ddl, string value)
        {
            if (ddl == null) return;
            ListItem item = ddl.Items.FindByValue(value);
            if (item != null) { ddl.ClearSelection(); item.Selected = true; }
            else if (ddl.Items.Count > 0) ddl.SelectedIndex = 0;
        }
    }
}
