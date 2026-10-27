using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web.UI;

namespace Nexa_ERP.HRMPayroll.LeaveInformation.LeaveReports
{
    public partial class LeaveApplicationReport : Page
    {
        PayrollDB conn = new PayrollDB();
        static readonly CultureInfo Inv = CultureInfo.InvariantCulture;

        // ---------- মডেল ----------
        public class LeaveLine
        {
            public string Name { get; set; }
            public string Total { get; set; }
            public string Used { get; set; }
            public string Remaining { get; set; }
        }

        // ---------- aspx এ ব্যবহৃত মান ----------
        public bool HasData;
        public string Message = "";
        public bool IsBangla = true;

        public string Company = "", CompanyAddress = "", LeaveTypeName = "";
        public string EmpName = "", Designation = "", CardNo = "", Section = "";
        public string JoinDate = "", PeriodFrom = "", PeriodTill = "", PeriodFromSlash = "", PeriodTillSlash = "";
        public string Days = "", ApplyDate = "", Purpose = "", Address = "";

        // বাংলা হলে প্রথমটি, ইংরেজি হলে দ্বিতীয়টি
        public string T(string bn, string en) { return IsBangla ? bn : en; }

        // Leave_Application page এর btnApplication_Click Session এ নাম ও শর্ত রাখে
        protected void Page_Load(object sender, EventArgs e)
        {
            string name = Session["LeaveRpt_Name"] as string;
            string prm = Session["LeaveRpt_Prm"] as string;

            if (string.IsNullOrEmpty(prm))
            {
                Message = "No report data. Please open this report from the Leave Application page.";
                return;
            }

            IsBangla = name != "Leave_Application_RPT_English";

            try
            {
                DataTable dt = LoadData(prm);
                if (dt.Rows.Count == 0)
                {
                    Message = "No data found for this application. (Save the application first and make sure the employee's leave balance exists.)";
                    return;
                }

                FillHeader(dt.Rows[0]);
                FillLines(dt);
                HasData = true;
            }
            catch (Exception ex)
            {
                Message = "Error: " + ex.Message;
            }
        }

        // আপনার দেওয়া SQL হুবহু; {?prm} এর জায়গায় WHERE 1=1 + prm
        DataTable LoadData(string prm)
        {
            string sql =
@"SELECT        Employee_information_new.Emp_no, Employee_information_new.ID_no, Employee_information_new.Bangla_name, Employee_information_new.Joining_Date, TB_Company.Conmany_Bangla, TB_Company.Bangla_Address, 
                         TB_Company.Phone, TB_Department.Bangla_Name AS Department, TB_Section.Section_bangla_Name, TB_Designation.Designation_Bangla, Leave_Application.Leave_Type, Leave_Application.From_Date, 
                         Leave_Application.Till_Date, Leave_Application.Purpose, Leave_Application.Phone AS Expr1, Leave_Application.Address, Leave_Application.Alternate_Person, Leave_Application.Status, Leave_Application.Apply_Days, 
                         Leave_Application.Apply_No, Leave_Name_List.Leave_Name, Emp_Wise_Dtls.Total_Days, Emp_Wise_Dtls.Total_User, Emp_Wise_Dtls.Total_Remaining, Employee_information_new.Line, 
                         Leave_Name_List.Leave_Name_Bangla, Emp_Wise_Dtls.Leave_code, Employee_information_new.Report_Type, Emp_Wise_Dtls.Years, TB_Company.Company_Logo, 
                         Leave_Name_List_1.Leave_Name_Bangla AS Aply_Leave_Name_Bangla
FROM            Leave_Name_List INNER JOIN
                         Employee_information_new INNER JOIN
                         TB_Company ON Employee_information_new.Company_Name = TB_Company.Company_Name INNER JOIN
                         Leave_Application ON Employee_information_new.ID_no = Leave_Application.ID_no INNER JOIN
                         Emp_Wise_Dtls ON Employee_information_new.Emp_no = Emp_Wise_Dtls.Emp_no ON Leave_Name_List.Leave_code = Emp_Wise_Dtls.Leave_code INNER JOIN
                         Leave_Name_List AS Leave_Name_List_1 ON Leave_Application.Leave_Type = Leave_Name_List_1.Leave_code INNER JOIN
                         Employee_information_With_Code ON Employee_information_new.ID_no = Employee_information_With_Code.ID_no INNER JOIN
                         TB_Department ON Employee_information_With_Code.Department_Code = TB_Department.Department_Code INNER JOIN
                         TB_Section ON Employee_information_With_Code.Section_Code = TB_Section.Section_Code INNER JOIN
                         TB_Designation ON Employee_information_With_Code.Designation_Code = TB_Designation.Designation_Code
WHERE 1=1 " + prm + " ORDER BY Emp_Wise_Dtls.Leave_code";

            using (SqlConnection con = conn.openConnection())
            {
                if (con.State != ConnectionState.Open) con.Open();
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.CommandTimeout = 60;
                    var dt = new DataTable();
                    using (var da = new SqlDataAdapter(cmd)) da.Fill(dt);
                    return dt;
                }
            }
        }

