<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="YarnCountInformation.aspx.cs" Inherits="Nexa_ERP.MerchandisingMarketing.MerchandisingConfiguration.YarnCountInformation" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>Create Yarn Count</title>

    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>

</head>

<body>
    <form id="form" runat="server" class="p-2">
        <!-- Outer Card -->
        <div class="bg-white border border-gray-300 rounded-xl shadow-md overflow-hidden max-w-full mx-auto">

            <!-- Header -->
            <div class="bg-[#0d6efd] text-white px-6 py-1">
                <h1 class="text-2xl mb-2">Create Yarn Count</h1>
                <asp:Label ID="Label5" runat="server" Text="Label" CssClass="ml-1"></asp:Label>
            </div>

            <!-- Body -->
            <div class="p-6 space-y-6">

                <!-- Top Part -->
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div>
                        <asp:Label ID="Label1" runat="server" Text="Yarn Count ID" CssClass="block mb-1"></asp:Label>
                        <asp:TextBox ID="txtdepartmentID" runat="server" ReadOnly="True"
                            CssClass="border border-gray-400 h-10 px-4 outline-none w-full rounded bg-white focus:border-blue-500 transition"></asp:TextBox>
                    </div>

                    <div>
                        <asp:Label ID="Label2" runat="server" Text="Count Number" CssClass="block  mb-1"></asp:Label>
                        <asp:TextBox ID="txtcountNumber" runat="server" TextMode="Number"
                            CssClass="border border-gray-400 h-10 px-4 outline-none w-full rounded bg-white focus:border-blue-500 transition"></asp:TextBox>
                    </div>
                </div>

                <!-- Middle Part -->
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div>
                        <asp:Label ID="Label3" runat="server" Text="Count System" CssClass="block mb-1">Count System</asp:Label>
                        <asp:DropDownList ID="ddlcountSystem" runat="server" CssClass="border border-gray-400 h-10 px-4 outline-none w-full rounded bg-white focus:border-blue-500 transition">
                        </asp:DropDownList>
                    </div>

                    <div>
                        <asp:Label ID="Label4" runat="server" Text="Count Value" CssClass="block mb-1">Count Value</asp:Label>
                        <asp:TextBox ID="txtcountValue" runat="server" TextMode="Number" Text="0" CssClass="border border-gray-400 h-10 px-4 outline-none w-full rounded bg-white focus:border-blue-500 transition"></asp:TextBox>
                    </div>
                </div>

                <!-- Bottom Part -->
                <div class="flex flex-col md:flex-row justify-between items-center mt-4 gap-4">
                    <!-- Left Checkboxes -->
                    <div class="flex items-center gap-6">
                        <div class="flex items-center space-x-2"> 
                            <asp:CheckBox ID="CheckBox" runat="server"/> 
                            <asp:Label ID="ckbisSingle" runat="server" Text="Label" CssClass= "mx-1">Is Single?</asp:Label> 
                        </div> 
                        <div class="flex items-center space-x-2"> 
                            <asp:CheckBox ID="CheckBox4" runat="server"/> 
                            <asp:Label ID="ckbisActive" runat="server" Text="Label" CssClass=" mx-1">Is Active?</asp:Label> 
                        </div>

                    </div>

                    <!-- Right Buttons -->
                    <div class="flex gap-3">
                        <asp:Button ID="btnsave" runat="server" Text="Save"
                            CssClass="bg-green-600 hover:bg-green-700 text-white h-10 w-24 rounded shadow-sm transition duration-200 cursor-pointer"/>

                        <asp:Button ID="btnclear" runat="server" Text="Clear"
                            CssClass="bg-gray-500 hover:bg-gray-600 text-white h-10 w-24 rounded shadow-sm transition duration-200 cursor-pointer"/>
                    </div>
                </div>

            </div>
        </div>
    </form>
</body>
</html>