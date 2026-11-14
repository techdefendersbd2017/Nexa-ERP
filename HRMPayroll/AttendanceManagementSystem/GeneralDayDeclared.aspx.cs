using Nexa_ERP.Connection;
using Nexa_ERP.HRMPayroll.Common;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.HRMPayroll.AttendanceManagementSystem
{
    public partial class SpecialDayDeclared : System.Web.UI.Page
    {
        PayrollDB conn = new PayrollDB();

        // পাবলিক ফিল্টার ক্লাস (Attendance_Reports এর মতোই)
        HRFilters filters;

        const int MaxIds = HRFilters.MaxIds;

        readonly List<string> loadErrors = new List<string>();

        // সমস্যা মিটে গেলে false করে দিন
        const bool ShowDebug = false;
        readonly List<string> debug = new List<string>();

        // ---------- মডেল ----------
        public class Emp
        {
            public string Id { get; set; }
            public string Name { get; set; }
            public string Designation { get; set; }
        }

        public class DayRow
        {
            public string Code { get; set; }
            public string Date { get; set; }
            public string Description { get; set; }
            public string AttStatus { get; set; }
        }

        // TODO: আপনার Login/Session এর key অনুযায়ী বদলান
        long UserCode { get { return HRFilters.UserCode; } }
        long FromCode { get { return HRFilters.SessionLong("From_Code", "FromCode"); } }

        List<string> AllErrors()
        {
            return loadErrors.Concat(filters.Errors).ToList();
        }

        // ================= Page Load =================
        protected void Page_Load(object sender, EventArgs e)
        {
            // ফিল্টার ক্লাস তৈরি: এই পেজে যেসব ফিল্টার আছে সেগুলো Attach করুন
            filters = new HRFilters()
                .Attach(HRFilters.Branch, ddBranch)
                .Attach(HRFilters.Category, ddCategory)
                .Attach(HRFilters.Dept, ddDept)
                .Attach(HRFilters.Section, ddSection)
                .Attach(HRFilters.SubSec, ddSubSec)
                .Attach(HRFilters.Desig, ddDesig)
                .Attach(HRFilters.Level, ddLevel)
                .Attach(HRFilters.Floor, ddFloor);
            filters.EmptyMeansAll = false;   // কিছু না বাছলে কিছুই insert হবে না

            filters.LoadLookups();           // কোড খোঁজার জন্য প্রতিটি request এ লাগে

            // পোস্টব্যাকের পর আগের টিক ফিরিয়ে আনা
            // (Repeater এর সারি ViewState থেকে ফেরে, তাই Add/Update/Delete এর পরেও নির্বাচন থাকে)
            if (IsPostBack && !string.IsNullOrEmpty(SelectedIdsRaw()))
            {
                string arr = new JavaScriptSerializer().Serialize(SelectedIdsRaw().Split(','));
                ClientScript.RegisterStartupScript(GetType(), "retick",
                    "document.addEventListener('DOMContentLoaded',function(){var ids=" + arr +
                    ";document.querySelectorAll('.row-checkbox').forEach(function(c){" +
                    "if(ids.indexOf(c.getAttribute('data-id'))>=0)c.checked=true;});});", true);
            }

            if (!IsPostBack)
            {
                FillDropDowns();
                ResetDefaults();
                ClearGrid();
                LoadDays();
            }

            if (IsPostBack && AllErrors().Count > 0)
                Toast("Option load error: " + string.Join(" | ", AllErrors()));
        }

        void FillDropDowns()
        {
            filters.FillControls();   // Branch, Category, Dept ... সব ভরে দেয়

            FillStatic(ddBlood, "-- All --", "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-");
            FillStatic(ddReligion, "-- All --", "Islam", "Hinduism", "Buddhism", "Christianity", "Others");
            // Attendance_Reports এর সঙ্গে একই তালিকা (প্রথমটি ডিফল্ট)
            FillStatic(ddStatus, null, "Active", "New", "Seperation", "All", "Resign", "Left");

            // TODO: আপনার সিস্টেমের Att. Status এর মান অনুযায়ী বদলান
            FillStatic(ddAttStatus, "--Select--", "Holiday", "Working Day", "Half Day");

            if (AllErrors().Count > 0)
                Toast("Option load error: " + string.Join(" | ", AllErrors()));
        }

        static void FillStatic(DropDownList dd, string blank, params string[] items)
        {
            dd.Items.Clear();
            if (blank != null) dd.Items.Add(new ListItem(blank, ""));
            foreach (string s in items) dd.Items.Add(new ListItem(s, s));
        }

        // ================= বাটন ইভেন্ট =================
        protected void btnShow_Click(object sender, EventArgs e)
        {
            ShowData();
            LoadDays();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ResetDefaults();
            ClearGrid();
            LoadDays();
            Toast("All filters cleared.");
        }

        protected void btnAdd_Click(object sender, EventArgs e) { RunAction("Pro_Special_Day_Declare_Add", "Special Date Add Successful", true); }
        protected void btnUpdate_Click(object sender, EventArgs e) { RunAction("Pro_Special_Day_Declare_Update", "Special Update Successful", false); }
        protected void btnDelByIdDate_Click(object sender, EventArgs e) { RunAction("Pro_Special_Day_Declare_Delete_by_ID", "Special Delete Successful", false); }
        protected void btnDelByDate_Click(object sender, EventArgs e) { RunAction("Pro_Special_Day_Declare_Delete_All", "Special Delete Successful", false); }

        // টিক দেওয়া ID গুলো: প্রথমে চেকবক্সের name="selId", না পেলে hfSelIds
        string SelectedIdsRaw()
        {
            string[] fromForm = Request.Form.GetValues("selId");
            if (fromForm != null && fromForm.Length > 0)
                return string.Join(",", fromForm);
            return hfSelIds.Value ?? "";
        }

        static bool TryDate(string s, out DateTime d)
        {
            return DateTime.TryParseExact((s ?? "").Trim(), "yyyy-MM-dd",
                CultureInfo.InvariantCulture, DateTimeStyles.None, out d);
        }

        // ================= Add / Update / Delete =================
        // নির্বাচিত প্রতিটি কর্মচারী × (From..To) এর প্রতিটি দিনের জন্য স্টোরড প্রসিডিউর চলে।
        // সব একটি ট্রানজেকশনে: মাঝে ব্যর্থ হলে কিছুই সেভ হয় না।
        void RunAction(string proc, string okMsg, bool isAdd)
        {
            long[] ids = HRFilters.ParseIds(SelectedIdsRaw())
                .Select(s => { long x; return long.TryParse(s, out x) ? x : 0; })
                .Where(x => x != 0).Distinct().ToArray();

            if (ids.Length == 0) { Toast("কমপক্ষে একজন কর্মচারী নির্বাচন করুন।"); return; }
            if (ids.Length > MaxIds) { Toast("Too many IDs (max " + MaxIds + ")."); return; }

            DateTime from, till, eff = DateTime.Today;
            if (!TryDate(txtFromDate.Text, out from) || !TryDate(txtTillDate.Text, out till))
            { Toast("Special Day এর তারিখ দিন।"); return; }
            if (till < from) { Toast("To তারিখ From এর আগে হতে পারবে না।"); return; }
            if (isAdd && !TryDate(txtEffJoin.Text, out eff)) { Toast("Effective Join Date দিন।"); return; }
            if (string.IsNullOrEmpty(ddAttStatus.SelectedValue)) { Toast("Att. Status নির্বাচন করুন।"); return; }

            long lunch = 0;
            if (isAdd && !string.IsNullOrWhiteSpace(txtLunchMin.Text) && !long.TryParse(txtLunchMin.Text.Trim(), out lunch))
            { Toast("Additional Lunch Time সংখ্যা হতে হবে।"); return; }

            int count = 0;
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();

                    using (SqlTransaction tx = con.BeginTransaction())
                    {
                        try
                        {
                            foreach (long id in ids)
                            {
                                for (DateTime d = from.Date; d <= till.Date; d = d.AddDays(1))
                                {
                                    using (var cmd = new SqlCommand(proc, con, tx))
                                    {
                                        cmd.CommandType = CommandType.StoredProcedure;
                                        cmd.Parameters.Add("@id_No", SqlDbType.BigInt).Value = id;
                                        cmd.Parameters.Add("@Special_Date", SqlDbType.Date).Value = d;
                                        cmd.Parameters.Add("@Description_of_Day", SqlDbType.VarChar).Value = txtDescription.Text ?? "";
                                        cmd.Parameters.Add("@Att_Status", SqlDbType.VarChar).Value = ddAttStatus.SelectedValue;
                                        if (isAdd)
                                        {
                                            cmd.Parameters.Add("@Efective_joining_Date", SqlDbType.Date).Value = eff;
                                            cmd.Parameters.Add("@Deduction_Min", SqlDbType.BigInt).Value = lunch;
                                        }
                                        cmd.ExecuteNonQuery();
                                        count++;
                                    }
                                }
                            }
                            tx.Commit();
                        }
                        catch
                        {
                            tx.Rollback();
                            throw;
                        }
                    }
                }
                Toast(okMsg + " (" + count + " entries)");
            }
            catch (Exception ex)
            {
                Toast("Process Fail: " + ex.Message);
            }

            LoadDays();
        }

        // ================= Declared special days (নিচের তালিকা) =================
        void LoadDays()
        {
            var list = new List<DayRow>();
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();

                    using (var cmd = new SqlCommand("SELECT * FROM Special_Day_Declare ORDER BY Special_Date ASC", con))
                    {
                        var dt = new DataTable();
                        using (var da = new SqlDataAdapter(cmd)) da.Fill(dt);

                        // কলাম ক্রম (WinForms এর মতো): 0=Day Code, 1=Date, 2=Description, 3=Att Status
                        foreach (DataRow r in dt.Rows)
                        {
                            DateTime dtm;
                            string ds = DateTime.TryParse(Convert.ToString(r[1]), out dtm)
                                ? dtm.ToString("dd-MMM-yyyy", CultureInfo.InvariantCulture)
                                : Convert.ToString(r[1]);

                            list.Add(new DayRow
                            {
                                Code = Convert.ToString(r[0]),
                                Date = ds,
                                Description = Convert.ToString(r[2]),
                                AttStatus = Convert.ToString(r[3])
                            });
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message);
            }

            rptDays.DataSource = list;
            rptDays.DataBind();
            trEmptyDays.Visible = list.Count == 0;
            lblDayCount.Text = list.Count + " Records";
        }

        // ================= Show এর মূল লজিক (Attendance_Reports এর মতো) =================
        bool ShowData()
        {
            DataTable dt;
            string status = string.IsNullOrEmpty(ddStatus.SelectedValue) ? "Active" : ddStatus.SelectedValue;

            try
            {
                string[] ids = HRFilters.ParseIds(txtMultiId.Text);

                if (ids.Length > MaxIds)
                {
                    Toast("Too many IDs (max " + MaxIds + ").");
                    return false;
                }

                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();

                    if (ids.Length > 0)
                    {
                        dt = QueryByIds(con, ids, status);
                    }
                    else
                    {
                        if (UserCode == 0)
                        {
                            Toast("User_Code পাওয়া যায়নি (Session)। Login করে আবার চেষ্টা করুন।");
                            return false;
                        }

                        // ফিল্টার ক্লাস দিয়ে সব নির্বাচন সেভ
                        debug.AddRange(filters.SaveSelections(con, UserCode, FromCode));

                        dt = RunStatusProc(con, status);
                        debug.Add("user=" + UserCode + ", fromCode=" + FromCode + ", status=" + status + ", rows=" + dt.Rows.Count);
                    }
                }
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message);
                return false;
            }

            if (ShowDebug && debug.Count > 0)
                Toast("Debug → " + string.Join(", ", debug));

            BindTable(dt);
            return true;
        }

        DataTable QueryByIds(SqlConnection con, string[] ids, string status)
        {
            bool numeric = ids.All(s => { long x; return long.TryParse(s, out x); });

            using (var cmd = new SqlCommand())
            {
                cmd.Connection = con;
                var names = new List<string>();
                for (int i = 0; i < ids.Length; i++)
                {
                    string p = "@id" + i;
                    names.Add(p);
                    if (numeric) cmd.Parameters.Add(p, SqlDbType.BigInt).Value = long.Parse(ids[i]);
                    else cmd.Parameters.Add(p, SqlDbType.NVarChar, 50).Value = ids[i];
                }

                string sql = "SELECT ID_no, Name, Designation, Resign_Status FROM View_Emp WHERE ID_no IN (" + string.Join(",", names) + ")";
                if (status != "All")
                {
                    sql += " AND Resign_Status = @st";
                    cmd.Parameters.Add("@st", SqlDbType.NVarChar, 50).Value = status;
                }
                cmd.CommandText = sql;

                var dt = new DataTable();
                using (var da = new SqlDataAdapter(cmd)) da.Fill(dt);
                return dt;
            }
        }

        DataTable RunStatusProc(SqlConnection con, string status)
        {
            string proc;
            switch (status)
            {
                case "Active": proc = "Pro_Employee_View_N"; break;
                case "New": proc = "Pro_Employee_View_N_New"; break;
                case "Seperation": proc = "Pro_Employee_View_N_Seperation"; break;
                case "All": proc = "Pro_Employee_View_N_All"; break;
                default: proc = "Pro_Employee_View_N_Resign_Lefty_Others"; break;
            }

            string from = string.IsNullOrWhiteSpace(txtFromDate.Text) ? "1900-01-01" : txtFromDate.Text.Trim();
            string till = string.IsNullOrWhiteSpace(txtTillDate.Text) ? DateTime.Today.ToString("yyyy-MM-dd") : txtTillDate.Text.Trim();

            using (var cmd = new SqlCommand(proc, con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandTimeout = 120;
                cmd.Parameters.AddWithValue("@Employee_Status", status);
                cmd.Parameters.AddWithValue("@from_Date", from);
                cmd.Parameters.AddWithValue("@till_Date", till);
                cmd.Parameters.AddWithValue("@User_Code", UserCode.ToString());
                cmd.Parameters.AddWithValue("@From_Code", FromCode.ToString());

                var dt = new DataTable();
                using (var rd = cmd.ExecuteReader()) dt.Load(rd);
                return dt;
            }
        }

        // ================= ফলাফল দেখানো =================
        void BindTable(DataTable dt)
        {
            var list = new List<Emp>();
            foreach (DataRow r in dt.Rows)
            {
                list.Add(new Emp
                {
                    Id = Col(r, "", "ID_no", "Id", "Emp_ID"),
                    Name = Col(r, "", "Name", "Emp_Name"),
                    Designation = Col(r, "", "Designation", "Desigation_name")
                });
            }

            rptEmployees.DataSource = list;
            rptEmployees.DataBind();
            trEmpty.Visible = list.Count == 0;
            lblCount.Text = list.Count + " Records";
            // দ্রষ্টব্য: Attendance_Reports এর মতো সব সারি স্বয়ংক্রিয় টিক দেওয়া হয় না;
            // মুছে ফেলার মতো কাজে ভুল এড়াতে ব্যবহারকারী "All" বাটন চাপবে।
        }

        static string Col(DataRow r, string fallback, params string[] names)
        {
            foreach (string n in names)
            {
                if (r.Table.Columns.Contains(n) && r[n] != DBNull.Value)
                    return Convert.ToString(r[n]);
            }
            return fallback;
        }

        // ================= সাহায্যকারী =================
        void ResetDefaults()
        {
            // মাল্টিপল সিলেক্ট ফিল্টার: সব সিলেকশন মোছা
            filters.ClearSelections();

            // সাধারণ ড্রপডাউন: প্রথম আইটেমে ফেরা
            foreach (var d in new[] { ddBlood, ddReligion, ddStatus, ddAttStatus })
                if (d.Items.Count > 0) d.SelectedIndex = 0;

            hfSelIds.Value = "";
            txtMultiId.Text = "";
            txtDescription.Text = "";
            txtLunchMin.Text = "";

            // ডিফল্ট তারিখ: আজ (yyyy-MM-dd ফরম্যাট দরকার, কারণ ঘরটি date টাইপে রূপান্তর হয়)
            string today = DateTime.Today.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
            txtFromDate.Text = today;
            txtTillDate.Text = today;
            txtEffJoin.Text = today;
        }

        void ClearGrid()
        {
            rptEmployees.DataSource = null;
            rptEmployees.DataBind();
            trEmpty.Visible = false;
            lblCount.Text = "0 Records";
        }

        void Toast(string msg)
        {
            string js = "document.addEventListener('DOMContentLoaded',function(){showNotification(" +
                        new JavaScriptSerializer().Serialize(msg) + ");});";
            ClientScript.RegisterStartupScript(GetType(), "toast" + Guid.NewGuid().ToString("N"), js, true);
        }
    }
}
