using Nexa_ERP.Connection;
using Nexa_ERP.HRMPayroll.Common;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Text;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.HRMPayroll.AttendanceManagementSystem
{
    public partial class AttendanceProcess : System.Web.UI.Page
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

            filters.LoadLookups();   // প্রতি রিকোয়েস্টে লাগে (Designation/Dept নাম বের করতে)

            if (!IsPostBack)
            {
                txtFromDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                txtTillDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                filters.FillControls();
                LoadStatus();
            }
        }

        // Separation পেজের LoadStatusInto(…, true) এর মতো: Active, All + Seperation_Status
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

        // QueryEmployees সবসময় ID_no, Name, Designation কলাম দেয়
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

        // ================= Att. Process (AJAX) =================
        // static মেথডে instance ফিল্ড (conn) পাওয়া যায় না, তাই নতুন PayrollDB নিতে হয়

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
                            if (Convert.ToString(r[5]) == "Lock")
                                return new { locked = true };
                    }
                }
            }
            return new { locked = false };
        }

        [WebMethod]
        public static object ProcessOne(string id, string fromDate, string tillDate)
        {
            try
            {
                long idNo = long.Parse(id, CultureInfo.InvariantCulture);
                DateTime from = DateTime.Parse(fromDate, CultureInfo.InvariantCulture);
                DateTime till = DateTime.Parse(tillDate, CultureInfo.InvariantCulture);

                using (SqlConnection con = new PayrollDB().openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();
                    using (var cmd = new SqlCommand("Process_attendance_new", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.CommandTimeout = 300;
                        cmd.Parameters.Add("@ID_No", SqlDbType.BigInt).Value = idNo;
                        cmd.Parameters.Add("@work_date", SqlDbType.DateTime).Value = from;
                        cmd.Parameters.Add("@till_Date", SqlDbType.DateTime).Value = till;
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