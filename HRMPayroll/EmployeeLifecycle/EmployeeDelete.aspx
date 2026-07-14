<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EmployeeDelete.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.EmployeeLifecycle.EmployeeDelete" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Employee Delete</title>

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

            <div class="bg-[#f0f0f0] shadow-xl rounded-b-lg px-4 py-1 space-y-3 ">
                <asp:HiddenField ID="hfUserId" runat="server" />

                <div class="border border-gray-400 p-2 flex gap-4">

                    <!-- employee id -->
                    <div class="flex flex-col gap-1.5 items-center flex-1">
                        <div class="flex gap-1 items-end w-full">
                            <div class="flex flex-col gap-0.5 w-full">
                                <label>Employee ID</label>
                                <asp:TextBox ID="txtAccountId" runat="server" ReadOnly="true" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                            </div>
                            <div>
                                <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="w-full rounded border border-gray-400 bg-[#f0f0f0] px-4 py-[1px] shadow-sm hover:bg-[#e2e2e2] cursor-pointer transition delay-150 duration-300 ease-in-out" />
                            </div>
                        </div>

                        <div class="flex gap-1.5 items-end w-full">
                            <div class="flex flex-col gap-0.5">
                                <label>Name</label>
                                <asp:DropDownList ID="ddlName" runat="server" CssClass="border rounded outline-none border-gray-300 w-20 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                            </div>
                            <div class="w-full">
                                <asp:TextBox ID="txtName" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                            </div>
                        </div>

                        <div class="flex flex-col gap-0.5 w-full">
                            <asp:Label ID="Label2" runat="server" Text="Bangla Name"></asp:Label>
                            <asp:TextBox ID="txtBanglaName" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                        </div>

                        <div class="flex flex-col gap-0.5 w-full">
                            <asp:Label ID="Label3" runat="server" Text="User Name"></asp:Label>
                            <asp:TextBox ID="txtUserName" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                        </div>
                    </div>

                    <!-- date container -->
                    <div class="flex flex-col gap-1.5 items-center flex-1">
                        <div class="flex flex-col gap-0.5 w-full">
                            <asp:Label ID="Label4" runat="server" Text="Joining Date"></asp:Label>
                            <asp:DropDownList ID="ddlJoiningDate" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <asp:Label ID="Label5" runat="server" Text="Probation Period"></asp:Label>
                            <asp:DropDownList ID="ddlProbationPeriod" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <asp:Label ID="Label6" runat="server" Text="Employee Status"></asp:Label>
                            <asp:DropDownList ID="ddlEmployeeStatus" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <asp:Label ID="Label7" runat="server" Text="Lock Status"></asp:Label>
                            <asp:DropDownList ID="ddlLockStatus" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                        </div>

                    </div>


                    <!-- Image profile -->
                    <div class="flex flex-col items-center gap-1.5">
                        <asp:ImageMap ID="ImageMap1" runat="server" CssClass="w-44 h-48 border border-gray-300 bg-gray-50 shadow-sm object-cover"></asp:ImageMap>
                        <asp:Button ID="btnPhoto" runat="server" Text="Photo" CssClass="w-44 rounded border border-gray-400 bg-[#f0f0f0] py-[1px] mt-2 shadow-sm transition hover:bg-[#e2e2e2] cursor-pointer" />
                    </div>
                </div>


                <div class="grid grid-cols-4 gap-x-4 gap-y-1.5">

                    <div class="flex flex-col gap-0.5 w-full">
                        <asp:Label ID="Label8" runat="server" Text="Company"></asp:Label>
                        <asp:DropDownList ID="ddlCompany" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full">
                        <asp:Label ID="Label9" runat="server" Text="Branch"></asp:Label>
                        <asp:DropDownList ID="ddlBranch" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full">
                        <asp:Label ID="Label10" runat="server" Text="Department"></asp:Label>
                        <asp:DropDownList ID="ddlDepartment" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full">
                        <asp:Label ID="Label11" runat="server" Text="Section"></asp:Label>
                        <asp:DropDownList ID="ddlSection" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full">
                        <asp:Label ID="Label12" runat="server" Text="Line"></asp:Label>
                        <asp:DropDownList ID="ddlLine" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full">
                        <asp:Label ID="Label13" runat="server" Text="Designation"></asp:Label>
                        <asp:DropDownList ID="ddlDesignation" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full">
                        <asp:Label ID="Label14" runat="server" Text="Category"></asp:Label>
                        <asp:DropDownList ID="ddlCategory" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full">
                        <asp:Label ID="Label15" runat="server" Text="Shift"></asp:Label>
                        <asp:DropDownList ID="ddlShift" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full">
                        <asp:Label ID="Label16" runat="server" Text="Weekly Holiday"></asp:Label>
                        <asp:DropDownList ID="ddlWeeklyHoliday" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full">
                        <asp:Label ID="Label17" runat="server" Text="Break Down"></asp:Label>
                        <asp:DropDownList ID="ddlBreakDown" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full">
                        <asp:Label ID="Label18" runat="server" Text="Gross Salary"></asp:Label>
                        <asp:TextBox ID="txtGrossSalary" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full">
                        <asp:Label ID="Label19" runat="server" Text="Tex Holder"></asp:Label>
                        <asp:DropDownList ID="ddlTexHolder" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full">
                        <asp:Label ID="Label20" runat="server" Text="Amount"></asp:Label>
                        <asp:TextBox ID="txtAmount" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full">
                        <asp:Label ID="Label21" runat="server" Text="Bank Holder"></asp:Label>
                        <asp:DropDownList ID="ddlBankHolder" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full">
                        <asp:Label ID="Label22" runat="server" Text="Bank Name"></asp:Label>
                        <asp:DropDownList ID="ddlBankName" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full">
                        <asp:Label ID="Label23" runat="server" Text="A/C No"></asp:Label>
                        <asp:TextBox ID="txtAcNo" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                    </div>

                </div>


                <!-- btn -->
                <div class="space-x-4 flex justify-between items-center py-2">
                    <div class="flex items-center gap-3">
                        <asp:Button ID="btnRefresh" runat="server" Text="Refresh" CssClass="inline-block rounded bg-[#20c997] text-white px-4 py-1 shadow-sm hover:bg-[#1aa179] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                        <div class="flex items-center gap-1">
                            <asp:CheckBox ID="chkIsActive" runat="server" />
                            <asp:Label for="chkIsActive" AssociatedControlID="chkIsActive" runat="server" Text="Is Active?" CssClass="cursor-pointer"></asp:Label>
                        </div>
                    </div>
                    <div class="flex gap-3">
                        <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="rounded bg-[#198754] text-white px-4 py-1 shadow-sm hover:bg-[#146c43] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                        <asp:Button ID="btnUpdate" runat="server" Text="Update" CssClass="rounded bg-[#3b82f6] text-white px-4 py-1 shadow-sm hover:bg-[#2563eb] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                        <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="rounded bg-[#dc3545] text-white px-4 py-1 shadow-sm hover:bg-[#bb2d3b] cursor-pointer transition delay-150 duration-300 ease-in-out" />
                    </div>
                </div>

            </div>

        </div>
    </form>
</body>
</html>