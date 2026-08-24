using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.TrimsAccessories.EstimationCostings
{
    public partial class MaterialRequirementByWorkOrder : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtMRDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                LoadMRList();
                LoadWorkOrders();
            }
        }

        private void LoadMRList()
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("MRID");
            dt.Columns.Add("MRNo");
            dt.Columns.Add("MRDate");
            dt.Columns.Add("WORcvNo");
            dt.Columns.Add("QuotationCode");
            dt.Columns.Add("Customer");
            dt.Columns.Add("TotalMaterials");

            gvMRList.DataSource = dt;
            gvMRList.DataBind();
        }

        private void LoadWorkOrders()
        {
            // ড্রপডাউনে কাজের অর্ডার লোড করার কোড
        }

        private void ShowPanel(bool isList, bool isForm, bool isReport)
        {
            pnlList.Attributes["class"] = isList ? "panel active" : "panel";
            pnlForm.Attributes["class"] = isForm ? "panel active" : "panel";
            pnlReport.Attributes["class"] = isReport ? "panel active" : "panel";
        }

        protected void btnAddNew_Click(object sender, EventArgs e)
        {
            ShowPanel(false, true, false);
            txtMRNo.Text = "MR-AUTO-" + DateTime.Now.Ticks.ToString().Substring(10);
        }

        protected void btnBackToList_Click(object sender, EventArgs e)
        {
            ShowPanel(true, false, false);
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            ShowPanel(true, false, false);
        }

        protected void ddlWorkOrder_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (ddlWorkOrder.SelectedValue != "0")
            {
                lblWONo.Text = ddlWorkOrder.SelectedItem.Text;
                lblQuotationCode.Text = "QT-2026-X";
                lblCustomer.Text = "Sample Buyer Ltd.";
                lblDeliveryDate.Text = DateTime.Now.AddDays(15).ToString("dd-MM-yyyy");
            }
        }

        protected void btnCalculate_Click(object sender, EventArgs e)
        {
            DataTable dtMat = new DataTable();
            dtMat.Columns.Add("RawMaterialID");
            dtMat.Columns.Add("RawMaterialName");
            dtMat.Columns.Add("Unit");
            dtMat.Columns.Add("RequiredQty");
            dtMat.Columns.Add("Remarks");

            dtMat.Rows.Add("RM-01", "Sewing Thread", "Pcs", "150", "Standard");
            dtMat.Rows.Add("RM-02", "Woven Label", "Pcs", "500", "Main Label");

            gvMaterialRequirement.DataSource = dtMat;
            gvMaterialRequirement.DataBind();

            lblTotalMaterials.Text = dtMat.Rows.Count.ToString();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('Saved Successfully!');", true);
            ShowPanel(true, false, false);
            LoadMRList();
        }

        protected void gvMRList_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "EditRow")
            {
                ShowPanel(false, true, false);
            }
            else if (e.CommandName == "ViewReport")
            {
                ShowPanel(false, false, true);

                lblRptMRNo.Text = "MR-2026-001";
                lblRptMRDate.Text = DateTime.Now.ToString("dd-MM-yyyy");
                lblRptWONo.Text = "WO-9988";
                lblRptQuotationCode.Text = "QT-5544";
                lblRptCustomer.Text = "ABC Fashion";
                lblRptDeliveryDate.Text = "30-06-2026";
            }
            else if (e.CommandName == "DeleteRow")
            {
                LoadMRList();
            }
        }
    }
}