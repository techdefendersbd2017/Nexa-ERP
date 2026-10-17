using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.HRMPayroll.HRMPayrollReports.HRReports
{
    public partial class ActiveEmployeeListReport : Page
    {
        PayrollDB conn = new PayrollDB();
        static readonly CultureInfo Inv = CultureInfo.InvariantCulture;

        const int ReportFormCode = 7;

        // ?rpt= না থাকলে rc (formCode) দিয়ে রিপোর্ট ঠিক হবে। নিজের formCode গুলো এখানে বসান।
        static readonly Dictionary<long, string> FormCodeMap = new Dictionary<long, string>
        {
            { 7, "active" }
            // , { 8, "bank" }, { 9, "cash" }, { 10, "bangla" }, { 11, "blood" }, { 12, "photo" },
            // { 13, "fire" }, { 14, "insactive" }, { 15, "inssep" }, { 16, "male" }, { 17, "newjoin" },
            // { 18, "nightlist" }, { 19, "nightwise" }, { 20, "religion" }, { 21, "separation" }, { 22, "worker" }
        };

        // p.*, sal.*, d.*, s.*, g.* নেওয়া হয়েছে যাতে Blood_Group, Photo, Bangla নাম, Bank, Insurance, Night ইত্যাদি
        // কলাম থাকলে নিজে থেকে পাওয়া যায়। ডুপ্লিকেট নামের কলাম ADO.NET নিজে Name1 করে দেয়।
        const string Sql = @"
SELECT e.ID_no, e.Name, b.Branch_Name, b.Address, b.Branch_Bangla, b.Bangla_Address_Branch,
       d.Department_Name, s.Section_Name, g.Desigation_name, e.Joining_Date,
       e.Resign_Status, e.Resign_Date, sal.Gross_Salary,
       d.*, s.*, g.*, p.*, sal.*
FROM dbo.Employee_information_new e
INNER JOIN dbo.Employee_information_With_Code ec ON e.ID_no = ec.ID_no
INNER JOIN dbo.z_Test_ID z ON e.ID_no = z.ID_No
INNER JOIN dbo.TB_Branch b ON ec.Branch_Code = b.Branch_Code
INNER JOIN dbo.TB_Department d ON ec.Department_Code = d.Department_Code
INNER JOIN dbo.TB_Section s ON ec.Section_Code = s.Section_Code
INNER JOIN dbo.TB_Designation g ON ec.Designation_Code = g.Designation_Code
INNER JOIN dbo.Employee_Salary_information_new sal ON e.ID_no = sal.ID_no
INNER JOIN dbo.Employee_Personal_Information_new p ON e.ID_no = p.ID_No
WHERE z.User_ID = @u AND z.From_Code = @f
ORDER BY d.Department_Name, s.Section_Name, e.ID_no asc";

        const string LogoSql = @"
SELECT TOP 1 b.Branch_logo
FROM dbo.z_Test_ID z
INNER JOIN dbo.Employee_information_With_Code ec ON z.ID_No = ec.ID_no
INNER JOIN dbo.TB_Branch b ON ec.Branch_Code = b.Branch_Code
WHERE z.User_ID = @u AND z.From_Code = @f";

        const string ExportCss =
            "table{border-collapse:collapse;width:100%;font-family:Arial;font-size:9pt}" +
            "td,th{border:1px solid #000;padding:2px 4px;vertical-align:top}" +
            "td.headCell{border:0;text-align:center}.co{font-size:14pt;font-weight:bold}.ttl{font-weight:bold}" +
            ".gDept td{background:#d9d9d9}.gSec td{background:#efefef}.sub td{background:#f7f7f7}.grand td{background:#d9d9d9}" +
            ".c{text-align:center}.r{text-align:right}";

        // ================= মডেল ক্লাস =================
        class Emp
        {
            public DataRow Row;
            public string Sl = "", IdNo = "", Name = "", NameBn = "", Designation = "", DesigBn = "";
            public string Department = "", DeptBn = "", Section = "", SecBn = "";
            public string Branch = "", BranchBn = "", Address = "", AddressBn = "";
            public string JoinDate = "", ResignDateStr = "", Gender = "", Religion = "", Blood = "", Father = "";
            public string BankNo = "", Insurance = "";
            public DateTime? Join;
            public decimal Gross;
            public string GrossStr = "";
            public bool Resigned, Male, IsBank, IsCash, Fire, HasIns, Night;
        }

        class Col
        {
            public string H, Cls; public int W; public Func<Emp, string> V;
            public bool Html, IsGross;
        }

        class Lvl
        {
            public string Label, Total, Css; public Func<Emp, string> Key;
        }

        class Rpt
        {
            public string Title, File, Hint = "", GrandLabel = "Grand Total", CountLabel = "Total Employee";
            public bool Bn, JoinRange;
            public Func<Emp, bool> Filter;
            public Comparison<Emp> Sort;
            public List<Lvl> Lv = new List<Lvl>();
            public List<Col> Cols = new List<Col>();
        }

        // ================= কলাম/গ্রুপ হেল্পার =================
        static Col C(string h, int w, string cls, Func<Emp, string> v) { return new Col { H = h, W = w, Cls = cls, V = v }; }
        static Col CHtml(string h, int w, string cls, Func<Emp, string> v) { return new Col { H = h, W = w, Cls = cls, V = v, Html = true }; }
        static Col CGross(string h, int w) { return new Col { H = h, W = w, Cls = "r", V = e => e.GrossStr, IsGross = true }; }

        static Col cSl(int w, string h = "Sl") { return C(h, w, "c", e => e.Sl); }
        static Col cId(int w, string h = "ID No") { return C(h, w, "r", e => e.IdNo); }
        static Col cName(int w) { return C("Name", w, "", e => e.Name); }
        static Col cDes(int w) { return C("Designation", w, "", e => e.Designation); }
        static Col cJoin(int w) { return C("Joining Date", w, "", e => e.JoinDate); }
        static Col cDept(int w) { return C("Department", w, "", e => e.Department); }
        static Col cSec(int w) { return C("Section", w, "", e => e.Section); }
        static Col cRem(int w) { return C("Remarks", w, "", e => ""); }

        static Lvl LvDept() { return new Lvl { Label = "Department", Total = "Department Total", Css = "gDept", Key = e => e.Department }; }
        static Lvl LvSec() { return new Lvl { Label = "Section", Total = "Section Total", Css = "gSec", Key = e => e.Section }; }

        static List<Col> Basic()
        {
            return new List<Col> { cSl(5), cId(8), cName(20), cDes(18), cJoin(11), cSec(14), CGross("Gross Salary", 12), cRem(12) };
        }

        // ================= রিপোর্ট ডেফিনিশন =================
        Rpt BuildReport(string key)
        {
            var r = new Rpt();
            DateTime jf, jt;
            switch (key)
            {
                case "active":
                    r.Title = "Active Employee List"; r.File = "ActiveEmployeeList";
                    r.Filter = e => !e.Resigned;
                    r.Lv.Add(LvDept()); r.Lv.Add(LvSec());
                    r.Cols = new List<Col> { cSl(5), cId(7), cName(15), cDes(15), cJoin(10), cDept(15), cSec(12), CGross("Gross Salary", 10), cRem(11) };
                    break;

                case "bank":
                    r.Title = "Bank Employee List"; r.File = "BankEmployeeList";
                    r.Filter = e => !e.Resigned && e.IsBank;
                    r.Hint = "(Payment_Mode / Bank Account কলাম ঠিক আছে কিনা দেখুন)";
                    r.Lv.Add(LvDept());
                    r.Cols = new List<Col> { cSl(5), cId(7), cName(17), cDes(15), cJoin(10), cSec(13),
                        C("Bank A/C No", 15, "", e => e.BankNo), CGross("Gross Salary", 10), cRem(8) };
                    break;

                case "cash":
                    r.Title = "Cash Employee List"; r.File = "CashEmployeeList";
                    r.Filter = e => !e.Resigned && e.IsCash;
                    r.Lv.Add(LvDept()); r.Cols = Basic();
                    break;

                case "bangla":
                    r.Title = "কর্মচারী তালিকা"; r.File = "EmployeeListBangla"; r.Bn = true;
                    r.GrandLabel = "সর্বমোট"; r.CountLabel = "মোট কর্মচারী";
                    r.Filter = e => !e.Resigned;
                    r.Lv.Add(new Lvl { Label = "বিভাগ", Total = "বিভাগ মোট", Css = "gDept", Key = e => e.DeptBn });
                    r.Lv.Add(new Lvl { Label = "সেকশন", Total = "সেকশন মোট", Css = "gSec", Key = e => e.SecBn });
                    r.Cols = new List<Col> {
                        cSl(5, "ক্রঃ"), cId(7, "আইডি"), C("নাম", 17, "", e => e.NameBn), C("পদবী", 15, "", e => e.DesigBn),
                        C("যোগদানের তারিখ", 11, "", e => e.JoinDate), C("বিভাগ", 15, "", e => e.DeptBn),
                        C("সেকশন", 12, "", e => e.SecBn), CGross("মোট বেতন", 10), C("মন্তব্য", 8, "", e => "") };
                    break;

                case "blood":
                    r.Title = "Employee List By Blood Group"; r.File = "EmployeeListByBloodGroup";
                    r.Filter = e => !e.Resigned;
                    r.Lv.Add(new Lvl { Label = "Blood Group", Total = "Blood Group Total", Css = "gDept", Key = e => e.Blood.Length == 0 ? "Unknown" : e.Blood });
                    r.Cols = new List<Col> { cSl(5), cId(8), cName(20), cDes(17), cJoin(11), cDept(15), cSec(14), C("Blood Group", 10, "c", e => e.Blood) };
                    break;

                case "photo":
                    r.Title = "Employee List With Photo"; r.File = "EmployeeListWithPhoto";
                    r.Filter = e => !e.Resigned;
                    r.Lv.Add(LvDept());
                    r.Cols = new List<Col> { CHtml("Photo", 10, "c", e => PhotoHtml(e.Row)), cSl(5), cId(8), cName(19), cDes(17), cJoin(11), cSec(15), CGross("Gross Salary", 15) };
                    break;

                case "fire":
                    r.Title = "Fire Fighter List"; r.File = "FireFighterList";
                    r.Filter = e => !e.Resigned && e.Fire;
                    r.Hint = "(Fire Fighter কলাম/ডিজিগনেশন ঠিক আছে কিনা দেখুন)";
                    r.Lv.Add(LvDept()); r.Cols = Basic();
                    break;

                case "insactive":
                    r.Title = "Group Insurance List (Active)"; r.File = "GroupInsuranceListActive";
                    r.Filter = e => !e.Resigned && e.HasIns;
                    r.Hint = "(Insurance কলাম ঠিক আছে কিনা দেখুন)";
                    r.Lv.Add(LvDept());
                    r.Cols = new List<Col> { cSl(5), cId(8), cName(20), cDes(17), cJoin(11), cSec(13), C("Insurance", 14, "", e => e.Insurance), CGross("Gross Salary", 12) };
                    break;

                case "inssep":
                    r.Title = "Group Insurance List (Separation)"; r.File = "GroupInsuranceListSeparation";
                    r.Filter = e => e.Resigned && e.HasIns;
                    r.Hint = "(Insurance / Resign কলাম ঠিক আছে কিনা দেখুন)";
                    r.Lv.Add(LvDept());
                    r.Cols = new List<Col> { cSl(5), cId(8), cName(18), cDes(15), cJoin(10), C("Resign Date", 10, "", e => e.ResignDateStr),
                        cSec(12), C("Insurance", 12, "", e => e.Insurance), CGross("Gross Salary", 10) };
                    break;

                case "male":
                    r.Title = "Male Employee List"; r.File = "MaleEmployeeList";
                    r.Filter = e => !e.Resigned && e.Male;
                    r.Lv.Add(LvDept()); r.Cols = Basic();
                    break;

                case "newjoin":
                    r.Title = "New Joining Employee List"; r.File = "NewJoiningEmployeeList"; r.JoinRange = true;
                    GetJoinRange(out jf, out jt);
                    r.Filter = e => e.Join.HasValue && e.Join.Value.Date >= jf && e.Join.Value.Date <= jt;
                    r.Hint = "(তারিখ: " + jf.ToString("dd-MMM-yyyy", Inv) + " থেকে " + jt.ToString("dd-MMM-yyyy", Inv) + ")";
                    r.Sort = (a, b) => { int c = Nullable.Compare(a.Join, b.Join); return c != 0 ? c : CmpId(a.IdNo, b.IdNo); };
                    r.Cols = new List<Col> { cSl(5), cId(8), cName(20), cDes(17), cJoin(11), cDept(15), cSec(14), CGross("Gross Salary", 10) };
                    break;

                case "nightlist":
                    r.Title = "Night Permission Employee List"; r.File = "NightPermissionEmployeeList";
                    r.Filter = e => !e.Resigned && e.Night;
                    r.Hint = "(Night Permission কলাম ঠিক আছে কিনা দেখুন)";
                    r.Lv.Add(LvDept()); r.Cols = Basic();
                    break;

                case "nightwise":
                    r.Title = "Night Permission Employee Wise"; r.File = "NightPermissionEmployeeWise";
                    r.Filter = e => !e.Resigned && e.Night;
                    r.Hint = "(Night Permission কলাম ঠিক আছে কিনা দেখুন)";
                    r.Cols = new List<Col> { cSl(5), cId(8), cName(20), cDes(17), cDept(15), cSec(13), C("Permission Date", 11, "", e => ""), C("Signature", 11, "", e => "") };
                    break;

                case "religion":
                    r.Title = "Religion Wise Employee List"; r.File = "ReligionWiseEmployeeList";
                    r.Filter = e => !e.Resigned;
                    r.Lv.Add(new Lvl { Label = "Religion", Total = "Religion Total", Css = "gDept", Key = e => e.Religion.Length == 0 ? "Unknown" : e.Religion });
                    r.Cols = new List<Col> { cSl(5), cId(8), cName(20), cDes(17), cJoin(11), cDept(15), cSec(14), C("Religion", 10, "c", e => e.Religion) };
                    break;

                case "separation":
                    r.Title = "Separation Employee List"; r.File = "SeparationEmployeeList";
                    r.Filter = e => e.Resigned;
                    r.Hint = "(Resign_Status / Resign_Date দেখুন)";
                    r.Lv.Add(LvDept());
                    r.Cols = new List<Col> { cSl(5), cId(7), cName(17), cDes(15), cJoin(10), C("Resign Date", 10, "", e => e.ResignDateStr),
                        cSec(12), CGross("Gross Salary", 10), cRem(14) };
                    break;

                case "worker":
                    r.Title = "Worker Register"; r.File = "WorkerRegister";
                    r.Filter = e => !e.Resigned;
                    r.Lv.Add(LvDept());
                    r.Cols = new List<Col> { cSl(4), cId(7), cName(15), C("Father's Name", 14, "", e => e.Father), C("Gender", 6, "c", e => e.Gender),
                        cDes(12), cSec(11), cJoin(10), CGross("Gross", 9), C("Signature", 12, "", e => "") };
                    break;

                default:
                    return null;
            }
            return r;
        }

        // ================= Session / Query =================
        long UserCode { get { return SessionLong("User_Code", "UserCode", "User_ID", "UserID", "userid"); } }
        long FromCode
        {
            get
            {
                string[] v = Request.QueryString.GetValues("rc");
                long x;
                if (v != null)
                    for (int i = v.Length - 1; i >= 0; i--)
                        if (long.TryParse(v[i], out x)) return x;
                return ReportFormCode;
            }
        }

        long SessionLong(params string[] keys)
        {
            foreach (string k in keys)
            {
                long v;
                object o = Session[k];
                if (o != null && long.TryParse(Convert.ToString(o), out v) && v != 0) return v;
            }
            return 0;
        }

        string ReportKey()
        {
            string k = (Request.QueryString["rpt"] ?? "").Trim().ToLowerInvariant();
            if (k.Length > 0) return k;
            string m;
            return FormCodeMap.TryGetValue(FromCode, out m) ? m : "active";
        }

        void GetJoinRange(out DateTime from, out DateTime to)
        {
            DateTime t = DateTime.Today;
            if (!DateTime.TryParse(Request.QueryString["jf"], Inv, DateTimeStyles.None, out from)) from = new DateTime(t.Year, t.Month, 1);
            if (!DateTime.TryParse(Request.QueryString["jt"], Inv, DateTimeStyles.None, out to)) to = t;
            from = from.Date; to = to.Date;
        }

        // ================= রিপোর্ট স্টেট =================
        Rpt rp;
        List<Emp> list;
        string company = "", address = "", subTitle = "";

        // ================= Page Load =================
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;
            if (!Prepare()) return;

            litTable.Text = BuildTable(false);
        }

        // ================= Word / Excel =================
        protected void btnWord_Click(object sender, EventArgs e) { SendFile(".doc", "application/msword"); }
        protected void btnExcel_Click(object sender, EventArgs e) { SendFile(".xls", "application/vnd.ms-excel"); }

        void SendFile(string ext, string mime)
        {
            if (!Prepare()) return;

            string html = "<html xmlns:o=\"urn:schemas-microsoft-com:office:office\" xmlns:x=\"urn:schemas-microsoft-com:office:excel\">"
                        + "<head><meta charset=\"utf-8\"/><style>" + ExportCss + "</style></head><body>"
                        + BuildTable(true) + "</body></html>";

            Response.Clear();
            Response.Buffer = true;
            Response.ContentType = mime + "; charset=utf-8";
            Response.Charset = "utf-8";
            Response.AddHeader("Content-Disposition", "attachment; filename=" + rp.File + ext);
            Response.BinaryWrite(new UTF8Encoding(true).GetPreamble());
            Response.BinaryWrite(Encoding.UTF8.GetBytes(html));
            Response.Flush();
            Response.End();
        }

        // ================= ডাটা প্রস্তুত =================
        bool Prepare()
        {
            if (UserCode == 0)
            {
                ShowMessage("User_Code পাওয়া যায়নি (Session)। Login করে আবার চেষ্টা করুন।");
                return false;
            }

            string key = ReportKey();
            rp = BuildReport(key);
            if (rp == null)
            {
                ShowMessage("অজানা রিপোর্ট: " + key);
                return false;
            }
            Page.Title = rp.Title;

            try
            {
                List<Emp> all = LoadEmps(UserCode, FromCode);
                if (all.Count == 0)
                {
                    int saved = CountSaved(UserCode, FromCode);
                    ShowMessage("কোনো কর্মচারীর তথ্য পাওয়া যায়নি। (User=" + UserCode + ", From_Code=" + FromCode +
                                ", z_Test_ID তে ID: " + saved + ")" +
                                (saved == 0
                                    ? " রিপোর্ট পেজ থেকে কর্মচারী টিক দিয়ে আবার Report View চাপুন।"
                                    : " ID সেভ আছে, কিন্তু Employee table গুলোর সঙ্গে মিলছে না।"));
                    return false;
                }

                list = all.FindAll(x => rp.Filter(x));
                if (list.Count == 0)
                {
                    ShowMessage(rp.Title + ": এই রিপোর্টের শর্তে কোনো কর্মচারী পাওয়া যায়নি। " + rp.Hint);
                    return false;
                }

                if (rp.Sort != null) list.Sort(rp.Sort);
                else list.Sort(DefaultCompare);

                for (int i = 0; i < list.Count; i++) list[i].Sl = (i + 1).ToString(Inv);

                Emp f = list[0];
                company = rp.Bn && f.BranchBn.Length > 0 ? f.BranchBn : f.Branch;
                address = rp.Bn && f.AddressBn.Length > 0 ? f.AddressBn : f.Address;

                subTitle = "";
                if (rp.JoinRange)
                {
                    DateTime jf, jt; GetJoinRange(out jf, out jt);
                    subTitle = "From " + jf.ToString("dd-MMM-yyyy", Inv) + " To " + jt.ToString("dd-MMM-yyyy", Inv);
                }
                return true;
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message);
                return false;
            }
        }

        int DefaultCompare(Emp a, Emp b)
        {
            foreach (Lvl l in rp.Lv)
            {
                int c = string.Compare(l.Key(a), l.Key(b), StringComparison.OrdinalIgnoreCase);
                if (c != 0) return c;
            }
            return CmpId(a.IdNo, b.IdNo);
        }

        static int CmpId(string a, string b)
        {
            long x, y;
            if (long.TryParse(a, out x) && long.TryParse(b, out y)) return x.CompareTo(y);
            return string.Compare(a, b, StringComparison.OrdinalIgnoreCase);
        }

        void ShowMessage(string msg)
        {
            lblNone.Text = HttpUtility.HtmlEncode(msg);
            lblNone.Visible = true;
            pnlReport.Visible = false;
        }

        int CountSaved(long user, long from)
        {
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();
                    using (var cmd = new SqlCommand("SELECT COUNT(*) FROM dbo.z_Test_ID WHERE User_ID=@u AND From_Code=@f", con))
                    {
                        cmd.Parameters.Add("@u", SqlDbType.BigInt).Value = user;
                        cmd.Parameters.Add("@f", SqlDbType.BigInt).Value = from;
                        return Convert.ToInt32(cmd.ExecuteScalar());
                    }
                }
            }
            catch { return -1; }
        }

        // ================= টেবিল HTML তৈরি =================
        string BuildTable(bool export)
        {
            var sb = new StringBuilder();
            int n = rp.Cols.Count;
            int gi = rp.Cols.FindIndex(c => c.IsGross);

            sb.Append("<table class=\"t\"><colgroup>");
            foreach (Col c in rp.Cols) sb.Append("<col style=\"width:" + c.W + "%\" />");
            sb.Append("</colgroup><thead>");

            sb.Append("<tr class=\"headRow\"><td class=\"headCell\" colspan=\"" + n + "\"><div class=\"head\">");
            if (!export) sb.Append(LogoHtml());
            sb.Append("<div class=\"co\">" + H(company) + "</div>");
            if (address.Length > 0) sb.Append("<div class=\"adr\">" + H(address) + "</div>");
            sb.Append("<div class=\"ttl\">" + H(rp.Title) + "</div>");
            if (subTitle.Length > 0) sb.Append("<div class=\"sub\">" + H(subTitle) + "</div>");
            sb.Append("</div></td></tr>");

            sb.Append("<tr>");
            foreach (Col c in rp.Cols) sb.Append("<th>" + H(c.H) + "</th>");
            sb.Append("</tr></thead><tbody>");

            int L = rp.Lv.Count;
            decimal[] tot = new decimal[L];
            int[] cnt = new int[L];
            decimal grand = 0;

            for (int i = 0; i < list.Count; i++)
            {
                Emp cur = list[i];
                Emp prev = i > 0 ? list[i - 1] : null;
                Emp next = i < list.Count - 1 ? list[i + 1] : null;

                for (int l = 0; l < L; l++)
                {
                    if (prev == null || Path(prev, l) != Path(cur, l))
                    {
                        tot[l] = 0; cnt[l] = 0;
                        sb.Append("<tr class=\"" + rp.Lv[l].Css + "\"><td colspan=\"" + n + "\"><b>" + H(rp.Lv[l].Label) + ": " + H(rp.Lv[l].Key(cur)) + "</b></td></tr>");
                    }
                }

                sb.Append("<tr>");
                foreach (Col c in rp.Cols)
                {
                    string v = c.V(cur);
                    sb.Append("<td" + (c.Cls.Length > 0 ? " class=\"" + c.Cls + "\"" : "") + ">" + (c.Html ? v : H(v)) + "</td>");
                }
                sb.Append("</tr>");

                grand += cur.Gross;
                for (int l = 0; l < L; l++) { tot[l] += cur.Gross; cnt[l]++; }

                for (int l = L - 1; l >= 0; l--)
                {
                    if (next == null || Path(next, l) != Path(cur, l))
                    {
                        string lbl = H(rp.Lv[l].Total) + " (" + H(rp.Lv[l].Key(cur)) + ")";
                        if (gi > 0)
                        {
                            sb.Append("<tr class=\"sub\"><td colspan=\"" + gi + "\" class=\"r\"><b>" + lbl + "</b></td>"
                                    + "<td class=\"r\"><b>" + tot[l].ToString("#,##0", Inv) + "</b></td>");
                            if (n - gi - 1 > 0) sb.Append("<td colspan=\"" + (n - gi - 1) + "\"></td>");
                            sb.Append("</tr>");
                        }
                        else
                        {
                            sb.Append("<tr class=\"sub\"><td colspan=\"" + n + "\" class=\"r\"><b>" + lbl + ": " + cnt[l] + "</b></td></tr>");
                        }
                    }
                }
            }

            if (gi > 0)
            {
                sb.Append("<tr class=\"grand\"><td colspan=\"" + gi + "\" class=\"r\"><b>" + H(rp.GrandLabel) + " (" + list.Count + ")</b></td>"
                        + "<td class=\"r\"><b>" + grand.ToString("#,##0", Inv) + "</b></td>");
                if (n - gi - 1 > 0) sb.Append("<td colspan=\"" + (n - gi - 1) + "\"></td>");
                sb.Append("</tr>");
            }
            else
            {
                sb.Append("<tr class=\"grand\"><td colspan=\"" + n + "\" class=\"r\"><b>" + H(rp.CountLabel) + ": " + list.Count + "</b></td></tr>");
            }

            sb.Append("</tbody></table>");
            return sb.ToString();
        }

        string Path(Emp e, int level)
        {
            var sb = new StringBuilder();
            for (int i = 0; i <= level; i++) sb.Append(rp.Lv[i].Key(e)).Append('\u0001');
            return sb.ToString();
        }

        static string H(string s) { return HttpUtility.HtmlEncode(s ?? ""); }

        // ================= ডাটা লোড =================
        List<Emp> LoadEmps(long user, long from)
        {
            var dt = new DataTable();
            using (SqlConnection con = conn.openConnection())
            {
                if (con.State != ConnectionState.Open) con.Open();
                using (var cmd = new SqlCommand(Sql, con))
                {
                    cmd.Parameters.Add("@u", SqlDbType.BigInt).Value = user;
                    cmd.Parameters.Add("@f", SqlDbType.BigInt).Value = from;
                    using (var da = new SqlDataAdapter(cmd)) da.Fill(dt);
                }
            }

            bool hasFire = HasCol(dt, "Fire_Fighter", "FireFighter", "Fire_Fighter_Status", "Is_Fire_Fighter", "Fire_Fighting");
            bool hasNight = HasCol(dt, "Night_Permission", "Night_Permission_Status", "Night_Permit", "Night_Allow");

            var res = new List<Emp>();
            var seen = new HashSet<string>();
            foreach (DataRow r in dt.Rows)
            {
                string id = S(r, "ID_no");
                if (!seen.Add(id)) continue;

                var e = new Emp();
                e.Row = r;
                e.IdNo = id;
                e.Name = S(r, "Name");
                e.NameBn = Fb(Pick(r, "Name_Bangla", "Bangla_Name", "Name_Bn", "Employee_Name_Bangla", "NameBangla"), e.Name);
                e.Branch = S(r, "Branch_Name");
                e.BranchBn = S(r, "Branch_Bangla");
                e.Address = S(r, "Address");
                e.AddressBn = S(r, "Bangla_Address_Branch");
                e.Department = S(r, "Department_Name");
                e.DeptBn = Fb(Pick(r, "Department_Bangla", "Department_Name_Bangla", "Dept_Bangla", "Department_Bn"), e.Department);
                e.Section = S(r, "Section_Name");
                e.SecBn = Fb(Pick(r, "Section_Bangla", "Section_Name_Bangla", "Section_Bn"), e.Section);
                e.Designation = S(r, "Desigation_name");
                e.DesigBn = Fb(Pick(r, "Desigation_Bangla", "Designation_Bangla", "Desigation_name_Bangla", "Designation_Bn"), e.Designation);

                e.Join = ParseDate(r["Joining_Date"]);
                e.JoinDate = e.Join.HasValue ? e.Join.Value.ToString("dd-MMM-yyyy", Inv) : "";
                DateTime? rd = ParseDate(r["Resign_Date"]);
                bool rdOk = rd.HasValue && rd.Value.Year > 1990;
                e.ResignDateStr = rdOk ? rd.Value.ToString("dd-MMM-yyyy", Inv) : "";

                // Resign_Status এর মান আপনার ডাটাবেস অনুযায়ী এখানে ঠিক করে নিন
                string rs = S(r, "Resign_Status").ToLowerInvariant();
                if (rs.Length == 0) e.Resigned = rdOk;
                else e.Resigned = rs == "1" || rs == "true" || rs == "yes" || rs == "y" || rs == "r" || rs == "s"
                               || rs.Contains("resign") || rs.Contains("separat") || rs.Contains("left") || rs.Contains("inactive");

                e.Gender = S(r, "Gender");
                string g = e.Gender.ToLowerInvariant();
                e.Male = g == "male" || g == "m" || g == "পুরুষ";
                e.Religion = S(r, "Religion");
                e.Blood = Pick(r, "Blood_Group", "BloodGroup", "Blood_Group_Name", "Blood");
                e.Father = Pick(r, "Father_Name", "Fathers_Name", "Father", "FatherName");

                decimal gr = Math.Round(Dec(r["Gross_Salary"]), MidpointRounding.AwayFromZero);
                e.Gross = gr;
                e.GrossStr = gr.ToString("#,##0", Inv);

                // Bank / Cash
                e.BankNo = Pick(r, "Bank_Account_No", "Bank_AC_No", "Account_No", "Bank_Account", "AC_No");
                string pm = Pick(r, "Payment_Mode", "Payment_Type", "Pay_Type", "Salary_Payment_Type", "Payment_Method").ToLowerInvariant();
                e.IsBank = pm.Contains("bank") || (pm.Length == 0 && e.BankNo.Length > 0);
                e.IsCash = pm.Contains("cash") || (pm.Length == 0 && e.BankNo.Length == 0);

                // Insurance
                e.Insurance = Pick(r, "Group_Insurance", "Group_Insurance_No", "Insurance_No", "Insurance_Policy_No", "Group_Insurance_Status");
                string iv = e.Insurance.ToLowerInvariant();
                e.HasIns = iv.Length > 0 && iv != "0" && iv != "false" && iv != "no" && iv != "n";

                // Fire fighter
                e.Fire = hasFire
                    ? Yes(Pick(r, "Fire_Fighter", "FireFighter", "Fire_Fighter_Status", "Is_Fire_Fighter", "Fire_Fighting"))
                    : (e.Designation + " " + e.Section).ToLowerInvariant().Contains("fire");

                // Night permission
                e.Night = hasNight && Yes(Pick(r, "Night_Permission", "Night_Permission_Status", "Night_Permit", "Night_Allow"));

                res.Add(e);
            }
            return res;
        }

        // ================= লোগো / ফটো =================
        string LogoHtml()
        {
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();
                    using (var cmd = new SqlCommand(LogoSql, con))
                    {
                        cmd.Parameters.Add("@u", SqlDbType.BigInt).Value = UserCode;
                        cmd.Parameters.Add("@f", SqlDbType.BigInt).Value = FromCode;
                        byte[] b = cmd.ExecuteScalar() as byte[];
                        if (b == null || b.Length < 4) return "";
                        return "<img class=\"logo\" alt=\"\" src=\"data:" + Mime(b) + ";base64," + Convert.ToBase64String(b) + "\" />";
                    }
                }
            }
            catch { return ""; }
        }

        static string PhotoHtml(DataRow r)
        {
            foreach (string n in new[] { "Photo", "Image", "Employee_Photo", "Emp_Photo", "Picture", "Employee_Image" })
            {
                if (r.Table.Columns.Contains(n) && r[n] is byte[])
                {
                    byte[] b = (byte[])r[n];
                    if (b.Length > 3)
                        return "<img class=\"ph\" alt=\"\" src=\"data:" + Mime(b) + ";base64," + Convert.ToBase64String(b) + "\" />";
                }
            }
            return "";
        }

        static string Mime(byte[] b)
        {
            if (b[0] == 0xFF && b[1] == 0xD8) return "image/jpeg";
            if (b[0] == 0x47 && b[1] == 0x49) return "image/gif";
            if (b[0] == 0x42 && b[1] == 0x4D) return "image/bmp";
            return "image/png";
        }

        // ================= হেল্পার =================
        static string S(DataRow r, string col)
        {
            if (!r.Table.Columns.Contains(col) || r[col] == DBNull.Value) return "";
            return Convert.ToString(r[col]).Trim();
        }

        static string Pick(DataRow r, params string[] names)
        {
            foreach (string n in names)
            {
                string v = S(r, n);
                if (v.Length > 0) return v;
            }
            return "";
        }

        static bool HasCol(DataTable t, params string[] names)
        {
            foreach (string n in names) if (t.Columns.Contains(n)) return true;
            return false;
        }

        static string Fb(string v, string fallback) { return v.Length > 0 ? v : fallback; }

        static bool Yes(string v)
        {
            v = (v ?? "").Trim().ToLowerInvariant();
            return v == "1" || v == "true" || v == "yes" || v == "y" || v == "হ্যাঁ";
        }

        static decimal Dec(object o)
        {
            decimal d;
            if (o == null || o == DBNull.Value) return 0;
            return decimal.TryParse(Convert.ToString(o), NumberStyles.Any, Inv, out d) ? d : 0;
        }

        static DateTime? ParseDate(object o)
        {
            DateTime dt;
            if (o == null || o == DBNull.Value) return null;
            if (o is DateTime) return (DateTime)o;
            if (!DateTime.TryParse(Convert.ToString(o), out dt)) return null;
            return dt;
        }
    }
}