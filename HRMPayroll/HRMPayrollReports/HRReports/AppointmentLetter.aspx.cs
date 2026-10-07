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
            public string CompanyName { get; set; }      // Branch_Bangla
            public string CompanyAddress { get; set; }   // Bangla_Address_Branch
            public string LogoSrc { get; set; }          // Branch_logo (data URI), না থাকলে ফাঁকা
            public string LetterDate { get; set; }
            public string Name { get; set; }
            public string Father { get; set; }
            public string Mother { get; set; }
            public string Spouse { get; set; }           // SpousNameBangla (নতুন)
            public string Husband { get; set; }          // পুরনো ASPX এর জন্য রাখা (এখন ফাঁকা)
            public string Wife { get; set; }             // পুরনো ASPX এর জন্য রাখা (এখন ফাঁকা)
            public string Mobile { get; set; }
            public string NID { get; set; }
            public string BID { get; set; }
            // বর্তমান ঠিকানা
            public string Village { get; set; }          // নতুন টেবিলে নেই (ফাঁকা)
            public string Post { get; set; }             // নতুন টেবিলে নেই (ফাঁকা)
            public string Thana { get; set; }            // Present Upazila
            public string District { get; set; }         // Present District
            // স্থায়ী ঠিকানা
            public string PVillage { get; set; }         // নতুন টেবিলে নেই (ফাঁকা)
            public string PPost { get; set; }            // নতুন টেবিলে নেই (ফাঁকা)
            public string PThana { get; set; }           // Permanent Upazila
            public string PDistrict { get; set; }        // Permanent District
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
            public string AttBonus { get; set; }         // নতুন কুয়েরিতে নেই (ফাঁকা)
        }

        // মূল টেবিল Employee_Information ও z_Test_ID — এগুলো INNER।
        // বাকি সব LEFT JOIN, যাতে কোনো কোড/সারি না মিললেও নিয়োগপত্র বাদ না পড়ে।
        const string Sql = @"
SELECT e.Employee_ID_No, e.Name, e.Bangla_name, e.Joining_Date, e.JoiningGross,
       e.Fathers, e.Fathers_Bangla, e.Mothers, e.Mothers_Bangla,
       e.SpousNameEnglish, e.SpousNameBangla,
       e.NID, e.BID, e.Personal_Phone,
       br.Branch_Name, br.Branch_Bangla, br.Address AS Branch_Address_English,
       br.Bangla_Address_Branch, br.Branch_logo,
       d.Department_Name, d.Bangla_Name AS DepartmentNameBangla,
       s.Section_Name, s.Section_bangla_Name,
       dn.District_Name, dn.District_Bangla_Name,
       un.Upazila_Name, un.Upazila_Bangla_Name,
       dn1.District_Name AS Present_DistrictNameEng, dn1.District_Bangla_Name AS Present_DistrictNameBangla,
       un1.Upazila_Name AS PresentUpazila_NameEnglish, un1.Upazila_Bangla_Name AS Present_Upazila_NameBangla,
       b.Basic_Salary, b.Hous_Rant, b.Food_Allowance, b.Medicl_Allowance, b.Transport_Allowance, b.OT_Rate,
       g.Desigation_name, g.Designation_Bangla, g.Grade,
       g.Designation_Catagory, g.Designation_Catagory_Bangla
