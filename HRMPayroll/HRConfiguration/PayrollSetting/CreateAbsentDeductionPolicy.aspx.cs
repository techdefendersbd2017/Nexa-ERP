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
    public partial class CreateAbsentDeductionPolicy : System.Web.UI.Page
    {
        SqlConnection con;
        PayrollDB conn = new PayrollDB();
        SqlCommand cmd;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string user = Request.QueryString["user"];
                LoadPolicyGrid();
            }
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            ClearForm();
        }
        private void ClearForm()
        {
            hfPolicyId.Value = string.Empty;
            txtPolicyId.Text = string.Empty;
            txtPolicyName.Text = string.Empty;
            txtDeductionValue.Text = "0.00"; // বা ফাকা রাখতে পারেন string.Empty
            txtFormula.Text = string.Empty;
            if (ddlDeductionType.Items.Count > 0)
            {
                ddlDeductionType.SelectedIndex = 0;
            }
            chkIsActive.Checked = true;
            txtFormula.Enabled = false;
            LoadPolicyGrid();
        }
        private void LoadPolicyGrid()
        {
            // আপনার কানেকশন স্ট্রিং ক্লাস অনুযায়ী con অবজেক্ট নিন
            SqlConnection con = conn.openConnection();

            // শুধুমাত্র ID এবং Name তুলে আনার জন্য SQL Query
            string query = "SELECT Absent_Policy_Code, Absent_Policy_Name FROM tbl_AbsentDeductionPolicy ORDER BY Absent_Policy_Code DESC";

            try
            {
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        // গ্রিডভিউতে ডাটা সোর্স সেট করে বাইন্ড করা
                        gvPolicies.DataSource = dt;
                        gvPolicies.DataBind();
                    }
                }
            }
            catch (Exception ex)
            {
                string cleanMessage = ex.Message.Replace("'", "\\'").Replace("\r", "").Replace("\n", " ");
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Grid Load Error: " + cleanMessage + "');", true);
            }
            finally
            {
                if (con != null && con.State != ConnectionState.Closed)
                {
                    con.Close();
                }
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                con = conn.openConnection();
                using (SqlCommand cmd = new SqlCommand("sp_AbsentDeductionPolicy", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    int policyId = 0;
                    if (!string.IsNullOrEmpty(hfPolicyId.Value))
                    {
                        int.TryParse(hfPolicyId.Value, out policyId);
                    }
                    cmd.Parameters.AddWithValue("@AbsentPolicyCode", policyId == 0 ? (object)DBNull.Value : policyId);
                    cmd.Parameters.AddWithValue("@AbsentPolicyName", txtPolicyName.Text.Trim());
                    cmd.Parameters.AddWithValue("@DeductionType", Convert.ToInt32(ddlDeductionType.SelectedValue));
                    decimal deductionValue = 0;
                    decimal.TryParse(txtDeductionValue.Text.Trim(), out deductionValue);
                    cmd.Parameters.AddWithValue("@DeductionValue", deductionValue);
                    cmd.Parameters.AddWithValue("@SalaryFormula", ddlDeductionType.SelectedValue == "4" ? (object)txtFormula.Text.Trim() : DBNull.Value);
                    cmd.Parameters.AddWithValue("@IsActive", chkIsActive.Checked);
                    cmd.Parameters.AddWithValue("@UserId", Session["UserId"] ?? (object)DBNull.Value);
                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            string actionResult = rdr["OperationStatus"].ToString(); // Matches column name from SP
                            string newId = rdr["NewPolicyCode"].ToString();        // Matches column name from SP

                            if (actionResult == "INSERTED")
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Policy Saved Successfully! New ID: " + newId + "');", true);
                            }
                            else if (actionResult == "UPDATED")
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Policy Updated Successfully!');", true);
                            }
                        }
                    }

                    LoadPolicyGrid();
                }
            }
            catch (Exception ex)
            {
                string cleanMessage = ex.Message.Replace("'", "\\'").Replace("\r", "").Replace("\n", " ");
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error: " + cleanMessage + "');", true);
            }
            finally
            {
                if (con != null && con.State != ConnectionState.Closed)
                {
                    con.Close();
                }
            }
        }

        protected void gvAbsentPolicy_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

        protected void ddlDeductionType_SelectedIndexChanged(object sender, EventArgs e)
        {
            // যদি Formula Driven (Value = 4) সিলেক্ট করা হয়
            if (ddlDeductionType.SelectedValue == "4")
            {
                divFormula.Visible = true;       // ফর্মুলা ইনপুট বক্স দেখাবে
                txtDeductionValue.Enabled = false; // রেট বা ফিক্সড ভ্যালুর বক্সটি বন্ধ হয়ে যাবে
                txtDeductionValue.Text = "0.00";
            }
            else
            {
                divFormula.Visible = false;      // ফর্মুলা বক্স লুকিয়ে ফেলবে
                txtDeductionValue.Enabled = true;  // সাধারণ রেট বক্স চালু হবে
                txtFormula.Text = "";
            }
        }

        protected void gvPolicies_SelectedIndexChanged(object sender, EventArgs e)
        {
            // ১. গ্রিডভিউ থেকে সিলেক্টেড রো এবং পলিসি আইডি বের করা
            GridViewRow row = gvPolicies.SelectedRow;
            string policyId = gvPolicies.DataKeys[row.RowIndex].Value.ToString();
            txtPolicyId.Text = policyId;

            // ২. ডাটাবেজ থেকে এই ID-র সব তথ্য তুলে আনার ব্যবস্থা
            SqlConnection con = conn.openConnection();
            string query = "SELECT Absent_Policy_Code, Absent_Policy_Name, DeductionType, DeductionValue, SalaryFormula, IsActive FROM tbl_AbsentDeductionPolicy WHERE Absent_Policy_Code = @AbsentPolicyCode";

            try
            {
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@AbsentPolicyCode", Convert.ToInt32(policyId));

                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            hfPolicyId.Value = rdr["Absent_Policy_Code"].ToString();
                            txtPolicyName.Text = rdr["Absent_Policy_Name"].ToString();
                            ddlDeductionType.SelectedValue = rdr["DeductionType"].ToString();
                            txtDeductionValue.Text = rdr["DeductionValue"].ToString();
                            txtFormula.Text = rdr["SalaryFormula"] != DBNull.Value ? rdr["SalaryFormula"].ToString() : "";
                            chkIsActive.Checked = Convert.ToBoolean(rdr["IsActive"]);
                            if (ddlDeductionType.SelectedValue == "4")
                            {
                                txtFormula.Enabled = true; 
                            }
                            else
                            {
                                txtFormula.Enabled = false;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                string cleanMessage = ex.Message.Replace("'", "\\'").Replace("\r", "").Replace("\n", " ");
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Data Load Error: " + cleanMessage + "');", true);
            }
            finally
            {
                if (con != null && con.State != ConnectionState.Closed)
                {
                    con.Close();
                }
            }

            // যদি Formula Driven (Value = 4) সিলেক্ট করা হয়
            if (ddlDeductionType.SelectedValue == "4")
            {
                divFormula.Visible = true;       // ফর্মুলা ইনপুট বক্স দেখাবে
                txtDeductionValue.Enabled = false; // রেট বা ফিক্সড ভ্যালুর বক্সটি বন্ধ হয়ে যাবে
                txtDeductionValue.Text = "0.00";
            }
            else
            {
                divFormula.Visible = false;      // ফর্মুলা বক্স লুকিয়ে ফেলবে
                txtDeductionValue.Enabled = true;  // সাধারণ রেট বক্স চালু হবে
                txtFormula.Text = "";
            }
        }
    }
}