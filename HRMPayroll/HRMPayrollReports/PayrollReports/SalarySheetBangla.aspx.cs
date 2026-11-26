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

namespace Nexa_ERP.HRMPayroll.HRMPayrollReports.PayrollReports
{
    public partial class SalarySheetBangla : System.Web.UI.Page
    {
        PayrollDB conn = new PayrollDB();

        // আলাদা View লাগে না: আপনার SQL সরাসরি এখানে বসানো আছে (derived table হিসেবে ব্যবহার হয়)।
        const string SalarySelect =
            @"SELECT Employee_information_new.ID_no, TB_Designation.Designation_Bangla, TB_Designation.Grade, TB_Department.Bangla_Name AS Department, TB_Section.Section_bangla_Name, TB_Section.Section_Name,
                     TB_Designation.Desigation_name, TB_Department.Department_Name, Salary_Sheet_Information.Years, Salary_Sheet_Information.Months, Employee_information_new.Name,
                     Employee_information_new.Bangla_name, Employee_information_new.Joining_Date, Seperation_Status.Seperation_Name, TB_Line.Line_Name, TB_Line.Line_bangla_Name,
                     Salary_Sheet_Information.Bank_Holder, Salary_Sheet_Information.Bank_Account_Number, Salary_Sheet_Information.Old_Gross_Salary, Salary_Sheet_Information.Increment_Amount,
                     Salary_Sheet_Information.New_Gross_Salary, Salary_Sheet_Information.Basic_Salary, Salary_Sheet_Information.House_Rant, Salary_Sheet_Information.Medical_Allowance,
                     Salary_Sheet_Information.Convance_Allowance, Salary_Sheet_Information.Food_Allowance, Salary_Sheet_Information.Festival_Holiday, Salary_Sheet_Information.Casual_Leave,
                     Salary_Sheet_Information.Medival_Leave, Salary_Sheet_Information.Compansation_Leave, Salary_Sheet_Information.Earn_Leave, Salary_Sheet_Information.Meternaty_Leave,
                     Salary_Sheet_Information.Weekend_Leave, Salary_Sheet_Information.Special_Leave, Salary_Sheet_Information.General_Others_Leave, Salary_Sheet_Information.Present_Days,
                     Salary_Sheet_Information.Late_Days, Salary_Sheet_Information.Absent_Days, Salary_Sheet_Information.Total_Days, Salary_Sheet_Information.Gross_Payable_Amount,
                     Salary_Sheet_Information.Lanch_out_Minite, Salary_Sheet_Information.Lanch_out_Minite_Rate, Salary_Sheet_Information.OT_Rate, Salary_Sheet_Information.Compliance_OT_Hours,
                     Salary_Sheet_Information.Compliance_OT_Min, Salary_Sheet_Information.Compliance_OT_Amount, Salary_Sheet_Information.Extra_OT_Hours, Salary_Sheet_Information.Extra_OT_Min,
                     Salary_Sheet_Information.Extra_OT_Amount, Salary_Sheet_Information.Attendance_Bonus, Salary_Sheet_Information.Night_Bill_Amount, Salary_Sheet_Information.Holiday_Bill_Amount,
                     Salary_Sheet_Information.Others_Bill_Amount, Salary_Sheet_Information.Grand_total, Salary_Sheet_Information.Complicance_Grand_total, Salary_Sheet_Information.Absent_Deduction,
                     Salary_Sheet_Information.Lanch_out_Deduction, Salary_Sheet_Information.Lanch_Deduction, Salary_Sheet_Information.Salary_Advance_Deduction, Salary_Sheet_Information.Tax_Deduction,
                     Salary_Sheet_Information.Stamp_Deduction, Salary_Sheet_Information.Others_Deduction, Salary_Sheet_Information.Total_Deduction, Salary_Sheet_Information.Net_Pay_Amount,
                     Salary_Sheet_Information.Compliance_Net_Payment, TB_Company.Company_Name, TB_Company.Conmany_Bangla, TB_Company.Address, TB_Company.Bangla_Address, z_Test_ID.User_ID,
                     z_Test_ID.From_Code, TB_Catagory.Catagory_Name, Salary_Sheet_Information.Separetion_Date
              FROM Employee_information_new INNER JOIN
                     Salary_Sheet_Information ON Employee_information_new.ID_no = Salary_Sheet_Information.ID_no INNER JOIN
                     Seperation_Status ON Salary_Sheet_Information.Employee_Status = Seperation_Status.Seperation_Code INNER JOIN
                     TB_Department ON Salary_Sheet_Information.Dempartment_Code = TB_Department.Department_Code INNER JOIN
                     TB_Section ON Salary_Sheet_Information.Section_Code = TB_Section.Section_Code INNER JOIN
                     TB_Line ON Salary_Sheet_Information.Line_Code = TB_Line.Line_Code INNER JOIN
                     TB_Designation ON Salary_Sheet_Information.Designation_Code = TB_Designation.Designation_Code INNER JOIN
                     Employee_information_With_Code ON Employee_information_new.ID_no = Employee_information_With_Code.ID_no INNER JOIN
                     TB_Company ON Employee_information_With_Code.Company_Code = TB_Company.Company_Code INNER JOIN
                     z_Test_ID ON Employee_information_new.ID_no = z_Test_ID.ID_No INNER JOIN
                     TB_Catagory ON Salary_Sheet_Information.Catagory_Code = TB_Catagory.Catagory_Code";

