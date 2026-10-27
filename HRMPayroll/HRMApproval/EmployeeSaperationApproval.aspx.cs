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
using System.Web.UI.WebControls;

namespace Nexa_ERP.HRMPayroll.HRMApproval
{
    public partial class EmployeeSaperationApproval : Page
    {
        PayrollDB conn = new PayrollDB();

        // পাবলিক ফিল্টার ক্লাস (HRMReports এর মতোই)
        HRFilters filters;

        const int MaxIds = HRFilters.MaxIds;

        // WinForms এর stored procedure গুলো
        const string ProcConfirm = "Pro_Employee_Seperation_Confirm";
        const string ProcDelete = "Pro_Employee_Seperation_Delete";

        // ---------- মডেল ----------
        public class SepEmp
        {
            public string Id { get; set; }
            public string Name { get; set; }
            public string Designation { get; set; }
            public string JoinDate { get; set; }
            public string SepType { get; set; }
            public string SepDate { get; set; }
        }

        // ================= Page Load =================
        protected void Page_Load(object sender, EventArgs e)
        {
            filters = new HRFilters()
                .Attach(HRFilters.Branch, ddBranch)
                .Attach(HRFilters.Category, ddCategory)
                .Attach(HRFilters.Dept, ddDept)
                .Attach(HRFilters.Section, ddSection)
                .Attach(HRFilters.SubSec, ddSubSec)
                .Attach(HRFilters.Desig, ddDesig)
                .Attach(HRFilters.Level, ddLevel)
                .Attach(HRFilters.Floor, ddFloor);
            filters.EmptyMeansAll = false;

            filters.LoadLookups();

            if (!IsPostBack)
            {
                filters.FillControls();
                hfSelIds.Value = "";

                // WinForms এর Form_Load এর মতো: শুরুতেই সব Open Separation দেখানো (টিক ছাড়া)
                ShowData(false);
            }

            if (filters.Errors.Count > 0)
                Toast("Option load error: " + string.Join(" | ", filters.Errors));
        }

        // ================= বাটন ইভেন্ট =================

        protected void btnShow_Click(object sender, EventArgs e)
        {
            ShowData(true);
        }

        protected void btnConfirm_Click(object sender, EventArgs e)
        {
            RunAction(ProcConfirm, "Separation confirmed");
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            RunAction(ProcDelete, "Separation deleted");
        }

        // ================= Confirm / Delete এর মূল কাজ =================
        // সব নির্বাচিত ID একটি ট্রানজেকশনে চলে: কোনোটি ব্যর্থ হলে কোনোটিই সেভ হয় না।
        void RunAction(string proc, string okMessage)
        {
            string raw = SelectedIdsRaw();

            long[] ids = HRFilters.ParseIds(raw)
                .Select(s => { long x; return long.TryParse(s, out x) ? x : 0; })
                .Where(x => x != 0).Distinct().ToArray();

            if (ids.Length == 0)
            {
                Toast("কমপক্ষে একজন কর্মচারী নির্বাচন করুন।");
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
                            foreach (long id in ids)
                            {
                                using (var cmd = new SqlCommand(proc, con, tran))
                                {
                                    cmd.CommandType = CommandType.StoredProcedure;
                                    cmd.CommandTimeout = 120;
                                    cmd.Parameters.Add("@ID_No", SqlDbType.BigInt).Value = id;
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

            Toast(okMessage + " (" + ids.Length + " employee)");
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

                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();
                    dt = QueryOpenSeparations(con, ids, hasFrom, from, hasTill, till);
                }

                dt = ApplyOrgFilters(dt);
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message);
                return false;
            }

            BindTable(dt, checkAll);
            return true;
        }

