<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StyleWiseBodyPartsEntry.aspx.cs" Inherits="Nexa_ERP.Production.Cutting.StyleWiseBodyPartsEntry" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Style Party Entry</title>

    <!-- tailwind css link -->
    <script src="https://cdn.tailwindcss.com"></script>

</head>
<body>
    <form id="form1" runat="server" class="min-h-screen p-2 mt-2">
        <div class="max-w-[1320px] w-full m-auto rounded-lg border">

            <div class="bg-[#0d6efd] text-white rounded-t-lg px-4 py-2">
                <p class="text-2xl mb-1">Style Party Entry</p>
                <p class="">Label</p>
            </div>

            <div class="bg-[#f0f0f0] shadow-xl rounded-b-lg px-4 py-4">
                <asp:HiddenField ID="hfUserId" runat="server" />

                <%-- main container --%>
                <div class="grid grid-cols-7 space-x-3">
                    <%-- left container --%>
                    <div class="col-span-3">
                        <div class="flex flex-col flex-grow h-full">
                            <div class="flex flex-col gap-y-1">
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label class="whitespace-nowrap">Style Parts Entry ID</label>
                                    <asp:TextBox ID="txtStylePartsEntryId" runat="server" ReadOnly="true" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex flex-col gap-0.5 w-full">
                                    <label>Name</label>
                                    <asp:TextBox ID="txtName" runat="server" CssClass="w-full border rounded outline-none border-gray-300 px-2 h-7 focus:border-blue-500 shadow-sm transition delay-150 duration-150 ease-in-out"></asp:TextBox>
                                </div>
                                <div class="flex items-center gap-6 mt-3">
                                    <div class="flex items-center gap-1">
                                        <asp:CheckBox ID="chkIsPrint" runat="server" CssClass="cursor-pointer accent-[#198754]" />
                                        <asp:Label for="chkIsPrint" AssociatedControlID="chkIsPrint" runat="server" Text="Is Print" CssClass="cursor-pointer"></asp:Label>
                                    </div>
                                    <div class="flex items-center gap-1">
                                        <asp:CheckBox ID="chkIsEmbroidery" runat="server" CssClass="cursor-pointer accent-[#198754]" />
                                        <asp:Label for="chkIsEmbroidery" AssociatedControlID="chkIsEmbroidery" runat="server" Text="Is Embroidery" CssClass="cursor-pointer"></asp:Label>
                                    </div>
                                    <div class="flex items-center gap-1">
                                        <asp:CheckBox ID="chkIsSmoke" runat="server" CssClass="cursor-pointer accent-[#198754]" />
                                        <asp:Label for="chkIsSmoke" AssociatedControlID="chkIsSmoke" runat="server" Text="Is Smoke" CssClass="cursor-pointer"></asp:Label>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <%-- Right container --%>
                    <div class="col-span-4 mt-[26px]">

                        <!-- text list view 1st -->
                        <div class="border border-gray-400 bg-gray-300 rounded w-full h-96 flex-1 overflow-y-auto">
                            <asp:ListView ID="ListView1" runat="server"></asp:ListView>
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
</body>
</html>


