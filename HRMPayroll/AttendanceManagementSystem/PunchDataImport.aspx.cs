using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;

namespace Nexa_ERP.HRMPayroll.HRConfiguration.HRMSetting
{
    public partial class PunchDataImport : System.Web.UI.Page
    {
        PayrollDB conn = new PayrollDB();

        // আপনার ফাইলের Date/Time ফরম্যাট অনুযায়ী এখানে ফরম্যাট যোগ/পরিবর্তন করুন
        private static readonly string[] DateFormats =
        {
            "dd-MMM-yyyy",   // client-side page always sends dates in this format now, e.g. "09-Jan-2026"
            "yyyy-MM-dd", "dd/MM/yyyy", "d/M/yyyy", "yyyy/MM/dd", "dd-MM-yyyy", "d-M-yyyy"
        };

        private static readonly string[] TimeFormats =
        {
            "HH:mm:ss", "H:mm:ss", "HH:mm", "H:mm", "h:mm:ss tt", "hh:mm:ss tt", "h:mm tt", "hh:mm tt"
        };

        // [নতুন] একই কলামে Date ও Time একসাথে থাকলে (যেমন "2026-10-19 20:37:56" - Original Records Report.csv)
        private static readonly string[] DateTimeFormats =
        {
            "yyyy-MM-dd HH:mm:ss", "yyyy-MM-dd H:mm:ss", "yyyy-MM-dd HH:mm", "yyyy-MM-dd H:mm",
            "yyyy-MM-dd'T'HH:mm:ss",
            "dd-MMM-yyyy HH:mm:ss", "dd/MM/yyyy HH:mm:ss", "d/M/yyyy H:mm:ss",
            "dd/MM/yyyy hh:mm:ss tt", "d/M/yyyy h:mm:ss tt", "M/d/yyyy h:mm:ss tt"
        };

        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void btnImport_Click(object sender, EventArgs e)
        {
            try
            {
                string json = hfPunchData.Value;
                if (string.IsNullOrWhiteSpace(json))
                {
                    Alert("No data received. Please select a file and try again.");
                    return;
                }

                // Rows sent by the page: [{ No, StaffCode, Name, Department, UserID, Week, Date, Time, MachineID }, ...]
                // [নতুন] CSV ফরম্যাটে: [{ "Person ID", Name, Department, Time(Date+Time একসাথে), ... }, ...] ও চলবে
                var serializer = new JavaScriptSerializer { MaxJsonLength = int.MaxValue };
                List<Dictionary<string, string>> rows = serializer.Deserialize<List<Dictionary<string, string>>>(json);

                if (rows == null || rows.Count == 0)
                {
                    Alert("No rows found to import.");
                    return;
                }

                DataTable dt = BuildTable(rows);

                int saved;
                List<string> errors;
                SavePunchData(dt, out saved, out errors);

                hfPunchData.Value = string.Empty;

                string msg = saved + " row(s) imported successfully.";
                if (errors.Count > 0)
                {
                    int show = Math.Min(errors.Count, 10);
                    msg += "\n\n" + errors.Count + " row(s) skipped:\n"
                           + string.Join("\n", errors.GetRange(0, show).ToArray());
                    if (errors.Count > show) msg += "\n...";
                }
                Alert(msg);
            }
            catch (Exception ex)
            {
                Alert("Import failed: " + ex.Message);
            }
        }

