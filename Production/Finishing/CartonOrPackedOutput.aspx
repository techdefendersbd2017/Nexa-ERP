<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CartonOrPackedOutput.aspx.cs" Inherits="Nexa_ERP.Production.Finishing.CartonOrPackedOutput" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Carton/Packed Output</title>

    <!-- tailwind css link -->
    <script src="https://cdn.tailwindcss.com"></script>

</head>
<body>
    <form id="form1" runat="server" class="min-h-screen p-2 mt-2">
        <div class="max-w-[1320px] w-full m-auto rounded-lg border">

            <div class="bg-[#0d6efd] text-white rounded-t-lg px-4 py-2">
                <p class="text-2xl mb-1">Carton/Packed Output</p>
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
                                    <label class="whitespace-nowrap">Carton/Packed ID</label>
                                    <asp:TextBox ID="txtCartonPackedId" runat="server" ReadOnly="true" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="whitespace-nowrap">Date</label>
                                    <asp:DropDownList ID="ddlDate" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="whitespace-nowrap">Line No</label>
                                    <asp:DropDownList ID="ddlLineNo" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="whitespace-nowrap">Floor</label>
                                    <asp:DropDownList ID="ddlFloor" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full col-span-2">
                                    <label class="whitespace-nowrap">Packed No</label>
                                    <asp:TextBox ID="txtPackedNo" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="whitespace-nowrap">PO</label>
                                    <asp:TextBox ID="txtPo" runat="server" ReadOnly="true" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full col-span-2">
                                    <label class="whitespace-nowrap">Buyer</label>
                                    <asp:TextBox ID="txtBuyer" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                            </div>


                            <%-- Details info Fieldset --%>

                            <fieldset class="border border-gray-400 rounded p-2">
                                <legend class="italic font-medium text-sm px-2">Details Info</legend>

                                <div class="grid grid-cols-3 gap-x-2 gap-y-1">

                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">P. Month</label>
                                        <asp:DropDownList ID="ddlPMonth" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">Ship Date</label>
                                        <asp:DropDownList ID="ddlShipDate" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                    </div>
                                    <div class="flex items-end gap-0.5">
                                        <div class="flex flex-col gap-0.5 w-full">
                                            <label class="whitespace-nowrap">Ctn. L</label>
                                            <asp:TextBox ID="txtCtnL" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                        </div>
                                        <label class="whitespace-nowrap">cm</label>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">Net Weight</label>
                                        <asp:TextBox ID="txtNetWeight" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">Gro Weight</label>
                                        <asp:TextBox ID="txtGroWeight" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                    </div>
                                    <div class="flex items-end gap-0.5">
                                        <div class="flex flex-col gap-0.5 w-full">
                                            <label class="whitespace-nowrap">Ctn. W</label>
                                            <asp:TextBox ID="txtCtnW" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                        </div>
                                        <label class="whitespace-nowrap">cm</label>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">Finished</label>
                                        <asp:TextBox ID="txtFinished" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">Carton No</label>
                                        <asp:TextBox ID="txtCartonNo" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                    </div>
                                    <div class="flex items-end gap-0.5">
                                        <div class="flex flex-col gap-0.5 w-full">
                                            <label class="whitespace-nowrap">Ctn. H</label>
                                            <asp:TextBox ID="txtCtnH" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                        </div>
                                        <label class="whitespace-nowrap">cm</label>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">Carton Qty</label>
                                        <asp:TextBox ID="txtCartonQty" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                    </div>
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">Per Ctn Qty</label>
                                        <asp:TextBox ID="txtPerCtnQty" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                    </div>
                                </div>
                            </fieldset>
                        </div>
                    </div>



                    <%-- right container list view --%>
                    <div class="col-span-5 flex flex-col h-full">
                        <div class="grid grid-cols-2 gap-x-2 gap-y-1">
                            <div class="flex gap-0.5 items-end col-span-2">
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="whitespace-nowrap">Pack Date</label>
                                    <asp:DropDownList ID="ddlPackDate" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <label class="whitespace-nowrap">-</label>
                                <asp:DropDownList ID="ddlPackDate2" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="whitespace-nowrap">Buyer</label>
                                <asp:TextBox ID="txtBuyer2" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="whitespace-nowrap">Style</label>
                                <asp:TextBox ID="txtStyle" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label class="whitespace-nowrap">PO</label>
                                <asp:TextBox ID="txtPo2" runat="server" ReadOnly="true" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex items-end">
                                <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="rounded bg-[#22C55E] text-white px-4 py-0.5 shadow-sm hover:bg-[#16A34A] cursor-pointer transition delay-150 duration-300 ease-in-out" />
                            </div>
                        </div>

                        <%-- list view --%>
                        <div class="border border-gray-400 bg-gray-300 rounded w-full flex-1  overflow-y-auto overflow-x-auto mt-4">
                            <asp:ListView ID="ListView1" runat="server"></asp:ListView>
                        </div>

                    </div>
                </div>


                <%-- assorted size details fieldset --%>
                <div class="grid grid-cols-12 gap-x-3 gap-y-2 mt-2">

                    <fieldset class="border border-gray-400 rounded p-2 col-span-6">
                        <legend class="italic font-medium text-sm px-2">Assorted Size Details Filter Option</legend>

                        <div class="flex flex-col space-y-2">
                            <div class="grid grid-cols-3 gap-x-2 gap-y-1">
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="whitespace-nowrap">Style No</label>
                                    <asp:DropDownList ID="ddlStyleNo" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="whitespace-nowrap">Color</label>
                                    <asp:DropDownList ID="ddlColor" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="whitespace-nowrap">Size</label>
                                    <asp:DropDownList ID="ddlSize" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex items-end col-span-3 justify-end">
                                    <asp:Button ID="btnFilter" runat="server" Text="Filter" CssClass="rounded bg-[#22C55E] text-white px-4 py-0.5 shadow-sm hover:bg-[#16A34A] cursor-pointer transition delay-150 duration-300 ease-in-out" />
                                </div>
                            </div>


                            <%-- list view --%>
                            <div class="border border-gray-400 bg-gray-300 rounded w-full h-36 overflow-y-auto overflow-x-auto mt-2">
                                <asp:GridView ID="GridView2" runat="server"></asp:GridView>
                            </div>

                            <div class="flex gap-x-4 items-end">
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="whitespace-nowrap">Remarks</label>
                                    <asp:TextBox ID="txtRemarks" runat="server" TextMode="MultiLine" Rows="2" CssClass="w-full border rounded outline-none border-gray-300 px-2 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex items-center gap-1">
                                    <asp:CheckBox ID="chkIsAssorted" runat="server" CssClass="cursor-pointer accent-[#198754]" />
                                    <asp:Label for="chkIsAssorted" AssociatedControlID="chkIsAssorted" runat="server" Text="Is Assorted" CssClass="cursor-pointer whitespace-nowrap"></asp:Label>
                                </div>
                                <div class="flex items-end">
                                    <asp:Button ID="btnAdd" runat="server" Text="Add" CssClass="rounded bg-[#22C55E] text-white px-4 py-0.5 shadow-sm hover:bg-[#16A34A] cursor-pointer transition delay-150 duration-300 ease-in-out" />
                                </div>
                            </div>

                        </div>
                    </fieldset>

                    <%-- order status --%>
                    <div class="col-span-6 flex flex-col h-full pt-2">
                        <label class="whitespace-nowrap w-full flex justify-center items-center bg-[#0d6efd] text-white border border-gray-400 rounded py-0.5">Order Status</label>

                        <%-- list view --%>
                        <div class="border border-gray-400 bg-gray-300 rounded w-full flex-1 h-36 overflow-y-auto overflow-x-auto mt-0.5">
                            <asp:ListView ID="ListView2" runat="server"></asp:ListView>
                        </div>
                    </div>
                </div>


                <%-- grid view --%>
                <div class="border border-gray-400 bg-gray-300 rounded w-full h-72 overflow-y-auto overflow-x-auto mt-2 mb-2">
                    <asp:GridView ID="GridView1" runat="server"></asp:GridView>
                </div>

                <div class="grid grid-cols-5 gap-x-2">

                    <div class="flex flex-col gap-0.5 w-full">
                        <label>Total Ctn. Qty:</label>
                        <asp:TextBox ID="txtTotalCtnQty" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full">
                        <label>Total Qty:</label>
                        <asp:TextBox ID="txtTotalQty" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full">
                        <label>Total Gross wt:</label>
                        <asp:TextBox ID="txtTotalGrossWt" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full">
                        <label>Total Net wt:</label>
                        <asp:TextBox ID="txtTotalNetWt" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                    </div>
                    <div class="flex flex-col gap-0.5 w-full">
                        <label>Total CBM:</label>
                        <asp:TextBox ID="txtTotalCbm" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
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