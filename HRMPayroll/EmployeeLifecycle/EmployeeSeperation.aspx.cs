using Nexa_ERP.Connection;
using Nexa_ERP.HRMPayroll.Common;      // HRFilters ক্লাস
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.HRMPayroll.EmployeeLifecycle
{
    public partial class EmployeeSeperation : Page
    {
        PayrollDB conn = new PayrollDB();

        HRFilters filters;

        const int MaxIds = HRFilters.MaxIds;

        readonly List<string> loadErrors = new List<string>();

        // সমস্যা মিটে গেলে false করে দিন
        const bool ShowDebug = true;
        readonly List<string> debug = new List<string>();

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

        // aspx এর ঘরগুলোর অর্থ (ID বদলাননি, তাই নাম দিয়ে চেনা সহজ করা হলো)
        TextBox ApplicationDateBox { get { return TextBox1; } }   // Application Date
        TextBox ResignDateBox { get { return TextBox2; } }        // Resign Date

        string StatusText()
        {
            return ddStatus.SelectedItem != null ? ddStatus.SelectedItem.Text.Trim() : "";
        }

        static bool IsActive(string s) { return string.Equals(s, "Active", StringComparison.OrdinalIgnoreCase); }
        static bool IsAll(string s) { return string.Equals(s, "All", StringComparison.OrdinalIgnoreCase); }

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
                ClearGrid();
            }

            if (IsPostBack && AllErrors().Count > 0)
                Toast("Option load error: " + string.Join(" | ", AllErrors()));
        }

        void FillDropDowns()
        {
            filters.FillControls();

            LoadStatusInto(ddStatus, true);     // Active, All + Seperation তালিকা (খোঁজার জন্য)
            LoadStatusInto(toddStatus, false);  // শুধু Seperation তালিকা (Save এর নতুন Status, ডেক্সটপের comboBox1 এর মতো)

            if (AllErrors().Count > 0)
                Toast("Option load error: " + string.Join(" | ", AllErrors()));
        }

        // withActiveAll = true  : Active, All + Seperation_Status
        // withActiveAll = false : শুধু Seperation_Status (Value = Seperation_Code, সংখ্যা)
        void LoadStatusInto(DropDownList target, bool withActiveAll)
        {
            target.Items.Clear();
            if (withActiveAll)
            {
                target.Items.Add(new ListItem("Active", "1"));
                target.Items.Add(new ListItem("All", "7"));
            }

            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();

                    using (var cmd = new SqlCommand(
                        "SELECT Seperation_Code, Seperation_Name FROM Seperation_Status " +
                        "ORDER BY Seperation_Code ASC", con))
                    {
                        var dt = new DataTable();
                        using (var da = new SqlDataAdapter(cmd)) da.Fill(dt);

                        foreach (DataRow r in dt.Rows)
                        {
                            string name = Convert.ToString(r["Seperation_Name"]);
                            if (string.IsNullOrWhiteSpace(name)) continue;
                            name = name.Trim();

                            if (IsActive(name) || IsAll(name)) continue;

                            target.Items.Add(new ListItem(name, Convert.ToString(r["Seperation_Code"])));
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                loadErrors.Add("status(" + target.ID + "): " + ex.Message);
            }
        }

        // ================= বাটন ইভেন্ট =================
        protected void btnShow_Click(object sender, EventArgs e)
        {
            ShowData();
        }

        // ================= Save (ডেক্সটপের কোডের মতো) =================
        // টিক দেওয়া প্রতিটি কর্মচারীর জন্য Pro_Employee_Seperation_Information চালায়
        protected void btnReport_Click(object sender, EventArgs e)
        {
            // ১) টিক দেওয়া ID
            long[] ids = HRFilters.ParseIds(SelectedIdsRaw())
                .Select(s => { long x; return long.TryParse(s, out x) ? x : 0; })
                .Where(x => x != 0).Distinct().ToArray();

            if (ids.Length == 0)
            {
                Toast("কমপক্ষে একজন কর্মচারী নির্বাচন করুন।");
                return;
            }
            if (ids.Length > MaxIds)
            {
                Toast("Too many IDs (max " + MaxIds + ").");
                return;
            }

            // ২) To Employee Status (ডেক্সটপের comboBox1.SelectedValue)
            long statusCode;
            if (toddStatus.SelectedItem == null || !long.TryParse(toddStatus.SelectedValue, out statusCode))
            {
                Toast("To Employee Status নির্বাচন করুন।");
                return;
            }

            // ৩) Resign Date (বাধ্যতামূলক)
            DateTime resignDate;
            if (!DateTime.TryParse(ResignDateBox.Text, out resignDate))
            {
                Toast("Resign Date দিন।");
                return;
            }

            // ৪) Application Date (ঐচ্ছিক; খালি থাকলে NULL যাবে)
            DateTime appDate;
            bool hasAppDate = DateTime.TryParse(ApplicationDateBox.Text, out appDate);

            // ৫) সব একটি transaction এ: কোনো একটি ব্যর্থ হলে কিছুই সেভ হয় না
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
                                using (var cmd = new SqlCommand("Pro_Employee_Seperation_Information_Web", con, tx))
                                {
                                    cmd.CommandType = CommandType.StoredProcedure;

                                    cmd.Parameters.Add("@ID_No", SqlDbType.BigInt).Value = id;
                                    cmd.Parameters.Add("@Resign_Status", SqlDbType.BigInt).Value = statusCode;
                                    cmd.Parameters.Add("@Resign_Date", SqlDbType.Date).Value = resignDate.Date;
                                    cmd.Parameters.Add("@Application_Date", SqlDbType.Date).Value =
                                        hasAppDate ? (object)appDate.Date : DBNull.Value;

                                    cmd.ExecuteNonQuery();
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
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message);
                return;
            }

            Toast("Save Successfull (" + ids.Length + " জন)");

            // তালিকা নতুন Status সহ রিফ্রেশ
            ShowData();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            filters.ClearSelections();
            foreach (var d in new[] { ddStatus, toddStatus })
                if (d.Items.Count > 0) d.SelectedIndex = 0;

            hfSelIds.Value = "";
            txtFromDate.Text = txtTillDate.Text = txtMultiId.Text = "";
            ApplicationDateBox.Text = ResignDateBox.Text = "";
            ClearGrid();
            Toast("All filters cleared.");
        }

        // টিক দেওয়া ID গুলো
        string SelectedIdsRaw()
        {
            string[] fromForm = Request.Form.GetValues("selId");
            if (fromForm != null && fromForm.Length > 0)
                return string.Join(",", fromForm);
            return hfSelIds.Value ?? "";
        }

        // ================= Show এর মূল লজিক (প্রসিডিউর ছাড়া) =================
        bool ShowData()
        {
            DataTable dt;
            string status = StatusText();

            if (string.IsNullOrEmpty(status))
            {
                Toast("একটি Status নির্বাচন করুন।");
                return false;
            }

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

                    dt = filters.QueryEmployees(con, status, txtFromDate.Text, txtTillDate.Text, ids, debug);
                    debug.Add("status=" + status + ", byIds=" + (ids.Length > 0) + ", rows=" + dt.Rows.Count);
                }
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message);
                return false;
            }

            if (ShowDebug && debug.Count > 0)
                Toast("Debug → " + string.Join(", ", debug));

            BindTable(dt, status);
            return true;
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
                    Status = Col(r, "", "Resign_Status", "Status", "Employee_Status")
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

            if (list.Count > 0)
            {
                ClientScript.RegisterStartupScript(GetType(), "chkall",
                    "document.addEventListener('DOMContentLoaded',function(){document.querySelectorAll('.row-checkbox,#selectAllRows').forEach(function(c){c.checked=true;});});", true);
            }
        }

        void ClearGrid()
        {
            rptEmployees.DataSource = null;
            rptEmployees.DataBind();
            trEmpty.Visible = false;
            lblCount.Text = "0 Records";
            litPaging.Text = "Showing 0 entries";
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
        void Toast(string msg)
        {
            string js = "document.addEventListener('DOMContentLoaded',function(){showNotification(" +
                        new JavaScriptSerializer().Serialize(msg) + ");});";
            ClientScript.RegisterStartupScript(GetType(), "toast" + Guid.NewGuid().ToString("N"), js, true);
        }
    }
}