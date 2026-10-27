using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Text;
using System.Web.UI;

namespace Nexa_ERP.HRMPayroll.HRMPayrollReports.HRReports
{
    // Lefty Letter Issue পেজ থেকে নতুন ট্যাবে খোলে:
    //   LeftyLetterView.aspx?report=<নাম>&probation=<0|1>
    // রিপোর্ট নাম (ডেক্সটপের reportName):
    //   Thard_Latter | Probation_Time_Latter | Envlap2 (বর্তমান ঠিকানার খাম) | Envlap (স্থায়ী ঠিকানার খাম)
    //   Fast_Secend_Third_Latter (প্রতি কর্মচারীর ১ম, ২য়, ৩য় চিঠি পরপর)
    //   Fast_Latter, Secend_Latter (আলাদা পেজ আছে, এখানেও চলে)
    public partial class LeftyLetterView : System.Web.UI.Page
    {
        PayrollDB conn = new PayrollDB();

        // সব তারিখ ও সংখ্যা বাংলা অঙ্কে (টেমপ্লেটের স্থির লেখার মতো)। ইংরেজি অঙ্ক চাইলে false করুন।
        const bool BanglaDigits = true;
        const string DateFormat = "dd-MM-yyyy";
        const string DateFormatSlash = "dd/MM/yyyy";   // ৩য় পত্রের উপরের তারিখ আপনার PDF-এ স্ল্যাশ দিয়ে

        // খামের পাতার মাপ: ৬৮৪ x ২৯৭ pt (আপনার খামের PDF অনুযায়ী)
        const string EnvelopePageCss = "@page { size:241.3mm 104.8mm; margin:0; }";
        const string LetterPageCss = "@page { size:A4; margin:0; }";

        class Def
        {
            public string Title;
            public bool Envelope;
            public Func<DataRow, string> Render;
        }

        static readonly Dictionary<string, Def> Reports = new Dictionary<string, Def>(StringComparer.Ordinal)
        {
            { "Fast_Latter",              new Def { Title = "1st Letter",          Render = RenderFirstLetter } },
            { "Secend_Latter",            new Def { Title = "2nd Letter",          Render = RenderSecondLetter } },
            { "Thard_Latter",             new Def { Title = "3rd Letter",          Render = RenderThirdLetter } },
            { "Probation_Time_Latter",    new Def { Title = "Probation Period Letter", Render = RenderProbationLetter } },
            { "Fast_Secend_Latter",       new Def { Title = "1st & 2nd Letter",     Render = r => RenderFirstLetter(r) + RenderSecondLetter(r) } },
            { "Fast_Secend_Third_Latter", new Def { Title = "1st, 2nd & 3rd Letter", Render = r => RenderFirstLetter(r) + RenderSecondLetter(r) + RenderThirdLetter(r) } },
            { "Envlap2",                  new Def { Title = "Envelope (Present Address)",   Envelope = true, Render = r => RenderEnvelope(r, true) } },
            { "Envlap",                   new Def { Title = "Envelope (Permanent Address)", Envelope = true, Render = r => RenderEnvelope(r, false) } }
        };

        // ডেক্সটপের রিপোর্টের SQL (z_Test_ID দিয়ে ফিল্টার করা)। {?prm} এর জায়গায় probation শর্ত।
        const string BaseSql =
            "SELECT e.ID_no, e.Name, e.Bangla_name, e.Designation, e.Joining_Date, " +
            "       b.Absent_Date, b.Letter_issue_Date, b.Secend_Later_Date, b.Thard_Date, b.Probation_Time, " +
            "       d.Designation_Bangla, s.Section_bangla_Name, " +
            "       p.Fathers_Bangla, p.Husband_Bangla, " +
            "       p.B_Village, p.B_Post, p.B_Thana, p.B_District, " +
            "       p.B_P_Village, p.B_P_Post, p.B_P_Thana, p.B_P_District, " +
            "       c.Conmany_Bangla, c.Bangla_Address " +
            "FROM Employee_information_new e " +
            "INNER JOIN B_Later_information b ON e.ID_no = b.Card_No " +
            "INNER JOIN Employee_Personal_Information_new p ON e.ID_no = p.ID_No " +
            "INNER JOIN Employee_information_With_Code ec ON e.ID_no = ec.ID_no " +
            "INNER JOIN TB_Company c ON ec.Company_Code = c.Company_Code " +
            "INNER JOIN z_Test_ID z ON e.ID_no = z.ID_No " +
            "INNER JOIN TB_Designation d ON ec.Designation_Code = d.Designation_Code " +
            "INNER JOIN TB_Section s ON ec.Section_Code = s.Section_Code ";

