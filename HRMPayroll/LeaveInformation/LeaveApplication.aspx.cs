using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.HRMPayroll.LeaveInformation
{
    public partial class LeaveApplication : Page
    {
        PayrollDB conn = new PayrollDB();

        static readonly CultureInfo Inv = CultureInfo.InvariantCulture;

        // TODO: আপনার রিপোর্ট পেজের নাম/পথ দিন (Application বাটন এই পেজ নতুন ট্যাবে খোলে)
        const string ReportPage = "~/HRMPayroll/LeaveInformation/LeaveReports/LeaveApplicationReport.aspx";

        // stored procedure এ তারিখ যে ফরম্যাটে যাবে (Desktop এ "10-Oct-26" ধরনের টেক্সট যেত)
        const string DbDateFmt = "dd-MMM-yyyy";

        // ---- ঠিকানার কলাম (Desktop এর checkBox1 / checkBox2 হুবহু) ----
        // chkPermanent = Desktop এর checkBox1, chkPresent = checkBox2
        // উল্টো হলে শুধু এই দুটি সেট অদলবদল করুন
        static readonly string[] AddrSetA_Worker = { "B_Village", "B_Post", "B_Thana", "B_District" };
        static readonly string[] AddrSetA_Other = { "Village", "Post", "Thana", "District" };
        static readonly string[] AddrSetB_Worker = { "B_P_Village", "B_P_Post", "B_P_Thana", "B_P_District" };
        static readonly string[] AddrSetB_Other = { "P_Village", "P_Post", "P_Thana", "P_District" };

        // ---------- মডেল ----------
        public class LeaveRow
        {
            public string ApplyNo { get; set; }
            public string IdNo { get; set; }
            public string LeaveType { get; set; }
            public string FromDate { get; set; }
            public string TillDate { get; set; }
            public string Days { get; set; }
        }

        // ---------- ViewState ----------
        string EmpNo { get { return (ViewState["EmpNo"] as string) ?? ""; } set { ViewState["EmpNo"] = value; } }          // Desktop textBox10
        string Category { get { return (ViewState["Cat"] as string) ?? ""; } set { ViewState["Cat"] = value; } }          // Desktop label18
        string JoinStatus { get { return (ViewState["JStat"] as string) ?? ""; } set { ViewState["JStat"] = value; } }    // Desktop textBox3
        string SepDate { get { return (ViewState["Sep"] as string) ?? ""; } set { ViewState["Sep"] = value; } }           // Desktop dateTimePicker1
        bool FromList { get { return ViewState["FromList"] != null && (bool)ViewState["FromList"]; } set { ViewState["FromList"] = value; } }

        bool IsWorker
        {
            get { return Category == "Worker" || Category == "Non Management" || Category == "Finishing Iron"; }
        }

        // ================= Page Load =================
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                FillLeaveTypes();
                txtFromDate.Text = txtTillDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                BindList();
            }
        }

        protected void Page_PreRender(object sender, EventArgs e)
        {
            // Custom না হলে Address শুধু পড়া যাবে (Desktop এর মতো)
            if (chkCustom.Checked) txtAddress.Attributes.Remove("readonly");
            else txtAddress.Attributes["readonly"] = "readonly";

            // Worker হলে Bangla (SutonnyMJ) ফন্ট
            if (IsWorker)
            {
                txtPurpose.Style["font-family"] = "SutonnyMJ";
                txtAddress.Style["font-family"] = "SutonnyMJ";
            }
            else
            {
                txtPurpose.Style.Remove("font-family");
                txtAddress.Style.Remove("font-family");
            }
        }

        // ================= Employee ID =================
        protected void txtEmployeeId_TextChanged(object sender, EventArgs e)
        {
            try { LoadEmployee(txtEmployeeId.Text.Trim()); }
            catch (Exception ex) { Toast("Error: " + ex.Message); }
        }

        void LoadEmployee(string id)
        {
            ClearEntry(false);

            if (id == "") { ClearEmployee(); return; }

            DataTable dt = Fill("SELECT * FROM Employee_View_new WHERE ID_no=@id", Sp("@id", id));
            if (dt.Rows.Count == 0)
            {
                ClearEmployee();
                Toast("Employee ID not found.");
                return;
            }

            DataRow r = dt.Rows[0];
            EmpNo = S(r[0]);
            txtEmployeeId.Text = S(r[1]);
            txtName.Text = S(r[2]);
            txtDesignation.Text = S(r[13]);
            JoinStatus = S(r[6]);
            DateTime sep;
            SepDate = DateTime.TryParse(S(r[7]), out sep) ? sep.ToString("yyyy-MM-dd") : "";
            Category = S(r[14]);

            RefreshRemaining();
        }

        void ClearEmployee()
        {
            txtName.Text = txtDesignation.Text = txtRemainingDays.Text = "";
            EmpNo = Category = JoinStatus = SepDate = "";
        }

        // ================= Leave Type / Date =================
        void FillLeaveTypes()
        {
            ddlLeaveType.Items.Clear();
            ddlLeaveType.Items.Add(new ListItem("-- Select --", ""));
            try
            {
                DataTable dt = Fill("SELECT Leave_Name, Leave_code FROM Leave_Name_List");
                foreach (DataRow r in dt.Rows)
                    ddlLeaveType.Items.Add(new ListItem(S(r["Leave_Name"]).Trim(), S(r["Leave_code"])));
            }
            catch (Exception ex) { Toast("Leave type load error: " + ex.Message); }
        }

        protected void ddlLeaveType_SelectedIndexChanged(object sender, EventArgs e)
        {
            try
            {
                RefreshRemaining();
                SetDefaultPurpose();
            }
            catch (Exception ex) { Toast("Error: " + ex.Message); }
        }

        protected void txtFromDate_TextChanged(object sender, EventArgs e)
        {
            DateTime f, t;
            if (TryDate(txtFromDate.Text, out f) && (!TryDate(txtTillDate.Text, out t) || t < f))
                txtTillDate.Text = f.ToString("yyyy-MM-dd");   // Till কখনো From এর আগে নয়
            try { RefreshRemaining(); }
            catch (Exception ex) { Toast("Error: " + ex.Message); }
        }

        // From Date এর বছর অনুযায়ী অবশিষ্ট ছুটি
        void RefreshRemaining()
        {
            if (EmpNo == "" || ddlLeaveType.SelectedValue == "")
            {
                txtRemainingDays.Text = "";
                return;
            }
            DateTime f;
            int year = TryDate(txtFromDate.Text, out f) ? f.Year : DateTime.Today.Year;
            txtRemainingDays.Text = BalanceText(year);
        }

        string BalanceText(int year)
        {
            DataTable dt = Fill("SELECT * FROM Emp_Wise_Dtls WHERE Emp_no=@e AND Years=@y AND Leave_code=@c",
                                Sp("@e", EmpNo), Sp("@y", year.ToString()), Sp("@c", ddlLeaveType.SelectedValue));
            return dt.Rows.Count > 0 ? S(dt.Rows[0][4]) : "0";
        }

        // নতুন এন্ট্রির সময় ছুটির ধরন অনুযায়ী ডিফল্ট Purpose
        void SetDefaultPurpose()
        {
            if (FromList) return;
            string t = ddlLeaveType.SelectedItem != null ? ddlLeaveType.SelectedItem.Text : "";
            string p = "";

            if (IsWorker)
            {
                if (t == "Casual Leave") p = "cvwievwiK mgm¨vi Kvi‡b|";
                else if (t == "Sick Leave") p = "kvwiwiK Amy¯’Zvi Kvi‡b|";
                else if (t == "Maternity Leave") p = "gvZ…Z¡ Kvjxb QzwU |";
            }
            else
            {
                if (t == "Casual Leave") p = "Due to Family Problem.";
                else if (t == "Sick Leave") p = "Due to physical illness.";
                else if (t == "Maternity Leave") p = "Due to Maternity Problem";
            }
            txtPurpose.Text = p;
        }

        // ================= Address চেকবক্স =================
        protected void chkPermanent_CheckedChanged(object sender, EventArgs e)
        {
            if (!chkPermanent.Checked) return;
            chkPresent.Checked = chkCustom.Checked = false;
            FillAddress(IsWorker ? AddrSetA_Worker : AddrSetA_Other);
        }

        protected void chkPresent_CheckedChanged(object sender, EventArgs e)
        {
            if (!chkPresent.Checked) return;
            chkPermanent.Checked = chkCustom.Checked = false;
            FillAddress(IsWorker ? AddrSetB_Worker : AddrSetB_Other);
        }

        protected void chkCustom_CheckedChanged(object sender, EventArgs e)
        {
            if (!chkCustom.Checked) return;
            chkPermanent.Checked = chkPresent.Checked = false;
            txtAddress.Text = "";
        }

        void FillAddress(string[] cols)
        {
            txtAddress.Text = "";
            string id = txtEmployeeId.Text.Trim();
            if (id == "") { Toast("Please enter Employee ID first."); return; }

            try
            {
                // কলামের নাম উপরের ধ্রুবক থেকে, ইউজার ইনপুট থেকে নয়
                DataTable dt = Fill("SELECT " + string.Join(",", cols) + " FROM Employee_Personal_Information_new WHERE ID_No=@id", Sp("@id", id));
                if (dt.Rows.Count == 0) return;

                DataRow r = dt.Rows[0];
                if (IsWorker)
                    txtAddress.Text = " MÖvg t" + S(r[0]) + ",WvKNi t " + S(r[1]) + ",_vbv t " + S(r[2]) + ",‡Rjv t " + S(r[3]);
                else
                    txtAddress.Text = "Village: " + S(r[0]) + ", Post Office: " + S(r[1]) + ", Police Station: " + S(r[2]) + ", District: " + S(r[3]);
            }
            catch (Exception ex) { Toast("Address load error: " + ex.Message); }
        }

        // ================= তালিকা =================
        void BindList()
        {
            var list = new List<LeaveRow>();
            try
            {
                DataTable dt = Fill("SELECT * FROM View_Leave_Application_For_List_View WHERE Status=1 ORDER BY ID_no ASC");
                foreach (DataRow r in dt.Rows)
                {
                    list.Add(new LeaveRow
                    {
                        ApplyNo = S(r[0]),
                        IdNo = S(r[1]),
                        LeaveType = S(r[4]),
                        FromDate = FmtDate(r[5]),
                        TillDate = FmtDate(r[6]),
                        Days = S(r[12])
                    });
                }
            }
            catch (Exception ex) { Toast("List load error: " + ex.Message); }

            rptApplications.DataSource = list;
            rptApplications.DataBind();
            trEmpty.Visible = list.Count == 0;
            lblCount.Text = list.Count + " Records";
            litPaging.Text = list.Count == 0
                ? "Showing 0 entries"
                : "Showing <span class=\"font-medium text-slate-700\">" + list.Count + "</span> entries";
        }

        // তালিকার সারিতে ক্লিক = ফর্মে লোড
        protected void rptApplications_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "pick") return;
            try
            {
                LoadApplication(Server.HtmlDecode(Convert.ToString(e.CommandArgument)));
                BindList();   // নির্বাচিত সারি হাইলাইট
            }
            catch (Exception ex) { Toast("Error: " + ex.Message); }
        }

        void LoadApplication(string applyNo)
        {
            DataTable dt = Fill("SELECT * FROM View_Leave_Application_For_List_View WHERE Apply_No=@a", Sp("@a", applyNo));
            if (dt.Rows.Count == 0) { Toast("Application not found."); return; }

            DataRow r = dt.Rows[0];
            ClearEntry(false);
            hfApplyNo.Value = applyNo;
            FromList = true;

            txtEmployeeId.Text = S(r[1]);
            txtName.Text = S(r[2]);
            txtDesignation.Text = S(r[3]);

            ddlLeaveType.ClearSelection();
            string lt = S(r[4]);
            ListItem li = ddlLeaveType.Items.FindByText(lt);
            if (li == null) { li = new ListItem(lt, ""); ddlLeaveType.Items.Add(li); }
            li.Selected = true;

            DateTime d;
            txtFromDate.Text = DateTime.TryParse(S(r[5]), out d) ? d.ToString("yyyy-MM-dd") : "";
            txtTillDate.Text = DateTime.TryParse(S(r[6]), out d) ? d.ToString("yyyy-MM-dd") : "";
            txtPurpose.Text = S(r[7]);
            txtPhone.Text = S(r[8]);
            txtAddress.Text = S(r[9]);
            txtAlternate.Text = S(r[10]);

            // কর্মচারীর Emp No ও Category
            DataTable em = Fill("SELECT * FROM Employee_View_new WHERE ID_no=@id", Sp("@id", txtEmployeeId.Text.Trim()));
            if (em.Rows.Count > 0)
            {
                EmpNo = S(em.Rows[0][0]);
                Category = S(em.Rows[0][14]);
                JoinStatus = S(em.Rows[0][6]);
                DateTime sep;
                SepDate = DateTime.TryParse(S(em.Rows[0][7]), out sep) ? sep.ToString("yyyy-MM-dd") : "";
            }
            else { EmpNo = Category = JoinStatus = SepDate = ""; }

            RefreshRemaining();
        }

        // ================= বাটন ইভেন্ট =================
        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                DateTime from, till;
                string err = CheckEntry(true, out from, out till);
                if (err != null) { Toast(err); return; }

                RunSaveProc("Pro_Leave_Appliction", "", from, till);

                hfApplyNo.Value = "";
                FromList = false;
                BindList();
                Toast("Your leave application generated successfully. Click 'Application' to print.");
            }
            catch (Exception ex) { Toast("Error: " + ex.Message); }
        }

        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            try
            {
                if (hfApplyNo.Value == "") { Toast("Select an application from the list first."); return; }

                DateTime from, till;
                string err = CheckEntry(false, out from, out till);
                if (err != null) { Toast(err); return; }

                RunSaveProc("Pro_Leave_Appliction_Update", hfApplyNo.Value, from, till);

                hfApplyNo.Value = "";
                FromList = false;
                BindList();
                Toast("Leave application updated successfully.");
            }
            catch (Exception ex) { Toast("Error: " + ex.Message); }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            try
            {
                if (hfApplyNo.Value == "") { Toast("Select an application from the list first."); return; }

                DataTable dt = Fill("SELECT * FROM View_Leave_Application_For_List_View WHERE Apply_No=@a", Sp("@a", hfApplyNo.Value));
                if (dt.Rows.Count == 0 || S(dt.Rows[0][11]) != "1")
                {
                    Toast("Only open applications can be deleted.");
                    return;
                }

                DateTime from, till;
                if (!TryDate(txtFromDate.Text, out from) || !TryDate(txtTillDate.Text, out till))
                {
                    Toast("Invalid date.");
                    return;
                }

                ExecProc("Pro_Leave_Appliction_Delete",
                    Sp("@Application_Code", hfApplyNo.Value),
                    Sp("@ID_no", txtEmployeeId.Text.Trim()),
                    Sp("@Leave_Type", LeaveTypeText()),
                    Sp("@From_Date", from.ToString(DbDateFmt, Inv)),
                    Sp("@Till_Date", till.ToString(DbDateFmt, Inv)));

                ClearEntry(true);
                BindList();
                Toast("Leave application deleted successfully.");
            }
            catch (Exception ex) { Toast("Error: " + ex.Message); }
        }

        // রিপোর্ট: নাম ও শর্ত Session এ রেখে রিপোর্ট পেজে পাঠায় (নতুন ট্যাবে খোলে)
        protected void btnApplication_Click(object sender, EventArgs e)
        {
            DateTime from, till;
            if (EmpNo == "" || !TryDate(txtFromDate.Text, out from) || !TryDate(txtTillDate.Text, out till))
            {
                Toast("Employee ID or date is invalid.");
                return;
            }

            string reportName = IsWorker ? "Leave_Application_RPT" : "Leave_Application_RPT_English";
            string prm = " and Employee_information_new.ID_no='" + Esc(txtEmployeeId.Text.Trim()) + "'" +
                         " and Years ='" + from.Year + "' and Status=1" +
                         " and [From_Date]='" + from.ToString(DbDateFmt, Inv) + "'" +
                         " and Till_Date='" + till.ToString(DbDateFmt, Inv) + "'";

            Session["LeaveRpt_Name"] = reportName;
            Session["LeaveRpt_Prm"] = prm;

            Response.Redirect(ReportPage, false);
            Context.ApplicationInstance.CompleteRequest();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ClearEntry(true);
            BindList();
            Toast("Form cleared.");
        }

        // ================= যাচাই (Desktop এর নিয়মগুলো) =================
        // isNew=true: Save, false: Update। সমস্যা থাকলে বার্তা ফেরত দেয়, নাহলে null।
        string CheckEntry(bool isNew, out DateTime from, out DateTime till)
        {
            from = till = DateTime.MinValue;

            if (EmpNo == "") return "Please enter a valid Employee ID.";
            if (ddlLeaveType.SelectedValue == "") return "Please select Leave Type.";
            if (!TryDate(txtFromDate.Text, out from) || !TryDate(txtTillDate.Text, out till)) return "Invalid date.";
            if (from > till) return "Date range wrong.";

            // মাস লক
            DataTable lk = Fill("SELECT * FROM Lock_Months WHERE DATEPART(MONTH,Lock_Month)=@m AND DATEPART(YEAR,Lock_Month)=@y",
                                Sp("@m", from.Month), Sp("@y", from.Year));
            foreach (DataRow r in lk.Rows)
                if (S(r[6]) == "Lock") return "This month is locked.";

            // ছুটির ব্যালেন্স (শুধু নতুন আবেদনে)
            if (isNew)
            {
                decimal bal;
                if (!decimal.TryParse(BalanceText(from.Year), NumberStyles.Any, Inv, out bal) || bal <= 0)
                    return "Your '" + LeaveTypeText() + "' leave balance is zero.";

                // চাকরি ছেড়ে গেছে কিনা
                DateTime sep;
                if (JoinStatus != "Active" && DateTime.TryParse(SepDate, out sep) && sep < till)
                    return "This employee separated.";
            }

            // উপস্থিত/Late থাকলে আবেদন নয়
            DataTable at = Fill("SELECT att_status FROM emp_Attendance WHERE EMP_NO=@e AND Work_date BETWEEN @f AND @t AND att_status IN ('Present','Late')",
                                Sp("@e", EmpNo), Sp("@f", from), Sp("@t", till));
            if (at.Rows.Count > 0) return "Application entry denied: employee is '" + S(at.Rows[0][0]) + "' in this date range.";

            // একই তারিখে খোলা আবেদন আছে কিনা (শুধু নতুনে)
            if (isNew)
            {
                DataTable ap = Fill("SELECT * FROM Leave_Application WHERE ID_no=@id AND @f BETWEEN From_Date AND Till_Date",
                                    Sp("@id", txtEmployeeId.Text.Trim()), Sp("@f", from));
                if (ap.Rows.Count > 0) return "Already application exists. Please wait for confirmation.";
            }

            // নিশ্চিত হওয়া ছুটি আছে কিনা
            DataTable cf = Fill("SELECT * FROM Leave_Application_Confirm WHERE [Status]=2 AND ID_no=@id AND (Apply_Date BETWEEN @f AND @t)",
                                Sp("@id", txtEmployeeId.Text.Trim()), Sp("@f", from), Sp("@t", till));
            if (cf.Rows.Count > 0) return "Leave application already exists on this date.";

            return null;
        }

        void RunSaveProc(string proc, string applyCode, DateTime from, DateTime till)
        {
            ExecProc(proc,
                Sp("@Application_Code", applyCode),
                Sp("@ID_no", txtEmployeeId.Text.Trim()),
                Sp("@Name", txtName.Text),
                Sp("@Designation", txtDesignation.Text),
                Sp("@Leave_Type", LeaveTypeText()),
                Sp("@From_Date", from.ToString(DbDateFmt, Inv)),
                Sp("@Till_Date", till.ToString(DbDateFmt, Inv)),
                Sp("@Purpose", txtPurpose.Text),
                Sp("@Phone", txtPhone.Text),
                Sp("@Address", txtAddress.Text),
                Sp("@Alternate_Person", txtAlternate.Text));
        }

        // ================= সাহায্যকারী =================
        void ClearEntry(bool clearEmployee)
        {
            hfApplyNo.Value = "";
            FromList = false;
            txtPurpose.Text = txtAddress.Text = txtPhone.Text = txtAlternate.Text = "";
            chkPermanent.Checked = chkPresent.Checked = chkCustom.Checked = false;

            if (clearEmployee)
            {
                txtEmployeeId.Text = "";
                ClearEmployee();
                ddlLeaveType.ClearSelection();
                txtFromDate.Text = txtTillDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
            }
        }

        string LeaveTypeText()
        {
            return ddlLeaveType.SelectedItem != null ? ddlLeaveType.SelectedItem.Text : "";
        }

        static string S(object o)
        {
            return o == null || o == DBNull.Value ? "" : Convert.ToString(o);
        }

        static string FmtDate(object o)
        {
            DateTime d;
            return DateTime.TryParse(S(o), out d) ? d.ToString("dd-MMM-yyyy", Inv) : S(o);
        }

        static bool TryDate(string s, out DateTime d)
        {
            return DateTime.TryParseExact((s ?? "").Trim(), "yyyy-MM-dd", Inv, DateTimeStyles.None, out d);
        }

        static string Esc(string s) { return (s ?? "").Replace("'", "''"); }

        static SqlParameter Sp(string name, object value)
        {
            return new SqlParameter(name, value ?? DBNull.Value);
        }

        DataTable Fill(string sql, params SqlParameter[] ps)
        {
            using (SqlConnection con = conn.openConnection())
            {
                if (con.State != ConnectionState.Open) con.Open();
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.CommandTimeout = 60;
                    if (ps != null && ps.Length > 0) cmd.Parameters.AddRange(ps);
                    var dt = new DataTable();
                    using (var da = new SqlDataAdapter(cmd)) da.Fill(dt);
                    return dt;
                }
            }
        }

        void ExecProc(string proc, params SqlParameter[] ps)
        {
            using (SqlConnection con = conn.openConnection())
            {
                if (con.State != ConnectionState.Open) con.Open();
                using (var cmd = new SqlCommand(proc, con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandTimeout = 60;
                    cmd.Parameters.AddRange(ps);
                    cmd.ExecuteNonQuery();
                }
            }
        }

        void Toast(string msg)
        {
            string js = "document.addEventListener('DOMContentLoaded',function(){showNotification(" +
                        new JavaScriptSerializer().Serialize(msg) + ");});";
            ClientScript.RegisterStartupScript(GetType(), "toast" + Guid.NewGuid().ToString("N"), js, true);
        }
    }
}
