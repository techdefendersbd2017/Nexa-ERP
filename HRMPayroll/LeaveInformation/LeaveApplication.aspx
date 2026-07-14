<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LeaveApplication.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.LeaveInformation.LeaveApplication" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Leave Application</title>
</head>

<!-- tailwind css link -->
<script src="https://cdn.tailwindcss.com"></script>

<body>
    <form id="form1" runat="server" class="min-h-screen p-2 mt-2">
        <div class="max-w-[1320px] w-full m-auto rounded-lg border">

            <div class="bg-[#0d6efd] text-white rounded-t-lg px-4 py-2">
                <p class="text-2xl mb-1">Create Sub Section</p>
                <p class="">Label</p>
            </div>

            <div class="bg-[#f0f0f0] shadow-xl rounded-b-lg px-4 py-4">
                <asp:HiddenField ID="hfUserId" runat="server" />

                <div class="grid grid-cols-4 gap-x-4 gap-y-1.5">

                    <div class="flex flex-col gap-0.5 w-full">
                        <asp:Label ID="Label" runat="server" Text="Employee ID"></asp:Label>
                        <asp:TextBox ID="txtEmployeeId" ReadOnly="true" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full">
                        <asp:Label ID="Label1" runat="server" Text="Name"></asp:Label>
                        <asp:TextBox ID="txtName" ReadOnly="true" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full">
                        <asp:Label ID="Label2" runat="server" Text="Designation"></asp:Label>
                        <asp:TextBox ID="txtDesignation" ReadOnly="true" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full">
                        <asp:Label ID="Label3" runat="server" Text="Leave Type"></asp:Label>
                        <asp:DropDownList ID="ddlLeaveType" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full">
                        <asp:Label ID="Label4" runat="server" Text="Remaining Days"></asp:Label>
                        <asp:TextBox ID="txtRemainingDays" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full">
                        <asp:Label ID="Label5" runat="server" Text="From"></asp:Label>
                        <asp:DropDownList ID="ddlFrom" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full">
                        <asp:Label ID="Label6" runat="server" Text="Till"></asp:Label>
                        <asp:DropDownList ID="ddlTill" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                    </div>

                    <%-- checkbox 3 --%>
                    <div class="flex gap-3 w-full items-end flex-wrap">
                        <div class="flex items-center gap-0.5">
                            <asp:CheckBox ID="chkPermanent" runat="server" CssClass="cursor-pointer accent-[#198754]" />
                            <asp:Label for="chkPermanent" AssociatedControlID="chkPermanent" runat="server" Text="Permanent" CssClass="cursor-pointer"></asp:Label>
                        </div>
                        <div class="flex items-center gap-0.5">
                            <asp:CheckBox ID="chkPresent" runat="server" CssClass="cursor-pointer accent-[#198754]" />
                            <asp:Label for="chkPresent" AssociatedControlID="chkPresent" runat="server" Text="Present" CssClass="cursor-pointer"></asp:Label>
                        </div>
                        <div class="flex items-center gap-0.5">
                            <asp:CheckBox ID="chkCustom" runat="server" CssClass="cursor-pointer accent-[#198754]" />
                            <asp:Label for="chkCustom" AssociatedControlID="chkCustom" runat="server" Text="Custom" CssClass="cursor-pointer"></asp:Label>
                        </div>
                    </div>
                    <div class="flex gap-3 border border-gray-300 items-center p-0.5 col-span-4 ">
                        <div class="flex flex-col gap-0.5 w-full">
                            <asp:Label ID="label13" runat="server" Text="Employee ID"></asp:Label>
                            <asp:TextBox ID="txtEmployeeId1" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out overflow-y-auto"></asp:TextBox>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <asp:Label ID="Label8" runat="server" Text="Status"></asp:Label>
                            <asp:DropDownList ID="ddlStatus" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                        </div>
                        <div class="">
                            <div class="flex gap-3 items-end mt-[25px]">
                                <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="rounded bg-[#6c757d] text-white px-4 py-0.5 shadow-sm hover:bg-[#5c636a] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                                <asp:Button ID="btnConfirmSpplication" runat="server" Text="Confirm Application" CssClass="rounded bg-[#198754] text-white px-4 py-0.5 shadow-sm hover:bg-[#157347] cursor-pointer transition delay-150 duration-300 ease-in-out" />
                            </div>
                        </div>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full col-span-2">
                        <asp:Label ID="Label7" runat="server" Text="Purpose"></asp:Label>
                        <asp:TextBox ID="txtPurpose" TextMode="MultiLine" Rows="3" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out overflow-y-auto"></asp:TextBox>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full col-span-2">
                        <asp:Label ID="label12" runat="server" Text="Address"></asp:Label>
                        <asp:TextBox ID="txtAddress" TextMode="MultiLine" Rows="3" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out overflow-y-auto"></asp:TextBox>
                    </div>

                </div>


                <!-- btn -->
                <div class="space-x-4 flex justify-between items-center my-4">
                    <div class="flex items-center gap-3">
                        <asp:Button ID="btnApplication" runat="server" Text="Application" CssClass="rounded bg-[#198754] text-white px-4 py-0.5 shadow-sm hover:bg-[#157347] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                        <div class="flex items-center gap-1">
                            <asp:CheckBox ID="chkIsActive" runat="server" CssClass="cursor-pointer accent-[#198754]" />
                            <asp:Label for="chkIsActive" AssociatedControlID="chkIsActive" runat="server" Text="Is Active?" CssClass="cursor-pointer"></asp:Label>
                        </div>
                    </div>
                    <div class="flex gap-3">
                        <asp:Button ID="btnUpdate" runat="server" Text="Update" CssClass="rounded bg-[#f59e0b] text-white px-4 py-1 shadow-sm hover:bg-[#d97706] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                        <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="rounded bg-[#198754] text-white px-4 py-1 shadow-sm hover:bg-[#146c43] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                        <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="inline-block rounded bg-[#dc3545] text-white px-4 py-1 shadow-sm hover:bg-[#bb2d3b] cursor-pointer transition delay-150 duration-300 ease-in-out" />

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