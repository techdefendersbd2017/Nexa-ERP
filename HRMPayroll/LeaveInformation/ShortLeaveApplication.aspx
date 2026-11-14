<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ShortLeaveApplication.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.LeaveInformation.ShortLeaveApplication" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Short Leave</title>
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
             border:1px solid #d9dce5;border-radius:6px;background:#f6f7fb;font-size:13px;color:#1e293b;
             transition:border-color .15s, box-shadow .15s, background .15s;width:100%}
        .fld:hover{border-color:#b6bccb}
        .fld:focus{outline:none;border-color:#3b82f6;box-shadow:0 0 0 3px rgba(59,130,246,.15)}
        input.fld{display:block;cursor:text}
        input.fld::placeholder,textarea.fld::placeholder{color:#a0a7b5}
        select.fld{display:block;cursor:pointer;padding:0 6px}
        input.fld.date{background:#f3f4f7;color:#334155}
        textarea.fld{display:block;height:auto;padding:6px 10px;resize:vertical}
        .lbl{display:block;font-size:13px;color:#334155;margin-bottom:6px}
        .chkcell input{cursor:pointer;accent-color:#198754;width:15px;height:15px}
    </style>
</head>
<body class="bg-slate-100 text-slate-800 antialiased h-screen flex flex-col overflow-hidden">
<form id="form1" runat="server" class="flex flex-col h-screen overflow-hidden" autocomplete="off">

    <section class="bg-white border-b border-slate-200 px-6 py-4 shrink-0 relative z-30">
        <h1 class="text-base font-bold text-slate-800 mb-3">Short Leave / Gate Pass</h1>
        <div class="bg-slate-50/70 border border-slate-200 rounded-xl p-4">
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-x-4 gap-y-3">

                <div><label class="lbl">Work Date</label>
                    <asp:TextBox ID="txtWorkDate" runat="server" TextMode="Date" CssClass="fld date" /></div>

                <div><label class="lbl">Leave Type</label>
                    <asp:DropDownList ID="ddlLeaveType" runat="server" CssClass="fld">
                        <asp:ListItem Text="Short Leave" Value="SL" Selected="True" />
                        <asp:ListItem Text="Gate Pass" Value="GP" />
                    </asp:DropDownList></div>

                <div class="sm:col-span-2 lg:col-span-2">
                    <label class="lbl">ID No <span class="text-xs text-slate-400">(কমা বা নতুন লাইন দিয়ে একাধিক ID দিন)</span></label>
                    <asp:TextBox ID="txtIdNo" runat="server" TextMode="MultiLine" Rows="3" CssClass="fld" placeholder="যেমন: 1001, 1002, 1003" />
                </div>
            </div>
        </div>

        <div class="flex flex-wrap justify-between items-center gap-2 mt-3">
            <div class="flex items-center gap-2">
                <asp:LinkButton ID="btnShow" runat="server" OnClick="btnShow_Click" CssClass="h-9 px-5 rounded-lg bg-cyan-500 hover:bg-cyan-600 text-white text-sm font-medium flex items-center gap-2 shadow-sm transition">
                    <i class="fa-solid fa-magnifying-glass text-xs"></i><span>Show</span>
                </asp:LinkButton>
                <button type="button" onclick="checkAll(true)" class="h-9 px-5 rounded-lg bg-blue-600 hover:bg-blue-700 text-white text-sm font-medium flex items-center gap-2 shadow-sm transition">
                    <i class="fa-regular fa-square-check text-xs"></i><span>All</span>
                </button>
                <button type="button" onclick="checkAll(false)" class="h-9 px-4 rounded-lg border border-slate-300 bg-white hover:bg-slate-50 text-slate-700 text-sm font-medium flex items-center gap-2 transition">
                    <i class="fa-regular fa-square text-xs"></i><span>Clear</span>
                </button>
            </div>
            <div class="flex items-center gap-2">
                <asp:LinkButton ID="btnSave" runat="server" OnClick="btnSave_Click" CssClass="h-9 px-5 rounded-lg bg-emerald-600 hover:bg-emerald-700 text-white text-sm font-medium flex items-center gap-2 shadow-sm transition">
                    <i class="fa-regular fa-floppy-disk text-xs"></i><span>Save</span>
                </asp:LinkButton>
                <asp:LinkButton ID="btnDelete" runat="server" OnClick="btnDelete_Click" OnClientClick="return confirm('Delete selected entries?');" CssClass="h-9 px-5 rounded-lg bg-red-600 hover:bg-red-700 text-white text-sm font-medium flex items-center gap-2 shadow-sm transition">
                    <i class="fa-regular fa-trash-can text-xs"></i><span>Delete</span>
                </asp:LinkButton>
                <asp:LinkButton ID="btnRefresh" runat="server" OnClick="btnRefresh_Click" CssClass="h-9 px-4 rounded-lg border border-slate-300 bg-white hover:bg-slate-50 text-slate-700 text-sm font-medium flex items-center gap-2 transition">
                    <i class="fa-solid fa-rotate text-xs"></i><span>Refresh</span>
                </asp:LinkButton>
            </div>
        </div>
    </section>

    <!-- Results -->
    <div class="flex-1 flex flex-col min-h-0 overflow-hidden">
        <main class="flex-1 flex flex-col min-h-0 bg-slate-100 overflow-hidden relative">

            <div class="bg-white border-b border-slate-200 px-6 py-3 flex flex-wrap items-center justify-between gap-4 shrink-0">
                <div>
                    <div class="flex items-center space-x-2">
                        <h2 class="text-base font-bold text-slate-800">Attendance List</h2>
                        <asp:Label ID="lblCount" runat="server" CssClass="bg-indigo-50 text-indigo-700 text-xs font-semibold px-2.5 py-0.5 rounded-full border border-indigo-100" Text="0 Records" />
                    </div>
                    <p class="text-xs text-slate-500 mt-0.5">টিক দেওয়া কর্মচারীদের জন্য Save / Delete কাজ করবে।</p>
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
                                    <th class="py-3.5 px-4 w-10 chkcell"><input type="checkbox" id="chkHead" onclick="checkAll(this.checked)" /></th>
                                    <th class="py-3.5 px-4">ID No</th>
                                    <th class="py-3.5 px-4">Name</th>
                                    <th class="py-3.5 px-4">Designation</th>
                                    <th class="py-3.5 px-4">Date</th>
                                    <th class="py-3.5 px-4">Att. Status</th>
                                    <th class="py-3.5 px-4">In Time</th>
                                    <th class="py-3.5 px-4">Out Time</th>
                                </tr>
                            </thead>
                            <tbody id="tableBody" class="divide-y divide-slate-100 text-sm text-slate-700 bg-white">
                                <asp:Repeater ID="rptRows" runat="server">
                                    <ItemTemplate>
                                        <tr class="hover:bg-slate-50/80 transition-colors">
                                            <td class="py-3 px-4 chkcell">
                                                <asp:CheckBox ID="chkRow" runat="server" Checked="true" />
                                                <asp:HiddenField ID="hfId" runat="server" Value='<%# Eval("IdNo") %>' />
                                            </td>
                                            <td class="py-3 px-4 text-xs font-semibold text-slate-900"><%# Server.HtmlEncode(Convert.ToString(Eval("IdNo"))) %></td>
                                            <td class="py-3 px-4 text-xs text-slate-700"><%# Server.HtmlEncode(Convert.ToString(Eval("Name"))) %></td>
                                            <td class="py-3 px-4 text-xs text-slate-600"><%# Server.HtmlEncode(Convert.ToString(Eval("Designation"))) %></td>
                                            <td class="py-3 px-4 text-xs text-slate-600"><%# Server.HtmlEncode(Convert.ToString(Eval("WorkDate"))) %></td>
                                            <td class="py-3 px-4 text-xs text-slate-600"><%# Server.HtmlEncode(Convert.ToString(Eval("Status"))) %></td>
                                            <td class="py-3 px-4 text-xs text-slate-600"><%# Server.HtmlEncode(Convert.ToString(Eval("InTime"))) %></td>
                                            <td class="py-3 px-4 text-xs text-slate-600"><%# Server.HtmlEncode(Convert.ToString(Eval("OutTime"))) %></td>
                                        </tr>
                                    </ItemTemplate>
                                </asp:Repeater>
                                <tr id="trEmpty" runat="server" visible="false"><td colspan="8" class="text-center py-8 text-slate-400 text-xs">No records found.</td></tr>
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

    <div id="toastContainer" class="fixed bottom-5 right-5 z-50 flex flex-col space-y-2 pointer-events-none"></div>
</form>

<script>
const esc = s => String(s).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));

// All / Clear : সব সারির টিক চালু/বন্ধ
function checkAll(state) {
    document.querySelectorAll('#tableBody input[type=checkbox]').forEach(function (c) {
        if (c.closest('tr').style.display !== 'none') c.checked = state;
    });
    var h = document.getElementById('chkHead');
    if (h) h.checked = state;
}

// Enter চাপলে ফর্ম সাবমিট বন্ধ (ID No ঘরে নতুন লাইন চলবে)
document.addEventListener('DOMContentLoaded', function () {
    document.getElementById('form1').addEventListener('keydown', function (e) {
        if (e.key !== 'Enter') return;
        var t = e.target;
        if (t.tagName === 'TEXTAREA' || t.tagName === 'A' || t.tagName === 'BUTTON') return;
        e.preventDefault();
    });
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
    setTimeout(() => { toast.classList.add('translate-y-2', 'opacity-0'); setTimeout(() => toast.remove(), 300); }, 3500);
}
</script>
</body>
</html>
