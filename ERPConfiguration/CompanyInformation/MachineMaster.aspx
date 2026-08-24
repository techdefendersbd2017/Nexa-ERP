<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MachineMaster.aspx.cs" Inherits="Nexa_ERP.ERPConfiguration.CompanyInformation.MachineMaster" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Machine Master & Production Capacity Configuration</title>
    <!-- Bootstrap 5 CSS CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <!-- FontAwesome for Icons -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" />
    <style>
        .card-header-bg {
            background-color: #f8f9fa;
            font-weight: bold;
        }
        .preview-img {
            max-width: 150px;
            max-height: 150px;
            border: 1px solid #ddd;
            padding: 5px;
            display: none;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container-fluid py-4">
            <!-- Header Section -->
            <div class="row mb-4">
                <div class="col-12">
                    <div class="card shadow-sm border-0">
                        <div class="card-body bg-light text-dark rounded d-flex justify-content-between align-items-center">
                            <div>
                                <h2 class="h4 mb-0"><i class="fa-solid fa-gears me-2 text-primary"></i> Machine Master</h2>
                                <p class="text-muted mb-0 small">Machine Master & Production Capacity Configuration</p>
                            </div>
                            <div>
                                <asp:Button ID="btnSave" runat="server" Text="Save Machine" CssClass="btn btn-success px-4" OnClick="btnSave_Click" />
                                <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="btn btn-secondary px-3" OnClick="btnClear_Click" CausesValidation="false" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Tabs Navigation -->
            <ul class="nav nav-tabs" id="machineMasterTabs" role="tablist">
                <li class="nav-item" role="presentation">
                    <button class="nav-link active" id="general-tab" data-bs-toggle="tab" data-bs-target="#general" type="button" role="tab">
                        <i class="fa-solid fa-circle-info me-1"></i> General Information (Tab 1)
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="location-status-tab" data-bs-toggle="tab" data-bs-target="#locationStatus" type="button" role="tab">
                        <i class="fa-solid fa-location-dot me-1"></i> Location & Status (Tab 2)
                    </button>
                </li>
            </ul>

            <!-- Tabs Content -->
            <div class="tab-content border border-top-0 p-4 bg-white shadow-sm rounded-bottom" id="machineMasterTabsContent">
                
                <!-- TAB 1: General Information -->
                <div class="tab-pane fade show active" id="general" role="tabpanel" aria-labelledby="general-tab">
                    <h5 class="text-primary mb-3"><i class="fa-solid fa-sliders me-2"></i> General Information</h5>
                    <hr />
                    <div class="row g-3">
                        <!-- Machine ID -->
                        <div class="col-md-3">
                            <label class="form-label fw-bold">Machine ID / Code</label>
                            <asp:TextBox ID="txtMachineID" runat="server" CssClass="form-control" Text="MCH-00001" ReadOnly="true"></asp:TextBox>
                            <div class="form-text text-muted">Unique identifier</div>
                        </div>
                        
                        <!-- Machine Name -->
                        <div class="col-md-3">
                            <label class="form-label fw-bold">Machine Name</label>
                            <asp:TextBox ID="txtMachineName" runat="server" CssClass="form-control" Placeholder="e.g. Sewing, Button, Snap..."></asp:TextBox>
                        </div>

                        <!-- Machine Type -->
                        <div class="col-md-3">
                            <label class="form-label fw-bold">Machine Type</label>
                            <asp:DropDownList ID="ddlMachineType" runat="server" CssClass="form-select">
                                <asp:ListItem Text="-- Select Type --" Value="" />
                                <asp:ListItem Text="Sewing" Value="Sewing" />
                                <asp:ListItem Text="Cutting" Value="Cutting" />
                                <asp:ListItem Text="Printing" Value="Printing" />
                                <asp:ListItem Text="Embroidery" Value="Embroidery" />
                                <asp:ListItem Text="Button" Value="Button" />
                                <asp:ListItem Text="Snap" Value="Snap" />
                                <asp:ListItem Text="Eyelet" Value="Eyelet" />
                                <asp:ListItem Text="Rivet" Value="Rivet" />
                                <asp:ListItem Text="Finishing" Value="Finishing" />
                                <asp:ListItem Text="Packing" Value="Packing" />
                                <asp:ListItem Text="Other" Value="Other" />
                            </asp:DropDownList>
                        </div>

                        <!-- Machine Category -->
                        <div class="col-md-3">
                            <label class="form-label fw-bold">Machine Category</label>
                            <asp:DropDownList ID="ddlMachineCategory" runat="server" CssClass="form-select">
                                <asp:ListItem Text="-- Select Category --" Value="" />
                                <asp:ListItem Text="Category A" Value="CatA" />
                                <asp:ListItem Text="Category B" Value="CatB" />
                            </asp:DropDownList>
                        </div>

                        <!-- Machine Brand -->
                        <div class="col-md-3">
                            <label class="form-label fw-bold">Machine Brand</label>
                            <asp:DropDownList ID="ddlMachineBrand" runat="server" CssClass="form-select">
                                <asp:ListItem Text="-- Select Brand --" Value="" />
                                <asp:ListItem Text="JUKI" Value="JUKI" />
                                <asp:ListItem Text="Brother" Value="Brother" />
                                <asp:ListItem Text="YAMATO" Value="YAMATO" />
                                <asp:ListItem Text="Typical" Value="Typical" />
                                <asp:ListItem Text="Kansai" Value="Kansai" />
                                <asp:ListItem Text="Other" Value="Other" />
                            </asp:DropDownList>
                        </div>

                        <!-- Model No -->
                        <div class="col-md-3">
                            <label class="form-label fw-bold">Model No</label>
                            <asp:TextBox ID="txtModelNo" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>

                        <!-- Serial No -->
                        <div class="col-md-3">
                            <label class="form-label fw-bold">Serial No</label>
                            <asp:TextBox ID="txtSerialNo" runat="server" CssClass="form-control"></asp:TextBox>
                            <div class="form-text text-muted">Unique</div>
                        </div>

                        <!-- Machine Speed (RPM) -->
                        <div class="col-md-3">
                            <label class="form-label fw-bold">Machine Speed (RPM)</label>
                            <asp:TextBox ID="txtMachineSpeed" runat="server" CssClass="form-control" TextMode="Number"></asp:TextBox>
                            <div class="form-text text-danger small">শুধু Spec/Display field — Capacity Calculation-এ ব্যবহার হবে না</div>
                        </div>

                        <!-- Vendor / Supplier Name -->
                        <div class="col-md-3">
                            <label class="form-label fw-bold text-success">Vendor / Supplier Name <span class="badge bg-info text-dark">নতুন</span></label>
                            <asp:TextBox ID="txtVendorName" runat="server" CssClass="form-control"></asp:TextBox>
                            <div class="form-text text-muted">ভবিষ্যৎ Costing/Warranty claim-এর জন্য</div>
                        </div>

                        <!-- Vendor Contact -->
                        <div class="col-md-3">
                            <label class="form-label fw-bold text-success">Vendor Contact <span class="badge bg-info text-dark">নতুন</span></label>
                            <asp:TextBox ID="txtVendorContact" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>

                        <!-- Machine Photo -->
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Machine Photo</label>
                            <asp:FileUpload ID="fileMachinePhoto" runat="server" CssClass="form-control" />
                            <div class="form-text">Thumbnail preview এখানেই দেখাবে</div>
                            <div class="mt-2">
                                <asp:Image ID="imgPreview" runat="server" CssClass="preview-img rounded" />
                            </div>
                        </div>

                        <!-- Machine Specification -->
                        <div class="col-md-6">
                            <label class="form-label fw-bold">Machine Specification</label>
                            <asp:TextBox ID="txtMachineSpec" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3"></asp:TextBox>
                        </div>

                        <!-- Machine Description -->
                        <div class="col-md-12">
                            <label class="form-label fw-bold">Machine Description</label>
                            <asp:TextBox ID="txtMachineDesc" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3"></asp:TextBox>
                        </div>
                    </div>
                </div>

                <!-- TAB 2: Location Information & Machine Status -->
                <div class="tab-pane fade" id="locationStatus" role="tabpanel" aria-labelledby="location-status-tab">
                    
                    <!-- Location Section -->
                    <h5 class="text-primary mb-3"><i class="fa-solid fa-map-location-dot me-2"></i> Location Information (Tab 2)</h5>
                    <hr />
                    <div class="row g-3 mb-4">
                        <div class="col-md-3">
                            <label class="form-label fw-bold">Company</label>
                            <asp:DropDownList ID="ddlCompany" runat="server" CssClass="form-select">
                                <asp:ListItem Text="-- Select Company --" Value="" />
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-bold">Factory</label>
                            <asp:DropDownList ID="ddlFactory" runat="server" CssClass="form-select">
                                <asp:ListItem Text="-- Select Factory --" Value="" />
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-bold">Production Department</label>
                            <asp:DropDownList ID="ddlDepartment" runat="server" CssClass="form-select">
                                <asp:ListItem Text="-- Select Department --" Value="" />
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-bold">Production Section</label>
                            <asp:DropDownList ID="ddlSection" runat="server" CssClass="form-select">
                                <asp:ListItem Text="-- Select Section --" Value="" />
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-bold">Production Line</label>
                            <asp:DropDownList ID="ddlLine" runat="server" CssClass="form-select">
                                <asp:ListItem Text="-- Select Line --" Value="" />
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-bold">Floor</label>
                            <asp:DropDownList ID="ddlFloor" runat="server" CssClass="form-select">
                                <asp:ListItem Text="-- Select Floor --" Value="" />
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-bold">Machine Location</label>
                            <asp:TextBox ID="txtMachineLocation" runat="server" CssClass="form-control" Placeholder="Specific spot/zone"></asp:TextBox>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-bold">Responsible Department</label>
                            <asp:DropDownList ID="ddlRespDept" runat="server" CssClass="form-select">
                                <asp:ListItem Text="-- Select Resp. Dept --" Value="" />
                            </asp:DropDownList>
                        </div>
                    </div>

                    <!-- Machine Status Section -->
                    <h5 class="text-primary mb-3"><i class="fa-solid fa-heart-pulse me-2"></i> Machine Status & Dates</h5>
                    <hr />
                    <div class="row g-3">
                        <div class="col-md-4">
                            <label class="form-label fw-bold">Machine Status</label>
                            <asp:DropDownList ID="ddlMachineStatus" runat="server" CssClass="form-select">
                                <asp:ListItem Text="Active" Value="Active" Selected="True" />
                                <asp:ListItem Text="Inactive" Value="Inactive" />
                                <asp:ListItem Text="Under Maintenance" Value="Under Maintenance" />
                                <asp:ListItem Text="Breakdown" Value="Breakdown" />
                                <asp:ListItem Text="Idle" Value="Idle" />
                                <asp:ListItem Text="Scrap" Value="Scrap" />
                                <asp:ListItem Text="Sold" Value="Sold" />
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-bold">Machine Condition</label>
                            <asp:DropDownList ID="ddlMachineCondition" runat="server" CssClass="form-select">
                                <asp:ListItem Text="-- Select Condition --" Value="" />
                                <asp:ListItem Text="Excellent" Value="Excellent" />
                                <asp:ListItem Text="Good" Value="Good" />
                                <asp:ListItem Text="Fair" Value="Fair" />
                                <asp:ListItem Text="Poor" Value="Poor" />
                            </asp:DropDownList>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-bold">Installation Date</label>
                            <asp:TextBox ID="txtInstallationDate" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-bold">Purchase Date</label>
                            <asp:TextBox ID="txtPurchaseDate" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-bold">Warranty Expiry Date</label>
                            <asp:TextBox ID="txtWarrantyExpiryDate" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-bold">Last Maintenance Date</label>
                            <asp:TextBox ID="txtLastMaintenanceDate" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-bold">Next Maintenance Date</label>
                            <asp:TextBox ID="txtNextMaintenanceDate" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                        </div>
                    </div>

                </div>
            </div>
        </div>
    </form>

    <!-- Bootstrap 5 JS Bundle CDN -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>