        // WinForms এর query এর নিরাপদ রূপ (parameterized): SQL Injection বন্ধ
        DataTable QueryOpenSeparations(SqlConnection con, string[] ids,
                                       bool hasFrom, DateTime from, bool hasTill, DateTime till)
        {
            using (var cmd = new SqlCommand())
            {
                cmd.Connection = con;
                cmd.CommandTimeout = 120;

                string sql = "SELECT * FROM View_Seperation_Employee WHERE Separtation_Status='Open'";

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
                    sql += " AND [Resign_Date] >= @from";
                    cmd.Parameters.Add("@from", SqlDbType.DateTime).Value = from.Date;
                }
                if (hasTill)
                {
                    sql += " AND [Resign_Date] < @till";
                    cmd.Parameters.Add("@till", SqlDbType.DateTime).Value = till.Date.AddDays(1);
                }

                sql += " ORDER BY [Resign_Date] DESC";
                cmd.CommandText = sql;

                var dt = new DataTable();
                using (var da = new SqlDataAdapter(cmd)) da.Fill(dt);
                return dt;
            }
        }

        // ================= Branch/Dept ... ফিল্টার =================
        DataTable ApplyOrgFilters(DataTable dt)
        {
            var skipped = new List<string>();

            dt = FilterByList(dt, ddBranch, "Branch", skipped, "Branch", "Branch_Name");
            dt = FilterByList(dt, ddCategory, "Category", skipped, "Category", "Category_Name");
            dt = FilterByList(dt, ddDept, "Department", skipped, "Department", "Department_Name", "Dept");
            dt = FilterByList(dt, ddSection, "Section", skipped, "Section", "Section_Name");
            dt = FilterByList(dt, ddSubSec, "Sub Section", skipped, "Sub_Section", "SubSection", "Sub_Section_Name");
            dt = FilterByList(dt, ddFloor, "Floor", skipped, "Floor", "Floor_Name");
            dt = FilterByList(dt, ddDesig, "Designation", skipped, "Designation", "Desigation_name");
            dt = FilterByList(dt, ddLevel, "Designation Level", skipped, "Designation_Level", "Level", "Desig_Level");

            if (skipped.Count > 0)
                Toast("এই ফিল্টারের কলাম View এ নেই, তাই প্রযোজ্য হয়নি: " + string.Join(", ", skipped));

            return dt;
        }

        static DataTable FilterByList(DataTable dt, ListBox lb, string label, List<string> skipped, params string[] columns)
        {
            var wanted = new HashSet<string>(
                lb.Items.Cast<ListItem>().Where(i => i.Selected).Select(i => i.Text.Trim()),
                StringComparer.OrdinalIgnoreCase);

            if (wanted.Count == 0) return dt;     // কিছু না বাছলে = সব

            string col = columns.FirstOrDefault(c => dt.Columns.Contains(c));
            if (col == null)
            {
                skipped.Add(label);
                return dt;
            }

            var rows = dt.AsEnumerable()
                         .Where(r => r[col] != DBNull.Value && wanted.Contains(Convert.ToString(r[col]).Trim()))
                         .ToList();

            return rows.Count == 0 ? dt.Clone() : rows.CopyToDataTable();
        }

        // ================= ফলাফল দেখানো =================
        void BindTable(DataTable dt, bool checkAll)
        {
            // Separation Type এর কলাম: আগে জানা নামগুলো, না পেলে কলামের নাম দেখে অনুমান
            string typeCol = FindColumn(dt,
                "Seperation_Type", "Separtation_Type", "Separation_Type",
                "Seperation_Type_Name", "Separation_Type_Name", "Separtation_Type_Name",
                "SeperationType", "SeparationType", "Resign_Type", "Resign_Type_Name",
                "Resign_Status", "Type", "Seperation_Name");

            if (typeCol == null)
                typeCol = GuessTypeColumn(dt);

            if (typeCol == null && dt.Columns.Count > 0)
                Toast("Separation Type কলাম পাওয়া যায়নি। View এর কলাম: " +
                      string.Join(", ", dt.Columns.Cast<DataColumn>().Select(c => c.ColumnName)));

            var list = new List<SepEmp>();
            foreach (DataRow r in dt.Rows)
            {
                list.Add(new SepEmp
                {
                    Id = Col(r, "ID_no", "Id", "Emp_ID"),
                    Name = Col(r, "Name", "Emp_Name"),
                    Designation = Col(r, "Designation", "Desigation_name"),
                    JoinDate = DateCol(r, "Date_of_Join", "Joining_Date", "Join_Date", "DOJ", "Date_Of_Joining"),
                    SepType = typeCol == null ? "" : Col(r, typeCol),
                    SepDate = DateCol(r, "Resign_Date", "Seperation_Date", "Separation_Date")
                });
            }

            rptEmployees.DataSource = list;
            rptEmployees.DataBind();
            trEmpty.Visible = list.Count == 0;

            lblCount.Text = list.Count + " Records";
            litPaging.Text = list.Count == 0
                ? "Showing 0 entries"
                : "Showing <span class=\"font-medium text-slate-700\">1</span> to <span class=\"font-medium text-slate-700\">" + list.Count +
                  "</span> of <span class=\"font-medium text-slate-700\">" + list.Count + "</span> entries";

            if (checkAll && list.Count > 0)
            {
                ClientScript.RegisterStartupScript(GetType(), "chkall",
                    "document.addEventListener('DOMContentLoaded',function(){document.querySelectorAll('.row-checkbox,#selectAllRows').forEach(function(c){c.checked=true;});});", true);
            }
        }

