<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SizeGradingOrPOtoPOTransfer.aspx.cs" Inherits="Nexa_ERP.Production.Cutting.SizeGradingOrPOtoPOTransfer" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>PO To PO Transfer</title>

    <!-- tailwind css link -->
    <script src="https://cdn.tailwindcss.com"></script>

</head>
<body>
    <form id="form1" runat="server" class="min-h-screen p-2 mt-2">
        <div class="max-w-[1320px] w-full m-auto rounded-lg border">

            <div class="bg-[#0d6efd] text-white rounded-t-lg px-4 py-2">
                <p class="text-2xl mb-1">PO To PO Transfer</p>
                <p class="">Label</p>
            </div>

            <div class="bg-[#f0f0f0] shadow-xl rounded-b-lg px-4 py-4">
                <asp:HiddenField ID="hfUserId" runat="server" />

                <%-- main container --%>
                <div class="grid grid-cols-12 gap-x-3 gap-y-1 h-full">

                    <%-- left input --%>
                    <div class="col-span-6">
                        <div class="flex flex-col space-y-2">

                            <%-- top input --%>
                            <div class="grid grid-cols-3 gap-x-2 gap-y-1">

                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="whitespace-nowrap">PO Transfer ID</label>
                                    <asp:TextBox ID="txtPoTransferId" runat="server" ReadOnly="true" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="whitespace-nowrap">Transfer No</label>
                                    <asp:TextBox ID="txtTransferNo" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="whitespace-nowrap">Section</label>
                                    <asp:TextBox ID="txtSection" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="whitespace-nowrap">Date</label>
                                    <asp:DropDownList ID="ddlDate" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="whitespace-nowrap">Cutting Floor</label>
                                    <asp:DropDownList ID="ddlCuttingFloor" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="whitespace-nowrap">Line</label>
                                    <asp:DropDownList ID="ddlLine" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                            </div>


                            <%-- transfer from send --%>
                            <fieldset class="border border-gray-400 rounded p-2">
                                <legend class="text-sm italic font-medium px-2">Transfer From (Send)</legend>

                                <div class="grid grid-cols-3 gap-x-2 gap-y-1">

                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">Buyer</label>
                                        <asp:TextBox ID="txtBuyer" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">Style</label>
                                        <asp:TextBox ID="txtStyle" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">Cutting No</label>
                                        <asp:TextBox ID="txtCuttingNo" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                    </div>
                                </div>
                            </fieldset>


                            <%-- transfer to receive --%>
                            <fieldset class="border border-gray-400 rounded p-2">
                                <legend class="text-sm italic font-medium px-2">Transfer To (Receive)</legend>

                                <div class="grid grid-cols-3 gap-x-2 gap-y-1">

                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">Buyer</label>
                                        <asp:TextBox ID="txtBuyer2" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">Style</label>
                                        <asp:TextBox ID="txtStyle2" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">PO</label>
                                        <asp:TextBox ID="txtPo" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">Delivery Date</label>
                                        <asp:DropDownList ID="ddlDeliveryDate" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">Production Month</label>
                                        <asp:DropDownList ID="ddlProductionMonth" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                    </div>
                                    <div class="flex items-end">
                                        <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="rounded bg-[#22C55E] text-white px-4 py-0.5 shadow-sm hover:bg-[#16A34A] cursor-pointer transition delay-150 duration-300 ease-in-out" />
                                    </div>
                                </div>
                            </fieldset>

                        </div>
                    </div>



                    <%-- total input with list view --%>
                    <div class="col-span-6 flex flex-col h-full">

                        <%-- top input --%>

                        <div class="grid grid-cols-3 gap-x-2 gap-y-1">
                            <div class="flex gap-0.5 items-end col-span-2">
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="whitespace-nowrap">Date</label>
                                    <asp:DropDownList ID="ddlDate2" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <asp:DropDownList ID="ddlInputDate2" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label>Buyer</label>
                                <asp:TextBox ID="txtBuyer3" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label>PO</label>
                                <asp:TextBox ID="txtPo3" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label>Style</label>
                                <asp:TextBox ID="txtStyle3" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="whitespace-nowrap">Transfer No.</label>
                                <asp:DropDownList ID="ddlTransferNo" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                            </div>
                            <div class="flex gap-x-1 items-end col-span-2">
                                <div class="flex items-end">
                                    <asp:Button ID="btnTrSendSearch" runat="server" Text="Tr. Send Search" CssClass="rounded bg-[#22C55E] text-white px-4 py-0.5 shadow-sm hover:bg-[#16A34A] cursor-pointer transition delay-150 duration-300 ease-in-out" />
                                </div>
                                <div class="flex items-end">
                                    <asp:Button ID="btnTrRcvSearch" runat="server" Text="Tr. Rcv Search" CssClass="rounded bg-[#22C55E] text-white px-4 py-0.5 shadow-sm hover:bg-[#16A34A] cursor-pointer transition delay-150 duration-300 ease-in-out" />
                                </div>
                            </div>

                        </div>

                        <%-- list view --%>
                        <div class="border border-gray-400 bg-gray-300 rounded w-full flex-1 h-56 overflow-y-auto overflow-x-auto mt-2 mb-1">
                            <asp:ListView ID="ListView1" runat="server"></asp:ListView>
                        </div>

                    </div>
                </div>

                <%-- list view --%>
                <div class="border border-gray-400 bg-gray-300 rounded w-full h-72 overflow-y-auto overflow-x-auto mt-2 mb-1">
                    <asp:GridView ID="GridView1" runat="server"></asp:GridView>
                </div>


                <!--below  btn -->
                <div class="space-x-4 flex justify-between items-center mt-3">
                    <div class="flex items-center gap-3">
                        <asp:Button ID="btnRefresh" runat="server" Text="Refresh" CssClass="rounded bg-[#2BBBAD] text-white px-4 py-1 shadow-sm hover:bg-[#239A8D] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                        <div class="flex items-center gap-1">
                            <asp:CheckBox ID="chkIsActive" runat="server" CssClass="cursor-pointer accent-[#198754]" />
                            <asp:Label for="chkIsActive" AssociatedControlID="chkIsActive" runat="server" Text="Is Active?" CssClass="cursor-pointer"></asp:Label>
                        </div>
                    </div>
                    <div class="flex gap-3">

                        <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="rounded bg-[#22C55E] text-white px-4 py-1 shadow-sm hover:bg-[#16A34A] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                        <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="rounded bg-[#E55353] text-white px-4 py-1 shadow-sm hover:bg-[#475569] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                        <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="rounded bg-[#64748B] text-white px-4 py-1 shadow-sm hover:bg-[#475569] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                        <asp:Button ID="btnClose" runat="server" Text="Close" CssClass="rounded bg-[#E55353] text-white px-4 py-1 shadow-sm hover:bg-[#475569] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>











