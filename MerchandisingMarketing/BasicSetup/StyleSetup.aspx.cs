using System;

namespace Nexa_ERP.MerchandisingMarketing.BasicSetup
{
    public partial class StyleSetup : System.Web.UI.Page
    {
        private const string TabActiveCss = "px-4 py-2 text-sm font-medium no-underline rounded-t bg-[#255C8C] text-white";
        private const string TabInactiveCss = "px-4 py-2 text-sm font-medium no-underline rounded-t bg-gray-100 text-gray-600 hover:bg-gray-200";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ShowStyleList();
                // TODO: BindDropDowns(); BindGridView();
            }
            else
            {
                // keep tab highlighting correct across postbacks
                ApplyPOTabStyles();
                ApplyCombineTabStyles();
            }
        }

        // ===== panel visibility helpers =====
        private void ShowStyleList()
        {
            pnlStyleList.Visible = true;
            pnlStyleDetails.Visible = false;
            pnlPOContainer.Visible = false;
            pnlPOCombine.Visible = false;
        }

        private void ShowStyleDetails()
        {
            pnlStyleList.Visible = false;
            pnlStyleDetails.Visible = true;
            pnlPOContainer.Visible = false;
            pnlPOCombine.Visible = false;
        }

        private void ShowPOContainer(string activeTab)
        {
            pnlStyleList.Visible = false;
            pnlStyleDetails.Visible = false;
            pnlPOContainer.Visible = true;
            pnlPOCombine.Visible = false;

            hfActivePOTab.Value = activeTab;
            ApplyPOTabStyles();
        }

        private void ShowPOCombine()
        {
            pnlStyleList.Visible = false;
            pnlStyleDetails.Visible = false;
            pnlPOContainer.Visible = false;
            pnlPOCombine.Visible = true;

            hfActiveCombineTab.Value = "Detail";
            ApplyCombineTabStyles();
        }

        private void ApplyPOTabStyles()
        {
            string active = hfActivePOTab.Value;

            pnlPOMaster.Visible = active == "Master";
            pnlPODetails.Visible = active == "Details";
            pnlFileUpload.Visible = active == "FileUpload";

            btnTabPOMaster.CssClass = active == "Master" ? TabActiveCss : TabInactiveCss;
            btnTabPODetails.CssClass = active == "Details" ? TabActiveCss : TabInactiveCss;
            btnTabFileUpload.CssClass = active == "FileUpload" ? TabActiveCss : TabInactiveCss;
        }

        private void ApplyCombineTabStyles()
        {
            string active = hfActiveCombineTab.Value;

            pnlCombineDetail.Visible = active == "Detail";
            pnlCombineSummary.Visible = active == "Summary";

            btnTabDetail.CssClass = active == "Detail" ? TabActiveCss : TabInactiveCss;
            btnTabSummary.CssClass = active == "Summary" ? TabActiveCss : TabInactiveCss;
        }

        // ===== ===================== Style List ===================== =====
        protected void btnAddNewStyle_Click(object sender, EventArgs e)
        {
            hfStyleId.Value = "";
            ClearStyleDetailsForm();
            ShowStyleDetails();
        }

        // ===== ===================== Style Details ===================== =====
        protected void btnBackToStyleList_Click(object sender, EventArgs e)
        {
            ShowStyleList();
            // TODO: BindGridView();
        }

        protected void btnAddNewPurchaseOrder_Click(object sender, EventArgs e)
        {
            hfPOId.Value = "";
            ShowPOContainer("Master");
        }

        protected void btnClearStyleDetails_Click(object sender, EventArgs e)
        {
            ClearStyleDetailsForm();
        }

        protected void btnSaveStyle_Click(object sender, EventArgs e)
        {
            // TODO: validate + save Style Details, Financial Info, Fabric Details,
            // Embellishment Details using hfStyleId.Value
            ShowStyleList();
        }

        protected void btnUpdateImage_Click(object sender, EventArgs e)
        {
            // TODO: handle style image upload via fuStyleImage
        }

        protected void btnSelectSize_Click(object sender, EventArgs e)
        {
            // TODO: open size selection list and append chosen sizes into gvStyleSizes
        }

        protected void btnSizeEntry_Click(object sender, EventArgs e)
        {
            // TODO: open quick size entry dialog / inline row for gvStyleSizes
        }

        protected void btnSelectColor_Click(object sender, EventArgs e)
        {
            // TODO: open color selection list and append chosen colors into gvStyleColors
        }

        protected void btnColorEntry_Click(object sender, EventArgs e)
        {
            // TODO: open quick color entry dialog / inline row for gvStyleColors
        }

        private void ClearStyleDetailsForm()
        {
            ddlProductDept.SelectedIndex = 0;
            ddlBuyerName.SelectedIndex = 0;
            ddlItemType.SelectedIndex = 0;
            txtStyleNo.Text = "";
            txtStyleDescription.Text = "";
            txtMarketingSMV.Text = "0";
            chkIsActiveStyle.Checked = true;

            txtFOBUsd.Text = "0";
            txtCMDzn.Text = "0";
            txtPOFOB.Text = "0";
            ddlCurrencyStyle.SelectedIndex = 0;
            txtPoExchangeRate.Text = "0";

            txtFabricGSM.Text = "";
            txtFabrication.Text = "";

            chkIsPrint.Checked = false;
            ddlPrintType.SelectedIndex = 0;
            chkIsEmbroidery.Checked = false;
            ddlEmbroideryType.SelectedIndex = 0;
            chkIsWashing.Checked = false;
            ddlWashingType.SelectedIndex = 0;
            chkIsSmock.Checked = false;
            ddlSmockType.SelectedIndex = 0;
        }

        // ===== ===================== PO Container : tabs ===================== =====
        protected void btnTabPOMaster_Click(object sender, EventArgs e)
        {
            hfActivePOTab.Value = "Master";
            ApplyPOTabStyles();
        }

        protected void btnTabPODetails_Click(object sender, EventArgs e)
        {
            hfActivePOTab.Value = "Details";
            ApplyPOTabStyles();
        }

        protected void btnTabFileUpload_Click(object sender, EventArgs e)
        {
            hfActivePOTab.Value = "FileUpload";
            ApplyPOTabStyles();
        }

        protected void btnBackToStyleDetailsFromPO_Click(object sender, EventArgs e)
        {
            ShowStyleDetails();
        }

        // ===== ===================== PO Details tab ===================== =====
        protected void btnAddNewPOCombine_Click(object sender, EventArgs e)
        {
            hfPOCombineId.Value = "";
            ShowPOCombine();
        }

        protected void btnAddNewStyleFromPODetails_Click(object sender, EventArgs e)
        {
            hfStyleId.Value = "";
            ClearStyleDetailsForm();
            ShowStyleDetails();
        }

        protected void btnAddPODetailRow_Click(object sender, EventArgs e)
        {
            // TODO: append Style No / CM/Dz / FOB/PC / PO FOB / Color / Size / dates
            // as a row into gvPODetails
        }

        protected void btnAddAllSize_Click(object sender, EventArgs e)
        {
            // TODO: append a row into gvPODetails for every size configured on the style
        }

        // ===== ===================== File Upload tab ===================== =====
        protected void btnUploadPDF_Click(object sender, EventArgs e)
        {
            // TODO: handle PDF upload via fuPO and append into gvUploadedPDFs
        }

        // ===== ===================== Purchase Order Combine ===================== =====
        protected void btnBackToPODetails_Click(object sender, EventArgs e)
        {
            ShowPOContainer("Details");
        }

        protected void btnAddNewPurchaseOrderFromCombine_Click(object sender, EventArgs e)
        {
            hfPOId.Value = "";
            ShowPOContainer("Master");
        }

        protected void btnSaveCombine_Click(object sender, EventArgs e)
        {
            // TODO: validate + save Purchase Order Combine using hfPOCombineId.Value
            ShowPOContainer("Details");
        }

        protected void btnTabDetail_Click(object sender, EventArgs e)
        {
            hfActiveCombineTab.Value = "Detail";
            ApplyCombineTabStyles();
        }

        protected void btnTabSummary_Click(object sender, EventArgs e)
        {
            hfActiveCombineTab.Value = "Summary";
            ApplyCombineTabStyles();
        }

        protected void btnAddCombineDetailRow_Click(object sender, EventArgs e)
        {
            // TODO: append selected ddlPONoCombine value as a row into gvCombineDetail
        }
    }
}
