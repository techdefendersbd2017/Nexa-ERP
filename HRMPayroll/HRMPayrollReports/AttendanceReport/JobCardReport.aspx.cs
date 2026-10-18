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

namespace Nexa_ERP.HRMPayroll.HRMPayrollReports.AttendanceReport
{
    // ব্যবহার: JobCardReport.aspx?rc=123&from=2026-10-01&till=2026-10-15
    // rc  = Attendance Reports পেজ থেকে আসা ব্যাচ কোড (z_Test_ID.From_Code)
    public partial class JobCardReport : System.Web.UI.Page
    {
        PayrollDB conn = new PayrollDB();

        const string DateFormat = "dd-MM-yyyy";

        // ---- ডাটার মান অনুযায়ী এখানেই বদলান ----
        const string StatusPresent = "Present";
        const string StatusLate = "Late";
        const string StatusAbsent = "Absent";
        const string StatusWeekend = "WO";

        const string Sql =
            "SELECT e.ID_no, e.Name, e.Joining_Date, c.Company_Name, c.Address, " +
            "       a.Work_date, a.org_in_time, a.org_out_time, a.att_status, a.Late_min, a.OT_Hours, a.Holiday, " +
            "       sh.Shift_Name AS Shift, sh.In_Time AS Shift_In, sh.Out_Time AS Shift_Out, " +
            "       d.Department_Name AS Department, s.Section_Name AS Section, l.Line_Name AS Line, " +
            "       g.Desigation_name AS Designation " +
            "FROM dbo.emp_Attendance a " +
            "INNER JOIN dbo.Employee_information_new e ON a.EMP_NO = e.Emp_no " +
            "INNER JOIN dbo.Employee_information_With_Code ec ON e.ID_no = ec.ID_no " +
            "INNER JOIN dbo.TB_Company c ON ec.Company_Code = c.Company_Code " +
            "INNER JOIN dbo.TB_Shift sh ON a.Shift_Code = sh.Shift_Code " +
            "INNER JOIN dbo.TB_Department d ON ec.Department_Code = d.Department_Code " +
            "INNER JOIN dbo.TB_Section s ON ec.Section_Code = s.Section_Code " +
            "INNER JOIN dbo.TB_Line l ON ec.Line_Code = l.Line_Code " +
            "INNER JOIN dbo.TB_Designation g ON ec.Designation_Code = g.Designation_Code " +
            "INNER JOIN dbo.z_Test_ID z ON e.ID_no = z.ID_No " +
            "WHERE z.User_ID = @u AND z.From_Code = @rc " +
            "  AND a.Work_date >= @from AND a.Work_date < DATEADD(day, 1, @till) " +
            "ORDER BY e.ID_no, a.Work_date";

        protected void Page_Load(object sender, EventArgs e)
        {
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
            try { dt = Load(userCode, rc, from, till); }
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
            int emp = 0;
            foreach (var g in dt.AsEnumerable().GroupBy(r => Pick(r, "ID_no")))
            {
                RenderEmployee(sb, g.ToList());
                emp++;
            }

            litReport.Text = sb.ToString();
            litCount.Text = emp + " employee(s)";
        }

