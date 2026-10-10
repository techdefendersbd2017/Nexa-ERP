using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI.WebControls;

namespace Nexa_ERP.HRMPayroll.Common
{
    public class FilterItem
    {
        public string Name;
        public long Code;
    }

    public class FilterDef
    {
        public string Key;
        public string Sql;
        public string NameCol, CodeCol;
        public string DelProc, InsProc, CodeParam;
        public bool DelNeedsCode;
        public bool AltDb;
        public string[] Hint;
    }

    public class HRFilters
    {
        public const string Branch = "branch";
        public const string Category = "category";
        public const string Dept = "dept";
        public const string Section = "section";
        public const string SubSec = "subsec";
        public const string Desig = "desig";
        public const string Level = "level";
        public const string Floor = "floor";

        public const int MaxIds = 2000;

        public bool EmptyMeansAll { get; set; }
        public bool ClearUnusedFilters { get; set; }
        public readonly List<string> Errors = new List<string>();

        readonly List<FilterDef> defs;
        readonly Dictionary<string, ListControl> controls = new Dictionary<string, ListControl>();
        readonly Dictionary<string, List<FilterItem>> lookups = new Dictionary<string, List<FilterItem>>();

        public HRFilters()
        {
            EmptyMeansAll = false;
            ClearUnusedFilters = true;
            defs = BuildDefs();
        }

        static List<FilterDef> BuildDefs()
        {
            return new List<FilterDef>
            {
                new FilterDef{Key=Branch, AltDb=true, Sql="SELECT * FROM Branch_Information ORDER BY Branch_Name",
                    NameCol="Branch_Name", CodeCol="Branch_ID",
                    DelProc="Pro_Selected_Branch_Delete", InsProc="Pro_Selected_Branch", CodeParam="@Branch_Code"},

                new FilterDef{Key=Category, Sql="SELECT Catagory_Name, Catagory_Code FROM TB_Catagory ORDER BY Catagory_Name",
                    NameCol="Catagory_Name", CodeCol="Catagory_Code",
                    DelProc="Pro_Selected_Category_Delete", InsProc="Pro_Selected_Category", CodeParam="@Category_Code"},

                new FilterDef{Key=Dept, Sql="SELECT Department_Name, Department_Code FROM TB_Department ORDER BY Department_Name",
                    NameCol="Department_Name", CodeCol="Department_Code",
                    DelProc="Pro_Selected_Department_Delete", InsProc="Pro_Selected_Department", CodeParam="@Department_Code", DelNeedsCode=true},

                new FilterDef{Key=Section, Sql="SELECT Section_Name, Section_Code FROM TB_Section ORDER BY Section_Name",
                    NameCol="Section_Name", CodeCol="Section_Code",
                    DelProc="Pro_Selected_Section_Delete", InsProc="Pro_Selected_Section", CodeParam="@Section_Code"},

                new FilterDef{Key=SubSec, Sql="SELECT * FROM TB_Line ORDER BY Line_Name",
                    NameCol="Line_Name", CodeCol="Line_Code",
                    DelProc="Pro_Selected_Sub_Section_Delete", InsProc="Pro_Selected_Sub_Section", CodeParam="@Sub_Section_Code"},

                new FilterDef{Key=Desig, Sql="SELECT Desigation_name, Designation_Code FROM TB_Designation ORDER BY Desigation_name",
                    NameCol="Desigation_name", CodeCol="Designation_Code",
                    DelProc="Pro_Selected_Designation_Delete", InsProc="Pro_Selected_Designation", CodeParam="@Designation_Code"},

                new FilterDef{Key=Level, Hint=new[]{"Lavel","Level"}, Sql="SELECT * FROM Designation_Catagory",
                    NameCol="Designation_Lavel_Name", CodeCol="Designation_Lavel_ID",
                    DelProc="Pro_Selected_Designation_Delete_Lavel", InsProc="Pro_Selected_Designation_Level", CodeParam="@Designation_Lavel_ID"},

                new FilterDef{Key=Floor, Sql="SELECT * FROM TB_Floor",
                    NameCol="Floor_Name", CodeCol="Floor_ID",
                    DelProc="Pro_Selected_Floor_Delete", InsProc="Pro_Selected_Floor", CodeParam="@Floor_ID"}
            };
        }

        public HRFilters Attach(string key, ListControl control)
        {
            if (control != null) controls[key] = control;
            return this;
        }

        public void LoadLookups()
        {
            foreach (var d in defs)
                if (controls.ContainsKey(d.Key))
                    lookups[d.Key] = LoadItems(d);
        }

