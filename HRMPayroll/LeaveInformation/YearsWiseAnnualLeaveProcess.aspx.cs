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

namespace Nexa_ERP.HRMPayroll.LeaveInformation
{
    public partial class YearsWiseAnnualLeaveProcess : System.Web.UI.Page
    {
        PayrollDB conn = new PayrollDB();
        HRFilters filters;

        const int MaxIds = HRFilters.MaxIds;
        readonly List<string> loadErrors = new List<string>();

        // Desktop এর label15 (User_Code) ও label19 (From_Code) এর জায়গায় Session থেকে
        long UserCode { get { return HRFilters.UserCode; } }
        long FromCode { get { return HRFilters.SessionLong("From_Code", "FromCode"); } }

        List<string> AllErrors()
        {
            return loadErrors.Concat(filters.Errors).ToList();
        }

        // ================= Page Load =================
        protected void Page_Load(object sender, EventArgs e)
        {
            // Desktop এর ৫টি ফিল্টার: Category, Department, Section, Sub Section (Line), Designation
            filters = new HRFilters()
                .Attach(HRFilters.Category, ddCategory)
                .Attach(HRFilters.Dept, ddDept)
                .Attach(HRFilters.Section, ddSection)
                .Attach(HRFilters.SubSec, ddSubSec)
                .Attach(HRFilters.Desig, ddDesig);
            filters.EmptyMeansAll = false;   // কিছু না বাছলে কিছুই insert হবে না
            filters.LoadLookups();

            // পোস্টব্যাকের পর আগের টিক ফিরিয়ে আনা
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
                filters.FillControls();
                LoadEmployeeStatus();
                ResetDefaults();
                ClearGrid();
            }

            if (AllErrors().Count > 0)
                Toast("Option load error: " + string.Join(" | ", AllErrors()));
        }

        // Desktop: SELECT * FROM Seperation_Status → Seperation_Name / Seperation_Code
        void LoadEmployeeStatus()
        {
            ddlEmployeeStatus.Items.Clear();
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();

                    var dt = new DataTable();
                    using (var da = new SqlDataAdapter("SELECT * FROM Seperation_Status", con)) da.Fill(dt);

                    foreach (DataRow r in dt.Rows)
                        ddlEmployeeStatus.Items.Add(new ListItem(
                            Convert.ToString(r["Seperation_Name"]).Trim(),
                            Convert.ToString(r["Seperation_Code"])));
                }
            }
            catch (Exception ex)
            {
                loadErrors.Add("employeeStatus: " + ex.Message);
            }
        }

        // ================= বাটন ইভেন্ট =================
        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            LoadEmployeeStatus();
            ClearGrid();
        }

        protected void btnShow_Click(object sender, EventArgs e)
        {
            ShowData();
        }

        // Desktop এর button2_Click: টিক দেওয়া প্রত্যেক ID এর জন্য Pro_Annul_Leave_SummaryYear_Wise
        protected void btnProcess_Click(object sender, EventArgs e)
        {
            DateTime from, till;
            if (!TryDate(txtFromDate.Text, out from) || !TryDate(txtTillDate.Text, out till))
            {
                Toast("From ও Till তারিখ সঠিকভাবে দিন।");
                return;
            }

            long[] ids = HRFilters.ParseIds(SelectedIdsRaw())
                .Select(s => { long x; return long.TryParse(s, out x) ? x : 0; })
                .Where(x => x != 0).Distinct().ToArray();

            if (ids.Length == 0)
            {
                Toast("কমপক্ষে একজন কর্মচারী নির্বাচন করুন।");
                return;
            }

            int done = 0;
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();

                    foreach (long id in ids)
                    {
                        using (var cmd = new SqlCommand("Pro_Annul_Leave_SummaryYear_Wise", con))
                        {
                            cmd.CommandType = CommandType.StoredProcedure;
                            cmd.CommandTimeout = 120;
                            cmd.Parameters.Add("@ID_No", SqlDbType.BigInt).Value = id;
                            cmd.Parameters.Add("@from_Date", SqlDbType.DateTime).Value = from;
                            cmd.Parameters.Add("@from_Till", SqlDbType.DateTime).Value = till;
                            cmd.ExecuteNonQuery();
                            done++;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message + (done > 0 ? " (" + done + " জন আগে সম্পন্ন হয়েছে)" : ""));
                return;
            }

            Toast("Done (" + done + " employee processed)");
        }

        // ================= Show এর মূল লজিক (Desktop এর button1_Click) =================
        bool ShowData()
        {
            DataTable dt;
            string status = ddlEmployeeStatus.SelectedItem != null ? ddlEmployeeStatus.SelectedItem.Text.Trim() : "Active";

            try
            {
                string[] ids = HRFilters.ParseIds(txtMultiIdNo.Text);

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
                        // Multi ID No দেওয়া থাকলে সরাসরি View_Emp থেকে
                        dt = QueryByIds(con, ids, status);
                    }
                    else
                    {
                        if (UserCode == 0)
                        {
                            Toast("User_Code পাওয়া যায়নি (Session)। Login করে আবার চেষ্টা করুন।");
                            return false;
                        }

                        // Category/Department/Section/Sub Section/Designation এর নির্বাচন সেভ
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

                string sql = "SELECT ID_no, Name, Designation FROM View_Emp WHERE ID_no IN (" + string.Join(",", names) + ")";
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

        // Desktop এর Active / New / Seperation / All / অন্যান্য ধরনের Stored Procedure
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
            string till = string.IsNullOrWhiteSpace(txtTillDate.Text) ? DateTime.Today.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture) : txtTillDate.Text.Trim();

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
        public class Emp
        {
            public string Id { get; set; }
            public string Name { get; set; }
            public string Designation { get; set; }
        }

        void BindTable(DataTable dt)
        {
            var list = new List<Emp>();
            foreach (DataRow r in dt.Rows)
            {
                list.Add(new Emp
                {
                    Id = Col(r, "ID_no", "Id", "Emp_ID"),
                    Name = Col(r, "Name", "Emp_Name"),
                    Designation = Col(r, "Designation", "Desigation_name")
                });
            }

            rptEmployees.DataSource = list;
            rptEmployees.DataBind();
            trEmpty.Visible = list.Count == 0;
            lblCount.Text = list.Count + " Records";

            // Desktop এর মতো Show এর পর সব সারি টিক দেওয়া
            if (list.Count > 0)
            {
                ClientScript.RegisterStartupScript(GetType(), "chkall",
                    "document.addEventListener('DOMContentLoaded',function(){document.querySelectorAll('.row-checkbox,#selectAllRows').forEach(function(c){c.checked=true;});});", true);
            }
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

        // ================= সাহায্যকারী =================
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
            return DateTime.TryParseExact((s ?? "").Trim(), "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out d);
        }

        void ResetDefaults()
        {
            filters.ClearSelections();
            hfSelIds.Value = "";
            txtMultiIdNo.Text = "";

            // Desktop এর DateTimePicker এর মতো ডিফল্ট আজকের তারিখ
            string today = DateTime.Today.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
            txtFromDate.Text = today;
            txtTillDate.Text = today;

            if (ddlEmployeeStatus.Items.Count > 0) ddlEmployeeStatus.SelectedIndex = 0;
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