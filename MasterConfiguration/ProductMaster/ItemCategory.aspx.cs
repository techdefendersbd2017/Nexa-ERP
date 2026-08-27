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

namespace Nexa_ERP.TrimsAccessories.MsterSetup
{
    public partial class ItemCategory : System.Web.UI.Page
    {
        SqlConnection con;
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();
        SqlCommand cmd;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadCategoryInformation();
            }
        }

        private void LoadCategoryInformation()
        {
            try
            {
                con = conn.openConnection();
                {
                    SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM ta_ItemCategory Order by CategoryName asc", con);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    gvCategory.DataSource = dt;
                    gvCategory.DataBind();
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
            txtCategoryId.Text = txtCategoryName.Text = string.Empty;
            ddlStatus.SelectedValue = "Active";
        }

        protected void gvCategory_SelectedIndexChanged(object sender, EventArgs e)
        {
            txtCategoryId.Text = gvCategory.SelectedRow.Cells[0].Text;
            try
            {
                string sql = "Select * from ta_ItemCategory where CategoryID ='" + txtCategoryId.Text + "'";
                con = conn.openConnection();
                cmd = new SqlCommand(sql, con);
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        txtCategoryName.Text = reader["CategoryName"].ToString();
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
                using (SqlCommand cmd = new SqlCommand("sp_ta_InsertUpdate_ItemCategory", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    int categoryId = 0;
                    if (!string.IsNullOrEmpty(txtCategoryId.Text.Trim()))
                    {
                        int.TryParse(txtCategoryId.Text.Trim(), out categoryId);
                    }

                    cmd.Parameters.AddWithValue("@CategoryID", categoryId == 0 ? (object)DBNull.Value : categoryId);
                    cmd.Parameters.AddWithValue("@CategoryName", string.IsNullOrEmpty(txtCategoryName.Text.Trim()) ? (object)DBNull.Value : txtCategoryName.Text.Trim());
                    cmd.Parameters.AddWithValue("@Status", ddlStatus.SelectedValue);

                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            string actionResult = rdr["ActionType"].ToString();
                            string newId = rdr["ResultID"].ToString();

                            if (actionResult == "Inserted")
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Category Saved Successfully! ID: " + newId + "');", true);
                            }
                            else if (actionResult == "Updated")
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Category Updated Successfully!');", true);
                            }
                        }
                    }

                    clearform();
                    LoadCategoryInformation();
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

        protected void txtSearch_TextChanged(object sender, EventArgs e)
        {
            try
            {
                con = conn.openConnection();
                {
                    SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM ta_ItemCategory WHERE CategoryName LIKE '%" + txtSearch.Text.Trim() + "%' ORDER BY CategoryName ASC", con);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    gvCategory.DataSource = dt;
                    gvCategory.DataBind();
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
    }
}