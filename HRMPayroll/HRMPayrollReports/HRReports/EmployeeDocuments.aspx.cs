using Nexa_ERP.Connection;
using Nexa_ERP.HRMPayroll.Common;      // HRFilters (UserCode)
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Text;
using System.Web;

namespace Nexa_ERP.HRMPayroll.HRMPayrollReports.HRReports
{
    // HRMReports এর Report View বাটন নতুন ট্যাবে খোলে:
    //   EmployeeDocuments.aspx?report=<নাম>
    // report নাম:
    //   Full_File_Bangla (সবগুলো পরপর) | Appointment_Letter | ID_Card | Background_Check
    //   Job_Description | Nominee_Form | Medical_Form | Joining_Letter
    // কর্মচারী আসে z_Test_ID থেকে (HRMReports এ টিক দেওয়া, From_Code = 8)
    public partial class EmployeeDocuments : System.Web.UI.Page
    {
        PayrollDB conn = new PayrollDB();

        const int FormCode = 8;                 // HRMReports এর ResolveReport এর formCode এর সঙ্গে মিলতে হবে
        const string LetterPageCss = "@page { size:A4; margin:0; }";

        class Def
        {
            public string Title;
            public Func<DataRow, string> Render;
        }

        static readonly Dictionary<string, Def> Reports = new Dictionary<string, Def>(StringComparer.Ordinal)
        {
            { "Appointment_Letter", new Def { Title = "Appointment Letter", Render = AppointmentLetter } },
            { "ID_Card",            new Def { Title = "ID Card",            Render = IdCard } },
            { "Background_Check",   new Def { Title = "Background Check",   Render = BackgroundCheck } },
            { "Job_Description",    new Def { Title = "Job Description",    Render = JobDescription } },
            { "Nominee_Form",       new Def { Title = "Nominee Form",       Render = NomineeForm } },
            { "Medical_Form",       new Def { Title = "Medical Form",       Render = MedicalForm } },
            { "Joining_Letter",     new Def { Title = "Joining Letter",     Render = JoiningLetter } },
            { "Full_File_Bangla",   new Def { Title = "Full File Bangla",
                Render = r => AppointmentLetter(r) + IdCard(r) + BackgroundCheck(r) + JobDescription(r) +
                              NomineeForm(r) + MedicalForm(r) + JoiningLetter(r) } }
        };