        static readonly string[] BnMonths = { "জানুয়ারি", "ফেব্রুয়ারি", "মার্চ", "এপ্রিল", "মে", "জুন", "জুলাই", "আগস্ট", "সেপ্টেম্বর", "অক্টোবর", "নভেম্বর", "ডিসেম্বর" };
        static readonly CultureInfo CI = CultureInfo.InvariantCulture;

        // PDF এর মতো প্রতি পৃষ্ঠায় ১০টি সারি (শেষ পৃষ্ঠায় "মোট" সারিও একটি সারি ধরা হয়)
        const int RowsPerPage = 10;

        bool compliance;          // Report Type এর নামে "Compliance" থাকলে Compliance হিসাব
        string reportName = "";   // Report Type এর নাম (rn)

        // ---------- কলামের বর্ণনা ----------
        class Cn
        {
            public double W;                 // প্রস্থের অনুপাত
            public string Head;              // হেডার লেখা
            public string[] StackHead;       // ৪ ভাগের হেডার (উপরে শিরোনাম + নিচে ৩টি)
            public string Group;             // গ্রুপ হেডার (যেমন: ছুটির হিসাব, কর্তন)
            public bool VHead;               // হেডার খাড়া (নিচ থেকে উপরে)
            public int Rot;                  // 0 = কখনো না, 1 = সবসময়, 2 = লেখা বড় হলে খাড়া
            public bool Left;
            public bool Bold;
            public Func<DataRow, int, string[]> Val;      // ১টি বা ৩টি (stack) মান
            public Func<List<DataRow>, string[]> Tot;     // মোট সারির মান (null হলে ফাঁকা)
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            string rcStr = Request.QueryString["rc"];
            reportName = Request.QueryString["rn"] ?? "";
            compliance = reportName.IndexOf("compliance", StringComparison.OrdinalIgnoreCase) >= 0;

            long rc;
            if (!long.TryParse(rcStr, out rc))
            {
                Msg("রিপোর্ট ব্যাচ নম্বর (rc) পাওয়া যায়নি। Payroll_Reports পেজ থেকে রিপোর্ট খুলুন।");
                return;
            }

            DateTime from;
            if (!DateTime.TryParseExact(Request.QueryString["from"] ?? "", "yyyy-MM-dd", CI, DateTimeStyles.None, out from))
                from = DateTime.Today;

            DataTable dt;
            try
            {
                dt = LoadData(rc, from.Year, from.Month);
            }
            catch (Exception ex)
            {
                Msg("ডাটা লোড ব্যর্থ: " + ex.Message);
                return;
            }

            if (dt.Rows.Count == 0)
            {
                Msg("নির্বাচিত কর্মচারী ও মাস (" + BnMonths[from.Month - 1] + "-" + Bn(from.Year.ToString()) + ") এর কোনো বেতন তথ্য পাওয়া যায়নি।");
                return;
            }

