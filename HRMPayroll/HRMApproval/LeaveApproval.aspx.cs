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
    public partial class LeaveApproval : System.Web.UI.Page
    {
        PayrollDB conn = new PayrollDB();

        // Attendance_Reports পেজের মতোই ফিল্টার ক্লাস
        HRFilters filters;

        readonly List<string> loadErrors = new List<string>();

        long UserCode { get { return HRFilters.UserCode; } }
        long FromCode { get { return HRFilters.SessionLong("From_Code", "FromCode"); } }

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

                // ডেক্সটপ: comboBox1 = Status_ID in (1,2,3), comboBox2 = Status_ID in (2,3,4)
                FillStatus(ddStatus, "1,2,3");
                FillStatus(ddAction, "2,3,4");

                txtMonth.Text = DateTime.Today.ToString("yyyy-MM", CultureInfo.InvariantCulture);
                ClearGrid();
            }

            if (IsPostBack && loadErrors.Count + filters.Errors.Count > 0)
                Toast("Option load error: " + string.Join(" | ", loadErrors.Concat(filters.Errors)));
        }

        // Leave_Status থেকে ড্রপডাউন ভরা (Text = Status_name, Value = Status_ID)
        void FillStatus(DropDownList dd, string idList)
        {
            dd.Items.Clear();
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();

                    // idList কোডের ভেতরের ধ্রুবক (ব্যবহারকারীর ইনপুট নয়), তাই নিরাপদ
                    using (var cmd = new SqlCommand("SELECT Status_ID, Status_name FROM Leave_Status WHERE Status_ID IN (" + idList + ")", con))
                    {
                        var dt = new DataTable();
                        using (var da = new SqlDataAdapter(cmd)) da.Fill(dt);
                        foreach (DataRow r in dt.Rows)
                            dd.Items.Add(new ListItem(Convert.ToString(r["Status_name"]), Convert.ToString(r["Status_ID"])));
                    }
                }
            }
            catch (Exception ex)
            {
                loadErrors.Add("leaveStatus: " + ex.Message);
            }
        }

        // ================= Show বাটন =================
        protected void btnShow_Click(object sender, EventArgs e)
        {
            ShowData(true);
        }

        // ================= Ok বাটন (ডেক্সটপের button2_Click) =================
        protected void btnOk_Click(object sender, EventArgs e)
        {
            string[] applyNos = Request.Form.GetValues("selId");
            if (applyNos == null || applyNos.Length == 0)
            {
                Toast("কমপক্ষে একটি আবেদন নির্বাচন করুন।");
                return;
            }

            long mode;
            if (!long.TryParse(ddAction.SelectedValue, out mode))
            {
                Toast("অ্যাকশন (Status) নির্বাচন করুন।");
                return;
            }

            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();

                    foreach (string s in applyNos)
                    {
                        long applyNo;
                        if (!long.TryParse(s, out applyNo)) continue;

                        using (var cmd = new SqlCommand("Pro_Leave_Appliction_Confirm", con))
                        {
                            cmd.CommandType = CommandType.StoredProcedure;
                            cmd.Parameters.Add("@Apply_No", SqlDbType.BigInt).Value = applyNo;
                            cmd.Parameters.Add("@operation_mode", SqlDbType.BigInt).Value = mode;
                            cmd.ExecuteNonQuery();
                        }
                    }
                }
                Toast("Process Successful");
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message);
                return;
            }

            // ডেক্সটপের মতো: প্রসেসের পর আবার তালিকা লোড (এবার মাস ধরে নয়, শুধু ID ও Status ধরে)
            ShowData(false);
        }

        // ================= মূল লজিক =================
        // useMonth = true হলে Effective Month দিয়ে ফিল্টার (ডেক্সটপের Show বাটন)
        void ShowData(bool useMonth)
        {
            DataTable dt;
            try
            {
                string[] ids = HRFilters.ParseIds(txtIdNo.Text);

                // ১) ডেক্সটপের কোয়েরি, তবে প্যারামিটার সহ
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();

                    using (var cmd = new SqlCommand())
                    {
                        cmd.Connection = con;
                        string sql = "SELECT Apply_No,ID_no,Name,Designation,Section,Leave_Name,From_Date,Till_Date,Apply_Days,Status_name " +
                                     "FROM View_Leave_App WHERE Status=@st";
                        cmd.Parameters.Add("@st", SqlDbType.NVarChar, 20).Value = ddStatus.SelectedValue;

                        if (ids.Length > 0)
                        {
                            var names = new List<string>();
                            for (int i = 0; i < ids.Length; i++)
                            {
                                string p = "@id" + i;
                                names.Add(p);
                                cmd.Parameters.Add(p, SqlDbType.NVarChar, 50).Value = ids[i];
                            }
                            sql += " AND ID_no IN (" + string.Join(",", names) + ")";
                        }

                        DateTime month;
                        if (useMonth && DateTime.TryParseExact(txtMonth.Text.Trim(), "yyyy-MM",
                                CultureInfo.InvariantCulture, DateTimeStyles.None, out month))
                        {
                            sql += " AND DATEPART(MONTH,From_Date)=@m AND DATEPART(YEAR,From_Date)=@y";
                            cmd.Parameters.Add("@m", SqlDbType.Int).Value = month.Month;
                            cmd.Parameters.Add("@y", SqlDbType.Int).Value = month.Year;
                        }

                        cmd.CommandText = sql;
                        dt = new DataTable();
                        using (var da = new SqlDataAdapter(cmd)) da.Fill(dt);
                    }

                    // ২) Branch/Dept ইত্যাদি ফিল্টার: কিছু বাছা থাকলে ওই কর্মচারীদের ID দিয়ে ছাঁটা
                    if (AnyFilterSelected())
                    {
                        if (UserCode == 0)
                        {
                            Toast("User_Code পাওয়া যায়নি (Session)। Login করে আবার চেষ্টা করুন।");
                            return;
                        }

                        filters.SaveSelections(con, UserCode, FromCode);
                        HashSet<string> allowed = FilteredEmployeeIds(con);

                        var rows = dt.AsEnumerable().Where(r => allowed.Contains(Convert.ToString(r["ID_no"]).Trim())).ToList();
                        dt = rows.Count > 0 ? rows.CopyToDataTable() : dt.Clone();
                    }
                }
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message);
                return;
            }

            rptLeave.DataSource = dt;
            rptLeave.DataBind();
            trEmpty.Visible = dt.Rows.Count == 0;
            lblCount.Text = dt.Rows.Count + " Records";

            // ডেক্সটপের মতো: ID দিয়ে খুঁজলে সবকটি টিক দেওয়া থাকবে
            if (dt.Rows.Count > 0 && !string.IsNullOrWhiteSpace(txtIdNo.Text))
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

        // Attendance_Reports এর মতো Pro_Employee_View_N_All চালিয়ে ফিল্টার-মেলানো কর্মচারীদের ID তালিকা
        HashSet<string> FilteredEmployeeIds(SqlConnection con)
        {
            var set = new HashSet<string>();
            using (var cmd = new SqlCommand("Pro_Employee_View_N_All", con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandTimeout = 120;
                cmd.Parameters.AddWithValue("@Employee_Status", "All");
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

        void ClearGrid()
        {
            rptLeave.DataSource = null;
            rptLeave.DataBind();
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
