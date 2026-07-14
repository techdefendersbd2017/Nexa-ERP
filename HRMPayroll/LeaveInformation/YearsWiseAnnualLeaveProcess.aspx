<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="YearsWiseAnnualLeaveProcess.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.LeaveInformation.YearsWiseAnnualLeaveProcess" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Years Wise Annual Leave Process</title>
</head>

<!-- tailwind css link -->
<script src="https://cdn.tailwindcss.com"></script>

<body>
    <form id="form1" runat="server" class="min-h-screen p-2 mt-2">
        <div class="max-w-[1320px] w-full m-auto rounded-lg border">

            <div class="bg-[#0d6efd] text-white rounded-t-lg px-4 py-2">
                <p class="text-2xl mb-1">Years Wise Annual Leave Process</p>
                <p class="">Label</p>
            </div>

            <div class="bg-[#f0f0f0] shadow-xl rounded-b-lg px-4 py-4">
                <asp:HiddenField ID="hfUserId" runat="server" />

                <div class="grid grid-cols-3 gap-x-4 gap-y-1.5">

                    <div class="flex flex-col gap-0.5 w-full">
                        <asp:Label ID="Label" runat="server" Text="Employee ID"></asp:Label>
                        <asp:TextBox ID="txtEmployeeId" ReadOnly="true" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                    </div>
                    <div class="flex gap-0.5 items-end col-span-2">
                        <div class="flex flex-col gap-0.5 w-full">
                            <asp:Label ID="Label3" runat="server" CssClass="whitespace-nowrap" Text="Employee Status"></asp:Label>
                            <asp:DropDownList ID="ddlEmployeeStatus" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                        </div>
                        <asp:Button ID="btnRefresh" runat="server" Text="Refresh" CssClass="inline-block rounded bg-[#20c997] text-white px-4 py-0.5 shadow-sm hover:bg-[#1aa179] cursor-pointer transition delay-150 duration-300 ease-in-out" />
                    </div>
                    <div class="flex flex-col gap-0.5 w-full">
                        <asp:Label ID="Label5" runat="server" Text="From"></asp:Label>
                        <asp:DropDownList ID="ddlFrom" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full">
                        <asp:Label ID="Label6" runat="server" Text="Till"></asp:Label>
                        <asp:DropDownList ID="ddlTill" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                    </div>

                    <%-- checkbox 2 --%>
                    <div class="flex gap-3 w-full items-end flex-wrap">
                        <div class="flex items-center gap-0.5">
                            <asp:CheckBox ID="chkSelectAll" runat="server" CssClass="cursor-pointer accent-[#198754]" />
                            <asp:Label for="chkSelectAll" AssociatedControlID="chkSelectAll" runat="server" Text="Select All" CssClass="cursor-pointer"></asp:Label>
                        </div>
                        <div class="flex items-center gap-0.5">
                            <asp:CheckBox ID="chkDeselect" runat="server" CssClass="cursor-pointer accent-[#198754]" />
                            <asp:Label for="chkDeselect" AssociatedControlID="chkDeselect" runat="server" Text="De-Select" CssClass="cursor-pointer"></asp:Label>
                        </div>
                    </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <asp:Label ID="Label8" runat="server" Text="Category"></asp:Label>
                            <asp:DropDownList ID="ddlCategory" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full col-span-2">
                            <asp:Label ID="Label9" runat="server" Text="Department"></asp:Label>
                            <asp:DropDownList ID="ddlDepartment" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <asp:Label ID="Label10" runat="server" Text="Section"></asp:Label>
                            <asp:DropDownList ID="ddlSection" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <asp:Label ID="Label11" runat="server" Text="Sub Section"></asp:Label>
                            <asp:DropDownList ID="ddlSubSection" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <asp:Label ID="Label12" runat="server" Text="Designation"></asp:Label>
                            <asp:DropDownList ID="ddlDesignation" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full col-span-3">
                            <asp:Label ID="Label13" runat="server" Text="Multi ID No"></asp:Label>
                            <asp:TextBox ID="txtMultiIdNo" ReadOnly="true" TextMode="MultiLine" Rows2="3" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out overflow-y-auto'"></asp:TextBox>
                        </div>
                </div>


                <!-- btn -->
                <div class="space-x-4 flex justify-between items-center my-4">
                    <div class="flex items-center gap-3">
                        <asp:Button ID="btnProcess" runat="server" Text="Process" CssClass="rounded bg-[#6610f2] text-white px-4 py-0.5 shadow-sm hover:bg-[#520dc2] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                        <div class="flex items-center gap-1">
                            <asp:CheckBox ID="chkIsActive" runat="server" CssClass="cursor-pointer accent-[#198754]" />
                            <asp:Label for="chkIsActive" AssociatedControlID="chkIsActive" runat="server" Text="Is Active?" CssClass="cursor-pointer"></asp:Label>
                        </div>
                    </div>
                    <div class="flex gap-3">
                        <asp:Button ID="btnShow" runat="server" Text="Show" CssClass="rounded bg-[#0dcaf0] text-white px-4 py-1 shadow-sm hover:bg-[#0aa2c0] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                        <asp:Button ID="btnSelectAll" runat="server" Text="Select All" CssClass="rounded bg-[#198754] text-white px-4 py-1 shadow-sm hover:bg-[#146c43] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                        <asp:Button ID="btnDeselect" runat="server" Text="De-select" CssClass="inline-block rounded bg-[#fd7e14] text-white px-4 py-1 shadow-sm hover:bg-[#d65f00] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                    </div>
                </div>

                <!-- text grid 1st -->
                <div class="border border-gray-400 bg-gray-50 rounded w-full h-72 overflow-y-auto">
                    <asp:GridView ID="GridView1" runat="server"></asp:GridView>
                </div>

            </div>
        </div>
    </form>
</body>
</html>