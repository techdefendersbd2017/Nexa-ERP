using Nexa_ERP.Connection;
using Nexa_ERP.HRMPayroll.Common;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Web.Script.Serialization;
using System.Web.UI.WebControls;

namespace Nexa_ERP.HRMPayroll.AttendanceManagementSystem
{
    public partial class ShiftChangeing : System.Web.UI.Page
    {
        PayrollDB conn = new PayrollDB();
        HRFilters filters;
        readonly List<string> errs = new List<string>();
        const string DateFmt = "yyyy-MM-dd";

        public class Row
        {
            public string Id { get; set; }
            public string Name { get; set; }
            public string Designation { get; set; }
            public string EmpNo { get; set; }
            public string Date { get; set; }
            public string Shift { get; set; }
        }

        long UserCode { get { return HRFilters.UserCode; } }
        long FromCode { get { return HRFilters.SessionLong("From_Code", "FromCode"); } }
        string Status { get { return string.IsNullOrEmpty(ddStatus.SelectedValue) ? "Active" : ddStatus.SelectedValue; } }

        // ================= Page Load =================
        protected void Page_Load(object sender, EventArgs e)
        {
            // Attendance_Reports পেজের সব ফিল্টার
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

            // পোস্টব্যাকের পর আগের টিক ফিরিয়ে আনা
            string raw = SelectedIds();
            if (IsPostBack && raw != "")
            {
                string arr = new JavaScriptSerializer().Serialize(raw.Split(','));
                ClientScript.RegisterStartupScript(GetType(), "retick",
                    "document.addEventListener('DOMContentLoaded',function(){var ids=" + arr +
                    ";document.querySelectorAll('.row-checkbox').forEach(function(c){" +
                    "if(ids.indexOf(c.getAttribute('data-id'))>=0)c.checked=true;});});", true);
            }

            if (!IsPostBack)
            {
                filters.FillControls();
                FillCombos();
                string today = DateTime.Today.ToString(DateFmt, CultureInfo.InvariantCulture);
                txtFrom.Text = txtTill.Text = txtShiftDate.Text = today;
                DateTime ws0 = WeekStart(DateTime.Today);
                txtSvFrom.Text = ws0.ToString(DateFmt, CultureInfo.InvariantCulture);
                SetWeekLabel(ws0);
            }

            var all = errs.Concat(filters.Errors).ToList();
            if (all.Count > 0) Toast("Option load error: " + string.Join(" | ", all));
        }

        void FillCombos()
        {
            // desktop: Seperation_Status → Status dropdown
            Fill(ddStatus, "SELECT Seperation_Code, Seperation_Name FROM Seperation_Status", "Seperation_Name", "Seperation_Name", null);
            if (ddStatus.Items.Count == 0)
                foreach (string s in new[] { "Active", "New", "Seperation", "All", "Resign", "Left" }) ddStatus.Items.Add(s);

            // desktop: Team_Information, TB_Shift
            Fill(ddTeam, "SELECT Team_ID, Team_Name FROM Team_Information", "Team_Name", "Team_Name", null);
            Fill(ddSvTeam, "SELECT Team_ID, Team_Name FROM Team_Information", "Team_Name", "Team_Name", "-- All teams --");

            string shiftSql = "SELECT Shift_Code, Shift_Name FROM TB_Shift ORDER BY Shift_Name";
            Fill(ddFromShift, shiftSql, "Shift_Name", "Shift_Code", null);
            Fill(ddToShift, shiftSql, "Shift_Name", "Shift_Code", null);
            Fill(ddShiftF, shiftSql, "Shift_Name", "Shift_Code", null);
        }

        void Fill(ListControl c, string sql, string text, string val, string blank)
        {
            c.Items.Clear();
            if (blank != null) c.Items.Add(new ListItem(blank, ""));
            try
            {
                using (var con = Open())
                using (var cmd = new SqlCommand(sql, con))
                    foreach (DataRow r in Fill(cmd).Rows)
                        c.Items.Add(new ListItem(Convert.ToString(r[text]).Trim(), Convert.ToString(r[val])));
            }
            catch (Exception ex) { errs.Add(c.ID + ": " + ex.Message); }
        }

