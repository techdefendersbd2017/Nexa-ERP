using Nexa_ERP.Connection;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.MerchandisingMarketing.BasicSetup
{
    public partial class BuyerBrandSetup : System.Web.UI.Page
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

                LoadBuyers(ddlBuyerFilter, "--Select Buyer--");
                LoadBuyers(ddlBuyer, "--Select Buyer--");
                ShowList();
                LoadBrandList();
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
        //  LOAD BUYER DROPDOWN (filter + entry)
        // ================================================================
        private void LoadBuyers(DropDownList ddl, string firstText)
        {
            try
            {
                using (ConScope cs = new ConScope(conn.openConnection()))
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT BuyerID, BuyerName FROM Buyer WHERE ISNULL(IsActive, 1) = 1 ORDER BY BuyerName", cs.Con))
                {
                    DataTable dt = new DataTable();
                    new SqlDataAdapter(cmd).Fill(dt);

                    ddl.DataSource = dt;
                    ddl.DataTextField = "BuyerName";
                    ddl.DataValueField = "BuyerID";
                    ddl.DataBind();

                    ddl.Items.Insert(0, new ListItem(firstText, "0"));
                }
            }
            catch (Exception ex)
            {
                ShowMessage(ex.Message);
            }
        }

        // ================================================================
        //  LOAD BRAND LIST (Buyer + Brand Code/Name filter)
        // ================================================================
        private void LoadBrandList()
        {
            try
            {
                string query = @"
                    SELECT  b.BrandID AS BrandId, b.BuyerID, bu.BuyerName, b.BrandCode, b.BrandName,
                            CAST(ISNULL(b.IsActive, 0) AS BIT) AS IsActive
                    FROM    Brand b
                            INNER JOIN Buyer bu ON bu.BuyerID = b.BuyerID
                    WHERE   1 = 1";

                int buyerFilter = 0;
                int.TryParse(ddlBuyerFilter.SelectedValue, out buyerFilter);
                if (buyerFilter > 0)
                    query += " AND b.BuyerID = @BuyerID";

                string search = txtSearch.Text.Trim();
                if (search.Length > 0)
                    query += " AND (b.BrandName LIKE @Search OR b.BrandCode LIKE @Search)";

                query += " ORDER BY bu.BuyerName, b.BrandName";

                using (ConScope cs = new ConScope(conn.openConnection()))
                using (SqlCommand cmd = new SqlCommand(query, cs.Con))
                {
                    if (buyerFilter > 0)
                        cmd.Parameters.Add("@BuyerID", SqlDbType.Int).Value = buyerFilter;

                    if (search.Length > 0)
                        cmd.Parameters.Add("@Search", SqlDbType.NVarChar, 200).Value = "%" + search + "%";

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

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadBrandList();
        }

        protected void btnClearFilter_Click(object sender, EventArgs e)
        {
            ddlBuyerFilter.SelectedIndex = 0;
            txtSearch.Text = string.Empty;
            LoadBrandList();
        }

        // ================================================================
        //  GRIDVIEW : Edit / Delete
        // ================================================================
        protected void GridView1_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int brandId;
            if (!int.TryParse(Convert.ToString(e.CommandArgument), out brandId)) return;

            if (e.CommandName == "EditRow")
            {
                LoadBrandForEdit(brandId);
            }
            else if (e.CommandName == "DeleteRow")
            {
                DeleteBrand(brandId);
            }
        }

        private void LoadBrandForEdit(int brandId)
        {
            try
            {
                using (ConScope cs = new ConScope(conn.openConnection()))
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT BrandID, BrandCode, BrandName, BuyerID, IsActive FROM Brand WHERE BrandID = @BrandID", cs.Con))
                {
                    cmd.Parameters.Add("@BrandID", SqlDbType.Int).Value = brandId;

                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (!r.Read())
                        {
                            ShowMessage("Brand not found!");
                            return;
                        }

                        hfBrandId.Value = r["BrandID"].ToString();

                        string buyerId = r["BuyerID"] != DBNull.Value ? r["BuyerID"].ToString() : "0";
                        ddlBuyer.SelectedValue = ddlBuyer.Items.FindByValue(buyerId) != null ? buyerId : "0";

                        txtBrandCode.Text = r["BrandCode"] != DBNull.Value ? r["BrandCode"].ToString() : string.Empty;
                        txtBrandName.Text = r["BrandName"].ToString();
                        chkActive.Checked = r["IsActive"] != DBNull.Value && Convert.ToBoolean(r["IsActive"]);
                    }
                }

                ShowEntry();
            }
            catch (Exception ex)
            {
                ShowMessage(ex.Message);
            }
        }

        private void DeleteBrand(int brandId)
        {
            try
            {
                using (ConScope cs = new ConScope(conn.openConnection()))
                using (SqlCommand cmd = new SqlCommand("Pro_Brand_Delete", cs.Con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@BrandID", SqlDbType.Int).Value = brandId;
                    cmd.ExecuteNonQuery();
                }

                ShowMessage("Deleted Successfully!");
                LoadBrandList();
            }
            catch (SqlException ex)
            {
                // 547 = Foreign key conflict (অন্য table এ এই Brand ব্যবহার হচ্ছে)
                if (ex.Number == 547)
                    ShowMessage("This brand is already in use. You cannot delete it.");
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
            LoadBrandList();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ClearForm();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            // ---------- Validation ----------
            if (ddlBuyer.SelectedValue == "0" || ddlBuyer.SelectedValue == "") { ShowMessage("Please select a Buyer!"); return; }
            if (txtBrandCode.Text.Trim() == "") { ShowMessage("Brand Code is required!"); return; }
            if (txtBrandName.Text.Trim() == "") { ShowMessage("Brand Name is required!"); return; }

            int brandId = 0;
            int.TryParse(hfBrandId.Value, out brandId);

            int userId = 0;
            int.TryParse(hfUserId.Value, out userId);

            int buyerId = 0;
            int.TryParse(ddlBuyer.SelectedValue, out buyerId);

            // ---------- Save / Update ----------
            try
            {
                using (ConScope cs = new ConScope(conn.openConnection()))
                using (SqlCommand cmd = new SqlCommand("Pro_Brand_SaveUpdate", cs.Con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.Add("@BrandID", SqlDbType.Int).Value = brandId;
                    cmd.Parameters.Add("@BrandCode", SqlDbType.NVarChar, 50).Value = txtBrandCode.Text.Trim();
                    cmd.Parameters.Add("@BrandName", SqlDbType.NVarChar, 150).Value = txtBrandName.Text.Trim();
                    cmd.Parameters.Add("@BuyerID", SqlDbType.Int).Value = buyerId;
                    cmd.Parameters.Add("@IsActive", SqlDbType.Bit).Value = chkActive.Checked;
                    cmd.Parameters.Add("@UserId", SqlDbType.Int).Value = userId;

                    cmd.ExecuteNonQuery();
                }

                ShowMessage(brandId == 0 ? "Saved Successfully!" : "Updated Successfully!");

                ClearForm();
                ShowList();
                LoadBrandList();
            }
            catch (Exception ex)
            {
                // Duplicate brand এর মত SP error এখানে দেখাবে, form খোলা থাকবে
                ShowMessage(ex.Message);
            }
        }

        // ================================================================
        //  HELPERS
        // ================================================================
        private void ClearForm()
        {
            hfBrandId.Value = "0";

            ddlBuyer.SelectedIndex = 0;
            txtBrandCode.Text = string.Empty;
            txtBrandName.Text = string.Empty;
            chkActive.Checked = true;
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