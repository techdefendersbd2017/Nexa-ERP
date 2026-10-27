<%@ Page Language="C#" AutoEventWireup="true" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Data.SqlClient" %>
<%@ Import Namespace="System.Globalization" %>
<%@ Import Namespace="Nexa_ERP.Connection" %>

<script runat="server">
    // ================== এই পেজের সব লজিক এখানে (code-behind লাগে না) ==================
    static readonly CultureInfo Inv = CultureInfo.InvariantCulture;

    public class LeaveLine
    {
        public string Name { get; set; }
        public string Total { get; set; }
        public string Used { get; set; }
        public string Remaining { get; set; }
    }

    public bool HasData;
    public string Message = "";
    public bool IsBangla = true;

    public string Company = "", CompanyAddress = "", LeaveTypeName = "";
    public string EmpName = "", Designation = "", CardNo = "", Section = "";
    public string JoinDate = "", PeriodFrom = "", PeriodTill = "", PeriodFromSlash = "", PeriodTillSlash = "";
    public string Days = "", ApplyDate = "", Purpose = "", Address = "";

    // বাংলা হলে প্রথমটি, ইংরেজি হলে দ্বিতীয়টি
    public string T(string bn, string en) { return IsBangla ? bn : en; }

    protected void Page_Load(object sender, EventArgs e)
    {
        string name = Session["LeaveRpt_Name"] as string;
        string prm = Session["LeaveRpt_Prm"] as string;

        if (string.IsNullOrEmpty(prm))
        {
            Message = "No report data. Please open this report from the Leave Application page.";
            return;
        }

        IsBangla = name != "Leave_Application_RPT_English";

        try
        {
            DataTable dt = LoadData(prm);
            if (dt.Rows.Count == 0)
            {
                Message = "No data found for this application. (Save the application first and make sure the employee's leave balance exists.)";
                return;
            }

            FillHeader(dt.Rows[0]);
            FillLines(dt);
            HasData = true;
        }
        catch (Exception ex)
        {
            Message = "Error: " + ex.Message;
        }
    }

    // আপনার দেওয়া SQL; {?prm} এর জায়গায় WHERE 1=1 + prm
    DataTable LoadData(string prm)
    {
        string sql =
@"SELECT        Employee_information_new.Emp_no, Employee_information_new.ID_no, Employee_information_new.Bangla_name, Employee_information_new.Joining_Date, TB_Company.Conmany_Bangla, TB_Company.Bangla_Address, 
                         TB_Company.Phone, TB_Department.Bangla_Name AS Department, TB_Section.Section_bangla_Name, TB_Designation.Designation_Bangla, Leave_Application.Leave_Type, Leave_Application.From_Date, 
                         Leave_Application.Till_Date, Leave_Application.Purpose, Leave_Application.Phone AS Expr1, Leave_Application.Address, Leave_Application.Alternate_Person, Leave_Application.Status, Leave_Application.Apply_Days, 
                         Leave_Application.Apply_No, Leave_Name_List.Leave_Name, Emp_Wise_Dtls.Total_Days, Emp_Wise_Dtls.Total_User, Emp_Wise_Dtls.Total_Remaining, Employee_information_new.Line, 
                         Leave_Name_List.Leave_Name_Bangla, Emp_Wise_Dtls.Leave_code, Employee_information_new.Report_Type, Emp_Wise_Dtls.Years, TB_Company.Company_Logo, 
                         Leave_Name_List_1.Leave_Name_Bangla AS Aply_Leave_Name_Bangla
FROM            Leave_Name_List INNER JOIN
                         Employee_information_new INNER JOIN
                         TB_Company ON Employee_information_new.Company_Name = TB_Company.Company_Name INNER JOIN
                         Leave_Application ON Employee_information_new.ID_no = Leave_Application.ID_no INNER JOIN
                         Emp_Wise_Dtls ON Employee_information_new.Emp_no = Emp_Wise_Dtls.Emp_no ON Leave_Name_List.Leave_code = Emp_Wise_Dtls.Leave_code INNER JOIN
                         Leave_Name_List AS Leave_Name_List_1 ON Leave_Application.Leave_Type = Leave_Name_List_1.Leave_code INNER JOIN
                         Employee_information_With_Code ON Employee_information_new.ID_no = Employee_information_With_Code.ID_no INNER JOIN
                         TB_Department ON Employee_information_With_Code.Department_Code = TB_Department.Department_Code INNER JOIN
                         TB_Section ON Employee_information_With_Code.Section_Code = TB_Section.Section_Code INNER JOIN
                         TB_Designation ON Employee_information_With_Code.Designation_Code = TB_Designation.Designation_Code
WHERE 1=1 " + prm + " ORDER BY Emp_Wise_Dtls.Leave_code";

        PayrollDB conn = new PayrollDB();
        using (SqlConnection con = conn.openConnection())
        {
            if (con.State != ConnectionState.Open) con.Open();
            using (var cmd = new SqlCommand(sql, con))
            {
                cmd.CommandTimeout = 60;
                var dt = new DataTable();
                using (var da = new SqlDataAdapter(cmd)) da.Fill(dt);
                return dt;
            }
        }
    }

    void FillHeader(DataRow r)
    {
        Company = Col(r, "Conmany_Bangla");
        CompanyAddress = Col(r, "Bangla_Address");
        LeaveTypeName = IsBangla ? Col(r, "Aply_Leave_Name_Bangla") : Col(r, "Leave_Type");

        EmpName = Col(r, "Bangla_name");
        Designation = Col(r, "Designation_Bangla");
        CardNo = N(Col(r, "ID_no"));
        Section = Col(r, "Section_bangla_Name");

        JoinDate = Fmt(r, "Joining_Date", "dd-MM-yyyy");
        PeriodFrom = Fmt(r, "From_Date", "dd-MM-yy");
        PeriodTill = Fmt(r, "Till_Date", "dd-MM-yy");
        PeriodFromSlash = Fmt(r, "From_Date", "dd/MM/yyyy");
        PeriodTillSlash = Fmt(r, "Till_Date", "dd/MM/yyyy");
        Days = N(Col(r, "Apply_Days"));
        ApplyDate = N(DateTime.Today.ToString("dd-MM-yyyy", Inv));

        Purpose = Col(r, "Purpose");
        Address = Col(r, "Address");
    }

    void FillLines(DataTable dt)
    {
        var lines = new List<LeaveLine>();
        foreach (DataRow r in dt.Rows)
        {
            lines.Add(new LeaveLine
            {
                Name = IsBangla ? Col(r, "Leave_Name_Bangla") : Col(r, "Leave_Name"),
                Total = N(Col(r, "Total_Days")),
                Used = N(Col(r, "Total_User")),
                Remaining = N(Col(r, "Total_Remaining"))
            });
        }
        rptLines.DataSource = lines;
        rptLines.DataBind();
    }

    static string Col(DataRow r, string name)
    {
        return r.Table.Columns.Contains(name) && r[name] != DBNull.Value ? Convert.ToString(r[name]).Trim() : "";
    }

    string Fmt(DataRow r, string col, string format)
    {
        DateTime d;
        return DateTime.TryParse(Col(r, col), out d) ? N(d.ToString(format, Inv)) : "";
    }

    // বাংলা রিপোর্টে ইংরেজি অঙ্ক -> বাংলা অঙ্ক
    string N(string s)
    {
        if (!IsBangla || string.IsNullOrEmpty(s)) return s;
        var sb = new System.Text.StringBuilder(s.Length);
        foreach (char c in s)
            sb.Append(c >= '0' && c <= '9' ? (char)('০' + (c - '0')) : c);
        return sb.ToString();
    }
