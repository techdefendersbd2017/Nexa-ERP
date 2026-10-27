<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SalaryBreckDownProcess.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.Payrollinformation.SalaryBreckDownProcess" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Salary Breck Down Process</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />

    <!-- tailwind css link -->
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body>
    <form id="form1" runat="server" class="min-h-screen p-2 mt-2" autocomplete="off">
        <div class="max-w-[1320px] w-full m-auto rounded-lg border">

            <div class="bg-[#0d6efd] text-white rounded-t-lg px-4 py-2">
                <p class="text-2xl mb-1">Salary Breck Down Process</p>
                <p><asp:Label ID="lblInfo" runat="server" Text="0 Employees" /></p>
            </div>

            <div class="bg-[#f0f0f0] shadow-xl rounded-b-lg px-4 py-4">

                <!-- ফলাফল / এরর বার্তা -->
                <asp:Label ID="lblMsg" runat="server" Visible="false" CssClass="block mb-3 rounded px-3 py-2 text-sm" />

                <div class="grid grid-cols-6 gap-x-4 gap-y-2">

                    <!-- Employee grid -->
                    <div class="border border-gray-400 bg-gray-50 shadow-xl rounded w-full max-h-[75vh] overflow-y-auto col-span-5">
                        <asp:GridView ID="GridView1" runat="server" ClientIDMode="Static"
                            AutoGenerateColumns="false" DataKeyNames="ID_no"
                            UseAccessibleHeader="true"
                            CssClass="w-full text-left border-collapse text-sm"
                            HeaderStyle-CssClass="bg-slate-100 text-slate-700 sticky top-0 z-10"
                            RowStyle-CssClass="border-t border-gray-200 hover:bg-slate-50"
                            AlternatingRowStyle-CssClass="border-t border-gray-200 bg-white hover:bg-slate-50"
                            EmptyDataText="No employee found.">
                            <Columns>
                                <asp:TemplateField>
                                    <HeaderTemplate>
                                        <input type="checkbox" id="chkHead" class="w-4 h-4 cursor-pointer accent-[#0d6efd]"
                                            onclick="toggleAll(this.checked);" checked="checked" />
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <asp:CheckBox ID="chkSel" runat="server" CssClass="cursor-pointer accent-[#0d6efd]" />
                                    </ItemTemplate>
                                    <HeaderStyle CssClass="px-3 py-2 w-10" />
                                    <ItemStyle CssClass="px-3 py-1.5" />
                                </asp:TemplateField>
                                <asp:BoundField DataField="ID_no" HeaderText="ID No">
                                    <HeaderStyle CssClass="px-3 py-2" />
                                    <ItemStyle CssClass="px-3 py-1.5 font-medium" />
                                </asp:BoundField>
                                <asp:BoundField DataField="Name" HeaderText="Name">
                                    <HeaderStyle CssClass="px-3 py-2" />
                                    <ItemStyle CssClass="px-3 py-1.5" />
                                </asp:BoundField>
                                <asp:BoundField DataField="Designation" HeaderText="Designation">
                                    <HeaderStyle CssClass="px-3 py-2" />
                                    <ItemStyle CssClass="px-3 py-1.5" />
                                </asp:BoundField>
                            </Columns>
                        </asp:GridView>
                    </div>

                    <!-- Buttons -->
                    <div class="space-y-4 flex flex-col my-4">
                        <div class="flex items-center gap-3">
                            <asp:Button ID="btnRefresh" runat="server" Text="Refresh" OnClick="btnRefresh_Click"
                                CssClass="rounded bg-[#2BBBAD] text-white px-4 py-1 shadow-sm hover:bg-[#239A8D] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                            <div class="flex items-center gap-1">
                                <asp:CheckBox ID="chkIsActive" runat="server" Checked="true" CssClass="cursor-pointer accent-[#198754]" />
                                <asp:Label AssociatedControlID="chkIsActive" runat="server" Text="Is Active?" CssClass="cursor-pointer"></asp:Label>
                            </div>
                        </div>

                        <div class="flex flex-col gap-3">
                            <asp:Button ID="btnSelectAll" runat="server" Text="Select All" OnClientClick="toggleAll(true); return false;"
                                CssClass="rounded bg-[#3b82f6] text-white px-4 py-1 shadow-sm hover:bg-[#2563eb] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                            <asp:Button ID="btnNoSelect" runat="server" Text="No Select" OnClientClick="toggleAll(false); return false;"
                                CssClass="rounded bg-[#3b82f6] text-white px-4 py-1 shadow-sm hover:bg-[#2563eb] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                            <asp:Button ID="btnProcess" runat="server" Text="Process" OnClick="btnProcess_Click"
                                OnClientClick="return confirmProcess();"
                                CssClass="rounded bg-[#2FBF71] text-white px-4 py-1 shadow-sm hover:bg-[#26A65B] cursor-pointer transition delay-150 duration-300 ease-in-out" />
                        </div>
                    </div>

                </div>
            </div>
        </div>
    </form>

    <script>
// গ্রিডের সব চেকবক্স (হেডারসহ) টিক / আনটিক — পোস্টব্যাক ছাড়াই
function toggleAll(state) {
    document.querySelectorAll('#GridView1 input[type=checkbox]').forEach(function (c) { c.checked = state; });
}

// হেডার বাদে টিক দেওয়া সারির সংখ্যা
function checkedCount() {
    return document.querySelectorAll('#GridView1 tbody input[type=checkbox]:checked').length;
}

function confirmProcess() {
    var n = checkedCount();
    if (n === 0) { alert('Please Select Employee'); return false; }
    return confirm('Process salary for ' + n + ' selected employee(s)?');
}
</script>
</body>
</html>