        // z_Test_ID এর টিক দেওয়া কর্মচারীদের সব তথ্য (HRMReports এর Crystal Query থেকে দরকারি কলাম)
        // Photo / Nominee / Experience না থাকলেও যাতে কর্মী পাওয়া যায়, তাই ঐ তিনটি LEFT JOIN
        const string SqlEmp = @"SELECT        Employee_information_new.ID_no, Employee_information_new.Bangla_name, Employee_information_new.Joining_Date, TB_Department.Bangla_Name AS Department_Bangla, TB_Section.Section_bangla_Name, 
                         TB_Line.Line_bangla_Name, TB_Designation.Designation_Bangla, TB_Company.Conmany_Bangla, TB_Company.Address, TB_Company.Bangla_Address, Employee_Personal_Information_new.NID, 
                         Employee_Personal_Information_new.B_Village, Employee_Personal_Information_new.B_Post, Employee_Personal_Information_new.B_Thana, Employee_Personal_Information_new.B_District, 
                         Employee_Personal_Information_new.B_P_Village, Employee_Personal_Information_new.B_P_Post, Employee_Personal_Information_new.B_P_Thana, Employee_Personal_Information_new.B_P_District, 
                         Employee_Personal_Information_new.Blood_Group, TB_Company.Company_Logo, Employee_Personal_Information_new.Home_Phone, Emp_Photo.Photo, TB_Designation.Designation_Catagory_Bangla AS Work_Type_Bangla,
                          TB_Company.EMail, TB_Company.Phone, Employee_Personal_Information_new.BID, TB_Designation.Grade, z_Test_ID.User_ID, z_Test_ID.From_Code, techdefendersbd.tb_job_disciption.Purpose_the_work, techdefendersbd.tb_job_disciption.Responsibilities, 
                         TB_Designation_1.Designation_Bangla AS Report_to1, TB_Designation_2.Designation_Bangla AS Report_to2, Employee_Personal_Information_new.Fathers, Employee_Personal_Information_new.Fathers_Bangla, 
                         Employee_Personal_Information_new.Mothers, Employee_Personal_Information_new.Mothers_Bangla, Employee_Personal_Information_new.Husband, Employee_Personal_Information_new.Husband_Bangla, 
                         Employee_Personal_Information_new.Wife, Employee_Personal_Information_new.Wife_Bangla, Employee_Personal_Information_new.Date_of_Birth, Employee_Personal_Information_new.Gender, 
                         Employee_Personal_Information_new.Religion, Employee_Personal_Information_new.Marital_Status, Employee_Personal_Information_new.Personal_Phone, Employee_Personal_Information_new.TIN, 
                         Employee_Personal_Information_new.Email AS EMp_Email, Employee_Personal_Information_new.Village, Employee_Personal_Information_new.Post, Employee_Personal_Information_new.Thana, 
                         Employee_Personal_Information_new.District, Employee_Personal_Information_new.P_Village, Employee_Personal_Information_new.P_Post, Employee_Personal_Information_new.P_Thana, 
                         Employee_Personal_Information_new.P_District, Employee_Personal_Information_new.Years, Employee_Personal_Information_new.Division_name, Employee_Personal_Information_new.Division_name_Bangla, 
                         Employee_Personal_Information_new.Number_of_Child, Employee_Personal_Information_new.Hight, Employee_Personal_Information_new.House_Holder_name, Employee_Personal_Information_new.House_Hodler_Bangla, 
                         Employee_Personal_Information_new.House_Holder_Phone, Employee_Personal_Information_new.DOB, Employee_Personal_Information_new.Weight, Employee_Personal_Information_new.Hight_inchi, 
                         Employee_Salary_information_new.OT_Holder, Employee_Salary_information_new.Attendance_Bonus_Holder, Employee_Salary_information_new.Bonus_Amount, Employee_Salary_information_new.Tiffin_Holder, 
                         Employee_Salary_information_new.Night_Holder, Employee_Salary_information_new.Holiday_Holder, Employee_Salary_information_new.Gross_Salary, Employee_Salary_information_new.Bank_Salary, 
                         Employee_Salary_information_new.Cash_Salary, Employee_Salary_information_new.Tex_Holder, Employee_Salary_information_new.Tex_Amount, Employee_Salary_information_new.Bank_Holder, 
                         Employee_Salary_information_new.Bank_Name, Employee_Salary_information_new.A_C_No, Employee_Salary_information_new.Brunch_Name, Employee_Salary_information_new.Brackdown_policy, 
                         Employee_Salary_information_new.Salary_Lock, Employee_Salary_information_new.Others_Allow, tb_Education.Education_Name, tb_Education.Education_Bangla, Brack_Down_System.Basic_Salary, 
                         Brack_Down_System.Hous_Rant, Brack_Down_System.Food_Allowance, Brack_Down_System.Medicl_Allowance, Brack_Down_System.Transport_Allowance, Brack_Down_System.OT_Rate, 
                         Brack_Down_System.Absent_Deduction_Rate, TB_Designation.Designation_Catagory, Employee_Nominee_Information_New.Nominee_Name, Employee_Nominee_Information_New.Relation, 
                         Employee_Nominee_Information_New.BID AS N_BID, Employee_Nominee_Information_New.NID AS N_NID, Employee_Nominee_Information_New.Address AS Nominit_Address, 
                         Employee_Nominee_Information_New.Nominee_Name_Bangla, Employee_Nominee_Information_New.Relation_Bangla, Employee_Nominee_Information_New.Address_Bangla, 
                         Employee_Nominee_Information_New.Nominee_Date_of_Birth, Employee_Nominee_Information_New.N_Village_En, Employee_Nominee_Information_New.N_Village_Ba, Employee_Nominee_Information_New.N_Post_En, 
                         Employee_Nominee_Information_New.N_Post_Ba, Employee_Nominee_Information_New.N_Than_En, Employee_Nominee_Information_New.N_Thana_Ba, Employee_Nominee_Information_New.N_District_En, 
                         Employee_Nominee_Information_New.N_District_Ba, Employee_Job_Exprience.Factory_Name, Employee_Job_Exprience.Factory_Name_Bangla, Employee_Job_Exprience.Factory_Address, 
                         Employee_Job_Exprience.Factory_Address_Bangla, Employee_Job_Exprience.From_Date, Employee_Job_Exprience.To_Date, Employee_Job_Exprience.Total_Exprience, Employee_Job_Exprience.exp_time, 
                         Employee_Job_Exprience.Total_Exprience_Month
FROM            TB_Designation AS TB_Designation_1 INNER JOIN
                         techdefendersbd.tb_job_disciption ON TB_Designation_1.Designation_Code = techdefendersbd.tb_job_disciption.Report_To1 INNER JOIN
                         TB_Designation AS TB_Designation_2 ON techdefendersbd.tb_job_disciption.Report_To2 = TB_Designation_2.Designation_Code INNER JOIN
                         Employee_information_new INNER JOIN
                         Employee_Personal_Information_new ON Employee_information_new.ID_no = Employee_Personal_Information_new.ID_No INNER JOIN
                         Emp_Photo ON Employee_information_new.ID_no = Emp_Photo.Emp_no INNER JOIN
                         Employee_information_With_Code ON Employee_information_new.ID_no = Employee_information_With_Code.ID_no INNER JOIN
                         TB_Company ON Employee_information_With_Code.Company_Code = TB_Company.Company_Code INNER JOIN
                         TB_Department ON Employee_information_With_Code.Department_Code = TB_Department.Department_Code INNER JOIN
                         TB_Section ON Employee_information_With_Code.Section_Code = TB_Section.Section_Code INNER JOIN
                         TB_Line ON Employee_information_With_Code.Line_Code = TB_Line.Line_Code INNER JOIN
                         TB_Designation ON Employee_information_With_Code.Designation_Code = TB_Designation.Designation_Code INNER JOIN
                         z_Test_ID ON Employee_information_With_Code.ID_no = z_Test_ID.ID_No ON techdefendersbd.tb_job_disciption.Designation_Code = TB_Designation.Designation_Code INNER JOIN
                         Employee_Salary_information_new ON Employee_information_new.ID_no = Employee_Salary_information_new.ID_no INNER JOIN
                         tb_Education ON Employee_Personal_Information_new.Education = tb_Education.Education_Name INNER JOIN
                         Brack_Down_System ON Employee_information_new.ID_no = Brack_Down_System.ID_no INNER JOIN
                         Employee_Nominee_Information_New ON Employee_information_new.ID_no = Employee_Nominee_Information_New.ID_NO INNER JOIN
                         Employee_Job_Exprience ON Employee_Personal_Information_new.ID_No = Employee_Job_Exprience.ID_no 
WHERE z_Test_ID.User_ID = @u AND z_Test_ID.From_Code = @f " +
            "ORDER BY Employee_information_new.ID_no";

        protected void Page_Load(object sender, EventArgs e)
        {
            string report = Request.QueryString["report"] ?? "";
            Def def;

            if (!Reports.TryGetValue(report, out def))
            {
                litLetters.Text = "<div class=\"msg\">এই রিপোর্টের (" + E(report) + ") লেআউট যোগ করা হয়নি।</div>";
                return;
            }

            litTitle.Text = E(def.Title);
            litPageCss.Text = "<style>@media print { " + LetterPageCss + " }</style>";

            long user = HRFilters.UserCode;
            if (user == 0)
            {
                litLetters.Text = "<div class=\"msg\">User_Code পাওয়া যায়নি (Session)। Login করে আবার চেষ্টা করুন।</div>";
                return;
            }

            DataTable dt;
            try
            {
                dt = Load(user);
            }
            catch (Exception ex)
            {
                litLetters.Text = "<div class=\"msg\">Error: " + E(ex.Message) + "</div>";
                return;
            }

            if (dt.Rows.Count == 0)
            {
                litLetters.Text = "<div class=\"msg\">নির্বাচিত কর্মচারীর তথ্য পাওয়া যায়নি।</div>";
                litCount.Text = "0";
                return;
            }

            var sb = new StringBuilder();
            var seen = new HashSet<string>();   // Nominee / Experience এর একাধিক সারির জন্য একই কর্মীর পুনরাবৃত্তি বাদ
            int n = 0;
            foreach (DataRow r in dt.Rows)
            {
                if (!seen.Add(S(r, "ID_no"))) continue;
                sb.Append(def.Render(r));
                n++;
            }
            litLetters.Text = sb.ToString();
            litCount.Text = n + " employee(s)";
        }

