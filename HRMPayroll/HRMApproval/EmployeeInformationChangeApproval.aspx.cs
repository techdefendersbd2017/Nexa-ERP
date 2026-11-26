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
    public partial class EmployeeInformationCheangeApproval : System.Web.UI.Page
    {
        PayrollDB conn = new PayrollDB();

        // DeductionEarningApproval / IncrementApproval পেজের মতোই ফিল্টার ক্লাস
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
                ClearGrid();
            }

            if (IsPostBack && loadErrors.Count + filters.Errors.Count > 0)
                Toast("Option load error: " + string.Join(" | ", loadErrors.Concat(filters.Errors)));
        }

        // ================= Show বাটন (ডেক্সটপের button1_Click) =================
        protected void btnShow_Click(object sender, EventArgs e)
        {
            ShowData();
        }

        // ================= Confirm / Delete (ডেক্সটপের button2 / button3) =================
        protected void btnConfirm_Click(object sender, EventArgs e)
        {
            ProcessAction("PRo_Employee_Information_Change_Confirm", "Confirm Successful");
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            ProcessAction("PRo_Employee_Information_Change_Delete", "Delete Successful");
        }

        // দুটি বাটনের একই কাজ, শুধু stored procedure আলাদা (procName কোডের ধ্রুবক)
        void ProcessAction(string procName, string okMsg)
        {
            string[] ids = Request.Form.GetValues("selId");
            if (ids == null || ids.Length == 0)
            {
                Toast("কমপক্ষে একটি এন্ট্রি নির্বাচন করুন।");
                return;
            }

            int done = 0;
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();

                    // একই ID একাধিকবার টিক হলেও procedure একবারই চলবে (ডেক্সটপে @ID_No-ই পাঠানো হয়)
                    foreach (string s in ids.Distinct())
                    {
                        long idNo;
                        if (!long.TryParse(s, out idNo)) continue;

                        using (var cmd = new SqlCommand(procName, con))
                        {
                            cmd.CommandType = CommandType.StoredProcedure;
                            cmd.Parameters.Add("@ID_No", SqlDbType.BigInt).Value = idNo;
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
                return;
            }

            // ডেক্সটপের মতো: প্রসেসের পর আবার Open তালিকা লোড
            ShowData();
        }

        // ================= মূল লজিক =================
        void ShowData()
        {
            DataTable dt = new DataTable();
            try
            {
                string[] ids = HRFilters.ParseIds(txtIdNo.Text);

                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();

                    using (var cmd = new SqlCommand())
                    {
                        cmd.Connection = con;
                        string sql = "SELECT [ID_no],[Name],[Joining_Date],[Effective_Date],[Catagory_Name],[New_Catagory_Name]," +
                                     "[Desigation_name],[New_Desigation_name],[Department_Name],[New_Department_Name]," +
                                     "[Section_Name],[New_Section_Name],[Line_Name],[New_Line_Name],[Auto_no],[Open_Status] " +
                                     "FROM [View_Employee_Information_Change_New] WHERE [Open_Status]='Open'";

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

                        sql += " ORDER BY [Effective_Date] DESC";
                        cmd.CommandText = sql;
                        using (var da = new SqlDataAdapter(cmd)) da.Fill(dt);
                    }

                    // Branch/Dept ইত্যাদি ফিল্টার: কিছু বাছা থাকলে ওই কর্মচারীদের ID দিয়ে ছাঁটা
                    if (AnyFilterSelected())
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

            // ডেক্সটপের মতো: Show এর পর সব সারি টিক দেওয়া থাকবে
            if (dt.Rows.Count > 0)
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

        // তারিখ: dd-MMM-yyyy
        protected string Dt(object item, string name)
        {
            string s = Get(item, name);
            DateTime d;
            return DateTime.TryParse(s, out d)
                ? Server.HtmlEncode(d.ToString("dd-MMM-yyyy", CultureInfo.InvariantCulture))
                : Server.HtmlEncode(s);
        }

        // পুরনো → নতুন: নতুন মান ফাঁকা বা একই হলে শুধু পুরনোটি দেখায়
        protected string Chg(object item, string oldCol, string newCol)
        {
            string o = (Get(item, oldCol) ?? "").Trim();
            string n = (Get(item, newCol) ?? "").Trim();

            if (n.Length == 0 || string.Equals(o, n, StringComparison.OrdinalIgnoreCase))
                return "<span class=\"text-slate-700\">" + Server.HtmlEncode(o) + "</span>";

            return "<span class=\"chg-old\">" + Server.HtmlEncode(o) + "</span>" +
                   "<i class=\"fa-solid fa-arrow-right chg-arrow\"></i>" +
                   "<span class=\"chg-new\">" + Server.HtmlEncode(n) + "</span>";
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