        public void FillControls()
        {
            foreach (var d in defs)
            {
                ListControl dd;
                if (!controls.TryGetValue(d.Key, out dd)) continue;

                dd.Items.Clear();
                foreach (var it in Lookup(d).GroupBy(i => i.Code).Select(g => g.First()).OrderBy(i => i.Name))
                    dd.Items.Add(new ListItem(it.Name, it.Code.ToString()));
            }
        }

        public void ClearSelections()
        {
            foreach (var c in controls.Values) c.ClearSelection();
        }

        List<long> SelectedCodes(ListControl dd)
        {
            var codes = new List<long>();
            foreach (ListItem li in dd.Items)
            {
                long c;
                if (li.Selected && long.TryParse(li.Value, out c) && !codes.Contains(c))
                    codes.Add(c);
            }
            return codes;
        }

        List<FilterItem> Lookup(FilterDef d)
        {
            List<FilterItem> list;
            if (!lookups.TryGetValue(d.Key, out list))
            {
                list = LoadItems(d);
                lookups[d.Key] = list;
            }
            return list;
        }

        List<FilterItem> LoadItems(FilterDef f)
        {
            var items = new List<FilterItem>();
            try
            {
                using (SqlConnection con = OpenCon(f))
                {
                    if (con.State != ConnectionState.Open) con.Open();
                    using (var da = new SqlDataAdapter(f.Sql, con))
                    {
                        var dt = new DataTable();
                        da.Fill(dt);

                        string nameCol = FindCol(dt, f.NameCol, "name");
                        string codeCol = FindCol(dt, f.CodeCol, "code", "id");

                        foreach (DataRow r in dt.Rows)
                        {
                            string name = Convert.ToString(r[nameCol]);
                            long code;
                            if (string.IsNullOrWhiteSpace(name)) continue;
                            if (!long.TryParse(Convert.ToString(r[codeCol]), out code)) continue;
                            items.Add(new FilterItem { Name = name.Trim(), Code = code });
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                string msg = ex.Message;
                if (f.Hint != null && msg.IndexOf("Invalid object name", StringComparison.OrdinalIgnoreCase) >= 0)
                    msg += " | সম্ভাব্য টেবিল: " + FindTables(f);
                Errors.Add(f.Key + ": " + msg);
            }
            return items;
        }

        static SqlConnection OpenCon(FilterDef f)
        {
            return f.AltDb ? new Database_Connection().openConnection() : new PayrollDB().openConnection();
        }

        string FindTables(FilterDef f)
        {
            try
            {
                using (SqlConnection con = OpenCon(f))
                {
                    if (con.State != ConnectionState.Open) con.Open();
                    string where = string.Join(" OR ", f.Hint.Select((h, i) => "name LIKE @h" + i));
                    using (var cmd = new SqlCommand("SELECT name FROM sys.tables WHERE " + where + " ORDER BY name", con))
                    {
                        for (int i = 0; i < f.Hint.Length; i++)
                            cmd.Parameters.AddWithValue("@h" + i, "%" + f.Hint[i] + "%");
                        var names = new List<string>();
                        using (var rd = cmd.ExecuteReader())
                            while (rd.Read()) names.Add(Convert.ToString(rd[0]));
                        return names.Count == 0 ? "(কিছু পাওয়া যায়নি)" : string.Join(", ", names);
                    }
                }
            }
            catch (Exception ex) { return "(খোঁজা যায়নি: " + ex.Message + ")"; }
        }

        static string FindCol(DataTable dt, string preferred, params string[] hints)
        {
            if (dt.Columns.Contains(preferred)) return preferred;
            foreach (string h in hints)
                foreach (DataColumn c in dt.Columns)
                    if (c.ColumnName.IndexOf(h, StringComparison.OrdinalIgnoreCase) >= 0) return c.ColumnName;
            throw new Exception("Column '" + preferred + "' not found. Available: " +
                                string.Join(", ", dt.Columns.Cast<DataColumn>().Select(c => c.ColumnName)));
        }

        static readonly Dictionary<string, string> EmpTableCols = new Dictionary<string, string>
        {
            { Branch,   "Branch_Code" },
            { Category, "Catagory_Code" },
            { Dept,     "Department_Code" },
            { Section,  "Section_Code" },
            { SubSec,   "Line_Code" },
            { Desig,    "Designation_Code" },
            { Floor,    "Floor_Code" }   // Employee_Information টেবিলে কলামের নাম মিলিয়ে নিন
        };

        string NameOf(string key, string code)
        {
            long c;
            if (!long.TryParse(code, out c)) return "";
            var d = defs.First(x => x.Key == key);
            var it = Lookup(d).FirstOrDefault(i => i.Code == c);
            return it != null ? it.Name : "";
        }

        public DataTable QueryEmployees(SqlConnection con, string status, string fromText, string tillText,
                                        string[] ids, List<string> debug)
        {
            var cmd = new SqlCommand();
            cmd.Connection = con;
            cmd.CommandTimeout = 120;

            var where = new List<string>();
            int n = 0;

            bool isAll = string.Equals(status, "All", StringComparison.OrdinalIgnoreCase);
            bool isActive = string.Equals(status, "Active", StringComparison.OrdinalIgnoreCase);
            bool byIds = ids != null && ids.Length > 0;

            if (byIds)
            {
                // ---- ID দিয়ে ----
                bool numeric = ids.All(s => { long x; return long.TryParse(s, out x); });
                var ps = new List<string>();
                foreach (string id in ids)
                {
                    string p = "@p" + (n++);
                    ps.Add(p);
                    if (numeric) cmd.Parameters.Add(p, SqlDbType.BigInt).Value = long.Parse(id);
                    else cmd.Parameters.Add(p, SqlDbType.NVarChar, 50).Value = id;
                }
                // FIX: এখানে আগে "order By ..." ছিল, যা WHERE-এর ভেতরে ঢুকে syntax error দিত।
                // Ordering নিচে শেষে একবারই দেওয়া আছে।
                where.Add("[Employee_ID_No] IN (" + string.Join(",", ps) + ")");
            }
            else
            {
                // ---- ফিল্টার ----
                foreach (var d in defs)
                {
                    ListControl dd;
                    if (!controls.TryGetValue(d.Key, out dd)) continue;
                    var codes = SelectedCodes(dd);
                    if (codes.Count == 0) continue;   // কিছু না বাছলে = All

                    var ps = new List<string>();
                    foreach (long c in codes)
                    {
                        string p = "@p" + (n++);
                        ps.Add(p);
                        cmd.Parameters.Add(p, SqlDbType.BigInt).Value = c;
                    }
                    string list = string.Join(",", ps);

                    string col;
                    if (EmpTableCols.TryGetValue(d.Key, out col))
                    {
                        where.Add("[" + col + "] IN (" + list + ")");
                    }
                    else if (d.Key == Level)
                    {
                        where.Add("[Designation_Code] IN (SELECT Designation_Code FROM TB_Designation " +
                                  "WHERE Designation_Lavel_ID IN (" + list + "))");
                    }
                }
            }

            // ঐচ্ছিক: ID দিয়ে সার্চে সব status দেখাতে চাইলে নিচের শর্তটি "if (!isAll && !byIds)" করুন।
            if (!isAll)
            {
                where.Add("[Resign_Status] = @st");
                cmd.Parameters.Add("@st", SqlDbType.NVarChar, 50).Value = status;
            }

            if (!byIds && !isAll && !isActive)
            {
                DateTime f, t;
                if (DateTime.TryParse(fromText, out f))
                {
                    where.Add("[Resign_Date] >= @fd");
                    cmd.Parameters.Add("@fd", SqlDbType.DateTime).Value = f.Date;
                }
                if (DateTime.TryParse(tillText, out t))
                {
                    where.Add("[Resign_Date] < @td");
                    cmd.Parameters.Add("@td", SqlDbType.DateTime).Value = t.Date.AddDays(1);
                }
            }

            cmd.CommandText =
                "SELECT Employee_ID_No, Name, Joining_Date, Resign_Date, Resign_Status, " +
                "Branch_Code, Department_Code, Designation_Code " +
                "FROM Employee_Information" +
                (where.Count > 0 ? " WHERE " + string.Join(" AND ", where) : "") +
                " ORDER BY Employee_ID_No";

            var raw = new DataTable();
            using (var da = new SqlDataAdapter(cmd)) da.Fill(raw);

            if (debug != null)
                debug.Add("where=" + (where.Count > 0 ? string.Join(" AND ", where) : "(none)"));

            var res = new DataTable();
            foreach (string c in new[] { "ID_no", "Name", "Designation", "Department", "Branch",
                                          "Resign_Status", "Resign_Date", "Joining_Date" })
                res.Columns.Add(c, typeof(string));

            foreach (DataRow r in raw.Rows)
            {
                var row = res.NewRow();
                row["ID_no"] = Convert.ToString(r["Employee_ID_No"]);
                row["Name"] = Convert.ToString(r["Name"]);
                row["Designation"] = NameOf(Desig, Convert.ToString(r["Designation_Code"]));
                row["Department"] = NameOf(Dept, Convert.ToString(r["Department_Code"]));
                row["Branch"] = NameOf(Branch, Convert.ToString(r["Branch_Code"]));
                row["Resign_Status"] = Convert.ToString(r["Resign_Status"]);
                row["Resign_Date"] = r["Resign_Date"] == DBNull.Value ? "" : Convert.ToDateTime(r["Resign_Date"]).ToString("yyyy-MM-dd");
                row["Joining_Date"] = r["Joining_Date"] == DBNull.Value ? "" : Convert.ToDateTime(r["Joining_Date"]).ToString("yyyy-MM-dd");
                res.Rows.Add(row);
            }
            return res;
        }

        public List<string> SaveSelections(SqlConnection con, long user, long from)
        {
            var debug = new List<string>();

            foreach (var d in defs)
            {
                ListControl dd;
                bool used = controls.TryGetValue(d.Key, out dd);
                if (!used && !ClearUnusedFilters) continue;

                var codes = new List<long>();
                if (used)
                {
                    codes = SelectedCodes(dd);
                    if (codes.Count == 0 && EmptyMeansAll)
                        codes = Lookup(d).Select(i => i.Code).Distinct().ToList();
                }

                debug.Add(d.Key + "=" + codes.Count + (codes.Count > 0 ? "[" + string.Join("|", codes) + "]" : ""));

                if (d.DelNeedsCode)
                {
                    string delParam = ResolveCodeParam(con, d.DelProc, d.CodeParam);
                    foreach (long c in Lookup(d).Select(i => i.Code).Distinct())
                        HRDb.ExecProc(con, d.DelProc, HRDb.P(delParam, c), HRDb.P("@User_Code", user), HRDb.P("@From_Code", from));
                }
                else
                {
                    HRDb.ExecProc(con, d.DelProc, HRDb.P("@User_Code", user), HRDb.P("@From_Code", from));
                }

                if (codes.Count > 0)
                {
                    string insParam = ResolveCodeParam(con, d.InsProc, d.CodeParam);
                    foreach (long c in codes)
                        HRDb.ExecProc(con, d.InsProc, HRDb.P(insParam, c), HRDb.P("@User_Code", user), HRDb.P("@From_Code", from));
                }
            }
            return debug;
        }

        static readonly Dictionary<string, string> paramCache = new Dictionary<string, string>();
        static readonly object paramLock = new object();

        static string ResolveCodeParam(SqlConnection con, string proc, string preferred)
        {
            string key = proc + "|" + preferred, cached;
            lock (paramLock) { if (paramCache.TryGetValue(key, out cached)) return cached; }

            string result = preferred;
            try
            {
                using (var cmd = new SqlCommand(proc, con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    SqlCommandBuilder.DeriveParameters(cmd);

                    var names = cmd.Parameters.Cast<SqlParameter>()
                                   .Select(p => p.ParameterName)
                                   .Where(n => !n.Equals("@RETURN_VALUE", StringComparison.OrdinalIgnoreCase))
                                   .ToList();

                    if (!names.Any(n => n.Equals(preferred, StringComparison.OrdinalIgnoreCase)))
                    {
                        string other = names.FirstOrDefault(n =>
                            !n.Equals("@User_Code", StringComparison.OrdinalIgnoreCase) &&
                            !n.Equals("@From_Code", StringComparison.OrdinalIgnoreCase));
                        if (other != null) result = other;
                    }
                }
            }
            catch { }

            lock (paramLock) { paramCache[key] = result; }
            return result;
        }

        public static long SessionLong(params string[] keys)
        {
            var s = HttpContext.Current != null ? HttpContext.Current.Session : null;
            if (s == null) return 0;
            foreach (string k in keys)
            {
                long v;
                object o = s[k];
                if (o != null && long.TryParse(Convert.ToString(o), out v) && v != 0) return v;
            }
            return 0;
        }

        public static long UserCode
        {
            get { return SessionLong("User_Code", "UserCode", "User_ID", "UserID", "userid"); }
        }

        public static string[] ParseIds(string text)
        {
            if (string.IsNullOrWhiteSpace(text)) return new string[0];
            return text.Split(new[] { ',', ';', '\n', '\r', ' ', '\t' }, StringSplitOptions.RemoveEmptyEntries)
                       .Select(s => s.Trim().Trim('\'', '"'))
                       .Where(s => s.Length > 0)
                       .Distinct(StringComparer.OrdinalIgnoreCase)
                       .ToArray();
        }
    }

    public static class HRDb
    {
        public static SqlParameter P(string name, long value)
        {
            return new SqlParameter(name, SqlDbType.BigInt) { Value = value };
        }

        public static void ExecProc(SqlConnection con, string proc, params SqlParameter[] ps)
        {
            using (var cmd = new SqlCommand(proc, con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddRange(ps);
                cmd.ExecuteNonQuery();
            }
        }
    }
}