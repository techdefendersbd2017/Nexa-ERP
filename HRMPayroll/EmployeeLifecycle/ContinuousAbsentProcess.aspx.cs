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

namespace Nexa_ERP.HRMPayroll.EmployeeLifecycle
{
    public partial class ContinuousAbsentProcess : System.Web.UI.Page
    {
        PayrollDB conn = new PayrollDB();
        HRFilters filters;

        readonly List<string> loadErrors = new List<string>();

        // TODO: List View বাটনের রিপোর্ট পেজ (ডেস্কটপের Lefty_list_View + Left_Out_List, Status='Open')
        // নিজের পেজের পথ অনুযায়ী বদলান। এই পেজের ফোল্ডারের সাপেক্ষে বা ~/ দিয়ে লিখুন।
        const string ListViewPage = "~/HRMPayroll/HRMPayrollReports/Lefty_List_View.aspx?report=Left_Out_List&status=Open";

        // Cross-product এর সর্বোচ্চ সংখ্যা (Pro_Lefty বারবার কল হয়)
        const int MaxCombos = 200;

        public class Emp
        {
            public string Id { get; set; }
            public string Name { get; set; }
            public string Designation { get; set; }
            public string Days { get; set; }
        }

        List<string> AllErrors()
        {
            return loadErrors.Concat(filters.Errors).ToList();
        }

        // ================= Page Load =================
        protected void Page_Load(object sender, EventArgs e)
        {
            // ডেস্কটপের Category / Department / Section / Designation, Attendance_Reports এর মতো multi-select
            filters = new HRFilters()
                .Attach(HRFilters.Category, ddCategory)
                .Attach(HRFilters.Dept, ddDept)
                .Attach(HRFilters.Section, ddSection)
                .Attach(HRFilters.Desig, ddDesig);

            filters.LoadLookups();

            // পোস্টব্যাকের পর আগের টিক ফিরিয়ে আনা
            if (IsPostBack && !string.IsNullOrEmpty(SelectedRaw()))
            {
                string arr = new JavaScriptSerializer().Serialize(SelectedRaw().Split(','));
                ClientScript.RegisterStartupScript(GetType(), "retick",
                    "document.addEventListener('DOMContentLoaded',function(){var v=" + arr +
                    ";document.querySelectorAll('.row-checkbox').forEach(function(c){" +
                    "if(v.indexOf(c.value)>=0)c.checked=true;});" +
                    "if(typeof updateSelCount==='function')updateSelCount();});", true);
            }

            if (!IsPostBack)
            {
                FillDropDowns();
                ResetDefaults();
                ClearGrid();
            }

            if (IsPostBack && AllErrors().Count > 0)
                Toast("Option load error: " + string.Join(" | ", AllErrors()));
        }

        // ================= ড্রপডাউন ভরা =================
        void FillDropDowns()
        {
            filters.FillControls();   // Category, Dept, Section, Desig

            // Emp. Status: ডেস্কটপের Seperation_Status টেবিল (Text = Seperation_Name)
            try
            {
                var dt = Query("SELECT Seperation_Code, Seperation_Name FROM Seperation_Status");
                ddStatus.Items.Clear();
                foreach (DataRow r in dt.Rows)
                    ddStatus.Items.Add(new ListItem(Convert.ToString(r["Seperation_Name"]).Trim(), Convert.ToString(r["Seperation_Code"])));
            }
            catch (Exception ex) { loadErrors.Add("status: " + ex.Message); }

            // Line: ডেস্কটপের TB_Line (Text = Line_Name)
            try
            {
                var dt = Query("SELECT Line_Code, Line_Name FROM TB_Line ORDER BY Line_Name ASC");
                ddLine.Items.Clear();
                foreach (DataRow r in dt.Rows)
                {
                    string n = Convert.ToString(r["Line_Name"]).Trim();
                    if (n.Length == 0) continue;
                    ddLine.Items.Add(new ListItem(n, Convert.ToString(r["Line_Code"])));
                }
            }
            catch (Exception ex) { loadErrors.Add("line: " + ex.Message); }

            if (AllErrors().Count > 0)
                Toast("Option load error: " + string.Join(" | ", AllErrors()));
        }

