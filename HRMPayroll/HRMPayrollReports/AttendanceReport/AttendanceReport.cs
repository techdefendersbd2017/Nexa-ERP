using System;
using System.Collections.Generic;
using System.Globalization;
using System.Text;
using System.Web;

namespace Nexa_ERP.HRMPayroll.HRMPayrollReports.AttendanceReport
{
    // ---------- একটি সারি ----------
    // IsGroup = Department/Section গ্রুপ সারি, IsTotal = শেষের যোগফল সারি, নইলে Cells = ডাটা সারি
    public class RptRow
    {
        public bool IsGroup;
        public bool IsTotal;
        public string Text;
        public string[] Cells;
    }

    // ---------- একদিনের পাতা (HTML রিপোর্টের একটি <section>) ----------
    public class RptSection
    {
        public string Company, Address, Title, Summary, Stamp;
        public string[] Head;
        public int[] Align;        // 0 = বাম, 1 = মাঝ, 2 = ডান
        public double[] Weights;   // কলামের আপেক্ষিক প্রস্থ
        public List<RptRow> Rows = new List<RptRow>();
    }

    // =====================================================================
    //  PDF (হাতে তৈরি, লাইব্রেরি লাগে না), Word ও Excel (HTML ভিত্তিক) এক্সপোর্ট
    //  প্রতিটি তারিখ আলাদা পাতায় যায়।
    // =====================================================================
    public static class ReportExport
    {
        static readonly CultureInfo Inv = CultureInfo.InvariantCulture;

        static readonly string[] Signs = { "Prepared By", "Time Section", "S.V/Line Chief Incharge", "A.P.M/P.M", "Checked by HR", "Approved By" };

        // ============ পেজ থেকে যে ৩টি মেথড কল করবেন ============
        public static void DownloadPdf(List<RptSection> secs, string fileName)
        {
            Send(Pdf(secs), "application/pdf", fileName);
        }

        public static void DownloadWord(List<RptSection> secs, string fileName)
        {
            Send(Utf8Bom(WordHtml(secs)), "application/msword", fileName);
        }

        public static void DownloadExcel(List<RptSection> secs, string fileName)
        {
            Send(Utf8Bom(ExcelHtml(secs)), "application/vnd.ms-excel", fileName);
        }