        DataTable Load(long user)
        {
            var dt = new DataTable();
            using (SqlConnection con = conn.openConnection())
            {
                if (con.State != ConnectionState.Open) con.Open();
                using (var cmd = new SqlCommand(SqlEmp, con))
                {
                    cmd.CommandTimeout = 60;
                    cmd.Parameters.Add("@u", SqlDbType.BigInt).Value = user;
                    cmd.Parameters.Add("@f", SqlDbType.BigInt).Value = FormCode;
                    using (var da = new SqlDataAdapter(cmd)) da.Fill(dt);
                }
            }
            return dt;
        }

        // ===================== Helper =====================
        static string S(DataRow r, string col)
        {
            if (!r.Table.Columns.Contains(col) || r[col] == DBNull.Value) return "";
            return Convert.ToString(r[col]).Trim();
        }
        static string E(string s) { return HttpUtility.HtmlEncode(s ?? ""); }

        static string Bn(string s)
        {
            if (string.IsNullOrEmpty(s)) return s;
            var sb = new StringBuilder();
            foreach (char c in s)
                sb.Append((c >= '0' && c <= '9') ? (char)('\u09E6' + (c - '0')) : c);
            return sb.ToString();
        }

        static string D(DataRow r, string col)
        {
            string v = S(r, col);
            DateTime dt;
            if (v != "" && DateTime.TryParse(v, out dt)) return Bn(dt.ToString("dd/MM/yyyy", CultureInfo.InvariantCulture));
            return E(v);
        }

        static string M(DataRow r, string col)
        {
            decimal d;
            if (decimal.TryParse(S(r, col), NumberStyles.Any, CultureInfo.InvariantCulture, out d))
                return Bn(d.ToString("N0", CultureInfo.InvariantCulture)) + "/=";
            return "";
        }

        static string Age(DataRow r, string col)
        {
            DateTime dt;
            if (!DateTime.TryParse(S(r, col), out dt)) return "";
            int a = DateTime.Today.Year - dt.Year;
            if (dt.Date > DateTime.Today.AddYears(-a)) a--;
            return Bn(a.ToString());
        }

        static string Img(DataRow r, string col, string css)
        {
            byte[] b = r.Table.Columns.Contains(col) && r[col] != DBNull.Value ? r[col] as byte[] : null;
            if (b == null || b.Length == 0) return "<span class='" + css + " noimg'></span>";
            return "<img class='" + css + "' src='data:image/jpeg;base64," + Convert.ToBase64String(b) + "' />";
        }

        static string Join(params string[] parts)
        {
            var l = new List<string>();
            foreach (string p in parts) if (!string.IsNullOrWhiteSpace(p)) l.Add(p.Trim());
            return string.Join(", ", l.ToArray());
        }

        static string Present(DataRow r) { return E(Join(S(r, "B_Village"), S(r, "B_Post"), S(r, "B_Thana"), S(r, "B_District"))); }
        static string Permanent(DataRow r) { return E(Join(S(r, "B_P_Village"), S(r, "B_P_Post"), S(r, "B_P_Thana"), S(r, "B_P_District"))); }
        static string Spouse(DataRow r) { return E(S(r, "Husband_Bangla") != "" ? S(r, "Husband_Bangla") : S(r, "Wife_Bangla")); }

        static string KV(string k, string v) { return "<tr><td class='k'>" + k + "</td><td>ঃ " + v + "</td></tr>"; }
        static string Sheet(string inner) { return "<div class='sheet'>" + inner + "</div>"; }

        static string Head(DataRow r, string title)
        {
            return "<div class='hd'><h1>" + E(S(r, "Conmany_Bangla")) + "</h1><div class='sub'>" + E(S(r, "Bangla_Address")) + "</div></div>" +
                   (title != "" ? "<div class='ttl'>" + title + "</div>" : "");
        }

        static string Sign(string a, string b) { return "<div class='sign'><div>" + a + "</div><div>" + b + "</div></div>"; }

