using System;

namespace Nexa_ERP.MerchandisingMarketing.BasicSetup
{
    public partial class ItemTypeSetup : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ShowList();
                // TODO: BindGridView();
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

        // Item Type List -> "Add Item Type" clicked
        protected void btnAddNew_Click(object sender, EventArgs e)
        {
            hfItemTypeId.Value = "";
            ClearEntryForm();
            ShowEntry();
        }

        // Item Type Entry -> "Back To List" clicked
        protected void btnBackToList_Click(object sender, EventArgs e)
        {
            ShowList();
            // TODO: BindGridView();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            // TODO: validate + save Item Type Info using hfItemTypeId.Value
            ShowList();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ClearEntryForm();
        }

        private void ClearEntryForm()
        {
            txtItemTypeName.Text = "";
            txtRemarks.Text = "";
            chkActiveStatus.Checked = true;
        }
    }
}