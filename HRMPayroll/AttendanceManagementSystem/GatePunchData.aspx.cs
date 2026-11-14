using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Text;
using System.Text.RegularExpressions;
using System.Web.Script.Serialization;
using System.Web.UI;

namespace Nexa_ERP.HRMPayroll.AttendanceManagementSystem
{
    public partial class GatePunchData : System.Web.UI.Page
    {
        // web.config <connectionStrings> names - change these to match your project
        private const string CS_ZK = "ZkTechDB";          // database that has view Punch_View
        private const string CS_HIK = "HikvisionDB";      // database that has table attlog
        private const string CS_PAYROLL = "HRPayrollDB";  // HR_PAYROLL_DB (Lock_Months + Pro_Punch_data)

        private const int MaxIds = 1000;
        private const int MaxTransferRows = 50000;
        private const string TimeFormat = "yyyy-MM-dd HH:mm:ss";

        private class PunchRow
        {
            public string id { get; set; }
            public string time { get; set; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtFrom.Text = DateTime.Today.ToString("yyyy-MM-dd");
                txtTill.Text = DateTime.Today.ToString("yyyy-MM-dd");
            }
        }

        /* =========================================================
           Load Punch Data From Machine
           ========================================================= */
        protected void btnLoad_Click(object sender, EventArgs e)
        {
            try
            {
                DateTime from, till;
                if (!TryDate(txtFrom.Text, out from) || !TryDate(txtTill.Text, out till))
                {
                    Notify("error", "Please select valid From Date and Till Date.");
                    return;
                }
                if (from > till)
                {
                    Notify("error", "From Date cannot be later than Till Date.");
                    return;
                }

                List<string> ids;
                if (!TryParseIds(txtIds.Text, out ids))
                {
                    Notify("error", "ID can contain only numbers separated by comma, space or new line (maximum " + MaxIds + " IDs).");
                    return;
                }

                bool zk = ddlMachine.SelectedValue == "Zk";
                string csName = zk ? CS_ZK : CS_HIK;

                var sql = new StringBuilder();
                if (zk)
                    sql.Append("SELECT BADGENUMBER AS EmpId, NAME AS EmpName, MachineAlias AS Machine, CHECKTIME AS PunchTime FROM Punch_View WHERE CHECKTIME >= @from AND CHECKTIME < @till");
                else
                    sql.Append("SELECT employeeID AS EmpId, personName AS EmpName, deviceName AS Machine, authDateTime AS PunchTime FROM attlog WHERE authDateTime >= @from AND authDateTime < @till");

                var list = new List<Dictionary<string, string>>();

                using (var con = new SqlConnection(GetConnectionString(csName)))
                using (var cmd = new SqlCommand())
                {
                    cmd.Connection = con;
                    cmd.Parameters.Add("@from", SqlDbType.DateTime).Value = from.Date;
                    cmd.Parameters.Add("@till", SqlDbType.DateTime).Value = till.Date.AddDays(1);   // inclusive of the whole Till Date

                    if (ids.Count > 0)
                    {
                        var names = new List<string>();
                        for (int i = 0; i < ids.Count; i++)
                        {
                            string p = "@id" + i;
                            names.Add(p);
                            cmd.Parameters.Add(p, SqlDbType.BigInt).Value = long.Parse(ids[i], CultureInfo.InvariantCulture);
                        }
                        sql.Append(" AND " + (zk ? "BADGENUMBER" : "employeeID") + " IN (" + string.Join(",", names) + ")");
                    }
                    sql.Append(" ORDER BY PunchTime");
                    cmd.CommandText = sql.ToString();
                    cmd.CommandTimeout = 120;

                    con.Open();
                    using (var rd = cmd.ExecuteReader())
                    {
                        while (rd.Read())
                        {
                            if (rd["PunchTime"] == DBNull.Value) continue;
                            DateTime t = Convert.ToDateTime(rd["PunchTime"]);
                            list.Add(new Dictionary<string, string>
                            {
                                { "id", Convert.ToString(rd["EmpId"]).Trim() },
                                { "name", Convert.ToString(rd["EmpName"]).Trim() },
                                { "machine", Convert.ToString(rd["Machine"]).Trim() },
                                { "time", t.ToString(TimeFormat, CultureInfo.InvariantCulture) }
                            });
                        }
                    }
                }

                hfRows.Value = Json().Serialize(list);

                if (list.Count == 0)
                    Notify("error", "No punch data found for the selected dates.");
                else
                    Notify("ok", list.Count + " punch records loaded.");
            }
            catch (Exception ex)
            {
                Notify("error", "Unable to load punch data: " + ex.Message);
            }
        }