        DataTable Load(long user, long rc, DateTime from, DateTime till)
        {
            var dt = new DataTable();
            using (SqlConnection con = conn.openConnection())
            {
                if (con.State != ConnectionState.Open) con.Open();
                using (var cmd = new SqlCommand(Sql, con))
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

        // ================= একজন কর্মীর পাতা =================
        static void RenderEmployee(StringBuilder sb, List<DataRow> rows)
        {
            DataRow f = rows[0];

            sb.Append("<section class=\"page\">");
            sb.Append("<div class=\"co\">" + Enc(Pick(f, "Company_Name")) + "</div>");
            sb.Append("<div class=\"ad\">" + Enc(Pick(f, "Address")) + "</div>");
            sb.Append("<div class=\"ttl\">Employee Job Card</div>");

            DateTime jd;
            string join = DateTime.TryParse(Pick(f, "Joining_Date"), CultureInfo.InvariantCulture, DateTimeStyles.None, out jd)
                ? jd.ToString(DateFormat, CultureInfo.InvariantCulture) : "";
            string shiftTime = Tm(f["Shift_In"]).ToUpperInvariant() + " To " + Tm(f["Shift_Out"]).ToUpperInvariant();

            sb.Append("<table class=\"info\">");
            sb.Append(Info("Employee ID", Pick(f, "ID_no"), "Joining Date", join));
            sb.Append(Info("Employee Name", Pick(f, "Name"), "Shift In & Out", shiftTime));
            sb.Append(Info("Designation", Pick(f, "Designation"), "Section", Pick(f, "Section")));
            sb.Append(Info("Department", Pick(f, "Department"), "Line", Pick(f, "Line")));
            sb.Append("</table>");

            sb.Append("<table class=\"rp\"><thead><tr><th>Work Date</th><th>Day</th><th>Working Shift</th><th>In Time</th>" +
                      "<th>Out Time</th><th>Late (min)</th><th>OT</th><th>Status</th></tr></thead><tbody>");

            int present = 0, late = 0, absent = 0, wo = 0, gh = 0, fh = 0, cl = 0, sl = 0, ml = 0, el = 0, sp = 0, lwp = 0;
            decimal otTotal = 0;

            foreach (DataRow r in rows)
            {
                DateTime wd = Convert.ToDateTime(r["Work_date"]);
                string st = Pick(r, "att_status");
                string holiday = Pick(r, "Holiday");
                bool isHol = holiday.Length > 0 && !new[] { "0", "No", "N/A", "--" }.Contains(holiday, StringComparer.OrdinalIgnoreCase);

                decimal ot = Dec(r["OT_Hours"]);
                otTotal += ot;

                string cls = "";
                switch (st.ToUpperInvariant())
                {
                    case "PRESENT": present++; break;
                    case "LATE": present++; late++; cls = "late"; break;
                    case "ABSENT": absent++; cls = "abs"; break;
                    case "WO": wo++; cls = "wo"; break;
                    case "GH": gh++; cls = "wo"; break;
                    case "FH": fh++; cls = "wo"; break;
                    case "CL": cl++; break;
                    case "SL": sl++; break;
                    case "ML": ml++; break;
                    case "EL": el++; break;
                    case "SPL": sp++; break;
                    case "LWP": lwp++; break;
                    default: if (isHol) { gh++; cls = "wo"; } break;
                }

                sb.Append("<tr class=\"" + cls + "\">");
                sb.Append("<td class=\"c\">" + wd.ToString(DateFormat, CultureInfo.InvariantCulture) + "</td>");
                sb.Append("<td class=\"c\">" + wd.ToString("ddd", CultureInfo.InvariantCulture) + "</td>");
                sb.Append("<td class=\"c\">" + Enc(Pick(r, "Shift")) + "</td>"); 
                sb.Append("<td class=\"c\">" + Enc(Tm(r["org_in_time"]).ToUpperInvariant()) + "</td>");
                sb.Append("<td class=\"c\">" + Enc(Tm(r["org_out_time"]).ToUpperInvariant()) + "</td>");
                sb.Append("<td class=\"c\">" + Dec(r["Late_min"]).ToString("0", CultureInfo.InvariantCulture) + "</td>");
                sb.Append("<td class=\"c\">" + ot.ToString("0.00", CultureInfo.InvariantCulture) + "</td>");
                sb.Append("<td class=\"c st\">" + Enc(st) + "</td>");
                sb.Append("</tr>");
            }
            sb.Append("</tbody></table>");

            sb.Append("<table class=\"sm\"><tr><th>Total Days</th><th>Present Days</th><th>Late Days</th><th>Absent Days</th>" +
                      "<th>Weekend</th><th>General Holiday</th><th>Festival Holiday</th><th>OT Hour</th></tr><tr>" +
                      "<td>" + rows.Count + "</td><td>" + present + "</td><td>" + late + "</td><td>" + absent + "</td>" +
                      "<td>" + wo + "</td><td>" + gh + "</td><td>" + fh + "</td><td>" + otTotal.ToString("0.0", CultureInfo.InvariantCulture) + "</td></tr></table>");

            sb.Append("<table class=\"sm\"><tr><th>Casual Leave</th><th>Sick Leave</th><th>Maternity Leave</th><th>Earn Leave</th>" +
                      "<th>Special Leave</th><th>Leave Without Pay</th></tr><tr>" +
                      "<td>" + cl + "</td><td>" + sl + "</td><td>" + ml + "</td><td>" + el + "</td><td>" + sp + "</td><td>" + lwp + "</td></tr></table>");

            sb.Append("<div class=\"signs\"><div>Employee</div><div>Prepared By</div><div>HR / Admin</div><div>Authorised</div></div>");
            sb.Append("<div class=\"stamp\"><span>" + DateTime.Now.ToString("dd-MM-yy hh:mm:sstt", CultureInfo.InvariantCulture) + "</span></div>");
            sb.Append("</section>");
        }

        static string Info(string l1, string v1, string l2, string v2)
        {
            return "<tr><td class=\"l\">" + Enc(l1) + "</td><td class=\"s\">:</td><td>" + Enc(v1) + "</td>" +
                   "<td class=\"l\">" + Enc(l2) + "</td><td class=\"s\">:</td><td>" + Enc(v2) + "</td></tr>";
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
            return d.ToString("hh:mmtt", CultureInfo.InvariantCulture);
        }

        static decimal Dec(object o)
        {
            if (o == null || o == DBNull.Value) return 0;
            decimal v;
            return decimal.TryParse(Convert.ToString(o), NumberStyles.Any, CultureInfo.InvariantCulture, out v) ? v : 0;
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
