<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PriceQuotationApproval.aspx.cs" Inherits="Nexa_ERP.Approval.TrimsAccessoriesApprovl.PriceQuotationApproval" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Price Quotation Approval Panel - Enterprise ERP</title>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <!-- FontAwesome Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" />
    
    <style>
        :root {
            --primary-color: #0f172a;
            --accent-color: #2563eb;
            --success-color: #16a34a;
            --danger-color: #dc2626;
            --warning-color: #d97706;
            --bg-light: #f8fafc;
        }
        body {
            background-color: var(--bg-light);
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            color: #334155;
        }
        .card {
            border: none;
            box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06);
            border-radius: 0.5rem;
            margin-bottom: 1.5rem;
        }
        .card-header {
            background-color: #fff;
            border-bottom: 1px solid #e2e8f0;
            font-weight: 600;
            padding: 1rem 1.25rem;
            border-top-left-radius: 0.5rem !important;
            border-top-right-radius: 0.5rem !important;
        }
        .badge-status {
            font-size: 0.85rem;
            padding: 0.5em 0.8em;
            font-weight: 500;
        }
        /* Custom Nav Link styling for ASP.NET LinkButtons */
        .nav-tabs .nav-link {
            color: #475569;
            border: 1px solid transparent;
            cursor: pointer;
        }
        .nav-tabs .nav-link:hover {
            border-color: #e2e8f0 #e2e8f0 #dee2e6;
            background-color: #f1f5f9;
        }
        .nav-tabs .nav-link.active {
            color: var(--accent-color) !important;
            background-color: #fff;
            border-color: #dee2e6 #dee2e6 #fff;
            font-weight: bold;
        }
        /* Timeline Design */
        .approval-timeline {
            position: relative;
            padding-left: 1.5rem;
            list-style: none;
        }
        .approval-timeline::before {
            content: '';
            position: absolute;
            left: 0.5rem;
            top: 0.25rem;
            bottom: 0.25rem;
            width: 2px;
            background-color: #e2e8f0;
        }
        .timeline-item {
            position: relative;
            margin-bottom: 1.25rem;
        }
        .timeline-indicator {
            position: absolute;
            left: -1.5rem;
            top: 0.15rem;
            width: 1rem;
            height: 1rem;
            border-radius: 50%;
            background-color: #cbd5e1;
            border: 2px solid #fff;
            text-align: center;
            line-height: 0.6rem;
            font-size: 0.5rem;
        }
        .timeline-item.completed .timeline-indicator {
            background-color: var(--success-color);
            color: #fff;
        }
        .timeline-item.current .timeline-indicator {
            background-color: var(--warning-color);
            box-shadow: 0 0 0 4px rgba(217, 119, 6, 0.2);
        }
        .table th {
            font-weight: 600;
            background-color: #f1f5f9;
            color: #475569;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container-fluid py-4 px-md-5">
            
            <!-- Page Header -->
            <div class="d-flex justify-content-between align-items-center mb-4">
                <div>
                    <h2 class="h3 mb-1 text-dark fw-bold"><i class="fas fa-file-invoice-dollar text-primary me-2"></i> Price Quotation Management</h2>
                    <p class="text-muted mb-0">Garments ERP - Quotation Entry, View & Approval Panel.</p>
                </div>
                <div>
                    <span class="text-muted small">Quotation No:</span>
                    <span class="fw-bold text-dark fs-5 ms-1">PQ-000125</span>
                    <span class="badge bg-warning badge-status ms-2">Pending Approval</span>
                </div>
            </div>

            <!-- Working Navigation Tabs using ASP.NET LinkButton -->
            <ul class="nav nav-tabs mb-4">
                <li class="nav-item">
                    <asp:LinkButton ID="btnTabGeneral" runat="server" CssClass="nav-link" OnClick="Tab_Click" CommandArgument="General">
                        <i class="fas fa-info-circle me-1"></i> General Information
                    </asp:LinkButton>
                </li>
                <li class="nav-item">
                    <asp:LinkButton ID="btnTabItemDetails" runat="server" CssClass="nav-link" OnClick="Tab_Click" CommandArgument="ItemDetails">
                        <i class="fas fa-boxes me-1"></i> Item Details
                    </asp:LinkButton>
                </li>
                <li class="nav-item">
                    <asp:LinkButton ID="btnTabCosting" runat="server" CssClass="nav-link" OnClick="Tab_Click" CommandArgument="Costing">
                        <i class="fas fa-calculator me-1"></i> Costing
                    </asp:LinkButton>
                </li>
                <li class="nav-item">
                    <asp:LinkButton ID="btnTabApproval" runat="server" CssClass="nav-link active" OnClick="Tab_Click" CommandArgument="Approval">
                        <i class="fas fa-check-double me-1"></i> Approval
                    </asp:LinkButton>
                </li>
                <li class="nav-item">
                    <asp:LinkButton ID="btnTabHistory" runat="server" CssClass="nav-link" OnClick="Tab_Click" CommandArgument="History">
                        <i class="fas fa-history me-1"></i> History
                    </asp:LinkButton>
                </li>
            </ul>

            <!-- MultiView to control Tab Contents -->
            <asp:MultiView ID="MainMultiView" runat="server" ActiveViewIndex="3">
                
                <!-- Tab 1: General Information View -->
                <asp:View ID="ViewGeneral" runat="server">
                    <div class="card">
                        <div class="card-header"><i class="fas fa-info-circle me-2 text-primary"></i> General Information</div>
                        <div class="card-body">
                            <div class="row g-3">
                                <div class="col-md-4">
                                    <label class="form-label text-muted">Customer / Buyer</label>
                                    <asp:TextBox ID="txtCustomer" runat="server" CssClass="form-control" Text="H&M Group" ReadOnly="true"></asp:TextBox>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label text-muted">Quotation Date</label>
                                    <asp:TextBox ID="txtDate" runat="server" CssClass="form-control" Text="10-Aug-2026" ReadOnly="true"></asp:TextBox>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label text-muted">Season</label>
                                    <asp:TextBox ID="txtSeason" runat="server" CssClass="form-control" Text="Summer 2026" ReadOnly="true"></asp:TextBox>
                                </div>
                            </div>
                        </div>
                    </div>
                </asp:View>

                <!-- Tab 2: Item Details View -->
                <asp:View ID="ViewItemDetails" runat="server">
                    <div class="card">
                        <div class="card-header"><i class="fas fa-boxes me-2 text-primary"></i> Style & Item Details</div>
                        <div class="card-body">
                            <table class="table table-bordered">
                                <thead>
                                    <tr>
                                        <th>Style No</th>
                                        <th>Item Description</th>
                                        <th>Order Qty (Pcs)</th>
                                        <th>Unit Price ($)</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td>HM-2026-991</td>
                                        <td>Mens Cotton Basic T-Shirt</td>
                                        <td>10,000</td>
                                        <td>$4.52</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </asp:View>

                <!-- Tab 3: Costing View -->
                <asp:View ID="ViewCosting" runat="server">
                    <div class="card">
                        <div class="card-header"><i class="fas fa-calculator me-2 text-primary"></i> Costing Breakdown</div>
                        <div class="card-body">
                            <p class="text-muted">Yarn Cost, Knitting, Dyeing, CM (Cost of Making), Accessories, and Profit Margin details go here.</p>
                            <span class="badge bg-success fs-6">Total Value: $45,200.00</span>
                        </div>
                    </div>
                </asp:View>

                <!-- Tab 4: Approval View (Main Panel) -->
                <asp:View ID="ViewApproval" runat="server">
                    <!-- Approval Summary Section -->
                    <div class="card mb-4">
                        <div class="card-body">
                            <div class="row g-3">
                                <div class="col-md-2">
                                    <span class="d-block text-muted small">Quotation Date</span>
                                    <span class="fw-semibold">10-Aug-2026</span>
                                </div>
                                <div class="col-md-2">
                                    <span class="d-block text-muted small">Customer / Buyer</span>
                                    <span class="fw-semibold">H&M Group</span>
                                </div>
                                <div class="col-md-2">
                                    <span class="d-block text-muted small">Style No</span>
                                    <span class="fw-semibold">HM-2026-991</span>
                                </div>
                                <div class="col-md-2">
                                    <span class="d-block text-muted small">PO No</span>
                                    <span class="fw-semibold">PO-883920</span>
                                </div>
                                <div class="col-md-2">
                                    <span class="d-block text-muted small">Total Value</span>
                                    <span class="fw-semibold text-success">$45,200.00</span>
                                </div>
                                <div class="col-md-2">
                                    <span class="d-block text-muted small">Submitted By</span>
                                    <span class="fw-semibold">Mr. Karim (Merch. Exe)</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Main Content Layout (Responsive Two-Column Grid) -->
                    <div class="row">
                        <!-- Left Column: Approval Timeline & History -->
                        <div class="col-lg-7">
                            <!-- Approval Progress Timeline -->
                            <div class="card">
                                <div class="card-header"><i class="fas fa-stream me-2 text-primary"></i> Approval Progress Workflow</div>
                                <div class="card-body">
                                    <ul class="approval-timeline">
                                        <li class="timeline-item completed">
                                            <div class="timeline-indicator"><i class="fas fa-check"></i></div>
                                            <div class="fw-semibold">Created & Submitted</div>
                                            <div class="small text-muted">Merchandising Executive (Mr. Karim) - 10-Aug-2026 09:20 AM</div>
                                        </li>
                                        <li class="timeline-item completed">
                                            <div class="timeline-indicator"><i class="fas fa-check"></i></div>
                                            <div class="fw-semibold">Merchandising Manager Level</div>
                                            <div class="small text-muted">Mr. Rahim - Approved on 10-Aug-2026 11:30 AM</div>
                                        </li>
                                        <li class="timeline-item current">
                                            <div class="timeline-indicator"></div>
                                            <div class="fw-semibold text-warning">General Manager Level (Current)</div>
                                            <div class="small text-muted">Waiting for Mr. Hasan - Since 10-Aug-2026 11:35 AM</div>
                                        </li>
                                        <li class="timeline-item">
                                            <div class="timeline-indicator"></div>
                                            <div class="fw-semibold text-muted">Final Approval / Managing Director</div>
                                            <div class="small text-muted">Pending next level</div>
                                        </li>
                                    </ul>
                                </div>
                            </div>
                        </div>

                        <!-- Right Column: Current Approval & Action Panel -->
                        <div class="col-lg-5">
                            <!-- Current Approval Status Box -->
                            <div class="card border-top border-warning border-4">
                                <div class="card-header"><i class="fas fa-user-clock me-2 text-warning"></i> Current Approval Status</div>
                                <div class="card-body">
                                    <div class="mb-3 d-flex justify-content-between">
                                        <span class="text-muted">Current Approval Level:</span>
                                        <span class="fw-bold">Level 3</span>
                                    </div>
                                    <div class="mb-3 d-flex justify-content-between">
                                        <span class="text-muted">Required Role:</span>
                                        <span class="fw-bold text-primary">General Manager</span>
                                    </div>
                                    <div class="mb-3 d-flex justify-content-between">
                                        <span class="text-muted">Current Approver:</span>
                                        <span class="fw-bold">Mr. Hasan</span>
                                    </div>
                                    <div class="mb-3 d-flex justify-content-between">
                                        <span class="text-muted">Waiting Since:</span>
                                        <span class="fw-semibold">10-Aug-2026 11:35 AM</span>
                                    </div>
                                    <div class="d-flex justify-content-between align-items-center">
                                        <span class="text-muted">Status:</span>
                                        <span class="badge bg-warning badge-status">Pending Approval</span>
                                    </div>
                                </div>
                            </div>

                            <!-- Action Panel -->
                            <asp:Panel ID="pnlApprovalActions" runat="server" CssClass="card bg-white">
                                <div class="card-header bg-light"><i class="fas fa-tasks me-2 text-success"></i> Take Approval Action</div>
                                <div class="card-body">
                                    <div class="d-grid gap-2">
                                        <button type="button" class="btn btn-success fw-semibold py-2" data-bs-toggle="modal" data-bs-target="#approveModal">
                                            <i class="fas fa-check-circle me-1"></i> Approve Quotation
                                        </button>
                                        <button type="button" class="btn btn-danger fw-semibold py-2" data-bs-toggle="modal" data-bs-target="#rejectModal">
                                            <i class="fas fa-times-circle me-1"></i> Reject Quotation
                                        </button>
                                        <button type="button" class="btn btn-outline-primary fw-semibold py-2" data-bs-toggle="modal" data-bs-target="#forwardModal">
                                            <i class="fas fa-share me-1"></i> Forward Quotation
                                        </button>
                                    </div>
                                </div>
                            </asp:Panel>

                            <!-- Read-Only Notice -->
                            <asp:Panel ID="pnlReadOnlyNotice" runat="server" Visible="false" CssClass="alert alert-secondary">
                                <i class="fas fa-lock me-1"></i> You do not have permission to approve/reject this quotation.
                            </asp:Panel>
                        </div>
                    </div>
                </asp:View>

                <!-- Tab 5: History View -->
                <asp:View ID="ViewHistory" runat="server">
                    <div class="card">
                        <div class="card-header"><i class="fas fa-history me-2 text-primary"></i> Complete Approval Activity History</div>
                        <div class="card-body p-0">
                            <div class="table-responsive">
                                <table class="table table-hover mb-0 align-middle text-sm">
                                    <thead>
                                        <tr>
                                            <th>Level</th>
                                            <th>Role</th>
                                            <th>User</th>
                                            <th>Action</th>
                                            <th>Status</th>
                                            <th>Remarks</th>
                                            <th>Date & Time</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td>Level 1</td>
                                            <td>Merch. Executive</td>
                                            <td>Mr. Karim</td>
                                            <td>Submit</td>
                                            <td><span class="badge bg-secondary">Submitted</span></td>
                                            <td>-</td>
                                            <td>10-Aug-2026 09:20 AM</td>
                                        </tr>
                                        <tr>
                                            <td>Level 2</td>
                                            <td>Merch. Manager</td>
                                            <td>Mr. Rahim</td>
                                            <td>Approve</td>
                                            <td><span class="badge bg-success">Approved</span></td>
                                            <td>Costing verified.</td>
                                            <td>10-Aug-2026 11:30 AM</td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </asp:View>

            </asp:MultiView>

        </div>

        <!-- Modals (Approve, Reject, Forward) এখানে আগের মতো থাকবে -->
        <!-- Approve Modal -->
        <div class="modal fade" id="approveModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">
                    <div class="modal-header bg-success text-white">
                        <h5 class="modal-title"><i class="fas fa-check-circle me-1"></i> Confirm Approval</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <p>Are you sure you want to approve this Price Quotation? (<strong class="text-primary">PQ-000125</strong>)</p>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button>
                        <asp:Button ID="btnConfirmApprove" runat="server" Text="Confirm Approval" CssClass="btn btn-success" />
                    </div>
                </div>
            </div>
        </div>

    </form>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>