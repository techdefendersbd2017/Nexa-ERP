using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Text;
using System.Web;
using System.Web.UI;

// ASPX এর Inherits="Nexa_ERP.HRMPayroll.HRMPayrollReports.HRReports.ActiveEmployeeListReport" এর সঙ্গে মিলতে হবে
namespace Nexa_ERP.HRMPayroll.HRMPayrollReports.HRReports
{
    // ---------- একটি সারির তথ্য (সব আগে থেকে ফরম্যাট করা) ----------
    public class AelRow
    {
        public string Sl { get; set; }
        public string IdNo { get; set; }
        public string Name { get; set; }
        public string Designation { get; set; }
        public string JoinDate { get; set; }
        public string Department { get; set; }
        public string Section { get; set; }
        public string Line { get; set; }
        public string Gross { get; set; }      // 14,273
        public string GrossRaw { get; set; }   // 14273 (Excel এর জন্য)
    }

    public partial class ActiveEmployeeListReport : Page
    {
        PayrollDB conn = new PayrollDB();
        static readonly CultureInfo Inv = CultureInfo.InvariantCulture;

        const string ReportTitle = "Active Employee List";

        // HRMReports এর ResolveReport এ এই রিপোর্টের formCode এর সঙ্গে মিলতে হবে
        const int ReportFormCode = 7;

        // z_Test_ID এর সঙ্গে JOIN: শুধু HRMReports এ টিক দেওয়া কর্মচারীরা আসে।
        // Nominee / Photo টেবিলে INNER JOIN নেই, তাই একই কর্মচারী একাধিকবার আসে না
        // এবং ছবি/নমিনি না থাকলেও কেউ বাদ পড়ে না।
        const string Sql = @"
SELECT e.ID_no, e.Name, e.Designation, e.Joining_Date, e.Department, e.Section, e.Line,
       e.Company_Name, sal.Gross_Salary
FROM dbo.Employee_information_new e
INNER JOIN dbo.z_Test_ID z ON e.ID_no = z.ID_No
LEFT JOIN dbo.Employee_Salary_information_new sal ON e.ID_no = sal.ID_no
WHERE z.User_ID = @u AND z.From_Code = @f
ORDER BY e.ID_no";

        const string LogoSql = @"
SELECT TOP 1 c.Company_Logo
FROM dbo.z_Test_ID z
INNER JOIN dbo.Employee_information_With_Code ec ON z.ID_No = ec.ID_no
INNER JOIN dbo.TB_Company c ON ec.Company_Code = c.Company_Code
WHERE z.User_ID = @u AND z.From_Code = @f";

        long UserCode { get { return SessionLong("User_Code", "UserCode", "User_ID", "UserID", "userid"); } }
        long FromCode { get { return ReportFormCode; } }

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

        string company = "";

        // ================= Page Load =================
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            List<AelRow> rows = LoadForPage();
            if (rows == null) return;

            lblCompany.Text = HttpUtility.HtmlEncode(company);
            litLogo.Text = LogoHtml();
            rptRows.DataSource = rows;
            rptRows.DataBind();
        }

        // রো লোড করে; সমস্যা হলে বার্তা দেখিয়ে null ফেরত দেয়
        List<AelRow> LoadForPage()
        {
            if (UserCode == 0)
            {
                ShowMessage("User_Code পাওয়া যায়নি (Session)। Login করে আবার চেষ্টা করুন।");
                return null;
            }

            try
            {
                List<AelRow> rows = LoadRows(UserCode, FromCode);
                if (rows.Count == 0)
                {
                    int saved = CountSaved(UserCode, FromCode);
                    ShowMessage("কোনো কর্মচারীর তথ্য পাওয়া যায়নি। (User=" + UserCode + ", From_Code=" + FromCode +
                                ", z_Test_ID তে ID: " + saved + ")" +
                                (saved == 0
                                    ? " রিপোর্ট পেজ থেকে কর্মচারী টিক দিয়ে আবার Report View চাপুন।"
                                    : " ID সেভ আছে, কিন্তু Employee_information_new এ মিলছে না।"));
                    return null;
                }
                return rows;
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message);
                return null;
            }
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