            litReport.Text = BuildReport(dt, from);
        }

        DataTable LoadData(long rc, int year, int month)
        {
            using (SqlConnection con = conn.openConnection())
            {
                if (con.State != ConnectionState.Open) con.Open();

                string sql = "SELECT v.* FROM (" + SalarySelect + ") v" +
                             " WHERE User_ID=@u AND From_Code=@rc" +
                             " AND TRY_CAST(Years AS int)=@y AND TRY_CAST(Months AS int)=@m";

                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.CommandTimeout = 120;
                    cmd.Parameters.Add("@u", SqlDbType.BigInt).Value = HRFilters.UserCode;
                    cmd.Parameters.Add("@rc", SqlDbType.BigInt).Value = rc;
                    cmd.Parameters.Add("@y", SqlDbType.Int).Value = year;
                    cmd.Parameters.Add("@m", SqlDbType.Int).Value = month;

                    var dt = new DataTable();
                    using (var da = new SqlDataAdapter(cmd)) da.Fill(dt);
                    return dt;
                }
            }
        }

        // ================= কলামের তালিকা (PDF এর ক্রমে) =================
        List<Cn> BuildCols()
        {
            var c = new List<Cn>();

            c.Add(new Cn { W = 21, Head = "ক্রমিক নং", VHead = true, Val = (r, i) => new[] { Bn((i + 1).ToString()) } });
            c.Add(new Cn { W = 92, Head = "নাম", Left = true, Val = (r, i) => new[] { Pick(r, "Bangla_name", "Name") } });
            c.Add(new Cn { W = 18, Head = "কার্ড", VHead = true, Rot = 1, Val = (r, i) => new[] { Bn(S(r, "ID_no")) } });
            c.Add(new Cn { W = 21, Head = "লাইন", VHead = true, Rot = 2, Val = (r, i) => new[] { Bn(Pick(r, "Line_bangla_Name", "Line_Name")) } });
            c.Add(new Cn { W = 18, Head = "যোগদানের তারিখ", VHead = true, Rot = 1, Val = (r, i) => new[] { Bn(Dt(r, "Joining_Date")) } });
            c.Add(new Cn { W = 20, Head = "গ্রেড", VHead = true, Val = (r, i) => new[] { Bn(S(r, "Grade")) } });
            c.Add(new Cn { W = 71, Head = "পদবী", Bold = true, Val = (r, i) => new[] { Pick(r, "Designation_Bangla", "Desigation_name") } });

            // বিস্তারিত: মূল বেতন / বাড়ি ভাড়া / অন্যান্য (চিকিৎসা + যাতায়াত + খাদ্য)
            c.Add(new Cn
            {
                W = 43,
                StackHead = new[] { "বিস্তারিত", "মূল বেতন", "বাড়ি ভাড়া", "অন্যান্য" },
                Val = (r, i) => new[] {
                    M(D(r, "Basic_Salary")),
                    M(D(r, "House_Rant")),
                    M(D(r, "Medical_Allowance") + D(r, "Convance_Allowance") + D(r, "Food_Allowance")) }
            });

            c.Add(Money("পূর্বের মোট বেতন", 19, "Old_Gross_Salary", false));
            c.Add(Money("মজুরী বৃদ্ধি", 18, "Increment_Amount", false));
            c.Add(Money("বর্তমান মোট বেতন", 18, "New_Gross_Salary", true));

            // ছুটির হিসাব
            string lg = "ছুটির হিসাব";
            c.Add(Cnt("উৎসব", 14, "Festival_Holiday", lg));
            c.Add(Cnt("নৈমিত্তিক", 14, "Casual_Leave", lg));
            c.Add(Cnt("অসুস্থতা", 14, "Medival_Leave", lg));
            c.Add(Cnt("ক্ষতিপূরণ মূলক", 14, "Compansation_Leave", lg));
            c.Add(Cnt("অন্যান্য", 14, "General_Others_Leave", lg));
            c.Add(Cnt("অর্জিত", 14, "Earn_Leave", lg));
            c.Add(Cnt("মাতৃত্ব / ১৩-১", 14, "Meternaty_Leave", lg));
            c.Add(Cnt("সাপ্তাহিক", 14, "Weekend_Leave", lg));
            c.Add(Cnt("বিশেষ ছুটি", 14, "Special_Leave", lg));

            c.Add(Cnt("উপস্থিত", 16, "Present_Days", null));
            c.Add(Cnt("বিলম্ব দিন", 16, "Late_Days", null));
            c.Add(Cnt("অনুপস্থিত", 16, "Absent_Days", null));
            var td = Cnt("মোট দিন", 16, "Total_Days", null); td.Bold = true; c.Add(td);
            c.Add(Cnt("লাঞ্চআউট মিনিট", 16, "Lanch_out_Minite", null));
            c.Add(Money("প্রদেয় টাকা", 19, "Gross_Payable_Amount", true));

            // ওভার টাইম: কমপ্লায়েন্স ও অতিরিক্ত (প্রতি ঘন্টা / মোট ঘন্টা / মোট টাকা)
            //c.Add(new Cn
            //{
            //    W = 50,
            //    StackHead = new[] { "ওভার", "প্রতি ঘন্টা", "মোট ঘন্টা", "মোট টাকা" },
            //    Val = (r, i) => new[] {
            //        H2(D(r, "OT_Rate")),
            //        H2(OtHrs(r, "Compliance_OT_Hours", "Compliance_OT_Min")),
            //        M(D(r, "Compliance_OT_Amount")) },
            //    Tot = l => new[] {
            //        "",
            //        H2(l.Sum(x => OtHrs(x, "Compliance_OT_Hours", "Compliance_OT_Min"))),
            //        P(l.Sum(x => D(x, "Compliance_OT_Amount"))) }
            //});
            c.Add(new Cn
            {
                W = 50,
                StackHead = new[] { "ওভার", "প্রতি ঘন্টা", "মোট ঘন্টা", "মোট টাকা" },
                Val = (r, i) => new[] {
                    H2(D(r, "OT_Rate")),
                    H2(OtHrs(r, "Extra_OT_Hours", "Extra_OT_Min")),
                    M(D(r, "Extra_OT_Amount")) },
                Tot = l => new[] {
                    "",
                    H2(l.Sum(x => OtHrs(x, "Extra_OT_Hours", "Extra_OT_Min"))),
                    P(l.Sum(x => D(x, "Extra_OT_Amount"))) }
            });

            c.Add(Money("হাজিরা বোনাস", 17, "Attendance_Bonus", true));
            c.Add(Money("নাইট বিল", 17, "Night_Bill_Amount", true));
            c.Add(Money("হলিডে বিল", 17, "Holiday_Bill_Amount", true));
            c.Add(Money("অন্যান্য", 17, "Others_Bill_Amount", true));
            c.Add(new Cn
            {
                W = 24,
                Head = "মোট টাকা",
                VHead = true,
                Rot = 2,
                Val = (r, i) => new[] { M(GrandOf(r)) },
                Tot = l => new[] { P(l.Sum(x => GrandOf(x))) }
            });

            // কর্তন
            string dg = "কর্তন";
            c.Add(Money("অনুপস্থিত", 17, "Absent_Deduction", true, dg));
            c.Add(Money("লাঞ্চ আউট", 17, "Lanch_out_Deduction", true, dg));
            c.Add(Money("লাঞ্চ", 17, "Lanch_Deduction", true, dg));
            c.Add(Money("অগ্রীম", 17, "Salary_Advance_Deduction", true, dg));
            c.Add(Money("অন্যান্য", 17, "Others_Deduction", true, dg));
            c.Add(Money("স্ট্যাম্প", 17, "Stamp_Deduction", true, dg));

            // মোট প্রদেয় / ক্যাশ / ব্যাংক
            c.Add(new Cn
            {
                W = 38,
                Head = "মোট প্রদেয় টাকা",
                Bold = true,
                Val = (r, i) => new[] { M(NetOf(r)) },
                Tot = l => new[] { P(l.Sum(x => NetOf(x))) }
            });
            //c.Add(new Cn
            //{
            //    W = 38,
            //    Head = "ক্যাশ প্রদেয় টাকা",
            //    Bold = true,
            //    Val = (r, i) => new[] { M(IsBank(r) ? 0m : NetOf(r)) },
            //    Tot = l => new[] { P(l.Where(x => !IsBank(x)).Sum(x => NetOf(x))) }
            //});
            //c.Add(new Cn
            //{
            //    W = 38,
            //    Head = "ব্যাংক প্রদেয় টাকা",
            //    Bold = true,
            //    Val = (r, i) => new[] { M(IsBank(r) ? NetOf(r) : 0m) },
            //    Tot = l => new[] { P(l.Where(x => IsBank(x)).Sum(x => NetOf(x))) }
            //});
            c.Add(new Cn { W = 90, Head = "স্বাক্ষর", Val = (r, i) => new[] { "" } });

            return c;
        }

