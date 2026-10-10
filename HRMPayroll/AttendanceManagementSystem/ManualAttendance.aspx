<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ManualAttendance.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.AttendanceManagementSystem.ManualAttendance" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manual Attendance Entry</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; }
        ::-webkit-scrollbar{width:6px;height:6px}
        ::-webkit-scrollbar-track{background:#f1f5f9}
        ::-webkit-scrollbar-thumb{background:#cbd5e1;border-radius:3px}
        ::-webkit-scrollbar-thumb:hover{background:#94a3b8}

        /* Common Field Styles matching previous page */
        .fld {
            display: block; width: 100%; height: 32px; padding: 0 10px;
            border: 1px solid #d9dce5; border-radius: 6px; background: #f6f7fb;
            font-size: 13px; color: #1e293b; outline: none;
            transition: border-color .15s, box-shadow .15s, background .15s;
        }
        .fld:hover { border-color: #b6bccb; }
        .fld:focus { border-color: #3b82f6; box-shadow: 0 0 0 3px rgba(59,130,246,.15); background: #fff; }

        .lbl { display: block; font-size: 12.5px; font-weight: 500; color: #475569; margin-bottom: 4px; }

        /* ===== Multi-select (Attendance Process পেজের মতো) ===== */
        select.ms-src{width:100%;min-height:32px;font-size:13px;border:1px solid #d9dce5;border-radius:6px}
        .msf{display:flex;align-items:center;justify-content:space-between;gap:6px;height:32px;padding:0 10px;
             border:1px solid #d9dce5;border-radius:6px;background:#f6f7fb;font-size:13px;color:#94a3b8;
             cursor:pointer;user-select:none;transition:border-color .15s, box-shadow .15s, background .15s;width:100%}
        .msf:hover{border-color:#b6bccb}
        .msf:focus,.msf.open{outline:none;border-color:#3b82f6;box-shadow:0 0 0 3px rgba(59,130,246,.15)}
        .msf.has{background:#fafaee;border-color:#d8dbc9;color:#1e293b}
        .msf .txt{flex:1;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;text-align:left}
        .msf .clr{display:none;color:#64748b;font-size:11px;padding:3px;border-radius:4px}
        .msf .clr:hover{background:#e2e8f0;color:#0f172a}
        .msf.has .clr{display:inline-block}
        .msf .chev{color:#64748b;font-size:11px}

        .msp{position:absolute;left:0;top:calc(100% + 4px);width:100%;background:#fff;border:1px solid #e2e8f0;
             border-radius:8px;box-shadow:0 10px 25px -5px rgba(15,23,42,.18),0 4px 10px -6px rgba(15,23,42,.12);z-index:60}
        .msp .ph{display:flex;align-items:center;justify-content:space-between;padding:8px 10px;font-size:12px;color:#64748b;border-bottom:1px solid #eef0f4}
        .msp .ph button{color:#ef4444;font-size:12px;background:none;border:0;cursor:pointer}
        .msp .ph button:hover{text-decoration:underline}
        .msp .ps{display:flex;align-items:center;gap:8px;padding:8px 10px;border-bottom:1px solid #eef0f4}
        .msp .ps i{color:#94a3b8;font-size:13px}
        .msp .ps input{flex:1;border:0;outline:0;font-size:13px;color:#334155;background:transparent;min-width:0}
        .msp .pl{max-height:200px;overflow-y:auto;padding:6px}
        .msp .it{display:flex;align-items:center;gap:10px;padding:7px 8px;border-radius:6px;font-size:13px;color:#1e293b;cursor:pointer}
        .msp .it:hover{background:#f1f5f9}
        .msp .empty{padding:14px 8px;font-size:12px;color:#94a3b8;text-align:center}
        .cb{width:16px;height:16px;border-radius:4px;border:1.5px solid #cbd5e1;background:#fff;display:inline-flex;align-items:center;justify-content:center;flex-shrink:0;color:#fff;font-size:9px}
        .cb.on{background:#2563eb;border-color:#2563eb}

        /* Grid Styles */
        .custom-grid { width: 100%; border-collapse: collapse; }
        .custom-grid th {
            background: #f8fafc; border-bottom: 1px solid #e2e8f0;
            padding: 10px 12px; font-size: 11px; font-weight: 600;
            color: #64748b; text-transform: uppercase; text-align: left;
            position: sticky; top: 0; z-index: 10;
        }
        .custom-grid td {
            padding: 8px 12px; font-size: 13px; color: #1e293b;
            border-bottom: 1px solid #f1f5f9;
        }
        .custom-grid tr:hover td { background: #f8fafc; }

        /* Button Styles */
        .btn { height: 32px; padding: 0 14px; border-radius: 6px; font-size: 13px; font-weight: 500; display: inline-flex; align-items: center; justify-content: center; gap: 6px; cursor: pointer; transition: all .15s; }
        .btn-primary { background: #2563eb; color: #fff; border: none; }
        .btn-primary:hover { background: #1d4ed8; }
        .btn-secondary { background: #fff; color: #475569; border: 1px solid #cbd5e1; }
        .btn-secondary:hover { background: #f8fafc; }
        .btn-danger { background: #e11d48; color: #fff; border: none; }
        .btn-danger:hover { background: #be123c; }
    </style>
</head>
<body class="bg-slate-100 text-slate-800 antialiased h-screen flex flex-col overflow-hidden">
    <form id="form1" runat="server" class="h-screen flex flex-col overflow-hidden" autocomplete="off">

        <!-- Top Header -->
        <header class="bg-white border-b border-slate-300 px-4 py-2 shrink-0 flex items-center justify-between shadow-sm z-20">
            <div class="flex items-center gap-2">
                <i class="fa-solid fa-user-clock text-blue-600"></i>
                <h1 class="text-sm font-bold text-slate-800">Manual Attendance Entry</h1>
            </div>
        </header>

        <!-- Main Content Area -->
        <div class="flex-1 flex overflow-hidden">

            <!-- Left Panel: Filters & Entry Form -->
            <div class="w-[340px] bg-white border-r border-slate-300 flex flex-col shrink-0 overflow-y-auto">
                <div class="p-4 space-y-3.5 flex-1">

                    <div class="flex items-center gap-3">
                        <label class="w-24 text-right lbl mb-0">Employee Status</label>
                        <asp:DropDownList ID="ddStatus" runat="server" CssClass="fld flex-1">
                            <asp:ListItem Text="Active" Value="1" />
                            <asp:ListItem Text="All" Value="7" />
                        </asp:DropDownList>
                    </div>

                    <div class="flex items-center gap-3">
                        <label class="w-24 text-right lbl mb-0">Category</label>
                        <div class="flex-1 min-w-0"><asp:ListBox ID="lbCategory" runat="server" SelectionMode="Multiple" CssClass="ms-src" /></div>
                    </div>

                    <div class="flex items-center gap-3">
                        <label class="w-24 text-right lbl mb-0">Department</label>
                        <div class="flex-1 min-w-0"><asp:ListBox ID="lbDept" runat="server" SelectionMode="Multiple" CssClass="ms-src" /></div>
                    </div>

                    <div class="flex items-center gap-3">
                        <label class="w-24 text-right lbl mb-0">Section</label>
                        <div class="flex-1 min-w-0"><asp:ListBox ID="lbSection" runat="server" SelectionMode="Multiple" CssClass="ms-src" /></div>
                    </div>

                    <div class="flex items-center gap-3">
                        <label class="w-24 text-right lbl mb-0">Sub Section</label>
                        <div class="flex-1 min-w-0"><asp:ListBox ID="lbSubSec" runat="server" SelectionMode="Multiple" CssClass="ms-src" /></div>
                    </div>

                    <div class="flex items-center gap-3">
                        <label class="w-24 text-right lbl mb-0">Designation</label>
                        <div class="flex-1 min-w-0"><asp:ListBox ID="lbDesig" runat="server" SelectionMode="Multiple" CssClass="ms-src" /></div>
                    </div>

                    <!-- Multi Date Section -->
                    <div class="flex items-center gap-3">
                        <div class="w-24 flex items-center justify-end gap-1.5">
                            <asp:CheckBox ID="chkMultiDate" runat="server" CssClass="w-3.5 h-3.5 text-blue-600 rounded border-slate-300 focus:ring-blue-500" />
                            <label class="lbl mb-0 cursor-pointer" for="chkMultiDate">Multi Date</label>
                        </div>
                        <div class="flex-1 flex gap-1.5">
                            <asp:TextBox ID="txtFromDate" runat="server" TextMode="Date" CssClass="fld w-1/2 px-1 text-xs" />
                            <asp:TextBox ID="txtToDate" runat="server" TextMode="Date" CssClass="fld w-1/2 px-1 text-xs" />
                        </div>
                    </div>

                    <div class="flex items-start gap-3">
                        <label class="w-24 text-right lbl mt-1">ID</label>
                        <asp:TextBox ID="txtEmpIds" runat="server" TextMode="MultiLine" Rows="3" CssClass="fld flex-1 h-auto py-1.5 resize-none" placeholder="Comma separated IDs..." />
                    </div>

                    <!-- Attendance Type (Att_status_Type টেবিল থেকে লোড হয়; কিছু সিলেক্ট না করলে = সব) -->
                    <div class="flex items-center gap-3">
                        <label class="w-24 text-right lbl mb-0">Attendance Type</label>
                        <div class="flex-1 min-w-0">
                            <asp:ListBox ID="lbAttType" runat="server" SelectionMode="Multiple" CssClass="ms-src">
                                <asp:ListItem Text="Absent" Value="Absent" />
                                <asp:ListItem Text="Present" Value="Present" />
                                <asp:ListItem Text="Late" Value="Late" />
                                <asp:ListItem Text="WO" Value="WO" />
                                <asp:ListItem Text="FH" Value="FH" />
                                <asp:ListItem Text="GH" Value="GH" />
                            </asp:ListBox>
                        </div>
                    </div>

                    <!-- Action Buttons -->
                    <div class="flex items-center gap-3 pt-2">
                        <div class="w-24"></div>
                        <div class="flex-1 flex gap-2">
                            <asp:Button ID="btnShow" runat="server" Text="Show" CssClass="btn btn-primary flex-1" OnClick="btnShow_Click" />
                            <button type="button" class="btn btn-secondary flex-1" onclick="selectAllGrid(true)">All</button>
                            <button type="button" class="btn btn-secondary flex-1" onclick="selectAllGrid(false)">None</button>
                        </div>
                    </div>

                    <hr class="border-slate-200 my-2" />

                    <!-- Time Entry Section -->
                    <div class="space-y-3">
                        <div class="flex items-center gap-3">
                            <div class="w-24 flex items-center justify-end gap-1.5">
                                <asp:CheckBox ID="chkIn" runat="server" CssClass="w-3.5 h-3.5 text-blue-600 rounded border-slate-300 focus:ring-blue-500" />
                                <label class="lbl mb-0 cursor-pointer" for="chkIn">In</label>
                            </div>
                            <asp:TextBox ID="txtInTime" runat="server" TextMode="Time" CssClass="fld w-32 px-2" />
                        </div>

                        <div class="flex items-center gap-3">
                            <div class="w-24 flex items-center justify-end gap-1.5">
                                <asp:CheckBox ID="chkOut" runat="server" CssClass="w-3.5 h-3.5 text-blue-600 rounded border-slate-300 focus:ring-blue-500" />
                                <label class="lbl mb-0 cursor-pointer" for="chkOut">Out</label>
                            </div>
                            <asp:TextBox ID="txtOutTime" runat="server" TextMode="Time" CssClass="fld w-32 px-2" />
                            <div class="flex items-center gap-1.5 ml-2">
                                <asp:CheckBox ID="chkFullNight" runat="server" CssClass="w-3.5 h-3.5 text-blue-600 rounded border-slate-300 focus:ring-blue-500" />
                                <label class="lbl mb-0 cursor-pointer" for="chkFullNight">Full Night</label>
                            </div>
                        </div>
                    </div>

                    <!-- Save/Delete Buttons -->
                    <div class="flex items-center gap-3 pt-4">
                        <div class="w-24"></div>
                        <div class="flex-1 flex gap-2">
                            <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn btn-primary flex-1" OnClick="btnSave_Click" />
                            <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="btn btn-danger flex-1" OnClick="btnDelete_Click" OnClientClick="return confirm('সিলেক্ট করা রো গুলোর Manual Attendance Delete করবেন?');" />
                        </div>
                    </div>

                </div>
            </div>

            <!-- Right Panel: Data Grid -->
            <div class="flex-1 flex flex-col bg-white overflow-hidden">
                <div class="flex-1 overflow-auto">
                    <table class="custom-grid">
                        <thead>
                            <tr>
                                <th class="w-10 text-center"><input type="checkbox" id="chkSelectAll" class="rounded w-4 h-4 cursor-pointer" onchange="selectAllGrid(this.checked)" /></th>
                                <th>Emp_ID</th>
                                <th>Employee Name</th>
                                <th>Designation</th>
                                <th>Work Date</th>
                                <th>In Time</th>
                                <th>Out Time</th>
                                <th>Att. Status</th>
                                <th>Late Min</th>
                                <th>OT Hour</th>
                            </tr>
                        </thead>
                        <tbody id="tableBody">
                            <asp:Literal ID="litGridRows" runat="server" />
                        </tbody>
                    </table>
                </div>
            </div>

        </div>
    </form>

<script>
// @ts-nocheck
const esc = s => String(s).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));

// ---------- গ্রিডের সব রো সিলেক্ট / আনসিলেক্ট ----------
function selectAllGrid(state) {
    document.querySelectorAll('input[name="rowChk"]').forEach(function (cb) { cb.checked = state; });
    var h = document.getElementById('chkSelectAll');
    if (h) h.checked = state;
}

// ---------- Multi Date টিক না থাকলে To Date লুকানো (Desktop এর মতো) ----------
function syncMultiDate() {
    var chk = document.getElementById('<%= chkMultiDate.ClientID %>');
    var to = document.getElementById('<%= txtToDate.ClientID %>');
    if (chk && to) to.style.visibility = chk.checked ? 'visible' : 'hidden';
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
            fld.className = 'msf'; fld.tabIndex = 0;
            fld.innerHTML = '<span class="txt"></span><i class="fa-solid fa-xmark clr" title="Clear"></i><i class="fa-solid fa-chevron-down chev"></i>';
            wrap.appendChild(fld);

            var panel = document.createElement('div');
            panel.className = 'msp'; panel.style.display = 'none';
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
                document.querySelectorAll('.msp').forEach(function (p) { p.style.display = 'none'; });
                document.querySelectorAll('.msf.open').forEach(function (f) { f.classList.remove('open'); });
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
        if (e.target.closest('.msp') || e.target.closest('.msf')) return;
        document.querySelectorAll('.msp').forEach(function (p) { p.style.display = 'none'; });
        document.querySelectorAll('.msf.open').forEach(function (f) { f.classList.remove('open'); });
    });
}

document.addEventListener('DOMContentLoaded', function () {
    try { initMulti(); } catch (err) { console.error('initMulti error:', err); }
    var chk = document.getElementById('<%= chkMultiDate.ClientID %>');
    if (chk) chk.addEventListener('change', syncMultiDate);
    syncMultiDate();
});
</script>
</body>
</html>
