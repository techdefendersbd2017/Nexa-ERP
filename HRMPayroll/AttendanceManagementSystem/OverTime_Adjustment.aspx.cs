using Nexa_ERP.Connection;
using Nexa_ERP.HRMPayroll.Common;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.HRMPayroll.AttendanceManagementSystem
{
    public partial class OverTime_Adjustment : System.Web.UI.Page
    {
        PayrollDB conn = new PayrollDB();
        HRFilters filters;
        const int Chunk = 1000;   // SQL Server এর 2100 parameter limit এড়াতে

        // ================= Page Load =================
        protected void Page_Load(object sender, EventArgs e)
        {
            // Manual Attendance পেজের মতোই ফিল্টার (multi-select ListBox)
            filters = new HRFilters()
                .Attach(HRFilters.Category, lbCategory)
                .Attach(HRFilters.Dept, lbDept)
                .Attach(HRFilters.Section, lbSection)
                .Attach(HRFilters.SubSec, lbSubSec)
                .Attach(HRFilters.Desig, lbDesig);

            filters.LoadLookups();

            if (!IsPostBack)
            {
                txtWorkDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                filters.FillControls();
                LoadStatus();
            }
        }

        // Manual Attendance পেজের মতো: Active, All + Seperation_Status
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

        // ================= Show =================
        protected void btnShow_Click(object sender, EventArgs e)
        {
            LoadGrid();
        }

        void LoadGrid()
        {
            try
            {
                DateTime workDate;
                if (!DateTime.TryParse(txtWorkDate.Text, CultureInfo.InvariantCulture, DateTimeStyles.None, out workDate))
                {
                    ShowError("Work Date সঠিক নয়।");
                    return;
                }

                string[] ids = HRFilters.ParseIds(txtEmpIds.Text);
                if (ids.Length > HRFilters.MaxIds) { ShowError("Too many IDs (max " + HRFilters.MaxIds + ")."); return; }

                BindRows(GetAttendance(workDate.Date, ids));
            }
            catch (Exception ex)
            {
                ShowError(ex.Message);
            }
        }

        // Desktop এর কোয়ারি (Attendance_View) — ফিল্টার করা কর্মচারীদের জন্য
        DataTable GetAttendance(DateTime workDate, string[] ids)
        {
            string status = ddStatus.SelectedItem != null ? ddStatus.SelectedItem.Text.Trim() : "";
            if (status == "") throw new Exception("একটি Status নির্বাচন করুন।");

            var empIds = new List<long>();
            using (SqlConnection con = conn.openConnection())
            {
                if (con.State != ConnectionState.Open) con.Open();

                // Category/Dept/Section/SubSec/Desig ফিল্টার HRFilters নিজেই প্রয়োগ করে
                DataTable emp = filters.QueryEmployees(con, status, null, null, ids, null);
                if (filters.Errors.Count > 0)
                    throw new Exception("Option load error: " + string.Join(" | ", filters.Errors));

                foreach (DataRow r in emp.Rows)
                {
                    long id;
                    if (long.TryParse(Convert.ToString(r["ID_no"]), out id)) empIds.Add(id);
                }

                var result = new DataTable();
                if (empIds.Count == 0) return result;

                for (int i = 0; i < empIds.Count; i += Chunk)
                {
                    var part = empIds.Skip(i).Take(Chunk).ToList();
                    using (var cmd = new SqlCommand())
                    {
                        cmd.Connection = con;
                        cmd.CommandTimeout = 120;

                        var ps = new List<string>();
                        for (int k = 0; k < part.Count; k++)
                        {
                            string p = "@i" + k;
                            ps.Add(p);
                            cmd.Parameters.Add(p, SqlDbType.BigInt).Value = part[k];
                        }
                        cmd.Parameters.Add("@f", SqlDbType.DateTime).Value = workDate;
                        cmd.Parameters.Add("@t", SqlDbType.DateTime).Value = workDate.AddDays(1);

                        cmd.CommandText =
                            "SELECT a.ID_no, a.Name, a.Designation, a.Work_date, " +
                            "CAST(a.org_in_time AS time) AS org_in_time, " +
                            "CAST(a.org_out_time AS time) AS org_out_time, a.OT_Hours, " +
                            "d.Adjust_Type, " +
                            "CASE WHEN d.ID_No IS NULL THEN NULL " +
                            "     WHEN e.Catagory_Code IN (4,5) THEN CAST(d.Deduction_Hours AS decimal(18,2)) " +
                            "     ELSE CAST(d.Deduction_Hours / 60.0 AS decimal(18,2)) END AS Adj_Hours " +
                            "FROM Attendance_View a " +
                            "LEFT JOIN OT_Deduction_Information d ON d.ID_No = a.ID_no " +
                            "  AND CAST(d.Work_Date AS date) = CAST(a.Work_date AS date) " +
                            "LEFT JOIN Employee_information_With_Code e ON e.ID_no = a.ID_no " +
                            "WHERE a.Work_date >= @f AND a.Work_date < @t AND a.ID_no IN (" + string.Join(",", ps) + ")";

                        using (var da = new SqlDataAdapter(cmd)) da.Fill(result);
                    }
                }

                if (result.Rows.Count > 0)
                    result.DefaultView.Sort = "ID_no ASC";
                return result.DefaultView.ToTable();
            }
        }

        // ================= Grid Render =================
        void ShowError(string msg)
        {
            litGridRows.Text = "<tr><td colspan='10' class='text-center py-8 text-rose-600 text-xs'>" +
                               Server.HtmlEncode(msg) + "</td></tr>";
        }

        static string FmtTime(object o)
        {
            if (o == null || o == DBNull.Value) return "";
            if (o is TimeSpan)
                return DateTime.Today.Add((TimeSpan)o).ToString("hh:mm tt", CultureInfo.InvariantCulture);
            DateTime d;
            return DateTime.TryParse(Convert.ToString(o), out d)
                ? d.ToString("hh:mm tt", CultureInfo.InvariantCulture) : Convert.ToString(o);
        }

        void BindRows(DataTable dt)
        {
            var sb = new StringBuilder();
            foreach (DataRow r in dt.Rows)
            {
                string id = Convert.ToString(r["ID_no"]);
                DateTime wd = Convert.ToDateTime(r["Work_date"]);
                // key = ID|yyyy-MM-dd  (Add/Delete এ Request.Form থেকে পড়া হবে)
                string key = Server.HtmlEncode(id + "|" + wd.ToString("yyyy-MM-dd"));

                sb.Append("<tr>");
                // Desktop এর মতো Show করলে সব রো টিক দেওয়া থাকে
                sb.Append("<td class='text-center'><input type='checkbox' name='rowChk' checked class='row-checkbox rounded w-4 h-4 cursor-pointer' value='" + key + "' /></td>");
                sb.Append("<td class='font-medium text-slate-700'>" + Server.HtmlEncode(id) + "</td>");
                sb.Append("<td>" + Server.HtmlEncode(Convert.ToString(r["Name"])) + "</td>");
                sb.Append("<td>" + Server.HtmlEncode(Convert.ToString(r["Designation"])) + "</td>");
                sb.Append("<td>" + wd.ToString("dd-MMM-yyyy", CultureInfo.InvariantCulture) + "</td>");
                sb.Append("<td>" + FmtTime(r["org_in_time"]) + "</td>");
                sb.Append("<td>" + FmtTime(r["org_out_time"]) + "</td>");
                sb.Append("<td>" + Server.HtmlEncode(Convert.ToString(r["OT_Hours"])) + "</td>");

                string at = Convert.ToString(r["Adjust_Type"]).Trim();
                string badge = "";
                if (at.Length > 0)
                {
                    string cls = at.Equals("Add", StringComparison.OrdinalIgnoreCase)
                        ? "bg-emerald-100 text-emerald-700" : "bg-rose-100 text-rose-700";
                    badge = "<span class='px-2 py-0.5 rounded-full text-[10px] font-semibold " + cls + "'>" +
                            Server.HtmlEncode(at) + "</span>";
                }
                sb.Append("<td>" + badge + "</td>");
                sb.Append("<td>" + Server.HtmlEncode(Convert.ToString(r["Adj_Hours"])) + "</td>");
                sb.Append("</tr>");
            }
            if (dt.Rows.Count == 0)
                sb.Append("<tr><td colspan='10' class='text-center py-8 text-slate-400 text-xs'>No matching records found for the selected criteria.</td></tr>");
            litGridRows.Text = sb.ToString();
        }

        // ================= Add / Delete =================
        // Desktop: Add = Pro_OT_Deduction_Information, Delete = Pro_OT_Deduction_Information_Delete
        protected void btnAdd_Click(object sender, EventArgs e) { Execute(false); }
        protected void btnDelete_Click(object sender, EventArgs e) { Execute(true); }

        void Execute(bool isDelete)
        {
            try
            {
                string[] keys = Request.Form.GetValues("rowChk");
                if (keys == null || keys.Length == 0) { Alert("কমপক্ষে একটি রো সিলেক্ট করুন।"); LoadGrid(); return; }

                // Deduction Hours: Add এর সময় অবশ্যই দিতে হবে; Delete এ খালি থাকলে 0 যাবে
                long hours = 0;
                string hTxt = (txtDeduction.Text ?? "").Trim();
                if (!long.TryParse(hTxt, out hours))
                {
                    if (!isDelete) { Alert("Deduction OT Hours সঠিক নয়।"); LoadGrid(); return; }
                    hours = 0;
                }

                if (hours < 0) { Alert("Hours ঋণাত্মক হতে পারবে না। যোগ/বিয়োগ OT Action থেকে নির্বাচন করুন।"); LoadGrid(); return; }

                string adjType = ddOtAction.SelectedValue == "add" ? "Add" : "Deduct";

                // Key পার্স
                var rows = new List<KeyValuePair<long, DateTime>>();
                foreach (string k in keys)
                {
                    string[] p = k.Split('|');
                    long id; DateTime d;
                    if (p.Length == 2 && long.TryParse(p[0], out id) &&
                        DateTime.TryParseExact(p[1], "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out d))
                        rows.Add(new KeyValuePair<long, DateTime>(id, d));
                }
                if (rows.Count == 0) { Alert("সিলেক্ট করা রো পড়া যায়নি।"); LoadGrid(); return; }

                int ok = 0;
                var fails = new List<string>();
                string proc = isDelete ? "Pro_OT_Deduction_Information_Delete" : "Pro_OT_Deduction_Information";

                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();

                    foreach (var r in rows)
                    {
                        try
                        {
                            using (var cmd = new SqlCommand(proc, con))
                            {
                                cmd.CommandType = CommandType.StoredProcedure;
                                cmd.CommandTimeout = 120;
                                cmd.Parameters.Add("@ID_No", SqlDbType.BigInt).Value = r.Key;
                                cmd.Parameters.Add("@Work_Date", SqlDbType.DateTime).Value = r.Value;
                                cmd.Parameters.Add("@Deduction_Hours", SqlDbType.BigInt).Value = hours;
                                if (!isDelete)
                                    cmd.Parameters.Add("@Adjust_Type", SqlDbType.VarChar, 10).Value = adjType;
                                cmd.ExecuteNonQuery();
                                ok++;   // exception না হলেই সফল
                            }
                        }
                        catch (Exception ex)
                        {
                            fails.Add(r.Key + " (" + r.Value.ToString("dd-MMM") + "): " + ex.Message);
                        }
                    }
                }

                string what = isDelete ? "Delete" : "Save";
                string msg = what + " সফল: " + ok + " টি রো";
                if (fails.Count > 0)
                    msg += "\nব্যর্থ: " + fails.Count + " টি\n" + string.Join("\n", fails.Take(5));
                Alert(msg);

                LoadGrid();
            }
            catch (Exception ex)
            {
                Alert(ex.Message);
            }
        }

        void Alert(string msg)
        {
            string js = "alert(" + new JavaScriptSerializer().Serialize(msg) + ");";
            ClientScript.RegisterStartupScript(GetType(), "msg", js, true);
        }
    }
}