        // টাকার কলাম (কমা সহ), চাইলে মোট সারিতেও যোগফল
        static Cn Money(string head, double w, string field, bool total, string group = null)
        {
            var c = new Cn { W = w, Head = head, VHead = true, Group = group, Rot = 2 };
            c.Val = (r, i) => new[] { M(D(r, field)) };
            if (total) c.Tot = l => new[] { P(l.Sum(x => D(x, field))) };
            return c;
        }

        // দিন/ছুটির সংখ্যার কলাম
        static Cn Cnt(string head, double w, string field, string group)
        {
            var c = new Cn { W = w, Head = head, VHead = true, Group = group };
            c.Val = (r, i) => new[] { Dy(D(r, field)) };
            return c;
        }

        decimal GrandOf(DataRow r) { return compliance ? D(r, "Complicance_Grand_total") : D(r, "Grand_total"); }
        decimal NetOf(DataRow r) { return compliance ? D(r, "Compliance_Net_Payment") : D(r, "Net_Pay_Amount"); }
        static decimal OtHrs(DataRow r, string h, string m) { return D(r, h) + D(r, m) / 60m; }

        // ================= রিপোর্ট তৈরি =================
        string BuildReport(DataTable dt, DateTime from)
        {
            var rows = dt.Rows.Cast<DataRow>().ToList();
            DataRow first = rows[0];

            string company = Pick(first, "Conmany_Bangla", "Company_Name");
            string address = Pick(first, "Bangla_Address", "Address");
            string title = "মাসিক বেতন পত্র- " + BnMonths[from.Month - 1] + "-" + Bn(from.Year.ToString());

            var cols = BuildCols();
            var pages = new List<string>();

            // প্রতিটি সেকশনের জন্য: ১ম পৃষ্ঠা সারসংক্ষেপ, তারপর বিস্তারিত পৃষ্ঠা
            var groups = rows.GroupBy(r => Pick(r, "Section_bangla_Name", "Section_Name")).OrderBy(g => g.Key);
            foreach (var g in groups)
            {
                var list = g.OrderBy(r => NumKey(r)).ThenBy(r => S(r, "ID_no")).ToList();
                string sec = "সেকশনঃ " + g.Key;
                string pay = PayLabel(list);

                pages.Add(SummaryPage(company, address, title, sec, pay, list));
                DetailPages(pages, cols, company, address, title, sec, pay, list);
            }

            var sb = new StringBuilder();
            for (int i = 0; i < pages.Count; i++)
                sb.Append(pages[i].Replace("@@PG@@", (i + 1).ToString()).Replace("@@TOT@@", pages.Count.ToString()));
            return sb.ToString();
        }

