<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LeftyLetterIssue.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.EmployeeLifecycle.LeftyLetterIssue" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lefty Letter Issue</title>
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

        /* ---- Filter fields (select / multi-select look) ---- */
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
        select.fld{display:block;cursor:pointer;color:#1e293b;padding:0 6px}
        input.fld::placeholder{color:#a0a7b5}
        input.fld.date{background:#f3f4f7;color:#334155}
        .dt-wrap{position:relative}
        .dt-wrap i{position:absolute;right:10px;top:10px;color:#a0a7b5;font-size:12px;pointer-events:none}

        /* ListBox (multiple): JS সফল হলে লুকানো হয়; JS ব্যর্থ হলে এটিই কাজ করে (Ctrl+Click) */
        select.ms-src{width:100%;min-height:32px;font-size:13px;border:1px solid #d9dce5;border-radius:6px}

        .panel{position:absolute;left:0;top:calc(100% + 4px);min-width:100%;width:260px;background:#fff;border:1px solid #e2e8f0;
               border-radius:8px;box-shadow:0 10px 25px -5px rgba(15,23,42,.18),0 4px 10px -6px rgba(15,23,42,.12);z-index:60}
        .panel .ph{display:flex;align-items:center;justify-content:space-between;padding:8px 10px;font-size:12px;color:#64748b;border-bottom:1px solid #eef0f4}
        .panel .ph button{color:#ef4444;font-size:12px;background:none;border:0;cursor:pointer}
        .panel .ph button:hover{text-decoration:underline}
        .panel .ps{display:flex;align-items:center;gap:8px;padding:8px 10px;border-bottom:1px solid #eef0f4}
        .panel .ps i{color:#94a3b8;font-size:13px}
        .panel .ps input{flex:1;border:0;outline:0;font-size:13px;color:#334155;background:transparent;min-width:0}
        .panel .pl{max-height:224px;overflow-y:auto;padding:6px}
        .panel .it{display:flex;align-items:center;gap:10px;padding:7px 8px;border-radius:6px;font-size:13px;color:#1e293b;cursor:pointer}
        .panel .it:hover{background:#f1f5f9}
        .panel .empty{padding:14px 8px;font-size:12px;color:#94a3b8;text-align:center}
        .cb{width:16px;height:16px;border-radius:4px;border:1.5px solid #cbd5e1;background:#fff;display:inline-flex;align-items:center;justify-content:center;flex-shrink:0;color:#fff;font-size:9px}
        .cb.on{background:#2563eb;border-color:#2563eb}
        .lbl{display:block;font-size:13px;color:#334155;margin-bottom:6px}
        .lbl.sm{font-size:11.5px;color:#64748b}

        /* ---- Buttons ---- */
        .btn{display:inline-flex;align-items:center;justify-content:center;gap:6px;height:34px;padding:0 14px;border:1px solid #cbd5e1;
             border-radius:8px;background:#fff;color:#334155;font-size:13px;font-weight:500;transition:background .15s, opacity .15s;white-space:nowrap;text-decoration:none}
        .btn:hover{background:#f8fafc}
        .btn-primary{background:#2563eb;border-color:#2563eb;color:#fff;box-shadow:0 1px 2px rgba(15,23,42,.08)}
        .btn-primary:hover{background:#1d4ed8}
        .btn-sm{height:30px;padding:0 10px;font-size:12px}
        .lock{opacity:.4;pointer-events:none}

        /* ---- Checkbox (asp:CheckBox) ---- */
        .chk{display:inline-flex;align-items:center;gap:8px;font-size:13px;color:#334155;white-space:nowrap}
        .chk input{width:16px;height:16px;accent-color:#2563eb;cursor:pointer}
        .chk label{cursor:pointer}

        .card-title{font-size:12px;font-weight:700;letter-spacing:.04em;text-transform:uppercase;color:#64748b;margin-bottom:10px}
    </style>
</head>
<body class="bg-slate-100 text-slate-800 antialiased min-h-screen">
<form id="form1" runat="server" class="flex flex-col min-h-screen" autocomplete="off">
    <asp:HiddenField ID="hfSelIds" runat="server" ClientIDMode="Static" />

    <!-- ================= Page header ================= -->
    <header class="bg-white border-b border-slate-200 px-6 py-3 flex items-center gap-3">
        <div class="w-9 h-9 rounded-lg bg-blue-50 text-blue-600 flex items-center justify-center"><i class="fa-solid fa-envelope-open-text"></i></div>
        <div>
            <h1 class="text-lg font-bold text-slate-800 leading-tight">Lefty Letter Issue</h1>
            <p class="text-xs text-slate-500">Auto Lefty Letter Process</p>
        </div>
    </header>

    <!-- ================= Filters (সেপারেশন পেজের মতো) ================= -->
    <section class="bg-white border-b border-slate-200 px-6 py-4 relative z-30">
        <div class="bg-slate-50/70 border border-slate-200 rounded-xl p-4">
            <div id="filterGrid" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-x-4 gap-y-3">
                <%-- নিচের ৮টি ফিল্টার মাল্টিপল সিলেক্ট (ListBox) --%>
                <div><label class="lbl">Branch</label><asp:ListBox ID="ddBranch" runat="server" ClientIDMode="Static" SelectionMode="Multiple" CssClass="ms-src" /></div>
                <div><label class="lbl">Category</label><asp:ListBox ID="ddCategory" runat="server" ClientIDMode="Static" SelectionMode="Multiple" CssClass="ms-src" /></div>
                <div><label class="lbl">Department</label><asp:ListBox ID="ddDept" runat="server" ClientIDMode="Static" SelectionMode="Multiple" CssClass="ms-src" /></div>
                <div><label class="lbl">Section</label><asp:ListBox ID="ddSection" runat="server" ClientIDMode="Static" SelectionMode="Multiple" CssClass="ms-src" /></div>
                <div><label class="lbl">Sub Section</label><asp:ListBox ID="ddSubSec" runat="server" ClientIDMode="Static" SelectionMode="Multiple" CssClass="ms-src" /></div>
                <div><label class="lbl">Floor</label><asp:ListBox ID="ddFloor" runat="server" ClientIDMode="Static" SelectionMode="Multiple" CssClass="ms-src" /></div>
                <div><label class="lbl">Designation</label><asp:ListBox ID="ddDesig" runat="server" ClientIDMode="Static" SelectionMode="Multiple" CssClass="ms-src" /></div>
                <div><label class="lbl">Designation Level</label><asp:ListBox ID="ddLevel" runat="server" ClientIDMode="Static" SelectionMode="Multiple" CssClass="ms-src" /></div>
                <div><label class="lbl">Employee Status</label><asp:DropDownList ID="ddStatus" runat="server" ClientIDMode="Static" CssClass="fld" /></div>
                <div><label class="lbl">Multi ID No</label><asp:TextBox ID="txtMultiId" runat="server" ClientIDMode="Static" CssClass="fld" placeholder="e.g. 1001, 1002…" autocomplete="off" style="cursor:text" /></div>

                <div><label class="lbl sm">From Date</label>
                    <div class="dt-wrap"><asp:TextBox ID="txtFromDate" runat="server" ClientIDMode="Static" CssClass="fld date" placeholder="Pick a date" autocomplete="off" onfocus="this.type='date'; try{this.showPicker()}catch(e){}" onblur="if(!this.value)this.type='text'" /><i class="fa-regular fa-calendar"></i></div></div>
                <div><label class="lbl sm">Till Date</label>
                    <div class="dt-wrap"><asp:TextBox ID="txtTillDate" runat="server" ClientIDMode="Static" CssClass="fld date" placeholder="Pick a date" autocomplete="off" onfocus="this.type='date'; try{this.showPicker()}catch(e){}" onblur="if(!this.value)this.type='text'" /><i class="fa-regular fa-calendar"></i></div></div>
            </div>
        </div>

        <%-- ডেক্সটপের: Search / Search New letter Employee / Select All / Clear Selected --%>
        <div class="flex flex-wrap justify-end items-center gap-2 mt-3">
            <asp:LinkButton ID="btnSearchId" runat="server" ClientIDMode="Static" OnClick="btnSearchId_Click" CssClass="btn">
                <i class="fa-solid fa-magnifying-glass text-xs"></i><span>Search by ID No</span>
            </asp:LinkButton>
            <asp:LinkButton ID="btnSearchNew" runat="server" ClientIDMode="Static" OnClick="btnSearchNew_Click" CssClass="btn btn-primary">
                <i class="fa-solid fa-user-plus text-xs"></i><span>Search New Letter Employee</span>
            </asp:LinkButton>
            <button type="button" class="btn" onclick="setAllRows(true)"><i class="fa-regular fa-square-check text-xs"></i><span>Select All</span></button>
            <button type="button" class="btn" onclick="setAllRows(false)"><i class="fa-regular fa-square text-xs"></i><span>Clear Selected</span></button>
            <asp:LinkButton ID="btnClear" runat="server" ClientIDMode="Static" OnClick="btnClear_Click" CssClass="btn">
                <i class="fa-solid fa-eraser text-xs"></i><span>Clear</span>
            </asp:LinkButton>
        </div>
    </section>

    <!-- ================= Letter actions (ডেক্সটপের বাকি অংশ) ================= -->
    <section class="bg-white border-b border-slate-200 px-6 py-4">
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-4">

            <!-- Letter Process -->
            <div class="border border-slate-200 rounded-xl p-4 bg-slate-50/70">
                <div class="card-title"><i class="fa-solid fa-gears mr-1"></i> Letter Process</div>
                <div class="mb-3"><asp:CheckBox ID="chkManual" runat="server" ClientIDMode="Static" Text="Letter Date Manual" CssClass="chk" /></div>

                <div class="space-y-2">
                    <div class="flex items-center gap-2 flex-wrap">
                        <div class="w-20"><asp:CheckBox ID="chk1st" runat="server" ClientIDMode="Static" Text="1st Letter" CssClass="chk" /></div>
                        <asp:LinkButton ID="btnProc1" runat="server" ClientIDMode="Static" CommandArgument="1" OnCommand="btnProc_Command" OnClientClick="return collectIds();" CssClass="btn btn-sm lock"><span>1st Letter Process</span></asp:LinkButton>
                        <div id="wrapDate1" class="dt-wrap w-40" style="display:none"><asp:TextBox ID="txtDate1" runat="server" ClientIDMode="Static" CssClass="fld date" placeholder="Pick a date" autocomplete="off" onfocus="this.type='date'; try{this.showPicker()}catch(e){}" onblur="if(!this.value)this.type='text'" /><i class="fa-regular fa-calendar"></i></div>
                    </div>
                    <div class="flex items-center gap-2 flex-wrap">
                        <div class="w-20"><asp:CheckBox ID="chk2nd" runat="server" ClientIDMode="Static" Text="2nd Letter" CssClass="chk" /></div>
                        <asp:LinkButton ID="btnProc2" runat="server" ClientIDMode="Static" CommandArgument="2" OnCommand="btnProc_Command" OnClientClick="return collectIds();" CssClass="btn btn-sm lock"><span>2nd Letter Process</span></asp:LinkButton>
                        <div id="wrapDate2" class="dt-wrap w-40" style="display:none"><asp:TextBox ID="txtDate2" runat="server" ClientIDMode="Static" CssClass="fld date" placeholder="Pick a date" autocomplete="off" onfocus="this.type='date'; try{this.showPicker()}catch(e){}" onblur="if(!this.value)this.type='text'" /><i class="fa-regular fa-calendar"></i></div>
                    </div>
                    <div class="flex items-center gap-2 flex-wrap">
                        <div class="w-20"><asp:CheckBox ID="chk3rd" runat="server" ClientIDMode="Static" Text="3rd Letter" CssClass="chk" /></div>
                        <asp:LinkButton ID="btnProc3" runat="server" ClientIDMode="Static" CommandArgument="3" OnCommand="btnProc_Command" OnClientClick="return collectIds();" CssClass="btn btn-sm lock"><span>3rd Letter Process</span></asp:LinkButton>
                        <div id="wrapDate3" class="dt-wrap w-40" style="display:none"><asp:TextBox ID="txtDate3" runat="server" ClientIDMode="Static" CssClass="fld date" placeholder="Pick a date" autocomplete="off" onfocus="this.type='date'; try{this.showPicker()}catch(e){}" onblur="if(!this.value)this.type='text'" /><i class="fa-regular fa-calendar"></i></div>
                    </div>
                </div>
                <p class="text-[11px] text-slate-400 mt-3">Letter চেকবক্সে টিক দিলে সংশ্লিষ্ট Process বাটন চালু হবে। টিক দেওয়া কর্মচারীদের জন্য Process হবে।</p>
            </div>

            <!-- Search by Letter Date -->
            <div class="border border-slate-200 rounded-xl p-4 bg-slate-50/70">
                <div class="card-title"><i class="fa-solid fa-calendar-days mr-1"></i> Search by Letter Date</div>
                <div class="mb-3"><asp:CheckBox ID="chkMulti" runat="server" ClientIDMode="Static" Text="Multi Date" CssClass="chk" /></div>
                <div class="grid grid-cols-2 gap-3 mb-3">
                    <div><label class="lbl sm">From</label>
                        <div class="dt-wrap"><asp:TextBox ID="txtMultiFrom" runat="server" ClientIDMode="Static" CssClass="fld date" placeholder="Pick a date" autocomplete="off" onfocus="this.type='date'; try{this.showPicker()}catch(e){}" onblur="if(!this.value)this.type='text'" /><i class="fa-regular fa-calendar"></i></div></div>
                    <div id="wrapMultiTill" style="display:none"><label class="lbl sm">Till</label>
                        <div class="dt-wrap"><asp:TextBox ID="txtMultiTill" runat="server" ClientIDMode="Static" CssClass="fld date" placeholder="Pick a date" autocomplete="off" onfocus="this.type='date'; try{this.showPicker()}catch(e){}" onblur="if(!this.value)this.type='text'" /><i class="fa-regular fa-calendar"></i></div></div>
                </div>
                <div class="flex flex-wrap gap-2">
                    <asp:LinkButton ID="btnS1" runat="server" CommandArgument="1" OnCommand="btnSearchLetter_Command" CssClass="btn btn-sm"><i class="fa-solid fa-magnifying-glass text-[10px]"></i><span>1st Letter Search</span></asp:LinkButton>
                    <asp:LinkButton ID="btnS2" runat="server" CommandArgument="2" OnCommand="btnSearchLetter_Command" CssClass="btn btn-sm"><i class="fa-solid fa-magnifying-glass text-[10px]"></i><span>2nd Letter Search</span></asp:LinkButton>
                    <asp:LinkButton ID="btnS3" runat="server" CommandArgument="3" OnCommand="btnSearchLetter_Command" CssClass="btn btn-sm"><i class="fa-solid fa-magnifying-glass text-[10px]"></i><span>3rd Letter Search</span></asp:LinkButton>
                </div>
                <p class="text-[11px] text-slate-400 mt-3">Multi Date বন্ধ থাকলে শুধু From তারিখের চিঠি; চালু থাকলে From–Till সময়ের মধ্যে খুঁজবে।</p>
            </div>

            <!-- View / Print -->
            <div class="border border-slate-200 rounded-xl p-4 bg-slate-50/70">
                <div class="card-title"><i class="fa-solid fa-print mr-1"></i> Letter View</div>
                <div class="grid grid-cols-3 gap-2">
                    <asp:LinkButton ID="btnV1" runat="server" OnClick="btnV1_Click" OnClientClick="return viewClick('Fast_Latter');" CssClass="btn btn-sm"><span>1st Letter View</span></asp:LinkButton>
                    <asp:LinkButton ID="btnV2" runat="server" CommandArgument="Secend_Latter|0" OnCommand="btnView_Command" OnClientClick="return viewClick('Secend_Latter');" CssClass="btn btn-sm"><span>2nd Letter View</span></asp:LinkButton>
                    <asp:LinkButton ID="btnV3" runat="server" CommandArgument="Thard_Latter|0" OnCommand="btnView_Command" OnClientClick="return viewClick('Thard_Latter');" CssClass="btn btn-sm"><span>3rd Letter View</span></asp:LinkButton>
                    <asp:LinkButton ID="btnVEnvP" runat="server" CommandArgument="Envlap2|0" OnCommand="btnView_Command" OnClientClick="return viewClick('Envlap2');" CssClass="btn btn-sm"><span>Present Envelope</span></asp:LinkButton>
                    <asp:LinkButton ID="btnVEnv" runat="server" CommandArgument="Envlap|-1" OnCommand="btnView_Command" OnClientClick="return viewClick('Envlap');" CssClass="btn btn-sm"><span>Parmanent Envelope</span></asp:LinkButton>
                    <asp:LinkButton ID="btnVProb" runat="server" CommandArgument="Probation_Time_Latter|1" OnCommand="btnView_Command" OnClientClick="return viewClick('Probation_Time_Latter');" CssClass="btn btn-sm"><span>Probation Period</span></asp:LinkButton>
                </div>
                <div class="mt-2">
                    <asp:LinkButton ID="btnVAll" runat="server" CommandArgument="Fast_Secend_Third_Latter|0" OnCommand="btnView_Command" OnClientClick="return viewClick('Fast_Secend_Third_Latter');" CssClass="btn btn-primary w-full"><i class="fa-solid fa-file-lines text-xs"></i><span>1st, 2nd &amp; 3rd Letter View</span></asp:LinkButton>
                </div>
                <p class="text-[11px] text-slate-400 mt-3">টিক দেওয়া কর্মচারীদের রিপোর্ট নতুন ট্যাবে খুলবে।</p>
            </div>
        </div>
    </section>

    <!-- ================= Results ================= -->
    <main class="flex-1 flex flex-col bg-slate-100">

        <div class="bg-white border-b border-slate-200 px-6 py-4 flex flex-wrap items-center justify-between gap-4">
            <div>
                <div class="flex items-center space-x-2">
                    <h2 class="text-base font-bold text-slate-800"><asp:Label ID="lblReportTitle" runat="server" Text="Lefty Employee List" /></h2>
                    <asp:Label ID="lblCount" runat="server" CssClass="bg-indigo-50 text-indigo-700 text-xs font-semibold px-2.5 py-0.5 rounded-full border border-indigo-100" Text="0 Records" />
                </div>
                <p class="text-xs text-slate-500 mt-0.5">Showing results generated based on selected criteria.</p>
            </div>
            <div class="flex items-center space-x-2">
                <div class="relative">
                    <input type="text" id="tableSearch" onkeyup="searchTable()" onkeydown="if(event.key==='Enter')return false;" placeholder="Quick filter table..." class="bg-slate-50 border border-slate-300 rounded-lg pl-8 pr-3 py-1.5 text-xs text-slate-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 w-48 sm:w-64">
                    <i class="fa-solid fa-search absolute left-2.5 top-2 text-slate-400 text-xs"></i>
                </div>
                <button type="button" onclick="window.print()" title="Print" class="bg-white border border-slate-300 hover:bg-slate-50 text-slate-700 p-1.5 rounded-lg text-xs font-medium transition px-3">
                    <i class="fa-solid fa-print"></i>
                </button>
            </div>
        </div>

        <div class="flex-1 p-6">
            <div class="bg-white border border-slate-200 rounded-xl shadow-sm overflow-hidden flex flex-col">
                <div class="overflow-auto" style="max-height:460px">
                    <table id="reportTable" class="w-full text-left border-collapse">
                        <thead>
                            <tr class="bg-slate-50 border-b border-slate-200 text-xs font-semibold text-slate-600 uppercase tracking-wider sticky top-0 z-10">
                                <th class="py-3.5 px-4 w-12 text-center bg-slate-50">
                                    <input type="checkbox" id="selectAllRows" onchange="toggleAllRowCheckboxes(this)" class="rounded w-4 h-4" style="accent-color:#4f46e5">
                                </th>
                                <th class="py-3.5 px-4 font-semibold bg-slate-50">ID No</th>
                                <th class="py-3.5 px-4 font-semibold bg-slate-50">Name</th>
                                <th class="py-3.5 px-4 font-semibold bg-slate-50">Designation</th>
                                <th class="py-3.5 px-4 font-semibold bg-slate-50">Absent Date</th>
                                <th class="py-3.5 px-4 font-semibold bg-slate-50">1st Letter</th>
                                <th class="py-3.5 px-4 font-semibold bg-slate-50">2nd Letter</th>
                                <th class="py-3.5 px-4 font-semibold bg-slate-50">3rd Letter</th>
                            </tr>
                        </thead>
                        <tbody id="tableBody" class="divide-y divide-slate-100 text-sm text-slate-700 bg-white">
                            <asp:Repeater ID="rptEmployees" runat="server">
                                <ItemTemplate>
                                    <tr class="hover:bg-slate-50/80 transition-colors">
                                        <%-- name="selId" ও value অবশ্যই থাকতে হবে: ব্রাউজার টিক দেওয়া ID সরাসরি সার্ভারে পাঠায় --%>
                                        <td class="py-3 px-4 text-center"><input type="checkbox" name="selId" class="row-checkbox rounded w-4 h-4" style="accent-color:#4f46e5" value='<%# Server.HtmlEncode(Convert.ToString(Eval("Id"))) %>' data-id='<%# Server.HtmlEncode(Convert.ToString(Eval("Id"))) %>'></td>
                                        <td class="py-3 px-4 font-semibold text-slate-900 text-xs"><%# Server.HtmlEncode(Convert.ToString(Eval("Id"))) %></td>
                                        <td class="py-3 px-4 font-medium text-slate-800 text-xs"><%# Server.HtmlEncode(Convert.ToString(Eval("Name"))) %></td>
                                        <td class="py-3 px-4 text-slate-600 text-xs"><%# Server.HtmlEncode(Convert.ToString(Eval("Designation"))) %></td>
                                        <td class="py-3 px-4 text-slate-600 text-xs"><%# Server.HtmlEncode(Convert.ToString(Eval("AbsentDate"))) %></td>
                                        <td class="py-3 px-4 text-slate-600 text-xs"><%# Server.HtmlEncode(Convert.ToString(Eval("FirstDate"))) %></td>
                                        <td class="py-3 px-4 text-slate-600 text-xs"><%# Server.HtmlEncode(Convert.ToString(Eval("SecondDate"))) %></td>
                                        <td class="py-3 px-4 text-slate-600 text-xs"><%# Server.HtmlEncode(Convert.ToString(Eval("ThirdDate"))) %></td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                            <tr id="trEmpty" runat="server" visible="false"><td colspan="8" class="text-center py-8 text-slate-400 text-xs">No matching records found for the selected criteria.</td></tr>
                        </tbody>
                    </table>
                </div>
                <div class="bg-slate-50 border-t border-slate-200 px-6 py-3 text-xs text-slate-500">
                    <asp:Literal ID="litPaging" runat="server" />
                </div>
            </div>
        </div>
    </main>

    <!-- Notification Toast Container -->
    <div id="toastContainer" class="fixed bottom-5 right-5 z-50 flex flex-col space-y-2 pointer-events-none"></div>

</form>

<script>
// @ts-nocheck
const esc = s => String(s).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
const $ = id => document.getElementById(id);

// টিক দেওয়া ID গুলো hfSelIds এ জমা (সার্ভার name="selId" থেকেও পড়ে, এটি অতিরিক্ত নিরাপত্তা)
function collectIds() {
    const ids = [];
    document.querySelectorAll('.row-checkbox:checked').forEach(c => {
        const id = c.getAttribute('data-id') || c.value;
        if (id) ids.push(id);
    });
    const hf = $('hfSelIds');
    if (hf) hf.value = ids.join(',');
    return true;
}

// Letter View: কর্মচারী নির্বাচন বাধ্যতামূলক। রিপোর্ট পেজ থাকলে নতুন ট্যাবে খোলে (এই পেজ অপরিবর্তিত থাকে)
// যে রিপোর্টগুলোর ওয়েব পেজ তৈরি হয়েছে, শুধু সেগুলো এখানে যোগ করুন
const READY_REPORTS = ['Fast_Latter', 'Secend_Latter', 'Thard_Latter', 'Probation_Time_Latter', 'Envlap2', 'Envlap', 'Fast_Secend_Third_Latter'];

function viewClick(report) {
    if (READY_REPORTS.indexOf(report) < 0) {
        showNotification('এই রিপোর্টের ওয়েব পেজ এখনও যোগ করা হয়নি।');
        return false;
    }
    collectIds();
    if (!$('hfSelIds').value) {
        showNotification('কমপক্ষে একজন কর্মচারী নির্বাচন করুন।');
        return false;
    }
    const f = document.forms[0];
    f.target = '_blank';                                   // রিপোর্ট নতুন (পাশের) ট্যাবে
    setTimeout(function () { f.target = ''; }, 1000);      // এই পেজের অন্য বাটনের জন্য আগের অবস্থা
    return true;
}

// ---------- Select All / Clear Selected ----------
function setAllRows(state) {
    document.querySelectorAll('.row-checkbox').forEach(cb => cb.checked = state);
    const h = $('selectAllRows'); if (h) h.checked = state;
}
function toggleAllRowCheckboxes(source) { setAllRows(source.checked); }

// ---------- Letter Process UI (1st / 2nd / 3rd) ----------
const LETTERS = [['chk1st', 'btnProc1', 'wrapDate1'], ['chk2nd', 'btnProc2', 'wrapDate2'], ['chk3rd', 'btnProc3', 'wrapDate3']];

function updateLetterUI() {
    const manual = $('chkManual').checked;
    LETTERS.forEach(function (x) {
        $(x[1]).classList.toggle('lock', !$(x[0]).checked);   // টিক না দিলে Process বাটন বন্ধ
        $(x[2]).style.display = manual ? '' : 'none';         // Manual হলে তারিখ ঘর দেখাও
    });
    $('wrapMultiTill').style.display = $('chkMulti').checked ? '' : 'none';
}
function onLetterCheck(src) {
    if (src.checked) LETTERS.forEach(function (x) { if (x[0] !== src.id) $(x[0]).checked = false; });
    updateLetterUI();
}

// ---------- Multi-select ড্রপডাউন (ListBox → চেকবক্স প্যানেল) ----------
function initMulti() {
    document.querySelectorAll('select.ms-src').forEach(function (sel) {
        try {
            var wrap = document.createElement('div');
            wrap.style.position = 'relative';
            sel.parentNode.insertBefore(wrap, sel);
            wrap.appendChild(sel);

            var fld = document.createElement('div');
            fld.className = 'fld'; fld.tabIndex = 0;
            fld.innerHTML = '<span class="txt"></span><i class="fa-solid fa-xmark clr" title="Clear"></i><i class="fa-solid fa-chevron-down chev"></i>';
            wrap.appendChild(fld);

            var panel = document.createElement('div');
            panel.className = 'panel'; panel.style.display = 'none';
            panel.innerHTML =
                '<div class="ph"><span class="cnt"></span><button type="button" class="clrAll">Clear all</button></div>' +
                '<div class="ps"><i class="fa-solid fa-search"></i><input type="text" placeholder="Search..."></div>' +
                '<div class="pl"></div>';
            wrap.appendChild(panel);

            var txt = fld.querySelector('.txt'), list = panel.querySelector('.pl'),
                cnt = panel.querySelector('.cnt'), q = panel.querySelector('input');

            function render() {
                var term = q.value.toLowerCase(), html = '', picked = [];
                for (var i = 0; i < sel.options.length; i++) {
                    var o = sel.options[i];
                    if (o.selected) picked.push(o.text);
                    if (term && o.text.toLowerCase().indexOf(term) < 0) continue;
                    html += '<div class="it" data-i="' + i + '"><span class="cb' + (o.selected ? ' on' : '') + '">' +
                        (o.selected ? '<i class="fa-solid fa-check"></i>' : '') + '</span><span>' + esc(o.text) + '</span></div>';
                }
                list.innerHTML = html || '<div class="empty">No options</div>';
                cnt.textContent = picked.length + ' selected';
                txt.textContent = picked.length === 0 ? '-- All --' : (picked.length <= 2 ? picked.join(', ') : picked.length + ' selected');
                fld.classList.toggle('has', picked.length > 0);
            }

            function clearAll() {
                for (var i = 0; i < sel.options.length; i++) sel.options[i].selected = false;
                render();
            }

            list.addEventListener('click', function (e) {
                var it = e.target.closest('.it'); if (!it) return;
                var o = sel.options[+it.getAttribute('data-i')];
                o.selected = !o.selected;
                render();
            });
            panel.querySelector('.clrAll').addEventListener('click', clearAll);
            fld.querySelector('.clr').addEventListener('click', function (e) { e.stopPropagation(); clearAll(); });
            fld.addEventListener('click', function () {
                var open = panel.style.display === 'none';
                document.querySelectorAll('.panel').forEach(function (p) { p.style.display = 'none'; });
                document.querySelectorAll('.fld.open').forEach(function (f) { f.classList.remove('open'); });
                panel.style.display = open ? 'block' : 'none';
                fld.classList.toggle('open', open);
                if (open) { q.value = ''; render(); q.focus(); }
            });
            panel.addEventListener('click', function (e) { e.stopPropagation(); });
            q.addEventListener('keydown', function (e) { if (e.key === 'Enter') e.preventDefault(); });
            render();
            sel.style.display = 'none';          // আসল select লুকানো, কিন্তু সার্ভারে ঠিকই যায়
        } catch (err) { console.error('multi-select init failed for', sel.id, err); sel.style.display = ''; }
    });

    // বাইরে ক্লিক করলে প্যানেল বন্ধ
    document.addEventListener('click', function (e) {
        if (e.target.closest('.panel') || e.target.closest('.fld')) return;
        document.querySelectorAll('.panel').forEach(function (p) { p.style.display = 'none'; });
        document.querySelectorAll('.fld.open').forEach(function (f) { f.classList.remove('open'); });
    });
}

document.addEventListener('DOMContentLoaded', function () {
    try { initMulti(); } catch (err) { console.error('initMulti error:', err); }

    // তারিখ ঘরে মান থাকলে date হিসেবে দেখাও
    document.querySelectorAll('input.date').forEach(i => { if (i.value) i.type = 'date'; });

    // Letter চেকবক্স
    LETTERS.forEach(function (x) { $(x[0]).addEventListener('change', function () { onLetterCheck(this); }); });
    $('chkManual').addEventListener('change', updateLetterUI);
    $('chkMulti').addEventListener('change', updateLetterUI);
    updateLetterUI();

    // যেভাবেই ফর্ম সাবমিট হোক, আগে ID জমা হবে
    const f = document.forms[0], old = f.onsubmit;
    f.onsubmit = function () { collectIds(); return old ? old.apply(this, arguments) : true; };

    // Multi ID ঘরে Enter চাপলে ID Search চলবে
    const mi = $('txtMultiId');
    if (mi) mi.addEventListener('keydown', e => {
        if (e.key === 'Enter') {
            e.preventDefault();
            const b = $('btnSearchId');
            if (b) b.click();
        }
    });
});

// ---------- টেবিলের Quick filter ----------
function searchTable() {
    const q = $('tableSearch').value.toLowerCase();
    document.querySelectorAll('#tableBody tr').forEach(tr => {
        if (tr.id && tr.id.indexOf('trEmpty') > -1) return;
        tr.style.display = tr.textContent.toLowerCase().includes(q) ? '' : 'none';
    });
}

function showNotification(message) {
    const container = $('toastContainer');
    const toast = document.createElement('div');
    toast.className = "bg-slate-900 text-white text-xs px-4 py-2.5 rounded-xl shadow-lg pointer-events-auto flex items-center space-x-2 transition transform translate-y-2 opacity-0";
    toast.innerHTML = `<i class="fa-solid fa-circle-info text-indigo-400"></i><span>${esc(message)}</span>`;
    container.appendChild(toast);
    setTimeout(() => toast.classList.remove('translate-y-2', 'opacity-0'), 10);
    setTimeout(() => { toast.classList.add('translate-y-2', 'opacity-0'); setTimeout(() => toast.remove(), 300); }, 3000);
}
</script>
</body>
</html>
