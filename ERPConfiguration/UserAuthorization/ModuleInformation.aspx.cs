using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Nexa_ERP.Connection;

namespace Nexa_ERP.ERPConfiguration.UserAuthorization
{
    public partial class ModuleInformation : System.Web.UI.Page
    {
        SqlConnection con;
        Database_Connection conn = new Database_Connection();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindModuleGrid();
                ClearForm(); // ClearForm আগে ডাকলে ডাটা রিসেট হয়ে সঠিক আইডি আসবে
            }
        }

        void LoadNextModule_ID()
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT ISNULL(MAX(Module_ID), 0) + 1 FROM Module_Information";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    object result = cmd.ExecuteScalar();
                    txtModuleID.Text = result != null ? result.ToString() : "1";
                }
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open)
                {
                    con.Close();
                }
            }
        }

        // Bind Data to GridView
        private void BindModuleGrid()
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT Module_ID, Module_Name, Icon_Class, Module_Code, is_Active, SortingNo FROM Module_Information ORDER BY SortingNo ASC, Module_ID DESC";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        gvModuleInfo.DataSource = dt;
                        gvModuleInfo.DataBind();
                    }
                }
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open)
                {
                    con.Close();
                }
            }
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ClearForm();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                con = conn.openConnection();
                long moduleId = string.IsNullOrEmpty(hfModuleID.Value) ? 0 : Convert.ToInt64(hfModuleID.Value);
                string query = "";

                if (moduleId == 0)
                {
                    // Insert Query
                    query = @"INSERT INTO Module_Information (Module_ID,Module_Name, Icon_Class, Module_Code, is_Active, SortingNo) 
                              VALUES (@Module_ID,@Module_Name, @Icon_Class, @Module_Code, @is_Active, @SortingNo)";
                }
                else
                {
                    // Update Query
                    query = @"UPDATE Module_Information 
                              SET Module_Name = @Module_Name, 
                                  Icon_Class = @Icon_Class, 
                                  Module_Code = @Module_Code, 
                                  is_Active = @is_Active, 
                                  SortingNo = @SortingNo 
                              WHERE Module_ID = @Module_ID";
                }

                using (SqlCommand cmd = new SqlCommand(query, con))
                {                    

                    cmd.Parameters.AddWithValue("Module_ID", txtModuleID.Text.Trim());
                    cmd.Parameters.AddWithValue("@Module_Name", txtModuleName.Text.Trim());
                    cmd.Parameters.AddWithValue("@Icon_Class", txtIconClass.Text.Trim());
                    cmd.Parameters.AddWithValue("@Module_Code", txtModuleCode.Text.Trim());
                    cmd.Parameters.AddWithValue("@is_Active", chkIsActive.Checked);

                    int sortingNo = 0;
                    int.TryParse(txtSortingNo.Text.Trim(), out sortingNo);
                    cmd.Parameters.AddWithValue("@SortingNo", sortingNo);

                    cmd.ExecuteNonQuery();
                }


                ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('Module saved successfully!');", true);
            }
            catch (Exception ex)
            {
                string safeMsg = ex.Message.Replace("'", "\\'").Replace("\r\n", " ");
                ScriptManager.RegisterStartupScript(this, GetType(), "alert", $"alert('Error: {safeMsg}');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open)
                {
                    con.Close();
                }
            }
            BindModuleGrid();
            ClearForm();
        }

        protected void gvModuleInfo_SelectedIndexChanged(object sender, EventArgs e)
        {
            try
            {
                GridViewRow row = gvModuleInfo.SelectedRow;
                string moduleId = gvModuleInfo.DataKeys[row.RowIndex].Value.ToString();

                con = conn.openConnection();
                string query = "SELECT Module_ID, Module_Name, Icon_Class, Module_Code, is_Active, SortingNo FROM Module_Information WHERE Module_ID = @Module_ID";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@Module_ID", moduleId);
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        if (dt.Rows.Count > 0)
                        {
                            DataRow dr = dt.Rows[0];
                            hfModuleID.Value = dr["Module_ID"].ToString();
                            txtModuleID.Text = dr["Module_ID"].ToString();
                            txtModuleName.Text = dr["Module_Name"].ToString();
                            txtModuleCode.Text = dr["Module_Code"].ToString();
                            txtIconClass.Text = dr["Icon_Class"].ToString();
                            txtSortingNo.Text = dr["SortingNo"].ToString();
                            chkIsActive.Checked = dr["is_Active"] != DBNull.Value && Convert.ToBoolean(dr["is_Active"]);

                            lblStatusInfo.Text = "Update Mode";
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                string safeMsg = ex.Message.Replace("'", "\\'").Replace("\r\n", " ");
                ScriptManager.RegisterStartupScript(this, GetType(), "alert", $"alert('Error: {safeMsg}');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open)
                {
                    con.Close();
                }
            }
        }

        private void ClearForm()
        {
            hfModuleID.Value = "0";
            txtModuleName.Text = string.Empty;
            txtModuleCode.Text = string.Empty;
            txtIconClass.Text = string.Empty;
            txtSortingNo.Text = "0";
            chkIsActive.Checked = true;
            lblStatusInfo.Text = "New Entry";
            gvModuleInfo.SelectedIndex = -1;

            // নতুন এন্ট্রির জন্য অটো আইডি লোড করবে
            LoadNextModule_ID();
        }
    }
}