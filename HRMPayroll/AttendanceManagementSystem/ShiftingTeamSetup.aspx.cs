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

namespace Nexa_ERP.HRMPayroll.AttendanceManagementSystem
{
    public partial class ShiftingTeamSetup : System.Web.UI.Page
    {
        PayrollDB conn = new PayrollDB();

        // DeductionEarningApproval / IncrementApproval পেজের মতোই ফিল্টার ক্লাস
        HRFilters filters;

        readonly List<string> loadErrors = new List<string>();

        // Search চাপার সময় ID দেওয়া থাকলে সবকটি টিক দেওয়া হবে
        bool tickAll = false;

        long UserCode { get { return HRFilters.UserCode; } }
        long FromCode { get { return HRFilters.SessionLong("From_Code", "FromCode"); } }

        // ================= Page Load (ডেক্সটপের Form_Load) =================
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
                FillStatus();
                FillTeam();
                ClearGrid();
            }

            if (IsPostBack && loadErrors.Count + filters.Errors.Count > 0)
                Toast("Option load error: " + string.Join(" | ", loadErrors.Concat(filters.Errors)));
        }

        // Status ড্রপডাউন (Statuss টেবিল: Status_Code / Status_name)
        void FillStatus()
        {
            ddStatus.Items.Clear();
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();
                    using (var cmd = new SqlCommand("SELECT Status_Code, Status_name FROM Statuss", con))
                    {
                        var dt = new DataTable();
                        using (var da = new SqlDataAdapter(cmd)) da.Fill(dt);
                        foreach (DataRow r in dt.Rows)
                            ddStatus.Items.Add(new ListItem(Convert.ToString(r["Status_name"]), Convert.ToString(r["Status_Code"])));
                    }
                }
                var active = ddStatus.Items.FindByText("Active");
                if (active != null) ddStatus.SelectedValue = active.Value;
            }
            catch (Exception ex)
            {
                loadErrors.Add("Status: " + ex.Message);
            }
        }

        // ডেক্সটপ: SELECT * FROM Team_Information → Team_Name / Team_ID
        void FillTeam()
        {
            ddTeam.Items.Clear();
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();
                    using (var cmd = new SqlCommand("SELECT Team_ID, Team_Name FROM Team_Information", con))
                    {
                        var dt = new DataTable();
                        using (var da = new SqlDataAdapter(cmd)) da.Fill(dt);
                        ddTeam.Items.Add(new ListItem("", ""));
                        foreach (DataRow r in dt.Rows)
                            ddTeam.Items.Add(new ListItem(Convert.ToString(r["Team_Name"]), Convert.ToString(r["Team_ID"])));
                    }
                }
            }
            catch (Exception ex)
            {
                loadErrors.Add("Team: " + ex.Message);
            }
        }

        // ================= Search বাটন (ডেক্সটপের button1_Click) =================
        protected void btnShow_Click(object sender, EventArgs e)
        {
            tickAll = !string.IsNullOrWhiteSpace(txtIdNo.Text);
            ShowData();
        }

        // ================= Add / Remove (ডেক্সটপের button2 / button5) =================
        protected void btnAdd_Click(object sender, EventArgs e)
        {
            ProcessAction("Pro_Employee_Wise_Team_Information", "Add Successful");
        }

        protected void btnRemove_Click(object sender, EventArgs e)
        {
            ProcessAction("Pro_Employee_Wise_Team_Information_Remove", "Remove Successful");
        }

        // দুটি বাটনের একই কাজ, শুধু stored procedure আলাদা (procName কোডের ধ্রুবক)
        void ProcessAction(string procName, string okMsg)
        {
            long teamId;
            if (!long.TryParse(ddTeam.SelectedValue, out teamId))
            {
                Toast("অনুগ্রহ করে একটি Team নির্বাচন করুন।");
                ShowData();
                return;
            }

            string[] ids = Request.Form.GetValues("selEmp");
            if (ids == null || ids.Length == 0)
            {
                Toast("Please Select Employee");
                ShowData();
                return;
            }

            int done = 0;
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();

                    foreach (string s in ids)
                    {
                        long idNo;
                        if (!long.TryParse(s, out idNo)) continue;

                        using (var cmd = new SqlCommand(procName, con))
                        {
                            cmd.CommandType = CommandType.StoredProcedure;
                            cmd.Parameters.Add("@ID_No", SqlDbType.BigInt).Value = idNo;
                            cmd.Parameters.Add("@Team_ID", SqlDbType.BigInt).Value = teamId;
                            cmd.ExecuteNonQuery();
                        }
                        done++;
                    }
                }
                Toast(okMsg + " (" + done + ")");
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message + " (processed: " + done + ")");
            }

            // তালিকা ও টিক অবস্থা যেমন ছিল তেমনই থাকবে
            ShowData();
        }

        // ================= মূল লজিক =================
        void ShowData()
        {
            string[] ids = HRFilters.ParseIds(txtIdNo.Text);
            bool anyFilter = AnyFilterSelected();

            if (ids.Length == 0 && !anyFilter)
            {
                Toast("Please Input Employee ID No");
                ClearGrid();
                return;
            }

            DataTable dt = new DataTable();
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();

                    using (var cmd = new SqlCommand())
                    {
                        cmd.Connection = con;
                        string sql = "SELECT ID_no,Name,Designation FROM View_Emp";

                        if (ids.Length > 0)
                        {
                            var names = new List<string>();
                            for (int i = 0; i < ids.Length; i++)
                            {
                                string p = "@id" + i;
                                names.Add(p);
                                cmd.Parameters.Add(p, SqlDbType.NVarChar, 50).Value = ids[i];
                            }
                            sql += " WHERE ID_no IN (" + string.Join(",", names) + ")";
                        }

                        cmd.CommandText = sql;
                        using (var da = new SqlDataAdapter(cmd)) da.Fill(dt);
                    }

                    // Branch/Dept ইত্যাদি ফিল্টার: কিছু বাছা থাকলে ওই কর্মচারীদের ID দিয়ে ছাঁটা
                    if (anyFilter)
                    {
                        if (UserCode == 0)
                        {
                            Toast("User_Code পাওয়া যায়নি (Session)। Login করে আবার চেষ্টা করুন।");
                            return;
                        }

                        filters.SaveSelections(con, UserCode, FromCode);
                        HashSet<string> allowed = FilteredEmployeeIds(con);

                        string idCol = new[] { "ID_no", "ID_No" }.FirstOrDefault(c => dt.Columns.Contains(c));
                        if (idCol != null)
                        {
                            var rows = dt.AsEnumerable().Where(r => allowed.Contains(Convert.ToString(r[idCol]).Trim())).ToList();
                            dt = rows.Count > 0 ? rows.CopyToDataTable() : dt.Clone();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message);
                return;
            }

            rptEmp.DataSource = dt;
            rptEmp.DataBind();
            trEmpty.Visible = dt.Rows.Count == 0;
            lblCount.Text = dt.Rows.Count + " Records";

            if (dt.Rows.Count > 0 && tickAll)
            {
                ClientScript.RegisterStartupScript(GetType(), "chkall",
                    "document.addEventListener('DOMContentLoaded',function(){setAll(true);});", true);
            }
        }

        // ফিল্টার বক্সে কিছু বাছা হয়েছে কি না
        bool AnyFilterSelected()
        {
            var boxes = new[] { ddBranch, ddCategory, ddDept, ddSection, ddSubSec, ddFloor, ddDesig, ddLevel };
            return boxes.Any(b => b.Items.Cast<ListItem>().Any(i => i.Selected));
        }

        // Pro_Employee_View_N_All চালিয়ে ফিল্টার-মেলানো কর্মচারীদের ID তালিকা
        // Employee_Status = ড্রপডাউনে বাছা Status (যেমন Active)
        HashSet<string> FilteredEmployeeIds(SqlConnection con)
        {
            var set = new HashSet<string>();
            string status = ddStatus.SelectedItem != null ? ddStatus.SelectedItem.Text : "All";

            using (var cmd = new SqlCommand("Pro_Employee_View_N_All", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandTimeout = 120;
                cmd.Parameters.AddWithValue("@Employee_Status", status);
                cmd.Parameters.AddWithValue("@from_Date", "1900-01-01");
                cmd.Parameters.AddWithValue("@till_Date", DateTime.Today.ToString("yyyy-MM-dd"));
                cmd.Parameters.AddWithValue("@User_Code", UserCode.ToString());
                cmd.Parameters.AddWithValue("@From_Code", FromCode.ToString());

                var dt = new DataTable();
                using (var rd = cmd.ExecuteReader()) dt.Load(rd);

                string col = new[] { "ID_no", "Id", "Emp_ID" }.FirstOrDefault(c => dt.Columns.Contains(c));
                if (col != null)
                    foreach (DataRow r in dt.Rows)
                        set.Add(Convert.ToString(r[col]).Trim());
            }
            return set;
        }

        // ---------- Repeater helper: কলামের নাম না মিললেও পেজ ভাঙবে না ----------
        protected string Get(object item, params string[] names)
        {
            var drv = item as DataRowView;
            if (drv == null) return "";
            foreach (string n in names)
                if (drv.Row.Table.Columns.Contains(n))
                    return Convert.ToString(drv[n]);
            return "";
        }

        // আগের পোস্টে টিক দেওয়া ID গুলো আবার টিক দেখানো
        protected string IsChecked(object item)
        {
            string[] sel = Request.Form.GetValues("selEmp");
            if (sel == null) return "";
            string id = Get(item, "ID_no", "ID_No").Trim();
            return sel.Contains(id) ? "checked" : "";
        }

        void ClearGrid()
        {
            rptEmp.DataSource = null;
            rptEmp.DataBind();
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