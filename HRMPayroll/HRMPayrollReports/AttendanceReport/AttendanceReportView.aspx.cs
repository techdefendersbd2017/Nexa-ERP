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

        // Download বাটনের জন্য (প্রতিটি তারিখের পাতার ডাটা)
        List<RptSection> exportSecs;
        string exportName = "Attendance_Report";

        const string DateFormat = "dd-MMM-yyyy";

        // ---- ডাটার মান অনুযায়ী এখানেই বদলান ----
        const string StatusPresent = "Present";
        const string StatusAbsent = "Absent";

        // emp_Attendance.Holiday কলামে এই মানগুলো ছাড়া কিছু থাকলে সেই দিন ছুটির দিন ধরা হয়
        const string IsHoliday = "ISNULL(LTRIM(RTRIM(CAST(a.Holiday AS nvarchar(50)))),'') NOT IN ('','0','No','N/A','--')";

        // ছুটির দিনের স্ট্যাটাস (WO = Weekly Off, FH = Festival Holiday, GH = Govt Holiday)
        const string HolidayStatuses = "'WO','FH','GH'";

        // পাঞ্চ আছে = In Time ফাঁকা নয় এবং 00:00 নয় (time / datetime যেকোনো টাইপে কাজ করবে)
        const string HasPunch = "(a.org_in_time IS NOT NULL AND CAST(a.org_in_time AS time) <> '00:00:00')";

        // গতকালের স্ট্যাটাস এগুলো হলে তারও আগের দিন দেখা হবে
        const string SkipStatuses = "'WO','CL','SL','EL','FH','GH'";

        // প্রতিটি কর্মচারীর আজকের আগের সর্বশেষ দিন (SkipStatuses বাদে) এর স্ট্যাটাস
        const string PrevStatus = "(SELECT TOP 1 prv.att_status FROM dbo.emp_Attendance AS prv " +
                                  "WHERE prv.EMP_NO = a.EMP_NO AND CAST(prv.Work_date AS date) < CAST(a.Work_date AS date) " +
                                  "AND ISNULL(prv.att_status,'') NOT IN (" + SkipStatuses + ") " +
                                  "ORDER BY prv.Work_date DESC)";

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

            // ছুটির দিনে (WO/FH/GH) যাদের পাঞ্চ আছে => Holiday Present
            // (ছুটির দিনে সিস্টেম যদি Present স্ট্যাটাস বসিয়ে দেয় এবং Holiday কলামে মান থাকে, সেটাও ধরা হবে)
            { "HolidayPresent", new Def { Title = "Holiday Present Report",
                Where = "((ISNULL(a.att_status,'') IN (" + HolidayStatuses + ") AND " + HasPunch + ") " +
                        "OR (a.att_status = '" + StatusPresent + "' AND (" + IsHoliday + ")))",
                TotalLabel = "Total Holiday Present" } },

            // ছুটির দিনে (WO/FH/GH) যাদের পাঞ্চ নেই => Holiday Absent
            { "HolidayAbsent",  new Def { Title = "Holiday Absent Report",
                Where = "((ISNULL(a.att_status,'') IN (" + HolidayStatuses + ") AND NOT " + HasPunch + ") " +
                        "OR (a.att_status = '" + StatusAbsent + "' AND (" + IsHoliday + ")))",
                TotalLabel = "Total Holiday Absent", AbsentLayout = true } },

            { "TodayPresentYesterdayAbsent", new Def { Title = "Today Present Yesterday Absent Report", Where = "a.att_status = '" + StatusPresent + "' AND NOT (" + IsHoliday + ") AND " + PrevStatus + " = '" + StatusAbsent + "'", TotalLabel = "Total Today Present Yesterday Absent" } }
        };

        const string BaseSql = @"SELECT e.ID_no,e.Name, c.Company_Name, c.Address, a.Work_date, a.org_in_time AS in_time, a.org_out_time AS out_time, a.att_status, 
