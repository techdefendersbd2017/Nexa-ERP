<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="IncrementApproval.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.Payrollinformation.IncrementApproval" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Increment Approval</title>

    <!-- tailwind css link -->
    <script src="https://cdn.tailwindcss.com"></script>


</head>
<body>
    <form id="form1" runat="server" class="min-h-screen p-2 mt-2">
        <div class="max-w-[1320px] w-full m-auto rounded-lg border">

            <div class="bg-[#0d6efd] text-white rounded-t-lg px-4 py-2">
                <p class="text-2xl mb-1">Increment Approval</p>
                <p class="">Label</p>
            </div>

            <div class="bg-[#f0f0f0] shadow-xl rounded-b-lg px-4 py-4">
                <asp:HiddenField ID="hfUserId" runat="server" />

                <div class="bg-[#f0f0f0] shadow-xl rounded-b-lg px-4 py-4">
                    <asp:HiddenField ID="HiddenField1" runat="server" />

                    <div class="grid grid-cols-3 gap-x-4 gap-y-2">

                        <div class="flex flex-col gap-0.5 w-full">
                            <label>Increment Approval ID</label>
                            <asp:TextBox ID="txtIncrementApprovalId" runat="server" ReadOnly="true" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label>Select Category</label>
                            <asp:DropDownList ID="ddlSelectCategory" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label>Select Department</label>
                            <asp:DropDownList ID="ddlSelectDepartment" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label>Select Section</label>
                            <asp:DropDownList ID="ddlSelectSection" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label>------</label>
                            <asp:DropDownList ID="ddlNull" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label>Select Designation</label>
                            <asp:DropDownList ID="ddlSelectDesignation" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label>---</label>
                            <asp:DropDownList ID="null2" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label>Date</label>
                            <asp:DropDownList ID="ddlDate" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label>---</label>
                            <asp:DropDownList ID="null3" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label>---</label>
                            <asp:TextBox ID="null4" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                        </div>

                    </div>



                    <!-- btn -->
                    <div class="space-x-4 flex justify-between items-center my-4">
                        <div class="flex items-center gap-3">
                            <asp:Button ID="btnRefresh" runat="server" Text="Refresh" CssClass="rounded bg-[#2BBBAD] text-white px-4 py-1 shadow-sm hover:bg-[#239A8D] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                            <div class="flex items-center gap-1">
                                <asp:CheckBox ID="chkIsActive" runat="server" CssClass="cursor-pointer accent-[#198754]" />
                                <asp:Label for="chkIsActive" AssociatedControlID="chkIsActive" runat="server" Text="Is Active?" CssClass="cursor-pointer"></asp:Label>
                            </div>
                        </div>
                        <div class="flex gap-3">
                            <asp:Button ID="btnShow" runat="server" Text="Show" CssClass="rounded bg-[#3b82f6] text-white px-4 py-1 shadow-sm hover:bg-[#2563eb] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                            <asp:Button ID="btnSelect" runat="server" Text="Select" CssClass="rounded bg-[#3b82f6] text-white px-4 py-1 shadow-sm hover:bg-[#2563eb] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                            <asp:Button ID="btnDeSelect" runat="server" Text="De-Select" CssClass="rounded bg-[#3b82f6] text-white px-4 py-1 shadow-sm hover:bg-[#2563eb] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                            <asp:Button ID="btnApproved" runat="server" Text="Approved" CssClass="rounded bg-[#28A745] text-white px-4 py-1 shadow-sm hover:bg-[#218838] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                            <asp:Button ID="btnReOpen" runat="server" Text="Re-Open" CssClass="rounded bg-[#f59e0b] text-white px-4 py-1 shadow-sm hover:bg-[#d97706] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                            <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="rounded bg-[#ef4444] text-white px-4 py-1 shadow-sm hover:bg-[#dc2626] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                        </div>
                    </div>

                    <!-- text grid 1st -->
                    <div class="border border-gray-400 bg-gray-50 rounded w-full h-72 overflow-y-auto">
                        <asp:GridView ID="GridView1" runat="server"></asp:GridView>
                    </div>

                </div>
            </div>
        </div>
    </form>
</body>
</html>