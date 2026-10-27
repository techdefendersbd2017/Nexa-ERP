using Nexa_ERP.Connection;
using Nexa_ERP.HRMPayroll.Common;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Text;
using System.Web.Services;
using System.Web.UI.WebControls;

namespace Nexa_ERP.HRMPayroll.Payrollinformation
{
    public partial class SalaryProcess : System.Web.UI.Page
    {
        PayrollDB conn = new PayrollDB();
        HRFilters filters;

        protected void Page_Load(object sender, EventArgs e)
        {
            filters = new HRFilters()
                .Attach(HRFilters.Category, lbCategory)
                .Attach(HRFilters.Dept, lbDept)
                .Attach(HRFilters.Section, lbSection)
                .Attach(HRFilters.SubSec, lbSubSec)
                .Attach(HRFilters.Desig, lbDesig);

            filters.LoadLookups();

            if (!IsPostBack)
            {
                // মাসের ১ তারিখ থেকে আজ পর্যন্ত (বেতনের জন্য সুবিধাজনক ডিফল্ট)
                DateTime today = DateTime.Today;
                txtFromDate.Text = new DateTime(today.Year, today.Month, 1).ToString("yyyy-MM-dd");
                txtTillDate.Text = today.ToString("yyyy-MM-dd");
                filters.FillControls();
                LoadStatus();
            }
        }

        // AttendanceProcess পেজের মতোই: Active, All + Seperation_Status
        void LoadStatus()
        {
            ddStatus.Items.Clear();
            ddStatus.Items.Add(new ListItem("Active", "1"));
            ddStatus.Items.Add(new ListItem("All", "7"));

            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();
                    using (var cmd = new SqlCommand(
                        "SELECT Seperation_Code, Seperation_Name FROM Seperation_Status ORDER BY Seperation_Code", con))
                    {
                        var dt = new DataTable();
                        using (var da = new SqlDataAdapter(cmd)) da.Fill(dt);
                        foreach (DataRow r in dt.Rows)
                        {
                            string name = Convert.ToString(r["Seperation_Name"]);
                            if (string.IsNullOrWhiteSpace(name)) continue;
                            name = name.Trim();
                            if (name.Equals("Active", StringComparison.OrdinalIgnoreCase) ||
                                name.Equals("All", StringComparison.OrdinalIgnoreCase)) continue;
                            ddStatus.Items.Add(new ListItem(name, Convert.ToString(r["Seperation_Code"])));
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowError("status: " + ex.Message);
            }
        }

        // ---------- Search ----------
        protected void btnSearch_Click(object sender, EventArgs e)
        {
            try
            {
                string status = ddStatus.SelectedItem != null ? ddStatus.SelectedItem.Text.Trim() : "";
                if (status == "") { ShowError("একটি Status নির্বাচন করুন।"); return; }

                string[] ids = HRFilters.ParseIds(txtIds.Text);
                if (ids.Length > HRFilters.MaxIds) { ShowError("Too many IDs (max " + HRFilters.MaxIds + ")."); return; }

                DataTable dt;
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();
                    dt = filters.QueryEmployees(con, status, txtFromDate.Text, txtTillDate.Text, ids, null);
                }

                if (filters.Errors.Count > 0)
                    ShowError("Option load error: " + string.Join(" | ", filters.Errors));
                else
                    BindRows(dt);
            }
            catch (Exception ex)
            {
                ShowError(ex.Message);
            }
        }

        void ShowError(string msg)
        {
            litRows.Text = "<tr><td colspan='4' class='text-center py-8 text-rose-600 text-xs'>" +
                           Server.HtmlEncode(msg) + "</td></tr>";
            lblTotal.Text = "0";
        }

        void BindRows(DataTable dt)
        {
            var sb = new StringBuilder();
            foreach (DataRow r in dt.Rows)
            {
                string id = Server.HtmlEncode(Convert.ToString(r["ID_no"]));
                sb.Append("<tr class='hover:bg-slate-50/80 transition-colors'>");
                sb.Append("<td class='py-3 px-4 text-center'><input type='checkbox' checked class='row-checkbox rounded w-4 h-4' value='" + id + "' data-id='" + id + "'></td>");
                sb.Append("<td class='py-3 px-4 font-semibold text-slate-900 text-xs'>" + id + "</td>");
                sb.Append("<td class='py-3 px-4 font-medium text-slate-800 text-xs'>" + Server.HtmlEncode(Convert.ToString(r["Name"])) + "</td>");
                sb.Append("<td class='py-3 px-4 text-slate-600 text-xs'>" + Server.HtmlEncode(Convert.ToString(r["Designation"])) + "</td>");
                sb.Append("</tr>");
            }
            if (dt.Rows.Count == 0)
                sb.Append("<tr><td colspan='4' class='text-center py-8 text-slate-400 text-xs'>No matching records found for the selected criteria.</td></tr>");
            litRows.Text = sb.ToString();
            lblTotal.Text = dt.Rows.Count.ToString();
        }

