<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="FabricBookingSheet.aspx.cs" Inherits="Nexa_ERP.MasterConfiguration.BuyerManagement.FabricBookingSheet" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Fabrics Booking Sheet</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet" />
    <style>
        body { background:#f8fafc; font-family:Arial,Helvetica,sans-serif; color:#000; }
        .filter-bar { background:#fff; border:1px solid #e2e8f0; border-radius:.375rem; padding:.75rem 1rem; margin:1rem auto; max-width:1180px; }

        /* ===== SHEET (A4 landscape) ===== */
        .sheet { background:#fff; width:1123px; margin:0 auto 2rem; padding:18px 24px; font-size:11px; box-shadow:0 0 6px rgba(0,0,0,.15); }
        .sheet .co { text-align:center; line-height:1.5; }
        .sheet .co .name { font-size:13px; font-weight:700; }
        .sheet .co .addr { font-size:11px; }
        .sheet .co .title { font-size:13px; font-weight:700; }
        .hdr { display:flex; justify-content:space-between; align-items:flex-start; margin-top:6px; }
        .hdr .logo { width:110px; }
        .hdr .logo img { max-width:100px; max-height:70px; }
        .hdr table { border-collapse:collapse; }
        .hdr td { padding:1px 4px; vertical-align:top; font-size:11px; }
        .hdr td.l { font-weight:700; white-space:nowrap; }
        .hdr .img { width:140px; height:84px; border:1px solid #000; text-align:center; }
        .hdr .img img { max-width:100%; max-height:100%; }

        .sheet table.t { border-collapse:collapse; margin-top:4px; }
        .sheet table.t th, .sheet table.t td { border:1px solid #000; padding:2px 4px; font-size:11px; text-align:center; vertical-align:middle; }
        .sheet table.t th { font-weight:700; }
        .sheet table.t th.ob { background:#c7d2fe; }
        .sheet table.t td.num { text-align:right; }
        .sheet table.t tr.gt td { background:#e6f7f1; font-weight:700; }
        .sheet table.t td.fin { background:#fff8e6; }
        .sec-title { text-align:center; font-weight:700; margin-top:6px; }
        .fab-line { margin-top:8px; font-size:11px; }
        .sign { display:flex; justify-content:space-between; margin-top:50px; }
        .sign div { width:18%; text-align:center; border-top:1px solid #000; padding-top:3px; font-weight:700; font-size:11px; }

        @page { size:A4 landscape; margin:8mm; }
        @media print {
            body { background:#fff; }
            .no-print { display:none !important; }
            .sheet { box-shadow:none; margin:0; width:100%; padding:0; }
        }
    </style>
</head>
<body>
<form id="form1" runat="server">

    <div class="filter-bar no-print">
        <div class="row g-2 align-items-end">
            <div class="col-md-3">
                <label class="form-label mb-0 small">PO No</label>
                <asp:DropDownList ID="ddlPO" runat="server" CssClass="form-select form-select-sm" />
            </div>
            <div class="col-md-3">
                <label class="form-label mb-0 small">Booking Status</label>
                <asp:DropDownList ID="ddlBooked" runat="server" CssClass="form-select form-select-sm">
                    <asp:ListItem Value="1" Selected="True">Booked only</asp:ListItem>
                    <asp:ListItem Value="">All lines</asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="col-md-6 text-end">
                <asp:LinkButton ID="btnShow" runat="server" CssClass="btn btn-sm btn-primary" OnClick="btnShow_Click"><i class="bi bi-search"></i> Show</asp:LinkButton>
                <button type="button" class="btn btn-sm btn-outline-dark" onclick="window.print();"><i class="bi bi-printer"></i> Print / PDF</button>
                <a href="FabricBookingReport.aspx" class="btn btn-sm btn-outline-secondary"><i class="bi bi-arrow-left"></i> Report</a>
            </div>
        </div>
        <div class="small text-muted mt-1">Logged in as: <b><asp:Label ID="lblUser" runat="server" /></b></div>
    </div>

    <asp:Panel ID="pnlSheet" runat="server" Visible="false">
        <div class="sheet">
            <asp:Literal ID="litSheet" runat="server" />
        </div>
    </asp:Panel>

</form>
</body>
</html>
