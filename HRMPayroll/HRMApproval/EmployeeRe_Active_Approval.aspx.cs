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

namespace Nexa_ERP.HRMPayroll.HRMApproval
{
    public partial class EmployeeRe_Active_Approval : Page
    {
        PayrollDB conn = new PayrollDB();

        const int MaxIds = HRFilters.MaxIds;

        // WinForms এর stored procedure
        const string ProcReActive = "Pro_Employee_Re_Active";

        // ---------- মডেল ----------
        public class SepEmp
        {
            public string Id { get; set; }
            public string Name { get; set; }
            public string Designation { get; set; }
            public string JoinDate { get; set; }
            public string SepType { get; set; }
            public string SepDate { get; set; }
        }

        // ================= Page Load =================
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                hfSelIds.Value = "";
                txtActDate.Text = DateTime.Today.ToString("yyyy-MM-dd");

                // WinForms এর Form_Load এর মতো: শুরুতেই সব Confirm হওয়া Separation দেখানো (টিক ছাড়া)
                ShowData(false);
            }
        }

        // ================= বাটন ইভেন্ট =================
        protected void btnShow_Click(object sender, EventArgs e)
        {
            ShowData(true);   // WinForms এর মতো Show এ সবাই টিক হয়ে যায়
        }

        protected void btnActive_Click(object sender, EventArgs e)
        {
            RunReActive();
        }

        // ================= Re-Active এর মূল কাজ =================
        // সব নির্বাচিত ID একটি ট্রানজেকশনে চলে: কোনোটি ব্যর্থ হলে কোনোটিই সেভ হয় না।
        void RunReActive()
        {
            string raw = SelectedIdsRaw();

            long[] ids = HRFilters.ParseIds(raw)
                .Select(s => { long x; return long.TryParse(s, out x) ? x : 0; })
                .Where(x => x != 0).Distinct().ToArray();

            if (ids.Length == 0)
            {
                Toast("কমপক্ষে একজন কর্মচারী নির্বাচন করুন।");
                return;
            }

            DateTime actDate;
            if (!TryDate(txtActDate.Text, out actDate))
            {
                Toast("Activation Date সঠিক নয়।");
                RetainTicks(raw);
                return;
            }

            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();

                    using (SqlTransaction tran = con.BeginTransaction())
                    {
                        try
                        {
                            foreach (long id in ids)
                            {
                                using (var cmd = new SqlCommand(ProcReActive, con, tran))
                                {
                                    cmd.CommandType = CommandType.StoredProcedure;
                                    cmd.CommandTimeout = 120;
                                    cmd.Parameters.Add("@ID_No", SqlDbType.BigInt).Value = id;
                                    cmd.Parameters.Add("@Re_Active_Date", SqlDbType.Date).Value = actDate.Date;
                                    cmd.ExecuteNonQuery();
                                }
                            }
                            tran.Commit();
                        }
                        catch
                        {
                            tran.Rollback();
                            throw;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message);
                RetainTicks(raw);
                return;
            }

            Toast("Re-Active successful (" + ids.Length + " employee)");
            hfSelIds.Value = "";
            ShowData(false);
        }

        // ================= তালিকা আনা =================
        bool ShowData(bool checkAll)
        {
            DataTable dt;

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
                    dt = QueryConfirmedSeparations(con, ids);
                }
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message);
                return false;
            }

            BindTable(dt, checkAll);
            return true;
        }

        // WinForms এর query এর নিরাপদ রূপ (parameterized): SQL Injection বন্ধ
        DataTable QueryConfirmedSeparations(SqlConnection con, string[] ids)
        {
            using (var cmd = new SqlCommand())
            {
                cmd.Connection = con;
                cmd.CommandTimeout = 120;

                string sql = "SELECT * FROM View_Seperation_Employee WHERE Separtation_Status='Confirm'";

                if (ids.Length > 0)
                {
                    bool numeric = ids.All(s => { long x; return long.TryParse(s, out x); });
                    var names = new List<string>();
                    for (int i = 0; i < ids.Length; i++)
                    {
                        string p = "@id" + i;
                        names.Add(p);
                        if (numeric) cmd.Parameters.Add(p, SqlDbType.BigInt).Value = long.Parse(ids[i]);
                        else cmd.Parameters.Add(p, SqlDbType.NVarChar, 50).Value = ids[i];
                    }
                    sql += " AND ID_no IN (" + string.Join(",", names) + ")";
                }

                sql += " ORDER BY [Resign_Date] DESC";
                cmd.CommandText = sql;

                var dt = new DataTable();
                using (var da = new SqlDataAdapter(cmd)) da.Fill(dt);
                return dt;
            }
        }

        // ================= ফলাফল দেখানো =================
        void BindTable(DataTable dt, bool checkAll)
        {
            // Separation Type এর কলাম: আগে জানা নামগুলো, না পেলে কলামের নাম দেখে অনুমান
            string typeCol = FindColumn(dt,
                "Seperation_Type", "Separtation_Type", "Separation_Type",
                "Seperation_Type_Name", "Separation_Type_Name", "Separtation_Type_Name",
                "SeperationType", "SeparationType", "Resign_Type", "Resign_Type_Name",
                "Resign_Status", "Type", "Seperation_Name");

            if (typeCol == null)
                typeCol = GuessTypeColumn(dt);

            if (typeCol == null && dt.Columns.Count > 0)
                Toast("Separation Type কলাম পাওয়া যায়নি। View এর কলাম: " +
                      string.Join(", ", dt.Columns.Cast<DataColumn>().Select(c => c.ColumnName)));

            var list = new List<SepEmp>();
            foreach (DataRow r in dt.Rows)
            {
                list.Add(new SepEmp
                {
                    Id = Col(r, "ID_no", "Id", "Emp_ID"),
                    Name = Col(r, "Name", "Emp_Name"),
                    Designation = Col(r, "Designation", "Desigation_name"),
                    JoinDate = DateCol(r, "Date_of_Join", "Joining_Date", "Join_Date", "DOJ", "Date_Of_Joining"),
                    SepType = typeCol == null ? "" : Col(r, typeCol),
                    SepDate = DateCol(r, "Resign_Date", "Seperation_Date", "Separation_Date")
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

            if (checkAll && list.Count > 0)
            {
                ClientScript.RegisterStartupScript(GetType(), "chkall",
                    "document.addEventListener('DOMContentLoaded',function(){document.querySelectorAll('.row-checkbox,#selectAllRows').forEach(function(c){c.checked=true;});updateSelCount();});", true);
            }
        }

        static string FindColumn(DataTable dt, params string[] names)
        {
            foreach (string n in names)
            {
                foreach (DataColumn c in dt.Columns)
                {
                    if (string.Equals(c.ColumnName, n, StringComparison.OrdinalIgnoreCase))
                        return c.ColumnName;
                }
            }
            return null;
        }

        static string GuessTypeColumn(DataTable dt)
        {
            var cols = dt.Columns.Cast<DataColumn>().Select(c => c.ColumnName)
                         .Where(n => n.IndexOf("type", StringComparison.OrdinalIgnoreCase) >= 0)
                         .Where(n => !n.EndsWith("id", StringComparison.OrdinalIgnoreCase))
                         .ToList();

            string best = cols.FirstOrDefault(n =>
                n.IndexOf("sep", StringComparison.OrdinalIgnoreCase) >= 0 ||
                n.IndexOf("resign", StringComparison.OrdinalIgnoreCase) >= 0 ||
                n.IndexOf("termin", StringComparison.OrdinalIgnoreCase) >= 0);

            return best ?? cols.FirstOrDefault();
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

        // তারিখ কলাম: dd-MMM-yyyy ফরম্যাটে
        static string DateCol(DataRow r, params string[] names)
        {
            foreach (string n in names)
            {
                if (r.Table.Columns.Contains(n) && r[n] != DBNull.Value)
                {
                    DateTime d;
                    if (r[n] is DateTime) return ((DateTime)r[n]).ToString("dd-MMM-yyyy", CultureInfo.InvariantCulture);
                    if (DateTime.TryParse(Convert.ToString(r[n]), out d)) return d.ToString("dd-MMM-yyyy", CultureInfo.InvariantCulture);
                    return Convert.ToString(r[n]);
                }
            }
            return "";
        }

        // ================= সাহায্যকারী =================
        static bool TryDate(string s, out DateTime d)
        {
            d = DateTime.MinValue;
            if (string.IsNullOrWhiteSpace(s)) return false;
            return DateTime.TryParseExact(s.Trim(), "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out d)
                   || DateTime.TryParse(s.Trim(), out d);
        }

        // টিক দেওয়া ID গুলো: প্রথমে চেকবক্সের name="selId", না পেলে hfSelIds
        string SelectedIdsRaw()
        {
            string[] fromForm = Request.Form.GetValues("selId");
            if (fromForm != null && fromForm.Length > 0)
                return string.Join(",", fromForm);
            return hfSelIds.Value ?? "";
        }

        // ব্যর্থ হলে আগের টিকগুলো ফিরিয়ে আনা
        void RetainTicks(string raw)
        {
            if (string.IsNullOrEmpty(raw)) return;
            string arr = new JavaScriptSerializer().Serialize(raw.Split(','));
            ClientScript.RegisterStartupScript(GetType(), "retick",
                "document.addEventListener('DOMContentLoaded',function(){var ids=" + arr +
                ";document.querySelectorAll('.row-checkbox').forEach(function(c){" +
                "if(ids.indexOf(c.getAttribute('data-id'))>=0)c.checked=true;});updateSelCount();});", true);
        }

        void Toast(string msg)
        {
            string js = "document.addEventListener('DOMContentLoaded',function(){showNotification(" +
                        new JavaScriptSerializer().Serialize(msg) + ");});";
            ClientScript.RegisterStartupScript(GetType(), "toast" + Guid.NewGuid().ToString("N"), js, true);
        }
    }
}