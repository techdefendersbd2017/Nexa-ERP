using Nexa_ERP.Connection;
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

namespace Nexa_ERP.HRMPayroll
{
    public partial class HRMDashboard : System.Web.UI.Page
    {
        // আপনার HRMReports এর মতোই একই কানেকশন ক্লাস
        PayrollDB conn = new PayrollDB();

        // =====================================================================
        // কোন কার্ডের ডাটা কোথা থেকে আসছে
        //  ✔ নিশ্চিত  : View_Emp + Resign_Status (আপনার HRMReports এ ব্যবহৃত)
        //  ? অনুমান   : নিচে ? চিহ্নিত Table/Column — আপনার ডাটাবেস অনুযায়ী বদলান
        // @Today = আজ, @MonthStart = মাসের ১ তারিখ, @MonthEnd = পরের মাসের ১ তারিখ
        // =====================================================================

        // 1. Total Employee ✔
        const string SqlTotalEmployee = "SELECT COUNT(*) FROM Employee_information_new WHERE Resign_Status = 'Active'";

        // 2-4. Present / Late / Absent ?  (Attendance Table ও Status কোড অনুমান)
        const string SqlPresent =
            "SELECT COUNT(DISTINCT ID_no) FROM emp_Attendance " +
            "WHERE CAST(Work_date AS date) = @Today AND att_status IN ('Present','Late')";
        const string SqlLate =
            "SELECT COUNT(DISTINCT ID_no) FROM emp_Attendance " +
            "WHERE CAST(Work_date AS date) = @Today AND att_status = 'Late'";
        const string SqlAbsent =
            "SELECT COUNT(DISTINCT ID_no) FROM emp_Attendance " +
            "WHERE CAST(Work_date AS date) = @Today AND att_status = 'Absent'";

        // 5. Holiday ? (এই মাসের ছুটির দিন)
        const string SqlHoliday =
            "SELECT COUNT(DISTINCT ID_no) FROM emp_Attendance " +
            "WHERE CAST(Work_date AS date) = @Today AND att_status in('WO','FH','GH')";

        // 6. This Month Increment ?
        const string SqlIncrement =
            "SELECT COUNT(*) FROM Employee_information_new WHERE Resign_Status = 'Active'";

        // 7. Total Leave ? (আজ ছুটিতে থাকা)
        const string SqlLeave =
            "SELECT COUNT(DISTINCT ID_no) FROM emp_Attendance " +
            "WHERE CAST(Work_date AS date) = @Today AND att_status in('CL','SL','EL')";

        // 8-10. New Join / Resign / Lefty ✔ স্ট্যাটাস, ? তারিখের কলাম (View_Emp এ থাকলে)
        const string SqlNewJoin =
            "SELECT COUNT(*) FROM Employee_information_new " +
            "WHERE Joining_Date >= @MonthStart AND Joining_Date < @MonthEnd";
        const string SqlResign =
            "SELECT COUNT(*) FROM Employee_information_new WHERE Resign_Status = 'Resign' " +
            "AND Resign_Date >= @MonthStart AND Resign_Date < @MonthEnd";
        const string SqlLefty =
            "SELECT COUNT(*) FROM Employee_information_new WHERE Resign_Status = 'Left' " +
            "AND Resign_Date >= @MonthStart AND Resign_Date < @MonthEnd";

        // =====================================================================
        // নতুন যোগ: কার্ভ/চার্টের SQL (আগের Table/Column ই ব্যবহার হয়েছে)
        // =====================================================================

        // শেষ ৭ দিনের হাজিরা (Present + Late) — দিন অনুযায়ী
        const string SqlAtt7 =
            "SELECT CAST(Work_date AS date) AS d, att_status, COUNT(DISTINCT ID_no) AS c FROM emp_Attendance " +
            "WHERE Work_date >= @From AND Work_date < @To AND att_status IN ('Present','Late','Absent') " +
            "GROUP BY CAST(Work_date AS date), att_status";