        void FillHeader(DataRow r)
        {
            Company = Col(r, "Conmany_Bangla");
            CompanyAddress = Col(r, "Bangla_Address");
            LeaveTypeName = IsBangla ? Col(r, "Aply_Leave_Name_Bangla") : Col(r, "Leave_Type");

            EmpName = Col(r, "Bangla_name");
            Designation = Col(r, "Designation_Bangla");
            CardNo = N(Col(r, "ID_no"));
            Section = Col(r, "Section_bangla_Name");

            JoinDate = Fmt(r, "Joining_Date", "dd-MM-yyyy");
            PeriodFrom = Fmt(r, "From_Date", "dd-MM-yy");
            PeriodTill = Fmt(r, "Till_Date", "dd-MM-yy");
            PeriodFromSlash = Fmt(r, "From_Date", "dd/MM/yyyy");
            PeriodTillSlash = Fmt(r, "Till_Date", "dd/MM/yyyy");
            Days = N(Col(r, "Apply_Days"));
            ApplyDate = N(DateTime.Today.ToString("dd-MM-yyyy", Inv));

            Purpose = Col(r, "Purpose");
            Address = Col(r, "Address");
        }

        void FillLines(DataTable dt)
        {
            var lines = new List<LeaveLine>();
            foreach (DataRow r in dt.Rows)
            {
                lines.Add(new LeaveLine
                {
                    Name = IsBangla ? Col(r, "Leave_Name_Bangla") : Col(r, "Leave_Name"),
                    Total = N(Col(r, "Total_Days")),
                    Used = N(Col(r, "Total_User")),
                    Remaining = N(Col(r, "Total_Remaining"))
                });
            }
            rptLines.DataSource = lines;
            rptLines.DataBind();
        }

        // ---------- সাহায্যকারী ----------
        static string Col(DataRow r, string name)
        {
            return r.Table.Columns.Contains(name) && r[name] != DBNull.Value ? Convert.ToString(r[name]).Trim() : "";
        }

        string Fmt(DataRow r, string col, string format)
        {
            DateTime d;
            return DateTime.TryParse(Col(r, col), out d) ? N(d.ToString(format, Inv)) : "";
        }

        // বাংলা রিপোর্টে ইংরেজি অঙ্ক -> বাংলা অঙ্ক
        string N(string s)
        {
            if (!IsBangla || string.IsNullOrEmpty(s)) return s;
            var sb = new System.Text.StringBuilder(s.Length);
            foreach (char c in s)
                sb.Append(c >= '0' && c <= '9' ? (char)('০' + (c - '0')) : c);
            return sb.ToString();
        }
    }
}