        protected void Page_Load(object sender, EventArgs e)
        {
            string report = Request.QueryString["report"] ?? "";
            Def def;

            if (!Reports.TryGetValue(report, out def))
            {
                litLetters.Text = "<div class=\"msg\">এই রিপোর্টের (" + Enc(report) + ") ওয়েব লেআউট এখনও যোগ করা হয়নি।</div>";
                return;
            }

            litTitle.Text = Enc(def.Title);
            litPageCss.Text = "<style>@media print { " + (def.Envelope ? EnvelopePageCss : LetterPageCss) + " }</style>";

            int probation;
            bool hasProb = int.TryParse(Request.QueryString["probation"], out probation) && (probation == 0 || probation == 1);

            DataTable dt;
            try
            {
                dt = Load(hasProb, probation);
            }
            catch (Exception ex)
            {
                litLetters.Text = "<div class=\"msg\">Error: " + Enc(ex.Message) + "</div>";
                return;
            }

            if (dt.Rows.Count == 0)
            {
                litLetters.Text = "<div class=\"msg\">নির্বাচিত কর্মচারীর কোনো চিঠির তথ্য পাওয়া যায়নি।</div>";
                litCount.Text = "0";
                return;
            }

            var sb = new StringBuilder();
            foreach (DataRow r in dt.Rows) sb.Append(def.Render(r));
            litLetters.Text = sb.ToString();
            litCount.Text = dt.Rows.Count + (def.Envelope ? " envelope(s)" : " employee(s)");
        }

        DataTable Load(bool hasProb, int probation)
        {
            var dt = new DataTable();
            using (SqlConnection con = conn.openConnection())
            {
                if (con.State != ConnectionState.Open) con.Open();
                string sql = BaseSql + (hasProb ? "WHERE b.Probation_Time = @p " : "") + "ORDER BY e.ID_no";
                using (var cmd = new SqlCommand(sql, con))
                {
                    if (hasProb) cmd.Parameters.Add("@p", SqlDbType.Int).Value = probation;
                    using (var da = new SqlDataAdapter(cmd)) da.Fill(dt);
                }
            }
            return dt;
        }

        // ================= চিঠির সাধারণ অংশ =================

        // লেটারহেড (কোম্পানির নাম ও ঠিকানা)
        static void Letterhead(StringBuilder sb, DataRow r)
        {
            sb.Append("<div class=\"lh\"><div class=\"co\">" + Enc(Pick(r, "Conmany_Bangla")) + "</div><div class=\"ad\">" + Enc(Pick(r, "Bangla_Address")) + "</div></div>");
        }

        // অফিস তথ্য + বর্তমান ঠিকানা + স্থায়ী ঠিকানার টেবিল
        static void InfoTable(StringBuilder sb, DataRow r)
        {
            sb.Append("<table class=\"info\"><tr><th>-অফিস তথ্য-</th><th>বর্তমান ঠিকানা</th><th>স্থায়ী ঠিকানা</th></tr><tr>");

            sb.Append("<td class=\"c1\">");
            sb.Append(Kv("নাম", Pick(r, "Bangla_name", "Name"), "w"));
            sb.Append(Kv("কার্ড নং", Digits(Pick(r, "ID_no")), "w"));
            sb.Append(Kv("পদবী", Pick(r, "Designation_Bangla", "Designation"), "w"));
            sb.Append(Kv("সেকশন", Pick(r, "Section_bangla_Name"), "w"));
            sb.Append("</td>");

            sb.Append("<td class=\"c2\">" + Address(Pick(r, "Fathers_Bangla"), Pick(r, "Husband_Bangla"),
                Pick(r, "B_Village"), Pick(r, "B_Post"), Pick(r, "B_Thana"), Pick(r, "B_District")) + "</td>");

            sb.Append("<td class=\"c3\">" + Address(Pick(r, "Fathers_Bangla"), Pick(r, "Husband_Bangla"),
                Pick(r, "B_P_Village"), Pick(r, "B_P_Post"), Pick(r, "B_P_Thana"), Pick(r, "B_P_District")) + "</td>");

            sb.Append("</tr></table>");
        }

