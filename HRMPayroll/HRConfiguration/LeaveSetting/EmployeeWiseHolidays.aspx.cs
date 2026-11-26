using Nexa_ERP.Connection;
using Nexa_ERP.HRMPayroll.Common;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.HRMPayroll.HRConfiguration.LeaveSetting
{
    public partial class EmployeeWiseHolidays : System.Web.UI.Page
    {
        PayrollDB conn = new PayrollDB();

        // HRMReports এর মতোই ফিল্টার ক্লাস
        HRFilters filters;

        const string DateFmt = "dd-MMM-yyyy";
        const string InputFmt = "yyyy-MM-dd";   // HTML date input

        // ---------- মডেল ----------
        public class Emp
        {
            public string IdNo { get; set; }
            public string Name { get; set; }
            public string Designation { get; set; }
            public string Department { get; set; }
            public string Branch { get; set; }
            public string Status { get; set; }
        }

        public class Row
        {
            public string ApplyNo { get; set; }
            public string IdNo { get; set; }
            public string FromDate { get; set; }
            public string TillDate { get; set; }
        }

        long UserCode { get { return HRFilters.UserCode; } }
        long FromCode { get { return HRFilters.SessionLong("From_Code", "FromCode"); } }

        // ================= Page Load =================
        protected void Page_Load(object sender, EventArgs e)
        {
            // ফিল্টার ক্লাস তৈরি: HRMReports এর মতো একই ৮টি মাল্টি-সিলেক্ট
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

            if (!IsPostBack)
            {
                FillDropDowns();
                LoadHolidayTypes();
                ResetForm();
                BindEmp(new List<Emp>());
                BindList();
                return;
            }

            if (filters.Errors.Count > 0)
                Toast("Option load error: " + string.Join(" | ", filters.Errors));

            // Save/Delete এর পর কর্মচারী গ্রিডের আগের টিক ফিরিয়ে আনা
            // (Show, Apply No ক্লিক ও Clear এ নয়, কারণ এগুলোতে গ্রিড নতুন করে ভরে)
            string target = Request.Form["__EVENTTARGET"] ?? "";
            string[] ticked = Request.Form.GetValues("selEmp");
            bool skip = target.IndexOf("btnShow", StringComparison.OrdinalIgnoreCase) >= 0
                     || target.IndexOf("rptList", StringComparison.OrdinalIgnoreCase) >= 0
                     || target.IndexOf("btnClear", StringComparison.OrdinalIgnoreCase) >= 0;

            if (ticked != null && !skip)
            {
                string arr = new JavaScriptSerializer().Serialize(ticked);
                ClientScript.RegisterStartupScript(GetType(), "retick",
                    "document.addEventListener('DOMContentLoaded',function(){var ids=" + arr +
                    ";document.querySelectorAll('.emp-cb').forEach(function(c){c.checked=ids.indexOf(c.value)>=0;});});", true);
            }
        }

        void FillDropDowns()
        {
            filters.FillControls();   // Branch, Category, Dept ... সব ভরে দেয়

            FillStatic(ddBlood, "-- All --", "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-");
            FillStatic(ddReligion, "-- All --", "Islam", "Hinduism", "Buddhism", "Christianity", "Others");
            // HRMReports এর মতোই (প্রথমটি ডিফল্ট)
            FillStatic(ddStatus, null, "Active", "New", "Seperation", "All", "Resign", "Left");

            if (filters.Errors.Count > 0)
                Toast("Option load error: " + string.Join(" | ", filters.Errors));
        }

        static void FillStatic(DropDownList dd, string blank, params string[] items)
        {
            dd.Items.Clear();
            if (blank != null) dd.Items.Add(new ListItem(blank, ""));
            foreach (string s in items) dd.Items.Add(new ListItem(s, s));
        }

        // ================= Holiday Type =================
        // ডেস্কটপ: SELECT * FROM Holiday_Type (DisplayMember=Type_name, ValueMember=Holi_Code)
        void LoadHolidayTypes()
        {
            ddHoliType.Items.Clear();
            ddHoliType.Items.Add(new ListItem("-- Select --", ""));
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();
                    using (var cmd = new SqlCommand("SELECT Holi_Code, Type_name FROM Holiday_Type", con))
                    {
                        var dt = new DataTable();
                        using (var da = new SqlDataAdapter(cmd)) da.Fill(dt);
                        foreach (DataRow r in dt.Rows)
                            ddHoliType.Items.Add(new ListItem(Convert.ToString(r["Type_name"]).Trim(), Convert.ToString(r["Holi_Code"])));
                    }
                }
            }
            catch (Exception ex)
            {
                Toast("Holiday type load error: " + ex.Message);
            }
        }

        // ================= Show: ফিল্টার বা ID দিয়ে কর্মচারী খোঁজা =================
        protected void btnShow_Click(object sender, EventArgs e)
        {
            hfApplyCode.Value = "";
            string status = string.IsNullOrEmpty(ddStatus.SelectedValue) ? "Active" : ddStatus.SelectedValue;
            var list = new List<Emp>();

            try
            {
                string[] ids = HRFilters.ParseIds(txtMultiId.Text).Distinct().ToArray();

                if (ids.Length > HRFilters.MaxIds)
                {
                    Toast("Too many IDs (max " + HRFilters.MaxIds + ").");
                    return;
                }

                if (ids.Length > 0)
                {
                    // ID দেওয়া থাকলে ডেস্কটপের মতো View_Emp থেকে সরাসরি
                    list = LoadEmployeesByIds(ids);

                    var missing = ids.Where(i => !list.Any(x => x.IdNo == i)).ToList();
                    if (missing.Count > 0)
                        Toast("পাওয়া যায়নি: " + string.Join(", ", missing));
                }
                else
                {
                    if (UserCode == 0)
                    {
                        Toast("User_Code পাওয়া যায়নি (Session)। Login করে আবার চেষ্টা করুন।");
                        return;
                    }

                    using (SqlConnection con = conn.openConnection())
                    {
                        if (con.State != ConnectionState.Open) con.Open();

                        // ফিল্টার ক্লাস দিয়ে সব নির্বাচন সেভ, তারপর স্ট্যাটাস অনুযায়ী প্রসিডিউর
                        filters.SaveSelections(con, UserCode, FromCode);
                        DataTable dt = RunStatusProc(con, status);
                        list = MapEmp(dt, status);
                    }
                }
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message);
                return;
            }

            BindEmp(list);
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

            string from = "1900-01-01";
            string till = DateTime.Today.ToString("yyyy-MM-dd");

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

        // ডেস্কটপ textBox2_KeyDown: View_Emp থেকে ID_no IN (...)
        List<Emp> LoadEmployeesByIds(string[] ids)
        {
            using (SqlConnection con = conn.openConnection())
            {
                if (con.State != ConnectionState.Open) con.Open();
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
                    cmd.CommandText = "SELECT * FROM View_Emp WHERE ID_no IN (" + string.Join(",", names) + ")";

                    var dt = new DataTable();
                    using (var da = new SqlDataAdapter(cmd)) da.Fill(dt);
                    return MapEmp(dt, "");
                }
            }
        }

        static List<Emp> MapEmp(DataTable dt, string fallbackStatus)
        {
            var list = new List<Emp>();
            foreach (DataRow r in dt.Rows)
            {
                list.Add(new Emp
                {
                    IdNo = Col(r, "", "ID_no", "Id", "Emp_ID"),
                    Name = Col(r, "", "Name", "Emp_Name"),
                    Designation = Col(r, "", "Designation", "Desigation_name"),
                    Department = Col(r, "", "Department", "Department_Name"),
                    Branch = Col(r, "", "Branch", "Branch_Name"),
                    Status = Col(r, fallbackStatus, "Resign_Status", "Status", "Employee_Status")
                });
            }
            return list;
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

        void BindEmp(List<Emp> list)
        {
            rptEmp.DataSource = list;
            rptEmp.DataBind();
            trEmpEmpty.Visible = list.Count == 0;
            lblEmpCount.Text = list.Count.ToString();
        }

        // ================= Save =================
        // ডেস্কটপ button1_Click: টিক দেওয়া প্রতিটি কর্মচারীর জন্য Pro_Employe_Wise_Holiday_Add_New
        protected void btnSave_Click(object sender, EventArgs e)
        {
            DateTime from, till;
            if (!DateTime.TryParseExact(txtFromDate.Text.Trim(), InputFmt, CultureInfo.InvariantCulture, DateTimeStyles.None, out from) ||
                !DateTime.TryParseExact(txtTillDate.Text.Trim(), InputFmt, CultureInfo.InvariantCulture, DateTimeStyles.None, out till))
            {
                Toast("From Date ও Till Date সঠিকভাবে দিন।");
                return;
            }
            if (till < from)
            {
                Toast("Till Date, From Date এর আগে হতে পারবে না।");
                return;
            }

            long holiId;
            if (!long.TryParse(ddHoliType.SelectedValue, out holiId))
            {
                Toast("Please Check your Holiday Type");
                return;
            }

            string[] ticked = Request.Form.GetValues("selEmp");
            var ids = new List<long>();
            if (ticked != null)
                foreach (string s in ticked)
                {
                    long x;
                    if (long.TryParse(s, out x) && !ids.Contains(x)) ids.Add(x);
                }

            if (ids.Count == 0)
            {
                Toast("কমপক্ষে একজন কর্মচারী টিক দিন।");
                return;
            }

            int ok = 0;
            var failed = new List<string>();

            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();

                    foreach (long id in ids)
                    {
                        try
                        {
                            using (var cmd = new SqlCommand("Pro_Employe_Wise_Holiday_Add_New", con))
                            {
                                cmd.CommandType = CommandType.StoredProcedure;
                                cmd.Parameters.Add("@ID_No", SqlDbType.BigInt).Value = id;
                                cmd.Parameters.Add("@form", SqlDbType.DateTime).Value = from;
                                cmd.Parameters.Add("@Till", SqlDbType.DateTime).Value = till;
                                cmd.Parameters.Add("@Holiday_name", SqlDbType.VarChar).Value = txtHolidayName.Text.Trim();
                                cmd.Parameters.Add("@Holi_ID", SqlDbType.BigInt).Value = holiId;
                                cmd.ExecuteNonQuery();
                                ok++;
                            }
                        }
                        catch (Exception exRow)
                        {
                            failed.Add(id + " (" + exRow.Message + ")");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message);
                BindList();
                return;
            }

            hfApplyCode.Value = "";
            BindList();

            if (ok > 0 && failed.Count == 0) Toast("Save Successful (" + ok + " employee)");
            else if (ok > 0) Toast("Saved " + ok + ", failed: " + string.Join("; ", failed));
            else Toast("Save Fail: " + string.Join("; ", failed));
        }

        // ================= Delete =================
        // ডেস্কটপে এখানে ভুল করে ID No পাঠানো হতো; এখানে Apply_Code পাঠানো হচ্ছে
        protected void btnDelete_Click(object sender, EventArgs e)
        {
            var codes = new List<long>();
            string[] ticked = Request.Form.GetValues("selApply");
            if (ticked != null)
                foreach (string s in ticked)
                {
                    long x;
                    if (long.TryParse(s, out x) && !codes.Contains(x)) codes.Add(x);
                }

            // কিছু টিক না থাকলে Apply No-তে ক্লিক করে বাছা রেকর্ড
            if (codes.Count == 0)
            {
                long one;
                if (long.TryParse((hfApplyCode.Value ?? "").Trim(), out one)) codes.Add(one);
            }

            if (codes.Count == 0)
            {
                Toast("মুছতে ডান পাশের তালিকা থেকে রো টিক দিন।");
                return;
            }

            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();
                    foreach (long c in codes)
                        HRDb.ExecProc(con, "Pro_Employe_Wise_Holiday_Delete", HRDb.P("@Apply_Code", c));
                }
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message);
                return;
            }

            hfApplyCode.Value = "";
            BindList();
            Toast("Delete Successful (" + codes.Count + ")");
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ResetForm();
            BindEmp(new List<Emp>());
            BindList();
            Toast("All filters cleared.");
        }

        // ================= ডান তালিকা থেকে রো বাছলে ফর্মে লোড (ডেস্কটপ listView1_SelectedIndexChanged) =================
        protected void rptList_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "pick") return;
            string code = Convert.ToString(e.CommandArgument);
            string empId = null;

            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();
                    using (var cmd = new SqlCommand("SELECT * FROM Employe_Wise_Holiday WHERE Apply_Code=@a", con))
                    {
                        cmd.Parameters.Add("@a", SqlDbType.NVarChar, 50).Value = code;
                        var dt = new DataTable();
                        using (var da = new SqlDataAdapter(cmd)) da.Fill(dt);

                        if (dt.Rows.Count == 0) { Toast("Record not found."); BindList(); return; }

                        DataRow r = dt.Rows[0];
                        // কলামের ক্রম ডেস্কটপের মতো: 0=Apply_Code, 1=ID_no, 2=From, 3=Till, 4=Holi_ID
                        hfApplyCode.Value = Convert.ToString(r[0]);
                        empId = Convert.ToString(r[1]);
                        txtMultiId.Text = empId;
                        txtFromDate.Text = ToDate(r[2]).ToString(InputFmt, CultureInfo.InvariantCulture);
                        txtTillDate.Text = ToDate(r[3]).ToString(InputFmt, CultureInfo.InvariantCulture);

                        ddHoliType.ClearSelection();
                        var li = ddHoliType.Items.FindByValue(Convert.ToString(r[4]));
                        if (li != null) li.Selected = true;
                    }
                }
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message);
            }

            List<Emp> emps = new List<Emp>();
            try
            {
                if (!string.IsNullOrEmpty(empId)) emps = LoadEmployeesByIds(new[] { empId });
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message);
            }
            BindEmp(emps);
            BindList();
        }

        // ================= ডান তালিকা =================
        // ডেস্কটপ: Select * from Employe_Wise_Holiday Order By Apply_Code Desc
        void BindList()
        {
            var list = new List<Row>();
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();
                    using (var cmd = new SqlCommand("SELECT * FROM Employe_Wise_Holiday ORDER BY Apply_Code DESC", con))
                    {
                        var dt = new DataTable();
                        using (var da = new SqlDataAdapter(cmd)) da.Fill(dt);

                        foreach (DataRow r in dt.Rows)
                            list.Add(new Row
                            {
                                ApplyNo = Convert.ToString(r[0]),
                                IdNo = Convert.ToString(r[1]),
                                FromDate = ToDate(r[2]).ToString(DateFmt, CultureInfo.InvariantCulture),
                                TillDate = ToDate(r[3]).ToString(DateFmt, CultureInfo.InvariantCulture)
                            });
                    }
                }
            }
            catch (Exception ex)
            {
                Toast("List load error: " + ex.Message);
            }

            rptList.DataSource = list;
            rptList.DataBind();
            trEmpty.Visible = list.Count == 0;
            lblCount.Text = list.Count + " Records";
            litPaging.Text = list.Count == 0
                ? "Showing 0 entries"
                : "Showing <span class=\"font-medium text-slate-700\">" + list.Count + "</span> entries";
        }

        // ================= সাহায্যকারী =================
        static DateTime ToDate(object o)
        {
            if (o is DateTime) return (DateTime)o;
            DateTime d;
            return DateTime.TryParse(Convert.ToString(o), out d) ? d : DateTime.Today;
        }

        void ResetForm()
        {
            // মাল্টিপল সিলেক্ট ফিল্টার: সব সিলেকশন মোছা
            filters.ClearSelections();

            // সাধারণ ড্রপডাউন: প্রথম আইটেমে ফেরা
            foreach (var d in new[] { ddBlood, ddReligion, ddStatus, ddHoliType })
                if (d.Items.Count > 0) d.SelectedIndex = 0;

            hfApplyCode.Value = "";
            txtMultiId.Text = "";
            txtHolidayName.Text = "";
            txtFromDate.Text = DateTime.Today.ToString(InputFmt, CultureInfo.InvariantCulture);
            txtTillDate.Text = DateTime.Today.ToString(InputFmt, CultureInfo.InvariantCulture);
        }

        void Toast(string msg)
        {
            string js = "document.addEventListener('DOMContentLoaded',function(){showNotification(" +
                        new JavaScriptSerializer().Serialize(msg) + ");});";
            ClientScript.RegisterStartupScript(GetType(), "toast" + Guid.NewGuid().ToString("N"), js, true);
        }
    }
}
