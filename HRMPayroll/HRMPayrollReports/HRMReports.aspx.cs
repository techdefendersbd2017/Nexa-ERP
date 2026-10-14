using Nexa_ERP.Connection;
using Nexa_ERP.HRMPayroll.Common;      // <-- নতুন
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.HRMPayroll.HRMPayrollReports
{
    public partial class HRMReports : Page
    {
        PayrollDB conn = new PayrollDB();

        // পাবলিক ফিল্টার ক্লাস
        HRFilters filters;

        const int MaxIds = HRFilters.MaxIds;

        readonly List<string> loadErrors = new List<string>();

        // সমস্যা মিটে গেলে false করে দিন
        const bool ShowDebug = true;
        readonly List<string> debug = new List<string>();

        // ---------- মডেল ----------
        public class Emp
        {
            public string Id { get; set; }
            public string Name { get; set; }
            public string Designation { get; set; }
            public string Department { get; set; }
            public string Branch { get; set; }
            public string Status { get; set; }
        }

        // TODO: আপনার Login/Session এর key অনুযায়ী বদলান
        long UserCode { get { return HRFilters.UserCode; } }
        long FromCode { get { return HRFilters.SessionLong("From_Code", "FromCode"); } }

        List<string> AllErrors()
        {
            return loadErrors.Concat(filters.Errors).ToList();
        }

        // ================= Page Load =================
        protected void Page_Load(object sender, EventArgs e)
        {
            // ফিল্টার ক্লাস তৈরি: এই পেজে যেসব ফিল্টার আছে সেগুলো Attach করুন
            filters = new HRFilters()
                .Attach(HRFilters.Branch, ddBranch)
                .Attach(HRFilters.Category, ddCategory)
                .Attach(HRFilters.Dept, ddDept)
                .Attach(HRFilters.Section, ddSection)
                .Attach(HRFilters.SubSec, ddSubSec)
                .Attach(HRFilters.Desig, ddDesig)
                .Attach(HRFilters.Level, ddLevel)
                .Attach(HRFilters.Floor, ddFloor);
            filters.EmptyMeansAll = false;   // কিছু না বাছলে কিছুই insert হবে না

            filters.LoadLookups();           // কোড খোঁজার জন্য প্রতিটি request এ লাগে

            // পোস্টব্যাকের পর আগের টিক ফিরিয়ে আনা
            if (IsPostBack && !string.IsNullOrEmpty(SelectedIdsRaw()))
            {
                string arr = new JavaScriptSerializer().Serialize(SelectedIdsRaw().Split(','));
                ClientScript.RegisterStartupScript(GetType(), "retick",
                    "document.addEventListener('DOMContentLoaded',function(){var ids=" + arr +
                    ";document.querySelectorAll('.row-checkbox').forEach(function(c){" +
                    "if(ids.indexOf(c.getAttribute('data-id'))>=0)c.checked=true;});});", true);
            }

            if (!IsPostBack)
            {
                FillDropDowns();
                ResetDefaults();
                ClearGrid();
            }

            if (IsPostBack && AllErrors().Count > 0)
                Toast("Option load error: " + string.Join(" | ", AllErrors()));
        }

        void FillDropDowns()
        {
            filters.FillControls();   // Branch, Category, Dept ... সব ভরে দেয়

            FillStatic(ddBlood, "-- All --", "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-");
            FillStatic(ddReligion, "-- All --", "Islam", "Hinduism", "Buddhism", "Christianity", "Others");
            // TODO: comboBox_Resign_Status এর আইটেমের সঙ্গে হুবহু মিলিয়ে নিন (প্রথমটি ডিফল্ট)
            FillStatic(ddStatus, null, "Active", "New", "Seperation", "All", "Resign", "Left");

            LoadReportTypes();

            if (AllErrors().Count > 0)
                Toast("Option load error: " + string.Join(" | ", AllErrors()));
        }

        // Text = Report_Name, Value = Report_Code
        // Report_Name এর নাম ResolveReport এর নামের সঙ্গে হুবহু মিলতে হবে
        void LoadReportTypes()
        {
            ddRType.Items.Clear();
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();

                    using (var cmd = new SqlCommand(
                        "SELECT Report_Code, Report_Name FROM Soft_Reports " +
                        "WHERE Menu=1   ORDER BY Report_Name ASC", con))// AND user_id=@uid
                    {
                        cmd.Parameters.Add("@uid", SqlDbType.NVarChar, 50).Value = UserCode.ToString();

                        var dt = new DataTable();
                        using (var da = new SqlDataAdapter(cmd)) da.Fill(dt);

                        foreach (DataRow r in dt.Rows)
                        {
                            string name = Convert.ToString(r["Report_Name"]);
                            if (string.IsNullOrWhiteSpace(name)) continue;
                            ddRType.Items.Add(new ListItem(name.Trim(), Convert.ToString(r["Report_Code"])));
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                loadErrors.Add("reportType: " + ex.Message);
            }
        }

        // নির্বাচিত Report Type এর নাম (Value এখন কোড, তাই Text নিতে হয়)
        string RTypeText()
        {
            return ddRType.SelectedItem != null ? ddRType.SelectedItem.Text.Trim() : "";
        }

        static void FillStatic(DropDownList dd, string blank, params string[] items)
        {
            dd.Items.Clear();
            if (blank != null) dd.Items.Add(new ListItem(blank, ""));
            foreach (string s in items) dd.Items.Add(new ListItem(s, s));
        }

        // ================= বাটন ইভেন্ট =================
        protected void btnShow_Click(object sender, EventArgs e)
        {
            ShowData();
        }

        // ===== নতুন রিপোর্ট যোগ করতে শুধু এখানে একটি else if বসান =====
        // page    : রিপোর্ট পেজের পথ
        // formCode: z_Test_ID এর From_Code
        // needIds : true হলে গ্রিড থেকে কর্মচারী নির্বাচন লাগবে
        static bool ResolveReport(string name, out string page, out int formCode, out bool needIds)
        {
            page = null; formCode = 0; needIds = true;
            name = Norm(name);   // বাড়তি/ডবল স্পেস বাদ দিয়ে মেলানো, তাই Soft_Reports এর নামে স্পেসের ভুলে আর আটকাবে না

            if (name == "Active Employee List")
            { page = "HRReports/ActiveEmployeeListReport.aspx"; formCode = 7; needIds = true; }
            else if (name == "Full File Bangla")
            { page = "HRReports/EmployeeDocuments.aspx?report=Full_File_Bangla"; formCode = 8; needIds = true; }
            else if (name == "Appointment Letter" || name == "Appointment Latter")
            { page = "HRReports/EmployeeDocuments.aspx?report=Appointment_Letter"; formCode = 8; needIds = true; }
            else if (name == "ID Card" || name == "ID Card Bangla")
            { page = "HRReports/EmployeeDocuments.aspx?report=ID_Card"; formCode = 8; needIds = true; }
            else if (name == "Background Check" || name == "Police Verification Letter")
            { page = "HRReports/EmployeeDocuments.aspx?report=Background_Check"; formCode = 8; needIds = true; }
            else if (name == "Job Description")
            { page = "HRReports/EmployeeDocuments.aspx?report=Job_Description"; formCode = 8; needIds = true; }
            else if (name == "Nominee Form" || name == "Nominee From")
            { page = "HRReports/EmployeeDocuments.aspx?report=Nominee_Form"; formCode = 8; needIds = true; }
            else if (name == "Medical Form" || name == "Medical From")
            { page = "HRReports/EmployeeDocuments.aspx?report=Medical_Form"; formCode = 8; needIds = true; }
            else if (name == "Joining Letter" || name == "Joining Latter")
            { page = "HRReports/EmployeeDocuments.aspx?report=Joining_Letter"; formCode = 8; needIds = true; }
            else
                return false;   // তালিকায় নেই

            return true;
        }

        static string Norm(string s)
        {
            return System.Text.RegularExpressions.Regex.Replace((s ?? "").Trim(), @"\s+", " ");
        }

        // ড্রপডাউনের কোন কোন নাম নতুন ট্যাবে রিপোর্ট খোলে তার তালিকা ResolveReport থেকেই JS এ যায়
        // (JS এ আলাদা তালিকা রাখতে হয় না, তাই দুই জায়গার নাম আর অমিল হবে না)
        protected void Page_PreRender(object sender, EventArgs e)
        {
            var map = new Dictionary<string, bool>();
            foreach (ListItem it in ddRType.Items)
            {
                string p; int f; bool n;
                string key = it.Text.Trim();
                if (ResolveReport(key, out p, out f, out n)) map[key] = n;
            }
            ClientScript.RegisterStartupScript(GetType(), "rpts",
                "window.RESOLVED_REPORTS=" + new JavaScriptSerializer().Serialize(map) + ";", true);
        }

        protected void btnReport_Click(object sender, EventArgs e)
        {
            string page; int formCode; bool needIds;
            string rt = RTypeText();

            if (ResolveReport(rt, out page, out formCode, out needIds))
                OpenReport(page, formCode, needIds);
            else if (ShowData())
                Toast("Report generated successfully! (Type: " + rt + ")");
        }

        // টিক দেওয়া ID গুলো: প্রথমে চেকবক্সের name="selId", না পেলে hfSelIds
        string SelectedIdsRaw()
        {
            string[] fromForm = Request.Form.GetValues("selId");
            if (fromForm != null && fromForm.Length > 0)
                return string.Join(",", fromForm);
            return hfSelIds.Value ?? "";
        }

        // নির্বাচিত ID z_Test_ID তে সেভ করে পেজ খোলা
        void OpenReport(string page, int formCode, bool needIds)
        {
            if (UserCode == 0)
            {
                Toast("User_Code পাওয়া যায়নি (Session)। Login করে আবার চেষ্টা করুন।");
                return;
            }

            long[] ids = HRFilters.ParseIds(SelectedIdsRaw())
                .Select(s => { long x; return long.TryParse(s, out x) ? x : 0; })
                .Where(x => x != 0).Distinct().ToArray();

            if (needIds && ids.Length == 0)
            {
                Toast("কমপক্ষে একজন কর্মচারী নির্বাচন করুন।");
                return;
            }

            if (ids.Length > MaxIds)
            {
                Toast("Too many IDs (max " + MaxIds + ").");
                return;
            }

            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();

                    using (var del = new SqlCommand(
                        "DELETE FROM dbo.z_Test_ID WHERE User_ID=@u AND From_Code=@f", con))
                    {
                        del.Parameters.Add("@u", SqlDbType.BigInt).Value = UserCode;
                        del.Parameters.Add("@f", SqlDbType.BigInt).Value = formCode;
                        del.ExecuteNonQuery();
                    }

                    if (needIds)
                    {
                        foreach (long id in ids)
                            HRDb.ExecProc(con, "Pro_z_Test_ID_New",
                                HRDb.P("@ID_No", id), HRDb.P("@User_ID", UserCode), HRDb.P("@Form_Code", formCode));
                    }
                }
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message);
                return;
            }
            string url = ResolveClientUrl(page);
            ClientScript.RegisterStartupScript(GetType(), "openRpt",
                "window.open(" + new JavaScriptSerializer().Serialize(url) + ", '_blank');", true);
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ResetDefaults();
            ClearGrid();
            Toast("All filters cleared.");
        }

        // ================= Show এর মূল লজিক =================
        bool ShowData()
        {
            DataTable dt;
            string status = string.IsNullOrEmpty(ddStatus.SelectedValue) ? "Active" : ddStatus.SelectedValue;

            try
            {
                string[] ids = HRFilters.ParseIds(txtMultiId.Text);

                if (ids.Length > MaxIds)
                {
                    Toast("Too many IDs (max " + MaxIds + ").");
                    return false;
                }

                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();

                    if (ids.Length > 0)
                    {
                        dt = QueryByIds(con, ids, status);
                    }
                    else
                    {
                        if (UserCode == 0)
                        {
                            Toast("User_Code পাওয়া যায়নি (Session)। Login করে আবার চেষ্টা করুন।");
                            return false;
                        }

                        // ফিল্টার ক্লাস দিয়ে সব নির্বাচন সেভ
                        debug.AddRange(filters.SaveSelections(con, UserCode, FromCode));

                        dt = RunStatusProc(con, status);
                        debug.Add("user=" + UserCode + ", fromCode=" + FromCode + ", status=" + status + ", rows=" + dt.Rows.Count);
                    }
                }
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message);
                return false;
            }

            if (ShowDebug && debug.Count > 0)
                Toast("Debug → " + string.Join(", ", debug));

            BindTable(dt, status);
            return true;
        }

        DataTable QueryByIds(SqlConnection con, string[] ids, string status)
        {
            bool numeric = ids.All(s => { long x; return long.TryParse(s, out x); });

            using (var cmd = new SqlCommand())
            {
                cmd.Connection = con;
                var names = new List<string>();
                for (int i = 0; i < ids.Length; i++)
                {
                    string p = "@id" + i;
                    names.Add(p);
                    if (numeric) cmd.Parameters.Add(p, SqlDbType.BigInt).Value = long.Parse(ids[i]);
                    else cmd.Parameters.Add(p, SqlDbType.NVarChar, 50).Value = ids[i];
                }

                string sql = "SELECT ID_no, Name, Designation, Resign_Status FROM View_Emp WHERE ID_no IN (" + string.Join(",", names) + ")";
                if (status != "All")
                {
                    sql += " AND Resign_Status = @st";
                    cmd.Parameters.Add("@st", SqlDbType.NVarChar, 50).Value = status;
                }
                cmd.CommandText = sql;

                var dt = new DataTable();
                using (var da = new SqlDataAdapter(cmd)) da.Fill(dt);
                return dt;
            }
        }

        DataTable RunStatusProc(SqlConnection con, string status)
        {
            string proc;
            switch (status)
            {
                case "Active": proc = "Pro_Employee_View_N"; break;
                case "New": proc = "Pro_Employee_View_N_New"; break;
                case "Seperation": proc = "Pro_Employee_View_N_Seperation"; break;
                case "All": proc = "Pro_Employee_View_N_All"; break;
                default: proc = "Pro_Employee_View_N_Resign_Lefty_Others"; break;
            }

            string from = string.IsNullOrWhiteSpace(txtFromDate.Text) ? "1900-01-01" : txtFromDate.Text.Trim();
            string till = string.IsNullOrWhiteSpace(txtTillDate.Text) ? DateTime.Today.ToString("yyyy-MM-dd") : txtTillDate.Text.Trim();

            using (var cmd = new SqlCommand(proc, con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandTimeout = 120;
                cmd.Parameters.AddWithValue("@Employee_Status", status);
                cmd.Parameters.AddWithValue("@from_Date", from);
                cmd.Parameters.AddWithValue("@till_Date", till);
                cmd.Parameters.AddWithValue("@User_Code", UserCode.ToString());
                cmd.Parameters.AddWithValue("@From_Code", FromCode.ToString());

                var dt = new DataTable();
                using (var rd = cmd.ExecuteReader()) dt.Load(rd);
                return dt;
            }
        }

        // ================= ফলাফল দেখানো =================
        void BindTable(DataTable dt, string status)
        {
            var list = new List<Emp>();
            foreach (DataRow r in dt.Rows)
            {
                list.Add(new Emp
                {
                    Id = Col(r, "", "ID_no", "Id", "Emp_ID"),
                    Name = Col(r, "", "Name", "Emp_Name"),
                    Designation = Col(r, "", "Designation", "Desigation_name"),
                    Department = Col(r, "", "Department", "Department_Name"),
                    Branch = Col(r, "", "Branch", "Branch_Name"),
                    Status = Col(r, status, "Resign_Status", "Status", "Employee_Status")
                });
            }

            rptEmployees.DataSource = list;
            rptEmployees.DataBind();
            trEmpty.Visible = list.Count == 0;

            lblReportTitle.Text = string.IsNullOrEmpty(RTypeText()) ? "Active Employee List" : RTypeText();
            lblCount.Text = list.Count + " Records";
            litPaging.Text = list.Count == 0
                ? "Showing 0 entries"
                : "Showing <span class=\"font-medium text-slate-700\">1</span> to <span class=\"font-medium text-slate-700\">" + list.Count +
                  "</span> of <span class=\"font-medium text-slate-700\">" + list.Count + "</span> entries";

            if (list.Count > 0)
            {
                ClientScript.RegisterStartupScript(GetType(), "chkall",
                    "document.addEventListener('DOMContentLoaded',function(){document.querySelectorAll('.row-checkbox,#selectAllRows').forEach(function(c){c.checked=true;});});", true);
            }
        }

        static string Col(DataRow r, string fallback, params string[] names)
        {
            foreach (string n in names)
            {
                if (r.Table.Columns.Contains(n) && r[n] != DBNull.Value)
                    return Convert.ToString(r[n]);
            }
            return fallback;
        }

        // ================= সাহায্যকারী =================
        void ResetDefaults()
        {
            // মাল্টিপল সিলেক্ট ফিল্টার: সব সিলেকশন মোছা
            filters.ClearSelections();

            // সাধারণ ড্রপডাউন: প্রথম আইটেমে ফেরা
            foreach (var d in new[] { ddBlood, ddReligion, ddStatus, ddRType })
                if (d.Items.Count > 0) d.SelectedIndex = 0;

            hfSelIds.Value = "";
            txtFromDate.Text = txtTillDate.Text = txtMultiId.Text = "";
        }

        void ClearGrid()
        {
            rptEmployees.DataSource = null;
            rptEmployees.DataBind();
            trEmpty.Visible = false;

            lblReportTitle.Text = string.IsNullOrEmpty(RTypeText()) ? "Active Employee List" : RTypeText();
            lblCount.Text = "0 Records";
            litPaging.Text = "Showing 0 entries";
        }

        void Toast(string msg)
        {
            string js = "document.addEventListener('DOMContentLoaded',function(){showNotification(" +
                        new JavaScriptSerializer().Serialize(msg) + ");});";
            ClientScript.RegisterStartupScript(GetType(), "toast" + Guid.NewGuid().ToString("N"), js, true);
        }
    }
}
