using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.HRMPayroll.EmployeeLifecycle
{
    public partial class EmployeeEntry : System.Web.UI.Page
    {
        PayrollDB conn = new PayrollDB();

        const int MaxPhotoBytes = 300 * 1024;   // 300 KB

        // aspx এ  var OPT = <%= OptJson %>;
        protected string OptJson = "{}";
        readonly List<string> loadErrors = new List<string>();

        // TODO: আপনার Login/Session key অনুযায়ী বদলান (HR Reports পেজে যেটা ব্যবহার করেছেন)
        string UserName
        {
            get { return Convert.ToString(Session["User_Name"] ?? Session["UserName"] ?? ""); }
        }

        // ================= Page Load =================
        protected void Page_Load(object sender, EventArgs e)
        {
            lblUser.Text = UserName;
            if (!IsPostBack) ResetForm();
        }

        // অপশন তালিকা প্রতিটি request এ তৈরি হয় (HRFilters.LoadLookups এর মতো)
        protected override void OnPreRender(EventArgs e)
        {
            base.OnPreRender(e);
            OptJson = BuildOptions();
            if (loadErrors.Count > 0) Toast("Option load error: " + string.Join(" | ", loadErrors));
        }

        string BuildOptions()
        {
            var opt = new Dictionary<string, List<string>>();

            opt["mr"] = new List<string> { "Mr.", "Mrs.", "Ms." };
            opt["blood"] = new List<string> { "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-" };
            opt["tax"] = new List<string> { "No", "Yes" };
            opt["bank"] = new List<string> { "No", "Yes" };
            // TODO: Desktop এর comboBox_Brack_Down এর আইটেমের সঙ্গে হুবহু মিলিয়ে নিন
            opt["brk"] = new List<string> { "Yes", "No" };

            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();

                    opt["company"] = Names(con, "SELECT Company_Name FROM TB_Company", "Company_Name");
                    opt["branch"] = Names(con, "SELECT Branch_Name FROM TB_Branch", "Branch_Name");
                    opt["dept"] = Names(con, "SELECT Department_Name FROM TB_Department ORDER BY Department_Name", "Department_Name");
                    opt["section"] = Names(con, "SELECT Section_Name FROM TB_Section ORDER BY Section_Name", "Section_Name");
                    opt["line"] = Names(con, "SELECT Line_Name FROM TB_Line ORDER BY Line_Name", "Line_Name");
                    opt["desig"] = Names(con, "SELECT Desigation_name FROM TB_Designation ORDER BY Desigation_name", "Desigation_name");
                    opt["category"] = Names(con, "SELECT Catagory_Name FROM TB_Catagory", "Catagory_Name");
                    opt["shift"] = Names(con, "SELECT Shift_Name FROM TB_Shift ORDER BY Shift_Name", "Shift_Name");
                    opt["floor"] = Names(con, "SELECT Floor_Name FROM TB_Floor", "Floor_Name");
                    opt["weekoff"] = Names(con, "SELECT Weekly_Name FROM TB_Weekly_Off", "Weekly_Name");
                    opt["paytype"] = Names(con, "SELECT Pay_Type_Name FROM Payment_Type", "Pay_Type_Name");
                    opt["bankname"] = Names(con, "SELECT Bank_Name FROM Bank_Information", "Bank_Name");
                }
            }
            catch (Exception ex)
            {
                loadErrors.Add("options: " + ex.Message);
            }

            return new JavaScriptSerializer().Serialize(opt);
        }

        static List<string> Names(SqlConnection con, string sql, string col)
        {
            var list = new List<string>();
            var dt = new DataTable();
            using (var da = new SqlDataAdapter(sql, con)) da.Fill(dt);
            foreach (DataRow r in dt.Rows)
            {
                string s = Convert.ToString(r[col]).Trim();
                if (s != "" && !list.Contains(s)) list.Add(s);
            }
            return list;
        }

        static string V(HiddenField hf) { return (hf.Value ?? "").Trim(); }

        // ================= Search =================
        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadEmployee(txtEmpId.Text.Trim());
        }

        void LoadEmployee(string empId)
        {
            if (empId == "") { Toast("Please enter ID No."); return; }

            bool found = false;
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();

                    using (var cmd = new SqlCommand("SELECT * FROM Employee_View_By_Code WHERE ID_no=@id", con))
                    {
                        cmd.Parameters.Add("@id", SqlDbType.NVarChar, 50).Value = empId;
                        using (var rd = cmd.ExecuteReader())
                        {
                            if (rd.Read())
                            {
                                found = true;
                                // Desktop পেজের সঙ্গে একই column index
                                hfEmpNo.Value = rd[0].ToString();
                                txtEmpId.Text = rd[1].ToString();
                                hfMR.Value = rd[2].ToString().Trim();
                                txtName.Text = rd[3].ToString();
                                txtBanglaName.Text = rd[4].ToString();
                                txtJoining.Text = ToHtmlDate(rd[5]);
                                txtProbation.Text = ToHtmlDate(rd[6]);
                                hfBreak.Value = rd[7].ToString().Trim();
                                txtGross.Text = rd[8].ToString();
                                hfCompany.Value = rd[9].ToString().Trim();
                                hfBranch.Value = rd[10].ToString().Trim();
                                hfDept.Value = rd[11].ToString().Trim();
                                hfSection.Value = rd[12].ToString().Trim();
                                hfLine.Value = rd[13].ToString().Trim();
                                hfDesig.Value = rd[14].ToString().Trim();
                                hfCategory.Value = rd[15].ToString().Trim();
                                hfShift.Value = rd[16].ToString().Trim();
                                hfFloor.Value = rd[17].ToString().Trim();
                                hfWeekOff.Value = rd[18].ToString().Trim();
                                hfTax.Value = rd[19].ToString().Trim();
                                txtTaxAmount.Text = rd[20].ToString();
                                hfBank.Value = rd[21].ToString().Trim();
                                hfBankName.Value = rd[22].ToString().Trim();
                                txtAcNo.Text = rd[23].ToString();
                                lblStatus.Text = rd[25].ToString();
                                lblStatusDate.Text = lblStatus.Text == "Active" ? "" : "(" + ToDisplayDate(rd[26]) + ")";
                                hfLock.Value = rd[28].ToString();
                                hfBlood.Value = rd[32].ToString().Trim();
                                hfPayType.Value = rd[34].ToString().Trim();
                                txtBankGross.Text = rd[35].ToString();
                                txtCashGross.Text = rd[36].ToString();
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message);
                return;
            }

            if (!found)
            {
                string id = empId;
                ResetForm();
                Toast("This ID- '" + id + "' Not Exists In your Database.");
                return;
            }

            LoadPhoto(txtEmpId.Text.Trim());
            LoadIncrement(txtEmpId.Text.Trim());
            ApplyLock();
        }

        // ================= Photo =================
        void LoadPhoto(string empId)
        {
            imgEmp.ImageUrl = "~/Images/user-default.png";
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();
                    using (var cmd = new SqlCommand("SELECT Photo FROM Emp_Photo WHERE Emp_no=@e", con))
                    {
                        cmd.Parameters.Add("@e", SqlDbType.NVarChar, 50).Value = empId;
                        object o = cmd.ExecuteScalar();
                        if (o != null && o != DBNull.Value)
                            imgEmp.ImageUrl = "data:image/jpeg;base64," + Convert.ToBase64String((byte[])o);
                    }
                }
            }
            catch (Exception ex)
            {
                Toast("Photo error: " + ex.Message);
            }
        }

        // নতুন ছবি আপলোড হলে byte[] ফেরত দেয়, নইলে null। 300KB এর বেশি বা ভুল ফরম্যাট হলে invalid = true।
        byte[] GetUploadedPhoto(out bool invalid)
        {
            invalid = false;
            if (!fuPhoto.HasFile) return null;

            if (fuPhoto.PostedFile.ContentLength > MaxPhotoBytes)
            {
                invalid = true;
                return null;
            }

            string ext = Path.GetExtension(fuPhoto.FileName).ToLowerInvariant();
            if (ext != ".jpg" && ext != ".jpeg" && ext != ".png" && ext != ".bmp")
            {
                invalid = true;
                return null;
            }
            return fuPhoto.FileBytes;
        }

        void SavePhoto(SqlConnection con, string empId, byte[] photo)
        {
            if (photo == null) return;

            using (var up = new SqlCommand("UPDATE Emp_Photo SET Photo=@p WHERE Emp_no=@e", con))
            {
                up.Parameters.Add("@p", SqlDbType.VarBinary, -1).Value = photo;
                up.Parameters.Add("@e", SqlDbType.NVarChar, 50).Value = empId;
                if (up.ExecuteNonQuery() > 0) return;
            }
            // রেকর্ড না থাকলে নতুন Insert (TODO: Emp_Photo এর কলাম মিলিয়ে নিন)
            using (var ins = new SqlCommand("INSERT INTO Emp_Photo (Emp_no, Photo) VALUES (@e, @p)", con))
            {
                ins.Parameters.Add("@p", SqlDbType.VarBinary, -1).Value = photo;
                ins.Parameters.Add("@e", SqlDbType.NVarChar, 50).Value = empId;
                ins.ExecuteNonQuery();
            }
        }

        // ================= Save / Update =================
        protected void btnSave_Click(object sender, EventArgs e)
        {
            // নতুন কর্মচারী: আগে থেকে থাকলে Save হবে না
            if (EmpExists(txtEmpId.Text.Trim()))
            {
                Toast("This employee al-ready exist in database. Please check your employee ID No.");
                return;
            }
            hfEmpNo.Value = "";
            SaveEmployee("Save");
        }

        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            if (!EmpExists(txtEmpId.Text.Trim()))
            {
                Toast("This employee not exist in database. Please check your employee ID No.");
                return;
            }
            SaveEmployee("Update");
        }

        bool EmpExists(string empId)
        {
            if (empId == "") return false;
            using (SqlConnection con = conn.openConnection())
            {
                if (con.State != ConnectionState.Open) con.Open();
                using (var cmd = new SqlCommand("SELECT TOP 1 1 FROM Employee_View_By_Code WHERE ID_no=@id", con))
                {
                    cmd.Parameters.Add("@id", SqlDbType.NVarChar, 50).Value = empId;
                    return cmd.ExecuteScalar() != null;
                }
            }
        }

        void SaveEmployee(string mode)
        {
            if (txtEmpId.Text.Trim() == "") { Toast("Please enter ID No."); return; }
            if (txtName.Text.Trim() == "") { Toast("Please check Name (English)."); return; }
            if (txtBanglaName.Text.Trim() == "") { Toast("Please check Bangla Name."); return; }

            bool invalid;
            byte[] photo = GetUploadedPhoto(out invalid);
            if (invalid)
            {
                Toast("ছবির সাইজ সর্বোচ্চ 300 KB এবং ফরম্যাট JPG/PNG/BMP হতে হবে।");
                return;
            }

            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();

                    using (var cmd = new SqlCommand("Pro_Employee_Entry", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;

                        // Desktop পেজের সঙ্গে একই parameter নাম ও ক্রম
                        cmd.Parameters.AddWithValue("@emp_no", hfEmpNo.Value);
                        cmd.Parameters.AddWithValue("@Emp_ID", txtEmpId.Text.Trim());
                        cmd.Parameters.AddWithValue("@Name", txtName.Text.Trim());
                        cmd.Parameters.AddWithValue("@Bangal_Name", txtBanglaName.Text.Trim());
                        cmd.Parameters.AddWithValue("@Joining_Date", ToSqlText(txtJoining.Text));
                        cmd.Parameters.AddWithValue("@Probation_End_Time", ToSqlText(txtProbation.Text));
                        cmd.Parameters.AddWithValue("@Compani_Name", V(hfCompany));
                        cmd.Parameters.AddWithValue("@Branch_Name", V(hfBranch));
                        cmd.Parameters.AddWithValue("@Department_Name", V(hfDept));
                        cmd.Parameters.AddWithValue("@Section_name", V(hfSection));
                        cmd.Parameters.AddWithValue("@Line_Name", V(hfLine));
                        cmd.Parameters.AddWithValue("@Designation_Name", V(hfDesig));
                        cmd.Parameters.AddWithValue("@Catagory_Name", V(hfCategory));
                        cmd.Parameters.AddWithValue("@Shift_Name", V(hfShift));
                        cmd.Parameters.AddWithValue("@Floor_Name", V(hfFloor));
                        cmd.Parameters.AddWithValue("@Weekly_off_Day", V(hfWeekOff));
                        cmd.Parameters.AddWithValue("@Gross_Salary", txtGross.Text.Trim());
                        cmd.Parameters.AddWithValue("@Entry", UserName);
                        cmd.Parameters.AddWithValue("@Brackdown_policy", V(hfBreak));
                        cmd.Parameters.AddWithValue("@MR", V(hfMR));
                        cmd.Parameters.AddWithValue("@Bank_Holder", V(hfBank));
                        cmd.Parameters.AddWithValue("@Bank_Name", V(hfBankName));
                        cmd.Parameters.AddWithValue("@A_C_No", txtAcNo.Text.Trim());
                        cmd.Parameters.AddWithValue("@Tex_Holder", V(hfTax));
                        cmd.Parameters.AddWithValue("@Tex_Amount", txtTaxAmount.Text.Trim());
                        cmd.Parameters.AddWithValue("@Operation_mood", mode);
                        cmd.Parameters.AddWithValue("@Blood_Group", V(hfBlood));
                        cmd.Parameters.AddWithValue("@Pay_Type_Name", V(hfPayType));
                        cmd.Parameters.AddWithValue("@Bank_Gross", txtBankGross.Text.Trim());
                        cmd.Parameters.AddWithValue("@Cash_Gross", txtCashGross.Text.Trim());
                        cmd.ExecuteNonQuery();
                    }

                    SavePhoto(con, txtEmpId.Text.Trim(), photo);
                }

                LoadEmployee(txtEmpId.Text.Trim());
                Toast("Save Successfull");
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message);
            }
        }

        // ================= Delete =================
        protected void btnDelete_Click(object sender, EventArgs e)
        {
            if (txtEmpId.Text.Trim() == "") { Toast("Please enter ID No."); return; }
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();
                    using (var cmd = new SqlCommand("Pro_Employee_Delete", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@Emp_ID", txtEmpId.Text.Trim());
                        cmd.ExecuteNonQuery();
                    }
                }
                ResetForm();
                Toast("Delete Successfull");
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message);
            }
        }

        // ================= Refresh / Increment =================
        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            ResetForm();
        }

        protected void btnIncrement_Click(object sender, EventArgs e)
        {
            LoadIncrement(txtEmpId.Text.Trim());
            ClientScript.RegisterStartupScript(GetType(), "goInc",
                "document.addEventListener('DOMContentLoaded',function(){location.hash='#p4';});", true);
        }

        void LoadIncrement(string empId)
        {
            if (empId == "") { gvIncrement.DataSource = null; gvIncrement.DataBind(); return; }
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();
                    using (var cmd = new SqlCommand(
                        "SELECT Efective_Date, Old_Gross_Salary, Increment_Amount, New_Gross, Status_Name, Designation, Desigation_name, Increment_Name " +
                        "FROM View_Increment_History WHERE ID_No=@id AND Status_Name='Confirm' ORDER BY Efective_Date DESC", con))
                    {
                        cmd.Parameters.Add("@id", SqlDbType.NVarChar, 50).Value = empId;
                        var dt = new DataTable();
                        using (var da = new SqlDataAdapter(cmd)) da.Fill(dt);
                        gvIncrement.DataSource = dt;
                        gvIncrement.DataBind();
                    }
                }
            }
            catch (Exception ex)
            {
                Toast("Increment error: " + ex.Message);
            }
        }

        // ================= Lock (Desktop এর label14 == "1" লজিক) =================
        // ড্রপডাউন গুলো JS (applyLock) নিজে বন্ধ করে hfLock দেখে
        void ApplyLock()
        {
            bool locked = hfLock.Value == "1";
            lblLock.Text = locked ? "Lock" : "Unlock";
            lblLock.CssClass = locked ? "font-semibold text-red-600" : "font-semibold text-emerald-600";

            // Employee ID সবসময় খোলা থাকবে (Desktop এও তাই)
            var controls = new WebControl[]
            {
                txtName, txtBanglaName, txtJoining, txtProbation,
                txtGross, txtBankGross, txtCashGross, txtTaxAmount, txtAcNo,
                fuPhoto, btnSave, btnUpdate, btnDelete
            };
            foreach (var c in controls) c.Enabled = !locked;
        }

        // ================= সাহায্যকারী =================
        void ResetForm()
        {
            hfEmpNo.Value = ""; hfLock.Value = "";
            txtEmpId.Text = txtName.Text = txtBanglaName.Text = "";
            txtJoining.Text = DateTime.Today.ToString("yyyy-MM-dd");
            txtProbation.Text = DateTime.Today.ToString("yyyy-MM-dd");
            txtGross.Text = txtBankGross.Text = txtCashGross.Text = "0";
            txtTaxAmount.Text = txtAcNo.Text = "";
            lblStatus.Text = lblStatusDate.Text = "";

            // সব ড্রপডাউন ফাঁকা
            foreach (var h in new[] { hfBlood, hfCompany, hfBranch, hfDept, hfSection, hfLine, hfDesig,
                                      hfFloor, hfBreak, hfPayType, hfBankName })
                h.Value = "";

            // Desktop এর ডিফল্ট মান
            hfCategory.Value = "Non Management";
            hfShift.Value = "General W/PS";
            hfWeekOff.Value = "Friday";
            hfMR.Value = "Mr.";
            hfTax.Value = "No";
            hfBank.Value = "No";

            imgEmp.ImageUrl = "~/Images/user-default.png";
            gvIncrement.DataSource = null; gvIncrement.DataBind();
            ApplyLock();
            lblLock.Text = "Unlock";
        }

        static string ToHtmlDate(object v)
        {
            DateTime d;
            return DateTime.TryParse(Convert.ToString(v), out d) ? d.ToString("yyyy-MM-dd") : "";
        }

        static string ToDisplayDate(object v)
        {
            DateTime d;
            return DateTime.TryParse(Convert.ToString(v), out d) ? d.ToString("dd-MMM-yyyy", CultureInfo.InvariantCulture) : "";
        }

        // Desktop যেমন "10-Oct-2026" টেক্সট পাঠাত, এখানেও তাই
        static string ToSqlText(string htmlDate)
        {
            DateTime d;
            return DateTime.TryParse(htmlDate, out d) ? d.ToString("dd-MMM-yyyy", CultureInfo.InvariantCulture) : "";
        }

        void Toast(string msg)
        {
            string js = "document.addEventListener('DOMContentLoaded',function(){showNotification(" +
                        new JavaScriptSerializer().Serialize(msg) + ");});";
            ClientScript.RegisterStartupScript(GetType(), "toast" + Guid.NewGuid().ToString("N"), js, true);
        }
    }
}
