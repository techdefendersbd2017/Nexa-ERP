using Nexa_ERP.Connection;
using Nexa_ERP.HRMPayroll.Common;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.HRMPayroll.HRMPayrollReports.AttendanceReport
{
    public partial class AttendanceReportView : System.Web.UI.Page
    {
        PayrollDB conn = new PayrollDB();

        const string DateFormat = "dd-MMM-yyyy";

        // ---- ডাটার মান অনুযায়ী এখানেই বদলান ----
        const string StatusPresent = "Present";
        const string StatusAbsent = "Absent";
        // emp_Attendance.Holiday কলামে এই মানগুলো ছাড়া কিছু থাকলে সেই দিন ছুটির দিন ধরা হয়
        const string IsHoliday = "ISNULL(LTRIM(RTRIM(CAST(a.Holiday AS nvarchar(50)))),'') NOT IN ('','0','No','N/A','--')";

        class Def
        {
            public string Title;        // রিপোর্টের শিরোনাম (তারিখের আগে)
            public string Where;        // অতিরিক্ত SQL শর্ত
            public bool AbsentLayout;   // true = Absent ধাঁচের কলাম, false = Present ধাঁচের
            public bool AllStatus;      // true = শেষে স্ট্যাটাস অনুযায়ী যোগফল
            public string TotalLabel;
        }

        static readonly Dictionary<string, Def> Reports = new Dictionary<string, Def>(StringComparer.OrdinalIgnoreCase)
        {
            { "Present",        new Def { Title = "Present Report",         Where = "a.att_status = '" + StatusPresent + "' AND NOT (" + IsHoliday + ")", TotalLabel = "Total Present" } },
            { "Absent",         new Def { Title = "Daily Absent Report",    Where = "a.att_status = '" + StatusAbsent  + "' AND NOT (" + IsHoliday + ")", TotalLabel = "Total Absent", AbsentLayout = true } },
            { "AllStatus",      new Def { Title = "All Status Report",      Where = "1=1", TotalLabel = "Total Employee", AllStatus = true } },
            { "HolidayPresent", new Def { Title = "Holiday Present Report", Where = "a.att_status = '" + StatusPresent + "' AND (" + IsHoliday + ")", TotalLabel = "Total Holiday Present" } },
            { "HolidayAbsent",  new Def { Title = "Holiday Absent Report",  Where = "a.att_status = '" + StatusAbsent  + "' AND (" + IsHoliday + ")", TotalLabel = "Total Holiday Absent", AbsentLayout = true } }
        };

        const string BaseSql =
            "SELECT e.ID_no, e.Name, c.Company_Name, c.Address, a.Work_date, a.org_in_time, a.org_out_time, a.att_status, " +
            "       a.Late_min, a.Remarks, a.Holiday, a.Total_Absent, " +
            "       d.Department_Name AS Department, s.Section_Name AS Section, l.Line_Name AS Line, " +
            "       g.Desigation_name AS Designation, p.Personal_Phone " +
            "FROM dbo.emp_Attendance a " +
            "INNER JOIN dbo.Employee_information_new e ON a.EMP_NO = e.Emp_no " +
            "INNER JOIN dbo.Employee_information_With_Code ec ON e.ID_no = ec.ID_no " +
            "INNER JOIN dbo.TB_Company c ON ec.Company_Code = c.Company_Code " +
            "INNER JOIN dbo.TB_Department d ON ec.Department_Code = d.Department_Code " +
            "INNER JOIN dbo.TB_Section s ON ec.Section_Code = s.Section_Code " +
            "INNER JOIN dbo.TB_Line l ON ec.Line_Code = l.Line_Code " +
            "INNER JOIN dbo.TB_Designation g ON ec.Designation_Code = g.Designation_Code " +
            "INNER JOIN dbo.z_Test_ID z ON e.ID_no = z.ID_No " +
            "LEFT JOIN dbo.Employee_Personal_Information_new p ON ec.ID_no = p.ID_No " +
            "WHERE z.User_ID = @u AND z.From_Code = @rc " +
            "  AND a.Work_date >= @from AND a.Work_date < DATEADD(day, 1, @till) ";

        protected void Page_Load(object sender, EventArgs e)
        {
            string report = Request.QueryString["report"] ?? "";
            Def def;
            if (!Reports.TryGetValue(report, out def))
            {
                litReport.Text = "<div class=\"msg\">এই রিপোর্টের (" + Enc(report) + ") লেআউট পাওয়া যায়নি।</div>";
                return;
            }
            litTitle.Text = Enc(def.Title);

            long rc;
            if (!long.TryParse(Request.QueryString["rc"], out rc))
            {
                litReport.Text = "<div class=\"msg\">রিপোর্ট ব্যাচ (rc) পাওয়া যায়নি। Attendance Reports পেজ থেকে Report View চাপুন।</div>";
                return;
            }

            long userCode = HRFilters.UserCode;
            if (userCode == 0)
            {
                litReport.Text = "<div class=\"msg\">User_Code পাওয়া যায়নি (Session)। Login করে আবার চেষ্টা করুন।</div>";
                return;
            }

            DateTime from = ParseDate(Request.QueryString["from"]);
            DateTime till = ParseDate(Request.QueryString["till"]);
            if (till < from) { DateTime t = from; from = till; till = t; }

            DataTable dt;
            try { dt = Load(def, userCode, rc, from, till); }
            catch (Exception ex)
            {
                litReport.Text = "<div class=\"msg\">Error: " + Enc(ex.Message) + "</div>";
                return;
            }

            if (dt.Rows.Count == 0)
            {
                litReport.Text = "<div class=\"msg\">নির্বাচিত কর্মচারী ও তারিখের জন্য কোনো তথ্য পাওয়া যায়নি।</div>";
                litCount.Text = "0";
                return;
            }

            var sb = new StringBuilder();
            foreach (var g in dt.AsEnumerable().GroupBy(r => Convert.ToDateTime(r["Work_date"]).Date).OrderBy(g => g.Key))
                RenderDay(sb, def, g.Key, g.ToList());

            litReport.Text = sb.ToString();
            litCount.Text = dt.Rows.Count + " record(s)";
        }

        DataTable Load(Def def, long user, long rc, DateTime from, DateTime till)
        {
            var dt = new DataTable();
            using (SqlConnection con = conn.openConnection())
            {
                if (con.State != ConnectionState.Open) con.Open();
                string sql = BaseSql + " AND (" + def.Where + ") ORDER BY a.Work_date, d.Department_Name, s.Section_Name, e.ID_no";
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.CommandTimeout = 120;
                    cmd.Parameters.Add("@u", SqlDbType.BigInt).Value = user;
                    cmd.Parameters.Add("@rc", SqlDbType.BigInt).Value = rc;
                    cmd.Parameters.Add("@from", SqlDbType.DateTime).Value = from;
                    cmd.Parameters.Add("@till", SqlDbType.DateTime).Value = till;
                    using (var da = new SqlDataAdapter(cmd)) da.Fill(dt);
                }
            }
            return dt;
        }

        // ================= একদিনের পাতা =================
        static void RenderDay(StringBuilder sb, Def def, DateTime day, List<DataRow> rows)
        {
            DataRow first = rows[0];
            int cols = def.AbsentLayout ? 10 : 9;

            sb.Append("<section class=\"page\">");
            sb.Append("<div class=\"co\">" + Enc(Pick(first, "Company_Name")) + "</div>");
            sb.Append("<div class=\"ad\">" + Enc(Pick(first, "Address")) + "</div>");
            sb.Append("<div class=\"ttl\">" + Enc(def.Title) + " On- " + day.ToString(DateFormat, CultureInfo.InvariantCulture) + "</div>");

            sb.Append("<table class=\"rp\"><thead><tr>");
            if (def.AbsentLayout)
                sb.Append("<th>Sl No</th><th>ID No</th><th>Name</th><th>Designation</th><th>In Time</th><th>Line No</th><th>Mobile No</th><th>Status</th><th>Monthly Absent</th><th>Staff Signature</th>");
            else
                sb.Append("<th>Sl No</th><th>ID No</th><th>Name</th><th>Designation</th><th>In Time</th><th>Out Time</th><th>Status</th><th>Late</th><th>Remarks</th>");
            sb.Append("</tr></thead><tbody>");

            string lastGrp = null;
            int sl = 0;
            var statusCount = new SortedDictionary<string, int>(StringComparer.OrdinalIgnoreCase);

            foreach (DataRow r in rows)
            {
                string grp = "Department: " + Pick(r, "Department") + ", Section: " + Pick(r, "Section");
                if (grp != lastGrp)
                {
                    sb.Append("<tr class=\"grp\"><td colspan=\"" + cols + "\">" + Enc(grp) + "</td></tr>");
                    lastGrp = grp;
                }
                sl++;
                string st = Pick(r, "att_status");
                if (def.AllStatus)
                {
                    string key = st.Length == 0 ? "N/A" : st;
                    int n; statusCount.TryGetValue(key, out n); statusCount[key] = n + 1;
                }

                sb.Append("<tr><td class=\"c\">" + sl + "</td><td class=\"c\">" + Enc(Pick(r, "ID_no")) + "</td><td>" + Enc(Pick(r, "Name")) +
                          "</td><td>" + Enc(Pick(r, "Designation")) + "</td><td class=\"c\">" + Enc(Tm(r["in_time"])) + "</td>");

                if (def.AbsentLayout)
                {
                    sb.Append("<td class=\"c\">" + Enc(Pick(r, "Line")) + "</td><td class=\"c\">" + Enc(Pick(r, "Personal_Phone")) +
                              "</td><td class=\"c\">" + Enc(st) + "</td><td class=\"c\">" + Enc(Pick(r, "Total_Absent")) + "</td><td class=\"sig\"></td>");
                }
                else
                {
                    sb.Append("<td class=\"c\">" + Enc(Tm(r["out_time"])) + "</td><td class=\"c\">" + Enc(st) +
                              "</td><td class=\"c\">" + Enc(Num(r["Late_min"])) + "</td><td>" + Enc(Pick(r, "Remarks")) + "</td>");
                }
                sb.Append("</tr>");
            }

            sb.Append("<tr class=\"tot\"><td colspan=\"" + cols + "\">" + Enc(def.TotalLabel) + " - " + sl + "</td></tr>");
            sb.Append("</tbody></table>");

            if (def.AllStatus)
            {
                sb.Append("<div class=\"summ\">");
                foreach (var kv in statusCount) sb.Append("<span><b>" + Enc(kv.Key) + "</b>: " + kv.Value + "</span>");
                sb.Append("</div>");
            }

            sb.Append("<div class=\"signs\"><div>Prepared By</div><div>Time Section</div><div>S.V/Line Chief Incharge</div><div>A.P.M/P.M</div><div>Checked by HR</div><div>Approved By</div></div>");
            sb.Append("<div class=\"stamp\"><span>" + DateTime.Now.ToString("dd-MM-yy hh:mm:sstt", CultureInfo.InvariantCulture) + "</span></div>");
            sb.Append("</section>");
        }

        // ================= সাহায্যকারী =================
        static DateTime ParseDate(string s)
        {
            DateTime d;
            if (!string.IsNullOrWhiteSpace(s) &&
                (DateTime.TryParseExact(s.Trim(), "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out d) ||
                 DateTime.TryParse(s.Trim(), CultureInfo.InvariantCulture, DateTimeStyles.None, out d)))
                return d.Date;
            return DateTime.Today;
        }

        // 7:59 am ধাঁচে সময়; ফাঁকা/1900-01-01 00:00 হলে ফাঁকা
        static string Tm(object o)
        {
            if (o == null || o == DBNull.Value) return "";
            DateTime d;
            if (o is TimeSpan) d = DateTime.Today.Add((TimeSpan)o);
            else if (o is DateTime) d = (DateTime)o;
            else
            {
                string s = Convert.ToString(o).Trim();
                if (s.Length == 0) return "";
                if (!DateTime.TryParse(s, CultureInfo.InvariantCulture, DateTimeStyles.None, out d)) return s;
            }
            if (d.TimeOfDay == TimeSpan.Zero && d.Year <= 1900) return "";
            return d.ToString("h:mm tt", CultureInfo.InvariantCulture).ToLowerInvariant();
        }

        static string Num(object o)
        {
            if (o == null || o == DBNull.Value) return "0.0";
            decimal v;
            return decimal.TryParse(Convert.ToString(o), NumberStyles.Any, CultureInfo.InvariantCulture, out v)
                ? v.ToString("0.0", CultureInfo.InvariantCulture) : Convert.ToString(o);
        }

        static string Pick(DataRow r, string col)
        {
            if (!r.Table.Columns.Contains(col) || r[col] == DBNull.Value) return "";
            return Convert.ToString(r[col]).Trim();
        }

        static string Enc(string s)
        {
            return System.Web.HttpUtility.HtmlEncode(s ?? "");
        }
    }
}
