<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="IncrementEntry.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.Payrollinformation.IncrementEntry" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Increment Entry</title>

    <!-- tailwind css link -->
    <script src="https://cdn.tailwindcss.com"></script>


    <style>
        .page {
            display: none;
        }

            .page.active {
                display: block;
                background-color: white;
            }
    </style>
</head>

<body>
    <form id="form1" runat="server" class="min-h-screen p-2 mt-2">
        <div class="max-w-[1320px] w-full m-auto rounded-lg border">

            <div class="bg-[#0d6efd] text-white rounded-t-lg px-4 py-2">
                <p class="text-2xl mb-1">Increment Entry</p>
                <p class="">Label</p>
            </div>

            <div class="bg-[#f0f0f0] shadow-xl rounded-b-lg px-4 py-2">
                <asp:HiddenField ID="hfUserId" runat="server" />

                <div class="tabs  flex">
                    <div class="tab-wrapper bg-white flex items-center">
                        <button type="button" data-page="increment" class="px-4 h-10">Increment</button>
                        <span class="w-0.5 h-10 bg-gray-500"></span>
                    </div>
                    <div class="tab-wrapper flex items-center">
                        <button type="button" data-page="promotion" class="px-4 h-10">Promotion</button>
                        <span class="w-0.5 h-10 bg-gray-500"></span>
                    </div>
                    <div class="flex items-center tab-wrapper">
                        <button type="button" data-page="incrementWithPromotion" class="px-4 h-10">Increment With Promotion</button>
                    </div>
                </div>

                <div class="pages mt-0">

                    <%-- Increment page --%>

                    <div id="increment" class="page">
                        <div class="border border-dashed rounded border-gray-500 p-2 pb-0 mb-4">
                            <div class="grid grid-cols-4 gap-x-4 gap-y-1.5">
                                <div class="flex flex-col gap-0.5 w-full">
                                    <asp:Label ID="Label" runat="server" Text="Increment ID"></asp:Label>
                                    <asp:TextBox ID="txtIncrementId" ReadOnly="true" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <asp:Label ID="Label1" runat="server" Text="Emp. Status"></asp:Label>
                                    <asp:DropDownList ID="ddlIncrementEmpStatus" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <asp:Label ID="Label2" runat="server" Text="Category"></asp:Label>
                                    <asp:DropDownList ID="ddlIncrementCategory" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <asp:Label ID="Label3" runat="server" Text="Department"></asp:Label>
                                    <asp:DropDownList ID="ddlIncrementDepartment" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <asp:Label ID="Label4" runat="server" Text="Section"></asp:Label>
                                    <asp:DropDownList ID="ddlIncrementSection" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <asp:Label ID="Label5" runat="server" Text="Line"></asp:Label>
                                    <asp:DropDownList ID="ddlIncrementLine" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <asp:Label ID="Label6" runat="server" Text="Designation"></asp:Label>
                                    <asp:DropDownList ID="ddlIncrementDesignation" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <asp:Label ID="Label7" runat="server" Text="From Month"></asp:Label>
                                    <asp:DropDownList ID="ddlIncrementFromMonth" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <asp:Label ID="Label8" runat="server" Text="Increment Type"></asp:Label>
                                    <asp:DropDownList ID="ddlIncrementType" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <asp:Label ID="Label9" runat="server" Text="Increment Value"></asp:Label>
                                    <asp:TextBox ID="txtIncrementValue" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <asp:Label ID="Label10" runat="server" Text="Increment From"></asp:Label>
                                    <asp:DropDownList ID="ddlIncrementFrom" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>

                                <div class="flex flex-col gap-0.5 w-full">
                                    <asp:Label ID="Label11" runat="server" Text="Effective Date"></asp:Label>
                                    <asp:DropDownList ID="ddlIncrementEffectiveDate" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <asp:Label ID="Label111" runat="server" Text="Ye"></asp:Label>
                                    <asp:DropDownList ID="ddlIncrementYe" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                            </div>



                            <!-- btn -->
                            <div class="space-x-4 flex justify-between items-center my-4">
                                <div class="flex items-center gap-3 cursor-pointer">
                                    <asp:Button ID="btnIncrementRefresh" runat="server" Text="Refresh" CssClass="rounded bg-[#64748B] text-white px-4 py-1 shadow-sm hover:bg-[#475569] transition delay-150 duration-300 ease-in-out" />

                                    <div class="flex items-center gap-1">
                                        <asp:CheckBox ID="chkIncrementIsActive" runat="server" CssClass="cursor-pointer accent-[#198754]" />
                                        <asp:Label for="chkIncrementIsActive" AssociatedControlID="chkIncrementIsActive" runat="server" Text="Is Active?" CssClass="cursor-pointer"></asp:Label>
                                    </div>
                                </div>
                                <div class="flex gap-3">
                                    <asp:Button ID="btnIncrementShow" runat="server" Text="Show" CssClass="rounded bg-[#2563EB] text-white px-4 py-1 shadow-sm hover:bg-[#1D4ED8] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                                    <asp:Button ID="btnIncrementAll" runat="server" Text="All" CssClass="rounded bg-[#10B981] text-white px-4 py-1 shadow-sm hover:bg-[#059669] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                                    <asp:Button ID="btnIncrementViewOpenList" runat="server" Text="View Open List" CssClass="rounded bg-[#F59E0B] text-white px-4 py-1 shadow-sm hover:bg-[#D97706] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                                    <asp:Button ID="btnIncrementExportToExcel" runat="server" Text="Export To Excel" CssClass="rounded bg-[#14B8A6] text-white px-4 py-1 shadow-sm hover:bg-[#059669] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                                    <asp:Button ID="btnIncrementPrintView" runat="server" Text="Print View" CssClass="rounded bg-[#F97316] text-white px-4 py-1 shadow-sm hover:bg-[#EA580C] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                                    <asp:Button ID="btnIncrementSave" runat="server" Text="Save" CssClass="rounded bg-[#8B5CF6] text-white px-4 py-1 shadow-sm hover:bg-[#7C3AED] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                                    <asp:Button ID="btnIncrementClear" runat="server" Text="Clear" CssClass="rounded bg-[#EF4444] text-white px-4 py-1 shadow-sm hover:bg-[#DC2626] cursor-pointer transition delay-150 duration-300 ease-in-out" />
                                </div>
                            </div>
                        </div>

                        <!-- text grid Increment page -->
                        <div class="border border-gray-400 bg-gray-50 rounded w-full h-72 overflow-y-scroll">
                            <asp:GridView ID="incrementGridView" runat="server"></asp:GridView>
                        </div>
                    </div>



                    <%-- Promotion page --%>
                    <div id="promotion" class="page">
                        <div class="border border-dashed rounded border-gray-500 p-2 pb-0 mb-4">
                            <div class="grid grid-cols-4 gap-x-4 gap-y-1.5">
                                <div class="flex flex-col gap-0.5 w-full">
                                    <asp:Label ID="Label12" runat="server" Text="Promotion ID"></asp:Label>
                                    <asp:TextBox ID="txtPromotionId" ReadOnly="true" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <asp:Label ID="Label13" runat="server" Text="Emp. Status"></asp:Label>
                                    <asp:DropDownList ID="ddlPromotionEmpStatus" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <asp:Label ID="Label14" runat="server" Text="Category"></asp:Label>
                                    <asp:DropDownList ID="ddlPromotionCategory" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <asp:Label ID="Label15" runat="server" Text="Department"></asp:Label>
                                    <asp:DropDownList ID="ddlPromotionDepartment" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <asp:Label ID="Label16" runat="server" Text="Section"></asp:Label>
                                    <asp:DropDownList ID="ddlPromotionSection" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <asp:Label ID="Label17" runat="server" Text="Line"></asp:Label>
                                    <asp:DropDownList ID="ddlPromotionLine" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <asp:Label ID="Label18" runat="server" Text="Designation "></asp:Label>
                                    <asp:DropDownList ID="ddlPromotionDesignation" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <asp:Label ID="Label19" runat="server" Text="From Date"></asp:Label>
                                    <asp:DropDownList ID="ddlPromotionFromDate" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <asp:Label ID="Label20" runat="server" Text="Pro Designation"></asp:Label>
                                    <asp:DropDownList ID="ddlPromotionProDesignation" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <asp:Label ID="Label21" runat="server" Text="Pro Category"></asp:Label>
                                    <asp:DropDownList ID="ddlPromotionProCategory" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <asp:Label ID="Label22" runat="server" Text="Pro Department"></asp:Label>
                                    <asp:DropDownList ID="ddlPromotionProDepartment" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <asp:Label ID="Label23" runat="server" Text="Pro Section"></asp:Label>
                                    <asp:DropDownList ID="ddlPromotionProSection" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>

                                <div class="flex flex-col gap-0.5 w-full">
                                    <asp:Label ID="Label24" runat="server" Text="Effective Date"></asp:Label>
                                    <asp:DropDownList ID="ddlPromotionEfectiveDate" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <asp:Label ID="Label240" runat="server" Text="Ye"></asp:Label>
                                    <asp:DropDownList ID="ddlPromotionYe" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                            </div>



                            <!-- btn -->
                            <div class="space-x-4 flex justify-between items-center my-4">
                                <div class="flex items-center gap-3 cursor-pointer">
                                    <asp:Button ID="btnPromotionRefresh" runat="server" Text="Refresh" CssClass="rounded bg-[#64748B] text-white px-4 py-1 shadow-sm hover:bg-[#475569] transition delay-150 duration-300 ease-in-out" />

                                    <div class="flex items-center gap-1">
                                        <asp:CheckBox ID="chkPromotionIsActive" runat="server" CssClass="cursor-pointer accent-[#198754]" />
                                        <asp:Label for="chkPromotionIsActive" AssociatedControlID="chkPromotionIsActive" runat="server" Text="Is Active?" CssClass="cursor-pointer"></asp:Label>
                                    </div>
                                </div>
                                <div class="flex gap-3">
                                    <asp:Button ID="btnPromotionShow" runat="server" Text="Show" CssClass="rounded bg-[#2563EB] text-white px-4 py-1 shadow-sm hover:bg-[#1D4ED8] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                                    <asp:Button ID="btnPromotionAll" runat="server" Text="All" CssClass="rounded bg-[#10B981] text-white px-4 py-1 shadow-sm hover:bg-[#059669] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                                    <asp:Button ID="btnPromotionExportToExcel" runat="server" Text="Export To Excel" CssClass="rounded bg-[#14B8A6] text-white px-4 py-1 shadow-sm hover:bg-[#059669] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                                    <asp:Button ID="btnPromotionPrintView" runat="server" Text="Print View" CssClass="rounded bg-[#F97316] text-white px-4 py-1 shadow-sm hover:bg-[#EA580C] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                                    <asp:Button ID="btnPromotionSave" runat="server" Text="Save" CssClass="rounded bg-[#8B5CF6] text-white px-4 py-1 shadow-sm hover:bg-[#7C3AED] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                                    <asp:Button ID="btnPromotionClear" runat="server" Text="Clear" CssClass="rounded bg-[#EF4444] text-white px-4 py-1 shadow-sm hover:bg-[#DC2626] cursor-pointer transition delay-150 duration-300 ease-in-out" />
                                </div>
                            </div>
                        </div>

                        <!-- text grid Promotion pgae -->
                        <div class="border border-gray-400 bg-gray-50 rounded w-full h-72 overflow-y-scroll">
                            <asp:GridView ID="PromotionGridView" runat="server"></asp:GridView>
                        </div>
                    </div>


                    <%-- Increment with promotion page --%>

                    <div id="incrementWithPromotion" class="page">
                        <div class="border border-dashed rounded border-gray-500 p-2 pb-0 mb-4">
                            <div class="grid grid-cols-4 gap-x-4 gap-y-1.5">
                                <div class="flex flex-col gap-0.5 w-full">
                                    <asp:Label ID="Label25" runat="server" Text="Increment with Promotion ID"></asp:Label>
                                    <asp:TextBox ID="txtIncWithProID" ReadOnly="true" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <asp:Label ID="Label26" runat="server" Text="Emp. Status"></asp:Label>
                                    <asp:DropDownList ID="ddlIncWithProEmpStatus" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <asp:Label ID="Label27" runat="server" Text="Category"></asp:Label>
                                    <asp:DropDownList ID="ddlIncWithCategory" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <asp:Label ID="Label28" runat="server" Text="Department"></asp:Label>
                                    <asp:DropDownList ID="ddlincWithProDepartment" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <asp:Label ID="Label29" runat="server" Text="Section"></asp:Label>
                                    <asp:DropDownList ID="ddlIncWithProSection" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <asp:Label ID="Label30" runat="server" Text="Line"></asp:Label>
                                    <asp:DropDownList ID="ddlIncWithProLine" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <asp:Label ID="Label31" runat="server" Text="Designation "></asp:Label>
                                    <asp:DropDownList ID="ddlIncWithDesignation" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <asp:Label ID="Label32" runat="server" Text="From Date"></asp:Label>
                                    <asp:DropDownList ID="ddlIncWithProFromDate" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <asp:Label ID="Label60" runat="server" Text="Inc. Type"></asp:Label>
                                    <asp:DropDownList ID="ddlIncWithProIncType" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <asp:Label ID="Label61" runat="server" Text="Inc. Value"></asp:Label>
                                    <asp:TextBox ID="txtIncWithProIncValue" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <asp:Label ID="Label62" runat="server" Text="Inc. With"></asp:Label>
                                    <asp:DropDownList ID="ddlIncWithProIncWith" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <asp:Label ID="Label63" runat="server" Text="Inc. Effective"></asp:Label>
                                    <asp:DropDownList ID="ddlIncWithProIncEffective" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <asp:Label ID="Label33" runat="server" Text="Pro Designation"></asp:Label>
                                    <asp:DropDownList ID="ddlIncWithProDesignation" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <asp:Label ID="Label34" runat="server" Text="Pro Category"></asp:Label>
                                    <asp:DropDownList ID="ddlIncWithProCategory" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <asp:Label ID="Label35" runat="server" Text="Pro Department"></asp:Label>
                                    <asp:DropDownList ID="ddlIncWithDepartment" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <asp:Label ID="Label36" runat="server" Text="Pro Section"></asp:Label>
                                    <asp:DropDownList ID="ddlIncWithSection" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:DropDownList>
                                </div>
                            </div>



                            <!-- btn -->
                            <div class="space-x-4 flex justify-between items-center my-4">
                                <div class="flex items-center gap-3 cursor-pointer">
                                    <asp:Button ID="btnIncWithProRefresh" runat="server" Text="Refresh" CssClass="rounded bg-[#64748B] text-white px-4 py-1 shadow-sm hover:bg-[#475569] transition delay-150 duration-300 ease-in-out" />

                                    <div class="flex items-center gap-1">
                                        <asp:CheckBox ID="chkIncWithProIsActive" runat="server" CssClass="cursor-pointer accent-[#198754]" />
                                        <asp:Label for="chkIncWithProIsActive" AssociatedControlID="chkIncWithProIsActive" runat="server" Text="Is Active?" CssClass="cursor-pointer"></asp:Label>
                                    </div>
                                </div>
                                <div class="flex gap-3">
                                    <asp:Button ID="btnIncWithShow" runat="server" Text="Show" CssClass="rounded bg-[#2563EB] text-white px-4 py-1 shadow-sm hover:bg-[#1D4ED8] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                                    <asp:Button ID="btnIncWithProViewPending" runat="server" Text="View Pending" CssClass="rounded bg-[#10B981] text-white px-4 py-1 shadow-sm hover:bg-[#059669] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                                    <asp:Button ID="BtnIncWithProExportTo" runat="server" Text="Export To" CssClass="rounded bg-[#14B8A6] text-white px-4 py-1 shadow-sm hover:bg-[#059669] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                                    <asp:Button ID="btnIncWithProPrintView" runat="server" Text="Print View" CssClass="rounded bg-[#F97316] text-white px-4 py-1 shadow-sm hover:bg-[#EA580C] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                                    <asp:Button ID="btnIncWithProSave" runat="server" Text="Save" CssClass="rounded bg-[#8B5CF6] text-white px-4 py-1 shadow-sm hover:bg-[#7C3AED] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                                    <asp:Button ID="btnIncWithProClear" runat="server" Text="Clear" CssClass="rounded bg-[#EF4444] text-white px-4 py-1 shadow-sm hover:bg-[#DC2626] cursor-pointer transition delay-150 duration-300 ease-in-out" />
                                </div>
                            </div>
                        </div>

                        <!-- text grid increment with Promotion pgae -->
                        <div class="border border-gray-400 bg-gray-50 rounded w-full h-72 overflow-y-scroll">
                            <asp:GridView ID="incWithProGridView" runat="server"></asp:GridView>
                        </div>
                    </div>

                </div>
            </div>


        </div>

    </form>

    <script>

        const buttons = document.querySelectorAll(".tabs button");
        const pages = document.querySelectorAll(".page");
        const tabWrapper = document.querySelectorAll(".tab-wrapper");

        buttons.forEach(btn => {
            btn.addEventListener("click", function () {

                pages.forEach(p => {
                    p.classList.remove("active");
                });
                tabWrapper.forEach(w => {
                    w.classList.remove("bg-white");
                });
                buttons.forEach(b => {
                    b.classList.remove("bg-white");
                });

                const btnId = btn.dataset.page;

                document.getElementById(btnId).classList.add("active");
                btn.classList.add("bg-white");
            });

        });

        // initial show
        document.getElementById("increment").classList.add("active");


    </script>
</body>
</html>