        // ---------- সারসংক্ষেপ পৃষ্ঠা ----------
        string SummaryPage(string company, string address, string title, string sec, string pay, List<DataRow> rows)
        {
            decimal comp = rows.Sum(r => D(r, "Compliance_OT_Amount"));
            decimal ext = rows.Sum(r => D(r, "Extra_OT_Amount"));

            var left = new List<string[]>();
            left.Add(new[] { "মোট শ্রমিক", Bn(rows.Count.ToString()), "b" });
            left.Add(new[] { "বর্তমান মোট বেতন", M(rows.Sum(r => D(r, "New_Gross_Salary"))), "" });
            left.Add(new[] { "মোট প্রাপ্য বেতন", M(rows.Sum(r => D(r, "Gross_Payable_Amount"))), "" });
            left.Add(new[] { "কমপ্লায়েন্স ও.টি", M(comp), "" });
            left.Add(new[] { "অতিরিক্ত ও.টি", M(ext), "" });
            left.Add(new[] { "মোট ও.টি টাকা", M(comp + ext), "b" });
            left.Add(new[] { "হাজিরা বোনাস", M(rows.Sum(r => D(r, "Attendance_Bonus"))), "" });
            left.Add(new[] { "নাইট বিল", M(rows.Sum(r => D(r, "Night_Bill_Amount"))), "" });
            left.Add(new[] { "হলিডে বিল", M(rows.Sum(r => D(r, "Holiday_Bill_Amount"))), "" });
            left.Add(new[] { "অন্যান্য", M(rows.Sum(r => D(r, "Others_Bill_Amount"))), "" });
            left.Add(new[] { "মোট টাকা", M(rows.Sum(r => GrandOf(r))), "" });

            var right = new List<string[]>();
            right.Add(new[] { "অনুপস্থিত কর্তনের টাকা", M(rows.Sum(r => D(r, "Absent_Deduction"))), "" });
            right.Add(new[] { "লাঞ্চ আউট কর্তন", M(rows.Sum(r => D(r, "Lanch_out_Deduction"))), "" });
            right.Add(new[] { "লাঞ্চ  কর্তন", M(rows.Sum(r => D(r, "Lanch_Deduction"))), "" });
            right.Add(new[] { "অগ্রীম কর্তন", M(rows.Sum(r => D(r, "Salary_Advance_Deduction"))), "" });
            right.Add(new[] { "অন্যান্য কর্তন", M(rows.Sum(r => D(r, "Others_Deduction"))), "" });
            right.Add(new[] { "স্ট্যাম্প কর্তন", M(rows.Sum(r => D(r, "Stamp_Deduction"))), "" });
            right.Add(new[] { "মোট কর্তন", M(rows.Sum(r => D(r, "Total_Deduction"))), "" });
            right.Add(new[] { "মোট প্রদেয় টাকা", M(rows.Sum(r => NetOf(r))), "b" });
            //right.Add(new[] { "মোট প্রদেয় টাকা ক্যাশ", M(rows.Where(r => !IsBank(r)).Sum(r => NetOf(r))), "b" });
            //right.Add(new[] { "মোট প্রদেয় টাকা ব্যাংক", M(rows.Where(r => IsBank(r)).Sum(r => NetOf(r))), "b" });

            var sb = new StringBuilder();
            sb.Append("<div class='pg'><div class='pnr'>Page @@PG@@ of @@TOT@@</div>");
            sb.Append("<div class='sh'><div class='co'>").Append(H(company)).Append("</div><div class='ad'>").Append(H(address)).Append("</div></div>");
            sb.Append("<div class='sr'><span class='sec'>").Append(H(sec)).Append("</span><span class='tt'>").Append(H(title)).Append("</span></div>");
            sb.Append("<div class='paybox'>").Append(H(pay)).Append("</div>");
            sb.Append("<div class='sumwrap'>").Append(SumCol(left)).Append(SumCol(right)).Append("</div>");
            sb.Append(SignHtml()).Append("</div>");
            return sb.ToString();
        }

