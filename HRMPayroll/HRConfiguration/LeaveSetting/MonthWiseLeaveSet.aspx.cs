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
    public partial class MonthWiseLeaveSet : System.Web.UI.Page
    {
        SqlConnection con;
        PayrollDB conn = new PayrollDB();
        SqlCommand cmd;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string user = Request.QueryString["user"];
                LoadddlLeave();
                LoadddlYear();
                LoadLeaveInformation();
            }
        }

        private void LoadddlLeave()
        {
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    string query = "SELECT Leave_code, Leave_Name FROM Leave_Name_List WHERE Is_Active = 1 ORDER BY Leave_Name ASC";
                    SqlDataAdapter da = new SqlDataAdapter(query, con);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlLeave.DataSource = dt;
                    ddlLeave.DataTextField = "Leave_Name";
                    ddlLeave.DataValueField = "Leave_code";
                    ddlLeave.DataBind();
                    ddlLeave.Items.Insert(0, new ListItem("--Select--", "0"));
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
        }

        private void LoadddlYear()
        {
            try
            {
                int currentYear = DateTime.Now.Year;
                for (int y = currentYear + 1; y >= currentYear - 1; y--)
                {
                    ddlYear.Items.Add(new ListItem(y.ToString(), y.ToString()));
                }
                ddlYear.SelectedValue = currentYear.ToString();
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
                string sql = @"SELECT la.Leave_code, la.LeaveYear, ln.Leave_Name,
                                      la.Jan, la.Feb, la.Mar, la.Apr, la.May, la.Jun,
                                      la.Jul, la.Aug, la.Sep, la.Oct, la.Nov, la.Dec
                               FROM LeaveAllocationMst la
                               LEFT JOIN Leave_Name_List ln ON la.Leave_code = ln.Leave_code
                               ORDER BY la.LeaveYear DESC, ln.Leave_Name ASC";
                SqlDataAdapter da = new SqlDataAdapter(sql, con);
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
            txtLeaveSetId.Text = string.Empty;
            ddlLeave.SelectedValue = "0";
            ddlYear.SelectedValue = DateTime.Now.Year.ToString();

            txtJanuary.Text = txtFebruary.Text = txtMarch.Text = txtApril.Text = txtMay.Text = txtJune.Text =
                txtJuly.Text = txtAugust.Text = txtSeptember.Text = txtOctober.Text = txtNovember.Text = txtDecember.Text = string.Empty;

            chkIsActive.Checked = false;
        }

        protected void GridView1_SelectedIndexChanged(object sender, EventArgs e)
        {
            string leaveCode = GridView1.SelectedRow.Cells[1].Text;
            string leaveYear = GridView1.SelectedRow.Cells[3].Text;

            txtLeaveSetId.Text = leaveCode;

            try
            {
                string sql = "SELECT * FROM LeaveAllocationMst WHERE Leave_code = @Leave_code AND LeaveYear = @LeaveYear";
                con = conn.openConnection();
                cmd = new SqlCommand(sql, con);
                cmd.Parameters.AddWithValue("@Leave_code", leaveCode);
                cmd.Parameters.AddWithValue("@LeaveYear", leaveYear);
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        ddlLeave.SelectedValue = reader["Leave_code"].ToString();
                        ddlYear.SelectedValue = reader["LeaveYear"].ToString();
                        txtJanuary.Text = reader["Jan"].ToString();
                        txtFebruary.Text = reader["Feb"].ToString();
                        txtMarch.Text = reader["Mar"].ToString();
                        txtApril.Text = reader["Apr"].ToString();
                        txtMay.Text = reader["May"].ToString();
                        txtJune.Text = reader["Jun"].ToString();
                        txtJuly.Text = reader["Jul"].ToString();
                        txtAugust.Text = reader["Aug"].ToString();
                        txtSeptember.Text = reader["Sep"].ToString();
                        txtOctober.Text = reader["Oct"].ToString();
                        txtNovember.Text = reader["Nov"].ToString();
                        txtDecember.Text = reader["Dec"].ToString();
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
            if (string.IsNullOrEmpty(ddlLeave.SelectedValue) || ddlLeave.SelectedValue == "0")
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Please select a Leave.');", true);
                return;
            }

            if (string.IsNullOrEmpty(ddlYear.SelectedValue))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Please select a Year.');", true);
                return;
            }

            using (SqlConnection con = conn.openConnection())
            {
                using (SqlCommand cmd = new SqlCommand("Pro_LeaveAllocationMonthWise_Web", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    int leaveCode = 0;
                    int.TryParse(ddlLeave.SelectedValue, out leaveCode);

                    int leaveYear = 0;
                    int.TryParse(ddlYear.SelectedValue, out leaveYear);

                    cmd.Parameters.AddWithValue("@Leave_code", leaveCode);
                    cmd.Parameters.AddWithValue("@LeaveYear", leaveYear);
                    cmd.Parameters.AddWithValue("@Jan", ParseFloat(txtJanuary.Text));
                    cmd.Parameters.AddWithValue("@Feb", ParseFloat(txtFebruary.Text));
                    cmd.Parameters.AddWithValue("@Mar", ParseFloat(txtMarch.Text));
                    cmd.Parameters.AddWithValue("@Apr", ParseFloat(txtApril.Text));
                    cmd.Parameters.AddWithValue("@May", ParseFloat(txtMay.Text));
                    cmd.Parameters.AddWithValue("@Jun", ParseFloat(txtJune.Text));
                    cmd.Parameters.AddWithValue("@Jul", ParseFloat(txtJuly.Text));
                    cmd.Parameters.AddWithValue("@Aug", ParseFloat(txtAugust.Text));
                    cmd.Parameters.AddWithValue("@Sep", ParseFloat(txtSeptember.Text));
                    cmd.Parameters.AddWithValue("@Oct", ParseFloat(txtOctober.Text));
                    cmd.Parameters.AddWithValue("@Nov", ParseFloat(txtNovember.Text));
                    cmd.Parameters.AddWithValue("@Dec", ParseFloat(txtDecember.Text));

                    try
                    {
                        cmd.ExecuteNonQuery();
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Month Wise Leave Set Saved Successfully!');", true);
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

        private float ParseFloat(string value)
        {
            float result = 0;
            if (!string.IsNullOrEmpty(value))
            {
                float.TryParse(value.Trim(), out result);
            }
            return result;
        }
    }
}