        // দেওয়া নামগুলোর মধ্যে প্রথম যেটি DataTable এ আছে (বড়/ছোট হাত উপেক্ষা করে) সেটির আসল নাম
        static string FindColumn(DataTable dt, params string[] names)
        {
            foreach (string n in names)
            {
                foreach (DataColumn c in dt.Columns)
                {
                    if (string.Equals(c.ColumnName, n, StringComparison.OrdinalIgnoreCase))
                        return c.ColumnName;
                }
            }
            return null;
        }

        // নাম না মিললে: "type" আছে এবং sep/resign সম্পর্কিত কলাম খোঁজা (ID কলাম বাদ)
        static string GuessTypeColumn(DataTable dt)
        {
            var cols = dt.Columns.Cast<DataColumn>().Select(c => c.ColumnName)
                         .Where(n => n.IndexOf("type", StringComparison.OrdinalIgnoreCase) >= 0)
                         .Where(n => !n.EndsWith("id", StringComparison.OrdinalIgnoreCase))
                         .ToList();

            string best = cols.FirstOrDefault(n =>
                n.IndexOf("sep", StringComparison.OrdinalIgnoreCase) >= 0 ||
                n.IndexOf("resign", StringComparison.OrdinalIgnoreCase) >= 0 ||
                n.IndexOf("termin", StringComparison.OrdinalIgnoreCase) >= 0);

            return best ?? cols.FirstOrDefault();
        }

        static string Col(DataRow r, params string[] names)
        {
            foreach (string n in names)
            {
                if (r.Table.Columns.Contains(n) && r[n] != DBNull.Value)
                    return Convert.ToString(r[n]);
            }
            return "";
        }

        // তারিখ কলাম: dd-MMM-yyyy ফরম্যাটে
        static string DateCol(DataRow r, params string[] names)
        {
            foreach (string n in names)
            {
                if (r.Table.Columns.Contains(n) && r[n] != DBNull.Value)
                {
                    DateTime d;
                    if (r[n] is DateTime) return ((DateTime)r[n]).ToString("dd-MMM-yyyy", CultureInfo.InvariantCulture);
                    if (DateTime.TryParse(Convert.ToString(r[n]), out d)) return d.ToString("dd-MMM-yyyy", CultureInfo.InvariantCulture);
                    return Convert.ToString(r[n]);
                }
            }
            return "";
        }

        // ================= সাহায্যকারী =================
        static bool TryDate(string s, out DateTime d)
        {
            d = DateTime.MinValue;
            if (string.IsNullOrWhiteSpace(s)) return false;
            return DateTime.TryParseExact(s.Trim(), "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out d)
                   || DateTime.TryParse(s.Trim(), out d);
        }

        // টিক দেওয়া ID গুলো: প্রথমে চেকবক্সের name="selId", না পেলে hfSelIds
        string SelectedIdsRaw()
        {
            string[] fromForm = Request.Form.GetValues("selId");
            if (fromForm != null && fromForm.Length > 0)
                return string.Join(",", fromForm);
            return hfSelIds.Value ?? "";
        }

        // ব্যর্থ হলে আগের টিকগুলো ফিরিয়ে আনা
        void RetainTicks(string raw)
        {
            if (string.IsNullOrEmpty(raw)) return;
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