        // ধন্যবাদান্তে, ব্যবস্থাপক ... অনুলিপি
        static void Closing(StringBuilder sb, DataRow r, string ccLabel, int gapPx)
        {
            sb.Append("<div class=\"sign\"><div>ধন্যবাদান্তে,</div><div class=\"gap\"></div>");
            sb.Append("<div>ব্যবস্থাপক<br>(এইচ.আর এবং কমপ্লায়েন্স)<br>" + Enc(Pick(r, "Conmany_Bangla")) + "<br>" + Enc(Pick(r, "Bangla_Address")) + "</div></div>");
            sb.Append("<div class=\"cc\" style=\"margin-top:" + gapPx + "px\">" + ccLabel + "<br>১। শ্রমিকের ব্যক্তিগত নথি।</div>");
        }

        // ================= ১ম পত্র (Fast_Latter) =================
        static string RenderFirstLetter(DataRow r)
        {
            var sb = new StringBuilder();
            sb.Append("<section class=\"page\">");
            Letterhead(sb, r);

            sb.Append("<div class=\"title\">বাংলাদেশ শ্রম আইন, ২০০৬ এর ২৭(৩ক) ধারা মতে অননুমোদিত অনুপস্থিত শ্রমিকের<br>ইস্যু করা ১ম পত্র</div>");
            sb.Append("<div class=\"date\">তারিখ: " + Enc(Date(r, "Letter_issue_Date")) + "</div>");
            sb.Append("<hr class=\"rule\"><div class=\"reg\">রেজিস্টার ডাকে প্রেরিত</div>");
            InfoTable(sb, r);

            sb.Append("<div class=\"subject\">বিষয়ঃ- বিনা নোটিশে কর্মস্থলে অনুপস্থিত থাকা প্রসংগে ব্যাখ্যা প্রদান ও চাকুরীতে পুনরায় যোগদানের জন্য নোটিশ।</div>");

            sb.Append("<div class=\"body\"><p>জনাব/জনাবা,</p>");
            sb.Append("<p>আপনি গত " + Enc(Date(r, "Absent_Date")) + " ইং তারিখ হতে অদ্যাবধি বিনা নোটিশে এবং কর্তৃপক্ষের বিনা অনুমোতিতে কর্মস্থলে ১০ (দশ) দিনের অধিক সময় অনুপস্থিত রহিয়াছেন। " +
                      "এ ধরনের অনুপস্থিতির কারনে কারখানায় উৎপাদন ব্যহত হচ্ছে বিধায় বাংলাদেশ শ্রম আইন, ২০০৬ এর ২৭(৩ক) ধারা মতে " +
                      "অনতিবিলম্বে আপনাকে অনুপস্থিতির কারন ব্যাখ্যা সহ কাজে যোগদানের অথবা আপনার এ ধরনের বিনা নোটিশে বা উর্দ্ধোতন কর্তৃপক্ষের " +
                      "অনুমতি ব্যতিরেকে কারখানায় ১০ দিনের অধিক সময় অনুপস্থিতি থাকার বিষয়ে ব্যাখ্যা প্রদানের নির্দেশ প্রদান করা হলো।</p></div>");

            Closing(sb, r, "অনুলিপি:", 26);
            sb.Append("</section>");
            return sb.ToString();
        }

