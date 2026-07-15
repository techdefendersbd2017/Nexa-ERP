<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CreatePackingList.aspx.cs" Inherits="Nexa_ERP.Production.Finishing.CreatePackingList" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Create Packing List (Floor)</title>

    <!-- tailwind css link -->
    <script src="https://cdn.tailwindcss.com"></script>

</head>
<body>
    <form id="form1" runat="server" class="min-h-screen p-2 mt-2">
        <div class="max-w-[1320px] w-full m-auto rounded-lg border">

            <div class="bg-[#0d6efd] text-white rounded-t-lg px-4 py-2">
                <p class="text-2xl mb-1">Create Packing List (Floor)</p>
                <p class="">Label</p>
            </div>

            <div class="bg-[#f0f0f0] shadow-xl rounded-b-lg px-4 py-4">
                <asp:HiddenField ID="hfUserId" runat="server" />

                <%-- main container --%>
                <div class="grid grid-cols-12 gap-x-3 gap-y-1 h-full">

                    <%-- left input --%>
                    <div class="col-span-7">
                        <div class="flex flex-col space-y-2">

                            <%-- top input --%>
                            <div class="grid grid-cols-3 gap-x-2 gap-y-1">

                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="whitespace-nowrap">Packing List ID</label>
                                    <asp:TextBox ID="txtPackingListId" runat="server" ReadOnly="true" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="whitespace-nowrap">Packing List No</label>
                                    <asp:TextBox ID="txtPackingListNo" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="whitespace-nowrap">Date</label>
                                    <asp:DropDownList ID="ddlDate" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="whitespace-nowrap">Style No</label>
                                    <asp:DropDownList ID="ddlStyleNo" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="whitespace-nowrap">Shipment Type</label>
                                    <asp:DropDownList ID="ddlShipmentTypr" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="whitespace-nowrap">Buyer</label>
                                    <asp:TextBox ID="txtBuyer" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="whitespace-nowrap">PO No</label>
                                    <asp:TextBox ID="txtPoNo" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="whitespace-nowrap">Dest PO/Lot No</label>
                                    <asp:TextBox ID="txtDestPoOrLotNo" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="whitespace-nowrap">Master Lc</label>
                                    <asp:TextBox ID="txtMasterLc" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex items-end col-span-3 justify-end">
                                    <asp:Button ID="btnAdd" runat="server" Text="Add" CssClass="rounded bg-[#22C55E] text-white px-4 py-0.5 shadow-sm hover:bg-[#16A34A] cursor-pointer transition delay-150 duration-300 ease-in-out" />
                                </div>
                            </div>


                            <%-- transfer from send --%>
                            <fieldset class="border border-gray-400 rounded p-2">
                                <legend class="text-sm italic font-medium px-2">Other Options</legend>

                                <div class="grid grid-cols-2 gap-x-2 gap-y-1">

                                    <div class="flex items-center gap-1">
                                        <asp:CheckBox ID="chkColorwiseCtnNumberReset" runat="server" CssClass="cursor-pointer accent-[#198754]" />
                                        <asp:Label for="chkColorwiseCtnNumberReset" AssociatedControlID="chkColorwiseCtnNumberReset" runat="server" Text="Colorwise Ctn Number Reset" CssClass="cursor-pointer whitespace-nowrap"></asp:Label>
                                    </div>
                                    <div class="flex items-end justify-end">
                                        <asp:Button ID="btnUpdateRate" runat="server" Text="Update Rate" CssClass="rounded bg-[#22C55E] text-white px-4 py-0.5 shadow-sm hover:bg-[#16A34A] cursor-pointer transition delay-150 duration-300 ease-in-out" />
                                    </div>
                                </div>
                            </fieldset>
                        </div>
                    </div>



                    <%-- Right container total input with list view --%>
                    <div class="col-span-5 flex flex-col h-full">

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
                                <label>PO No</label>
                                <asp:TextBox ID="txtPoNo3" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label>Pack. List No</label>
                                <asp:TextBox ID="txtPackingListNo2" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                            </div>

                            <div class="flex items-end">
                                <asp:Button ID="btnSearch2" runat="server" Text="Search" CssClass="rounded bg-[#22C55E] text-white px-4 py-0.5 shadow-sm hover:bg-[#16A34A] cursor-pointer transition delay-150 duration-300 ease-in-out" />
                            </div>
                        </div>

                        <%-- list view --%>
                        <div class="border border-gray-400 bg-gray-300 rounded w-full flex-1 h-56 overflow-y-auto overflow-x-auto mt-2">
                            <asp:ListView ID="ListView1" runat="server"></asp:ListView>
                        </div>

                    </div>
                </div>

                <%-- list view --%>
                <div class="border border-gray-400 bg-gray-300 rounded w-full h-40 overflow-y-auto overflow-x-auto mt-2 mb-1">
                    <asp:GridView ID="GridView1" runat="server"></asp:GridView>
                </div>

                <%-- list view --%>
                <div class="border border-gray-400 bg-gray-300 rounded w-full h-72 overflow-y-auto overflow-x-auto mt-2 mb-1">
                    <asp:GridView ID="GridView2" runat="server"></asp:GridView>
                </div>

                <div class="grid grid-cols-7 gap-x-2 items-end">
                    <div class="flex flex-col gap-0.5 w-full">
                        <label>Actual G.W</label>
                        <asp:TextBox ID="txtActualGW" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full">
                        <label>Actual N.W</label>
                        <asp:TextBox ID="txtActualNW" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full">
                        <label>Actual CBM</label>
                        <asp:TextBox ID="txtActualCbm" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full">
                        <label>Nor. Poly</label>
                        <asp:TextBox ID="txtNorPoly" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full">
                        <label>Re. Poly</label>
                        <asp:TextBox ID="txtRePoly" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                    </div>
                    <div class="flex items-center gap-1 col-span-2">
                        <asp:CheckBox ID="chkIsAllowAutoInsertOnOtherRows" runat="server" CssClass="cursor-pointer accent-[#198754]" />
                        <asp:Label for="chkIsAllowAutoInsertOnOtherRows" AssociatedControlID="chkIsAllowAutoInsertOnOtherRows" runat="server" Text="Is allow auto insert on other rows" CssClass="cursor-pointer whitespace-nowrap"></asp:Label>
                    </div>

                </div>


                <!--below  btn -->
                <div class="space-x-4 flex justify-between items-center mt-6">
                    <div class="flex items-center gap-3">
                        <asp:Button ID="btnRefresh" runat="server" Text="Refresh" CssClass="rounded bg-[#2BBBAD] text-white px-4 py-1 shadow-sm hover:bg-[#239A8D] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                        <div class="flex items-center gap-1">
                            <asp:CheckBox ID="chkIsActive" runat="server" CssClass="cursor-pointer accent-[#198754]" />
                            <asp:Label for="chkIsActive" AssociatedControlID="chkIsActive" runat="server" Text="Is Active?" CssClass="cursor-pointer"></asp:Label>
                        </div>
                    </div>
                    <div class="flex gap-3">

                        <div class="flex items-center gap-1 bg-yellow-400 p-1 rounded">
                            <asp:CheckBox ID="chkIsReleased" runat="server" CssClass="cursor-pointer accent-[#198754]" />
                            <asp:Label for="chkIsReleased" AssociatedControlID="chkIsReleased" runat="server" Text="Is Release? [Merchandiser can see thik packing list]" CssClass="cursor-pointer"></asp:Label>
                        </div>

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