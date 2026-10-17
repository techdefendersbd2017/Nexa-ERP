using Nexa_ERP.Connection;
using Nexa_ERP.HRMPayroll.Common;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Text;
using System.Web;
using System.Web.UI;

namespace Nexa_ERP.HRMPayroll.HRMPayrollReports.AttendanceReport
{
    // ব্যবহার: AttendanceSummaryView.aspx?report=Department&rc=123&date=2026-10-15[&layout=A|B]
    // report = Department | Designation | Section | SubSection
    // layout A = Late+Present সহ (Department Wise PDF এর ধাঁচ)
    // layout B = Absent % সহ (Section Wise PDF এর ধাঁচ)
    public partial class AttendanceSummaryView : System.Web.UI.Page
    {
        PayrollDB conn = new PayrollDB();

        const string DateFormat = "dd-MMM-yyyy";

        // ---- ডাটার মান অনুযায়ী এখানেই বদলান ----
        const string StatusPresent = "Present";
        const string StatusLate = "Late";
        const string StatusAbsent = "Absent";
        const string LeaveList = "'CL','SL','ML','EL','SPL','LWP','Leave'";

        class Def
        {
            public string Label;      // শিরোনাম ও কলামের নাম
            public string Expr;       // GROUP BY কলাম (শুধু এখান থেকেই SQL এ যায়)
            public string DefLayout;  // ডিফল্ট লেআউট
        }

        static readonly Dictionary<string, Def> Reports = new Dictionary<string, Def>(StringComparer.OrdinalIgnoreCase)
        {
            { "Department",  new Def { Label = "Department",  Expr = "d.Department_Name",  DefLayout = "A" } },
            { "Designation", new Def { Label = "Designation", Expr = "g.Desigation_name",  DefLayout = "A" } },
            { "Section",     new Def { Label = "Section",     Expr = "s.Section_Name",     DefLayout = "B" } },
            { "SubSection",  new Def { Label = "Sub Section", Expr = "l.Line_Name",        DefLayout = "B" } }
        };

        const string SqlTemplate =
            "SELECT {G} AS Grp, MAX(c.Company_Name) AS Company_Name, MAX(c.Address) AS Address, COUNT(*) AS Total, " +
            "  SUM(CASE WHEN a.att_status = '" + StatusPresent + "' THEN 1 ELSE 0 END) AS Pres, " +
            "  SUM(CASE WHEN a.att_status = '" + StatusLate + "' THEN 1 ELSE 0 END) AS Late, " +
            "  SUM(CASE WHEN a.att_status IN (" + LeaveList + ") THEN 1 ELSE 0 END) AS Leave, " +
            "  SUM(CASE WHEN a.att_status = '" + StatusAbsent + "' THEN 1 ELSE 0 END) AS Absent " +
            "FROM dbo.emp_Attendance a " +
            "INNER JOIN dbo.Employee_information_new e ON a.EMP_NO = e.Emp_no " +
            "INNER JOIN dbo.Employee_information_With_Code ec ON e.ID_no = ec.ID_no " +
            "INNER JOIN dbo.TB_Company c ON ec.Company_Code = c.Company_Code " +
            "INNER JOIN dbo.TB_Department d ON ec.Department_Code = d.Department_Code " +
            "INNER JOIN dbo.TB_Section s ON ec.Section_Code = s.Section_Code " +
            "INNER JOIN dbo.TB_Line l ON ec.Line_Code = l.Line_Code " +
            "INNER JOIN dbo.TB_Designation g ON ec.Designation_Code = g.Designation_Code " +
            "INNER JOIN dbo.z_Test_ID z ON e.ID_no = z.ID_No " +
            "WHERE z.User_ID = @u AND z.From_Code = @rc " +
            "  AND a.Work_date >= @d AND a.Work_date < DATEADD(day, 1, @d) " +
            "GROUP BY {G} ORDER BY {G}";

        protected void Page_Load(object sender, EventArgs e)
        {
            string report = Request.QueryString["report"] ?? "";
            Def def;
            if (!Reports.TryGetValue(report, out def))
            {
                litReport.Text = "<div class=\"msg\">এই রিপোর্টের (" + Enc(report) + ") লেআউট পাওয়া যায়নি।</div>";
                return;
            }

            string layout = (Request.QueryString["layout"] ?? def.DefLayout).Trim().ToUpperInvariant();
            if (layout != "A" && layout != "B") layout = def.DefLayout;

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

            DateTime day = ParseDate(Request.QueryString["date"]);
            string title = def.Label + " Wise Daily Attendance Summary " + day.ToString(DateFormat, CultureInfo.InvariantCulture);
            litTitle.Text = Enc(title);

            DataTable dt;
            try { dt = Load(def, userCode, rc, day); }
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

            litReport.Text = Render(def, layout, title, dt);
            litCount.Text = dt.Rows.Count + " " + Enc(def.Label) + "(s)";
        }

