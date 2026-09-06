using System;

namespace Nexa_ERP.MerchandisingMarketing.BasicSetup
{
    public partial class BuyingAgentSetup : System.Web.UI.Page
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

        // Buying Agent List -> "Add Buying Agent" clicked
        protected void btnAddNew_Click(object sender, EventArgs e)
        {
            hfBuyingAgentId.Value = "";
            ClearEntryForm();
            ShowEntry();
        }

        // Buying Agent Entry -> "Back To List" clicked
        protected void btnBackToList_Click(object sender, EventArgs e)
        {
            ShowList();
            // TODO: BindGridView();
        }

        protected void btnAddBuyer_Click(object sender, EventArgs e)
        {
            // TODO: append selected ddlSelectBuyer value as a row into gvBuyers
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            // TODO: validate + save Buying Agent Info + linked Buyers list
            // using hfBuyingAgentId.Value
            ShowList();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ClearEntryForm();
        }

        private void ClearEntryForm()
        {
            txtCode.Text = "";
            txtName.Text = "";
            ddlAgentType.SelectedIndex = 0;
            txtContactPerson.Text = "";
            txtMobile.Text = "";
            txtPhone.Text = "";
            txtAddress.Text = "";
            txtFax.Text = "";
            txtEmail.Text = "";
            txtWeb.Text = "";
            chkIsActive.Checked = true;
            ddlSelectBuyer.SelectedIndex = 0;
        }
    }
}