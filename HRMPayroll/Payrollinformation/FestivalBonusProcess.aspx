<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="FestivalBonusProcess.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.Payrollinformation.FestivalBonusProcess" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Festival Bonus Process</title>

    <!-- tailwind css link -->
    <script src="https://cdn.tailwindcss.com"></script>

</head>
<body>
    <form id="form1" runat="server" class="min-h-screen p-2 mt-2">
        <div class="max-w-[1320px] w-full m-auto rounded-lg border">

            <div class="bg-[#0d6efd] text-white rounded-t-lg px-4 py-2">
                <p class="text-2xl mb-1">Festival Bonus Process</p>
                <p class="">Label</p>
            </div>



            <div class="bg-[#f0f0f0] shadow-xl rounded-b-lg px-4 py-4">
                <asp:HiddenField ID="hfUserId" runat="server" />

                <div class="grid grid-cols-2 gap-x-4 gap-y-1.5">
                    <div class="space-y-4 flex flex-col flex-grow">
                        <div class="grid grid-cols-2 gap-x-4 gap-y-1.5">

                            <div class="flex flex-col gap-0.5 w-full">
                                <label>Process ID</label>
                                <asp:TextBox ID="txtProcessId" runat="server" ReadOnly="true" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label>Process Code</label>
                                <asp:TextBox ID="txtProcessCode" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label>Payment Date</label>
                                <asp:DropDownList ID="ddlPaymentDate" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label>Status</label>
                                <asp:DropDownList ID="ddlStatus" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full col-span-2">
                                <label>Festival Type</label>
                                <asp:TextBox ID="txtFestivalType" runat="server" Rows="2" TextMode="MultiLine" CssClass="w-full border rounded outline-none border-gray-300 px-2  focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out overflow-y-auto"></asp:TextBox>
                            </div>
                            
                        </div>
                        <!-- btn -->
                        <div class="space-x-28 flex justify-between items-center my-4">
                            <div class="flex items-center gap-3 whitespace-nowrap">
                                <asp:Button ID="btnRefresh" runat="server" Text="Refresh" CssClass="rounded bg-[#2BBBAD] text-white px-4 py-1 shadow-sm hover:bg-[#239A8D] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                                <div class="flex items-center gap-1">
                                    <asp:CheckBox ID="chkIsActive" runat="server" CssClass="cursor-pointer accent-[#198754]" />
                                    <asp:Label for="chkIsActive" AssociatedControlID="chkIsActive" runat="server" Text="Is Active?" CssClass="cursor-pointer"></asp:Label>
                                </div>
                            </div>
                            <div class="flex gap-3 flex-wrap">
                                <asp:Button ID="btnAdd" runat="server" Text="Add" CssClass="rounded bg-[#22c55e] text-white px-4 py-1 shadow-sm hover:bg-[#16a34a] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                                <asp:Button ID="btnUpdate" runat="server" Text="Update" CssClass="rounded bg-[#3B82F6] text-white px-4 py-1 shadow-sm hover:bg-[#2563EB] cursor-pointer transition delay-150 duration-300 ease-in-out" />


                                <asp:Button ID="btnProcess" runat="server" Text="Process" CssClass="rounded bg-[#F59E0B] text-white px-4 py-1 shadow-sm hover:bg-[#D97706] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                                <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="rounded bg-[#EF4444] text-white px-4 py-1 shadow-sm hover:bg-[#DC2626] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                                <asp:Button ID="btnAddPaymentDate" runat="server" Text="Add/Update Payment Date" CssClass="rounded bg-[#10B981] text-white px-4 py-1 shadow-sm hover:bg-[#059669] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                            </div>
                        </div>

                        <!-- text grid 1st -->

                        <%-- jodi grid lage -----deducting or earning page e ache --%>
                    </div>


                    <!-- text grid 2st -->
                    <div>
                        <div class="border border-gray-400 bg-gray-50 rounded w-full h-full overflow-y-auto">
                            <asp:GridView ID="GridView2" runat="server"></asp:GridView>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </form>
</body>
</html>