        /* =========================================================
           Transfer To Payroll Database
           ========================================================= */
        protected void btnTransfer_Click(object sender, EventArgs e)
        {
            try
            {
                if (string.IsNullOrEmpty(hfSelected.Value))
                {
                    Notify("error", "Please select at least one row to transfer.");
                    return;
                }

                var picked = Json().Deserialize<List<PunchRow>>(hfSelected.Value);
                if (picked == null || picked.Count == 0)
                {
                    Notify("error", "Please select at least one row to transfer.");
                    return;
                }
                if (picked.Count > MaxTransferRows)
                {
                    Notify("error", "Too many rows (" + picked.Count + "). Maximum " + MaxTransferRows + " rows can be transferred at a time.");
                    return;
                }

                // validate every row first
                var ids = new List<long>(picked.Count);
                var times = new List<DateTime>(picked.Count);
                var months = new SortedDictionary<string, DateTime>();
                foreach (var r in picked)
                {
                    long id; DateTime t;
                    if (!long.TryParse(r.id, NumberStyles.None, CultureInfo.InvariantCulture, out id) ||
                        !DateTime.TryParseExact(r.time, TimeFormat, CultureInfo.InvariantCulture, DateTimeStyles.None, out t))
                    {
                        Notify("error", "Invalid data found (ID: " + r.id + ", Time: " + r.time + "). Please load the data again.");
                        return;
                    }
                    ids.Add(id);
                    times.Add(t);
                    months[t.ToString("yyyyMM")] = new DateTime(t.Year, t.Month, 1);
                }

                using (var con = new SqlConnection(GetConnectionString(CS_PAYROLL)))
                {
                    con.Open();

                    // ---- Lock month check (every month that appears in the selected rows) ----
                    foreach (var m in months.Values)
                    {
                        using (var chk = new SqlCommand(
                            "SELECT COUNT(*) FROM Lock_Months WHERE DATEPART(Month, Lock_Month) = @m AND DATEPART(Year, Lock_Month) = @y", con))
                        {
                            chk.Parameters.Add("@m", SqlDbType.Int).Value = m.Month;
                            chk.Parameters.Add("@y", SqlDbType.Int).Value = m.Year;
                            if (Convert.ToInt32(chk.ExecuteScalar()) > 0)
                            {
                                Notify("error", m.ToString("MMM-yyyy", CultureInfo.InvariantCulture) + " is locked. Transfer cancelled.");
                                return;
                            }
                        }
                    }

                    // ---- Transfer (all or nothing) ----
                    using (var tx = con.BeginTransaction())
                    {
                        try
                        {
                            using (var cmd = new SqlCommand("Pro_Punch_data", con, tx))
                            {
                                cmd.CommandType = CommandType.StoredProcedure;
                                cmd.CommandTimeout = 300;
                                var pId = cmd.Parameters.Add("@Id_no", SqlDbType.BigInt);
                                var pDate = cmd.Parameters.Add("@punch_Date", SqlDbType.DateTime);
                                var pTime = cmd.Parameters.Add("@punch_time", SqlDbType.DateTime);

                                for (int i = 0; i < ids.Count; i++)
                                {
                                    pId.Value = ids[i];
                                    pDate.Value = times[i];
                                    pTime.Value = times[i];
                                    cmd.ExecuteNonQuery();
                                }
                            }
                            tx.Commit();
                        }
                        catch
                        {
                            tx.Rollback();
                            throw;
                        }
                    }
                }

                hfRows.Value = "";       // clear the grid after a successful transfer
                hfSelected.Value = "";
                Notify("ok", "Punch Gate successful (" + ids.Count + " records transferred).");
            }
            catch (Exception ex)
            {
                Notify("error", "Transfer failed, no data was saved: " + ex.Message);
            }
        }

        /* =========================================================
           Helpers
           ========================================================= */
        private static JavaScriptSerializer Json()
        {
            return new JavaScriptSerializer { MaxJsonLength = int.MaxValue };
        }

        private static string GetConnectionString(string name)
        {
            var cs = ConfigurationManager.ConnectionStrings[name];
            if (cs == null || string.IsNullOrWhiteSpace(cs.ConnectionString))
                throw new ConfigurationErrorsException("Connection string '" + name + "' was not found in web.config.");
            return cs.ConnectionString;
        }

        private static bool TryDate(string text, out DateTime value)
        {
            return DateTime.TryParseExact((text ?? "").Trim(), "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out value);
        }

        // Accepts "101, 102 103\n104". Digits only, so the values are safe to send as SQL parameters.
        private static bool TryParseIds(string text, out List<string> ids)
        {
            ids = new List<string>();
            if (string.IsNullOrWhiteSpace(text)) return true;

            var seen = new HashSet<string>();
            foreach (var part in Regex.Split(text.Trim(), @"[\s,;]+"))
            {
                if (part.Length == 0) continue;
                long n;
                if (!Regex.IsMatch(part, @"^\d{1,18}$") || !long.TryParse(part, NumberStyles.None, CultureInfo.InvariantCulture, out n))
                    return false;
                if (seen.Add(part)) ids.Add(part);
            }
            return ids.Count <= MaxIds;
        }

        private void Notify(string type, string message)
        {
            var js = Json();
            string script = "window.addEventListener('load',function(){window.pdNotify(" +
                            js.Serialize(type) + "," + js.Serialize(message) + ");});";
            ScriptManager.RegisterStartupScript(this, GetType(), "pdNotify" + Guid.NewGuid().ToString("N"), script, true);
        }
    }
}
