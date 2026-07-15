<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="FinishingOutput.aspx.cs" Inherits="Nexa_ERP.Production.Finishing.FinishingOutput" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Finishing Output</title>

    <!-- tailwind css link -->
    <script src="https://cdn.tailwindcss.com"></script>

</head>
<body>
    <form id="form1" runat="server" class="min-h-screen p-2 mt-2">
        <div class="max-w-[1320px] w-full m-auto rounded-lg border">

            <div class="bg-[#0d6efd] text-white rounded-t-lg px-4 py-2">
                <p class="text-2xl mb-1">Finishing Output</p>
                <p class="">Label</p>
            </div>

            <div class="bg-[#f0f0f0] shadow-xl rounded-b-lg px-4 py-4">
                <asp:HiddenField ID="hfUserId" runat="server" />

                <%-- main container --%>
                <div class="grid grid-cols-12 gap-x-3 gap-y-1 h-full">

                    <%-- left container total input with list view --%>
                    <div class="col-span-6 flex flex-col h-full">

                        <%-- top input --%>

                        <div class="grid grid-cols-2 gap-x-2 gap-y-1">

                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="whitespace-nowrap">Fin. Output ID</label>
                                <asp:TextBox ID="txtFinishingOutputId" runat="server" ReadOnly="true" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="whitespace-nowrap">Factory</label>
                                <asp:DropDownList ID="ddlFactory" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="whitespace-nowrap">Floor</label>
                                <asp:DropDownList ID="ddlFloor" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="whitespace-nowrap">Date</label>
                                <asp:DropDownList ID="ddlDate" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="whitespace-nowrap">Hour</label>
                                <asp:DropDownList ID="ddlHour" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="whitespace-nowrap">Line No</label>
                                <asp:TextBox ID="txtLineNo" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full col-span-2">
                                <label class="whitespace-nowrap">Remarks</label>
                                <asp:TextBox ID="txtRemarks" runat="server" TextMode="MultiLine" Rows="2" CssClass="w-full border rounded outline-none border-gray-300 px-2  focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                            </div>
                        </div>
                    </div>

                    <%-- right input --%>
                    <div class="col-span-6">
                        <div class="flex flex-col space-y-2">

                            <%-- Filter options fieldset --%>
                            <fieldset class="border border-gray-400 rounded p-2 col-span-3">
                                <legend class="italic text-sm px-2 font-medium">Filter Options</legend>

                                <div class="grid grid-cols-3 gap-x-2 gap-y-1">

                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">Buyer</label>
                                        <asp:TextBox ID="txtBuyer" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">Style No</label>
                                        <asp:TextBox ID="txtStyleNo" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">PO No</label>
                                        <asp:TextBox ID="txtPoNo" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">Color</label>
                                        <asp:DropDownList ID="ddlColor" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">Delivery Date</label>
                                        <asp:TextBox ID="txtDeliveryDate" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                    </div>
                                    <div class="flex items-end">
                                        <asp:Button ID="btnFilter" runat="server" Text="Filter" CssClass="rounded bg-[#22C55E] text-white px-4 py-0.5 shadow-sm hover:bg-[#16A34A] cursor-pointer transition delay-150 duration-300 ease-in-out" />
                                    </div>
                                </div>
                            </fieldset>


                            <%-- packed input into --%>
                            <fieldset class="border border-gray-400 rounded p-2 col-span-3">
                                <legend class="italic text-sm px-2 font-medium">Packed Input Info</legend>

                                <div class="grid grid-cols-2 gap-x-2 gap-y-1">

                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">Packed Floor</label>
                                        <asp:DropDownList ID="ddlPackedFloor" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">Packed Line</label>
                                        <asp:DropDownList ID="ddlPackedLine" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                    </div>
                                </div>
                            </fieldset>
                        </div>
                    </div>
                </div>


                <%-- list view --%>
                <div class="border border-gray-400 bg-gray-300 rounded w-full h-72 overflow-y-auto overflow-x-auto mt-2 mb-1">
                    <asp:GridView ID="GridView1" runat="server"></asp:GridView>
                </div>

                <div class="grid grid-cols-3">

                    <div class="flex flex-col gap-0.5 w-full">
                        <label>Total Output</label>
                        <asp:TextBox ID="txtTotalOutput" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
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

                        <asp:Button ID="btnShow" runat="server" Text="Show" CssClass="rounded bg-[#64748B] text-white px-4 py-1 shadow-sm hover:bg-[#475569] cursor-pointer transition delay-150 duration-300 ease-in-out" />

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