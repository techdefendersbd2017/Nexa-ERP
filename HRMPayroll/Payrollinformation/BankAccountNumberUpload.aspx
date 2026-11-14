<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="BankAccountNumberUpload.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.Payrollinformation.BankAccountNumberUpload" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bank Account Number Upload</title>
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

        .fld{display:block;height:32px;padding:0 10px;border:1px solid #d9dce5;border-radius:6px;background:#f6f7fb;
             font-size:13px;color:#1e293b;width:100%;transition:border-color .15s, box-shadow .15s, background .15s}
        .fld:hover{border-color:#b6bccb}
        .fld:focus{outline:none;border-color:#3b82f6;box-shadow:0 0 0 3px rgba(59,130,246,.15);background:#fff}
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
            <div class="w-9 h-9 rounded-lg bg-blue-50 text-blue-600 flex items-center justify-center"><i class="fa-solid fa-building-columns"></i></div>
            <div>
                <h1 class="text-base font-bold text-slate-800">Bank Account Number Upload</h1>
                <p class="text-xs text-slate-500">Excel ফাইল থেকে কর্মচারীদের ব্যাংক অ্যাকাউন্ট নম্বর Payroll Database এ আপলোড</p>
            </div>
        </div>
    </section>

    <div class="flex-1 min-h-0 p-4 overflow-hidden">
        <div class="grid grid-cols-1 lg:grid-cols-[1fr_340px] gap-4 h-full min-h-0">

            <!-- ================= LEFT: Excel data list ================= -->
            <div class="bg-white border border-slate-200 rounded-xl shadow-sm flex flex-col min-h-0 overflow-hidden">
                <div class="px-4 py-3 border-b border-slate-200 flex items-center justify-between shrink-0">
                    <div class="flex items-center gap-2">
                        <h2 class="text-sm font-bold text-slate-800">Account List</h2>
                        <asp:Label ID="lblCount" runat="server" CssClass="bg-indigo-50 text-indigo-700 text-xs font-semibold px-2.5 py-0.5 rounded-full border border-indigo-100" Text="0 Records" />
                    </div>
                    <input type="text" id="rowSearch" onkeyup="filterRows(this,'rowBody')" onkeydown="if(event.key==='Enter')return false;" placeholder="Quick filter..." class="bg-slate-50 border border-slate-300 rounded-lg pl-3 pr-3 py-1.5 text-xs text-slate-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 w-40">
                </div>

                <div class="flex-1 overflow-auto">
                    <table class="w-full text-left border-collapse">
                        <thead>
                            <tr class="bg-slate-50 border-b border-slate-200 text-xs font-semibold text-slate-600 uppercase tracking-wider sticky top-0 z-10">
                                <th class="py-3 px-4 w-12 text-center"><input type="checkbox" onchange="toggleAll(this,'.row-cb input')" checked class="w-4 h-4 accent-blue-600"></th>
                                <th class="py-3 px-3">ID No</th>
                                <th class="py-3 px-3">Name</th>
                                <th class="py-3 px-3">Designation</th>
                                <th class="py-3 px-3">Bank</th>
                                <th class="py-3 px-3">Bank Name</th>
                                <th class="py-3 px-3">Account No</th>
                            </tr>
                        </thead>
                        <tbody id="rowBody" class="divide-y divide-slate-100 text-xs text-slate-700 bg-white">
                            <asp:Repeater ID="rptRows" runat="server">
                                <ItemTemplate>
                                    <tr class="hover:bg-slate-50/80 transition-colors">
                                        <td class="py-2.5 px-4 text-center">
                                            <asp:CheckBox ID="chk" runat="server" Checked="true" CssClass="cbx row-cb" />
                                            <asp:HiddenField ID="hfId" runat="server" Value='<%# Eval("ID_no") %>' />
                                            <asp:HiddenField ID="hfBank" runat="server" Value='<%# Eval("Bank") %>' />
                                            <asp:HiddenField ID="hfBankName" runat="server" Value='<%# Eval("Bank_Name") %>' />
                                            <asp:HiddenField ID="hfAcNo" runat="server" Value='<%# Eval("Account_No") %>' />
                                        </td>
                                        <td class="py-2.5 px-3 font-semibold text-slate-900"><%# Server.HtmlEncode(Convert.ToString(Eval("ID_no"))) %></td>
                                        <td class="py-2.5 px-3 font-medium text-slate-800"><%# Server.HtmlEncode(Convert.ToString(Eval("Name"))) %></td>
                                        <td class="py-2.5 px-3 text-slate-600"><%# Server.HtmlEncode(Convert.ToString(Eval("Designation"))) %></td>
                                        <td class="py-2.5 px-3 text-slate-600"><%# Server.HtmlEncode(Convert.ToString(Eval("Bank"))) %></td>
                                        <td class="py-2.5 px-3 text-slate-600"><%# Server.HtmlEncode(Convert.ToString(Eval("Bank_Name"))) %></td>
                                        <td class="py-2.5 px-3 font-semibold"><%# Server.HtmlEncode(Convert.ToString(Eval("Account_No"))) %></td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                            <tr id="trEmpty" runat="server"><td colspan="7" class="text-center py-8 text-slate-400 text-xs">Excel ফাইল সিলেক্ট করুন — ডাটা এখানে দেখা যাবে।</td></tr>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- ================= RIGHT: Upload panel ================= -->
            <div class="flex flex-col min-h-0 gap-4">
                <div class="bg-white border border-slate-200 rounded-xl shadow-sm p-4 shrink-0">
                    <div class="space-y-3">
                        <div>
                            <label class="lbl">Sheet Name</label>
                            <asp:TextBox ID="txtSheet" runat="server" ClientIDMode="Static" CssClass="fld" Text="Sheet1" placeholder="Sheet1" />
                        </div>

                        <div>
                            <label class="lbl">Excel File (.xls / .xlsx)</label>
                            <asp:FileUpload ID="fuExcel" runat="server" ClientIDMode="Static" CssClass="hidden" accept=".xls,.xlsx" onchange="onFilePicked(this)" />
                            <button type="button" onclick="document.getElementById('fuExcel').click()" class="w-full h-9 px-4 rounded-lg border border-slate-300 bg-white hover:bg-slate-50 text-slate-700 text-sm font-medium flex items-center justify-center gap-2 transition">
                                <i class="fa-solid fa-file-excel text-xs text-emerald-600"></i><span>Upload Excel File</span>
                            </button>
                            <p class="text-xs text-slate-500 mt-2 break-all min-h-[16px]"><asp:Label ID="lblFile" runat="server" ClientIDMode="Static" Text="" /></p>
                            <asp:LinkButton ID="btnLoad" runat="server" ClientIDMode="Static" OnClick="btnLoad_Click" CssClass="hidden" />
                        </div>

                        <div class="flex gap-2 pt-1">
                            <asp:LinkButton ID="btnUpload" runat="server" ClientIDMode="Static" OnClick="btnUpload_Click" OnClientClick="return confirm('নির্বাচিত ডাটা Payroll Database এ আপলোড করবেন?');" CssClass="flex-1 h-9 px-4 rounded-lg bg-blue-600 hover:bg-blue-700 text-white text-sm font-medium flex items-center justify-center gap-2 shadow-sm transition">
                                <i class="fa-solid fa-cloud-arrow-up text-xs"></i><span>Upload To Payroll Database</span>
                            </asp:LinkButton>
                            <asp:LinkButton ID="btnClear" runat="server" ClientIDMode="Static" OnClick="btnClear_Click" CssClass="h-9 px-4 rounded-lg border border-slate-300 bg-white hover:bg-slate-50 text-slate-700 text-sm font-medium flex items-center gap-2 transition">
                                <i class="fa-solid fa-eraser text-xs"></i><span>Clear</span>
                            </asp:LinkButton>
                        </div>
                    </div>
                </div>

                <div class="bg-white border border-slate-200 rounded-xl shadow-sm p-4 text-xs text-slate-600 leading-relaxed">
                    <p class="font-semibold text-slate-800 mb-1">Excel কলামের ক্রম</p>
                    <p>ID No, Name, Designation, Bank, Bank Name, Account No — প্রথম সারি হেডার হতে হবে।</p>
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

function toggleAll(src, selector) {
    document.querySelectorAll(selector).forEach(c => c.checked = src.checked);
}

function filterRows(input, bodyId) {
    const q = input.value.toLowerCase();
    document.querySelectorAll('#' + bodyId + ' tr').forEach(tr => {
        if (tr.id && tr.id.indexOf('Empty') > -1) return;
        tr.style.display = tr.textContent.toLowerCase().includes(q) ? '' : 'none';
    });
}

// ফাইল সিলেক্ট করার সাথে সাথে Excel পড়ে তালিকা দেখাও
function onFilePicked(input) {
    if (!input.files || !input.files.length) return;
    document.getElementById('lblFile').textContent = input.files[0].name;
    document.getElementById('btnLoad').click();
}

document.addEventListener('DOMContentLoaded', function () {
    document.querySelectorAll('input[type=text]').forEach(i => {
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
