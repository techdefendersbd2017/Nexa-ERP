using Nexa_ERP.Connection;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.MasterConfiguration.BuyerManagement
{
    public partial class ProductCategory : System.Web.UI.Page
    {
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();

        // openConnection() shared connection ফেরত দিলে Dispose না করে শুধু Close করা হচ্ছে।
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
                ShowList();
                LoadCategoryList();
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
        //  LOAD CATEGORY LIST (দুইটা Grid এ একসাথে bind হবে)
        //  Pro_ProductCategory_GetList
        // ================================================================
        private void LoadCategoryList()
        {
            try
            {
                string search = txtSearch.Text.Trim();

                int status = -1;
                int.TryParse(ddlStatusFilter.SelectedValue, out status);

                using (ConScope cs = new ConScope(conn.openConnection()))
                using (SqlCommand cmd = new SqlCommand("Pro_ProductCategory_GetList", cs.Con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@Search", SqlDbType.NVarChar, 200).Value =
                        search.Length > 0 ? (object)search : DBNull.Value;
                    cmd.Parameters.Add("@IsActive", SqlDbType.Int).Value = status;

                    DataTable dt = new DataTable();
                    new SqlDataAdapter(cmd).Fill(dt);

                    // List panel grid
                    GridView1.DataSource = dt;
                    GridView1.DataBind();

                    // Entry panel grid (Save button এর নিচে)
                    GridView2.DataSource = dt;
                    GridView2.DataBind();
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
            LoadCategoryList();
        }

        protected void btnClearFilter_Click(object sender, EventArgs e)
        {
            txtSearch.Text = string.Empty;
            ddlStatusFilter.SelectedIndex = 0;
            LoadCategoryList();
        }

        // ================================================================
        //  GRIDVIEW : Edit / Delete (GridView1 ও GridView2 দুইটারই handler)
        // ================================================================
        protected void Grid_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int categoryId;
            if (!int.TryParse(Convert.ToString(e.CommandArgument), out categoryId)) return;

            if (e.CommandName == "EditRow")
            {
                LoadCategoryForEdit(categoryId);
            }
            else if (e.CommandName == "DeleteRow")
            {
                DeleteCategory(categoryId);
            }
        }

        // Pro_ProductCategory_GetById
        private void LoadCategoryForEdit(int categoryId)
        {
            try
            {
                using (ConScope cs = new ConScope(conn.openConnection()))
                using (SqlCommand cmd = new SqlCommand("Pro_ProductCategory_GetById", cs.Con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@CategoryID", SqlDbType.Int).Value = categoryId;

                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (!r.Read())
                        {
                            ShowMessage("Category not found!");
                            return;
                        }

                        hfCategoryId.Value = r["CategoryID"].ToString();
                        txtCategoryCode.Text = r["CategoryCode"] != DBNull.Value ? r["CategoryCode"].ToString() : string.Empty;
                        txtCategoryName.Text = r["CategoryName"] != DBNull.Value ? r["CategoryName"].ToString() : string.Empty;
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

        // Pro_ProductCategory_Delete
        private void DeleteCategory(int categoryId)
        {
            try
            {
                using (ConScope cs = new ConScope(conn.openConnection()))
                using (SqlCommand cmd = new SqlCommand("Pro_ProductCategory_Delete", cs.Con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@CategoryID", SqlDbType.Int).Value = categoryId;
                    cmd.ExecuteNonQuery();
                }

                // যে category edit হচ্ছিল সেটাই delete হলে form clear করে দাও
                if (hfCategoryId.Value == categoryId.ToString())
                    ClearForm();

                ShowMessage("Deleted Successfully!");
                LoadCategoryList();
            }
            catch (SqlException ex)
            {
                // 547 = Foreign key conflict (অন্য table এ এই Category ব্যবহার হচ্ছে)
                if (ex.Number == 547)
                    ShowMessage("This category is already in use. You cannot delete it.");
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
            LoadCategoryList();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ClearForm();
        }

        // Pro_ProductCategory_SaveUpdate
        protected void btnSave_Click(object sender, EventArgs e)
        {
            // ---------- Validation ----------
            string code = txtCategoryCode.Text.Trim();
            string name = txtCategoryName.Text.Trim();

            if (code == "") { ShowMessage("Category Code is required!"); return; }
            if (name == "") { ShowMessage("Category Name is required!"); return; }

            int categoryId = 0;
            int.TryParse(hfCategoryId.Value, out categoryId);

            // ---------- Save / Update ----------
            try
            {
                using (ConScope cs = new ConScope(conn.openConnection()))
                using (SqlCommand cmd = new SqlCommand("Pro_ProductCategory_SaveUpdate", cs.Con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.Add("@CategoryID", SqlDbType.Int).Value = categoryId;
                    cmd.Parameters.Add("@CategoryCode", SqlDbType.NVarChar, 50).Value = code;
                    cmd.Parameters.Add("@CategoryName", SqlDbType.NVarChar, 150).Value = name;
                    cmd.Parameters.Add("@IsActive", SqlDbType.Bit).Value = chkActive.Checked;

                    cmd.ExecuteNonQuery();
                }

                ShowMessage(categoryId == 0 ? "Saved Successfully!" : "Updated Successfully!");

                // Save এর পরে List tab এ যাবে না: form clear হবে, Entry panel এই থাকবে,
                // আর নিচের GridView2 refresh হবে।
                ClearForm();
                ShowEntry();
                LoadCategoryList();
            }
            catch (Exception ex)
            {
                ShowMessage(ex.Message);
            }
        }

        // ================================================================
        //  HELPERS
        // ================================================================
        private void ClearForm()
        {
            hfCategoryId.Value = "0";
            txtCategoryCode.Text = string.Empty;
            txtCategoryName.Text = string.Empty;
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
