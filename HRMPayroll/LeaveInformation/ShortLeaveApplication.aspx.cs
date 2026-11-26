using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.HRMPayroll.LeaveInformation
{
    public partial class ShortLeaveApplication : Page
    {
        PayrollDB conn = new PayrollDB();
        static readonly CultureInfo Inv = CultureInfo.InvariantCulture;

        // ---- Leave Type অনুযায়ী Stored Procedure ----
        // Short Leave = Desktop (Short_Leave.cs) এর procedure হুবহু।
        // TODO: Gate Pass এর procedure এর নাম আপনার ডাটাবেস অনুযায়ী ঠিক করুন।
        //       (Desktop এ Gate Pass ছিল না, তাই নাম অনুমান করে বসানো হয়েছে)
        const string SL_Save = "Pro_Emp_Early_Out_Permition";
        const string SL_Delete = "Pro_Emp_Early_Out_Permition_Delete";
        const string GP_Save = "Pro_Emp_Gate_Pass";
        const string GP_Delete = "Pro_Emp_Gate_Pass_Delete";

        const int MaxIds = 1000;

        public class AttRow
        {
            public string IdNo { get; set; }
            public string Name { get; set; }
            public string Designation { get; set; }
            public string WorkDate { get; set; }
            public string Status { get; set; }
            public string InTime { get; set; }
            public string OutTime { get; set; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtWorkDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                BindGrid(new List<AttRow>());
            }
        }

        // ================= Show =================
        protected void btnShow_Click(object sender, EventArgs e)
        {
            try
            {
                DateTime wd;
                if (!TryDate(txtWorkDate.Text, out wd)) { Toast("Invalid Work Date."); return; }

                List<long> ids;
                string err = ParseIds(txtIdNo.Text, out ids);
                if (err != null) { Toast(err); return; }

                // Desktop এর কোয়েরি, তবে ID গুলো parameter আকারে (SQL injection নেই)
                var ps = new List<SqlParameter>();
                var names = new List<string>();
                for (int i = 0; i < ids.Count; i++)
                {
                    string p = "@id" + i;
                    names.Add(p);
                    ps.Add(new SqlParameter(p, SqlDbType.BigInt) { Value = ids[i] });
                }
                ps.Add(new SqlParameter("@d", SqlDbType.Date) { Value = wd.Date });

                string sql = "SELECT ID_no, Name, Designation, Work_date, " +
                             "CAST(org_in_time AS time) AS in_time, CAST(org_out_time AS time) AS Out_Time, att_status " +
                             "FROM View_Manual_Attendance " +
                             "WHERE ID_no IN (" + string.Join(",", names) + ") AND CAST(Work_date AS date) = @d " +
                             "ORDER BY Work_date ASC";

                DataTable dt = Fill(sql, ps.ToArray());
                var list = new List<AttRow>();
                foreach (DataRow r in dt.Rows)
                {
                    list.Add(new AttRow
                    {
                        IdNo = S(r["ID_no"]),
                        Name = S(r["Name"]),
                        Designation = S(r["Designation"]),
                        WorkDate = FmtDate(r["Work_date"]),
                        InTime = FmtTime(r["in_time"]),
                        OutTime = FmtTime(r["Out_Time"]),
                        Status = S(r["att_status"])
                    });
                }
                BindGrid(list);   // Desktop এর মতো সব সারি টিক দেওয়া অবস্থায়
                if (list.Count == 0) Toast("No attendance found for the given ID(s) and date.");
            }
            catch (Exception ex) { Toast("Error: " + ex.Message); }
        }

        // ================= Save / Delete =================
        protected void btnSave_Click(object sender, EventArgs e)
        {
            RunForSelected(IsGatePass ? GP_Save : SL_Save, "Save Successful");
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            RunForSelected(IsGatePass ? GP_Delete : SL_Delete, "Delete Successful");
        }

        bool IsGatePass { get { return ddlLeaveType.SelectedValue == "GP"; } }

        void RunForSelected(string proc, string okMessage)
        {
            try
            {
                DateTime wd;
                if (!TryDate(txtWorkDate.Text, out wd)) { Toast("Invalid Work Date."); return; }

                var ids = new List<long>();
                foreach (RepeaterItem it in rptRows.Items)
                {
                    var chk = (CheckBox)it.FindControl("chkRow");
                    var hf = (HiddenField)it.FindControl("hfId");
                    long id;
                    if (chk != null && chk.Checked && long.TryParse(hf.Value, NumberStyles.None, Inv, out id))
                        ids.Add(id);
                }
                if (ids.Count == 0) { Toast("Please select at least one employee."); return; }

                // সব এন্ট্রি একটাই transaction এ: মাঝপথে ব্যর্থ হলে কিছুই সেভ হবে না
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();
                    using (SqlTransaction tx = con.BeginTransaction())
                    {
                        try
                        {
                            foreach (long id in ids)
                            {
                                using (var cmd = new SqlCommand(proc, con, tx))
                                {
                                    cmd.CommandType = CommandType.StoredProcedure;
                                    cmd.CommandTimeout = 60;
                                    cmd.Parameters.Add("@ID_no", SqlDbType.BigInt).Value = id;
                                    cmd.Parameters.Add("@Work_Date", SqlDbType.DateTime).Value = wd.Date;
                                    cmd.ExecuteNonQuery();
                                }
                            }
                            tx.Commit();
                        }
                        catch { tx.Rollback(); throw; }
                    }
                }
                Toast(ddlLeaveType.SelectedItem.Text + ": " + okMessage + " (" + ids.Count + ")");
            }
            catch (Exception ex) { Toast("Error: " + ex.Message); }
        }

        // ================= Refresh =================
        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            txtIdNo.Text = "";
            txtWorkDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
            ddlLeaveType.SelectedIndex = 0;
            BindGrid(new List<AttRow>());
            Toast("Refreshed.");
        }

        // ================= সাহায্যকারী =================
        void BindGrid(List<AttRow> list)
        {
            rptRows.DataSource = list;
            rptRows.DataBind();
            trEmpty.Visible = list.Count == 0;
            lblCount.Text = list.Count + " Records";
            litPaging.Text = list.Count == 0
                ? "Showing 0 entries"
                : "Showing <span class=\"font-medium text-slate-700\">" + list.Count + "</span> entries";
        }

        // কমা / স্পেস / নতুন লাইনে আলাদা করা ID গুলো যাচাই করে long তালিকা বানায়
        static string ParseIds(string text, out List<long> ids)
        {
            ids = new List<long>();
            if (string.IsNullOrWhiteSpace(text)) return "Please Check Your ID No";

            foreach (string tok in Regex.Split(text.Trim(), @"[\s,;]+"))
            {
                if (tok.Length == 0) continue;
                long id;
                if (!long.TryParse(tok, NumberStyles.None, Inv, out id)) return "Invalid ID No: " + tok;
                if (!ids.Contains(id)) ids.Add(id);
            }
            if (ids.Count == 0) return "Please Check Your ID No";
            if (ids.Count > MaxIds) return "Too many IDs (max " + MaxIds + ").";
            return null;
        }

        static string S(object o) { return o == null || o == DBNull.Value ? "" : Convert.ToString(o); }

        static string FmtDate(object o)
        {
            DateTime d;
            return DateTime.TryParse(S(o), out d) ? d.ToString("dd-MMM-yyyy", Inv) : S(o);
        }

        static string FmtTime(object o)
        {
            if (o is TimeSpan) return DateTime.Today.Add((TimeSpan)o).ToString("hh:mm tt", Inv);
            return S(o);
        }

        static bool TryDate(string s, out DateTime d)
        {
            return DateTime.TryParseExact((s ?? "").Trim(), "yyyy-MM-dd", Inv, DateTimeStyles.None, out d);
        }

        DataTable Fill(string sql, params SqlParameter[] ps)
        {
            using (SqlConnection con = conn.openConnection())
            {
                if (con.State != ConnectionState.Open) con.Open();
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.CommandTimeout = 60;
                    if (ps != null && ps.Length > 0) cmd.Parameters.AddRange(ps);
                    var dt = new DataTable();
                    using (var da = new SqlDataAdapter(cmd)) da.Fill(dt);
                    return dt;
                }
            }
        }

        void Toast(string msg)
        {
            string js = "document.addEventListener('DOMContentLoaded',function(){showNotification(" +
                        new JavaScriptSerializer().Serialize(msg) + ");});";
            ClientScript.RegisterStartupScript(GetType(), "toast" + Guid.NewGuid().ToString("N"), js, true);
        }
    }
}