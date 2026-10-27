using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.HRMPayroll.Payrollinformation
{
    // Desktop ফর্ম (Deduction_or_Earning.cs) এর ওয়েব রূপ
    public partial class DeductionEarnning : Page
    {
        PayrollDB conn = new PayrollDB();

        const int MaxIds = 2000;

        // Desktop এ Lock_Months এর reader[8] কলামে "Lock" লেখা থাকে
        const int LockColumnIndex = 8;
        const string LockValue = "Lock";

        // Desktop এ button1.Text ("Add") ই operation_Type হিসেবে যেত
        const string OperationAdd = "Add";

        // ================= Page Load =================
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            try
            {
                FillModes();
                FillTypes();
                FillStatus();
                FillFilterTypes();
            }
            catch (Exception ex)
            {
                Toast("Option load error: " + ex.Message);
            }

            txtEffDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
            ClearEmployees();
            ClearEntries();
        }

        // ================= ড্রপডাউন লোড =================
        void FillModes()
        {
            // SELECT * FROM Deduction_Mode
            DataTable dt = Query("SELECT Mode_Code, Mode_Name FROM Deduction_Mode ORDER BY Mode_Name", null);
            ddMode.Items.Clear();
            ddMode.Items.Add(new ListItem("-- Select --", ""));
            foreach (DataRow r in dt.Rows)
                ddMode.Items.Add(new ListItem(Convert.ToString(r["Mode_Name"]), Convert.ToString(r["Mode_Code"])));
        }

        // Mode বদলালে সেই Mode এর Deduction_Catagory
        void FillTypes()
        {
            ddType.Items.Clear();
            ddType.Items.Add(new ListItem("-- Select --", ""));

            long mode;
            if (!long.TryParse(ddMode.SelectedValue, out mode)) return;

            DataTable dt = Query("SELECT Deduct_Code, Deduct_Name FROM Deduction_Catagory WHERE Mode_Code=@m ORDER BY Deduct_Name",
                cmd => cmd.Parameters.Add("@m", SqlDbType.BigInt).Value = mode);
            foreach (DataRow r in dt.Rows)
                ddType.Items.Add(new ListItem(Convert.ToString(r["Deduct_Name"]), Convert.ToString(r["Deduct_Code"])));
        }

        void FillStatus()
        {
            // SELECT * FROM Statuss (Text = Status_name, Value = Status_Code)
            DataTable dt = Query("SELECT Status_Code, Status_name FROM Statuss", null);
            ddStatus.Items.Clear();
            foreach (DataRow r in dt.Rows)
                ddStatus.Items.Add(new ListItem(Convert.ToString(r["Status_name"]), Convert.ToString(r["Status_Code"])));
        }

        // ডান পাশের Type ফিল্টার (Deduct_Name ধরে ফিল্টার হয়)
        void FillFilterTypes()
        {
            DataTable dt = Query("SELECT DISTINCT Deduct_Name FROM Deduction_Catagory ORDER BY Deduct_Name", null);
            ddFilterType.Items.Clear();
            ddFilterType.Items.Add(new ListItem("-- All --", ""));
            foreach (DataRow r in dt.Rows)
            {
                string n = Convert.ToString(r["Deduct_Name"]);
                ddFilterType.Items.Add(new ListItem(n, n));
            }
        }

        protected void ddMode_SelectedIndexChanged(object sender, EventArgs e)
        {
            try { FillTypes(); }
            catch (Exception ex) { Toast("Error: " + ex.Message); }
        }

        // ================= বাঁ পাশ: Employee Load =================
        protected void btnLoadEmp_Click(object sender, EventArgs e)
        {
            List<long> ids;
            if (!TryParseIds(txtEmpIds.Text, out ids)) return;
            if (ids.Count == 0)
            {
                Toast("ID No লিখুন।");
                return;
            }

            try
            {
                DataTable dt;
                using (var cmd = new SqlCommand())
                {
                    string inList = AddIdParams(cmd, ids, "@e");
                    cmd.CommandText = "SELECT ID_no, Name, Designation FROM Employee_information_new WHERE ID_no IN (" + inList + ")";
                    dt = Fill(cmd);
                }

                rptEmp.DataSource = dt;
                rptEmp.DataBind();            // চেকবক্স Checked="true" (Desktop এর মতো সব টিক)
                trEmpEmpty.Visible = dt.Rows.Count == 0;
                lblEmpCount.Text = dt.Rows.Count + " Records";

                if (dt.Rows.Count == 0) Toast("কোনো কর্মচারী পাওয়া যায়নি।");
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message);
            }
        }

        // ================= Add (Pro_Deduction_Information) =================
        protected void btnAdd_Click(object sender, EventArgs e)
        {
            List<long> empIds = SelectedEmployeeIds();
            if (empIds.Count == 0) { Toast("কমপক্ষে একজন কর্মচারী নির্বাচন করুন।"); return; }

            long mode;
            if (!long.TryParse(ddMode.SelectedValue, out mode)) { Toast("Mode নির্বাচন করুন।"); return; }

            string type = ddType.SelectedValue;
            if (string.IsNullOrEmpty(type)) { Toast("Type নির্বাচন করুন।"); return; }

            DateTime effDate;
            if (!DateTime.TryParse(txtEffDate.Text, out effDate)) { Toast("সঠিক Eff. Date দিন।"); return; }

            long amount;
            if (!long.TryParse(txtAmount.Text.Trim(), out amount) || amount <= 0) { Toast("সঠিক Amount দিন।"); return; }

            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();

                    // ===== Lock System =====
                    if (IsMonthLocked(con, effDate))
                    {
                        Toast("This Month Lock");
                        return;
                    }

                    // সবাই একসাথে সেভ হবে, মাঝপথে ভুল হলে কিছুই সেভ হবে না
                    using (SqlTransaction tx = con.BeginTransaction())
                    {
                        foreach (long id in empIds)
                        {
                            using (var cmd = new SqlCommand("Pro_Deduction_Information", con, tx))
                            {
                                cmd.CommandType = CommandType.StoredProcedure;
                                cmd.Parameters.Add("@ID_No", SqlDbType.BigInt).Value = id;
                                cmd.Parameters.Add("@Advance_Month", SqlDbType.DateTime).Value = effDate;
                                cmd.Parameters.Add("@Deduction_Mode", SqlDbType.BigInt).Value = mode;
                                cmd.Parameters.Add("@Deduction_Type", SqlDbType.VarChar).Value = type;
                                cmd.Parameters.Add("@Advance_Amount", SqlDbType.BigInt).Value = amount;
                                cmd.Parameters.Add("@operation_Type", SqlDbType.VarChar).Value = OperationAdd;
                                cmd.ExecuteNonQuery();
                            }
                        }
                        tx.Commit();
                    }
                }
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message);
                return;
            }

            Toast("Save Successful");
            BindEntries();     // Desktop এর মতো সেভের পর ডান তালিকা আপডেট
        }

        // ================= ডান পাশ: Select / Refresh / Clear / Delete =================
        protected void btnSelect_Click(object sender, EventArgs e) { BindEntries(); }

        protected void btnRefresh_Click(object sender, EventArgs e) { BindEntries(); }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            txtSearchId.Text = "";
            if (ddFilterType.Items.Count > 0) ddFilterType.SelectedIndex = 0;
            if (ddStatus.Items.Count > 0) ddStatus.SelectedIndex = 0;
            ClearEntries();
            Toast("Filters cleared.");
        }

        // Pro_Deduction_Information_Delete
        protected void btnDelete_Click(object sender, EventArgs e)
        {
            List<long> entries = SelectedEntryNos();
            if (entries.Count == 0) { Toast("কমপক্ষে একটি এন্ট্রি নির্বাচন করুন।"); return; }

            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();

                    using (SqlTransaction tx = con.BeginTransaction())
                    {
                        foreach (long no in entries)
                        {
                            using (var cmd = new SqlCommand("Pro_Deduction_Information_Delete", con, tx))
                            {
                                cmd.CommandType = CommandType.StoredProcedure;
                                cmd.Parameters.Add("@Entry_no", SqlDbType.BigInt).Value = no;
                                cmd.ExecuteNonQuery();
                            }
                        }
                        tx.Commit();
                    }
                }
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message);
                return;
            }

            Toast("Delete Successful");
            BindEntries();
        }

        // ================= ডান তালিকা লোড =================
        // Desktop এর তিনটি আলাদা query এক জায়গায়: Month + (Status) + (ID) + (Type) দিয়ে ফিল্টার
        void BindEntries()
        {
            DateTime month;
            if (!DateTime.TryParse(txtEffDate.Text, out month)) { Toast("সঠিক Eff. Date দিন।"); return; }

            List<long> ids;
            if (!TryParseIds(txtSearchId.Text, out ids)) return;

            try
            {
                DataTable dt;
                using (var cmd = new SqlCommand())
                {
                    string sql = "SELECT Entry_no, ID_no, Name, Mode_Name, Deduct_Name, Advance_Amount " +
                                 "FROM View_Deduction_Informations WHERE CAST(Advance_Month AS date) = @m";
                    cmd.Parameters.Add("@m", SqlDbType.Date).Value = month.Date;

                    if (!string.IsNullOrEmpty(ddStatus.SelectedValue))
                    {
                        sql += " AND Status = @st";
                        cmd.Parameters.Add("@st", SqlDbType.NVarChar, 50).Value = ddStatus.SelectedValue;
                    }
                    if (ids.Count > 0)
                        sql += " AND ID_no IN (" + AddIdParams(cmd, ids, "@s") + ")";
                    if (!string.IsNullOrEmpty(ddFilterType.SelectedValue))
                    {
                        sql += " AND Deduct_Name = @dn";
                        cmd.Parameters.Add("@dn", SqlDbType.NVarChar, 200).Value = ddFilterType.SelectedValue;
                    }
                    cmd.CommandText = sql + " ORDER BY Entry_no";
                    dt = Fill(cmd);
                }

                rptEntry.DataSource = dt;
                rptEntry.DataBind();
                trEntryEmpty.Visible = dt.Rows.Count == 0;
                lblEntryCount.Text = dt.Rows.Count + " Records";
                lblEntryTitle.Text = "Eff. Date: " + month.ToString("dd-MMM-yyyy");
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message);
            }
        }

        // ================= সাহায্যকারী =================
        bool IsMonthLocked(SqlConnection con, DateTime d)
        {
            using (var cmd = new SqlCommand(
                "SELECT * FROM Lock_Months WHERE DATEPART(MONTH, Lock_Month) = @mo AND DATEPART(YEAR, Lock_Month) = @yr", con))
            {
                cmd.Parameters.Add("@mo", SqlDbType.Int).Value = d.Month;
                cmd.Parameters.Add("@yr", SqlDbType.Int).Value = d.Year;
                using (var rd = cmd.ExecuteReader())
                {
                    while (rd.Read())
                    {
                        if (rd.FieldCount > LockColumnIndex &&
                            string.Equals(Convert.ToString(rd[LockColumnIndex]), LockValue, StringComparison.OrdinalIgnoreCase))
                            return true;
                    }
                }
            }
            return false;
        }

        List<long> SelectedEmployeeIds()
        {
            var list = new List<long>();
            foreach (RepeaterItem it in rptEmp.Items)
            {
                var chk = it.FindControl("chk") as CheckBox;
                var hf = it.FindControl("hfId") as HiddenField;
                long id;
                if (chk != null && chk.Checked && hf != null && long.TryParse(hf.Value, out id)) list.Add(id);
            }
            return list.Distinct().ToList();
        }

        List<long> SelectedEntryNos()
        {
            var list = new List<long>();
            foreach (RepeaterItem it in rptEntry.Items)
            {
                var chk = it.FindControl("chk") as CheckBox;
                var hf = it.FindControl("hfEntry") as HiddenField;
                long no;
                if (chk != null && chk.Checked && hf != null && long.TryParse(hf.Value, out no)) list.Add(no);
            }
            return list.Distinct().ToList();
        }

        // কমা / স্পেস / নতুন লাইন দিয়ে আলাদা করা ID পার্স (SQL Injection ছাড়া)
        bool TryParseIds(string text, out List<long> ids)
        {
            ids = new List<long>();
            if (string.IsNullOrWhiteSpace(text)) return true;

            string[] parts = text.Split(new[] { ',', ';', ' ', '\r', '\n', '\t' }, StringSplitOptions.RemoveEmptyEntries);
            foreach (string p in parts)
            {
                long x;
                if (!long.TryParse(p, out x))
                {
                    Toast("ID No তে শুধু সংখ্যা ও কমা দিন: " + p);
                    return false;
                }
                ids.Add(x);
            }
            ids = ids.Distinct().ToList();

            if (ids.Count > MaxIds)
            {
                Toast("Too many IDs (max " + MaxIds + ").");
                return false;
            }
            return true;
        }

        static string AddIdParams(SqlCommand cmd, List<long> ids, string prefix)
        {
            var names = new List<string>();
            for (int i = 0; i < ids.Count; i++)
            {
                string p = prefix + i;
                names.Add(p);
                cmd.Parameters.Add(p, SqlDbType.BigInt).Value = ids[i];
            }
            return string.Join(",", names);
        }

        DataTable Query(string sql, Action<SqlCommand> addParams)
        {
            using (var cmd = new SqlCommand(sql))
            {
                if (addParams != null) addParams(cmd);
                return Fill(cmd);
            }
        }

        DataTable Fill(SqlCommand cmd)
        {
            using (SqlConnection con = conn.openConnection())
            {
                if (con.State != ConnectionState.Open) con.Open();
                cmd.Connection = con;
                cmd.CommandTimeout = 120;
                var dt = new DataTable();
                using (var da = new SqlDataAdapter(cmd)) da.Fill(dt);
                return dt;
            }
        }

        void ClearEmployees()
        {
            rptEmp.DataSource = null;
            rptEmp.DataBind();
            trEmpEmpty.Visible = true;
            lblEmpCount.Text = "0 Records";
        }

        void ClearEntries()
        {
            rptEntry.DataSource = null;
            rptEntry.DataBind();
            trEntryEmpty.Visible = true;
            lblEntryCount.Text = "0 Records";
            lblEntryTitle.Text = "Eff. Date অনুযায়ী ফলাফল";
        }

        void Toast(string msg)
        {
            string js = "document.addEventListener('DOMContentLoaded',function(){showNotification(" +
                        new JavaScriptSerializer().Serialize(msg) + ");});";
            ClientScript.RegisterStartupScript(GetType(), "toast" + Guid.NewGuid().ToString("N"), js, true);
        }
    }
}