        // ================= Salary Process (AJAX) =================
        // Desktop অ্যাপের Lock System এর মতো: সেই মাসে Lock থাকলে প্রসেস হবে না।
        // Lock_Months টেবিলের কোন কলামে "Lock" লেখা থাকে তা Desktop (index 9) ও
        // Attendance পেজে (index 5) আলাদা, তাই এখানে সব কলাম দেখে নেওয়া হয়েছে।
        [WebMethod]
        public static object CheckLock(string fromDate)
        {
            DateTime d = DateTime.Parse(fromDate, CultureInfo.InvariantCulture);
            using (SqlConnection con = new PayrollDB().openConnection())
            {
                if (con.State != ConnectionState.Open) con.Open();
                using (var cmd = new SqlCommand(
                    "SELECT * FROM Lock_Months WHERE DATEPART(MONTH,Lock_Month)=@m AND DATEPART(YEAR,Lock_Month)=@y", con))
                {
                    cmd.Parameters.Add("@m", SqlDbType.Int).Value = d.Month;
                    cmd.Parameters.Add("@y", SqlDbType.Int).Value = d.Year;
                    using (var r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                            for (int i = 0; i < r.FieldCount; i++)
                                if (!r.IsDBNull(i) && Convert.ToString(r[i]).Trim() == "Lock")
                                    return new { locked = true };
                    }
                }
            }
            return new { locked = false };
        }

        // action: salary | advance | final | tds | festival | extraot | salary2
        [WebMethod]
        public static object ProcessOne(string action, string id, string fromDate, string tillDate,
                                        bool night, bool holiday, bool fullCash)
        {
            try
            {
                long idNo = long.Parse(id, CultureInfo.InvariantCulture);
                DateTime from = DateTime.Parse(fromDate, CultureInfo.InvariantCulture);
                DateTime till = DateTime.Parse(tillDate, CultureInfo.InvariantCulture);

                // Desktop বাটনের Stored Procedure এর সাথে মিলিয়ে নেওয়া (শুধু এই তালিকার বাইরে কিছু চলবে না)
                string proc;
                switch (action)
                {
                    case "salary": proc = "Pro_Salary_Process1"; break;                        // button1
                    case "advance": proc = "Pro_Advance_Salary_Sheet_Information"; break;       // button3_Click_1
                    case "final": proc = "Pro_Full_Final_Sattlement"; break;                  // button4_Click_1
                    case "tds": proc = "Pro_Employee_TDS_Informations"; break;              // button7_Click_1
                    case "festival": proc = "Pro_Festival_Holiday_Sheet_Information"; break;     // button8_Click_1
                    case "extraot": proc = "Pro_Extra_OT_Holiday_Payment"; break;               // button10
                    case "salary2": proc = "Pro_Salary_Process4_hours"; break;                  // button11
                    default: return new { ok = false, msg = "Unknown action: " + action };
                }

                using (SqlConnection con = new PayrollDB().openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();
                    using (var cmd = new SqlCommand(proc, con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.CommandTimeout = 300;
                        cmd.Parameters.Add("@id_No", SqlDbType.BigInt).Value = idNo;

                        if (action == "final")
                        {
                            cmd.Parameters.Add("@Payment_Date", SqlDbType.Date).Value = till;
                        }
                        else if (action == "tds")
                        {
                            cmd.Parameters.Add("@From_Months", SqlDbType.Date).Value = from;
                        }
                        else
                        {
                            cmd.Parameters.Add("@From_Date", SqlDbType.Date).Value = from;
                            cmd.Parameters.Add("@till_Date", SqlDbType.Date).Value = till;
                            cmd.Parameters.Add("@Night_tiffin_Alow", SqlDbType.Bit).Value = night;
                            cmd.Parameters.Add("@holiday_Allow", SqlDbType.Bit).Value = holiday;
                            cmd.Parameters.Add("@Full_Cash", SqlDbType.Bit).Value = fullCash;
                        }
                        cmd.ExecuteNonQuery();
                    }
                }
                return new { ok = true, msg = "" };
            }
            catch (Exception ex)
            {
                return new { ok = false, msg = ex.Message };
            }
        }
    }
}
