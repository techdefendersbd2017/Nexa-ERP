using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.MasterConfiguration.BuyerManagement
{
    public partial class StyleInformationForGarments : System.Web.UI.Page
    {
        SqlConnection con;
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();
        SqlCommand cmd;

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
        // PAGE LOAD
        // ============================================================
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                lblUser.Text = CurrentUserName;
                txtStyleID.Text = "0";
                txtRevNo.Text = "00";
                txtCreationDate.Text = DateTime.Today.ToString("yyyy-MM-dd");

                pnlList.Visible = true;
                pnlEntry.Visible = false;

                hfStyleId.Value = "0";
                hfSetId.Value = "0";
                hfActiveTab.Value = "basic-tab";
                LoadStyleList();
            }
        }

        // ============================================================
        // COMMON HELPERS
        // ============================================================
        private void ShowAlert(string msg)
        {
            string safe = msg.Replace("'", "").Replace("\r", "").Replace("\n", " ");
            ScriptManager.RegisterStartupScript(this, this.GetType(),
                Guid.NewGuid().ToString("N"),
                "alert('" + safe + "');", true);
        }
        private void PreserveTab(string tabId)
        {
            hfActiveTab.Value = tabId;
            ScriptManager.RegisterStartupScript(this, this.GetType(),
                "setTab_" + Guid.NewGuid().ToString("N"),
                @"(function(){
            if(!window.bootstrap || !bootstrap.Tab) return;
            var btn=document.querySelector('#styleTabs [data-bs-target=""#" + tabId + @"""]');
            if(btn) bootstrap.Tab.getOrCreateInstance(btn).show();
            var hf=document.getElementById('hfActiveTab');
            if(hf) hf.value='" + tabId + @"';
        })();",
                true);
        }

        private void ResetAllDropdowns()
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(),
                "resetDD_" + Guid.NewGuid().ToString("N"),
                "if(window.NexaDD){window.NexaDD.resetAll();}", true);
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

        // ============================================================
        // GRIDVIEW BOOLEAN HELPERS
        // (fixes "String was not recognized as a valid Boolean")
        // ============================================================
        protected string GetActiveCss(object value)
        {
            return IsActiveValue(value) ? "bg-success" : "bg-secondary";
        }

        protected string GetActiveText(object value)
        {
            return IsActiveValue(value) ? "Yes" : "No";
        }

        private bool IsActiveValue(object value)
        {
            if (value == null || value == DBNull.Value) return false;

            if (value is bool) return (bool)value;
            if (value is int) return (int)value == 1;

            string s = value.ToString().Trim();
            if (s.Length == 0) return false;
            if (s.Equals("1") || s.Equals("true", StringComparison.OrdinalIgnoreCase)
                || s.Equals("yes", StringComparison.OrdinalIgnoreCase)) return true;

            return false;
        }

        // ============================================================
        // LIST LOAD & SEARCH
        // ============================================================
        private void LoadStyleList()
        {
            try
            {
                con = conn.openConnection();
                string query = @"
                    SELECT  s.StyleID,
                            s.StyleNo AS StyleCode,
                            s.StyleNo,
                            s.StyleName,
                            ISNULL(b.BuyerName,'') AS BuyerName,
                            ISNULL(sn.SeasonName,'') AS Season,
                            CASE s.StyleStatus
                                 WHEN 'D' THEN 'Draft'
                                 WHEN 'A' THEN 'Active'
                                 WHEN 'I' THEN 'Inactive'
                                 WHEN 'C' THEN 'Closed'
                                 ELSE s.StyleStatus END AS StyleStatus,
                            s.RevisionNo
                    FROM    dbo.StyleMaster s
                    LEFT JOIN dbo.Buyer  b  ON b.BuyerID  = s.BuyerID
                    LEFT JOIN dbo.Season sn ON sn.SeasonID = s.SeasonID
                    WHERE   s.IsActive = 1";

                if (!string.IsNullOrEmpty(hfBuyerFilter.Value))
                    query += " AND s.BuyerID = @BuyerID";

                if (!string.IsNullOrEmpty(hfStatusFilter.Value))
                    query += " AND s.StyleStatus = @Status";

                if (!string.IsNullOrEmpty(txtSearch.Text.Trim()))
                    query += " AND (s.StyleNo LIKE @Q OR s.StyleName LIKE @Q)";

                query += " ORDER BY s.StyleID DESC";

                using (SqlCommand c = new SqlCommand(query, con))
                {
                    if (!string.IsNullOrEmpty(hfBuyerFilter.Value))
                        c.Parameters.AddWithValue("@BuyerID", Convert.ToInt32(hfBuyerFilter.Value));
                    if (!string.IsNullOrEmpty(hfStatusFilter.Value))
                        c.Parameters.AddWithValue("@Status", hfStatusFilter.Value);
                    if (!string.IsNullOrEmpty(txtSearch.Text.Trim()))
                        c.Parameters.AddWithValue("@Q", "%" + txtSearch.Text.Trim() + "%");

                    SqlDataAdapter da = new SqlDataAdapter(c);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    gvStyles.DataSource = dt;
                    gvStyles.DataBind();
                }
                CloseConnection();
            }
            catch (Exception ex)
            {
                CloseConnection();
                ShowAlert("List load error: " + ex.Message);
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e) { LoadStyleList(); }

        protected void btnClearFilter_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            hfBuyerFilter.Value = "";
            hfStatusFilter.Value = "";
            ResetAllDropdowns();
            LoadStyleList();
        }

        // ============================================================
        // ADD NEW / RESET / CLOSE / COPY
        // ============================================================
        protected void btnAddNew_Click(object sender, EventArgs e)
        {
            ClearForm();
            ResetAllDropdowns();
            pnlList.Visible = false;
            pnlEntry.Visible = true;
            btnSave.Visible = true;
            btnUpdate.Visible = false;
            txtStyleID.Text = "0";
            txtRevNo.Text = "00";
            ViewState["StyleID"] = null;
            ShowAlert("New Style Entry Form Opened.");
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            ClearForm();
            ResetAllDropdowns();
            ShowAlert("Form reset completed.");
        }

        protected void btnClose_Click(object sender, EventArgs e)
        {
            pnlEntry.Visible = false;
            pnlList.Visible = true;
            LoadStyleList();
        }

        protected void btnCopyStyle_Click(object sender, EventArgs e)
        {
            if (ViewState["StyleID"] == null)
            {
                ShowAlert("Please select a style first.");
                return;
            }
            int srcId = Convert.ToInt32(ViewState["StyleID"]);
            LoadStyleById(srcId);
            ViewState["StyleID"] = null;
            txtStyleID.Text = "0";
            txtStyleNo.Text = txtStyleNo.Text + "-COPY";
            hfStyleId.Value = "0";
            pnlList.Visible = false;
            pnlEntry.Visible = true;
            btnSave.Visible = true;
            btnUpdate.Visible = false;
            ShowAlert("Style copied. Modify and Save as new.");
        }

        // ============================================================
        // SAVE (INSERT)
        // ============================================================
        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!ValidateForm()) return;

            try
            {
                con = conn.openConnection();
                using (SqlCommand c = new SqlCommand("sp_SaveUpdateStyleMaster", con))
                {
                    c.CommandType = CommandType.StoredProcedure;
                    c.Parameters.Add("@StyleID", SqlDbType.Int).Value = 0;
                    AddStyleParams(c);
                    c.Parameters.Add("@CreatedBy", SqlDbType.Int).Value = CurrentUserId;

                    SqlParameter outId = new SqlParameter("@NewStyleID", SqlDbType.Int);
                    outId.Direction = ParameterDirection.Output;
                    c.Parameters.Add(outId);

                    c.ExecuteNonQuery();

                    int newId = Convert.ToInt32(outId.Value);
                    ViewState["StyleID"] = newId;
                    hfStyleId.Value = newId.ToString();
                    txtStyleID.Text = newId.ToString();

                    SaveStyleColors(newId);
                    SaveStyleSizes(newId);
                    SaveStyleFabrics(newId);
                    SaveStyleAccessories(newId);

                    ShowAlert("Style saved successfully. ID = " + newId);
                    btnSave.Visible = false;
                    btnUpdate.Visible = true;
                }
                CloseConnection();
                LoadStyleList();
            }
            catch (Exception ex)
            {
                CloseConnection();
                ShowAlert("Save error: " + ex.Message);
            }
        }

        // ============================================================
        // UPDATE
        // ============================================================
        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            if (ViewState["StyleID"] == null)
            {
                ShowAlert("No style loaded for update.");
                return;
            }

            if (!ValidateForm()) return;

            try
            {
                int styleId = Convert.ToInt32(ViewState["StyleID"]);

                con = conn.openConnection();
                using (SqlCommand c = new SqlCommand("sp_SaveUpdateStyleMaster", con))
                {
                    c.CommandType = CommandType.StoredProcedure;
                    c.Parameters.Add("@StyleID", SqlDbType.Int).Value = styleId;
                    AddStyleParams(c);
                    c.Parameters.Add("@CreatedBy", SqlDbType.Int).Value = CurrentUserId;

                    SqlParameter outId = new SqlParameter("@NewStyleID", SqlDbType.Int);
                    outId.Direction = ParameterDirection.Output;
                    c.Parameters.Add(outId);

                    c.ExecuteNonQuery();
                }
                CloseConnection();

                SaveStyleColors(styleId);
                SaveStyleSizes(styleId);
                SaveStyleFabrics(styleId);
                SaveStyleAccessories(styleId);

                ShowAlert("Style updated successfully.");
                LoadStyleList();
            }
            catch (Exception ex)
            {
                CloseConnection();
                ShowAlert("Update error: " + ex.Message);
            }
        }

        private void AddStyleParams(SqlCommand c)
        {
            c.Parameters.AddWithValue("@StyleNo", txtStyleNo.Text.Trim());
            c.Parameters.AddWithValue("@StyleName", txtStyleName.Text.Trim());
            c.Parameters.AddWithValue("@StyleDescription", NullIfEmpty(txtStyleDesc.Text));
            c.Parameters.AddWithValue("@RevisionNo", txtRevNo.Text.Trim());
            c.Parameters.AddWithValue("@StyleStatus", string.IsNullOrEmpty(hfMainStatus.Value) ? "D" : hfMainStatus.Value);

            c.Parameters.AddWithValue("@BuyerID", NullIfZero(hfBuyer.Value));
            c.Parameters.AddWithValue("@BrandID", NullIfZero(hfBrand.Value));
            c.Parameters.AddWithValue("@AgentID", NullIfZero(hfAgent.Value));
            c.Parameters.AddWithValue("@SeasonID", NullIfZero(hfSeason.Value));
            c.Parameters.AddWithValue("@SeasonYear", NullIfEmpty(hfSeasonYear.Value));
            c.Parameters.AddWithValue("@ProductCategoryID", NullIfZero(hfProductCategory.Value));
            c.Parameters.AddWithValue("@ProductTypeID", NullIfZero(hfProductType.Value));
            c.Parameters.AddWithValue("@GarmentTypeID", NullIfZero(hfGarmentType.Value));
            c.Parameters.AddWithValue("@GenderID", NullIfZero(hfGender.Value));

            c.Parameters.AddWithValue("@Department", NullIfEmpty(txtDepartment.Text));
            c.Parameters.AddWithValue("@Division", NullIfEmpty(txtDivision.Text));
            c.Parameters.AddWithValue("@MerchandiserID", NullIfZero(hfMerchandiser.Value));
            c.Parameters.AddWithValue("@CreationDate", DateOrNull(txtCreationDate.Text));

            c.Parameters.AddWithValue("@BuyerStyleRef", NullIfEmpty(txtBuyerStyleRef.Text));
            c.Parameters.AddWithValue("@FitType", NullIfEmpty(ddlFit.SelectedValue));
            c.Parameters.AddWithValue("@TargetPrice", NullIfEmpty(txtTargetPrice.Text));
            c.Parameters.AddWithValue("@Currency", NullIfEmpty(ddlCurrency.SelectedValue));
            c.Parameters.AddWithValue("@DeliveryDate", DateOrNull(txtDeliveryDate.Text));
            c.Parameters.AddWithValue("@HSCode", NullIfEmpty(txtHSCode.Text));
            c.Parameters.AddWithValue("@CountryOfOrigin", NullIfEmpty(txtCountryOrigin.Text));
            c.Parameters.AddWithValue("@LeadTime", NullIfEmpty(txtLeadTime.Text));
            c.Parameters.AddWithValue("@MOQ", NullIfEmpty(txtMOQ.Text));
            c.Parameters.AddWithValue("@SMV", NullIfEmpty(txtSMV.Text));
            c.Parameters.AddWithValue("@SampleType", NullIfEmpty(ddlSampleType.SelectedValue));
            c.Parameters.AddWithValue("@GarmentWeight", NullIfEmpty(txtGarmentWeight.Text));
            c.Parameters.AddWithValue("@PackingType", NullIfEmpty(txtPacking.Text));
            c.Parameters.AddWithValue("@Remarks", NullIfEmpty(txtRemarks.Text));

            c.Parameters.AddWithValue("@FabricType", NullIfEmpty(txtFabricType.Text));
            c.Parameters.AddWithValue("@KnitWoven", NullIfEmpty(hfKnitWoven.Value));
            c.Parameters.AddWithValue("@Construction", NullIfEmpty(txtConstruction.Text));
            c.Parameters.AddWithValue("@SpecGSM", NullIfEmpty(txtSpecGsm.Text));
            c.Parameters.AddWithValue("@SpecComposition", NullIfEmpty(txtSpecComposition.Text));
            c.Parameters.AddWithValue("@FabricWidth", NullIfEmpty(txtFabricWidth.Text));
            c.Parameters.AddWithValue("@Finish", NullIfEmpty(txtFinish.Text));
            c.Parameters.AddWithValue("@WashType", NullIfEmpty(txtWashType.Text));
            c.Parameters.AddWithValue("@Sleeve", NullIfEmpty(txtSleeve.Text));
            c.Parameters.AddWithValue("@Neck", NullIfEmpty(txtNeck.Text));
            c.Parameters.AddWithValue("@Closure", NullIfEmpty(txtClosure.Text));
            c.Parameters.AddWithValue("@Pocket", NullIfEmpty(txtPocket.Text));
            c.Parameters.AddWithValue("@PrintEmbroidery", NullIfEmpty(txtPrintEmb.Text));
            c.Parameters.AddWithValue("@MainLabel", NullIfEmpty(txtMainLabel.Text));
            c.Parameters.AddWithValue("@CareLabel", NullIfEmpty(txtCareLabel.Text));
            c.Parameters.AddWithValue("@StitchType", NullIfEmpty(txtStitchType.Text));
            c.Parameters.AddWithValue("@SPI", NullIfEmpty(txtSPI.Text));
            c.Parameters.AddWithValue("@HemType", NullIfEmpty(txtHemType.Text));
            c.Parameters.AddWithValue("@CareInstruction", NullIfEmpty(txtCareInstr.Text));
        }

        // ============================================================
        // LOAD STYLE BY ID (for Edit)
        // ============================================================
        private void LoadStyleById(int styleId)
        {
            try
            {
                con = conn.openConnection();
                string sql = "SELECT * FROM dbo.StyleMaster WHERE StyleID = @ID";
                using (SqlCommand c = new SqlCommand(sql, con))
                {
                    c.Parameters.AddWithValue("@ID", styleId);
                    SqlDataReader r = c.ExecuteReader();
                    if (r.Read())
                    {
                        ViewState["StyleID"] = styleId;
                        hfStyleId.Value = styleId.ToString();
                        txtStyleID.Text = styleId.ToString();
                        txtStyleNo.Text = r["StyleNo"].ToString();
                        txtStyleName.Text = r["StyleName"].ToString();
                        txtStyleDesc.Text = r["StyleDescription"].ToString();
                        txtRevNo.Text = r["RevisionNo"].ToString();

                        hfMainStatus.Value = r["StyleStatus"].ToString();
                        hfBuyer.Value = r["BuyerID"].ToString();
                        hfBrand.Value = r["BrandID"].ToString();
                        hfAgent.Value = r["AgentID"].ToString();
                        hfSeason.Value = r["SeasonID"].ToString();
                        hfSeasonYear.Value = r["SeasonYear"].ToString();
                        hfProductCategory.Value = r["ProductCategoryID"].ToString();
                        hfProductType.Value = r["ProductTypeID"].ToString();
                        hfGarmentType.Value = r["GarmentTypeID"].ToString();
                        hfGender.Value = r["GenderID"].ToString();
                        hfMerchandiser.Value = r["MerchandiserID"].ToString();
                        hfKnitWoven.Value = r["KnitWoven"].ToString();

                        txtDepartment.Text = r["Department"].ToString();
                        txtDivision.Text = r["Division"].ToString();
                        txtCreationDate.Text = r["CreationDate"] != DBNull.Value
                            ? Convert.ToDateTime(r["CreationDate"]).ToString("yyyy-MM-dd") : "";
                        txtBuyerStyleRef.Text = r["BuyerStyleRef"].ToString();
                        ddlFit.SelectedValue = r["FitType"].ToString();
                        txtTargetPrice.Text = r["TargetPrice"].ToString();
                        ddlCurrency.SelectedValue = r["Currency"].ToString();
                        txtDeliveryDate.Text = r["DeliveryDate"] != DBNull.Value
                            ? Convert.ToDateTime(r["DeliveryDate"]).ToString("yyyy-MM-dd") : "";
                        txtHSCode.Text = r["HSCode"].ToString();
                        txtCountryOrigin.Text = r["CountryOfOrigin"].ToString();
                        txtLeadTime.Text = r["LeadTime"].ToString();
                        txtMOQ.Text = r["MOQ"].ToString();
                        txtSMV.Text = r["SMV"].ToString();
                        ddlSampleType.SelectedValue = r["SampleType"].ToString();
                        txtGarmentWeight.Text = r["GarmentWeight"].ToString();
                        txtPacking.Text = r["PackingType"].ToString();
                        txtRemarks.Text = r["Remarks"].ToString();

                        txtFabricType.Text = r["FabricType"].ToString();
                        txtConstruction.Text = r["Construction"].ToString();
                        txtSpecGsm.Text = r["SpecGSM"].ToString();
                        txtSpecComposition.Text = r["SpecComposition"].ToString();
                        txtFabricWidth.Text = r["FabricWidth"].ToString();
                        txtFinish.Text = r["Finish"].ToString();
                        txtWashType.Text = r["WashType"].ToString();
                        txtSleeve.Text = r["Sleeve"].ToString();
                        txtNeck.Text = r["Neck"].ToString();
                        txtClosure.Text = r["Closure"].ToString();
                        txtPocket.Text = r["Pocket"].ToString();
                        txtPrintEmb.Text = r["PrintEmbroidery"].ToString();
                        txtMainLabel.Text = r["MainLabel"].ToString();
                        txtCareLabel.Text = r["CareLabel"].ToString();
                        txtStitchType.Text = r["StitchType"].ToString();
                        txtSPI.Text = r["SPI"].ToString();
                        txtHemType.Text = r["HemType"].ToString();
                        txtCareInstr.Text = r["CareInstruction"].ToString();

                        r.Close();

                        RestoreDropdownsFromHidden();

                        LoadStyleColors(styleId);
                        LoadStyleSizes(styleId);
                        LoadStyleFabrics(styleId);
                        LoadStyleAccessories(styleId);
                        LoadStyleSets(styleId);
                        LoadHistory(styleId);
                    }
                    else
                    {
                        r.Close();
                        ClearForm();
                    }
                }
                CloseConnection();
            }
            catch (Exception ex)
            {
                CloseConnection();
                ShowAlert("Load error: " + ex.Message);
            }
        }

        private void RestoreDropdownsFromHidden()
        {
            string script = @"
                (function(){
                    if(!window.NexaDD) return;
                    function set(k){ var hf=document.getElementById('hf'+k.charAt(0).toUpperCase()+k.slice(1)); if(hf && hf.value) window.NexaDD.setValue(k,hf.value); }
                    ['buyer','brand','agent','season','seasonYear','productCategory','productType',
                     'garmentType','gender','merchandiser','mainStatus','knitWoven'].forEach(set);
                })();";
            ScriptManager.RegisterStartupScript(this, this.GetType(),
                "restoreDD_" + Guid.NewGuid().ToString("N"), script, true);
        }

        // ============================================================
        // GRIDVIEW — EDIT / DELETE
        // ============================================================
        protected void gvStyles_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "EditRow")
            {
                int styleId = Convert.ToInt32(e.CommandArgument);
                pnlList.Visible = false;
                pnlEntry.Visible = true;
                btnSave.Visible = false;
                btnUpdate.Visible = true;

                LoadStyleById(styleId);
                ShowAlert("Style loaded for editing.");
            }
            else if (e.CommandName == "DeleteRow")
            {
                int styleId = Convert.ToInt32(e.CommandArgument);
                try
                {
                    con = conn.openConnection();
                    using (SqlCommand c = new SqlCommand("UPDATE dbo.StyleMaster SET IsActive=0, ModifiedBy=@U, ModifiedDate=GETDATE() WHERE StyleID=@ID", con))
                    {
                        c.Parameters.AddWithValue("@U", CurrentUserId);
                        c.Parameters.AddWithValue("@ID", styleId);
                        c.ExecuteNonQuery();
                    }
                    CloseConnection();
                    ShowAlert("Style deactivated.");
                    LoadStyleList();
                }
                catch (Exception ex)
                {
                    CloseConnection();
                    ShowAlert("Delete error: " + ex.Message);
                }
            }
        }

        // ============================================================
        // COLOR GRID
        // ============================================================
        protected void btnAddColor_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(hfColor.Value)) { ShowAlert("Select a color."); return; }

            DataTable dt = GetGridTable(gvColors,
                new[] { "ColorCode", "ColorName", "PantoneCode", "IsActive" },
                new[] { "IsActive" });

            DataRow dr = dt.NewRow();
            dr["ColorCode"] = hfColor.Value;
            dr["ColorName"] = hfColor.Value;
            dr["PantoneCode"] = txtPantone.Text.Trim();
            dr["IsActive"] = true;
            dt.Rows.Add(dr);

            gvColors.DataSource = dt;
            gvColors.DataBind();
            hfColor.Value = "";
            txtPantone.Text = "";
            PreserveTab("colorsize-tab");
        }

        protected void gvColors_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "DelRow")
            {
                int idx = Convert.ToInt32(e.CommandArgument);
                DataTable dt = GetGridTable(gvColors,
                    new[] { "ColorCode", "ColorName", "PantoneCode", "IsActive" },
                    new[] { "IsActive" });
                dt.Rows.RemoveAt(idx);
                gvColors.DataSource = dt;
                gvColors.DataBind();
                PreserveTab("colorsize-tab");
            }
        }

        private void SaveStyleColors(int styleId)
        {
            if (gvColors.Rows.Count == 0) return;
            try
            {
                con = conn.openConnection();
                using (SqlCommand c = new SqlCommand("DELETE FROM dbo.StyleColor WHERE StyleID=@ID", con))
                {
                    c.Parameters.AddWithValue("@ID", styleId);
                    c.ExecuteNonQuery();
                }
                foreach (GridViewRow row in gvColors.Rows)
                {
                    string code = row.Cells[0].Text;
                    string name = row.Cells[1].Text;
                    string pant = row.Cells[2].Text;
                    using (SqlCommand c = new SqlCommand(
                        @"INSERT INTO dbo.StyleColor (StyleID, ColorCode, ColorName, PantoneCode, IsActive, CreatedDate)
                          VALUES (@S, @C, @N, @P, 1, GETDATE())", con))
                    {
                        c.Parameters.AddWithValue("@S", styleId);
                        c.Parameters.AddWithValue("@C", code);
                        c.Parameters.AddWithValue("@N", name);
                        c.Parameters.AddWithValue("@P", pant);
                        c.ExecuteNonQuery();
                    }
                }
                CloseConnection();
            }
            catch { CloseConnection(); }
        }

        private void LoadStyleColors(int styleId)
        {
            try
            {
                con = conn.openConnection();
                string sql = "SELECT ColorCode, ColorName, PantoneCode, IsActive FROM dbo.StyleColor WHERE StyleID=@ID ORDER BY SortOrder, StyleColorID";
                using (SqlCommand c = new SqlCommand(sql, con))
                {
                    c.Parameters.AddWithValue("@ID", styleId);
                    SqlDataAdapter da = new SqlDataAdapter(c);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    gvColors.DataSource = dt;
                    gvColors.DataBind();
                }
                CloseConnection();
            }
            catch { CloseConnection(); }
        }

        // ============================================================
        // SIZE GRID
        // ============================================================
        protected void btnAddSize_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(hfSize.Value)) { ShowAlert("Select a size."); return; }

            DataTable dt = GetGridTable(gvSizes,
                new[] { "SizeCode", "SizeName", "SizeRange", "IsActive" },
                new[] { "IsActive" });

            DataRow dr = dt.NewRow();
            dr["SizeCode"] = hfSize.Value;
            dr["SizeName"] = hfSize.Value;
            dr["SizeRange"] = "";
            dr["IsActive"] = true;
            dt.Rows.Add(dr);

            gvSizes.DataSource = dt;
            gvSizes.DataBind();
            hfSize.Value = "";
            PreserveTab("colorsize-tab");
        }

        protected void gvSizes_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "DelRow")
            {
                int idx = Convert.ToInt32(e.CommandArgument);
                DataTable dt = GetGridTable(gvSizes,
                    new[] { "SizeCode", "SizeName", "SizeRange", "IsActive" },
                    new[] { "IsActive" });
                dt.Rows.RemoveAt(idx);
                gvSizes.DataSource = dt;
                gvSizes.DataBind();
                PreserveTab("colorsize-tab");
            }
        }

        private void SaveStyleSizes(int styleId)
        {
            if (gvSizes.Rows.Count == 0) return;
            try
            {
                con = conn.openConnection();
                using (SqlCommand c = new SqlCommand("DELETE FROM dbo.StyleSize WHERE StyleID=@ID", con))
                {
                    c.Parameters.AddWithValue("@ID", styleId);
                    c.ExecuteNonQuery();
                }
                int sort = 0;
                foreach (GridViewRow row in gvSizes.Rows)
                {
                    sort++;
                    using (SqlCommand c = new SqlCommand(
                        @"INSERT INTO dbo.StyleSize (StyleID, SizeCode, SizeName, SizeRange, SortOrder, IsActive, CreatedDate)
                          VALUES (@S, @C, @N, @R, @O, 1, GETDATE())", con))
                    {
                        c.Parameters.AddWithValue("@S", styleId);
                        c.Parameters.AddWithValue("@C", row.Cells[0].Text);
                        c.Parameters.AddWithValue("@N", row.Cells[1].Text);
                        c.Parameters.AddWithValue("@R", row.Cells[2].Text);
                        c.Parameters.AddWithValue("@O", sort);
                        c.ExecuteNonQuery();
                    }
                }
                CloseConnection();
            }
            catch { CloseConnection(); }
        }

        private void LoadStyleSizes(int styleId)
        {
            try
            {
                con = conn.openConnection();
                string sql = "SELECT SizeCode, SizeName, SizeRange, IsActive FROM dbo.StyleSize WHERE StyleID=@ID ORDER BY SortOrder, StyleSizeID";
                using (SqlCommand c = new SqlCommand(sql, con))
                {
                    c.Parameters.AddWithValue("@ID", styleId);
                    SqlDataAdapter da = new SqlDataAdapter(c);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    gvSizes.DataSource = dt;
                    gvSizes.DataBind();
                }
                CloseConnection();
            }
            catch { CloseConnection(); }
        }

        // ============================================================
        // FABRIC GRID
        // ============================================================
        protected void btnAddFabric_Click(object sender, EventArgs e)
        {
            DataTable dt = GetGridTable(gvFabric,
                new[] { "FabricCode", "FabricName", "Composition", "GSM", "ColorName", "Consumption", "WastagePercent", "Unit" });
            DataRow dr = dt.NewRow();
            dr["FabricCode"] = txtFabCode.Text.Trim();
            dr["FabricName"] = txtFabName.Text.Trim();
            dr["Composition"] = txtFabComp.Text.Trim();
            dr["GSM"] = txtFabGsm.Text.Trim();
            dr["ColorName"] = txtFabColor.Text.Trim();
            dr["Consumption"] = DecOrZero(txtFabCons.Text);
            dr["WastagePercent"] = DecOrZero(txtFabWaste.Text);
            dr["Unit"] = hfFabUnit.Value;
            dt.Rows.Add(dr);
            gvFabric.DataSource = dt;
            gvFabric.DataBind();

            txtFabCode.Text = ""; txtFabName.Text = ""; txtFabComp.Text = "";
            txtFabGsm.Text = ""; txtFabColor.Text = ""; txtFabCons.Text = "";
            txtFabWaste.Text = ""; hfFabUnit.Value = "";
            PreserveTab("colorsize-tab");
        }

        protected void gvFabric_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "DelRow")
            {
                int idx = Convert.ToInt32(e.CommandArgument);
                DataTable dt = GetGridTable(gvFabric,
                    new[] { "FabricCode", "FabricName", "Composition", "GSM", "ColorName", "Consumption", "WastagePercent", "Unit" });
                dt.Rows.RemoveAt(idx);
                gvFabric.DataSource = dt;
                gvFabric.DataBind();
                PreserveTab("colorsize-tab");
            }
        }

        private void SaveStyleFabrics(int styleId)
        {
            if (gvFabric.Rows.Count == 0) return;
            try
            {
                con = conn.openConnection();
                using (SqlCommand c = new SqlCommand("DELETE FROM dbo.StyleFabric WHERE StyleID=@ID", con))
                {
                    c.Parameters.AddWithValue("@ID", styleId);
                    c.ExecuteNonQuery();
                }
                int sort = 0;
                foreach (GridViewRow row in gvFabric.Rows)
                {
                    sort++;
                    using (SqlCommand c = new SqlCommand(
                        @"INSERT INTO dbo.StyleFabric
                          (StyleID, FabricCode, FabricName, Composition, GSM, ColorName, Consumption, WastagePercent, UnitCode, SortOrder, IsActive, CreatedDate)
                          VALUES (@S, @C, @N, @Comp, @G, @Col, @Cons, @W, @U, @O, 1, GETDATE())", con))
                    {
                        c.Parameters.AddWithValue("@S", styleId);
                        c.Parameters.AddWithValue("@C", row.Cells[0].Text);
                        c.Parameters.AddWithValue("@N", row.Cells[1].Text);
                        c.Parameters.AddWithValue("@Comp", row.Cells[2].Text);
                        c.Parameters.AddWithValue("@G", row.Cells[3].Text);
                        c.Parameters.AddWithValue("@Col", row.Cells[4].Text);
                        c.Parameters.AddWithValue("@Cons", DecOrZero(row.Cells[5].Text));
                        c.Parameters.AddWithValue("@W", DecOrZero(row.Cells[6].Text));
                        c.Parameters.AddWithValue("@U", row.Cells[7].Text);
                        c.Parameters.AddWithValue("@O", sort);
                        c.ExecuteNonQuery();
                    }
                }
                CloseConnection();
            }
            catch { CloseConnection(); }
        }

        private void LoadStyleFabrics(int styleId)
        {
            try
            {
                con = conn.openConnection();
                string sql = @"SELECT FabricCode, FabricName, Composition, GSM, ColorName,
                                      Consumption, WastagePercent, UnitCode AS Unit
                               FROM dbo.StyleFabric WHERE StyleID=@ID ORDER BY SortOrder, StyleFabricID";
                using (SqlCommand c = new SqlCommand(sql, con))
                {
                    c.Parameters.AddWithValue("@ID", styleId);
                    SqlDataAdapter da = new SqlDataAdapter(c);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    gvFabric.DataSource = dt;
                    gvFabric.DataBind();
                }
                CloseConnection();
            }
            catch { CloseConnection(); }
        }

        // ============================================================
        // ACCESSORIES GRID
        // ============================================================
        protected void btnAddAcc_Click(object sender, EventArgs e)
        {
            DataTable dt = GetGridTable(gvAcc,
                new[] { "ItemCode", "ItemName", "ItemType", "SizeColor", "Consumption", "Unit", "WastagePercent", "Supplier" });
            DataRow dr = dt.NewRow();
            dr["ItemCode"] = txtAccCode.Text.Trim();
            dr["ItemName"] = txtAccName.Text.Trim();
            dr["ItemType"] = hfAccType.Value;
            dr["SizeColor"] = txtAccSizeColor.Text.Trim();
            dr["Consumption"] = DecOrZero(txtAccCons.Text);
            dr["Unit"] = hfAccUnit.Value;
            dr["WastagePercent"] = DecOrZero(txtAccWaste.Text);
            dr["Supplier"] = txtAccSupplier.Text.Trim();
            dt.Rows.Add(dr);
            gvAcc.DataSource = dt;
            gvAcc.DataBind();

            txtAccCode.Text = ""; txtAccName.Text = ""; txtAccSizeColor.Text = "";
            txtAccCons.Text = ""; txtAccWaste.Text = ""; txtAccSupplier.Text = "";
            hfAccType.Value = ""; hfAccUnit.Value = "";
            PreserveTab("colorsize-tab");
        }

        protected void gvAcc_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "DelRow")
            {
                int idx = Convert.ToInt32(e.CommandArgument);
                DataTable dt = GetGridTable(gvAcc,
                    new[] { "ItemCode", "ItemName", "ItemType", "SizeColor", "Consumption", "Unit", "WastagePercent", "Supplier" });
                dt.Rows.RemoveAt(idx);
                gvAcc.DataSource = dt;
                gvAcc.DataBind();
                PreserveTab("colorsize-tab");
            }
        }

        private void SaveStyleAccessories(int styleId)
        {
            if (gvAcc.Rows.Count == 0) return;
            try
            {
                con = conn.openConnection();
                using (SqlCommand c = new SqlCommand("DELETE FROM dbo.StyleAccessories WHERE StyleID=@ID", con))
                {
                    c.Parameters.AddWithValue("@ID", styleId);
                    c.ExecuteNonQuery();
                }
                int sort = 0;
                foreach (GridViewRow row in gvAcc.Rows)
                {
                    sort++;
                    using (SqlCommand c = new SqlCommand(
                        @"INSERT INTO dbo.StyleAccessories
                          (StyleID, ItemCode, ItemName, AccTypeName, SizeColor, Consumption, UnitCode, WastagePercent, Supplier, SortOrder, IsActive, CreatedDate)
                          VALUES (@S, @C, @N, @T, @SC, @Cons, @U, @W, @Sup, @O, 1, GETDATE())", con))
                    {
                        c.Parameters.AddWithValue("@S", styleId);
                        c.Parameters.AddWithValue("@C", row.Cells[0].Text);
                        c.Parameters.AddWithValue("@N", row.Cells[1].Text);
                        c.Parameters.AddWithValue("@T", row.Cells[2].Text);
                        c.Parameters.AddWithValue("@SC", row.Cells[3].Text);
                        c.Parameters.AddWithValue("@Cons", DecOrZero(row.Cells[4].Text));
                        c.Parameters.AddWithValue("@U", row.Cells[5].Text);
                        c.Parameters.AddWithValue("@W", DecOrZero(row.Cells[6].Text));
                        c.Parameters.AddWithValue("@Sup", row.Cells[7].Text);
                        c.Parameters.AddWithValue("@O", sort);
                        c.ExecuteNonQuery();
                    }
                }
                CloseConnection();
            }
            catch { CloseConnection(); }
        }

        private void LoadStyleAccessories(int styleId)
        {
            try
            {
                con = conn.openConnection();
                string sql = @"SELECT ItemCode, ItemName, AccTypeName AS ItemType, SizeColor,
                                      Consumption, UnitCode AS Unit, WastagePercent, Supplier
                               FROM dbo.StyleAccessories WHERE StyleID=@ID ORDER BY SortOrder, StyleAccID";
                using (SqlCommand c = new SqlCommand(sql, con))
                {
                    c.Parameters.AddWithValue("@ID", styleId);
                    SqlDataAdapter da = new SqlDataAdapter(c);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    gvAcc.DataSource = dt;
                    gvAcc.DataBind();
                }
                CloseConnection();
            }
            catch { CloseConnection(); }
        }

        // ============================================================
        // SET
        // ============================================================
        protected void btnSetSave_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(txtSetName.Text.Trim()))
            {
                ShowAlert("Enter Set Name.");
                return;
            }
            if (ViewState["StyleID"] == null)
            {
                ShowAlert("Save the style first before adding a set.");
                return;
            }
            try
            {
                con = conn.openConnection();
                int setId;
                using (SqlCommand c = new SqlCommand("sp_SaveUpdateStyleSet", con))
                {
                    c.CommandType = CommandType.StoredProcedure;
                    c.Parameters.Add("@SetID", SqlDbType.Int).Value =
                        string.IsNullOrEmpty(hfSetId.Value) ? 0 : Convert.ToInt32(hfSetId.Value);
                    c.Parameters.Add("@StyleID", SqlDbType.Int).Value = Convert.ToInt32(ViewState["StyleID"]);
                    c.Parameters.Add("@SetName", SqlDbType.NVarChar, 100).Value = txtSetName.Text.Trim();
                    c.Parameters.Add("@SetRemarks", SqlDbType.NVarChar, 300).Value =
                        string.IsNullOrWhiteSpace(txtSetRemarks.Text) ? (object)DBNull.Value : txtSetRemarks.Text.Trim();

                    SqlParameter outId = new SqlParameter("@NewSetID", SqlDbType.Int);
                    outId.Direction = ParameterDirection.Output;
                    c.Parameters.Add(outId);
                    c.ExecuteNonQuery();
                    setId = Convert.ToInt32(outId.Value);
                }
                CloseConnection();
                hfSetId.Value = setId.ToString();
                LoadStyleSets(Convert.ToInt32(ViewState["StyleID"]));
                ShowAlert("Set saved.");
            }
            catch (Exception ex)
            {
                CloseConnection();
                ShowAlert("Set save error: " + ex.Message);
            }
        }

        private void LoadStyleSets(int styleId)
        {
            try
            {
                con = conn.openConnection();
                string sql = "SELECT SetID, SetName FROM dbo.StyleSet WHERE StyleID=@ID AND IsActive=1";
                using (SqlCommand c = new SqlCommand(sql, con))
                {
                    c.Parameters.AddWithValue("@ID", styleId);
                    SqlDataAdapter da = new SqlDataAdapter(c);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    gvSets.DataSource = dt;
                    gvSets.DataBind();
                }
                CloseConnection();
            }
            catch { CloseConnection(); }
        }

        protected void btnSetNew_Click(object sender, EventArgs e)
        {
            hfSetId.Value = "0";
            txtSetName.Text = "";
            txtSetRemarks.Text = "";
            txtCompName.Text = "";
            txtCompQty.Text = "1";
            txtCompStyle.Text = "";
            txtMapSet.Text = "";
            txtMapComp.Text = "";
            ShowAlert("New Set form is ready.");
            PreserveTab("colorsize-tab");
        }

        protected void btnAddSetComp_Click(object sender, EventArgs e)
        {
            ShowAlert("Add Set Component: implement per your workflow.");
            PreserveTab("set-tab");
        }

        protected void gvSetComp_RowCommand(object sender, GridViewCommandEventArgs e) { }
        protected void btnAddSetMap_Click(object sender, EventArgs e) 
        {
            PreserveTab("set-tab");
        }
        protected void gvSetMap_RowCommand(object sender, GridViewCommandEventArgs e) { }

        protected void gvSets_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "LoadSet")
            {
                hfSetId.Value = Convert.ToString(e.CommandArgument);
                ShowAlert("Set loaded.");
            }
            else if (e.CommandName == "OffSet")
            {
                try
                {
                    int setId = Convert.ToInt32(e.CommandArgument);
                    con = conn.openConnection();
                    using (SqlCommand c = new SqlCommand("UPDATE dbo.StyleSet SET IsActive=0 WHERE SetID=@ID", con))
                    {
                        c.Parameters.AddWithValue("@ID", setId);
                        c.ExecuteNonQuery();
                    }
                    CloseConnection();
                    if (ViewState["StyleID"] != null)
                        LoadStyleSets(Convert.ToInt32(ViewState["StyleID"]));
                    ShowAlert("Set deactivated.");
                }
                catch (Exception ex) { CloseConnection(); ShowAlert(ex.Message); }
            }
        }

        private void LoadHistory(int styleId)
        {
            try
            {
                con = conn.openConnection();
                string sql = @"SELECT ActionDateTime, ActionByUser, ActionType, FieldName, PreviousValue, NewValue, Remarks
                               FROM dbo.StyleHistory WHERE StyleID=@ID ORDER BY HistoryID DESC";
                using (SqlCommand c = new SqlCommand(sql, con))
                {
                    c.Parameters.AddWithValue("@ID", styleId);
                    SqlDataAdapter da = new SqlDataAdapter(c);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    gvHistory.DataSource = dt;
                    gvHistory.DataBind();
                }
                CloseConnection();
            }
            catch { CloseConnection(); }
        }

        // ============================================================
        // IMAGE DELETE
        // ============================================================
        protected void DeleteImage_Command(object sender, CommandEventArgs e)
        {
            ShowAlert(e.CommandArgument + " image delete event.");
        }

        // ============================================================
        // VALIDATION & CLEAR
        // ============================================================
        private bool ValidateForm()
        {
            if (string.IsNullOrWhiteSpace(txtStyleNo.Text)) { ShowAlert("Style No is required."); return false; }
            if (string.IsNullOrWhiteSpace(txtStyleName.Text)) { ShowAlert("Style Name is required."); return false; }
            return true;
        }

        private void ClearForm()
        {
            txtStyleID.Text = "0";
            txtStyleNo.Text = "";
            txtStyleName.Text = "";
            txtStyleDesc.Text = "";
            txtRevNo.Text = "00";
            txtDepartment.Text = "";
            txtDivision.Text = "";
            txtCreationDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
            txtRemarks.Text = "";

            txtBuyerStyleRef.Text = "";
            ddlFit.SelectedIndex = 0;
            txtTargetPrice.Text = "";
            ddlCurrency.SelectedIndex = 0;
            txtDeliveryDate.Text = "";
            txtHSCode.Text = "";
            txtCountryOrigin.Text = "Bangladesh";
            txtLeadTime.Text = "";
            txtMOQ.Text = "";
            txtSMV.Text = "";
            ddlSampleType.SelectedIndex = 0;
            txtGarmentWeight.Text = "";
            txtPacking.Text = "";

            txtFabricType.Text = "";
            txtConstruction.Text = "";
            txtSpecGsm.Text = "";
            txtSpecComposition.Text = "";
            txtFabricWidth.Text = "";
            txtFinish.Text = "";
            txtWashType.Text = "";
            txtSleeve.Text = "";
            txtNeck.Text = "";
            txtClosure.Text = "";
            txtPocket.Text = "";
            txtPrintEmb.Text = "";
            txtMainLabel.Text = "";
            txtCareLabel.Text = "";
            txtStitchType.Text = "";
            txtSPI.Text = "";
            txtHemType.Text = "";
            txtCareInstr.Text = "";

            txtPantone.Text = "";
            txtFabCode.Text = "";
            txtFabName.Text = "";
            txtFabComp.Text = "";
            txtFabGsm.Text = "";
            txtFabColor.Text = "";
            txtFabCons.Text = "";
            txtFabWaste.Text = "";
            txtAccCode.Text = "";
            txtAccName.Text = "";
            txtAccSizeColor.Text = "";
            txtAccCons.Text = "";
            txtAccWaste.Text = "";
            txtAccSupplier.Text = "";
            txtSetName.Text = "";
            txtSetRemarks.Text = "";
            txtCompName.Text = "";
            txtCompQty.Text = "1";
            txtCompStyle.Text = "";
            txtMapSet.Text = "";
            txtMapComp.Text = "";

            hfStyleId.Value = "0";
            hfSetId.Value = "0";
            hfBuyer.Value = ""; hfBrand.Value = ""; hfAgent.Value = "";
            hfSeason.Value = ""; hfSeasonYear.Value = ""; hfProductCategory.Value = "";
            hfProductType.Value = ""; hfGarmentType.Value = ""; hfGender.Value = "";
            hfMerchandiser.Value = ""; hfKnitWoven.Value = ""; hfMainStatus.Value = "";
            hfColor.Value = ""; hfSize.Value = ""; hfFabUnit.Value = "";
            hfAccType.Value = ""; hfAccUnit.Value = ""; hfMapComp.Value = ""; hfMapType.Value = "";
            hfBuyerFilter.Value = ""; hfStatusFilter.Value = "";

            ViewState["StyleID"] = null;

            gvColors.DataSource = null; gvColors.DataBind();
            gvSizes.DataSource = null; gvSizes.DataBind();
            gvFabric.DataSource = null; gvFabric.DataBind();
            gvAcc.DataSource = null; gvAcc.DataBind();
            gvSets.DataSource = null; gvSets.DataBind();
            gvHistory.DataSource = null; gvHistory.DataBind();
        }

        // ============================================================
        // GRID HELPERS (typed bool support)
        // ============================================================
        private DataTable GetGridTable(GridView gv, string[] columns, string[] boolColumns = null)
        {
            boolColumns = boolColumns ?? new string[0];

            DataTable dt = new DataTable();
            foreach (string col in columns)
            {
                if (Array.IndexOf(boolColumns, col) >= 0)
                    dt.Columns.Add(col, typeof(bool));
                else
                    dt.Columns.Add(col, typeof(object));
            }

            DataTable src = gv.DataSource as DataTable;
            if (src != null)
            {
                foreach (DataRow r in src.Rows)
                {
                    DataRow dr = dt.NewRow();
                    for (int i = 0; i < columns.Length; i++)
                    {
                        string col = columns[i];
                        if (Array.IndexOf(boolColumns, col) >= 0)
                            dr[col] = IsActiveValue(r[col]);
                        else
                            dr[col] = r[col];
                    }
                    dt.Rows.Add(dr);
                }
                return dt;
            }

            foreach (GridViewRow row in gv.Rows)
            {
                DataRow dr = dt.NewRow();
                for (int i = 0; i < columns.Length && i < row.Cells.Count; i++)
                {
                    string col = columns[i];
                    string txt = row.Cells[i].Text;
                    if (Array.IndexOf(boolColumns, col) >= 0)
                        dr[col] = IsActiveValue(txt);
                    else
                        dr[col] = txt;
                }
                dt.Rows.Add(dr);
            }
            return dt;
        }
    }
}