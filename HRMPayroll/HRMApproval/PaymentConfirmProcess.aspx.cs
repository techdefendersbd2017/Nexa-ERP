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
    public partial class PaymentConfirmProcess : System.Web.UI.Page
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
                DateTime today = DateTime.Today;
                txtFromDate.Text = new DateTime(today.Year, today.Month, 1).ToString("yyyy-MM-dd");
                txtTillDate.Text = today.ToString("yyyy-MM-dd");
                filters.FillControls();
                LoadStatus();
                LoadPayStatus();
            }
        }

        // Active, All + Seperation_Status (SalaryProcess পেজের মতো)
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

        // Desktop: SELECT * FROM Pay_Status Order By Pay_Status_ID asc
        void LoadPayStatus()
        {
            ddPayStatus.Items.Clear();
            ddPayStatus.Items.Add(new ListItem("--Pay Status--", ""));

            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();
                    using (var cmd = new SqlCommand(
                        "SELECT Pay_Status_ID, Pay_Status_Name FROM Pay_Status ORDER BY Pay_Status_ID ASC", con))
                    {
                        var dt = new DataTable();
                        using (var da = new SqlDataAdapter(cmd)) da.Fill(dt);
                        foreach (DataRow r in dt.Rows)
                            ddPayStatus.Items.Add(new ListItem(
                                Convert.ToString(r["Pay_Status_Name"]),
                                Convert.ToString(r["Pay_Status_ID"])));
                    }
                }
            }
            catch (Exception ex)
            {
                ShowError("pay status: " + ex.Message);
            }
        }

        // ---------- Show ----------
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

        // ================= Set Pay Status (AJAX) =================
        // Desktop বাটন "Set" (button7_Click) এর মতো: প্রতিটি ID এর জন্য Pro_Payment_Setting
        [WebMethod]
        public static object SetPayStatus(string id, string monthYear, string payStatusId)
        {
            try
            {
                long idNo = long.Parse(id, CultureInfo.InvariantCulture);
                DateTime monthYr = DateTime.Parse(monthYear, CultureInfo.InvariantCulture);
                long payId = long.Parse(payStatusId, CultureInfo.InvariantCulture);

                using (SqlConnection con = new PayrollDB().openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();
                    using (var cmd = new SqlCommand("Pro_Payment_Setting", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.CommandTimeout = 120;
                        cmd.Parameters.Add("@ID_No", SqlDbType.BigInt).Value = idNo;
                        cmd.Parameters.Add("@month_year", SqlDbType.DateTime).Value = monthYr;
                        cmd.Parameters.Add("@Pay_Status_ID", SqlDbType.BigInt).Value = payId;
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
