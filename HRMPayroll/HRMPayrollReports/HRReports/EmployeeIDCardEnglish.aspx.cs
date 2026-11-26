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
    // PVC card (85.6 x 54 mm) ID card in ENGLISH. 10 cards per A4 (front + back per row, 5 employees per page).
    // Link: EmployeeIDCardEnglish.aspx?rc=<batch no>
    public partial class EmployeeIDCardEnglish : System.Web.UI.Page
    {
        PayrollDB conn = new PayrollDB();

        const int PerSheet = 5;

        // ===== ইংরেজি তথ্যের কলামের নাম =====
        // নিচের ৪টি কলামের নাম আপনার ডাটাবেসের সাথে না মিললে শুধু এখানে বদলান (বাকি কোড ঠিক থাকবে)
        const string COL_NAME = "Employee_information_new.Employee_Name";   // কর্মীর ইংরেজি নাম
        const string COL_DEPARTMENT = "TB_Department.Department_Name";            // বিভাগের ইংরেজি নাম
        const string COL_DESIGNATION = "TB_Designation.Designation_Name";          // পদবীর ইংরেজি নাম
        const string COL_COMPANY = "TB_Company.Company_Name";                  // কোম্পানির ইংরেজি নাম

        int FormCode
        {
            get
            {
                int v;
                return int.TryParse(Request.QueryString["rc"], out v) ? v : 8;
            }
        }

        static readonly string SqlEmp = @"
SELECT        z_Test_ID.ID_No AS ID_no, Employee_information_new.Joining_Date, TB_Designation.Designation_Catagory AS Work_Type, TB_Company.Address, TB_Company.Phone, TB_Company.Company_Logo, 
                         Employee_Personal_Information_new.NID, Employee_Personal_Information_new.Blood_Group, Employee_Personal_Information_new.Home_Phone, Employee_Personal_Information_new.P_Village, 
                         Employee_Personal_Information_new.P_Post, Employee_Personal_Information_new.P_Thana, Employee_Personal_Information_new.P_District, Emp_Photo.Photo, Employee_information_new.Name, 
                         Employee_information_new.Designation, TB_Company.Company_Name, TB_Department.Department_Name, TB_Designation.Desigation_name
FROM            z_Test_ID LEFT OUTER JOIN
                         Employee_information_With_Code ON Employee_information_With_Code.ID_no = z_Test_ID.ID_No LEFT OUTER JOIN
                         Employee_information_new ON Employee_information_new.ID_no = z_Test_ID.ID_No LEFT OUTER JOIN
                         Employee_Personal_Information_new ON Employee_Personal_Information_new.ID_No = z_Test_ID.ID_No LEFT OUTER JOIN
                         Emp_Photo ON Emp_Photo.Emp_no = z_Test_ID.ID_No LEFT OUTER JOIN
                         TB_Company ON TB_Company.Company_Code = Employee_information_With_Code.Company_Code LEFT OUTER JOIN
                         TB_Department ON TB_Department.Department_Code = Employee_information_With_Code.Department_Code LEFT OUTER JOIN
                         TB_Designation ON TB_Designation.Designation_Code = Employee_information_With_Code.Designation_Code
WHERE z_Test_ID.User_ID = @u AND z_Test_ID.From_Code = @f
ORDER BY z_Test_ID.ID_No";

        protected void Page_Load(object sender, EventArgs e)
        {
            long user = HRFilters.UserCode;
            if (user == 0)
            {
                litCards.Text = "<div class=\"msg\">User_Code not found (Session). Please login and try again.</div>";
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
                litCards.Text = "<div class=\"msg\">No employee data found for the selected employees.</div>";
                litCount.Text = "0";
                return;
            }

            var sb = new StringBuilder();
            var seen = new HashSet<string>();
            int n = 0;
            foreach (DataRow r in dt.Rows)
            {
                if (!seen.Add(S(r, "ID_no"))) continue;

                if (n % PerSheet == 0) sb.Append("<div class='sheet'>");
                sb.Append(CardFront(r));
                sb.Append(CardBack(r));
                n++;
                if (n % PerSheet == 0) sb.Append("</div>");
            }
            if (n % PerSheet != 0) sb.Append("</div>");

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

        static string D(DataRow r, string col)
        {
            string v = S(r, col);
            DateTime dt;
            if (v != "" && DateTime.TryParse(v, out dt)) return dt.ToString("dd/MM/yyyy", CultureInfo.InvariantCulture);
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

        static string Permanent(DataRow r) { return E(Join(S(r, "P_Village"), S(r, "P_Post"), S(r, "P_Thana"), S(r, "P_District"))); }

        static string Row(string k, string v) { return "<tr><td class='k'>" + k + "</td><td>: " + v + "</td></tr>"; }

        // ===================== Front =====================
        static string CardFront(DataRow r)
        {
            var sb = new StringBuilder();
            sb.Append("<div class='card'>");
            sb.Append("<div class='hd'>" + Img(r, "Company_Logo", "logo") +
                      "<div class='mid'><h2>" + E(S(r, "Company_Name")) + "</h2><div class='ad'>" + E(S(r, "Address")) + "</div></div></div>");
            sb.Append("<div class='bd'><table>");
            sb.Append(Row("Name", "<b>" + E(S(r, "Name")) + "</b>"));
            sb.Append(Row("Designation", E(S(r, "Desigation_name"))));
            sb.Append(Row("Work Type", E(S(r, "Work_Type"))));
            sb.Append(Row("Department", E(S(r, "Department_Name"))));
            sb.Append(Row("Joining Date", D(r, "Joining_Date")));
            sb.Append(Row("Card No", "<b>" + E(S(r, "ID_no")) + "</b>"));
            sb.Append("</table>" + Img(r, "Photo", "photo") + "</div>");
            sb.Append("<div class='sg'><div>Employee Signature</div><div>Authorized Signature</div></div>");
            sb.Append("</div>");
            return sb.ToString();
        }

        // ===================== Back =====================
        static string CardBack(DataRow r)
        {
            var sb = new StringBuilder();
            sb.Append("<div class='card'>");
            sb.Append("<div class='ttl'>Validity: Till the period of service.</div><div class='back'>");
            sb.Append("<div><p>Factory / Organization Address:<br/>" + E(S(r, "Address")) + "</p>" +
                      "<p>Telephone: " + E(S(r, "Phone")) + "</p>" +
                      "<p>If this card is lost, inform the factory authority immediately.</p></div>");
            sb.Append("<div><p>Blood Group: <b>" + E(S(r, "Blood_Group")) + "</b></p>" +
                      "<p><u>Permanent Address</u><br/>" + Permanent(r) + "</p>" +
                      "<p>Emergency Phone: " + E(S(r, "Home_Phone")) + "<br/>National ID No: " + E(S(r, "NID")) + "</p></div>");
            sb.Append("</div>");
            sb.Append("<div class='sg big'><div>Employee Signature</div><div>Authorized Signature</div></div>");
            sb.Append("</div>");
            return sb.ToString();
        }
    }
}
