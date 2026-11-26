using Nexa_ERP.Connection;
using Nexa_ERP.HRMPayroll.Common;
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
    public partial class LeaveReports : Page
    {
        PayrollDB conn = new PayrollDB();

        // পাবলিক ফিল্টার ক্লাস
        HRFilters filters;

        const int MaxIds = HRFilters.MaxIds;

        readonly List<string> loadErrors = new List<string>();

        // সমস্যা মিটে গেলে false করে দিন
        const bool ShowDebug = true;
        readonly List<string> debug = new List<string>();

        // Soft_Reports টেবিলে রিপোর্ট পেজের লিংকের কলাম
        const string LinkColumn = "ReportPageLink";

        // TODO: Soft_Reports এ শুধু Leave রিপোর্ট দেখাতে চাইলে এখানে শর্ত দিন।
        // যেমন: " AND Report_Group='Leave'"  (ফাঁকা থাকলে HRMReports এর মতোই সব Menu=1 রিপোর্ট আসবে)
        const string ReportExtraFilter = "";

        // একই request এ বারবার DB তে না গিয়ে লিংকের তালিকা একবারই লোড
        Dictionary<string, string> reportLinks;

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

        long UserCode { get { return HRFilters.UserCode; } }
        long FromCode { get { return HRFilters.SessionLong("From_Code", "FromCode"); } }

        List<string> AllErrors()
        {
            return loadErrors.Concat(filters.Errors).ToList();
        }

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
            filters.EmptyMeansAll = false;   // কিছু না বাছলে কিছুই insert হবে না

            filters.LoadLookups();

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
            filters.FillControls();

            FillStatic(ddBlood, "-- All --", "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-");
            FillStatic(ddReligion, "-- All --", "Islam", "Hinduism", "Buddhism", "Christianity", "Others");
            FillStatic(ddStatus, null, "Active", "New", "Seperation", "All", "Resign", "Left");

            LoadReportTypes();

            if (AllErrors().Count > 0)
                Toast("Option load error: " + string.Join(" | ", AllErrors()));
        }

        // Text = Report_Name, Value = Report_Code
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
                        "WHERE Menu=1" + ReportExtraFilter + " ORDER BY Report_Name ASC", con))
                    {
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

        // ===== Soft_Reports এর ReportPageLink কলাম থেকে: Report_Code -> রিপোর্ট পেজের লিংক =====
        Dictionary<string, string> ReportLinks()
        {
            if (reportLinks != null) return reportLinks;

            reportLinks = new Dictionary<string, string>();
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();

                    using (var cmd = new SqlCommand(
                        "SELECT Report_Code, [" + LinkColumn + "] AS Link FROM Soft_Reports WHERE Menu=1" + ReportExtraFilter, con))
                    {
                        var dt = new DataTable();
                        using (var da = new SqlDataAdapter(cmd)) da.Fill(dt);

                        foreach (DataRow r in dt.Rows)
                        {
                            string link = Convert.ToString(r["Link"]).Trim();
                            if (link.Length == 0) continue;
                            reportLinks[Convert.ToString(r["Report_Code"])] = link;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                loadErrors.Add("reportLink: " + ex.Message);
            }
            return reportLinks;
        }

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

        protected void Page_PreRender(object sender, EventArgs e)
        {
            var links = ReportLinks();
            var map = new Dictionary<string, bool>();
            foreach (ListItem it in ddRType.Items)
                if (links.ContainsKey(it.Value)) map[it.Value] = true;   // true = কর্মচারী নির্বাচন লাগবে

            ClientScript.RegisterStartupScript(GetType(), "rpts",
                "window.RESOLVED_REPORTS=" + new JavaScriptSerializer().Serialize(map) + ";", true);
        }

        protected void btnReport_Click(object sender, EventArgs e)
        {
            string code = ddRType.SelectedValue;
            string rt = RTypeText();

            string link;
            if (ReportLinks().TryGetValue(code, out link))
                OpenReport(link, true);
            else if (ShowData())
                Toast("Report generated successfully! (Type: " + rt + ")");
        }

        string SelectedIdsRaw()
        {
            string[] fromForm = Request.Form.GetValues("selId");
            if (fromForm != null && fromForm.Length > 0)
                return string.Join(",", fromForm);
            return hfSelIds.Value ?? "";
        }

        // নির্বাচিত ID z_Test_ID তে সেভ করে রিপোর্ট পেজে পাঠানো
        void OpenReport(string page, bool needIds)
        {
            int token = 1000000000 + (int)(DateTime.Now - new DateTime(2020, 1, 1)).TotalSeconds;

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
                        "DELETE FROM dbo.z_Test_ID WHERE User_ID=@u AND (From_Code=@t OR (From_Code>=1000000000 AND From_Code<@old))", con))
                    {
                        del.Parameters.Add("@u", SqlDbType.BigInt).Value = UserCode;
                        del.Parameters.Add("@t", SqlDbType.BigInt).Value = token;
                        del.Parameters.Add("@old", SqlDbType.BigInt).Value = token - 86400;
                        del.ExecuteNonQuery();
                    }

                    if (needIds)
                    {
                        foreach (long id in ids)
                            HRDb.ExecProc(con, "Pro_z_Test_ID_New",
                                HRDb.P("@ID_No", id), HRDb.P("@User_ID", UserCode), HRDb.P("@Form_Code", token));
                    }
                }
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message);
                return;
            }

            string url = ResolveClientUrl(page);

            url = System.Text.RegularExpressions.Regex.Replace(url, @"([?&])(rc|jf|jt)=[^&]*&?", "$1");
            url = url.TrimEnd('?', '&');

            string sep = url.Contains("?") ? "&" : "?";
            url = url + sep + "rc=" + token;

            // ড্যাশবোর্ডে From/Till Date দেওয়া থাকলে রিপোর্টে সেটি যাবে
            DateTime d1, d2;
            if (DateTime.TryParse(txtFromDate.Text, out d1))
                url += "&jf=" + d1.ToString("yyyy-MM-dd");
            if (DateTime.TryParse(txtTillDate.Text, out d2))
                url += "&jt=" + d2.ToString("yyyy-MM-dd");

            Response.Redirect(url, false);
            Context.ApplicationInstance.CompleteRequest();
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

            lblReportTitle.Text = string.IsNullOrEmpty(RTypeText()) ? "Leave Report" : RTypeText();
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
            filters.ClearSelections();

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

            lblReportTitle.Text = string.IsNullOrEmpty(RTypeText()) ? "Leave Report" : RTypeText();
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