        // ================= ডাটাবেস সহায়ক =================
        SqlConnection Open()
        {
            SqlConnection c = conn.openConnection();
            if (c.State != ConnectionState.Open) c.Open();
            return c;
        }

        static DataTable Fill(SqlCommand cmd)
        {
            var dt = new DataTable();
            using (var da = new SqlDataAdapter(cmd)) da.Fill(dt);
            return dt;
        }

        static void Proc(SqlConnection con, SqlTransaction tx, string name, params SqlParameter[] p)
        {
            using (var cmd = new SqlCommand(name, con, tx))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddRange(p);
                cmd.ExecuteNonQuery();
            }
        }

        static string InClause(SqlCommand cmd, string[] ids, string prefix)
        {
            bool num = ids.All(s => { long x; return long.TryParse(s, out x); });
            var names = new List<string>();
            for (int i = 0; i < ids.Length; i++)
            {
                string p = prefix + i;
                names.Add(p);
                if (num) cmd.Parameters.Add(p, SqlDbType.BigInt).Value = long.Parse(ids[i]);
                else cmd.Parameters.Add(p, SqlDbType.NVarChar, 50).Value = ids[i];
            }
            return string.Join(",", names);
        }

        static bool ParseDate(string s, out DateTime d)
        {
            return DateTime.TryParseExact((s ?? "").Trim(), DateFmt, CultureInfo.InvariantCulture, DateTimeStyles.None, out d);
        }

        string SelectedIds()
        {
            string[] f = Request.Form.GetValues("selId");
            if (f != null && f.Length > 0) return string.Join(",", f);
            return hfSelIds.Value ?? "";
        }

        // ================= Tab 1: কর্মচারী খোঁজা =================
        void Run(Func<SqlConnection, DataTable> query, string source)
        {
            try
            {
                DataTable dt;
                using (var con = Open()) dt = query(con);
                BindEmployees(dt, source);
            }
            catch (Exception ex) { Toast("Error: " + ex.Message); }
        }

        // Filter অনুযায়ী (desktop button4 এর Department/Section/... সিলেকশন সেভ + Pro_Employee_View_N*)
        protected void btnFilter_Click(object sender, EventArgs e)
        {
            if (UserCode == 0) { Toast("User_Code not found (session). Please log in again."); return; }

            Run(con =>
            {
                filters.SaveSelections(con, UserCode, FromCode);

                // Current shift ফিল্টার: desktop এর Pro_Selected_Shift_Delete / Pro_Selected_Shift
                Proc(con, null, "Pro_Selected_Shift_Delete", new SqlParameter("@User_Code", UserCode), new SqlParameter("@From_Code", FromCode));
                foreach (ListItem it in ddShiftF.Items)
                    if (it.Selected)
                        Proc(con, null, "Pro_Selected_Shift", new SqlParameter("@Shift_Code", long.Parse(it.Value)),
                            new SqlParameter("@User_Code", UserCode), new SqlParameter("@From_Code", FromCode));

                return RunStatusProc(con);
            }, "Filter");
        }

