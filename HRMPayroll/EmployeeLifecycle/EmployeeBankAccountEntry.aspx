<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EmployeeBankAccountEntry.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.EmployeeLifecycle.EmployeeBankAccountEntry" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Bank Account Entry</title>

    <!-- tailwind css link -->
    <script src="https://cdn.tailwindcss.com"></script>

    <style>
        #chkIsActive {
            accent-color: #198754;
            cursor: pointer !important;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server" class="min-h-screen p-2 mt-2">
        <div class="max-w-[1320px] w-full m-auto rounded-lg border">

            <div class="bg-[#0d6efd] text-white rounded-t-lg px-4 py-1">
                <p class="text-2xl mb-1">Bank Account Entry</p>
                <p class="">Label</p>
            </div>

            <div class="bg-[#f0f0f0] shadow-xl rounded-b-lg px-4 py-3 space-y-2 ">
                <asp:HiddenField ID="hfUserId" runat="server" />


                <div class="grid grid-cols-4 gap-3">

                    <div class="flex flex-col gap-1 w-full">
                        <label>Account ID</label>
                        <asp:TextBox ID="txtAccountId" runat="server" ReadOnly="true" CssClass="border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                    </div>

                    <div class="flex flex-col gap-1 w-full">
                        <asp:Label ID="Label2" runat="server" Text="Account Name"></asp:Label>
                        <asp:TextBox ID="txtAccountName" runat="server" CssClass="border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                    </div>

                    <div class="flex flex-col gap-1 w-full">
                        <asp:Label ID="Label3" runat="server" Text="Designation"></asp:Label>
                        <asp:TextBox ID="txtDesignation" runat="server" CssClass="border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                    </div>

                    <div class="flex flex-col gap-1 w-full">
                        <asp:Label ID="Label4" runat="server" Text="Department"></asp:Label>
                        <asp:TextBox ID="txtDepartment" runat="server" CssClass="border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                    </div>

                    <div class="grid grid-cols-3 col-span-4 gap-3">
                        <div class="flex flex-col gap-1 w-full">
                            <asp:Label ID="Label5" runat="server" Text="Section Name"></asp:Label>
                            <asp:TextBox ID="txtSectionName" runat="server" CssClass="border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                        </div>

                        <div class="flex flex-col gap-1 w-full">
                            <asp:Label ID="Label6" runat="server" Text="Bank Name"></asp:Label>
                            <asp:TextBox ID="txtBName" runat="server" CssClass="border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                        </div>

                        <div class="flex flex-col gap-1 w-full">
                            <asp:Label ID="Label7" runat="server" Text="Account No"></asp:Label>
                            <asp:TextBox ID="txtAccNo" runat="server" CssClass="border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                        </div>
                    </div>
                </div>

                <!-- btn -->
                <div class="space-x-4 flex justify-between items-center py-4">
                    <div class="flex items-center gap-3">
                        <asp:Button ID="btnRefresh" runat="server" Text="Refresh" CssClass="inline-block rounded bg-[#20c997] text-white px-4 py-1 shadow-sm hover:bg-[#1aa179] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                        <div class="flex items-center gap-1">
                            <asp:CheckBox ID="chkIsActive" runat="server" />
                            <asp:Label for="chkIsActive" AssociatedControlID="chkIsActive" runat="server" Text="Is Active?" CssClass="cursor-pointer"></asp:Label>
                        </div>
                    </div>
                    <div class="flex gap-3">
                        <asp:Button ID="btnAdd" runat="server" Text="Add" CssClass="rounded bg-[#198754] text-white px-4 py-1 shadow-sm hover:bg-[#146c43] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                        <asp:Button ID="btnUpdate" runat="server" Text="Update" CssClass="rounded bg-[#3b82f6] text-white px-4 py-1 shadow-sm hover:bg-[#2563eb] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                        <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="rounded bg-[#dc3545] text-white px-4 py-1 shadow-sm hover:bg-[#bb2d3b] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                        <asp:Button ID="btnListView" runat="server" Text="List View" CssClass="rounded bg-[#6f42c1] text-white px-4 py-1 shadow-sm hover:bg-[#5936a2] cursor-pointer transition delay-150 duration-300 ease-in-out" />
                    </div>
                </div>


                <!-- text grid -->
                <div class="border border-gray-400 rounded w-full h-72 overflow-y-scroll">
                    <asp:GridView ID="GridView1" runat="server"></asp:GridView>
                    
                </div>
            </div>
        </div>
    </form>
</body>
</html>
