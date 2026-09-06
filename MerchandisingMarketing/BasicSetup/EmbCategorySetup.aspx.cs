using System;

namespace Nexa_ERP.MerchandisingMarketing.BasicSetup
{
    public partial class EmbCategorySetup : System.Web.UI.Page
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

        // Emb Category List -> "Add Emb Category" clicked
        protected void btnAddNew_Click(object sender, EventArgs e)
        {
            hfEmbCategoryId.Value = "";
            ClearEntryForm();
            ShowEntry();
        }

        // Emb Category Entry -> "Back To List" clicked
        protected void btnBackToList_Click(object sender, EventArgs e)
        {
            ShowList();
            // TODO: BindGridView();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            // TODO: validate + save Emb Category Info using hfEmbCategoryId.Value
            ShowList();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ClearEntryForm();
        }

        private void ClearEntryForm()
        {
            ddlEmbellishmentType.SelectedIndex = 0;
            txtCategoryCode.Text = "";
            txtCategoryName.Text = "";
            txtRemarks.Text = "";
            chkActiveStatus.Checked = true;
        }
    }
}