        // ============ ফাইল ব্রাউজারে পাঠানো ============
        static void Send(byte[] data, string contentType, string fileName)
        {
            HttpContext ctx = HttpContext.Current;
            HttpResponse res = ctx.Response;

            res.Clear();
            res.Buffer = true;
            res.ContentType = contentType;
            res.AddHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
            res.AddHeader("Content-Length", data.Length.ToString(Inv));
            res.BinaryWrite(data);
            res.Flush();
            res.SuppressContent = true;
            ctx.ApplicationInstance.CompleteRequest();
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

        static string Enc(string s) { return HttpUtility.HtmlEncode(s ?? ""); }

        static string AlignName(int a) { return a == 1 ? "center" : (a == 2 ? "right" : "left"); }

        // ------------------------- Word / Excel এর সাধারণ সারি তৈরি -------------------------
        static void AppendRows(StringBuilder sb, RptSection sec, bool excel)
        {
            int n = sec.Head.Length;
            double sum = 0;
            foreach (double w in sec.Weights) sum += w;
            string txt = excel ? ";mso-number-format:'\\@'" : "";

            sb.Append("<tr>");
            for (int i = 0; i < n; i++)
            {
                string width = excel ? "" : "width:" + (sec.Weights[i] / sum * 100).ToString("0.#", Inv) + "%;";
                sb.Append("<th style=\"" + width + "border:1px solid #000;text-align:center;font-weight:bold;background:#f1f1f1\">")
                  .Append(Enc(sec.Head[i])).Append("</th>");
            }
            sb.Append("</tr>");

            foreach (RptRow r in sec.Rows)
            {
                if (r.IsGroup)
                {
                    sb.Append("<tr><td colspan=\"" + n + "\" style=\"border:1px solid #000;font-weight:bold;background:#f5f5f5\">")
                      .Append(Enc(r.Text)).Append("</td></tr>");
                }
                else if (r.IsTotal)
                {
                    sb.Append("<tr><td colspan=\"" + n + "\" style=\"border:0;font-weight:bold\">")
                      .Append(Enc(r.Text)).Append("</td></tr>");
                }
                else
                {
                    sb.Append("<tr>");
                    for (int i = 0; i < n; i++)
                    {
                        string v = (r.Cells != null && i < r.Cells.Length) ? r.Cells[i] : "";
                        sb.Append("<td style=\"border:1px solid #000;text-align:" + AlignName(sec.Align[i]) + txt + "\">")
                          .Append(Enc(v)).Append("</td>");
                    }
                    sb.Append("</tr>");
                }
            }
        }

        // ------------------------- Word -------------------------
        public static string WordHtml(List<RptSection> secs)
        {
            var sb = new StringBuilder();
            sb.Append("<html xmlns:o=\"urn:schemas-microsoft-com:office:office\" xmlns:w=\"urn:schemas-microsoft-com:office:word\" xmlns=\"http://www.w3.org/TR/REC-html40\">");
            sb.Append("<head><meta charset=\"utf-8\"><title>Attendance Report</title>");
            sb.Append("<!--[if gte mso 9]><xml><w:WordDocument><w:View>Print</w:View><w:Zoom>100</w:Zoom></w:WordDocument></xml><![endif]-->");
            sb.Append("<style>");
            sb.Append("@page Section1{size:595.3pt 841.9pt;margin:28pt 28pt 28pt 28pt}");
            sb.Append("div.Section1{page:Section1}");
            sb.Append("body{font-family:Arial,Helvetica,sans-serif;font-size:8pt}");
            sb.Append("p{margin:0}");
            sb.Append("table.t{border-collapse:collapse;width:100%}");
            sb.Append("table.t td,table.t th{padding:2pt 3pt;font-size:8pt;vertical-align:top;font-family:Arial,Helvetica,sans-serif}");
            sb.Append("</style></head><body><div class=\"Section1\">");

            for (int s = 0; s < secs.Count; s++)
            {
                RptSection sec = secs[s];
                sb.Append(s == 0 ? "<div>" : "<div style=\"page-break-before:always\">");
                sb.Append("<p style=\"text-align:center;font-size:14pt;font-weight:bold\">").Append(Enc(sec.Company)).Append("</p>");
                sb.Append("<p style=\"text-align:center;font-size:9pt\">").Append(Enc(sec.Address)).Append("</p>");
                sb.Append("<p style=\"text-align:center;font-size:10pt;font-weight:bold;text-decoration:underline;margin:4pt 0 6pt 0\">").Append(Enc(sec.Title)).Append("</p>");

                sb.Append("<table class=\"t\" border=\"1\" cellspacing=\"0\" cellpadding=\"3\" style=\"border-collapse:collapse;width:100%\">");
                AppendRows(sb, sec, false);
                sb.Append("</table>");

                if (!string.IsNullOrEmpty(sec.Summary))
                    sb.Append("<p style=\"margin-top:4pt\">").Append(Enc(sec.Summary)).Append("</p>");

                sb.Append("<p>&nbsp;</p><p>&nbsp;</p><p>&nbsp;</p>");
                sb.Append("<table style=\"width:100%;border-collapse:collapse\"><tr>");
                foreach (string sg in Signs)
                    sb.Append("<td style=\"width:16%;border-top:1px solid #000;text-align:center;font-size:7.5pt;padding-top:2pt\">").Append(Enc(sg)).Append("</td><td style=\"width:0.8%\"></td>");
                sb.Append("</tr></table>");

                sb.Append("<p style=\"margin-top:8pt;font-size:7pt\">").Append(Enc(sec.Stamp)).Append("</p>");
                sb.Append("</div>");
            }
            sb.Append("</div></body></html>");
            return sb.ToString();
        }

        // ------------------------- Excel -------------------------
        public static string ExcelHtml(List<RptSection> secs)
        {
            var sb = new StringBuilder();
            sb.Append("<html xmlns:o=\"urn:schemas-microsoft-com:office:office\" xmlns:x=\"urn:schemas-microsoft-com:office:excel\" xmlns=\"http://www.w3.org/TR/REC-html40\">");
            sb.Append("<head><meta charset=\"utf-8\">");
            sb.Append("<!--[if gte mso 9]><xml><x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet><x:Name>Attendance</x:Name>");
            sb.Append("<x:WorksheetOptions><x:DisplayGridlines/></x:WorksheetOptions></x:ExcelWorksheet></x:ExcelWorksheets></x:ExcelWorkbook></xml><![endif]-->");
            sb.Append("<style>td,th{font-family:Arial,Helvetica,sans-serif;font-size:10pt;vertical-align:top}</style></head><body>");
            sb.Append("<table border=\"0\">");

            foreach (RptSection sec in secs)
            {
                int n = sec.Head.Length;
                sb.Append("<tr><td colspan=\"" + n + "\" style=\"text-align:center;font-size:14pt;font-weight:bold\">").Append(Enc(sec.Company)).Append("</td></tr>");
                sb.Append("<tr><td colspan=\"" + n + "\" style=\"text-align:center\">").Append(Enc(sec.Address)).Append("</td></tr>");
                sb.Append("<tr><td colspan=\"" + n + "\" style=\"text-align:center;font-weight:bold;text-decoration:underline\">").Append(Enc(sec.Title)).Append("</td></tr>");

                AppendRows(sb, sec, true);

                if (!string.IsNullOrEmpty(sec.Summary))
                    sb.Append("<tr><td colspan=\"" + n + "\">").Append(Enc(sec.Summary)).Append("</td></tr>");

                sb.Append("<tr><td colspan=\"" + n + "\">&nbsp;</td></tr><tr><td colspan=\"" + n + "\">&nbsp;</td></tr>");
                sb.Append("<tr>");
                for (int i = 0; i < Signs.Length && i < n; i++)
                    sb.Append("<td style=\"border-top:1px solid #000;text-align:center\">").Append(Enc(Signs[i])).Append("</td>");
                sb.Append("</tr>");
                sb.Append("<tr><td colspan=\"" + n + "\">").Append(Enc(sec.Stamp)).Append("</td></tr>");
                sb.Append("<tr><td colspan=\"" + n + "\">&nbsp;</td></tr><tr><td colspan=\"" + n + "\">&nbsp;</td></tr>");
            }
            sb.Append("</table></body></html>");
            return sb.ToString();
        }

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

        // বিল্ট-ইন PDF ফন্টে শুধু ASCII চলে; বাকি অক্ষর '?' হয়ে যায়
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
              .Append(F(x)).Append(' ').Append(F(y)).Append(" Td (").Append(Esc(Ascii(s))).Append(") Tj ET\n");
        }

