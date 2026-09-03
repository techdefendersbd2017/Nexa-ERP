<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="cuttingLimitSet.aspx.cs" Inherits="Nexa_ERP.MerchandisingMarketing.BuyerPurchaseOrder.cuttingLimitSet" %>


<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Cutting Limit Set</title>
    <!-- tailwind css link -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- icon link -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.3.1/css/all.min.css" />


</head>
<body>
    <form id="form1" runat="server" class="min-h-screen p-2 mt-2">


        <%-- ========================= Cutting limit set open ============================ --%>

        <div class="max-w-[1320px] w-full m-auto rounded-lg border" id="Color">

            <div class="bg-[#255C8C] flex justify-between items-center rounded-t-lg px-4 py-2">
                <div class="text-white">
                    <p class="text-xl mb-1 font-medium">Cutting Limit Set</p>

                </div>

            </div>

            <div class="bg-[#ffffff] shadow-xl rounded-b-lg p-4">
                <asp:HiddenField ID="hfUserId" runat="server" />

                <%-- main container --%>
                <div class=" w-full grid grid-cols-12 space-x-3">

                    <%-- left container --%>
                    <fieldset class="col-span-12 border border-gray-400 rounded p-2 bg-[#FBFCFE]">
                        <legend class="text-sm font-medium px-2 text-[#255C8C] italic">Filters</legend>

                        <div class="grid grid-cols-4 gap-3 w-full">

                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Company</label>
                                <asp:DropDownList ID="ddlCompany" placeholder="e.g " runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                    <asp:ListItem Value="" Selected="True">--Select Company--</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Buyer</label>
                                <asp:DropDownList ID="ddlBuyer" placeholder="e.g " runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                    <asp:ListItem Value="" Selected="True">--Select Buyer--</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">Style</label>
                                <asp:DropDownList ID="ddlStyle" placeholder="e.g " runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                    <asp:ListItem Value="" Selected="True">--Select Style--</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="text-sm font-medium">PO</label>
                                <asp:DropDownList ID="ddlPo" placeholder="e.g " runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 py-1 focus:border-[#255C8C] shadow-sm transition duration-200 ease-in-out">
                                    <asp:ListItem Value="" Selected="True">--Select PO--</asp:ListItem>
                                </asp:DropDownList>
                            </div>

                            <!-- clear Button -->
                            <div class="flex w-full items-end justify-end col-span-4">
                                <asp:LinkButton ID="btnCancel" runat="server" CssClass="flex items-center gap-1.5 rounded bg-[#DC2626] text-white px-4 py-1.5 shadow-sm hover:bg-[#B91C1C] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                                        <i class="fa-regular fa-calendar-minus"></i>
                                        <span>Clear</span>
                                </asp:LinkButton>
                            </div>
                        </div>
                    </fieldset>
                </div>



                <%-- List view --%>
                <div class="mt-6">
                    <div class="border border-gray-400 bg-gray-300 rounded w-full h-72 overflow-y-auto overflow-x-auto">
                        <asp:ListView ID="ListView3" runat="server"></asp:ListView>
                    </div>


                </div>
            </div>
        </div>
    </form>
</body>
</html>



