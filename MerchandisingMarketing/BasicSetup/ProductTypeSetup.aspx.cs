using System;

namespace Nexa_ERP.MerchandisingMarketing.BasicSetup
{
    public partial class ProductTypeSetup : System.Web.UI.Page
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

        // Product Type List -> "Add Product Type" clicked
        protected void btnAddNew_Click(object sender, EventArgs e)
        {
            hfProductTypeId.Value = "";
            ClearEntryForm();
            ShowEntry();
        }

        // Product Type Entry -> "Back To List" clicked
        protected void btnBackToList_Click(object sender, EventArgs e)
        {
            ShowList();
            // TODO: BindGridView();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            // TODO: validate + save Product Type Info using hfProductTypeId.Value
            ShowList();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ClearEntryForm();
        }

        private void ClearEntryForm()
        {
            txtProductTypeName.Text = "";
        }
    }
}