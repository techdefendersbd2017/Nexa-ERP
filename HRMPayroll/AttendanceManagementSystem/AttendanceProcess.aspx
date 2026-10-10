<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AttendanceProcess.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.AttendanceManagementSystem.AttendanceProcess" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Attendance Process</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; }
        ::-webkit-scrollbar{width:6px;height:6px}
        ::-webkit-scrollbar-track{background:#f1f5f9}
        ::-webkit-scrollbar-thumb{background:#cbd5e1;border-radius:3px}
        ::-webkit-scrollbar-thumb:hover{background:#94a3b8}

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
        input.fld.date{background:#f3f4f7;color:#334155}
        textarea.fld{height:64px;padding:6px 10px;display:block;cursor:text;color:#1e293b;resize:none}
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
        .dt-wrap{position:relative}

        .pbar-track{height:10px;background:#e2e8f0;border-radius:999px;overflow:hidden}
        .pbar-fill{height:100%;width:0;background:linear-gradient(90deg,#3b82f6,#2563eb);border-radius:999px;transition:width .25s ease}
        .pbar-fill.done{background:linear-gradient(90deg,#10b981,#059669)}
        .pbar-fill.err{background:linear-gradient(90deg,#f59e0b,#ef4444)}
    </style>
</head>
<body class="bg-slate-100 text-slate-800 antialiased h-screen flex flex-col overflow-hidden">
<form id="form1" runat="server" class="flex flex-col h-screen overflow-hidden" autocomplete="off">
    <asp:HiddenField ID="hfSelIds" runat="server" ClientIDMode="Static" />

    <section class="bg-white border-b border-slate-200 px-6 py-4 shrink-0 relative z-30">
        <div class="mb-3 flex items-center gap-2">
            <i class="fa-solid fa-clock text-blue-600"></i>
            <h1 class="text-base font-bold text-slate-800">Attendance Process</h1>
        </div>

        <div class="bg-slate-50/70 border border-slate-200 rounded-xl p-4">
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-x-4 gap-y-3">
                <div><label class="lbl">Employee Status</label><asp:DropDownList ID="ddStatus" runat="server" ClientIDMode="Static" CssClass="fld" /></div>
                <div><label class="lbl">Category</label><asp:ListBox ID="lbCategory" runat="server" ClientIDMode="Static" SelectionMode="Multiple" CssClass="ms-src" /></div>
                <div><label class="lbl">Department</label><asp:ListBox ID="lbDept" runat="server" ClientIDMode="Static" SelectionMode="Multiple" CssClass="ms-src" /></div>
                <div><label class="lbl">Section</label><asp:ListBox ID="lbSection" runat="server" ClientIDMode="Static" SelectionMode="Multiple" CssClass="ms-src" /></div>
                <div><label class="lbl">Sub Section</label><asp:ListBox ID="lbSubSec" runat="server" ClientIDMode="Static" SelectionMode="Multiple" CssClass="ms-src" /></div>
                <div><label class="lbl">Designation</label><asp:ListBox ID="lbDesig" runat="server" ClientIDMode="Static" SelectionMode="Multiple" CssClass="ms-src" /></div>
                <div><label class="lbl sm">From Date</label>
                    <asp:TextBox ID="txtFromDate" runat="server" ClientIDMode="Static" TextMode="Date" CssClass="fld date" /></div>
                <div><label class="lbl sm">Till Date</label>
                    <asp:TextBox ID="txtTillDate" runat="server" ClientIDMode="Static" TextMode="Date" CssClass="fld date" /></div>
                <div class="lg:col-span-2"><label class="lbl">ID (comma / new line separated)</label>
                    <asp:TextBox ID="txtIds" runat="server" ClientIDMode="Static" TextMode="MultiLine" CssClass="fld" placeholder="e.g. 1001, 1002, 1003" /></div>
            </div>
        </div>

        <div class="flex justify-between items-center gap-2 mt-3">
            <div class="text-xs text-slate-600">
                Total Employee:
                <asp:Label ID="lblTotal" runat="server" ClientIDMode="Static" CssClass="ml-1 bg-indigo-50 text-indigo-700 font-semibold px-2.5 py-0.5 rounded-full border border-indigo-100" Text="0" />
            </div>
            <div class="flex items-center gap-2">
                <asp:LinkButton ID="btnSearch" runat="server" ClientIDMode="Static" OnClick="btnSearch_Click" CssClass="h-9 px-4 rounded-lg border border-slate-300 bg-white hover:bg-slate-50 text-slate-700 text-sm font-medium flex items-center gap-2 transition">
                    <i class="fa-solid fa-magnifying-glass text-xs"></i><span>Search</span>
                </asp:LinkButton>
                <button type="button" id="btnProcess" onclick="startProcess()" class="h-9 px-5 rounded-lg bg-emerald-600 hover:bg-emerald-700 disabled:opacity-60 disabled:cursor-not-allowed text-white text-sm font-medium flex items-center gap-2 shadow-sm transition">
                    <i class="fa-solid fa-gears text-xs"></i><span>Att. Process</span>
                </button>
                <button type="button" id="btnStop" onclick="stopProcess()" style="display:none" class="h-9 px-4 rounded-lg border border-rose-300 bg-white hover:bg-rose-50 text-rose-600 text-sm font-medium flex items-center gap-2 transition">
                    <i class="fa-solid fa-stop text-xs"></i><span>Stop</span>
                </button>
            </div>
        </div>

        <!-- Process Bar -->
        <div id="processBox" style="display:none" class="mt-3 bg-slate-50 border border-slate-200 rounded-xl px-4 py-3">
            <div class="flex items-center justify-between text-xs text-slate-600 mb-2">
                <span id="pText" class="font-medium">Preparing...</span>
                <span id="pPct" class="font-semibold text-slate-800">0%</span>
            </div>
            <div class="pbar-track"><div id="pFill" class="pbar-fill"></div></div>
            <div class="flex items-center justify-between text-[11px] text-slate-500 mt-2">
                <span id="pCount">0 / 0 processed</span>
                <span><span id="pEta"></span> <span id="pFail" class="text-rose-600 ml-2"></span></span>
            </div>
        </div>
    </section>

    <!-- Results -->
    <div class="flex-1 flex flex-col min-h-0 overflow-hidden">
        <main class="flex-1 flex flex-col min-h-0 bg-slate-100 overflow-hidden">
            <div class="flex-1 p-6 overflow-auto">
                <div class="bg-white border border-slate-200 rounded-xl shadow-sm overflow-hidden flex flex-col h-full">
                    <div class="overflow-auto flex-1">
                        <table id="reportTable" class="w-full text-left border-collapse">
                            <thead>
                                <tr class="bg-slate-50 border-b border-slate-200 text-xs font-semibold text-slate-600 uppercase tracking-wider sticky top-0 z-10">
                                    <th class="py-3.5 px-4 w-12 text-center">
                                        <input type="checkbox" id="selectAllRows" checked onchange="toggleAllRowCheckboxes(this)" class="rounded w-4 h-4">
                                    </th>
                                    <th class="py-3.5 px-4 font-semibold">ID No</th>
                                    <th class="py-3.5 px-4 font-semibold">Name</th>
                                    <th class="py-3.5 px-4 font-semibold">Designation</th>
                                </tr>
                            </thead>
                            <tbody id="tableBody" class="divide-y divide-slate-100 text-sm text-slate-700 bg-white">
                                <asp:Literal ID="litRows" runat="server" />
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <div id="toastContainer" class="fixed bottom-5 right-5 z-50 flex flex-col space-y-2 pointer-events-none"></div>
</form>

<script>
// @ts-nocheck
const esc = s => String(s).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));

function collectIds() {
    const ids = [];
    document.querySelectorAll('.row-checkbox:checked').forEach(c => {
        const id = c.getAttribute('data-id') || c.value;
        if (id) ids.push(id);
    });
    const hf = document.getElementById('hfSelIds');
    if (hf) hf.value = ids.join(',');
    return ids;
}
function toggleAllRowCheckboxes(src) {
    document.querySelectorAll('.row-checkbox').forEach(cb => cb.checked = src.checked);
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
});

function showNotification(message) {
    const container = document.getElementById('toastContainer');
    const toast = document.createElement('div');
    toast.className = "bg-slate-900 text-white text-xs px-4 py-2.5 rounded-xl shadow-lg pointer-events-auto flex items-center space-x-2 transition transform translate-y-2 opacity-0";
    toast.innerHTML = '<i class="fa-solid fa-circle-info text-indigo-400"></i><span>' + esc(message) + '</span>';
    container.appendChild(toast);
    setTimeout(() => toast.classList.remove('translate-y-2', 'opacity-0'), 10);
    setTimeout(() => { toast.classList.add('translate-y-2', 'opacity-0'); setTimeout(() => toast.remove(), 300); }, 3500);
}

// ================= Att. Process + Process Bar =================
var procRunning = false, procCancel = false;

function pageMethod(name, payload) {
    return fetch(location.pathname + '/' + name, {
        method: 'POST', credentials: 'same-origin',
        headers: { 'Content-Type': 'application/json; charset=utf-8' },
        body: JSON.stringify(payload || {})
    }).then(function (r) {
        if (!r.ok) throw new Error('Server error ' + r.status);
        return r.json();
    }).then(function (j) { return j.d; });
}

function setBar(done, total, text, state) {
    var pct = total > 0 ? Math.round(done * 100 / total) : 0;
    var fill = document.getElementById('pFill');
    fill.style.width = pct + '%';
    fill.className = 'pbar-fill' + (state ? ' ' + state : '');
    document.getElementById('pPct').textContent = pct + '%';
    document.getElementById('pCount').textContent = done + ' / ' + total + ' processed';
    if (text) document.getElementById('pText').textContent = text;
}

async function startProcess() {
    if (procRunning) return;
    var ids = collectIds();
    var from = document.getElementById('txtFromDate').value;
    var till = document.getElementById('txtTillDate').value;

    if (ids.length === 0) { showNotification('Please Select Employee'); return; }
    if (!from || !till) { showNotification('From Date ও Till Date দিন।'); return; }
    if (till < from) { showNotification('Till Date, From Date এর আগে হতে পারবে না।'); return; }

    document.getElementById('processBox').style.display = 'block';
    var btn = document.getElementById('btnProcess'), stop = document.getElementById('btnStop');
    var failEl = document.getElementById('pFail'), etaEl = document.getElementById('pEta');
    failEl.textContent = ''; etaEl.textContent = '';
    setBar(0, ids.length, 'Checking month lock...');

    procRunning = true; procCancel = false;
    btn.disabled = true; stop.style.display = '';

    var done = 0, failed = 0, firstErr = '', t0 = Date.now();
    try {
        var lk = await pageMethod('CheckLock', { fromDate: from });
        if (lk && lk.locked) {
            setBar(0, ids.length, 'This Month Lock', 'err');
            showNotification('This Month Lock');
            return;
        }
        for (var i = 0; i < ids.length; i++) {
            if (procCancel) break;
            setBar(done, ids.length, 'Processing ID: ' + ids[i]);
            try {
                var r = await pageMethod('ProcessOne', { id: ids[i], fromDate: from, tillDate: till });
                if (!r || !r.ok) { failed++; if (!firstErr) firstErr = (r && r.msg) || 'Unknown error'; }
            } catch (e) { failed++; if (!firstErr) firstErr = e.message; }
            done++;
            setBar(done, ids.length, 'Processing ID: ' + ids[i], failed ? 'err' : '');
            if (failed) failEl.textContent = failed + ' failed';
            var remainSec = ((Date.now() - t0) / done) * (ids.length - done) / 1000;
            etaEl.textContent = done < ids.length ? 'Est. remaining: ~' + (remainSec < 60 ? Math.ceil(remainSec) + ' sec' : (remainSec / 60).toFixed(1) + ' min') : '';
        }
        if (procCancel) {
            setBar(done, ids.length, 'Stopped by user', 'err');
            showNotification('Process stopped (' + done + ' / ' + ids.length + ')');
        } else if (failed === 0) {
            setBar(done, ids.length, 'Selected Process Successful', 'done');
            showNotification('Selected Process Successful');
        } else {
            setBar(done, ids.length, 'Completed with errors', 'err');
            showNotification(failed + ' failed. ' + firstErr);
        }
    } catch (e) {
        setBar(done, ids.length, 'Error: ' + e.message, 'err');
        showNotification('Error: ' + e.message);
    } finally {
        procRunning = false;
        btn.disabled = false; stop.style.display = 'none';
    }
}
function stopProcess() { procCancel = true; }
</script>
</body>
</html>
