using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.HRMPayroll.Payrollinformation
{
    public partial class SalaryBreckDownProcess : Page
    {
        PayrollDB conn = new PayrollDB();

        // ================= Page Load =================
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                chkIsActive.Checked = true;
                LoadEmployees();
            }
        }

        // ================= Refresh =================
        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            lblMsg.Visible = false;
            LoadEmployees();
        }

        // ================= Employee তালিকা (View_Emp) =================
        void LoadEmployees()
        {
            try
            {
                string sql = "SELECT ID_no, Name, Designation FROM View_Emp";
                if (chkIsActive.Checked)
                    sql += " WHERE Resign_Status = 'Active'";
                sql += " ORDER BY ID_no";

                var dt = new DataTable();
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();
                    using (var da = new SqlDataAdapter(sql, con))
                        da.Fill(dt);
                }

                GridView1.DataSource = dt;
                GridView1.DataBind();

                // হেডারকে <thead> বানানো (sticky header কাজ করার জন্য)
                if (GridView1.HeaderRow != null)
                    GridView1.HeaderRow.TableSection = TableRowSection.TableHeader;

                // WinForms এর মতোই শুরুতে সবাই টিক দেওয়া
                foreach (GridViewRow row in GridView1.Rows)
                {
                    var chk = row.FindControl("chkSel") as CheckBox;
                    if (chk != null) chk.Checked = true;
                }

                lblInfo.Text = dt.Rows.Count + " Employees";
            }
            catch (Exception ex)
            {
                GridView1.DataSource = null;
                GridView1.DataBind();
                lblInfo.Text = "0 Employees";
                ShowMsg("Error: " + ex.Message, false);
            }
        }

        // ================= Process =================
        protected void btnProcess_Click(object sender, EventArgs e)
        {
            // টিক দেওয়া ID সংগ্রহ
            var ids = new List<long>();
            foreach (GridViewRow row in GridView1.Rows)
            {
                var chk = row.FindControl("chkSel") as CheckBox;
                if (chk == null || !chk.Checked) continue;

                long id;
                if (long.TryParse(Convert.ToString(GridView1.DataKeys[row.RowIndex].Value), out id))
                    ids.Add(id);
            }

            if (ids.Count == 0)
            {
                ShowMsg("Please Select Employee", false);
                return;
            }

            int ok = 0;
            var failed = new List<string>();

            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();

                    foreach (long id in ids)
                    {
                        try
                        {
                            using (var cmd = new SqlCommand("Pro_Pay_Process_System", con))
                            {
                                cmd.CommandType = CommandType.StoredProcedure;
                                cmd.CommandTimeout = 120;
                                cmd.Parameters.Add("@ID_No", SqlDbType.BigInt).Value = id;
                                cmd.ExecuteNonQuery();
                            }
                            ok++;
                        }
                        catch (Exception exRow)
                        {
                            // একজনের এরর হলে বাকিদের প্রসেস চলতে থাকবে
                            failed.Add(id + " (" + exRow.Message + ")");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMsg("Error: " + ex.Message, false);
                return;
            }

            if (failed.Count == 0)
                ShowMsg("Selected Process Successful (" + ok + " employee)", true);
            else
                ShowMsg("Processed: " + ok + ", Failed: " + failed.Count + " → " + string.Join(" | ", failed), false);
        }

        // ================= সাহায্যকারী =================
        void ShowMsg(string text, bool success)
        {
            lblMsg.Text = Server.HtmlEncode(text);
            lblMsg.CssClass = "block mb-3 rounded px-3 py-2 text-sm " +
                (success ? "bg-green-100 text-green-800 border border-green-300"
                         : "bg-red-100 text-red-800 border border-red-300");
            lblMsg.Visible = true;
        }
    }
}
