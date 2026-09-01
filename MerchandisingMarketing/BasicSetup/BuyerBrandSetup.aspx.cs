using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.Shipment
{
    public partial class DeemedExportLC : System.Web.UI.Page
    {
        protected void Page_Load1(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ShowList1();
                // TODO: BindDropDowns(); BindGridView();
            }
        }

        private void ShowList1()
        {
            pnlList.Visible = true;
            pnlEntry.Visible = false;
        }

        private void ShowEntry1()
        {
            pnlList.Visible = false;
            pnlEntry.Visible = true;
        }

        // Deemed Export LC List -> "Add New Deemed Export LC" clicked
        protected void btnAddNew_Click1(object sender, EventArgs e)
        {
            hfLCId.Value = "";
            ClearEntryForm1();
            ShowEntry();
        }

        // Used by both the header "Back To Deemed Export LC List" link
        // and the footer "Back to List" button
        protected void btnBackToList_Click1(object sender, EventArgs e)
        {
            ShowList();
            // TODO: BindGridView();
        }

        protected void btnCancel_Click1(object sender, EventArgs e)
        {
            ShowList();
        }

        protected void btnSaveAndPrint_Click1(object sender, EventArgs e)
        {
            // TODO: validate + save Deemed Export LC record using hfLCId.Value
            // TODO: trigger work order print
            ShowList();
        }

        private void ClearEntryForm1()
        {
            txtLCNo.Text = "";
            txtIssueDate.Text = "";
            txtExportDate.Text = "";
            txtExpiryDate.Text = "";
            txtLCValue.Text = "";
            txtLCQty.Text = "";
            txtCustomer.Text = "";
            txtExportPI.Text = "";
            txtRemarks.Text = "";
            txtLCValueDisplay.Text = "0";
            txtPIValueDisplay.Text = "0";
            txtDifferenceDisplay.Text = "0";
            txtLCCharge.Text = "0";
        }
    }
}