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
    public partial class ManualAttendance : System.Web.UI.Page
    {
        PayrollDB conn = new PayrollDB();
        HRFilters filters;
        const int Chunk = 1000;   // SQL Server এর 2100 parameter limit এড়াতে

        // ================= Page Load =================
        protected void Page_Load(object sender, EventArgs e)
        {
            // Attendance Process পেজের মতোই ListBox (multi-select) attach করা হয়েছে
            filters = new HRFilters()
                .Attach(HRFilters.Category, lbCategory)
                .Attach(HRFilters.Dept, lbDept)
                .Attach(HRFilters.Section, lbSection)
                .Attach(HRFilters.SubSec, lbSubSec)
                .Attach(HRFilters.Desig, lbDesig);

            filters.LoadLookups();   // প্রতি রিকোয়েস্টে লাগে (Designation/Dept নাম বের করতে)

            if (!IsPostBack)
            {
                string today = DateTime.Today.ToString("yyyy-MM-dd");
                txtFromDate.Text = today;
                txtToDate.Text = today;

                filters.FillControls();   // ListBox এ "All" যোগ করার দরকার নেই: কিছু সিলেক্ট না করলেই সব
                LoadStatus();
                LoadAttTypes();
            }
        }

        // Attendance Process পেজের মতো: Active, All + Seperation_Status
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

        // Att_status_Type টেবিল থেকে Attendance Type (Desktop: dataGridView7)
        void LoadAttTypes()
        {
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();
                    using (var da = new SqlDataAdapter(
                        "SELECT Att_Status_Code, att_status FROM Att_status_Type ORDER BY Att_Status_Code", con))
                    {
                        var dt = new DataTable();
                        da.Fill(dt);
                        lbAttType.Items.Clear();
                        foreach (DataRow r in dt.Rows)
                        {
                            string n = Convert.ToString(r["att_status"]).Trim();
                            if (n.Length == 0 || n.Equals("All", StringComparison.OrdinalIgnoreCase)) continue;
                            lbAttType.Items.Add(new ListItem(n, n));
                        }
                    }
                }
            }
            catch { /* ব্যর্থ হলে aspx এর static item গুলোই থাকবে */ }
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
                DateTime from, till;
                if (!TryGetDates(out from, out till)) return;

                string[] ids = HRFilters.ParseIds(txtEmpIds.Text);
                if (ids.Length > HRFilters.MaxIds) { ShowError("Too many IDs (max " + HRFilters.MaxIds + ")."); return; }

                BindRows(GetAttendance(from, till, ids));
            }
            catch (Exception ex)
            {
                ShowError(ex.Message);
            }
        }

        // Multi Date টিক না থাকলে শুধু From Date
        bool TryGetDates(out DateTime from, out DateTime till)
        {
            till = DateTime.MinValue;
            if (!DateTime.TryParse(txtFromDate.Text, CultureInfo.InvariantCulture, DateTimeStyles.None, out from))
            {
                ShowError("From Date সঠিক নয়।");
                return false;
            }
            if (chkMultiDate.Checked)
            {
                if (!DateTime.TryParse(txtToDate.Text, CultureInfo.InvariantCulture, DateTimeStyles.None, out till))
                {
                    ShowError("To Date সঠিক নয়।");
                    return false;
                }
                if (till < from) { ShowError("To Date, From Date এর আগে হতে পারে না।"); return false; }
            }
            else till = from;

            from = from.Date; till = till.Date;
            return true;
        }

        DataTable GetAttendance(DateTime from, DateTime till, string[] ids)
        {
            string status = ddStatus.SelectedItem != null ? ddStatus.SelectedItem.Text.Trim() : "";
            if (status == "") throw new Exception("একটি Status নির্বাচন করুন।");

            var empIds = new List<long>();
            using (SqlConnection con = conn.openConnection())
            {
                if (con.State != ConnectionState.Open) con.Open();

                // Category/Dept/Section/SubSec/Desig এর multi-select ফিল্টার HRFilters নিজেই প্রয়োগ করে
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

                // Attendance Type: কিছু সিলেক্ট না করলে সব
                var types = new List<string>();
                foreach (ListItem li in lbAttType.Items)
                    if (li.Selected) types.Add(li.Value);

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
                        cmd.Parameters.Add("@f", SqlDbType.DateTime).Value = from;
                        cmd.Parameters.Add("@t", SqlDbType.DateTime).Value = till.AddDays(1);

                        // View_Manual_Attendance_New_web এর কলাম অনুযায়ী আপডেট করা হয়েছে
                        string sql =
                            "SELECT Employee_ID_No, Name, Desigation_name, Work_date, " +
                            "CAST(in_time AS time) AS in_time, CAST(out_time AS time) AS out_time, " +
                            "Late_min, General_OT, att_status " +
                            "FROM View_Manual_Attendance_New_web " +
                            "WHERE Work_date >= @f AND Work_date < @t AND Employee_ID_No IN (" + string.Join(",", ps) + ")";

                        if (types.Count > 0)
                        {
                            var tp = new List<string>();
                            for (int k = 0; k < types.Count; k++)
                            {
                                string p = "@s" + k;
                                tp.Add(p);
                                cmd.Parameters.Add(p, SqlDbType.NVarChar, 50).Value = types[k];
                            }
                            sql += " AND att_status IN (" + string.Join(",", tp) + ")";
                        }
                        cmd.CommandText = sql;

                        using (var da = new SqlDataAdapter(cmd)) da.Fill(result);
                    }
                }

                if (result.Rows.Count > 0)
                    result.DefaultView.Sort = "Work_date ASC, Employee_ID_No ASC";
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

        static string Badge(string status)
        {
            string s = (status ?? "").Trim().ToLowerInvariant();
            string cls = "bg-slate-100 text-slate-600";
            if (s == "present") cls = "bg-emerald-100 text-emerald-700";
            else if (s == "absent") cls = "bg-rose-100 text-rose-700";
            else if (s == "late") cls = "bg-amber-100 text-amber-700";
            return "<span class='px-2 py-0.5 rounded-full text-[10px] font-semibold " + cls + "'>" +
                   System.Web.HttpUtility.HtmlEncode(status) + "</span>";
        }

        void BindRows(DataTable dt)
        {
            var sb = new StringBuilder();
            foreach (DataRow r in dt.Rows)
            {
                string id = Convert.ToString(r["Employee_ID_No"]);
                DateTime wd = Convert.ToDateTime(r["Work_date"]);
                // key = ID|yyyy-MM-dd  (Save/Delete এ Request.Form থেকে পড়া হবে)
                string key = Server.HtmlEncode(id + "|" + wd.ToString("yyyy-MM-dd"));

                sb.Append("<tr>");
                sb.Append("<td class='text-center'><input type='checkbox' name='rowChk' checked class='row-checkbox rounded w-4 h-4 cursor-pointer' value='" + key + "' /></td>");
                sb.Append("<td class='font-medium text-slate-700'>" + Server.HtmlEncode(id) + "</td>");
                sb.Append("<td>" + Server.HtmlEncode(Convert.ToString(r["Name"])) + "</td>");
                sb.Append("<td>" + Server.HtmlEncode(Convert.ToString(r["Desigation_name"])) + "</td>");
                sb.Append("<td>" + wd.ToString("dd-MMM-yyyy", CultureInfo.InvariantCulture) + "</td>");
                sb.Append("<td>" + FmtTime(r["in_time"]) + "</td>");
                sb.Append("<td>" + FmtTime(r["out_time"]) + "</td>");
                sb.Append("<td>" + Badge(Convert.ToString(r["att_status"])) + "</td>");
                sb.Append("<td>" + Server.HtmlEncode(Convert.ToString(r["Late_min"])) + "</td>");
                sb.Append("<td>" + Server.HtmlEncode(Convert.ToString(r["General_OT"])) + "</td>");
                sb.Append("</tr>");
            }
            if (dt.Rows.Count == 0)
                sb.Append("<tr><td colspan='10' class='text-center py-8 text-slate-400 text-xs'>No matching records found for the selected criteria.</td></tr>");
            litGridRows.Text = sb.ToString();
        }

        // ================= Save / Delete =================
        protected void btnSave_Click(object sender, EventArgs e) { Execute(false); }
        protected void btnDelete_Click(object sender, EventArgs e) { Execute(true); }

        void Execute(bool isDelete)
        {
            try
            {
                string[] keys = Request.Form.GetValues("rowChk");
                if (keys == null || keys.Length == 0) { Alert("কমপক্ষে একটি রো সিলেক্ট করুন।"); LoadGrid(); return; }

                if (!chkIn.Checked && !chkOut.Checked) { Alert("In অথবা Out টিক দিন।"); LoadGrid(); return; }

                TimeSpan tIn = TimeSpan.Zero, tOut = TimeSpan.Zero;
                if (chkIn.Checked && !TimeSpan.TryParse(txtInTime.Text, CultureInfo.InvariantCulture, out tIn))
                { Alert("In Time সঠিক নয়।"); LoadGrid(); return; }
                if (chkOut.Checked && !TimeSpan.TryParse(txtOutTime.Text, CultureInfo.InvariantCulture, out tOut))
                { Alert("Out Time সঠিক নয়।"); LoadGrid(); return; }

                long userId = HRFilters.UserCode;
                if (userId == 0) { Alert("Session শেষ হয়ে গেছে, আবার Login করুন।"); return; }

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

                // Punch_Time হিসেবে 1900-01-01 + সময় (Desktop এর "hh:mm tt" স্ট্রিং কনভার্সনের সমতুল্য)
                DateTime baseDate = new DateTime(1900, 1, 1);
                DateTime punchIn = baseDate.Add(tIn);
                DateTime punchOut = baseDate.Add(tOut);

                int ok = 0;
                var fails = new List<string>();

                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();

                    // ---- Lock check: সিলেক্ট করা সব মাসের জন্য ----
                    foreach (var ym in rows.Select(r => new DateTime(r.Value.Year, r.Value.Month, 1)).Distinct())
                    {
                        if (IsLocked(con, ym))
                        {
                            Alert("This Month Lock: " + ym.ToString("MMM-yyyy", CultureInfo.InvariantCulture));
                            LoadGrid();
                            return;
                        }
                    }

                    string proc = isDelete ? "Pro_Manual_attendance_Delete" : "Pro_Manual_attendance_New";
                    foreach (var r in rows)
                    {
                        try
                        {
                            using (var cmd = new SqlCommand(proc, con))
                            {
                                cmd.CommandType = CommandType.StoredProcedure;
                                cmd.CommandTimeout = 120;
                                cmd.Parameters.Add("@ID_No", SqlDbType.BigInt).Value = r.Key;
                                cmd.Parameters.Add("@From_Date", SqlDbType.DateTime).Value = r.Value;
                                cmd.Parameters.Add("@Punch_Time", SqlDbType.DateTime).Value = punchIn;
                                cmd.Parameters.Add("@Punch_Time2", SqlDbType.DateTime).Value = punchOut;
                                cmd.Parameters.Add("@in", SqlDbType.Bit).Value = chkIn.Checked;
                                cmd.Parameters.Add("@out", SqlDbType.Bit).Value = chkOut.Checked;
                                cmd.Parameters.Add("@full_night", SqlDbType.Bit).Value = chkFullNight.Checked;
                                cmd.Parameters.Add("@user_ID", SqlDbType.BigInt).Value = userId;
                                cmd.ExecuteNonQuery();
                                ok++;   // exception না হলেই সফল (proc এ NOCOUNT থাকলে return value -1 আসে)
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

                LoadGrid();   // ফিল্টার ViewState এ আছে, তাই একই ডাটা রিফ্রেশ হবে
            }
            catch (Exception ex)
            {
                Alert(ex.Message);
            }
        }

        static bool IsLocked(SqlConnection con, DateTime monthStart)
        {
            using (var cmd = new SqlCommand(
                "SELECT * FROM Lock_Months WHERE DATEPART(MONTH,Lock_Month)=@m AND DATEPART(YEAR,Lock_Month)=@y", con))
            {
                cmd.Parameters.Add("@m", SqlDbType.Int).Value = monthStart.Month;
                cmd.Parameters.Add("@y", SqlDbType.Int).Value = monthStart.Year;
                using (var r = cmd.ExecuteReader())
                {
                    while (r.Read())
                        if (Convert.ToString(r[5]) == "Lock") return true;   // Desktop এর মতোই কলাম index 5
                }
            }
            return false;
        }

        void Alert(string msg)
        {
            string js = "alert(" + new JavaScriptSerializer().Serialize(msg) + ");";
            ClientScript.RegisterStartupScript(GetType(), "msg", js, true);
        }
    }
}