        static List<string> Wrap(string s, double width, double fs, bool bold)
        {
            var lines = new List<string>();
            s = Ascii(s).Trim();
            if (s.Length == 0) { lines.Add(""); return lines; }

            string cur = "";
            foreach (string word0 in s.Split(' '))
            {
                if (word0.Length == 0) continue;
                var parts = new List<string>();
                string w = word0;
                while (Tw(w, fs, bold) > width && w.Length > 1)
                {
                    int k = w.Length - 1;
                    while (k > 1 && Tw(w.Substring(0, k), fs, bold) > width) k--;
                    parts.Add(w.Substring(0, k));
                    w = w.Substring(k);
                }
                parts.Add(w);

                foreach (string word in parts)
                {
                    string t = cur.Length == 0 ? word : cur + " " + word;
                    if (cur.Length == 0 || Tw(t, fs, bold) <= width) cur = t;
                    else { lines.Add(cur); cur = word; }
                }
            }
            if (cur.Length > 0) lines.Add(cur);
            if (lines.Count == 0) lines.Add("");
            return lines;
        }

        class Prep
        {
            public RptRow Row;
            public List<string>[] Lines;
            public double H;
        }

        public static byte[] Pdf(List<RptSection> secs)
        {
            const double W = 595.28, Ht = 841.89, M = 30;
            const double fs = 7.5, lineH = 9.5, padV = 3, padH = 2.5;
            const double tableTop = M + 56;       // হেডার ব্লকের নিচ থেকে টেবিল শুরু
            const double limit = Ht - M - 14;     // উপর থেকে মাপা নিচের সীমা
            const double signsH = 70;
            double tw = W - 2 * M;

            var contents = new List<string>();

            foreach (RptSection sec in secs)
            {
                int n = sec.Head.Length;

                // কলামের প্রস্থ
                double sum = 0;
                foreach (double w in sec.Weights) sum += w;
                double[] cw = new double[n];
                for (int i = 0; i < n; i++) cw[i] = sec.Weights[i] / sum * tw;

                // হেডার সারির উচ্চতা (হেডার লেখা ভেঙে নামতে পারে)
                var headLines = new List<string>[n];
                int hMax = 1;
                for (int i = 0; i < n; i++)
                {
                    headLines[i] = Wrap(sec.Head[i], cw[i] - 2 * padH, fs, true);
                    if (headLines[i].Count > hMax) hMax = headLines[i].Count;
                }
                double headH = hMax * lineH + 2 * padV;

                // প্রতিটি সারির উচ্চতা
                var preps = new List<Prep>();
                foreach (RptRow r in sec.Rows)
                {
                    var p = new Prep { Row = r };
                    if (r.Cells != null)
                    {
                        p.Lines = new List<string>[n];
                        int mx = 1;
                        for (int i = 0; i < n; i++)
                        {
                            string v = i < r.Cells.Length ? r.Cells[i] : "";
                            p.Lines[i] = Wrap(v, cw[i] - 2 * padH, fs, false);
                            if (p.Lines[i].Count > mx) mx = p.Lines[i].Count;
                        }
                        p.H = mx * lineH + 2 * padV;
                    }
                    else
                    {
                        p.Lines = new List<string>[1];
                        p.Lines[0] = Wrap(r.Text, tw - 2 * padH, fs, true);
                        p.H = p.Lines[0].Count * lineH + 2 * padV;
                    }
                    preps.Add(p);
                }

                // পাতায় ভাগ করা
                var pgs = new List<List<Prep>>();
                var cur = new List<Prep>();
                double used = tableTop + headH;
                foreach (Prep p in preps)
                {
                    if (used + p.H > limit && cur.Count > 0)
                    {
                        pgs.Add(cur);
                        cur = new List<Prep>();
                        used = tableTop + headH;
                    }
                    cur.Add(p);
                    used += p.H;
                }
                pgs.Add(cur);

                // সারাংশ + সই এর জায়গা না থাকলে আলাদা পাতা
                double extra = (string.IsNullOrEmpty(sec.Summary) ? 0 : 14) + signsH;
                if (used + extra > limit) pgs.Add(new List<Prep>());

                // প্রতিটি পাতার কনটেন্ট
                for (int pg = 0; pg < pgs.Count; pg++)
                {
                    var cs = new StringBuilder();
                    cs.Append("0 G 0 g 0.5 w\n");

                    string company = Ascii(sec.Company);
                    double titleFs = 14;
                    while (titleFs > 9 && Tw(company, titleFs, true) > tw - 80) titleFs -= 0.5;
                    Text(cs, "F2", titleFs, (W - Tw(company, titleFs, true)) / 2, Ht - (M + 14), company);

                    string addr = Ascii(sec.Address);
                    Text(cs, "F1", 8.5, (W - Tw(addr, 8.5, false)) / 2, Ht - (M + 27), addr);

                    string ttl = Ascii(sec.Title);
                    double ttlW = Tw(ttl, 10, true);
                    Text(cs, "F2", 10, (W - ttlW) / 2, Ht - (M + 41), ttl);
                    cs.Append(F((W - ttlW) / 2)).Append(' ').Append(F(Ht - (M + 43.5))).Append(" m ")
                      .Append(F((W + ttlW) / 2)).Append(' ').Append(F(Ht - (M + 43.5))).Append(" l S\n");

                    string pageTxt = "Page " + (pg + 1) + " of " + pgs.Count;
                    Text(cs, "F1", 7, W - M - Tw(pageTxt, 7, false), Ht - (M + 6), pageTxt);

                    double top = tableTop;

                    if (pgs[pg].Count > 0)
                    {
                        // হেডার সারি
                        double x = M;
                        for (int i = 0; i < n; i++)
                        {
                            cs.Append("0.945 g ").Append(F(x)).Append(' ').Append(F(Ht - (top + headH))).Append(' ')
                              .Append(F(cw[i])).Append(' ').Append(F(headH)).Append(" re f 0 g\n");
                            cs.Append(F(x)).Append(' ').Append(F(Ht - (top + headH))).Append(' ')
                              .Append(F(cw[i])).Append(' ').Append(F(headH)).Append(" re S\n");
                            for (int ln = 0; ln < headLines[i].Count; ln++)
                            {
                                string h = headLines[i][ln];
                                Text(cs, "F2", fs, x + (cw[i] - Tw(h, fs, true)) / 2, Ht - (top + padV + 6.5 + ln * lineH), h);
                            }
                            x += cw[i];
                        }
                        top += headH;

                        // ডাটা সারি
                        foreach (Prep p in pgs[pg])
                        {
                            if (p.Row.Cells == null)
                            {
                                // গ্রুপ বা যোগফল সারি (পুরো প্রস্থ জুড়ে)
                                if (p.Row.IsGroup)
                                {
                                    cs.Append("0.97 g ").Append(F(M)).Append(' ').Append(F(Ht - (top + p.H))).Append(' ')
                                      .Append(F(tw)).Append(' ').Append(F(p.H)).Append(" re f 0 g\n");
                                    cs.Append(F(M)).Append(' ').Append(F(Ht - (top + p.H))).Append(' ')
                                      .Append(F(tw)).Append(' ').Append(F(p.H)).Append(" re S\n");
                                }
                                for (int ln = 0; ln < p.Lines[0].Count; ln++)
                                    Text(cs, "F2", fs, M + padH, Ht - (top + padV + 6.5 + ln * lineH), p.Lines[0][ln]);
                            }
                            else
                            {
                                x = M;
                                for (int i = 0; i < n; i++)
                                {
                                    cs.Append(F(x)).Append(' ').Append(F(Ht - (top + p.H))).Append(' ')
                                      .Append(F(cw[i])).Append(' ').Append(F(p.H)).Append(" re S\n");
                                    for (int ln = 0; ln < p.Lines[i].Count; ln++)
                                    {
                                        string t = p.Lines[i][ln];
                                        double tx = x + padH;
                                        if (sec.Align[i] == 1) tx = x + (cw[i] - Tw(t, fs, false)) / 2;
                                        else if (sec.Align[i] == 2) tx = x + cw[i] - padH - Tw(t, fs, false);
                                        Text(cs, "F1", fs, tx, Ht - (top + padV + 6.5 + ln * lineH), t);
                                    }
                                    x += cw[i];
                                }
                            }
                            top += p.H;
                        }
                    }

                    // শেষ পাতায়: সারাংশ, সই, সময়
                    if (pg == pgs.Count - 1)
                    {
                        if (!string.IsNullOrEmpty(sec.Summary))
                        {
                            Text(cs, "F1", fs, M, Ht - (top + 11), sec.Summary);
                            top += 14;
                        }
                        double colW = tw / Signs.Length;
                        for (int i = 0; i < Signs.Length; i++)
                        {
                            double x0 = M + i * colW + 3, x1 = M + (i + 1) * colW - 3;
                            double ly = Ht - (top + 44);
                            cs.Append(F(x0)).Append(' ').Append(F(ly)).Append(" m ").Append(F(x1)).Append(' ').Append(F(ly)).Append(" l S\n");
                            string sg = Signs[i];
                            Text(cs, "F1", 7, x0 + ((x1 - x0) - Tw(sg, 7, false)) / 2, ly - 9, sg);
                        }
                        Text(cs, "F1", 7, M, M - 12, sec.Stamp);
                    }

                    contents.Add(cs.ToString());
                }
            }

            // PDF ফাইল জোড়া লাগানো
            int pageCount = contents.Count;
            var sb = new StringBuilder();
            var offs = new List<int>();
            sb.Append("%PDF-1.4\n");

            AddObj(sb, offs, "<< /Type /Catalog /Pages 2 0 R >>");

            var kids = new StringBuilder();
            for (int i = 0; i < pageCount; i++) kids.Append(5 + 2 * i).Append(" 0 R ");
            AddObj(sb, offs, "<< /Type /Pages /Kids [" + kids.ToString().Trim() + "] /Count " + pageCount + " >>");

            AddObj(sb, offs, "<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica /Encoding /WinAnsiEncoding >>");
            AddObj(sb, offs, "<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold /Encoding /WinAnsiEncoding >>");

            for (int i = 0; i < pageCount; i++)
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