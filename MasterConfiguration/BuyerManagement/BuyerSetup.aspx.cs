using Nexa_ERP.Connection;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Text.RegularExpressions;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.MerchandisingMarketing.BasicSetup
{
    public partial class BuyerSetup : System.Web.UI.Page
    {
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();

        // Shared connection Dispose করলে পরে error আসে, তাই শুধু Close করা হচ্ছে।
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
        //  LOAD BUYER LIST (Search + Status filter)
        // ================================================================
        private void LoadBuyerList()
        {
            try
            {
                string query = @"
                    SELECT  BuyerID, BuyerCode, BuyerName, Country,
                            ContactPerson, ContactEmail, ContactPhone,
                            CASE WHEN IsActive = 1 THEN 'Active' ELSE 'Inactive' END AS StatusName
                    FROM    dbo.Buyer
                    WHERE   1 = 1";

                string search = txtSearchBuyer.Text.Trim();
                if (search.Length > 0)
                    query += @" AND (BuyerCode LIKE @Search OR BuyerName LIKE @Search
                                     OR Country LIKE @Search OR ContactPerson LIKE @Search)";

                if (ddlStatus.SelectedValue != "")
                    query += " AND IsActive = @IsActive";

                query += " ORDER BY BuyerName";

                using (ConScope cs = new ConScope(conn.openConnection()))
                using (SqlCommand cmd = new SqlCommand(query, cs.Con))
                {
                    if (search.Length > 0)
                        cmd.Parameters.Add("@Search", SqlDbType.NVarChar, 200).Value = "%" + search + "%";

                    if (ddlStatus.SelectedValue != "")
                        cmd.Parameters.Add("@IsActive", SqlDbType.Bit).Value = ddlStatus.SelectedValue == "1";

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

        protected void ddlStatus_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadBuyerList();
        }

        protected void btnClearFilter_Click(object sender, EventArgs e)
        {
            txtSearchBuyer.Text = string.Empty;
            ddlStatus.SelectedIndex = 0;
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
                using (SqlCommand cmd = new SqlCommand("SELECT * FROM dbo.Buyer WHERE BuyerID = @BuyerID", cs.Con))
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
                        txtCountry.Text = r["Country"].ToString();
                        txtContactPerson.Text = r["ContactPerson"].ToString();
                        txtContactPhone.Text = r["ContactPhone"].ToString();
                        txtContactEmail.Text = r["ContactEmail"].ToString();

                        chkIsActive.Checked = r["IsActive"] != DBNull.Value && Convert.ToBoolean(r["IsActive"]);
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

            string email = txtContactEmail.Text.Trim();
            if (email.Length > 0 && !Regex.IsMatch(email, @"^[^@\s]+@[^@\s]+\.[^@\s]+$"))
            {
                ShowMessage("Please enter a valid email address!");
                return;
            }

            int buyerId = 0;
            int.TryParse(hfBuyerId.Value, out buyerId);

            int userId = 0;
            int.TryParse(hfUserId.Value, out userId);

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
                    cmd.Parameters.Add("@Country", SqlDbType.NVarChar, 100).Value = txtCountry.Text.Trim();
                    cmd.Parameters.Add("@ContactPerson", SqlDbType.NVarChar, 150).Value = txtContactPerson.Text.Trim();
                    cmd.Parameters.Add("@ContactEmail", SqlDbType.NVarChar, 150).Value = email;
                    cmd.Parameters.Add("@ContactPhone", SqlDbType.NVarChar, 50).Value = txtContactPhone.Text.Trim();
                    cmd.Parameters.Add("@IsActive", SqlDbType.Bit).Value = chkIsActive.Checked;
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
            txtCountry.Text = string.Empty;
            txtContactPerson.Text = string.Empty;
            txtContactPhone.Text = string.Empty;
            txtContactEmail.Text = string.Empty;
            chkIsActive.Checked = true;
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