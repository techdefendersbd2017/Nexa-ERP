using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.HRMPayroll.HRMPayrollReports
{
    public partial class HRMReports : Page
    {
        // ---------------------------------------------------------------
        // aspx এ যা যোগ করতে হবে (একবারই):
        //
        // 1) HiddenField:
        //    <asp:HiddenField ID="hfSelIds" runat="server" />
        //
        // 2) Repeater এর প্রতিটি সারির চেকবক্স:
        //    <input type="checkbox" class="row-checkbox" data-id='<%# Eval("Id") %>' />
        //
        // 3) Report বাটনে:  OnClientClick="collectIds();"
        //
        // 4) Script:
        //    function collectIds(){
        //      var ids=[];
        //      document.querySelectorAll('.row-checkbox:checked').forEach(function(c){
        //        var id=c.getAttribute('data-id'); if(id) ids.push(id);
        //      });
        //      document.getElementById('<%= hfSelIds.ClientID %>').value = ids.join(',');
        //    }
        // ---------------------------------------------------------------

        PayrollDB conn = new PayrollDB();

        // কোনো ফিল্টারে কিছু নির্বাচন না করলে: true = সব ধরা হবে, false = কিছুই insert হবে না
        const bool EmptyMeansAll = false;
        const int MaxIds = 2000;   // SQL Server এর parameter সীমা ২১০০

        readonly List<string> loadErrors = new List<string>();

        // সমস্যা মিটে গেলে false করে দিন
        const bool ShowDebug = true;
        readonly List<string> debug = new List<string>();

        // ---------- মডেল ----------
        public class Emp
        {
            public string Id { get; set; }
            public string Name { get; set; }
            public string Designation { get; set; }
            public string Department { get; set; }
            public string Branch { get; set; }
            public string Status { get; set; }
        }

        class Item { public string Name; public long Code; }

        class Filt
        {
            public string Key;
            public ListControl Dd;     // ListBox (Multiple) ও DropDownList দুটোই ধরে
            public string Sql;
            public string NameCol, CodeCol;
            public string DelProc, InsProc, CodeParam;
            public bool DelNeedsCode;
            public bool AltDb;
            public string[] Hint;
        }

        List<Filt> Filters()
        {
            return new List<Filt>
            {
                new Filt{Key="branch",   Dd=ddBranch,   AltDb=true, Sql="SELECT * FROM Branch_Information ORDER BY Branch_Name",
                         NameCol="Branch_Name", CodeCol="Branch_ID",
                         DelProc="Pro_Selected_Branch_Delete", InsProc="Pro_Selected_Branch", CodeParam="@Branch_Code"},

                new Filt{Key="category", Dd=ddCategory, Sql="SELECT Catagory_Name, Catagory_Code FROM TB_Catagory ORDER BY Catagory_Name",
                         NameCol="Catagory_Name", CodeCol="Catagory_Code",
                         DelProc="Pro_Selected_Category_Delete", InsProc="Pro_Selected_Category", CodeParam="@Category_Code"},

                new Filt{Key="dept",     Dd=ddDept,     Sql="SELECT Department_Name, Department_Code FROM TB_Department ORDER BY Department_Name",
                         NameCol="Department_Name", CodeCol="Department_Code",
                         DelProc="Pro_Selected_Department_Delete", InsProc="Pro_Selected_Department", CodeParam="@Department_Code", DelNeedsCode=true},

                new Filt{Key="section",  Dd=ddSection,  Sql="SELECT Section_Name, Section_Code FROM TB_Section ORDER BY Section_Name",
                         NameCol="Section_Name", CodeCol="Section_Code",
                         DelProc="Pro_Selected_Section_Delete", InsProc="Pro_Selected_Section", CodeParam="@Section_Code"},

                // TODO: টেবিল ও কলামের নাম মিলিয়ে নিন
                new Filt{Key="subsec",   Dd=ddSubSec,   Sql="SELECT * FROM TB_Line ORDER BY Line_Name",
                         NameCol="Line_Name", CodeCol="Line_Code",
                         DelProc="Pro_Selected_Sub_Section_Delete", InsProc="Pro_Selected_Sub_Section", CodeParam="@Sub_Section_Code"},

                new Filt{Key="desig",    Dd=ddDesig,    Sql="SELECT Desigation_name, Designation_Code FROM TB_Designation ORDER BY Desigation_name",
                         NameCol="Desigation_name", CodeCol="Designation_Code",
                         DelProc="Pro_Selected_Designation_Delete", InsProc="Pro_Selected_Designation", CodeParam="@Designation_Code"},

                // TODO: টেবিল ও কলামের নাম মিলিয়ে নিন
                new Filt{Key="level",    Dd=ddLevel,    Hint=new[]{"Lavel","Level"}, Sql="SELECT * FROM Designation_Catagory",
                         NameCol="Designation_Lavel_Name", CodeCol="Designation_Lavel_ID",
                         DelProc="Pro_Selected_Designation_Delete_Lavel", InsProc="Pro_Selected_Designation_Level", CodeParam="@Designation_Lavel_ID"},

                // TODO: টেবিল ও কলামের নাম মিলিয়ে নিন
                new Filt{Key="floor",    Dd=ddFloor,    Sql="SELECT * FROM TB_Floor",
                         NameCol="Floor_Name", CodeCol="Floor_ID",
                         DelProc="Pro_Selected_Floor_Delete", InsProc="Pro_Selected_Floor", CodeParam="@Floor_ID"}
            };
        }

        readonly Dictionary<string, List<Item>> lookups = new Dictionary<string, List<Item>>();

        // TODO: আপনার Login/Session এর key অনুযায়ী বদলান
        long UserCode { get { return SessionLong("User_Code", "UserCode", "User_ID", "UserID", "userid"); } }
        long FromCode { get { return SessionLong("From_Code", "FromCode"); } }

        long SessionLong(params string[] keys)
        {
            foreach (string k in keys)
            {
                long v = ToLong(Session[k]);
                if (v != 0) return v;
            }
            return 0;
        }

        static long ToLong(object o)
        {
            long v;
            return o != null && long.TryParse(Convert.ToString(o), out v) ? v : 0;
        }

        // ================= Page Load =================
        protected void Page_Load(object sender, EventArgs e)
        {
            LoadLookups();   // কোড খোঁজার জন্য প্রতিটি request এ লাগে

            // পোস্টব্যাকের পর আগের টিক ফিরিয়ে আনা (checkbox এ runat="server" নেই বলে ASP.NET টিক মনে রাখে না)
            if (IsPostBack && !string.IsNullOrEmpty(SelectedIdsRaw()))
            {
                string arr = new JavaScriptSerializer().Serialize(SelectedIdsRaw().Split(','));
                ClientScript.RegisterStartupScript(GetType(), "retick",
                    "document.addEventListener('DOMContentLoaded',function(){var ids=" + arr +
                    ";document.querySelectorAll('.row-checkbox').forEach(function(c){" +
                    "if(ids.indexOf(c.getAttribute('data-id'))>=0)c.checked=true;});});", true);
            }

            if (!IsPostBack)
            {
                FillDropDowns();
                ResetDefaults();
                ClearGrid();
            }

            if (IsPostBack && loadErrors.Count > 0)
                Toast("Option load error: " + string.Join(" | ", loadErrors));
        }

        void LoadLookups()
        {
            foreach (var f in Filters())
                lookups[f.Key] = LoadItems(f);   // প্রতিটি ফিল্টার নিজের connection এ লোড হয়
        }

        // ফিল্টার ভরা: Text = নাম, Value = কোড (মাল্টিপল সিলেক্ট; কিছু না বাছলে = All)
        void FillDropDowns()
        {
            foreach (var f in Filters())
            {
                f.Dd.Items.Clear();
                foreach (var it in lookups[f.Key].GroupBy(i => i.Code).Select(g => g.First()).OrderBy(i => i.Name))
                    f.Dd.Items.Add(new ListItem(it.Name, it.Code.ToString()));
            }

            FillStatic(ddBlood, "-- All --", "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-");
            FillStatic(ddReligion, "-- All --", "Islam", "Hinduism", "Buddhism", "Christianity", "Others");
            // TODO: comboBox_Resign_Status এর আইটেমের সঙ্গে হুবহু মিলিয়ে নিন (প্রথমটি ডিফল্ট)
            FillStatic(ddStatus, null, "Active", "New", "Seperation", "All", "Resign", "Left");

            // [পরিবর্তন] Report Type এখন ডাটাবেস থেকে লোড হয় (View_User_Access_Reports)
            LoadReportTypes();

            if (loadErrors.Count > 0)
                Toast("Option load error: " + string.Join(" | ", loadErrors));
        }

        // [পরিবর্তন - নতুন] WinForms এর comboBox2 এর মতো: Text = Report_Name, Value = Report_Code
        // Report_Name এর নাম ResolveReport এর নামের সঙ্গে হুবহু মিলতে হবে
        void LoadReportTypes()
        {
            ddRType.Items.Clear();
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();

                    using (var cmd = new SqlCommand(
                        "SELECT Report_Code, Report_Name FROM Soft_Reports " +
                        "WHERE Menu=1   ORDER BY Report_Name ASC", con))// AND user_id=@uid
                    {
                        cmd.Parameters.Add("@uid", SqlDbType.NVarChar, 50).Value = UserCode.ToString();

                        var dt = new DataTable();
                        using (var da = new SqlDataAdapter(cmd)) da.Fill(dt);

                        foreach (DataRow r in dt.Rows)
                        {
                            string name = Convert.ToString(r["Report_Name"]);
                            if (string.IsNullOrWhiteSpace(name)) continue;
                            ddRType.Items.Add(new ListItem(name.Trim(), Convert.ToString(r["Report_Code"])));
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                loadErrors.Add("reportType: " + ex.Message);
            }
        }

        // [পরিবর্তন - নতুন] নির্বাচিত Report Type এর নাম (Value এখন কোড, তাই Text নিতে হয়)
        string RTypeText()
        {
            return ddRType.SelectedItem != null ? ddRType.SelectedItem.Text.Trim() : "";
        }

        static void FillStatic(DropDownList dd, string blank, params string[] items)
        {
            dd.Items.Clear();
            if (blank != null) dd.Items.Add(new ListItem(blank, ""));
            foreach (string s in items) dd.Items.Add(new ListItem(s, s));
        }

        List<Item> LoadItems(Filt f)
        {
            var items = new List<Item>();
            try
            {
                using (SqlConnection con = f.AltDb ? new Database_Connection().openConnection() : conn.openConnection())
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
                            items.Add(new Item { Name = name.Trim(), Code = code });
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                string msg = ex.Message;
                if (f.Hint != null && msg.IndexOf("Invalid object name", StringComparison.OrdinalIgnoreCase) >= 0)
                    msg += " | সম্ভাব্য টেবিল: " + FindTables(f);
                loadErrors.Add(f.Key + ": " + msg);
            }
            return items;
        }

        string FindTables(Filt f)
        {
            try
            {
                using (SqlConnection con = f.AltDb ? new Database_Connection().openConnection() : conn.openConnection())
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

        // ================= বাটন ইভেন্ট =================
        protected void btnShow_Click(object sender, EventArgs e)
        {
            ShowData();
        }

        // ===== নতুন রিপোর্ট যোগ করতে শুধু এখানে একটি else if বসান =====
        // page    : রিপোর্ট পেজের পথ
        // formCode: z_Test_ID এর From_Code (WinForms এর prm এ যা ছিল; পেজের FromCode এর সঙ্গে মিলতে হবে)
        // needIds : true হলে গ্রিড থেকে কর্মচারী নির্বাচন লাগবে, false হলে লাগবে না
        static bool ResolveReport(string name, out string page, out int formCode, out bool needIds)
        {
            page = null; formCode = 0; needIds = true;

            if (name == "Active Employee  List")
            { page = "HRReports/ActiveEmployeeListReport.aspx"; formCode = 7; needIds = true; }  // ActiveEmployeeListReport.aspx.cs এর ReportFormCode এর সঙ্গে মিলতে হবে
            else if (name == "Appointment Latter")
            { page = "HRReports/AppointmentLetter.aspx"; formCode = 2; needIds = true; }       // WinForms: From_Code=2
            else if (name == "Active Employee List with Last Increment")
            { page = "HRReports/ActiveEmployeeListLastIncrement.aspx"; formCode = 3; needIds = true; }      // TODO
            else if (name == "Designation Roster")
            { page = "HRReports/DesignationRoster.aspx"; formCode = 4; needIds = true; }       // TODO
            else if (name == "Blood Group Directory")
            { page = "HRReports/BloodGroup.aspx"; formCode = 5; needIds = true; }              // TODO
            else if (name == "Joining Status Report")
            { page = "HRReports/JoiningStatus.aspx"; formCode = 6; needIds = true; }           // TODO
            else
                return false;   // তালিকায় নেই

            return true;
        }

        protected void btnReport_Click(object sender, EventArgs e)
        {
            string page; int formCode; bool needIds;

            // [পরিবর্তন] SelectedValue এখন Report_Code, তাই নাম নেওয়া হচ্ছে Text থেকে
            string rt = RTypeText();

            if (ResolveReport(rt, out page, out formCode, out needIds))
                OpenReport(page, formCode, needIds);
            else if (ShowData())
                // এই বার্তা মানে: নির্বাচিত Report Type আলাদা পেজের তালিকায় নেই, তাই সাধারণ তালিকা দেখানো হলো
                Toast("Report generated successfully! (Type: " + rt + ")");
        }

        // টিক দেওয়া ID গুলো: প্রথমে চেকবক্সের name="selId" (ব্রাউজার নিজেই পাঠায়, JS লাগে না), না পেলে hfSelIds
        string SelectedIdsRaw()
        {
            string[] fromForm = Request.Form.GetValues("selId");
            if (fromForm != null && fromForm.Length > 0)
                return string.Join(",", fromForm);
            return hfSelIds.Value ?? "";
        }

        // সব রিপোর্টের জন্য একই: নির্বাচিত ID z_Test_ID তে সেভ করে পেজ খোলা
        void OpenReport(string page, int formCode, bool needIds)
        {
            if (UserCode == 0)
            {
                Toast("User_Code পাওয়া যায়নি (Session)। Login করে আবার চেষ্টা করুন।");
                return;
            }

            long[] ids = ParseIds(SelectedIdsRaw())
                .Select(s => { long x; return long.TryParse(s, out x) ? x : 0; })
                .Where(x => x != 0).Distinct().ToArray();

            if (needIds && ids.Length == 0)
            {
                Toast("কমপক্ষে একজন কর্মচারী নির্বাচন করুন।");
                return;
            }

            if (ids.Length > MaxIds)
            {
                Toast("Too many IDs (max " + MaxIds + ").");
                return;
            }

            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();

                    // শুধু এই ইউজার + এই রিপোর্টের আগের নির্বাচন মোছে, অন্য রিপোর্টের ডাটা অক্ষত থাকে
                    using (var del = new SqlCommand(
                        "DELETE FROM dbo.z_Test_ID WHERE User_ID=@u AND From_Code=@f", con))
                    {
                        del.Parameters.Add("@u", SqlDbType.BigInt).Value = UserCode;
                        del.Parameters.Add("@f", SqlDbType.BigInt).Value = formCode;
                        del.ExecuteNonQuery();
                    }

                    if (needIds)
                    {
                        foreach (long id in ids)
                            ExecProc(con, "Pro_z_Test_ID_New",
                                P("@ID_No", id), P("@User_ID", UserCode), P("@Form_Code", formCode));
                    }
                }
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message);
                return;
            }

            Response.Redirect(page, false);
            Context.ApplicationInstance.CompleteRequest();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ResetDefaults();
            ClearGrid();
            Toast("All filters cleared.");
        }

        // ================= Show এর মূল লজিক =================
        bool ShowData()
        {
            DataTable dt;
            string status = string.IsNullOrEmpty(ddStatus.SelectedValue) ? "Active" : ddStatus.SelectedValue;

            try
            {
                string[] ids = ParseIds(txtMultiId.Text);

                if (ids.Length > MaxIds)
                {
                    Toast("Too many IDs (max " + MaxIds + ").");
                    return false;
                }

                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();

                    if (ids.Length > 0)
                    {
                        dt = QueryByIds(con, ids, status);
                    }
                    else
                    {
                        if (UserCode == 0)
                        {
                            Toast("User_Code পাওয়া যায়নি (Session)। Login করে আবার চেষ্টা করুন।");
                            return false;
                        }
                        SaveSelections(con);
                        dt = RunStatusProc(con, status);
                        debug.Add("user=" + UserCode + ", fromCode=" + FromCode + ", status=" + status + ", rows=" + dt.Rows.Count);
                    }
                }
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message);
                return false;
            }

            if (ShowDebug && debug.Count > 0)
                Toast("Debug → " + string.Join(", ", debug));

            BindTable(dt, status);
            return true;
        }

        DataTable QueryByIds(SqlConnection con, string[] ids, string status)
        {
            bool numeric = ids.All(s => { long x; return long.TryParse(s, out x); });

            using (var cmd = new SqlCommand())
            {
                cmd.Connection = con;
                var names = new List<string>();
                for (int i = 0; i < ids.Length; i++)
                {
                    string p = "@id" + i;
                    names.Add(p);
                    if (numeric) cmd.Parameters.Add(p, SqlDbType.BigInt).Value = long.Parse(ids[i]);
                    else cmd.Parameters.Add(p, SqlDbType.NVarChar, 50).Value = ids[i];
                }

                string sql = "SELECT ID_no, Name, Designation, Resign_Status FROM View_Emp WHERE ID_no IN (" + string.Join(",", names) + ")";
                if (status != "All")
                {
                    sql += " AND Resign_Status = @st";
                    cmd.Parameters.Add("@st", SqlDbType.NVarChar, 50).Value = status;
                }
                cmd.CommandText = sql;

                var dt = new DataTable();
                using (var da = new SqlDataAdapter(cmd)) da.Fill(dt);
                return dt;
            }
        }

        void SaveSelections(SqlConnection con)
        {
            long user = UserCode, from = FromCode;

            foreach (var f in Filters())
            {
                var all = lookups[f.Key];

                // মাল্টিপল সিলেক্ট: টিক দেওয়া সব কোড নেওয়া হয়
                var codes = new List<long>();
                foreach (ListItem li in f.Dd.Items)
                {
                    long c;
                    if (li.Selected && long.TryParse(li.Value, out c) && !codes.Contains(c))
                        codes.Add(c);
                }
                if (codes.Count == 0 && EmptyMeansAll)
                    codes = all.Select(i => i.Code).Distinct().ToList();

                debug.Add(f.Key + "=" + codes.Count + (codes.Count > 0 ? "[" + string.Join("|", codes) + "]" : ""));

                if (f.DelNeedsCode)
                {
                    string delParam = ResolveCodeParam(con, f.DelProc, f.CodeParam);
                    foreach (long c in all.Select(i => i.Code).Distinct())
                        ExecProc(con, f.DelProc, P(delParam, c), P("@User_Code", user), P("@From_Code", from));
                }
                else
                {
                    ExecProc(con, f.DelProc, P("@User_Code", user), P("@From_Code", from));
                }

                if (codes.Count > 0)
                {
                    string insParam = ResolveCodeParam(con, f.InsProc, f.CodeParam);
                    foreach (long c in codes)
                        ExecProc(con, f.InsProc, P(insParam, c), P("@User_Code", user), P("@From_Code", from));
                }
            }
        }

        DataTable RunStatusProc(SqlConnection con, string status)
        {
            string proc;
            switch (status)
            {
                case "Active": proc = "Pro_Employee_View_N"; break;
                case "New": proc = "Pro_Employee_View_N_New"; break;
                case "Seperation": proc = "Pro_Employee_View_N_Seperation"; break;
                case "All": proc = "Pro_Employee_View_N_All"; break;
                default: proc = "Pro_Employee_View_N_Resign_Lefty_Others"; break;
            }

            string from = string.IsNullOrWhiteSpace(txtFromDate.Text) ? "1900-01-01" : txtFromDate.Text.Trim();
            string till = string.IsNullOrWhiteSpace(txtTillDate.Text) ? DateTime.Today.ToString("yyyy-MM-dd") : txtTillDate.Text.Trim();

            using (var cmd = new SqlCommand(proc, con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandTimeout = 120;
                cmd.Parameters.AddWithValue("@Employee_Status", status);
                cmd.Parameters.AddWithValue("@from_Date", from);
                cmd.Parameters.AddWithValue("@till_Date", till);
                cmd.Parameters.AddWithValue("@User_Code", UserCode.ToString());
                cmd.Parameters.AddWithValue("@From_Code", FromCode.ToString());

                var dt = new DataTable();
                using (var rd = cmd.ExecuteReader()) dt.Load(rd);
                return dt;
            }
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

        static SqlParameter P(string name, long value)
        {
            return new SqlParameter(name, SqlDbType.BigInt) { Value = value };
        }

        static void ExecProc(SqlConnection con, string proc, params SqlParameter[] ps)
        {
            using (var cmd = new SqlCommand(proc, con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddRange(ps);
                cmd.ExecuteNonQuery();
            }
        }

        // ================= ফলাফল দেখানো =================
        void BindTable(DataTable dt, string status)
        {
            var list = new List<Emp>();
            foreach (DataRow r in dt.Rows)
            {
                list.Add(new Emp
                {
                    Id = Col(r, "", "ID_no", "Id", "Emp_ID"),
                    Name = Col(r, "", "Name", "Emp_Name"),
                    Designation = Col(r, "", "Designation", "Desigation_name"),
                    Department = Col(r, "", "Department", "Department_Name"),
                    Branch = Col(r, "", "Branch", "Branch_Name"),
                    Status = Col(r, status, "Resign_Status", "Status", "Employee_Status")
                });
            }

            rptEmployees.DataSource = list;
            rptEmployees.DataBind();
            trEmpty.Visible = list.Count == 0;

            // [পরিবর্তন] টাইটেলে Report_Name (Text) দেখানো হয়
            lblReportTitle.Text = string.IsNullOrEmpty(RTypeText()) ? "Active Employee List" : RTypeText();
            lblCount.Text = list.Count + " Records";
            litPaging.Text = list.Count == 0
                ? "Showing 0 entries"
                : "Showing <span class=\"font-medium text-slate-700\">1</span> to <span class=\"font-medium text-slate-700\">" + list.Count +
                  "</span> of <span class=\"font-medium text-slate-700\">" + list.Count + "</span> entries";

            if (list.Count > 0)
            {
                ClientScript.RegisterStartupScript(GetType(), "chkall",
                    "document.addEventListener('DOMContentLoaded',function(){document.querySelectorAll('.row-checkbox,#selectAllRows').forEach(function(c){c.checked=true;});});", true);
            }
        }

        static string Col(DataRow r, string fallback, params string[] names)
        {
            foreach (string n in names)
            {
                if (r.Table.Columns.Contains(n) && r[n] != DBNull.Value)
                    return Convert.ToString(r[n]);
            }
            return fallback;
        }

        // ================= সাহায্যকারী =================
        static string[] ParseIds(string text)
        {
            if (string.IsNullOrWhiteSpace(text)) return new string[0];
            return text.Split(new[] { ',', ';', '\n', '\r', ' ', '\t' }, StringSplitOptions.RemoveEmptyEntries)
                       .Select(s => s.Trim().Trim('\'', '"'))
                       .Where(s => s.Length > 0)
                       .Distinct(StringComparer.OrdinalIgnoreCase)
                       .ToArray();
        }

        void ResetDefaults()
        {
            // মাল্টিপল সিলেক্ট ফিল্টার: সব সিলেকশন মোছা
            foreach (var f in Filters()) f.Dd.ClearSelection();

            // সাধারণ ড্রপডাউন: প্রথম আইটেমে ফেরা
            // [পরিবর্তন] ddRType খালি থাকলেও যেন error না হয় (Items.Count গার্ড)
            foreach (var d in new[] { ddBlood, ddReligion, ddStatus, ddRType })
                if (d.Items.Count > 0) d.SelectedIndex = 0;

            hfSelIds.Value = "";
            txtFromDate.Text = txtTillDate.Text = txtMultiId.Text = "";
        }

        void ClearGrid()
        {
            rptEmployees.DataSource = null;
            rptEmployees.DataBind();
            trEmpty.Visible = false;

            // [পরিবর্তন] টাইটেলে Report_Name (Text) দেখানো হয়
            lblReportTitle.Text = string.IsNullOrEmpty(RTypeText()) ? "Active Employee List" : RTypeText();
            lblCount.Text = "0 Records";
            litPaging.Text = "Showing 0 entries";
        }

        void Toast(string msg)
        {
            string js = "document.addEventListener('DOMContentLoaded',function(){showNotification(" +
                        new JavaScriptSerializer().Serialize(msg) + ");});";
            ClientScript.RegisterStartupScript(GetType(), "toast" + Guid.NewGuid().ToString("N"), js, true);
        }
    }
}