using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.Inventory.InventoryConfiguration
{
    public partial class CrateStore : System.Web.UI.Page
    {
        SqlConnection con;
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();
        SqlCommand cmd;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Load_BranchInfoarmation();
            }
        }
        private void Load_BranchInfoarmation()
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT * FROM vw_Branch_Information ORDER BY Branch_Name";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    ddlBranchName.DataSource = dt;
                    ddlBranchName.DataTextField = "Branch_Name";
                    ddlBranchName.DataValueField = "Branch_ID";
                    ddlBranchName.DataBind();
                    ddlBranchName.Items.Insert(0, new ListItem("--Select Branch--", "0"));
                }
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
        }

        private void LoadStoreInformation()
        {
            try
            {
                con = conn.openConnection();
                {
                    SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM CrateStore where BranchName='"+ ddlBranchName .SelectedValue+ "' ORDER BY StoreName ASC", con);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    gvCrateStore.DataSource = dt;
                    gvCrateStore.DataBind();
                }
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert",
                    "alert('" + ex.Message.Replace("'", "\\'") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open)
                {
                    con.Close();
                }
            }
        }

        private void clearform()
        {
            txtStoreId.Text = txtStoreName.Text = string.Empty;
            ddlStatus.SelectedValue = "Active";
            btnSaveStoreName.Text = "Save";
        }

        protected void gvCrateStore_SelectedIndexChanged(object sender, EventArgs e)
        {
            txtStoreId.Text = gvCrateStore.SelectedRow.Cells[0].Text;
            try
            {
                string sql = "SELECT * FROM CrateStore WHERE StoreId = '" + txtStoreId.Text + "'";
                con = conn.openConnection();
                cmd = new SqlCommand(sql, con);
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        ddlBranchName.SelectedValue = reader["BranchName"].ToString();
                        txtStoreName.Text = reader["StoreName"].ToString();
                        ddlStatus.SelectedValue = reader["Status"].ToString();
                    }
                    btnSaveStoreName.Text = "Update";
                }
                else
                {
                    clearform();
                }
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open)
                {
                    con.Close();
                }
            }
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            clearform();
        }

        protected void btnSaveStoreName_Click(object sender, EventArgs e)
        {
            try
            {
                con = conn.openConnection();
                using (SqlCommand cmd = new SqlCommand("sp_CrateStore_SaveUpdate", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    int storeId = 0;
                    if (!string.IsNullOrEmpty(txtStoreId.Text.Trim()))
                    {
                        int.TryParse(txtStoreId.Text.Trim(), out storeId);
                    }

                    cmd.Parameters.AddWithValue("@StoreId", storeId == 0 ? (object)DBNull.Value : storeId);
                    cmd.Parameters.AddWithValue("@BranchName", string.IsNullOrEmpty(ddlBranchName.SelectedValue) ? (object)DBNull.Value : ddlBranchName.SelectedValue);
                    cmd.Parameters.AddWithValue("@StoreName", string.IsNullOrEmpty(txtStoreName.Text.Trim()) ? (object)DBNull.Value : txtStoreName.Text.Trim());
                    cmd.Parameters.AddWithValue("@Status", ddlStatus.SelectedValue);

                    // যদি Stored Procedure থেকে ActionType রিটার্ন করাতে চান, তবে নিচে এক্সিকিউট রিডার ব্যবহার করতে পারেন।
                    // অথবা সাধারণ ExecuteNonQuery দিয়েও করতে পারেন। নিচে স্ট্যান্ডার্ড ফরম্যাট দেওয়া হলো:
                    cmd.ExecuteNonQuery();

                    if (storeId == 0)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Crate Store Saved Successfully!');", true);
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Crate Store Updated Successfully!');", true);
                    }

                    clearform();
                    LoadStoreInformation();
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error: " + ex.Message.Replace("'", "\\'") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open)
                {
                    con.Close();
                }
            }
        }

        protected void ddlBranchName_SelectedIndexChanged(object sender, EventArgs e)
        {

            LoadStoreInformation();
        }
    }
}