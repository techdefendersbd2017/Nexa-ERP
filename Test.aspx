<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Test.aspx.cs" Inherits="Nexa_ERP.Test" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div>

            <asp:Panel ID="Panel1" runat="server">

                <div>
                    <asp:Button ID="Button1" runat="server" Text="Button" OnClick="Button1_Click" />
                    <asp:Label ID="Label1" runat="server" Text="Label"></asp:Label>

                    <b><p>This is text Page</p></b>
                    <asp:Button ID="Button3" runat="server" Text="Button" OnClick="Button3_Click" />
                </div>


            </asp:Panel>

                <asp:Panel ID="Panel2" runat="server">

                <div>
                    <asp:Button ID="Button2" runat="server" Text="Button" />
                    <asp:Label ID="Label2" runat="server" Text="Label"></asp:Label>

                    <b><p>This is text Page</p></b>
                </div>


            </asp:Panel>



        </div>
    </form>
</body>
</html>
