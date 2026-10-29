<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LatePermissionApproval.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.HRMApproval.LatePermissionApproval" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Late Permission Approval</title>
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

        /* ---- Filter fields ---- */
        .fld{display:flex;align-items:center;justify-content:space-between;gap:6px;height:32px;padding:0 10px;
             border:1px solid #d9dce5;border-radius:6px;background:#f6f7fb;font-size:13px;color:#1e293b;
             transition:border-color .15s, box-shadow .15s, background .15s;width:100%}
        .fld:hover{border-color:#b6bccb}
        .fld:focus{outline:none;border-color:#3b82f6;box-shadow:0 0 0 3px rgba(59,130,246,.15)}
        input.fld{cursor:text}
        input.fld::placeholder{color:#a0a7b5}
        input.fld.date{background:#f3f4f7;color:#334155}
        select.fld{cursor:pointer}
        .dt-wrap{position:relative}
        .dt-wrap i{position:absolute;right:10px;top:10px;color:#a0a7b5;font-size:12px;pointer-events:none}
        .lbl{display:block;font-size:13px;color:#334155;margin-bottom:6px}
        .chk-lbl{display:inline-flex;align-items:center;gap:6px;font-size:13px;color:#334155;margin-bottom:6px;cursor:pointer}
        .chk-lbl input{width:15px;height:15px}
        .note-cell{max-width:240px;overflow:hidden;text-overflow:ellipsis}
    </style>
</head>
<body class="bg-slate-100 text-slate-800 antialiased h-screen flex flex-col overflow-hidden">
<form id="form1" runat="server" class="flex flex-col h-screen overflow-hidden" autocomplete="off">
    <asp:HiddenField ID="hfSelIds" runat="server" ClientIDMode="Static" />

    <!-- ================= Filters ================= -->
    <section class="bg-white border-b border-slate-200 px-6 py-4 shrink-0 relative z-30">
        <div class="bg-slate-50/70 border border-slate-200 rounded-xl p-4">
            <div id="filterGrid" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-x-4 gap-y-3">

                <%-- From Month চেকবক্স + From Date --%>
                <div>
                    <label class="chk-lbl"><asp:CheckBox ID="chkFromMonth" runat="server" ClientIDMode="Static" /><span>From Month</span></label>
                    <div class="dt-wrap"><asp:TextBox ID="txtFromDate" runat="server" ClientIDMode="Static" CssClass="fld date" placeholder="Pick a date" autocomplete="off" onfocus="this.type='date'; try{this.showPicker()}catch(e){}" onblur="if(!this.value)this.type='text'" /><i class="fa-regular fa-calendar"></i></div>
                </div>

                <div>
                    <label class="lbl">Till Date</label>
                    <div class="dt-wrap"><asp:TextBox ID="txtTillDate" runat="server" ClientIDMode="Static" CssClass="fld date" placeholder="Pick a date" autocomplete="off" onfocus="this.type='date'; try{this.showPicker()}catch(e){}" onblur="if(!this.value)this.type='text'" /><i class="fa-regular fa-calendar"></i></div>
                </div>

                <div>
                    <label class="lbl">Attendance Type</label>
                    <asp:DropDownList ID="ddType" runat="server" ClientIDMode="Static" CssClass="fld">
                        <asp:ListItem Text="Pending" Value="0" Selected="True" />
                        <asp:ListItem Text="Approved" Value="1" />
                        <asp:ListItem Text="Delete" Value="2" />
                    </asp:DropDownList>
                </div>

                <div class="sm:col-span-2 lg:col-span-2">
                    <label class="lbl">ID No</label>
                    <asp:TextBox ID="txtMultiId" runat="server" ClientIDMode="Static" CssClass="fld" placeholder="e.g. 1001, 1002…" autocomplete="off" />
                </div>
            </div>
        </div>

        <div class="flex justify-end items-center gap-2 mt-3">
            <asp:LinkButton ID="btnShow" runat="server" ClientIDMode="Static" OnClick="btnShow_Click" CssClass="h-9 px-4 rounded-lg border border-slate-300 bg-white hover:bg-slate-50 text-slate-700 text-sm font-medium flex items-center gap-2 transition">
                <i class="fa-regular fa-eye text-xs"></i><span>Show</span>
            </asp:LinkButton>
            <button type="button" id="btnSelClear" onclick="clearSelection()" class="h-9 px-4 rounded-lg border border-slate-300 bg-white hover:bg-slate-50 text-slate-700 text-sm font-medium flex items-center gap-2 transition">
                <i class="fa-solid fa-eraser text-xs"></i><span>Selection Clear</span>
            </button>
            <asp:LinkButton ID="btnConfirm" runat="server" ClientIDMode="Static" OnClick="btnConfirm_Click" OnClientClick="return doAction('confirm');" CssClass="h-9 px-5 rounded-lg bg-blue-600 hover:bg-blue-700 text-white text-sm font-medium flex items-center gap-2 shadow-sm transition">
                <i class="fa-solid fa-check text-xs"></i><span>Confirm</span>
            </asp:LinkButton>
            <asp:LinkButton ID="btnReopen" runat="server" ClientIDMode="Static" OnClick="btnReopen_Click" OnClientClick="return doAction('reopen');" CssClass="h-9 px-5 rounded-lg bg-amber-500 hover:bg-amber-600 text-white text-sm font-medium flex items-center gap-2 shadow-sm transition">
                <i class="fa-solid fa-rotate-left text-xs"></i><span>Re-Open</span>
            </asp:LinkButton>
            <asp:LinkButton ID="btnDelete" runat="server" ClientIDMode="Static" OnClick="btnDelete_Click" OnClientClick="return doAction('delete');" CssClass="h-9 px-5 rounded-lg bg-rose-600 hover:bg-rose-700 text-white text-sm font-medium flex items-center gap-2 shadow-sm transition">
                <i class="fa-regular fa-trash-can text-xs"></i><span>Delete</span>
            </asp:LinkButton>
        </div>
    </section>

    <!-- ================= Results ================= -->
    <div class="flex-1 flex flex-col min-h-0 overflow-hidden">
        <main class="flex-1 flex flex-col min-h-0 bg-slate-100 overflow-hidden relative">

            <!-- Toolbar / Summary Header -->
            <div class="bg-white border-b border-slate-200 px-6 py-4 flex flex-wrap items-center justify-between gap-4 shrink-0">
                <div>
                    <div class="flex items-center space-x-2">
                        <h2 class="text-base font-bold text-slate-800">Late Permission Approval</h2>
                        <asp:Label ID="lblCount" runat="server" CssClass="bg-indigo-50 text-indigo-700 text-xs font-semibold px-2.5 py-0.5 rounded-full border border-indigo-100" Text="0 Records" />
                        <span id="selCount" class="bg-amber-50 text-amber-700 text-xs font-semibold px-2.5 py-0.5 rounded-full border border-amber-100">0 Selected</span>
                        <asp:Label ID="lblUser" runat="server" CssClass="bg-slate-100 text-slate-600 text-xs font-semibold px-2.5 py-0.5 rounded-full border border-slate-200" Text="" />
                    </div>
                    <p class="text-xs text-slate-500 mt-0.5">Late permission requests waiting for approval.</p>
                </div>
                <div class="flex items-center space-x-2">
                    <div class="relative">
                        <input type="text" id="tableSearch" onkeyup="searchTable()" onkeydown="if(event.key==='Enter')return false;" placeholder="Quick filter table..." class="bg-slate-50 border border-slate-300 rounded-lg pl-8 pr-3 py-1.5 text-xs text-slate-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 w-48 sm:w-64">
                        <i class="fa-solid fa-search absolute left-2.5 top-2 text-slate-400 text-xs"></i>
                    </div>
                </div>
            </div>

            <!-- Data Table -->
            <div class="flex-1 p-6 overflow-auto">
                <div class="bg-white border border-slate-200 rounded-xl shadow-sm overflow-hidden flex flex-col h-full">
                    <div class="overflow-auto flex-1">
                        <table id="reportTable" class="w-full text-left border-collapse whitespace-nowrap">
                            <thead>
                                <tr class="bg-slate-50 border-b border-slate-200 text-xs font-semibold text-slate-600 uppercase tracking-wider sticky top-0 z-10">
                                    <th class="py-3.5 px-4 w-12 text-center">
                                        <input type="checkbox" id="selectAllRows" onchange="toggleAllRowCheckboxes(this)" class="rounded text-indigo-600 focus:ring-indigo-500 w-4 h-4">
                                    </th>
                                    <th class="py-3.5 px-4 font-semibold">Entry No</th>
                                    <th class="py-3.5 px-4 font-semibold">ID No</th>
                                    <th class="py-3.5 px-4 font-semibold">Name</th>
                                    <th class="py-3.5 px-4 font-semibold">Designation</th>
                                    <th class="py-3.5 px-4 font-semibold">Department</th>
                                    <th class="py-3.5 px-4 font-semibold">Section</th>
                                    <th class="py-3.5 px-4 font-semibold">Note</th>
                                    <th class="py-3.5 px-4 font-semibold">Entry Date Time</th>
                                    <th class="py-3.5 px-4 font-semibold">Org In</th>
                                    <th class="py-3.5 px-4 font-semibold">Org Out</th>
                                    <th class="py-3.5 px-4 font-semibold">Work Date</th>
                                    <th class="py-3.5 px-4 font-semibold">Status</th>
                                </tr>
                            </thead>
                            <tbody id="tableBody" class="divide-y divide-slate-100 text-sm text-slate-700 bg-white">
                                <asp:Repeater ID="rptRows" runat="server">
                                    <ItemTemplate>
                                        <tr class="hover:bg-slate-50/80 transition-colors">
                                            <%-- name="selId" ও value (ID_no|Work_Date) অবশ্যই থাকতে হবে: ব্রাউজার টিক দেওয়া কী সরাসরি সার্ভারে পাঠায় --%>
                                            <td class="py-3 px-4 text-center"><input type="checkbox" name="selId" class="row-checkbox rounded text-indigo-600 focus:ring-indigo-500 w-4 h-4" onchange="updateSelCount()" value='<%# Server.HtmlEncode(Convert.ToString(Eval("Key"))) %>' data-id='<%# Server.HtmlEncode(Convert.ToString(Eval("Key"))) %>'></td>
                                            <td class="py-3 px-4 text-slate-600 text-xs"><%# Server.HtmlEncode(Convert.ToString(Eval("EntryNo"))) %></td>
                                            <td class="py-3 px-4 font-semibold text-slate-900 text-xs"><%# Server.HtmlEncode(Convert.ToString(Eval("IdNo"))) %></td>
                                            <td class="py-3 px-4 font-medium text-slate-800 text-xs"><%# Server.HtmlEncode(Convert.ToString(Eval("Name"))) %></td>
                                            <td class="py-3 px-4 text-slate-600 text-xs"><%# Server.HtmlEncode(Convert.ToString(Eval("Designation"))) %></td>
                                            <td class="py-3 px-4 text-slate-600 text-xs"><%# Server.HtmlEncode(Convert.ToString(Eval("Department"))) %></td>
                                            <td class="py-3 px-4 text-slate-600 text-xs"><%# Server.HtmlEncode(Convert.ToString(Eval("Section"))) %></td>
                                            <td class="py-3 px-4 text-slate-600 text-xs note-cell" title='<%# Server.HtmlEncode(Convert.ToString(Eval("Note"))) %>'><%# Server.HtmlEncode(Convert.ToString(Eval("Note"))) %></td>
                                            <td class="py-3 px-4 text-slate-600 text-xs"><%# Server.HtmlEncode(Convert.ToString(Eval("EntryDateTime"))) %></td>
                                            <td class="py-3 px-4 text-slate-600 text-xs"><%# Server.HtmlEncode(Convert.ToString(Eval("OrgInTime"))) %></td>
                                            <td class="py-3 px-4 text-slate-600 text-xs"><%# Server.HtmlEncode(Convert.ToString(Eval("OrgOutTime"))) %></td>
                                            <td class="py-3 px-4 text-slate-600 text-xs"><%# Server.HtmlEncode(Convert.ToString(Eval("WorkDate"))) %></td>
                                            <td class="py-3 px-4"><span class='<%# Eval("StatusCss") %>'><%# Server.HtmlEncode(Convert.ToString(Eval("Status"))) %></span></td>
                                        </tr>
                                    </ItemTemplate>
                                </asp:Repeater>
                                <tr id="trEmpty" runat="server" visible="false"><td colspan="13" class="text-center py-8 text-slate-400 text-xs">No late permission records found for the selected criteria.</td></tr>
                            </tbody>
                        </table>
                    </div>

                    <!-- Table Footer -->
                    <div class="bg-slate-50 border-t border-slate-200 px-6 py-3 flex items-center justify-between text-xs text-slate-500 shrink-0">
                        <div><asp:Literal ID="litPaging" runat="server" /></div>
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

// টিক দেওয়া Entry_no গুলো hfSelIds এ জমা (সার্ভার name="selId" থেকেও পড়ে, এটি অতিরিক্ত নিরাপত্তা)
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

// Confirm / Re-Open / Delete এর আগে: কমপক্ষে একটি রেকর্ড নির্বাচন + নিশ্চিতকরণ
function doAction(kind) {
    const ids = collectIds();
    if (ids.length === 0) {
        showNotification('কমপক্ষে একটি রেকর্ড নির্বাচন করুন।');
        return false;
    }
    let msg;
    if (kind === 'reopen') msg = ids.length + ' টি রেকর্ড Re-Open করতে চান?';
    else if (kind === 'delete') msg = ids.length + ' টি রেকর্ড Delete করতে চান?';
    else msg = ids.length + ' টি রেকর্ড Confirm করতে চান?';
    return confirm(msg);
}

// Selection Clear: সব টিক তুলে দেয় (সার্ভারে যায় না)
function clearSelection() {
    document.querySelectorAll('.row-checkbox').forEach(c => c.checked = false);
    const all = document.getElementById('selectAllRows');
    if (all) all.checked = false;
    updateSelCount();
}

function updateSelCount() {
    const n = document.querySelectorAll('.row-checkbox:checked').length;
    const el = document.getElementById('selCount');
    if (el) el.textContent = n + ' Selected';
}

document.addEventListener('DOMContentLoaded', function () {
    // তারিখ ঘরে মান থাকলে date হিসেবে দেখাও
    document.querySelectorAll('input.date').forEach(i => { if (i.value) i.type = 'date'; });

    // যেভাবেই ফর্ম সাবমিট হোক, আগে Entry_no জমা হবে
    const f = document.forms[0], old = f.onsubmit;
    f.onsubmit = function () { collectIds(); return old ? old.apply(this, arguments) : true; };

    // ID ঘরে Enter চাপলে Show বাটন চলবে
    const mi = document.getElementById('txtMultiId');
    if (mi) mi.addEventListener('keydown', e => {
        if (e.key === 'Enter') {
            e.preventDefault();
            const b = document.getElementById('btnShow');
            if (b) b.click();
        }
    });

    // পোস্টব্যাকের পর নির্বাচিত সংখ্যা দেখানো
    setTimeout(updateSelCount, 50);
});

// ---------- টেবিলের Quick filter ----------
function searchTable() {
    const q = document.getElementById('tableSearch').value.toLowerCase();
    document.querySelectorAll('#tableBody tr').forEach(tr => {
        if (tr.id && tr.id.indexOf('trEmpty') > -1) return;
        tr.style.display = tr.textContent.toLowerCase().includes(q) ? '' : 'none';
    });
}
function toggleAllRowCheckboxes(source) {
    document.querySelectorAll('.row-checkbox').forEach(cb => cb.checked = source.checked);
    updateSelCount();
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
