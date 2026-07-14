using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.HRMPayroll.HRConfiguration.HRMSetting
{
    public partial class DepartmentSetting : System.Web.UI.Page
    {
        SqlConnection con;
        PayrollDB conn = new PayrollDB();
        SqlCommand cmd;
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string user = Request.QueryString["user"];
                LoadDepartmentInformation();
            }
        }
        private void LoadDepartmentInformation()
        {
            try
            {
                con = conn.openConnection();
                {
                    SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM TB_Department Order by Department_Name asc", con);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    gvDepartment.DataSource = dt;
                    gvDepartment.DataBind();
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

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    using (SqlCommand cmd = new SqlCommand("Pro_Department_Save_Web", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;

                        cmd.Parameters.Add("@Department_Code", SqlDbType.Int).Value =string.IsNullOrEmpty(txtDepartmentID.Text) ? 0 : Convert.ToInt32(txtDepartmentID.Text);
                        cmd.Parameters.Add("@Department_Name", SqlDbType.NVarChar, 200).Value = txtDepartmentName.Text.Trim();
                        cmd.Parameters.Add("@Bangla_Name", SqlDbType.NVarChar, 200).Value = txtDepartmentNameLocal.Text.Trim();
                        cmd.Parameters.Add("@DptPrefix", SqlDbType.NVarChar, 50).Value = txtPrefix.Text.Trim();
                        cmd.Parameters.Add("@RequiredManpower", SqlDbType.Int).Value =  string.IsNullOrEmpty(txtRequiredManpower.Text) ? 0 : Convert.ToInt32(txtRequiredManpower.Text);
                        cmd.Parameters.Add("@Extra_Required_Manpower", SqlDbType.Int).Value =string.IsNullOrEmpty(txtExtraRequiredManpower.Text) ? 0 : Convert.ToInt32(txtExtraRequiredManpower.Text);
                        cmd.Parameters.Add("@IsActive", SqlDbType.Bit).Value = chkIsActive.Checked;
                        cmd.ExecuteNonQuery();
                    }
                }

                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert",
                    "alert('Save Successfully!');", true);
                LoadDepartmentInformation();
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

        protected void gvDepartment_SelectedIndexChanged(object sender, EventArgs e)
        {
            txtDepartmentID.Text = gvDepartment.SelectedRow.Cells[1].Text;
            try
            {
                string sql = "Select * from TB_Department where Department_Code ='" + txtDepartmentID.Text + "'";
                con = conn.openConnection();
                cmd = new SqlCommand(sql, con);
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        txtDepartmentName.Text = reader[1].ToString();
                        txtPrefix.Text = reader[4].ToString();
                        txtDepartmentNameLocal.Text = reader[2].ToString();
                        txtRequiredManpower.Text = reader[5].ToString();
                        txtExtraRequiredManpower.Text = reader[6].ToString();
                        chkIsActive.Checked = reader[7] != DBNull.Value && Convert.ToBoolean(reader[7]); // ✅ CheckBox
                    }
                }
                else
                {
                    txtDepartmentID.Text = txtDepartmentName.Text = txtPrefix.Text = txtDepartmentNameLocal.Text = txtRequiredManpower.Text = txtExtraRequiredManpower.Text = string.Empty;
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

        protected void btnClear_Click(object sender, EventArgs e)
        {
            txtDepartmentID.Text = txtDepartmentName.Text = txtPrefix.Text = txtDepartmentNameLocal.Text = txtRequiredManpower.Text = txtExtraRequiredManpower.Text = string.Empty;
            chkIsActive.Checked = false;
        }
    }
}