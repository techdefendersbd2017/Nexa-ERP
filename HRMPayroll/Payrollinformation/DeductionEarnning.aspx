<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DeductionEarnning.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.Payrollinformation.DeductionEarnning" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Deduction Or Earning</title>
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

        /* ---- Filter / input fields (HRMReports এর মতো) ---- */
        .fld{display:block;height:32px;padding:0 10px;border:1px solid #d9dce5;border-radius:6px;background:#f6f7fb;
             font-size:13px;color:#1e293b;width:100%;transition:border-color .15s, box-shadow .15s, background .15s}
        .fld:hover{border-color:#b6bccb}
        .fld:focus{outline:none;border-color:#3b82f6;box-shadow:0 0 0 3px rgba(59,130,246,.15);background:#fff}
        select.fld{cursor:pointer;padding:0 6px}
        input.fld::placeholder{color:#a0a7b5}
        .lbl{display:block;font-size:13px;color:#334155;margin-bottom:6px}
        .cbx input{width:16px;height:16px;accent-color:#2563eb;cursor:pointer}
        .cbx{display:inline-flex;align-items:center}
    </style>
</head>
<body class="bg-slate-100 text-slate-800 antialiased h-screen flex flex-col overflow-hidden">
<form id="form1" runat="server" class="flex flex-col h-screen overflow-hidden" autocomplete="off">

    <!-- Page header -->
    <section class="bg-white border-b border-slate-200 px-6 py-3 shrink-0">
        <div class="flex items-center gap-3">
            <div class="w-9 h-9 rounded-lg bg-blue-50 text-blue-600 flex items-center justify-center"><i class="fa-solid fa-money-bill-transfer"></i></div>
            <div>
                <h1 class="text-base font-bold text-slate-800">Deduction Or Earning</h1>
                <p class="text-xs text-slate-500">কর্মচারীদের Deduction / Earning এন্ট্রি, খোঁজা ও মোছা</p>
            </div>
        </div>
    </section>

    <div class="flex-1 min-h-0 p-4 overflow-hidden">
        <div class="grid grid-cols-1 lg:grid-cols-[420px_1fr] gap-4 h-full min-h-0">

            <!-- ================= LEFT: Entry form + Employee list ================= -->
            <div class="flex flex-col min-h-0 gap-4">

                <div class="bg-white border border-slate-200 rounded-xl shadow-sm p-4 shrink-0">
                    <div class="grid grid-cols-2 gap-x-4 gap-y-3">
                        <div class="col-span-2">
                            <label class="lbl">ID No</label>
                            <div class="flex gap-2">
                                <asp:TextBox ID="txtEmpIds" runat="server" ClientIDMode="Static" CssClass="fld" placeholder="e.g. 1001, 1002, 1003 — Enter চাপুন" />
                                <asp:LinkButton ID="btnLoadEmp" runat="server" ClientIDMode="Static" OnClick="btnLoadEmp_Click" CssClass="h-8 px-3 rounded-md border border-slate-300 bg-white hover:bg-slate-50 text-slate-700 text-xs font-medium flex items-center gap-1.5 whitespace-nowrap transition">
                                    <i class="fa-solid fa-download text-[11px]"></i><span>Load</span>
                                </asp:LinkButton>
                            </div>
                        </div>
                        <div>
                            <label class="lbl">Mode</label>
                            <asp:DropDownList ID="ddMode" runat="server" ClientIDMode="Static" CssClass="fld" AutoPostBack="true" OnSelectedIndexChanged="ddMode_SelectedIndexChanged" />
                        </div>
                        <div>
                            <label class="lbl">Type</label>
                            <asp:DropDownList ID="ddType" runat="server" ClientIDMode="Static" CssClass="fld" />
                        </div>
                        <div>
                            <label class="lbl">Eff. Date</label>
                            <asp:TextBox ID="txtEffDate" runat="server" ClientIDMode="Static" TextMode="Date" CssClass="fld" />
                        </div>
                        <div>
                            <label class="lbl">Amount</label>
                            <asp:TextBox ID="txtAmount" runat="server" ClientIDMode="Static" CssClass="fld" placeholder="0" />
                        </div>
                    </div>
                    <div class="flex justify-end mt-4">
                        <asp:LinkButton ID="btnAdd" runat="server" ClientIDMode="Static" OnClick="btnAdd_Click" CssClass="h-9 px-5 rounded-lg bg-blue-600 hover:bg-blue-700 text-white text-sm font-medium flex items-center gap-2 shadow-sm transition">
                            <i class="fa-solid fa-plus text-xs"></i><span>Add</span>
                        </asp:LinkButton>
                    </div>
                </div>

                <!-- Employee list -->
                <div class="bg-white border border-slate-200 rounded-xl shadow-sm flex flex-col flex-1 min-h-0 overflow-hidden">
                    <div class="px-4 py-3 border-b border-slate-200 flex items-center justify-between shrink-0">
                        <div class="flex items-center gap-2">
                            <h2 class="text-sm font-bold text-slate-800">Employees</h2>
                            <asp:Label ID="lblEmpCount" runat="server" CssClass="bg-indigo-50 text-indigo-700 text-xs font-semibold px-2.5 py-0.5 rounded-full border border-indigo-100" Text="0 Records" />
                        </div>
                        <input type="text" id="empSearch" onkeyup="filterRows(this,'empBody')" onkeydown="if(event.key==='Enter')return false;" placeholder="Quick filter..." class="bg-slate-50 border border-slate-300 rounded-lg pl-3 pr-3 py-1 text-xs text-slate-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 w-36">
                    </div>
                    <div class="flex-1 overflow-auto">
                        <table class="w-full text-left border-collapse">
                            <thead>
                                <tr class="bg-slate-50 border-b border-slate-200 text-xs font-semibold text-slate-600 uppercase tracking-wider sticky top-0 z-10">
                                    <th class="py-3 px-4 w-12 text-center"><input type="checkbox" onchange="toggleAll(this,'.emp-cb input')" checked class="w-4 h-4 accent-blue-600"></th>
                                    <th class="py-3 px-3">ID No</th>
                                    <th class="py-3 px-3">Name</th>
                                    <th class="py-3 px-3">Designation</th>
                                </tr>
                            </thead>
                            <tbody id="empBody" class="divide-y divide-slate-100 text-xs text-slate-700 bg-white">
                                <asp:Repeater ID="rptEmp" runat="server">
                                    <ItemTemplate>
                                        <tr class="hover:bg-slate-50/80 transition-colors">
                                            <td class="py-2.5 px-4 text-center">
                                                <asp:CheckBox ID="chk" runat="server" Checked="true" CssClass="cbx emp-cb" />
                                                <asp:HiddenField ID="hfId" runat="server" Value='<%# Eval("ID_no") %>' />
                                            </td>
                                            <td class="py-2.5 px-3 font-semibold text-slate-900"><%# Server.HtmlEncode(Convert.ToString(Eval("ID_no"))) %></td>
                                            <td class="py-2.5 px-3 font-medium text-slate-800"><%# Server.HtmlEncode(Convert.ToString(Eval("Name"))) %></td>
                                            <td class="py-2.5 px-3 text-slate-600"><%# Server.HtmlEncode(Convert.ToString(Eval("Designation"))) %></td>
                                        </tr>
                                    </ItemTemplate>
                                </asp:Repeater>
                                <tr id="trEmpEmpty" runat="server"><td colspan="4" class="text-center py-8 text-slate-400 text-xs">ID No লিখে Enter চাপুন বা Load করুন।</td></tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- ================= RIGHT: Search + Entries ================= -->
            <div class="flex flex-col min-h-0 gap-4">

                <div class="bg-white border border-slate-200 rounded-xl shadow-sm p-4 shrink-0">
                    <div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-x-4 gap-y-3 items-end">
                        <div>
                            <label class="lbl">Status</label>
                            <asp:DropDownList ID="ddStatus" runat="server" ClientIDMode="Static" CssClass="fld" />
                        </div>
                        <div>
                            <label class="lbl">Type</label>
                            <asp:DropDownList ID="ddFilterType" runat="server" ClientIDMode="Static" CssClass="fld" />
                        </div>
                        <div>
                            <label class="lbl">ID No</label>
                            <asp:TextBox ID="txtSearchId" runat="server" ClientIDMode="Static" CssClass="fld" placeholder="e.g. 1001, 1002" />
                        </div>
                        <div class="flex gap-2">
                            <asp:LinkButton ID="btnSelect" runat="server" ClientIDMode="Static" OnClick="btnSelect_Click" CssClass="h-8 px-4 rounded-lg bg-blue-600 hover:bg-blue-700 text-white text-sm font-medium flex items-center gap-2 shadow-sm transition">
                                <i class="fa-solid fa-magnifying-glass text-xs"></i><span>Select</span>
                            </asp:LinkButton>
                            <asp:LinkButton ID="btnClear" runat="server" ClientIDMode="Static" OnClick="btnClear_Click" CssClass="h-8 px-4 rounded-lg border border-slate-300 bg-white hover:bg-slate-50 text-slate-700 text-sm font-medium flex items-center gap-2 transition">
                                <i class="fa-solid fa-eraser text-xs"></i><span>Clear</span>
                            </asp:LinkButton>
                        </div>
                    </div>
                </div>

                <div class="bg-white border border-slate-200 rounded-xl shadow-sm flex flex-col flex-1 min-h-0 overflow-hidden">
                    <div class="px-4 py-3 border-b border-slate-200 flex flex-wrap items-center justify-between gap-3 shrink-0">
                        <div>
                            <div class="flex items-center gap-2">
                                <h2 class="text-sm font-bold text-slate-800">Deduction / Earning Entries</h2>
                                <asp:Label ID="lblEntryCount" runat="server" CssClass="bg-indigo-50 text-indigo-700 text-xs font-semibold px-2.5 py-0.5 rounded-full border border-indigo-100" Text="0 Records" />
                            </div>
                            <p class="text-xs text-slate-500 mt-0.5"><asp:Label ID="lblEntryTitle" runat="server" Text="Eff. Date অনুযায়ী ফলাফল" /></p>
                        </div>
                        <div class="flex items-center gap-2">
                            <input type="text" id="entrySearch" onkeyup="filterRows(this,'entryBody')" onkeydown="if(event.key==='Enter')return false;" placeholder="Quick filter..." class="bg-slate-50 border border-slate-300 rounded-lg pl-3 pr-3 py-1.5 text-xs text-slate-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 w-40">
                            <asp:LinkButton ID="btnRefresh" runat="server" ClientIDMode="Static" OnClick="btnRefresh_Click" CssClass="h-8 px-3 rounded-lg border border-slate-300 bg-white hover:bg-slate-50 text-slate-700 text-xs font-medium flex items-center gap-1.5 transition">
                                <i class="fa-solid fa-rotate text-[11px]"></i><span>Refresh</span>
                            </asp:LinkButton>
                            <asp:LinkButton ID="btnDelete" runat="server" ClientIDMode="Static" OnClick="btnDelete_Click" OnClientClick="return confirm('নির্বাচিত এন্ট্রিগুলো মুছে ফেলবেন?');" CssClass="h-8 px-3 rounded-lg bg-red-500 hover:bg-red-600 text-white text-xs font-medium flex items-center gap-1.5 shadow-sm transition">
                                <i class="fa-regular fa-trash-can text-[11px]"></i><span>Delete</span>
                            </asp:LinkButton>
                        </div>
                    </div>

                    <div class="flex-1 overflow-auto">
                        <table class="w-full text-left border-collapse">
                            <thead>
                                <tr class="bg-slate-50 border-b border-slate-200 text-xs font-semibold text-slate-600 uppercase tracking-wider sticky top-0 z-10">
                                    <th class="py-3 px-4 w-12 text-center"><input type="checkbox" onchange="toggleAll(this,'.entry-cb input')" class="w-4 h-4 accent-blue-600"></th>
                                    <th class="py-3 px-3">Entry No</th>
                                    <th class="py-3 px-3">ID No</th>
                                    <th class="py-3 px-3">Name</th>
                                    <th class="py-3 px-3">Mode</th>
                                    <th class="py-3 px-3">Type</th>
                                    <th class="py-3 px-3 text-right">Amount</th>
                                </tr>
                            </thead>
                            <tbody id="entryBody" class="divide-y divide-slate-100 text-xs text-slate-700 bg-white">
                                <asp:Repeater ID="rptEntry" runat="server">
                                    <ItemTemplate>
                                        <tr class="hover:bg-slate-50/80 transition-colors">
                                            <td class="py-2.5 px-4 text-center">
                                                <asp:CheckBox ID="chk" runat="server" CssClass="cbx entry-cb" />
                                                <asp:HiddenField ID="hfEntry" runat="server" Value='<%# Eval("Entry_no") %>' />
                                            </td>
                                            <td class="py-2.5 px-3 font-semibold text-slate-900"><%# Server.HtmlEncode(Convert.ToString(Eval("Entry_no"))) %></td>
                                            <td class="py-2.5 px-3"><%# Server.HtmlEncode(Convert.ToString(Eval("ID_no"))) %></td>
                                            <td class="py-2.5 px-3 font-medium text-slate-800"><%# Server.HtmlEncode(Convert.ToString(Eval("Name"))) %></td>
                                            <td class="py-2.5 px-3 text-slate-600"><%# Server.HtmlEncode(Convert.ToString(Eval("Mode_Name"))) %></td>
                                            <td class="py-2.5 px-3 text-slate-600"><%# Server.HtmlEncode(Convert.ToString(Eval("Deduct_Name"))) %></td>
                                            <td class="py-2.5 px-3 text-right font-semibold"><%# Server.HtmlEncode(Convert.ToString(Eval("Advance_Amount"))) %></td>
                                        </tr>
                                    </ItemTemplate>
                                </asp:Repeater>
                                <tr id="trEntryEmpty" runat="server"><td colspan="7" class="text-center py-8 text-slate-400 text-xs">No matching records found for the selected criteria.</td></tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Toast container -->
    <div id="toastContainer" class="fixed bottom-5 right-5 z-50 flex flex-col space-y-2 pointer-events-none"></div>
</form>

<script>
// @ts-nocheck
const esc = s => String(s).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));

// হেডারের চেকবক্স দিয়ে সব সারি টিক/আনটিক
function toggleAll(src, selector) {
    document.querySelectorAll(selector).forEach(c => c.checked = src.checked);
}

// টেবিলের Quick filter (শুধু ব্রাউজারে লুকায়, সার্ভারে কিছু বদলায় না)
function filterRows(input, bodyId) {
    const q = input.value.toLowerCase();
    document.querySelectorAll('#' + bodyId + ' tr').forEach(tr => {
        if (tr.id && tr.id.indexOf('Empty') > -1) return;
        tr.style.display = tr.textContent.toLowerCase().includes(q) ? '' : 'none';
    });
}

document.addEventListener('DOMContentLoaded', function () {
    // ID No ঘরে Enter: বাঁ দিকে Employee Load, ডান দিকে Select
    function bindEnter(inputId, btnId) {
        const el = document.getElementById(inputId);
        if (!el) return;
        el.addEventListener('keydown', function (e) {
            if (e.key === 'Enter') {
                e.preventDefault();
                const b = document.getElementById(btnId);
                if (b) b.click();
            }
        });
    }
    bindEnter('txtEmpIds', 'btnLoadEmp');
    bindEnter('txtSearchId', 'btnSelect');

    // অন্য ঘরে Enter চাপলে অনিচ্ছাকৃত সাবমিট বন্ধ
    document.querySelectorAll('input[type=text],input[type=date]').forEach(i => {
        if (i.id === 'txtEmpIds' || i.id === 'txtSearchId') return;
        i.addEventListener('keydown', e => { if (e.key === 'Enter') e.preventDefault(); });
    });
});

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
