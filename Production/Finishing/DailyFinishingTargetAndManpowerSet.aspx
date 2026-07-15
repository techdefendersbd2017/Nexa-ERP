<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DailyFinishingTargetAndManpowerSet.aspx.cs" Inherits="Nexa_ERP.Production.Finishing.DailyFinishingTargetAndManpowerSet" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Daily Finishing Target And Manpower Set</title>

    <!-- tailwind css link -->
    <script src="https://cdn.tailwindcss.com"></script>

</head>
<body>
    <form id="form1" runat="server" class="min-h-screen p-2 mt-2">
        <div class="max-w-[1320px] w-full m-auto rounded-lg border">

            <div class="bg-[#0d6efd] text-white rounded-t-lg px-4 py-2">
                <p class="text-2xl mb-1">Daily Finishing Target And Manpower Set</p>
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
                                    <label class="whitespace-nowrap">Fin. Manpower ID</label>
                                    <asp:TextBox ID="txtFinishingManpowerId" runat="server" ReadOnly="true" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="whitespace-nowrap">Section</label>
                                    <asp:DropDownList ID="ddlSection" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="whitespace-nowrap">Floor</label>
                                    <asp:DropDownList ID="ddlFloor" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="whitespace-nowrap">Date Time</label>
                                    <asp:DropDownList ID="ddlDateTime" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="whitespace-nowrap">Target Hour</label>
                                    <asp:TextBox ID="txtTargetHour" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex gap-0.5 items-end">
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label class="whitespace-nowrap">Target Efficiency</label>
                                        <asp:TextBox ID="txtTargetEfficiency" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                    </div>
                                    <label class="whitespace-nowrap">%</label>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full col-span-3">
                                    <label class="whitespace-nowrap">Remarks</label>
                                    <asp:TextBox ID="txtRemarks" runat="server" TextMode="MultiLine" Rows="2" CssClass="w-full border rounded outline-none border-gray-300 px-2 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>

                                <fieldset class="border border-gray-400 rounded p-2 col-span-3">
                                    <legend class="italic text-sm px-2 font-medium">Manpower Status</legend>

                                    <div class="grid grid-cols-3 gap-x-2 gap-y-1">
                                        <div class="flex flex-col gap-0.5 w-full">
                                            <label class="whitespace-nowrap">Quality</label>
                                            <asp:TextBox ID="txtQuality" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                        </div>
                                        <div class="flex flex-col gap-0.5 w-full">
                                            <label class="whitespace-nowrap">Iron Man</label>
                                            <asp:TextBox ID="txtIronMan" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                        </div>
                                        <div class="flex flex-col gap-0.5 w-full">
                                            <label class="whitespace-nowrap">Sucker Man</label>
                                            <asp:TextBox ID="txtSukerMan" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                        </div>
                                        <div class="flex flex-col gap-0.5 w-full">
                                            <label class="whitespace-nowrap">Poly Man</label>
                                            <asp:TextBox ID="txtPolyMan" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                        </div>
                                        <div class="flex flex-col gap-0.5 w-full">
                                            <label class="whitespace-nowrap">Packing Man</label>
                                            <asp:TextBox ID="txtPackingMan" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                        </div>
                                        <div class="flex flex-col gap-0.5 w-full">
                                            <label class="whitespace-nowrap">Total MP</label>
                                            <asp:TextBox ID="txtTotalMp" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                        </div>
                                        <div class="flex items-end">
                                            <asp:Button ID="btnChangeMp" runat="server" Text="Change MP" CssClass="rounded bg-[#22C55E] text-white px-2 py-0.5 shadow-sm hover:bg-[#16A34A] cursor-pointer transition delay-150 duration-300 ease-in-out" />
                                        </div>
                                    </div>
                                </fieldset>

                            </div>
                        </div>
                    </div>



                    <%-- total input with list view --%>
                    <div class="col-span-6 flex flex-col h-full">

                        <%-- top input --%>

                        <div class="grid grid-cols-3 gap-x-2 gap-y-1">

                            <div class="flex flex-col gap-0.5 w-full">
                                <label>Order Qty</label>
                                <asp:TextBox ID="txtOrderQty" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label>Sewing</label>
                                <asp:TextBox ID="txtSewing" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label>Wash Rcvd</label>
                                <asp:TextBox ID="txtWashRcvd" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label>Fin. Input</label>
                                <asp:TextBox ID="txtFinishingInput" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label>Fin. Qty</label>
                                <asp:TextBox ID="txtFinishingQty" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label>Fin. WIP</label>
                                <asp:TextBox ID="txtFinishingWip" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                            </div>
                        </div>

                        <%-- list view --%>
                        <div class="border border-gray-400 bg-gray-300 rounded w-full flex-1 h-36 overflow-y-auto overflow-x-auto mt-2 mb-1">
                            <asp:ListView ID="ListView1" runat="server"></asp:ListView>
                        </div>

                    </div>
                </div>


                <div class="grid grid-cols-12 gap-x-3 gap-y-1 mt-3">

                    <%-- total input with list view --%>
                    <div class="col-span-12 flex flex-col h-full">

                        <%-- top input --%>

                        <div class="grid grid-cols-6 gap-x-2 gap-y-1">

                            <div class="flex flex-col gap-0.5 w-full">
                                <label>Buyer</label>
                                <asp:DropDownList ID="ddlBuyer" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label>PO No</label>
                                <asp:TextBox ID="txtPoNo3" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label>Style No</label>
                                <asp:TextBox ID="txtStyleNo3" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label>Order Qty</label>
                                <asp:TextBox ID="txtOrderQty2" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label>Day Target</label>
                                <asp:TextBox ID="txtDayTarget" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label>TGT/Hr.</label>
                                <asp:TextBox ID="txtTgtHr" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label>Req. Hr.</label>
                                <asp:TextBox ID="txtReqHr" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label>Tgt Hr.</label>
                                <asp:TextBox ID="txtTgtHr2" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label>Tgt Effi</label>
                                <asp:TextBox ID="txtTgtEffi" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full col-span-2">
                                <label>Remarks</label>
                                <asp:TextBox ID="txtRemarks2" runat="server" TextMode="MultiLine" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex items-end">
                                <asp:Button ID="btnAdd" runat="server" Text="Add" CssClass="rounded bg-[#22C55E] text-white px-4 py-0.5 shadow-sm hover:bg-[#16A34A] cursor-pointer transition delay-150 duration-300 ease-in-out" />
                            </div>

                        </div>


                    </div>
                </div>


                <%-- list view --%>
                <div class="border border-gray-400 bg-gray-300 rounded w-full h-72 overflow-y-auto overflow-x-auto mt-2 mb-1">
                    <asp:GridView ID="GridView1" runat="server"></asp:GridView>
                </div>

                <div class="grid grid-cols-3">

                    <div class="flex flex-col gap-0.5 w-full">
                        <label>Total</label>
                        <asp:TextBox ID="txtTotal" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
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

                        <asp:Button ID="btnFinishingTargetSheet" runat="server" Text="Finishing Target Sheet" CssClass="rounded bg-[#64748B] text-white px-4 py-1 shadow-sm hover:bg-[#475569] cursor-pointer transition delay-150 duration-300 ease-in-out" />

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