</script>

<!DOCTYPE html>
<html lang="bn">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Leave Application</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+Bengali:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Noto Sans Bengali', 'Nirmala UI', sans-serif; background:#e2e8f0; color:#000; }
        .sheet { width:210mm; min-height:297mm; margin:16px auto; background:#fff; padding:12mm 10mm; box-shadow:0 4px 16px rgba(0,0,0,.15); }
        /* SutonnyMJ (ANSI) এ সেভ হওয়া Purpose/Address — ফন্টটি এই পিসিতে ইনস্টল থাকতে হবে */
        .ansi { font-family:'SutonnyMJ','Noto Sans Bengali',sans-serif; font-size:15px; }
        .box { border:1px solid #000; }
        .tag { border:1px solid #000; font-weight:700; padding:3px 12px; background:#fff; white-space:nowrap; box-shadow:2px 2px 0 #000; }
        .title-box { display:inline-block; border:1px solid #000; background:#f1f1f1; padding:6px 40px; font-size:22px; font-weight:700; }
        table.det { width:100%; border-collapse:collapse; font-size:13px; }
        table.det th, table.det td { border:1px solid #cfcfcf; padding:10px 8px; text-align:center; }
        table.det thead tr.cap th { background:#d9d9d9; font-weight:700; font-size:14px; border:1px solid #bdbdbd; }
        .sig { border-top:1px solid #000; padding-top:3px; text-align:center; font-size:13px; }
        .cut { border-top:1px dashed #777; margin:18px 0 10px; }
        @page { size:A4; margin:0; }
        @media print {
            body { background:#fff; }
            .no-print { display:none !important; }
            .sheet { margin:0; box-shadow:none; }
        }
    </style>
</head>
<body>
<form id="form1" runat="server">

<div class="no-print sticky top-0 z-10 bg-white border-b border-slate-300 px-6 py-2 flex items-center justify-end gap-2">
    <button type="button" onclick="window.print()" class="h-9 px-5 rounded-lg bg-blue-600 hover:bg-blue-700 text-white text-sm font-medium flex items-center gap-2">
        <i class="fa-solid fa-print text-xs"></i><span>Print</span>
    </button>
    <button type="button" onclick="window.close()" class="h-9 px-4 rounded-lg border border-slate-300 bg-white hover:bg-slate-50 text-slate-700 text-sm font-medium">Close</button>
</div>

<% if (!HasData) { %>
<div class="sheet flex items-start justify-center">
    <p class="text-sm text-slate-500 mt-10"><%: Message %></p>
</div>
<% } else { %>
<div class="sheet text-[13px]">

    <!-- Company header -->
    <div class="text-center">
        <h1 class="text-[26px] font-bold leading-tight"><%: Company %></h1>
        <p class="text-[14px] font-semibold mt-1"><%: CompanyAddress %></p>
    </div>

    <div class="text-center mt-6 mb-6">
        <span class="title-box"><%: T("ছুটির আবেদন পত্র", "Leave Application") %></span>
    </div>

    <!-- Leave type -->
    <div class="flex items-stretch gap-0 mb-3">
        <div class="shrink-0 pr-2 flex items-center"><span class="tag"><%: T("ছুটির প্রকৃতিঃ", "Leave Type:") %></span></div>
        <div class="box flex-1 px-2 py-2 font-medium"><%: LeaveTypeName %></div>
    </div>

    <!-- Employee + period -->
    <div class="box grid grid-cols-2">
        <div class="p-1.5 space-y-5 border-r border-black">
            <div><%: T("নাম", "Name") %> &nbsp;&nbsp;<span class="font-semibold">ঃ <%: EmpName %></span></div>
            <div><%: T("পদবী", "Designation") %> &nbsp;<span class="font-semibold">ঃ <%: Designation %></span></div>
            <div><b><%: T("কার্ড নং", "Card No") %> ঃ <%: CardNo %></b> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <%: T("সেকশনঃ", "Section:") %> <%: Section %></div>
            <div><%: T("যোগদানের তারিখ", "Joining Date") %> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ঃ <b><%: JoinDate %></b></div>
        </div>
        <div class="p-1.5 space-y-2.5">
            <div><%: T("ছুটির সময় সীমা", "Leave Period") %> &nbsp;ঃ<%: PeriodFrom %> <b><%: T("তারিখ হইতে", "to") %></b> <%: PeriodTill %> <b><%: T("তারিখ পর্যন্ত।", "") %></b></div>
            <div><%: T("মোট", "Total") %> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ঃ <%: Days %> <%: T("দিন।", "day(s).") %></div>
            <div><%: T("আবেদনকারীর স্বাক্ষরঃ", "Applicant Signature:") %> <span class="inline-block border-b border-black w-56 align-bottom"></span></div>
            <div><%: T("আবেদনের তারিখ", "Application Date") %> ঃ <%: ApplyDate %></div>
            <div class="flex gap-1"><span class="shrink-0"><%: T("ছুটিতে থাকাকালীন ঠিকানা", "Address during leave") %> &nbsp;ঃ</span>
                <span class="<%= IsBangla ? "ansi" : "" %>"><%: Address %></span></div>
        </div>
    </div>

    <!-- Reason -->
    <div class="flex items-stretch gap-0 mt-5 mb-5">
        <div class="shrink-0 pr-2 flex items-center"><span class="tag"><%: T("ছুটির কারণঃ", "Reason:") %></span></div>
        <div class="box flex-1 px-2 py-2 <%= IsBangla ? "ansi" : "" %>"><%: Purpose %></div>
    </div>

    <!-- Leave details -->
    <table class="det">
        <thead>
            <tr class="cap"><th colspan="5"><%: T("ছুটির বিবরণ", "Leave Details") %></th></tr>
            <tr>
                <th style="width:22%"><%: T("ছুটির নাম", "Leave Name") %></th>
                <th style="width:17%"><%: T("মোট ছুটি", "Total") %></th>
                <th style="width:17%"><%: T("ব্যবহৃত ছুটি", "Used") %></th>
                <th style="width:17%"><%: T("পাওনা ছুটি", "Remaining") %></th>
                <th><%: T("মন্তব্য", "Remarks") %></th>
            </tr>
        </thead>
        <tbody>
            <asp:Repeater ID="rptLines" runat="server">
                <ItemTemplate>
                    <tr>
                        <td><%# Server.HtmlEncode(Convert.ToString(Eval("Name"))) %></td>
                        <td><%# Server.HtmlEncode(Convert.ToString(Eval("Total"))) %></td>
                        <td><%# Server.HtmlEncode(Convert.ToString(Eval("Used"))) %></td>
                        <td><%# Server.HtmlEncode(Convert.ToString(Eval("Remaining"))) %></td>
                        <td></td>
                    </tr>
                </ItemTemplate>
            </asp:Repeater>
        </tbody>
    </table>

    <!-- Signatures -->
    <div class="grid grid-cols-4 gap-6 mt-14 px-1">
        <div class="sig"><%: T("সুপারভাইজার/ইনচার্জ", "Supervisor / In-charge") %></div>
        <div class="sig"><%: T("উৎপাদন ব্যবস্থাপক/বিভাগীয়", "Production Mgr / Dept.") %></div>
        <div class="sig"><%: T("মানব সম্পদ বিভাগ", "HR Department") %></div>
        <div class="sig"><%: T("মহাব্যবস্থাপক", "General Manager") %></div>
    </div>

    <div class="cut"></div>

    <!-- Applicant copy -->
    <div class="text-center">
        <p class="text-[16px] font-medium"><%: Company %></p>
        <span class="inline-block box px-2 py-0.5 mt-1 font-medium"><%: T("আবেদনকারীর অংশ", "Applicant Copy") %></span>
    </div>

    <div class="box mt-1 px-1.5 py-2 space-y-3.5">
        <div><%: T("নাম", "Name") %> ঃ <b><%: EmpName %></b> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <%: T("পদবী", "Designation") %> ঃ <%: Designation %></div>
        <div><%: T("কার্ড নং", "Card No") %> ঃ <%: CardNo %> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <%: T("সেকশন", "Section") %> ঃ <%: Section %></div>
        <div><%: T("ছুটির সময়সীমা ঃ", "Leave period:") %><%: PeriodFromSlash %> <%: T("তারিখ হইতে", "to") %> <%: PeriodTillSlash %> <%: T("তারিখ পর্যন্ত মোট", "total") %> <%: Days %> <%: T("দিন।", "day(s).") %></div>
        <div><%: T("ছুটির কারণ", "Reason") %> &nbsp;&nbsp;&nbsp;&nbsp;ঃ <span class="<%= IsBangla ? "ansi" : "" %>"><%: Purpose %></span></div>
        <div><%: T("ছুটি উপভোগ কালীন ঠিকানা ঃ", "Address during leave:") %> <span class="<%= IsBangla ? "ansi" : "" %>"><%: Address %></span></div>
    </div>

    <div class="flex justify-end mt-14">
        <div class="sig w-44"><%: T("মহাব্যবস্থাপক", "General Manager") %></div>
    </div>
</div>
<% } %>

</form>
</body>
</html>
