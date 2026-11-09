<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TableViewer.aspx.cs" Inherits="Nexa_ERP.Tools.TableViewer" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Database Table Viewer</title>
    <style>
        body { margin:0; background:#f4f6fa; color:#1d2433; font:15px/1.5 "Segoe UI", "Noto Sans Bengali", Arial, sans-serif; }
        .wrap { max-width:1200px; margin:0 auto; padding:24px 16px; }
        h1 { font-size:22px; margin:0 0 4px; }
        .sub { color:#6b7385; margin:0 0 20px; font-size:14px; }
        .card { background:#fff; border:1px solid #e3e7ef; border-radius:12px; padding:16px; }
        .bar { display:flex; flex-wrap:wrap; gap:12px; align-items:flex-end; }
        .field { display:flex; flex-direction:column; gap:4px; }
        .field label { font-size:12px; color:#6b7385; font-weight:600; text-transform:uppercase; letter-spacing:.04em; }
        .ctl { height:40px; padding:0 12px; border:1px solid #d5dbe8; border-radius:8px; font:inherit; background:#fff; min-width:260px; }
        .ctl.small { min-width:110px; }
        .btn { height:40px; padding:0 22px; border:0; border-radius:8px; background:#2f6fed; color:#fff; font:inherit; font-weight:600; cursor:pointer; }
        .btn:hover { background:#2459c7; }
        .meta { margin:16px 0 8px; color:#6b7385; font-size:13px; }
        .err { color:#c0392b; margin-top:12px; display:block; }
        .grid-box { overflow:auto; max-height:65vh; border:1px solid #e3e7ef; border-radius:10px; }
        .grid { border-collapse:collapse; width:100%; font-size:14px; }
        .grid th, .grid td { padding:9px 12px; text-align:left; border-bottom:1px solid #e3e7ef; white-space:nowrap; }
        .grid th { position:sticky; top:0; background:#eef2fb; font-weight:600; }
        .grid tr:hover td { background:#f7f9fe; }
        .empty { padding:40px 16px; text-align:center; color:#6b7385; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="wrap">
            <h1>Database Table Viewer</h1>
            <p class="sub">টেবিল সিলেক্ট করুন, তারপর Load Data চাপুন।</p>

            <div class="card">
                <div class="bar">
                    <div class="field">
                        <label for="ddlDatabase">Database</label>
                        <asp:DropDownList ID="ddlDatabase" runat="server" CssClass="ctl" AutoPostBack="true"
                            OnSelectedIndexChanged="ddlDatabase_SelectedIndexChanged">
                            <asp:ListItem Text="Accounts (nexa_acc)" Value="ACC" Selected="True" />
                            <asp:ListItem Text="Merchandising (NexaDBs)" Value="MER" />
                            <asp:ListItem Text="Payroll (Tech_Pay)" Value="PAY" />
                            <asp:ListItem Text="Master (NexaMaster)" Value="MST" />
                        </asp:DropDownList>
                    </div>
                    <div class="field">
                        <label for="ddlTables">Table</label>
                        <asp:DropDownList ID="ddlTables" runat="server" CssClass="ctl"></asp:DropDownList>
                    </div>
                    <asp:Button ID="btnLoad" runat="server" Text="Load Data" CssClass="btn" OnClick="btnLoad_Click" />
                </div>

                <asp:Label ID="lblError" runat="server" CssClass="err" Visible="false"></asp:Label>
                <div class="meta"><asp:Label ID="lblInfo" runat="server" Text="কোনো টেবিল লোড হয়নি"></asp:Label></div>

                <div class="grid-box">
                    <asp:GridView ID="gvData" runat="server" CssClass="grid" GridLines="None"
                        AutoGenerateColumns="true" EnableViewState="false"
                        EmptyDataText="কোনো ডাটা পাওয়া যায়নি।" EmptyDataRowStyle-CssClass="empty">
                    </asp:GridView>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
