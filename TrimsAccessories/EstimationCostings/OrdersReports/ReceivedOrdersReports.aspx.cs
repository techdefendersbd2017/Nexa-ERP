using Nexa_ERP.Connection;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.TrimsAccessories.EstimationCostings.OrdersReports
{
    public partial class ReceivedOrdersReports : System.Web.UI.Page
    {
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();

        // Sub-total accumulator variables
        decimal subTotalReqQty = 0;
        decimal subTotalTotalReqQty = 0;
        decimal subTotalTotalAmount = 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Request.QueryString["WORcvID"] != null &&
                    int.TryParse(Request.QueryString["WORcvID"], out int rcvId))
                {
                    LoadReportData(rcvId);
                }
            }
        }

        private void LoadReportData(int rcvId)
        {
            using (SqlConnection con = conn.openConnection())
            {
                // Join Master, Color, and Size tables to bring all 15 parameters together
                string query = @"
SELECT m.WorkOrderNo AS WONo, m.WoDate, m.DeliveryDate, m.Buyer, m.Style, m.OrderNo, m.GrandTotalAmount AS GrandTotal, m.WoRefNoDetails, b.Branch_Name, b.E_Mail AS BranchEmail, b.Phone_No AS BranchPhone, 
b.Address AS BranchAddress, c.PartyName, c.ContactPerson, c.Phone AS CustPhone, c.Email AS CustEmail, c.Address AS CustAddress
FROM WorkOrder_Master m LEFT OUTER JOIN vw_Branch_Information b ON m.BranchID = b.Branch_ID LEFT OUTER JOIN tbl_CustomerSupplier c ON m.CustomerName = c.PartyID
                    WHERE m.[WorkOrderID] = @WORcvID;

                    SELECT 
                        sd.[WorkOrderNo],
                        m.[ItemName],
                        cd.[ColorName],
                        sd.[Size],
                        sd.[Measurement],
                        sd.[ReqQty],
                        sd.[Unit],
                        sd.[RateUnit],
                        sd.[ExtraPercent],
                        sd.[TotalReqQty],
                        sd.[TotalAmount],
                        sd.[Remarks],
                        m.[WoRefNoDetails]
                    FROM [nexamar].[techdefendersbd].[WorkOrder_Size_Details] sd
                    INNER JOIN [nexamar].[techdefendersbd].[WorkOrder_Color_Details] cd ON sd.[WorkOrderNo] = cd.[WorkOrderNo] AND sd.[ColorSlNo] = cd.[ColorSlNo]
                    INNER JOIN [nexamar].[techdefendersbd].[WorkOrder_Master] m ON sd.[WorkOrderNo] = m.[WorkOrderNo]
                    WHERE m.[WorkOrderID] = @WORcvID;";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@WORcvID", rcvId);

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataSet ds = new DataSet();
                        da.Fill(ds);

                        if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                        {
                            DataRow row = ds.Tables[0].Rows[0];

                            lblWONo.Text = row["WONo"]?.ToString();
                            lblWORcvDate.Text = row["WoDate"] != DBNull.Value ? Convert.ToDateTime(row["WoDate"]).ToString("dd-MMM-yyyy") : "";
                            lblDeliveryDate.Text = row["DeliveryDate"] != DBNull.Value ? Convert.ToDateTime(row["DeliveryDate"]).ToString("dd-MMM-yyyy") : "";
                            lblGrandTotal.Text = row["GrandTotal"] != DBNull.Value ? Convert.ToDecimal(row["GrandTotal"]).ToString("N2") : "0.00";

                            // Buyer & Order Info
                            lblBuyer.Text = row["Buyer"]?.ToString();
                            lblStyle.Text = row["Style"]?.ToString();
                            lblOrderNo.Text = row["OrderNo"]?.ToString();

                            // Branch Info
                            lblBranchName.Text = row["Branch_Name"]?.ToString();
                            lblBranchAddress.Text = row["BranchAddress"]?.ToString();
                            lblBranchPhone.Text = row["BranchPhone"]?.ToString();
                            lblBranchEmail.Text = row["BranchEmail"]?.ToString();

                            // Customer Info
                            lblPartyName.Text = row["PartyName"]?.ToString();
                            lblContactPerson.Text = row["ContactPerson"]?.ToString();
                            lblCustomerPhone.Text = row["CustPhone"]?.ToString();
                        }

                        if (ds.Tables.Count > 1)
                        {
                            gvOrderDetails.DataSource = ds.Tables[1];
                            gvOrderDetails.DataBind();
                        }
                    }
                }
            }
        }

        // FIX: safe decimal reader — DataBinder.Eval returns DBNull.Value (not null) for
        // empty DB fields, so "?? 0" never caught it and Convert.ToDecimal(DBNull.Value)
        // was throwing InvalidCastException whenever a row had a blank numeric field.
        private decimal GetSafeDecimal(object dataItem, string fieldName)
        {
            object value = DataBinder.Eval(dataItem, fieldName);
            if (value == null || value == DBNull.Value)
                return 0;

            return decimal.TryParse(value.ToString(), out decimal result) ? result : 0;
        }

        protected void gvOrderDetails_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                // Accumulate values for Sub Totals (Column 5: ReqQty, Column 9: TotalReqQty, Column 10: TotalAmount)
                subTotalReqQty += GetSafeDecimal(e.Row.DataItem, "ReqQty");
                subTotalTotalReqQty += GetSafeDecimal(e.Row.DataItem, "TotalReqQty");
                subTotalTotalAmount += GetSafeDecimal(e.Row.DataItem, "TotalAmount");
            }
            else if (e.Row.RowType == DataControlRowType.Footer)
            {
                // FIX: Item Name, Color Name, Size, Measurement — এই ৪টা কলাম merge করে
                // একটাই সেলে "Item wise Sub Total:" দেখানো হচ্ছে (colspan = 4)
                e.Row.Cells[0].Text = "Item wise Sub Total:";
                e.Row.Cells[0].ColumnSpan = 4;
                e.Row.Cells[0].HorizontalAlign = HorizontalAlign.Right;
                e.Row.Cells[0].Attributes.Add("style", "font-weight:bold; text-align:right;");

                // মার্জ হয়ে যাওয়া বাকি ৩টা সেল (ColorName, Size, Measurement) রিমুভ করা হচ্ছে,
                // কারণ Cells[0] এখন colspan=4 দিয়ে ওদের জায়গা দখল করে নিয়েছে
                e.Row.Cells.RemoveAt(3); // Measurement
                e.Row.Cells.RemoveAt(2); // Size
                e.Row.Cells.RemoveAt(1); // ColorName

                // ৩টা সেল রিমুভ হওয়ায় বাকি সব সেলের index ৩ ঘর করে বাম দিকে শিফট হয়ে গেছে
                // আগে: ReqQty@4, TotalReqQty@8, TotalAmount@9
                // এখন: ReqQty@1, TotalReqQty@5, TotalAmount@6
                e.Row.Cells[1].Text = subTotalReqQty.ToString("N2");
                e.Row.Cells[5].Text = subTotalTotalReqQty.ToString("N2");
                e.Row.Cells[6].Text = subTotalTotalAmount.ToString("N2");

                e.Row.CssClass = "subtotal-row";
            }
        }

        // NOTE: Edit/Delete LinkButtons in the markup have CommandName="EditItem"/"DeleteItem"
        // but there was no OnRowCommand wired up, so clicking them did nothing.
        // Wire this up in the .aspx GridView tag: OnRowCommand="gvOrderDetails_RowCommand"
        // and add a CommandArgument (e.g. a unique row/detail ID) to each LinkButton if you
        // want this handler to actually act on a specific row.
        protected void gvOrderDetails_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "EditItem")
            {
                // TODO: implement edit logic using e.CommandArgument
            }
            else if (e.CommandName == "DeleteItem")
            {
                // TODO: implement delete logic using e.CommandArgument
            }
        }
    }
}
