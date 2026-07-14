using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.HRMPayroll.HRConfiguration.PayrollSetting
{
    public partial class CreateSalaryBreakdownPolicy : System.Web.UI.Page
    {
        SqlConnection con;
        PayrollDB conn = new PayrollDB();
        SqlCommand cmd;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string user = Request.QueryString["user"];
                LoadBrackdownRulls();
            }
        }
        private void LoadBrackdownRulls()
        {
            try
            {
                con = conn.openConnection();
                {
                    SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM Brackdown_Policy Order by Brackdown_Code asc", con);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    gvSalaryPolicy.DataSource = dt;
                    gvSalaryPolicy.DataBind();
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

        protected void btnRefresh_Click(object sender, EventArgs e)
        {

        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                // 1. Connection sudhu ekhane ekbar open hobe
                con = conn.openConnection();

                using (SqlCommand cmd = new SqlCommand("Pro_Brackdown_Policy", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    long categoryId = 0;
                    if (!string.IsNullOrEmpty(txtPolicyId.Text.Trim()))
                    {
                        long.TryParse(txtPolicyId.Text.Trim(), out categoryId);
                    }

                    cmd.Parameters.AddWithValue("@Brackdown_Code", categoryId);
                    cmd.Parameters.AddWithValue("@Brackdown_Name", string.IsNullOrEmpty(txtPolicyName.Text.Trim()) ? (object)DBNull.Value : txtPolicyName.Text.Trim());
                    cmd.Parameters.AddWithValue("@Brackdown_Type", Convert.ToInt32(ddlPolicyType.SelectedValue));
                    cmd.Parameters.AddWithValue("@Basic_Salary", string.IsNullOrEmpty(txtBasicPercent.Text.Trim()) ? (object)DBNull.Value : txtBasicPercent.Text.Trim());
                    cmd.Parameters.AddWithValue("@Hous_Rant", string.IsNullOrEmpty(txtHouseRentPercent.Text.Trim()) ? (object)DBNull.Value : txtHouseRentPercent.Text.Trim());
                    cmd.Parameters.AddWithValue("@Medical_Allowance", string.IsNullOrEmpty(txtMedicalPercent.Text.Trim()) ? (object)DBNull.Value : txtMedicalPercent.Text.Trim());
                    cmd.Parameters.AddWithValue("@Food_Allowance", string.IsNullOrEmpty(txtFoodAllowance.Text.Trim()) ? (object)DBNull.Value : txtFoodAllowance.Text.Trim());
                    cmd.Parameters.AddWithValue("@Transport_allowance", string.IsNullOrEmpty(txtConveyancePercent.Text.Trim()) ? (object)DBNull.Value : txtConveyancePercent.Text.Trim());
                    cmd.Parameters.AddWithValue("@IsActive", chkIsActive.Checked);

                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            string actionResult = rdr["Action"].ToString();
                            string newId = rdr["ResultCode"].ToString();

                            if (actionResult == "INSERTED")
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Salary Breakdown Policy Saved Successfully! New ID: " + newId + "');", true);

                            }
                            else if (actionResult == "UPDATED")
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Salary Breakdown Policy Updated Successfully!');", true);
                            }
                        }
                    }

                    clearform();
                    LoadBrackdownRulls();
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error: " + ex.Message.Replace("'", "\\'") + "');", true);
            }
            finally
            {
                // 2. Error hok ba na hok, connection jeno bondho hoy tai finally block-e close kora bhalo
                if (con != null && con.State == ConnectionState.Open)
                {
                    con.Close();
                }
            }

        }

        protected void gvSalaryPolicy_SelectedIndexChanged(object sender, EventArgs e)
        {
            txtPolicyId.Text = gvSalaryPolicy.SelectedRow.Cells[1].Text;
            try
            {
                string sql = "Select * from Brackdown_Policy where Brackdown_Code ='" + txtPolicyId.Text + "'";
                con = conn.openConnection();
                cmd = new SqlCommand(sql, con);
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        txtPolicyName.Text = reader[1].ToString();
                        ddlPolicyType.SelectedValue = reader[2].ToString();
                        txtBasicPercent.Text = reader[3].ToString();
                        txtHouseRentPercent.Text = reader[4].ToString();
                        txtMedicalPercent.Text = reader[5].ToString();
                        txtConveyancePercent.Text = reader[7].ToString();
                        txtFoodAllowance.Text = reader[6].ToString();
                        chkIsActive.Checked = reader[11] != DBNull.Value && Convert.ToBoolean(reader[11]); // ✅ CheckBox
                    }
                }
                else
                {
                    txtPolicyName.Text  = string.Empty;
                    ddlPolicyType.SelectedValue = "0";
                    txtBasicPercent.Text = "0";
                    txtHouseRentPercent.Text = "0";
                    txtMedicalPercent.Text = "0";
                    txtConveyancePercent.Text = "0";
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
            txtPolicyName.Text = string.Empty;
            ddlPolicyType.SelectedValue = "0";
            txtBasicPercent.Text = string.Empty;
            txtHouseRentPercent.Text = string.Empty;
            txtMedicalPercent.Text = string.Empty;
            txtConveyancePercent.Text = string.Empty;
            chkIsActive.Checked = true;
        }
    }
}