        // ================= ২য় পত্র (Secend_Latter) =================
        static string RenderSecondLetter(DataRow r)
        {
            var sb = new StringBuilder();
            sb.Append("<section class=\"page\">");
            Letterhead(sb, r);

            sb.Append("<div class=\"title\">বাংলাদেশ শ্রম আইন, ২০০৬ এর ২৭(৩ক) ধারা মতে অননুমোদিত অনুপস্থিত শ্রমিকের<br>ইস্যু করা ২য় পত্র</div>");
            sb.Append("<div class=\"date\">তারিখ: " + Enc(Date(r, "Secend_Later_Date")) + "</div>");
            sb.Append("<hr class=\"rule\"><div class=\"reg\">রেজিস্টার ডাকে প্রেরিত</div>");
            InfoTable(sb, r);

            sb.Append("<div class=\"subject u\">বিষয়ঃ- বিনা নোটিশে ১০(দশ) দিনের অধিক কর্মস্থলে অনুপস্থিত থাকার কারণে বাংলাদেশ শ্রম আইন, ২০০৬ এর ২৭(৩ক) ধারানুযায়ী আত্মপক্ষ সমর্থনসহ কাজে যোগদানের নোটিশ।</div>");

            sb.Append("<div class=\"body\"><p style=\"margin-bottom:2px\">জনাব/জনাবা,</p>");
            sb.Append("<p>আপনি গত " + Enc(Date(r, "Absent_Date")) + " ইং তারিখ হতে ১০(দশ) দিনের অধিক বিনা নোটিশে ও কর্তৃপক্ষের বিনা অনুমতিতে কর্মস্থলে অনুপস্থিতি থাকায় " +
                      "আপনাকে এই বিষয়ে ব্যাখ্যা প্রদান করার জন্য এবং একই সাথে চাকুরীতে যোগদান করার নির্দেশ সম্বলিতপত্র আপনার বর্তমান ও স্থায়ী ঠিকানায় বিগত " +
                      Enc(Date(r, "Letter_issue_Date")) + " ইং তারিখে ডাকযোগে প্রতিষ্ঠান-কর্তৃপক্ষ কর্তৃক প্রেরণ করা হয়। " +
                      "কিন্তু আপনি লিখিত ব্যাখ্যাও প্রদান করেন নাই এবং চাকুরীতেও যোগদান করেন নাই।</p>");
            sb.Append("<p>তাই আপনাকে আগামী ৭(সাত) দিনের মধ্যে প্রতিষ্ঠানে উপস্থিত হইয়া আত্মপক্ষ সমর্থনসহ কাজে যোগদানের জন্য নির্দেশ প্রদান করা হইল।</p></div>");

            Closing(sb, r, "অনুলিপি-", 26);
            sb.Append("</section>");
            return sb.ToString();
        }

