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
        h2 { font-size:17px; margin:0 0 4px; }
        .sub { color:#6b7385; margin:0 0 20px; font-size:14px; }
        .card { background:#fff; border:1px solid #e3e7ef; border-radius:12px; padding:16px; margin-bottom:16px; }
        .bar { display:flex; flex-wrap:wrap; gap:12px; align-items:flex-end; }
        .field { display:flex; flex-direction:column; gap:4px; }
        .field label { font-size:12px; color:#6b7385; font-weight:600; text-transform:uppercase; letter-spacing:.04em; }
        .ctl { height:40px; padding:0 12px; border:1px solid #d5dbe8; border-radius:8px; font:inherit; background:#fff; min-width:260px; }
        .btn { height:40px; padding:0 22px; border:0; border-radius:8px; background:#2f6fed; color:#fff; font:inherit; font-weight:600; cursor:pointer; }
        .btn:hover { background:#2459c7; }
        .btn.gray { background:#5b6478; } .btn.gray:hover { background:#454d5f; }
        .btn.red { background:#d64545; } .btn.red:hover { background:#b53030; }
        .meta { margin:16px 0 8px; color:#6b7385; font-size:13px; }
        .err { color:#c0392b; margin-top:12px; display:block; }
        .ok { color:#1e8449; margin:10px 0; display:block; font-weight:600; }
        .warn { color:#b9770e; margin:6px 0; display:block; }
        .grid-box { overflow:auto; max-height:65vh; border:1px solid #e3e7ef; border-radius:10px; }
        .grid { border-collapse:collapse; width:100%; font-size:14px; }
        .grid th, .grid td { padding:9px 12px; text-align:left; border-bottom:1px solid #e3e7ef; white-space:nowrap; }
        .grid th { position:sticky; top:0; background:#eef2fb; font-weight:600; }
        .grid tr:hover td { background:#f7f9fe; }
        .empty { padding:40px 16px; text-align:center; color:#6b7385; }
        .cols { margin:10px 0 14px; }
        .cols td { padding:2px 18px 2px 0; }
        .cols label { margin-left:4px; }
        .bj { font-family:SutonnyMJ, "Segoe UI", Arial, sans-serif; font-size:16px; }
        .note { font-size:13px; color:#6b7385; margin:0 0 8px; }
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

                <asp:Panel ID="pnlGrid" runat="server" CssClass="grid-box" Visible="false">
                    <asp:GridView ID="gvData" runat="server" CssClass="grid" GridLines="None"
                        AutoGenerateColumns="true" EnableViewState="false"
                        EmptyDataText="কোনো ডাটা পাওয়া যায়নি।" EmptyDataRowStyle-CssClass="empty">
                    </asp:GridView>
                </asp:Panel>
            </div>

            <!-- বিজয় -> ইউনিকোড কনভার্ট প্যানেল -->
            <asp:Panel ID="pnlConvert" runat="server" CssClass="card" Visible="false">
                <h2>বিজয় → ইউনিকোড রূপান্তর</h2>
                <p class="note">যে কলামগুলো কনভার্ট করতে চান টিক দিন। আগে Preview দেখে নিন, তারপর Update করুন।
                    (ইংরেজি/নম্বর মেশানো কলাম কনভার্ট করলে সেগুলোও বাংলা হয়ে যাবে — তাই শুধু বিজয় ডাটার কলাম সিলেক্ট করুন।)</p>
                <asp:Label ID="lblPkInfo" runat="server" CssClass="note"></asp:Label>

                <asp:CheckBoxList ID="cblColumns" runat="server" CssClass="cols"
                    RepeatLayout="Table" RepeatDirection="Horizontal" RepeatColumns="4"></asp:CheckBoxList>

                <div class="bar">
                    <asp:Button ID="btnPreview" runat="server" Text="Preview (ডাটাবেসে পরিবর্তন হবে না)" CssClass="btn gray" OnClick="btnPreview_Click" />
                    <asp:Button ID="btnUpdate" runat="server" Text="Database এ Update করুন" CssClass="btn red" OnClick="btnUpdate_Click"
                        OnClientClick="return confirm('সিলেক্ট করা কলামের আগের ডাটা ডাটাবেসে স্থায়ীভাবে বদলে যাবে।\nব্যাকআপ নিয়েছেন? চালিয়ে যাবেন?');" />
                    <asp:CheckBox ID="chkForce" runat="server" Text="অরূপান্তরিত চিহ্ন থাকলেও Update করুন" />
                </div>

                <asp:Label ID="lblMsg" runat="server" CssClass="ok"></asp:Label>
                <asp:Label ID="lblWarn" runat="server" CssClass="warn"></asp:Label>

                <asp:Panel ID="pnlPreview" runat="server" CssClass="grid-box" Visible="false">
                    <asp:GridView ID="gvPreview" runat="server" CssClass="grid" GridLines="None" AutoGenerateColumns="false"
                        EnableViewState="false" EmptyDataText="কোনো পরিবর্তনযোগ্য ডাটা পাওয়া যায়নি।" EmptyDataRowStyle-CssClass="empty">
                        <Columns>
                            <asp:BoundField DataField="Row" HeaderText="Row (Key)" />
                            <asp:BoundField DataField="Column" HeaderText="Column" />
                            <asp:BoundField DataField="Before" HeaderText="আগে (Bijoy)" ItemStyle-CssClass="bj" />
                            <asp:BoundField DataField="After" HeaderText="পরে (Unicode)" />
                        </Columns>
                    </asp:GridView>
                </asp:Panel>
            </asp:Panel>
        </div>
    </form>
</body>
</html>