        DataTable RunStatusProc(SqlConnection con)
        {
            string proc;
            switch (Status)
            {
                case "Active": proc = "Pro_Employee_View_N"; break;
                case "New": proc = "Pro_Employee_View_N_New"; break;
                case "Seperation": proc = "Pro_Employee_View_N_Seperation"; break;
                case "All": proc = "Pro_Employee_View_N_All"; break;
                default: proc = "Pro_Employee_View_N_Resign_Lefty_Others"; break;
            }
            using (var cmd = new SqlCommand(proc, con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandTimeout = 120;
                cmd.Parameters.AddWithValue("@Employee_Status", Status);
                cmd.Parameters.AddWithValue("@from_Date", string.IsNullOrWhiteSpace(txtFrom.Text) ? "1900-01-01" : txtFrom.Text.Trim());
                cmd.Parameters.AddWithValue("@till_Date", string.IsNullOrWhiteSpace(txtTill.Text) ? DateTime.Today.ToString(DateFmt, CultureInfo.InvariantCulture) : txtTill.Text.Trim());
                cmd.Parameters.AddWithValue("@User_Code", UserCode.ToString());
                cmd.Parameters.AddWithValue("@From_Code", FromCode.ToString());
                var dt = new DataTable();
                using (var rd = cmd.ExecuteReader()) dt.Load(rd);
                return dt;
            }
        }

        // ID অনুযায়ী
        protected void btnIds_Click(object sender, EventArgs e)
        {
            string[] ids = HRFilters.ParseIds(txtIds.Text);
            if (ids.Length == 0) { Toast("Enter ID No."); return; }
            if (ids.Length > HRFilters.MaxIds) { Toast("Too many IDs (max " + HRFilters.MaxIds + ")."); return; }

            Run(con =>
            {
                var cmd = new SqlCommand { Connection = con };
                string sql = "SELECT ID_no, Name, Designation FROM View_Emp WHERE ID_no IN (" + InClause(cmd, ids, "@i") + ")";
                if (Status != "All")
                {
                    sql += " AND Resign_Status = @st";
                    cmd.Parameters.Add("@st", SqlDbType.NVarChar, 50).Value = Status;
                }
                cmd.CommandText = sql;
                return Fill(cmd);
            }, "ID");
        }

        // টিম অনুযায়ী (desktop button5)
        protected void btnTeam_Click(object sender, EventArgs e)
        {
            if (ddTeam.SelectedItem == null) { Toast("Select a team."); return; }
            string team = ddTeam.SelectedItem.Text;

            Run(con =>
            {
                var cmd = new SqlCommand("SELECT ID_no, Name, Designation FROM View_Employee_Wise_Team_Information WHERE Team_Name = @t", con);
                cmd.Parameters.Add("@t", SqlDbType.NVarChar, 100).Value = team;
                return Fill(cmd);
            }, "Team: " + team);
        }

        // তারিখ ও শিফট অনুযায়ী (desktop button1)
        protected void btnShiftSearch_Click(object sender, EventArgs e)
        {
            DateTime d;
            if (ddFromShift.SelectedItem == null || !ParseDate(txtShiftDate.Text, out d)) { Toast("Select a shift and a date."); return; }
            string shift = ddFromShift.SelectedValue, name = ddFromShift.SelectedItem.Text;

            Run(con =>
            {
                var cmd = new SqlCommand(
                    "SELECT ID_no, Name, Designation, Emp_no, Work_date, Shift_Code FROM View_By_Shift_Employee " +
                    "WHERE Work_date >= @d AND Work_date < DATEADD(day, 1, @d) AND Shift_Code = @s", con);
                cmd.Parameters.Add("@d", SqlDbType.DateTime).Value = d;
                cmd.Parameters.Add("@s", SqlDbType.NVarChar, 50).Value = shift;
                return Fill(cmd);
            }, name + " · " + d.ToString("dd-MMM-yyyy"));
        }

        void BindEmployees(DataTable dt, string source)
        {
            var list = dt.Rows.Cast<DataRow>().Select(Map).ToList();
            rptEmp.DataSource = list;
            rptEmp.DataBind();
            trEmpty.Visible = list.Count == 0;
            if (list.Count == 0) trEmpty.Cells[0].InnerText = "No employees found for the selected criteria.";
            lblCount.Text = list.Count + " records";
            lblSrc.Text = source;

            if (list.Count > 0)
                ClientScript.RegisterStartupScript(GetType(), "chkall",
                    "document.addEventListener('DOMContentLoaded',function(){selAll(true);});", true);
        }

        // ================= Save / Delete (desktop button2 / button3) =================
        protected void btnSave_Click(object sender, EventArgs e) { Apply("Pro_Shift_Change", "Shift saved for "); }
        protected void btnDelete_Click(object sender, EventArgs e) { Apply("Pro_Shift_Change_Delete", "Shift deleted for "); }

        void Apply(string proc, string okMsg)
        {
            string[] ids = HRFilters.ParseIds(SelectedIds());
            if (ids.Length == 0) { Toast("Please select employee."); return; }
            if (ddToShift.SelectedItem == null) { Toast("Select the To shift."); return; }

            DateTime from, till;
            if (!ParseDate(txtFrom.Text, out from)) { Toast("Enter the From date."); return; }
            till = from;
            if (chkRange.Checked && !ParseDate(txtTill.Text, out till)) { Toast("Enter the Till date."); return; }
            if (till < from) { Toast("Till date cannot be before From date."); return; }

            long shiftCode = long.Parse(ddToShift.SelectedValue);
            string shiftName = ddToShift.SelectedItem.Text;
            int n = 0;

            try
            {
                using (var con = Open())
                using (var tx = con.BeginTransaction())   // একটি ব্যর্থ হলে সব rollback
                {
                    foreach (string id in ids)
                    {
                        long idNo;
                        if (!long.TryParse(id, out idNo)) continue;
                        Proc(con, tx, proc,
                            new SqlParameter("@ID_No", idNo),
                            new SqlParameter("@shift_Code", shiftCode),
                            new SqlParameter("@shiff_Name", SqlDbType.VarChar) { Value = shiftName },
                            new SqlParameter("@from_Date", SqlDbType.DateTime) { Value = from },
                            new SqlParameter("@till_Date", SqlDbType.DateTime) { Value = till });
                        n++;
                    }
                    tx.Commit();
                }
                Toast(okMsg + n + " employee(s): " + shiftName + ", " + from.ToString("dd-MMM-yyyy") +
                      (till > from ? " to " + till.ToString("dd-MMM-yyyy") : ""));
            }
            catch (Exception ex) { Toast("Error: " + ex.Message); }
        }

        // ================= Tab 2: Saved shift roster (weekly grid) =================
        static readonly string[] Days = { "Saturday", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday" };
        // Shift badge colours: { badge classes, dot class }
        static readonly string[][] Colors = {
            new[] { "bg-sky-50 text-sky-700 border-sky-200 hover:bg-sky-100", "bg-sky-500" },
            new[] { "bg-amber-50 text-amber-700 border-amber-200 hover:bg-amber-100", "bg-amber-500" },
            new[] { "bg-indigo-50 text-indigo-700 border-indigo-200 hover:bg-indigo-100", "bg-indigo-600" },
            new[] { "bg-rose-50 text-rose-700 border-rose-200 hover:bg-rose-100", "bg-rose-500" },
            new[] { "bg-emerald-50 text-emerald-700 border-emerald-200 hover:bg-emerald-100", "bg-emerald-500" },
            new[] { "bg-purple-50 text-purple-700 border-purple-200 hover:bg-purple-100", "bg-purple-500" },
            new[] { "bg-teal-50 text-teal-700 border-teal-200 hover:bg-teal-100", "bg-teal-500" },
            new[] { "bg-orange-50 text-orange-700 border-orange-200 hover:bg-orange-100", "bg-orange-500" } };
        static readonly string[] Avatars = { "bg-blue-600", "bg-emerald-600", "bg-indigo-600", "bg-purple-600", "bg-amber-600", "bg-rose-600", "bg-cyan-600", "bg-slate-700" };

        static DateTime WeekStart(DateTime d) { return d.Date.AddDays(-(((int)d.DayOfWeek + 1) % 7)); }   // week starts on Saturday

        string[] Clr(string code)
        {
            var it = ddToShift.Items.FindByValue(code);
            return Colors[(it == null ? 0 : ddToShift.Items.IndexOf(it)) % Colors.Length];
        }

        string ShiftText(string code)
        {
            var it = ddToShift.Items.FindByValue(code);
            return Server.HtmlEncode(it != null ? it.Text : code);
        }

        void SetWeekLabel(DateTime ws)
        {
            var ci = CultureInfo.InvariantCulture;
            lblWeek.Text = ws.ToString("dd MMM", ci) + " - " + ws.AddDays(6).ToString("dd MMM, yyyy", ci);
        }

        const string EmptyTitle = "Click Show to load the roster";
        const string EmptyHint = "Pick a team, IDs or a date, then view the saved shifts.";

        static string EmptyRoster(string title, string hint)
        {
            return "<tbody id='rosterBody'><tr id='rosterEmpty'><td colspan='9' class='py-12 px-4 text-center'>" +
                   "<div class='w-14 h-14 rounded-full bg-slate-100 text-slate-400 flex items-center justify-center mx-auto mb-3 text-xl'><i class='fa-solid fa-user-slash'></i></div>" +
                   "<h4 class='text-base font-semibold text-slate-700'>" + title + "</h4><p class='text-sm text-slate-500 mt-1'>" + hint + "</p></td></tr></tbody>";
        }

        // Shift filter buttons and legend are rebuilt on every request
        protected void Page_PreRender(object sender, EventArgs e)
        {
            var pills = new StringBuilder("<button type='button' data-filter='ALL' onclick=\"setShiftFilter('ALL')\" class='filter-btn px-3 py-1.5 rounded-lg text-xs font-semibold bg-slate-800 text-white ring-2 ring-offset-1 ring-indigo-500 transition-all'>All</button>");
            var legend = new StringBuilder();
            foreach (ListItem it in ddToShift.Items)
            {
                string[] k = Clr(it.Value);
                string nm = Server.HtmlEncode(it.Text);
                pills.Append("<button type='button' data-filter='" + Server.HtmlEncode(it.Value) + "' onclick=\"setShiftFilter('" + Server.HtmlEncode(it.Value) + "')\" class='filter-btn px-3 py-1.5 rounded-lg text-xs font-semibold border whitespace-nowrap transition-all " + k[0] + "'>" + nm + "</button>");
                legend.Append("<span class='inline-flex items-center gap-1.5 text-slate-600'><span class='w-2.5 h-2.5 rounded-full " + k[1] + "'></span><strong>" + nm + "</strong></span>");
            }
            litPills.Text = pills.ToString();
            litLegend.Text = legend.ToString();
            if (string.IsNullOrEmpty(litRoster.Text)) litRoster.Text = EmptyRoster(EmptyTitle, EmptyHint);
        }

        protected void btnSvShow_Click(object sender, EventArgs e) { ShowRoster(0); }
        protected void btnWkPrev_Click(object sender, EventArgs e) { ShowRoster(-7); }
        protected void btnWkNext_Click(object sender, EventArgs e) { ShowRoster(7); }
        protected void btnWkCur_Click(object sender, EventArgs e)
        {
            txtSvFrom.Text = DateTime.Today.ToString(DateFmt, CultureInfo.InvariantCulture);
            ShowRoster(0);
        }

        protected void btnSvClear_Click(object sender, EventArgs e)
        {
            hfTab.Value = "saved";
            ddSvTeam.SelectedIndex = 0; txtSvIds.Text = "";
            DateTime ws = WeekStart(DateTime.Today);
            txtSvFrom.Text = ws.ToString(DateFmt, CultureInfo.InvariantCulture);
            SetWeekLabel(ws);
            litRoster.Text = EmptyRoster(EmptyTitle, EmptyHint);
        }

        void ShowRoster(int shiftDays)
        {
            hfTab.Value = "saved";
            DateTime d;
            if (!ParseDate(txtSvFrom.Text, out d)) d = DateTime.Today;
            DateTime ws = WeekStart(d).AddDays(shiftDays);
            txtSvFrom.Text = ws.ToString(DateFmt, CultureInfo.InvariantCulture);
            SetWeekLabel(ws);

            string[] ids = HRFilters.ParseIds(txtSvIds.Text);
            if (ids.Length > HRFilters.MaxIds) { Toast("Too many IDs (max " + HRFilters.MaxIds + ")."); return; }
            string team = string.IsNullOrEmpty(ddSvTeam.SelectedValue) ? null : ddSvTeam.SelectedItem.Text;
            const string teamSql = " AND ID_no IN (SELECT ID_no FROM View_Employee_Wise_Team_Information WHERE Team_Name = @team)";

            DataTable emps, shifts;
            try
            {
                using (var con = Open())
                {
                    // 1) every employee that matches the filters (shown even when no shift is saved)
                    var ce = new SqlCommand { Connection = con, CommandTimeout = 120 };
                    var se = new StringBuilder("SELECT TOP 5000 ID_no, Name, Designation FROM View_Emp WHERE 1 = 1");
                    if (ids.Length > 0) se.Append(" AND ID_no IN (" + InClause(ce, ids, "@i") + ")");
                    else { se.Append(" AND Resign_Status = @st"); ce.Parameters.Add("@st", SqlDbType.NVarChar, 50).Value = "Active"; }
                    if (team != null) { se.Append(teamSql); ce.Parameters.Add("@team", SqlDbType.NVarChar, 100).Value = team; }
                    ce.CommandText = se.Append(" ORDER BY ID_no").ToString();
                    emps = Fill(ce);

                    // 2) saved shifts of the selected week
                    var cs = new SqlCommand { Connection = con, CommandTimeout = 120 };
                    var ss = new StringBuilder("SELECT TOP 100000 ID_no, Work_date, Shift_Code FROM View_By_Shift_Employee WHERE Work_date >= @f AND Work_date < @t");
                    cs.Parameters.Add("@f", SqlDbType.DateTime).Value = ws;
                    cs.Parameters.Add("@t", SqlDbType.DateTime).Value = ws.AddDays(7);
                    if (ids.Length > 0) ss.Append(" AND ID_no IN (" + InClause(cs, ids, "@i") + ")");
                    if (team != null) { ss.Append(teamSql); cs.Parameters.Add("@team", SqlDbType.NVarChar, 100).Value = team; }
                    cs.CommandText = ss.ToString();
                    shifts = Fill(cs);
                }
            }
            catch (Exception ex) { Toast("Error: " + ex.Message); return; }

            // employee x 7 days
            var order = new List<string>();
            var info = new Dictionary<string, string[]>();
            var grid = new Dictionary<string, string[]>();
            foreach (DataRow r in emps.Rows)
            {
                string id = Col(r, "ID_no");
                if (grid.ContainsKey(id)) continue;
                grid[id] = new string[7];
                info[id] = new[] { Col(r, "Name"), Col(r, "Designation") };
                order.Add(id);
            }
            foreach (DataRow r in shifts.Rows)
            {
                string id = Col(r, "ID_no");
                if (!grid.ContainsKey(id) || r["Work_date"] == DBNull.Value) continue;
                int di = (int)(Convert.ToDateTime(r["Work_date"]).Date - ws).TotalDays;
                if (di >= 0 && di < 7) grid[id][di] = Col(r, "Shift_Code");
            }

            if (order.Count == 0)
            {
                litRoster.Text = EmptyRoster("No employees found", "Try a different team or ID.");
                return;
            }

            var ci = CultureInfo.InvariantCulture;
            var sb = new StringBuilder();
            sb.Append("<thead><tr class='bg-slate-50/90 border-b border-slate-200 text-slate-700 text-xs'>" +
                      "<th class='py-3.5 px-5 font-bold min-w-[230px] sticky left-0 bg-slate-50 z-10 border-r border-slate-200/70'>Employee &amp; ID</th>");
            for (int i = 0; i < 7; i++)
            {
                DateTime dd = ws.AddDays(i);
                bool today = dd.Date == DateTime.Today;
                sb.Append("<th class='py-3 px-3 text-center font-bold min-w-[125px]" + (today ? " bg-indigo-50/60 text-indigo-900" : "") + "'>" +
                          "<div class='flex items-center justify-center'><span>" + Days[i] + "</span>" +
                          (today ? "<span class='ml-1.5 px-1.5 py-0.5 text-[10px] font-bold bg-indigo-600 text-white rounded-md'>Today</span>" : "") + "</div>" +
                          "<div class='text-[11px] font-medium text-slate-400 mt-0.5'>" + dd.ToString("dd MMM", ci) + "</div></th>");
            }
            sb.Append("<th class='py-3.5 px-4 text-center font-bold min-w-[95px] border-l border-slate-200/70'>Total duty</th></tr></thead><tbody id='rosterBody' class='divide-y divide-slate-100 text-sm'>");

            for (int n = 0; n < order.Count; n++)
            {
                string id = order[n];
                string[] inf = info[id];
                string nm = string.IsNullOrWhiteSpace(inf[0]) ? id : inf[0].Trim();
                string search = (id + " " + inf[0] + " " + inf[1]).ToLowerInvariant();
                int days = grid[id].Count(x => !string.IsNullOrEmpty(x));

                sb.Append("<tr class='hover:bg-slate-50/80 transition-colors' data-s='" + Server.HtmlEncode(search) + "'>" +
                    "<td class='py-3.5 px-5 sticky left-0 bg-white z-10 border-r border-slate-100'><div class='flex items-center gap-3'>" +
                    "<div class='w-10 h-10 rounded-xl " + Avatars[n % Avatars.Length] + " text-white font-bold text-sm flex items-center justify-center shrink-0 shadow-sm'>" + Server.HtmlEncode(nm.Substring(0, 1)) + "</div>" +
                    "<div class='min-w-0'><div class='font-bold text-slate-800 truncate'>" + Server.HtmlEncode(nm) + "</div>" +
                    "<div class='text-xs text-slate-500 truncate'>" + Server.HtmlEncode(inf[1]) + " • <span class='text-indigo-600/80 font-medium'>ID " + Server.HtmlEncode(id) + "</span></div></div></div></td>");

                for (int i = 0; i < 7; i++)
                {
                    string code = grid[id][i];
                    string bg = ws.AddDays(i).Date == DateTime.Today ? " bg-indigo-50/25" : "";
                    if (string.IsNullOrEmpty(code))
                        sb.Append("<td class='py-2.5 px-2.5 text-center" + bg + "'><span class='text-slate-300'>—</span></td>");
                    else
                        sb.Append("<td class='py-2.5 px-2.5 text-center" + bg + "'><div data-sh='" + Server.HtmlEncode(code) + "' class='w-full py-2 px-2.5 rounded-xl border " + Clr(code)[0] +
                                  " flex items-center justify-center gap-1.5 text-xs font-bold transition-all'><i class='fa-regular fa-clock text-[11px]'></i><span>" + ShiftText(code) + "</span></div></td>");
                }
                sb.Append("<td class='py-3.5 px-4 text-center border-l border-slate-100'><span class='inline-flex items-center px-2.5 py-1 rounded-lg text-xs font-bold bg-slate-100 text-slate-700'>" + days + (days == 1 ? " day" : " days") + "</span></td></tr>");
            }
            sb.Append("</tbody>");
            litRoster.Text = sb.ToString();
        }

        // ================= সহায়ক =================
        Row Map(DataRow r)
        {
            string code = Col(r, "Shift_Code");
            var it = string.IsNullOrEmpty(code) ? null : ddToShift.Items.FindByValue(code);
            string date = "";
            if (r.Table.Columns.Contains("Work_date") && r["Work_date"] != DBNull.Value)
                date = r["Work_date"] is DateTime ? ((DateTime)r["Work_date"]).ToString("dd-MMM-yyyy") : Convert.ToString(r["Work_date"]);

            return new Row
            {
                Id = Col(r, "ID_no", "Id", "Emp_ID"),
                Name = Col(r, "Name", "Emp_Name"),
                Designation = Col(r, "Designation", "Desigation_name"),
                EmpNo = Col(r, "Emp_no"),
                Date = date,
                Shift = it != null ? it.Text : code
            };
        }

        static string Col(DataRow r, params string[] names)
        {
            foreach (string n in names)
                if (r.Table.Columns.Contains(n) && r[n] != DBNull.Value) return Convert.ToString(r[n]);
            return "";
        }

        void Toast(string msg)
        {
            string js = "document.addEventListener('DOMContentLoaded',function(){showNotification(" +
                        new JavaScriptSerializer().Serialize(msg) + ");});";
            ClientScript.RegisterStartupScript(GetType(), "toast" + Guid.NewGuid().ToString("N"), js, true);
        }
    }
}