        static string SumCol(List<string[]> items)
        {
            var sb = new StringBuilder("<table>");
            foreach (var it in items)
                sb.Append(it[2] == "b" ? "<tr class='b'>" : "<tr>")
                  .Append("<td class='lb'>").Append(H(it[0])).Append("</td><td class='cl'>ঃ</td><td class='vl'>").Append(H(it[1])).Append("</td></tr>");
            return sb.Append("</table>").ToString();
        }

        // ---------- বিস্তারিত পৃষ্ঠা ----------
        void DetailPages(List<string> pages, List<Cn> cols, string company, string address, string title, string sec, string pay, List<DataRow> list)
        {
            int n = list.Count;
            int items = n + 1;   // সারি + "মোট" সারি

            for (int start = 0; start < items; start += RowsPerPage)
            {
                int end = Math.Min(start + RowsPerPage, items);
                var sb = new StringBuilder();

                sb.Append("<div class='pg'><div class='box'><div class='ph'>");
                sb.Append("<div><div class='co'>").Append(H(company)).Append("</div><div class='ad'>").Append(H(address)).Append("</div></div>");
                sb.Append("<div><div class='pn'>Page @@PG@@ of @@TOT@@</div><div class='pay'>").Append(H(pay)).Append("</div></div>");
                sb.Append("<div><div class='tt'>").Append(H(title)).Append("</div><div class='sec'>").Append(H(sec)).Append("</div></div>");
                sb.Append("</div>");

                sb.Append("<table class='sheet'>").Append(ColGroup(cols)).Append(THead(cols)).Append("<tbody>");
                for (int i = start; i < end; i++)
                {
                    if (i < n) sb.Append(DataRowHtml(cols, list[i], i));
                    else sb.Append(TotalRowHtml(cols, list));
                }
                sb.Append("</tbody></table></div>");
                sb.Append(SignHtml()).Append("</div>");

                pages.Add(sb.ToString());
            }
        }

