using Nexa_ERP.Connection;
using Nexa_ERP.HRMPayroll.Common;      // HRFilters ক্লাস
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.HRMPayroll.EmployeeLifecycle
{
    public partial class LeftyLetterIssue : Page
    {
        PayrollDB conn = new PayrollDB();

        HRFilters filters;

        const int MaxIds = HRFilters.MaxIds;

        // রিপোর্ট নাম → ওয়েব রিপোর্ট পেজ। নতুন রিপোর্ট পেজ বানালে এখানে একটি লাইন যোগ করুন।
        // কোয়েরি স্ট্রিং: ?report=<নাম>&probation=<0|1>  (probation না থাকলে শর্ত নেই)
        static readonly Dictionary<string, string> ReportPages = new Dictionary<string, string>(StringComparer.Ordinal)
        {
            { "Fast_Latter",   "~/HRMPayroll/HRMPayrollReports/HRReports/LeftyLetterView.aspx" },    // পাথ আপনার প্রজেক্ট অনুযায়ী মিলিয়ে নিন
            { "Secend_Latter", "~/HRMPayroll/HRMPayrollReports/HRReports/LeftyLetterView.aspx" },
            { "Thard_Latter", "~/HRMPayroll/HRMPayrollReports/HRReports/LeftyLetterView.aspx" },
            { "Probation_Time_Latter", "~/HRMPayroll/HRMPayrollReports/HRReports/LeftyLetterView.aspx" },
            { "Envlap2", "~/HRMPayroll/HRMPayrollReports/HRReports/LeftyLetterView.aspx" },
            { "Envlap", "~/HRMPayroll/HRMPayrollReports/HRReports/LeftyLetterView.aspx" },
            { "Fast_Secend_Latter", "~/HRMPayroll/HRMPayrollReports/HRReports/LeftyLetterView.aspx" },
            { "Fast_Secend_Third_Latter", "~/HRMPayroll/HRMPayrollReports/HRReports/LeftyLetterView.aspx" }
        };

        // ডেক্সটপের reportName গুলো (শুধু এগুলোই অনুমোদিত)
        static readonly HashSet<string> AllowedReports = new HashSet<string>(StringComparer.Ordinal)
        {
            "Fast_Latter", "Secend_Latter", "Thard_Latter",
            "Envlap2", "Envlap", "Probation_Time_Latter", "Fast_Secend_Latter", "Fast_Secend_Third_Latter"
        };

        readonly List<string> loadErrors = new List<string>();
        bool rebound;   // এই রিকোয়েস্টে গ্রিড নতুন করে বাঁধা হয়েছে কিনা

        // ---------- মডেল ----------
        public class LeftyRow
        {
            public string Id { get; set; }
            public string Name { get; set; }
            public string Designation { get; set; }
            public string AbsentDate { get; set; }
            public string FirstDate { get; set; }
            public string SecondDate { get; set; }
            public string ThirdDate { get; set; }
        }

        string StatusText()
        {
            return ddStatus.SelectedItem != null ? ddStatus.SelectedItem.Text.Trim() : "";
        }

        static bool IsActive(string s) { return string.Equals(s, "Active", StringComparison.OrdinalIgnoreCase); }
        static bool IsAll(string s) { return string.Equals(s, "All", StringComparison.OrdinalIgnoreCase); }

        List<string> AllErrors()
        {
            return loadErrors.Concat(filters.Errors).ToList();
        }

        static string TodayText() { return DateTime.Today.ToString("yyyy-MM-dd"); }

        // ================= Page Load =================
        protected void Page_Load(object sender, EventArgs e)
        {
            filters = new HRFilters()
                .Attach(HRFilters.Branch, ddBranch)
                .Attach(HRFilters.Category, ddCategory)
                .Attach(HRFilters.Dept, ddDept)
                .Attach(HRFilters.Section, ddSection)
                .Attach(HRFilters.SubSec, ddSubSec)
                .Attach(HRFilters.Desig, ddDesig)
                .Attach(HRFilters.Level, ddLevel)
                .Attach(HRFilters.Floor, ddFloor);

            filters.LoadLookups();

            if (!IsPostBack)
            {
                FillDropDowns();
                SetDefaultDates();
                ClearGrid();
            }

            if (IsPostBack && AllErrors().Count > 0)
                Toast("Option load error: " + string.Join(" | ", AllErrors()));
        }

        // পোস্টব্যাকের পর (গ্রিড নতুন করে না বাঁধলে) আগের টিক ফিরিয়ে আনা
        protected void Page_PreRender(object sender, EventArgs e)
        {
            string raw = SelectedIdsRaw();
            if (IsPostBack && !rebound && !string.IsNullOrEmpty(raw))
            {
                string arr = new JavaScriptSerializer().Serialize(raw.Split(','));
                ClientScript.RegisterStartupScript(GetType(), "retick",
                    "document.addEventListener('DOMContentLoaded',function(){var ids=" + arr +
                    ";document.querySelectorAll('.row-checkbox').forEach(function(c){" +
                    "if(ids.indexOf(c.getAttribute('data-id'))>=0)c.checked=true;});});", true);
            }
        }

        void FillDropDowns()
        {
            filters.FillControls();
            LoadStatus();
            SelectAllStatus();

            if (AllErrors().Count > 0)
                Toast("Option load error: " + string.Join(" | ", AllErrors()));
        }

        // Active, All + Seperation_Status (সেপারেশন পেজের ddStatus এর মতোই)
        void LoadStatus()
        {
            ddStatus.Items.Clear();
            ddStatus.Items.Add(new ListItem("Active", "1"));
            ddStatus.Items.Add(new ListItem("All", "7"));

            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();

                    using (var cmd = new SqlCommand(
                        "SELECT Seperation_Code, Seperation_Name FROM Seperation_Status ORDER BY Seperation_Code ASC", con))
                    {
                        var dt = new DataTable();
                        using (var da = new SqlDataAdapter(cmd)) da.Fill(dt);

                        foreach (DataRow r in dt.Rows)
                        {
                            string name = Convert.ToString(r["Seperation_Name"]);
                            if (string.IsNullOrWhiteSpace(name)) continue;
                            name = name.Trim();
                            if (IsActive(name) || IsAll(name)) continue;
                            ddStatus.Items.Add(new ListItem(name, Convert.ToString(r["Seperation_Code"])));
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                loadErrors.Add("status: " + ex.Message);
            }
        }

        // Lefty কর্মচারী খোঁজার জন্য ডিফল্ট Status = All
        void SelectAllStatus()
        {
            var it = ddStatus.Items.FindByText("All");
            if (it != null) ddStatus.SelectedValue = it.Value;
        }

        // ডেক্সটপের মতো সব তারিখের ঘরে আজকের তারিখ
        void SetDefaultDates()
        {
            string t = TodayText();
            txtFromDate.Text = txtTillDate.Text = t;
            txtMultiFrom.Text = txtMultiTill.Text = t;
            txtDate1.Text = txtDate2.Text = txtDate3.Text = t;
        }

        // ================= ডেটা খোঁজা =================

        // Search (ID No ঘর): id_no in (...)
        protected void btnSearchId_Click(object sender, EventArgs e)
        {
            long[] ids = HRFilters.ParseIds(txtMultiId.Text)
                .Select(s => { long x; return long.TryParse(s, out x) ? x : 0; })
                .Where(x => x != 0).Distinct().ToArray();

            if (ids.Length == 0)
            {
                Toast("Multi ID No ঘরে আইডি দিন।");
                return;
            }
            if (ids.Length > MaxIds)
            {
                Toast("Too many IDs (max " + MaxIds + ").");
                return;
            }

            try
            {
                // ids সবই long, তাই সরাসরি যোগ করা নিরাপদ
                DataTable dt = Query("SELECT * FROM View_Lefty_Search WHERE id_no IN (" + string.Join(",", ids) + ")");
                Bind(dt, true);
            }
            catch (Exception ex) { Toast("Error: " + ex.Message); }
        }

        // Search New letter Employee: Absent_Date, From Date – Till Date এর মধ্যে
        protected void btnSearchNew_Click(object sender, EventArgs e)
        {
            DateTime from, till;
            if (!TryDate(txtFromDate, out from) || !TryDate(txtTillDate, out till))
            {
                Toast("From Date ও Till Date দিন।");
                return;
            }

            try
            {
                DataTable dt = Query(
                    "SELECT * FROM View_Lefty_Search WHERE CAST(Absent_Date AS date) BETWEEN @a AND @b",
                    P("@a", from), P("@b", till));
                dt = ApplyFilters(dt);
                Bind(dt, true);
            }
            catch (Exception ex) { Toast("Error: " + ex.Message); }
        }

        // 1st / 2nd / 3rd Letter Search (Multi Date নিচের From–Till)
        protected void btnSearchLetter_Command(object sender, CommandEventArgs e)
        {
            string col;
            switch (e.CommandArgument as string)
            {
                case "1": col = "Letter_issue_Date"; break;
                case "2": col = "Secend_Later_Date"; break;
                case "3": col = "Thard_Date"; break;
                default: return;
            }

            DateTime from, till;
            if (!TryDate(txtMultiFrom, out from))
            {
                Toast("From তারিখ দিন।");
                return;
            }

            try
            {
                DataTable dt;
                if (chkMulti.Checked)
                {
                    if (!TryDate(txtMultiTill, out till))
                    {
                        Toast("Till তারিখ দিন।");
                        return;
                    }
                    dt = Query("SELECT * FROM View_Lefty_Search WHERE CAST(" + col + " AS date) BETWEEN @a AND @b",
                        P("@a", from), P("@b", till));
                }
                else
                {
                    dt = Query("SELECT * FROM View_Lefty_Search WHERE CAST(" + col + " AS date) = @a",
                        P("@a", from));
                }
                dt = ApplyFilters(dt);
                Bind(dt, false);
            }
            catch (Exception ex) { Toast("Error: " + ex.Message); }
        }

        // ================= Letter Process =================
        // ডেক্সটপ: Pro_lefty_employee_{1st|2nd|3rd}_letter_process (@ID_No, @1st_Date, @manual_Date)
        protected void btnProc_Command(object sender, CommandEventArgs e)
        {
            int n;
            if (!int.TryParse(Convert.ToString(e.CommandArgument), out n) || n < 1 || n > 3) return;

            CheckBox chk = n == 1 ? chk1st : n == 2 ? chk2nd : chk3rd;
            TextBox dateBox = n == 1 ? txtDate1 : n == 2 ? txtDate2 : txtDate3;
            string ord = n == 1 ? "1st" : n == 2 ? "2nd" : "3rd";

            if (!chk.Checked)
            {
                Toast(ord + " Letter চেকবক্সে টিক দিন।");
                return;
            }

            long[] ids = SelectedLongIds();
            if (ids.Length == 0)
            {
                Toast("কমপক্ষে একজন কর্মচারী নির্বাচন করুন।");
                return;
            }
            if (ids.Length > MaxIds)
            {
                Toast("Too many IDs (max " + MaxIds + ").");
                return;
            }

            DateTime d;
            if (!TryDate(dateBox, out d))
            {
                Toast(ord + " Letter এর তারিখ দিন।");
                return;
            }

            string proc = "Pro_lefty_employee_" + ord + "_letter_process";
            string dateParam = "@" + ord + "_Date";
            bool manual = chkManual.Checked;

            try
            {
                // সব একটি transaction এ: কোনোটি ব্যর্থ হলে কিছুই সেভ হয় না
                InTransaction((con, tx) =>
                {
                    foreach (long id in ids)
                    {
                        using (var cmd = new SqlCommand(proc, con, tx))
                        {
                            cmd.CommandType = CommandType.StoredProcedure;
                            cmd.Parameters.Add("@ID_No", SqlDbType.BigInt).Value = id;
                            cmd.Parameters.Add(dateParam, SqlDbType.DateTime).Value = d;
                            cmd.Parameters.Add("@manual_Date", SqlDbType.Bit).Value = manual;
                            cmd.ExecuteNonQuery();
                        }
                    }
                });
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message);
                return;
            }

            Toast("Selected Employees " + ord + " Letter Process Success. (" + ids.Length + " জন)");
        }

        // ================= Letter View (নতুন ট্যাবে রিপোর্ট) =================
        // 1st Letter View: ক্লিক ইভেন্ট
        protected void btnV1_Click(object sender, EventArgs e)
        {
            OpenReport("Fast_Latter", 0);
        }

        // বাকি View বাটন: CommandArgument = "reportName|probation"  (probation: 0, 1, অথবা -1 = শর্ত নেই)
        protected void btnView_Command(object sender, CommandEventArgs e)
        {
            string[] parts = Convert.ToString(e.CommandArgument).Split('|');
            int probation;
            if (parts.Length < 2 || !int.TryParse(parts[1], out probation)) probation = -1;
            OpenReport(parts[0], probation);
        }

        void OpenReport(string report, int probation)
        {
            string page;
            if (!AllowedReports.Contains(report) || !ReportPages.TryGetValue(report, out page))
            {
                Toast("এই রিপোর্টের ওয়েব পেজ এখনও যোগ করা হয়নি।");
                return;
            }

            long[] ids = SelectedLongIds();
            if (ids.Length == 0)
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
                // ডেক্সটপের মতো: আগে Pro_z_Test_ID_Delete (সবার জন্য), তারপর Pro_z_Test_ID (সবার জন্য)
                InTransaction((con, tx) =>
                {
                    foreach (long id in ids) RunIdProc(con, tx, "Pro_z_Test_ID_Delete", id);
                    foreach (long id in ids) RunIdProc(con, tx, "Pro_z_Test_ID", id);
                });
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message);
                return;
            }

            // ফর্ম target=_blank থাকায় এই রেসপন্স নতুন ট্যাবে যায়: সেখানে রিপোর্ট পেজ খোলে
            string url = ResolveUrl(page) + "?report=" + Server.UrlEncode(report) +
                         (probation >= 0 ? "&probation=" + probation : "");
            Response.Redirect(url, false);
            Context.ApplicationInstance.CompleteRequest();
        }

        static void RunIdProc(SqlConnection con, SqlTransaction tx, string proc, long id)
        {
            using (var cmd = new SqlCommand(proc, con, tx))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("@ID_No", SqlDbType.BigInt).Value = id;
                cmd.ExecuteNonQuery();
            }
        }

        // ================= Clear =================
        protected void btnClear_Click(object sender, EventArgs e)
        {
            filters.ClearSelections();
            SelectAllStatus();

            hfSelIds.Value = "";
            txtMultiId.Text = "";
            SetDefaultDates();
            chkManual.Checked = chkMulti.Checked = false;
            chk1st.Checked = chk2nd.Checked = chk3rd.Checked = false;

            ClearGrid();
            Toast("All filters cleared.");
        }

        // ================= সাহায্যকারী: ডেটা =================

        // View_Lefty_Search এর ফলাফলে ড্রপডাউন ফিল্টার (Branch, Dept ...) প্রয়োগ
        // HRFilters.QueryEmployees থেকে মিলে যাওয়া ID নিয়ে ফলাফল ছেঁকে নেওয়া হয়
        DataTable ApplyFilters(DataTable dt)
        {
            bool anySelected = new[] { ddBranch, ddCategory, ddDept, ddSection, ddSubSec, ddFloor, ddDesig, ddLevel }
                .Any(l => l.GetSelectedIndices().Length > 0);

            if (!anySelected && IsAll(StatusText())) return dt;   // কোনো ফিল্টার নেই

            var allowed = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            using (SqlConnection con = conn.openConnection())
            {
                if (con.State != ConnectionState.Open) con.Open();
                DataTable emp = filters.QueryEmployees(con, StatusText(), "", "", new string[0], new List<string>());
                foreach (DataRow r in emp.Rows)
                    allowed.Add(Col(r, "", "ID_no", "Id", "Emp_ID").Trim());
            }

            DataTable result = dt.Clone();
            foreach (DataRow r in dt.Rows)
                if (allowed.Contains(Col(r, "", "ID_no", "Id", "Emp_ID").Trim()))
                    result.ImportRow(r);
            return result;
        }

        DataTable Query(string sql, params SqlParameter[] ps)
        {
            var dt = new DataTable();
            using (SqlConnection con = conn.openConnection())
            {
                if (con.State != ConnectionState.Open) con.Open();
                using (var cmd = new SqlCommand(sql, con))
                {
                    if (ps != null && ps.Length > 0) cmd.Parameters.AddRange(ps);
                    using (var da = new SqlDataAdapter(cmd)) da.Fill(dt);
                }
            }
            return dt;
        }

        static SqlParameter P(string name, DateTime value)
        {
            return new SqlParameter(name, SqlDbType.Date) { Value = value.Date };
        }

        void InTransaction(Action<SqlConnection, SqlTransaction> work)
        {
            using (SqlConnection con = conn.openConnection())
            {
                if (con.State != ConnectionState.Open) con.Open();
                using (SqlTransaction tx = con.BeginTransaction())
                {
                    try
                    {
                        work(con, tx);
                        tx.Commit();
                    }
                    catch
                    {
                        tx.Rollback();
                        throw;
                    }
                }
            }
        }

        static bool TryDate(TextBox box, out DateTime d)
        {
            string s = (box.Text ?? "").Trim();
            return DateTime.TryParseExact(s, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out d)
                   || DateTime.TryParse(s, out d);
        }

        // টিক দেওয়া ID গুলো
        string SelectedIdsRaw()
        {
            string[] fromForm = Request.Form.GetValues("selId");
            if (fromForm != null && fromForm.Length > 0)
                return string.Join(",", fromForm);
            return hfSelIds.Value ?? "";
        }

        long[] SelectedLongIds()
        {
            return HRFilters.ParseIds(SelectedIdsRaw())
                .Select(s => { long x; return long.TryParse(s, out x) ? x : 0; })
                .Where(x => x != 0).Distinct().ToArray();
        }

        // ================= ফলাফল দেখানো =================
        void Bind(DataTable dt, bool selectAll)
        {
            var list = new List<LeftyRow>();
            foreach (DataRow r in dt.Rows)
            {
                list.Add(new LeftyRow
                {
                    Id = Col(r, "", "ID_no", "Id", "Emp_ID"),
                    Name = Col(r, "", "Name", "Emp_Name"),
                    Designation = Col(r, "", "Designation", "Desigation_name"),
                    AbsentDate = DateCol(r, "Absent_Date"),
                    FirstDate = DateCol(r, "Letter_issue_Date"),
                    SecondDate = DateCol(r, "Secend_Later_Date"),
                    ThirdDate = DateCol(r, "Thard_Date")
                });
            }

            rptEmployees.DataSource = list;
            rptEmployees.DataBind();
            trEmpty.Visible = list.Count == 0;
            rebound = true;

            lblCount.Text = list.Count + " Records";
            litPaging.Text = list.Count == 0
                ? "Showing 0 entries"
                : "Showing <span class=\"font-medium text-slate-700\">1</span> to <span class=\"font-medium text-slate-700\">" + list.Count +
                  "</span> of <span class=\"font-medium text-slate-700\">" + list.Count + "</span> entries";

            // ডেক্সটপের মতো: New letter / ID সার্চে সবাইকে টিক দেওয়া
            if (selectAll && list.Count > 0)
            {
                ClientScript.RegisterStartupScript(GetType(), "chkall",
                    "document.addEventListener('DOMContentLoaded',function(){document.querySelectorAll('.row-checkbox,#selectAllRows').forEach(function(c){c.checked=true;});});", true);
            }
        }

        void ClearGrid()
        {
            rptEmployees.DataSource = null;
            rptEmployees.DataBind();
            trEmpty.Visible = false;
            rebound = true;
            lblCount.Text = "0 Records";
            litPaging.Text = "Showing 0 entries";
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

        static string DateCol(DataRow r, string name)
        {
            if (!r.Table.Columns.Contains(name) || r[name] == DBNull.Value) return "";
            DateTime d;
            return DateTime.TryParse(Convert.ToString(r[name]), out d)
                ? d.ToString("dd-MMM-yyyy", CultureInfo.InvariantCulture)
                : Convert.ToString(r[name]);
        }

        void Toast(string msg)
        {
            string js = "document.addEventListener('DOMContentLoaded',function(){showNotification(" +
                        new JavaScriptSerializer().Serialize(msg) + ");});";
            ClientScript.RegisterStartupScript(GetType(), "toast" + Guid.NewGuid().ToString("N"), js, true);
        }
    }
}
