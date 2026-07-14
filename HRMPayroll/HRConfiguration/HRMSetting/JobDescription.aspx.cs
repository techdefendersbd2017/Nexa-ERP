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
    public partial class JobDescription : System.Web.UI.Page
    {
        SqlConnection con;
        PayrollDB conn = new PayrollDB();
        SqlCommand cmd;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindJobDescriptionGrid();
                ClearForm();
                LoadDesignation();
                LoadddlReportTo1();
                LoadddlReportTo2();
            }
        }

        private void LoadDesignation()
        {
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    string query = "SELECT * FROM TB_Designation order By Desigation_name asc";
                    SqlDataAdapter da = new SqlDataAdapter(query, con);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlDesignation.DataSource = dt;
                    ddlDesignation.DataTextField = "Desigation_name";
                    ddlDesignation.DataValueField = "Designation_Code";
                    ddlDesignation.DataBind();
                    ddlDesignation.Items.Insert(0, new ListItem("--Select--", "0"));
                } // এখানে con অটোমেটিক ক্লোজ হয়ে যাবে
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
        }

        private void LoadddlReportTo1()
        {
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    string query = "SELECT * FROM TB_Designation order By Desigation_name asc";
                    SqlDataAdapter da = new SqlDataAdapter(query, con);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlReportTo1.DataSource = dt;
                    ddlReportTo1.DataTextField = "Desigation_name";
                    ddlReportTo1.DataValueField = "Designation_Code";
                    ddlReportTo1.DataBind();
                    ddlReportTo1.Items.Insert(0, new ListItem("--Select--", "0"));
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
        }

        private void LoadddlReportTo2()
        {
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    string query = "SELECT * FROM TB_Designation order By Desigation_name asc";
                    SqlDataAdapter da = new SqlDataAdapter(query, con);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlReportTo2.DataSource = dt;
                    ddlReportTo2.DataTextField = "Desigation_name";
                    ddlReportTo2.DataValueField = "Designation_Code";
                    ddlReportTo2.DataBind();
                    ddlReportTo2.Items.Insert(0, new ListItem("--Select--", "0"));
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
        }

        private void BindJobDescriptionGrid()
        {
            string query = @"SELECT HRM_JobDescription.JobDescription_ID, dbo.TB_Designation.Designation_Code, dbo.TB_Designation.Desigation_name, HRM_JobDescription.IsActive
                    FROM HRM_JobDescription INNER JOIN dbo.TB_Designation ON HRM_JobDescription.Designation_ID = dbo.TB_Designation.Designation_Code";

            con = conn.openConnection();
            {
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        gvJobDescription.DataSource = dt;
                        gvJobDescription.DataBind();
                    }
                }
            }
        }


        protected void gvJobDescription_SelectedIndexChanged(object sender, EventArgs e)
        {
            txtJobDescriptionId.Text = gvJobDescription.SelectedRow.Cells[1].Text;
            try
            {
                string sql = "SELECT * FROM HRM_JobDescription WHERE JobDescription_ID ='" + txtJobDescriptionId.Text + "'";
                con = conn.openConnection();
                cmd = new SqlCommand(sql, con);
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        ddlDesignation.SelectedValue = reader[1].ToString();
                        ddlReportTo1.SelectedValue = reader[2].ToString();
                        ddlReportTo2.SelectedValue = reader[3].ToString();
                        txtPurposeTheWork.Text = reader[4].ToString();
                        txtResponsibilities.Text = reader[5].ToString();
                        chkIsActive.Checked = Convert.ToBoolean(reader[6]);
                    }
                }
                else
                {
                    ddlReportTo1.SelectedValue = ddlReportTo2.SelectedValue = "0";
                    txtPurposeTheWork.Text = txtResponsibilities.Text  = string.Empty;
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

        private void SaveOrUpdateData(int id)
        {
            if (ddlDesignation.SelectedIndex <= 0)
            {
                ShowAlert("Please select a valid Designation.");
                return;
            }

            int userId = 1;
            if (!string.IsNullOrEmpty(hfUserId.Value))
            {
                int.TryParse(hfUserId.Value, out userId);
            }

            con = conn.openConnection();
            {
                using (SqlCommand cmd = new SqlCommand("sp_HRM_JobDescription_SaveAndUpdate", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    // প্রসিডিউরের প্যারামিটারসমূহ অ্যাসাইন করা হচ্ছে
                    cmd.Parameters.AddWithValue("@JobDescription_ID", id);
                    cmd.Parameters.AddWithValue("@Designation_ID", Convert.ToInt32(ddlDesignation.SelectedValue));

                    // ড্রপডাউন যদি Nullable হয় তবে DBNull চেক
                    cmd.Parameters.AddWithValue("@ReportTo_1_ID", ddlReportTo1.SelectedIndex > 0 ? (object)Convert.ToInt32(ddlReportTo1.SelectedValue) : DBNull.Value);
                    cmd.Parameters.AddWithValue("@ReportTo_2_ID", ddlReportTo2.SelectedIndex > 0 ? (object)Convert.ToInt32(ddlReportTo2.SelectedValue) : DBNull.Value);

                    cmd.Parameters.AddWithValue("@PurposeOfTheWork", string.IsNullOrEmpty(txtPurposeTheWork.Text.Trim()) ? (object)DBNull.Value : txtPurposeTheWork.Text.Trim());
                    cmd.Parameters.AddWithValue("@Responsibilities", string.IsNullOrEmpty(txtResponsibilities.Text.Trim()) ? (object)DBNull.Value : txtResponsibilities.Text.Trim());
                    cmd.Parameters.AddWithValue("@IsActive", chkIsActive.Checked);
                    cmd.Parameters.AddWithValue("@UserId", userId);

                    try
                    {
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                int statusCode = Convert.ToInt32(reader["StatusCode"]);
                                string statusMessage = reader["StatusMessage"].ToString();

                                if (statusCode > 0)
                                {
                                    ShowAlert(statusMessage);
                                    ClearForm();
                                }
                                else
                                {
                                    ShowAlert("Error: " + statusMessage);
                                }
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        ShowAlert("System Error: " + ex.Message);
                    }
                }
            }
        }

        // ফর্ম ক্লিয়ার করার মেথড
        private void ClearForm()
        {
            txtJobDescriptionId.Text = string.Empty;
            if (ddlDesignation.Items.Count > 0) ddlDesignation.SelectedIndex = 0;
            if (ddlReportTo1.Items.Count > 0) ddlReportTo1.SelectedIndex = 0;
            if (ddlReportTo2.Items.Count > 0) ddlReportTo2.SelectedIndex = 0;
            txtPurposeTheWork.Text = string.Empty;
            txtResponsibilities.Text = string.Empty;
            chkIsActive.Checked = true; 
        }

        // জাভাস্ক্রিপ্ট অ্যালার্ট নোটিফিকেশন মেthড
        private void ShowAlert(string message)
        {
            string script = $"alert('{message.Replace("'", "\\'")}');";
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ServerMessage", script, true);
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            // নতুন রেকর্ডের জন্য ID পাস হবে 0
            SaveOrUpdateData(0);
        }

        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            // আইডি টেক্সটবক্স ফাঁকা না থাকলে সেটি পার্স করবে, অন্যথায় 0
            int jobDescriptionId = 0;
            if (!string.IsNullOrEmpty(txtJobDescriptionId.Text))
            {
                int.TryParse(txtJobDescriptionId.Text, out jobDescriptionId);
            }

            if (jobDescriptionId > 0)
            {
                SaveOrUpdateData(jobDescriptionId);
            }
            else
            {
                ShowAlert("Please select a record from the list to update.");
            }
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            ClearForm();
        }
    }
}