<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LeaveApplication.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.LeaveInformation.LeaveApplication" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Leave Application</title>
    <!-- Tailwind CSS CDN -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- FontAwesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <!-- Inter Font -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; }
        ::-webkit-scrollbar{width:6px;height:6px}
        ::-webkit-scrollbar-track{background:#f1f5f9}
        ::-webkit-scrollbar-thumb{background:#cbd5e1;border-radius:3px}
        ::-webkit-scrollbar-thumb:hover{background:#94a3b8}

        /* ---- SutonnyMJ: ক্লায়েন্ট পিসিতে ইনস্টল থাকলে local() নেবে, নইলে সার্ভারের ফাইল থেকে ---- */
        @font-face{
            font-family:'SutonnyMJ';
            src:local('SutonnyMJ'), url('../../Fonts/SutonnyMJ.ttf') format('truetype'); /* পাথ আপনার প্রজেক্ট অনুযায়ী ঠিক করুন */
        }

        /* ---- Filter fields (HRM Reports এর মতই) ---- */
        .fld{display:flex;align-items:center;justify-content:space-between;gap:6px;height:32px;padding:0 10px;
             border:1px solid #d9dce5;border-radius:6px;background:#f6f7fb;font-size:13px;color:#1e293b;
             transition:border-color .15s, box-shadow .15s, background .15s;width:100%}
        .fld:hover{border-color:#b6bccb}
        .fld:focus{outline:none;border-color:#3b82f6;box-shadow:0 0 0 3px rgba(59,130,246,.15)}
        input.fld{display:block;cursor:text}
        input.fld::placeholder,textarea.fld::placeholder{color:#a0a7b5}
        select.fld{display:block;cursor:pointer;padding:0 6px}
        input.fld.date{background:#f3f4f7;color:#334155}
        textarea.fld{display:block;height:auto;padding:6px 10px;resize:vertical}
        .fld.ro,.fld[readonly]{background:#eceef3;color:#334155}
        .lbl{display:block;font-size:13px;color:#334155;margin-bottom:6px}
        .chk label{margin-left:4px;cursor:pointer;font-size:13px;color:#334155}
        .chk input{cursor:pointer;accent-color:#198754}

        /* ---- Font selector (Purpose / Address) ---- */
        .fontSel{height:24px;font-size:11px;border:1px solid #d9dce5;border-radius:6px;background:#fff;color:#334155;padding:0 6px;cursor:pointer}
        .fontSel:focus{outline:none;border-color:#3b82f6}
        .convBtn{height:24px;font-size:11px;font-weight:500;border:1px solid #bfdbfe;border-radius:6px;background:#eff6ff;color:#1d4ed8;padding:0 8px;cursor:pointer;white-space:nowrap}
        .convBtn:hover{background:#dbeafe}
        .undoBtn{height:24px;width:24px;font-size:11px;border:1px solid #d9dce5;border-radius:6px;background:#fff;color:#475569;cursor:pointer}
        .undoBtn:hover{background:#f1f5f9}
    </style>
</head>
<body class="bg-slate-100 text-slate-800 antialiased h-screen flex flex-col overflow-hidden">
<form id="form1" runat="server" class="flex flex-col h-screen overflow-hidden" autocomplete="off">
    <asp:HiddenField ID="hfApplyNo" runat="server" ClientIDMode="Static" />

    <section class="bg-white border-b border-slate-200 px-6 py-4 shrink-0 relative z-30">
        <h1 class="text-base font-bold text-slate-800 mb-3">Leave Application</h1>
        <div class="bg-slate-50/70 border border-slate-200 rounded-xl p-4">
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-x-4 gap-y-3">

                <div><label class="lbl">Employee ID</label>
                    <asp:TextBox ID="txtEmployeeId" runat="server" ClientIDMode="Static" CssClass="fld" AutoPostBack="true" OnTextChanged="txtEmployeeId_TextChanged" placeholder="Type ID, press Enter" /></div>
                <div><label class="lbl">Name</label>
                    <asp:TextBox ID="txtName" runat="server" ReadOnly="true" CssClass="fld ro" /></div>
                <div><label class="lbl">Designation</label>
                    <asp:TextBox ID="txtDesignation" runat="server" ReadOnly="true" CssClass="fld ro" /></div>
                <div><label class="lbl">Leave Type</label>
                    <asp:DropDownList ID="ddlLeaveType" runat="server" CssClass="fld" AutoPostBack="true" OnSelectedIndexChanged="ddlLeaveType_SelectedIndexChanged" /></div>

                <div><label class="lbl">Remaining Days</label>
                    <asp:TextBox ID="txtRemainingDays" runat="server" ReadOnly="true" CssClass="fld ro" /></div>
                <div><label class="lbl">From Date</label>
                    <asp:TextBox ID="txtFromDate" runat="server" TextMode="Date" CssClass="fld date" AutoPostBack="true" OnTextChanged="txtFromDate_TextChanged" /></div>
                <div><label class="lbl">Till Date</label>
                    <asp:TextBox ID="txtTillDate" runat="server" TextMode="Date" CssClass="fld date" /></div>
                <div><label class="lbl">Address From</label>
                    <div class="chk flex items-center gap-4 h-8">
                        <asp:CheckBox ID="chkPermanent" runat="server" Text="Permanent" AutoPostBack="true" OnCheckedChanged="chkPermanent_CheckedChanged" />
                        <asp:CheckBox ID="chkPresent" runat="server" Text="Present" AutoPostBack="true" OnCheckedChanged="chkPresent_CheckedChanged" />
                        <asp:CheckBox ID="chkCustom" runat="server" Text="Custom" AutoPostBack="true" OnCheckedChanged="chkCustom_CheckedChanged" />
                    </div></div>

                <%-- Desktop backend (Pro_Leave_Appliction) এ @Phone ও @Alternate_Person লাগে, তাই এ দুটি যোগ করা হয়েছে --%>
                <div><label class="lbl">Phone No</label>
                    <asp:TextBox ID="txtPhone" runat="server" CssClass="fld" placeholder="Phone number" /></div>
                <div><label class="lbl">Alternate Person</label>
                    <asp:TextBox ID="txtAlternate" runat="server" CssClass="fld" placeholder="Alternate person" /></div>
                <div class="lg:col-span-1 hidden lg:block"></div>
                <div class="hidden lg:block"></div>

                <%-- Purpose: SutonnyMJ / Unicode মাল্টি ফন্ট --%>
                <div class="sm:col-span-2">
                    <div class="flex items-center justify-between mb-1.5">
                        <label class="lbl" style="margin-bottom:0">Purpose</label>
                        <div class="flex items-center gap-1.5">
                            <button type="button" class="convBtn" title="ঘরের Bijoy লেখাকে Unicode এ রূপান্তর করে" onclick="convertField('txtPurpose','fontPurpose')">Bijoy → Unicode</button>
                            <button type="button" class="undoBtn" title="রূপান্তরের আগের লেখা ফিরিয়ে আনে" onclick="undoConvert('txtPurpose','fontPurpose')">↩</button>
                            <select id="fontPurpose" class="fontSel" onchange="setFont('txtPurpose', this.value)">
                                <option value="mj">SutonnyMJ</option>
                                <option value="uni">Unicode</option>
                            </select>
                        </div>
                    </div>
                    <asp:TextBox ID="txtPurpose" runat="server" ClientIDMode="Static" TextMode="MultiLine" Rows="3" CssClass="fld" />
                </div>

                <%-- Address: SutonnyMJ / Unicode মাল্টি ফন্ট --%>
                <div class="sm:col-span-2">
                    <div class="flex items-center justify-between mb-1.5">
                        <label class="lbl" style="margin-bottom:0">Address</label>
                        <div class="flex items-center gap-1.5">
                            <button type="button" class="convBtn" title="ঘরের Bijoy লেখাকে Unicode এ রূপান্তর করে" onclick="convertField('txtAddress','fontAddress')">Bijoy → Unicode</button>
                            <button type="button" class="undoBtn" title="রূপান্তরের আগের লেখা ফিরিয়ে আনে" onclick="undoConvert('txtAddress','fontAddress')">↩</button>
                            <select id="fontAddress" class="fontSel" onchange="setFont('txtAddress', this.value)">
                                <option value="mj">SutonnyMJ</option>
                                <option value="uni">Unicode</option>
                            </select>
                        </div>
                    </div>
                    <asp:TextBox ID="txtAddress" runat="server" ClientIDMode="Static" TextMode="MultiLine" Rows="3" CssClass="fld" />
                </div>
            </div>
        </div>

        <div class="flex justify-end items-center gap-2 mt-3">
            <asp:LinkButton ID="btnSave" runat="server" OnClick="btnSave_Click" CssClass="h-9 px-5 rounded-lg bg-emerald-600 hover:bg-emerald-700 text-white text-sm font-medium flex items-center gap-2 shadow-sm transition">
                <i class="fa-regular fa-floppy-disk text-xs"></i><span>Save</span>
            </asp:LinkButton>
            <asp:LinkButton ID="btnUpdate" runat="server" OnClick="btnUpdate_Click" CssClass="h-9 px-5 rounded-lg bg-amber-500 hover:bg-amber-600 text-white text-sm font-medium flex items-center gap-2 shadow-sm transition">
                <i class="fa-solid fa-pen text-xs"></i><span>Update</span>
            </asp:LinkButton>
            <asp:LinkButton ID="btnDelete" runat="server" OnClick="btnDelete_Click" OnClientClick="return confirm('Are you sure you want to delete this leave application?');" CssClass="h-9 px-5 rounded-lg bg-red-600 hover:bg-red-700 text-white text-sm font-medium flex items-center gap-2 shadow-sm transition">
                <i class="fa-regular fa-trash-can text-xs"></i><span>Delete</span>
            </asp:LinkButton>
            <asp:LinkButton ID="btnApplication" runat="server" OnClick="btnApplication_Click" OnClientClick="return onAppClick();" CssClass="h-9 px-5 rounded-lg bg-blue-600 hover:bg-blue-700 text-white text-sm font-medium flex items-center gap-2 shadow-sm transition">
                <i class="fa-solid fa-print text-xs"></i><span>Application</span>
            </asp:LinkButton>
            <asp:LinkButton ID="btnClear" runat="server" OnClick="btnClear_Click" CssClass="h-9 px-4 rounded-lg border border-slate-300 bg-white hover:bg-slate-50 text-slate-700 text-sm font-medium flex items-center gap-2 transition">
                <i class="fa-solid fa-eraser text-xs"></i><span>Clear</span>
            </asp:LinkButton>
        </div>
    </section>

    <!-- Results -->
    <div class="flex-1 flex flex-col min-h-0 overflow-hidden">
        <main class="flex-1 flex flex-col min-h-0 bg-slate-100 overflow-hidden relative">

            <div class="bg-white border-b border-slate-200 px-6 py-3 flex flex-wrap items-center justify-between gap-4 shrink-0">
                <div>
                    <div class="flex items-center space-x-2">
                        <h2 class="text-base font-bold text-slate-800">Open Leave Applications</h2>
                        <asp:Label ID="lblCount" runat="server" CssClass="bg-indigo-50 text-indigo-700 text-xs font-semibold px-2.5 py-0.5 rounded-full border border-indigo-100" Text="0 Records" />
                    </div>
                    <p class="text-xs text-slate-500 mt-0.5">Click a row to load it into the form for Update / Delete.</p>
                </div>
                <div class="relative">
                    <input type="text" id="tableSearch" onkeyup="searchTable()" placeholder="Quick filter table..." class="bg-slate-50 border border-slate-300 rounded-lg pl-8 pr-3 py-1.5 text-xs text-slate-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 w-48 sm:w-64">
                    <i class="fa-solid fa-search absolute left-2.5 top-2 text-slate-400 text-xs"></i>
                </div>
            </div>

            <div class="flex-1 p-6 overflow-auto">
                <div class="bg-white border border-slate-200 rounded-xl shadow-sm overflow-hidden flex flex-col h-full">
                    <div class="overflow-auto flex-1">
                        <table id="reportTable" class="w-full text-left border-collapse">
                            <thead>
                                <tr class="bg-slate-50 border-b border-slate-200 text-xs font-semibold text-slate-600 uppercase tracking-wider sticky top-0 z-10">
                                    <th class="py-3.5 px-4">Apply No</th>
                                    <th class="py-3.5 px-4">ID No</th>
                                    <th class="py-3.5 px-4">Leave Type</th>
                                    <th class="py-3.5 px-4">From Date</th>
                                    <th class="py-3.5 px-4">Till Date</th>
                                    <th class="py-3.5 px-4">Apply Days</th>
                                </tr>
                            </thead>
                            <tbody id="tableBody" class="divide-y divide-slate-100 text-sm text-slate-700 bg-white">
                                <asp:Repeater ID="rptApplications" runat="server" OnItemCommand="rptApplications_ItemCommand">
                                    <ItemTemplate>
                                        <tr class="cursor-pointer hover:bg-slate-50/80 transition-colors <%# Convert.ToString(Eval("ApplyNo")) == hfApplyNo.Value ? "bg-blue-50" : "" %>"
                                            onclick="var a=this.querySelector('a');if(a)a.click();">
                                            <td class="py-3 px-4 text-xs font-semibold text-blue-700">
                                                <asp:LinkButton ID="lnkPick" runat="server" CommandName="pick"
                                                    CommandArgument='<%# Server.HtmlEncode(Convert.ToString(Eval("ApplyNo"))) %>'
                                                    Text='<%# Server.HtmlEncode(Convert.ToString(Eval("ApplyNo"))) %>' />
                                            </td>
                                            <td class="py-3 px-4 text-xs font-semibold text-slate-900"><%# Server.HtmlEncode(Convert.ToString(Eval("IdNo"))) %></td>
                                            <td class="py-3 px-4 text-xs text-slate-600"><%# Server.HtmlEncode(Convert.ToString(Eval("LeaveType"))) %></td>
                                            <td class="py-3 px-4 text-xs text-slate-600"><%# Server.HtmlEncode(Convert.ToString(Eval("FromDate"))) %></td>
                                            <td class="py-3 px-4 text-xs text-slate-600"><%# Server.HtmlEncode(Convert.ToString(Eval("TillDate"))) %></td>
                                            <td class="py-3 px-4 text-xs text-slate-600"><%# Server.HtmlEncode(Convert.ToString(Eval("Days"))) %></td>
                                        </tr>
                                    </ItemTemplate>
                                </asp:Repeater>
                                <tr id="trEmpty" runat="server" visible="false"><td colspan="6" class="text-center py-8 text-slate-400 text-xs">No open leave applications found.</td></tr>
                            </tbody>
                        </table>
                    </div>
                    <div class="bg-slate-50 border-t border-slate-200 px-6 py-3 text-xs text-slate-500 shrink-0">
                        <asp:Literal ID="litPaging" runat="server" />
                    </div>
                </div>
            </div>
        </main>
    </div>

    <!-- Toast -->
    <div id="toastContainer" class="fixed bottom-5 right-5 z-50 flex flex-col space-y-2 pointer-events-none"></div>
</form>

<script>
// @ts-nocheck
const esc = s => String(s).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));

// ---- Multi font: Purpose / Address (SutonnyMJ ও Unicode) ----
var FONTS = {
    uni: "'Inter','Noto Sans Bengali','Nirmala UI','Vrinda',sans-serif",
    mj:  "'SutonnyMJ',sans-serif"
};

function setFont(id, mode) {
    var el = document.getElementById(id);
    if (!el) return;
    el.style.fontFamily = FONTS[mode] || FONTS.uni;
    el.style.fontSize = (mode === 'mj') ? '16px' : '13px';   // SutonnyMJ ছোট দেখায়, তাই বড়
    try { localStorage.setItem('font_' + id, mode); } catch (e) {}
}

// পেজ লোড/পোস্টব্যাকের পর আগের পছন্দ ফিরিয়ে আনে (ডিফল্ট: SutonnyMJ)
document.addEventListener('DOMContentLoaded', function () {
    [['txtPurpose', 'fontPurpose'], ['txtAddress', 'fontAddress']].forEach(function (p) {
        var mode = 'mj';
        try { mode = localStorage.getItem('font_' + p[0]) || 'mj'; } catch (e) {}
        document.getElementById(p[1]).value = mode;
        setFont(p[0], mode);
    });
});

// ======================================================================
// Bijoy (SutonnyMJ ইত্যাদি ANSI) -> Unicode কনভার্টার
// ম্যাপিং টেবিল: "bijoy-unicode-converter" (MIT, Naim Howlader) থেকে নেওয়া।
// কার/রেফ সাজানোর অংশ নতুন করে লেখা (ে ি ৈ এবং র্ এর ক্রম ঠিক রাখতে)।
// (সব বাংলা/বিশেষ অক্ষর \uXXXX আকারে, যাতে ফাইলের এনকোডিং নিয়ে সমস্যা না হয়)
// ======================================================================
var BIJOY_MAP = [
    ["0","\u09e6"],
    ["1","\u09e7"],
    ["2","\u09e8"],
    ["3","\u09e9"],
    ["4","\u09ea"],
    ["5","\u09eb"],
    ["6","\u09ec"],
    ["7","\u09ed"],
    ["8","\u09ee"],
    ["9","\u09ef"],
    ["i\u00a8","\u09b0\u200c\u09cd\u09af"],
    ["\u00aa\u00a8","\u09cd\u09b0\u09cd\u09af"],
    ["\u00b0","\u0995\u09cd\u0995"],
    ["\u00b1","\u0995\u09cd\u099f"],
    ["\u00b3","\u0995\u09cd\u09a4"],
    ["K\u00a1","\u0995\u09cd\u09ac"],
    ["\u00af\u0152","\u09b8\u09cd\u0995\u09cd\u09b0"],
    ["\u00b5","\u0995\u09cd\u09b0"],
    ["K\u00ac","\u0995\u09cd\u09b2"],
    ["\u00b6","\u0995\u09cd\u09b7"],
    ["\u00ff","\u0995\u09cd\u09b7"],
    ["\u00b7","\u0995\u09cd\u09b8"],
    ["\u00b8","\u0997\u09c1"],
    ["\u00bb","\u0997\u09cd\u09a7"],
    ["M\u0153","\u0997\u09cd\u09a8"],
    ["M\u00a5","\u0997\u09cd\u09ae"],
    ["M\u00ad","\u0997\u09cd\u09b2"],
    ["\u00bc","\u0999\u09cd\u0995"],
    ["\u2022\u00b6","\u0999\u09cd\u0995\u09cd\u09b7"],
    ["\u2022L","\u0999\u09cd\u0996"],
    ["\u00bd","\u0999\u09cd\u0997"],
    ["\u2022N","\u0999\u09cd\u0998"],
    ["\u2022","\u0995\u09cd\u09b8"],
    ["\u201dP","\u099a\u09cd\u099a"],
    ["\u201dQ","\u099a\u09cd\u099b"],
    ["\u201dQ\u00a1","\u099a\u09cd\u099b\u09cd\u09ac"],
    ["\u201dT","\u099a\u09cd\u099e"],
    ["\u00be\u00a1","\u099c\u09cd\u099c\u09cd\u09ac"],
    ["\u00be","\u099c\u09cd\u099c"],
    ["\u00c0","\u099c\u09cd\u099d"],
    ["\u00c1","\u099c\u09cd\u099e"],
    ["R\u00a1","\u099c\u09cd\u09ac"],
    ["\u00c2","\u099e\u09cd\u099a"],
    ["\u00c3","\u099e\u09cd\u099b"],
    ["\u00c4","\u099e\u09cd\u099c"],
    ["\u00c5","\u099e\u09cd\u099d"],
    ["\u00c6","\u099f\u09cd\u099f"],
    ["U\u00a1","\u099f\u09cd\u09ac"],
    ["U\u00a5","\u099f\u09cd\u09ae"],
    ["\u00c7","\u09a1\u09cd\u09a1"],
    ["\u00c8","\u09a3\u09cd\u099f"],
    ["\u00c9","\u09a3\u09cd\u09a0"],
    ["\u00dd","\u09a8\u09cd\u09b8"],
    ["\u00ca","\u09a3\u09cd\u09a1"],
    ["\u0161\u2018","\u09a8\u09cd\u09a4\u09c1"],
    ["Y^","\u09a3\u09cd\u09ac"],
    ["\u00cb","\u09a4\u09cd\u09a4"],
    ["\u00cb\u00a1","\u09a4\u09cd\u09a4\u09cd\u09ac"],
    ["\u00cc","\u09a4\u09cd\u09a5"],
    ["Z\u00a5","\u09a4\u09cd\u09ae"],
    ["\u0161\u2014\u00a1","\u09a8\u09cd\u09a4\u09cd\u09ac"],
    ["Z\u00a1","\u09a4\u09cd\u09ac"],
    ["\u00ce","\u09a4\u09cd\u09b0"],
    ["_\u00a1","\u09a5\u09cd\u09ac"],
    ["\u02dcM","\u09a6\u09cd\u0997"],
    ["\u02dcN","\u09a6\u09cd\u0998"],
    ["\u00cf","\u09a6\u09cd\u09a6"],
    ["\u00d7","\u09a6\u09cd\u09a7"],
    ["\u02dc\u00a1","\u09a6\u09cd\u09ac"],
    ["\u00d8","\u09a6\u09cd\u09ac"],
    ["\u2122\u00a2","\u09a6\u09cd\u09ad"],
    ["\u00d9","\u09a6\u09cd\u09ae"],
    ["`\u00aa\u201c","\u09a6\u09cd\u09b0\u09c1"],
    ["a\u0178","\u09a7\u09cd\u09ac"],
    ["a\u00a5","\u09a7\u09cd\u09ae"],
    ["\u203aU","\u09a8\u09cd\u099f"],
    ["\u00da","\u09a8\u09cd\u09a0"],
    ["\u00db","\u09a8\u09cd\u09a1"],
    ["\u0161\u00cd","\u09a8\u09cd\u09a4"],
    ["\u0161\u2014","\u09a8\u09cd\u09a4"],
    ["\u0161\u00bf","\u09a8\u09cd\u09a4\u09cd\u09b0"],
    ["\u0161\u2019","\u09a8\u09cd\u09a5"],
    ["\u203a`","\u09a8\u09cd\u09a6"],
    ["\u203a\u00d8","\u09a8\u09cd\u09a6\u09cd\u09ac"],
    ["\u00dc","\u09a8\u09cd\u09a7"],
    ["b\u0153","\u09a8\u09cd\u09a8"],
    ["\u0161^","\u09a8\u09cd\u09ac"],
    ["b\u00a5","\u09a8\u09cd\u09ae"],
    ["\u00de","\u09aa\u09cd\u099f"],
    ["\u00df","\u09aa\u09cd\u09a4"],
    ["c\u0153","\u09aa\u09cd\u09a8"],
    ["\u00e0","\u09aa\u09cd\u09aa"],
    ["c\u00f8","\u09aa\u09cd\u09b2"],
    ["c\u00ad","\u09aa\u09cd\u09b2"],
    ["\u00e1","\u09aa\u09cd\u09b8"],
    ["d\u00ac","\u09ab\u09cd\u09b2"],
    ["\u00e2","\u09ac\u09cd\u099c"],
    ["\u00e3","\u09ac\u09cd\u09a6"],
    ["\u00e4","\u09ac\u09cd\u09a7"],
    ["e\u0178","\u09ac\u09cd\u09ac"],
    ["e\u00ad","\u09ac\u09cd\u09b2"],
    ["\u00e5","\u09ad\u09cd\u09b0"],
    ["g\u0153","\u09ae\u09cd\u09a8"],
    ["\u00a4\u00fa","\u09ae\u09cd\u09aa"],
    ["\u00e7","\u09ae\u09cd\u09ab"],
    ["\u00a4^","\u09ae\u09cd\u09ac"],
    ["\u00a4\u00a2","\u09ae\u09cd\u09ad"],
    ["\u00a4\u00a3","\u09ae\u09cd\u09ad\u09cd\u09b0"],
    ["\u00a4\u00a7","\u09ae\u09cd\u09ae"],
    ["\u00a4\u00ad","\u09ae\u09cd\u09b2"],
    ["i\u201c","\u09b0\u09c1"],
    ["i\u00e6","\u09b0\u09c1"],
    ["i\u0192","\u09b0\u09c2"],
    ["\u00e9","\u09b2\u09cd\u0995"],
    ["\u00ea","\u09b2\u09cd\u0997"],
    ["\u00eb","\u09b2\u09cd\u099f"],
    ["\u00ec","\u09b2\u09cd\u09a1"],
    ["\u00ed","\u09b2\u09cd\u09aa"],
    ["\u00ee","\u09b2\u09cd\u09ab"],
    ["j\u00a6","\u09b2\u09cd\u09ac"],
    ["j\u00a5","\u09b2\u09cd\u09ae"],
    ["j\u00f8","\u09b2\u09cd\u09b2"],
    ["\u00ef","\u09b6\u09c1"],
    ["\u00f0","\u09b6\u09cd\u099a"],
    ["k\u0153","\u09b6\u09cd\u09a8"],
    ["k\u00f8","\u09b6\u09cd\u09b2"],
    ["k\u00a6","\u09b6\u09cd\u09ac"],
    ["k\u00a5","\u09b6\u09cd\u09ae"],
    ["k\u00ad","\u09b6\u09cd\u09b2"],
    ["\u00ae\u2039","\u09b7\u09cd\u0995"],
    ["\u00ae\u0152","\u09b7\u09cd\u0995\u09cd\u09b0"],
    ["\u00f3","\u09b7\u09cd\u099f"],
    ["\u00f4","\u09b7\u09cd\u09a0"],
    ["\u00f2","\u09b7\u09cd\u09a3"],
    ["\u00ae\u00fa","\u09b7\u09cd\u09aa"],
    ["\u00f5","\u09b7\u09cd\u09ab"],
    ["\u00ae\u00a7","\u09b7\u09cd\u09ae"],
    ["\u00af\u2039","\u09b8\u09cd\u0995"],
    ["\u00f7","\u09b8\u09cd\u099f"],
    ["\u00f6","\u09b8\u09cd\u0996"],
    ["\u00af\u2014","\u09b8\u09cd\u09a4"],
    ["\u00af\u00cd","\u09b8\u09cd\u09a4"],
    ["\u00af\u2018","\u09b8\u09cd\u09a4\u09c1"],
    ["\u00af\u00bf","\u09b8\u09cd\u09a4\u09cd\u09b0"],
    ["\u00af\u2019","\u09b8\u09cd\u09a5"],
    ["m\u0153","\u09b8\u09cd\u09a8"],
    ["\u00af\u00fa","\u09b8\u09cd\u09aa"],
    ["\u00f9","\u09b8\u09cd\u09ab"],
    ["\u00af^","\u09b8\u09cd\u09ac"],
    ["\u00af\u00a7","\u09b8\u09cd\u09ae"],
    ["\u00af\u00ad","\u09b8\u09cd\u09b2"],
    ["\u00fb","\u09b9\u09c1"],
    ["n\u00e8","\u09b9\u09cd\u09a3"],
    ["\u00fd","\u09b9\u09cd\u09a8"],
    ["\u00fe","\u09b9\u09cd\u09ae"],
    ["n\u00ac","\u09b9\u09cd\u09b2"],
    ["\u00fc","\u09b9\u09c3"],
    ["\u00a9","\ue000"],
    ["Av","\u0986"],
    ["A","\u0985"],
    ["B","\u0987"],
    ["C","\u0988"],
    ["D","\u0989"],
    ["E","\u098a"],
    ["F","\u098b"],
    ["G","\u098f"],
    ["H","\u0990"],
    ["I","\u0993"],
    ["J","\u0994"],
    ["K","\u0995"],
    ["L","\u0996"],
    ["M","\u0997"],
    ["N","\u0998"],
    ["O","\u0999"],
    ["P","\u099a"],
    ["Q","\u099b"],
    ["R","\u099c"],
    ["S","\u099d"],
    ["T","\u099e"],
    ["U","\u099f"],
    ["V","\u09a0"],
    ["W","\u09a1"],
    ["X","\u09a2"],
    ["Y","\u09a3"],
    ["Z","\u09a4"],
    ["_","\u09a5"],
    ["`","\u09a6"],
    ["a","\u09a7"],
    ["b","\u09a8"],
    ["c","\u09aa"],
    ["d","\u09ab"],
    ["e","\u09ac"],
    ["f","\u09ad"],
    ["g","\u09ae"],
    ["h","\u09af"],
    ["i","\u09b0"],
    ["j","\u09b2"],
    ["k","\u09b6"],
    ["l","\u09b7"],
    ["m","\u09b8"],
    ["n","\u09b9"],
    ["o","\u09dc"],
    ["p","\u09dd"],
    ["q","\u09df"],
    ["r","\u09ce"],
    ["v","\u09be"],
    ["w","\u09bf"],
    ["x","\u09c0"],
    ["y","\u09c1"],
    ["z","\u09c1"],
    ["~","\u09c2"],
    ["\u201e","\u09c3"],
    ["\u2021","\u09c7"],
    ["\u2020","\u09c7"],
    ["\u2030","\u09c8"],
    ["\u02c6","\u09c8"],
    ["\u0160","\u09d7"],
    ["\u00d4","\u2018"],
    ["\u00d5","\u2019"],
    ["|","\u0964"],
    ["\u00d2","\u201c"],
    ["\u00d3","\u201d"],
    ["s","\u0982"],
    ["t","\u0983"],
    ["u","\u0981"],
    ["\u00aa","\u09cd\u09b0"],
    ["\u00d6","\u09cd\u09b0"],
    ["\u00ab","\u09cd\u09b0"],
    ["\u00a8","\u09cd\u09af"],
    ["&","\u09cd"],
    ["\u2026","\u09c3"]
];

var BJ_MARK = "\uE000", BJ_H = "\u09CD", BJ_ZWNJ = "\u200C";
function bjIsCons(c) {
    if (!c) return false;
    var x = c.charCodeAt(0);
    return (x >= 0x0995 && x <= 0x09B9) || x === 0x09CE || x === 0x09DC || x === 0x09DD || x === 0x09DF;
}
function bjIsPre(c) { return c === "\u09BF" || c === "\u09C7" || c === "\u09C8"; } // ি ে ৈ

// Bijoy-তে ি ে ৈ ব্যঞ্জনের আগে বসে এবং র্ (রেফ) ব্যঞ্জনের পরে বসে; Unicode-এ উল্টো।
function bjReorder(t) {
    var out = "", i = 0, n = t.length;
    while (i < n) {
        var j = i;
        while (j < n && bjIsPre(t.charAt(j))) j++;
        var pres = t.substring(i, j);
        if (j < n && bjIsCons(t.charAt(j))) {
            var k = j + 1, reph = false, body = t.charAt(j);
            for (;;) {
                var a = t.charAt(k);
                if (a === BJ_MARK) { reph = true; k++; continue; }
                if (a === BJ_ZWNJ && t.charAt(k + 1) === BJ_H && bjIsCons(t.charAt(k + 2))) { body += a + BJ_H + t.charAt(k + 2); k += 3; continue; }
                if (a === BJ_H && bjIsCons(t.charAt(k + 1))) { body += a + t.charAt(k + 1); k += 2; continue; }
                break;
            }
            if (pres) {
                var last = pres.charAt(pres.length - 1), nx = t.charAt(k);
                if (last === "\u09C7" && nx === "\u09BE") { pres = pres.slice(0, -1) + "\u09CB"; k++; }       // ে + া = ো
                else if (last === "\u09C7" && nx === "\u09D7") { pres = pres.slice(0, -1) + "\u09CC"; k++; }  // ে + ৗ = ৌ
            }
            out += (reph ? "\u09B0" + BJ_H : "") + body + pres;
            i = k;
            continue;
        }
        if (pres) { out += pres; i = j; continue; }
        out += (t.charAt(i) === BJ_MARK ? "\u09B0" + BJ_H : t.charAt(i));
        i++;
    }
    return out;
}

function bijoyToUnicode(text) {
    var s = String(text == null ? "" : text);
    for (var m = 0; m < BIJOY_MAP.length; m++) s = s.split(BIJOY_MAP[m][0]).join(BIJOY_MAP[m][1]);
    s = bjReorder(s);
    s = s.replace(/\u0985\u09BE/g, "\u0986");                                  // অ + া = আ
    s = s.replace(/\u0981([\u09BE\u09CB\u09CC\u09D7\u09C1\u09C2\u09C0\u09C3])/g, "$1\u0981"); // ঁ কারের পরে
    return s;
}
function hasBengaliUnicode(s) { return /[\u0980-\u09FF]/.test(s); }


// ---- "Bijoy → Unicode" বাটন: ডাটাবেসের পুরাতন Bijoy লেখাকে Unicode এ রূপান্তর ----
function convertField(id, fontId) {
    var el = document.getElementById(id);
    if (!el) return;
    var txt = el.value;
    if (!txt || !txt.trim()) { showNotification('রূপান্তর করার মতো কোনো লেখা নেই।'); return; }
    if (hasBengaliUnicode(txt)) { showNotification('এই লেখায় আগে থেকেই Unicode বাংলা আছে, তাই রূপান্তর করা হয়নি।'); return; }
    el._bijoyBackup = txt;                       // ভুল হলে ↩ বাটনে ফেরত আনা যাবে
    el.value = bijoyToUnicode(txt);
    var sel = document.getElementById(fontId);
    if (sel) sel.value = 'uni';
    setFont(id, 'uni');                          // Unicode ফন্টে দেখাবে
    showNotification('Bijoy থেকে Unicode এ রূপান্তর হয়েছে।');
}

function undoConvert(id, fontId) {
    var el = document.getElementById(id);
    if (!el) return;
    if (el._bijoyBackup === undefined) { showNotification('ফেরত আনার মতো আগের লেখা নেই।'); return; }
    el.value = el._bijoyBackup;
    el._bijoyBackup = undefined;
    var sel = document.getElementById(fontId);
    if (sel) sel.value = 'mj';
    setFont(id, 'mj');                           // আগের Bijoy লেখা SutonnyMJ তে দেখাবে
    showNotification('আগের লেখা ফিরিয়ে আনা হয়েছে।');
}

// Application (রিপোর্ট) বাটন: নতুন ট্যাবে খোলে, এই পেজ অপরিবর্তিত থাকে
function onAppClick() {
    var id = document.getElementById('txtEmployeeId').value.trim();
    if (!id) { showNotification('Please enter Employee ID first.'); return false; }
    var f = document.forms[0];
    f.target = '_blank';
    setTimeout(function () { f.target = ''; }, 1000);
    return true;
}

// Enter চাপলে ফর্ম সাবমিট বন্ধ; Employee ID তে Enter = ডেটা লোড
document.addEventListener('DOMContentLoaded', function () {
    document.getElementById('form1').addEventListener('keydown', function (e) {
        if (e.key !== 'Enter') return;
        var t = e.target;
        if (t.tagName === 'TEXTAREA' || t.tagName === 'A' || t.tagName === 'BUTTON') return;
        e.preventDefault();
        if (t.id === 'txtEmployeeId') __doPostBack('<%= txtEmployeeId.UniqueID %>', '');
    });
});

// টেবিলের Quick filter
function searchTable() {
    const q = document.getElementById('tableSearch').value.toLowerCase();
    document.querySelectorAll('#tableBody tr').forEach(tr => {
        if (tr.id && tr.id.indexOf('trEmpty') > -1) return;
        tr.style.display = tr.textContent.toLowerCase().includes(q) ? '' : 'none';
    });
}

function showNotification(message) {
    const container = document.getElementById('toastContainer');
    const toast = document.createElement('div');
    toast.className = "bg-slate-900 text-white text-xs px-4 py-2.5 rounded-xl shadow-lg pointer-events-auto flex items-center space-x-2 transition transform translate-y-2 opacity-0";
    toast.innerHTML = `<i class="fa-solid fa-circle-info text-indigo-400"></i><span>${esc(message)}</span>`;
    container.appendChild(toast);
    setTimeout(() => toast.classList.remove('translate-y-2', 'opacity-0'), 10);
    setTimeout(() => { toast.classList.add('translate-y-2', 'opacity-0'); setTimeout(() => toast.remove(), 300); }, 3500);
}
</script>
</body>
</html>
