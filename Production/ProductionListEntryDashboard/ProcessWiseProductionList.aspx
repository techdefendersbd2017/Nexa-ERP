<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ProcessWiseProductionList.aspx.cs" Inherits="Nexa_ERP.Production.ProductionListEntryDashboard.ProcessWiseProductionList" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Process Wise Production List</title>

    <!-- tailwind css link -->
    <script src="https://cdn.tailwindcss.com"></script>

    <!-- icon link -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.3.1/css/all.min.css" />

</head>
<body>
    <form id="form1" runat="server" class="min-h-screen p-2 mt-2">
        <div class="max-w-[1320px] w-full m-auto rounded-lg border">

            <div class="bg-[#255C8C] flex justify-center items-center rounded-t-lg px-4 py-2">
                <p class="text-white text-xl font-medium">Process Wise Production List</p>
            </div>

            <div class="bg-[#ffffff] shadow-xl rounded-b-lg p-4">
                <asp:HiddenField ID="hfUserId" runat="server" />
                <asp:HiddenField ID="hfTargetId" runat="server" />

                <%-- main entry fields box --%>
                <div class="bg-[#FBFCFE] p-2 rounded border border-gray-400">
                    <div class="grid grid-cols-6 gap-x-2 gap-y-1">
                        <!--1st Row-->
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">Company</label>
                            <asp:TextBox ID="txtCompany" placeholder="Company" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">Prod. Type</label>
                            <asp:TextBox ID="txtSection" placeholder="Prod. Type" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">Section</label>
                            <asp:TextBox ID="txtFloor" placeholder="Section" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">Floor</label>
                            <asp:TextBox ID="txtTargetDate" placeholder="Floor" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">MC/Line</label>
                            <asp:TextBox ID="txtTargetHour" placeholder="MC/Line" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">WO Ref. No</label>
                            <asp:TextBox ID="txtTargetEff" placeholder="WO Ref. No" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                        </div>
                        <!--2st Row-->
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">Item</label>
                            <asp:TextBox ID="TextBox1" placeholder="Item" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">WO No</label>
                            <asp:TextBox ID="TextBox2" placeholder="WO No" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">Process</label>
                            <asp:TextBox ID="TextBox3" placeholder="Process" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">Status</label>
                            <asp:TextBox ID="TextBox4" placeholder="Status" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">From</label>
                            <asp:TextBox ID="TextBox5" placeholder="From" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                        </div>
                        <div class="flex flex-col gap-0.5 w-full">
                            <label class="text-sm font-medium">To</label>
                            <asp:TextBox ID="TextBox6" placeholder="To" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                        </div>
                    </div>
                    <%-- add button --%>
                    <div class="flex justify-end mt-3">
                        <asp:LinkButton ID="btnSearch" runat="server" CssClass="flex items-center gap-1.5 rounded bg-[#2EB85C] text-white px-4 py-1 shadow-sm hover:bg-[#1E7E34] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center h-[34px] whitespace-nowrap"> Search </asp:LinkButton>
                    </div>
                </div>

                <%-- Bottom Gridview  --%>
                <div class="border border-gray-400 bg-gray-100 rounded w-full h-80 flex-1 overflow-y-auto overflow-x-auto mt-3">
                    <asp:GridView ID="GridView2" runat="server"></asp:GridView>
                </div>

            </div>
        </div>
    </form>
</body>
</html>

