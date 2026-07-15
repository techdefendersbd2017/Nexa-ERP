<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StyleWiseBundlePartsMapping.aspx.cs" Inherits="Nexa_ERP.Production.Cutting.StyleWiseBundlePartsMapping" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Style Party Mapping</title>

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
                <p class="text-2xl mb-1">Style Party Mapping</p>
                <p class="">Label</p>
            </div>

            <div class="bg-[#f0f0f0] shadow-xl rounded-b-lg px-4 py-4">
                <asp:HiddenField ID="hfUserId" runat="server" />

                <%-- main container --%>
                <div class="grid grid-cols-12 space-y-3">

                    <%-- top input --%>
                    <div class="col-span-12">
                        <div class="flex flex-col flex-grow h-full">
                            <div class="grid grid-cols-4 space-x-3 items-end">
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="whitespace-nowrap">Style Mapping ID</label>
                                    <asp:TextBox ID="txtStylePartsMappingId" runat="server" ReadOnly="true" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Stle No</label>
                                    <asp:TextBox ID="txtStyleNo" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex items-center space-x-6 w-full">
                                    <div class="flex items-center gap-1 ml-3">
                                        <asp:CheckBox ID="chkIsPrint" runat="server" CssClass="cursor-pointer accent-[#198754]" />
                                        <asp:Label for="chkIsPrint" AssociatedControlID="chkIsPrint" runat="server" Text="Is Print" CssClass="cursor-pointer whitespace-nowrap"></asp:Label>
                                    </div>
                                    <div class="flex items-center gap-1">
                                        <asp:CheckBox ID="chkIsEmbroidery" runat="server" CssClass="cursor-pointer accent-[#198754]" />
                                        <asp:Label for="chkIsEmbroidery" AssociatedControlID="chkIsEmbroidery" runat="server" Text="Is Embroidery" CssClass="cursor-pointer whitespace-nowrap"></asp:Label>
                                    </div>
                                    <div class="flex items-center gap-1">
                                        <asp:CheckBox ID="chkIsSmoke" runat="server" CssClass="cursor-pointer accent-[#198754]" />
                                        <asp:Label for="chkIsSmoke" AssociatedControlID="chkIsSmoke" runat="server" Text="Is Smoke" CssClass="cursor-pointer whitespace-nowrap"></asp:Label>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>


                    <%-- left container --%>

                    <div class="border border-gray-400 rounded p-3 col-span-3 w-full overflow-y-auto">
                        <div class="flex flex-col space-y-1">
                            <div class="flex items-center space-x-1">
                                <div class="flex items-center">
                                    <div class="w-4 h-4 rounded border border-gray-700 flex justify-center items-center">
                                        <asp:Label ID="Label1" runat="server" class="text-sm" Text="+"></asp:Label>
                                    </div>
                                    <asp:Label ID="Label2" runat="server" Text="--"></asp:Label>
                                </div>
                                <asp:Label ID="Label3" runat="server" Text="CARNET"></asp:Label>
                            </div>
                            <div class="flex items-center space-x-1">
                                <div class="flex items-center">
                                    <div class="w-4 h-4 rounded border border-gray-700 flex justify-center items-center">
                                        <asp:Label ID="Label4" runat="server" class="text-sm" Text="+"></asp:Label>
                                    </div>
                                    <asp:Label ID="Label5" runat="server" Text="--"></asp:Label>
                                </div>
                                <asp:Label ID="Label6" runat="server" Text="CECIL"></asp:Label>
                            </div>
                            <div class="flex items-center space-x-1">
                                <div class="flex items-center">
                                    <div class="w-4 h-4 rounded border border-gray-700 flex justify-center items-center">
                                        <asp:Label ID="Label7" runat="server" class="text-sm" Text="+"></asp:Label>
                                    </div>
                                    <asp:Label ID="Label8" runat="server" Text="--"></asp:Label>
                                </div>
                                <asp:Label ID="Label9" runat="server" Text="COPENHAGEN TOURIST"></asp:Label>
                            </div>
                            <div class="flex items-center space-x-1">
                                <div class="flex items-center">
                                    <div class="w-4 h-4 rounded border border-gray-700 flex justify-center items-center">
                                        <asp:Label ID="Label50" runat="server" class="text-sm" Text="+"></asp:Label>
                                    </div>
                                    <asp:Label ID="Label10" runat="server" Text="--"></asp:Label>
                                </div>
                                <asp:Label ID="Label11" runat="server" Text="OUI"></asp:Label>
                            </div>
                            <div class="flex items-center space-x-1">
                                <div class="flex items-center">
                                    <div class="w-4 h-4 rounded border border-gray-700 flex justify-center items-center">
                                        <asp:Label ID="Label12" runat="server" class="text-sm" Text="+"></asp:Label>
                                    </div>
                                    <asp:Label ID="Label13" runat="server" Text="--"></asp:Label>
                                </div>
                                <asp:Label ID="Label14" runat="server" Text="PRE-END"></asp:Label>
                            </div>
                            <div class="flex items-center space-x-1">
                                <div class="flex items-center">
                                    <div class="w-4 h-4 rounded border border-gray-700 flex justify-center items-center">
                                        <asp:Label ID="Label15" runat="server" class="text-sm" Text="+"></asp:Label>
                                    </div>
                                    <asp:Label ID="Label16" runat="server" Text="--"></asp:Label>
                                </div>
                                <asp:Label ID="Label17" runat="server" Text="RENNER"></asp:Label>
                            </div>
                            <div class="flex items-center space-x-1">
                                <div class="flex items-center">
                                    <div class="w-4 h-4 rounded border border-gray-700 flex justify-center items-center">
                                        <asp:Label ID="Label18" runat="server" class="text-sm" Text="+"></asp:Label>
                                    </div>
                                    <asp:Label ID="Label19" runat="server" Text="--"></asp:Label>
                                </div>
                                <asp:Label ID="Label20" runat="server" Text="STREET ONE"></asp:Label>
                            </div>
                            <div class="flex items-center space-x-1">
                                <div class="flex items-center">
                                    <div class="w-4 h-4 rounded border border-gray-700 flex justify-center items-center">
                                        <asp:Label ID="Label60" runat="server" class="text-sm" Text="+"></asp:Label>
                                    </div>
                                    <asp:Label ID="Label21" runat="server" Text="--"></asp:Label>
                                </div>
                                <asp:Label ID="Label22" runat="server" Text="STREET ONE STUDIO"></asp:Label>
                            </div>
                            <div class="flex items-center space-x-1">
                                <div class="flex items-center">
                                    <div class="w-4 h-4 rounded border border-gray-700 flex justify-center items-center">
                                        <asp:Label ID="Label23" runat="server" class="text-sm" Text="+"></asp:Label>
                                    </div>
                                    <asp:Label ID="Label24" runat="server" Text="--"></asp:Label>
                                </div>
                                <asp:Label ID="Label25" runat="server" Text="TOM TAILOR"></asp:Label>
                            </div>
                            <div class="flex items-center space-x-1">
                                <div class="flex items-center">
                                    <div class="w-4 h-4 rounded border border-gray-700 flex justify-center items-center">
                                        <asp:Label ID="Label26" runat="server" class="text-sm" Text="+"></asp:Label>
                                    </div>
                                    <asp:Label ID="Label27" runat="server" Text="--"></asp:Label>
                                </div>
                                <asp:Label ID="Label28" runat="server" Text="ZERO"></asp:Label>
                            </div>
                        </div>
                    </div>

                    <%-- Right container --%>
                    <div class="col-span-9 ml-3 border border-gray-400 rounded overflow-y-auto overflow-x-auto">

                        <!-- tab list view 1st -->
                        <div class=" w-full flex-1 ">
                            <div class="tabs  flex">
                                <div class="tab-wrapper bg-white flex items-center">
                                    <button type="button" data-page="allParts" class="px-4 h-10 whitespace-nowrap">All Parts</button>
                                    <span class="w-0.5 h-10 bg-gray-500"></span>
                                </div>
                                <div class="tab-wrapper flex items-center">
                                    <button type="button" data-page="bundlingParts" class="px-4 h-10 whitespace-nowrap">Bundling Parts</button>
                                    <span class="w-0.5 h-10 bg-gray-500"></span>
                                </div>
                                <div class="tab-wrapper flex items-center">
                                    <button type="button" data-page="contrastBuildlingParts" class="px-4 h-10 whitespace-nowrap">Contrast Buildling Parts</button>
                                    <span class="w-0.5 h-10 bg-gray-500"></span>
                                </div>
                                <div class="tab-wrapper flex items-center">
                                    <button type="button" data-page="printParts" class="px-4 h-10 whitespace-nowrap">Print Parts</button>
                                    <span class="w-0.5 h-10 bg-gray-500"></span>
                                </div>
                                <div class="tab-wrapper flex items-center">
                                    <button type="button" data-page="embroideryParts" class="px-4 h-10 whitespace-nowrap">Embroidrry Parts</button>
                                    <span class="w-0.5 h-10 bg-gray-500"></span>
                                </div>
                                <div class="tab-wrapper flex items-center">
                                    <button type="button" data-page="smokeParts" class="px-4 h-10 whitespace-nowrap">Smoke Parts</button>
                                </div>
                            </div>
                        </div>

                        <%-- all parts --%>
                        <div class="page active" id="allParts">
                            <div class="p-2 pb-0 mb-4">
                                dfsgggggggggggg
                            </div>
                        </div>

                        <%-- bundling parts --%>
                        <div class="page" id="bundlingParts">
                            <div class="p-2 pb-0 mb-4">
                                aaaaaaaaaaaaaaaaaaaaaaaaaaaaa
                            </div>
                        </div>

                        <%-- contrast building parts --%>
                        <div class="page" id="contrastBuildlingParts">
                            <div class="p-2 pb-0 mb-4">
                                bbbbbbbbbbbbbbbbbbbbbbbbbbbb
                            </div>
                        </div>

                        <%-- print parts --%>
                        <div class="page" id="printParts">
                            <div class="p-2 pb-0 mb-4">
                                ccccccccccccccccccccccccccccccccccc
                            </div>
                        </div>

                        <%-- embroidery parts --%>
                        <div class="page" id="embroideryParts">
                            <div class="p-2 pb-0 mb-4">
                                ddddddddddddddddddddddddd
                            </div>
                        </div>

                        <%-- smoke parts --%>
                        <div class="page" id="smokeParts">
                            <div class="p-2 pb-0 mb-4">
                                eeeeeeeeeeeeeeeeeeeeeeeeeeeeee
                            </div>
                        </div>
                    </div>
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
                        <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="rounded bg-[#22C55E] text-white px-4 py-1 shadow-sm hover:bg-[#16A34A] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                        <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="rounded bg-[#E55353] text-white px-4 py-1 shadow-sm hover:bg-[#C93F3F] cursor-pointer transition delay-150 duration-300 ease-in-out" />


                        <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="rounded bg-[#64748B] text-white px-4 py-1 shadow-sm hover:bg-[#475569] cursor-pointer transition delay-150 duration-300 ease-in-out" />

                        <asp:Button ID="btnClose" runat="server" Text="Close" CssClass="rounded bg-[#E55353] text-white px-4 py-1 shadow-sm hover:bg-[#475569] cursor-pointer transition delay-150 duration-300 ease-in-out" />

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
        document.getElementById("allParts").classList.add("active");


    </script>
</body>
</html>


