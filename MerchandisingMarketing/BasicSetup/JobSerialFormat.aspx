<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="JobSerialFormat.aspx.cs" Inherits="Nexa_ERP.MerchandisingMarketing.BasicSetup.JobSerialFormat" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Job Serial Format</title>

    <!-- tailwind css link -->
    <script src="https://cdn.tailwindcss.com"></script>

    <!-- icon link -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/7.3.1/css/all.min.css" />

</head>
<body>
    <form id="form1" runat="server" class="min-h-screen p-2 mt-2">
        <div class="max-w-[1320px] w-full m-auto rounded-lg border">

            <div class="bg-[#255C8C] flex justify-center items-center rounded-t-lg px-4 py-2">
                <p class="text-white text-xl font-medium">Job Serial Format</p>
            </div>
            <div class="bg-[#ffffff] shadow-xl rounded-b-lg p-4">
                <asp:HiddenField ID="hfUserId" runat="server" />

                <%-- Job Serial Format box : centered --%>
                <div class="flex justify-center">
                    <div class="w-full max-w-3xl bg-[#FBFCFE] p-3 rounded border border-gray-400">
                        <p class="text-base font-semibold border-b border-gray-300 pb-2 mb-2">Job Serial Format</p>

                        <div class="border border-gray-300 rounded overflow-hidden">
                            <table class="w-full text-sm">
                                <thead>
                                    <tr class="bg-gray-100">
                                        <th class="text-left font-semibold px-3 py-2 border-b border-gray-300">Pattern Name</th>
                                        <th class="text-center font-semibold px-3 py-2 border-b border-l border-gray-300 w-32">Active</th>
                                        <th class="text-center font-semibold px-3 py-2 border-b border-l border-gray-300 w-32">Same For PO</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr class="border-b border-gray-200">
                                        <td class="px-3 py-2"><span class="font-semibold">Pattern-1:</span> Factory Prefix-Year Prefix-000001</td>
                                        <td class="text-center px-3 py-2 border-l border-gray-200">
                                            <asp:RadioButton ID="rbActive1" runat="server" GroupName="ActivePattern" />
                                        </td>
                                        <td class="text-center px-3 py-2 border-l border-gray-200">
                                            <asp:RadioButton ID="rbSameForPO1" runat="server" GroupName="SameForPOPattern" />
                                        </td>
                                    </tr>
                                    <tr class="border-b border-gray-200">
                                        <td class="px-3 py-2"><span class="font-semibold">Pattern-2:</span> Factory Prefix-Buyer Code-0001/Year Prefix</td>
                                        <td class="text-center px-3 py-2 border-l border-gray-200">
                                            <asp:RadioButton ID="rbActive2" runat="server" GroupName="ActivePattern" />
                                        </td>
                                        <td class="text-center px-3 py-2 border-l border-gray-200">
                                            <asp:RadioButton ID="rbSameForPO2" runat="server" GroupName="SameForPOPattern" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="px-3 py-2"><span class="font-semibold">Pattern-3:</span> Writeable</td>
                                        <td class="text-center px-3 py-2 border-l border-gray-200">
                                            <asp:RadioButton ID="rbActive3" runat="server" GroupName="ActivePattern" />
                                        </td>
                                        <td class="text-center px-3 py-2 border-l border-gray-200">
                                            <asp:RadioButton ID="rbSameForPO3" runat="server" GroupName="SameForPOPattern" />
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>

                        <div class="flex justify-end mt-3">
                            <asp:LinkButton ID="btnUpdate" runat="server" OnClick="btnUpdate_Click" CssClass="flex items-center gap-1.5 rounded bg-[#255C8C] text-white px-6 py-1.5 shadow-sm hover:bg-[#1a4569] cursor-pointer transition duration-200 ease-in-out font-medium text-sm no-underline justify-center">
                                <span>Update</span>
                            </asp:LinkButton>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </form>
</body>
</html>
