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

    // One row of the Fabric Booking grid.
    // Key = Color + Part + Size + Fabric.  SizeCode = "ALL" means the line applies to every size of the color.
    // Dzn is the stored value, Pc is always Dzn / 12.
    public class FabRow
    {
        public const string AllSizes = "ALL";

        public string ColorCode { get; set; }
        public string PartName { get; set; }      // Body / Sleeve / Collar / Cuff / Flat Knit Bottom / Rib / Pocket / Other
        public string SizeCode { get; set; }      // ALL or a style size
        public string FabricCode { get; set; }
        public string FabricName { get; set; }
        public string GSM { get; set; }
        public string FabForm { get; set; }       // Open / Tube
        public string Dia { get; set; }           // finish dia (inch)
        public string PartSize { get; set; }      // collar size / cuff size / bottom size
        public string Ply { get; set; }           // Single / Double (cuff)
        public decimal KgDzn { get; set; }
        public decimal YdDzn { get; set; }
        public decimal RateDzn { get; set; }
        public int Qty { get; set; }
        public bool IsBooked { get; set; }

        public decimal LossPct { get; set; }
        public decimal KgPc { get { return KgDzn / 12m; } }
        public decimal YdPc { get { return YdDzn / 12m; } }
        public decimal RatePc { get { return RateDzn / 12m; } }
        // Cuff + Double = fabric is used twice → Total Kg / Yds x 2 (Kg/Pc, Yds/Pc stay as entered)
        public static decimal PlyFactorOf(string part, string ply)
        {
            return (part == "Cuff" && ply == "Double") ? 2m : 1m;
        }
        public decimal PlyFactor { get { return PlyFactorOf(PartName, Ply); } }

        public decimal TotalKg { get { return Qty * KgPc * (1m + LossPct / 100m) * PlyFactor; } }
        public decimal TotalYd { get { return Qty * YdPc * (1m + LossPct / 100m) * PlyFactor; } }
        public decimal Amount { get { return Qty * RatePc; } }

        public FabRow()
        {
            PartName = "Body";
            SizeCode = AllSizes;
        }
    }

    // One row of the Accessories Booking grid (Dzn is the stored value, Pc is always Dzn / 12)
    public class AccRow
    {
        public string ColorCode { get; set; }
        public string ItemCode { get; set; }
        public string ItemName { get; set; }
        public string ItemType { get; set; }
        public string SizeColor { get; set; }
        public string Unit { get; set; }
        public decimal ConsDzn { get; set; }
        public decimal RateDzn { get; set; }
        public decimal WastePct { get; set; }
        public int Qty { get; set; }
        public bool IsBooked { get; set; }

        public decimal ConsPc { get { return ConsDzn / 12m; } }
        public decimal RatePc { get { return RateDzn / 12m; } }
        public decimal TotalQty { get { return Qty * ConsPc * (1m + WastePct / 100m); } }
        public decimal Amount { get { return Qty * RatePc; } }
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

        // Every render: refresh row/column totals, PO Qty, Total Value, Accessories qty, Embellishment & Fabric amounts
        protected void Page_PreRender(object sender, EventArgs e)
        {
            if (!pnlEntry.Visible) return;

            decimal price = DecOrZero(txtUnitPrice.Text);
            int total = RefreshMatrixTotals(price);

            txtPOQty.Text = total.ToString();
            txtTotalValue.Text = (total * price).ToString("N2");

            RefreshEmbAmounts();
            RefreshFabAmounts();
            RefreshAccAmounts();
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
            // style changed → old matrix / embellishment / fabric no longer valid
            BindMatrix(new MatrixData());
            BindEmb(new List<EmbRow>());
            BindFab(new List<FabRow>());
            BindAcc(new List<AccRow>());
            ViewState["LastQty"] = null;

            int styleId;
            if (!int.TryParse(ddlStyle.SelectedValue, out styleId) || styleId == 0)
            {
                hfStyleId.Value = "0";
                ClearStyleSnapshot();
                ClearStyleLists();
                BindAcc(new List<AccRow>());
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
        // STYLE COLOR / SIZE / FABRIC LISTS (multi-select dropdowns)
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

        private DataTable GetStyleFabrics(int styleId)
        {
            DataTable dt = new DataTable();
            con = conn.openConnection();
            using (SqlCommand c = new SqlCommand(@"
                SELECT FabricCode, FabricName, GSM
                FROM   dbo.StyleFabric
                WHERE  StyleID=@ID
                ORDER BY SortOrder, StyleFabricID", con))
            {
                c.Parameters.AddWithValue("@ID", styleId);
                new SqlDataAdapter(c).Fill(dt);
            }
            CloseConnection();
            return dt;
        }

        private void PopulateStyleLists(int styleId)
        {
            try
            {
                List<string> colors = GetStyleColors(styleId);
                List<string> sizes = GetStyleSizes(styleId);
                DataTable fabs = GetStyleFabrics(styleId);
                DataTable accs = GetStyleAccessories(styleId);

                cblColors.Items.Clear();
                cblEmbColors.Items.Clear();
                cblFabColors.Items.Clear();
                cblSizes.Items.Clear();
                cblFabSizes.Items.Clear();
                cblFabrics.Items.Clear();
                cblAccColors.Items.Clear();
                cblAccItems.Items.Clear();

                foreach (string c in colors)
                {
                    cblColors.Items.Add(new ListItem(c, c));
                    cblEmbColors.Items.Add(new ListItem(c, c));
                    cblFabColors.Items.Add(new ListItem(c, c));
                    cblAccColors.Items.Add(new ListItem(c, c));
                }
                foreach (string s in sizes)
                {
                    cblSizes.Items.Add(new ListItem(s, s));
                    cblFabSizes.Items.Add(new ListItem(s, s));
                }

                foreach (DataRow ar in accs.Rows)
                {
                    string acode = GetStr(ar["ItemCode"]);
                    string aname = GetStr(ar["ItemName"]);
                    cblAccItems.Items.Add(new ListItem(acode + (aname.Length > 0 ? " - " + aname : ""), acode));
                }

                foreach (DataRow dr in fabs.Rows)
                {
                    string code = GetStr(dr["FabricCode"]);
                    string name = GetStr(dr["FabricName"]);
                    cblFabrics.Items.Add(new ListItem(code + (name.Length > 0 ? " - " + name : ""), code));
                }
            }
            catch (Exception ex)
            {
                CloseConnection();
                ShowAlert("Color/Size/Fabric load error: " + ex.Message);
            }
        }

        private void ClearStyleLists()
        {
            cblColors.Items.Clear();
            cblSizes.Items.Clear();
            cblEmbColors.Items.Clear();
            cblFabColors.Items.Clear();
            cblFabSizes.Items.Clear();
            cblFabrics.Items.Clear();
            cblAccColors.Items.Clear();
            cblAccItems.Items.Clear();
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

        // qty for one Color + Size ("ALL" = whole color)
        private static int QtyFor(MatrixData m, string color, string size)
        {
            if (string.IsNullOrEmpty(size) || size == FabRow.AllSizes) return ColorTotal(m, color);
            int q;
            return m.Qty.TryGetValue(Key(color, size), out q) ? q : 0;
        }

        // ============================================================
        // FABRIC BOOKING (Color x Part x Size x Fabric)
        // ============================================================

        // Dzn is the master value; if only Pc was typed, convert it
        private static decimal DznFrom(string dznText, string pcText)
        {
            decimal dzn, pc;
            decimal.TryParse(dznText, out dzn);
            decimal.TryParse(pcText, out pc);
            if (dzn <= 0m && pc > 0m) dzn = pc * 12m;
            return dzn;
        }

        // parts that must carry their own size (collar size / cuff size / bottom size)
        private static bool PartNeedsSize(string part)
        {
            return part == "Collar" || part == "Cuff" || part == "Flat Knit Bottom";
        }

        private List<FabRow> ReadFab()
        {
            List<FabRow> list = new List<FabRow>();
            foreach (GridViewRow row in gvFab.Rows)
            {
                if (row.RowType != DataControlRowType.DataRow) continue;
                Literal lc = row.FindControl("litFabColor") as Literal;
                if (lc == null) continue;

                FabRow r = new FabRow();
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
                r.KgDzn = DznFrom(((TextBox)row.FindControl("txtFabKgDzn")).Text, ((TextBox)row.FindControl("txtFabKgPc")).Text);
                r.YdDzn = DznFrom(((TextBox)row.FindControl("txtFabYdDzn")).Text, ((TextBox)row.FindControl("txtFabYdPc")).Text);
                r.RateDzn = DznFrom(((TextBox)row.FindControl("txtFabRateDzn")).Text, ((TextBox)row.FindControl("txtFabRatePc")).Text);
                r.Qty = IntOrZero(((TextBox)row.FindControl("txtFabQty")).Text.Trim());
                r.LossPct = DecOrZero(((TextBox)row.FindControl("txtFabLoss")).Text.Trim());
                r.IsBooked = ((CheckBox)row.FindControl("chkBookFab")).Checked;
                list.Add(r);
            }
            return list;
        }

        private void BindFab(List<FabRow> rows)
        {
            gvFab.DataSource = rows;
            gvFab.DataBind();
        }

        protected void gvFab_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType != DataControlRowType.DataRow) return;
            FabRow r = e.Row.DataItem as FabRow;
            if (r == null) return;
            SelectDDL((DropDownList)e.Row.FindControl("ddlFabFormRow"), r.FabForm ?? "");
            SelectDDL((DropDownList)e.Row.FindControl("ddlFabPlyRow"), r.Ply ?? "");
        }

        protected void btnAddFab_Click(object sender, EventArgs e)
        {
            List<string> colors = GetChecked(cblFabColors);
            List<string> fabrics = GetChecked(cblFabrics);
            List<string> sizes = GetChecked(cblFabSizes);
            string part = ddlFabPart.SelectedValue;

            if (colors.Count == 0) { ShowAlert("Select at least one Color."); return; }
            if (fabrics.Count == 0) { ShowAlert("Select at least one Fabric."); return; }
            if (part.Length == 0) { ShowAlert("Select a Part (Body / Collar / Cuff ...)."); return; }
            if (sizes.Count == 0) sizes.Add(FabRow.AllSizes);   // no size picked → one line for ALL sizes

            decimal kgDzn = DznFrom(txtFabKgDzn.Text, txtFabKgPc.Text);
            decimal ydDzn = DznFrom(txtFabYdDzn.Text, txtFabYdPc.Text);
            decimal rateDzn = DznFrom(txtFabRateDzn.Text, txtFabRatePc.Text);
            decimal lossPct = DecOrZero(txtFabLoss.Text);

            if (kgDzn <= 0m && ydDzn <= 0m)
            { ShowAlert("Enter Consumption (Kg or Yds), then click Add."); return; }

            string form = ddlFabForm.SelectedValue;
            string dia = txtFabDia.Text.Trim();
            string partSize = txtFabPartSize.Text.Trim();
            string ply = ddlFabPly.SelectedValue;

            int styleId;
            int.TryParse(hfStyleId.Value, out styleId);
            DataTable fabInfo = styleId > 0 ? GetStyleFabrics(styleId) : new DataTable();

            List<FabRow> rows = ReadFab();
            MatrixData m = ReadMatrix();
            int added = 0;

            foreach (string color in colors)
            {
                foreach (string code in fabrics)
                {
                    foreach (string size in sizes)
                    {
                        if (rows.Any(x => x.ColorCode == color && x.FabricCode == code && x.PartName == part && x.SizeCode == size)) continue;

                        string name = "", gsm = "";
                        foreach (DataRow dr in fabInfo.Rows)
                        {
                            if (GetStr(dr["FabricCode"]) == code)
                            {
                                name = GetStr(dr["FabricName"]);
                                gsm = GetStr(dr["GSM"]);
                                break;
                            }
                        }

                        rows.Add(new FabRow
                        {
                            ColorCode = color,
                            PartName = part,
                            SizeCode = size,
                            FabricCode = code,
                            FabricName = name,
                            GSM = gsm,
                            FabForm = form,
                            Dia = dia,
                            PartSize = partSize,
                            Ply = ply,
                            KgDzn = kgDzn,
                            YdDzn = ydDzn,
                            RateDzn = rateDzn,
                            LossPct = lossPct,
                            Qty = QtyFor(m, color, size),
                            IsBooked = true
                        });
                        added++;
                    }
                }
            }

            BindFab(rows);
            cblFabColors.ClearSelection();
            cblFabrics.ClearSelection();
            cblFabSizes.ClearSelection();
            ddlFabForm.SelectedIndex = 0;
            ddlFabPly.SelectedIndex = 0;
            txtFabDia.Text = txtFabPartSize.Text = "";
            txtFabKgDzn.Text = txtFabKgPc.Text = txtFabYdDzn.Text = txtFabYdPc.Text = txtFabRateDzn.Text = txtFabRatePc.Text = txtFabLoss.Text = "";

            if (added == 0)
                ShowAlert("Selected color / fabric / part / size combination(s) already added.");
        }

        protected void gvFab_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int idx;
            if (!int.TryParse(Convert.ToString(e.CommandArgument), out idx)) return;

            List<FabRow> rows = ReadFab();
            if (idx < 0 || idx >= rows.Count) return;

            if (e.CommandName == "RemoveRow")
            {
                rows.RemoveAt(idx);
            }
            else if (e.CommandName == "CopyRow")
            {
                // duplicate the line right below, user then changes Size / Dia / Cons for the copy
                FabRow s = rows[idx];
                rows.Insert(idx + 1, new FabRow
                {
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
                    KgDzn = s.KgDzn,
                    YdDzn = s.YdDzn,
                    RateDzn = s.RateDzn,
                    LossPct = s.LossPct,
                    Qty = s.Qty,
                    IsBooked = s.IsBooked
                });
            }
            else return;

            BindFab(rows);
        }

        // re-pull Qty of every fabric line from the Color x Size matrix
        protected void btnSyncFabQty_Click(object sender, EventArgs e)
        {
            List<FabRow> rows = ReadFab();
            MatrixData m = ReadMatrix();
            foreach (FabRow r in rows)
                r.Qty = QtyFor(m, r.ColorCode, r.SizeCode);
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

                decimal f = 1m + DecOrZero(((TextBox)row.FindControl("txtFabLoss")).Text) / 100m;
                f *= FabRow.PlyFactorOf(((Literal)row.FindControl("litFabPart")).Text,
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

        private void LoadFabFromPO(int poId)
        {
            List<FabRow> rows = new List<FabRow>();
            try
            {
                con = conn.openConnection();
                using (SqlCommand c = new SqlCommand(@"
                    SELECT ColorCode, ISNULL(PartName,'Body') AS PartName, ISNULL(SizeCode,'ALL') AS SizeCode,
                           FabricCode, FabricName, GSM, FabricForm, Dia, PartSize, Ply,
                           KgPerDzn, YdPerDzn, RatePerDzn, Qty, LossPct, IsBooked
                    FROM   dbo.POFabricBooking
                    WHERE  POID=@ID
                    ORDER BY SortOrder, FabBookID", con))
                {
                    c.Parameters.AddWithValue("@ID", poId);
                    using (SqlDataReader r = c.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            rows.Add(new FabRow
                            {
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
                                KgDzn = Convert.ToDecimal(r["KgPerDzn"]),
                                YdDzn = Convert.ToDecimal(r["YdPerDzn"]),
                                RateDzn = Convert.ToDecimal(r["RatePerDzn"]),
                                Qty = Convert.ToInt32(r["Qty"]),
                                LossPct = Convert.ToDecimal(r["LossPct"]),
                                IsBooked = Convert.ToBoolean(r["IsBooked"])
                            });
                        }
                    }
                }
                CloseConnection();
            }
            catch (Exception ex)
            {
                CloseConnection();
                ShowAlert("Fabric booking load error: " + ex.Message);
            }
            BindFab(rows);
        }

        // ============================================================
        // ACCESSORIES BOOKING (Color x Accessories)
        // ============================================================
        private DataTable GetStyleAccessories(int styleId)
        {
            DataTable dt = new DataTable();
            con = conn.openConnection();
            using (SqlCommand c = new SqlCommand(@"
                SELECT ItemCode, ItemName, AccTypeName, SizeColor, UnitCode, Consumption, WastagePercent
                FROM   dbo.StyleAccessories
                WHERE  StyleID=@ID
                ORDER BY SortOrder, StyleAccID", con))
            {
                c.Parameters.AddWithValue("@ID", styleId);
                new SqlDataAdapter(c).Fill(dt);
            }
            CloseConnection();
            return dt;
        }

        private List<AccRow> ReadAcc()
        {
            List<AccRow> list = new List<AccRow>();
            foreach (GridViewRow row in gvAcc.Rows)
            {
                if (row.RowType != DataControlRowType.DataRow) continue;
                Literal lc = row.FindControl("litAccColor") as Literal;
                if (lc == null) continue;

                AccRow r = new AccRow();
                r.ColorCode = lc.Text;
                r.ItemCode = ((Literal)row.FindControl("litAccCode")).Text;
                r.ItemName = ((HiddenField)row.FindControl("hfAccName")).Value;
                r.ItemType = ((HiddenField)row.FindControl("hfAccType")).Value;
                r.SizeColor = ((HiddenField)row.FindControl("hfAccSize")).Value;
                r.Unit = ((TextBox)row.FindControl("txtAccUnit")).Text.Trim();
                r.ConsDzn = DznFrom(((TextBox)row.FindControl("txtAccConsDzn")).Text, ((TextBox)row.FindControl("txtAccConsPc")).Text);
                r.RateDzn = DznFrom(((TextBox)row.FindControl("txtAccRateDzn")).Text, ((TextBox)row.FindControl("txtAccRatePc")).Text);
                r.WastePct = DecOrZero(((TextBox)row.FindControl("txtAccLoss")).Text.Trim());
                r.Qty = IntOrZero(((TextBox)row.FindControl("txtAccQty")).Text.Trim());
                r.IsBooked = ((CheckBox)row.FindControl("chkBookAcc")).Checked;
                list.Add(r);
            }
            return list;
        }

        private void BindAcc(List<AccRow> rows)
        {
            gvAcc.DataSource = rows;
            gvAcc.DataBind();
        }

        protected void btnAddAcc_Click(object sender, EventArgs e)
        {
            List<string> colors = GetChecked(cblAccColors);
            List<string> items = GetChecked(cblAccItems);

            if (colors.Count == 0) { ShowAlert("Select at least one Color."); return; }
            if (items.Count == 0) { ShowAlert("Select at least one Accessories item."); return; }

            int styleId;
            int.TryParse(hfStyleId.Value, out styleId);
            DataTable info = styleId > 0 ? GetStyleAccessories(styleId) : new DataTable();

            decimal consDzn = DznFrom(txtAccConsDzn.Text, txtAccConsPc.Text);
            decimal rateDzn = DznFrom(txtAccRateDzn.Text, txtAccRatePc.Text);
            bool hasWaste = txtAccLoss.Text.Trim().Length > 0;
            decimal wasteIn = DecOrZero(txtAccLoss.Text);
            string unitSel = ddlAccUnit.SelectedValue;

            List<AccRow> rows = ReadAcc();
            MatrixData m = ReadMatrix();
            int added = 0;

            foreach (string color in colors)
            {
                foreach (string code in items)
                {
                    if (rows.Any(x => x.ColorCode == color && x.ItemCode == code)) continue;

                    string name = "", type = "", size = "", styleUnit = "";
                    decimal styleConsPc = 0m, styleWaste = 0m;
                    foreach (DataRow dr in info.Rows)
                    {
                        if (GetStr(dr["ItemCode"]) != code) continue;
                        name = GetStr(dr["ItemName"]);
                        type = GetStr(dr["AccTypeName"]);
                        size = GetStr(dr["SizeColor"]);
                        styleUnit = GetStr(dr["UnitCode"]);
                        styleConsPc = dr["Consumption"] != DBNull.Value ? Convert.ToDecimal(dr["Consumption"]) : 0m;
                        styleWaste = dr["WastagePercent"] != DBNull.Value ? Convert.ToDecimal(dr["WastagePercent"]) : 0m;
                        break;
                    }

                    rows.Add(new AccRow
                    {
                        ColorCode = color,
                        ItemCode = code,
                        ItemName = name,
                        ItemType = type,
                        SizeColor = size,
                        Unit = unitSel.Length > 0 ? unitSel : styleUnit,
                        ConsDzn = consDzn > 0m ? consDzn : styleConsPc * 12m,
                        RateDzn = rateDzn,
                        WastePct = hasWaste ? wasteIn : styleWaste,
                        Qty = ColorTotal(m, color),
                        IsBooked = true
                    });
                    added++;
                }
            }

            BindAcc(rows);
            cblAccColors.ClearSelection();
            cblAccItems.ClearSelection();
            txtAccConsDzn.Text = txtAccConsPc.Text = txtAccRateDzn.Text = txtAccRatePc.Text = txtAccLoss.Text = "";
            ddlAccUnit.SelectedIndex = 0;

            if (added == 0)
                ShowAlert("Selected color/accessories combination(s) already added.");
        }

        protected void gvAcc_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName != "RemoveRow") return;
            int idx;
            if (!int.TryParse(Convert.ToString(e.CommandArgument), out idx)) return;

            List<AccRow> rows = ReadAcc();
            if (idx < 0 || idx >= rows.Count) return;
            rows.RemoveAt(idx);
            BindAcc(rows);
        }

        private void RefreshAccAmounts()
        {
            decimal sAmt = 0m;
            foreach (GridViewRow row in gvAcc.Rows)
            {
                if (row.RowType != DataControlRowType.DataRow) continue;
                if (row.FindControl("txtAccQty") == null) continue;

                decimal consPc = DznFrom(((TextBox)row.FindControl("txtAccConsDzn")).Text, ((TextBox)row.FindControl("txtAccConsPc")).Text) / 12m;
                decimal ratePc = DznFrom(((TextBox)row.FindControl("txtAccRateDzn")).Text, ((TextBox)row.FindControl("txtAccRatePc")).Text) / 12m;
                decimal f = 1m + DecOrZero(((TextBox)row.FindControl("txtAccLoss")).Text) / 100m;
                int qty = IntOrZero(((TextBox)row.FindControl("txtAccQty")).Text.Trim());

                decimal tq = qty * consPc * f, am = qty * ratePc;
                ((Label)row.FindControl("lblAccTotalQty")).Text = tq.ToString("N2");
                ((Label)row.FindControl("lblAccAmt")).Text = am.ToString("N2");
                sAmt += am;
            }
            lblAccSumAmt.Text = sAmt.ToString("N2");
        }

        private void LoadAccFromPO(int poId)
        {
            List<AccRow> rows = new List<AccRow>();
            try
            {
                con = conn.openConnection();
                using (SqlCommand c = new SqlCommand(@"
                    SELECT ColorCode, ItemCode, ItemName, ItemType, SizeColor, UnitCode,
                           ConsPerDzn, RatePerDzn, WastagePct, Qty, IsBooked
                    FROM   dbo.POAccessoriesBooking
                    WHERE  POID=@ID
                    ORDER BY SortOrder, AccBookID", con))
                {
                    c.Parameters.AddWithValue("@ID", poId);
                    using (SqlDataReader r = c.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            rows.Add(new AccRow
                            {
                                ColorCode = GetStr(r["ColorCode"]),
                                ItemCode = GetStr(r["ItemCode"]),
                                ItemName = GetStr(r["ItemName"]),
                                ItemType = GetStr(r["ItemType"]),
                                SizeColor = GetStr(r["SizeColor"]),
                                Unit = GetStr(r["UnitCode"]),
                                ConsDzn = Convert.ToDecimal(r["ConsPerDzn"]),
                                RateDzn = Convert.ToDecimal(r["RatePerDzn"]),
                                WastePct = Convert.ToDecimal(r["WastagePct"]),
                                Qty = Convert.ToInt32(r["Qty"]),
                                IsBooked = Convert.ToBoolean(r["IsBooked"])
                            });
                        }
                    }
                }
                CloseConnection();
            }
            catch (Exception ex)
            {
                CloseConnection();
                ShowAlert("Accessories booking load error: " + ex.Message);
            }
            BindAcc(rows);
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
                    LoadFabFromPO(poId);
                    LoadAccFromPO(poId);
                    ViewState["LastQty"] = null;   // PreRender reloads Accessories
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
            List<FabRow> fabRows = ReadFab();
            List<AccRow> accRows = ReadAcc();

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

                        // 4. Fabric booking (Color x Part x Size x Fabric)
                        using (SqlCommand c = new SqlCommand("DELETE FROM dbo.POFabricBooking WHERE POID=@ID", con, tx))
                        {
                            c.Parameters.AddWithValue("@ID", poId);
                            c.ExecuteNonQuery();
                        }
                        int fsort = 0;
                        foreach (FabRow fr in fabRows)
                        {
                            fsort++;
                            using (SqlCommand c = new SqlCommand(@"
                                INSERT INTO dbo.POFabricBooking
                                    (POID, ColorCode, PartName, SizeCode, FabricCode, FabricName, GSM,
                                     FabricForm, Dia, PartSize, Ply,
                                     KgPerDzn, YdPerDzn, RatePerDzn,
                                     Qty, LossPct, TotalKg, TotalYd, Amount, IsBooked, SortOrder)
                                VALUES (@ID, @Color, @Part, @SizeCode, @Code, @Name, @Gsm,
                                        @Form, @Dia, @PartSize, @Ply,
                                        @Kg, @Yd, @Rate,
                                        @Qty, @Loss, @TKg, @TYd, @Amt, @Booked, @Sort)", con, tx))
                            {
                                c.Parameters.AddWithValue("@ID", poId);
                                c.Parameters.AddWithValue("@Color", fr.ColorCode);
                                c.Parameters.AddWithValue("@Part", string.IsNullOrEmpty(fr.PartName) ? "Body" : fr.PartName);
                                c.Parameters.AddWithValue("@SizeCode", string.IsNullOrEmpty(fr.SizeCode) ? FabRow.AllSizes : fr.SizeCode);
                                c.Parameters.AddWithValue("@Code", fr.FabricCode);
                                c.Parameters.AddWithValue("@Name", NullIfEmpty(fr.FabricName));
                                c.Parameters.AddWithValue("@Gsm", NullIfEmpty(fr.GSM));
                                c.Parameters.AddWithValue("@Form", NullIfEmpty(fr.FabForm));
                                c.Parameters.AddWithValue("@Dia", NullIfEmpty(fr.Dia));
                                c.Parameters.AddWithValue("@PartSize", NullIfEmpty(fr.PartSize));
                                c.Parameters.AddWithValue("@Ply", NullIfEmpty(fr.Ply));
                                c.Parameters.AddWithValue("@Kg", fr.KgDzn);
                                c.Parameters.AddWithValue("@Yd", fr.YdDzn);
                                c.Parameters.AddWithValue("@Rate", fr.RateDzn);
                                c.Parameters.AddWithValue("@Qty", fr.Qty);
                                c.Parameters.AddWithValue("@Loss", fr.LossPct);
                                c.Parameters.AddWithValue("@TKg", fr.TotalKg);
                                c.Parameters.AddWithValue("@TYd", fr.TotalYd);
                                c.Parameters.AddWithValue("@Amt", fr.Amount);
                                c.Parameters.AddWithValue("@Booked", fr.IsBooked);
                                c.Parameters.AddWithValue("@Sort", fsort);
                                c.ExecuteNonQuery();
                            }
                        }

                        // 5. Accessories booking (Color x Accessories)
                        using (SqlCommand c = new SqlCommand("DELETE FROM dbo.POAccessoriesBooking WHERE POID=@ID", con, tx))
                        {
                            c.Parameters.AddWithValue("@ID", poId);
                            c.ExecuteNonQuery();
                        }
                        int asort = 0;
                        foreach (AccRow ar in accRows)
                        {
                            asort++;
                            using (SqlCommand c = new SqlCommand(@"
                                INSERT INTO dbo.POAccessoriesBooking
                                    (POID, ColorCode, ItemCode, ItemName, ItemType, SizeColor, UnitCode,
                                     ConsPerDzn, RatePerDzn, WastagePct, Qty, TotalQty, Amount, IsBooked, SortOrder)
                                VALUES (@ID, @Color, @Code, @Name, @Type, @Size, @Unit,
                                        @Cons, @Rate, @Waste, @Qty, @TQty, @Amt, @Booked, @Sort)", con, tx))
                            {
                                c.Parameters.AddWithValue("@ID", poId);
                                c.Parameters.AddWithValue("@Color", ar.ColorCode);
                                c.Parameters.AddWithValue("@Code", ar.ItemCode);
                                c.Parameters.AddWithValue("@Name", NullIfEmpty(ar.ItemName));
                                c.Parameters.AddWithValue("@Type", NullIfEmpty(ar.ItemType));
                                c.Parameters.AddWithValue("@Size", NullIfEmpty(ar.SizeColor));
                                c.Parameters.AddWithValue("@Unit", NullIfEmpty(ar.Unit));
                                c.Parameters.AddWithValue("@Cons", ar.ConsDzn);
                                c.Parameters.AddWithValue("@Rate", ar.RateDzn);
                                c.Parameters.AddWithValue("@Waste", ar.WastePct);
                                c.Parameters.AddWithValue("@Qty", ar.Qty);
                                c.Parameters.AddWithValue("@TQty", ar.TotalQty);
                                c.Parameters.AddWithValue("@Amt", ar.Amount);
                                c.Parameters.AddWithValue("@Booked", ar.IsBooked);
                                c.Parameters.AddWithValue("@Sort", asort);
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

            // Fabric booking rules (only for lines marked "Book?")
            foreach (FabRow fr in ReadFab())
            {
                if (!fr.IsBooked) continue;

                string tag = fr.ColorCode + " / " + fr.PartName + " / " + fr.FabricCode
                           + (fr.SizeCode != FabRow.AllSizes ? " / " + fr.SizeCode : "");

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

            ddlFabPart.SelectedIndex = 0;
            ddlFabForm.SelectedIndex = 0;
            ddlFabPly.SelectedIndex = 0;
            txtFabDia.Text = txtFabPartSize.Text = "";
            txtFabKgDzn.Text = txtFabKgPc.Text = txtFabYdDzn.Text = txtFabYdPc.Text = txtFabRateDzn.Text = txtFabRatePc.Text = txtFabLoss.Text = "";

            BindMatrix(new MatrixData());
            BindEmb(new List<EmbRow>());
            lblEmbTotal.Text = "0.00";
            BindFab(new List<FabRow>());
            lblFabSumKg.Text = lblFabSumYd.Text = lblFabSumAmt.Text = "0.00";
            txtAccConsDzn.Text = txtAccConsPc.Text = txtAccRateDzn.Text = txtAccRatePc.Text = txtAccLoss.Text = "";
            ddlAccUnit.SelectedIndex = 0;
            lblAccSumAmt.Text = "0.00";
            BindAcc(new List<AccRow>());
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