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
    public partial class LatePermissionEntry : System.Web.UI.Page
    {
        PayrollDB conn = new PayrollDB();
        HRFilters filters;
        const int Chunk = 1000;   // SQL Server এর 2100 parameter limit এড়াতে

        // ================= Page Load =================
        protected void Page_Load(object sender, EventArgs e)
        {
            // ManualAttendance পেজের মতোই multi-select ফিল্টার
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
                filters.FillControls();   // কিছু সিলেক্ট না করলে = সব
                LoadStatus();
            }
        }

        // Active, All + Seperation_Status
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

        // ================= Show / Refresh =================
        protected void btnShow_Click(object sender, EventArgs e)
        {
            LoadGrid();
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            // পেজ নতুন করে লোড (ফিল্টার, ID, Note সব রিসেট)
            Response.Redirect(Request.RawUrl, false);
            Context.ApplicationInstance.CompleteRequest();
        }

        void LoadGrid()
        {
            try
            {
                DateTime workDate;
                if (!TryGetDate(out workDate)) return;

                string[] ids = HRFilters.ParseIds(txtEmpIds.Text);
                if (ids.Length > HRFilters.MaxIds) { ShowError("Too many IDs (max " + HRFilters.MaxIds + ")."); return; }

                BindRows(GetLateRows(workDate, ids));
            }
            catch (Exception ex)
            {
                ShowError(ex.Message);
            }
        }

        bool TryGetDate(out DateTime workDate)
        {
            if (!DateTime.TryParse(txtWorkDate.Text, CultureInfo.InvariantCulture, DateTimeStyles.None, out workDate))
            {
                ShowError("Work Date সঠিক নয়।");
                return false;
            }
            workDate = workDate.Date;
            return true;
        }

        // Desktop কোয়ারির সমতুল্য: View_Manual_Attendance থেকে att_status = 'Late' রো
        DataTable GetLateRows(DateTime workDate, string[] ids)
        {
            string status = ddStatus.SelectedItem != null ? ddStatus.SelectedItem.Text.Trim() : "";
            if (status == "") throw new Exception("একটি Status নির্বাচন করুন।");

            var empIds = new List<long>();
            using (SqlConnection con = conn.openConnection())
            {
                if (con.State != ConnectionState.Open) con.Open();

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
                            "SELECT ID_no, Name, Designation, Work_date, " +
                            "CAST(org_in_time AS time) AS in_time, CAST(org_out_time AS time) AS out_time, att_status " +
                            "FROM View_Manual_Attendance " +
                            "WHERE Work_date >= @f AND Work_date < @t AND att_status = 'Late' " +
                            "AND ID_no IN (" + string.Join(",", ps) + ")";

                        using (var da = new SqlDataAdapter(cmd)) da.Fill(result);
                    }
                }

                if (result.Rows.Count > 0)
                    result.DefaultView.Sort = "Work_date ASC, ID_no ASC";
                return result.DefaultView.ToTable();
            }
        }

        // ================= Grid Render =================
        void ShowError(string msg)
        {
            litGridRows.Text = "<tr><td colspan='8' class='text-center py-8 text-rose-600 text-xs'>" +
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
                string id = Convert.ToString(r["ID_no"]);
                DateTime wd = Convert.ToDateTime(r["Work_date"]);
                // key = ID|yyyy-MM-dd (Save/Delete এ Request.Form থেকে পড়া হবে)
                string key = Server.HtmlEncode(id + "|" + wd.ToString("yyyy-MM-dd"));

                sb.Append("<tr>");
                sb.Append("<td class='text-center'><input type='checkbox' name='rowChk' checked class='row-checkbox rounded w-4 h-4 cursor-pointer' value='" + key + "' /></td>");
                sb.Append("<td class='font-medium text-slate-700'>" + Server.HtmlEncode(id) + "</td>");
                sb.Append("<td>" + Server.HtmlEncode(Convert.ToString(r["Name"])) + "</td>");
                sb.Append("<td>" + Server.HtmlEncode(Convert.ToString(r["Designation"])) + "</td>");
                sb.Append("<td>" + wd.ToString("dd-MMM-yyyy", CultureInfo.InvariantCulture) + "</td>");
                sb.Append("<td>" + Badge(Convert.ToString(r["att_status"])) + "</td>");
                sb.Append("<td>" + FmtTime(r["in_time"]) + "</td>");
                sb.Append("<td>" + FmtTime(r["out_time"]) + "</td>");
                sb.Append("</tr>");
            }
            if (dt.Rows.Count == 0)
                sb.Append("<tr><td colspan='8' class='text-center py-8 text-slate-400 text-xs'>No late records found for the selected criteria.</td></tr>");
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

                long userId = HRFilters.UserCode;
                if (userId == 0) { Alert("Session শেষ হয়ে গেছে, আবার Login করুন।"); return; }

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

                string proc = isDelete ? "Pro_Emp_Late_permition_Delete" : "Pro_Emp_Late_permition";
                string note = txtNote.Text ?? "";

                int ok = 0;
                var fails = new List<string>();

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
                                cmd.Parameters.Add("@ID_no", SqlDbType.BigInt).Value = r.Key;
                                cmd.Parameters.Add("@Work_Date", SqlDbType.DateTime).Value = r.Value;
                                cmd.Parameters.Add("@Note", SqlDbType.VarChar).Value = note;
                                cmd.Parameters.Add("@user_ID", SqlDbType.BigInt).Value = userId;
                                cmd.ExecuteNonQuery();
                                ok++;
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

                LoadGrid();   // একই ফিল্টারে গ্রিড রিফ্রেশ
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
