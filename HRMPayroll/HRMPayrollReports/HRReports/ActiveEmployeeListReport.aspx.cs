using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web;
using System.Web.UI;


// ASPX এর Inherits="Nexa_ERP.HRMPayroll.HRMPayrollReports.HRReports.ActiveEmployeeListReport" এর সঙ্গে মিলতে হবে
namespace Nexa_ERP.HRMPayroll.HRMPayrollReports.HRReports
{
    // এই ফাইলে AelRow বা AelExport ক্লাস নেই: সেগুলো AelExport.cs ফাইলে আছে

    public partial class ActiveEmployeeListReport : Page
    {

        PayrollDB conn = new PayrollDB();
        static readonly CultureInfo Inv = CultureInfo.InvariantCulture;

        const string ReportTitle = "Active Employee List";

        // HRMReports এর ResolveReport এ এই রিপোর্টের formCode এর সঙ্গে মিলতে হবে
        const int ReportFormCode = 7;

        const string Sql = @"
SELECT e.Employee_ID_No, e.Name, b.Branch_Name, d.Department_Name, s.Section_Name,
       g.Desigation_name, e.Joining_Date, e.Gross_Salary
FROM dbo.Employee_Information e
INNER JOIN dbo.z_Test_ID z ON e.Employee_ID_No = z.ID_No
INNER JOIN dbo.TB_Branch b ON e.Branch_Code = b.Branch_Code
INNER JOIN dbo.TB_Department d ON e.Department_Code = d.Department_Code
INNER JOIN dbo.TB_Section s ON e.Section_Code = s.Section_Code
INNER JOIN dbo.TB_Designation g ON e.Designation_Code = g.Designation_Code
WHERE z.User_ID = @u AND z.From_Code = @f
ORDER BY e.Employee_ID_No asc";

        const string LogoSql = @"
SELECT TOP 1 b.Branch_logo
FROM dbo.z_Test_ID z
INNER JOIN dbo.Employee_Information e ON z.ID_No = e.Employee_ID_No
INNER JOIN dbo.TB_Branch b ON e.Branch_Code = b.Branch_Code
WHERE z.User_ID = @u AND z.From_Code = @f";

        long UserCode { get { return SessionLong("User_Code", "UserCode", "User_ID", "UserID", "userid"); } }
        long FromCode { get { return ReportFormCode; } }

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

        string company = "";

        // ================= Page Load =================
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            List<AelRow> rows = LoadForPage();
            if (rows == null) return;

            lblCompany.Text = HttpUtility.HtmlEncode(company);
            litLogo.Text = LogoHtml();
            rptRows.DataSource = rows;
            rptRows.DataBind();
        }

        // রো লোড করে; সমস্যা হলে বার্তা দেখিয়ে null ফেরত দেয়
        List<AelRow> LoadForPage()
        {
            if (UserCode == 0)
            {
                ShowMessage("User_Code পাওয়া যায়নি (Session)। Login করে আবার চেষ্টা করুন।");
                return null;
            }

            try
            {
                List<AelRow> rows = LoadRows(UserCode, FromCode);
                if (rows.Count == 0)
                {
                    int saved = CountSaved(UserCode, FromCode);
                    ShowMessage("কোনো কর্মচারীর তথ্য পাওয়া যায়নি। (User=" + UserCode + ", From_Code=" + FromCode +
                                ", z_Test_ID তে ID: " + saved + ")" +
                                (saved == 0
                                    ? " রিপোর্ট পেজ থেকে কর্মচারী টিক দিয়ে আবার Report View চাপুন।"
                                    : " ID সেভ আছে, কিন্তু Employee_Information বা Branch/Department/Section/Designation এর সঙ্গে মিলছে না।"));
                    return null;
                }
                return rows;
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message);
                return null;
            }
        }

        void ShowMessage(string msg)
        {
            lblNone.Text = HttpUtility.HtmlEncode(msg);
            lblNone.Visible = true;
            pnlReport.Visible = false;
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

        // ================= ডাউনলোড বাটন (শুধু ক্লাস কল) =================
        protected void btnPdf_Click(object sender, EventArgs e)
        {
            List<AelRow> rows = LoadForPage();
            if (rows == null) return;
            AelExport.DownloadPdf(rows, company, ReportTitle, "ActiveEmployeeList.pdf");
        }

        protected void btnWord_Click(object sender, EventArgs e)
        {
            List<AelRow> rows = LoadForPage();
            if (rows == null) return;
            AelExport.DownloadWord(rows, company, ReportTitle, "ActiveEmployeeList.doc");
        }

        protected void btnExcel_Click(object sender, EventArgs e)
        {
            List<AelRow> rows = LoadForPage();
            if (rows == null) return;
            AelExport.DownloadExcel(rows, company, ReportTitle, "ActiveEmployeeList.xls");
        }

        // ASPX এ <%# H(Eval("...")) %> — HTML encode করে
        protected string H(object o)
        {
            return HttpUtility.HtmlEncode(Convert.ToString(o));
        }

        // ================= ডাটা লোড =================
        List<AelRow> LoadRows(long user, long from)
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

            var list = new List<AelRow>();
            var seen = new HashSet<string>();
            foreach (DataRow r in dt.Rows)
            {
                string id = S(r, "Employee_ID_No");
                if (!seen.Add(id)) continue;   // একই কর্মচারী একবারই

                if (company.Length == 0) company = S(r, "Branch_Name");

                decimal gross = Dec(r["Gross_Salary"]);
                list.Add(new AelRow
                {
                    Sl = (list.Count + 1).ToString(Inv),
                    IdNo = id,
                    Name = S(r, "Name"),
                    Designation = S(r, "Desigation_name"),
                    JoinDate = FmtDate(r["Joining_Date"]),
                    Department = S(r, "Department_Name"),
                    Section = S(r, "Section_Name"),
                    Gross = Math.Round(gross, MidpointRounding.AwayFromZero).ToString("#,##0", Inv),
                    GrossRaw = Math.Round(gross, MidpointRounding.AwayFromZero).ToString("0", Inv)
                });
            }
            return list;
        }

        // ব্রাঞ্চের লোগো (থাকলে)
        string LogoHtml()
        {
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();
                    using (var cmd = new SqlCommand(LogoSql, con))
                    {
                        cmd.Parameters.Add("@u", SqlDbType.BigInt).Value = UserCode;
                        cmd.Parameters.Add("@f", SqlDbType.BigInt).Value = FromCode;
                        byte[] b = cmd.ExecuteScalar() as byte[];
                        if (b == null || b.Length < 4) return "";
                        string mime = "image/png";
                        if (b[0] == 0xFF && b[1] == 0xD8) mime = "image/jpeg";
                        else if (b[0] == 0x47 && b[1] == 0x49) mime = "image/gif";
                        else if (b[0] == 0x42 && b[1] == 0x4D) mime = "image/bmp";
                        return "<img class=\"logo\" alt=\"\" src=\"data:" + mime + ";base64," + Convert.ToBase64String(b) + "\" />";
                    }
                }
            }
            catch { return ""; }
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

        static string FmtDate(object o)
        {
            DateTime dt;
            if (o == null || o == DBNull.Value) return "";
            if (o is DateTime) dt = (DateTime)o;
            else if (!DateTime.TryParse(Convert.ToString(o), out dt)) return "";
            return dt.ToString("dd-MMM-yyyy", Inv);   // 01-Apr-2026
        }
    }
}