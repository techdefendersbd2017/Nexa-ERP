using System;

namespace Nexa_ERP.MerchandisingMarketing.BasicSetup
{
    public partial class BuyerSetup : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ShowList();
                // TODO: BindDropDowns(); BindGridView();
            }
        }

        private void ShowList()
        {
            pnlList.Visible = true;
            pnlEntry.Visible = false;
        }

        private void ShowEntry()
        {
            pnlList.Visible = false;
            pnlEntry.Visible = true;
        }

        // Buyer List -> "Add Buyer Entry" clicked
        protected void btnAddNew_Click(object sender, EventArgs e)
        {
            hfBuyerId.Value = "";
            ClearEntryForm();
            ShowEntry();
        }

        // Buyer Information -> "Back To List" clicked
        protected void btnBackToList_Click(object sender, EventArgs e)
        {
            ShowList();
            // TODO: BindGridView();
        }

        protected void btnClearFilter_Click(object sender, EventArgs e)
        {
            txtSearchBuyer.Text = "";
            ddlBuyerType.SelectedIndex = 0;
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            // TODO: validate + save Buyer Information + Buyer Ledger
            // using hfBuyerId.Value
            ShowList();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ClearEntryForm();
        }

        private void ClearEntryForm()
        {
            txtBuyerCode.Text = "";
            ddlMainBuyer.SelectedIndex = 0;
            txtKnitOutsideBuyerName.Text = "";
            txtBuyerName.Text = "";
            txtContact.Text = "";
            txtDyeingOutsideBuyerName.Text = "";
            txtDisplayName.Text = "";
            txtEmail.Text = "";
            txtGarmentsOutsideBuyerName.Text = "";
            txtLCSCName.Text = "";
            txtCommission.Text = "0";
            txtLicenceNo.Text = "";
            txtAddress.Text = "";
            ddlCountry.SelectedIndex = 0;
            rbIsActive.Checked = false;
            rbIsLocal.Checked = false;
            txtAssetLedger.Text = "0";
            txtSalesLedger.Text = "0";
            txtLiabilityLedger.Text = "0";
        }
    }
}