        /// <summary>
        /// প্রতিটি row এর জন্য Pro_Punch_data_Web কল করে। সব একটি Transaction-এর ভেতরে,
        /// তাই মাঝপথে error হলে কিছুই save হবে না (Rollback)।
        /// </summary>
        private void SavePunchData(DataTable dt, out int saved, out List<string> errors)
        {
            saved = 0;
            errors = new List<string>();

            using (SqlConnection con = conn.openConnection())
            {
                if (con.State != ConnectionState.Open)
                    con.Open();

                using (SqlTransaction tran = con.BeginTransaction())
                using (SqlCommand cmd = new SqlCommand("Pro_Punch_data_Web", con, tran))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandTimeout = 300;

                    SqlParameter pId = cmd.Parameters.Add("@ID_no", SqlDbType.BigInt);
                    SqlParameter pDate = cmd.Parameters.Add("@punch_date", SqlDbType.DateTime);
                    SqlParameter pTime = cmd.Parameters.Add("@punch_time", SqlDbType.DateTime);

                    try
                    {
                        int line = 0;
                        foreach (DataRow r in dt.Rows)
                        {
                            line++;

                            long idNo;
                            DateTime date, time;

                            // ID_no হিসেবে UserID ব্যবহার হয়েছে। StaffCode লাগলে "UserID" এর জায়গায় "StaffCode" দিন।
                            if (!long.TryParse(r["UserID"].ToString(), out idNo))
                            {
                                errors.Add("Row " + line + ": invalid User ID '" + r["UserID"] + "'");
                                continue;
                            }

                            if (!DateTime.TryParseExact(r["PunchDate"].ToString(), DateFormats,
                                    CultureInfo.InvariantCulture, DateTimeStyles.None, out date))
                            {
                                errors.Add("Row " + line + ": invalid Date '" + r["PunchDate"] + "'");
                                continue;
                            }

                            if (!DateTime.TryParseExact(r["PunchTime"].ToString(), TimeFormats,
                                    CultureInfo.InvariantCulture, DateTimeStyles.None, out time))
                            {
                                errors.Add("Row " + line + ": invalid Time '" + r["PunchTime"] + "'");
                                continue;
                            }

                            pId.Value = idNo;
                            pDate.Value = date.Date;
                            // Procedure এ (@punch_date + @punch_time) যোগ হয়, তাই time এর date অংশ 1900-01-01 (= 0) রাখা হয়েছে
                            pTime.Value = new DateTime(1900, 1, 1) + time.TimeOfDay;

                            cmd.ExecuteNonQuery();
                            saved++;
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

        private static DataTable BuildTable(List<Dictionary<string, string>> rows)
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("StaffCode", typeof(string));
            dt.Columns.Add("Name", typeof(string));
            dt.Columns.Add("Department", typeof(string));
            dt.Columns.Add("UserID", typeof(string));
            dt.Columns.Add("Week", typeof(string));
            dt.Columns.Add("PunchDate", typeof(string));
            dt.Columns.Add("PunchTime", typeof(string));
            dt.Columns.Add("MachineID", typeof(string));

            foreach (var r in rows)
            {
                // আগের ফরম্যাট: UserID, Date, Time আলাদা কলামে আসে
                string userId = Get(r, "UserID");
                string date = Get(r, "Date");
                string time = Get(r, "Time");

                // [নতুন] CSV ফরম্যাট: "Person ID" (শুরুতে ' থাকে, যেমন '100)
                if (userId.Length == 0)
                    userId = Get(r, "PersonID");
                if (userId.Length == 0)
                    userId = Get(r, "Person ID");
                userId = userId.TrimStart('\'', '"', ' ');

                // [নতুন] Date খালি থাকলে এবং Time কলামে Date+Time একসাথে থাকলে ভেঙে নেওয়া হয়
                // যেমন "2026-10-19 20:37:56" → Date "19-Oct-2026", Time "20:37:56"
                if (date.Length == 0 && time.Length > 0)
                {
                    DateTime dtm;
                    if (DateTime.TryParseExact(time, DateTimeFormats,
                            CultureInfo.InvariantCulture, DateTimeStyles.None, out dtm))
                    {
                        date = dtm.ToString("dd-MMM-yyyy", CultureInfo.InvariantCulture);
                        time = dtm.ToString("HH:mm:ss", CultureInfo.InvariantCulture);
                    }
                }

                dt.Rows.Add(
                    Get(r, "StaffCode"),
                    Get(r, "Name"),
                    Get(r, "Department"),
                    userId,
                    Get(r, "Week"),
                    date,
                    time,
                    Get(r, "MachineID"));
            }
            return dt;
        }

        private static string Get(Dictionary<string, string> row, string key)
        {
            string v;
            return row.TryGetValue(key, out v) && v != null ? v.Trim() : string.Empty;
        }

        private void Alert(string message)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert",
                "alert('" + HttpUtility.JavaScriptStringEncode(message) + "');", true);
        }
    }
}
