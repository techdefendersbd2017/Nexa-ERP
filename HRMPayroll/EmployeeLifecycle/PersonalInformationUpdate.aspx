<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PersonalInformationUpdate.aspx.cs" Inherits="Nexa_ERP.HRMPayroll.EmployeeLifecycle.PersonalInformationUpdate" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Personal Information Update</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <style>
        /* ছবির সাথে মিল রেখে কালার আপডেট */
        body { background-color: #f0f2f5; font-family: 'Segoe UI', Arial, sans-serif; font-size: 12px; }
        
        .main-wrapper { 
            max-width: 1150px; 
            margin: 10px auto; 
            background: #fff; 
            border: 1px solid #ccc; 
            box-shadow: 0 0 10px rgba(0,0,0,0.1); 
            padding: 0; /* হেডার ফুল উইডথ করার জন্য */
            border-radius: 5px;
            overflow: hidden;
        }

        /* ছবির নীল হেডার অংশ */
        .header-title {
            background-color: #2e5bd7;
            color: white;
            padding: 12px;
            text-align: center;
            font-weight: bold;
            font-style: italic;
            font-size: 16px;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 15px;
        }

        .content-area { padding: 15px; }

        .fixed-top-section { border-bottom: 1px solid #eee; margin-bottom: 10px; padding-bottom: 10px; }
        
        /* ছবি অনুযায়ী ফটো বক্স ও বাটন */
        .photo-box { width: 120px; height: 140px; border: 1px solid #ccc; background: #f8f9fa; display: flex; align-items: center; justify-content: center; margin-bottom: 5px; }
        .photo-btn { background: #eef3ff; border: 1px solid #adc5ff; color: #2e5bd7; font-weight: bold; width: 120px; font-size: 11px; padding: 2px; text-align: center; display: block; }

        /* ট্যাব কালার */
        .nav-tabs .nav-link { background: #f8f9fa; border: 1px solid #ddd; color: #555; margin-right: 2px; padding: 6px 12px; }
        .nav-tabs .nav-link.active { background: #2e5bd7 !important; color: #fff !important; border-bottom: none; font-weight: bold; }
        
        .tab-content { background: #fff; border: 1px solid #ddd; border-top: none; padding: 20px; min-height: 480px; }
        
        .form-row-custom { display: flex; align-items: center; margin-bottom: 6px; }
        .form-row-custom label { width: 130px; min-width: 130px; margin-bottom: 0; font-weight: 500; color: #333; }
        .form-control-sm, .form-select-sm { border-radius: 4px; border: 1px solid #ced4da; font-size: 12px; height: 28px; }
        
        .section-title { font-weight: bold; background: #f0f4ff; color: #2e5bd7; padding: 4px 10px; display: block; margin-bottom: 10px; border-left: 4px solid #2e5bd7; }
        
        /* ছবির মত ফুটার বাটন স্টাইল */
        .footer-btns { margin-top: 15px; text-align: center; border-top: 1px solid #eee; padding-top: 15px; padding-bottom: 15px; }
        .footer-btns .btn { 
            min-width: 140px; 
            border-radius: 5px; 
            margin: 0 5px; 
            font-size: 12px; 
            font-weight: bold;
            background-color: #eef3ff;
            border: 1px solid #2e5bd7;
            color: #2e5bd7;
        }
        .footer-btns .btn:hover { background-color: #2e5bd7; color: #fff; }

        .btn-search-dark { background-color: #f8f9fa; border: 1px solid #ccc; color: #333; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server" />
        <div class="main-wrapper">
            <!-- নীল হেডার টাইটেল -->
            <div class="header-title">Personal Information Update</div>

            <div class="content-area">
                <!-- 1. FIXED TOP SECTION -->
                <div class="fixed-top-section">
                    <div class="row g-2">
                        <div class="col-md-8">
                            <div class="form-row-custom">
                                <label>Employee ID</label>
                                <div class="input-group input-group-sm" style="width: 250px;">
                                    <asp:TextBox ID="txtEmpID" runat="server" CssClass="form-control"></asp:TextBox>
                                    <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-search-dark" />
                                </div>
                            </div>
                            <div class="form-row-custom">
                                <label>Name</label>
                                <asp:TextBox ID="txtName" runat="server" CssClass="form-control form-control-sm"></asp:TextBox>
                            </div>
                            <div class="form-row-custom">
                                <label>Bangla Name</label>
                                <asp:TextBox ID="txtBanglaName" runat="server" CssClass="form-control form-control-sm"></asp:TextBox>
                            </div>
                            <div class="mt-1"><span class="text-primary fw-bold">User Name: Monzil</span></div>
                        </div>
                        <div class="col-md-4 d-flex justify-content-end align-items-start">
                            <div class="text-end small me-3 pt-2">
                                Joining Date: 06-May-2026 <br />
                                Probation Period: 06-May-2026 <br />
                                Employee Status: <asp:DropDownList runat="server" CssClass="form-select-sm d-inline-block" Width="100px"><asp:ListItem>Active</asp:ListItem></asp:DropDownList><br />
                                Separation Date: 06-May-2026
                            </div>
                            <div>
                                <div class="photo-box text-muted">Photo</div>
                                <span class="photo-btn">Photo</span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- 2. TAB NAVIGATION -->
                <ul class="nav nav-tabs" id="hrTabs" role="tablist">
                    <li class="nav-item"><button class="nav-link active" data-bs-toggle="tab" data-bs-target="#tab1">Personal Information</button></li>
                    <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab2">Address Information</button></li>
                    <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab3">Nominee Information</button></li>
                    <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab4">Job Experience</button></li>
                    <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab5">Reference</button></li>
                    <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab6">Covid 19 Info</button></li>
                    <li class="nav-item"><button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab7">Training Information</button></li>
                </ul>

                <!-- 3. TAB CONTENT -->
                <div class="tab-content">
                    <div class="tab-pane fade show active" id="tab1">
                        <div class="row">
                            <div class="col-md-6 border-end pe-4">
                                <div class="form-row-custom"><label>Father English</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>Mother English</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>Husband English</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>Wife English</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>NID</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>Date Of Birth</label>
                                    <asp:TextBox runat="server" CssClass="form-control form-control-sm me-1" Width="120px" Placeholder="DD-MM-YYYY" />
                                    <asp:DropDownList runat="server" CssClass="form-select form-select-sm" Width="100px"><asp:ListItem>Format</asp:ListItem></asp:DropDownList>
                                </div>
                                <div class="form-row-custom"><label>Religion</label><asp:DropDownList runat="server" CssClass="form-select form-select-sm w-100"><asp:ListItem>Select</asp:ListItem></asp:DropDownList></div>
                                <div class="form-row-custom"><label>Gender</label><asp:DropDownList runat="server" CssClass="form-select form-select-sm w-100"><asp:ListItem>Select</asp:ListItem></asp:DropDownList></div>
                                <div class="form-row-custom"><label>Blood Group</label><asp:DropDownList runat="server" CssClass="form-select form-select-sm w-100"><asp:ListItem>Select</asp:ListItem></asp:DropDownList></div>
                                <div class="form-row-custom"><label>Personal Phone</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>Education</label><asp:DropDownList runat="server" CssClass="form-select form-select-sm w-100"><asp:ListItem>Select</asp:ListItem></asp:DropDownList></div>
                            </div>
                            <div class="col-md-6 ps-4">
                                <div class="form-row-custom"><label>Father (Bangla)</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>Mother (Bangla)</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>Husband (Bangla)</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>Wife (Bangla)</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>BID</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>Marital Status</label><asp:DropDownList runat="server" CssClass="form-select form-select-sm w-100"><asp:ListItem>Select</asp:ListItem></asp:DropDownList></div>
                                <div class="form-row-custom"><label>No of Child</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>Height</label>
                                    <asp:TextBox runat="server" Width="50px" CssClass="form-control-sm me-1" /> ft 
                                    <asp:TextBox runat="server" Width="50px" CssClass="form-control-sm mx-1" /> inc
                                    <label style="width:70px; min-width:70px;" class="ms-2">Weight KG</label><asp:TextBox runat="server" Width="60px" CssClass="form-control-sm" />
                                </div>
                                <div class="form-row-custom"><label>TIN</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>Home Phone</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>E-mail</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                            </div>
                        </div>
                    </div>

                    <div class="tab-pane fade" id="tab2">
                        <div class="row">
                            <div class="col-md-6 border-end">
                                <span class="section-title">Permanent Address</span>
                                <div class="form-row-custom"><label>Village</label><asp:DropDownList runat="server" CssClass="form-select-sm w-50 me-1"></asp:DropDownList><asp:TextBox runat="server" CssClass="form-control form-control-sm w-50"></asp:TextBox></div>
                                <div class="form-row-custom"><label>Post Office</label><asp:DropDownList runat="server" CssClass="form-select-sm w-50 me-1"></asp:DropDownList><asp:TextBox runat="server" CssClass="form-control form-control-sm w-50"></asp:TextBox></div>
                                <div class="form-row-custom"><label>Police Station</label><asp:DropDownList runat="server" CssClass="form-select-sm w-50 me-1"></asp:DropDownList><asp:TextBox runat="server" CssClass="form-control form-control-sm w-50"></asp:TextBox></div>
                                <div class="form-row-custom"><label>District</label><asp:DropDownList runat="server" CssClass="form-select-sm w-100"></asp:DropDownList></div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-check mb-2 ms-4">
                                    <input class="form-check-input" type="checkbox" id="chkSame" />
                                    <label class="form-check-label fw-bold">If present or permanent address same click here.</label>
                                </div>
                                <span class="section-title ms-4">Present Address</span>
                                <div class="ms-4">
                                    <div class="form-row-custom"><label>Village</label><asp:DropDownList runat="server" CssClass="form-select-sm w-50 me-1"></asp:DropDownList><asp:TextBox runat="server" CssClass="form-control form-control-sm w-50"></asp:TextBox></div>
                                    <div class="form-row-custom"><label>Post Office</label><asp:DropDownList runat="server" CssClass="form-select-sm w-50 me-1"></asp:DropDownList><asp:TextBox runat="server" CssClass="form-control form-control-sm w-50"></asp:TextBox></div>
                                    <div class="form-row-custom"><label>Police Station</label><asp:DropDownList runat="server" CssClass="form-select-sm w-50 me-1"></asp:DropDownList><asp:TextBox runat="server" CssClass="form-control form-control-sm w-50"></asp:TextBox></div>
                                    <div class="form-row-custom"><label>District</label><asp:DropDownList runat="server" CssClass="form-select-sm w-50 me-1"></asp:DropDownList><asp:TextBox runat="server" CssClass="form-control form-control-sm w-50"></asp:TextBox></div>
                                    <div class="form-row-custom"><label>House Holder</label><asp:TextBox runat="server" CssClass="form-control form-control-sm w-100"></asp:TextBox></div>
                                    <div class="form-row-custom"><label>Phone</label><asp:TextBox runat="server" CssClass="form-control form-control-sm w-100"></asp:TextBox></div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="tab-pane fade" id="tab3">
                        <div class="row">
                            <div class="col-md-6 border-end">
                                <div class="form-row-custom"><label>Relation</label><asp:DropDownList runat="server" CssClass="form-select-sm w-100"><asp:ListItem>Select</asp:ListItem></asp:DropDownList></div>
                                <div class="form-row-custom"><label>Nominee's Name</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>NID</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>BID</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                            </div>
                            <div class="col-md-6 ps-4">
                                <div class="form-row-custom"><label>Nominee Name(Ban)</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>Date Of Birth</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" Width="150px" /></div>
                                <div class="form-row-custom"><label>Phone No</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                            </div>
                        </div>
                        <div class="form-check my-2"><input type="checkbox" /> If Employee & Nominee Address Same</div>
                        <div class="row mt-2">
                            <div class="col-md-6"><div class="form-row-custom"><label>Village</label><asp:TextBox runat="server" CssClass="form-control form-control-sm w-100" /></div></div>
                            <div class="col-md-6"><asp:TextBox runat="server" CssClass="form-control form-control-sm w-100" /></div>
                            <div class="col-md-6"><div class="form-row-custom"><label>District</label><asp:TextBox runat="server" CssClass="form-control form-control-sm w-100" /></div></div>
                            <div class="col-md-6"><asp:TextBox runat="server" CssClass="form-control form-control-sm w-100" /></div>
                            <div class="col-md-6"><asp:TextBox runat="server" CssClass="form-control form-control-sm w-100 mt-2" TextMode="MultiLine" Rows="3" /></div>
                            <div class="col-md-6"><asp:TextBox runat="server" CssClass="form-control form-control-sm w-100 mt-2" TextMode="MultiLine" Rows="3" /></div>
                        </div>
                    </div>

                    <div class="tab-pane fade" id="tab4">
                        <div class="row">
                            <div class="col-md-7 border-end">
                                <div class="form-row-custom"><label>Factory Name</label><asp:TextBox runat="server" CssClass="form-control form-control-sm w-100" /></div>
                                <div class="form-row-custom"><label>Address</label><asp:TextBox runat="server" TextMode="MultiLine" Rows="2" CssClass="form-control form-control-sm w-100" /></div>
                            </div>
                            <div class="col-md-5 ps-4">
                                <div class="form-row-custom"><label>Total Experience</label><asp:TextBox Width="40px" runat="server" /> Year <asp:TextBox Width="40px" runat="server" CssClass="ms-2" /> Month</div>
                                <div class="form-check mb-2"><input type="checkbox" /> If you use Experience From & Till Date</div>
                                <div class="form-row-custom"><label>From Date</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" Width="150px" /></div>
                                <div class="form-row-custom"><label>Till Date</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" Width="150px" /></div>
                            </div>
                        </div>
                    </div>

                    <div class="tab-pane fade" id="tab5">
                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-row-custom">
                                    <label>Ref. Employee ID</label>
                                    <div class="input-group input-group-sm">
                                        <asp:TextBox runat="server" CssClass="form-control" />
                                        <asp:Button runat="server" Text="Search" CssClass="btn btn-search-dark" />
                                    </div>
                                </div>
                                <div class="form-row-custom"><label>Name</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>Designation</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>Company</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>Email</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                <div class="form-row-custom"><label>Phone</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                            </div>
                        </div>
                    </div>

                    <div class="tab-pane fade" id="tab6">
                        <div class="row">
                            <div class="col-md-5 border-end">
                                <div class="form-row-custom"><label>Vaccine Status</label><asp:TextBox runat="server" CssClass="form-control form-control-sm w-100" /></div>
                                <div class="form-row-custom"><label>Vaccine Name</label><asp:TextBox runat="server" CssClass="form-control form-control-sm w-100" /></div>
                                <div class="ms-4 mt-3">
                                    <div class="mb-2"><input type="checkbox" /> 1st Dose <asp:TextBox runat="server" CssClass="ms-2" Width="120px" /></div>
                                    <div class="mb-2"><input type="checkbox" /> 2nd Dose <asp:TextBox runat="server" CssClass="ms-2" Width="120px" /></div>
                                    <div class="mb-2"><input type="checkbox" /> 3rd Dose <asp:TextBox runat="server" CssClass="ms-2" Width="120px" /></div>
                                    <div class="mb-2"><input type="checkbox" /> 4th Dose <asp:TextBox runat="server" CssClass="ms-2" Width="120px" /></div>
                                </div>
                            </div>
                            <div class="col-md-7 ps-4">
                                <span class="section-title">Vaccine Basic Info</span>
                                <div class="border p-2" style="height: 250px; background: #f9f9f9;"></div>
                            </div>
                        </div>
                    </div>

                    <div class="tab-pane fade" id="tab7">
                        <div class="row">
                            <div class="col-md-5 border-end pe-4">
                                 <div class="form-row-custom"><label>Training Head</label><asp:DropDownList runat="server" CssClass="form-select-sm w-100"><asp:ListItem>Select</asp:ListItem></asp:DropDownList></div>
                                 <div class="form-row-custom"><label>Training Subject</label><asp:DropDownList runat="server" CssClass="form-select-sm w-100"><asp:ListItem>Select</asp:ListItem></asp:DropDownList></div>
                                 <div class="form-row-custom"><label>Duration Date</label><asp:TextBox runat="server" Width="110px" /> to <asp:TextBox runat="server" Width="110px" /></div>
                                 <div class="form-row-custom"><label>Days</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                 <div class="form-row-custom"><label>Trainer Name</label><asp:TextBox runat="server" CssClass="form-control form-control-sm" /></div>
                                 <div class="form-row-custom"><label>Trainer Org.</label><asp:TextBox runat="server" TextMode="MultiLine" Rows="3" CssClass="form-control form-control-sm w-100" /></div>
                                 <div class="form-row-custom"><label>Org. Address</label><asp:TextBox runat="server" TextMode="MultiLine" Rows="3" CssClass="form-control form-control-sm w-100" /></div>
                                 <div class="text-center mt-2">
                                     <asp:Button runat="server" Text="Save" CssClass="btn btn-sm btn-light border w-25" /> 
                                     <asp:Button runat="server" Text="Delete" CssClass="btn btn-sm btn-light border w-25" />
                                 </div>
                            </div>
                            <div class="col-md-7 ps-4">
                                <table class="table table-sm table-bordered">
                                    <thead class="table-light small">
                                        <tr><th>Entry No</th><th>Training Head</th><th>Subject</th><th>Duration Date</th></tr>
                                    </thead>
                                    <tbody style="height:300px; display:block;"></tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- FOOTER BUTTONS -->
                <div class="footer-btns">
                    <asp:Button ID="btnRefresh" runat="server" Text="Refresh" CssClass="btn" />
                    <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn" />
                    <asp:Button ID="btnUpdate" runat="server" Text="Update" CssClass="btn" />
                    <asp:Button ID="btnClose" runat="server" Text="Close" CssClass="btn" />
                </div>
            </div>
        </div>
    </form>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        document.addEventListener("DOMContentLoaded", function () {
            var selectedTab = localStorage.getItem('activeTab');
            if (selectedTab) {
                var tabEl = document.querySelector(`button[data-bs-target="${selectedTab}"]`);
                if (tabEl) new bootstrap.Tab(tabEl).show();
            }
            var tabLinks = document.querySelectorAll('.nav-link');
            tabLinks.forEach(function (tab) {
                tab.addEventListener('shown.bs.tab', function (e) {
                    localStorage.setItem('activeTab', e.target.getAttribute('data-bs-target'));
                });
            });
        });
    </script>
</body>
</html>