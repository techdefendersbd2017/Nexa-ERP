<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EmployeeInformationChange.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.EmployeeLifecycle.EmployeeInformationChange" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Employee Information Change Update</title>
</head>

<!-- tailwind css link -->
<script src="https://cdn.tailwindcss.com"></script>

<body>
    <form id="form1" runat="server" class="min-h-screen p-2 mt-2">
        <div class="max-w-[1320px] w-full m-auto rounded-lg border">

            <div class="bg-[#0d6efd] text-white rounded-t-lg px-4 py-2">
                <p class="text-2xl mb-1">Employee Information Change Update</p>
                <p class="">Label</p>
            </div>

            <div class="bg-[#f0f0f0] shadow-xl rounded-b-lg px-4 py-4">
                <asp:HiddenField ID="hfUserId" runat="server" />

                <div class="grid grid-cols-5 gap-x-4 gap-y-1.5">

                    <div class="flex flex-col gap-0.5 w-full">
                        <asp:Label ID="Label8" runat="server" Text="Employee ID"></asp:Label>
                        <asp:TextBox ID="txtEmployeeId" ReadOnly="true" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full">
                        <asp:Label ID="Label9" runat="server" Text="User Name"></asp:Label>
                        <asp:TextBox ID="txtUserName" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full">
                        <asp:Label ID="Label10" runat="server" Text="Entry No"></asp:Label>
                        <asp:TextBox ID="txtEntryNo" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                    </div>

                    <div class="flex flex-col gap-0.5 w-full">
                        <asp:Label ID="Label11" runat="server" Text="Name"></asp:Label>
                        <asp:TextBox ID="txtName" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full">
                        <asp:Label ID="Label12" runat="server" Text="Bangla Name"></asp:Label>
                        <asp:TextBox ID="txtBanglaName" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                    </div>


                </div>


                <!-- Previous Information -->
                <div class="grid grid-cols-2 gap-4 my-4">
                    <fieldset class="border border-gray-400 px-4 py-4 rounded">
                        <legend class="px-2 text-sm font-medium italic">Previous information</legend>


                        <div class="space-y-1.5">

                            <div class="flex flex-col gap-0.5 w-full">
                                <asp:Label ID="Label1" runat="server" Text="Category"></asp:Label>
                                <asp:TextBox ID="txtCategory" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                            </div>


                            <div class="flex gap-1.5 items-end w-full">
                                <div class="flex flex-col gap-0.5 w-3/4">
                                    <label>Designation</label>
                                    <asp:TextBox ID="TextBox1" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex gap-1.5 w-1/4">
                                    <asp:TextBox ID="txtDesignation1" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                    <asp:TextBox ID="txtDesignation2" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                            </div>

                            <div class="flex flex-col gap-0.5 w-full">
                                <asp:Label ID="Label16" runat="server" Text="Department"></asp:Label>
                                <asp:TextBox ID="txtDepartment" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <asp:Label ID="Label17" runat="server" Text="Section"></asp:Label>
                                <asp:TextBox ID="txtSection" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <asp:Label ID="Label18" runat="server" Text="Line"></asp:Label>
                                <asp:TextBox ID="txtLine" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <asp:Label ID="Label13" runat="server" Text="Joining Date"></asp:Label>
                                <asp:DropDownList ID="ddlJoiningDate" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                            </div>
                        </div>
                    </fieldset>


                    <!-- New information -->

                    <fieldset class="border border-gray-400 px-4 py-4 rounded">
                        <legend class="px-2 text-sm font-medium italic">New Information</legend>


                        <div class="space-y-1.5">

                            <div class="flex flex-col gap-0.5 w-full">
                                <asp:Label ID="Label30" runat="server" Text="Category"></asp:Label>
                                <asp:DropDownList ID="ddlCategory2" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                            </div>

                            <div class="flex gap-1.5 items-end w-full">
                                <div class="flex flex-col gap-0.5 w-3/4">
                                    <label>Designation</label>
                                    <asp:DropDownList ID="ddlDesignation" runat="server" CssClass="border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="w-1/4">
                                    <asp:TextBox ID="txtDesignation" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <asp:Label ID="Label20" runat="server" Text="Department"></asp:Label>
                                <asp:DropDownList ID="ddlDepartment" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <asp:Label ID="Label31" runat="server" Text="Section"></asp:Label>
                                <asp:DropDownList ID="ddlSection" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <asp:Label ID="Label32" runat="server" Text="Line"></asp:Label>
                                <asp:DropDownList ID="ddlLine" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <asp:Label ID="Label21" runat="server" Text="Effective Date"></asp:Label>
                                <asp:DropDownList ID="ddlEffectiveDate" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                            </div>

                        </div>
                    </fieldset>
                </div>

                <!-- btn -->
                <div class="space-x-4 flex justify-between items-center my-4">
                    <div class="flex items-center gap-3">
                        <asp:Button ID="btnRefresh" runat="server" Text="Refresh" CssClass="inline-block rounded bg-[#20c997] text-white px-4 py-1 shadow-sm hover:bg-[#1aa179] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                        <div class="flex items-center gap-1">
                            <asp:CheckBox ID="chkIsActive" runat="server" CssClass="cursor-pointer accent-[#198754]"/>
                            <asp:Label for="chkIsActive" AssociatedControlID="chkIsActive" runat="server" Text="Is Active?" CssClass="cursor-pointer"></asp:Label>
                        </div>
                    </div>
                    <div class="flex gap-3">
                        <asp:Button ID="btnAdd" runat="server" Text="Add" CssClass="rounded bg-[#198754] text-white px-4 py-1 shadow-sm hover:bg-[#146c43] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                        <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="rounded bg-[#dc3545] text-white px-4 py-1 shadow-sm hover:bg-[#bb2d3b] cursor-pointer transition delay-150 duration-300 ease-in-out" />
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