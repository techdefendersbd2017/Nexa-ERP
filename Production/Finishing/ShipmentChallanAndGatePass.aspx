<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ShipmentChallanAndGatePass.aspx.cs" Inherits="Nexa_ERP.Production.Finishing.ShipmentChallanAndGatePass" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Shipment Challan & Gate Pass</title>

    <!-- tailwind css link -->
    <script src="https://cdn.tailwindcss.com"></script>

</head>
<body>
    <form id="form1" runat="server" class="min-h-screen p-2 mt-2">
        <div class="max-w-[1320px] w-full m-auto rounded-lg border">

            <div class="bg-[#0d6efd] text-white rounded-t-lg px-4 py-2">
                <p class="text-2xl mb-1">Shipment Challan & Gate Pass</p>
                <p class="">Label</p>
            </div>

            <div class="bg-[#f0f0f0] shadow-xl rounded-b-lg px-4 py-4">
                <asp:HiddenField ID="hfUserId" runat="server" />

                <%-- main container --%>
                <div class="grid grid-cols-12 gap-x-3 gap-y-1 h-full">

                    <%-- left input --%>
                    <div class="col-span-12">
                        <div class="flex flex-col space-y-2">

                            <div class="grid grid-cols-6 gap-x-2 gap-y-1">
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="whitespace-nowrap">Ship. Challan Id</label>
                                    <asp:TextBox ID="txtShipmentChallanId" runat="server" ReadOnly="true" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="whitespace-nowrap">Buyer</label>
                                    <asp:TextBox ID="TextBox2" runat="server" ReadOnly="true" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="whitespace-nowrap">PO No</label>
                                    <asp:TextBox ID="TextBox3" runat="server" ReadOnly="true" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="whitespace-nowrap">Packing List No</label>
                                    <asp:TextBox ID="TextBox4" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex items-end gap-2">
                                    <fieldset class="border border-gray-400 rounded px-2 py-1">
                                        <legend class="italic text-sm font-medium px-2">Pack. List Shipment</legend>

                                        <div class="flex gap-3">
                                            <label class="flex gap-1 items-center cursor-pointer">
                                                <input type="radio" name="group" class="cursor-pointer" />
                                                <span>Done</span>
                                            </label>

                                            <!-- Not Done -->
                                            <label class="flex gap-1 items-center cursor-pointer">
                                                <input type="radio" name="group" class="cursor-pointer" />
                                                <span class="whitespace-nowrap">Not Done</span>
                                            </label>

                                        </div>
                                    </fieldset>
                                    <asp:Button ID="btnPackingList" runat="server" Text="Packing List" CssClass="rounded bg-[#22C55E] text-white px-4 py-0.5 shadow-sm hover:bg-[#16A34A] cursor-pointer transition delay-150 duration-300 ease-in-out" />
                                </div>


                            </div>
                        </div>
                    </div>
                </div>



                <%-- list view --%>
                <div class="border border-gray-400 bg-gray-300 rounded w-full  h-40 overflow-y-auto overflow-x-auto mt-2 mb-1">
                    <asp:ListView ID="ListView1" runat="server"></asp:ListView>
                </div>

                <%-- Grid view --%>
                <div class="border border-gray-400 bg-gray-300 rounded w-full h-40 overflow-y-auto overflow-x-auto mt-2 mb-1">
                    <asp:GridView ID="GridView1" runat="server"></asp:GridView>
                </div>



                <%-- master info --%>
                <div class="grid grid-cols-12 gap-x-3 gap-y-1 h-full">

                    <%-- left input --%>
                    <div class="col-span-7">
                        <div class="flex flex-col space-y-2">

                            <fieldset class="border border-gray-400 rounded p-2">
                                <legend class="italic font-medium text-sm px-2">Master Info</legend>
                                <%-- top input --%>
                                <div class="grid grid-cols-3 gap-x-2 gap-y-1">

                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">Challan Date</label>
                                        <asp:DropDownList ID="ddlChallanDate" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">Challan No</label>
                                        <asp:TextBox ID="txtChallanNo" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">Gate Pass</label>
                                        <asp:TextBox ID="txtGatePass" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">Escort No</label>
                                        <asp:TextBox ID="txtEscortNo" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">CNF Agent</label>
                                        <asp:DropDownList ID="ddlCnfAgent" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">CNF Mobile No</label>
                                        <asp:TextBox ID="txtCnfMobileNo" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">CNF Contact Person</label>
                                        <asp:TextBox ID="txtCnfContactPerson" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">Driver Name</label>
                                        <asp:TextBox ID="txtDriverName" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">Driver Mobile</label>
                                        <asp:TextBox ID="txtDriverMobile" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">Truck No.</label>
                                        <asp:TextBox ID="txtTruckNo" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">Driver Licence</label>
                                        <asp:TextBox ID="txtDriverLicence" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">Lock No</label>
                                        <asp:TextBox ID="txtLockNo" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">CBM</label>
                                        <asp:TextBox ID="txtCbm" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">DEPO</label>
                                        <asp:DropDownList ID="ddlDepo" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">Description Of Goods</label>
                                        <asp:TextBox ID="txtDescriptionOfGoods" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full col-span-2">
                                        <label class="whitespace-nowrap">Unit</label>
                                        <asp:DropDownList ID="ddlUnit" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">Com. Factory</label>
                                        <asp:TextBox ID="txtComFactory" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full col-span-3">
                                        <label class="whitespace-nowrap">Remarks</label>
                                        <asp:TextBox ID="txtRemarks" runat="server" TextMode="MultiLine" Rows="2" CssClass="w-full border rounded outline-none border-gray-300 px-2 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                    </div>
                                </div>
                            </fieldset>

                        </div>
                    </div>

                    <div class="col-span-5 h-full flex flex-col">

                        <div class="grid grid-cols-0">
                            <div class="flex items-end gap-0.5">
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="whitespace-nowrap">Date</label>
                                    <asp:DropDownList ID="ddlDate" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <label class="whitespace-nowrap">-</label>
                                <asp:DropDownList ID="ddlDate2" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="rounded bg-[#22C55E] text-white px-4 py-0.5 shadow-sm hover:bg-[#16A34A] cursor-pointer transition delay-150 duration-300 ease-in-out" />
                            </div>

                        </div>
                        <%-- list view --%>
                        <div class="border border-gray-400 bg-gray-300 rounded w-full flex-1 overflow-y-auto overflow-x-auto mt-2">
                            <asp:ListView ID="ListView2" runat="server"></asp:ListView>
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