        // ===================== 1. Appointment Letter =====================
        static string AppointmentLetter(DataRow r)
        {
            string jd = D(r, "Joining_Date");
            decimal basic;
            string otRate = "";
            if (decimal.TryParse(S(r, "Basic_Salary"), NumberStyles.Any, CultureInfo.InvariantCulture, out basic))
                otRate = Bn((basic / 208m * 2m).ToString("0.00", CultureInfo.InvariantCulture));

            var sb = new StringBuilder();
            sb.Append(Head(r, "(নিয়োগ পত্র / APPOINTMENT LETTER)"));
            sb.Append("<div style='text-align:right'>তারিখঃ " + jd + " ইং</div>");
            sb.Append("<table class='kv'>");
            sb.Append("<tr><td>১। নামঃ <b>" + E(S(r, "Bangla_name")) + "</b></td><td></td></tr>");
            sb.Append("<tr><td>২। পিতার নামঃ " + E(S(r, "Fathers_Bangla")) + "</td><td>৩। মাতার নামঃ " + E(S(r, "Mothers_Bangla")) + "</td></tr>");
            sb.Append("<tr><td>৪। স্বামীর (যদি থাকে)ঃ " + E(S(r, "Husband_Bangla")) + "</td><td>৫। স্ত্রীর নাম (যদি থাকে)ঃ " + E(S(r, "Wife_Bangla")) + "</td></tr>");
            sb.Append("<tr><td>৬। ব্যক্তিগত মোবাইল নংঃ " + Bn(E(S(r, "Personal_Phone"))) + "</td><td>৭। জাতীয় পরিচয় পত্রের নংঃ " + Bn(E(S(r, "NID"))) + "</td></tr>");
            sb.Append("<tr><td colspan='2'>৮। বর্তমান ঠিকানাঃ " + Present(r) + "</td></tr>");
            sb.Append("<tr><td colspan='2'>৯। স্থায়ী ঠিকানাঃ " + Permanent(r) + "</td></tr>");
            sb.Append("</table>");
            sb.Append("<p><b><u>বিষয়ঃ চাকুরীর নিয়োগপত্র।</u></b></p><p>জনাব,</p>");
            sb.Append("<p class='j'>আপনার " + jd + " ইং তারিখের আবেদনপত্র ও সাক্ষাতের পরিপ্রেক্ষিতে আপনাকে " + jd + " ইং তারিখ হইতে নিম্ন বর্ণিত শর্ত সাপেক্ষে অত্র প্রতিষ্ঠানে নিয়োগ দেওয়া হলোঃ</p>");
            sb.Append("<table class='kv'><tr><td>১০। <b>আপনার বর্তমান পদবীঃ</b> " + E(S(r, "Designation_Bangla")) + "<br/><b>আই ডি নংঃ " + Bn(E(S(r, "ID_no"))) + "</b></td>" +
                      "<td>বিভাগঃ " + E(S(r, "Department_Bangla")) + "<br/>গ্রেডঃ " + Bn(E(S(r, "Grade"))) + "</td>" +
                      "<td><b>সেকশনঃ</b> " + E(S(r, "Section_bangla_Name")) + "<br/>কাজের ধরণঃ " + E(S(r, "Work_Type_Bangla")) + "</td></tr></table>");
            sb.Append("<p>১১। আপনার বর্তমান মাসিক মজুরী হবে নিম্নরূপঃ</p>");
            sb.Append("<table class='kv' style='width:65%'>");
            sb.Append(KV("মূল মজুরি", M(r, "Basic_Salary") + " টাকা"));
            sb.Append(KV("বাড়ী ভাড়া", M(r, "Hous_Rant") + " টাকা"));
            sb.Append(KV("খাদ্য ভাতা", M(r, "Food_Allowance") + " টাকা"));
            sb.Append(KV("যাতায়াত ভাতা", M(r, "Transport_Allowance") + " টাকা"));
            sb.Append(KV("চিকিৎসা ভাতা", M(r, "Medicl_Allowance") + " টাকা"));
            sb.Append("<tr><td class='k'><b>সর্বমোট মজুরী</b></td><td><b>ঃ " + M(r, "Gross_Salary") + " টাকা</b></td></tr></table>");
            sb.Append("<p class='j'>* ওটি হার (প্রতি ঘন্টা)ঃ " + otRate + " &nbsp;&nbsp;&nbsp; * বাৎসরিক মজুরি বৃদ্ধির হার মূল মজুরীর ৯%</p>");

            sb.Append(@"
<p class='j'>১২। আপনি চাকুরীর প্রথম ০৩ (তিন) মাস শিক্ষানবিশ থাকবেন। উক্ত সময়ের পরে আপনার কর্মদক্ষতা বিবেচনা পূর্বক কর্তৃপক্ষ আপনাকে স্থায়ী করতে পারেন অথবা শিক্ষানবিশকাল আরও তিন (৩) মাস বৃদ্ধি করতে পারবেন। কৃতিত্বের সহিত শিক্ষানবিশকাল সমাপ্তির পর আপনি এই প্রতিষ্ঠানের নিয়মিত শ্রমিক কর্মচারী হিসাবে বিবেচিত হবেন। এর জন্য আলাদা কোন পত্র দেওয়া হইবেনা। শিক্ষানবিশ কাল থাকাকালীন যদি আপনার কাজের মান সন্তোষজনক না হয় তবে কর্তৃপক্ষ কোন প্রকার নোটিশ ও কারণ দর্শানো ব্যতিরেকে আপনাকে চাকুরী হইতে অপসারণ করতে পারবেন। এই সময় আপনি কোন প্রকার অবসান ভাতাদি পাবেন না।</p>
<p class='j'>১৩। চাকুরী হতে অপসারণ অথবা অব্যহতিঃ<br/>
(ক) চাকুরী নিশ্চিত হওয়ার পরও উভয় পক্ষ চাকুরী অপসারণ করতে পারবেন। সে ক্ষেত্রে আপনি ৬০ (ষাট) দিনের লিখিত নোটিশ দিয়ে চাকুরী হতে অব্যহতি নিতে পারবেন। নোটিশ দিতে ব্যর্থ হলে ২(দুই) মাসের মূল মজুরীর সমপরিমান টাকা জমা দিয়ে চাকুরী হতে অব্যহতি নিতে পারবেন।<br/>
(খ) মাসিক মজুরীর ভিত্তিতে নিয়োজিত শ্রমিকের ক্ষেত্রে ১২০ দিনের এবং অন্য শ্রমিকের ক্ষেত্রে ৬০ দিনের নোটিশ অথবা নোটিশের পরিবর্তে নোটিশ মেয়াদের জন্য মজুরী প্রদান করিয়া মালিক কোন স্থায়ী শ্রমিকের চাকুরী অবসান করিতে পারিবেন।</p>
<p class='j'>১৪। কর্ম সময়ঃ স্বাভাবিক কর্ম সময় দিনে ৮ (আট) ঘন্টা। কর্তৃপক্ষ প্রয়োজনবোধে আপনাকে অতিরিক্ত সময় কাজ করাতে পারবে (যা বাধ্যতামূলক নয়)। সেক্ষেত্রে অতিরিক্ত সময়ের মজুরী দ্বিগুণ হারে মজুরী পরিশোধ করা হবে। যার হিসাব হবে এরূপ (মূল মজুরী/২০৮)*২* অতিরিক্ত কর্মঘন্টা।</p>
<p class='j'>১৫। ছুটি ও বন্ধঃ আপনি নিম্নে বর্ণিত হারে ছুটি পাবেনঃ<br/>
ক) সাপ্তাহিক ছুটিঃ সপ্তাহে ০১ একদিন (শুক্রবার অথবা সরকার নির্ধারিত আদেশ মোতাবেক)।<br/>
খ) নৈমিত্তিক ছুটিঃ প্রতি পঞ্জিকা বৎসরে পূর্ণ মজুরীতে ১০ (দশ) দিন।<br/>
গ) পীড়া ছুটিঃ প্রতি পঞ্জিকা বৎসরে পূর্ণ মজুরীতে ১৪ (চৌদ্দ) দিন।<br/>
ঘ) বাৎসরিক ছুটিঃ প্রতি ১৮ (আঠারো) কর্ম দিবসের জন্য ১ (এক) দিন, তবে চাকুরীর মেয়াদ কমপক্ষে অবিচ্ছিন্ন ভাবে ০১ বৎসর পূর্ণ হলে এই ছুটি ভোগ করতে পারবেন এবং সর্বোচ্চ ৪০ দিন পর্যন্ত জমা করা যাবে।<br/>
ঙ) উৎসব ছুটিঃ প্রতি পঞ্জিকা বৎসরে পূর্ণ মজুরীতে কমপক্ষে ১১ (এগার) দিন।<br/>
চ) মাতৃত্বকালীন ছুটিঃ পূর্ণ মজুরীতে ১২০ (একশত বিশ) দিন। [শুধু মাত্র মহিলা শ্রমিকদের ক্ষেত্রে শ্রম আইন অনুযায়ী প্রযোজ্য]</p>
<p class='j'>১৬। আহারের /বিশ্রামের বিরতি ১ ঘন্টা।</p>
<p class='j'>১৭। আপনি যদি কখনো কোনরূপ অসদাচরণের অপরাধে দোষী প্রমানিত হন তবে কর্তৃপক্ষ আপনার বিরুদ্ধে আইনগত শাস্তি মূলক ব্যবস্থা গ্রহণ করিতে পারবে।</p>
<p class='j'>১৮। আপনি কোম্পানীর অন্যান্য সুযোগ সুবিধা (যেমন মাসিক হাজিরা বোনাস, উৎসব বোনাস ইত্যাদি কোম্পানির প্রচলিত নিয়ম অনুযায়ী পাবেন।</p>
<p class='j'>১৯। কোম্পানীর প্রয়োজনে স্ব-মালিকানাধীন অন্য যে কোন কারখানায় বদলী করিতে পারিবে।</p>
<p class='j'>২০। আপনি আপনার ঠিকানা পরিবর্তন করিলে ৭ (সাত) দিনের মধ্যে অফিসকে লিখিত ভাবে জানাইতে হইবে।</p>
<p class='j'>২১। সর্বোপরী আপনার চাকুরীর যাবতীয় শর্তাবলী বিদ্যমান শ্রম আইন অনুযায়ী পরিচালিত হবে।</p>
<p class='j'>উপরে বর্ণিত শর্তাদি যদি আপনার গ্রহণ যোগ্য মনে হয় তবে আপনার সম্মতি স্বরূপ এই নিয়োগ পত্রের অনুলিপিতে স্বাক্ষর করে নিম্নে স্বাক্ষর কারীর নিকট ফেরত দিবেন।</p>");
            sb.Append(Sign("শ্রমিকের স্বাক্ষর", "নিয়োগকারীর স্বাক্ষর"));
            return Sheet(sb.ToString());
        }

        // ===================== 2. ID Card =====================
        static string IdCard(DataRow r)
        {
            var sb = new StringBuilder();
            sb.Append("<div class='ttl'>আইডি কার্ড (সামনে ও পিছনে)</div>");

            // সামনের পাশ
            sb.Append("<div class='card'><div style='text-align:right;font-size:12px'>ইস্যুর তারিখঃ " + D(r, "Joining_Date") + "</div>");
            sb.Append("<div class='top'>" + Img(r, "Company_Logo", "logo") +
                      "<div class='mid'><h2>" + E(S(r, "Conmany_Bangla")) + "</h2><div style='font-size:12px'>" + E(S(r, "Bangla_Address")) + "</div></div>" +
                      Img(r, "Photo", "photo") + "</div>");
            sb.Append("<table class='kv' style='margin-top:6px'>");
            sb.Append(KV("নাম", "<b>" + E(S(r, "Bangla_name")) + "</b>"));
            sb.Append(KV("পদবী", E(S(r, "Designation_Bangla"))));
            sb.Append(KV("কাজের ধরন", E(S(r, "Work_Type_Bangla"))));
            sb.Append(KV("বিভাগ/শাখা", E(S(r, "Department_Bangla"))));
            sb.Append(KV("যোগদানের তাং", D(r, "Joining_Date")));
            sb.Append(KV("টিকেট / কার্ড নং", "<b>" + Bn(E(S(r, "ID_no"))) + "</b>"));
            sb.Append("</table>");
            sb.Append("<div class='sign' style='margin-top:30px'><div>শ্রমিকের স্বাক্ষর</div><div>কর্তৃপক্ষের স্বাক্ষর</div></div></div>");

            // পিছনের পাশ
            sb.Append("<div class='card'><div style='text-align:center;font-weight:bold;border-bottom:1px solid #000;padding-bottom:4px'>মেয়াদঃ চাকুরী স্থায়ী কাল পর্যন্ত।</div><div class='back' style='margin-top:6px'>");
            sb.Append("<div><p>কারখানা/ প্রতিষ্ঠানের ঠিকানাঃ<br/>" + E(S(r, "Bangla_Address")) + "</p>" +
                      "<p>টেলিফোন নম্বরঃ " + Bn(E(S(r, "Phone"))) + "</p>" +
                      "<p>উক্ত পরিচয় পত্র হারাইয়া গেলে তাৎক্ষণিক কারখানা কর্তৃপক্ষকে জানাইতে হইবে।</p></div>");
            sb.Append("<div><p>রক্তের গ্রুপঃ <b>" + E(S(r, "Blood_Group")) + "</b></p><p><u>স্থায়ী ঠিকানা</u><br/>" + Permanent(r) + "</p>" +
                      "<p>জরুরি ফোন নংঃ " + Bn(E(S(r, "Home_Phone"))) + "<br/>জাতীয় পরিচয় নংঃ " + Bn(E(S(r, "NID"))) + "</p></div>");
            sb.Append("</div></div>");
            return Sheet(sb.ToString());
        }

        // ===================== 3. Background Check =====================
        static string BackgroundCheck(DataRow r)
        {
            string[] rows = {
                "আপনি কি তাকে চিনেন ?",
                "কতদিন যাবৎ আপনি তাকে চিনেন ?",
                "আপনার সাথে তার সম্পর্ক কি ?",
                "তার বাবার নাম কি ?",
                "তার স্থায়ী ঠিকানা কি ?",
                "আপনার জানামতে তার নামে থানায় কোন অভিযোগ আছে কিনা ?",
                "যদি থাকে, কি ধরনের অভিযোগ ? এবং দণ্ডপ্রাপ্ত আসামী কিনা ?",
                "আপনার জানামতে সে পূর্বে রাষ্ট্র বিরোধী কোন কাজে লিপ্ত ছিল কিনা ?",
                "আপনার জানামতে সে পূর্বে রাষ্ট্র বিরোধী বা নিষিদ্ধ কোন সংগঠনের সাথে জড়িত কিনা ?",
                "তার চরিত্রের ব্যাপারে আপনার মন্তব্য-",
                "আপনার কি মনে হয় তিনি রপ্তানিমুখী গার্মেন্টস এক্সেসরিজ প্রতিষ্ঠানে চাকুরী করার যোগ্য ?" };
            string[] ans = { "হ্যাঁ / না", "", "", "", "", "হ্যাঁ / না", "", "হ্যাঁ / না", "হ্যাঁ / না", "ভালো / খারাপ", "যোগ্য / অযোগ্য" };

            var sb = new StringBuilder();
            sb.Append(Head(r, "শ্রমিক/কর্মচারীর ব্যক্তিগত তথ্য যাচাই ফরম"));
            sb.Append("<table class='kv'>");
            sb.Append(KV("শ্রমিক/কর্মচারীর নাম", "<b>" + E(S(r, "Bangla_name")) + "</b>"));
            sb.Append(KV("পদবী", E(S(r, "Designation_Bangla"))));
            sb.Append(KV("বিভাগ/শাখা", E(S(r, "Department_Bangla"))));
            sb.Append(KV("আই ডি নং", Bn(E(S(r, "ID_no")))));
            sb.Append(KV("তারিখ", D(r, "Joining_Date")));
            sb.Append("</table><br/>");
            sb.Append("<table class='bd'><tr><th style='width:6%'>ক্রঃনং</th><th>বিষয়</th><th style='width:17%'>সূত্র-১</th><th style='width:17%'>সূত্র-২</th><th style='width:17%'>সূত্র-৩</th></tr>");
            for (int i = 0; i < rows.Length; i++)
                sb.Append("<tr><td>" + Bn((i + 1).ToString()) + "</td><td>" + rows[i] + "</td><td>" + ans[i] + "</td><td>" + ans[i] + "</td><td>" + ans[i] + "</td></tr>");
            sb.Append("<tr><td colspan='2'>নামঃ</td><td></td><td></td><td></td></tr>");
            sb.Append("<tr><td colspan='2'>পেশাঃ</td><td></td><td></td><td></td></tr>");
            sb.Append("<tr><td colspan='2'>ঠিকানাঃ</td><td></td><td></td><td></td></tr>");
            sb.Append("<tr><td colspan='2'>ফোনঃ</td><td></td><td></td><td></td></tr></table>");
            sb.Append("<p>মন্তব্যঃ (তথ্য যাচাইকারী)</p><p>মন্তব্যঃ (মানব সম্পদ ও প্রশাসন বিভাগ)</p>");
            sb.Append(Sign("তথ্য যাচাইকারীর স্বাক্ষর", "মানব সম্পদ"));
            return Sheet(sb.ToString());
        }

        // ===================== 4. Job Description =====================
        static string JobDescription(DataRow r)
        {
            string des = E(S(r, "Designation_Bangla"));
            var sb = new StringBuilder();
            sb.Append(Head(r, "-ঃ " + des + " এর দায়িত্ব ও কর্তব্য ঃ-"));
            sb.Append("<table class='kv'>");
            sb.Append(KV("আই ডি নং", Bn(E(S(r, "ID_no")))));
            sb.Append(KV("নাম", E(S(r, "Bangla_name"))));
            sb.Append(KV("পদবী", des));
            sb.Append(KV("বিভাগ", E(S(r, "Department_Bangla"))));
            sb.Append(KV("প্রত্যক্ষ রিপোর্ট", E(S(r, "Report_to1"))));
            sb.Append(KV("পরোক্ষ রিপোর্ট", E(S(r, "Report_to2"))));
            sb.Append("</table><p><b>প্রধান দায়িত্ব সমূহঃ</b></p>");

            string resp = S(r, "Responsibilities");
            if (resp != "")
                sb.Append("<p class='j'>" + E(resp).Replace("\n", "<br/>") + "</p>");
            else
                sb.Append(@"<p class='j'>
১। যথা সময়ে ফ্যাক্টরীতে উপস্থিত হওয়া এবং কার্যক্রম শুরু করা।<br/>
২। ইন-চার্জ / ম্যানেজার কর্তৃক আরোপিত অপরাপর দায়িত্ব পালন করা।<br/>
৩। কাজ শুরু করার পূর্বে সকল কাটিং সরঞ্জামাদির কার্যক্ষমতা স্বশরীরে পরীক্ষা করা।<br/>
৪। যে স্টাইল বা অর্ডারের এর পণ্য ছাপা হবে তার বায়ার অনুমোদিত স্যাম্পল সংগ্রহ করতে হবে।<br/>
৫। কাজ এর পর প্রতিটি মেশিন ভালভাবে পরিস্কার করা।<br/>
৬। কাজ চলাকালীন সময়ে কোন প্রকার ত্রুটি দেখা দিলে সাথে সাথে সুপারভাইজারকে অবহিত করা।<br/>
৭। নিজের ও সেকশনের যাবতীয় নিরাপত্তার বিষয়ে সচেষ্ট হওয়া।<br/>
৮। শৃংখলা ও নিয়মানুবর্তীতা বজায় রাখা এবং কোম্পানির নিয়ম কানুনের (যেমনঃ পিপিই, আই.ডি. কার্ড পরিধান) প্রতি শ্রদ্ধা রেখে তা অনুসরণ করা।<br/>
৯। উর্দ্ধতন কর্তৃপক্ষের নির্দেশ অনুযায়ী কাজ করা।<br/>
১০। ৫এস পদ্ধতি বুঝে নিয়ে সে অনুযায়ী কর্মস্থলকে সবসময় গুছিয়ে রাখা ও আপনার অধীনস্তদের মাঝে ৫ এস এর চর্চা নিশ্চিত করতে হবে।<br/>
১১। বায়ার কমপ্লায়েন্স ও কোম্পানীর নির্দেশিত সকল আইন কানুন ও নিয়ম শৃংখলা যথাযথভাবে মেনে চলা।</p>");

            sb.Append("<p class='j' style='margin-top:40px'>আমি <b><u>" + E(S(r, "Bangla_name")) + "</u></b>, এই মর্মে নিশ্চয়তা প্রদান করিতেছি যে, উপরোক্ত বিষয় পড়ে পরিপূর্ণ ভাবে বুঝতে পেরেছি। আমি আরও অবগত আছি যে, ইহার একটি প্রতিলিপি আমার ব্যক্তিগত নথিতে সংরক্ষিত হইবে।</p>");
            sb.Append(Sign("কর্মীর স্বাক্ষর", "মানব সম্পদ"));
            return Sheet(sb.ToString());
        }

        // ===================== 5. Nominee Form (ফরম-৪১) =====================
        static string NomineeForm(DataRow r)
        {
            string nomAddr = E(Join(S(r, "N_Village_Ba"), S(r, "N_Post_Ba"), S(r, "N_Thana_Ba"), S(r, "N_District_Ba")));
            var sb = new StringBuilder();
            sb.Append("<div style='text-align:center'><b>ফরম- ৪১</b><br/><small>[ধারা ১৯,১৩১(১)(ক), ১৫৫(২), ২৩৪,২৬৪,২৬৫ ও ২৭৩ এবং বিধি-১১৮(১),১৩৬,২৩২(২),২৬২(১),২৮৯(১) ও ৩২১(১) দ্রষ্টব্য]</small></div>");
            sb.Append("<div class='ttl'>জমা ও বিভিন্নখাতে প্রাপ্য অর্থ পরিশোধের ঘোষণা ও মনোনয়নের ফরম</div>");
            sb.Append("<table class='kv'>");
            sb.Append(KV("কারখানা/ প্রতিষ্ঠানের নাম", E(S(r, "Conmany_Bangla"))));
            sb.Append(KV("কারখানা / প্রতিষ্ঠানের ঠিকানা", E(S(r, "Bangla_Address"))));
            sb.Append(KV("শ্রমিকের নাম", "<b>" + E(S(r, "Bangla_name")) + "</b>"));
            sb.Append(KV("লিঙ্গ", E(S(r, "Gender"))));
            sb.Append(KV("পিতার নাম", E(S(r, "Fathers_Bangla"))));
            sb.Append(KV("মাতার নাম", E(S(r, "Mothers_Bangla"))));
            sb.Append(KV("স্বামী/স্ত্রীর নাম", Spouse(r)));
            sb.Append(KV("জন্ম তারিখ", D(r, "Date_of_Birth")));
            sb.Append(KV("বর্তমান ঠিকানা", Present(r)));
            sb.Append(KV("স্থায়ী ঠিকানা", Permanent(r)));
            sb.Append(KV("চাকুরীতে নিযুক্তির তারিখ", D(r, "Joining_Date")));
            sb.Append(KV("পদের নাম", E(S(r, "Designation_Bangla"))));
            sb.Append(KV("আই. ডি. নং", Bn(E(S(r, "ID_no")))));
            sb.Append("</table>");
            sb.Append("<p class='j' style='margin-top:10px'>আমি এতদ্বারা ঘোষণা করিতেছি যে, আমার মৃত্যু হইলে বা আমার অবর্তমানে, আমার অনুকূলে জমা ও বিভিন্নখাতে প্রাপ্য টাকা গ্রহণের জন্য আমি নির্ধারিত ব্যক্তি/ব্যক্তিগণকে মনোনয়ন দান করিতেছি এবং নির্দেশ দিচ্ছি যে, উক্ত টাকা নির্ধারিত পদ্ধতিতে মনোনীত ব্যক্তিদের মধ্যে বণ্টন করিতে হইবে।</p>");
            sb.Append("<table class='bd'><tr><th>মনোনীত ব্যক্তির নাম, ঠিকানা ও ছবি</th><th>এন আই ডি নং</th><th>সদস্যদের সহিত সম্পর্ক</th><th>বয়স</th><th>প্রত্যেক মনোনীত ব্যক্তিকে দেওয়া অংশ</th></tr>");
            sb.Append("<tr><td>" + E(S(r, "Nominee_Name_Bangla")) + "<br/>" + nomAddr + "</td><td>" + Bn(E(S(r, "N_NID"))) + "</td><td>" +
                      E(S(r, "Relation_Bangla")) + "</td><td>" + Age(r, "Nominee_Date_of_Birth") + " বছর</td><td>১০০%</td></tr></table>");
            sb.Append("<p class='j' style='margin-top:10px'>প্রত্যয়ন করিতেছি যে, আমার উপস্থিতিতে জনাব/জনাবা <b>" + E(S(r, "Nominee_Name_Bangla")) + "</b> লিপিবদ্ধ বিবরণসমূহ পাঠ করিবার পর উক্ত ঘোষণা পত্রে স্বাক্ষর করিয়াছেন।</p>");
            sb.Append("<div class='sign' style='margin-top:40px'><div>মনোনয়ন প্রদানকারী শ্রমিকের স্বাক্ষর, টিপসহি ও তারিখ<br/>" + D(r, "Joining_Date") + "</div><div>মালিকের বা অধিকার প্রাপ্ত কর্মকর্তার স্বাক্ষর<br/>তারিখঃ " + D(r, "Joining_Date") + "</div></div>");
            return Sheet(sb.ToString());
        }

        // ===================== 6. Medical Form (ফরম-১৫) =====================
        static string MedicalForm(DataRow r)
        {
            var sb = new StringBuilder();
            sb.Append("<div style='text-align:center'><b>ফরম-১৫</b><br/><small>ধারা ৩৪,৩৬,৩৭ ও ২৭৭ এবং বিধি ৩৪(১) ও ৩৩৬(৪) দ্রষ্টব্য</small></div>");
            sb.Append("<div class='ttl'>বয়স ও সক্ষমতা প্রত্যয়ন পত্র<br/><small>(রেজিস্টার্ড চিকিৎসকের প্যাড-এ)</small></div>");
            sb.Append("<table class='kv'>");
            sb.Append(KV("১। ক্রমিক নং", Bn(E(S(r, "ID_no")))));
            sb.Append(KV("তারিখ", D(r, "Joining_Date")));
            sb.Append(KV("২। নাম", "<b>" + E(S(r, "Bangla_name")) + "</b>"));
            sb.Append(KV("৩। পিতার নাম", E(S(r, "Fathers_Bangla"))));
            sb.Append(KV("৪। মাতার নাম", E(S(r, "Mothers_Bangla"))));
            sb.Append(KV("৫। লিঙ্গ", E(S(r, "Gender"))));
            sb.Append(KV("৬। স্থায়ী ঠিকানা", Permanent(r)));
            sb.Append(KV("৭। অস্থায়ী / যোগাযোগের ঠিকানা", Present(r)));
            sb.Append(KV("৮। জন্ম সনদ / জাতীয় পরিচয় পত্র / নাগরিকত্ব সনদ / শিক্ষা সনদ", Bn(E(S(r, "NID")))));
            sb.Append(KV("৯। দৈহিক সক্ষমতা", "ক্রটিমুক্ত"));
            sb.Append("</table>");
            string h = S(r, "Hight"), hi = S(r, "Hight_inchi"), w = S(r, "Weight");
            sb.Append("<p class='j' style='margin-top:10px'>আমি এই মর্মে প্রত্যয়ন করিতেছি যে, তিনি প্রতিষ্ঠানে নিযুক্ত হইতে ইচ্ছুক এবং আমার পরীক্ষা হইতে এরূপ পাওয়া গিয়াছে যে, তাহার বয়স <b>" + Age(r, "Date_of_Birth") + "</b> বছর এবং তিনি প্রতিষ্ঠানে প্রাপ্তবয়স্ক/ কিশোর হিসাবে নিযুক্ত হইবার যোগ্য।</p>");
            sb.Append("<p>তাহার সনাক্তকরণের চিহ্নঃ</p>");
            sb.Append("<p>ডাক্তারী পরীক্ষাঃ উচ্চতাঃ " + Bn(E(h)) + " ফুট " + Bn(E(hi)) + " ইঞ্চি। ওজনঃ " + Bn(E(w)) + " কেজি।</p>");
            sb.Append("<p>চোখের পরীক্ষাঃ<br/>ক) সঠিকভাবে বর্ণ বা রং চিনতে পারে কিনাঃ হ্যাঁ<br/>খ) ত্রুটিপূর্ণ দৃষ্টিশক্তি কিনাঃ না</p>");
            sb.Append("<div class='sign' style='margin-top:60px'><div>সংশ্লিষ্ট ব্যক্তির স্বাক্ষর/টিপ সহি</div><div>রেজিস্টার্ড চিকিৎসকের স্বাক্ষর</div></div>");
            return Sheet(sb.ToString());
        }

        // ===================== 7. Joining Letter (চাকুরীর জন্য আবেদন) =====================
        static string JoiningLetter(DataRow r)
        {
            string des = E(S(r, "Designation_Bangla"));
            string exp = S(r, "Total_Exprience") != "" ? Bn(E(S(r, "Total_Exprience"))) + " বছর " + Bn(E(S(r, "Total_Exprience_Month"))) + " মাস" : "০ বছর ০ মাস";
            var sb = new StringBuilder();
            sb.Append(Head(r, "চাকুরীর জন্য আবেদন"));
            sb.Append("<p>বরাবর,<br/>ব্যবস্থাপনা পরিচালক<br/>" + E(S(r, "Conmany_Bangla")) + "<br/>" + E(S(r, "Bangla_Address")) + "</p>");
            sb.Append("<p><b>বিষয়ঃ \"<u>" + des + "</u>\" পদে চাকুরীর জন্য আবেদন।</b></p><p>জনাব,</p>");
            sb.Append("<p class='j'>যথাবিহিত সম্মান পূর্বক বিনীত নিবেদন এই যে, আমি বিশেষ সূত্রে জানতে পারলাম যে, আপনার গার্মেন্টস এক্সেসরিজ উৎপাদনকারী প্রতিষ্ঠানে কিছু সংখ্যক লোক নিয়োগ করা হবে। আমি উক্ত পদের জন্য একজন আগ্রহী প্রার্থী/প্রার্থিনী হিসাবে আবেদন করছি।</p>");
            sb.Append("<p>নিম্নে আমার জীবন বৃত্তান্ত আপনার সুবিবেচনার জন্য পেশ করা হলোঃ-</p><table class='kv'>");
            sb.Append(KV("১। নাম", E(S(r, "Bangla_name"))));
            sb.Append(KV("২। পিতার নাম", E(S(r, "Fathers_Bangla"))));
            sb.Append(KV("৩। মাতার নাম", E(S(r, "Mothers_Bangla"))));
            sb.Append(KV("৪। স্বামী/ স্ত্রীর নাম", Spouse(r)));
            sb.Append(KV("৫। স্থায়ী ঠিকানা", Permanent(r)));
            sb.Append(KV("৬। বাড়ীওয়ালার নাম / মোবাইল নম্বর", ""));
            sb.Append(KV("৭। বর্তমান ঠিকানা", Present(r)));
            sb.Append(KV("৮। ব্যক্তিগত নং (জন্ম সনদ)", ""));
            sb.Append(KV("৯। জাতীয় পরিচয় পত্র নম্বর", Bn(E(S(r, "NID")))));
            sb.Append(KV("১০। শিক্ষাগত যোগ্যতা", E(S(r, "Education_Bangla"))));
            sb.Append(KV("১১। জন্ম তারিখ", D(r, "Date_of_Birth")));
            sb.Append(KV("১২। বৈবাহিক অবস্থা", E(S(r, "Marital_Status"))));
            sb.Append(KV("১৩। সন্তানের সংখ্যা", Bn(E(S(r, "Number_of_Child"))) + " জন"));
            sb.Append(KV("১৪। জাতীয়তা", "বাংলাদেশী"));
            sb.Append(KV("১৫। অভিজ্ঞতা", exp));
            sb.Append(KV("১৬। সর্বশেষ কর্মস্থল", E(S(r, "Factory_Name_Bangla"))));
            sb.Append(KV("১৭। জরুরী প্রয়োজনে পরিবার / নিকট আত্মীয়ের সাথে যোগাযোগের ফোন/ মোবাইল নং", Bn(E(S(r, "Home_Phone")))));
            sb.Append("</table>");
            sb.Append("<p class='j'>১৮। অঙ্গীকার ঃ আমি এই মর্মে অঙ্গীকার করিতেছি যে, উপরে উল্লেখিত আমার সকল তথ্য সম্পূর্ণ সত্য এবং সকল সনদপত্র সঠিক।</p>");
            sb.Append("<p class='j'>১৯। মাধ্যম বা পরিচিত ব্যক্তির নামঃ</p>");
            sb.Append("<p class='j'>অতএব হুজুরের সমীপে প্রার্থনা এই যে উপরোক্ত বিষয় সমূহ বিবেচনা করে আমাকে উক্ত পদে নিয়োগ দান করে বাধিত করবেন।</p>");
            sb.Append("<div style='display:flex;justify-content:space-between;margin-top:14px'><div>তারিখঃ " + D(r, "Joining_Date") + "</div><div style='text-align:right'>বিনীত<br/><br/>নিবেদক/নিবেদিকা</div></div>");

            sb.Append("<hr style='border-top:1px dashed #000;margin:14px 0'/>");
            sb.Append("<div style='text-align:center'><u>বিভাগীয় প্রধান কর্তৃক পূরনীয়</u></div>");
            sb.Append("<p class='j'>জনাব/জনাবা <b>" + E(S(r, "Bangla_name")) + "</b> কে " + des + " পদে নিম্নলিখিত শর্তে নিয়োগ প্রদানের জন্য সুপারিশ করা হল।</p>");
            sb.Append("<p class='j'>তার আইডি নংঃ <b>" + Bn(E(S(r, "ID_no"))) + "</b> লাইনঃ " + E(S(r, "Line_bangla_Name")) + ", সর্বমোট মজুরীঃ <b>" + M(r, "Gross_Salary") + "</b> টাকা, যোগদানের তারিখঃ " + D(r, "Joining_Date") + ",<br/>কর্মদক্ষতার গ্রেডঃ " + Bn(E(S(r, "Grade"))) + "।</p>");
            sb.Append("<div class='sign' style='margin-top:40px;font-size:12px'><div>সুপারভাইজার/<br/>ইনচার্জ</div><div>বিভাগ / শাখা প্রধান</div><div>জিএম<br/>(মার্কেটিং এন্ড অপারেশন)</div><div>বিভাগীয় প্রধান<br/>(এইচ আর এন্ড কমপ্লায়েন্স)</div><div>নিয়োগকারীর স্বাক্ষর</div></div>");
            return Sheet(sb.ToString());
        }
    }
}