        // শেষ ৬ মাস — মাস অনুযায়ী (Year, Month, Count)
        const string SqlJoin6 =
            "SELECT YEAR(Joining_Date), MONTH(Joining_Date), COUNT(*) FROM Employee_information_new " +
            "WHERE Joining_Date >= @From AND Joining_Date < @To " +
            "GROUP BY YEAR(Joining_Date), MONTH(Joining_Date)";
        const string SqlResign6 =
            "SELECT YEAR(Resign_Date), MONTH(Resign_Date), COUNT(*) FROM Employee_information_new " +
            "WHERE Resign_Status = 'Resign' AND Resign_Date >= @From AND Resign_Date < @To " +
            "GROUP BY YEAR(Resign_Date), MONTH(Resign_Date)";
        const string SqlLefty6 =
            "SELECT YEAR(Resign_Date), MONTH(Resign_Date), COUNT(*) FROM Employee_information_new " +
            "WHERE Resign_Status = 'Left' AND Resign_Date >= @From AND Resign_Date < @To " +
            "GROUP BY YEAR(Resign_Date), MONTH(Resign_Date)";

        // .aspx এর <script> এ এই ভ্যালুগুলো বসে (JSON array)
        public string AttLabels = "[]";
        public string AttData = "[]";        // Present
        public string AttLateData = "[]";    // Late
        public string AttAbsentData = "[]";  // Absent
        public string MonLabels = "[]";
        public string JoinData = "[]";
        public string ResignData = "[]";
        public string LeftyData = "[]";

