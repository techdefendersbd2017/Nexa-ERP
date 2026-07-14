using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.HRMPayroll.HRConfiguration.HRMSetting
{
    public partial class CreateBranchPolicy : System.Web.UI.Page
    {
        SqlConnection con;
        PayrollDB conn = new PayrollDB();
        SqlCommand cmd;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string user = Request.QueryString["user"];
                hfUserId.Value = "1";
                LoadBranch();// ব্রাঞ্চ ড্রপডাউন লোড করবে
                LoadPolicyGrid();     // পলিসি লিস্ট গ্রিডভিউ লোড করবে
                ClearForm();
            }
        }
        private void LoadPolicyGrid()
        {
            using (SqlConnection con = conn.openConnection())
            {
                using (SqlCommand cmd = new SqlCommand("sp_Attendance_Overtime_Policy_GetAll", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        try
                        {
                            da.Fill(dt);
                            gvBranchPolicy.DataSource = dt;
                            gvBranchPolicy.DataBind();
                        }
                        catch (Exception ex)
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
                        }
                    }
                }
            }
        }
        private void LoadBranch()
        {
            Database_Connection conn = new Database_Connection();
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    string query = "SELECT * FROM Branch_Information order By Branch_Name asc";
                    SqlDataAdapter da = new SqlDataAdapter(query, con);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlBranch.DataSource = dt;
                    ddlBranch.DataTextField = "Branch_Name";
                    ddlBranch.DataValueField = "Branch_ID";
                    ddlBranch.DataBind();
                    ddlBranch.Items.Insert(0, new ListItem("--Select--", "0"));
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

        protected void btnSave_Click(object sender, EventArgs e)
        {
            using (SqlConnection con = conn.openConnection())
            {
                using (SqlCommand cmd = new SqlCommand("sp_Attendance_Overtime_Policy_SaveOrUpdate", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    // প্রসিডিউর প্যারামিটার অ্যাসাইনমেন্ট
                    cmd.Parameters.AddWithValue("@PolicyID", string.IsNullOrEmpty(txtPolicyId.Text) ? (object)DBNull.Value : txtPolicyId.Text.Trim());
                    cmd.Parameters.AddWithValue("@Branch_ID", Convert.ToInt32(ddlBranch.SelectedValue));
                    cmd.Parameters.AddWithValue("@OtCalculationType", Convert.ToByte(DropDownList2.SelectedValue));

                    cmd.Parameters.AddWithValue("@OriginalOtStart", string.IsNullOrEmpty(txtOtDeductionOrg.Text) ? (object)DBNull.Value : txtOtDeductionOrg.Text.Trim());
                    cmd.Parameters.AddWithValue("@ComplianceOtStart", string.IsNullOrEmpty(TextBox1.Text) ? (object)DBNull.Value : TextBox1.Text.Trim());
                    cmd.Parameters.AddWithValue("@ExtraOtStart", string.IsNullOrEmpty(txtOtStart.Text) ? (object)DBNull.Value : txtOtStart.Text.Trim());
                    cmd.Parameters.AddWithValue("@OutTimeStart", string.IsNullOrEmpty(txtOutTimeStart.Text) ? (object)DBNull.Value : txtOutTimeStart.Text.Trim());
                    cmd.Parameters.AddWithValue("@EarlyOutGraceTime", string.IsNullOrEmpty(txtEarlyDeductStart.Text) ? (object)DBNull.Value : txtEarlyDeductStart.Text.Trim());

                    cmd.Parameters.AddWithValue("@IsActive", chkIsActive.Checked);
                    cmd.Parameters.AddWithValue("@UserId", Convert.ToInt32(hfUserId.Value));

                    try
                    {
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                string responseMessage = reader["ResponseMessage"].ToString();
                                string targetId = reader["TargetID"].ToString();

                                if (responseMessage == "SUCCESS_INSERT")
                                {
                                    ShowAlert("success", "Policy configuration saved successfully!");
                                    ClearForm();
                                    LoadPolicyGrid();
                                }
                                else if (responseMessage == "SUCCESS_UPDATE")
                                {
                                    ShowAlert("success", "Policy configuration updated successfully!");
                                    ClearForm();
                                    LoadPolicyGrid();
                                }
                                else if (responseMessage == "ERR_DUPLICATE_BRANCH")
                                {
                                    ShowAlert("warning", "A configuration policy already exists for this branch.");
                                }
                                else
                                {
                                    ShowAlert("danger", "Database Response: " + responseMessage);
                                }
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        ShowAlert("danger", "Execution Error: " + ex.Message);
                    }
                }
                con.Close();
            }
        }


        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            ClearForm();
        }

        protected void gvBranchPolicy_SelectedIndexChanged(object sender, EventArgs e)
        {
            txtPolicyId.Text = gvBranchPolicy.SelectedRow.Cells[1].Text;

            try
            {
                string sql = "Select * from Attendance_Overtime_Policy where PolicyID ='" + txtPolicyId.Text + "'";

                con = conn.openConnection();
                cmd = new SqlCommand(sql, con);
                SqlDataReader reader = cmd.ExecuteReader();

                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        ddlBranch.SelectedValue = reader[1].ToString();
                        DropDownList2.SelectedValue = reader[2].ToString();
                        txtOtDeductionOrg.Text = reader[3].ToString();
                        TextBox1.Text = reader[4].ToString();
                        txtOtStart.Text = reader[5].ToString();
                        txtOutTimeStart.Text = reader[6].ToString();
                        txtEarlyDeductStart.Text = reader[7].ToString();
                        chkIsActive.Checked = reader[8] != DBNull.Value && Convert.ToBoolean(reader[8]);
                    }
                }
                else
                {
                    //txtSubSectionId.Text = txtLineName.Text = txtBanglaName.Text = txtPrefix.Text = txtRequiredManpower.Text = txtExtraRequiredManpower.Text = txtBanglaName.Text = string.Empty;
                    chkIsActive.Checked = false;
                }

                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
        }


        private void LoadPolicyDetailsByBranch(int branchId)
        {
            string query = "SELECT * FROM Attendance_Overtime_Policy WHERE Branch_ID = @Branch_ID";
            using (SqlConnection con = conn.openConnection())
            {
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@Branch_ID", branchId);
                    try
                    {
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                txtPolicyId.Text = reader["PolicyID"].ToString();
                                ddlBranch.SelectedValue = reader["Branch_ID"].ToString();
                                DropDownList2.SelectedValue = reader["OtCalculationType"].ToString();

                                txtOtDeductionOrg.Text = reader["OriginalOtStart"].ToString();
                                TextBox1.Text = reader["ComplianceOtStart"].ToString();
                                txtOtStart.Text = reader["ExtraOtStart"].ToString();
                                txtOutTimeStart.Text = reader["OutTimeStart"].ToString();
                                txtEarlyDeductStart.Text = reader["EarlyOutGraceTime"].ToString();

                                chkIsActive.Checked = Convert.ToBoolean(reader["IsActive"]);

                                // এডিট মোডে Save বাটন অফ করে Update বাটন অন করতে পারেন
                                btnSave.Enabled = false;
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        ShowAlert("danger", "Load Details Error: " + ex.Message);
                    }
                }
            }
            con.Close();
        }

        private bool ValidateForm()
        {
            if (ddlBranch.SelectedValue == "0")
            {
                ShowAlert("warning", "Please select a specific Branch.");
                return false;
            }
            if (DropDownList2.SelectedValue == "0")
            {
                ShowAlert("warning", "Please select an OT Calculation Type.");
                return false;
            }
            return true;
        }

        private void ClearForm()
        {
            txtPolicyId.Text = string.Empty;
            ddlBranch.SelectedIndex = 0;
            DropDownList2.SelectedIndex = 0;
            txtOtDeductionOrg.Text = string.Empty;
            TextBox1.Text = string.Empty;
            txtOtStart.Text = string.Empty;
            txtOutTimeStart.Text = string.Empty;
            txtEarlyDeductStart.Text = string.Empty;
            chkIsActive.Checked = true;

            btnSave.Enabled = true;
        }

        private void ShowAlert(string type, string message)
        {
            // JavaScript Alert বা Toastr এর মাধ্যমে স্ক্রিনে মেসেজ দেখানোর মেকানিজম
            string script = $"alert('{message.Replace("'", "\\'")}');";
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alertScript", script, true);
        }


    }
}