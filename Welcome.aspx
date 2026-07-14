<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Welcome.aspx.cs" Inherits="Nexa_ERP.Welcome" %>


<!DOCTYPE html>
<html>
<head runat="server">
    <title>Nexa ERP</title>
        <!-- Bootstrap -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    <style>
        .welcome-text {
            font-size: 50px;
            font-weight: bold;
            color: #0d6efd;
            text-align: center;
            margin-top: 60px;
            opacity: 0;
            animation: fadeIn 4s ease-in-out forwards;
        }

        @keyframes fadeIn {
            to { opacity: 1; }
        }
        @media print {

            body * {
                visibility: hidden;
            }

            #printArea, #printArea * {
                visibility: visible;
            }

            #printArea {
                position: absolute;
                left: 0;
                top: 0;
                width: 100%;
            }

        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:Panel ID="PanelwelcomeText" runat="server">            
            <div class="welcome-text" id="welcomeText"></div>
        </asp:Panel>

        <asp:Panel ID="PanelWorkProgress" runat="server">
            <div class="container mt-4">
                <div class="card shadow-sm">
        
                    <!-- Card Header -->
                    <div class="card-header bg-primary text-white fw-bold">
                        <i class="fas fa-tasks me-2"></i> Work Progress List
                    </div>

                    <!-- Card Body -->
                    <div class="card-body">

                        <div class="table-responsive">
                            <div id="printArea">
                            <asp:GridView ID="gvWorkProgress" runat="server"
                                CssClass="table table-bordered table-hover table-striped table-sm align-middle text-center"
                                AutoGenerateColumns="False"
                                DataKeyNames="Form_ID"
                                HeaderStyle-CssClass="table-dark"
                                EmptyDataText="No Work Progress Data Found"
                                AllowPaging="true"
                                PageSize="10"
                                OnPageIndexChanging="gvWorkProgress_PageIndexChanging">
                                <Columns>

                                    <asp:TemplateField HeaderText="SL">
                                        <ItemTemplate>
                                            <%# Container.DataItemIndex + 1 %>
                                        </ItemTemplate>
                                    </asp:TemplateField>


                                    <asp:BoundField DataField="Form_ID" HeaderText="Form ID" />


                                    <asp:BoundField DataField="Form_Name" HeaderText="Branch Name" />

                                    <asp:TemplateField HeaderText="Working Stage">
                                        <ItemTemplate>
                                            <span class='badge 
                                                <%# Eval("WorkingStage").ToString() == "Pending" ? "bg-warning text-dark" :
                                                    Eval("WorkingStage").ToString() == "Working" ? "bg-primary" :
                                                    Eval("WorkingStage").ToString() == "Complete" ? "bg-success" :
                                                    "bg-secondary" %>'>
                                                <%# Eval("WorkingStage") %>
                                            </span>
                                        </ItemTemplate>

                                        <EditItemTemplate>
                                            <asp:DropDownList ID="ddlStage" runat="server" CssClass="form-select form-select-sm">
                                                <asp:ListItem Text="Pending" Value="Pending"></asp:ListItem>
                                                <asp:ListItem Text="On Working" Value="On Working"></asp:ListItem>
                                                <asp:ListItem Text="Complete" Value="Complete"></asp:ListItem>
                                            </asp:DropDownList>
                                        </EditItemTemplate>
                                    </asp:TemplateField>

                                    <asp:BoundField DataField="WorkUnder" HeaderText="UI Designer" />

                                </Columns>

                            </asp:GridView>
                                </div>
                        </div>
                        <asp:Button ID="btnExportPDF" runat="server" 
                        Text="Export To PDF" 
                        CssClass="btn btn-danger btn-sm"
                        OnClick="btnExportPDF_Click" />
                    </div>
                </div>
            </div>
        </asp:Panel>
    </form>

    <script>
        const texts = [
            "Welcome to Nexa ERP",
            "Your Smart Business Solution",
            "Manage Everything with Nexa ERP"
        ];

        const element = document.getElementById("welcomeText");
        let textIndex = 0;
        let charIndex = 0;

        function typeEffect() {
            if (charIndex < texts[textIndex].length) {
                element.innerHTML += texts[textIndex].charAt(charIndex);
                charIndex++;
                setTimeout(typeEffect, 100);
            }
        }

        function changeText() {
            element.innerHTML = "";
            charIndex = 0;
            typeEffect();
        }

        // Initial load
        window.onload = () => {
            typeEffect();
            setInterval(() => {
                textIndex = (textIndex + 1) % texts.length;
                changeText();
            }, 10000); // 10 seconds
        };
    </script>
</body>
</html>