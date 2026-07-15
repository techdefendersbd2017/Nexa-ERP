<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DailyCuttingTargetAndManpowerSet.aspx.cs" Inherits="Nexa_ERP.Production.Cutting.DailyCuttingTargetAndManpowerSet" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Daily Cutting Target & Manpower set</title>

    <!-- tailwind css link -->
    <script src="https://cdn.tailwindcss.com"></script>

</head>
<body>
    <form id="form1" runat="server" class="min-h-screen p-2 mt-2">
        <div class="max-w-[1320px] w-full m-auto rounded-lg border">

            <div class="bg-[#0d6efd] text-white rounded-t-lg px-4 py-2">
                <p class="text-2xl mb-1">Daily Cutting Target & Manpower set</p>
                <p class="">Label</p>
            </div>

            <div class="bg-[#f0f0f0] shadow-xl rounded-b-lg px-4 py-4">
                <asp:HiddenField ID="hfUserId" runat="server" />

                <%-- Main fields container --%>
                <div class="grid grid-cols-7 gap-x-4">

                    <%-- Left container --%>
                    <div class="col-span-5">
                        <div class="flex flex-col flex-grow h-full">
                            <div class="grid grid-cols-5 gap-x-2 gap-y-1">
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="whitespace-nowrap">Manpower ID</label>
                                    <asp:TextBox ID="txtManpowerId" runat="server" ReadOnly="true" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Section</label>
                                    <asp:DropDownList ID="ddlSection" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Floor</label>
                                    <asp:DropDownList ID="ddlFloor" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Line No</label>
                                    <asp:DropDownList ID="ddlLineNo" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex gap-1 items-end w-full">
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label>Date Time</label>
                                        <asp:DropDownList ID="ddlDateTime" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                    </div>
                                    <!-- <div>
                                        <asp:Button ID="btnCopy" runat="server" Text="Copy" CssClass="rounded bg-[#17A2B8] text-white px-3 py-0.5 shadow-sm hover:bg-[#138496] cursor-pointer transition delay-150 duration-300 ease-in-out" />
                                    </div> -->
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Target Hour</label>
                                    <asp:TextBox ID="txtTargetHour" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Calculative Hour</label>
                                    <asp:TextBox ID="txtCalculativeHour" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex gap-0.5  w-full">
                                    <div class="flex flex-col gap-0.5 w-full">
                                        <label>Target Eff.</label>
                                        <asp:TextBox ID="txtTargetEfficiency" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                    </div>
                                    <div class="flex items-end">
                                        <label>%</label>
                                    </div>
                                </div>

                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Buyer</label>
                                    <asp:DropDownList ID="ddlBuyer" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Style No</label>
                                    <asp:TextBox ID="txtStyleNo" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>PO No</label>
                                    <asp:TextBox ID="txtPoNo" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>color</label>
                                    <asp:DropDownList ID="ddlColor" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Order Qty</label>
                                    <asp:TextBox ID="txtOrderQty" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Plan Cut Qty</label>
                                    <asp:TextBox ID="txtPlanCutQty" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Cut Qty</label>
                                    <asp:TextBox ID="txtCutQty" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Cut Balance</label>
                                    <asp:TextBox ID="txtCutBalance" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Cut. SMV</label>
                                    <asp:TextBox ID="txtCutSMV" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex items-end">
                                    <asp:Button ID="btnCopy2" runat="server" Text="Copy" CssClass="rounded bg-[#17A2B8] text-white px-3 py-0.5 shadow-sm hover:bg-[#138496] cursor-pointer transition delay-150 duration-300 ease-in-out" />
                                </div>
                                <div class="col-span-3 justify-start">
                                    <fieldset class="border border-gray-400 rounded px-2 py-1.5">
                                        <legend class="px-2 italic text-sm font-medium">Manpower Status</legend>

                                        <div class="flex gap-x-4">
                                            <div class="flex flex-col gap-0.5 w-full">
                                                <label>Cutting Man</label>
                                                <asp:TextBox ID="txtCuttingMan" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                            </div>
                                            <div class="flex flex-col gap-0.5 w-full">
                                                <label>Cutting Assistant</label>
                                                <asp:TextBox ID="TextBox2" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                            </div>
                                        </div>
                                    </fieldset>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full col-span-2">
                                    <label>Remarks</label>
                                    <asp:TextBox ID="txtRemarks" runat="server" TextMode="MultiLine" Rows="2" CssClass="w-full border rounded outline-none border-gray-300 px-2 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                            </div>
                        </div>
                    </div>


                    <%-- Right container --%>
                    <div class=" col-span-2">

                        <!-- text list view 1st -->
                        <div class="border border-gray-400 bg-gray-300 rounded w-full h-full flex-1 overflow-y-auto">
                            <asp:GridView ID="GridView1" runat="server"></asp:GridView>
                        </div>
                    </div>
                </div>


                <div class="mt-3">
                    <fieldset class="border border-gray-400 rounded px-2 py-1.5">
                        <div class="grid grid-cols-7 col-span-4 gap-x-2 gap-y-1">
                            <div class="flex flex-col gap-0.5 w-full">
                                <label>Day Target</label>
                                <asp:TextBox ID="txtDayTarget" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label>Table</label>
                                <asp:DropDownList ID="ddlTable" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label>Table Cut. Man</label>
                                <asp:TextBox ID="txtTableCutterMan" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label>Table Cut. Assis.</label>
                                <asp:TextBox ID="txtTableCutterAssistant" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                               <label>Marker Pcs</label>
                                <asp:TextBox ID="txtMarkerPcs" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label>Lay Qty</label>
                                <asp:TextBox ID="txtLayQty" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label>Req. Min</label>
                                <asp:TextBox ID="txtReqMin" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label>Hour</label>
                                <asp:TextBox ID="txtHour" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label>Plan Start Time</label>
                                <asp:DropDownList ID="ddlPlanStartTime" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label>Plan End Time</label>
                                <asp:DropDownList ID="ddlPlanEndTime" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label>T. Eff%</label>
                                <asp:TextBox ID="txtTEff" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label>W. Hour</label>
                                <asp:TextBox ID="txtWHour" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex flex-col gap-0.5 w-full">
                                <label>Total</label>
                                <asp:TextBox ID="txtTotal" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                            </div>
                            <div class="flex items-end">
                                <asp:Button ID="btnAdd" runat="server" Text="Add" CssClass="rounded bg-[#22C55E] text-white px-4 py-0.5 shadow-sm hover:bg-[#239A8D] cursor-pointer transition delay-150 duration-300 ease-in-out" />
                            </div>

                            <div class="flex gap-1 w-full items-end col-span-7">
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Remarks</label>
                                    <asp:TextBox ID="txtRemark" runat="server" Rows="2" TextMode="MultiLine" CssClass="w-full border rounded outline-none border-gray-300 px-2 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                            </div>

                        </div>
                    </fieldset>
                </div>

                <!-- text list view 1st -->
                <div class="border border-gray-400 bg-gray-300 rounded w-full h-72 mt-3 overflow-y-auto">
                    <asp:GridView ID="GridView2" runat="server"></asp:GridView>
                </div>

                <!-- btn -->
                <div class="space-x-4 flex justify-between items-center mt-3">
                    <div class="flex items-center gap-3">
                        <asp:Button ID="btnRefresh" runat="server" Text="Refresh" CssClass="rounded bg-[#2BBBAD] text-white px-4 py-1 shadow-sm hover:bg-[#239A8D] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                        <div class="flex items-center gap-1">
                            <asp:CheckBox ID="chkIsActive" runat="server" CssClass="cursor-pointer accent-[#198754]" />
                            <asp:Label for="chkIsActive" AssociatedControlID="chkIsActive" runat="server" Text="Is Active?" CssClass="cursor-pointer"></asp:Label>
                        </div>
                    </div>
                    <div class="flex gap-3">
                        <asp:Button ID="btnCutingTargetSheet" runat="server" Text="Cutting Target Sheet" CssClass="rounded bg-[#4A90E2] text-white px-4 py-1 shadow-sm hover:bg-[#357ABD] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                        <asp:Button ID="btnShow" runat="server" Text="Show" CssClass="rounded bg-[#4A90E2] text-white px-4 py-1 shadow-sm hover:bg-[#357ABD] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                        <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="rounded bg-[#22C55E] text-white px-4 py-1 shadow-sm hover:bg-[#16A34A] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                        <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="rounded bg-[#E55353] text-white px-4 py-1 shadow-sm hover:bg-[#C93F3F] cursor-pointer transition delay-150 duration-300 ease-in-out" />


                        <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="rounded bg-[#64748B] text-white px-4 py-1 shadow-sm hover:bg-[#475569] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                        <asp:Button ID="btnClose" runat="server" Text="Close" CssClass="rounded bg-[#E55353] text-white px-4 py-1 shadow-sm hover:bg-[#475569] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
