<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EmployeeInformationChangeApproval.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.HRMApproval.EmployeeInformationCheangeApproval" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Employee Information Change Approval</title>
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

        /* ---- Filter fields ---- */
        .fld{display:flex;align-items:center;justify-content:space-between;gap:6px;height:32px;padding:0 10px;
             border:1px solid #d9dce5;border-radius:6px;background:#f6f7fb;font-size:13px;color:#1e293b;
             transition:border-color .15s, box-shadow .15s, background .15s;width:100%}
        .fld:hover{border-color:#b6bccb}
        .fld:focus{outline:none;border-color:#3b82f6;box-shadow:0 0 0 3px rgba(59,130,246,.15)}
        input.fld{cursor:text}
        input.fld::placeholder{color:#a0a7b5}
        .lbl{display:block;font-size:13px;color:#334155;margin-bottom:6px}

        /* ---- Multi-select ড্রপডাউন ---- */
        div.fld{cursor:pointer;user-select:none;color:#94a3b8}
        .fld.open{outline:none;border-color:#3b82f6;box-shadow:0 0 0 3px rgba(59,130,246,.15)}
        .fld.has{background:#fafaee;border-color:#d8dbc9;color:#1e293b}
        .fld .txt{flex:1;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;text-align:left}
        .fld .clr{display:none;color:#64748b;font-size:11px;padding:3px;border-radius:4px}
        .fld .clr:hover{background:#e2e8f0;color:#0f172a}
        .fld.has .clr{display:inline-block}
        .fld .chev{color:#64748b;font-size:11px}
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

        /* ---- পুরনো → নতুন মান ---- */
        .chg-old{color:#64748b}
        .chg-arrow{color:#94a3b8;font-size:9px;margin:0 4px}
        .chg-new{color:#047857;font-weight:600;background:#ecfdf5;border:1px solid #a7f3d0;border-radius:4px;padding:1px 6px}
    </style>
</head>
<body class="bg-slate-100 text-slate-800 antialiased h-screen flex flex-col overflow-hidden">
<form id="form1" runat="server" class="flex flex-col h-screen overflow-hidden" autocomplete="off">

    <section class="bg-white border-b border-slate-200 px-6 py-4 shrink-0 relative z-30">
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

                <%-- ডেক্সটপ ফর্মের textBox1 --%>
                <div><label class="lbl">ID No</label>
                    <asp:TextBox ID="txtIdNo" runat="server" ClientIDMode="Static" CssClass="fld" placeholder="e.g. 1001, 1002…" autocomplete="off" /></div>
            </div>
        </div>
        <div class="flex justify-end items-center gap-2 mt-3">
            <asp:LinkButton ID="btnShow" runat="server" ClientIDMode="Static" OnClick="btnShow_Click" CssClass="h-9 px-4 rounded-lg border border-slate-300 bg-white hover:bg-slate-50 text-slate-700 text-sm font-medium flex items-center gap-2 transition">
                <i class="fa-regular fa-eye text-xs"></i><span>Show</span>
            </asp:LinkButton>
            <button type="button" onclick="setAll(true)" class="h-9 px-4 rounded-lg border border-slate-300 bg-white hover:bg-slate-50 text-slate-700 text-sm font-medium flex items-center gap-2 transition">
                <i class="fa-regular fa-square-check text-xs"></i><span>Select</span>
            </button>
            <button type="button" onclick="setAll(false)" class="h-9 px-4 rounded-lg border border-slate-300 bg-white hover:bg-slate-50 text-slate-700 text-sm font-medium flex items-center gap-2 transition">
                <i class="fa-solid fa-eraser text-xs"></i><span>Clear</span>
            </button>
            <asp:LinkButton ID="btnConfirm" runat="server" ClientIDMode="Static" OnClick="btnConfirm_Click" OnClientClick="return confirmAct('নির্বাচিতগুলো Confirm করতে চান?');" CssClass="h-9 px-5 rounded-lg bg-blue-600 hover:bg-blue-700 text-white text-sm font-medium flex items-center gap-2 shadow-sm transition">
                <i class="fa-solid fa-check text-xs"></i><span>Confirm</span>
            </asp:LinkButton>
            <asp:LinkButton ID="btnDelete" runat="server" ClientIDMode="Static" OnClick="btnDelete_Click" OnClientClick="return confirmAct('নির্বাচিতগুলো Delete করতে চান? এটি আগের অবস্থায় ফেরানো যাবে না।');" CssClass="h-9 px-5 rounded-lg bg-red-600 hover:bg-red-700 text-white text-sm font-medium flex items-center gap-2 shadow-sm transition">
                <i class="fa-regular fa-trash-can text-xs"></i><span>Delete</span>
            </asp:LinkButton>
        </div>
    </section>

    <!-- Results -->
    <div class="flex-1 flex flex-col min-h-0 overflow-hidden">
        <main class="flex-1 flex flex-col min-h-0 bg-slate-100 overflow-hidden relative">

            <div class="bg-white border-b border-slate-200 px-6 py-4 flex flex-wrap items-center justify-between gap-4 shrink-0 shadow-2xs">
                <div>
                    <div class="flex items-center space-x-2">
                        <h2 class="text-base font-bold text-slate-800">Employee Information Change Approval</h2>
                        <asp:Label ID="lblCount" runat="server" CssClass="bg-indigo-50 text-indigo-700 text-xs font-semibold px-2.5 py-0.5 rounded-full border border-indigo-100" Text="0 Records" />
                    </div>
                    <p class="text-xs text-slate-500 mt-0.5">Showing pending (Open) employee information changes. Old value → New value.</p>
                </div>
                <div class="relative">
                    <input type="text" id="tableSearch" onkeyup="searchTable()" onkeydown="if(event.key==='Enter')return false;" placeholder="Quick filter table..." class="bg-slate-50 border border-slate-300 rounded-lg pl-8 pr-3 py-1.5 text-xs text-slate-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 w-48 sm:w-64">
                    <i class="fa-solid fa-search absolute left-2.5 top-2 text-slate-400 text-xs"></i>
                </div>
            </div>

            <div class="flex-1 p-6 overflow-auto">
                <div class="bg-white border border-slate-200 rounded-xl shadow-sm overflow-hidden flex flex-col h-full">
                    <div class="overflow-x-auto flex-1">
                        <table id="reportTable" class="w-full text-left border-collapse">
                            <thead>
                                <tr class="bg-slate-50 border-b border-slate-200 text-xs font-semibold text-slate-600 uppercase tracking-wider sticky top-0 z-10">
                                    <th class="py-3.5 px-4 w-12 text-center">
                                        <input type="checkbox" id="selectAllRows" onchange="setAll(this.checked)" class="rounded text-indigo-600 focus:ring-indigo-500 w-4 h-4">
                                    </th>
                                    <th class="py-3.5 px-4 font-semibold">ID No</th>
                                    <th class="py-3.5 px-4 font-semibold">Name</th>
                                    <th class="py-3.5 px-4 font-semibold">Joining Date</th>
                                    <th class="py-3.5 px-4 font-semibold">Effective Date</th>
                                    <th class="py-3.5 px-4 font-semibold">Category</th>
                                    <th class="py-3.5 px-4 font-semibold">Designation</th>
                                    <th class="py-3.5 px-4 font-semibold">Department</th>
                                    <th class="py-3.5 px-4 font-semibold">Section</th>
                                    <th class="py-3.5 px-4 font-semibold">Line</th>
                                </tr>
                            </thead>
                            <tbody id="tableBody" class="divide-y divide-slate-100 text-sm text-slate-700 bg-white">
                                <asp:Repeater ID="rptEmp" runat="server">
                                    <ItemTemplate>
                                        <tr class="hover:bg-slate-50/80 transition-colors">
                                            <%-- name="selId" এর value = ID_no; বাটন চাপলে সার্ভার এটিই পড়ে --%>
                                            <td class="py-3 px-4 text-center"><input type="checkbox" name="selId" class="row-checkbox rounded text-indigo-600 focus:ring-indigo-500 w-4 h-4" value='<%# Server.HtmlEncode(Get(Container.DataItem, "ID_no", "ID_No")) %>'></td>
                                            <td class="py-3 px-4 font-semibold text-slate-900 text-xs"><%# Server.HtmlEncode(Get(Container.DataItem, "ID_no", "ID_No")) %></td>
                                            <td class="py-3 px-4 font-medium text-slate-800 text-xs"><%# Server.HtmlEncode(Get(Container.DataItem, "Name")) %></td>
                                            <td class="py-3 px-4 text-slate-600 text-xs whitespace-nowrap"><%# Dt(Container.DataItem, "Joining_Date") %></td>
                                            <td class="py-3 px-4 text-slate-600 text-xs whitespace-nowrap"><%# Dt(Container.DataItem, "Effective_Date") %></td>
                                            <td class="py-3 px-4 text-xs"><%# Chg(Container.DataItem, "Catagory_Name", "New_Catagory_Name") %></td>
                                            <td class="py-3 px-4 text-xs"><%# Chg(Container.DataItem, "Desigation_name", "New_Desigation_name") %></td>
                                            <td class="py-3 px-4 text-xs"><%# Chg(Container.DataItem, "Department_Name", "New_Department_Name") %></td>
                                            <td class="py-3 px-4 text-xs"><%# Chg(Container.DataItem, "Section_Name", "New_Section_Name") %></td>
                                            <td class="py-3 px-4 text-xs"><%# Chg(Container.DataItem, "Line_Name", "New_Line_Name") %></td>
                                        </tr>
                                    </ItemTemplate>
                                </asp:Repeater>
                                <tr id="trEmpty" runat="server" visible="false"><td colspan="10" class="text-center py-8 text-slate-400 text-xs">No pending changes found for the selected criteria.</td></tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <!-- Notification Toast Container -->
    <div id="toastContainer" class="fixed bottom-5 right-5 z-50 flex flex-col space-y-2 pointer-events-none"></div>

</form>

<script>
// @ts-nocheck
const esc = s => String(s).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));

// Select / Clear: সব চেকবক্স টিক দেওয়া বা তোলা
function setAll(v) {
    document.querySelectorAll('.row-checkbox').forEach(c => c.checked = v);
    var h = document.getElementById('selectAllRows'); if (h) h.checked = v;
}

// Confirm / Delete চাপলে অন্তত একটি টিক লাগবে
function confirmAct(msg) {
    if (!document.querySelectorAll('.row-checkbox:checked').length) {
        showNotification('কমপক্ষে একটি এন্ট্রি নির্বাচন করুন।');
        return false;
    }
    return confirm(msg);
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
                o.selected = !o.selected; render();
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

    // ID No ঘরে Enter চাপলে Show চলবে
    var t = document.getElementById('txtIdNo');
    if (t) t.addEventListener('keydown', function (e) {
        if (e.key === 'Enter') { e.preventDefault(); document.getElementById('btnShow').click(); }
    });
});

// ---------- টেবিলের Quick filter ----------
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
