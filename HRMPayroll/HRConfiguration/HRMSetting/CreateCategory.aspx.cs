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

namespace Nexa_ERP.HRMPayroll.HRConfiguration.HRMSetting
{
    public partial class CreateCategory : System.Web.UI.Page
    {
        SqlConnection con;
        PayrollDB conn = new PayrollDB();
        SqlCommand cmd;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string user = Request.QueryString["user"];
                LoadCategoryInformation();
                LoadddlSalaryBrackdownPolicy();
            }
        }

        private void LoadddlSalaryBrackdownPolicy()
        {
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    string query = "SELECT * FROM Brackdown_Policy order By Brackdown_Name asc";
                    SqlDataAdapter da = new SqlDataAdapter(query, con);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlSalaryBrackdownPolicy.DataSource = dt;
                    ddlSalaryBrackdownPolicy.DataTextField = "Brackdown_Name";
                    ddlSalaryBrackdownPolicy.DataValueField = "Brackdown_Code";
                    ddlSalaryBrackdownPolicy.DataBind();
                    ddlSalaryBrackdownPolicy.Items.Insert(0, new ListItem("--Select--", "0"));
                }
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
        private void LoadCategoryInformation()
        {
            try
            {
                con = conn.openConnection();
                {
                    SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM TB_Catagory Order by Catagory_Name asc", con);
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
        private void SelectCategoryInfo()
        {            
            try
            {
                string sql = "Select * from TB_Department where Department_Code ='" + txtCategoryId.Text + "'";
                con = conn.openConnection();
                cmd = new SqlCommand(sql, con);
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        txtCategory.Text = reader[1].ToString();
                        ddlOTHolder.SelectedValue = reader[2].ToString();
                        ddlAttBonusHolder.SelectedValue = reader[3].ToString();
                        ddlNightBillHolder.SelectedValue = reader[4].ToString();
                        ddlHolidayHolder.SelectedValue = reader[5].ToString();
                        ddlTifinHolder.SelectedValue = reader[6].ToString();
                        ddlSalaryBrackdownPolicy.SelectedValue = reader[7].ToString();

                        chkIsActive.Checked = reader[8] != DBNull.Value && Convert.ToBoolean(reader[8]); // ✅ CheckBox
                    }
                }
                else
                {
                    txtCategoryId.Text = txtCategory.Text = string.Empty;
                    chkIsActive.Checked = false;
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

        private void clearform()
        {
            txtCategoryId.Text = txtCategory.Text = string.Empty;
            ddlOTHolder.SelectedValue = "0";
            ddlAttBonusHolder.SelectedValue = "0";
            ddlNightBillHolder.SelectedValue = "0";
            ddlHolidayHolder.SelectedValue = "0";
            ddlTifinHolder.SelectedValue = "0";
            ddlSalaryBrackdownPolicy.SelectedValue = "0";
            chkIsActive.Checked = false;
        }

        protected void gvCategory_SelectedIndexChanged(object sender, EventArgs e)
        {
            txtCategoryId.Text = gvCategory.SelectedRow.Cells[1].Text;
            try
            {
                string sql = "Select * from TB_Catagory where Catagory_Code ='" + txtCategoryId.Text + "'";
                con = conn.openConnection();
                cmd = new SqlCommand(sql, con);
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        txtCategory.Text = reader[1].ToString();
                        ddlOTHolder.SelectedValue = reader[2].ToString();
                        ddlAttBonusHolder.SelectedValue = reader[3].ToString();
                        ddlNightBillHolder.SelectedValue = reader[4].ToString();
                        ddlHolidayHolder.SelectedValue = reader[5].ToString();
                        ddlTifinHolder.SelectedValue = reader[6].ToString();
                        ddlSalaryBrackdownPolicy.SelectedValue = reader[7].ToString();

                        chkIsActive.Checked = reader[8] != DBNull.Value && Convert.ToBoolean(reader[8]); // ✅ CheckBox
                    }
                }
                else
                {
                    txtCategoryId.Text = txtCategory.Text = string.Empty;
                    ddlOTHolder.SelectedValue = "0";
                    ddlAttBonusHolder.SelectedValue = "0";
                    ddlNightBillHolder.SelectedValue = "0";
                    ddlHolidayHolder.SelectedValue = "0";
                    ddlTifinHolder.SelectedValue = "0";
                    ddlSalaryBrackdownPolicy.SelectedValue = "0";
                    chkIsActive.Checked = false;
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


            con = conn.openConnection();
            {
                using (SqlCommand cmd = new SqlCommand("SP_Catagory_Save_Web", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    long categoryId = 0;
                    if (!string.IsNullOrEmpty(txtCategoryId.Text.Trim()))
                    {
                        long.TryParse(txtCategoryId.Text.Trim(), out categoryId);
                    }
                    cmd.Parameters.AddWithValue("@Catagory_Code", categoryId);
                    cmd.Parameters.AddWithValue("@Catagory_Name", string.IsNullOrEmpty(txtCategory.Text.Trim()) ? (object)DBNull.Value : txtCategory.Text.Trim());
                    cmd.Parameters.AddWithValue("@OT_Holder", Convert.ToInt32(ddlOTHolder.SelectedValue));
                    cmd.Parameters.AddWithValue("@Att_bonus_hoder", Convert.ToInt32(ddlAttBonusHolder.SelectedValue));
                    cmd.Parameters.AddWithValue("@TIffin_Holder", Convert.ToInt32(ddlTifinHolder.SelectedValue));
                    cmd.Parameters.AddWithValue("@Night_holder", Convert.ToInt32(ddlNightBillHolder.SelectedValue));
                    cmd.Parameters.AddWithValue("@Holiday_holder", Convert.ToInt32(ddlHolidayHolder.SelectedValue));
                    cmd.Parameters.AddWithValue("@SalaryBrackdownRullsID", Convert.ToInt32(ddlSalaryBrackdownPolicy.SelectedValue));
                    cmd.Parameters.AddWithValue("@IsActive", chkIsActive.Checked);

                    try
                    {
                        con = conn.openConnection();
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                string actionResult = rdr["Action"].ToString();
                                string newId = rdr["ResultCode"].ToString();

                                if (actionResult == "INSERTED")
                                {
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Category Saved Successfully! New ID: " + newId + "');", true);
                                }
                                else if (actionResult == "UPDATED")
                                {
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Category Updated Successfully!');", true);
                                }
                            }
                        }

                        clearform();

                    }
                    catch (Exception ex)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error: " + ex.Message.Replace("'", "\\'") + "');", true);
                    }
                }
            }
            con.Close();
        }
    }
}