        // ================= ৩য় পত্র (Thard_Latter) =================
        static string RenderThirdLetter(DataRow r)
        {
            var sb = new StringBuilder();
            sb.Append("<section class=\"page\">");
            Letterhead(sb, r);

            sb.Append("<div class=\"title\">বাংলাদেশ শ্রম আইন, ২০০৬ এর ২৭(৩ক) ধারা মতে অননুমোদিত অনুপস্থিত শ্রমিকের চূড়ান্ত নিষ্পত্তি</div>");
            // আপনার PDF-এ: বাঁয়ে তারিখ (স্ল্যাশ দিয়ে), মাঝে "ইস্যু করা ৩য় পত্র"
            sb.Append("<div class=\"row3\"><div class=\"date\">তারিখ: " + Enc(Date(r, "Thard_Date", DateFormatSlash)) + "</div><div class=\"issue\">ইস্যু করা ৩য় পত্র</div><div></div></div>");
            sb.Append("<hr class=\"rule\"><div class=\"reg\">রেজিস্টার ডাকে প্রেরিত</div>");
            InfoTable(sb, r);

            sb.Append("<div class=\"subject u\">বিষয় ঃ- বিনা নোটিশে ১০(দশ) দিনের অধিক কর্মস্থলে অনুপস্থিত থাকার কারণে বাংলাদেশ শ্রম আইন,২০১৩ এর ২৭(৩ক) ধারানুযায়ী চাকুরী হইতে ইস্তফা প্রসঙ্গে।</div>");

            sb.Append("<div class=\"body\"><p>জনাব/জনাবা,</p>");
            sb.Append("<p>আপনি গত " + Enc(Date(r, "Absent_Date")) + " ইং তারিখ হতে অদ্যাবধি পর্যন্ত কর্তৃপক্ষের বিনা অনুমতিতে কর্মস্থলে অনুপস্থিত থাকার কারণে আপনাকে গত " +
                      Enc(Date(r, "Letter_issue_Date")) + " ইং তারিখ একটি পত্রের মাধ্যমে ১০ (দশ) দিনের সময় দিয়ে চাকুরীতে যোগদান সহ ব্যাখ্যা প্রদান করতে বলা হয়েছিল। " +
                      "কিন্তু আপনি নির্ধারিত সময়ের মধ্যে কর্মস্থলে উপস্থিত হননি এবং কোন ব্যাখ্যা প্রদান করেননি। তথাপি কর্তৃপক্ষ গত " +
                      Enc(Date(r, "Secend_Later_Date")) + " ইং তারিখ আর একটি পত্রের মাধ্যমে আপনাকে আরো ০৭ (সাত) দিনের সময় দিয়ে আত্মপক্ষ সমর্থন সহ চাকুরীতে যোগদানের জন্য " +
                      "পুনরায় নির্দেশ প্রদান করেন। তৎসত্বেও আপনি নির্ধারিত সময়ের মধ্যে আত্মপক্ষ সমর্থন করেননি এবং চাকুরীতে যোগদান করেননি।</p>");
            sb.Append("<p>সুতরাং বাংলাদেশ শ্রম আইন ২০০৬ এর ২৭(৩ক) ধারা অনুযায়ী অনুপস্থিত দিন থেকে আপনি চাকুরী হতে স্বেচ্ছায় ইস্তফা গ্রহন করেছেন বলে গন্য করা হলো।</p>");
            sb.Append("<p>অতএব, আপনার বকেয়া মজুরী ও আইনানুগ পাওনা ( যদি থাকে ) যে কোন কর্ম দিবসে অফিস চলাকালীন সময়ে কারখানার হিসাব শাখা থেকে গ্রহন করার জন্য নির্দেশ দেয়া গেল।</p></div>");

            Closing(sb, r, "অনুলিপি-", 24);
            sb.Append("</section>");
            return sb.ToString();
        }

        // ================= Probation Period পত্র (Probation_Time_Latter) =================
        static string RenderProbationLetter(DataRow r)
        {
            var sb = new StringBuilder();
            sb.Append("<section class=\"page\">");
            Letterhead(sb, r);

            sb.Append("<div class=\"title\">বাংলাদেশ শ্রম আইন, ২০০৬ এর ২৭(৩ক) ধারা মতে অ-অনুমোদিত অনুপস্থিত শ্রমিকের চূড়ান্ত নিষ্পত্তি</div>");
            sb.Append("<div class=\"row3\"><div class=\"date\">তারিখ: " + Enc(Date(r, "Letter_issue_Date")) + "</div><div></div><div></div></div>");
            sb.Append("<hr class=\"rule\"><div class=\"reg\">রেজিস্টার ডাকে প্রেরিত</div>");
            InfoTable(sb, r);

            sb.Append("<div class=\"subject u\">বিষয় : বাংলাদেশ শ্রম আইন ২০০৬ এর ২৭(৩ক) ধারা মোতাবেক শ্রমিক কর্তৃক স্বেচ্ছায় চাকুরী হইতে ইস্তফা গ্রহণ প্রসঙ্গে।</div>");

            sb.Append("<div class=\"body\"><p>জনাব/জনাবা,</p>");
            sb.Append("<p>আপনি গত " + Enc(Date(r, "Absent_Date")) + " ইং তারিখ হতে অদ্যাবধি পর্যন্ত কর্তৃপক্ষের বিনা অনুমতিতে কর্মস্থলে ১০ দিন অনুপস্থিত থাকার কারনে " +
                      "আপনাকে বাংলাদেশ শ্রম আইন ২০০৬ এর ২৭ (৩ক) ধারা অনুযায়ী অনুপস্থিত দিন থেকে আপনি চাকুরী হতে স্বেচ্ছায় ইস্তফা গ্রহন করেছেন বলে গন্য করা হলো।</p>");
            sb.Append("<p>অতএব আপনার বকেয়া মজুরী ও আইনানুগ পাওনা (যদি থাকে) যে কোন কর্মদিবসে অফিস চলাকালীন সময়ে কারখানার হিসাব শাখা থেকে গ্রহন করার জন্য নির্দেশ দেয়া গেল।</p></div>");

            Closing(sb, r, "অনুলিপি-", 60);
            sb.Append("</section>");
            return sb.ToString();
        }

