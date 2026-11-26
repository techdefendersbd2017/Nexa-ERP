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
    // PVC কার্ড সাইজ (৮৫.৬ × ৫৪ মিমি) আইডি কার্ড। A4 পেজে ১০টি (২ কলাম × ৫ সারি)।
    // প্রতি সারিতে একজন কর্মীর সামনে (বামে) ও পিছনে (ডানে), তাই এক পেজে ৫ জন।
    // লিংক: EmployeeIDCard.aspx?rc=<ব্যাচ নম্বর>   (EmployeeDocuments এর মতোই z_Test_ID থেকে কর্মী আসে)
    public partial class EmployeeIDCard : System.Web.UI.Page
    {
        PayrollDB conn = new PayrollDB();

        const int PerSheet = 5;   // এক A4 পেজে কর্মী সংখ্যা (৫ × ২ = ১০ কার্ড)

        int FormCode
        {
            get
            {
                int v;
                return int.TryParse(Request.QueryString["rc"], out v) ? v : 8;
            }
        }

        // ID Card এর জন্য যতটুকু তথ্য লাগে শুধু ততটুকু (Nominee/Experience নেই, তাই একজনের একটাই সারি)
        const string SqlEmp = @"
SELECT
    z_Test_ID.ID_No AS ID_no,
    Employee_information_new.Bangla_name, Employee_information_new.Joining_Date,
    TB_Department.Bangla_Name AS Department_Bangla,
    TB_Designation.Designation_Bangla,
    TB_Designation.Designation_Catagory_Bangla AS Work_Type_Bangla,
    TB_Company.Conmany_Bangla, TB_Company.Bangla_Address, TB_Company.Phone, TB_Company.Company_Logo,
    Employee_Personal_Information_new.NID, Employee_Personal_Information_new.Blood_Group,
    Employee_Personal_Information_new.Home_Phone,
    Employee_Personal_Information_new.B_P_Village, Employee_Personal_Information_new.B_P_Post,
    Employee_Personal_Information_new.B_P_Thana, Employee_Personal_Information_new.B_P_District,
    Emp_Photo.Photo
FROM z_Test_ID
    LEFT JOIN Employee_information_With_Code    ON Employee_information_With_Code.ID_no = z_Test_ID.ID_No
    LEFT JOIN Employee_information_new          ON Employee_information_new.ID_no       = z_Test_ID.ID_No
    LEFT JOIN Employee_Personal_Information_new ON Employee_Personal_Information_new.ID_No = z_Test_ID.ID_No
    LEFT JOIN Emp_Photo                         ON Emp_Photo.Emp_no                     = z_Test_ID.ID_No
    LEFT JOIN TB_Company                        ON TB_Company.Company_Code              = Employee_information_With_Code.Company_Code
    LEFT JOIN TB_Department                     ON TB_Department.Department_Code        = Employee_information_With_Code.Department_Code
    LEFT JOIN TB_Designation                    ON TB_Designation.Designation_Code      = Employee_information_With_Code.Designation_Code
WHERE z_Test_ID.User_ID = @u AND z_Test_ID.From_Code = @f
ORDER BY z_Test_ID.ID_No";

        protected void Page_Load(object sender, EventArgs e)
        {
            long user = HRFilters.UserCode;
            if (user == 0)
            {
                litCards.Text = "<div class=\"msg\">User_Code পাওয়া যায়নি (Session)। Login করে আবার চেষ্টা করুন।</div>";
                return;
            }

            DataTable dt;
            try { dt = Load(user); }
            catch (Exception ex)
            {
                litCards.Text = "<div class=\"msg\">Error: " + E(ex.Message) + "</div>";
                return;
            }

            if (dt.Rows.Count == 0)
            {
                litCards.Text = "<div class=\"msg\">নির্বাচিত কর্মচারীর তথ্য পাওয়া যায়নি।</div>";
                litCount.Text = "0";
                return;
            }

            var sb = new StringBuilder();
            var seen = new HashSet<string>();
            int n = 0;
            foreach (DataRow r in dt.Rows)
            {
                if (!seen.Add(S(r, "ID_no"))) continue;

                if (n % PerSheet == 0) sb.Append("<div class='sheet'>");   // নতুন A4 পেজ শুরু
                sb.Append(CardFront(r));
                sb.Append(CardBack(r));
                n++;
                if (n % PerSheet == 0) sb.Append("</div>");                // পেজ ভরে গেলে বন্ধ
            }
            if (n % PerSheet != 0) sb.Append("</div>");                    // শেষ পেজ বন্ধ

            litCards.Text = sb.ToString();
            litCount.Text = n + " employee(s) · " + ((n + PerSheet - 1) / PerSheet) + " page(s)";
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
                sb.Append((c >= '0' && c <= '9') ? (char)('০' + (c - '0')) : c);
            return sb.ToString();
        }

        static string D(DataRow r, string col)
        {
            string v = S(r, col);
            DateTime dt;
            if (v != "" && DateTime.TryParse(v, out dt)) return Bn(dt.ToString("dd/MM/yyyy", CultureInfo.InvariantCulture));
            return E(v);
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

        static string Permanent(DataRow r) { return E(Join(S(r, "B_P_Village"), S(r, "B_P_Post"), S(r, "B_P_Thana"), S(r, "B_P_District"))); }

        static string Row(string k, string v) { return "<tr><td class='k'>" + k + "</td><td>ঃ " + v + "</td></tr>"; }

        // ===================== সামনের পাশ =====================
        static string CardFront(DataRow r)
        {
            var sb = new StringBuilder();
            sb.Append("<div class='card'>");
            sb.Append("<div class='hd'>" + Img(r, "Company_Logo", "logo") +
                      "<div class='mid'><h2>" + E(S(r, "Conmany_Bangla")) + "</h2><div class='ad'>" + E(S(r, "Bangla_Address")) + "</div></div></div>");
            sb.Append("<div class='bd'><table>");
            sb.Append(Row("নাম", "<b>" + E(S(r, "Bangla_name")) + "</b>"));
            sb.Append(Row("পদবী", E(S(r, "Designation_Bangla"))));
            sb.Append(Row("কাজের ধরন", E(S(r, "Work_Type_Bangla"))));
            sb.Append(Row("বিভাগ/শাখা", E(S(r, "Department_Bangla"))));
            sb.Append(Row("যোগদানের তাং", D(r, "Joining_Date")));
            sb.Append(Row("কার্ড নং", "<b>" + Bn(E(S(r, "ID_no"))) + "</b>"));
            sb.Append("</table>" + Img(r, "Photo", "photo") + "</div>");
            sb.Append("<div class='sg'><div>শ্রমিকের স্বাক্ষর</div><div>কর্তৃপক্ষের স্বাক্ষর</div></div>");
            sb.Append("</div>");
            return sb.ToString();
        }

        // ===================== পিছনের পাশ =====================
        static string CardBack(DataRow r)
        {
            var sb = new StringBuilder();
            sb.Append("<div class='card'>");
            sb.Append("<div class='ttl'>মেয়াদঃ চাকুরী স্থায়ী কাল পর্যন্ত।</div><div class='back'>");
            sb.Append("<div><p>কারখানা/ প্রতিষ্ঠানের ঠিকানাঃ<br/>" + E(S(r, "Bangla_Address")) + "</p>" +
                      "<p>টেলিফোন নম্বরঃ " + Bn(E(S(r, "Phone"))) + "</p>" +
                      "<p>উক্ত পরিচয় পত্র হারাইয়া গেলে তাৎক্ষণিক কারখানা কর্তৃপক্ষকে জানাইতে হইবে।</p></div>");
            sb.Append("<div><p>রক্তের গ্রুপঃ <b>" + E(S(r, "Blood_Group")) + "</b></p>" +
                      "<p><u>স্থায়ী ঠিকানা</u><br/>" + Permanent(r) + "</p>" +
                      "<p>জরুরি ফোন নংঃ " + Bn(E(S(r, "Home_Phone"))) + "<br/>জাতীয় পরিচয় নংঃ " + Bn(E(S(r, "NID"))) + "</p></div>");
            sb.Append("</div>");
            sb.Append("<div class='sg big'><div>শ্রমিকের স্বাক্ষর</div><div>কর্তৃপক্ষের স্বাক্ষর</div></div>");
            sb.Append("</div>");
            return sb.ToString();
        }
    }
}