        // ================= ডাউনলোড বাটন =================
        protected void btnPdf_Click(object sender, EventArgs e)
        {
            List<AelRow> rows = LoadForPage();
            if (rows == null) return;
            Send(AelExport.Pdf(rows, company, ReportTitle), "application/pdf", "ActiveEmployeeList.pdf");
        }

        protected void btnWord_Click(object sender, EventArgs e)
        {
            List<AelRow> rows = LoadForPage();
            if (rows == null) return;
            Send(Utf8Bom(AelExport.WordHtml(rows, company, ReportTitle)), "application/msword", "ActiveEmployeeList.doc");
        }

        protected void btnExcel_Click(object sender, EventArgs e)
        {
            List<AelRow> rows = LoadForPage();
            if (rows == null) return;
            Send(Utf8Bom(AelExport.ExcelHtml(rows, company, ReportTitle)), "application/vnd.ms-excel", "ActiveEmployeeList.xls");
        }

        static byte[] Utf8Bom(string html)
        {
            var enc = new UTF8Encoding(true);
            byte[] pre = enc.GetPreamble(), body = enc.GetBytes(html);
            byte[] all = new byte[pre.Length + body.Length];
            System.Buffer.BlockCopy(pre, 0, all, 0, pre.Length);
            System.Buffer.BlockCopy(body, 0, all, pre.Length, body.Length);
            return all;
        }

        void Send(byte[] data, string contentType, string fileName)
        {
            Response.Clear();
            Response.Buffer = true;
            Response.ContentType = contentType;
            Response.AddHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
            Response.AddHeader("Content-Length", data.Length.ToString(Inv));
            Response.BinaryWrite(data);
            Response.Flush();
            Response.SuppressContent = true;
            Context.ApplicationInstance.CompleteRequest();
        }

        // ASPX এ <%# H(Eval("...")) %> — HTML encode করে
        protected string H(object o)
        {
            return HttpUtility.HtmlEncode(Convert.ToString(o));
        }

        // ================= ডাটা লোড =================
        List<AelRow> LoadRows(long user, long from)
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

