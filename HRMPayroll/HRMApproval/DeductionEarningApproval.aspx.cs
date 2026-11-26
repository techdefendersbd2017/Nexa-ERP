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
    public partial class DeductionEarningApproval : System.Web.UI.Page
    {
        PayrollDB conn = new PayrollDB();

        // IncrementApproval পেজের মতোই ফিল্টার ক্লাস
        HRFilters filters;

        readonly List<string> loadErrors = new List<string>();

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

                // ডেক্সটপ: comboBox1 = Statuss (Status_name / Status_Code)
                FillStatus();
                txtDate.Text = DateTime.Today.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
                ClearGrid();
            }

            if (IsPostBack && loadErrors.Count + filters.Errors.Count > 0)
                Toast("Option load error: " + string.Join(" | ", loadErrors.Concat(filters.Errors)));
        }

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
            }
            catch (Exception ex)
            {
                loadErrors.Add("Status: " + ex.Message);
            }
        }

        // ================= Show বাটন (ডেক্সটপের button1_Click) =================
        protected void btnShow_Click(object sender, EventArgs e)
        {
            ShowData();
        }

        // ================= Confirm / Re-Open / Delete (ডেক্সটপের button4 / button5 / button6) =================
        protected void btnConfirm_Click(object sender, EventArgs e)
        {
            ProcessAction("Pro_Deduction_Information_Confirm", "Confirm Successful");
        }

        protected void btnReOpen_Click(object sender, EventArgs e)
        {
            ProcessAction("Pro_Deduction_Information_Re_Open", "Re-Open Successful");
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            ProcessAction("Pro_Deduction_Information_Delete", "Delete Successful");
        }

        // তিনটি বাটনের একই কাজ, শুধু stored procedure আলাদা (procName কোডের ধ্রুবক)
        void ProcessAction(string procName, string okMsg)
        {
            string[] entries = Request.Form.GetValues("selEntry");
            if (entries == null || entries.Length == 0)
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

                    foreach (string s in entries)
                    {
                        long entryNo;
                        if (!long.TryParse(s, out entryNo)) continue;

                        using (var cmd = new SqlCommand(procName, con))
                        {
                            cmd.CommandType = CommandType.StoredProcedure;
                            cmd.Parameters.Add("@Entry_no", SqlDbType.BigInt).Value = entryNo;
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
            if (ddStatus.SelectedItem == null)
            {
                Toast("Status লোড হয়নি।");
                return;
            }

            DateTime eff;
            if (!DateTime.TryParseExact(txtDate.Text.Trim(), "yyyy-MM-dd",
                    CultureInfo.InvariantCulture, DateTimeStyles.None, out eff))
            {
                Toast("Effective Date সঠিক নয়।");
                return;
            }

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
                        string sql = "SELECT Entry_no,ID_no,Name,Mode_Name,Deduct_Name,Advance_Amount " +
                                     "FROM View_Deduction_Informations " +
                                     "WHERE Status=@st AND DATEPART(year,Advance_Month)=@y AND DATEPART(month,Advance_Month)=@m";
                        cmd.Parameters.Add("@st", SqlDbType.NVarChar, 50).Value = ddStatus.SelectedValue;
                        cmd.Parameters.Add("@y", SqlDbType.Int).Value = eff.Year;
                        cmd.Parameters.Add("@m", SqlDbType.Int).Value = eff.Month;

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

            rptDed.DataSource = dt;
            rptDed.DataBind();
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
            rptDed.DataSource = null;
            rptDed.DataBind();
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