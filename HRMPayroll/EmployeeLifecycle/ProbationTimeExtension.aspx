<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ProbationTimeExtension.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.EmployeeLifecycle.ProbationTimeExtension" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Probation Time Extension</title>
</head>

<!-- tailwind css link -->
<script src="https://cdn.tailwindcss.com"></script>

<body>
    <form id="form1" runat="server" class="min-h-screen p-2 mt-2">
        <div class="max-w-[1320px] w-full m-auto rounded-lg border">

            <div class="bg-[#0d6efd] text-white rounded-t-lg px-4 py-2">
                <p class="text-2xl mb-1">Probation Time Extension</p>
                <p class="">Label</p>
            </div>

            <div class="bg-[#f0f0f0] shadow-xl rounded-b-lg px-4 py-4">
                <asp:HiddenField ID="hfUserId" runat="server" />

                <div class="grid grid-cols-2 gap-x-4 gap-y-1.5">

                    <div class="grid grid-cols-2 gap-x-4 gap-y-1.5">
                        <div class="flex flex-col gap-0.5 w-full">
                            <asp:Label ID="Label1" runat="server" Text="Employee ID"></asp:Label>
                            <asp:TextBox ID="txtEmployeeId" ReadOnly="true" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <asp:Label ID="Label2" runat="server" Text="Employee Name"></asp:Label>
                            <asp:TextBox ID="txtEmployeeName" ReadOnly="true" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <asp:Label ID="Label3" runat="server" Text="Designation"></asp:Label>
                            <asp:TextBox ID="txtDesignation" ReadOnly="true" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <asp:Label ID="Label4" runat="server" Text="Department"></asp:Label>
                            <asp:TextBox ID="txtDepartment" ReadOnly="true" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <asp:Label ID="Label5" runat="server" Text="Section"></asp:Label>
                            <asp:TextBox ID="txtSection" ReadOnly="true" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <asp:Label ID="Label6" runat="server" Text="Line"></asp:Label>
                            <asp:TextBox ID="txtLine" ReadOnly="true" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                        </div>
                    </div>



                    <div class="grid grid-cols-2 gap-x-4 gap-y-1.5">
                        <div class="flex flex-col gap-0.5 w-full">
                            <asp:Label ID="Label7" runat="server" Text="Joining Date"></asp:Label>
                            <asp:DropDownList ID="ddlJoiningDate" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <asp:Label ID="Label8" runat="server" Text="Probation Date"></asp:Label>
                            <asp:DropDownList ID="ddlProbationDate" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <asp:Label ID="Label9" runat="server" Text="Extention Date"></asp:Label>
                            <asp:DropDownList ID="ddlExtentionDate" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <asp:Label ID="Label10" runat="server" Text="Print Date"></asp:Label>
                            <asp:DropDownList ID="ddlPrintDate" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <asp:Label ID="Label11" runat="server" Text="Operation Type"></asp:Label>
                            <asp:DropDownList ID="ddlOperationType" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                        </div>
                        <div class="flex items-end">
                            <asp:Label ID="Label12" runat="server" Text="User Name" CssClass="text-sm"></asp:Label>&nbsp
    <asp:Label ID="Label13" runat="server" Text=":"></asp:Label>&nbsp&nbsp
    <asp:Label ID="Label14" runat="server" Text="User Name" CssClass="text-sm"></asp:Label>
                        </div>
                    </div>
                </div>


                <!-- btn -->

                <div class="flex items-center gap-4 justify-start my-4">
                    <asp:Button ID="btnRefresh" runat="server" Text="Ok" CssClass="inline-block rounded bg-[#20c997] text-white px-8 py-1 shadow-sm hover:bg-[#1aa179] cursor-pointer transition delay-150 duration-300 ease-in-out" />
                    <div class="flex items-center gap-1">
                        <asp:CheckBox ID="chkIsActive" runat="server" CssClass="cursor-pointer accent-[#198754]" />
                        <asp:Label for="chkIsActive" AssociatedControlID="chkIsActive" runat="server" Text="Is Active?" CssClass="cursor-pointer"></asp:Label>
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