            var list = new List<AelRow>();
            var seen = new HashSet<string>();
            foreach (DataRow r in dt.Rows)
            {
                string id = S(r, "ID_no");
                if (!seen.Add(id)) continue;   // একই কর্মচারী একবারই

                if (company.Length == 0) company = S(r, "Company_Name");

                decimal gross = Dec(r["Gross_Salary"]);
                string line = S(r, "Line");
                list.Add(new AelRow
                {
                    Sl = (list.Count + 1).ToString(Inv),
                    IdNo = id,
                    Name = S(r, "Name"),
                    Designation = S(r, "Designation"),
                    JoinDate = FmtDate(r["Joining_Date"]),
                    Department = S(r, "Department"),
                    Section = S(r, "Section"),
                    Line = line.Length == 0 ? "--" : line,
                    Gross = Math.Round(gross, MidpointRounding.AwayFromZero).ToString("#,##0", Inv),
                    GrossRaw = Math.Round(gross, MidpointRounding.AwayFromZero).ToString("0", Inv)
                });
            }
            return list;
        }

        // কোম্পানির লোগো (থাকলে) — ছোট আলাদা কোয়েরি, যাতে প্রতি সারিতে ছবি না আসে
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
                        string mime = "image/png";
                        if (b[0] == 0xFF && b[1] == 0xD8) mime = "image/jpeg";
                        else if (b[0] == 0x47 && b[1] == 0x49) mime = "image/gif";
                        else if (b[0] == 0x42 && b[1] == 0x4D) mime = "image/bmp";
                        return "<img class=\"logo\" alt=\"\" src=\"data:" + mime + ";base64," + Convert.ToBase64String(b) + "\" />";
                    }
                }
            }
            catch { return ""; }
        }

        // ---------- ফরম্যাট সাহায্যকারী ----------
        static string S(DataRow r, string col)
        {
            if (!r.Table.Columns.Contains(col) || r[col] == DBNull.Value) return "";
            return Convert.ToString(r[col]).Trim();
        }

        static decimal Dec(object o)
        {
            decimal d;
            if (o == null || o == DBNull.Value) return 0;
            return decimal.TryParse(Convert.ToString(o), NumberStyles.Any, Inv, out d) ? d : 0;
        }

        static string FmtDate(object o)
        {
            DateTime dt;
            if (o == null || o == DBNull.Value) return "";
            if (o is DateTime) dt = (DateTime)o;
            else if (!DateTime.TryParse(Convert.ToString(o), out dt)) return "";
            return dt.ToString("dd-MMM-yyyy", Inv);   // 01-Apr-2026
        }
    }

    // =====================================================================
    //  এক্সপোর্ট: PDF (হাতে তৈরি, কোনো লাইব্রেরি লাগে না), Word ও Excel (HTML ভিত্তিক)
    // =====================================================================
    public static class AelExport
    {
        static readonly CultureInfo Inv = CultureInfo.InvariantCulture;

        static readonly string[] Head = { "Sl", "ID No", "Name", "Designation", "Joining Date", "Department", "Section", "Line", "Gross Salary" };
        // 0 = বাম, 1 = মাঝ, 2 = ডান
        static readonly int[] Align = { 1, 2, 0, 0, 0, 0, 0, 0, 2 };

        static string[] Cells(AelRow r)
        {
            return new[] { r.Sl, r.IdNo, r.Name, r.Designation, r.JoinDate, r.Department, r.Section, r.Line, r.Gross };
        }

        // ------------------------- Word -------------------------
        public static string WordHtml(List<AelRow> rows, string company, string title)
        {
            var sb = new StringBuilder();
            sb.Append("<html xmlns:o=\"urn:schemas-microsoft-com:office:office\" xmlns:w=\"urn:schemas-microsoft-com:office:word\" xmlns=\"http://www.w3.org/TR/REC-html40\">");
            sb.Append("<head><meta charset=\"utf-8\"><title>").Append(Enc(title)).Append("</title>");
            sb.Append("<!--[if gte mso 9]><xml><w:WordDocument><w:View>Print</w:View><w:Zoom>100</w:Zoom></w:WordDocument></xml><![endif]-->");
            sb.Append("<style>");
            sb.Append("@page Section1{size:595.3pt 841.9pt;margin:36pt 36pt 36pt 36pt}");
            sb.Append("div.Section1{page:Section1}");
            sb.Append("body{font-family:Arial,Helvetica,sans-serif;font-size:8pt}");
            sb.Append("p{margin:0}");
            sb.Append("table.t{border-collapse:collapse;width:100%}");
            sb.Append("table.t td,table.t th{border:1px solid #000;padding:2pt 3pt;font-size:8pt;vertical-align:top;font-family:Arial,Helvetica,sans-serif}");
            sb.Append("table.t th{font-weight:normal;text-align:center}");
            sb.Append("</style></head><body><div class=\"Section1\">");
            sb.Append("<p style=\"text-align:center;font-size:14pt;font-weight:bold\">").Append(Enc(company)).Append("</p>");
            sb.Append("<p style=\"text-align:center;font-size:9pt;border-bottom:1px solid #000;padding-bottom:3pt;margin-bottom:6pt\">").Append(Enc(title)).Append("</p>");
            sb.Append(DataTable(rows, false));
            sb.Append("</div></body></html>");
            return sb.ToString();
        }

        // ------------------------- Excel -------------------------
        public static string ExcelHtml(List<AelRow> rows, string company, string title)
        {
            var sb = new StringBuilder();
            sb.Append("<html xmlns:o=\"urn:schemas-microsoft-com:office:office\" xmlns:x=\"urn:schemas-microsoft-com:office:excel\" xmlns=\"http://www.w3.org/TR/REC-html40\">");
            sb.Append("<head><meta charset=\"utf-8\">");
            sb.Append("<!--[if gte mso 9]><xml><x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet><x:Name>").Append(Enc(title));
            sb.Append("</x:Name><x:WorksheetOptions><x:DisplayGridlines/></x:WorksheetOptions></x:ExcelWorksheet></x:ExcelWorksheets></x:ExcelWorkbook></xml><![endif]-->");
            sb.Append("<style>td,th{font-family:Arial,Helvetica,sans-serif;font-size:10pt;vertical-align:top}</style></head><body>");
            sb.Append("<table border=\"0\">");
            sb.Append("<tr><td colspan=\"9\" style=\"text-align:center;font-size:14pt;font-weight:bold\">").Append(Enc(company)).Append("</td></tr>");
            sb.Append("<tr><td colspan=\"9\" style=\"text-align:center;font-size:11pt\">").Append(Enc(title)).Append("</td></tr>");
            sb.Append("</table>");
            sb.Append(DataTable(rows, true));
            sb.Append("</body></html>");
            return sb.ToString();
        }

        static string DataTable(List<AelRow> rows, bool excel)
        {
            double[] pct = { 5, 7, 19, 14, 12, 15, 12, 5, 11 };
            var sb = new StringBuilder();
            sb.Append("<table class=\"t\" border=\"1\" cellspacing=\"0\" cellpadding=\"3\" style=\"border-collapse:collapse;width:100%\">");
            sb.Append("<tr>");
            for (int i = 0; i < Head.Length; i++)
                sb.Append("<th style=\"width:").Append(pct[i].ToString("0", Inv)).Append("%;border:1px solid #000;text-align:center;font-weight:normal\">").Append(Enc(Head[i])).Append("</th>");
            sb.Append("</tr>");

            foreach (AelRow r in rows)
            {
                string[] c = Cells(r);
                sb.Append("<tr>");
                for (int i = 0; i < c.Length; i++)
                {
                    string al = Align[i] == 1 ? "center" : (Align[i] == 2 ? "right" : "left");
                    string extra = "";
                    string val = Enc(c[i]);
                    if (excel)
                    {
                        if (i == 8) { val = Enc(r.GrossRaw); extra = ";mso-number-format:'\\#\\,\\#\\#0'"; }
                        else if (i == 1 || i == 0) extra = ";mso-number-format:'0'";
                        else extra = ";mso-number-format:'\\@'";
                    }
                    sb.Append("<td style=\"border:1px solid #000;text-align:").Append(al).Append(extra).Append("\">").Append(val).Append("</td>");
                }
                sb.Append("</tr>");
            }
            sb.Append("</table>");
            return sb.ToString();
        }

        static string Enc(string s) { return HttpUtility.HtmlEncode(s ?? ""); }

        // ------------------------- PDF -------------------------
        // Helvetica এর অক্ষর-প্রস্থ (ASCII 32..126, প্রতি ১০০০ এককে)
        static readonly int[] Hw = {
            278,278,355,556,556,889,667,191,333,333,389,584,278,333,278,278,
            556,556,556,556,556,556,556,556,556,556,278,278,584,584,584,556,
            1015,667,667,722,722,667,611,778,722,278,500,667,556,833,722,778,
            667,778,722,667,611,722,667,944,667,667,611,278,278,278,469,556,
            333,556,556,500,556,556,278,556,556,222,222,500,222,833,556,556,
            556,556,333,500,278,556,500,722,500,500,500,334,260,334,584 };

        static double Tw(string s, double fs, bool bold)
        {
            double w = 0;
            foreach (char c in s)
            {
                int i = c - 32;
                w += (i >= 0 && i < Hw.Length) ? Hw[i] : 556;
            }
            w = w * fs / 1000.0;
            return bold ? w * 1.06 : w;
        }

        static string F(double d) { return d.ToString("0.##", Inv); }

        // বিল্ট-ইন PDF ফন্টে শুধু ASCII চলে; বাকি অক্ষর '?' হয়ে যায় (বাংলা নামের জন্য Print ব্যবহার করুন)
        static string Ascii(string s)
        {
            if (s == null) return "";
            var sb = new StringBuilder(s.Length);
            foreach (char c in s)
            {
                if (c >= 32 && c <= 126) sb.Append(c);
                else if (c == '\t' || c == '\r' || c == '\n') sb.Append(' ');
                else sb.Append('?');
            }
            return sb.ToString();
        }

        static string Esc(string s)
        {
            return s.Replace("\\", "\\\\").Replace("(", "\\(").Replace(")", "\\)");
        }

        static void Text(StringBuilder sb, string font, double fs, double x, double y, string s)
        {
            sb.Append("BT /").Append(font).Append(' ').Append(F(fs)).Append(" Tf ")
              .Append(F(x)).Append(' ').Append(F(y)).Append(" Td (").Append(Esc(s)).Append(") Tj ET\n");
        }

        static List<string> Wrap(string s, double width, double fs)
        {
            var lines = new List<string>();
            s = Ascii(s).Trim();
            if (s.Length == 0) { lines.Add(""); return lines; }

            string cur = "";
            foreach (string word0 in s.Split(' '))
            {
                if (word0.Length == 0) continue;
                // খুব লম্বা শব্দ হলে অক্ষরে অক্ষরে ভাঙা
                var parts = new List<string>();
                string w = word0;
                while (Tw(w, fs, false) > width && w.Length > 1)
                {
                    int k = w.Length - 1;
                    while (k > 1 && Tw(w.Substring(0, k), fs, false) > width) k--;
                    parts.Add(w.Substring(0, k));
                    w = w.Substring(k);
                }
                parts.Add(w);

                foreach (string word in parts)
                {
                    string t = cur.Length == 0 ? word : cur + " " + word;
                    if (cur.Length == 0 || Tw(t, fs, false) <= width) cur = t;
                    else { lines.Add(cur); cur = word; }
                }
            }
            if (cur.Length > 0) lines.Add(cur);
            if (lines.Count == 0) lines.Add("");
            return lines;
        }

        class Prep
        {
            public List<string>[] Cells;
            public double H;
        }

        public static byte[] Pdf(List<AelRow> rows, string company, string title)
        {
            const double W = 595.28, Ht = 841.89, M = 36;
            double[] cw = { 28, 38, 100, 72, 64, 78, 60, 28, 55 };
            const double fs = 8, lineH = 10, padV = 3, padH = 3, headH = 18, tableTop = M + 42;

            company = Ascii(company); title = Ascii(title);

            // ১) প্রতিটি সারির উচ্চতা হিসাব (শব্দ ভেঙে একাধিক লাইন হতে পারে)
            var preps = new List<Prep>();
            foreach (AelRow r in rows)
            {
                string[] c = Cells(r);
                var p = new Prep { Cells = new List<string>[c.Length] };
                int maxLines = 1;
                for (int i = 0; i < c.Length; i++)
                {
                    p.Cells[i] = Wrap(c[i], cw[i] - 2 * padH, fs);
                    if (p.Cells[i].Count > maxLines) maxLines = p.Cells[i].Count;
                }
                p.H = maxLines * lineH + 2 * padV;
                preps.Add(p);
            }

            // ২) পাতায় ভাগ করা
            var pages = new List<List<Prep>>();
            var curPage = new List<Prep>();
            double used = tableTop + headH;
            foreach (Prep p in preps)
            {
                if (used + p.H > Ht - M && curPage.Count > 0)
                {
                    pages.Add(curPage);
                    curPage = new List<Prep>();
                    used = tableTop + headH;
                }
                curPage.Add(p);
                used += p.H;
            }
            pages.Add(curPage);

            // ৩) প্রতিটি পাতার কনটেন্ট
            var contents = new List<string>();
            for (int pg = 0; pg < pages.Count; pg++)
            {
                var cs = new StringBuilder();
                cs.Append("0 G 0 g 0.5 w\n");

                double titleFs = 14;
                while (titleFs > 9 && Tw(company, titleFs, true) > W - 2 * M - 80) titleFs -= 0.5;
                Text(cs, "F2", titleFs, (W - Tw(company, titleFs, true)) / 2, Ht - (M + 14), company);

                string pageTxt = "Page " + (pg + 1) + " of " + pages.Count;
                Text(cs, "F1", 8, W - M - Tw(pageTxt, 8, false), Ht - (M + 10), pageTxt);
                Text(cs, "F1", 9, (W - Tw(title, 9, false)) / 2, Ht - (M + 30), title);

                cs.Append("1 w ").Append(F(M)).Append(' ').Append(F(Ht - (M + 36))).Append(" m ")
                  .Append(F(W - M)).Append(' ').Append(F(Ht - (M + 36))).Append(" l S 0.5 w\n");

                // হেডার সারি
                double x = M, top = tableTop;
                for (int i = 0; i < cw.Length; i++)
                {
                    cs.Append(F(x)).Append(' ').Append(F(Ht - (top + headH))).Append(' ')
                      .Append(F(cw[i])).Append(' ').Append(F(headH)).Append(" re S\n");
                    string h = Head[i];
                    Text(cs, "F1", fs, x + (cw[i] - Tw(h, fs, false)) / 2, Ht - (top + headH / 2 + 3), h);
                    x += cw[i];
                }
                top += headH;

                // ডাটা সারি
                foreach (Prep p in pages[pg])
                {
                    x = M;
                    for (int i = 0; i < cw.Length; i++)
                    {
                        cs.Append(F(x)).Append(' ').Append(F(Ht - (top + p.H))).Append(' ')
                          .Append(F(cw[i])).Append(' ').Append(F(p.H)).Append(" re S\n");
                        for (int ln = 0; ln < p.Cells[i].Count; ln++)
                        {
                            string t = p.Cells[i][ln];
                            double tx = x + padH;
                            if (Align[i] == 1) tx = x + (cw[i] - Tw(t, fs, false)) / 2;
                            else if (Align[i] == 2) tx = x + cw[i] - padH - Tw(t, fs, false);
                            Text(cs, "F1", fs, tx, Ht - (top + padV + 8 + ln * lineH), t);
                        }
                        x += cw[i];
                    }
                    top += p.H;
                }
                contents.Add(cs.ToString());
            }

            // ৪) PDF ফাইল জোড়া লাগানো
            var sb = new StringBuilder();
            var offs = new List<int>();
            sb.Append("%PDF-1.4\n");

            AddObj(sb, offs, "<< /Type /Catalog /Pages 2 0 R >>");

            var kids = new StringBuilder();
            for (int i = 0; i < pages.Count; i++) kids.Append(5 + 2 * i).Append(" 0 R ");
            AddObj(sb, offs, "<< /Type /Pages /Kids [" + kids.ToString().Trim() + "] /Count " + pages.Count + " >>");

            AddObj(sb, offs, "<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica /Encoding /WinAnsiEncoding >>");
            AddObj(sb, offs, "<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold /Encoding /WinAnsiEncoding >>");

            for (int i = 0; i < pages.Count; i++)
            {
                int contentId = 6 + 2 * i;
                AddObj(sb, offs, "<< /Type /Page /Parent 2 0 R /MediaBox [0 0 " + F(W) + " " + F(Ht) +
                                 "] /Resources << /Font << /F1 3 0 R /F2 4 0 R >> >> /Contents " + contentId + " 0 R >>");
                AddObj(sb, offs, "<< /Length " + contents[i].Length + " >>\nstream\n" + contents[i] + "\nendstream");
            }

            int xref = sb.Length;
            sb.Append("xref\n0 ").Append(offs.Count + 1).Append("\n0000000000 65535 f \n");
            foreach (int o in offs) sb.Append(o.ToString("0000000000", Inv)).Append(" 00000 n \n");
            sb.Append("trailer\n<< /Size ").Append(offs.Count + 1).Append(" /Root 1 0 R >>\nstartxref\n")
              .Append(xref).Append("\n%%EOF");

            return Encoding.ASCII.GetBytes(sb.ToString());
        }

        static void AddObj(StringBuilder sb, List<int> offs, string body)
        {
            offs.Add(sb.Length);
            sb.Append(offs.Count).Append(" 0 obj\n").Append(body).Append("\nendobj\n");
        }
    }
}
