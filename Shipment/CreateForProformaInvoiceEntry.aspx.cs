using Nexa_ERP.Connection;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.Shipment
{
    public partial class CreateForProformaInvoiceEntry : System.Web.UI.Page
    {
        SqlConnection con;
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();
        SqlCommand cmd;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadReceivingBranch();
                LoadPartyName();
                LoadPaymentTerms();
            }
        }
        private void LoadPaymentTerms()
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT * FROM tbl_PaymentTerm where IsActive=1 ORDER BY TermName";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlPaymentTerms.DataSource = dt;
                    ddlPaymentTerms.DataTextField = "TermName";
                    ddlPaymentTerms.DataValueField = "TermId";
                    ddlPaymentTerms.DataBind();
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
            finally
            {
                con.Close();
            }
        }
        private void LoadReceivingBranch()
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT Branch_ID, Branch_Name FROM vw_Branch_Information ORDER BY Branch_Name";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlBranch.DataSource = dt;
                    ddlBranch.DataTextField = "Branch_Name";
                    ddlBranch.DataValueField = "Branch_ID";
                    ddlBranch.DataBind();
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
            finally
            {
                con.Close();
            }
        }
        private void LoadPartyName()
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT PartyID, PartyName FROM tbl_CustomerSupplier WHERE PartyType NOT IN (2) ORDER BY PartyName";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlSupplier.DataSource = dt;
                    ddlSupplier.DataTextField = "PartyName";
                    ddlSupplier.DataValueField = "PartyID";
                    ddlSupplier.DataBind();

                    ddlSupplier.Items.Insert(0, new ListItem("--Select Party Name--", ""));
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
            finally
            {
                con.Close();
            }
        }

        protected void btnAddItem_Click(object sender, EventArgs e)
        {
            try
            {
                con=conn.openConnection();
                {
                    cmd = new SqlCommand(@"INSERT INTO SupplierPI_ItemDetail(ItemName,UOM,Quantity,UnitPrice,TotalAmount)VALUES
                                        '"+ddlItemName.SelectedItem.Text+"','"+txtUOM.Text+"','"+txtQuantity.Text+"', '"+txtTaxRate.Text+"'" +
                                        "'"+ txttotalAmount.Text+ "'", con);
                    cmd.ExecuteNonQuery ();
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Save Sucessfully');", true);
                }

            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
            finally
            {
                con.Close();
            }
        }

        protected void gvItemList_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "RemoveItem")
            {                

            }
        }

        protected void txtTaxRate_TextChanged(object sender, EventArgs e)
        {
            RecalculateTotals();
        }

        private void RecalculateTotals()
        {
            decimal subTotal = 0;
            decimal taxRate = 0;
            decimal.TryParse(txtTaxRate.Text, out taxRate);

            decimal taxAmount = (subTotal * taxRate) / 100;
            decimal grandTotal = subTotal + taxAmount;

            lblSubTotal.Text = subTotal.ToString("N2");
            lblGrandTotal.Text = grandTotal.ToString("N2");
        }

        private void ShowAlert(string message)
        {
            string safeMessage = message.Replace("'", "\\'");
            ClientScript.RegisterStartupScript(this.GetType(), "alertMsg", "alert('" + safeMessage + "');", true);
        }

        protected void ddlItemName_SelectedIndexChanged(object sender, EventArgs e)
        {

        }
    }
}