a.Late_min, a.Remarks, a.Holiday, a.Total_Absent, d.Department_Name AS Department, s.Section_Name AS Section, l.Line_Name AS Line, g.Desigation_name AS Designation,p.Personal_Phone, 
CONCAT(RIGHT('0' + CAST(ISNULL(a.OT_Hours, 0) AS VARCHAR(2)), 2), ':', RIGHT('0' + CAST(ISNULL(a.OT_Minits, 0) AS VARCHAR(2)), 2)) AS OT_Hours FROM dbo.emp_Attendance AS a
INNER JOIN dbo.Employee_information_new AS e ON a.EMP_NO = e.Emp_no INNER JOIN dbo.Employee_information_With_Code AS ec ON e.ID_no = ec.ID_no
INNER JOIN dbo.TB_Company AS c ON ec.Company_Code = c.Company_Code INNER JOIN dbo.TB_Department AS d ON ec.Department_Code = d.Department_Code INNER JOIN dbo.TB_Section AS s
ON ec.Section_Code = s.Section_Code INNER JOIN dbo.TB_Line AS l ON ec.Line_Code = l.Line_Code INNER JOIN dbo.TB_Designation AS g ON ec.Designation_Code = g.Designation_Code
INNER JOIN dbo.z_Test_ID AS z ON e.ID_no = z.ID_No LEFT OUTER JOIN dbo.Employee_Personal_Information_new AS p ON ec.ID_no = p.ID_No 
WHERE z.User_ID = @u AND z.From_Code = @rc AND a.Work_date >= @from AND a.Work_date<DATEADD(day, 1, @till)";

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

            // Report With Photo টিক দেওয়া থাকলে URL এ photo=1 আসে
            bool withPhoto = Request.QueryString["photo"] == "1";

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

            // টিক থাকলে ছবি লোড, নইলে null (null মানে ছবির কলাম থাকবে না)
            Dictionary<string, string> photos = null;
            if (withPhoto)
            {
                try { photos = LoadPhotos(userCode, rc); }
                catch (Exception ex)
                {
                    litReport.Text = "<div class=\"msg\">Photo Error: " + Enc(ex.Message) + "</div>";
                    return;
                }
            }

            var sb = new StringBuilder();
            exportSecs = new List<RptSection>();
            foreach (var g in dt.AsEnumerable().GroupBy(r => Convert.ToDateTime(r["Work_date"]).Date).OrderBy(g => g.Key))
                exportSecs.Add(RenderDay(sb, def, g.Key, g.ToList(), photos));

            exportName = def.Title.Replace(" ", "_") + "_" + from.ToString("yyyyMMdd", CultureInfo.InvariantCulture) +
                         (till.Date != from.Date ? "_to_" + till.ToString("yyyyMMdd", CultureInfo.InvariantCulture) : "");

            litReport.Text = sb.ToString();
            litCount.Text = dt.Rows.Count + " record(s)";
        }

        DataTable Load(Def def, long user, long rc, DateTime from, DateTime till)
        {
            var dt = new DataTable();
            using (SqlConnection con = conn.openConnection())
            {
                if (con.State != ConnectionState.Open) con.Open();
                string sql = BaseSql.Trim().TrimEnd(';') + " AND (" + def.Where + ") ORDER BY a.Work_date, d.Department_Name, s.Section_Name, e.ID_no";
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

        // নির্বাচিত কর্মচারীদের ছবি: ID_no -> data URI (Emp_Photo.Emp_no = ID_no)
        Dictionary<string, string> LoadPhotos(long user, long rc)
        {
            var map = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
            using (SqlConnection con = conn.openConnection())
            {
                if (con.State != ConnectionState.Open) con.Open();

                // Emp_no ও ID_No এর টাইপ আলাদা হলেও যেন এরর না আসে, তাই দুই পাশেই CAST
                const string sql =
                    "SELECT p.Emp_no, p.Photo FROM dbo.Emp_Photo AS p " +
                    "INNER JOIN dbo.z_Test_ID AS z ON CAST(p.Emp_no AS nvarchar(50)) = CAST(z.ID_No AS nvarchar(50)) " +
                    "WHERE z.User_ID = @u AND z.From_Code = @rc AND p.Photo IS NOT NULL";

                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.CommandTimeout = 120;
                    cmd.Parameters.Add("@u", SqlDbType.BigInt).Value = user;
                    cmd.Parameters.Add("@rc", SqlDbType.BigInt).Value = rc;
                    using (var rd = cmd.ExecuteReader())
                    {
                        while (rd.Read())
                        {
                            byte[] b = rd["Photo"] as byte[];
                            if (b == null || b.Length == 0) continue;

                            // ফাইলের শুরুর বাইট দেখে ছবির ধরন বোঝা
                            string mime = "image/jpeg";
                            if (b.Length > 4 && b[0] == 0x89 && b[1] == 0x50) mime = "image/png";
                            else if (b.Length > 3 && b[0] == 0x47 && b[1] == 0x49) mime = "image/gif";
                            else if (b.Length > 2 && b[0] == 0x42 && b[1] == 0x4D) mime = "image/bmp";

                            map[Convert.ToString(rd["Emp_no"]).Trim()] =
                                "data:" + mime + ";base64," + Convert.ToBase64String(b);
                        }
                    }
                }
            }
            return map;
        }

        // ================= Download (PDF / Word / Excel) =================
        // বাটন চাপলে পেজ আবার লোড হয় (URL এর query একই থাকে), তাই exportSecs Page_Load এ ভরা থাকে
        protected void btnPdf_Click(object sender, EventArgs e)
        {
            if (exportSecs == null || exportSecs.Count == 0) return;
            ReportExport.DownloadPdf(exportSecs, exportName + ".pdf");
        }

        protected void btnWord_Click(object sender, EventArgs e)
        {
            if (exportSecs == null || exportSecs.Count == 0) return;
            ReportExport.DownloadWord(exportSecs, exportName + ".doc");
        }

        protected void btnExcel_Click(object sender, EventArgs e)
        {
            if (exportSecs == null || exportSecs.Count == 0) return;
            ReportExport.DownloadExcel(exportSecs, exportName + ".xls");
        }

        // ================= একদিনের পাতা =================
        // photos == null হলে ছবির কলাম থাকবে না (Download এ ছবি যায় না)
        static RptSection RenderDay(StringBuilder sb, Def def, DateTime day, List<DataRow> rows, Dictionary<string, string> photos)
        {
            bool withPhoto = photos != null;
            DataRow first = rows[0];
            int cols = withPhoto ? 11 : 10;   // ছবি থাকলে একটি কলাম বেশি
            string dayStr = day.ToString(DateFormat, CultureInfo.InvariantCulture);

            // Download এর জন্য একই তথ্য
            var sec = new RptSection
            {
                Company = Pick(first, "Company_Name"),
                Address = Pick(first, "Address"),
                Title = def.Title + " On- " + dayStr,
                Stamp = DateTime.Now.ToString("dd-MM-yy hh:mm:sstt", CultureInfo.InvariantCulture),
                Head = def.AbsentLayout
                    ? new[] { "Sl No", "ID No", "Name", "Designation", "In Time", "Line No", "Mobile No", "Status", "Monthly Absent", "Staff Signature" }
                    : new[] { "Sl No", "ID No", "Name", "Designation", "In Time", "Out Time", "Status", "Late", "OT Hours", "Remarks" },
                Align = def.AbsentLayout
                    ? new[] { 1, 1, 0, 0, 1, 1, 1, 1, 1, 1 }
                    : new[] { 1, 1, 0, 0, 1, 1, 1, 1, 1, 0 },
                Weights = def.AbsentLayout
                    ? new double[] { 4, 7, 17, 15, 8, 8, 11, 8, 8, 14 }
                    : new double[] { 4, 7, 17, 15, 8, 8, 8, 6, 8, 19 }
            };

            sb.Append("<section class=\"page\">");
            sb.Append("<div class=\"co\">" + Enc(Pick(first, "Company_Name")) + "</div>");
            sb.Append("<div class=\"ad\">" + Enc(Pick(first, "Address")) + "</div>");
            sb.Append("<div class=\"ttl\">" + Enc(def.Title) + " On- " + dayStr + "</div>");

            sb.Append("<table class=\"rp\"><thead><tr>");
            string phTh = withPhoto ? "<th>Photo</th>" : "";
            if (def.AbsentLayout)
                sb.Append("<th>Sl No</th><th>ID No</th>" + phTh + "<th>Name</th><th>Designation</th><th>In Time</th><th>Line No</th><th>Mobile No</th><th>Status</th><th>Monthly Absent</th><th>Staff Signature</th>");
            else
                sb.Append("<th>Sl No</th><th>ID No</th>" + phTh + "<th>Name</th><th>Designation</th><th>In Time</th><th>Out Time</th><th>Status</th><th>Late</th><th>OT Hours</th><th>Remarks</th>");
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
                    sec.Rows.Add(new RptRow { IsGroup = true, Text = grp });
                    lastGrp = grp;
                }
                sl++;
                string st = Pick(r, "att_status");
                if (def.AllStatus)
                {
                    string key = st.Length == 0 ? "N/A" : st;
                    int n; statusCount.TryGetValue(key, out n); statusCount[key] = n + 1;
                }

                // ছবির ঘর (শুধু টিক থাকলে); ছবি না পেলে ফাঁকা ঘর
                string phTd = "";
                if (withPhoto)
                {
                    string src;
                    phTd = photos.TryGetValue(Pick(r, "ID_no"), out src)
                        ? "<td class=\"c\"><img class=\"ph\" src=\"" + src + "\" alt=\"\"/></td>"
                        : "<td class=\"c\"></td>";
                }

                sb.Append("<tr><td class=\"c\">" + sl + "</td><td class=\"c\">" + Enc(Pick(r, "ID_no")) + "</td>" + phTd +
                          "<td>" + Enc(Pick(r, "Name")) +
                          "</td><td>" + Enc(Pick(r, "Designation")) + "</td><td class=\"c\">" + Enc(Tm(r["in_time"])) + "</td>");

                if (def.AbsentLayout)
                {
                    sb.Append("<td class=\"c\">" + Enc(Pick(r, "Line")) + "</td><td class=\"c\">" + Enc(Pick(r, "Personal_Phone")) +
                              "</td><td class=\"c\">" + Enc(st) + "</td><td class=\"c\">" + Enc(Pick(r, "Total_Absent")) + "</td><td class=\"sig\"></td>");
                    sec.Rows.Add(new RptRow
                    {
                        Cells = new[] { sl.ToString(), Pick(r, "ID_no"), Pick(r, "Name"), Pick(r, "Designation"),
                        Tm(r["in_time"]), Pick(r, "Line"), Pick(r, "Personal_Phone"), st, Pick(r, "Total_Absent"), "" }
                    });
                }
                else
                {
                    sb.Append("<td class=\"c\">" + Enc(Tm(r["out_time"])) + "</td><td class=\"c\">" + Enc(st) +
                              "</td><td class=\"c\">" + Enc(Num(r["Late_min"])) + "</td><td class=\"c\">" + Enc(Pick(r, "OT_Hours")) +
                              "</td><td>" + Enc(Pick(r, "Remarks")) + "</td>");
                    sec.Rows.Add(new RptRow
                    {
                        Cells = new[] { sl.ToString(), Pick(r, "ID_no"), Pick(r, "Name"), Pick(r, "Designation"),
                        Tm(r["in_time"]), Tm(r["out_time"]), st, Num(r["Late_min"]), Pick(r, "OT_Hours"), Pick(r, "Remarks") }
                    });
                }
                sb.Append("</tr>");
            }

            sb.Append("<tr class=\"tot\"><td colspan=\"" + cols + "\">" + Enc(def.TotalLabel) + " - " + sl + "</td></tr>");
            sec.Rows.Add(new RptRow { IsTotal = true, Text = def.TotalLabel + " - " + sl });
            sb.Append("</tbody></table>");

            if (def.AllStatus)
            {
                sb.Append("<div class=\"summ\">");
                foreach (var kv in statusCount) sb.Append("<span><b>" + Enc(kv.Key) + "</b>: " + kv.Value + "</span>");
                sb.Append("</div>");
                sec.Summary = string.Join("    ", statusCount.Select(kv => kv.Key + ": " + kv.Value).ToArray());
            }

            sb.Append("<div class=\"signs\"><div>Prepared By</div><div>Time Section</div><div>S.V/Line Chief Incharge</div><div>A.P.M/P.M</div><div>Checked by HR</div><div>Approved By</div></div>");
            sb.Append("<div class=\"stamp\"><span>" + sec.Stamp + "</span></div>");
            sb.Append("</section>");

            return sec;
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
