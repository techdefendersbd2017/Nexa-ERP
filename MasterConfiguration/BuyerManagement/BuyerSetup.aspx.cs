using Nexa_ERP.Connection;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.MerchandisingMarketing.BasicSetup
{
    public partial class BuyerSetup : System.Web.UI.Page
    {
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();

        // openConnection() যদি shared connection ফেরত দেয়, using দিয়ে Dispose করলে
        // পরের বার "ConnectionString property has not been initialized" error আসে।
        // তাই Dispose এর বদলে শুধু Close করা হচ্ছে।
        private sealed class ConScope : IDisposable
        {
            public SqlConnection Con { get; private set; }
            public ConScope(SqlConnection con) { Con = con; }
            public void Dispose()
            {
                if (Con != null && Con.State != ConnectionState.Closed) Con.Close();
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Login user (আপনার project এর Session key অনুযায়ী পরিবর্তন করুন)
                hfUserId.Value = Session["UserId"] != null ? Session["UserId"].ToString() : "0";

                LoadCountries();
                ShowList();
                LoadBuyerList();
            }
        }

        // ================================================================
        //  PANEL SWITCH
        // ================================================================
        private void ShowList()
        {
            pnlList.Visible = true;
            pnlEntry.Visible = false;
        }

        private void ShowEntry()
        {
            pnlList.Visible = false;
            pnlEntry.Visible = true;
        }

        // ================================================================
        //  LOAD COUNTRY DROPDOWN
        // ================================================================
        private void LoadCountries()
        {
            try
            {
                using (ConScope cs = new ConScope(conn.openConnection()))
                using (SqlCommand cmd = new SqlCommand("SELECT CountryID, CountryName FROM CountryInformation ORDER BY CountryName", cs.Con))
                {
                    DataTable dt = new DataTable();
                    new SqlDataAdapter(cmd).Fill(dt);

                    ddlCountry.DataSource = dt;
                    ddlCountry.DataTextField = "CountryName";
                    ddlCountry.DataValueField = "CountryID";
                    ddlCountry.DataBind();

                    ddlCountry.Items.Insert(0, new ListItem("--Select Country--", "0"));
                }
            }
            catch (Exception ex)
            {
                ShowMessage(ex.Message);
            }
        }

        // ================================================================
        //  LOAD BUYER LIST (Search + Buyer Type filter)
        // ================================================================
        private void LoadBuyerList()
        {
            try
            {
                string query = @"
                    SELECT  b.BuyerID, b.BuyerCode, b.BuyerName, b.DisplayName,
                            ISNULL(c.CountryName, '') AS CountryName,
                            b.ContactNo, b.Email, b.Commission,
                            CASE WHEN b.IsLocal  = 1 THEN 'Local'  ELSE 'Foreign'  END AS BuyerTypeName,
                            CASE WHEN b.IsActive = 1 THEN 'Active' ELSE 'Inactive' END AS StatusName
                    FROM    BuyerInformation b
                            LEFT JOIN CountryInformation c ON c.CountryID = b.CountryID
                    WHERE   1 = 1";

                string search = txtSearchBuyer.Text.Trim();
                if (search.Length > 0)
                    query += " AND (b.BuyerName LIKE @Search OR b.BuyerCode LIKE @Search OR b.DisplayName LIKE @Search)";

                if (ddlBuyerType.SelectedValue != "")
                    query += " AND b.IsLocal = @IsLocal";

                query += " ORDER BY b.BuyerName";

                using (ConScope cs = new ConScope(conn.openConnection()))
                using (SqlCommand cmd = new SqlCommand(query, cs.Con))
                {
                    if (search.Length > 0)
                        cmd.Parameters.Add("@Search", SqlDbType.NVarChar, 200).Value = "%" + search + "%";

                    if (ddlBuyerType.SelectedValue != "")
                        cmd.Parameters.Add("@IsLocal", SqlDbType.Bit).Value = ddlBuyerType.SelectedValue == "1";

                    DataTable dt = new DataTable();
                    new SqlDataAdapter(cmd).Fill(dt);

                    GridView1.DataSource = dt;
                    GridView1.DataBind();
                }
            }
            catch (Exception ex)
            {
                ShowMessage(ex.Message);
            }
        }

        // ================================================================
        //  LIST PANEL EVENTS
        // ================================================================
        protected void btnAddNew_Click(object sender, EventArgs e)
        {
            ClearForm();
            ShowEntry();
        }

        protected void txtSearchBuyer_TextChanged(object sender, EventArgs e)
        {
            LoadBuyerList();
        }

        protected void ddlBuyerType_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadBuyerList();
        }

        protected void btnClearFilter_Click(object sender, EventArgs e)
        {
            txtSearchBuyer.Text = string.Empty;
            ddlBuyerType.SelectedIndex = 0;
            LoadBuyerList();
        }

        // ================================================================
        //  GRIDVIEW : Edit / Delete
        // ================================================================
        protected void GridView1_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int buyerId;
            if (!int.TryParse(Convert.ToString(e.CommandArgument), out buyerId)) return;

            if (e.CommandName == "EditBuyer")
            {
                LoadBuyerForEdit(buyerId);
            }
            else if (e.CommandName == "DeleteBuyer")
            {
                DeleteBuyer(buyerId);
            }
        }

        private void LoadBuyerForEdit(int buyerId)
        {
            try
            {
                using (ConScope cs = new ConScope(conn.openConnection()))
                using (SqlCommand cmd = new SqlCommand("SELECT * FROM BuyerInformation WHERE BuyerID = @BuyerID", cs.Con))
                {
                    cmd.Parameters.Add("@BuyerID", SqlDbType.Int).Value = buyerId;

                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (!r.Read())
                        {
                            ShowMessage("Buyer not found!");
                            return;
                        }

                        hfBuyerId.Value = r["BuyerID"].ToString();

                        txtBuyerCode.Text = r["BuyerCode"].ToString();
                        txtBuyerName.Text = r["BuyerName"].ToString();
                        txtDisplayName.Text = r["DisplayName"].ToString();
                        txtKnitOutsideBuyerName.Text = r["KnitOutsideBuyerName"].ToString();
                        txtDyeingOutsideBuyerName.Text = r["DyeingOutsideBuyerName"].ToString();
                        txtGarmentsOutsideBuyerName.Text = r["GarmentsOutsideBuyerName"].ToString();
                        txtContact.Text = r["ContactNo"].ToString();
                        txtEmail.Text = r["Email"].ToString();
                        txtLCSCName.Text = r["LCSCName"].ToString();
                        txtCommission.Text = Convert.ToDecimal(r["Commission"]).ToString("0.##", CultureInfo.InvariantCulture);
                        txtLicenceNo.Text = r["LicenceNo"].ToString();
                        txtAddress.Text = r["Address"].ToString();

                        string countryId = r["CountryID"] != DBNull.Value ? r["CountryID"].ToString() : "0";
                        ddlCountry.SelectedValue = ddlCountry.Items.FindByValue(countryId) != null ? countryId : "0";

                        chkIsActive.Checked = r["IsActive"] != DBNull.Value && Convert.ToBoolean(r["IsActive"]);
                        chkIsLocal.Checked = r["IsLocal"] != DBNull.Value && Convert.ToBoolean(r["IsLocal"]);

                        txtAssetLedger.Text = r["AssetLedger"].ToString();
                        txtSalesLedger.Text = r["SalesLedger"].ToString();
                        txtLiabilityLedger.Text = r["LiabilityLedger"].ToString();
                    }
                }

                ShowEntry();
            }
            catch (Exception ex)
            {
                ShowMessage(ex.Message);
            }
        }

        private void DeleteBuyer(int buyerId)
        {
            try
            {
                using (ConScope cs = new ConScope(conn.openConnection()))
                using (SqlCommand cmd = new SqlCommand("Pro_Buyer_Delete", cs.Con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@BuyerID", SqlDbType.Int).Value = buyerId;
                    cmd.ExecuteNonQuery();
                }

                ShowMessage("Deleted Successfully!");
                LoadBuyerList();
            }
            catch (SqlException ex)
            {
                // 547 = Foreign key conflict (অন্য table এ এই Buyer ব্যবহার হচ্ছে)
                if (ex.Number == 547)
                    ShowMessage("This buyer is already in use. You cannot delete it.");
                else
                    ShowMessage(ex.Message);
            }
            catch (Exception ex)
            {
                ShowMessage(ex.Message);
            }
        }

        // ================================================================
        //  ENTRY PANEL EVENTS
        // ================================================================
        protected void btnBackToList_Click(object sender, EventArgs e)
        {
            ClearForm();
            ShowList();
            LoadBuyerList();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ClearForm();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            // ---------- Validation ----------
            if (txtBuyerCode.Text.Trim() == "") { ShowMessage("Buyer Code is required!"); return; }
            if (txtBuyerName.Text.Trim() == "") { ShowMessage("Buyer Name is required!"); return; }
            if (txtDisplayName.Text.Trim() == "") { ShowMessage("Display Name is required!"); return; }

            decimal commission;
            if (!decimal.TryParse(txtCommission.Text.Trim(), NumberStyles.Any, CultureInfo.InvariantCulture, out commission)
                || commission < 0 || commission > 100)
            {
                ShowMessage("Commission must be a number between 0 and 100!");
                return;
            }

            int assetLedger, salesLedger, liabilityLedger;
            if (!int.TryParse(txtAssetLedger.Text.Trim(), out assetLedger)) assetLedger = 0;
            if (!int.TryParse(txtSalesLedger.Text.Trim(), out salesLedger)) salesLedger = 0;
            if (!int.TryParse(txtLiabilityLedger.Text.Trim(), out liabilityLedger)) liabilityLedger = 0;

            int buyerId = 0;
            int.TryParse(hfBuyerId.Value, out buyerId);

            int userId = 0;
            int.TryParse(hfUserId.Value, out userId);

            int countryId = 0;
            int.TryParse(ddlCountry.SelectedValue, out countryId);

            // ---------- Save / Update ----------
            try
            {
                using (ConScope cs = new ConScope(conn.openConnection()))
                using (SqlCommand cmd = new SqlCommand("Pro_Buyer_SaveUpdate", cs.Con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.Add("@BuyerID", SqlDbType.Int).Value = buyerId;
                    cmd.Parameters.Add("@BuyerCode", SqlDbType.NVarChar, 50).Value = txtBuyerCode.Text.Trim();
                    cmd.Parameters.Add("@BuyerName", SqlDbType.NVarChar, 200).Value = txtBuyerName.Text.Trim();
                    cmd.Parameters.Add("@DisplayName", SqlDbType.NVarChar, 200).Value = txtDisplayName.Text.Trim();
                    cmd.Parameters.Add("@KnitOutsideBuyerName", SqlDbType.NVarChar, 200).Value = txtKnitOutsideBuyerName.Text.Trim();
                    cmd.Parameters.Add("@DyeingOutsideBuyerName", SqlDbType.NVarChar, 200).Value = txtDyeingOutsideBuyerName.Text.Trim();
                    cmd.Parameters.Add("@GarmentsOutsideBuyerName", SqlDbType.NVarChar, 200).Value = txtGarmentsOutsideBuyerName.Text.Trim();
                    cmd.Parameters.Add("@ContactNo", SqlDbType.NVarChar, 50).Value = txtContact.Text.Trim();
                    cmd.Parameters.Add("@Email", SqlDbType.NVarChar, 150).Value = txtEmail.Text.Trim();
                    cmd.Parameters.Add("@LCSCName", SqlDbType.NVarChar, 200).Value = txtLCSCName.Text.Trim();

                    SqlParameter pCommission = cmd.Parameters.Add("@Commission", SqlDbType.Decimal);
                    pCommission.Precision = 18;
                    pCommission.Scale = 2;
                    pCommission.Value = commission;

                    cmd.Parameters.Add("@LicenceNo", SqlDbType.NVarChar, 100).Value = txtLicenceNo.Text.Trim();
                    cmd.Parameters.Add("@Address", SqlDbType.NVarChar, 500).Value = txtAddress.Text.Trim();
                    cmd.Parameters.Add("@CountryID", SqlDbType.Int).Value = countryId == 0 ? (object)DBNull.Value : countryId;
                    cmd.Parameters.Add("@IsActive", SqlDbType.Bit).Value = chkIsActive.Checked;
                    cmd.Parameters.Add("@IsLocal", SqlDbType.Bit).Value = chkIsLocal.Checked;
                    cmd.Parameters.Add("@AssetLedger", SqlDbType.Int).Value = assetLedger;
                    cmd.Parameters.Add("@SalesLedger", SqlDbType.Int).Value = salesLedger;
                    cmd.Parameters.Add("@LiabilityLedger", SqlDbType.Int).Value = liabilityLedger;
                    cmd.Parameters.Add("@UserId", SqlDbType.Int).Value = userId;

                    cmd.ExecuteNonQuery();
                }

                ShowMessage(buyerId == 0 ? "Saved Successfully!" : "Updated Successfully!");

                ClearForm();
                ShowList();
                LoadBuyerList();
            }
            catch (Exception ex)
            {
                // Duplicate code/name এর মত SP error এখানে দেখাবে, form খোলা থাকবে
                ShowMessage(ex.Message);
            }
        }

        // ================================================================
        //  HELPERS
        // ================================================================
        private void ClearForm()
        {
            hfBuyerId.Value = "0";

            txtBuyerCode.Text = string.Empty;
            txtBuyerName.Text = string.Empty;
            txtDisplayName.Text = string.Empty;
            txtKnitOutsideBuyerName.Text = string.Empty;
            txtDyeingOutsideBuyerName.Text = string.Empty;
            txtGarmentsOutsideBuyerName.Text = string.Empty;
            txtContact.Text = string.Empty;
            txtEmail.Text = string.Empty;
            txtLCSCName.Text = string.Empty;
            txtCommission.Text = "0";
            txtLicenceNo.Text = string.Empty;
            txtAddress.Text = string.Empty;
            ddlCountry.SelectedIndex = 0;
            chkIsActive.Checked = true;
            chkIsLocal.Checked = false;

            txtAssetLedger.Text = "0";
            txtSalesLedger.Text = "0";
            txtLiabilityLedger.Text = "0";
        }

        private void ShowMessage(string message)
        {
            string safe = (message ?? string.Empty)
                .Replace("\\", "\\\\")
                .Replace("'", "\\'")
                .Replace("\r", " ")
                .Replace("\n", " ");

            ScriptManager.RegisterStartupScript(this, this.GetType(), Guid.NewGuid().ToString(), "alert('" + safe + "');", true);
        }
    }
}
