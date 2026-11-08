<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EmployeeWiseHolidays.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.HRConfiguration.LeaveSetting.EmployeeWiseHolidays" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Employee Wise Holidays</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; }
        ::-webkit-scrollbar{width:6px;height:6px}
        ::-webkit-scrollbar-track{background:#f1f5f9}
        ::-webkit-scrollbar-thumb{background:#cbd5e1;border-radius:3px}
        ::-webkit-scrollbar-thumb:hover{background:#94a3b8}

        /* ---- Filter fields (HRMReports এর হুবহু একই) ---- */
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
        input.fld{cursor:text;color:#1e293b;user-select:text}
        select.fld{display:block;cursor:pointer;color:#1e293b;padding:0 6px}
        input.fld::placeholder{color:#a0a7b5}
        input.fld.date{background:#f3f4f7;color:#334155}
        .dt-wrap{position:relative}
        .dt-wrap i{position:absolute;right:10px;top:10px;color:#a0a7b5;font-size:12px;pointer-events:none}

        /* ListBox (multiple): JS সফল হলে লুকানো হয়; JS ব্যর্থ হলে এটিই কাজ করে (Ctrl+Click) */
        select.ms-src{width:100%;min-height:32px;font-size:13px;border:1px solid #d9dce5;border-radius:6px}

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
        tr.sel-row{background:#eff6ff !important}
    </style>
</head>
<body class="bg-slate-100 text-slate-800 antialiased h-screen flex flex-col overflow-hidden">
<form id="form1" runat="server" class="flex flex-col h-screen overflow-hidden" autocomplete="off">
    <asp:HiddenField ID="hfApplyCode" runat="server" ClientIDMode="Static" />

    <!-- ============ TOP: Filters (HRMReports এর মতো) ============ -->
    <section class="bg-white border-b border-slate-200 px-6 py-3 shrink-0 relative z-30">
        <div class="flex items-center justify-between mb-2">
            <div class="flex items-center gap-3">
                <div class="w-9 h-9 rounded-lg bg-blue-50 text-blue-600 flex items-center justify-center"><i class="fa-regular fa-calendar-check"></i></div>
                <div>
                    <h1 class="text-base font-bold text-slate-800">Employee Wise Holidays</h1>
                    <p class="text-xs text-slate-500">ফিল্টার দিয়ে কর্মচারী খুঁজুন, তারপর নিচে ছুটি অ্যাসাইন করুন।</p>
                </div>
            </div>
            <button type="button" onclick="toggleFilters()" class="h-8 px-3 rounded-lg border border-slate-300 bg-white hover:bg-slate-50 text-slate-700 text-xs font-medium flex items-center gap-2">
                <i id="fltIcon" class="fa-solid fa-chevron-up text-[10px]"></i><span id="fltText">Hide filters</span>
            </button>
        </div>

        <div id="filterBox">
            <div class="bg-slate-50/70 border border-slate-200 rounded-xl p-4">
                <div id="filterGrid" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-x-4 gap-y-3">
                    <div><label class="lbl">Branch</label><asp:ListBox ID="ddBranch" runat="server" ClientIDMode="Static" SelectionMode="Multiple" CssClass="ms-src" /></div>
                    <div><label class="lbl">Category</label><asp:ListBox ID="ddCategory" runat="server" ClientIDMode="Static" SelectionMode="Multiple" CssClass="ms-src" /></div>
                    <div><label class="lbl">Department</label><asp:ListBox ID="ddDept" runat="server" ClientIDMode="Static" SelectionMode="Multiple" CssClass="ms-src" /></div>
                    <div><label class="lbl">Section</label><asp:ListBox ID="ddSection" runat="server" ClientIDMode="Static" SelectionMode="Multiple" CssClass="ms-src" /></div>
                    <div><label class="lbl">Sub Section</label><asp:ListBox ID="ddSubSec" runat="server" ClientIDMode="Static" SelectionMode="Multiple" CssClass="ms-src" /></div>
                    <div><label class="lbl">Floor</label><asp:ListBox ID="ddFloor" runat="server" ClientIDMode="Static" SelectionMode="Multiple" CssClass="ms-src" /></div>
                    <div><label class="lbl">Designation</label><asp:ListBox ID="ddDesig" runat="server" ClientIDMode="Static" SelectionMode="Multiple" CssClass="ms-src" /></div>
                    <div><label class="lbl">Designation Level</label><asp:ListBox ID="ddLevel" runat="server" ClientIDMode="Static" SelectionMode="Multiple" CssClass="ms-src" /></div>
                    <div><label class="lbl">Blood Group</label><asp:DropDownList ID="ddBlood" runat="server" ClientIDMode="Static" CssClass="fld" /></div>
                    <div><label class="lbl">Religion</label><asp:DropDownList ID="ddReligion" runat="server" ClientIDMode="Static" CssClass="fld" /></div>
                    <div><label class="lbl">Employee Status</label><asp:DropDownList ID="ddStatus" runat="server" ClientIDMode="Static" CssClass="fld" /></div>
                    <div class="sm:col-span-2"><label class="lbl">Multi ID No</label>
                        <asp:TextBox ID="txtMultiId" runat="server" ClientIDMode="Static" CssClass="fld" placeholder="e.g. 1001, 1002, 1003…  (ID দিলে ফিল্টার বাদ যায়)" autocomplete="off" style="cursor:text" /></div>
                </div>
            </div>
            <div class="flex justify-end items-center gap-2 mt-3">
                <asp:LinkButton ID="btnShow" runat="server" ClientIDMode="Static" OnClick="btnShow_Click" CssClass="h-9 px-5 rounded-lg bg-blue-600 hover:bg-blue-700 text-white text-sm font-medium flex items-center gap-2 shadow-sm transition">
                    <i class="fa-regular fa-eye text-xs"></i><span>Show</span>
                </asp:LinkButton>
                <asp:LinkButton ID="btnClear" runat="server" ClientIDMode="Static" OnClick="btnClear_Click" CssClass="h-9 px-4 rounded-lg border border-slate-300 bg-white hover:bg-slate-50 text-slate-700 text-sm font-medium flex items-center gap-2 transition">
                    <i class="fa-solid fa-eraser text-xs"></i><span>Clear</span>
                </asp:LinkButton>
            </div>
        </div>
    </section>

    <!-- ============ BOTTOM: Entry + employees | Applied list ============ -->
    <div class="flex-1 flex min-h-0 gap-4 p-4 overflow-hidden">

        <!-- LEFT: Holiday entry + employee grid -->
        <aside class="w-full max-w-3xl shrink-0 flex flex-col min-h-0 bg-white border border-slate-200 rounded-xl shadow-sm overflow-hidden">
            <div class="p-4 bg-slate-50/70 border-b border-slate-200">
                <div class="grid grid-cols-2 lg:grid-cols-4 gap-3">
                    <div>
                        <label class="lbl sm">From Date</label>
                        <div class="dt-wrap"><asp:TextBox ID="txtFromDate" runat="server" ClientIDMode="Static" CssClass="fld date" placeholder="Pick a date" autocomplete="off" onfocus="this.type='date'; try{this.showPicker()}catch(e){}" onblur="if(!this.value)this.type='text'" /><i class="fa-regular fa-calendar"></i></div>
                    </div>
                    <div>
                        <label class="lbl sm">Till Date</label>
                        <div class="dt-wrap"><asp:TextBox ID="txtTillDate" runat="server" ClientIDMode="Static" CssClass="fld date" placeholder="Pick a date" autocomplete="off" onfocus="this.type='date'; try{this.showPicker()}catch(e){}" onblur="if(!this.value)this.type='text'" /><i class="fa-regular fa-calendar"></i></div>
                    </div>
                    <div>
                        <label class="lbl sm">Holiday Type</label>
                        <asp:DropDownList ID="ddHoliType" runat="server" ClientIDMode="Static" CssClass="fld" />
                    </div>
                    <div>
                        <label class="lbl sm">Holiday Name</label>
                        <asp:TextBox ID="txtHolidayName" runat="server" ClientIDMode="Static" CssClass="fld" placeholder="e.g. Eid Holiday" MaxLength="100" autocomplete="off" />
                    </div>
                </div>
                <div class="flex items-center gap-2 mt-3">
                    <asp:LinkButton ID="btnSave" runat="server" ClientIDMode="Static" OnClick="btnSave_Click" OnClientClick="return beforeSave();" CssClass="h-9 px-5 rounded-lg bg-emerald-600 hover:bg-emerald-700 text-white text-sm font-medium flex items-center gap-2 shadow-sm transition">
                        <i class="fa-regular fa-floppy-disk text-xs"></i><span>Save</span>
                    </asp:LinkButton>
                    <asp:LinkButton ID="btnDelete" runat="server" ClientIDMode="Static" OnClick="btnDelete_Click" OnClientClick="return confirmDelete();" CssClass="h-9 px-4 rounded-lg border border-rose-200 bg-white hover:bg-rose-50 text-rose-600 text-sm font-medium flex items-center gap-2 transition">
                        <i class="fa-regular fa-trash-can text-xs"></i><span>Delete</span>
                    </asp:LinkButton>
                    <button type="button" onclick="closeForm()" class="h-9 px-4 rounded-lg border border-slate-300 bg-white hover:bg-slate-50 text-slate-700 text-sm font-medium flex items-center gap-2 transition">
                        <i class="fa-solid fa-xmark text-xs"></i><span>Close</span>
                    </button>
                </div>
            </div>

            <div class="px-4 py-2.5 flex items-center justify-between border-b border-slate-200 text-xs">
                <span class="font-semibold text-slate-700">Employees
                    <asp:Label ID="lblEmpCount" runat="server" Text="0" CssClass="ml-1 bg-indigo-50 text-indigo-700 font-semibold px-2 py-0.5 rounded-full border border-indigo-100" />
                </span>
                <span class="text-slate-400">টিক দেওয়া কর্মচারীরাই Save হবে</span>
            </div>
            <div class="flex-1 overflow-auto">
                <table class="w-full text-left border-collapse">
                    <thead>
                        <tr class="bg-slate-50 border-b border-slate-200 text-xs font-semibold text-slate-600 sticky top-0 z-10">
                            <th class="py-2.5 px-3 w-10 text-center"><input type="checkbox" id="selectAllEmp" checked onchange="toggleAll('.emp-cb', this)" class="rounded text-indigo-600 w-4 h-4"></th>
                            <th class="py-2.5 px-3">ID No</th>
                            <th class="py-2.5 px-3">Name</th>
                            <th class="py-2.5 px-3">Designation</th>
                            <th class="py-2.5 px-3">Department</th>
                            <th class="py-2.5 px-3">Branch</th>
                            <th class="py-2.5 px-3">Status</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100 text-xs text-slate-700">
                        <asp:Repeater ID="rptEmp" runat="server">
                            <ItemTemplate>
                                <tr class="hover:bg-slate-50/80">
                                    <td class="py-2 px-3 text-center"><input type="checkbox" name="selEmp" class="emp-cb rounded text-indigo-600 w-4 h-4" value='<%# Server.HtmlEncode(Convert.ToString(Eval("IdNo"))) %>' checked></td>
                                    <td class="py-2 px-3 font-semibold text-slate-900"><%# Server.HtmlEncode(Convert.ToString(Eval("IdNo"))) %></td>
                                    <td class="py-2 px-3 font-medium"><%# Server.HtmlEncode(Convert.ToString(Eval("Name"))) %></td>
                                    <td class="py-2 px-3 text-slate-600"><%# Server.HtmlEncode(Convert.ToString(Eval("Designation"))) %></td>
                                    <td class="py-2 px-3 text-slate-600"><%# Server.HtmlEncode(Convert.ToString(Eval("Department"))) %></td>
                                    <td class="py-2 px-3 text-slate-600"><%# Server.HtmlEncode(Convert.ToString(Eval("Branch"))) %></td>
                                    <td class="py-2 px-3"><span class="inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-medium bg-emerald-50 text-emerald-700 border border-emerald-200"><%# Server.HtmlEncode(Convert.ToString(Eval("Status"))) %></span></td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                        <tr id="trEmpEmpty" runat="server"><td colspan="7" class="text-center py-8 text-slate-400 text-xs">ফিল্টার বা ID দিয়ে Show চাপুন; কর্মচারীরা এখানে আসবে।</td></tr>
                    </tbody>
                </table>
            </div>
        </aside>

        <!-- RIGHT: Applied list -->
        <main class="flex-1 flex flex-col min-h-0 min-w-0 bg-white border border-slate-200 rounded-xl shadow-sm overflow-hidden">
            <div class="px-5 py-3 border-b border-slate-200 flex flex-wrap items-center justify-between gap-3 shrink-0">
                <div class="flex items-center space-x-2">
                    <h2 class="text-sm font-bold text-slate-800">Applied Holidays</h2>
                    <asp:Label ID="lblCount" runat="server" CssClass="bg-indigo-50 text-indigo-700 text-xs font-semibold px-2.5 py-0.5 rounded-full border border-indigo-100" Text="0 Records" />
                </div>
                <div class="relative">
                    <input type="text" id="tableSearch" onkeyup="searchTable()" onkeydown="if(event.key==='Enter')return false;" placeholder="Quick filter table..." class="bg-slate-50 border border-slate-300 rounded-lg pl-8 pr-3 py-1.5 text-xs text-slate-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 w-48 sm:w-64">
                    <i class="fa-solid fa-search absolute left-2.5 top-2 text-slate-400 text-xs"></i>
                </div>
            </div>

            <div class="flex-1 overflow-auto">
                <table id="listTable" class="w-full text-left border-collapse">
                    <thead>
                        <tr class="bg-slate-50 border-b border-slate-200 text-xs font-semibold text-slate-600 uppercase tracking-wider sticky top-0 z-10">
                            <th class="py-3.5 px-4 w-12 text-center"><input type="checkbox" onchange="toggleAll('.row-checkbox', this)" class="rounded text-indigo-600 w-4 h-4"></th>
                            <th class="py-3.5 px-4">Apply No</th>
                            <th class="py-3.5 px-4">ID No</th>
                            <th class="py-3.5 px-4">From Date</th>
                            <th class="py-3.5 px-4">Till Date</th>
                        </tr>
                    </thead>
                    <tbody id="tableBody" class="divide-y divide-slate-100 text-sm text-slate-700 bg-white">
                        <asp:Repeater ID="rptList" runat="server" OnItemCommand="rptList_ItemCommand">
                            <ItemTemplate>
                                <tr class='hover:bg-slate-50/80 transition-colors<%# Convert.ToString(Eval("ApplyNo")) == hfApplyCode.Value ? " sel-row" : "" %>'>
                                    <td class="py-3 px-4 text-center"><input type="checkbox" name="selApply" class="row-checkbox rounded text-indigo-600 w-4 h-4" value='<%# Server.HtmlEncode(Convert.ToString(Eval("ApplyNo"))) %>'></td>
                                    <td class="py-3 px-4 text-xs font-semibold">
                                        <asp:LinkButton runat="server" CommandName="pick" CommandArgument='<%# Eval("ApplyNo") %>' CssClass="text-blue-600 hover:underline" ToolTip="Click to load"><%# Server.HtmlEncode(Convert.ToString(Eval("ApplyNo"))) %></asp:LinkButton>
                                    </td>
                                    <td class="py-3 px-4 text-xs font-medium text-slate-900"><%# Server.HtmlEncode(Convert.ToString(Eval("IdNo"))) %></td>
                                    <td class="py-3 px-4 text-xs text-slate-600"><%# Server.HtmlEncode(Convert.ToString(Eval("FromDate"))) %></td>
                                    <td class="py-3 px-4 text-xs text-slate-600"><%# Server.HtmlEncode(Convert.ToString(Eval("TillDate"))) %></td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                        <tr id="trEmpty" runat="server" visible="false"><td colspan="5" class="text-center py-8 text-slate-400 text-xs">No records found.</td></tr>
                    </tbody>
                </table>
            </div>

            <div class="bg-slate-50 border-t border-slate-200 px-5 py-2.5 text-xs text-slate-500 shrink-0">
                <asp:Literal ID="litPaging" runat="server" />
                <span class="ml-3 text-slate-400">Apply No-তে ক্লিক করলে ফর্মে লোড হবে; টিক দিয়ে Delete চাপলে টিক দেওয়া সবগুলো মুছবে।</span>
            </div>
        </main>
    </div>

    <div id="toastContainer" class="fixed bottom-5 right-5 z-50 flex flex-col space-y-2 pointer-events-none"></div>
</form>

<script>
// @ts-nocheck
const esc = s => String(s).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));

function toggleAll(sel, src) { document.querySelectorAll(sel).forEach(cb => cb.checked = src.checked); }

function toggleFilters() {
    var box = document.getElementById('filterBox');
    var hide = box.style.display !== 'none';
    box.style.display = hide ? 'none' : '';
    document.getElementById('fltText').textContent = hide ? 'Show filters' : 'Hide filters';
    document.getElementById('fltIcon').className = 'fa-solid text-[10px] ' + (hide ? 'fa-chevron-down' : 'fa-chevron-up');
}

function beforeSave() {
    if (!document.querySelectorAll('.emp-cb:checked').length) { showNotification('কমপক্ষে একজন কর্মচারী টিক দিন (আগে ফিল্টার/ID দিয়ে Show চাপুন)।'); return false; }
    if (!document.getElementById('txtFromDate').value || !document.getElementById('txtTillDate').value) { showNotification('From Date ও Till Date দিন।'); return false; }
    if (!document.getElementById('ddHoliType').value) { showNotification('Holiday Type নির্বাচন করুন।'); return false; }
    return true;
}

function confirmDelete() {
    if (!document.querySelectorAll('.row-checkbox:checked').length && !document.getElementById('hfApplyCode').value) {
        showNotification('মুছতে ডান পাশের তালিকা থেকে রো টিক দিন বা Apply No-তে ক্লিক করুন।'); return false;
    }
    return confirm('নির্বাচিত রেকর্ড মুছে ফেলবেন?');
}

function closeForm() {
    if (window.opener || window.history.length <= 1) window.close(); else window.history.back();
}

function searchTable() {
    const q = document.getElementById('tableSearch').value.toLowerCase();
    document.querySelectorAll('#tableBody tr').forEach(tr => {
        if (tr.id && tr.id.indexOf('trEmpty') > -1) return;
        tr.style.display = tr.textContent.toLowerCase().includes(q) ? '' : 'none';
    });
}

// ---------- Multi-select ড্রপডাউন (ListBox → চেকবক্স প্যানেল) : HRMReports এর হুবহু ----------
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

function showNotification(message) {
    const container = document.getElementById('toastContainer');
    const toast = document.createElement('div');
    toast.className = "bg-slate-900 text-white text-xs px-4 py-2.5 rounded-xl shadow-lg pointer-events-auto flex items-center space-x-2 transition transform translate-y-2 opacity-0";
    toast.innerHTML = `<i class="fa-solid fa-circle-info text-indigo-400"></i><span>${esc(message)}</span>`;
    container.appendChild(toast);
    setTimeout(() => toast.classList.remove('translate-y-2', 'opacity-0'), 10);
    setTimeout(() => { toast.classList.add('translate-y-2', 'opacity-0'); setTimeout(() => toast.remove(), 300); }, 3500);
}

document.addEventListener('DOMContentLoaded', function () {
    try { initMulti(); } catch (err) { console.error('initMulti error:', err); }

    document.querySelectorAll('input.date').forEach(i => { if (i.value) i.type = 'date'; });

    // Multi ID ঘরে Enter চাপলে Show বাটন চলবে
    const mi = document.getElementById('txtMultiId');
    if (mi) mi.addEventListener('keydown', e => {
        if (e.key === 'Enter') {
            e.preventDefault();
            const b = document.getElementById('btnShow');
            if (b) b.click();
        }
    });
});
</script>
</body>
</html>
