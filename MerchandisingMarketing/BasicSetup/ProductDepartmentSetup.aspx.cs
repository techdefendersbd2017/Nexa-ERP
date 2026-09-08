using System;

namespace Nexa_ERP.MerchandisingMarketing.BasicSetup
{
    public partial class ProductDepartmentSetup : System.Web.UI.Page
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

        // Product Department List -> "Add Product Department" clicked
        protected void btnAddNew_Click(object sender, EventArgs e)
        {
            hfDepartmentId.Value = "";
            ClearEntryForm();
            ShowEntry();
        }

        // Product Department Entry -> "Back To List" clicked
        protected void btnBackToList_Click(object sender, EventArgs e)
        {
            ShowList();
            // TODO: BindGridView();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            // TODO: validate + save Department Info using hfDepartmentId.Value
            ShowList();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ClearEntryForm();
        }

        private void ClearEntryForm()
        {
            txtDepartmentName.Text = "";
            txtRemarks.Text = "";
            chkActiveStatus.Checked = true;
        }
    }
}