        DataTable Load(Def def, long user, long rc, DateTime day)
        {
            var dt = new DataTable();
            using (SqlConnection con = conn.openConnection())
            {
                if (con.State != ConnectionState.Open) con.Open();
                using (var cmd = new SqlCommand(SqlTemplate.Replace("{G}", def.Expr), con))
                {
                    cmd.CommandTimeout = 120;
                    cmd.Parameters.Add("@u", SqlDbType.BigInt).Value = user;
                    cmd.Parameters.Add("@rc", SqlDbType.BigInt).Value = rc;
                    cmd.Parameters.Add("@d", SqlDbType.DateTime).Value = day;
                    using (var da = new SqlDataAdapter(cmd)) da.Fill(dt);
                }
            }
            return dt;
        }

        static string Render(Def def, string layout, string title, DataTable dt)
        {
            var sb = new StringBuilder();
            DataRow first = dt.Rows[0];
            bool A = layout == "A";

            sb.Append("<section class=\"page\">");
            sb.Append("<div class=\"co\">" + Enc(Pick(first, "Company_Name")) + "</div>");
            sb.Append("<div class=\"ad\">" + Enc(Pick(first, "Address")) + "</div>");
            sb.Append("<div class=\"ttl\">" + Enc(title) + "</div>");

            sb.Append("<table class=\"rp\"><thead><tr><th>Sl</th><th>" + Enc(def.Label) + "</th>");
            if (A) sb.Append("<th>Total Employee</th><th>Leave</th><th>Late</th><th>Present</th><th>Late+Present</th><th>Absent</th>");
            else sb.Append("<th>Total Active</th><th>Present</th><th>Late</th><th>Leave</th><th>Absent</th><th>Absent %</th>");
            sb.Append("</tr></thead><tbody>");

            int sl = 0, tTotal = 0, tPres = 0, tLate = 0, tLeave = 0, tAbs = 0;
            foreach (DataRow r in dt.Rows)
            {
                int total = I(r["Total"]), pres = I(r["Pres"]), late = I(r["Late"]), leave = I(r["Leave"]), abs = I(r["Absent"]);
                sl++; tTotal += total; tPres += pres; tLate += late; tLeave += leave; tAbs += abs;
                string name = Pick(r, "Grp"); if (name.Length == 0) name = "N/A";

                sb.Append("<tr><td class=\"c\">" + sl + "</td><td>" + Enc(name) + "</td>");
                sb.Append(Cells(A, total, pres, late, leave, abs));
                sb.Append("</tr>");
            }

            sb.Append("<tr class=\"gt\"><td></td><td>" + (A ? "Total" : "Grand Total") + "</td>");
            sb.Append(Cells(A, tTotal, tPres, tLate, tLeave, tAbs));
            sb.Append("</tr></tbody></table>");

            sb.Append("<div class=\"signs\"><div>Prepared By</div><div>Time Section</div><div>HR</div><div>A.P.M/P.M</div><div>Approved By</div></div>");
            sb.Append("<div class=\"stamp\"><span>" + DateTime.Now.ToString("dd-MM-yy hh:mm:sstt", CultureInfo.InvariantCulture) + "</span>");
            if (A) sb.Append("<span>Develop By: Techdefendersbd || web.www.techdefendersbd.com || email: support@techdefendersbd.com || Cell: 09611-699318.</span>");
            sb.Append("</div></section>");
            return sb.ToString();
        }

        // A: Total | Leave | Late | Present(শুধু Present) | Late+Present | Absent
        // B: Total | Present(Late সহ) | Late | Leave | Absent | Absent %
        static string Cells(bool A, int total, int pres, int late, int leave, int abs)
        {
            if (A)
                return N(total) + N(leave) + N(late) + N(pres) + N(pres + late) + N(abs);
            int pct = total == 0 ? 0 : (int)Math.Round(abs * 100.0 / total, MidpointRounding.AwayFromZero);
            return N(total) + N(pres + late) + N(late) + N(leave) + N(abs) + "<td class=\"c\">" + pct + "%</td>";
        }

        static string N(int v) { return "<td class=\"c\">" + v + "</td>"; }

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

        static int I(object o)
        {
            return (o == null || o == DBNull.Value) ? 0 : Convert.ToInt32(o);
        }

        static string Pick(DataRow r, string col)
        {
            if (!r.Table.Columns.Contains(col) || r[col] == DBNull.Value) return "";
            return Convert.ToString(r[col]).Trim();
        }

        static string Enc(string s)
        {
            return HttpUtility.HtmlEncode(s ?? "");
        }
    }
}
