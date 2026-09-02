<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ProductionDashboard.aspx.cs" Inherits="Nexa_ERP.Production.ProductionListEntryDashboard.ProductionDashboard" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Production Dashboard</title>

    <!-- tailwind css link -->
    <script src="https://cdn.tailwindcss.com"></script>

    <!-- icon link -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.3.1/css/all.min.css" />
</head>
<body>
    <form id="form1" runat="server" class="min-h-screen p-2 mt-2">
        <div class="max-w-[1320px] w-full m-auto rounded-lg border">

            <div class="bg-[#255C8C] flex justify-center items-center rounded-t-lg px-4 py-2">
                <p class="text-white text-xl font-medium">Production Dashboard</p>
            </div>

            <div class="bg-[#ffffff] shadow-xl rounded-b-lg p-4">
                <asp:HiddenField ID="hfUserId" runat="server" />
                <asp:HiddenField ID="hfTargetId" runat="server" />

                <%-- top filter --%>
                <div class="flex items-end gap-3 mb-4">
                    <div class="flex flex-col gap-0.5 w-40">
                        <label class="text-sm font-medium">Date</label>
                        <asp:TextBox ID="txtDate" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out"></asp:TextBox>
                    </div>
                    <div class="flex flex-col gap-0.5 w-64">
                        <label class="text-sm font-medium">Company</label>
                        <asp:TextBox ID="txtCompanyName" runat="server" ReadOnly="true" CssClass="w-full border rounded outline-none border-gray-300 bg-gray-100 px-2 py-1 shadow-sm"></asp:TextBox>
                    </div>
                    <asp:LinkButton ID="btnLoad" runat="server" CssClass="flex items-center gap-1.5 rounded bg-[#255C8C] text-white px-6 py-1.5 shadow-sm hover:bg-[#1a4569] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                        <span>Load</span>
                    </asp:LinkButton>
                </div>

                <%-- dashboard cards --%>
                <div class="grid grid-cols-2 gap-4">

                    <%-- Offset Print card --%>
                    <div class="bg-[#0F2A5E] rounded-lg border border-[#3C5A8C] overflow-hidden">
                        <div class="bg-[#6E97C9] text-center py-1.5">
                            <p class="text-white font-semibold tracking-wide">OFFSET PRINT</p>
                        </div>
                        <%--  Gridview  --%>
                        <div class="border border-gray-400 bg-gray-100 rounded w-full h-80 flex-1 overflow-y-auto overflow-x-auto mt-3">
                            <asp:GridView ID="GridView1" runat="server"></asp:GridView>
                        </div>
                    </div>

                    <%-- Label card --%>
                    <div class="bg-[#0F2A5E] rounded-lg border border-[#3C5A8C] overflow-hidden">
                        <div class="bg-[#6E97C9] text-center py-1.5">
                            <p class="text-white font-semibold tracking-wide">LABEL</p>
                        </div>
                        <%--  Gridview  --%>
                        <div class="border border-gray-400 bg-gray-100 rounded w-full h-80 flex-1 overflow-y-auto overflow-x-auto mt-3">
                            <asp:GridView ID="GridView2" runat="server"></asp:GridView>
                        </div>
                    </div>

                </div>

            </div>
        </div>
    </form>
</body>
</html>