        static string ColGroup(List<Cn> cols)
        {
            double total = cols.Sum(c => c.W);
            var sb = new StringBuilder("<colgroup>");
            foreach (var c in cols)
                sb.Append("<col style='width:").Append((c.W * 100 / total).ToString("0.###", CI)).Append("%' />");
            return sb.Append("</colgroup>").ToString();
        }

        static string THead(List<Cn> cols)
        {
            var r1 = new StringBuilder("<tr>");
            var r2 = new StringBuilder("<tr>");

            for (int i = 0; i < cols.Count; i++)
            {
                var c = cols[i];
                if (c.Group == null)
                {
                    if (c.StackHead != null)
                    {
                        r1.Append("<th rowspan='2' class='stkh'>");
                        foreach (string s in c.StackHead) r1.Append("<div>").Append(H(s)).Append("</div>");
                        r1.Append("</th>");
                    }
                    else if (c.VHead)
                        r1.Append("<th rowspan='2'><div class='vt'>").Append(H(c.Head)).Append("</div></th>");
                    else
                        r1.Append("<th rowspan='2'>").Append(H(c.Head)).Append("</th>");
                }
                else
                {
                    if (i == 0 || cols[i - 1].Group != c.Group)
                    {
                        int span = 0;
                        for (int j = i; j < cols.Count && cols[j].Group == c.Group; j++) span++;
                        r1.Append("<th colspan='").Append(span).Append("'>").Append(H(c.Group)).Append("</th>");
                    }
                    r2.Append("<th><div class='vt2'>").Append(H(c.Head)).Append("</div></th>");
                }
            }
            return "<thead>" + r1.Append("</tr>") + r2.Append("</tr>") + "</thead>";
        }

        string DataRowHtml(List<Cn> cols, DataRow r, int idx)
        {
            var sb = new StringBuilder("<tr class='dr'>");
            foreach (var c in cols) sb.Append(CellHtml(c, c.Val(r, idx)));
            return sb.Append("</tr>").ToString();
        }

        string TotalRowHtml(List<Cn> cols, List<DataRow> list)
        {
            const int lead = 7;   // ক্রমিক .. পদবী পর্যন্ত একত্রে
            var sb = new StringBuilder("<tr class='tr'>");
            sb.Append("<td colspan='").Append(lead).Append("' class='tl'>মোট = ").Append(Bn(list.Count.ToString())).Append(" জন</td>");
            for (int k = lead; k < cols.Count; k++)
            {
                var c = cols[k];
                if (c.Tot == null) { sb.Append("<td></td>"); continue; }
                sb.Append(CellHtml(c, c.Tot(list)));
            }
            return sb.Append("</tr>").ToString();
        }

        static string CellHtml(Cn c, string[] v)
        {
            if (v.Length == 3)
                return "<td class='stk'><div class='s'>" + H(v[0]) + "</div><div class='s'>" + H(v[1]) + "</div><div class='s'>" + H(v[2]) + "</div></td>";

            string cls = (c.Left ? "l" : "c") + (c.Bold ? " b" : "");
            string t = H(v[0]);
            bool rot = c.Rot == 1 || (c.Rot == 2 && v[0].Length >= 4);
            return "<td class='" + cls + "'>" + (rot ? "<div class='rv'>" + t + "</div>" : t) + "</td>";
        }

