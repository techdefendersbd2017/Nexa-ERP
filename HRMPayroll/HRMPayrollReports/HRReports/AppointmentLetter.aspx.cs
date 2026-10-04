using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Text;
using System.Web;
using System.Web.UI;

// ASPX এর Inherits="Nexa_ERP.HRMPayroll.HRMPayrollReports.HRReports.AppointmentLetter" এর সঙ্গে মিলতে হবে
namespace Nexa_ERP.HRMPayroll.HRMPayrollReports.HRReports
{
    public partial class AppointmentLetter : Page
    {
        PayrollDB conn = new PayrollDB();
        static readonly CultureInfo Inv = CultureInfo.InvariantCulture;

        // ---------- প্রতিটি নিয়োগপত্রের তথ্য (সব আগে থেকে ফরম্যাট করা) ----------
        public class Letter
        {
            public string CompanyName { get; set; }
            public string CompanyAddress { get; set; }
            public string LetterDate { get; set; }
            public string Name { get; set; }
            public string Father { get; set; }
            public string Mother { get; set; }
            public string Husband { get; set; }
            public string Wife { get; set; }
            public string Mobile { get; set; }
            public string NID { get; set; }
            public string Village { get; set; }
            public string Post { get; set; }
            public string Thana { get; set; }
            public string District { get; set; }
            public string PVillage { get; set; }
            public string PPost { get; set; }
            public string PThana { get; set; }
            public string PDistrict { get; set; }
            public string ApplyDate { get; set; }
            public string JoinDate { get; set; }
            public string Designation { get; set; }
            public string Department { get; set; }
            public string Section { get; set; }
            public string IdNo { get; set; }
            public string Grade { get; set; }
            public string WorkType { get; set; }
            public string Basic { get; set; }
            public string House { get; set; }
            public string HousePct { get; set; }
            public string Food { get; set; }
            public string Transport { get; set; }
            public string Medical { get; set; }
            public string Total { get; set; }
            public string OTRate { get; set; }
            public string AttBonus { get; set; }
        }

        // মূল টেবিল: Employee_information_new (e), Employee_information_With_Code (ec), z_Test_ID (z) — এগুলো INNER।
        // বাকি টেবিলে কোনো কর্মচারীর সারি না থাকলেও নিয়োগপত্র যেন বাদ না পড়ে, তাই LEFT JOIN।
        const string Sql = @"
SELECT e.ID_no, e.Name, e.Joining_Date,
       c.Conmany_Bangla, c.Bangla_Address,
       p.Fathers, p.Mothers, p.Husband, p.Wife, p.Personal_Phone, p.NID,
       p.Village, p.Post, p.Thana, p.District,
       p.P_Village, p.P_Post, p.P_Thana, p.P_District,
       d.Department_Name, s.Section_Name,
       g.Desigation_name, g.Grade, g.Designation_Catagory_Bangla AS Work_Type_Bangla, g.Attendance_Bonus,
       b.Basic_Salary, b.Hous_Rant, b.Food_Allowance, b.Medicl_Allowance, b.Transport_Allowance, b.OT_Rate,
       sal.Gross_Salary
FROM dbo.Employee_information_new e
INNER JOIN dbo.Employee_information_With_Code ec ON e.ID_no = ec.ID_no
INNER JOIN dbo.z_Test_ID z ON e.ID_no = z.ID_No
LEFT JOIN dbo.Employee_Personal_Information_new p ON e.ID_no = p.ID_No
LEFT JOIN dbo.Employee_Salary_information_new sal ON e.ID_no = sal.ID_no
LEFT JOIN dbo.TB_Company c ON ec.Company_Code = c.Company_Code
LEFT JOIN dbo.TB_Department d ON ec.Department_Code = d.Department_Code
LEFT JOIN dbo.TB_Section s ON ec.Section_Code = s.Section_Code
LEFT JOIN dbo.TB_Designation g ON ec.Designation_Code = g.Designation_Code
LEFT JOIN dbo.Brack_Down_System b ON e.ID_no = b.ID_no
WHERE z.User_ID = @u AND z.From_Code = @f
ORDER BY e.ID_no";

        // WinForms এ Joining Latter এর জন্য From_Code=2 স্থির ছিল; HRMReports এর ResolveReport এর মানের সঙ্গে মিলতে হবে
        const int LetterFormCode = 2;

        // User_Code: HRMReports পেজের সঙ্গে একই Session key
        long UserCode { get { return SessionLong("User_Code", "UserCode", "User_ID", "UserID", "userid"); } }
        long FromCode { get { return LetterFormCode; } }

        long SessionLong(params string[] keys)
        {
            foreach (string k in keys)
            {
                long v;
                object o = Session[k];
                if (o != null && long.TryParse(Convert.ToString(o), out v) && v != 0) return v;
            }
            return 0;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            if (UserCode == 0)
            {
                ShowMessage("User_Code পাওয়া যায়নি (Session)। Login করে আবার চেষ্টা করুন।");
                return;
            }

            try
            {
                List<Letter> list = LoadLetters(UserCode, FromCode);
                if (list.Count == 0)
                {
                    // কারণ বোঝার জন্য: z_Test_ID তে এই ইউজারের কতগুলো ID সেভ আছে
                    int saved = CountSaved(UserCode, FromCode);
                    ShowMessage("কোনো কর্মচারীর তথ্য পাওয়া যায়নি। (User=" + UserCode + ", From_Code=" + FromCode +
                                ", z_Test_ID তে ID: " + saved + ")" +
                                (saved == 0
                                    ? " রিপোর্ট পেজ থেকে কর্মচারী টিক দিয়ে আবার Report View চাপুন।"
                                    : " ID সেভ আছে, কিন্তু Employee_information_new / Employee_information_With_Code এ মিলছে না।"));
                    return;
                }
                rptLetters.DataSource = list;
                rptLetters.DataBind();
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message);
            }
        }

