<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EmployeeInformationChange.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.EmployeeLifecycle.EmployeeInformationChange" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Employee Information Change Update</title>
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
        .fld:focus{outline:none;border-color:#3b82f6;box-shadow:0 0 0 3px rgba(59,130,246,.15)}
        .fld[readonly]{background:#eceff4;color:#475569}
        select.fld{padding:0 6px;cursor:pointer}
        .lbl{display:block;font-size:13px;color:#334155;margin-bottom:4px}
    </style>
</head>
<body class="bg-slate-100 text-slate-800 antialiased">
<form id="form1" runat="server" class="min-h-screen p-3" autocomplete="off">
    <div class="max-w-[1320px] w-full m-auto rounded-xl border border-slate-200 bg-white shadow-sm">

        <!-- Header -->
        <div class="bg-[#0d6efd] text-white rounded-t-xl px-5 py-3 flex items-center justify-between">
            <p class="text-xl font-semibold">Employee Information Change Update</p>
            <p class="text-sm">User Name: <asp:Label ID="lblUserName" runat="server" CssClass="font-semibold" Text="User Name" /></p>
        </div>

        <div class="bg-slate-50 rounded-b-xl px-5 py-4">

            <!-- Employee -->
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-x-4 gap-y-3">
                <div>
                    <label class="lbl">Employee ID</label>
                    <asp:TextBox ID="txtEmployeeId" runat="server" ClientIDMode="Static" CssClass="fld"
                        AutoPostBack="true" OnTextChanged="txtEmployeeId_TextChanged" placeholder="ID লিখে Enter চাপুন" />
                </div>
                <div>
                    <label class="lbl">Name</label>
                    <asp:TextBox ID="txtName" runat="server" CssClass="fld" ReadOnly="true" />
                </div>
                <div>
                    <label class="lbl">Bangla Name</label>
                    <asp:TextBox ID="txtBanglaName" runat="server" CssClass="fld" ReadOnly="true" />
                </div>
                <div>
                    <label class="lbl">Entry No</label>
                    <asp:TextBox ID="txtEntryNo" runat="server" CssClass="fld" ReadOnly="true" />
                </div>
            </div>

            <!-- Previous / New -->
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-4 my-4">

                <!-- Previous information -->
                <fieldset class="border border-slate-300 bg-white px-4 py-4 rounded-lg">
                    <legend class="px-2 text-sm font-medium italic">Previous Information</legend>
                    <div class="space-y-2.5">
                        <div>
                            <label class="lbl">Joining Date</label>
                            <asp:TextBox ID="txtJoiningDate" runat="server" CssClass="fld" ReadOnly="true" />
                        </div>
                        <div>
                            <label class="lbl">Category</label>
                            <asp:TextBox ID="txtCategory" runat="server" CssClass="fld" ReadOnly="true" />
                        </div>
                        <div>
                            <label class="lbl">Designation</label>
                            <div class="flex gap-2">
                                <asp:TextBox ID="txtDesignationOld" runat="server" CssClass="fld" ReadOnly="true" style="flex:3" />
                                <asp:TextBox ID="txtDesignation1" runat="server" CssClass="fld" ReadOnly="true" style="flex:1" ToolTip="Grade" />
                                <asp:TextBox ID="txtDesignation2" runat="server" CssClass="fld" ReadOnly="true" style="flex:1" ToolTip="Grade" />
                            </div>
                        </div>
                        <div>
                            <label class="lbl">Department</label>
                            <asp:TextBox ID="txtDepartment" runat="server" CssClass="fld" ReadOnly="true" />
                        </div>
                        <div>
                            <label class="lbl">Section</label>
                            <asp:TextBox ID="txtSection" runat="server" CssClass="fld" ReadOnly="true" />
                        </div>
                        <div>
                            <label class="lbl">Line</label>
                            <asp:TextBox ID="txtLine" runat="server" CssClass="fld" ReadOnly="true" />
                        </div>
                    </div>
                </fieldset>

                <!-- New information -->
                <fieldset class="border border-slate-300 bg-white px-4 py-4 rounded-lg">
                    <legend class="px-2 text-sm font-medium italic">New Information</legend>
                    <div class="space-y-2.5">
                        <div>
                            <label class="lbl">Effective Date</label>
                            <asp:TextBox ID="txtEffectiveDate" runat="server" ClientIDMode="Static" CssClass="fld" TextMode="Date" />
                        </div>
                        <div>
                            <label class="lbl">Category</label>
                            <asp:DropDownList ID="ddlCategory2" runat="server" CssClass="fld" AutoPostBack="true" OnSelectedIndexChanged="ddlCategory2_SelectedIndexChanged" />
                        </div>
                        <div>
                            <label class="lbl">Designation</label>
                            <div class="flex gap-2">
                                <asp:DropDownList ID="ddlDesignation" runat="server" CssClass="fld" style="flex:3" />
                                <asp:TextBox ID="txtDesignation" runat="server" CssClass="fld" ReadOnly="true" style="flex:1" ToolTip="Tafsil Code" />
                            </div>
                        </div>
                        <div>
                            <label class="lbl">Department</label>
                            <asp:DropDownList ID="ddlDepartment" runat="server" CssClass="fld" />
                        </div>
                        <div>
                            <label class="lbl">Section</label>
                            <asp:DropDownList ID="ddlSection" runat="server" CssClass="fld" />
                        </div>
                        <div>
                            <label class="lbl">Line</label>
                            <asp:DropDownList ID="ddlLine" runat="server" CssClass="fld" />
                        </div>
                    </div>
                </fieldset>
            </div>

            <!-- Buttons -->
            <div class="flex justify-end items-center gap-2 mb-4">
                <asp:LinkButton ID="btnAdd" runat="server" ClientIDMode="Static" OnClick="btnAdd_Click"
                    CssClass="h-9 px-5 rounded-lg bg-emerald-600 hover:bg-emerald-700 text-white text-sm font-medium flex items-center gap-2 shadow-sm transition">
                    <i class="fa-solid fa-plus text-xs"></i><span>Add</span>
                </asp:LinkButton>
                <asp:LinkButton ID="btnDelete" runat="server" ClientIDMode="Static" OnClick="btnDelete_Click"
                    OnClientClick="return confirm('Are you sure you want to delete this entry?');"
                    CssClass="h-9 px-5 rounded-lg bg-rose-600 hover:bg-rose-700 text-white text-sm font-medium flex items-center gap-2 shadow-sm transition">
                    <i class="fa-regular fa-trash-can text-xs"></i><span>Delete</span>
                </asp:LinkButton>
                <asp:LinkButton ID="btnRefresh" runat="server" ClientIDMode="Static" OnClick="btnRefresh_Click"
                    CssClass="h-9 px-4 rounded-lg border border-slate-300 bg-white hover:bg-slate-50 text-slate-700 text-sm font-medium flex items-center gap-2 transition">
                    <i class="fa-solid fa-rotate text-xs"></i><span>Refresh</span>
                </asp:LinkButton>
            </div>

            <!-- Open entries list -->
            <div class="bg-white border border-slate-200 rounded-xl shadow-sm overflow-hidden">
                <div class="overflow-auto h-72">
                    <table class="w-full text-left border-collapse">
                        <thead>
                            <tr class="bg-slate-50 border-b border-slate-200 text-xs font-semibold text-slate-600 uppercase tracking-wider sticky top-0 z-10">
                                <th class="py-3 px-4">Entry No</th>
                                <th class="py-3 px-4">ID No</th>
                                <th class="py-3 px-4">Name</th>
                                <th class="py-3 px-4">Designation</th>
                                <th class="py-3 px-4">Status</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100 text-sm text-slate-700 bg-white">
                            <asp:Repeater ID="rptEntries" runat="server" OnItemCommand="rptEntries_ItemCommand">
                                <ItemTemplate>
                                    <tr class="hover:bg-slate-50/80 transition-colors">
                                        <td class="py-2.5 px-4 text-xs font-semibold">
                                            <asp:LinkButton ID="lnkSelect" runat="server" CommandName="select"
                                                CommandArgument='<%# Server.HtmlEncode(Convert.ToString(Eval("EntryNo"))) %>'
                                                CssClass="text-blue-600 hover:underline"><%# Server.HtmlEncode(Convert.ToString(Eval("EntryNo"))) %></asp:LinkButton>
                                        </td>
                                        <td class="py-2.5 px-4 text-xs"><%# Server.HtmlEncode(Convert.ToString(Eval("IdNo"))) %></td>
                                        <td class="py-2.5 px-4 text-xs"><%# Server.HtmlEncode(Convert.ToString(Eval("Name"))) %></td>
                                        <td class="py-2.5 px-4 text-xs"><%# Server.HtmlEncode(Convert.ToString(Eval("Designation"))) %></td>
                                        <td class="py-2.5 px-4 text-xs"><span class="inline-flex px-2 py-0.5 rounded-full text-[10px] font-medium bg-amber-50 text-amber-700 border border-amber-200"><%# Server.HtmlEncode(Convert.ToString(Eval("Status"))) %></span></td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                            <tr id="trEmpty" runat="server" visible="false"><td colspan="5" class="text-center py-8 text-slate-400 text-xs">No open entries found.</td></tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Notification Toast Container -->
    <div id="toastContainer" class="fixed bottom-5 right-5 z-50 flex flex-col space-y-2 pointer-events-none"></div>
</form>

<script>
const esc = s => String(s).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));

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
