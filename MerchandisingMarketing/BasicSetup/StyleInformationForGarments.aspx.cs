using Nexa_ERP.Connection;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.IO;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.MasterConfiguration.BuyerManagement
{
    public partial class StyleInformationForGarments : System.Web.UI.Page
    {
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();

        // Shared connection কে Dispose না করে শুধু Close করা হচ্ছে (BuyerBrandSetup এর মতই)
        private sealed class ConScope : IDisposable
        {
            public SqlConnection Con { get; private set; }
            public ConScope(SqlConnection con)
            {
                Con = con;
                if (Con != null && Con.State == ConnectionState.Closed) Con.Open();
            }
            public void Dispose()
            {
                if (Con != null && Con.State != ConnectionState.Closed) Con.Close();
            }
        }

        private static readonly string[] WorkflowSteps = { "Draft", "Submitted", "Merchandising Approval", "Management Approval", "Active" };
        private const string MasterTbl = "techdefendersbd.tbl_Mer_StyleMaster";

        // ================================================================
        //  PROPERTIES
        // ================================================================
        private int StyleId
        {
            get { int v; int.TryParse(hfStyleId.Value, out v); return v; }
            set { hfStyleId.Value = value.ToString(); }
        }

        private string CurrentUser
        {
            get
            {
                if (Session["UserName"] != null) return Session["UserName"].ToString();
                if (Session["UserId"] != null) return "User-" + Session["UserId"];
                return "Admin";
            }
        }

        private DataTable ColorsDT
        {
            get
            {
                DataTable dt = ViewState["dtColors"] as DataTable;
                if (dt == null)
                {
                    dt = new DataTable("Colors");
                    dt.Columns.Add("ColorCode", typeof(string));
                    dt.Columns.Add("ColorName", typeof(string));
                    dt.Columns.Add("PantoneCode", typeof(string));
                    dt.Columns.Add("IsActive", typeof(bool));
                    ViewState["dtColors"] = dt;
                }
                return dt;
            }
            set { value.TableName = "Colors"; ViewState["dtColors"] = value; }
        }

        private DataTable SizesDT
        {
            get
            {
                DataTable dt = ViewState["dtSizes"] as DataTable;
                if (dt == null)
                {
                    dt = new DataTable("Sizes");
                    dt.Columns.Add("SizeCode", typeof(string));
                    dt.Columns.Add("SizeName", typeof(string));
                    dt.Columns.Add("SizeRange", typeof(string));
                    dt.Columns.Add("IsActive", typeof(bool));
                    ViewState["dtSizes"] = dt;
                }
                return dt;
            }
            set { value.TableName = "Sizes"; ViewState["dtSizes"] = value; }
        }

        private DataTable FabricDT
        {
            get
            {
                DataTable dt = ViewState["dtFabric"] as DataTable;
                if (dt == null)
                {
                    dt = new DataTable("Fabric");
                    dt.Columns.Add("FabricCode", typeof(string));
                    dt.Columns.Add("FabricName", typeof(string));
                    dt.Columns.Add("Composition", typeof(string));
                    dt.Columns.Add("GSM", typeof(string));
                    dt.Columns.Add("ColorName", typeof(string));
                    dt.Columns.Add("Consumption", typeof(decimal));
                    dt.Columns.Add("WastagePercent", typeof(decimal));
                    dt.Columns.Add("Unit", typeof(string));
                    ViewState["dtFabric"] = dt;
                }
                return dt;
            }
            set { value.TableName = "Fabric"; ViewState["dtFabric"] = value; }
        }

        private DataTable AccDT
        {
            get
            {
                DataTable dt = ViewState["dtAcc"] as DataTable;
                if (dt == null)
                {
                    dt = new DataTable("Acc");
                    dt.Columns.Add("ItemCode", typeof(string));
                    dt.Columns.Add("ItemName", typeof(string));
                    dt.Columns.Add("ItemType", typeof(string));
                    dt.Columns.Add("SizeColor", typeof(string));
                    dt.Columns.Add("Consumption", typeof(decimal));
                    dt.Columns.Add("Unit", typeof(string));
                    dt.Columns.Add("WastagePercent", typeof(decimal));
                    dt.Columns.Add("Supplier", typeof(string));
                    ViewState["dtAcc"] = dt;
                }
                return dt;
            }
            set { value.TableName = "Acc"; ViewState["dtAcc"] = value; }
        }

        // ================================================================
        //  PAGE LOAD
        // ================================================================
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                hfUserId.Value = Session["UserId"] != null ? Session["UserId"].ToString() : "0";
                lblUser.Text = CurrentUser;

                LoadLookups();
                ShowList();
                LoadStyleList();
            }
        }

        // ================================================================
        //  GENERIC DB HELPERS
        // ================================================================
        private static SqlParameter P(string name, object value)
        {
            return new SqlParameter(name, value ?? DBNull.Value);
        }

        private static object N(string s)
        {
            return string.IsNullOrWhiteSpace(s) ? (object)DBNull.Value : s.Trim();
        }

        private static object NI(string s)
        {
            int v;
            return (int.TryParse(s, out v) && v > 0) ? (object)v : DBNull.Value;
        }

        private static decimal Dec(string s)
        {
            decimal v;
            if (decimal.TryParse((s ?? "").Trim(), NumberStyles.Any, CultureInfo.InvariantCulture, out v)) return v;
            return 0m;
        }

        private static object ParseDate(string s)
        {
            DateTime d;
            if (DateTime.TryParse(s, CultureInfo.InvariantCulture, DateTimeStyles.None, out d)) return d.Date;
            return DBNull.Value;
        }

        private static string DateStr(object o)
        {
            return (o == null || o == DBNull.Value) ? "" : Convert.ToDateTime(o).ToString("yyyy-MM-dd");
        }

        private static string Str(object o)
        {
            return (o == null || o == DBNull.Value) ? "" : o.ToString();
        }

        private DataTable GetTable(string sql, params SqlParameter[] ps)
        {
            DataTable dt = new DataTable();
            using (ConScope cs = new ConScope(conn.openConnection()))
            using (SqlCommand cmd = new SqlCommand(sql, cs.Con))
            {
                if (ps != null && ps.Length > 0) cmd.Parameters.AddRange(ps);
                new SqlDataAdapter(cmd).Fill(dt);
            }
            return dt;
        }

        private DataTable GetTableTx(SqlConnection cn, SqlTransaction tx, string sql, params SqlParameter[] ps)
        {
            DataTable dt = new DataTable();
            using (SqlCommand cmd = new SqlCommand(sql, cn, tx))
            {
                if (ps != null && ps.Length > 0) cmd.Parameters.AddRange(ps);
                new SqlDataAdapter(cmd).Fill(dt);
            }
            return dt;
        }

        private object ScalarTx(SqlConnection cn, SqlTransaction tx, string sql, params SqlParameter[] ps)
        {
            using (SqlCommand cmd = new SqlCommand(sql, cn, tx))
            {
                if (ps != null && ps.Length > 0) cmd.Parameters.AddRange(ps);
                return cmd.ExecuteScalar();
            }
        }

        private void ExecTx(SqlConnection cn, SqlTransaction tx, string sql, params SqlParameter[] ps)
        {
            using (SqlCommand cmd = new SqlCommand(sql, cn, tx))
            {
                if (ps != null && ps.Length > 0) cmd.Parameters.AddRange(ps);
                cmd.ExecuteNonQuery();
            }
        }

        private void Exec(string sql, params SqlParameter[] ps)
        {
            using (ConScope cs = new ConScope(conn.openConnection()))
            using (SqlCommand cmd = new SqlCommand(sql, cs.Con))
            {
                if (ps != null && ps.Length > 0) cmd.Parameters.AddRange(ps);
                cmd.ExecuteNonQuery();
            }
        }

        private void ShowMessage(string message)
        {
            string safe = (message ?? string.Empty)
                .Replace("\\", "\\\\")
                .Replace("'", "\\'")
                .Replace("\r", " ")
                .Replace("\n", " ");
            ClientScript.RegisterStartupScript(this.GetType(), Guid.NewGuid().ToString(), "alert('" + safe + "');", true);
        }

        private void BindDdl(DropDownList ddl, DataTable dt, string textField, string valueField, string firstText)
        {
            ddl.DataSource = dt;
            ddl.DataTextField = textField;
            ddl.DataValueField = valueField;
            ddl.DataBind();
            if (firstText != null) ddl.Items.Insert(0, new ListItem(firstText, ""));
        }

        // value না থাকলে item যোগ করে select করে
        private void SetDdl(DropDownList d, string v)
        {
            d.ClearSelection();
            if (string.IsNullOrEmpty(v))
            {
                if (d.Items.Count > 0) d.SelectedIndex = 0;
                return;
            }
            ListItem it = d.Items.FindByValue(v);
            if (it == null) { it = new ListItem(v, v); d.Items.Add(it); }
            it.Selected = true;
        }

        // ================================================================
        //  LOOKUPS
        // ================================================================
        private void LoadLookups()
        {
            try
            {
                DataTable buyers = GetTable("SELECT BuyerID, BuyerName FROM techdefendersbd.vw_BuyerInformation WHERE ISNULL(IsActive,1)=1 ORDER BY BuyerName");
                BindDdl(ddlBuyer, buyers, "BuyerName", "BuyerID", "--Select Buyer--");
                BindDdl(ddlBuyerFilter, buyers, "BuyerName", "BuyerID", "--All Buyers--");

                BindDdl(ddlAgent, GetTable("SELECT AgentID, HouseName FROM dbo.BuyingHouseAgent WHERE ISNULL(IsActive,1)=1 ORDER BY HouseName"), "HouseName", "AgentID", "Direct Buyer");

                BindDdl(ddlMerchandiser, GetTable("SELECT user_id, ISNULL(NULLIF(full_name,''), username) AS full_name FROM dbo.vw_User_Information_Top1000 WHERE ISNULL(is_active,1)=1 ORDER BY full_name"), "full_name", "user_id", "--Select Merchandiser--");

                BindDdl(ddlCountry, GetTable("SELECT CountryName FROM dbo.CountryMaster WHERE ISNULL(IsActive,1)=1 ORDER BY CountryName"), "CountryName", "CountryName", "--Select Country--");

                BindDdl(ddlPaymentTerm, GetTable("SELECT TermName FROM techdefendersbd.tbl_PaymentTerm WHERE IsActive=1 ORDER BY TermName"), "TermName", "TermName", "--Select Payment Term--");

                DataTable units = GetTable("SELECT ISNULL(NULLIF(ShortCode,''), UnitName) AS U FROM techdefendersbd.tbl_UnitSetup WHERE ISNULL(Status,'Active')='Active' ORDER BY U");
                BindDdl(ddlFabUnit, units, "U", "U", null);
                BindDdl(ddlAccUnit, units, "U", "U", null);
                if (ddlFabUnit.Items.Count == 0) { ddlFabUnit.Items.Add("Kgs"); ddlFabUnit.Items.Add("Yds"); ddlFabUnit.Items.Add("Mtr"); }
                if (ddlAccUnit.Items.Count == 0) { ddlAccUnit.Items.Add("Pcs"); ddlAccUnit.Items.Add("Mtr"); ddlAccUnit.Items.Add("Cone"); }

                BindDdl(ddlColor, GetTable("SELECT ColorCode, ColorName FROM dbo.ColorMaster WHERE IsActive=1 ORDER BY ColorName"), "ColorName", "ColorCode", "--Select Color--");

                DataTable sizes = GetTable(@"SELECT s.SizeID, s.SizeName + CASE WHEN g.GroupName IS NULL THEN '' ELSE ' (' + g.GroupName + ')' END AS Txt
                                             FROM techdefendersbd.Sizes s LEFT JOIN techdefendersbd.SizeGroups g ON g.GroupID = s.GroupID
                                             ORDER BY g.GroupName, s.SizeID");
                BindDdl(ddlSize, sizes, "Txt", "SizeID", "--Select Size--");

                ddlSeasonYear.Items.Clear();
                for (int y = DateTime.Now.Year - 1; y <= DateTime.Now.Year + 2; y++) ddlSeasonYear.Items.Add(y.ToString());
                SetDdl(ddlSeasonYear, DateTime.Now.Year.ToString());

                LoadBrands(0);
            }
            catch (Exception ex) { ShowMessage(ex.Message); }
        }

        private void LoadBrands(int buyerId)
        {
            ddlBrand.Items.Clear();
            if (buyerId > 0)
            {
                DataTable dt = GetTable("SELECT BrandID, BrandName FROM BuyerBrand WHERE BuyerID = @b AND ISNULL(IsActive,1)=1 ORDER BY BrandName", P("@b", buyerId));
                BindDdl(ddlBrand, dt, "BrandName", "BrandID", "--Select Brand--");
            }
            else
            {
                ddlBrand.Items.Add(new ListItem("--Select Brand--", ""));
            }
        }

        protected void ddlBuyer_SelectedIndexChanged(object sender, EventArgs e)
        {
            int b; int.TryParse(ddlBuyer.SelectedValue, out b);
            LoadBrands(b);
        }

        // ================================================================
        //  PANEL SWITCH + LIST
        // ================================================================
        private void ShowList() { pnlList.Visible = true; pnlEntry.Visible = false; }
        private void ShowEntry() { pnlList.Visible = false; pnlEntry.Visible = true; }

        private void LoadStyleList()
        {
            try
            {
                int buyer; int.TryParse(ddlBuyerFilter.SelectedValue, out buyer);
                string search = txtSearch.Text.Trim();
                DataTable dt = GetTable(@"
                    SELECT m.StyleID, m.StyleCode, m.StyleNo, m.StyleName, bi.BuyerName,
                           LTRIM(ISNULL(m.SeasonName,'') + ' ' + ISNULL(CAST(m.SeasonYear AS VARCHAR(4)),'')) AS Season,
                           m.StyleStatus, RIGHT('00' + CAST(m.RevisionNo AS VARCHAR(5)), 2) AS RevisionNo
                    FROM " + MasterTbl + @" m
                    LEFT JOIN techdefendersbd.vw_BuyerInformation bi ON bi.BuyerID = m.BuyerID
                    WHERE (@b = 0 OR m.BuyerID = @b)
                      AND (@s = '' OR m.StyleStatus = @s)
                      AND (@q = '' OR m.StyleCode LIKE @l OR m.StyleNo LIKE @l OR m.StyleName LIKE @l)
                    ORDER BY m.StyleID DESC",
                    P("@b", buyer), P("@s", ddlStatusFilter.SelectedValue), P("@q", search), P("@l", "%" + search + "%"));
                gvStyles.DataSource = dt;
                gvStyles.DataBind();
            }
            catch (Exception ex) { ShowMessage(ex.Message); }
        }

        protected void btnSearch_Click(object sender, EventArgs e) { LoadStyleList(); }

        protected void btnClearFilter_Click(object sender, EventArgs e)
        {
            ddlBuyerFilter.SelectedIndex = 0;
            ddlStatusFilter.SelectedIndex = 0;
            txtSearch.Text = "";
            LoadStyleList();
        }

        protected void btnAddNew_Click(object sender, EventArgs e)
        {
            ClearForm();
            ShowEntry();
        }

        protected void gvStyles_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int id;
            if (!int.TryParse(Convert.ToString(e.CommandArgument), out id)) return;

            if (e.CommandName == "EditRow") LoadStyle(id);
            else if (e.CommandName == "DeleteRow") DeleteStyle(id);
        }

        private void DeleteStyle(int id)
        {
            try
            {
                DataTable m = GetTable("SELECT StyleStatus, IsLocked FROM " + MasterTbl + " WHERE StyleID=@id", P("@id", id));
                if (m.Rows.Count == 0) return;
                string st = Str(m.Rows[0]["StyleStatus"]);
                if (Convert.ToBoolean(m.Rows[0]["IsLocked"]) || (st != "Draft" && st != "Rejected"))
                {
                    ShowMessage("Only Draft / Rejected style can be deleted.");
                    return;
                }
                Exec("DELETE FROM " + MasterTbl + " WHERE StyleID=@id", P("@id", id)); // child table গুলো ON DELETE CASCADE
                TryDeleteDir("~/Uploads/StyleImages/" + id);
                TryDeleteDir("~/Uploads/StyleDocs/" + id);
                ShowMessage("Deleted Successfully!");
                LoadStyleList();
            }
            catch (Exception ex) { ShowMessage(ex.Message); }
        }

        private void TryDeleteDir(string virtualPath)
        {
            try { string p = Server.MapPath(virtualPath); if (Directory.Exists(p)) Directory.Delete(p, true); } catch { }
        }

        // ================================================================
        //  CLEAR FORM
        // ================================================================
        private void ClearForm()
        {
            hfStyleId.Value = "0";
            hfTab.Value = "";

            txtStyleID.Text = PreviewStyleCode();
            txtStyleNo.Text = ""; txtStyleName.Text = ""; txtStyleDesc.Text = "";
            ddlMainStatus.SelectedValue = "Draft";
            txtRevNo.Text = "00";

            ddlBuyer.SelectedIndex = 0; LoadBrands(0);
            ddlAgent.SelectedIndex = 0; ddlMerchandiser.SelectedIndex = 0;
            ddlSeason.SelectedIndex = 0; SetDdl(ddlSeasonYear, DateTime.Now.Year.ToString());
            ddlProductCategory.SelectedIndex = 0; ddlProductType.SelectedIndex = 0;
            ddlGarmentType.SelectedIndex = 0; ddlGender.SelectedIndex = 0;
            txtDepartment.Text = ""; txtDivision.Text = "";
            txtCreationDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            txtRemarks.Text = "";

            txtBuyerStyleNo.Text = ""; txtProductNo.Text = "";
            ddlCountry.SelectedIndex = 0; ddlCurrency.SelectedIndex = 0;
            ddlPaymentTerm.SelectedIndex = 0; ddlShipmentMode.SelectedIndex = 0;
            txtPortLoading.Text = ""; txtPortDischarge.Text = "";

            txtFabricType.Text = ""; ddlKnitWoven.SelectedIndex = 0; txtConstruction.Text = ""; txtSpecGsm.Text = "";
            txtSpecComposition.Text = ""; txtFabricWidth.Text = ""; txtFinish.Text = ""; txtWashType.Text = "";
            txtSleeve.Text = ""; txtNeck.Text = ""; txtClosure.Text = ""; txtPocket.Text = "";

            chkPrinting.Checked = chkEmbroidery.Checked = chkWashing.Checked = chkSpecial.Checked = false;
            txtPrintingDetails.Text = txtEmbroideryDetails.Text = txtWashingDetails.Text = txtSpecialDetails.Text = "";

            ddlTnaTemplate.SelectedIndex = 0;
            txtSampleDeadline.Text = txtPPMeeting.Text = txtFabricIn.Text = txtShipmentDate.Text = "";

            ViewState["dtColors"] = null; ViewState["dtSizes"] = null; ViewState["dtFabric"] = null; ViewState["dtAcc"] = null;
            BindChildGrids();

            ResetImages();
            gvDocs.DataSource = null; gvDocs.DataBind();
            gvCosting.DataSource = null; gvCosting.DataBind();
            gvApproval.DataSource = null; gvApproval.DataBind();
            gvHistory.DataSource = null; gvHistory.DataBind();
            ClearCostingLabels();
            txtCostTotal.Text = ""; txtCostFob.Text = ""; ddlCostStatus.SelectedIndex = 0;
            txtApprovalRemarks.Text = "";
            BuildWorkflow("Draft");
            txtSubmittedBy.Text = "Not submitted"; txtApprovedBy.Text = "Not submitted";

            lblCreatedBy.Text = "-"; lblCreatedDate.Text = "-"; lblModified.Text = "-";
            lblLock.Text = "Unlocked for Editing";
            SetBadge(bdgPO, "0 Records", "bg-secondary"); SetBadge(bdgCosting, "Pending", "bg-secondary");
            SetBadge(bdgFabric, "0 Records", "bg-secondary"); SetBadge(bdgAcc, "Pending", "bg-secondary");
            SetBadge(bdgTna, "Pending", "bg-secondary"); SetBadge(bdgPrint, "Not Req.", "bg-secondary"); SetBadge(bdgEmb, "Not Req.", "bg-secondary");

            UpdateButtons(false);
        }

        private void UpdateButtons(bool locked)
        {
            bool isNew = StyleId == 0;
            btnSave.Visible = isNew;
            btnUpdate.Visible = !isNew && !locked;
            btnCopyStyle.Visible = !isNew;
        }

        private void BindChildGrids()
        {
            gvColors.DataSource = ColorsDT; gvColors.DataBind();
            gvSizes.DataSource = SizesDT; gvSizes.DataBind();
            gvFabric.DataSource = FabricDT; gvFabric.DataBind();
            gvAcc.DataSource = AccDT; gvAcc.DataBind();
        }

        private void SetBadge(Label lbl, string text, string css)
        {
            lbl.Text = text;
            lbl.CssClass = "badge " + css;
        }

        // ================================================================
        //  STYLE CODE  (ST-2026-0001)
        // ================================================================
        private string PreviewStyleCode()
        {
            try
            {
                using (ConScope cs = new ConScope(conn.openConnection()))
                    return GenerateStyleCode(cs.Con, null);
            }
            catch { return "(Auto)"; }
        }

        private string GenerateStyleCode(SqlConnection cn, SqlTransaction tx)
        {
            string prefix = "ST-" + DateTime.Now.Year + "-";
            object o = ScalarTx(cn, tx,
                "SELECT ISNULL(MAX(CAST(RIGHT(StyleCode,4) AS INT)),0)+1 FROM " + MasterTbl + " WITH (UPDLOCK, HOLDLOCK) WHERE StyleCode LIKE @p + '%' AND ISNUMERIC(RIGHT(StyleCode,4))=1",
                P("@p", prefix));
            return prefix + Convert.ToInt32(o).ToString("0000");
        }

        // ================================================================
        //  LOAD STYLE (Edit)
        // ================================================================
        private void LoadStyle(int id)
        {
            try
            {
                DataTable m = GetTable("SELECT * FROM " + MasterTbl + " WHERE StyleID=@id", P("@id", id));
                if (m.Rows.Count == 0) { ShowMessage("Style not found!"); return; }
                DataRow r = m.Rows[0];

                ClearForm();
                StyleId = id;

                txtStyleID.Text = Str(r["StyleCode"]);
                txtStyleNo.Text = Str(r["StyleNo"]);
                txtStyleName.Text = Str(r["StyleName"]);
                txtStyleDesc.Text = Str(r["StyleDescription"]);

                SetDdl(ddlBuyer, Str(r["BuyerID"]));
                int buyerId; int.TryParse(Str(r["BuyerID"]), out buyerId);
                LoadBrands(buyerId);
                SetDdl(ddlBrand, Str(r["BrandID"]));
                SetDdl(ddlAgent, Str(r["AgentID"]));
                SetDdl(ddlMerchandiser, Str(r["MerchandiserID"]));
                SetDdl(ddlSeason, Str(r["SeasonName"]));
                SetDdl(ddlSeasonYear, Str(r["SeasonYear"]));
                SetDdl(ddlProductCategory, Str(r["ProductCategory"]));
                SetDdl(ddlProductType, Str(r["ProductType"]));
                SetDdl(ddlGarmentType, Str(r["GarmentType"]));
                SetDdl(ddlGender, Str(r["Gender"]));
                txtDepartment.Text = Str(r["Department"]);
                txtDivision.Text = Str(r["Division"]);
                txtCreationDate.Text = DateStr(r["CreationDate"]);
                txtRemarks.Text = Str(r["InternalRemarks"]);

                // Commercial
                DataTable t = GetTable("SELECT * FROM techdefendersbd.tbl_Mer_StyleCommercial WHERE StyleID=@id", P("@id", id));
                if (t.Rows.Count > 0)
                {
                    DataRow c = t.Rows[0];
                    txtBuyerStyleNo.Text = Str(c["BuyerStyleNo"]); txtProductNo.Text = Str(c["ProductNo"]);
                    SetDdl(ddlCountry, Str(c["DestinationCountry"]));
                    SetDdl(ddlCurrency, Str(c["Currency"]));
                    SetDdl(ddlPaymentTerm, Str(c["PaymentTerm"]));
                    SetDdl(ddlShipmentMode, Str(c["ShipmentMode"]));
                    txtPortLoading.Text = Str(c["PortOfLoading"]); txtPortDischarge.Text = Str(c["PortOfDischarge"]);
                }

                // Specification
                t = GetTable("SELECT * FROM techdefendersbd.tbl_Mer_StyleSpecification WHERE StyleID=@id", P("@id", id));
                if (t.Rows.Count > 0)
                {
                    DataRow s = t.Rows[0];
                    txtFabricType.Text = Str(s["FabricType"]); SetDdl(ddlKnitWoven, Str(s["KnitWoven"]));
                    txtConstruction.Text = Str(s["Construction"]); txtSpecGsm.Text = Str(s["GSM"]);
                    txtSpecComposition.Text = Str(s["Composition"]); txtFabricWidth.Text = Str(s["FabricWidth"]);
                    txtFinish.Text = Str(s["Finish"]); txtWashType.Text = Str(s["WashType"]);
                    txtSleeve.Text = Str(s["SleeveType"]); txtNeck.Text = Str(s["NeckType"]);
                    txtClosure.Text = Str(s["ClosureType"]); txtPocket.Text = Str(s["PocketType"]);
                }

                // Work Order flags
                t = GetTable("SELECT * FROM techdefendersbd.tbl_Mer_StyleWorkOrder WHERE StyleID=@id", P("@id", id));
                if (t.Rows.Count > 0)
                {
                    DataRow w = t.Rows[0];
                    chkPrinting.Checked = Convert.ToBoolean(w["PrintingRequired"]); txtPrintingDetails.Text = Str(w["PrintingDetails"]);
                    chkEmbroidery.Checked = Convert.ToBoolean(w["EmbroideryRequired"]); txtEmbroideryDetails.Text = Str(w["EmbroideryDetails"]);
                    chkWashing.Checked = Convert.ToBoolean(w["WashingRequired"]); txtWashingDetails.Text = Str(w["WashingDetails"]);
                    chkSpecial.Checked = Convert.ToBoolean(w["SpecialProcessRequired"]); txtSpecialDetails.Text = Str(w["SpecialProcessDetails"]);
                }

                // TNA
                t = GetTable("SELECT * FROM techdefendersbd.tbl_Mer_StyleTNA WHERE StyleID=@id", P("@id", id));
                bool hasTna = t.Rows.Count > 0;
                if (hasTna)
                {
                    DataRow n = t.Rows[0];
                    SetDdl(ddlTnaTemplate, Str(n["TemplateName"]));
                    txtSampleDeadline.Text = DateStr(n["SampleDeadline"]); txtPPMeeting.Text = DateStr(n["PPMeetingDate"]);
                    txtFabricIn.Text = DateStr(n["FabricInDate"]); txtShipmentDate.Text = DateStr(n["ShipmentDate"]);
                }

                // Color / Size / Fabric / Accessories
                ColorsDT = GetTable("SELECT ColorCode, ColorName, PantoneCode, IsActive FROM techdefendersbd.tbl_Mer_StyleColors WHERE StyleID=@id ORDER BY ColorRowID", P("@id", id));
                SizesDT = GetTable("SELECT SizeCode, SizeName, SizeRange, IsActive FROM techdefendersbd.tbl_Mer_StyleSizes WHERE StyleID=@id ORDER BY SizeRowID", P("@id", id));
                FabricDT = GetTable("SELECT FabricCode, FabricName, Composition, GSM, ColorName, ISNULL(Consumption,0) AS Consumption, ISNULL(WastagePercent,0) AS WastagePercent, Unit FROM techdefendersbd.tbl_Mer_StyleFabric WHERE StyleID=@id ORDER BY FabricRowID", P("@id", id));
                AccDT = GetTable("SELECT ItemCode, ItemName, ItemType, SizeColor, ISNULL(Consumption,0) AS Consumption, Unit, ISNULL(WastagePercent,0) AS WastagePercent, Supplier FROM techdefendersbd.tbl_Mer_StyleAccessories WHERE StyleID=@id ORDER BY AccessoryRowID", P("@id", id));
                BindChildGrids();

                LoadImages(id);
                LoadDocs(id);
                LoadCosting(id);
                LoadApproval(id);
                LoadHistory(id);
                LoadSummary(id);
                LoadSidebar(id, buyerId, hasTna);

                ShowEntry();
            }
            catch (Exception ex) { ShowMessage(ex.Message); }
        }

        // Header status, rev, summary, lock
        private void LoadSummary(int id)
        {
            DataTable m = GetTable("SELECT StyleStatus, RevisionNo, IsLocked, CreatedBy, CreatedDate, ModifiedBy, ModifiedDate FROM " + MasterTbl + " WHERE StyleID=@id", P("@id", id));
            if (m.Rows.Count == 0) return;
            DataRow r = m.Rows[0];
            SetDdl(ddlMainStatus, Str(r["StyleStatus"]));
            txtRevNo.Text = Convert.ToInt32(r["RevisionNo"]).ToString("00");
            bool locked = Convert.ToBoolean(r["IsLocked"]);

            lblCreatedBy.Text = Str(r["CreatedBy"]);
            lblCreatedDate.Text = DateStr(r["CreatedDate"]);
            lblModified.Text = r["ModifiedDate"] == DBNull.Value ? "-" : Convert.ToDateTime(r["ModifiedDate"]).ToString("yyyy-MM-dd HH:mm") + " (" + Str(r["ModifiedBy"]) + ")";
            lblLock.Text = locked ? "Locked (Active)" : "Unlocked for Editing";
            ddlMainStatus.Enabled = !locked;
            UpdateButtons(locked);
        }

        private void LoadSidebar(int id, int buyerId, bool hasTna)
        {
            try
            {
                string sn = txtStyleNo.Text.Trim(), name = txtStyleName.Text.Trim();
                DataTable po = GetTable(@"SELECT COUNT(1) FROM techdefendersbd.tbl_POEntryInformation p
                                          INNER JOIN techdefendersbd.Style_Master sm ON sm.StyleId = p.StyleId
                                          WHERE sm.BuyerName = @b AND (sm.StyleName = @sn OR sm.StyleName = @nm)",
                                         P("@b", buyerId), P("@sn", sn), P("@nm", name));
                int pc = Convert.ToInt32(po.Rows[0][0]);
                SetBadge(bdgPO, pc + " Records", pc > 0 ? "bg-success" : "bg-secondary");
            }
            catch { }

            SetBadge(bdgFabric, FabricDT.Rows.Count + " Records", FabricDT.Rows.Count > 0 ? "bg-warning text-dark" : "bg-secondary");
            if (AccDT.Rows.Count > 0) SetBadge(bdgAcc, AccDT.Rows.Count + " Records", "bg-warning text-dark"); else SetBadge(bdgAcc, "Pending", "bg-secondary");
            if (hasTna) SetBadge(bdgTna, "Active", "bg-success"); else SetBadge(bdgTna, "Pending", "bg-secondary");
            if (chkPrinting.Checked) SetBadge(bdgPrint, "Required", "bg-success"); else SetBadge(bdgPrint, "Not Req.", "bg-secondary");
            if (chkEmbroidery.Checked) SetBadge(bdgEmb, "Required", "bg-success"); else SetBadge(bdgEmb, "Not Req.", "bg-secondary");
        }

        // ================================================================
        //  SAVE / UPDATE
        // ================================================================
        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtStyleNo.Text)) { ShowMessage("Style No is required!"); return; }
            if (string.IsNullOrWhiteSpace(txtStyleName.Text)) { ShowMessage("Style Name is required!"); return; }
            if (string.IsNullOrEmpty(ddlBuyer.SelectedValue)) { ShowMessage("Please select a Buyer!"); return; }
            if (string.IsNullOrEmpty(ddlMerchandiser.SelectedValue)) { ShowMessage("Please select Assigned Merchandiser!"); return; }

            bool wasNew = StyleId == 0;
            try
            {
                int id = SaveStyle();
                SaveImages(id);
                LoadStyle(id);
                ShowMessage(wasNew ? "Saved Successfully!" : "Updated Successfully!");
            }
            catch (Exception ex) { ShowMessage(ex.Message); }
        }

        private SqlParameter[] MasterParams()
        {
            return new SqlParameter[]
            {
                P("@no", txtStyleNo.Text.Trim()),
                P("@name", txtStyleName.Text.Trim()),
                P("@desc", N(txtStyleDesc.Text)),
                P("@buyer", NI(ddlBuyer.SelectedValue)),
                P("@brand", NI(ddlBrand.SelectedValue)),
                P("@agent", NI(ddlAgent.SelectedValue)),
                P("@season", N(ddlSeason.SelectedValue)),
                P("@year", NI(ddlSeasonYear.SelectedValue)),
                P("@cat", N(ddlProductCategory.SelectedValue)),
                P("@ptype", N(ddlProductType.SelectedValue)),
                P("@gtype", N(ddlGarmentType.SelectedValue)),
                P("@gender", N(ddlGender.SelectedValue)),
                P("@dept", N(txtDepartment.Text)),
                P("@div", N(txtDivision.Text)),
                P("@merch", NI(ddlMerchandiser.SelectedValue)),
                P("@cdate", ParseDate(txtCreationDate.Text)),
                P("@remarks", N(txtRemarks.Text)),
                P("@status", ddlMainStatus.SelectedValue),
                P("@locked", ddlMainStatus.SelectedValue == "Active"),
                P("@user", CurrentUser)
            };
        }

        private int SaveStyle()
        {
            int id = StyleId;
            bool isNew = id == 0;

            using (ConScope cs = new ConScope(conn.openConnection()))
            {
                SqlConnection cn = cs.Con;
                SqlTransaction tx = cn.BeginTransaction();
                try
                {
                    int buyerId; int.TryParse(ddlBuyer.SelectedValue, out buyerId);

                    object dup = ScalarTx(cn, tx,
                        "SELECT COUNT(1) FROM " + MasterTbl + " WHERE StyleNo=@no AND ISNULL(BuyerID,0)=@b AND StyleID<>@id",
                        P("@no", txtStyleNo.Text.Trim()), P("@b", buyerId), P("@id", id));
                    if (Convert.ToInt32(dup) > 0) throw new ApplicationException("This Style No already exists for the selected buyer.");

                    string oldStatus = null;

                    if (isNew)
                    {
                        string code = GenerateStyleCode(cn, tx);
                        SqlParameter[] ps = MasterParams();
                        SqlParameter[] all = new SqlParameter[ps.Length + 1];
                        ps.CopyTo(all, 0);
                        all[ps.Length] = P("@code", code);

                        id = Convert.ToInt32(ScalarTx(cn, tx, @"
                            INSERT INTO " + MasterTbl + @"
                              (StyleCode, StyleNo, StyleName, StyleDescription, BuyerID, BrandID, AgentID, SeasonName, SeasonYear,
                               ProductCategory, ProductType, GarmentType, Gender, Department, Division, MerchandiserID, CreationDate,
                               InternalRemarks, StyleStatus, RevisionNo, IsLocked, CreatedBy, CreatedDate)
                            VALUES
                              (@code, @no, @name, @desc, @buyer, @brand, @agent, @season, @year,
                               @cat, @ptype, @gtype, @gender, @dept, @div, @merch, @cdate,
                               @remarks, @status, 0, @locked, @user, GETDATE());
                            SELECT CAST(SCOPE_IDENTITY() AS INT);", all));

                        AddHistory(cn, tx, id, "Created", "StyleCode", null, code, "Initial style record entry");
                    }
                    else
                    {
                        DataTable cur = GetTableTx(cn, tx, "SELECT StyleStatus, IsLocked FROM " + MasterTbl + " WHERE StyleID=@id", P("@id", id));
                        if (cur.Rows.Count == 0) throw new ApplicationException("Style not found.");
                        if (Convert.ToBoolean(cur.Rows[0]["IsLocked"])) throw new ApplicationException("This style is Active (Locked) and cannot be edited.");
                        oldStatus = Str(cur.Rows[0]["StyleStatus"]);

                        SqlParameter[] ps = MasterParams();
                        SqlParameter[] all = new SqlParameter[ps.Length + 1];
                        ps.CopyTo(all, 0);
                        all[ps.Length] = P("@id", id);

                        ExecTx(cn, tx, @"
                            UPDATE " + MasterTbl + @"
                            SET StyleNo=@no, StyleName=@name, StyleDescription=@desc, BuyerID=@buyer, BrandID=@brand, AgentID=@agent,
                                SeasonName=@season, SeasonYear=@year, ProductCategory=@cat, ProductType=@ptype, GarmentType=@gtype,
                                Gender=@gender, Department=@dept, Division=@div, MerchandiserID=@merch, CreationDate=@cdate,
                                InternalRemarks=@remarks, StyleStatus=@status, IsLocked=@locked,
                                ModifiedBy=@user, ModifiedDate=GETDATE()
                            WHERE StyleID=@id", all);

                        AddHistory(cn, tx, id, "Updated", null, null, null, "Style information updated");
                        if (oldStatus != ddlMainStatus.SelectedValue)
                            AddHistory(cn, tx, id, "Status Changed", "StyleStatus", oldStatus, ddlMainStatus.SelectedValue, null);
                    }

                    SaveChildren(cn, tx, id);

                    tx.Commit();
                    return id;
                }
                catch
                {
                    try { tx.Rollback(); } catch { }
                    throw;
                }
            }
        }

        private void SaveChildren(SqlConnection cn, SqlTransaction tx, int id)
        {
            // ---- Commercial (1:1) ----
            ExecTx(cn, tx, @"
                UPDATE techdefendersbd.tbl_Mer_StyleCommercial
                   SET BuyerStyleNo=@bsn, ProductNo=@pno, DestinationCountry=@dc, Currency=@cur, PaymentTerm=@pt,
                       ShipmentMode=@sm, PortOfLoading=@pol, PortOfDischarge=@pod
                 WHERE StyleID=@sid;
                IF @@ROWCOUNT = 0
                    INSERT INTO techdefendersbd.tbl_Mer_StyleCommercial
                        (StyleID, BuyerStyleNo, ProductNo, DestinationCountry, Currency, PaymentTerm, ShipmentMode, PortOfLoading, PortOfDischarge)
                    VALUES (@sid, @bsn, @pno, @dc, @cur, @pt, @sm, @pol, @pod);",
                P("@sid", id), P("@bsn", N(txtBuyerStyleNo.Text)), P("@pno", N(txtProductNo.Text)),
                P("@dc", N(ddlCountry.SelectedValue)), P("@cur", N(ddlCurrency.SelectedValue)), P("@pt", N(ddlPaymentTerm.SelectedValue)),
                P("@sm", N(ddlShipmentMode.SelectedValue)), P("@pol", N(txtPortLoading.Text)), P("@pod", N(txtPortDischarge.Text)));

            // ---- Specification (1:1) ----
            ExecTx(cn, tx, @"
                UPDATE techdefendersbd.tbl_Mer_StyleSpecification
                   SET FabricType=@ft, KnitWoven=@kw, Construction=@con, GSM=@gsm, Composition=@comp, FabricWidth=@fw,
                       Finish=@fin, WashType=@wash, SleeveType=@sl, NeckType=@nk, ClosureType=@cl, PocketType=@pk
                 WHERE StyleID=@sid;
                IF @@ROWCOUNT = 0
                    INSERT INTO techdefendersbd.tbl_Mer_StyleSpecification
                        (StyleID, FabricType, KnitWoven, Construction, GSM, Composition, FabricWidth, Finish, WashType, SleeveType, NeckType, ClosureType, PocketType)
                    VALUES (@sid, @ft, @kw, @con, @gsm, @comp, @fw, @fin, @wash, @sl, @nk, @cl, @pk);",
                P("@sid", id), P("@ft", N(txtFabricType.Text)), P("@kw", N(ddlKnitWoven.SelectedValue)), P("@con", N(txtConstruction.Text)),
                P("@gsm", N(txtSpecGsm.Text)), P("@comp", N(txtSpecComposition.Text)), P("@fw", N(txtFabricWidth.Text)),
                P("@fin", N(txtFinish.Text)), P("@wash", N(txtWashType.Text)), P("@sl", N(txtSleeve.Text)), P("@nk", N(txtNeck.Text)),
                P("@cl", N(txtClosure.Text)), P("@pk", N(txtPocket.Text)));

            // ---- Work Order flags (1:1) ----
            ExecTx(cn, tx, @"
                UPDATE techdefendersbd.tbl_Mer_StyleWorkOrder
                   SET PrintingRequired=@pr, PrintingDetails=@prd, EmbroideryRequired=@er, EmbroideryDetails=@erd,
                       WashingRequired=@wr, WashingDetails=@wrd, SpecialProcessRequired=@sr, SpecialProcessDetails=@srd
                 WHERE StyleID=@sid;
                IF @@ROWCOUNT = 0
                    INSERT INTO techdefendersbd.tbl_Mer_StyleWorkOrder
                        (StyleID, PrintingRequired, PrintingDetails, EmbroideryRequired, EmbroideryDetails, WashingRequired, WashingDetails, SpecialProcessRequired, SpecialProcessDetails)
                    VALUES (@sid, @pr, @prd, @er, @erd, @wr, @wrd, @sr, @srd);",
                P("@sid", id), P("@pr", chkPrinting.Checked), P("@prd", N(txtPrintingDetails.Text)),
                P("@er", chkEmbroidery.Checked), P("@erd", N(txtEmbroideryDetails.Text)),
                P("@wr", chkWashing.Checked), P("@wrd", N(txtWashingDetails.Text)),
                P("@sr", chkSpecial.Checked), P("@srd", N(txtSpecialDetails.Text)));

            // ---- TNA (1:1) ----
            ExecTx(cn, tx, @"
                UPDATE techdefendersbd.tbl_Mer_StyleTNA
                   SET TemplateName=@tn, SampleDeadline=@sd, PPMeetingDate=@pp, FabricInDate=@fi, ShipmentDate=@sh
                 WHERE StyleID=@sid;
                IF @@ROWCOUNT = 0
                    INSERT INTO techdefendersbd.tbl_Mer_StyleTNA (StyleID, TemplateName, SampleDeadline, PPMeetingDate, FabricInDate, ShipmentDate)
                    VALUES (@sid, @tn, @sd, @pp, @fi, @sh);",
                P("@sid", id), P("@tn", N(ddlTnaTemplate.SelectedValue)), P("@sd", ParseDate(txtSampleDeadline.Text)),
                P("@pp", ParseDate(txtPPMeeting.Text)), P("@fi", ParseDate(txtFabricIn.Text)), P("@sh", ParseDate(txtShipmentDate.Text)));

            // ---- Colors ----
            ExecTx(cn, tx, "DELETE FROM techdefendersbd.tbl_Mer_StyleColors WHERE StyleID=@sid", P("@sid", id));
            foreach (DataRow r in ColorsDT.Rows)
                ExecTx(cn, tx, "INSERT INTO techdefendersbd.tbl_Mer_StyleColors (StyleID, ColorCode, ColorName, PantoneCode, IsActive) VALUES (@sid,@c,@n,@p,@a)",
                    P("@sid", id), P("@c", r["ColorCode"]), P("@n", r["ColorName"]), P("@p", r["PantoneCode"]), P("@a", Convert.ToBoolean(r["IsActive"])));

            // ---- Sizes ----
            ExecTx(cn, tx, "DELETE FROM techdefendersbd.tbl_Mer_StyleSizes WHERE StyleID=@sid", P("@sid", id));
            foreach (DataRow r in SizesDT.Rows)
                ExecTx(cn, tx, "INSERT INTO techdefendersbd.tbl_Mer_StyleSizes (StyleID, SizeCode, SizeName, SizeRange, IsActive) VALUES (@sid,@c,@n,@r,@a)",
                    P("@sid", id), P("@c", r["SizeCode"]), P("@n", r["SizeName"]), P("@r", r["SizeRange"]), P("@a", Convert.ToBoolean(r["IsActive"])));

            // ---- Fabric ----
            ExecTx(cn, tx, "DELETE FROM techdefendersbd.tbl_Mer_StyleFabric WHERE StyleID=@sid", P("@sid", id));
            foreach (DataRow r in FabricDT.Rows)
                ExecTx(cn, tx, @"INSERT INTO techdefendersbd.tbl_Mer_StyleFabric (StyleID, FabricCode, FabricName, Composition, GSM, ColorName, Consumption, WastagePercent, Unit)
                                 VALUES (@sid,@c,@n,@comp,@gsm,@col,@cons,@w,@u)",
                    P("@sid", id), P("@c", r["FabricCode"]), P("@n", r["FabricName"]), P("@comp", r["Composition"]), P("@gsm", r["GSM"]),
                    P("@col", r["ColorName"]), P("@cons", r["Consumption"]), P("@w", r["WastagePercent"]), P("@u", r["Unit"]));

            // ---- Accessories ----
            ExecTx(cn, tx, "DELETE FROM techdefendersbd.tbl_Mer_StyleAccessories WHERE StyleID=@sid", P("@sid", id));
            foreach (DataRow r in AccDT.Rows)
                ExecTx(cn, tx, @"INSERT INTO techdefendersbd.tbl_Mer_StyleAccessories (StyleID, ItemCode, ItemName, ItemType, SizeColor, Consumption, Unit, WastagePercent, Supplier)
                                 VALUES (@sid,@c,@n,@t,@sc,@cons,@u,@w,@sup)",
                    P("@sid", id), P("@c", r["ItemCode"]), P("@n", r["ItemName"]), P("@t", r["ItemType"]), P("@sc", r["SizeColor"]),
                    P("@cons", r["Consumption"]), P("@u", r["Unit"]), P("@w", r["WastagePercent"]), P("@sup", r["Supplier"]));
        }

        private void AddHistory(SqlConnection cn, SqlTransaction tx, int styleId, string type, string field, string prev, string now, string remarks)
        {
            ExecTx(cn, tx, @"INSERT INTO techdefendersbd.tbl_Mer_StyleHistory (StyleID, ActionDateTime, ActionByUser, ActionType, FieldName, PreviousValue, NewValue, Remarks)
                             VALUES (@sid, GETDATE(), @u, @t, @f, @p, @n, @r)",
                P("@sid", styleId), P("@u", CurrentUser), P("@t", type), P("@f", N(field)), P("@p", N(prev)), P("@n", N(now)), P("@r", N(remarks)));
        }

        private void LoadHistory(int id)
        {
            gvHistory.DataSource = GetTable("SELECT TOP 200 * FROM techdefendersbd.tbl_Mer_StyleHistory WHERE StyleID=@id ORDER BY HistoryID DESC", P("@id", id));
            gvHistory.DataBind();
        }

        // ================================================================
        //  TOP BUTTONS : Reset / Close / Copy
        // ================================================================
        protected void btnReset_Click(object sender, EventArgs e)
        {
            int id = StyleId;
            if (id > 0) LoadStyle(id); else ClearForm();
        }

        protected void btnClose_Click(object sender, EventArgs e)
        {
            ClearForm();
            ShowList();
            LoadStyleList();
        }

        protected void btnCopyStyle_Click(object sender, EventArgs e)
        {
            int src = StyleId;
            if (src == 0) { ShowMessage("Please save the style first."); return; }
            try
            {
                int newId;
                using (ConScope cs = new ConScope(conn.openConnection()))
                {
                    SqlConnection cn = cs.Con;
                    SqlTransaction tx = cn.BeginTransaction();
                    try
                    {
                        string code = GenerateStyleCode(cn, tx);
                        newId = Convert.ToInt32(ScalarTx(cn, tx, @"
                            INSERT INTO " + MasterTbl + @"
                              (StyleCode, StyleNo, StyleName, StyleDescription, BuyerID, BrandID, AgentID, SeasonName, SeasonYear,
                               ProductCategory, ProductType, GarmentType, Gender, Department, Division, MerchandiserID, CreationDate,
                               InternalRemarks, StyleStatus, RevisionNo, IsLocked, CreatedBy, CreatedDate)
                            SELECT @code, LEFT(StyleNo + '-COPY', 50), LEFT(StyleName + ' (Copy)', 150), StyleDescription, BuyerID, BrandID, AgentID, SeasonName, SeasonYear,
                                   ProductCategory, ProductType, GarmentType, Gender, Department, Division, MerchandiserID, CAST(GETDATE() AS DATE),
                                   InternalRemarks, 'Draft', 0, 0, @u, GETDATE()
                            FROM " + MasterTbl + @" WHERE StyleID = @src;
                            SELECT CAST(SCOPE_IDENTITY() AS INT);",
                            P("@code", code), P("@u", CurrentUser), P("@src", src)));

                        SqlParameter s = null;
                        string[] sqls = new string[]
                        {
                            "INSERT INTO techdefendersbd.tbl_Mer_StyleColors (StyleID,ColorCode,ColorName,PantoneCode,IsActive) SELECT @n,ColorCode,ColorName,PantoneCode,IsActive FROM techdefendersbd.tbl_Mer_StyleColors WHERE StyleID=@s",
                            "INSERT INTO techdefendersbd.tbl_Mer_StyleSizes (StyleID,SizeCode,SizeName,SizeRange,IsActive) SELECT @n,SizeCode,SizeName,SizeRange,IsActive FROM techdefendersbd.tbl_Mer_StyleSizes WHERE StyleID=@s",
                            "INSERT INTO techdefendersbd.tbl_Mer_StyleFabric (StyleID,FabricCode,FabricName,Composition,GSM,ColorName,Consumption,WastagePercent,Unit) SELECT @n,FabricCode,FabricName,Composition,GSM,ColorName,Consumption,WastagePercent,Unit FROM techdefendersbd.tbl_Mer_StyleFabric WHERE StyleID=@s",
                            "INSERT INTO techdefendersbd.tbl_Mer_StyleAccessories (StyleID,ItemCode,ItemName,ItemType,SizeColor,Consumption,Unit,WastagePercent,Supplier) SELECT @n,ItemCode,ItemName,ItemType,SizeColor,Consumption,Unit,WastagePercent,Supplier FROM techdefendersbd.tbl_Mer_StyleAccessories WHERE StyleID=@s",
                            "INSERT INTO techdefendersbd.tbl_Mer_StyleCommercial (StyleID,BuyerStyleNo,ProductNo,DestinationCountry,Currency,PaymentTerm,ShipmentMode,PortOfLoading,PortOfDischarge) SELECT @n,BuyerStyleNo,ProductNo,DestinationCountry,Currency,PaymentTerm,ShipmentMode,PortOfLoading,PortOfDischarge FROM techdefendersbd.tbl_Mer_StyleCommercial WHERE StyleID=@s",
                            "INSERT INTO techdefendersbd.tbl_Mer_StyleSpecification (StyleID,FabricType,KnitWoven,Construction,GSM,Composition,FabricWidth,Finish,WashType,SleeveType,NeckType,ClosureType,PocketType) SELECT @n,FabricType,KnitWoven,Construction,GSM,Composition,FabricWidth,Finish,WashType,SleeveType,NeckType,ClosureType,PocketType FROM techdefendersbd.tbl_Mer_StyleSpecification WHERE StyleID=@s",
                            "INSERT INTO techdefendersbd.tbl_Mer_StyleTNA (StyleID,TemplateName,SampleDeadline,PPMeetingDate,FabricInDate,ShipmentDate) SELECT @n,TemplateName,SampleDeadline,PPMeetingDate,FabricInDate,ShipmentDate FROM techdefendersbd.tbl_Mer_StyleTNA WHERE StyleID=@s",
                            "INSERT INTO techdefendersbd.tbl_Mer_StyleWorkOrder (StyleID,PrintingRequired,PrintingDetails,EmbroideryRequired,EmbroideryDetails,WashingRequired,WashingDetails,SpecialProcessRequired,SpecialProcessDetails) SELECT @n,PrintingRequired,PrintingDetails,EmbroideryRequired,EmbroideryDetails,WashingRequired,WashingDetails,SpecialProcessRequired,SpecialProcessDetails FROM techdefendersbd.tbl_Mer_StyleWorkOrder WHERE StyleID=@s"
                        };
                        foreach (string q in sqls)
                            ExecTx(cn, tx, q, P("@n", newId), P("@s", src));

                        AddHistory(cn, tx, newId, "Created", "StyleCode", null, code, "Copied from style ID " + src);
                        tx.Commit();
                    }
                    catch
                    {
                        try { tx.Rollback(); } catch { }
                        throw;
                    }
                }

                LoadStyle(newId);
                ShowMessage("Style copied. Please change Style No / Name and Save.");
            }
            catch (Exception ex) { ShowMessage(ex.Message); }
        }

        // ================================================================
        //  COLOR / SIZE / FABRIC / ACCESSORIES  (grid add / delete)
        // ================================================================
        protected void btnAddColor_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(ddlColor.SelectedValue)) { ShowMessage("Please select a color!"); return; }
            string code = ddlColor.SelectedValue;
            foreach (DataRow r in ColorsDT.Rows)
                if (Str(r["ColorCode"]) == code) { ShowMessage("This color is already added."); return; }

            ColorsDT.Rows.Add(code, ddlColor.SelectedItem.Text, txtPantone.Text.Trim(), true);
            txtPantone.Text = "";
            ddlColor.SelectedIndex = 0;
            gvColors.DataSource = ColorsDT; gvColors.DataBind();
        }

        protected void gvColors_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int i; if (e.CommandName == "DelRow" && int.TryParse(Convert.ToString(e.CommandArgument), out i) && i >= 0 && i < ColorsDT.Rows.Count)
            { ColorsDT.Rows.RemoveAt(i); gvColors.DataSource = ColorsDT; gvColors.DataBind(); }
        }

        protected void btnAddSize_Click(object sender, EventArgs e)
        {
            int sid;
            if (!int.TryParse(ddlSize.SelectedValue, out sid) || sid <= 0) { ShowMessage("Please select a size!"); return; }
            string code = "S" + sid.ToString("00");
            foreach (DataRow r in SizesDT.Rows)
                if (Str(r["SizeCode"]) == code) { ShowMessage("This size is already added."); return; }

            DataTable s = GetTable("SELECT s.SizeName, ISNULL(g.GroupName,'') AS GroupName FROM techdefendersbd.Sizes s LEFT JOIN techdefendersbd.SizeGroups g ON g.GroupID=s.GroupID WHERE s.SizeID=@id", P("@id", sid));
            if (s.Rows.Count == 0) return;
            SizesDT.Rows.Add(code, Str(s.Rows[0]["SizeName"]), Str(s.Rows[0]["GroupName"]), true);
            ddlSize.SelectedIndex = 0;
            gvSizes.DataSource = SizesDT; gvSizes.DataBind();
        }

        protected void gvSizes_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int i; if (e.CommandName == "DelRow" && int.TryParse(Convert.ToString(e.CommandArgument), out i) && i >= 0 && i < SizesDT.Rows.Count)
            { SizesDT.Rows.RemoveAt(i); gvSizes.DataSource = SizesDT; gvSizes.DataBind(); }
        }

        protected void btnAddFabric_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtFabCode.Text) || string.IsNullOrWhiteSpace(txtFabName.Text)) { ShowMessage("Fabric Code and Fabric Name are required!"); return; }
            FabricDT.Rows.Add(txtFabCode.Text.Trim(), txtFabName.Text.Trim(), txtFabComp.Text.Trim(), txtFabGsm.Text.Trim(), txtFabColor.Text.Trim(),
                              Dec(txtFabCons.Text), Dec(txtFabWaste.Text), ddlFabUnit.SelectedValue);
            txtFabCode.Text = txtFabName.Text = txtFabComp.Text = txtFabGsm.Text = txtFabColor.Text = txtFabCons.Text = txtFabWaste.Text = "";
            gvFabric.DataSource = FabricDT; gvFabric.DataBind();
        }

        protected void gvFabric_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int i; if (e.CommandName == "DelRow" && int.TryParse(Convert.ToString(e.CommandArgument), out i) && i >= 0 && i < FabricDT.Rows.Count)
            { FabricDT.Rows.RemoveAt(i); gvFabric.DataSource = FabricDT; gvFabric.DataBind(); }
        }

        protected void btnAddAcc_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtAccCode.Text) || string.IsNullOrWhiteSpace(txtAccName.Text)) { ShowMessage("Item Code and Item Name are required!"); return; }
            AccDT.Rows.Add(txtAccCode.Text.Trim(), txtAccName.Text.Trim(), ddlAccType.SelectedValue, txtAccSizeColor.Text.Trim(),
                           Dec(txtAccCons.Text), ddlAccUnit.SelectedValue, Dec(txtAccWaste.Text), txtAccSupplier.Text.Trim());
            txtAccCode.Text = txtAccName.Text = txtAccSizeColor.Text = txtAccCons.Text = txtAccWaste.Text = txtAccSupplier.Text = "";
            gvAcc.DataSource = AccDT; gvAcc.DataBind();
        }

        protected void gvAcc_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int i; if (e.CommandName == "DelRow" && int.TryParse(Convert.ToString(e.CommandArgument), out i) && i >= 0 && i < AccDT.Rows.Count)
            { AccDT.Rows.RemoveAt(i); gvAcc.DataSource = AccDT; gvAcc.DataBind(); }
        }

        // ================================================================
        //  IMAGES
        // ================================================================
        private void ResetImages()
        {
            foreach (string t in new[] { "Front", "Back", "Technical" }) SetImageControls(t, null);
        }

        private void SetImageControls(string type, DataRow r)
        {
            Image img; Label lbl; HyperLink lnk; LinkButton del;
            switch (type)
            {
                case "Front": img = imgFront; lbl = lblFrontName; lnk = lnkFrontZoom; del = btnDelFront; break;
                case "Back": img = imgBack; lbl = lblBackName; lnk = lnkBackZoom; del = btnDelBack; break;
                default: img = imgTech; lbl = lblTechName; lnk = lnkTechZoom; del = btnDelTech; break;
            }

            if (r == null)
            {
                img.Visible = false; lnk.Visible = false; del.Visible = false;
                lbl.Text = "No file selected";
                return;
            }

            string url = ResolveUrl(Str(r["FilePath"]));
            string fn = Str(r["FileName"]);
            bool isImg = false;
            string ext = Path.GetExtension(fn).ToLowerInvariant();
            if (ext == ".jpg" || ext == ".jpeg" || ext == ".png" || ext == ".gif" || ext == ".webp" || ext == ".bmp") isImg = true;

            img.Visible = isImg; if (isImg) img.ImageUrl = url;
            lnk.Visible = true; lnk.NavigateUrl = url;
            del.Visible = true;
            lbl.Text = fn;
        }

        private void LoadImages(int id)
        {
            ResetImages();
            DataTable dt = GetTable("SELECT ImageType, FilePath, FileName FROM techdefendersbd.tbl_Mer_StyleImages WHERE StyleID=@id ORDER BY ImageID", P("@id", id));
            foreach (DataRow r in dt.Rows) SetImageControls(Str(r["ImageType"]), r);
        }

        private void SaveImages(int id)
        {
            SaveOneImage(id, "Front", fuFront, new[] { ".jpg", ".jpeg", ".png", ".gif", ".webp", ".bmp" });
            SaveOneImage(id, "Back", fuBack, new[] { ".jpg", ".jpeg", ".png", ".gif", ".webp", ".bmp" });
            SaveOneImage(id, "Technical", fuTech, new[] { ".jpg", ".jpeg", ".png", ".gif", ".webp", ".bmp", ".pdf", ".svg", ".dxf", ".ai" });
        }

        private void SaveOneImage(int id, string type, FileUpload fu, string[] allowed)
        {
            if (!fu.HasFile) return;
            string ext = Path.GetExtension(fu.FileName).ToLowerInvariant();
            if (Array.IndexOf(allowed, ext) < 0) throw new ApplicationException(type + ": file type " + ext + " is not allowed.");
            if (fu.PostedFile.ContentLength > 10 * 1024 * 1024) throw new ApplicationException(type + ": file size must be under 10 MB.");

            string virtualDir = "~/Uploads/StyleImages/" + id;
            string phys = Server.MapPath(virtualDir);
            if (!Directory.Exists(phys)) Directory.CreateDirectory(phys);

            string saved = Guid.NewGuid().ToString("N") + ext;
            fu.SaveAs(Path.Combine(phys, saved));

            DataTable old = GetTable("SELECT FilePath FROM techdefendersbd.tbl_Mer_StyleImages WHERE StyleID=@id AND ImageType=@t", P("@id", id), P("@t", type));
            Exec("DELETE FROM techdefendersbd.tbl_Mer_StyleImages WHERE StyleID=@id AND ImageType=@t", P("@id", id), P("@t", type));
            Exec(@"INSERT INTO techdefendersbd.tbl_Mer_StyleImages (StyleID, ImageType, FilePath, FileName, UploadedBy, UploadedDate)
                   VALUES (@id, @t, @p, @f, @u, GETDATE())",
                 P("@id", id), P("@t", type), P("@p", virtualDir + "/" + saved), P("@f", Path.GetFileName(fu.FileName)), P("@u", CurrentUser));

            foreach (DataRow r in old.Rows) TryDeleteFile(Str(r["FilePath"]));
        }

        private void TryDeleteFile(string virtualPath)
        {
            try { string p = Server.MapPath(virtualPath); if (File.Exists(p)) File.Delete(p); } catch { }
        }

        protected void DeleteImage_Command(object sender, CommandEventArgs e)
        {
            int id = StyleId;
            if (id == 0) return;
            try
            {
                string type = Convert.ToString(e.CommandArgument);
                DataTable old = GetTable("SELECT FilePath FROM techdefendersbd.tbl_Mer_StyleImages WHERE StyleID=@id AND ImageType=@t", P("@id", id), P("@t", type));
                Exec("DELETE FROM techdefendersbd.tbl_Mer_StyleImages WHERE StyleID=@id AND ImageType=@t", P("@id", id), P("@t", type));
                foreach (DataRow r in old.Rows) TryDeleteFile(Str(r["FilePath"]));
                LoadImages(id);
            }
            catch (Exception ex) { ShowMessage(ex.Message); }
        }

        // ================================================================
        //  DOCUMENTS
        // ================================================================
        private void LoadDocs(int id)
        {
            gvDocs.DataSource = GetTable("SELECT DocumentID, DocumentName, DocumentType, FilePath, VersionNo, UploadedBy, UploadedDate FROM techdefendersbd.tbl_Mer_StyleDocuments WHERE StyleID=@id ORDER BY DocumentID DESC", P("@id", id));
            gvDocs.DataBind();
        }

        protected void btnUploadDoc_Click(object sender, EventArgs e)
        {
            int id = StyleId;
            if (id == 0) { ShowMessage("Please save the style first, then upload documents."); return; }
            if (!fuDoc.HasFile) { ShowMessage("Please choose a file."); return; }

            try
            {
                string ext = Path.GetExtension(fuDoc.FileName).ToLowerInvariant();
                string[] allowed = { ".pdf", ".doc", ".docx", ".xls", ".xlsx", ".ppt", ".pptx", ".jpg", ".jpeg", ".png", ".zip", ".rar", ".txt", ".csv" };
                if (Array.IndexOf(allowed, ext) < 0) { ShowMessage("File type " + ext + " is not allowed."); return; }
                if (fuDoc.PostedFile.ContentLength > 20 * 1024 * 1024) { ShowMessage("File size must be under 20 MB."); return; }

                string virtualDir = "~/Uploads/StyleDocs/" + id;
                string phys = Server.MapPath(virtualDir);
                if (!Directory.Exists(phys)) Directory.CreateDirectory(phys);
                string saved = Guid.NewGuid().ToString("N") + ext;
                fuDoc.SaveAs(Path.Combine(phys, saved));

                Exec(@"INSERT INTO techdefendersbd.tbl_Mer_StyleDocuments (StyleID, DocumentName, DocumentType, FilePath, VersionNo, UploadedBy, UploadedDate)
                       VALUES (@id, @n, @t, @p, @v, @u, GETDATE())",
                     P("@id", id), P("@n", Path.GetFileName(fuDoc.FileName)), P("@t", ddlDocType.SelectedValue),
                     P("@p", virtualDir + "/" + saved), P("@v", N(txtDocVersion.Text)), P("@u", CurrentUser));

                txtDocVersion.Text = "";
                LoadDocs(id);
            }
            catch (Exception ex) { ShowMessage(ex.Message); }
        }

        protected void gvDocs_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName != "DelDoc") return;
            int docId; if (!int.TryParse(Convert.ToString(e.CommandArgument), out docId)) return;
            try
            {
                DataTable old = GetTable("SELECT FilePath FROM techdefendersbd.tbl_Mer_StyleDocuments WHERE DocumentID=@d AND StyleID=@s", P("@d", docId), P("@s", StyleId));
                Exec("DELETE FROM techdefendersbd.tbl_Mer_StyleDocuments WHERE DocumentID=@d AND StyleID=@s", P("@d", docId), P("@s", StyleId));
                foreach (DataRow r in old.Rows) TryDeleteFile(Str(r["FilePath"]));
                LoadDocs(StyleId);
            }
            catch (Exception ex) { ShowMessage(ex.Message); }
        }

        // ================================================================
        //  COSTING
        // ================================================================
        private void ClearCostingLabels()
        {
            lblCostStatus.Text = "-"; lblCostVer.Text = "-"; lblTotalCost.Text = "-"; lblFob.Text = "-"; lblProfit.Text = "-";
        }

        private void LoadCosting(int id)
        {
            DataTable all = GetTable("SELECT VersionNo, CostingStatus, TotalCost, FOBPrice, ProfitMarginPercent, CostingDate, IsCurrent FROM techdefendersbd.tbl_Mer_StyleCosting WHERE StyleID=@id ORDER BY VersionNo DESC", P("@id", id));
            gvCosting.DataSource = all;
            gvCosting.DataBind();

            ClearCostingLabels();
            DataRow cur = null;
            foreach (DataRow r in all.Rows) if (Convert.ToBoolean(r["IsCurrent"])) { cur = r; break; }
            if (cur == null && all.Rows.Count > 0) cur = all.Rows[0];
            if (cur == null) { SetBadge(bdgCosting, "Pending", "bg-secondary"); return; }

            string cc = ddlCurrency.SelectedValue;
            lblCostStatus.Text = Str(cur["CostingStatus"]);
            lblCostVer.Text = "Ver " + Convert.ToInt32(cur["VersionNo"]).ToString("00") + " (" + DateStr(cur["CostingDate"]) + ")";
            lblTotalCost.Text = cur["TotalCost"] == DBNull.Value ? "-" : cc + " " + Convert.ToDecimal(cur["TotalCost"]).ToString("0.00");
            lblFob.Text = cur["FOBPrice"] == DBNull.Value ? "-" : cc + " " + Convert.ToDecimal(cur["FOBPrice"]).ToString("0.00");
            lblProfit.Text = cur["ProfitMarginPercent"] == DBNull.Value ? "-" : Convert.ToDecimal(cur["ProfitMarginPercent"]).ToString("0.00") + "%";
            SetBadge(bdgCosting, Str(cur["CostingStatus"]) == "Approved" ? "Completed" : Str(cur["CostingStatus"]), Str(cur["CostingStatus"]) == "Approved" ? "bg-primary" : "bg-warning text-dark");
        }

        protected void btnCreateCosting_Click(object sender, EventArgs e)
        {
            int id = StyleId;
            if (id == 0) { ShowMessage("Please save the style first."); return; }
            if (Dec(txtCostTotal.Text) <= 0) { ShowMessage("Please enter Total Cost."); return; }

            try
            {
                using (ConScope cs = new ConScope(conn.openConnection()))
                {
                    SqlConnection cn = cs.Con;
                    SqlTransaction tx = cn.BeginTransaction();
                    try
                    {
                        if (Convert.ToBoolean(ScalarTx(cn, tx, "SELECT IsLocked FROM " + MasterTbl + " WHERE StyleID=@id", P("@id", id))))
                            throw new ApplicationException("This style is Active (Locked).");

                        int ver = Convert.ToInt32(ScalarTx(cn, tx, "SELECT ISNULL(MAX(VersionNo),0)+1 FROM techdefendersbd.tbl_Mer_StyleCosting WHERE StyleID=@id", P("@id", id)));
                        ExecTx(cn, tx, "UPDATE techdefendersbd.tbl_Mer_StyleCosting SET IsCurrent=0 WHERE StyleID=@id", P("@id", id));
                        ExecTx(cn, tx, @"INSERT INTO techdefendersbd.tbl_Mer_StyleCosting (StyleID, VersionNo, CostingStatus, TotalCost, FOBPrice, CostingDate, IsCurrent)
                                         VALUES (@id, @v, @st, @tc, @fob, CAST(GETDATE() AS DATE), 1)",
                            P("@id", id), P("@v", ver), P("@st", ddlCostStatus.SelectedValue), P("@tc", Dec(txtCostTotal.Text)), P("@fob", Dec(txtCostFob.Text)));
                        AddHistory(cn, tx, id, "Costing", "VersionNo", null, ver.ToString("00"), "Costing created, Total " + Dec(txtCostTotal.Text).ToString("0.00") + " / FOB " + Dec(txtCostFob.Text).ToString("0.00"));
                        tx.Commit();
                    }
                    catch { try { tx.Rollback(); } catch { } throw; }
                }
                txtCostTotal.Text = ""; txtCostFob.Text = "";
                LoadCosting(id);
                LoadHistory(id);
            }
            catch (Exception ex) { ShowMessage(ex.Message); }
        }

        // ================================================================
        //  APPROVAL WORKFLOW
        // ================================================================
        private string CurrentStep(SqlConnection cn, SqlTransaction tx, int id)
        {
            object o = ScalarTx(cn, tx, "SELECT TOP 1 WorkflowStep FROM techdefendersbd.tbl_Mer_StyleApproval WHERE StyleID=@id ORDER BY ApprovalID DESC", P("@id", id));
            return (o == null || o == DBNull.Value) ? "Draft" : o.ToString();
        }

        private void BuildWorkflow(string current)
        {
            int ci = Array.IndexOf(WorkflowSteps, current);
            if (ci < 0) ci = 0;
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < WorkflowSteps.Length; i++)
            {
                string cls = i < ci ? "done" : (i == ci ? "active" : "");
                string label = WorkflowSteps[i] == "Active" ? "Active (Locked)" : WorkflowSteps[i];
                sb.Append("<div class=\"col\"><div class=\"workflow-step " + cls + "\">" + Server.HtmlEncode(label) + "</div></div>");
            }
            ltWorkflow.Text = sb.ToString();
        }

        private void LoadApproval(int id)
        {
            DataTable all = GetTable("SELECT ApprovalID, WorkflowStep, ActionTaken, ActionBy, ActionDate, Remarks FROM techdefendersbd.tbl_Mer_StyleApproval WHERE StyleID=@id ORDER BY ApprovalID DESC", P("@id", id));
            gvApproval.DataSource = all;
            gvApproval.DataBind();

            string step = all.Rows.Count > 0 ? Str(all.Rows[0]["WorkflowStep"]) : "Draft";
            BuildWorkflow(step);

            txtSubmittedBy.Text = "Not submitted";
            txtApprovedBy.Text = step == "Draft" ? "Not submitted" : "Pending";
            foreach (DataRow r in all.Rows)
            {
                if (Str(r["ActionTaken"]) == "Submitted") { txtSubmittedBy.Text = Str(r["ActionBy"]) + " (" + Convert.ToDateTime(r["ActionDate"]).ToString("yyyy-MM-dd") + ")"; break; }
            }
            bool approved = false;
            foreach (DataRow r in all.Rows)
            {
                if (Str(r["ActionTaken"]) == "Approved") { txtApprovedBy.Text = Str(r["ActionBy"]) + " (" + Convert.ToDateTime(r["ActionDate"]).ToString("yyyy-MM-dd") + ")"; approved = true; break; }
            }
            if (!approved && step != "Draft")
            {
                int idx = Array.IndexOf(WorkflowSteps, step);
                txtApprovedBy.Text = idx >= 0 && idx < WorkflowSteps.Length - 1 ? "Pending " + WorkflowSteps[idx + 1] : "Pending";
            }
        }

        protected void btnSubmit_Click(object sender, EventArgs e) { DoApproval("Submit"); }
        protected void btnApprove_Click(object sender, EventArgs e) { DoApproval("Approve"); }
        protected void btnReject_Click(object sender, EventArgs e) { DoApproval("Reject"); }
        protected void btnForward_Click(object sender, EventArgs e) { DoApproval("Forward"); }

        private void DoApproval(string action)
        {
            int id = StyleId;
            if (id == 0) { ShowMessage("Please save the style first."); return; }

            try
            {
                using (ConScope cs = new ConScope(conn.openConnection()))
                {
                    SqlConnection cn = cs.Con;
                    SqlTransaction tx = cn.BeginTransaction();
                    try
                    {
                        DataTable cur = GetTableTx(cn, tx, "SELECT StyleStatus, IsLocked FROM " + MasterTbl + " WHERE StyleID=@id", P("@id", id));
                        if (cur.Rows.Count == 0) throw new ApplicationException("Style not found.");
                        if (Convert.ToBoolean(cur.Rows[0]["IsLocked"])) throw new ApplicationException("This style is already Active (Locked).");

                        string oldStatus = Str(cur.Rows[0]["StyleStatus"]);
                        string step = CurrentStep(cn, tx, id);
                        string newStep = step, status = oldStatus, act = action;
                        bool lockIt = false;

                        switch (action)
                        {
                            case "Submit":
                                if (step != "Draft") throw new ApplicationException("Style is already submitted.");
                                newStep = "Submitted"; status = "Submitted"; act = "Submitted";
                                break;
                            case "Approve":
                                if (step == "Draft") throw new ApplicationException("Please submit the style first.");
                                if (step == "Submitted") { newStep = "Merchandising Approval"; status = "Submitted"; }
                                else if (step == "Merchandising Approval") { newStep = "Management Approval"; status = "Approved"; }
                                else if (step == "Management Approval") { newStep = "Active"; status = "Active"; lockIt = true; }
                                else throw new ApplicationException("Nothing to approve.");
                                act = "Approved";
                                break;
                            case "Reject":
                                if (step == "Draft") throw new ApplicationException("Style is not submitted yet.");
                                newStep = "Draft"; status = "Rejected"; act = "Rejected";
                                break;
                            case "Forward":
                                if (step == "Draft") throw new ApplicationException("Please submit the style first.");
                                act = "Forwarded";
                                break;
                        }

                        ExecTx(cn, tx, @"INSERT INTO techdefendersbd.tbl_Mer_StyleApproval (StyleID, WorkflowStep, ActionTaken, ActionBy, ActionDate, Remarks)
                                         VALUES (@id, @st, @a, @u, GETDATE(), @r)",
                            P("@id", id), P("@st", newStep), P("@a", act), P("@u", CurrentUser), P("@r", N(txtApprovalRemarks.Text)));

                        if (status != oldStatus || lockIt)
                        {
                            ExecTx(cn, tx, "UPDATE " + MasterTbl + " SET StyleStatus=@s, IsLocked=@l, ModifiedBy=@u, ModifiedDate=GETDATE() WHERE StyleID=@id",
                                P("@s", status), P("@l", lockIt), P("@u", CurrentUser), P("@id", id));
                            AddHistory(cn, tx, id, "Status Changed", "StyleStatus", oldStatus, status, act + " - " + newStep);
                        }
                        else
                        {
                            AddHistory(cn, tx, id, act, "WorkflowStep", step, newStep, txtApprovalRemarks.Text);
                        }
                        tx.Commit();
                    }
                    catch { try { tx.Rollback(); } catch { } throw; }
                }

                txtApprovalRemarks.Text = "";
                LoadSummary(id);
                LoadApproval(id);
                LoadHistory(id);
            }
            catch (Exception ex) { ShowMessage(ex.Message); }
        }
    }
}