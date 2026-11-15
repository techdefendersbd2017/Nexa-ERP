using Nexa_ERP.Connection;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.HRMPayroll.HRConfiguration.PayrollSetting
{
    public partial class SalaryAdvancePolicy : System.Web.UI.Page
    {
        PayrollDB conn = new PayrollDB();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadCategory();
                LoadPaymentType();
                SetDefaultDates();
                LoadPolicyGrid();
            }
        }

        // ================= Helpers =================
        private void Alert(string msg)
        {
            string clean = msg.Replace("'", "\\'").Replace("\r", "").Replace("\n", " ");
            ScriptManager.RegisterStartupScript(this, GetType(), Guid.NewGuid().ToString(), "alert('" + clean + "');", true);
        }

        private void SetDefaultDates()
        {
            string today = DateTime.Today.ToString("yyyy-MM-dd");
            txtPolicyMonth.Text = today;
            txtPayFrom.Text = today;
            txtPayTill.Text = today;
        }

        // TextMode=Date (yyyy-MM-dd) -> dd-MMM-yyyy (পুরাতন সফটওয়্যারের মতো)
        private string FormatDate(string value)
        {
            DateTime dt;
            if (DateTime.TryParse(value, CultureInfo.InvariantCulture, DateTimeStyles.None, out dt))
                return dt.ToString("dd-MMM-yyyy", CultureInfo.InvariantCulture);
            return DateTime.Today.ToString("dd-MMM-yyyy", CultureInfo.InvariantCulture);
        }

        private string ToInputDate(object dbValue)
        {
            DateTime dt;
            if (DateTime.TryParse(Convert.ToString(dbValue), out dt))
                return dt.ToString("yyyy-MM-dd");
            return DateTime.Today.ToString("yyyy-MM-dd");
        }

        private void SetSelected(DropDownList ddl, string value)
        {
            ddl.ClearSelection();
            ListItem item = ddl.Items.FindByValue(value);
            if (item == null) item = ddl.Items.FindByText(value);
            if (item != null) item.Selected = true;
            else if (ddl.Items.Count > 0) ddl.SelectedIndex = 0;
        }

        private void ApplyPolicyTypeState()
        {
            // Formula / Select হলে Value read-only এবং 0
            bool locked = ddlPolicyType.SelectedValue == "Formula" || ddlPolicyType.SelectedValue == "Select";
            txtPolicyValue.ReadOnly = locked;
            if (locked) txtPolicyValue.Text = "0";
        }

        // ================= Dropdown load =================
        private void LoadCategory()
        {
            BindDropDown(ddlCategory, "SELECT Catagory_Code, Catagory_Name FROM TB_Catagory", "Catagory_Name", "Catagory_Code");
        }

        private void LoadPaymentType()
        {
            BindDropDown(ddlPaymentType, "SELECT Deduct_Code, Deduct_Name FROM Deduction_Catagory WHERE Deduct_Code IN (2,3,4,5)", "Deduct_Name", "Deduct_Code");
        }

        private void BindDropDown(DropDownList ddl, string query, string textField, string valueField)
        {
            SqlConnection con = conn.openConnection();
            try
            {
                using (SqlDataAdapter da = new SqlDataAdapter(query, con))
                {
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    ddl.DataTextField = textField;
                    ddl.DataValueField = valueField;
                    ddl.DataSource = dt;
                    ddl.DataBind();
                    ddl.Items.Insert(0, new ListItem("Select", ""));
                }
            }
            catch (Exception ex) { Alert("Dropdown Load Error: " + ex.Message); }
            finally { if (con != null && con.State != ConnectionState.Closed) con.Close(); }
        }

        // ================= Grid =================
        private void LoadPolicyGrid()
        {
            SqlConnection con = conn.openConnection();
            try
            {
                string query = "SELECT * FROM View_Advance_Salary_policy ORDER BY Policy_Month DESC";
                using (SqlDataAdapter da = new SqlDataAdapter(query, con))
                {
                    DataTable src = new DataTable();
                    da.Fill(src);

                    // View-এর প্রথম ৩টি কলাম: Policy Code, Emp. Category, Policy Name
                    DataTable dt = new DataTable();
                    dt.Columns.Add("Policy_Code");
                    dt.Columns.Add("Emp_Category");
                    dt.Columns.Add("Policy_Name");
                    foreach (DataRow r in src.Rows)
                        dt.Rows.Add(r[0].ToString(), r[1].ToString(), r[2].ToString());

                    gvPolicies.DataSource = dt;
                    gvPolicies.DataBind();
                }
            }
            catch (Exception ex) { Alert("Grid Load Error: " + ex.Message); }
            finally { if (con != null && con.State != ConnectionState.Closed) con.Close(); }
        }

        protected void gvPolicies_SelectedIndexChanged(object sender, EventArgs e)
        {
            string policyId = gvPolicies.DataKeys[gvPolicies.SelectedRow.RowIndex].Value.ToString();
            txtPolicyId.Text = policyId;

            SqlConnection con = conn.openConnection();
            try
            {
                using (SqlCommand cmd = new SqlCommand("SELECT * FROM Advance_Salary_Policy WHERE Policy_ID = @Policy_ID", con))
                {
                    cmd.Parameters.AddWithValue("@Policy_ID", policyId);
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            txtPolicyName.Text = r[1].ToString();
                            SetSelected(ddlCategory, r[2].ToString());
                            SetSelected(ddlPolicyType, r[3].ToString());
                            txtPolicyValue.Text = r[4].ToString();
                            SetSelected(ddlPaymentType, r[5].ToString());
                            SetSelected(ddlAbsentDed, r[6].ToString());
                            SetSelected(ddlPaymentFrom, r[7].ToString());
                            SetSelected(ddlOtPay, r[8].ToString());
                            SetSelected(ddlNightTifin, r[9].ToString());
                            SetSelected(ddlAttBonus, r[10].ToString());
                            SetSelected(ddlRounding, r[11].ToString());
                            SetSelected(ddlPayType, r[12].ToString());
                            txtSheetHeader.Text = r[13].ToString();
                            txtPolicyMonth.Text = ToInputDate(r[14]);
                            txtPayFrom.Text = ToInputDate(r[15]);
                            txtPayTill.Text = ToInputDate(r[16]);
                        }
                    }
                }
                ApplyPolicyTypeState();
            }
            catch (Exception ex) { Alert("Data Load Error: " + ex.Message); }
            finally { if (con != null && con.State != ConnectionState.Closed) con.Close(); }
        }

        // ================= Events =================
        protected void ddlPolicyType_SelectedIndexChanged(object sender, EventArgs e)
        {
            ApplyPolicyTypeState();
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            ClearForm();
        }

        private void ClearForm()
        {
            txtPolicyId.Text = string.Empty;
            txtPolicyName.Text = string.Empty;
            txtSheetHeader.Text = string.Empty;
            txtPolicyValue.Text = "0";
            foreach (DropDownList d in new[] { ddlCategory, ddlPolicyType, ddlPaymentType, ddlAbsentDed, ddlPaymentFrom,
                                               ddlOtPay, ddlNightTifin, ddlAttBonus, ddlRounding, ddlPayType })
                d.SelectedIndex = 0;
            ApplyPolicyTypeState();
            SetDefaultDates();
            LoadPolicyGrid();
        }

        protected void btnAdd_Click(object sender, EventArgs e)
        {
            if (!string.IsNullOrWhiteSpace(txtPolicyId.Text))
            {
                Alert("Not Possible To Add. Already exists this data in the database.");
                return;
            }
            if (!Validate()) return;
            Save("Pro_Advance_Policy_Add");
        }

        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtPolicyId.Text))
            {
                Alert("Not Possible To Update. This Data Not Exists In The Database.");
                return;
            }
            if (!Validate()) return;
            Save("Pro_Advance_Policy_Update");
        }

        private bool Validate()
        {
            if (string.IsNullOrWhiteSpace(txtPolicyName.Text)) { Alert("Policy Name is required."); return false; }
            if (string.IsNullOrEmpty(ddlCategory.SelectedValue)) { Alert("Please select Employee Category."); return false; }
            if (string.IsNullOrEmpty(ddlPaymentType.SelectedValue)) { Alert("Please select Payment Type."); return false; }
            return true;
        }

        private void Save(string procName)
        {
            SqlConnection con = null;
            try
            {
                con = conn.openConnection();
                using (SqlCommand cmd = new SqlCommand(procName, con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Policy_ID", txtPolicyId.Text.Trim());
                    cmd.Parameters.AddWithValue("@Policy_Name", txtPolicyName.Text.Trim());
                    cmd.Parameters.AddWithValue("@Catagory_Code", ddlCategory.SelectedValue);
                    cmd.Parameters.AddWithValue("@Policy_Type", ddlPolicyType.SelectedValue);
                    cmd.Parameters.AddWithValue("@Policy_Value", txtPolicyValue.Text.Trim());
                    cmd.Parameters.AddWithValue("@Payment_Type", ddlPaymentType.SelectedValue);
                    cmd.Parameters.AddWithValue("@Absent_Deduction", ddlAbsentDed.SelectedValue);
                    cmd.Parameters.AddWithValue("@Payment_From", ddlPaymentFrom.SelectedValue);
                    cmd.Parameters.AddWithValue("@OT_Pay", ddlOtPay.SelectedValue);
                    cmd.Parameters.AddWithValue("@Night_Tifin_Holiday", ddlNightTifin.SelectedValue);
                    cmd.Parameters.AddWithValue("@Attendance_Bonus", ddlAttBonus.SelectedValue);
                    cmd.Parameters.AddWithValue("@Rounding", ddlRounding.SelectedValue);
                    cmd.Parameters.AddWithValue("@Pay_Type", ddlPayType.SelectedValue);
                    cmd.Parameters.AddWithValue("@Sheet_Heder", txtSheetHeader.Text.Trim());
                    cmd.Parameters.AddWithValue("@Policy_Month", FormatDate(txtPolicyMonth.Text));
                    cmd.Parameters.AddWithValue("@Pay_from", FormatDate(txtPayFrom.Text));
                    cmd.Parameters.AddWithValue("@Pay_Till", FormatDate(txtPayTill.Text));
                    cmd.ExecuteNonQuery();
                }
                Alert("Saved Successfully!");
                LoadPolicyGrid();
            }
            catch (Exception ex) { Alert("Error: " + ex.Message); }
            finally { if (con != null && con.State != ConnectionState.Closed) con.Close(); }
        }
    }
}
