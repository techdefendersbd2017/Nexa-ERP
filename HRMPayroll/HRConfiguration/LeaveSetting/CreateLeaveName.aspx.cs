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

namespace Nexa_ERP.HRMPayroll.HRConfiguration.LeaveSetting
{
    public partial class CreateLeaveName : System.Web.UI.Page
    {
        SqlConnection con;
        PayrollDB conn = new PayrollDB();
        SqlCommand cmd;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string user = Request.QueryString["user"];
                LoadLeaveInformation();
                LoadddlSex();
            }
        }

        private void LoadddlSex()
        {
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    string query = "SELECT * FROM Gender ORDER BY Gender_Name ASC";
                    SqlDataAdapter da = new SqlDataAdapter(query, con);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlSex.DataSource = dt;
                    ddlSex.DataTextField = "Gender_Name";
                    ddlSex.DataValueField = "Gender_Code";
                    ddlSex.DataBind();
                    ddlSex.Items.Insert(0, new ListItem("--Select--", "0"));
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
        }

        private void LoadLeaveInformation()
        {
            try
            {
                con = conn.openConnection();
                SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM Leave_Name_List ORDER BY Leave_Name ASC", con);
                DataTable dt = new DataTable();
                da.Fill(dt);
                GridView1.DataSource = dt;
                GridView1.DataBind();
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
            txtLeaveId.Text = txtLeaveNameEnglish.Text = txtLeaveNameBangla.Text = txtLeaveNameShort.Text = txtTotalLeaveDays.Text = string.Empty;
            ddlSex.SelectedValue = "0";
            chkIsActive.Checked = false;
        }

        protected void GridView1_SelectedIndexChanged(object sender, EventArgs e)
        {
            txtLeaveId.Text = GridView1.SelectedRow.Cells[1].Text;
            try
            {
                string sql = "SELECT * FROM Leave_Name_List WHERE Leave_code = '" + txtLeaveId.Text + "'";
                con = conn.openConnection();
                cmd = new SqlCommand(sql, con);
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        txtLeaveNameEnglish.Text = reader["Leave_Name"].ToString();
                        txtLeaveNameShort.Text = reader["Short_Name"].ToString();
                        txtTotalLeaveDays.Text = reader["Leave_Days"].ToString();
                        ddlSex.SelectedValue = reader["Sex_Type"].ToString();
                        txtLeaveNameBangla.Text = reader["Leave_Name_Bangla"].ToString();
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
            using (SqlConnection con = conn.openConnection())
            {
                using (SqlCommand cmd = new SqlCommand("Pro_Leave_Name_List_Web", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    long leaveId = 0;
                    if (!string.IsNullOrEmpty(txtLeaveId.Text.Trim()))
                    {
                        long.TryParse(txtLeaveId.Text.Trim(), out leaveId);
                    }

                    long days = 0;
                    long.TryParse(txtTotalLeaveDays.Text.Trim(), out days);

                    cmd.Parameters.AddWithValue("@Leave_Code", leaveId);
                    cmd.Parameters.AddWithValue("@Leave_Name", string.IsNullOrEmpty(txtLeaveNameEnglish.Text.Trim()) ? (object)DBNull.Value : txtLeaveNameEnglish.Text.Trim());
                    cmd.Parameters.AddWithValue("@Short_Name", string.IsNullOrEmpty(txtLeaveNameShort.Text.Trim()) ? (object)DBNull.Value : txtLeaveNameShort.Text.Trim());
                    cmd.Parameters.AddWithValue("@Days", days);
                    cmd.Parameters.AddWithValue("@Sex", ddlSex.SelectedValue);
                    string banglaName = txtLeaveNameBangla.Text.Trim();
                    cmd.Parameters.Add("@bangla_Name", SqlDbType.NVarChar, 500).Value = string.IsNullOrEmpty(banglaName) ? (object)DBNull.Value : banglaName;
                    cmd.Parameters.AddWithValue("@Is_Active", chkIsActive.Checked);

                    try
                    {
                        cmd.ExecuteNonQuery();
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Leave Name Saved Successfully!');", true);
                        clearform();
                    }
                    catch (Exception ex)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error: " + ex.Message.Replace("'", "\\'") + "');", true);
                    }
                }
            }
            LoadLeaveInformation();
        }
    }
}