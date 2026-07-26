<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SheetNesting.aspx.cs" Inherits="Nexa_ERP.TrimsAccessories.SheetNesting" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Hantech Nesting Optimizer</title>

    <style>
        body {
            font-family: Segoe UI;
            background: #f5f5f5;
            margin:0;
        }

        .container {
            width:97%;
            margin:auto;
            margin-top:20px;
        }

        .mainRow{
            display:flex;
            align-items:flex-start;
            gap:20px;
            flex-wrap:wrap;
        }

        .leftCol{
            flex:0 0 560px;   /* আগে ছিল 460px */
            max-width:560px;  /* আগে ছিল 460px */
        }

        .rightCol{
            flex:1;
            min-width:320px;  /* আগে ছিল 420px */
        }

        .card {
            background:#fff;
            border-radius:8px;
            box-shadow:0 2px 8px #ccc;
            padding:20px;
            margin-bottom:20px;
        }

        .title{
            font-size:24px;
            font-weight:bold;
            color:#003366;
            margin-bottom:20px;
        }
table{
    width:100%;
    table-layout:fixed;
}

td{
    padding:6px;
}

td:nth-child(1), td:nth-child(3){
    width:110px;   /* লেবেল কলাম */
    white-space:nowrap;
    font-size:13px;
}

        input[type=text]{
            width:100%;
            height:35px;
            border:1px solid #ccc;
            border-radius:4px;
            padding-left:8px;
            box-sizing:border-box;
        }

        .inputWithUnit{
            display:flex;
            gap:6px;
        }

        .inputWithUnit .measureInput{
            flex:1;
            min-width:0;
        }

        .unitSelect{
            width:78px;
            height:35px;
            border:1px solid #ccc;
            border-radius:4px;
            background:#fff;
        }

        .btn{
            padding:10px 20px;
            border:none;
            color:white;
            cursor:pointer;
            border-radius:5px;
            font-weight:bold;
        }

        .calculate{
            background:#007bff;
        }

        .save{
            background:green;
        }

        .clear{
            background:red;
        }

        .result{
            font-size:18px;
            color:#003366;
            font-weight:bold;
        }

        #drawingArea{
            width:100%;
            height:600px;
            border:2px solid #333;
            background:#fafafa;
            overflow:auto;
            position:relative;
        }

        .sheetOutline{
            position:absolute;
            border:2px solid #333;
            background:#ffffff;
        }

        .wasteMargin{
            position:absolute;
            background:repeating-linear-gradient(45deg,#e0e0e0,#e0e0e0 6px,#f2f2f2 6px,#f2f2f2 12px);
            border:1px dashed #999;
        }

        .piece{
            position:absolute;
            border:1px solid #1b5e20;
            background:#4CAF50;
            text-align:center;
            font-size:9px;
            line-height:1.3;
            color:white;
            overflow:hidden;
            box-sizing:border-box;
        }

        .rotate{
            background:#ff9800;
            border:1px solid #e65100;
        }

        .legend{
            margin-top:10px;
            font-size:13px;
        }

        .legendItem{
            display:inline-flex;
            align-items:center;
            margin-right:20px;
        }

        .legendItem .swatch{
            display:inline-block;
            width:14px;
            height:14px;
            margin-right:5px;
            border:1px solid #444;
            flex-shrink:0;
        }

        @media (max-width: 950px){
            .leftCol{
                flex:1 1 100%;
                max-width:100%;
            }
        }
    </style>

</head>

<body>

<form id="form1" runat="server">

<div class="container">

<div class="mainRow">

    <!-- ================= LEFT COLUMN ================= -->
    <div class="leftCol">

        <div class="card">

            <div class="title">
            Hantech Nesting Optimizer
            </div>

            <table>

            <tr>
                <td>Sheet Length</td>
                <td>
                    <div class="inputWithUnit">
                        <asp:TextBox ID="txtSheetLength" runat="server" CssClass="measureInput"></asp:TextBox>
                        <asp:DropDownList ID="ddlUnitSheetLength" runat="server" CssClass="unitSelect">
                            <asp:ListItem Text="Inch" Value="inch" Selected="True" />
                            <asp:ListItem Text="CM" Value="cm" />
                            <asp:ListItem Text="MM" Value="mm" />
                        </asp:DropDownList>
                    </div>
                </td>
                <td>Sheet Width</td>
                <td>
                    <div class="inputWithUnit">
                        <asp:TextBox ID="txtSheetWidth" runat="server" CssClass="measureInput"></asp:TextBox>
                        <asp:DropDownList ID="ddlUnitSheetWidth" runat="server" CssClass="unitSelect">
                            <asp:ListItem Text="Inch" Value="inch" Selected="True" />
                            <asp:ListItem Text="CM" Value="cm" />
                            <asp:ListItem Text="MM" Value="mm" />
                        </asp:DropDownList>
                    </div>
                </td>
            </tr>

            <tr>
                <td>Waste Top</td>
                <td>
                    <div class="inputWithUnit">
                        <asp:TextBox ID="txtWasteTop" runat="server" CssClass="measureInput" Text="0"></asp:TextBox>
                        <asp:DropDownList ID="ddlUnitWasteTop" runat="server" CssClass="unitSelect">
                            <asp:ListItem Text="CM" Value="cm" Selected="True" />
                            <asp:ListItem Text="Inch" Value="inch" />
                            <asp:ListItem Text="MM" Value="mm" />
                        </asp:DropDownList>
                    </div>
                </td>
                <td>Waste Bottom</td>
                <td>
                    <div class="inputWithUnit">
                        <asp:TextBox ID="txtWasteBottom" runat="server" CssClass="measureInput" Text="0"></asp:TextBox>
                        <asp:DropDownList ID="ddlUnitWasteBottom" runat="server" CssClass="unitSelect">
                            <asp:ListItem Text="CM" Value="cm" Selected="True" />
                            <asp:ListItem Text="Inch" Value="inch" />
                            <asp:ListItem Text="MM" Value="mm" />
                        </asp:DropDownList>
                    </div>
                </td>
            </tr>

            <tr>
                <td>Waste Left</td>
                <td>
                    <div class="inputWithUnit">
                        <asp:TextBox ID="txtWasteLeft" runat="server" CssClass="measureInput" Text="0"></asp:TextBox>
                        <asp:DropDownList ID="ddlUnitWasteLeft" runat="server" CssClass="unitSelect">
                            <asp:ListItem Text="CM" Value="cm" Selected="True" />
                            <asp:ListItem Text="Inch" Value="inch" />
                            <asp:ListItem Text="MM" Value="mm" />
                        </asp:DropDownList>
                    </div>
                </td>
                <td>Waste Right</td>
                <td>
                    <div class="inputWithUnit">
                        <asp:TextBox ID="txtWasteRight" runat="server" CssClass="measureInput" Text="0"></asp:TextBox>
                        <asp:DropDownList ID="ddlUnitWasteRight" runat="server" CssClass="unitSelect">
                            <asp:ListItem Text="CM" Value="cm" Selected="True" />
                            <asp:ListItem Text="Inch" Value="inch" />
                            <asp:ListItem Text="MM" Value="mm" />
                        </asp:DropDownList>
                    </div>
                </td>
            </tr>

            <tr>
                <td>Hantech Length</td>
                <td>
                    <div class="inputWithUnit">
                        <asp:TextBox ID="txtLength" runat="server" CssClass="measureInput"></asp:TextBox>
                        <asp:DropDownList ID="ddlUnitLength" runat="server" CssClass="unitSelect">
                            <asp:ListItem Text="Inch" Value="inch" Selected="True" />
                            <asp:ListItem Text="CM" Value="cm" />
                            <asp:ListItem Text="MM" Value="mm" />
                        </asp:DropDownList>
                    </div>
                </td>
                <td>Hantech Width</td>
                <td>
                    <div class="inputWithUnit">
                        <asp:TextBox ID="txtWidth" runat="server" CssClass="measureInput"></asp:TextBox>
                        <asp:DropDownList ID="ddlUnitWidth" runat="server" CssClass="unitSelect">
                            <asp:ListItem Text="Inch" Value="inch" Selected="True" />
                            <asp:ListItem Text="CM" Value="cm" />
                            <asp:ListItem Text="MM" Value="mm" />
                        </asp:DropDownList>
                    </div>
                </td>
            </tr>

            <tr>
                <td>Gap</td>
                <td>
                    <div class="inputWithUnit">
                        <asp:TextBox ID="txtGap" runat="server" CssClass="measureInput" Text="0"></asp:TextBox>
                        <asp:DropDownList ID="ddlUnitGap" runat="server" CssClass="unitSelect">
                            <asp:ListItem Text="Inch" Value="inch" Selected="True" />
                            <asp:ListItem Text="CM" Value="cm" />
                            <asp:ListItem Text="MM" Value="mm" />
                        </asp:DropDownList>
                    </div>
                </td>
                <td>Rotate Allow</td>
                <td>
                    <asp:CheckBox ID="chkRotate" runat="server" Checked="true"/>
                </td>
            </tr>

            </table>

            <br />

            <asp:Button ID="btnCalculate"
            runat="server"
            Text="Calculate"
            CssClass="btn calculate"
            OnClick="btnCalculate_Click"/>

            <asp:Button ID="btnSave"
            runat="server"
            Text="Save"
            CssClass="btn save" OnClick="btnSave_Click"/>

            <asp:Button ID="btnClear"
            runat="server"
            Text="Clear"
            CssClass="btn clear" OnClick="btnClear_Click"/>

            <br /><br />

            <asp:Label ID="lblMessage" runat="server" CssClass="result" ForeColor="Red"></asp:Label>

        </div>

        <div class="card">

            <div class="title">
            Calculation Result
            </div>

            <table>

            <tr>
                <td>Normal Qty</td>
                <td>
                    <asp:Label ID="lblNormalQty" runat="server" CssClass="result"/>
                </td>
                <td>Rotate Qty</td>
                <td>
                    <asp:Label ID="lblRotateQty" runat="server" CssClass="result"/>
                </td>
            </tr>

            <tr>
                <td>Total Qty</td>
                <td>
                    <asp:Label ID="lblTotalQty" runat="server" CssClass="result"/>
                </td>
                <td>Utilization %</td>
                <td>
                    <asp:Label ID="lblUtilization" runat="server" CssClass="result"/>
                </td>
            </tr>

            </table>

        </div>

    </div>

    <!-- ================= RIGHT COLUMN ================= -->
    <div class="rightCol">

        <div class="card">

            <div class="title">
            Nesting Preview
            </div>

            <asp:Panel ID="drawingArea"
            runat="server">

            </asp:Panel>

            <div class="legend">
            <span class="legendItem"><span class="swatch" style="background:#ffffff;border:2px solid #333;"></span>Sheet</span>
            <span class="legendItem"><span class="swatch" style="background:repeating-linear-gradient(45deg,#e0e0e0,#e0e0e0 6px,#f2f2f2 6px,#f2f2f2 12px);"></span>Waste Margin</span>
            <span class="legendItem"><span class="swatch" style="background:#4CAF50;"></span>Normal Piece</span>
            <span class="legendItem"><span class="swatch" style="background:#ff9800;"></span>Rotated Piece</span>
            </div>

        </div>

    </div>

</div>

</div>

</form>

</body>
</html>
