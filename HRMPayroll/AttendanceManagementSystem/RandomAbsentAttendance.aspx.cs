using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.HRMPayroll.AttendanceManagementSystem
{
    public partial class RandomAbsentAttendance : System.Web.UI.Page
    {
        // The procedure lives in the techpay database. If PayrollDB already points to techpay,
        // you can shorten this to just "Pro_Random_Absent_Manual_Attendance".
        private const string ProcName = "Pro_Random_Absent_Manual_Attendance";

        PayrollDB conn = new PayrollDB();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string user = Request.QueryString["user"];
                SetDefaults();
            }
        }

        // ---------- helpers ----------
        private void Alert(string message)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert",
                "alert('" + HttpUtility.JavaScriptStringEncode(message) + "');", true);
        }

        private void SetDefaults()
        {
            DateTime today = DateTime.Today;
            txtFromDate.Text = new DateTime(today.Year, today.Month, 1).ToString("yyyy-MM-dd");
            txtToDate.Text = today.ToString("yyyy-MM-dd");
            txtMinAbsent.Text = "15";
            txtMaxAbsent.Text = "20";
            txtMaxAbsentDays.Text = "3";
            chkNoConsecutive.Checked = true;
        }

        private static bool TryDate(string text, out DateTime value)
        {
            return DateTime.TryParseExact((text ?? "").Trim(), "yyyy-MM-dd",
                CultureInfo.InvariantCulture, DateTimeStyles.None, out value);
        }

        // ---------- buttons ----------
        protected void btnPreview_Click(object sender, EventArgs e)
        {
            RunProcess(true);
        }

        protected void btnApply_Click(object sender, EventArgs e)
        {
            RunProcess(false);
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            SetDefaults();
            gvDate.DataSource = null;
            gvDate.DataBind();
            gvEmp.DataSource = null;
            gvEmp.DataBind();
            lblStatus.Visible = false;
        }

        // ---------- run the procedure ----------
        private void RunProcess(bool preview)
        {
            // server-side validation (client validation can be bypassed)
            DateTime from, to;
            int minAbsent, maxAbsent, maxDays;

            if (!TryDate(txtFromDate.Text, out from) || !TryDate(txtToDate.Text, out to))
            {
                Alert("Please select a valid From Date and To Date.");
                return;
            }
            if (from > to)
            {
                Alert("To Date cannot be before From Date.");
                return;
            }
            if (!int.TryParse(txtMinAbsent.Text.Trim(), out minAbsent) || minAbsent < 0 ||
                !int.TryParse(txtMaxAbsent.Text.Trim(), out maxAbsent) || maxAbsent < 0)
            {
                Alert("Minimum and Maximum Absent must be whole numbers (0 or more).");
                return;
            }
            if (minAbsent > maxAbsent)
            {
                Alert("Minimum Absent cannot be greater than Maximum Absent.");
                return;
            }
            if (!int.TryParse(txtMaxAbsentDays.Text.Trim(), out maxDays) || maxDays < 1)
            {
                Alert("Max Absent Days Per Employee must be 1 or more.");
                return;
            }

            try
            {
                DataSet ds = new DataSet();

                using (SqlConnection con = conn.openConnection())
                using (SqlCommand cmd = new SqlCommand(ProcName, con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandTimeout = 300;

                    cmd.Parameters.Add("@FromDate", SqlDbType.Date).Value = from;
                    cmd.Parameters.Add("@ToDate", SqlDbType.Date).Value = to;
                    cmd.Parameters.Add("@MinAbsent", SqlDbType.Int).Value = minAbsent;
                    cmd.Parameters.Add("@MaxAbsent", SqlDbType.Int).Value = maxAbsent;
                    cmd.Parameters.Add("@MaxAbsentDaysPerEmp", SqlDbType.Int).Value = maxDays;
                    cmd.Parameters.Add("@NoConsecutive", SqlDbType.Bit).Value = chkNoConsecutive.Checked;
                    cmd.Parameters.Add("@Preview", SqlDbType.Bit).Value = preview;

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(ds);
                    }
                }

                // The procedure returns up to 3 result sets (Deleted_Rows only when Preview = 0),
                // so pick them by column name instead of by position.
                DataTable dtDeleted = null, dtDate = null, dtEmp = null;
                foreach (DataTable t in ds.Tables)
                {
                    if (t.Columns.Contains("Deleted_Rows")) dtDeleted = t;
                    else if (t.Columns.Contains("Absent_Count")) dtDate = t;
                    else if (t.Columns.Contains("Absent_Days")) dtEmp = t;
                }

                gvDate.DataSource = dtDate;
                gvDate.DataBind();
                gvEmp.DataSource = dtEmp;
                gvEmp.DataBind();

                int days = dtDate != null ? dtDate.Rows.Count : 0;
                int absentEntries = 0;
                if (dtDate != null)
                {
                    foreach (DataRow r in dtDate.Rows)
                        absentEntries += Convert.ToInt32(r["Absent_Count"]);
                }

                if (preview)
                {
                    lblStatus.CssClass = "note";
                    lblStatus.Text = "Preview only - no data was deleted. " + days + " day(s), " +
                                     absentEntries + " absent entries selected.";
                }
                else
                {
                    int deleted = (dtDeleted != null && dtDeleted.Rows.Count > 0)
                        ? Convert.ToInt32(dtDeleted.Rows[0]["Deleted_Rows"]) : 0;
                    lblStatus.CssClass = "note ok";
                    lblStatus.Text = "Done - " + deleted + " punch row(s) deleted for " + absentEntries +
                                     " absent entries across " + days + " day(s).";
                }
                lblStatus.Visible = true;
            }
            catch (Exception ex)
            {
                Alert(ex.Message);
            }
        }
    }
}