        // ---------------------------------------------------------------------
        readonly StringBuilder errors = new StringBuilder();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack) LoadDashboard();
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            LoadDashboard();
        }

        void LoadDashboard()
        {
            DateTime today = DateTime.Today;
            DateTime monthStart = new DateTime(today.Year, today.Month, 1);
            DateTime monthEnd = monthStart.AddMonths(1);

            lblToday.Text = today.ToString("dd MMM yyyy");
            lblMonth.Text = today.ToString("MMMM yyyy");

            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();

                    lblTotalEmp.Text = Count(con, "Total Employee", SqlTotalEmployee, today, monthStart, monthEnd);
                    lblPresent.Text = Count(con, "Total Present", SqlPresent, today, monthStart, monthEnd);
                    lblLate.Text = Count(con, "Total Late", SqlLate, today, monthStart, monthEnd);
                    lblAbsent.Text = Count(con, "Total Absent", SqlAbsent, today, monthStart, monthEnd);
                    lblHoliday.Text = Count(con, "Total Holiday", SqlHoliday, today, monthStart, monthEnd);
                    lblIncrement.Text = Count(con, "Increment", SqlIncrement, today, monthStart, monthEnd);
                    lblLeave.Text = Count(con, "Total Leave", SqlLeave, today, monthStart, monthEnd);
                    lblNewJoin.Text = Count(con, "New Join", SqlNewJoin, today, monthStart, monthEnd);
                    lblResign.Text = Count(con, "Total Resign", SqlResign, today, monthStart, monthEnd);
                    lblLefty.Text = Count(con, "Total Lefty", SqlLefty, today, monthStart, monthEnd);

                    // ---- নতুন যোগ: চার্ট ডাটা ----
                    LoadCharts(con, today, monthStart);
                }
            }
            catch (Exception ex)
            {
                errors.Append("• Connection: ").Append(Server.HtmlEncode(ex.Message)).Append("<br/>");
            }

            if (errors.Length > 0)
            {
                pnlWarn.Visible = true;
                litWarn.Text = "<b>কিছু কার্ডের SQL চলেনি (Table/Column নাম ঠিক করুন):</b><br/>" + errors;
            }
        }

        // একটি কার্ড ব্যর্থ হলে বাকিগুলো চলবে; ওই কার্ডে 0 দেখাবে
        string Count(SqlConnection con, string title, string sql, DateTime today, DateTime monthStart, DateTime monthEnd)
        {
            try
            {
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.CommandTimeout = 60;
                    cmd.Parameters.Add("@Today", SqlDbType.Date).Value = today;
                    cmd.Parameters.Add("@MonthStart", SqlDbType.Date).Value = monthStart;
                    cmd.Parameters.Add("@MonthEnd", SqlDbType.Date).Value = monthEnd;
                    object r = cmd.ExecuteScalar();
                    return (r == null || r == DBNull.Value) ? "0" : Convert.ToInt32(r).ToString("N0");
                }
            }
            catch (Exception ex)
            {
                errors.Append("• ").Append(title).Append(": ").Append(Server.HtmlEncode(ex.Message)).Append("<br/>");
                return "0";
            }
        }

        // =====================================================================
        // নতুন যোগ: চার্টের মেথডগুলো
        // =====================================================================
        void LoadCharts(SqlConnection con, DateTime today, DateTime monthStart)
        {
            var ci = CultureInfo.InvariantCulture;

            // ---- শেষ ৭ দিন (আজ সহ) ----
            DateTime attFrom = today.AddDays(-6);
            DateTime attTo = today.AddDays(1);
            var attMap = new Dictionary<string, int>();
            try
            {
                using (var cmd = new SqlCommand(SqlAtt7, con))
                {
                    cmd.CommandTimeout = 60;
                    cmd.Parameters.Add("@From", SqlDbType.Date).Value = attFrom;
                    cmd.Parameters.Add("@To", SqlDbType.Date).Value = attTo;
                    using (var rd = cmd.ExecuteReader())
                        while (rd.Read())
                            attMap[Convert.ToDateTime(rd[0]).ToString("yyyyMMdd") + "|" + Convert.ToString(rd[1]).Trim().ToLowerInvariant()] = Convert.ToInt32(rd[2]);
                }
            }
            catch (Exception ex)
            {
                errors.Append("• Attendance 7 Days: ").Append(Server.HtmlEncode(ex.Message)).Append("<br/>");
            }

            var attLabels = new List<string>();
            var attPresent = new List<int>();
            var attLate = new List<int>();
            var attAbsent = new List<int>();
            for (int i = 0; i < 7; i++)
            {
                DateTime d = attFrom.AddDays(i);
                string k = d.ToString("yyyyMMdd");
                attLabels.Add(d.ToString("dd MMM", ci));
                attPresent.Add(attMap.ContainsKey(k + "|present") ? attMap[k + "|present"] : 0);
                attLate.Add(attMap.ContainsKey(k + "|late") ? attMap[k + "|late"] : 0);
                attAbsent.Add(attMap.ContainsKey(k + "|absent") ? attMap[k + "|absent"] : 0);
            }
            AttLabels = ToJson(attLabels);
            AttData = ToJson(attPresent);
            AttLateData = ToJson(attLate);
            AttAbsentData = ToJson(attAbsent);

            // ---- শেষ ৬ মাস (চলতি মাস সহ) ----
            DateTime monFrom = monthStart.AddMonths(-5);
            DateTime monTo = monthStart.AddMonths(1);

            var monLabels = new List<string>();
            for (int i = 0; i < 6; i++)
                monLabels.Add(monFrom.AddMonths(i).ToString("MMM yy", ci));
            MonLabels = ToJson(monLabels);

            JoinData = ToJson(MonthlySeries(con, "Join 6 Months", SqlJoin6, monFrom, monTo));
            ResignData = ToJson(MonthlySeries(con, "Resign 6 Months", SqlResign6, monFrom, monTo));
            LeftyData = ToJson(MonthlySeries(con, "Lefty 6 Months", SqlLefty6, monFrom, monTo));
        }

        // ৬টি মাসের সংখ্যা ফেরত দেয়; ব্যর্থ হলে সব 0
        List<int> MonthlySeries(SqlConnection con, string title, string sql, DateTime from, DateTime to)
        {
            var map = new Dictionary<int, int>();
            try
            {
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.CommandTimeout = 60;
                    cmd.Parameters.Add("@From", SqlDbType.Date).Value = from;
                    cmd.Parameters.Add("@To", SqlDbType.Date).Value = to;
                    using (var rd = cmd.ExecuteReader())
                        while (rd.Read())
                            map[Convert.ToInt32(rd[0]) * 100 + Convert.ToInt32(rd[1])] = Convert.ToInt32(rd[2]);
                }
            }
            catch (Exception ex)
            {
                errors.Append("• ").Append(title).Append(": ").Append(Server.HtmlEncode(ex.Message)).Append("<br/>");
            }

            var result = new List<int>();
            for (int i = 0; i < 6; i++)
            {
                DateTime m = from.AddMonths(i);
                int key = m.Year * 100 + m.Month;
                result.Add(map.ContainsKey(key) ? map[key] : 0);
            }
            return result;
        }

        static string ToJson(IEnumerable<int> list)
        {
            return "[" + string.Join(",", list.Select(x => x.ToString(CultureInfo.InvariantCulture))) + "]";
        }

        static string ToJson(IEnumerable<string> list)
        {
            return "[" + string.Join(",", list.Select(x => "\"" + x.Replace("\"", "") + "\"")) + "]";
        }
    }
}