FROM dbo.Employee_Information e
INNER JOIN dbo.z_Test_ID z ON e.Employee_ID_No = z.ID_No
LEFT JOIN dbo.TB_Branch br ON e.Branch_Code = br.Branch_Code
LEFT JOIN dbo.TB_Department d ON e.Department_Code = d.Department_Code
LEFT JOIN dbo.TB_Section s ON e.Section_Code = s.Section_Code
LEFT JOIN dbo.District_Name_List dn ON e.District_Code = dn.District_Code
LEFT JOIN dbo.Upazila_Name_List un ON e.Upzila_Code = un.Upazila_Code
LEFT JOIN dbo.District_Name_List dn1 ON e.PresentDistrict_Code = dn1.District_Code
LEFT JOIN dbo.Upazila_Name_List un1 ON e.PresentUpzila_Code = un1.Upazila_Code
LEFT JOIN dbo.Brack_Down_System b ON e.Employee_ID_No = b.ID_no
LEFT JOIN dbo.TB_Designation g ON e.Designation_Code = g.Designation_Code
WHERE z.User_ID = @u AND z.From_Code = @f
ORDER BY e.Employee_ID_No";

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
                                    : " ID সেভ আছে, কিন্তু Employee_Information এ মিলছে না।"));
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

            // Gross: Brack_Down_System এর যোগফল না নিয়ে JoiningGross ব্যবহার; ০ হলে উপাদানগুলোর যোগফল
            decimal gross = Dec(r["JoiningGross"]);
            if (gross == 0)
                gross = basic + house + Dec(r["Food_Allowance"]) + Dec(r["Medicl_Allowance"]) + Dec(r["Transport_Allowance"]);

            return new Letter
            {
                CompanyName = Pick(r, "Branch_Bangla", "Branch_Name"),
                CompanyAddress = Pick(r, "Bangla_Address_Branch", "Branch_Address_English"),
                LogoSrc = LogoSrc(r),
                LetterDate = joinDate,
                Name = Pick(r, "Bangla_name", "Name"),
                Father = Pick(r, "Fathers_Bangla", "Fathers"),
                Mother = Pick(r, "Mothers_Bangla", "Mothers"),
                Spouse = Pick(r, "SpousNameBangla", "SpousNameEnglish"),
                Husband = "",
                Wife = "",
                Mobile = Bn(S(r, "Personal_Phone")),
                NID = Bn(S(r, "NID")),
                BID = Bn(S(r, "BID")),

                // বর্তমান ঠিকানা
                Village = "",
                Post = "",
                Thana = Pick(r, "Present_Upazila_NameBangla", "PresentUpazila_NameEnglish"),
                District = Pick(r, "Present_DistrictNameBangla", "Present_DistrictNameEng"),

                // স্থায়ী ঠিকানা
                PVillage = "",
                PPost = "",
                PThana = Pick(r, "Upazila_Bangla_Name", "Upazila_Name"),
                PDistrict = Pick(r, "District_Bangla_Name", "District_Name"),

                ApplyDate = joinDate,
                JoinDate = joinDate,
                Designation = Pick(r, "Designation_Bangla", "Desigation_name"),
                Department = Pick(r, "DepartmentNameBangla", "Department_Name"),
                Section = Pick(r, "Section_bangla_Name", "Section_Name"),
                IdNo = Bn(S(r, "Employee_ID_No")),
                Grade = Bn(S(r, "Grade")),
                WorkType = Pick(r, "Designation_Catagory_Bangla", "Designation_Catagory"),
                Basic = Money(r["Basic_Salary"]),
                House = Money(r["Hous_Rant"]),
                HousePct = Bn(pct),
                Food = Money(r["Food_Allowance"]),
                Transport = Money(r["Transport_Allowance"]),
                Medical = Money(r["Medicl_Allowance"]),
                Total = Money(gross),
                OTRate = Money(r["OT_Rate"]),
                AttBonus = ""
            };
        }

        // ---------- ফরম্যাট সাহায্যকারী ----------
        static string S(DataRow r, string col)
        {
            if (!r.Table.Columns.Contains(col) || r[col] == DBNull.Value) return "";
            return Convert.ToString(r[col]).Trim();
        }

        // বাংলা মান থাকলে সেটি, না থাকলে ইংরেজি মান
        static string Pick(DataRow r, string bnCol, string enCol)
        {
            string v = S(r, bnCol);
            return v.Length > 0 ? v : S(r, enCol);
        }

        // Branch_logo বাইনারি হলে <img src> এর জন্য data URI; নইলে ফাঁকা
        static string LogoSrc(DataRow r)
        {
            if (!r.Table.Columns.Contains("Branch_logo") || r["Branch_logo"] == DBNull.Value) return "";
            byte[] bytes = r["Branch_logo"] as byte[];
            if (bytes == null || bytes.Length == 0) return "";
            return "data:image/png;base64," + Convert.ToBase64String(bytes);
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