        DataTable Query(string sql)
        {
            var dt = new DataTable();
            using (SqlConnection con = conn.openConnection())
            {
                if (con.State != ConnectionState.Open) con.Open();
                using (var cmd = new SqlCommand(sql, con))
                using (var da = new SqlDataAdapter(cmd))
                    da.Fill(dt);
            }
            return dt;
        }

        // ================= বাটন ইভেন্ট =================
        protected void btnShow_Click(object sender, EventArgs e)
        {
            ShowData();
        }

        // List View: Pro_Clear_Open_List → টিক দেওয়া প্রতিজনের জন্য Pro_Lafty_Days → রিপোর্ট পেজ
        protected void btnListView_Click(object sender, EventArgs e)
        {
            DateTime from, till;
            if (!TryDates(out from, out till)) return;

            var rows = SelectedRows();
            if (rows.Count == 0)
            {
                Toast("কমপক্ষে একজন কর্মচারী নির্বাচন করুন।");
                return;
            }

            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();

                    ClearOpenList(con);

                    foreach (var r in rows)
                    {
                        using (var cmd = new SqlCommand("Pro_Lafty_Days", con))
                        {
                            cmd.CommandType = CommandType.StoredProcedure;
                            cmd.Parameters.Add("@ID_no", SqlDbType.BigInt).Value = r.Key;
                            cmd.Parameters.Add("@days", SqlDbType.BigInt).Value = r.Value;
                            cmd.Parameters.Add("@from_Date", SqlDbType.DateTime).Value = from;
                            cmd.Parameters.Add("@till_Date", SqlDbType.DateTime).Value = till;
                            cmd.ExecuteNonQuery();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message);
                return;
            }

            string url = ResolveClientUrl(ListViewPage);
            string js = "window.open(" + new JavaScriptSerializer().Serialize(url) + ",'_blank');";
            ClientScript.RegisterStartupScript(GetType(), "openlist", "document.addEventListener('DOMContentLoaded',function(){" + js + "});", true);
            Toast(rows.Count + " employee(s) processed.");
        }

