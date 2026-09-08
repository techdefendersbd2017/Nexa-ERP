using System;

namespace Nexa_ERP.MerchandisingMarketing.BasicSetup
{
    public partial class BuyerBrandSetup : System.Web.UI.Page
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

        // Set Breakdown List -> "Add New Set Breakdown" clicked
        protected void btnAddNew_Click(object sender, EventArgs e)
        {
            hfSetBreakdownId.Value = "";
            ClearEntryForm();
            ShowEntry();
        }

        // Master Information -> "Back To List" clicked
        protected void btnBackToList_Click(object sender, EventArgs e)
        {
            ShowList();
            // TODO: BindGridView();
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            // TODO: filter GridView1 by txtFromDate, txtToDate, ddlBuyerFilter, ddlStyleFilter, ddlPOFilter
        }

        protected void btnClearFilter_Click(object sender, EventArgs e)
        {
            txtFromDate.Text = "";
            txtToDate.Text = "";
            ddlBuyerFilter.SelectedIndex = 0;
            ddlStyleFilter.SelectedIndex = 0;
            ddlPOFilter.SelectedIndex = 0;
        }

        protected void btnAddPO_Click(object sender, EventArgs e)
        {
            // TODO: append selected ddlPONo value as a row into gvPOList
        }

        protected void btnAddColorLine_Click(object sender, EventArgs e)
        {
            // TODO: append Main Color / Style No / Color / Ratio / CM (PCS) / FOB (PCS)
            // as a row into gvColorBreakdown
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            // TODO: validate + save Master Information (Buyer, Main Style No, PO list,
            // color breakdown list) using hfSetBreakdownId.Value
            ShowList();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ClearEntryForm();
        }

        private void ClearEntryForm()
        {
            ddlBuyer.SelectedIndex = 0;
            ddlMainStyleNo.SelectedIndex = 0;
            ddlPONo.SelectedIndex = 0;
            ddlMainColor.SelectedIndex = 0;
            ddlStyleNo.SelectedIndex = 0;
            ddlColor.SelectedIndex = 0;
            txtRatio.Text = "0";
            txtCMPcs.Text = "0";
            txtFOBPcs.Text = "0";
        }
    }
}