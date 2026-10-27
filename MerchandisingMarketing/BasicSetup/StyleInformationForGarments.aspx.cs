using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;
using System.Web.Script.Serialization;
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

        // Stored Procedure / Table Type এর Schema (SQL ফাইলের সঙ্গে একই হতে হবে)
        private const string Sch = "dbo.";

        private static readonly string[] WorkflowSteps = { "Draft", "Submitted", "Merchandising Approval", "Management Approval", "Active" };

        // ================================================================
        //  DROPDOWN OPTIONS  (Employee Entry এর মতো OptJson -> aspx এর JS)
        // ================================================================
        public sealed class Opt
        {
            public string v { get; set; }   // value (ID বা text)
            public string t { get; set; }   // দেখানোর text
            public string p { get; set; }   // parent value (Brand -> Buyer)
        }

        protected string OptJson = "{}";
        private readonly List<string> loadErrors = new List<string>();
        private Dictionary<string, List<Opt>> _opts;

        // প্রতি request এ একবার লোড হয়; Add Color/Size এর handler ও এটা ব্যবহার করে
        private Dictionary<string, List<Opt>> Opts
        {
            get { if (_opts == null) _opts = LoadOptions(); return _opts; }
        }

        protected override void OnPreRender(EventArgs e)
        {
            base.OnPreRender(e);
            JavaScriptSerializer js = new JavaScriptSerializer();
            js.MaxJsonLength = int.MaxValue;
            OptJson = js.Serialize(Opts);
            if (loadErrors.Count > 0) ShowMessage("Option load error: " + string.Join(" | ", loadErrors));
        }

        private static List<Opt> L(params string[] items)
        {
            return items.Select(s => new Opt { v = s, t = s }).ToList();
        }

        private static List<Opt> FromTable(DataTable dt, string valCol, string txtCol, string parentCol)
        {
            List<Opt> list = new List<Opt>();
            HashSet<string> seen = new HashSet<string>();
            foreach (DataRow r in dt.Rows)
            {
                string v = Str(r[valCol]).Trim();
                string t = Str(r[txtCol]).Trim();
                if (v == "" || t == "") continue;
                string p = parentCol == null ? null : Str(r[parentCol]).Trim();
                if (!seen.Add(v + "|" + p)) continue;
                list.Add(new Opt { v = v, t = t, p = p });
            }
            return list;
        }

        private Dictionary<string, List<Opt>> LoadOptions()
        {
            Dictionary<string, List<Opt>> o = new Dictionary<string, List<Opt>>();

            // ---- Static তালিকা (আগে aspx এর ListItem এ ছিল) ----
            List<Opt> status = L("Draft", "Submitted", "Approved", "Active", "Rejected");
            o["mainStatus"] = status;
            o["statusFilter"] = status;
            o["season"] = L("Autumn/Winter", "Spring/Summer");

            List<string> years = new List<string>();
            for (int y = DateTime.Now.Year - 1; y <= DateTime.Now.Year + 2; y++) years.Add(y.ToString());
            o["seasonYear"] = L(years.ToArray());

            o["productCategory"] = L("Knit Outerwear", "Woven Bottoms", "Activewear");
            o["productType"] = L("Hoodie & Sweatshirt", "T-Shirt & Polo", "Jacket");
            o["garmentType"] = L("Pullover", "Zip-Up");
            o["gender"] = L("Mens", "Womens", "Kids");
            o["currency"] = new List<Opt>
            {
                new Opt { v = "USD", t = "USD ($)" },
                new Opt { v = "EUR", t = "EUR (€)" },
                new Opt { v = "GBP", t = "GBP (£)" }
            };
            o["shipmentMode"] = L("Sea Freight (FCL)", "Air Freight", "Courier");
            o["knitWoven"] = L("Knit", "Woven");
            o["tnaTemplate"] = L("Standard 90 Days Winterwear Template", "Standard 60 Days Template", "Standard 120 Days Template");
            o["accType"] = L("Label", "Button", "Zipper", "Thread", "Packing", "Other");
            o["docType"] = L("Tech Pack", "Sample Approval", "Buyer Spec", "Other");
            o["costStatus"] = L("Draft", "Submitted", "Approved");

            // ---- DB তালিকা (একটি SP, ৯টি result set) ----
            foreach (string k in new[] { "buyer", "buyerFilter", "brand", "agent", "merchandiser", "country", "paymentTerm", "fabUnit", "accUnit", "color", "size" })
                o[k] = new List<Opt>();

            try
            {
                DataSet ds = GetDataSet("sp_Mer_Style_Lookups");

                List<Opt> buyers = FromTable(ds.Tables[0], "BuyerID", "BuyerName", null);
                o["buyer"] = buyers;
                o["buyerFilter"] = buyers;
                o["brand"] = FromTable(ds.Tables[1], "BrandID", "BrandName", "BuyerID");
                o["agent"] = FromTable(ds.Tables[2], "AgentID", "HouseName", null);
                o["merchandiser"] = FromTable(ds.Tables[3], "user_id", "full_name", null);
                o["country"] = FromTable(ds.Tables[4], "CountryName", "CountryName", null);
                o["paymentTerm"] = FromTable(ds.Tables[5], "TermName", "TermName", null);

                List<Opt> units = FromTable(ds.Tables[6], "U", "U", null);
                o["fabUnit"] = units;
                o["accUnit"] = units;

                o["color"] = FromTable(ds.Tables[7], "ColorCode", "ColorName", null);
                o["size"] = FromTable(ds.Tables[8], "SizeID", "Txt", null);
            }
            catch (Exception ex)
            {
                loadErrors.Add("options: " + ex.Message);
            }

            // Unit খালি থাকলে আগের ডিফল্ট
            if (o["fabUnit"].Count == 0) o["fabUnit"] = L("Kgs", "Yds", "Mtr");
            if (o["accUnit"].Count == 0) o["accUnit"] = L("Pcs", "Mtr", "Cone");

            return o;
        }

        private string First(string key)
        {
            List<Opt> l = Opts[key];
            return l.Count > 0 ? l[0].v : "";
        }

        // value থেকে দেখানোর text বের করে (Add Color/Size এ লাগে)
        private string OptText(string key, string value)
        {
            foreach (Opt x in Opts[key]) if (x.v == value) return x.t;
            return value;
        }

        private static string V(HiddenField hf) { return (hf.Value ?? "").Trim(); }

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
        }

        // DB থেকে আসা ডাটা ViewState এর typed টেবিলে ঢোকায় (TVP এর কলাম ক্রম/টাইপ ঠিক রাখতে)
        private static void Refill(DataTable target, DataTable src)
        {
            target.Rows.Clear();
            foreach (DataRow s in src.Rows)
            {
                DataRow n = target.NewRow();
                foreach (DataColumn c in target.Columns)
                {
                    object v = src.Columns.Contains(c.ColumnName) ? s[c.ColumnName] : DBNull.Value;
                    if (v == null || v == DBNull.Value)
                    {
                        if (c.DataType == typeof(decimal)) n[c] = 0m;
                        else if (c.DataType == typeof(bool)) n[c] = true;
                        else n[c] = DBNull.Value;
                    }
                    else n[c] = Convert.ChangeType(v, c.DataType, CultureInfo.InvariantCulture);
                }
                target.Rows.Add(n);
            }
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

                ShowList();
                LoadStyleList();
            }
        }

        // ================================================================
        //  GENERIC DB HELPERS  (সবই Stored Procedure)
        // ================================================================
        private static SqlParameter P(string name, object value)
        {
            return new SqlParameter(name, value ?? DBNull.Value);
        }

        private static SqlParameter Tvp(string name, string typeName, DataTable dt)
        {
            SqlParameter p = new SqlParameter(name, SqlDbType.Structured);
            p.TypeName = Sch + typeName;
            p.Value = dt;
            return p;
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

        private static bool Bool(object o)
        {
            return o != null && o != DBNull.Value && Convert.ToBoolean(o);
        }

        private static SqlCommand NewCmd(string sp, SqlConnection cn, SqlParameter[] ps)
        {
            SqlCommand cmd = new SqlCommand(Sch + sp, cn);
            cmd.CommandType = CommandType.StoredProcedure;
            if (ps != null && ps.Length > 0) cmd.Parameters.AddRange(ps);
            return cmd;
        }

        // একটি result set
        private DataTable GetTable(string sp, params SqlParameter[] ps)
        {
            DataTable dt = new DataTable();
            using (ConScope cs = new ConScope(conn.openConnection()))
            using (SqlCommand cmd = NewCmd(sp, cs.Con, ps))
            using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                da.Fill(dt);
            return dt;
        }

        // একাধিক result set  (Tables[0], Tables[1] ...)
        private DataSet GetDataSet(string sp, params SqlParameter[] ps)
        {
            DataSet ds = new DataSet();
            using (ConScope cs = new ConScope(conn.openConnection()))
            using (SqlCommand cmd = NewCmd(sp, cs.Con, ps))
            using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                da.Fill(ds);
            return ds;
        }

        private void Exec(string sp, params SqlParameter[] ps)
        {
            using (ConScope cs = new ConScope(conn.openConnection()))
            using (SqlCommand cmd = NewCmd(sp, cs.Con, ps))
                cmd.ExecuteNonQuery();
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

        // ================================================================
        //  PANEL SWITCH + LIST
        // ================================================================
        private void ShowList() { pnlList.Visible = true; pnlEntry.Visible = false; }
        private void ShowEntry() { pnlList.Visible = false; pnlEntry.Visible = true; }

        private void LoadStyleList()
        {
            try
            {
                int buyer; int.TryParse(V(hfBuyerFilter), out buyer);
                DataTable dt = GetTable("sp_Mer_Style_GetList",
                    P("@BuyerID", buyer), P("@Status", V(hfStatusFilter)), P("@Search", txtSearch.Text.Trim()));
                gvStyles.DataSource = dt;
                gvStyles.DataBind();
            }
            catch (Exception ex) { ShowMessage(ex.Message); }
        }

        protected void btnSearch_Click(object sender, EventArgs e) { LoadStyleList(); }

        protected void btnClearFilter_Click(object sender, EventArgs e)
        {
            hfBuyerFilter.Value = "";
            hfStatusFilter.Value = "";
            txtSearch.Text = "";
            LoadStyleList();
        }

        protected void btnAddNew_Click(object sender, EventArgs e)
        {
            ClearForm();
            hfTab.Value = "";
            ShowEntry();
        }

        protected void gvStyles_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int id;
            if (!int.TryParse(Convert.ToString(e.CommandArgument), out id)) return;

            if (e.CommandName == "EditRow") { hfTab.Value = ""; LoadStyle(id); }
            else if (e.CommandName == "DeleteRow") DeleteStyle(id);
        }

        private void DeleteStyle(int id)
        {
            try
            {
                Exec("sp_Mer_Style_Delete", P("@StyleID", id));   // child table গুলো ON DELETE CASCADE
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
        //  CLEAR FORM  (আগে comment করা ছিল - এখন HiddenField দিয়ে চালু)
        // ================================================================
        private void ClearForm()
        {
            hfStyleId.Value = "0";

            txtStyleID.Text = PreviewStyleCode();
            txtStyleNo.Text = ""; txtStyleName.Text = ""; txtStyleDesc.Text = "";
            hfMainStatus.Value = "Draft";
            txtRevNo.Text = "00";
            hfLocked.Value = "0";

            hfBuyer.Value = ""; hfBrand.Value = ""; hfAgent.Value = ""; hfMerchandiser.Value = "";
            hfSeason.Value = First("season");
            hfSeasonYear.Value = DateTime.Now.Year.ToString();
            hfProductCategory.Value = First("productCategory");
            hfProductType.Value = First("productType");
            hfGarmentType.Value = First("garmentType");
            hfGender.Value = First("gender");
            txtDepartment.Text = ""; txtDivision.Text = "";
            txtCreationDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            txtRemarks.Text = "";

            txtBuyerStyleNo.Text = ""; txtProductNo.Text = "";
            hfCountry.Value = "";
            hfCurrency.Value = First("currency");
            hfPaymentTerm.Value = "";
            hfShipmentMode.Value = First("shipmentMode");
            txtPortLoading.Text = ""; txtPortDischarge.Text = "";

            txtFabricType.Text = ""; hfKnitWoven.Value = First("knitWoven"); txtConstruction.Text = ""; txtSpecGsm.Text = "";
            txtSpecComposition.Text = ""; txtFabricWidth.Text = ""; txtFinish.Text = ""; txtWashType.Text = "";
            txtSleeve.Text = ""; txtNeck.Text = ""; txtClosure.Text = ""; txtPocket.Text = "";

            chkPrinting.Checked = chkEmbroidery.Checked = chkWashing.Checked = chkSpecial.Checked = false;
            txtPrintingDetails.Text = txtEmbroideryDetails.Text = txtWashingDetails.Text = txtSpecialDetails.Text = "";

            hfTnaTemplate.Value = First("tnaTemplate");
            txtSampleDeadline.Text = txtPPMeeting.Text = txtFabricIn.Text = txtShipmentDate.Text = "";

            hfColor.Value = ""; hfSize.Value = "";
            hfFabUnit.Value = First("fabUnit"); hfAccUnit.Value = First("accUnit");
            hfAccType.Value = First("accType"); hfDocType.Value = First("docType"); hfCostStatus.Value = First("costStatus");
            txtPantone.Text = "";
            txtFabCode.Text = txtFabName.Text = txtFabComp.Text = txtFabGsm.Text = txtFabColor.Text = txtFabCons.Text = txtFabWaste.Text = "";
            txtAccCode.Text = txtAccName.Text = txtAccSizeColor.Text = txtAccCons.Text = txtAccWaste.Text = txtAccSupplier.Text = "";

            ViewState["dtColors"] = null; ViewState["dtSizes"] = null; ViewState["dtFabric"] = null; ViewState["dtAcc"] = null;
            BindChildGrids();

            ResetImages();
            gvDocs.DataSource = null; gvDocs.DataBind();
            gvCosting.DataSource = null; gvCosting.DataBind();
            gvApproval.DataSource = null; gvApproval.DataBind();
            gvHistory.DataSource = null; gvHistory.DataBind();
            ClearCostingLabels();
            txtCostTotal.Text = ""; txtCostFob.Text = "";
            txtApprovalRemarks.Text = "";
            BuildWorkflow("Draft");
            txtSubmittedBy.Text = "Not submitted"; txtApprovedBy.Text = "Not submitted";
            txtDocVersion.Text = "";

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
        //  STYLE CODE  (ST-2026-0001)  - শুধু Preview; আসল কোড Save SP তৈরি করে
        // ================================================================
        private string PreviewStyleCode()
        {
            try
            {
                SqlParameter o = new SqlParameter("@Code", SqlDbType.NVarChar, 30);
                o.Direction = ParameterDirection.Output;
                Exec("sp_Mer_Style_GenCode", o);
                return Convert.ToString(o.Value);
            }
            catch { return "(Auto)"; }
        }

        // ================================================================
        //  LOAD STYLE (Edit)
        // ================================================================
        private void LoadStyle(int id)
        {
            try
            {
                DataSet d = GetDataSet("sp_Mer_Style_GetDetails", P("@StyleID", id));
                if (d.Tables[0].Rows.Count == 0) { ShowMessage("Style not found!"); return; }
                DataRow r = d.Tables[0].Rows[0];

                ClearForm();
                StyleId = id;

                txtStyleID.Text = Str(r["StyleCode"]);
                txtStyleNo.Text = Str(r["StyleNo"]);
                txtStyleName.Text = Str(r["StyleName"]);
                txtStyleDesc.Text = Str(r["StyleDescription"]);

                int buyerId; int.TryParse(Str(r["BuyerID"]), out buyerId);
                hfBuyer.Value = Str(r["BuyerID"]);
                hfBrand.Value = Str(r["BrandID"]);
                hfAgent.Value = Str(r["AgentID"]);
                hfMerchandiser.Value = Str(r["MerchandiserID"]);
                hfSeason.Value = Str(r["SeasonName"]);
                hfSeasonYear.Value = Str(r["SeasonYear"]);
                hfProductCategory.Value = Str(r["ProductCategory"]);
                hfProductType.Value = Str(r["ProductType"]);
                hfGarmentType.Value = Str(r["GarmentType"]);
                hfGender.Value = Str(r["Gender"]);
                txtDepartment.Text = Str(r["Department"]);
                txtDivision.Text = Str(r["Division"]);
                txtCreationDate.Text = DateStr(r["CreationDate"]);
                txtRemarks.Text = Str(r["InternalRemarks"]);

                // Commercial
                DataTable t = d.Tables[1];
                if (t.Rows.Count > 0)
                {
                    DataRow c = t.Rows[0];
                    txtBuyerStyleNo.Text = Str(c["BuyerStyleNo"]); txtProductNo.Text = Str(c["ProductNo"]);
                    hfCountry.Value = Str(c["DestinationCountry"]);
                    hfCurrency.Value = Str(c["Currency"]);
                    hfPaymentTerm.Value = Str(c["PaymentTerm"]);
                    hfShipmentMode.Value = Str(c["ShipmentMode"]);
                    txtPortLoading.Text = Str(c["PortOfLoading"]); txtPortDischarge.Text = Str(c["PortOfDischarge"]);
                }

                // Specification
                t = d.Tables[2];
                if (t.Rows.Count > 0)
                {
                    DataRow s = t.Rows[0];
                    txtFabricType.Text = Str(s["FabricType"]); hfKnitWoven.Value = Str(s["KnitWoven"]);
                    txtConstruction.Text = Str(s["Construction"]); txtSpecGsm.Text = Str(s["GSM"]);
                    txtSpecComposition.Text = Str(s["Composition"]); txtFabricWidth.Text = Str(s["FabricWidth"]);
                    txtFinish.Text = Str(s["Finish"]); txtWashType.Text = Str(s["WashType"]);
                    txtSleeve.Text = Str(s["SleeveType"]); txtNeck.Text = Str(s["NeckType"]);
                    txtClosure.Text = Str(s["ClosureType"]); txtPocket.Text = Str(s["PocketType"]);
                }

                // Work Order flags
                t = d.Tables[3];
                if (t.Rows.Count > 0)
                {
                    DataRow w = t.Rows[0];
                    chkPrinting.Checked = Bool(w["PrintingRequired"]); txtPrintingDetails.Text = Str(w["PrintingDetails"]);
                    chkEmbroidery.Checked = Bool(w["EmbroideryRequired"]); txtEmbroideryDetails.Text = Str(w["EmbroideryDetails"]);
                    chkWashing.Checked = Bool(w["WashingRequired"]); txtWashingDetails.Text = Str(w["WashingDetails"]);
                    chkSpecial.Checked = Bool(w["SpecialProcessRequired"]); txtSpecialDetails.Text = Str(w["SpecialProcessDetails"]);
                }

                // TNA
                t = d.Tables[4];
                bool hasTna = t.Rows.Count > 0;
                if (hasTna)
                {
                    DataRow n = t.Rows[0];
                    hfTnaTemplate.Value = Str(n["TemplateName"]);
                    txtSampleDeadline.Text = DateStr(n["SampleDeadline"]); txtPPMeeting.Text = DateStr(n["PPMeetingDate"]);
                    txtFabricIn.Text = DateStr(n["FabricInDate"]); txtShipmentDate.Text = DateStr(n["ShipmentDate"]);
                }

                // Color / Size / Fabric / Accessories
                DataSet ch = GetDataSet("sp_Mer_Style_GetChildren", P("@StyleID", id));
                Refill(ColorsDT, ch.Tables[0]);
                Refill(SizesDT, ch.Tables[1]);
                Refill(FabricDT, ch.Tables[2]);
                Refill(AccDT, ch.Tables[3]);
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
            DataTable m = GetTable("sp_Mer_Style_GetSummary", P("@StyleID", id));
            if (m.Rows.Count == 0) return;
            DataRow r = m.Rows[0];
            hfMainStatus.Value = Str(r["StyleStatus"]);
            txtRevNo.Text = Convert.ToInt32(r["RevisionNo"]).ToString("00");
            bool locked = Bool(r["IsLocked"]);

            lblCreatedBy.Text = Str(r["CreatedBy"]);
            lblCreatedDate.Text = DateStr(r["CreatedDate"]);
            lblModified.Text = r["ModifiedDate"] == DBNull.Value ? "-" : Convert.ToDateTime(r["ModifiedDate"]).ToString("yyyy-MM-dd HH:mm") + " (" + Str(r["ModifiedBy"]) + ")";
            lblLock.Text = locked ? "Locked (Active)" : "Unlocked for Editing";
            hfLocked.Value = locked ? "1" : "0";     // JS এ Status ড্রপডাউন বন্ধ করে
            UpdateButtons(locked);
        }

        private void LoadSidebar(int id, int buyerId, bool hasTna)
        {
            try
            {
                DataTable po = GetTable("sp_Mer_Style_POCount",
                    P("@BuyerID", buyerId), P("@StyleNo", txtStyleNo.Text.Trim()), P("@StyleName", txtStyleName.Text.Trim()));
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
            if (string.IsNullOrEmpty(V(hfBuyer))) { ShowMessage("Please select a Buyer!"); return; }
            if (string.IsNullOrEmpty(V(hfMerchandiser))) { ShowMessage("Please select Assigned Merchandiser!"); return; }

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

        private int SaveStyle()
        {
            string status = V(hfMainStatus);
            if (status == "") status = "Draft";

            SqlParameter outId = new SqlParameter("@OutStyleID", SqlDbType.Int);
            outId.Direction = ParameterDirection.Output;

            List<SqlParameter> ps = new List<SqlParameter>
            {
                P("@StyleID", StyleId),

                // Master
                P("@StyleNo", txtStyleNo.Text.Trim()),
                P("@StyleName", txtStyleName.Text.Trim()),
                P("@StyleDescription", N(txtStyleDesc.Text)),
                P("@BuyerID", NI(V(hfBuyer))),
                P("@BrandID", NI(V(hfBrand))),
                P("@AgentID", NI(V(hfAgent))),
                P("@SeasonName", N(V(hfSeason))),
                P("@SeasonYear", NI(V(hfSeasonYear))),
                P("@ProductCategory", N(V(hfProductCategory))),
                P("@ProductType", N(V(hfProductType))),
                P("@GarmentType", N(V(hfGarmentType))),
                P("@Gender", N(V(hfGender))),
                P("@Department", N(txtDepartment.Text)),
                P("@Division", N(txtDivision.Text)),
                P("@MerchandiserID", NI(V(hfMerchandiser))),
                P("@CreationDate", ParseDate(txtCreationDate.Text)),
                P("@InternalRemarks", N(txtRemarks.Text)),
                P("@StyleStatus", status),
                P("@IsLocked", status == "Active"),

                // Commercial
                P("@BuyerStyleNo", N(txtBuyerStyleNo.Text)),
                P("@ProductNo", N(txtProductNo.Text)),
                P("@DestinationCountry", N(V(hfCountry))),
                P("@Currency", N(V(hfCurrency))),
                P("@PaymentTerm", N(V(hfPaymentTerm))),
                P("@ShipmentMode", N(V(hfShipmentMode))),
                P("@PortOfLoading", N(txtPortLoading.Text)),
                P("@PortOfDischarge", N(txtPortDischarge.Text)),

                // Specification
                P("@FabricType", N(txtFabricType.Text)),
                P("@KnitWoven", N(V(hfKnitWoven))),
                P("@Construction", N(txtConstruction.Text)),
                P("@GSM", N(txtSpecGsm.Text)),
                P("@Composition", N(txtSpecComposition.Text)),
                P("@FabricWidth", N(txtFabricWidth.Text)),
                P("@Finish", N(txtFinish.Text)),
                P("@WashType", N(txtWashType.Text)),
                P("@SleeveType", N(txtSleeve.Text)),
                P("@NeckType", N(txtNeck.Text)),
                P("@ClosureType", N(txtClosure.Text)),
                P("@PocketType", N(txtPocket.Text)),

                // Work Order
                P("@PrintingRequired", chkPrinting.Checked),
                P("@PrintingDetails", N(txtPrintingDetails.Text)),
                P("@EmbroideryRequired", chkEmbroidery.Checked),
                P("@EmbroideryDetails", N(txtEmbroideryDetails.Text)),
                P("@WashingRequired", chkWashing.Checked),
                P("@WashingDetails", N(txtWashingDetails.Text)),
                P("@SpecialRequired", chkSpecial.Checked),
                P("@SpecialDetails", N(txtSpecialDetails.Text)),

                // TNA
                P("@TemplateName", N(V(hfTnaTemplate))),
                P("@SampleDeadline", ParseDate(txtSampleDeadline.Text)),
                P("@PPMeetingDate", ParseDate(txtPPMeeting.Text)),
                P("@FabricInDate", ParseDate(txtFabricIn.Text)),
                P("@ShipmentDate", ParseDate(txtShipmentDate.Text)),

                // Grids (Table-Valued Parameter)
                Tvp("@Colors", "tt_Mer_StyleColor", ColorsDT),
                Tvp("@Sizes", "tt_Mer_StyleSize", SizesDT),
                Tvp("@Fabric", "tt_Mer_StyleFabric", FabricDT),
                Tvp("@Acc", "tt_Mer_StyleAccessory", AccDT),

                P("@User", CurrentUser),
                outId
            };

            Exec("sp_Mer_Style_Save", ps.ToArray());
            return Convert.ToInt32(outId.Value);
        }

        private void LoadHistory(int id)
        {
            gvHistory.DataSource = GetTable("sp_Mer_Style_History_List", P("@StyleID", id));
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
            hfTab.Value = "";
            ShowList();
            LoadStyleList();
        }

        protected void btnCopyStyle_Click(object sender, EventArgs e)
        {
            int src = StyleId;
            if (src == 0) { ShowMessage("Please save the style first."); return; }
            try
            {
                SqlParameter outId = new SqlParameter("@NewStyleID", SqlDbType.Int);
                outId.Direction = ParameterDirection.Output;
                Exec("sp_Mer_Style_Copy", P("@SourceStyleID", src), P("@User", CurrentUser), outId);

                LoadStyle(Convert.ToInt32(outId.Value));
                ShowMessage("Style copied. Please change Style No / Name and Save.");
            }
            catch (Exception ex) { ShowMessage(ex.Message); }
        }

        // ================================================================
        //  COLOR / SIZE / FABRIC / ACCESSORIES  (grid add / delete)
        // ================================================================
        protected void btnAddColor_Click(object sender, EventArgs e)
        {
            string code = V(hfColor);
            if (string.IsNullOrEmpty(code)) { ShowMessage("Please select a color!"); return; }
            foreach (DataRow r in ColorsDT.Rows)
                if (Str(r["ColorCode"]) == code) { ShowMessage("This color is already added."); return; }

            ColorsDT.Rows.Add(code, OptText("color", code), txtPantone.Text.Trim(), true);
            txtPantone.Text = "";
            hfColor.Value = "";
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
            if (!int.TryParse(V(hfSize), out sid) || sid <= 0) { ShowMessage("Please select a size!"); return; }
            string code = "S" + sid.ToString("00");
            foreach (DataRow r in SizesDT.Rows)
                if (Str(r["SizeCode"]) == code) { ShowMessage("This size is already added."); return; }

            DataTable s = GetTable("sp_Mer_Style_GetSizeInfo", P("@SizeID", sid));
            if (s.Rows.Count == 0) return;
            SizesDT.Rows.Add(code, Str(s.Rows[0]["SizeName"]), Str(s.Rows[0]["GroupName"]), true);
            hfSize.Value = "";
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
                              Dec(txtFabCons.Text), Dec(txtFabWaste.Text), V(hfFabUnit));
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
            AccDT.Rows.Add(txtAccCode.Text.Trim(), txtAccName.Text.Trim(), V(hfAccType), txtAccSizeColor.Text.Trim(),
                           Dec(txtAccCons.Text), V(hfAccUnit), Dec(txtAccWaste.Text), txtAccSupplier.Text.Trim());
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
            DataTable dt = GetTable("sp_Mer_Style_Image_List", P("@StyleID", id));
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

            // SP পুরোনো FilePath গুলো ফেরত দেয়, তারপর নতুনটা বসায়
            DataTable old = GetTable("sp_Mer_Style_Image_Save",
                P("@StyleID", id), P("@ImageType", type), P("@FilePath", virtualDir + "/" + saved),
                P("@FileName", Path.GetFileName(fu.FileName)), P("@User", CurrentUser));

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
                DataTable old = GetTable("sp_Mer_Style_Image_Delete", P("@StyleID", id), P("@ImageType", type));
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
            gvDocs.DataSource = GetTable("sp_Mer_Style_Doc_List", P("@StyleID", id));
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

                Exec("sp_Mer_Style_Doc_Save",
                    P("@StyleID", id), P("@DocumentName", Path.GetFileName(fuDoc.FileName)), P("@DocumentType", V(hfDocType)),
                    P("@FilePath", virtualDir + "/" + saved), P("@VersionNo", N(txtDocVersion.Text)), P("@User", CurrentUser));

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
                DataTable old = GetTable("sp_Mer_Style_Doc_Delete", P("@DocumentID", docId), P("@StyleID", StyleId));
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
            DataTable all = GetTable("sp_Mer_Style_Costing_List", P("@StyleID", id));
            gvCosting.DataSource = all;
            gvCosting.DataBind();

            ClearCostingLabels();
            DataRow cur = null;
            foreach (DataRow r in all.Rows) if (Bool(r["IsCurrent"])) { cur = r; break; }
            if (cur == null && all.Rows.Count > 0) cur = all.Rows[0];
            if (cur == null) { SetBadge(bdgCosting, "Pending", "bg-secondary"); return; }

            string cc = V(hfCurrency);
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
                string cs = V(hfCostStatus);
                if (cs == "") cs = "Draft";
                Exec("sp_Mer_Style_Costing_Create",
                    P("@StyleID", id), P("@CostingStatus", cs),
                    P("@TotalCost", Dec(txtCostTotal.Text)), P("@FOBPrice", Dec(txtCostFob.Text)), P("@User", CurrentUser));

                txtCostTotal.Text = ""; txtCostFob.Text = "";
                LoadCosting(id);
                LoadHistory(id);
            }
            catch (Exception ex) { ShowMessage(ex.Message); }
        }

        // ================================================================
        //  APPROVAL WORKFLOW
        // ================================================================
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
            DataTable all = GetTable("sp_Mer_Style_Approval_List", P("@StyleID", id));
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
                // সব শর্ত (Draft/Locked/Step) SP নিজেই যাচাই করে, ভুল হলে error message ফেরত দেয়
                Exec("sp_Mer_Style_Approval_Action",
                    P("@StyleID", id), P("@Action", action), P("@Remarks", N(txtApprovalRemarks.Text)), P("@User", CurrentUser));

                txtApprovalRemarks.Text = "";
                LoadSummary(id);
                LoadApproval(id);
                LoadHistory(id);
            }
            catch (Exception ex) { ShowMessage(ex.Message); }
        }
    }
}
