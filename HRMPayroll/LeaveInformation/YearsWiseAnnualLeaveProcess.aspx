<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="YearsWiseAnnualLeaveProcess.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.LeaveInformation.YearsWiseAnnualLeaveProcess" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Years Wise Annual Leave Process</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; }
        ::-webkit-scrollbar{width:6px;height:6px}
        ::-webkit-scrollbar-track{background:#f1f5f9}
        ::-webkit-scrollbar-thumb{background:#cbd5e1;border-radius:3px}
        ::-webkit-scrollbar-thumb:hover{background:#94a3b8}

        /* ---- Filter fields (Payroll Reports এর মতো) ---- */
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
        textarea.fld{display:block;height:auto;padding:6px 10px;cursor:text;color:#1e293b;resize:vertical}
        .dt-wrap{position:relative}
        .dt-wrap i{position:absolute;right:10px;top:10px;color:#a0a7b5;font-size:12px;pointer-events:none}

        /* JS ব্যর্থ হলে আসল ListBox টিই কাজ করবে (Ctrl+Click) */
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
    </style>
</head>
<body class="bg-slate-100 text-slate-800 antialiased h-screen flex flex-col overflow-hidden">
<form id="form1" runat="server" class="flex flex-col h-screen overflow-hidden" autocomplete="off">
    <asp:HiddenField ID="hfSelIds" runat="server" ClientIDMode="Static" />

    <!-- ================= Filters ================= -->
    <section class="bg-white border-b border-slate-200 px-6 py-4 shrink-0 relative z-30">
        <h1 class="text-lg font-semibold text-slate-800 mb-3">Years Wise Annual Leave Process</h1>

        <div class="bg-slate-50/70 border border-slate-200 rounded-xl p-4 space-y-3">

            <%-- Employee Status | From | Till | Refresh --%>
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-x-4 gap-y-3 items-end">
                <div><label class="lbl">Employee Status</label>
                    <asp:DropDownList ID="ddlEmployeeStatus" runat="server" ClientIDMode="Static" CssClass="fld" /></div>
                <div><label class="lbl sm">From</label>
                    <div class="dt-wrap"><asp:TextBox ID="txtFromDate" runat="server" ClientIDMode="Static" CssClass="fld date" placeholder="Pick a date" autocomplete="off" onfocus="this.type='date'; try{this.showPicker()}catch(e){}" onblur="if(!this.value)this.type='text'" /><i class="fa-regular fa-calendar"></i></div></div>
                <div><label class="lbl sm">Till</label>
                    <div class="dt-wrap"><asp:TextBox ID="txtTillDate" runat="server" ClientIDMode="Static" CssClass="fld date" placeholder="Pick a date" autocomplete="off" onfocus="this.type='date'; try{this.showPicker()}catch(e){}" onblur="if(!this.value)this.type='text'" /><i class="fa-regular fa-calendar"></i></div></div>
                <div>
                    <asp:LinkButton ID="btnRefresh" runat="server" ClientIDMode="Static" OnClick="btnRefresh_Click" CssClass="h-8 px-4 rounded-lg border border-slate-300 bg-white hover:bg-slate-50 text-slate-700 text-sm font-medium inline-flex items-center gap-2 transition">
                        <i class="fa-solid fa-rotate text-xs"></i><span>Refresh</span>
                    </asp:LinkButton>
                </div>
            </div>

            <%-- Select All / De-Select (সব ফিল্টারের জন্য) --%>
            <div class="flex items-center gap-5 text-sm text-slate-700">
                <label class="inline-flex items-center gap-1.5 cursor-pointer"><input type="checkbox" id="cbAllFilters" class="w-4 h-4 accent-emerald-600" onclick="filterSelectAll(this)"> Select All</label>
                <label class="inline-flex items-center gap-1.5 cursor-pointer"><input type="checkbox" id="cbNoneFilters" class="w-4 h-4 accent-emerald-600" onclick="filterDeselectAll(this)"> De-Select</label>
            </div>

            <%-- Payroll Reports এর মতো মাল্টি-সিলেক্ট ফিল্টার --%>
            <div id="filterGrid" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-x-4 gap-y-3">
                <div><label class="lbl">Category</label><asp:ListBox ID="ddCategory" runat="server" ClientIDMode="Static" SelectionMode="Multiple" CssClass="ms-src" /></div>
                <div><label class="lbl">Department</label><asp:ListBox ID="ddDept" runat="server" ClientIDMode="Static" SelectionMode="Multiple" CssClass="ms-src" /></div>
                <div><label class="lbl">Section</label><asp:ListBox ID="ddSection" runat="server" ClientIDMode="Static" SelectionMode="Multiple" CssClass="ms-src" /></div>
                <div><label class="lbl">Sub Section</label><asp:ListBox ID="ddSubSec" runat="server" ClientIDMode="Static" SelectionMode="Multiple" CssClass="ms-src" /></div>
                <div><label class="lbl">Designation</label><asp:ListBox ID="ddDesig" runat="server" ClientIDMode="Static" SelectionMode="Multiple" CssClass="ms-src" /></div>
            </div>

            <div><label class="lbl">Multi ID No</label>
                <asp:TextBox ID="txtMultiIdNo" runat="server" ClientIDMode="Static" TextMode="MultiLine" Rows="2" CssClass="fld" placeholder="e.g. 1001, 1002, 1003…" /></div>
        </div>

        <div class="flex flex-wrap justify-between items-center gap-2 mt-3">
            <asp:LinkButton ID="btnProcess" runat="server" ClientIDMode="Static" OnClick="btnProcess_Click" OnClientClick="return onProcessClick();" CssClass="h-9 px-5 rounded-lg bg-violet-600 hover:bg-violet-700 text-white text-sm font-medium inline-flex items-center gap-2 shadow-sm transition">
                <i class="fa-solid fa-gears text-xs"></i><span>Process</span>
            </asp:LinkButton>

            <div class="flex items-center gap-2">
                <asp:LinkButton ID="btnShow" runat="server" ClientIDMode="Static" OnClick="btnShow_Click" CssClass="h-9 px-4 rounded-lg bg-blue-600 hover:bg-blue-700 text-white text-sm font-medium inline-flex items-center gap-2 shadow-sm transition">
                    <i class="fa-regular fa-eye text-xs"></i><span>Show</span>
                </asp:LinkButton>
                <button type="button" onclick="setAllRows(true)" class="h-9 px-4 rounded-lg border border-slate-300 bg-white hover:bg-slate-50 text-slate-700 text-sm font-medium transition">Select All</button>
                <button type="button" onclick="setAllRows(false)" class="h-9 px-4 rounded-lg border border-slate-300 bg-white hover:bg-slate-50 text-slate-700 text-sm font-medium transition">Deselect</button>
            </div>
        </div>
    </section>

    <!-- ================= Results ================= -->
    <main class="flex-1 flex flex-col min-h-0 overflow-hidden">
        <div class="bg-white border-b border-slate-200 px-6 py-3 flex items-center justify-between shrink-0">
            <div class="flex items-center gap-2">
                <h2 class="text-base font-semibold text-slate-800">Employee List</h2>
                <asp:Label ID="lblCount" runat="server" CssClass="bg-indigo-50 text-indigo-700 text-xs font-semibold px-2.5 py-0.5 rounded-full border border-indigo-100" Text="0 Records" />
            </div>
            <div class="relative">
                <input type="text" id="tableSearch" onkeyup="searchTable()" onkeydown="if(event.key==='Enter')return false;" placeholder="Quick filter table..." class="bg-slate-50 border border-slate-300 rounded-lg pl-8 pr-3 py-1.5 text-xs text-slate-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 w-48 sm:w-64">
                <i class="fa-solid fa-search absolute left-2.5 top-2 text-slate-400 text-xs"></i>
            </div>
        </div>

        <div class="flex-1 p-6 overflow-auto">
            <div class="bg-white border border-slate-200 rounded-xl shadow-sm overflow-hidden h-full flex flex-col">
                <div class="overflow-auto flex-1">
                    <table id="reportTable" class="w-full text-left border-collapse">
                        <thead>
                            <tr class="bg-slate-50 border-b border-slate-200 text-xs font-semibold text-slate-600 sticky top-0 z-10">
                                <th class="py-3 px-4 w-12 text-center"><input type="checkbox" id="selectAllRows" onchange="setAllRows(this.checked)" class="w-4 h-4"></th>
                                <th class="py-3 px-4">ID No</th>
                                <th class="py-3 px-4">Name</th>
                                <th class="py-3 px-4">Designation</th>
                            </tr>
                        </thead>
                        <tbody id="tableBody" class="divide-y divide-slate-100 text-sm text-slate-700 bg-white">
                            <asp:Repeater ID="rptEmployees" runat="server">
                                <ItemTemplate>
                                    <tr class="hover:bg-slate-50/80 transition-colors">
                                        <td class="py-2.5 px-4 text-center"><input type="checkbox" name="selId" class="row-checkbox w-4 h-4" value='<%# Server.HtmlEncode(Convert.ToString(Eval("Id"))) %>' data-id='<%# Server.HtmlEncode(Convert.ToString(Eval("Id"))) %>'></td>
                                        <td class="py-2.5 px-4 font-semibold text-slate-900 text-xs"><%# Server.HtmlEncode(Convert.ToString(Eval("Id"))) %></td>
                                        <td class="py-2.5 px-4 text-xs"><%# Server.HtmlEncode(Convert.ToString(Eval("Name"))) %></td>
                                        <td class="py-2.5 px-4 text-slate-600 text-xs"><%# Server.HtmlEncode(Convert.ToString(Eval("Designation"))) %></td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                            <tr id="trEmpty" runat="server" visible="false"><td colspan="4" class="text-center py-8 text-slate-400 text-xs">No matching records found for the selected criteria.</td></tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </main>

    <div id="toastContainer" class="fixed bottom-5 right-5 z-50 flex flex-col space-y-2 pointer-events-none"></div>
</form>

<script>
// @ts-nocheck
const esc = s => String(s).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));

// টিক দেওয়া ID গুলো hfSelIds এ জমা (সার্ভার name="selId" থেকেও পড়ে)
function collectIds() {
    const ids = [];
    document.querySelectorAll('.row-checkbox:checked').forEach(c => {
        const id = c.getAttribute('data-id') || c.value;
        if (id) ids.push(id);
    });
    const hf = document.getElementById('hfSelIds');
    if (hf) hf.value = ids.join(',');
    return ids.length;
}

// Process: অন্তত একজন টিক দেওয়া থাকতে হবে
function onProcessClick() {
    if (collectIds() === 0) { showNotification('কমপক্ষে একজন কর্মচারী নির্বাচন করুন।'); return false; }
    return true;
}

// টেবিলের Select All / Deselect
function setAllRows(flag) {
    document.querySelectorAll('.row-checkbox').forEach(c => c.checked = flag);
    const m = document.getElementById('selectAllRows'); if (m) m.checked = flag;
}

// ফিল্টারের Select All / De-Select চেকবক্স (Category ... Designation সবগুলোর জন্য)
function filterSelectAll(cb) {
    if (!cb.checked) return;
    document.getElementById('cbNoneFilters').checked = false;
    document.querySelectorAll('select.ms-src').forEach(s => {
        for (let i = 0; i < s.options.length; i++) s.options[i].selected = true;
        if (s._render) s._render();
    });
}
function filterDeselectAll(cb) {
    if (!cb.checked) return;
    document.getElementById('cbAllFilters').checked = false;
    document.querySelectorAll('select.ms-src').forEach(s => {
        for (let i = 0; i < s.options.length; i++) s.options[i].selected = false;
        if (s._render) s._render();
    });
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
            sel._render = render;

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
            sel.style.display = 'none';
        } catch (err) { console.error('multi-select init failed for', sel.id, err); sel.style.display = ''; }
    });

    document.addEventListener('click', function (e) {
        if (e.target.closest('.panel') || e.target.closest('.fld')) return;
        document.querySelectorAll('.panel').forEach(function (p) { p.style.display = 'none'; });
        document.querySelectorAll('.fld.open').forEach(function (f) { f.classList.remove('open'); });
    });
}

document.addEventListener('DOMContentLoaded', function () {
    try { initMulti(); } catch (err) { console.error('initMulti error:', err); }

    document.querySelectorAll('input.date').forEach(i => { if (i.value) i.type = 'date'; });

    const f = document.forms[0], old = f.onsubmit;
    f.onsubmit = function () { collectIds(); return old ? old.apply(this, arguments) : true; };
});

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
    setTimeout(() => { toast.classList.add('translate-y-2', 'opacity-0'); setTimeout(() => toast.remove(), 300); }, 3000);
}
</script>
</body>
</html>
