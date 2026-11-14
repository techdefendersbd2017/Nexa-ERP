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
    public partial class IncrementApproval : System.Web.UI.Page
    {
        PayrollDB conn = new PayrollDB();

        // LeaveApproval পেজের মতোই ফিল্টার ক্লাস
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

                // ডেক্সটপ: comboBox1 = Increment_Catagory, comboBox2 = Increment_Promotion_Status
                FillCombo(ddIncType, "SELECT Increment_Catagory, Increment_Name FROM Increment_Catagory", "Increment_Name", "Increment_Catagory");
                FillCombo(ddStatus, "SELECT Status_Code, Status_Name FROM Increment_Promotion_Status", "Status_Name", "Status_Code");

                txtDate.Text = DateTime.Today.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
                ClearGrid();
            }

            if (IsPostBack && loadErrors.Count + filters.Errors.Count > 0)
                Toast("Option load error: " + string.Join(" | ", loadErrors.Concat(filters.Errors)));
        }

        // ড্রপডাউন ভরা (sql কোডের ভেতরের ধ্রুবক, ব্যবহারকারীর ইনপুট নয়)
        void FillCombo(DropDownList dd, string sql, string textCol, string valueCol)
        {
            dd.Items.Clear();
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();
                    using (var cmd = new SqlCommand(sql, con))
                    {
                        var dt = new DataTable();
                        using (var da = new SqlDataAdapter(cmd)) da.Fill(dt);
                        foreach (DataRow r in dt.Rows)
                            dd.Items.Add(new ListItem(Convert.ToString(r[textCol]), Convert.ToString(r[valueCol])));
                    }
                }
            }
            catch (Exception ex)
            {
                loadErrors.Add(dd.ID + ": " + ex.Message);
            }
        }

        // ================= Show বাটন (ডেক্সটপের button1_Click) =================
        protected void btnShow_Click(object sender, EventArgs e)
        {
            ShowData();
        }

        // ================= Approved / Delete / ReOpen (ডেক্সটপের button5 / button4 / button6) =================
        protected void btnApprove_Click(object sender, EventArgs e)
        {
            ProcessAction("Pro_Monthly_Increment_Approved", "Approved Successful");
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            ProcessAction("Pro_Monthly_Increment_Delete", "Delete Successful");
        }

        protected void btnReOpen_Click(object sender, EventArgs e)
        {
            ProcessAction("Pro_Monthly_Increment_ReOpen", "ReOpen Successful");
        }

        // তিনটি বাটনের একই কাজ, শুধু stored procedure আলাদা (procName কোডের ধ্রুবক)
        void ProcessAction(string procName, string okMsg)
        {
            string[] idNos = Request.Form.GetValues("selId");
            if (idNos == null || idNos.Length == 0)
            {
                Toast("কমপক্ষে একজন কর্মচারী নির্বাচন করুন।");
                return;
            }

            DateTime eff;
            if (!DateTime.TryParseExact(txtDate.Text.Trim(), "yyyy-MM-dd",
                    CultureInfo.InvariantCulture, DateTimeStyles.None, out eff))
            {
                Toast("Effective Date সঠিক নয়।");
                return;
            }

            int done = 0;
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();

                    foreach (string s in idNos)
                    {
                        long idNo;
                        if (!long.TryParse(s, out idNo)) continue;

                        using (var cmd = new SqlCommand(procName, con))
                        {
                            cmd.CommandType = CommandType.StoredProcedure;
                            cmd.Parameters.Add("@ID_No", SqlDbType.BigInt).Value = idNo;
                            cmd.Parameters.Add("@efective_Date", SqlDbType.DateTime).Value = eff;
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

            // ডেক্সটপের মতো: প্রসেসের পর আবার তালিকা লোড
            ShowData();
        }

        // ================= মূল লজিক =================
        void ShowData()
        {
            if (ddIncType.SelectedItem == null || ddStatus.SelectedItem == null)
            {
                Toast("Increment Type / Status লোড হয়নি।");
                return;
            }

            DateTime eff;
            if (!DateTime.TryParseExact(txtDate.Text.Trim(), "yyyy-MM-dd",
                    CultureInfo.InvariantCulture, DateTimeStyles.None, out eff))
            {
                Toast("Effective Date সঠিক নয়।");
                return;
            }

            DataTable dt;
            try
            {
                string[] ids = HRFilters.ParseIds(txtIdNo.Text);
                string incName = ddIncType.SelectedItem.Text;

                // ডেক্সটপের মতো: Increment হলে View_Increment, বাকি দুটির জন্য View_Promotion
                string view = incName == "Increment" ? "View_Increment" : "View_Promotion";

                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();

                    using (var cmd = new SqlCommand())
                    {
                        cmd.Connection = con;
                        string sql = "SELECT * FROM " + view +
                                     " WHERE Status_Name=@sn AND Increment_Name=@inc AND CAST(Efective_Date AS date)=@d";
                        cmd.Parameters.Add("@sn", SqlDbType.NVarChar, 100).Value = ddStatus.SelectedItem.Text;
                        cmd.Parameters.Add("@inc", SqlDbType.NVarChar, 100).Value = incName;
                        cmd.Parameters.Add("@d", SqlDbType.Date).Value = eff.Date;

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

                        cmd.CommandText = sql;
                        dt = new DataTable();
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

            rptInc.DataSource = dt;
            rptInc.DataBind();
            trEmpty.Visible = dt.Rows.Count == 0;
            lblCount.Text = dt.Rows.Count + " Records";

            // ID দিয়ে খুঁজলে সবকটি টিক দেওয়া থাকবে
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

        protected string Num(object item, params string[] names)
        {
            string s = Get(item, names);
            decimal d;
            return decimal.TryParse(s, out d) ? d.ToString("N2", CultureInfo.InvariantCulture) : Server.HtmlEncode(s);
        }

        void ClearGrid()
        {
            rptInc.DataSource = null;
            rptInc.DataBind();
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
