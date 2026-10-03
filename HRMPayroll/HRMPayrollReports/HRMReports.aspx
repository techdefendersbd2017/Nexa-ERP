<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="HRMReports.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.HRMPayrollReports.HRMReports" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HRM Reports Dashboard</title>
    <!-- Tailwind CSS CDN -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- FontAwesome for professional icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <!-- Inter Font -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">

    <style>
        body { font-family: 'Inter', sans-serif; }
        ::-webkit-scrollbar{width:6px;height:6px}
        ::-webkit-scrollbar-track{background:#f1f5f9}
        ::-webkit-scrollbar-thumb{background:#cbd5e1;border-radius:3px}
        ::-webkit-scrollbar-thumb:hover{background:#94a3b8}

        /* ---- Filter fields (select / multi-select look) ---- */দ
        .fld{display:flex;align-items:center;justify-content:space-between;gap:6px;height:32px;padding:0 10px;
             border:1px solid #d9dce5;border-radius:6px;background:#f6f7fb;font-size:13px;color:#94a3b8;
             cursor:pointer;user-select:none;transition:border-color .15s, box-shadow .15s, background .15s;width:100%}
        .fld:hover{border-color:#b6bccb}
        .fld:focus,.fld.open{outline:none;border-color:#3b82f6;box-shadow:0 0 0 3px rgba(59,130,246,.15)}
        .fld.has{background:#fafaee;border-color:#d8dbc9;color:#1e293b}
        .fld .txt{flex:1;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;text-align:left}
        .fld .clr{display:none;color:#64748b;font-size:11px;padding:3px;border-radius:4px}
        .fld .clr:hover{background:#e2e8f0;color:#0f172a}
        .fld.has .clr{display:inline-block}
        .fld .chev{color:#64748b;font-size:11px}
        input.fld{cursor:text}
        input.fld::placeholder{color:#a0a7b5}
        input.fld.date{background:#f3f4f7;color:#334155}
        .dt-wrap{position:relative}
        .dt-wrap i{position:absolute;right:10px;top:10px;color:#a0a7b5;font-size:12px;pointer-events:none}

        .panel{position:absolute;left:0;top:calc(100% + 4px);min-width:100%;width:260px;background:#fff;border:1px solid #e2e8f0;
               border-radius:8px;box-shadow:0 10px 25px -5px rgba(15,23,42,.18),0 4px 10px -6px rgba(15,23,42,.12);z-index:60}
        .panel.right{left:auto;right:0}
        .panel .ph{display:flex;align-items:center;justify-content:space-between;padding:8px 10px;font-size:12px;color:#64748b;border-bottom:1px solid #eef0f4}
        .panel .ph button{color:#ef4444;font-size:12px;background:none;border:0;cursor:pointer}
        .panel .ph button:hover{text-decoration:underline}
        .panel .ps{display:flex;align-items:center;gap:8px;padding:8px 10px;border-bottom:1px solid #eef0f4}
        .panel .ps i{color:#94a3b8;font-size:13px}
        .panel .ps input{flex:1;border:0;outline:0;font-size:13px;color:#334155;background:transparent;min-width:0}
        .panel .pl{max-height:224px;overflow-y:auto;padding:6px}
        .panel .sec{font-size:11px;font-weight:600;color:#64748b;padding:6px 8px 4px}
        .panel .it{display:flex;align-items:center;gap:10px;padding:7px 8px;border-radius:6px;font-size:13px;color:#1e293b;cursor:pointer}
        .panel .it:hover{background:#f1f5f9}
        .panel .it.sel-single{background:#eff6ff;color:#1d4ed8;font-weight:500}
        .panel .empty{padding:14px 8px;font-size:12px;color:#94a3b8;text-align:center}
        .cb{width:16px;height:16px;border-radius:4px;border:1.5px solid #cbd5e1;background:#fff;display:inline-flex;align-items:center;justify-content:center;flex-shrink:0;color:#fff;font-size:9px}
        .cb.on{background:#2563eb;border-color:#2563eb}
        .lbl{display:block;font-size:13px;color:#334155;margin-bottom:6px}
        .lbl.sm{font-size:11.5px;color:#64748b}
        </style>
</head>
<body class="bg-slate-100 text-slate-800 antialiased h-screen flex flex-col overflow-hidden">
<form id="form1" runat="server" class="flex flex-col h-screen overflow-hidden" autocomplete="off">

    <!-- Top Header Bar -->
    <header class="bg-white border-b border-slate-200 px-6 py-3 flex items-center justify-between shadow-xs shrink-0 relative z-40 relative z-40">
        <div class="flex items-center space-x-3">
            <div class="bg-indigo-600 text-white p-2 rounded-lg shadow-sm">
                <i class="fa-solid fa-users-gear text-lg"></i>
            </div>
            <div>
                <h1 class="text-lg font-bold text-slate-900 tracking-tight">HRM Reports</h1>
                <p class="text-xs text-slate-500">Human Resource Management & Analytics Suite</p>
            </div>
        </div>
        <div class="flex items-center space-x-4">
            <button type="button" onclick="showNotification('System status: All services online')" class="text-slate-500 hover:text-slate-700 p-2 rounded-full hover:bg-slate-100 transition">
                <i class="fa-regular fa-bell text-lg"></i>
            </button>
            <div class="flex items-center space-x-2 border-l pl-4 border-slate-200">
                <div class="w-8 h-8 rounded-full bg-indigo-100 text-indigo-700 flex items-center justify-center font-semibold text-sm">
                    HR
                </div>
                <span class="text-sm font-medium text-slate-700 hidden sm:inline">Admin User</span>
            </div>
        </div>
    </header>

    <!-- Filter Panel -->
    <section class="bg-white border-b border-slate-200 px-6 py-4 shrink-0 relative z-30">
        <asp:HiddenField ID="hfBranch" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="hfCategory" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="hfDept" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="hfSection" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="hfSubSec" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="hfFloor" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="hfDesig" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="hfLevel" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="hfBlood" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="hfReligion" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="hfStatus" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="hfRType" runat="server" ClientIDMode="Static" />
        <div class="bg-slate-50/70 border border-slate-200 rounded-xl p-4">
            <div id="filterGrid" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-x-4 gap-y-3">
                <div data-dd="branch"></div>
                <div data-dd="category"></div>
                <div data-dd="dept"></div>
                <div data-dd="section"></div>
                <div data-dd="subsec"></div>
                <div data-dd="floor"></div>
                <div data-dd="desig"></div>
                <div data-dd="level"></div>
                <div data-dd="blood"></div>
                <div data-dd="religion"></div>
                <div data-dd="status"></div>
                <div><label class="lbl sm">From Date</label>
                    <div class="dt-wrap"><asp:TextBox ID="txtFromDate" runat="server" ClientIDMode="Static" CssClass="fld date" placeholder="Pick a date" autocomplete="off" onfocus="this.type='date'; try{this.showPicker()}catch(e){}" onblur="if(!this.value)this.type='text'" /><i class="fa-regular fa-calendar"></i></div></div>
                <div><label class="lbl sm">Till Date</label>
                    <div class="dt-wrap"><asp:TextBox ID="txtTillDate" runat="server" ClientIDMode="Static" CssClass="fld date" placeholder="Pick a date" autocomplete="off" onfocus="this.type='date'; try{this.showPicker()}catch(e){}" onblur="if(!this.value)this.type='text'" /><i class="fa-regular fa-calendar"></i></div></div>
                <div data-dd="rtype"></div>
                <div><label class="lbl">Multi ID No</label>
                    <asp:TextBox ID="txtMultiId" runat="server" ClientIDMode="Static" CssClass="fld" placeholder="e.g. EMP-1001, EMP-1002…" autocomplete="off" style="cursor:text" /></div>
            </div>
        </div>
        <div class="flex justify-end items-center gap-2 mt-3">
            <asp:LinkButton ID="btnShow" runat="server" ClientIDMode="Static" OnClick="btnShow_Click" CssClass="h-9 px-4 rounded-lg border border-slate-300 bg-white hover:bg-slate-50 text-slate-700 text-sm font-medium flex items-center gap-2 transition">
                <i class="fa-regular fa-eye text-xs"></i><span>Show</span>
            </asp:LinkButton>
            <asp:LinkButton ID="btnReport" runat="server" ClientIDMode="Static" OnClick="btnReport_Click" CssClass="h-9 px-5 rounded-lg bg-blue-600 hover:bg-blue-700 text-white text-sm font-medium flex items-center gap-2 shadow-sm transition">
                <i class="fa-solid fa-magnifying-glass text-xs"></i><span>Report View</span>
            </asp:LinkButton>
            <asp:LinkButton ID="btnClear" runat="server" ClientIDMode="Static" OnClick="btnClear_Click" CssClass="h-9 px-4 rounded-lg border border-slate-300 bg-white hover:bg-slate-50 text-slate-700 text-sm font-medium flex items-center gap-2 transition">
                <i class="fa-solid fa-eraser text-xs"></i><span>Clear</span>
            </asp:LinkButton>
        </div>
    </section>

    <!-- Results -->
    <div class="flex-1 flex flex-col min-h-0 overflow-hidden">
        <!-- Right Main Content Area: Data Table & Report Preview -->
        <main class="flex-1 flex flex-col min-h-0 bg-slate-100 overflow-hidden relative">
            
            <!-- Toolbar / Summary Header for Results -->
            <div class="bg-white border-b border-slate-200 px-6 py-4 flex flex-wrap items-center justify-between gap-4 shrink-0 shadow-2xs">
                <div>
                    <div class="flex items-center space-x-2">
                        <h2 class="text-base font-bold text-slate-800"><asp:Label ID="lblReportTitle" runat="server" Text="Active Employee List" /></h2>
                        <asp:Label ID="lblCount" runat="server" CssClass="bg-indigo-50 text-indigo-700 text-xs font-semibold px-2.5 py-0.5 rounded-full border border-indigo-100" Text="0 Records" />
                    </div>
                    <p class="text-xs text-slate-500 mt-0.5">Showing results generated based on selected HRM criteria.</p>
                </div>
                <div class="flex items-center space-x-2">
                    <div class="relative">
                        <input type="text" id="tableSearch" onkeyup="searchTable()" onkeydown="if(event.key==='Enter')return false;" placeholder="Quick filter table..." class="bg-slate-50 border border-slate-300 rounded-lg pl-8 pr-3 py-1.5 text-xs text-slate-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 w-48 sm:w-64">
                        <i class="fa-solid fa-search absolute left-2.5 top-2 text-slate-400 text-xs"></i>
                    </div>
                    <button type="button" onclick="exportData('excel')" title="Export to Excel" class="bg-white border border-slate-300 hover:bg-slate-50 text-slate-700 p-1.5 rounded-lg text-xs font-medium shadow-2xs transition flex items-center space-x-1 px-3">
                        <i class="fa-solid fa-file-excel text-emerald-600"></i>
                        <span class="hidden sm:inline">Excel</span>
                    </button>
                    <button type="button" onclick="exportData('pdf')" title="Export to PDF" class="bg-white border border-slate-300 hover:bg-slate-50 text-slate-700 p-1.5 rounded-lg text-xs font-medium shadow-2xs transition flex items-center space-x-1 px-3">
                        <i class="fa-solid fa-file-pdf text-rose-600"></i>
                        <span class="hidden sm:inline">PDF</span>
                    </button>
                    <button type="button" onclick="printReport()" title="Print Report" class="bg-white border border-slate-300 hover:bg-slate-50 text-slate-700 p-1.5 rounded-lg text-xs font-medium shadow-2xs transition">
                        <i class="fa-solid fa-print"></i>
                    </button>
                </div>
            </div>

            <!-- Data Table Container -->
            <div class="flex-1 p-6 overflow-auto">
                <div class="bg-white border border-slate-200 rounded-xl shadow-sm overflow-hidden flex flex-col h-full">
                    <div class="overflow-x-auto flex-1">
                        <table id="reportTable" class="w-full text-left border-collapse">
                            <thead>
                                <tr class="bg-slate-50 border-b border-slate-200 text-xs font-semibold text-slate-600 uppercase tracking-wider sticky top-0 z-10">
                                    <th class="py-3.5 px-4 w-12 text-center">
                                        <input type="checkbox" id="selectAllRows" onchange="toggleAllRowCheckboxes(this)" class="rounded text-indigo-600 focus:ring-indigo-500 w-4 h-4">
                                    </th>
                                    <th class="py-3.5 px-4 font-semibold">ID No</th>
                                    <th class="py-3.5 px-4 font-semibold">Name</th>
                                    <th class="py-3.5 px-4 font-semibold">Designation</th>
                                    <th class="py-3.5 px-4 font-semibold">Department</th>
                                    <th class="py-3.5 px-4 font-semibold">Branch</th>
                                    <th class="py-3.5 px-4 font-semibold">Status</th>
                                </tr>
                            </thead>
                            <tbody id="tableBody" class="divide-y divide-slate-100 text-sm text-slate-700 bg-white">
                                <asp:Repeater ID="rptEmployees" runat="server">
                                    <ItemTemplate>
                                        <tr class="hover:bg-slate-50/80 transition-colors">
                                            <td class="py-3 px-4 text-center"><input type="checkbox" class="row-checkbox rounded text-indigo-600 focus:ring-indigo-500 w-4 h-4" value='<%# Server.HtmlEncode(Convert.ToString(Eval("Id"))) %>'></td>
                                            <td class="py-3 px-4 font-semibold text-slate-900 text-xs"><%# Server.HtmlEncode(Convert.ToString(Eval("Id"))) %></td>
                                            <td class="py-3 px-4 font-medium text-slate-800 text-xs"><%# Server.HtmlEncode(Convert.ToString(Eval("Name"))) %></td>
                                            <td class="py-3 px-4 text-slate-600 text-xs"><%# Server.HtmlEncode(Convert.ToString(Eval("Designation"))) %></td>
                                            <td class="py-3 px-4 text-slate-600 text-xs"><%# Server.HtmlEncode(Convert.ToString(Eval("Department"))) %></td>
                                            <td class="py-3 px-4 text-slate-600 text-xs"><%# Server.HtmlEncode(Convert.ToString(Eval("Branch"))) %></td>
                                            <td class="py-3 px-4"><span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-medium bg-emerald-50 text-emerald-700 border border-emerald-200"><%# Server.HtmlEncode(Convert.ToString(Eval("Status"))) %></span></td>
                                        </tr>
                                    </ItemTemplate>
                                </asp:Repeater>
                                <tr id="trEmpty" runat="server" visible="false"><td colspan="7" class="text-center py-8 text-slate-400 text-xs">No matching records found for the selected criteria.</td></tr>
                            </tbody>
                        </table>
                    </div>

                    <!-- Table Footer / Pagination -->
                    <div class="bg-slate-50 border-t border-slate-200 px-6 py-3 flex items-center justify-between text-xs text-slate-500 shrink-0">
                        <div><asp:Literal ID="litPaging" runat="server" /></div>
                        <div class="flex items-center space-x-2">
                            <button type="button" class="px-3 py-1 rounded border border-slate-300 bg-white text-slate-400 cursor-not-allowed">Previous</button>
                            <button type="button" class="px-3 py-1 rounded bg-indigo-600 text-white font-medium">1</button>
                            <button type="button" class="px-3 py-1 rounded border border-slate-300 bg-white text-slate-600 hover:bg-slate-100 transition">Next</button>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <!-- Notification Toast Container -->
    <div id="toastContainer" class="fixed bottom-5 right-5 z-50 flex flex-col space-y-2 pointer-events-none"></div>

</form>
</body>
</html>