        // Refresh: ডেস্কটপের button5_Click_1 (Pro_Clear_Open_List)
        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();
                    ClearOpenList(con);
                }
                Toast("Lefty Clear Successfull");
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message);
            }
        }

        // Delete Punch: ডেস্কটপের button1_Click_1 (Pro_Lefty_Punch_Delete)
        protected void btnDeletePunch_Click(object sender, EventArgs e)
        {
            var rows = SelectedRows();
            if (rows.Count == 0)
            {
                Toast("কমপক্ষে একজন কর্মচারী নির্বাচন করুন।");
                return;
            }

            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();

                    foreach (var r in rows)
                    {
                        using (var cmd = new SqlCommand("Pro_Lefty_Punch_Delete", con))
                        {
                            cmd.CommandType = CommandType.StoredProcedure;
                            cmd.Parameters.Add("@ID_no", SqlDbType.BigInt).Value = r.Key;
                            cmd.ExecuteNonQuery();
                        }
                    }
                }
                Toast("Punch deleted for " + rows.Count + " employee(s).");
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message);
            }
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            ResetDefaults();
            ClearGrid();
            Toast("All filters cleared.");
        }

        void ClearOpenList(SqlConnection con)
        {
            using (var cmd = new SqlCommand("Pro_Clear_Open_List", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.ExecuteNonQuery();
            }
        }

        // ================= Show এর মূল লজিক =================
        // ডেস্কটপের button2_Click: Pro_Lefty (work_date, till_Date, ab_Days, Department, Section, Line, Designation, Catagory, status)
        // মাল্টি-সিলেক্ট হওয়ায় নির্বাচিত মানগুলোর সব সমন্বয়ে Pro_Lefty চলে, ফলাফল ID ধরে একত্র হয়।
        bool ShowData()
        {
            DateTime from, till;
            if (!TryDates(out from, out till)) return false;

            string status = ddStatus.SelectedItem != null ? ddStatus.SelectedItem.Text.Trim() : "";
            string days = (txtDays.Text ?? "").Trim();

            var depts = SelectedTexts(ddDept);
            var secs = SelectedTexts(ddSection);
            var lines = SelectedTexts(ddLine);
            var desigs = SelectedTexts(ddDesig);
            var cats = SelectedTexts(ddCategory);

            long combos = (long)depts.Count * secs.Count * lines.Count * desigs.Count * cats.Count;
            if (combos > MaxCombos)
            {
                Toast("Too many filter combinations (" + combos + "). Please narrow the selection (max " + MaxCombos + ").");
                return false;
            }

            var list = new List<Emp>();
            var seen = new HashSet<string>();

            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();

                    foreach (string d in depts)
                        foreach (string s in secs)
                            foreach (string l in lines)
                                foreach (string g in desigs)
                                    foreach (string c in cats)
                                    {
                                        DataTable dt = RunLefty(con, from, till, days, d, s, l, g, c, status);
                                        foreach (DataRow r in dt.Rows)
                                        {
                                            string id = Col(r, 0, "ID_no", "ID_No", "Id", "Emp_ID");
                                            if (id.Length == 0 || !seen.Add(id)) continue;

                                            list.Add(new Emp
                                            {
                                                Id = id,
                                                Name = Col(r, 1, "Name", "Emp_Name"),
                                                Designation = Col(r, 2, "Designation", "Desigation_name"),
                                                Days = Col(r, 3, "Days", "Ab_Days", "Absent_Days", "days", "Total_Days")
                                            });
                                        }
                                    }
                }
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message);
                return false;
            }

            // Multi ID No দেওয়া থাকলে ফলাফল শুধু সেই ID গুলোতে সীমিত
            string[] filterIds = HRFilters.ParseIds(txtMultiId.Text);
            if (filterIds.Length > 0)
            {
                var set = new HashSet<string>(filterIds.Select(x => x.Trim()), StringComparer.OrdinalIgnoreCase);
                list = list.Where(x => set.Contains(x.Id)).ToList();
            }

            BindTable(list);
            return true;
        }

        DataTable RunLefty(SqlConnection con, DateTime from, DateTime till, string days,
                           string dept, string section, string line, string desig, string cat, string status)
        {
            using (var cmd = new SqlCommand("Pro_Lefty", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandTimeout = 120;

                // ডেস্কটপে DateTimePicker এর Text (যেমন 12-Nov-26) পাঠানো হতো, এখানেও একই ফরম্যাট
                cmd.Parameters.AddWithValue("@work_date", from.ToString("dd-MMM-yy", CultureInfo.InvariantCulture));
                cmd.Parameters.AddWithValue("@till_Date", till.ToString("dd-MMM-yy", CultureInfo.InvariantCulture));
                cmd.Parameters.AddWithValue("@ab_Days", days);
                cmd.Parameters.AddWithValue("@Department", dept);
                cmd.Parameters.AddWithValue("@Section", section);
                cmd.Parameters.AddWithValue("@Line", line);
                cmd.Parameters.AddWithValue("@Designation", desig);
                cmd.Parameters.AddWithValue("@Catagory", cat);
                cmd.Parameters.AddWithValue("@status", status);

                var dt = new DataTable();
                using (var rd = cmd.ExecuteReader()) dt.Load(rd);
                return dt;
            }
        }

        // কিছু না বাছলে একটিমাত্র "" (= সব), নইলে নির্বাচিত আইটেমের নাম
        static List<string> SelectedTexts(ListBox lb)
        {
            var l = lb.Items.Cast<ListItem>().Where(i => i.Selected).Select(i => i.Text.Trim()).ToList();
            if (l.Count == 0) l.Add("");
            return l;
        }

        // ================= ফলাফল দেখানো =================
        void BindTable(List<Emp> list)
        {
            rptEmployees.DataSource = list;
            rptEmployees.DataBind();
            trEmpty.Visible = list.Count == 0;

            lblCount.Text = list.Count + " Records";
            litPaging.Text = list.Count == 0
                ? "Showing 0 entries"
                : "Showing <span class=\"font-medium text-slate-700\">" + list.Count + "</span> entries";
        }

        static string Col(DataRow r, int fallbackIndex, params string[] names)
        {
            foreach (string n in names)
            {
                if (r.Table.Columns.Contains(n) && r[n] != DBNull.Value)
                    return Convert.ToString(r[n]).Trim();
            }
            // নাম না মিললে ডেস্কটপ গ্রিডের পজিশন অনুযায়ী (ID, Name, Designation, Days)
            if (fallbackIndex >= 0 && fallbackIndex < r.Table.Columns.Count && r[fallbackIndex] != DBNull.Value)
                return Convert.ToString(r[fallbackIndex]).Trim();
            return "";
        }

        // ================= সাহায্যকারী =================
        // টিক দেওয়া সারি: প্রথমে চেকবক্সের name="selId", না পেলে hfSelIds (মান: "ID|Days")
        string SelectedRaw()
        {
            string[] fromForm = Request.Form.GetValues("selId");
            if (fromForm != null && fromForm.Length > 0)
                return string.Join(",", fromForm);
            return hfSelIds.Value ?? "";
        }

        // ID -> Days
        Dictionary<long, long> SelectedRows()
        {
            var result = new Dictionary<long, long>();
            foreach (string part in SelectedRaw().Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries))
            {
                string[] kv = part.Split('|');
                long id, days = 0;
                if (!long.TryParse(kv[0].Trim(), out id) || id == 0) continue;
                if (kv.Length > 1) long.TryParse(kv[1].Trim(), out days);
                result[id] = days;
            }
            return result;
        }

        bool TryDates(out DateTime from, out DateTime till)
        {
            string[] fmts = { "yyyy-MM-dd", "dd-MMM-yy", "dd-MMM-yyyy", "dd/MM/yyyy" };
            from = till = DateTime.MinValue;

            if (!DateTime.TryParseExact((txtFromDate.Text ?? "").Trim(), fmts, CultureInfo.InvariantCulture, DateTimeStyles.None, out from) ||
                !DateTime.TryParseExact((txtTillDate.Text ?? "").Trim(), fmts, CultureInfo.InvariantCulture, DateTimeStyles.None, out till))
            {
                Toast("From Date ও Till Date সঠিকভাবে দিন।");
                return false;
            }
            if (till < from)
            {
                Toast("Till Date, From Date এর আগে হতে পারে না।");
                return false;
            }
            return true;
        }

        void ResetDefaults()
        {
            filters.ClearSelections();
            foreach (ListItem i in ddLine.Items) i.Selected = false;

            if (ddStatus.Items.Count > 0) ddStatus.SelectedIndex = 0;

            hfSelIds.Value = "";
            txtMultiId.Text = "";
            txtDays.Text = "";

            string today = DateTime.Today.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
            txtFromDate.Text = today;
            txtTillDate.Text = today;
        }

        void ClearGrid()
        {
            rptEmployees.DataSource = null;
            rptEmployees.DataBind();
            trEmpty.Visible = false;
            lblCount.Text = "0 Records";
            litPaging.Text = "Showing 0 entries";
        }

        void Toast(string msg)
        {
            string js = "document.addEventListener('DOMContentLoaded',function(){showNotification(" +
                        new JavaScriptSerializer().Serialize(msg) + ");});";
            ClientScript.RegisterStartupScript(GetType(), "toast" + Guid.NewGuid().ToString("N"), js, true);
        }
    }
}
