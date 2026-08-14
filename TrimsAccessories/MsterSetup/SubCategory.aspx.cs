using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.TrimsAccessories.MsterSetup
{
    public partial class SubCategory : System.Web.UI.Page
    {
        SqlConnection con;
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();
        SqlCommand cmd;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadCategoryDropdown();
                LoadSubCategoryInformation();
            }
        }

        private void LoadCategoryDropdown()
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT CategoryID, CategoryName FROM ta_ItemCategory WHERE Status='Active' ORDER BY CategoryName ASC";
                SqlDataAdapter da = new SqlDataAdapter(query, con);
                DataTable dt = new DataTable();
                da.Fill(dt);

                ddlItemCategory.DataSource = dt;
                ddlItemCategory.DataTextField = "CategoryName";
                ddlItemCategory.DataValueField = "CategoryID";
                ddlItemCategory.DataBind();
                ddlItemCategory.Items.Insert(0, new ListItem("--Select Category--", "0"));
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

        private void LoadSubCategoryInformation()
        {
            try
            {
                con = conn.openConnection();
                string query = @"SELECT s.SubCategoryID, c.CategoryName, s.SubCategoryName, s.Status 
                                 FROM ta_SubCategory s 
                                 INNER JOIN ta_ItemCategory c ON s.CategoryID = c.CategoryID 
                                 ORDER BY s.SubCategoryName ASC";
                SqlDataAdapter da = new SqlDataAdapter(query, con);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvSubCategory.DataSource = dt;
                gvSubCategory.DataBind();
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "\\'") + "');", true);
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
            txtSubCategoryId.Text = txtSubCategoryName.Text = string.Empty;
            ddlItemCategory.SelectedValue = "0";
            ddlStatus.SelectedValue = "Active";
        }

        protected void gvSubCategory_SelectedIndexChanged(object sender, EventArgs e)
        {
            txtSubCategoryId.Text = gvSubCategory.SelectedRow.Cells[0].Text;
            try
            {
                string sql = "Select * from ta_SubCategory where SubCategoryID ='" + txtSubCategoryId.Text + "'";
                con = conn.openConnection();
                cmd = new SqlCommand(sql, con);
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        ddlItemCategory.SelectedValue = reader["CategoryID"].ToString();
                        txtSubCategoryName.Text = reader["SubCategoryName"].ToString();
                        ddlStatus.SelectedValue = reader["Status"].ToString();
                    }
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

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            clearform();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                con = conn.openConnection();
                using (SqlCommand cmd = new SqlCommand("sp_ta_InsertUpdate_SubCategory", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    int subCategoryId = 0;
                    if (!string.IsNullOrEmpty(txtSubCategoryId.Text.Trim()))
                    {
                        int.TryParse(txtSubCategoryId.Text.Trim(), out subCategoryId);
                    }

                    cmd.Parameters.AddWithValue("@SubCategoryID", subCategoryId == 0 ? (object)DBNull.Value : subCategoryId);
                    cmd.Parameters.AddWithValue("@CategoryID", Convert.ToInt32(ddlItemCategory.SelectedValue));
                    cmd.Parameters.AddWithValue("@SubCategoryName", string.IsNullOrEmpty(txtSubCategoryName.Text.Trim()) ? (object)DBNull.Value : txtSubCategoryName.Text.Trim());
                    cmd.Parameters.AddWithValue("@Status", ddlStatus.SelectedValue);

                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            string actionResult = rdr["ActionType"].ToString();
                            string newId = rdr["ResultID"].ToString();

                            if (actionResult == "Inserted")
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Sub Category Saved Successfully! ID: " + newId + "');", true);
                            }
                            else if (actionResult == "Updated")
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Sub Category Updated Successfully!');", true);
                            }
                        }
                    }
                    clearform();
                    LoadSubCategoryInformation();
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
    }
}