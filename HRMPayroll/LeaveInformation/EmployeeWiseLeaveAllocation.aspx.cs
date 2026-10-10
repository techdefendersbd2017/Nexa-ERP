using Nexa_ERP.Connection;
using Nexa_ERP.HRMPayroll.Common;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.HRMPayroll.LeaveInformation
{
    public partial class EmployeeWiseLeaveAllocation : Page
    {
        PayrollDB conn = new PayrollDB();

        // HRM Reports এর মতই ফিল্টার ক্লাস (HRFilters অপরিবর্তিত)
        HRFilters filters;

        const int MaxIds = HRFilters.MaxIds;

        readonly List<string> loadErrors = new List<string>();

        // ---------- মডেল ----------
        public class Emp
        {
            public string Id { get; set; }
            public string Name { get; set; }
            public string Designation { get; set; }
            public string Department { get; set; }
            public string Branch { get; set; }
            public string Status { get; set; }
        }

        long UserCode { get { return HRFilters.UserCode; } }
        long FromCode { get { return HRFilters.SessionLong("From_Code", "FromCode"); } }

        List<string> AllErrors()
        {
            return loadErrors.Concat(filters.Errors).ToList();
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
            filters.EmptyMeansAll = false;   // কিছু না বাছলে কিছুই insert হবে না

            filters.LoadLookups();

            // পোস্টব্যাকের পর আগের টিক ফিরিয়ে আনা
            if (IsPostBack && !string.IsNullOrEmpty(SelectedIdsRaw()))
            {
                string arr = new JavaScriptSerializer().Serialize(SelectedIdsRaw().Split(','));
                ClientScript.RegisterStartupScript(GetType(), "retick",
                    "document.addEventListener('DOMContentLoaded',function(){var ids=" + arr +
                    ";document.querySelectorAll('.row-checkbox').forEach(function(c){" +
                    "if(ids.indexOf(c.getAttribute('data-id'))>=0)c.checked=true;});updateSelCount();});", true);
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

        void FillDropDowns()
        {
            filters.FillControls();   // Branch, Category, Dept ... সব ভরে দেয়

            FillStatic(ddStatus, null, "Active", "New", "Seperation", "All", "Resign", "Left");

            // Years: গত বছর থেকে আগামী বছর পর্যন্ত
            ddYear.Items.Clear();
            int y = DateTime.Today.Year;
            for (int i = y - 1; i <= y + 1; i++)
                ddYear.Items.Add(new ListItem(i.ToString(), i.ToString()));

            LoadLeaves();

            if (AllErrors().Count > 0)
                Toast("Option load error: " + string.Join(" | ", AllErrors()));
        }

        // Desktop এর Leave_Name_List: Text = Leave_Name, Value = Leave_code
        void LoadLeaves()
        {
            ddLeave.Items.Clear();
            ddLeave.Items.Add(new ListItem("-- Select --", ""));
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();
                    using (var cmd = new SqlCommand("SELECT Leave_Name, Leave_code FROM Leave_Name_List", con))
                    {
                        var dt = new DataTable();
                        using (var da = new SqlDataAdapter(cmd)) da.Fill(dt);
                        foreach (DataRow r in dt.Rows)
                        {
                            string name = Convert.ToString(r["Leave_Name"]);
                            if (string.IsNullOrWhiteSpace(name)) continue;
                            ddLeave.Items.Add(new ListItem(name.Trim(), Convert.ToString(r["Leave_code"])));
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                loadErrors.Add("leave: " + ex.Message);
            }
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
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ResetDefaults();
            ClearGrid();
            Toast("All filters cleared.");
        }

        // টিক দেওয়া ID গুলো: প্রথমে চেকবক্সের name="selId", না পেলে hfSelIds
        string SelectedIdsRaw()
        {
            string[] fromForm = Request.Form.GetValues("selId");
            if (fromForm != null && fromForm.Length > 0)
                return string.Join(",", fromForm);
            return hfSelIds.Value ?? "";
        }

        // ================= Leave Process (Desktop: button1_Click) =================
        protected void btnProcess_Click(object sender, EventArgs e)
        {
            long[] ids = HRFilters.ParseIds(SelectedIdsRaw())
                .Select(s => { long x; return long.TryParse(s, out x) ? x : 0; })
                .Where(x => x != 0).Distinct().ToArray();

            if (ids.Length == 0)
            {
                Toast("Please select at least one employee.");
                return;
            }
            if (ids.Length > MaxIds)
            {
                Toast("Too many IDs (max " + MaxIds + ").");
                return;
            }

            long leaveCode, year;
            if (!long.TryParse(ddLeave.SelectedValue, out leaveCode))
            {
                Toast("Please select Leave.");
                return;
            }
            if (!long.TryParse(ddYear.SelectedValue, out year))
            {
                Toast("Please select Year.");
                return;
            }

            int done = 0;
            long current = 0;
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();

                    foreach (long id in ids)
                    {
                        current = id;
                        HRDb.ExecProc(con, "Pro_Leave_process",
                            HRDb.P("@ID_No", id),
                            HRDb.P("@Leave_Code", leaveCode),
                            HRDb.P("@Years", year));
                        done++;
                    }
                }
            }
            catch (Exception ex)
            {
                Toast("Error at ID " + current + " (processed " + done + " of " + ids.Length + "): " + ex.Message);
                return;
            }

            Toast("Leave process completed for " + done + " employee(s).");
        }

        // ================= Search এর মূল লজিক (HRM Reports এর ShowData) =================
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
                        filters.SaveSelections(con, UserCode, FromCode);

                        dt = RunStatusProc(con, status);
                    }
                }
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message);
                return false;
            }

            BindTable(dt, status);
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
        void BindTable(DataTable dt, string status)
        {
            var list = new List<Emp>();
            foreach (DataRow r in dt.Rows)
            {
                list.Add(new Emp
                {
                    Id = Col(r, "", "ID_no", "Id", "Emp_ID"),
                    Name = Col(r, "", "Name", "Emp_Name"),
                    Designation = Col(r, "", "Designation", "Desigation_name"),
                    Department = Col(r, "", "Department", "Department_Name"),
                    Branch = Col(r, "", "Branch", "Branch_Name"),
                    Status = Col(r, status, "Resign_Status", "Status", "Employee_Status")
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

            // Desktop এর মতো Search এর পর সবাই টিক দেওয়া অবস্থায় আসে
            if (list.Count > 0)
            {
                ClientScript.RegisterStartupScript(GetType(), "chkall",
                    "document.addEventListener('DOMContentLoaded',function(){document.querySelectorAll('.row-checkbox,#selectAllRows').forEach(function(c){c.checked=true;});updateSelCount();});", true);
            }
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
            filters.ClearSelections();

            if (ddStatus.Items.Count > 0) ddStatus.SelectedIndex = 0;
            if (ddLeave.Items.Count > 0) ddLeave.SelectedIndex = 0;

            ListItem cur = ddYear.Items.FindByValue(DateTime.Today.Year.ToString());
            if (cur != null) { ddYear.ClearSelection(); cur.Selected = true; }

            hfSelIds.Value = "";
            txtFromDate.Text = txtTillDate.Text = txtMultiId.Text = "";
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
