<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="shortShipmentReasonStatusReport.aspx.cs" Inherits="Nexa_ERP.Production.Finishing.shortShipmentReasonStatusReport" %>



<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Short Shipment Reason Status Report</title>

    <!-- tailwind css link -->
    <script src="https://cdn.tailwindcss.com"></script>


</head>
<body>
    <form id="form1" runat="server" class="min-h-screen p-2 mt-2">
        <div class="max-w-[1320px] w-full m-auto rounded-lg border">

            <div class="bg-[#0d6efd] text-white rounded-t-lg px-4 py-2">
                <p class="text-2xl mb-1">Short Shipment Reason Status Report</p>
                <p class="">Label</p>
            </div>

            <div class="bg-[#f0f0f0] shadow-xl rounded-b-lg px-4 py-4">
                <asp:HiddenField ID="hfUserId" runat="server" />

                <%-- main container --%>
                <div class="grid grid-cols-12 gap-x-3 gap-y-1 h-full">

                    <%-- left input --%>
                    <div class="col-span-12">
                        <div class="flex flex-col space-y-2">

                            <%-- top input --%>
                            <div class="grid grid-cols-5 gap-x-2 gap-y-1">

                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="whitespace-nowrap">Short Ship. Report Id</label>
                                    <asp:TextBox ID="txtShortShipmentId" runat="server" ReadOnly="true" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="whitespace-nowrap">From</label>
                                    <asp:DropDownList ID="ddlDate" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="whitespace-nowrap">To</label>
                                    <asp:DropDownList ID="ddlTo" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="whitespace-nowrap">Buyer</label>
                                    <asp:TextBox ID="txtBuyer" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="whitespace-nowrap">Style</label>
                                    <asp:TextBox ID="txtStyle" runat="server"  CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full col-span-2">
                                    <label class="whitespace-nowrap">PO</label>
                                    <asp:TextBox ID="txtPo" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-2">
                                    <fieldset class="border border-gray-400 rounded p-2">
                                        <legend class="italic font-medium text-sm px-2">PO</legend>
                                        <div class="border border-gray-400 bg-gray-300 rounded w-full h-32 overflow-y-auto overflow-x-auto mt-2 mb-1">
                                            <asp:ListView ID="ListView1" runat="server"></asp:ListView>
                                        </div>
                                    </fieldset>
                                    <div class="flex items-end">
                                        <asp:Button ID="btnClear1" runat="server" Text="Clear" CssClass="rounded bg-[#64748B] text-white px-4 py-0.5 shadow-sm hover:bg-[#475569] cursor-pointer transition delay-150 duration-300 ease-in-out" />   
                                    </div>
                                </div>
                                <div class="flex items-end">
                                    <asp:Button ID="btnAdd" runat="server" Text="Add" CssClass="rounded bg-[#64748B] text-white px-4 py-0.5 shadow-sm hover:bg-[#475569] cursor-pointer transition delay-150 duration-300 ease-in-out" />   
                                </div>
                                <div class="flex items-end">
                                     <asp:Button ID="btnShow" runat="server" Text="Show" CssClass="rounded bg-[#64748B] text-white px-4 py-1 shadow-sm hover:bg-[#475569] cursor-pointer transition delay-150 duration-300 ease-in-out" />
                                </div>
                                
                            </div>
                        </div>
                    </div>             
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

                        <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="rounded bg-[#64748B] text-white px-4 py-1 shadow-sm hover:bg-[#475569] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                        <asp:Button ID="btnClose" runat="server" Text="Close" CssClass="rounded bg-[#E55353] text-white px-4 py-1 shadow-sm hover:bg-[#475569] cursor-pointer transition delay-150 duration-300 ease-in-out" Width="98px" />

                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>