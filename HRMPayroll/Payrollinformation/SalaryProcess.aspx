<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SalaryProcess.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.Payrollinformation.SalaryProcess" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Process Salary</title>

    <!-- tailwind css link -->
    <script src="https://cdn.tailwindcss.com"></script>

</head>
<body>
    <form id="form1" runat="server" class="min-h-screen p-2 mt-2">
        <div class="max-w-[1320px] w-full m-auto rounded-lg border">

            <div class="bg-[#0d6efd] text-white rounded-t-lg px-4 py-2">
                <p class="text-2xl mb-1">Process Salary</p>
                <p class="">Label</p>
            </div>

            <div class="bg-[#f0f0f0] shadow-xl rounded-b-lg px-4 py-4">
                <asp:HiddenField ID="hfUserId" runat="server" />

                <div class="grid grid-cols-3 gap-x-4 gap-y-1.5">

                        <div class="flex flex-col gap-0.5 w-full">
                            <label>Salary Process ID</label>
                            <asp:TextBox ID="txtSalaryProcessId" runat="server" ReadOnly="true" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                        </div>

                    <div class="flex flex-col gap-0.5 w-full">
                        <label>Category</label>
                        <asp:TextBox ID="txtCategory" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                    </div>
                    <div class="flex gap-4 items-end">
                        <div class="flex flex-col gap-0.5 w-full">
                            <label>Employee Status</label>
                            <asp:DropDownList ID="ddlEmployeeStatus" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                        </div>
                        <%-- checkbox 3 --%>
                        <div class="flex gap-6 w-full items-end">
                            <div class="flex items-center gap-1">
                                <asp:CheckBox ID="chkSelectAll" runat="server" CssClass="cursor-pointer accent-[#198754]" />
                                <asp:Label for="chkSelectAll" AssociatedControlID="chkSelectAll" runat="server" Text="Select All" CssClass="cursor-pointer"></asp:Label>
                            </div>
                            <div class="flex items-center gap-1">
                                <asp:CheckBox ID="chkDeselect" runat="server" CssClass="cursor-pointer accent-[#198754]" />
                                <asp:Label for="chkDeselect" AssociatedControlID="chkDeselect" runat="server" Text="De-Select" CssClass="cursor-pointer"></asp:Label>
                            </div>
                        </div>
                    </div>


                    <div class="flex flex-col gap-0.5 w-full">
                        <label>Department</label>
                        <asp:TextBox ID="txtDepartment" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full">
                        <label>Section</label>
                        <asp:TextBox ID="txtSection" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full">
                        <label>Sub Section</label>
                        <asp:TextBox ID="txtSubSection" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full">
                        <label>Designation</label>
                        <asp:TextBox ID="txtDesignation" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full">
                        <label>From</label>
                        <asp:DropDownList ID="ddlFrom" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full">
                        <label>Till</label>
                        <asp:DropDownList ID="ddlTill" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
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
                        <asp:Button ID="btnShow" runat="server" Text="Show" CssClass="rounded bg-[#22c55e] text-white px-4 py-1 shadow-sm hover:bg-[#16a34a] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                        <asp:Button ID="btnAll" runat="server" Text="All" CssClass="rounded bg-[#5B6EE1] text-white px-4 py-1 shadow-sm hover:bg-[#4758C8] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                        <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="rounded bg-[#8A8F98] text-white px-4 py-1 shadow-sm hover:bg-[#6F747C] cursor-pointer transition delay-150 duration-300 ease-in-out" />
                    </div>
                </div>

                <div>
                    <fieldset class="border border-gray-400 rounded shadow-sm p-2 mb-4">
                        <legend class="px-2 text-sm font-medium italic">Process</legend>

                        <div class="grid grid-cols-2 space-y-2 ">
                            <%-- checkbox 3 --%>
                            <div class="flex gap-6 w-full items-end col-span-2.5 mx-3">
                                <div class="flex items-center gap-1">
                                    <asp:CheckBox ID="chkTiffingNight" runat="server" CssClass="cursor-pointer accent-[#198754]" />
                                    <asp:Label for="chkTiffingNight" AssociatedControlID="chkTiffingNight" runat="server" Text="Tiffin & Night" CssClass="cursor-pointer"></asp:Label>
                                </div>
                                <div class="flex items-center gap-1">
                                    <asp:CheckBox ID="chkHoliday" runat="server" CssClass="cursor-pointer accent-[#198754]" />
                                    <asp:Label for="chkHoliday" AssociatedControlID="chkHoliday" runat="server" Text="Holiday" CssClass="cursor-pointer"></asp:Label>
                                </div>
                                <div class="flex items-center gap-1">
                                    <asp:CheckBox ID="chkFullCash" runat="server" CssClass="cursor-pointer accent-[#198754]" />
                                    <asp:Label for="chkFullCash" AssociatedControlID="chkFullCash" runat="server" Text="Full Cash" CssClass="cursor-pointer"></asp:Label>
                                </div>
                            </div>
                         
                            <div class="flex justify-around gap-3 col-span-2">
                                <asp:Button ID="btnSalaryProcess" runat="server" Text="Salary Process" CssClass="border border-gray-500 px-4 py-0.5 rounded hover:bg-[#e4e4e4] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                                <asp:Button ID="btnAdvanceProcess" runat="server" Text="Advance Process" CssClass="border border-gray-500 px-4 py-0.5 rounded hover:bg-[#e4e4e4] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                                <asp:Button ID="btnFinalSettlement" runat="server" Text="Final Settlement" CssClass="border border-gray-500 px-4 py-0.5 rounded hover:bg-[#e4e4e4] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                                <asp:Button ID="btnTdsProcess" runat="server" Text="TDS Process" CssClass="border border-gray-500 px-4 py-0.5 rounded hover:bg-[#e4e4e4] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                                <asp:Button ID="btnFestivalBillProcess" runat="server" Text="Festival Bill Process" CssClass="border border-gray-500 px-4 py-0.5 rounded hover:bg-[#e4e4e4] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                                <asp:Button ID="btnExtraOtHoliday" runat="server" Text="Extra OT Holiday" CssClass="border border-gray-500 px-4 py-0.5 rounded hover:bg-[#e4e4e4] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                                <asp:Button ID="btnSalaryProcess2" runat="server" Text="Salary Process 2" CssClass="border border-gray-500 px-4 py-0.5 rounded hover:bg-[#e4e4e4] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                            </div>
                        </div>
                    </fieldset>
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
