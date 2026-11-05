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
    public partial class LatePermissionApproval : Page
    {
        PayrollDB conn = new PayrollDB();

        const int MaxIds = HRFilters.MaxIds;

        // WinForms এর stored procedure (button text-ই @Operation হিসেবে যেত)
        const string ProcApproval = "Pro_Late_Permission_Approval";
        const string OpConfirm = "Confirm";
        const string OpReopen = "Re-Open";
        const string OpDelete = "Delete";

        // View ও কলামের নাম (নাম আলাদা হলে শুধু এখানে বদলান)
        const string ViewName = "View_Late_Permission";
        const string ColEntryNo = "Entry_no";
        const string ColStatus = "Early_Parmition_status";

        // ---------- মডেল ----------
        public class LateRow
        {
            public string EntryNo { get; set; }
            public string Key { get; set; }   // ID_no|Work_Date (চেকবক্সের মান)
            public string IdNo { get; set; }
            public string Name { get; set; }
            public string Designation { get; set; }
            public string Department { get; set; }
            public string Section { get; set; }
            public string Note { get; set; }
            public string EntryDateTime { get; set; }
            public string OrgInTime { get; set; }
            public string OrgOutTime { get; set; }
            public string WorkDate { get; set; }
            public string Status { get; set; }
            public string StatusCss { get; set; }
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

                // WinForms এর "User ID" লেবেল
                string uid = CurrentUserId();
                lblUser.Text = uid.Length > 0 ? "User: " + uid : "";
                lblUser.Visible = uid.Length > 0;
            }
        }

        // লগইন করা ইউজারের আইডি। আপনার প্রজেক্টের Session key অনুযায়ী এখানে বদলে নিন।
        string CurrentUserId()
        {
            object s = Session["UserID"] ?? Session["UserId"] ?? Session["UserName"];
            if (s != null) return Convert.ToString(s);
            return (User != null && User.Identity != null && User.Identity.IsAuthenticated) ? User.Identity.Name : "";
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

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            RunAction(OpDelete, "Deleted");
        }

        // ================= Confirm / Re-Open / Delete এর মূল কাজ =================
        // সব নির্বাচিত Entry_no একটি ট্রানজেকশনে চলে: কোনোটি ব্যর্থ হলে কোনোটিই সেভ হয় না।
        void RunAction(string operation, string okMessage)
        {
            string raw = SelectedIdsRaw();

            // প্রসিডিউরের কী হলো ID_no + Work_Date (Entry_no নয়)। চেকবক্সের মান: "ID|yyyyMMddHHmmssfff"
            var items = new List<KeyValuePair<long, DateTime>>();
            foreach (string part in raw.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries))
            {
                string[] p = part.Trim().Split('|');
                long id; DateTime wd;
                if (p.Length == 2 && long.TryParse(p[0], out id) &&
                    DateTime.TryParseExact(p[1], "yyyyMMddHHmmssfff", CultureInfo.InvariantCulture, DateTimeStyles.None, out wd))
                {
                    if (!items.Any(x => x.Key == id && x.Value == wd))
                        items.Add(new KeyValuePair<long, DateTime>(id, wd));
                }
            }

            if (items.Count == 0)
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
                            foreach (var item in items)
                            {
                                using (var cmd = new SqlCommand(ProcApproval, con, tran))
                                {
                                    cmd.CommandType = CommandType.StoredProcedure;
                                    cmd.CommandTimeout = 300; // প্রতিটির সাথে Process_attendance_new চলে
                                    cmd.Parameters.Add("@ID_no", SqlDbType.BigInt).Value = item.Key;
                                    cmd.Parameters.Add("@Work_Date", SqlDbType.DateTime).Value = item.Value;
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

            Toast(okMessage + " (" + items.Count + " record)");
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
                    "SELECT " + ColEntryNo + ", ID_no, Name, Designation, Department, Section, " +
                    "Note, Entry_Date_time, org_in_time, org_out_time, Work_Date " +
                    "FROM " + ViewName + " WHERE [" + ColStatus + "] = @st";
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

                sql += " ORDER BY [Work_Date], [ID_no]";
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

            var list = new List<LateRow>();
            foreach (DataRow r in dt.Rows)
            {
                list.Add(new LateRow
                {
                    EntryNo = Col(r, ColEntryNo),
                    Key = RowKey(r),
                    IdNo = Col(r, "ID_no"),
                    Name = Col(r, "Name"),
                    Designation = Col(r, "Designation"),
                    Department = Col(r, "Department"),
                    Section = Col(r, "Section"),
                    Note = Col(r, "Note"),
                    EntryDateTime = DateTimeCol(r, "Entry_Date_time"),
                    OrgInTime = TimeCol(r, "org_in_time"),
                    OrgOutTime = TimeCol(r, "org_out_time"),
                    WorkDate = DateCol(r, "Work_Date"),
                    Status = statusText,
                    StatusCss = statusCss
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

        // চেকবক্সের কী: ID_no|Work_Date (সময়সহ হুবহু, যাতে প্রসিডিউরের Work_Date সমতা মেলে)
        static string RowKey(DataRow r)
        {
            string id = Col(r, "ID_no");
            DateTime d;
            if (id.Length == 0 || !r.Table.Columns.Contains("Work_Date") || r["Work_Date"] == DBNull.Value) return "";
            object v = r["Work_Date"];
            d = v is DateTime ? (DateTime)v : Convert.ToDateTime(v);
            return id + "|" + d.ToString("yyyyMMddHHmmssfff", CultureInfo.InvariantCulture);
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

        // তারিখ ও সময়: dd-MMM-yyyy hh:mm tt
        static string DateTimeCol(DataRow r, string name)
        {
            if (!r.Table.Columns.Contains(name) || r[name] == DBNull.Value) return "";
            object v = r[name];
            if (v is DateTime) return ((DateTime)v).ToString("dd-MMM-yyyy hh:mm tt", CultureInfo.InvariantCulture);
            DateTime d;
            if (DateTime.TryParse(Convert.ToString(v), out d)) return d.ToString("dd-MMM-yyyy hh:mm tt", CultureInfo.InvariantCulture);
            return Convert.ToString(v);
        }

        // শুধু সময়: কলাম DateTime, TimeSpan বা string যাই হোক, hh:mm tt দেখায়
        static string TimeCol(DataRow r, string name)
        {
            if (!r.Table.Columns.Contains(name) || r[name] == DBNull.Value) return "";
            object v = r[name];
            if (v is DateTime) return ((DateTime)v).ToString("hh:mm tt", CultureInfo.InvariantCulture);
            if (v is TimeSpan) return DateTime.Today.Add((TimeSpan)v).ToString("hh:mm tt", CultureInfo.InvariantCulture);
            DateTime d;
            if (DateTime.TryParse(Convert.ToString(v), out d)) return d.ToString("hh:mm tt", CultureInfo.InvariantCulture);
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
