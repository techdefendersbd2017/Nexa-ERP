<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LeaveApplication.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.LeaveInformation.LeaveApplication" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Leave Application</title>
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

        /* ---- Filter fields (HRM Reports এর মতই) ---- */
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
        .fld.ro,.fld[readonly]{background:#eceef3;color:#334155}
        .lbl{display:block;font-size:13px;color:#334155;margin-bottom:6px}
        .chk label{margin-left:4px;cursor:pointer;font-size:13px;color:#334155}
        .chk input{cursor:pointer;accent-color:#198754}
    </style>
</head>
<body class="bg-slate-100 text-slate-800 antialiased h-screen flex flex-col overflow-hidden">
<form id="form1" runat="server" class="flex flex-col h-screen overflow-hidden" autocomplete="off">
    <asp:HiddenField ID="hfApplyNo" runat="server" ClientIDMode="Static" />

    <section class="bg-white border-b border-slate-200 px-6 py-4 shrink-0 relative z-30">
        <h1 class="text-base font-bold text-slate-800 mb-3">Leave Application</h1>
        <div class="bg-slate-50/70 border border-slate-200 rounded-xl p-4">
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-x-4 gap-y-3">

                <div><label class="lbl">Employee ID</label>
                    <asp:TextBox ID="txtEmployeeId" runat="server" ClientIDMode="Static" CssClass="fld" AutoPostBack="true" OnTextChanged="txtEmployeeId_TextChanged" placeholder="Type ID, press Enter" /></div>
                <div><label class="lbl">Name</label>
                    <asp:TextBox ID="txtName" runat="server" ReadOnly="true" CssClass="fld ro" /></div>
                <div><label class="lbl">Designation</label>
                    <asp:TextBox ID="txtDesignation" runat="server" ReadOnly="true" CssClass="fld ro" /></div>
                <div><label class="lbl">Leave Type</label>
                    <asp:DropDownList ID="ddlLeaveType" runat="server" CssClass="fld" AutoPostBack="true" OnSelectedIndexChanged="ddlLeaveType_SelectedIndexChanged" /></div>

                <div><label class="lbl">Remaining Days</label>
                    <asp:TextBox ID="txtRemainingDays" runat="server" ReadOnly="true" CssClass="fld ro" /></div>
                <div><label class="lbl">From Date</label>
                    <asp:TextBox ID="txtFromDate" runat="server" TextMode="Date" CssClass="fld date" AutoPostBack="true" OnTextChanged="txtFromDate_TextChanged" /></div>
                <div><label class="lbl">Till Date</label>
                    <asp:TextBox ID="txtTillDate" runat="server" TextMode="Date" CssClass="fld date" /></div>
                <div><label class="lbl">Address From</label>
                    <div class="chk flex items-center gap-4 h-8">
                        <asp:CheckBox ID="chkPermanent" runat="server" Text="Permanent" AutoPostBack="true" OnCheckedChanged="chkPermanent_CheckedChanged" />
                        <asp:CheckBox ID="chkPresent" runat="server" Text="Present" AutoPostBack="true" OnCheckedChanged="chkPresent_CheckedChanged" />
                        <asp:CheckBox ID="chkCustom" runat="server" Text="Custom" AutoPostBack="true" OnCheckedChanged="chkCustom_CheckedChanged" />
                    </div></div>

                <%-- Desktop backend (Pro_Leave_Appliction) এ @Phone ও @Alternate_Person লাগে, তাই এ দুটি যোগ করা হয়েছে --%>
                <div><label class="lbl">Phone No</label>
                    <asp:TextBox ID="txtPhone" runat="server" CssClass="fld" placeholder="Phone number" /></div>
                <div><label class="lbl">Alternate Person</label>
                    <asp:TextBox ID="txtAlternate" runat="server" CssClass="fld" placeholder="Alternate person" /></div>
                <div class="lg:col-span-1 hidden lg:block"></div>
                <div class="hidden lg:block"></div>

                <div class="sm:col-span-2"><label class="lbl">Purpose</label>
                    <asp:TextBox ID="txtPurpose" runat="server" TextMode="MultiLine" Rows="3" CssClass="fld" /></div>
                <div class="sm:col-span-2"><label class="lbl">Address</label>
                    <asp:TextBox ID="txtAddress" runat="server" TextMode="MultiLine" Rows="3" CssClass="fld" /></div>
            </div>
        </div>

        <div class="flex justify-end items-center gap-2 mt-3">
            <asp:LinkButton ID="btnSave" runat="server" OnClick="btnSave_Click" CssClass="h-9 px-5 rounded-lg bg-emerald-600 hover:bg-emerald-700 text-white text-sm font-medium flex items-center gap-2 shadow-sm transition">
                <i class="fa-regular fa-floppy-disk text-xs"></i><span>Save</span>
            </asp:LinkButton>
            <asp:LinkButton ID="btnUpdate" runat="server" OnClick="btnUpdate_Click" CssClass="h-9 px-5 rounded-lg bg-amber-500 hover:bg-amber-600 text-white text-sm font-medium flex items-center gap-2 shadow-sm transition">
                <i class="fa-solid fa-pen text-xs"></i><span>Update</span>
            </asp:LinkButton>
            <asp:LinkButton ID="btnDelete" runat="server" OnClick="btnDelete_Click" OnClientClick="return confirm('Are you sure you want to delete this leave application?');" CssClass="h-9 px-5 rounded-lg bg-red-600 hover:bg-red-700 text-white text-sm font-medium flex items-center gap-2 shadow-sm transition">
                <i class="fa-regular fa-trash-can text-xs"></i><span>Delete</span>
            </asp:LinkButton>
            <asp:LinkButton ID="btnApplication" runat="server" OnClick="btnApplication_Click" OnClientClick="return onAppClick();" CssClass="h-9 px-5 rounded-lg bg-blue-600 hover:bg-blue-700 text-white text-sm font-medium flex items-center gap-2 shadow-sm transition">
                <i class="fa-solid fa-print text-xs"></i><span>Application</span>
            </asp:LinkButton>
            <asp:LinkButton ID="btnClear" runat="server" OnClick="btnClear_Click" CssClass="h-9 px-4 rounded-lg border border-slate-300 bg-white hover:bg-slate-50 text-slate-700 text-sm font-medium flex items-center gap-2 transition">
                <i class="fa-solid fa-eraser text-xs"></i><span>Clear</span>
            </asp:LinkButton>
        </div>
    </section>

    <!-- Results -->
    <div class="flex-1 flex flex-col min-h-0 overflow-hidden">
        <main class="flex-1 flex flex-col min-h-0 bg-slate-100 overflow-hidden relative">

            <div class="bg-white border-b border-slate-200 px-6 py-3 flex flex-wrap items-center justify-between gap-4 shrink-0">
                <div>
                    <div class="flex items-center space-x-2">
                        <h2 class="text-base font-bold text-slate-800">Open Leave Applications</h2>
                        <asp:Label ID="lblCount" runat="server" CssClass="bg-indigo-50 text-indigo-700 text-xs font-semibold px-2.5 py-0.5 rounded-full border border-indigo-100" Text="0 Records" />
                    </div>
                    <p class="text-xs text-slate-500 mt-0.5">Click a row to load it into the form for Update / Delete.</p>
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
                                    <th class="py-3.5 px-4">Apply No</th>
                                    <th class="py-3.5 px-4">ID No</th>
                                    <th class="py-3.5 px-4">Leave Type</th>
                                    <th class="py-3.5 px-4">From Date</th>
                                    <th class="py-3.5 px-4">Till Date</th>
                                    <th class="py-3.5 px-4">Apply Days</th>
                                </tr>
                            </thead>
                            <tbody id="tableBody" class="divide-y divide-slate-100 text-sm text-slate-700 bg-white">
                                <asp:Repeater ID="rptApplications" runat="server" OnItemCommand="rptApplications_ItemCommand">
                                    <ItemTemplate>
                                        <tr class="cursor-pointer hover:bg-slate-50/80 transition-colors <%# Convert.ToString(Eval("ApplyNo")) == hfApplyNo.Value ? "bg-blue-50" : "" %>"
                                            onclick="var a=this.querySelector('a');if(a)a.click();">
                                            <td class="py-3 px-4 text-xs font-semibold text-blue-700">
                                                <asp:LinkButton ID="lnkPick" runat="server" CommandName="pick"
                                                    CommandArgument='<%# Server.HtmlEncode(Convert.ToString(Eval("ApplyNo"))) %>'
                                                    Text='<%# Server.HtmlEncode(Convert.ToString(Eval("ApplyNo"))) %>' />
                                            </td>
                                            <td class="py-3 px-4 text-xs font-semibold text-slate-900"><%# Server.HtmlEncode(Convert.ToString(Eval("IdNo"))) %></td>
                                            <td class="py-3 px-4 text-xs text-slate-600"><%# Server.HtmlEncode(Convert.ToString(Eval("LeaveType"))) %></td>
                                            <td class="py-3 px-4 text-xs text-slate-600"><%# Server.HtmlEncode(Convert.ToString(Eval("FromDate"))) %></td>
                                            <td class="py-3 px-4 text-xs text-slate-600"><%# Server.HtmlEncode(Convert.ToString(Eval("TillDate"))) %></td>
                                            <td class="py-3 px-4 text-xs text-slate-600"><%# Server.HtmlEncode(Convert.ToString(Eval("Days"))) %></td>
                                        </tr>
                                    </ItemTemplate>
                                </asp:Repeater>
                                <tr id="trEmpty" runat="server" visible="false"><td colspan="6" class="text-center py-8 text-slate-400 text-xs">No open leave applications found.</td></tr>
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

    <!-- Toast -->
    <div id="toastContainer" class="fixed bottom-5 right-5 z-50 flex flex-col space-y-2 pointer-events-none"></div>
</form>

<script>
// @ts-nocheck
const esc = s => String(s).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));

// Application (রিপোর্ট) বাটন: নতুন ট্যাবে খোলে, এই পেজ অপরিবর্তিত থাকে
function onAppClick() {
    var id = document.getElementById('txtEmployeeId').value.trim();
    if (!id) { showNotification('Please enter Employee ID first.'); return false; }
    var f = document.forms[0];
    f.target = '_blank';
    setTimeout(function () { f.target = ''; }, 1000);
    return true;
}

// Enter চাপলে ফর্ম সাবমিট বন্ধ; Employee ID তে Enter = ডেটা লোড
document.addEventListener('DOMContentLoaded', function () {
    document.getElementById('form1').addEventListener('keydown', function (e) {
        if (e.key !== 'Enter') return;
        var t = e.target;
        if (t.tagName === 'TEXTAREA' || t.tagName === 'A' || t.tagName === 'BUTTON') return;
        e.preventDefault();
        if (t.id === 'txtEmployeeId') __doPostBack('<%= txtEmployeeId.UniqueID %>', '');
    });
});

// টেবিলের Quick filter
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
