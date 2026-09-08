using System;

namespace Nexa_ERP.MerchandisingMarketing.BasicSetup
{
    public partial class SizeSetup : System.Web.UI.Page
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

        // Size List -> "Add Size" clicked
        protected void btnAddNew_Click(object sender, EventArgs e)
        {
            hfSizeId.Value = "";
            ClearEntryForm();
            ShowEntry();
        }

        // Size Entry -> "Back To List" clicked
        protected void btnBackToList_Click(object sender, EventArgs e)
        {
            ShowList();
            // TODO: BindGridView();
        }

        protected void ddlBuyer_SelectedIndexChanged(object sender, EventArgs e)
        {
            // TODO: reload gvSizesForBuyer based on selected ddlBuyer value
        }

        protected void btnAddNewSize_Click(object sender, EventArgs e)
        {
            // TODO: clear the Size Info fields (keep selected Buyer) to add another
            // size for the same buyer
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            // TODO: validate + save Size Info using hfSizeId.Value
            // TODO: refresh gvSizesForBuyer
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ClearEntryForm();
        }

        private void ClearEntryForm()
        {
            ddlBuyer.SelectedIndex = 0;
            txtSizeName.Text = "";
            txtDisplayName.Text = "";
            txtSortingNo.Text = "0";
            txtInseam.Text = "0";
            chkActiveStatus.Checked = true;
        }
    }
}