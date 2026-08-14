<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ProductionTargetReport.aspx.cs" Inherits="Nexa_ERP.TrimsAccessories.TrimsProduction.ProductionReport.ProductionTargetReport" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <title>Daily Production Target Report</title>
    <!-- Bootstrap 5 CSS CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <!-- FontAwesome for Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" />
    <style>
        body {
            background-color: #f8f9fa;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        .report-container {
            background: #fff;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 0 15px rgba(0,0,0,0.05);
            max-width: 1100px;
            margin: 30px auto;
        }
        .company-logo {
            max-height: 70px;
        }
        @media print {
            body {
                background-color: #fff;
            }
            .report-container {
                box-shadow: none;
                margin: 0;
                padding: 10px;
                max-width: 100%;
            }
            .no-print {
                display: none !important;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <div class="report-container">
                
                <!-- Header Section -->
                <div class="row border-bottom pb-3 mb-4 align-items-center">
                    <div class="col-3 text-start">
                        <asp:Image ID="imgLogo" runat="server" CssClass="company-logo" Visible="false" />
                    </div>
                    <div class="col-6 text-center">
                        <h3 class="fw-bold mb-1 text-dark"><asp:Label ID="lblBranchName" runat="server" Text="Company Name"></asp:Label></h3>
                        <p class="text-muted small mb-1"><asp:Label ID="lblAddress" runat="server" Text="Factory Address"></asp:Label></p>
                        <p class="text-muted small mb-0">Phone: <asp:Label ID="lblPhone" runat="server" Text=""></asp:Label> | Web: <asp:Label ID="lblWeb" runat="server" Text=""></asp:Label></p>
                    </div>
                    <div class="col-3 text-end">
                        <span class="badge bg-primary fs-6">Target Report</span>
                    </div>
                </div>

                <!-- Report Title -->
                <div class="text-center mb-4">
                    <h5 class="text-uppercase fw-bold text-secondary">Daily Production Target Sheet</h5>
                    <p class="text-muted small">Target Date: <asp:Label ID="lblTargetDate" runat="server" Text="Label"></asp:Label></p>
                </div>

                <!-- Item-wise Target Grid/Table Section -->
                <div class="row mb-4">
                    <div class="col-12">
                        <div class="table-responsive">
                            <asp:GridView ID="gvProductionTarget" runat="server" AutoGenerateColumns="False" CssClass="table table-bordered table-striped table-sm align-middle">
                                <Columns>
                                    <asp:BoundField DataField="TargetID" HeaderText="Target ID" />
                                    <asp:BoundField DataField="Floor_Name" HeaderText="Floor" />
                                    <asp:BoundField DataField="CategoryName" HeaderText="Category" />
                                    <asp:BoundField DataField="ItemName" HeaderText="Item Name" ItemStyle-CssClass="fw-bold text-primary" />
                                    <asp:BoundField DataField="Operator" HeaderText="Operator" />
                                    <asp:BoundField DataField="Helper" HeaderText="Helper" />
                                    <asp:BoundField DataField="WorkingHours" HeaderText="Work Hrs" />
                                    <asp:BoundField DataField="PerHourTarget" HeaderText="Per Hour" />
                                    <asp:BoundField DataField="SMV" HeaderText="SMV" />
                                    <asp:BoundField DataField="Efficiency" HeaderText="Eff(%)" />
                                    <asp:BoundField DataField="TotalHours" HeaderText="Tot.Hrs" />
                                    <asp:BoundField DataField="TotalTargetQty" HeaderText="Target Qty" ItemStyle-CssClass="fw-bold text-danger" />
                                    <asp:BoundField DataField="TargetRemarks" HeaderText="Remarks" />
                                </Columns>
                            </asp:GridView>
                        </div>
                    </div>
                </div>

                <!-- Highlight Summary Box (Total Sum of Date) -->
                <div class="row mb-4">
                    <div class="col-12">
                        <div class="p-3 bg-light border rounded d-flex justify-content-around text-center">
                            <div>
                                <span class="d-block text-muted small">Total Working Hours (Sum)</span>
                                <h4 class="fw-bold text-dark mb-0"><asp:Label ID="lblTotalHours" runat="server" Text="0" /></h4>
                            </div>
                            <div class="vr"></div>
                            <div>
                                <span class="d-block text-muted small">Total Target Quantity (Sum)</span>
                                <h4 class="fw-bold text-danger mb-0"><asp:Label ID="lblTotalTargetQty" runat="server" Text="0" /> Pcs</h4>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Action Buttons (Print / Close) -->
                <div class="text-center no-print mt-4">
                    <button type="button" onclick="window.print();" class="btn btn-success px-4 me-2">
                        <i class="fa-solid fa-print me-1"></i> Print Report
                    </button>
                    <button type="button" onclick="window.close();" class="btn btn-secondary px-4">
                        <i class="fa-solid fa-xmark me-1"></i> Close
                    </button>
                </div>

            </div>
        </div>
    </form>
</body>
</html>