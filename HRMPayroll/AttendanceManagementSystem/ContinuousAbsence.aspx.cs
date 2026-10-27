using Nexa_ERP.Connection;
using Nexa_ERP.HRMPayroll.Common;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.HRMPayroll.AttendanceManagementSystem
{
    public partial class ContinuousAbsence : System.Web.UI.Page
    {
        PayrollDB conn = new PayrollDB();
        HRFilters filters;

        const int MaxIds = HRFilters.MaxIds;
        readonly List<string> loadErrors = new List<string>();

        // ======== আপনার ডাটাবেস অনুযায়ী এই ৪টি মান ঠিক করে নিন ========
        const long PageFormCode = 20;                                  // এই পেজের From_Code (z_Test_ID / filter save এ ব্যবহৃত)
        const string ProcView = "Pro_Continuous_Absence_View";         // Show এর stored procedure
        const string ProcDeletePunch = "Pro_Delete_Punch";             // Delete Punch এর stored procedure
        const string ListViewPage = "HRReports/ContinuousAbsenceList.aspx"; // List View রিপোর্ট পেজ
        // ===============================================================

        public class Emp
        {
            public string Id { get; set; }
            public string Name { get; set; }
            public string Designation { get; set; }
        }

        long UserCode { get { return HRFilters.UserCode; } }

        List<string> AllErrors()
        {
            return loadErrors.Concat(filters.Errors).ToList();
        }

        // ================= Page Load =================
        protected void Page_Load(object sender, EventArgs e)
        {
            filters = new HRFilters()
                .Attach(HRFilters.Category, ddCategory)
                .Attach(HRFilters.Dept, ddDept)
                .Attach(HRFilters.Section, ddSection)
                .Attach(HRFilters.SubSec, ddSubSec)
                .Attach(HRFilters.Desig, ddDesig);
            filters.EmptyMeansAll = false;   // HRMReports এর মতোই

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
                FillDropDowns();
                ResetDefaults();
                ClearGrid();
            }

            if (IsPostBack && AllErrors().Count > 0)
                Toast("Option load error: " + string.Join(" | ", AllErrors()));
        }

        void FillDropDowns()
        {
            filters.FillControls();

            ddStatus.Items.Clear();
            foreach (string s in new[] { "Active", "New", "Seperation", "All", "Resign", "Left" })
                ddStatus.Items.Add(new ListItem(s, s));
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

        // Refresh: ড্রপডাউন আবার লোড, গ্রিড পরিষ্কার
        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            FillDropDowns();
            ResetDefaults();
            ClearGrid();
            Toast("Refreshed.");
        }

        // টিক দেওয়া ID গুলো: প্রথমে চেকবক্সের name="selId", না পেলে hfSelIds
        string SelectedIdsRaw()
        {
            string[] fromForm = Request.Form.GetValues("selId");
            if (fromForm != null && fromForm.Length > 0)
                return string.Join(",", fromForm);
            return hfSelIds.Value ?? "";
        }

        long[] SelectedIds()
        {
            return HRFilters.ParseIds(SelectedIdsRaw())
                .Select(s => { long x; return long.TryParse(s, out x) ? x : 0; })
                .Where(x => x != 0).Distinct().ToArray();
        }

        // List View: নির্বাচিত ID z_Test_ID তে সেভ করে রিপোর্ট পেজ খোলা (নতুন ট্যাবে)
        protected void btnListView_Click(object sender, EventArgs e)
        {
            if (UserCode == 0)
            {
                Toast("User_Code পাওয়া যায়নি (Session)। Login করে আবার চেষ্টা করুন।");
                return;
            }

            long[] ids = SelectedIds();
            if (ids.Length == 0) { Toast("কমপক্ষে একজন কর্মচারী নির্বাচন করুন।"); return; }
            if (ids.Length > MaxIds) { Toast("Too many IDs (max " + MaxIds + ")."); return; }

            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();

                    using (var del = new SqlCommand(
                        "DELETE FROM dbo.z_Test_ID WHERE User_ID=@u AND From_Code=@f", con))
                    {
                        del.Parameters.Add("@u", SqlDbType.BigInt).Value = UserCode;
                        del.Parameters.Add("@f", SqlDbType.BigInt).Value = PageFormCode;
                        del.ExecuteNonQuery();
                    }

                    foreach (long id in ids)
                        HRDb.ExecProc(con, "Pro_z_Test_ID_New",
                            HRDb.P("@ID_No", id), HRDb.P("@User_ID", UserCode), HRDb.P("@Form_Code", (int)PageFormCode));
                }
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message);
                return;
            }

            Response.Redirect(ListViewPage, false);
            Context.ApplicationInstance.CompleteRequest();
        }

        // Delete Punch: নির্বাচিত কর্মচারীদের From–To তারিখের Punch মোছা
        protected void btnDeletePunch_Click(object sender, EventArgs e)
        {
            long[] ids = SelectedIds();
            if (ids.Length == 0) { Toast("কমপক্ষে একজন কর্মচারী নির্বাচন করুন।"); return; }

            DateTime from, to;
            if (!DateTime.TryParse(txtFromDate.Text, out from) || !DateTime.TryParse(txtToDate.Text, out to))
            {
                Toast("From Date ও To Date সঠিকভাবে দিন।");
                return;
            }

            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();

                    foreach (long id in ids)
                    {
                        using (var cmd = new SqlCommand(ProcDeletePunch, con))
                        {
                            cmd.CommandType = CommandType.StoredProcedure;
                            cmd.Parameters.Add("@ID_No", SqlDbType.BigInt).Value = id;
                            cmd.Parameters.Add("@From_Date", SqlDbType.Date).Value = from.Date;
                            cmd.Parameters.Add("@To_Date", SqlDbType.Date).Value = to.Date;
                            cmd.ExecuteNonQuery();
                        }
                    }
                }
                Toast("Punch deleted for " + ids.Length + " employee(s).");
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message);
            }
        }

        // ================= Show এর মূল লজিক =================
        bool ShowData()
        {
            if (UserCode == 0)
            {
                Toast("User_Code পাওয়া যায়নি (Session)। Login করে আবার চেষ্টা করুন।");
                return false;
            }

            DataTable dt;
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();

                    // ফিল্টারের নির্বাচন সেভ (HRMReports এর মতোই)
                    filters.SaveSelections(con, UserCode, PageFormCode);

                    dt = RunViewProc(con);
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

        DataTable RunViewProc(SqlConnection con)
        {
            string status = string.IsNullOrEmpty(ddStatus.SelectedValue) ? "Active" : ddStatus.SelectedValue;
            string from = string.IsNullOrWhiteSpace(txtFromDate.Text) ? DateTime.Today.ToString("yyyy-MM-dd") : txtFromDate.Text.Trim();
            string to = string.IsNullOrWhiteSpace(txtToDate.Text) ? DateTime.Today.ToString("yyyy-MM-dd") : txtToDate.Text.Trim();

            int days;
            if (!int.TryParse(txtDays.Text, out days)) days = 0;

            using (var cmd = new SqlCommand(ProcView, con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandTimeout = 120;
                cmd.Parameters.AddWithValue("@Employee_Status", status);
                cmd.Parameters.AddWithValue("@from_Date", from);
                cmd.Parameters.AddWithValue("@to_Date", to);
                cmd.Parameters.AddWithValue("@Days", days);
                cmd.Parameters.AddWithValue("@User_Code", UserCode.ToString());
                cmd.Parameters.AddWithValue("@From_Code", PageFormCode.ToString());

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
            litPaging.Text = list.Count == 0
                ? "Showing 0 entries"
                : "Showing <span class=\"font-medium text-slate-700\">" + list.Count + "</span> entries";
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

            hfSelIds.Value = "";
            txtFromDate.Text = txtToDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
            txtDays.Text = "";
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
