<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="cuttingContrastFabricsEntry.aspx.cs" Inherits="Nexa_ERP.Production.Cutting.cuttingContrastFabricsEntry" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Cutting Contrast Fabrics Entry</title>

    <!-- tailwind css link -->
    <script src="https://cdn.tailwindcss.com"></script>

</head>
<body>
    <form id="form1" runat="server" class="min-h-screen p-2 mt-2">
        <div class="max-w-[1320px] w-full m-auto rounded-lg border">

            <div class="bg-[#0d6efd] text-white rounded-t-lg px-4 py-2">
                <p class="text-2xl mb-1">Cutting Contrast Fabrics Entry</p>
                <p class="">Label</p>
            </div>

            <div class="bg-[#f0f0f0] shadow-xl rounded-b-lg px-4 py-4">
                <asp:HiddenField ID="hfUserId" runat="server" />

                <%-- main container --%>
                <div class="grid grid-cols-12 gap-x-3 gap-y-1">

                    <div class="flex flex-col gap-0.5 w-full col-span-6">
                        <label class="whitespace-nowrap">Cutting Fabric Entry ID</label>
                        <asp:TextBox ID="txtCuttingEntryId" runat="server" ReadOnly="true" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                    </div>

                </div>

                <div class="grid grid-cols-12 space-x-3 mt-3">

                    <%-- Master info --%>
                    <div class="col-span-6">
                        <fieldset class="border border-gray-400 rounded w-full p-2">
                            <legend class="italic text-sm px-2 font-medium">Master Info</legend>

                            <div class="grid grid-cols-3 gap-x-2 gap-y-1 w-full">
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="whitespace-nowrap">Cutting</label>
                                    <asp:DropDownList ID="ddlCutting" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Cutting No</label>
                                    <asp:TextBox ID="txtCuttingNo" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Line</label>
                                    <asp:DropDownList ID="ddlLine" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex gap-x-0.5 items-end">
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">Marker Length</label>
                                        <asp:TextBox ID="txtMarkerLength" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                    </div>
                                    <asp:DropDownList ID="ddlMarkerLength" runat="server" CssClass="w-32 border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Buyer</label>
                                    <asp:TextBox ID="txtBuyer" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex gap-x-0.5 items-end">
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">Marker Width</label>
                                        <asp:TextBox ID="txtMarkerWidth" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                    </div>
                                    <asp:DropDownList ID="ddlMarkerWidth" runat="server" CssClass="w-32 border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Style</label>
                                    <asp:TextBox ID="txtStyle" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex gap-x-0.5 items-end">
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">Allow. Leng.</label>
                                        <asp:TextBox ID="txtAllowenceLength" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label>Width</label>
                                        <asp:TextBox ID="txtAllowenceWidth" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                    </div>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Type</label>
                                    <asp:DropDownList ID="ddlType" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex gap-x-0.5 items-end">
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">Cutting Date</label>
                                        <asp:TextBox ID="txtCuttingDate" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                    </div>
                                    <asp:TextBox ID="txtCuttingDate2" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Bundle Qty</label>
                                    <asp:TextBox ID="txtBundleQty" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Min Bundle Qty</label>
                                    <asp:TextBox ID="txtMinBundleQty" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Marker Qty</label>
                                    <asp:TextBox ID="txtMarkerQty" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Cutting Qty</label>
                                    <asp:TextBox ID="txtCuttingQty" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Total Lay Qty</label>
                                    <asp:TextBox ID="txtTotatLayQty" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full col-span-2">
                                    <label>Remarks</label>
                                    <asp:TextBox ID="txtRemarks" runat="server" TextMode="MultiLine" Rows="2" CssClass="w-full border rounded outline-none border-gray-300 px-2 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                            </div>

                        </fieldset>
                    </div>

                    <%-- Details info --%>
                    <div class="col-span-6">
                        <fieldset class="border border-gray-400 rounded w-full p-2">
                            <legend class="italic text-sm px-2 font-medium">Details Info</legend>

                            <div class="grid grid-cols-3 gap-x-2 gap-y-1 w-full">

                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>PO No</label>
                                    <asp:TextBox ID="txtPoNo" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Color</label>
                                    <asp:DropDownList ID="ddlColor" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Lot/Batch</label>
                                    <asp:TextBox ID="txtLotOrBatch" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Roll No</label>
                                    <asp:TextBox ID="txtRollNo" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Shinkage</label>
                                    <asp:DropDownList ID="ddlShinkage" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>GSM</label>
                                    <asp:TextBox ID="txtGSM" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Weight</label>
                                    <asp:TextBox ID="txtWeight" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Shade</label>
                                    <asp:DropDownList ID="ddlShade" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Lay Qty</label>
                                    <asp:TextBox ID="txtLayQty" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Order Place</label>
                                    <asp:DropDownList ID="ddlOrderPlace" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Del.</label>
                                    <asp:DropDownList ID="ddlDelivery" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex justify-between">
                                    <div class="flex items-end justify-center gap-1">
                                        <asp:CheckBox ID="chkIsTube" runat="server" CssClass="cursor-pointer accent-[#198754]" />
                                        <asp:Label for="chkIsTube" AssociatedControlID="chkIsTube" runat="server" Text="Is Tube" CssClass="cursor-pointer"></asp:Label>
                                    </div>
                                    <div class="flex justify-end items-end">
                                        <asp:Button ID="btnAdd" runat="server" Text="Add" CssClass="rounded bg-[#0d6efd] text-white px-4 py-0.5 shadow-sm hover:bg-[#0b5ed7] cursor-pointer transition delay-150 duration-300 ease-in-out" />
                                    </div>
                                </div>

                            </div>

                        </fieldset>


                        <div class="mt-3 grid grid-cols-2 gap-2">
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="whitespace-nowrap">B.N.S</label>
                                <asp:TextBox ID="txtBNS" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="whitespace-nowrap">S.N.S</label>
                                <asp:TextBox ID="txtSNS" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                            </div>
                        </div>
                    </div>

                </div>



                <%-- middle Container --%>
                <div class="mt-6 grid grid-cols-12 space-x-3">

                    <div class="col-span-3">
                        <div class="flex flex-col space-y-3 h-full">

                            <%-- employee id --%>
                            <div class="flex flex-col space-y-1 h-full">
                                <div class="flex space-x-1 items-end">
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">Employee Id</label>
                                        <asp:TextBox ID="txtEmployeeId" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                    </div>
                                    <asp:Button ID="btnAdd2" runat="server" Text="Add" CssClass="rounded bg-[#0d6efd] text-white px-4 py-0.5 shadow-sm hover:bg-[#0b5ed7] cursor-pointer transition delay-150 duration-300 ease-in-out" />
                                </div>
                                <div class="border border-gray-400 bg-gray-300 rounded w-full flex-1 overflow-y-auto overflow-x-auto">
                                    <asp:ListView ID="ListView2" runat="server"></asp:ListView>
                                </div>
                            </div>

                            <%-- part --%>
                            <div class="flex flex-col space-y-1 h-full">
                                <div class="flex space-x-1 items-end">
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">Part</label>
                                        <asp:TextBox ID="txtPart" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                    </div>
                                    <asp:Button ID="btnAdd3" runat="server" Text="Add" CssClass="rounded bg-[#0d6efd] text-white px-4 py-0.5 shadow-sm hover:bg-[#0b5ed7] cursor-pointer transition delay-150 duration-300 ease-in-out" />
                                </div>
                                <div class="border border-gray-400 bg-gray-300 rounded w-full flex-1 overflow-y-auto overflow-x-auto">
                                    <asp:ListView ID="ListView5" runat="server"></asp:ListView>
                                </div>
                            </div>


                        </div>
                    </div>
                            <%-- refresh cutt ratio btn --%>
                            <div class="flex flex-col space-y-1 items-center col-span-3 mt-[26px]">
                                <div class="w-full">
                                    <asp:Button ID="btnRefreshCuttingRation" runat="server" Text="Refresh Cut. Ratio button " CssClass="w-full rounded bg-[#0d6efd] text-white px-4 py-0.5 shadow-sm hover:bg-[#0b5ed7] cursor-pointer transition delay-150 duration-300 ease-in-out" />
                                </div>
                                <div class="border border-gray-400 bg-gray-300 rounded w-full flex-1 overflow-y-auto overflow-x-auto">
                                    <asp:GridView ID="GridView2" runat="server"></asp:GridView>
                                </div>
                            </div>




                    <%-- search --%>

                    <div class="col-span-6 flex flex-col space-y-2 items-center mt-[26px]">

                        <div class="border border-gray-400 rounded w-full bg-[#2BBBAD] text-white text-center">
                            <asp:Label ID="Label1" runat="server" Text="Search"></asp:Label>
                        </div>

                        <div class="grid grid-cols-12 border border-gray-400 rounded w-full">

                            <div class="col-span-4 w-full">

                                <div class="flex flex-col p-2 gap-x-2 gap-y-1">
                                    <div class="flex gap-x-1 items-end w-full col-span-2">
                                        <div class="flex flex-col gap-0.5 w-full">
                                            <label class="whitespace-nowrap">C. Date</label>
                                            <asp:DropDownList ID="ddlCDate" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                        </div>
                                        <asp:DropDownList ID="ddlCDate2" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                    </div>
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
                                        <asp:TextBox ID="txtPo2" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">Color</label>
                                        <asp:TextBox ID="txtColor2" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">Batch/Lot</label>
                                        <asp:TextBox ID="txtBatch" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">Floor</label>
                                        <asp:DropDownList ID="ddlFloor" runat="server" CssClass="border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                    </div>
                                    <div class="flex gap-x-1 ">
                                        <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="rounded bg-[#0d6efd] text-white px-4 py-0.5 shadow-sm hover:bg-[#0b5ed7] cursor-pointer transition delay-150 duration-300 ease-in-out" />
                                    </div>
                                </div>
                            </div>

                            <div class="col-span-8 p-2 w-full">
                                <div class="border border-gray-400 bg-gray-300 rounded w-full h-[430px] flex-1 flex-grow overflow-y-auto overflow-x-auto">
                                    <asp:ListView ID="ListView50" runat="server"></asp:ListView>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>



                <%-- total grid view --%>
                <div class="border border-gray-400 bg-gray-300 rounded w-full h-80 overflow-y-auto overflow-x-auto mt-3">
                    <asp:GridView ID="GridView1" runat="server"></asp:GridView>
                </div>


                <%-- all btn  --%>
                <div class="grid grid-cols-12 gap-x-12 p-2 border border-gray-400 rounded  mt-3">
                    <div class="col-span-5">
                        <div class="grid grid-cols-3 gap-3 items-center">

                            <asp:Button ID="btnBundleChart" runat="server" Text="Bundle Chart" CssClass="w-full rounded bg-[#0d6efd] text-white px-3 py-1 shadow-sm hover:bg-[#0b5ed7] cursor-pointer transition delay-150 duration-300 ease-in-out whitespace-nowrap" />

                            <asp:Button ID="btnBundleCard" runat="server" Text="Bundle Card" CssClass="w-full rounded bg-[#0d6efd] text-white px-3 py-1 shadow-sm hover:bg-[#0b5ed7] cursor-pointer transition delay-150 duration-300 ease-in-out whitespace-nowrap" />

                            <asp:Button ID="btnSticker" runat="server" Text="Sticker" CssClass="w-full rounded bg-[#0d6efd] text-white px-3 py-1 shadow-sm hover:bg-[#0b5ed7] cursor-pointer transition delay-150 duration-300 ease-in-out whitespace-nowrap" />

                            <asp:Button ID="btnOtherBCard" runat="server" Text="Other B. Card" CssClass="rounded bg-[#0d6efd] text-white px-2 py-1 shadow-sm hover:bg-[#0b5ed7] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                            <asp:Button ID="btnSticker2" runat="server" Text="Sticker 2" CssClass="w-full  rounded bg-[#0d6efd] text-white px-3 py-1 shadow-sm hover:bg-[#0b5ed7] cursor-pointer transition delay-150 duration-300 ease-in-out whitespace-nowrap" />

                        </div>
                    </div>


                    <%-- all checkbox --%>
                    <div class="col-span-7">
                        <div class="grid grid-cols-3 gap-3 items-center">
                            <div class="flex items-center gap-1">
                                <asp:CheckBox ID="chkRollWise" runat="server" CssClass="cursor-pointer accent-[#198754]" />
                                <asp:Label for="chkRollWise" AssociatedControlID="chkRollWise" runat="server" Text="Roll Wise" CssClass="cursor-pointer"></asp:Label>
                            </div>
                            <div class="flex items-center gap-1">
                                <asp:CheckBox ID="chkGroupMarker" runat="server" CssClass="cursor-pointer accent-[#198754]" />
                                <asp:Label for="chkGroupMarker" AssociatedControlID="chkGroupMarker" runat="server" Text="Group Marker" CssClass="cursor-pointer"></asp:Label>
                            </div>
                            <div class="flex items-center gap-1">
                                <asp:CheckBox ID="chkNotRunningShade" runat="server" CssClass="cursor-pointer accent-[#198754]" />
                                <asp:Label for="chkNotRunningShade" AssociatedControlID="chkNotRunningShade" runat="server" Text="Not-Running Shade" CssClass="cursor-pointer"></asp:Label>
                            </div>
                            <div class="flex items-center gap-1">
                                <asp:CheckBox ID="chkRunningShade" runat="server" CssClass="cursor-pointer accent-[#198754]" />
                                <asp:Label for="chkRunningShade" AssociatedControlID="chkRunningShade" runat="server" Text="Running Shade" CssClass="cursor-pointer"></asp:Label>
                            </div>
                            <div class="flex items-center gap-1">
                                <asp:CheckBox ID="chkRollWiseRunnig" runat="server" CssClass="cursor-pointer accent-[#198754]" />
                                <asp:Label for="chkRollWiseRunnig" AssociatedControlID="chkRollWiseRunnig" runat="server" Text="Roll Wise Running" CssClass="cursor-pointer"></asp:Label>
                            </div>
                            <div class="flex items-center gap-1">
                                <asp:CheckBox ID="chkPageWiseSlot" runat="server" CssClass="cursor-pointer accent-[#198754]" />
                                <asp:Label for="chkPageWiseSlot" AssociatedControlID="chkPageWiseSlot" runat="server" Text="Page Wise Slot" CssClass="cursor-pointer"></asp:Label>
                            </div>
                            <div class="flex items-center gap-1 col-span-2">
                                <asp:CheckBox ID="chkRollWiseNotRunnig" runat="server" CssClass="cursor-pointer accent-[#198754]" />
                                <asp:Label for="chkRollWiseNotRunnig" AssociatedControlID="chkRollWiseNotRunnig" runat="server" Text="Roll Wise Not Running" CssClass="cursor-pointer"></asp:Label>
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