        // ================= খাম (Envlap2 = বর্তমান ঠিকানা, Envlap = স্থায়ী ঠিকানা) =================
        static string RenderEnvelope(DataRow r, bool present)
        {
            string v = present ? "B_" : "B_P_";
            var sb = new StringBuilder();
            sb.Append("<section class=\"env\">");
            sb.Append("<div class=\"idn\">আই ডি নংঃ " + Enc(Digits(Pick(r, "ID_no"))) + "</div>");
            sb.Append("<div class=\"hr2\"></div>");
            sb.Append("<div class=\"egrid\">");

            sb.Append("<div class=\"from\"><div class=\"fco\">" + Enc(Pick(r, "Conmany_Bangla")) + "</div><div class=\"fad\">" + Enc(Pick(r, "Bangla_Address")) + "</div></div>");
            sb.Append("<div class=\"vl\"></div>");

            sb.Append("<div class=\"to\"><div class=\"tt\">" + (present ? "বর্তমান ঠিকানা" : "স্থায়ী ঠিকানা") + "</div>");
            sb.Append("<div class=\"tr\">প্রাপক,</div>");
            sb.Append(EKv("নাম", Pick(r, "Bangla_name", "Name")));
            sb.Append(EKv("পিতা", Pick(r, "Fathers_Bangla")));
            sb.Append(EKv("স্বামী", Pick(r, "Husband_Bangla")));
            sb.Append(EKv("গ্রাম", Pick(r, v + "Village")));
            sb.Append(EKv("ডাকঘর", Pick(r, v + "Post")));
            sb.Append(EKv("থানা", Pick(r, v + "Thana")));
            sb.Append(EKv("জেলা", Pick(r, v + "District")));
            sb.Append("</div></div></section>");
            return sb.ToString();
        }

        static string EKv(string label, string value)
        {
            return "<div class=\"ekv\"><i>" + Enc(label) + "</i><span>" + Enc(value) + "</span></div>";
        }

        // পিতা / স্বামী / গ্রাম / ডাকঘর / থানা / জেলা
        static string Address(string father, string husband, string village, string post, string thana, string district)
        {
            return Kv("পিতা", father, "") + Kv("স্বামী", husband, "") + Kv("গ্রাম", village, "") +
                   Kv("ডাকঘর", post, "") + Kv("থানা", thana, "") + Kv("জেলা", district, "");
        }

        static string Kv(string label, string value, string cls)
        {
            return "<div class=\"kv " + cls + "\"><i>" + Enc(label) + "</i><span>" + Enc(value) + "</span></div>";
        }

        // ================= সাহায্যকারী =================
        static string Pick(DataRow r, params string[] cols)
        {
            foreach (string c in cols)
            {
                if (r.Table.Columns.Contains(c) && r[c] != DBNull.Value)
                {
                    string s = Convert.ToString(r[c]).Trim();
                    if (s.Length > 0) return s;
                }
            }
            return "";
        }

        static string Date(DataRow r, string col)
        {
            return Date(r, col, DateFormat);
        }

        static string Date(DataRow r, string col, string format)
        {
            if (!r.Table.Columns.Contains(col) || r[col] == DBNull.Value) return "";
            DateTime d;
            if (!DateTime.TryParse(Convert.ToString(r[col]), out d)) return Convert.ToString(r[col]);
            return Digits(d.ToString(format, CultureInfo.InvariantCulture));
        }

        static string Digits(string s)
        {
            if (!BanglaDigits || string.IsNullOrEmpty(s)) return s;
            var sb = new StringBuilder(s.Length);
            foreach (char ch in s) sb.Append(ch >= '0' && ch <= '9' ? (char)('০' + (ch - '0')) : ch);
            return sb.ToString();
        }

        static string Enc(string s)
        {
            return System.Web.HttpUtility.HtmlEncode(s ?? "");
        }
    }
}