        static string SignHtml()
        {
            return "<div class='sign'><div>Prepared By</div><div>HR Depart.</div><div>Manager (HR &amp; Comp.)</div>" +
                   "<div>Accounts Department</div><div>GM (Marketing &amp; Operation)</div><div>Managing Director</div></div>";
        }

        // ================= সাহায্যকারী =================
        // শিরোনাম: Report Type এর নামে bank/cash থাকলে সেটি, নইলে ডাটা দেখে
        string PayLabel(List<DataRow> rows)
        {
            string l = (reportName ?? "").ToLowerInvariant();
            if (l.Contains("bank") || reportName.Contains("ব্যাংক")) return "ব্যাংক প্রদেয়";
            if (l.Contains("cash") || reportName.Contains("ক্যাশ")) return "ক্যাশ প্রদেয়";

            bool anyBank = rows.Any(r => IsBank(r));
            bool anyCash = rows.Any(r => !IsBank(r));
            if (anyBank && anyCash) return "ক্যাশ ও ব্যাংক প্রদেয়";
            return anyBank ? "ব্যাংক প্রদেয়" : "ক্যাশ প্রদেয়";
        }

        static long NumKey(DataRow r)
        {
            long x;
            return long.TryParse(S(r, "ID_no"), out x) ? x : long.MaxValue;
        }

        static string S(DataRow r, string c)
        {
            return r.Table.Columns.Contains(c) && r[c] != DBNull.Value ? Convert.ToString(r[c]).Trim() : "";
        }

        static string Pick(DataRow r, params string[] cols)
        {
            foreach (var c in cols) { string v = S(r, c); if (v.Length > 0) return v; }
            return "";
        }

        static decimal D(DataRow r, string c)
        {
            if (!r.Table.Columns.Contains(c) || r[c] == DBNull.Value) return 0m;
            decimal v;
            return decimal.TryParse(Convert.ToString(r[c], CI), NumberStyles.Any, CI, out v) ? v : 0m;
        }

        static string Dt(DataRow r, string c)
        {
            if (!r.Table.Columns.Contains(c) || r[c] == DBNull.Value) return "";
            DateTime d;
            return DateTime.TryParse(Convert.ToString(r[c], CI), CI, DateTimeStyles.None, out d)
                ? d.ToString("dd-MM-yy", CI) : S(r, c);
        }

        // ব্যাংক হোল্ডার কিনা: Bank_Holder হ্যাঁ/true/1 হলে, নইলে Bank_Holder ফাঁকা থাকলে অ্যাকাউন্ট নম্বর দেখে
        static bool IsBank(DataRow r)
        {
            string h = S(r, "Bank_Holder").ToLowerInvariant();
            if (h == "1" || h == "true" || h == "yes" || h == "y" || h == "bank" || h == "হ্যাঁ") return true;
            if (h.Length == 0) return S(r, "Bank_Account_Number").Length > 0;
            return false;
        }

        // সংখ্যার ফরম্যাট (সবই বাংলা অঙ্কে)
        static string M(decimal v) { return Bn(v.ToString("N0", CI)); }                                                    // ১৮,০০০
        static string P(decimal v) { return Bn(Math.Round(v, 0, MidpointRounding.AwayFromZero).ToString("0", CI)); }       // ৪৩৮২০০ (মোট সারি)
        static string H2(decimal v) { return Bn(v.ToString("0.00", CI)); }                                                 // ০.০০
        static string Dy(decimal v) { return Bn(v.ToString("0.##", CI)); }                                                 // দিন/ছুটি

        static string H(string s) { return HttpUtility.HtmlEncode(s ?? ""); }

        // ইংরেজি অঙ্ক → বাংলা অঙ্ক
        static string Bn(string s)
        {
            const string bn = "০১২৩৪৫৬৭৮৯";
            var sb = new StringBuilder();
            foreach (char ch in s) sb.Append(ch >= '0' && ch <= '9' ? bn[ch - '0'] : ch);
            return sb.ToString();
        }

        void Msg(string text)
        {
            litReport.Text = "<div class='msg'>" + H(text) + "</div>";
        }
    }
}
