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
    // Attendance Register: প্রতিটি কর্মচারীর এক সারিতে নির্বাচিত তারিখের প্রতিদিনের স্ট্যাটাস + শেষে যোগফল।
    // লিংক: AttendanceRegister.aspx?rc=<ব্যাচ>&from=yyyy-MM-dd&till=yyyy-MM-dd[&photo=1]
    // কর্মচারী আসে z_Test_ID থেকে (AttendanceReportView এর মতোই)।
    public partial class AttendanceRegister : System.Web.UI.Page
    {
        PayrollDB conn = new PayrollDB();

        // Download বাটনের জন্য (প্রতিটি Department/Section এর ডাটা)
        List<RptSection> exportSecs;
        string exportName = "Attendance_Register";

        const string DateFormat = "dd-MMM-yyyy";
        const int MaxDays = 31;

        // ---- ডাটার মান অনুযায়ী এখানেই বদলান ----
        const string StatusPresent = "Present";
        const string StatusAbsent = "Absent";
        static readonly string[] HolidayCodes = { "WO", "FH", "GH" };
        static readonly string[] LeaveCodes = { "CL", "SL", "EL" };

        // AttendanceReportView এর BaseSql এর মতোই (শুধু ORDER BY আলাদা)
        const string BaseSql = @"SELECT e.ID_no,e.Name, c.Company_Name, c.Address, a.Work_date, a.att_status, a.Late_min,
d.Department_Name AS Department, s.Section_Name AS Section, g.Desigation_name AS Designation
FROM dbo.emp_Attendance AS a
INNER JOIN dbo.Employee_information_new AS e ON a.EMP_NO = e.Emp_no INNER JOIN dbo.Employee_information_With_Code AS ec ON e.ID_no = ec.ID_no
INNER JOIN dbo.TB_Company AS c ON ec.Company_Code = c.Company_Code INNER JOIN dbo.TB_Department AS d ON ec.Department_Code = d.Department_Code INNER JOIN dbo.TB_Section AS s
ON ec.Section_Code = s.Section_Code INNER JOIN dbo.TB_Designation AS g ON ec.Designation_Code = g.Designation_Code
INNER JOIN dbo.z_Test_ID AS z ON e.ID_no = z.ID_No
WHERE z.User_ID = @u AND z.From_Code = @rc AND a.Work_date >= @from AND a.Work_date<DATEADD(day, 1, @till)
ORDER BY d.Department_Name, s.Section_Name, e.ID_no, a.Work_date";

        // একজন কর্মচারীর এক সারি
        class Emp
        {
            public string Id, Name, Designation, Department, Section;
            public Dictionary<DateTime, string> St = new Dictionary<DateTime, string>();
            public Dictionary<DateTime, decimal> Late = new Dictionary<DateTime, decimal>();
        }

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

            int dayCount = (int)(till.Date - from.Date).TotalDays + 1;
            if (dayCount > MaxDays)
            {
                litReport.Text = "<div class=\"msg\">Register এ সর্বোচ্চ " + MaxDays + " দিন দেখানো যায়। তারিখের ব্যবধান কমিয়ে (যেমন এক মাস) আবার চেষ্টা করুন।</div>";
                return;
            }

            bool withPhoto = Request.QueryString["photo"] == "1";

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

            // তারিখের তালিকা
            var days = new List<DateTime>();
            for (DateTime d = from.Date; d <= till.Date; d = d.AddDays(1)) days.Add(d);

            // কর্মচারী অনুযায়ী সাজানো (ডাটা ইতোমধ্যে Department, Section, ID_no ক্রমে)
            var emps = new List<Emp>();
            var map = new Dictionary<string, Emp>(StringComparer.OrdinalIgnoreCase);
            foreach (DataRow r in dt.Rows)
            {
                string id = Pick(r, "ID_no");
                Emp em;
                if (!map.TryGetValue(id, out em))
                {
                    em = new Emp
                    {
                        Id = id,
                        Name = Pick(r, "Name"),
                        Designation = Pick(r, "Designation"),
                        Department = Pick(r, "Department"),
                        Section = Pick(r, "Section")
                    };
                    map[id] = em;
                    emps.Add(em);
                }
                DateTime wd = Convert.ToDateTime(r["Work_date"]).Date;
                em.St[wd] = Pick(r, "att_status");
                decimal late;
                if (decimal.TryParse(Pick(r, "Late_min"), NumberStyles.Any, CultureInfo.InvariantCulture, out late)) em.Late[wd] = late;
            }

            string company = Pick(dt.Rows[0], "Company_Name");
            string address = Pick(dt.Rows[0], "Address");
            string range = from.ToString(DateFormat, CultureInfo.InvariantCulture) +
                           (till.Date != from.Date ? " To " + till.ToString(DateFormat, CultureInfo.InvariantCulture) : "");

            var sb = new StringBuilder();
            exportSecs = new List<RptSection>();
            foreach (var g in emps.GroupBy(x => x.Department + "|" + x.Section))
            {
                var list = g.ToList();
                exportSecs.Add(RenderGroup(sb, company, address, "Attendance Register : " + range,
                    "Department: " + list[0].Department + ", Section: " + list[0].Section, list, days, photos));
            }

            exportName = "Attendance_Register_" + from.ToString("yyyyMMdd", CultureInfo.InvariantCulture) +
                         (till.Date != from.Date ? "_to_" + till.ToString("yyyyMMdd", CultureInfo.InvariantCulture) : "");

            litReport.Text = sb.ToString();
            litCount.Text = emps.Count + " employee(s)";
        }

        DataTable Load(long user, long rc, DateTime from, DateTime till)
        {
            var dt = new DataTable();
            using (SqlConnection con = conn.openConnection())
            {
                if (con.State != ConnectionState.Open) con.Open();
                using (var cmd = new SqlCommand(BaseSql, con))
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

        // নির্বাচিত কর্মচারীদের ছবি: ID_no -> data URI (AttendanceReportView এর মতোই)
        Dictionary<string, string> LoadPhotos(long user, long rc)
        {
            var map = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
            using (SqlConnection con = conn.openConnection())
            {
                if (con.State != ConnectionState.Open) con.Open();
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
                            string mime = "image/jpeg";
                            if (b.Length > 4 && b[0] == 0x89 && b[1] == 0x50) mime = "image/png";
                            else if (b.Length > 3 && b[0] == 0x47 && b[1] == 0x49) mime = "image/gif";
                            else if (b.Length > 2 && b[0] == 0x42 && b[1] == 0x4D) mime = "image/bmp";
                            map[Convert.ToString(rd["Emp_no"]).Trim()] = "data:" + mime + ";base64," + Convert.ToBase64String(b);
                        }
                    }
                }
            }
            return map;
        }

        // ================= Download (PDF / Word / Excel) =================
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

        // ================= এক Department/Section এর পাতা =================
        static RptSection RenderGroup(StringBuilder sb, string company, string address, string title, string grp,
                                      List<Emp> emps, List<DateTime> days, Dictionary<string, string> photos)
        {
            bool withPhoto = photos != null;
            string stamp = DateTime.Now.ToString("dd-MM-yy hh:mm:sstt", CultureInfo.InvariantCulture);

            // Download এর কাঠামো: Sl, ID, Name, Designation, [দিনগুলো], Present, Absent, Holiday, Leave, Late
            var head = new List<string> { "Sl No", "ID No", "Name", "Designation" };
            var align = new List<int> { 1, 1, 0, 0 };
            var weights = new List<double> { 3, 7, 14, 12 };
            foreach (var d in days) { head.Add(d.Day.ToString()); align.Add(1); weights.Add(2.6); }
            head.AddRange(new[] { "Present", "Absent", "Holiday", "Leave", "Late" });
            for (int i = 0; i < 5; i++) { align.Add(1); weights.Add(5); }

            var sec = new RptSection
            {
                Company = company,
                Address = address,
                Title = title,
                Stamp = stamp,
                Head = head.ToArray(),
                Align = align.ToArray(),
                Weights = weights.ToArray()
            };

            int cols = 4 + days.Count + 5 + (withPhoto ? 1 : 0);

            sb.Append("<section class=\"page\">");
            sb.Append("<div class=\"co\">" + Enc(company) + "</div>");
            sb.Append("<div class=\"ad\">" + Enc(address) + "</div>");
            sb.Append("<div class=\"ttl\">" + Enc(title) + "</div>");
            sb.Append("<div class=\"grpl\">" + Enc(grp) + "</div>");
            sec.Rows.Add(new RptRow { IsGroup = true, Text = grp });

            sb.Append("<table class=\"rg\"><thead><tr>");
            sb.Append("<th class=\"sl\">Sl</th><th class=\"id\">ID No</th>" + (withPhoto ? "<th class=\"ph\">Photo</th>" : "") +
                      "<th class=\"nm\">Name</th><th class=\"ds\">Designation</th>");
            foreach (var d in days)
                sb.Append("<th class=\"dy\">" + d.Day + "<small>" + d.ToString("ddd", CultureInfo.InvariantCulture).Substring(0, 2) + "</small></th>");
            sb.Append("<th class=\"tt\">P</th><th class=\"tt\">A</th><th class=\"tt\">H</th><th class=\"tt\">L</th><th class=\"tt\">Late</th>");
            sb.Append("</tr></thead><tbody>");

            int sl = 0;
            foreach (var em in emps)
            {
                sl++;
                int p = 0, a = 0, h = 0, l = 0, late = 0;
                var cells = new List<string> { sl.ToString(), em.Id, em.Name, em.Designation };

                string phTd = "";
                if (withPhoto)
                {
                    string src;
                    phTd = photos.TryGetValue(em.Id, out src)
                        ? "<td class=\"c\"><img class=\"ph\" src=\"" + src + "\" alt=\"\"/></td>"
                        : "<td class=\"c\"></td>";
                }

                var row = new StringBuilder();
                row.Append("<tr><td class=\"c\">" + sl + "</td><td class=\"c\">" + Enc(em.Id) + "</td>" + phTd +
                           "<td class=\"l\">" + Enc(em.Name) + "</td><td class=\"l\">" + Enc(em.Designation) + "</td>");

                foreach (var d in days)
                {
                    string st;
                    em.St.TryGetValue(d, out st);
                    st = (st ?? "").Trim();

                    string code = "", css = "c";
                    if (st.Equals(StatusPresent, StringComparison.OrdinalIgnoreCase))
                    {
                        code = "P"; p++;
                        decimal lm;
                        if (em.Late.TryGetValue(d, out lm) && lm > 0) late++;
                    }
                    else if (st.Equals(StatusAbsent, StringComparison.OrdinalIgnoreCase)) { code = "A"; a++; css = "c sA"; }
                    else if (HolidayCodes.Contains(st, StringComparer.OrdinalIgnoreCase)) { code = st.ToUpperInvariant(); h++; css = "c sH"; }
                    else if (LeaveCodes.Contains(st, StringComparer.OrdinalIgnoreCase)) { code = st.ToUpperInvariant(); l++; css = "c sL"; }
                    else code = st;   // অন্য কোনো স্ট্যাটাস থাকলে সরাসরি দেখাবে

                    row.Append("<td class=\"" + css + "\">" + Enc(code) + "</td>");
                    cells.Add(code);
                }

                row.Append("<td class=\"c\"><b>" + p + "</b></td><td class=\"c\"><b>" + a + "</b></td><td class=\"c\"><b>" + h +
                           "</b></td><td class=\"c\"><b>" + l + "</b></td><td class=\"c\">" + late + "</td></tr>");
                sb.Append(row.ToString());

                cells.AddRange(new[] { p.ToString(), a.ToString(), h.ToString(), l.ToString(), late.ToString() });
                sec.Rows.Add(new RptRow { Cells = cells.ToArray() });
            }

            sb.Append("<tr class=\"tot\"><td colspan=\"" + cols + "\">Total Employee - " + sl + "</td></tr>");
            sec.Rows.Add(new RptRow { IsTotal = true, Text = "Total Employee - " + sl });
            sb.Append("</tbody></table>");

            string legend = "P = Present, A = Absent, WO = Weekly Off, FH = Festival Holiday, GH = Govt Holiday, CL/SL/EL = Leave, H = Holiday মোট, L = Leave মোট, Late = দেরিতে উপস্থিত দিন";
            sb.Append("<div class=\"legend\">" + Enc(legend) + "</div>");
            sec.Summary = legend;

            sb.Append("<div class=\"signs\"><div>Prepared By</div><div>Time Section</div><div>S.V/Line Chief Incharge</div><div>A.P.M/P.M</div><div>Checked by HR</div><div>Approved By</div></div>");
            sb.Append("<div class=\"stamp\"><span>" + stamp + "</span></div>");
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
