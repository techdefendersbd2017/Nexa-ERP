using Nexa_ERP.Connection;
using Nexa_ERP.HRMPayroll.Common;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Web.Script.Serialization;
using System.Web.UI;

namespace Nexa_ERP.HRMPayroll.HRMApproval
{
    public partial class AttendanceDeleteApproval : Page
    {
        PayrollDB conn = new PayrollDB();

        const int MaxIds = HRFilters.MaxIds;

        // WinForms এর stored procedure (button text-ই @Operation হিসেবে যেত)
        const string ProcApproval = "Pro_Attendance_Delete_Approval";
        const string OpConfirm = "Confirm";
        const string OpReopen = "Re-Open";

        // ---------- মডেল ----------
        public class AttRow
        {
            public string EntryNo { get; set; }
            public string IdNo { get; set; }
            public string Name { get; set; }
            public string Designation { get; set; }
            public string Department { get; set; }
            public string Section { get; set; }
            public string WorkDate { get; set; }
            public string PunchTime { get; set; }
            public string Status { get; set; }
            public string StatusCss { get; set; }
            public string UserName { get; set; }
            public string Position { get; set; }
            public string EntryDate { get; set; }
        }

        // ================= Page Load =================
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // WinForms এর মতো: শুরুতে দুই তারিখেই আজকের তারিখ, গ্রিড খালি
                string today = DateTime.Today.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
                txtFromDate.Text = today;
                txtTillDate.Text = today;
                hfSelIds.Value = "";
                trEmpty.Visible = false;
                litPaging.Text = "Showing 0 entries";
            }
        }

        // ================= বাটন ইভেন্ট =================
        protected void btnShow_Click(object sender, EventArgs e)
        {
            ShowData(true);
        }

        protected void btnConfirm_Click(object sender, EventArgs e)
        {
            RunAction(OpConfirm, "Confirmed");
        }

        protected void btnReopen_Click(object sender, EventArgs e)
        {
            RunAction(OpReopen, "Re-Opened");
        }

        // ================= Confirm / Re-Open এর মূল কাজ =================
        // সব নির্বাচিত Entry_no একটি ট্রানজেকশনে চলে: কোনোটি ব্যর্থ হলে কোনোটিই সেভ হয় না।
        void RunAction(string operation, string okMessage)
        {
            string raw = SelectedIdsRaw();

            long[] entries = HRFilters.ParseIds(raw)
                .Select(s => { long x; return long.TryParse(s, out x) ? x : 0; })
                .Where(x => x != 0).Distinct().ToArray();

            if (entries.Length == 0)
            {
                Toast("কমপক্ষে একটি রেকর্ড নির্বাচন করুন।");
                return;
            }

            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();

                    using (SqlTransaction tran = con.BeginTransaction())
                    {
                        try
                        {
                            foreach (long entryNo in entries)
                            {
                                using (var cmd = new SqlCommand(ProcApproval, con, tran))
                                {
                                    cmd.CommandType = CommandType.StoredProcedure;
                                    cmd.CommandTimeout = 120;
                                    cmd.Parameters.Add("@Entry_no", SqlDbType.BigInt).Value = entryNo;
                                    cmd.Parameters.Add("@Operation", SqlDbType.VarChar, 50).Value = operation;
                                    cmd.ExecuteNonQuery();
                                }
                            }
                            tran.Commit();
                        }
                        catch
                        {
                            tran.Rollback();
                            throw;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message);
                RetainTicks(raw);
                return;
            }

            Toast(okMessage + " (" + entries.Length + " record)");
            hfSelIds.Value = "";
            ShowData(false);
        }

        // ================= তালিকা আনা =================
        bool ShowData(bool checkAll)
        {
            DataTable dt;

            try
            {
                string[] ids = HRFilters.ParseIds(txtMultiId.Text);

                if (ids.Length > MaxIds)
                {
                    Toast("Too many IDs (max " + MaxIds + ").");
                    return false;
                }

                DateTime from, till;
                bool hasFrom = TryDate(txtFromDate.Text, out from);
                bool hasTill = TryDate(txtTillDate.Text, out till);

                // From Month টিক থাকলে From Date এর মাসের ১ তারিখ থেকে
                if (hasFrom && chkFromMonth.Checked)
                    from = new DateTime(from.Year, from.Month, 1);

                if (hasFrom && hasTill && from.Date > till.Date)
                {
                    Toast("From Date, Till Date এর চেয়ে বড় হতে পারবে না।");
                    return false;
                }

                int status;
                if (!int.TryParse(ddType.SelectedValue, out status)) status = 0;

                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();
                    dt = QueryRows(con, status, ids, hasFrom, from, hasTill, till);
                }
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message);
                return false;
            }

            BindTable(dt, checkAll);
            return true;
        }

        // WinForms এর string-concat query এর নিরাপদ রূপ (parameterized): SQL Injection বন্ধ
        DataTable QueryRows(SqlConnection con, int status, string[] ids,
                            bool hasFrom, DateTime from, bool hasTill, DateTime till)
        {
            using (var cmd = new SqlCommand())
            {
                cmd.Connection = con;
                cmd.CommandTimeout = 120;

                string sql =
                    "SELECT Entry_no, ID_no, Name, Designation, Department, Section, Work_Date, Punch_Time, " +
                    "Operation_Status, Entry_Datetime " +
                    "FROM View_Manual_Attendance_Data_Delete_History WHERE [Operation_Status] = @st";
                cmd.Parameters.Add("@st", SqlDbType.Int).Value = status;

                if (ids.Length > 0)
                {
                    bool numeric = ids.All(s => { long x; return long.TryParse(s, out x); });
                    var names = new List<string>();
                    for (int i = 0; i < ids.Length; i++)
                    {
                        string p = "@id" + i;
                        names.Add(p);
                        if (numeric) cmd.Parameters.Add(p, SqlDbType.BigInt).Value = long.Parse(ids[i]);
                        else cmd.Parameters.Add(p, SqlDbType.NVarChar, 50).Value = ids[i];
                    }
                    sql += " AND ID_no IN (" + string.Join(",", names) + ")";
                }

                if (hasFrom)
                {
                    sql += " AND [Work_Date] >= @from";
                    cmd.Parameters.Add("@from", SqlDbType.DateTime).Value = from.Date;
                }
                if (hasTill)
                {
                    sql += " AND [Work_Date] < @till";
                    cmd.Parameters.Add("@till", SqlDbType.DateTime).Value = till.Date.AddDays(1);
                }

                sql += " ORDER BY [Work_Date], [ID_no], [Punch_Time]";
                cmd.CommandText = sql;

                var dt = new DataTable();
                using (var da = new SqlDataAdapter(cmd)) da.Fill(dt);
                return dt;
            }
        }

        // ================= ফলাফল দেখানো =================
        void BindTable(DataTable dt, bool checkAll)
        {
            string statusText = ddType.SelectedItem != null ? ddType.SelectedItem.Text : "";
            string statusCss = StatusCss(ddType.SelectedValue);

            var list = new List<AttRow>();
            foreach (DataRow r in dt.Rows)
            {
                list.Add(new AttRow
                {
                    EntryNo = Col(r, "Entry_no"),
                    IdNo = Col(r, "ID_no"),
                    Name = Col(r, "Name"),
                    Designation = Col(r, "Designation"),
                    Department = Col(r, "Department"),
                    Section = Col(r, "Section"),
                    WorkDate = DateCol(r, "Work_Date"),
                    PunchTime = TimeCol(r, "Punch_Time"),
                    Status = statusText,
                    StatusCss = statusCss,
                    EntryDate = DateTimeCol(r, "Entry_Datetime")
                });
            }

            rptRows.DataSource = list;
            rptRows.DataBind();
            trEmpty.Visible = list.Count == 0;

            lblCount.Text = list.Count + " Records";
            litPaging.Text = list.Count == 0
                ? "Showing 0 entries"
                : "Showing <span class=\"font-medium text-slate-700\">1</span> to <span class=\"font-medium text-slate-700\">" + list.Count +
                  "</span> of <span class=\"font-medium text-slate-700\">" + list.Count + "</span> entries";

            // WinForms এর মতো: Show এর পর সব সারি টিক দেওয়া
            if (checkAll && list.Count > 0)
            {
                ClientScript.RegisterStartupScript(GetType(), "chkall",
                    "document.addEventListener('DOMContentLoaded',function(){document.querySelectorAll('.row-checkbox,#selectAllRows').forEach(function(c){c.checked=true;});updateSelCount();});", true);
            }
        }

        static string StatusCss(string value)
        {
            const string baseCss = "inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-medium border ";
            switch (value)
            {
                case "1": return baseCss + "bg-emerald-50 text-emerald-700 border-emerald-200";
                case "2": return baseCss + "bg-rose-50 text-rose-700 border-rose-200";
                default: return baseCss + "bg-amber-50 text-amber-700 border-amber-200";
            }
        }

        static string Col(DataRow r, string name)
        {
            if (r.Table.Columns.Contains(name) && r[name] != DBNull.Value)
                return Convert.ToString(r[name]);
            return "";
        }

        // তারিখ: dd-MMM-yyyy
        static string DateCol(DataRow r, string name)
        {
            if (!r.Table.Columns.Contains(name) || r[name] == DBNull.Value) return "";
            object v = r[name];
            if (v is DateTime) return ((DateTime)v).ToString("dd-MMM-yyyy", CultureInfo.InvariantCulture);
            DateTime d;
            if (DateTime.TryParse(Convert.ToString(v), out d)) return d.ToString("dd-MMM-yyyy", CultureInfo.InvariantCulture);
            return Convert.ToString(v);
        }

        // সময়: HH:mm:ss (TimeSpan / DateTime / text যেটাই হোক)
        static string TimeCol(DataRow r, string name)
        {
            if (!r.Table.Columns.Contains(name) || r[name] == DBNull.Value) return "";
            object v = r[name];
            if (v is TimeSpan) return ((TimeSpan)v).ToString(@"hh\:mm\:ss");
            if (v is DateTime) return ((DateTime)v).ToString("HH:mm:ss", CultureInfo.InvariantCulture);
            return Convert.ToString(v);
        }

        // তারিখ ও সময়: dd-MMM-yyyy hh:mm tt
        static string DateTimeCol(DataRow r, string name)
        {
            if (!r.Table.Columns.Contains(name) || r[name] == DBNull.Value) return "";
            object v = r[name];
            if (v is DateTime) return ((DateTime)v).ToString("dd-MMM-yyyy hh:mm tt", CultureInfo.InvariantCulture);
            return Convert.ToString(v);
        }

        // ================= সাহায্যকারী =================
        static bool TryDate(string s, out DateTime d)
        {
            d = DateTime.MinValue;
            if (string.IsNullOrWhiteSpace(s)) return false;
            return DateTime.TryParseExact(s.Trim(), "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out d)
                   || DateTime.TryParse(s.Trim(), out d);
        }

        // টিক দেওয়া Entry_no গুলো: প্রথমে চেকবক্সের name="selId", না পেলে hfSelIds
        string SelectedIdsRaw()
        {
            string[] fromForm = Request.Form.GetValues("selId");
            if (fromForm != null && fromForm.Length > 0)
                return string.Join(",", fromForm);
            return hfSelIds.Value ?? "";
        }

        // ব্যর্থ হলে আগের টিকগুলো ফিরিয়ে আনা (তালিকা আবার আনার পর)
        void RetainTicks(string raw)
        {
            if (string.IsNullOrEmpty(raw)) return;
            ShowData(false);
            string arr = new JavaScriptSerializer().Serialize(raw.Split(','));
            ClientScript.RegisterStartupScript(GetType(), "retick",
                "document.addEventListener('DOMContentLoaded',function(){var ids=" + arr +
                ";document.querySelectorAll('.row-checkbox').forEach(function(c){" +
                "if(ids.indexOf(c.getAttribute('data-id'))>=0)c.checked=true;});updateSelCount();});", true);
        }

        void Toast(string msg)
        {
            string js = "document.addEventListener('DOMContentLoaded',function(){showNotification(" +
                        new JavaScriptSerializer().Serialize(msg) + ");});";
            ClientScript.RegisterStartupScript(GetType(), "toast" + Guid.NewGuid().ToString("N"), js, true);
        }
    }
}
