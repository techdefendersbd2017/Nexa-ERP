<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ShiftChangeing.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.AttendanceManagementSystem.ShiftChangeing" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Shift Change</title>
<script src="https://cdn.tailwindcss.com"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<link href="https://fonts.googleapis.com/css2?family=Hind+Siliguri:wght@400;500;600;700&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
<style>
body{font-family:'Inter','Hind Siliguri',sans-serif}
@media print{.no-print{display:none!important}}
::-webkit-scrollbar{width:6px;height:6px}::-webkit-scrollbar-thumb{background:#cbd5e1;border-radius:3px}
.fld{display:flex;align-items:center;justify-content:space-between;gap:6px;height:34px;padding:0 10px;border:1px solid #d9dce5;border-radius:8px;background:#f8fafc;font-size:13px;color:#94a3b8;cursor:pointer;width:100%}
.fld:hover{border-color:#b6bccb}.fld.open,.fld:focus{outline:0;border-color:#3b82f6;box-shadow:0 0 0 3px rgba(59,130,246,.15)}
.fld.has{background:#f0f6ff;border-color:#bfd4f6;color:#1e293b}
.fld .txt{flex:1;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.fld .clr{display:none;color:#64748b;font-size:11px}.fld.has .clr{display:inline-block}
input.fld,select.fld,textarea.fld{color:#1e293b;cursor:text;display:block}select.fld{cursor:pointer}
textarea.fld{height:auto;padding:6px 10px;resize:vertical}
select.ms-src{width:100%;min-height:34px;font-size:13px}
.panel{position:absolute;left:0;top:calc(100% + 4px);width:100%;min-width:220px;background:#fff;border:1px solid #e2e8f0;border-radius:10px;box-shadow:0 10px 25px -5px rgba(15,23,42,.2);z-index:60}
.g2>div:nth-child(even) .panel{left:auto;right:0}
.panel .ph{display:flex;justify-content:space-between;padding:8px 10px;font-size:12px;color:#64748b;border-bottom:1px solid #eef0f4}
.panel .ph button{color:#ef4444}
.panel .ps{display:flex;gap:8px;padding:8px 10px;border-bottom:1px solid #eef0f4}.panel .ps input{flex:1;border:0;outline:0;font-size:13px;min-width:0}
.panel .pl{max-height:180px;overflow-y:auto;padding:6px}
.panel .it{display:flex;align-items:center;gap:10px;padding:6px 8px;border-radius:6px;font-size:13px;cursor:pointer}.panel .it:hover{background:#f1f5f9}
.panel .empty{padding:12px;font-size:12px;color:#94a3b8;text-align:center}
.cb{width:16px;height:16px;border-radius:4px;border:1.5px solid #cbd5e1;display:inline-flex;align-items:center;justify-content:center;color:#fff;font-size:9px;flex-shrink:0}.cb.on{background:#2563eb;border-color:#2563eb}
.lbl{display:block;font-size:12px;color:#475569;margin-bottom:4px}
.card{background:#fff;border:1px solid #e2e8f0;border-radius:12px;padding:12px}
.ct{font-size:13px;font-weight:600;color:#334155;margin-bottom:10px;display:flex;gap:8px;align-items:center}
.btn{height:34px;padding:0 14px;border-radius:8px;font-size:13px;font-weight:500;display:inline-flex;align-items:center;justify-content:center;gap:6px;border:1px solid #cbd5e1;background:#fff;color:#334155;cursor:pointer}
.btn:hover{background:#f1f5f9}.btn.p{background:#2563eb;border-color:#2563eb;color:#fff}.btn.p:hover{background:#1d4ed8}
.btn.d{background:#e11d48;border-color:#e11d48;color:#fff}.btn.d:hover{background:#be123c}.btn.w{width:100%;margin-top:8px}
.tabb{padding:10px 16px;font-size:13px;font-weight:600;color:#64748b;border-bottom:2px solid transparent}.tabb.on{color:#2563eb;border-color:#2563eb}
#tab_assign th{position:sticky;top:0;background:#f8fafc;z-index:5}
</style>
</head>
<body class="bg-slate-100 text-slate-800 antialiased h-screen flex flex-col overflow-hidden">
<form id="form1" runat="server" class="flex flex-col h-screen overflow-hidden" autocomplete="off">
<asp:HiddenField ID="hfSelIds" runat="server" ClientIDMode="Static" />
<asp:HiddenField ID="hfTab" runat="server" ClientIDMode="Static" Value="assign" />

<header class="bg-white border-b border-slate-200 px-6 flex items-center gap-6 shrink-0">
  <h1 class="text-base font-bold py-3"><i class="fa-solid fa-clock-rotate-left text-blue-600 mr-2"></i>Shift Change</h1>
  <nav class="flex">
    <button type="button" id="btn_assign" class="tabb on" onclick="tab('assign')">Change shift</button>
    <button type="button" id="btn_saved" class="tabb" onclick="tab('saved')">Saved shifts</button>
  </nav>
</header>

<%-- ================= TAB 1: Change shift ================= --%>
<div id="tab_assign" class="flex-1 flex min-h-0">
  <aside class="w-[440px] shrink-0 bg-slate-50 border-r border-slate-200 overflow-y-auto p-4 space-y-3">
    <div class="card">
      <div class="ct"><i class="fa-solid fa-id-badge text-blue-600"></i>Find by ID</div>
      <label class="lbl">Employee status</label>
      <asp:DropDownList ID="ddStatus" runat="server" CssClass="fld" />
      <label class="lbl mt-2">ID No (comma separated)</label>
      <asp:TextBox ID="txtIds" runat="server" TextMode="MultiLine" Rows="2" CssClass="fld" placeholder="e.g. 1001, 1002, 1003" />
      <asp:LinkButton ID="btnIds" runat="server" OnClick="btnIds_Click" CssClass="btn w"><i class="fa-regular fa-eye text-xs"></i>Show employees</asp:LinkButton>
    </div>

    <div class="card">
      <div class="ct"><i class="fa-solid fa-filter text-blue-600"></i>Find by filter</div>
      <div class="grid grid-cols-2 gap-x-3 gap-y-2 g2">
        <div><label class="lbl">Branch</label><asp:ListBox ID="ddBranch" runat="server" SelectionMode="Multiple" CssClass="ms-src" /></div>
        <div><label class="lbl">Category</label><asp:ListBox ID="ddCategory" runat="server" SelectionMode="Multiple" CssClass="ms-src" /></div>
        <div><label class="lbl">Department</label><asp:ListBox ID="ddDept" runat="server" SelectionMode="Multiple" CssClass="ms-src" /></div>
        <div><label class="lbl">Section</label><asp:ListBox ID="ddSection" runat="server" SelectionMode="Multiple" CssClass="ms-src" /></div>
        <div><label class="lbl">Sub section</label><asp:ListBox ID="ddSubSec" runat="server" SelectionMode="Multiple" CssClass="ms-src" /></div>
        <div><label class="lbl">Floor</label><asp:ListBox ID="ddFloor" runat="server" SelectionMode="Multiple" CssClass="ms-src" /></div>
        <div><label class="lbl">Designation</label><asp:ListBox ID="ddDesig" runat="server" SelectionMode="Multiple" CssClass="ms-src" /></div>
        <div><label class="lbl">Designation level</label><asp:ListBox ID="ddLevel" runat="server" SelectionMode="Multiple" CssClass="ms-src" /></div>
        <div><label class="lbl">Current shift</label><asp:ListBox ID="ddShiftF" runat="server" SelectionMode="Multiple" CssClass="ms-src" /></div>
      </div>
      <asp:LinkButton ID="btnFilter" runat="server" OnClick="btnFilter_Click" CssClass="btn p w"><i class="fa-solid fa-magnifying-glass text-xs"></i>Show employees</asp:LinkButton>
      <p class="text-[11px] text-slate-400 mt-2">New / Seperation status uses the From and Till dates below the table.</p>
    </div>

    <div class="card">
      <div class="ct"><i class="fa-solid fa-people-group text-blue-600"></i>Find by team</div>
      <asp:DropDownList ID="ddTeam" runat="server" CssClass="fld" />
      <asp:LinkButton ID="btnTeam" runat="server" OnClick="btnTeam_Click" CssClass="btn w">Search by team</asp:LinkButton>
    </div>

    <div class="card">
      <div class="ct"><i class="fa-solid fa-calendar-day text-blue-600"></i>Find by shift and date</div>
      <div class="grid grid-cols-2 gap-3">
        <div><label class="lbl">From shift</label><asp:DropDownList ID="ddFromShift" runat="server" CssClass="fld" /></div>
        <div><label class="lbl">Date</label><asp:TextBox ID="txtShiftDate" runat="server" TextMode="Date" CssClass="fld" /></div>
      </div>
      <asp:LinkButton ID="btnShiftSearch" runat="server" OnClick="btnShiftSearch_Click" CssClass="btn w">Search by date and shift</asp:LinkButton>
    </div>
  </aside>

  <main class="flex-1 flex flex-col min-w-0 min-h-0">
    <div class="bg-white border-b border-slate-200 px-6 py-3 flex flex-wrap items-center justify-between gap-3 shrink-0">
      <div class="flex items-center gap-2">
        <h2 class="text-base font-bold">Employees</h2>
        <asp:Label ID="lblCount" runat="server" CssClass="bg-indigo-50 text-indigo-700 text-xs font-semibold px-2.5 py-0.5 rounded-full border border-indigo-100" Text="0 records" />
        <asp:Label ID="lblSrc" runat="server" CssClass="text-xs text-slate-400" />
      </div>
      <div class="flex items-center gap-2">
        <input type="text" placeholder="Quick filter..." oninput="filt(this,'bodyA')" onkeydown="if(event.key==='Enter')return false;" class="bg-slate-50 border border-slate-300 rounded-lg px-3 py-1.5 text-xs w-48 focus:outline-none focus:ring-2 focus:ring-indigo-500">
        <button type="button" class="btn" onclick="selAll(true)">Select all</button>
        <button type="button" class="btn" onclick="selAll(false)">Deselect</button>
      </div>
    </div>
    <div class="flex-1 p-4 min-h-0">
      <div class="bg-white border border-slate-200 rounded-xl h-full overflow-auto">
        <table class="w-full text-left border-collapse">
          <thead><tr class="border-b border-slate-200 text-xs font-semibold text-slate-600">
            <th class="py-3 px-4 w-12 text-center"><input type="checkbox" id="selectAllRows" onchange="selAll(this.checked)" class="w-4 h-4"></th>
            <th class="py-3 px-4">ID No</th><th class="py-3 px-4">Name</th><th class="py-3 px-4">Designation</th>
            <th class="py-3 px-4">Emp No</th><th class="py-3 px-4">Date</th><th class="py-3 px-4">Shift</th>
          </tr></thead>
          <tbody id="bodyA" class="divide-y divide-slate-100 text-xs text-slate-700">
            <asp:Repeater ID="rptEmp" runat="server"><ItemTemplate>
              <tr class="hover:bg-slate-50">
                <td class="py-2.5 px-4 text-center"><input type="checkbox" name="selId" class="row-checkbox w-4 h-4" value='<%# Server.HtmlEncode(Convert.ToString(Eval("Id"))) %>' data-id='<%# Server.HtmlEncode(Convert.ToString(Eval("Id"))) %>'></td>
                <td class="py-2.5 px-4 font-semibold text-slate-900"><%# Server.HtmlEncode(Convert.ToString(Eval("Id"))) %></td>
                <td class="py-2.5 px-4 font-medium"><%# Server.HtmlEncode(Convert.ToString(Eval("Name"))) %></td>
                <td class="py-2.5 px-4"><%# Server.HtmlEncode(Convert.ToString(Eval("Designation"))) %></td>
                <td class="py-2.5 px-4"><%# Server.HtmlEncode(Convert.ToString(Eval("EmpNo"))) %></td>
                <td class="py-2.5 px-4"><%# Server.HtmlEncode(Convert.ToString(Eval("Date"))) %></td>
                <td class="py-2.5 px-4"><%# Server.HtmlEncode(Convert.ToString(Eval("Shift"))) %></td>
              </tr>
            </ItemTemplate></asp:Repeater>
            <tr id="trEmpty" runat="server"><td colspan="7" class="text-center py-10 text-slate-400">Search for employees using the options on the left.</td></tr>
          </tbody>
        </table>
      </div>
    </div>

    <div class="bg-white border-t border-slate-200 px-6 py-3 flex flex-wrap items-end gap-3 shrink-0">
      <div class="w-56"><label class="lbl">To shift</label><asp:DropDownList ID="ddToShift" runat="server" CssClass="fld" /></div>
      <div class="w-40"><label class="lbl">From date</label><asp:TextBox ID="txtFrom" runat="server" TextMode="Date" CssClass="fld" /></div>
      <div class="pb-2"><label class="text-xs text-slate-600 flex items-center gap-1.5 cursor-pointer"><asp:CheckBox ID="chkRange" runat="server" ClientIDMode="Static" onclick="rng()" />Date range</label></div>
      <div id="tillBox" class="w-40"><label class="lbl">Till date</label><asp:TextBox ID="txtTill" runat="server" TextMode="Date" CssClass="fld" /></div>
      <div class="ml-auto flex items-center gap-3">
        <span class="text-xs text-slate-500"><b id="selCnt">0</b> selected</span>
        <asp:LinkButton ID="btnDelete" runat="server" OnClick="btnDelete_Click" OnClientClick="return confirm('Delete the shift change for the selected employees?');" CssClass="btn d"><i class="fa-regular fa-trash-can text-xs"></i>Delete</asp:LinkButton>
        <asp:LinkButton ID="btnSave" runat="server" OnClick="btnSave_Click" CssClass="btn p"><i class="fa-regular fa-floppy-disk text-xs"></i>Save shift</asp:LinkButton>
      </div>
    </div>
  </main>
</div>

<%-- ================= TAB 2: Saved shifts (Duty Roster design) ================= --%>
<div id="tab_saved" class="flex-1 flex-col min-h-0 overflow-y-auto bg-slate-50" style="display:none">
<div class="max-w-7xl w-full mx-auto px-6 py-6">

  <header class="bg-white rounded-2xl shadow-sm border border-slate-200/80 p-5 sm:p-6 mb-6">
    <div class="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">
      <div class="flex items-start sm:items-center gap-4">
        <div class="w-12 h-12 rounded-xl bg-gradient-to-br from-indigo-600 to-blue-600 text-white flex items-center justify-center shadow-md shadow-indigo-200 shrink-0"><i class="fa-solid fa-calendar-check text-xl"></i></div>
        <div>
          <div class="flex flex-wrap items-center gap-2">
            <h1 class="text-2xl sm:text-3xl font-bold text-slate-900 tracking-tight">Saved Shift Roster</h1>
            <span class="px-2.5 py-0.5 text-xs font-semibold bg-indigo-50 text-indigo-700 border border-indigo-200 rounded-full">Weekly schedule</span>
          </div>
          <p class="text-sm text-slate-500 mt-0.5">View saved shifts by team or ID in a weekly grid</p>
        </div>
      </div>
      <div class="flex flex-wrap items-center gap-2.5 no-print">
        <button type="button" onclick="exportCsv('rosterBody')" class="inline-flex items-center gap-2 px-4 py-2.5 bg-emerald-600 hover:bg-emerald-700 text-white text-sm font-semibold rounded-xl shadow-sm shadow-emerald-200 transition-all"><i class="fa-solid fa-file-csv"></i><span>Export CSV</span></button>
        <button type="button" onclick="window.print()" class="inline-flex items-center gap-2 px-4 py-2.5 bg-white hover:bg-slate-50 text-slate-700 border border-slate-300 text-sm font-semibold rounded-xl shadow-sm transition-all"><i class="fa-solid fa-print text-slate-500"></i><span>Print</span></button>
      </div>
    </div>

    <div class="mt-5 pt-5 border-t border-slate-100 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3 items-end no-print">
      <div><label class="lbl">Team</label><asp:DropDownList ID="ddSvTeam" runat="server" CssClass="fld" /></div>
      <div><label class="lbl">Multi ID No</label><asp:TextBox ID="txtSvIds" runat="server" CssClass="fld" placeholder="e.g. 1001, 1002…" /></div>
      <div><label class="lbl">Date (shows that week)</label><asp:TextBox ID="txtSvFrom" runat="server" TextMode="Date" CssClass="fld" /></div>
      <div><asp:LinkButton ID="btnSvShow" runat="server" OnClick="btnSvShow_Click" CssClass="h-9 px-5 rounded-xl bg-indigo-600 hover:bg-indigo-700 text-white text-sm font-semibold inline-flex items-center gap-2 shadow-sm shadow-indigo-200 transition-all"><i class="fa-solid fa-magnifying-glass text-xs"></i><span>Show</span></asp:LinkButton>
        <asp:LinkButton ID="btnSvClear" runat="server" OnClick="btnSvClear_Click" CssClass="h-9 px-4 ml-2 rounded-xl border border-slate-300 bg-white hover:bg-slate-50 text-slate-700 text-sm font-semibold inline-flex items-center gap-2 transition-all"><i class="fa-solid fa-eraser text-xs"></i><span>Reset</span></asp:LinkButton></div>
    </div>

    <div class="mt-5 pt-5 border-t border-slate-100 flex flex-col xl:flex-row xl:items-center justify-between gap-4">
      <div class="flex flex-wrap items-center gap-2 no-print">
        <div class="inline-flex items-center bg-slate-100 p-1 rounded-xl border border-slate-200/70">
          <asp:LinkButton ID="btnWkPrev" runat="server" OnClick="btnWkPrev_Click" CssClass="p-2 hover:bg-white hover:shadow-sm rounded-lg text-slate-600 transition-all" ToolTip="Previous week"><i class="fa-solid fa-chevron-left text-xs"></i></asp:LinkButton>
          <div class="px-3 py-1 flex items-center gap-2 text-sm font-semibold text-slate-800"><i class="fa-regular fa-calendar text-indigo-600"></i><asp:Label ID="lblWeek" runat="server" /></div>
          <asp:LinkButton ID="btnWkNext" runat="server" OnClick="btnWkNext_Click" CssClass="p-2 hover:bg-white hover:shadow-sm rounded-lg text-slate-600 transition-all" ToolTip="Next week"><i class="fa-solid fa-chevron-right text-xs"></i></asp:LinkButton>
        </div>
        <asp:LinkButton ID="btnWkCur" runat="server" OnClick="btnWkCur_Click" CssClass="px-3 py-2 text-xs font-semibold text-indigo-600 bg-indigo-50 hover:bg-indigo-100 rounded-xl transition-colors">Current week</asp:LinkButton>
      </div>
      <div class="flex flex-col sm:flex-row items-stretch sm:items-center gap-3 no-print">
        <div class="flex items-center gap-1.5 overflow-x-auto pb-1 sm:pb-0"><asp:Literal ID="litPills" runat="server" /></div>
        <div class="relative min-w-[230px]">
          <i class="fa-solid fa-magnifying-glass absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-sm"></i>
          <input type="text" oninput="handleSearch(this.value)" onkeydown="if(event.key==='Enter')return false;" placeholder="Search by name or ID..." class="w-full pl-9 pr-4 py-2 text-sm bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-indigo-500/30 focus:border-indigo-500 focus:bg-white transition-all">
        </div>
      </div>
    </div>
  </header>

  <div class="bg-white rounded-t-2xl border border-b-0 border-slate-200/80 px-5 py-3.5 flex flex-wrap items-center gap-4 text-xs">
    <span class="font-semibold text-slate-600">Shift legend:</span><asp:Literal ID="litLegend" runat="server" />
  </div>
  <div class="bg-white rounded-b-2xl shadow-sm border border-slate-200/80 overflow-hidden">
    <div class="overflow-x-auto">
      <table class="w-full text-left border-collapse min-w-[980px]"><asp:Literal ID="litRoster" runat="server" /></table>
    </div>
  </div>
</div>
</div>

<div id="toastContainer" class="fixed bottom-5 right-5 z-50 flex flex-col gap-2 pointer-events-none"></div>
</form>

<script>
var $ = function (i) { return document.getElementById(i); };
var esc = function (s) { return String(s).replace(/[&<>"']/g, function (c) { return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]; }); };

function collectIds() {
    var ids = [];
    document.querySelectorAll('.row-checkbox:checked').forEach(function (c) { ids.push(c.getAttribute('data-id') || c.value); });
    $('hfSelIds').value = ids.join(',');
    return true;
}
function updCnt() { $('selCnt').textContent = document.querySelectorAll('.row-checkbox:checked').length; }
function selAll(on) {
    document.querySelectorAll('.row-checkbox').forEach(function (c) { c.checked = on; });
    $('selectAllRows').checked = on; updCnt();
}
function filt(inp, body) {
    var q = inp.value.toLowerCase();
    document.querySelectorAll('#' + body + ' tr').forEach(function (tr) {
        if (tr.id && tr.id.indexOf('Empty') > -1) return;
        tr.style.display = tr.textContent.toLowerCase().indexOf(q) > -1 ? '' : 'none';
    });
}
function rng() { var on = $('chkRange').checked; $('tillBox').style.opacity = on ? 1 : .4; }
function tab(t) {
    $('hfTab').value = t;
    ['assign', 'saved'].forEach(function (x) {
        $('tab_' + x).style.display = x === t ? 'flex' : 'none';
        $('btn_' + x).className = 'tabb' + (x === t ? ' on' : '');
    });
}
var shFlt = 'ALL', shQ = '';
function setShiftFilter(c) {
    shFlt = c;
    document.querySelectorAll('.filter-btn').forEach(function (b) {
        var on = b.getAttribute('data-filter') === c;
        ['ring-2', 'ring-offset-1', 'ring-indigo-500'].forEach(function (k) { b.classList.toggle(k, on); });
    });
    applyRoster();
}
function handleSearch(v) { shQ = v.trim().toLowerCase(); applyRoster(); }
function applyRoster() {
    document.querySelectorAll('#rosterBody tr[data-s]').forEach(function (tr) {
        var ok = (!shQ || tr.getAttribute('data-s').indexOf(shQ) > -1) && (shFlt === 'ALL' || !!tr.querySelector('[data-sh="' + shFlt + '"]'));
        tr.style.display = ok ? '' : 'none';
        tr.querySelectorAll('[data-sh]').forEach(function (c) { c.style.opacity = (shFlt === 'ALL' || c.getAttribute('data-sh') === shFlt) ? 1 : .35; });
    });
}
function exportCsv(body) {
    var rows = [], h = [];
    document.querySelectorAll('#' + body).forEach(function (tb) {
        h = Array.prototype.map.call(tb.closest('table').querySelectorAll('thead th'), function (t) { return t.textContent.replace(/\s+/g, ' ').trim(); });
        tb.querySelectorAll('tr').forEach(function (tr) {
            if (tr.style.display === 'none' || tr.id) return;
            rows.push(Array.prototype.map.call(tr.children, function (td) { return td.textContent.replace(/\s+/g, ' ').trim(); }));
        });
    });
    if (!rows.length) { showNotification('No data to export.'); return; }
    var csv = [h].concat(rows).map(function (r) { return r.map(function (v) { return '"' + v.replace(/"/g, '""') + '"'; }).join(','); }).join('\r\n');
    var a = document.createElement('a');
    a.href = URL.createObjectURL(new Blob(['\ufeff' + csv], { type: 'text/csv;charset=utf-8' }));
    a.download = 'saved_shifts.csv'; a.click();
}
function showNotification(m) {
    var t = document.createElement('div');
    t.className = 'bg-slate-900 text-white text-xs px-4 py-2.5 rounded-xl shadow-lg pointer-events-auto flex items-center gap-2';
    t.innerHTML = '<i class="fa-solid fa-circle-info text-indigo-400"></i><span>' + esc(m) + '</span>';
    $('toastContainer').appendChild(t);
    setTimeout(function () { t.remove(); }, 4000);
}

function initMulti() {
    document.querySelectorAll('select.ms-src').forEach(function (sel) {
        try {
            var wrap = document.createElement('div'); wrap.style.position = 'relative';
            sel.parentNode.insertBefore(wrap, sel); wrap.appendChild(sel);
            var fld = document.createElement('div'); fld.className = 'fld'; fld.tabIndex = 0;
            fld.innerHTML = '<span class="txt"></span><i class="fa-solid fa-xmark clr"></i><i class="fa-solid fa-chevron-down text-[11px] text-slate-500"></i>';
            wrap.appendChild(fld);
            var panel = document.createElement('div'); panel.className = 'panel'; panel.style.display = 'none';
            panel.innerHTML = '<div class="ph"><span class="cnt"></span><button type="button" class="clrAll">Clear all</button></div>' +
                '<div class="ps"><i class="fa-solid fa-search text-slate-400"></i><input type="text" placeholder="Search..."></div><div class="pl"></div>';
            wrap.appendChild(panel);
            var txt = fld.querySelector('.txt'), list = panel.querySelector('.pl'), cnt = panel.querySelector('.cnt'), q = panel.querySelector('input');
            function render() {
                var term = q.value.toLowerCase(), html = '', picked = [];
                for (var i = 0; i < sel.options.length; i++) {
                    var o = sel.options[i];
                    if (o.selected) picked.push(o.text);
                    if (term && o.text.toLowerCase().indexOf(term) < 0) continue;
                    html += '<div class="it" data-i="' + i + '"><span class="cb' + (o.selected ? ' on' : '') + '">' + (o.selected ? '<i class="fa-solid fa-check"></i>' : '') + '</span><span>' + esc(o.text) + '</span></div>';
                }
                list.innerHTML = html || '<div class="empty">No options</div>';
                cnt.textContent = picked.length + ' selected';
                txt.textContent = picked.length === 0 ? '-- All --' : (picked.length <= 2 ? picked.join(', ') : picked.length + ' selected');
                fld.classList.toggle('has', picked.length > 0);
            }
            function clearAll() { for (var i = 0; i < sel.options.length; i++) sel.options[i].selected = false; render(); }
            list.addEventListener('click', function (e) { var it = e.target.closest('.it'); if (!it) return; var o = sel.options[+it.getAttribute('data-i')]; o.selected = !o.selected; render(); });
            panel.querySelector('.clrAll').addEventListener('click', clearAll);
            fld.querySelector('.clr').addEventListener('click', function (e) { e.stopPropagation(); clearAll(); });
            fld.addEventListener('click', function () {
                var open = panel.style.display === 'none';
                document.querySelectorAll('.panel').forEach(function (p) { p.style.display = 'none'; });
                document.querySelectorAll('.fld.open').forEach(function (f) { f.classList.remove('open'); });
                panel.style.display = open ? 'block' : 'none'; fld.classList.toggle('open', open);
                if (open) { q.value = ''; render(); q.focus(); }
            });
            panel.addEventListener('click', function (e) { e.stopPropagation(); });
            q.addEventListener('keydown', function (e) { if (e.key === 'Enter') e.preventDefault(); });
            render(); sel.style.display = 'none';
        } catch (err) { console.error('multi-select failed', sel.id, err); sel.style.display = ''; }
    });
    document.addEventListener('click', function (e) {
        if (e.target.closest('.panel') || e.target.closest('.fld')) return;
        document.querySelectorAll('.panel').forEach(function (p) { p.style.display = 'none'; });
        document.querySelectorAll('.fld.open').forEach(function (f) { f.classList.remove('open'); });
    });
}

document.addEventListener('DOMContentLoaded', function () {
    try { initMulti(); } catch (err) { console.error(err); }
    var f = document.forms[0], old = f.onsubmit;
    f.onsubmit = function () { collectIds(); return old ? old.apply(this, arguments) : true; };
    document.addEventListener('change', function (e) { if (e.target.classList && e.target.classList.contains('row-checkbox')) updCnt(); });
    var ti = $('txtIds');
    tab($('hfTab').value || 'assign'); rng(); setTimeout(updCnt, 50);
});
</script>
</body>
</html>