        int CountSaved(long user, long from)
        {
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();
                    using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.z_Test_ID WHERE User_ID=@u AND From_Code=@f", con))
                    {
                        cmd.Parameters.Add("@u", SqlDbType.BigInt).Value = user;
                        cmd.Parameters.Add("@f", SqlDbType.BigInt).Value = from;
                        return Convert.ToInt32(cmd.ExecuteScalar());
                    }
                }
            }
            catch { return -1; }
        }

        void ShowMessage(string msg)
        {
            lblNone.Text = HttpUtility.HtmlEncode(msg);
            lblNone.Visible = true;
        }

        // ASPX এ <%# H(Eval("...")) %> — HTML encode করে
        protected string H(object o)
        {
            return HttpUtility.HtmlEncode(Convert.ToString(o));
        }

        // ---------- ডাটা লোড ----------
        List<Letter> LoadLetters(long user, long from)
        {
            var dt = new DataTable();
            using (SqlConnection con = conn.openConnection())
            {
                if (con.State != ConnectionState.Open) con.Open();
                using (var cmd = new SqlCommand(Sql, con))
                {
                    cmd.Parameters.Add("@u", SqlDbType.BigInt).Value = user;
                    cmd.Parameters.Add("@f", SqlDbType.BigInt).Value = from;
                    using (var da = new SqlDataAdapter(cmd)) da.Fill(dt);
                }
            }

            var list = new List<Letter>();
            foreach (DataRow r in dt.Rows) list.Add(Map(r));
            return list;
        }

        Letter Map(DataRow r)
        {
            string joinDate = BnDate(r["Joining_Date"]);
            decimal basic = Dec(r["Basic_Salary"]);
            decimal house = Dec(r["Hous_Rant"]);
            string pct = basic > 0 ? Math.Round(house / basic * 100).ToString("0", Inv) : "0";

            return new Letter
            {
                CompanyName = S(r, "Conmany_Bangla"),
                CompanyAddress = S(r, "Bangla_Address"),
                LetterDate = joinDate,
                Name = S(r, "Name"),
                Father = S(r, "Fathers"),
                Mother = S(r, "Mothers"),
                Husband = S(r, "Husband"),
                Wife = S(r, "Wife"),
                Mobile = Bn(S(r, "Personal_Phone")),
                NID = Bn(S(r, "NID")),
                Village = S(r, "Village"),
                Post = S(r, "Post"),
                Thana = S(r, "Thana"),
                District = S(r, "District"),
                PVillage = S(r, "P_Village"),
                PPost = S(r, "P_Post"),
                PThana = S(r, "P_Thana"),
                PDistrict = S(r, "P_District"),
                ApplyDate = joinDate,
                JoinDate = joinDate,
                Designation = S(r, "Desigation_name"),
                Department = S(r, "Department_Name"),
                Section = S(r, "Section_Name"),
                IdNo = Bn(S(r, "ID_no")),
                Grade = Bn(S(r, "Grade")),
                WorkType = S(r, "Work_Type_Bangla"),
                Basic = Money(r["Basic_Salary"]),
                House = Money(r["Hous_Rant"]),
                HousePct = Bn(pct),
                Food = Money(r["Food_Allowance"]),
                Transport = Money(r["Transport_Allowance"]),
                Medical = Money(r["Medicl_Allowance"]),
                Total = Money(r["Gross_Salary"]),
                OTRate = Money(r["OT_Rate"]),
                AttBonus = Bn(Money(r["Attendance_Bonus"]))
            };
        }

        // ---------- ফরম্যাট সাহায্যকারী ----------
        static string S(DataRow r, string col)
        {
            if (!r.Table.Columns.Contains(col) || r[col] == DBNull.Value) return "";
            return Convert.ToString(r[col]).Trim();
        }

        static decimal Dec(object o)
        {
            decimal d;
            if (o == null || o == DBNull.Value) return 0;
            return decimal.TryParse(Convert.ToString(o), NumberStyles.Any, Inv, out d) ? d : 0;
        }

        static string Money(object o)
        {
            return Dec(o).ToString("0.##", Inv);
        }

        static string BnDate(object o)
        {
            DateTime dt;
            if (o == null || o == DBNull.Value) return "";
            if (o is DateTime) dt = (DateTime)o;
            else if (!DateTime.TryParse(Convert.ToString(o), out dt)) return "";
            return Bn(dt.ToString("dd/MM/yyyy", Inv));
        }

        // ইংরেজি অঙ্ককে বাংলা অঙ্কে রূপান্তর
        static readonly string[] BnDigits = { "০", "১", "২", "৩", "৪", "৫", "৬", "৭", "৮", "৯" };

        static string Bn(string s)
        {
            if (string.IsNullOrEmpty(s)) return "";
            var sb = new StringBuilder();
            foreach (char c in s)
                sb.Append(c >= '0' && c <= '9' ? BnDigits[c - '0'] : c.ToString());
            return sb.ToString();
        }
    }
}
