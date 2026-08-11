using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.TrimsAccessories.EstimationCostings
{
    public partial class PriceQuotationPrint : System.Web.UI.Page
    {
        SqlConnection con;
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();

        private string currentGroupItem = null;
        private decimal currentGroupTotal = 0;
        private int insertedRowsCount = 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string qid = Request.QueryString["QID"];
                int quotationId;

                if (string.IsNullOrEmpty(qid) || !int.TryParse(qid, out quotationId))
                {
                    Response.Write("Invalid Quotation ID.");
                    Response.End();
                    return;
                }

                LoadMaster(quotationId);
                LoadDetails(quotationId);
                LoadBranchInformation(quotationId);
                SetDeveloperAndFooterInfo();
            }
        }

        private void SetDeveloperAndFooterInfo()
        {
            if (lblDeveloperInfo != null)
            {
                lblDeveloperInfo.Text = "Developed & Maintained by: Nexa ERP System | Powered by Tech Defenders BD";
            }
        }

        private void LoadBranchInformation(int quotationId)
        {
            try
            {
                con = conn.openConnection();
                string query = @"SELECT tbl_PriceQuotationMaster.QuotationID, vw_Branch_Information.Branch_Name, vw_Branch_Information.Prifix, vw_Branch_Information.E_Mail, vw_Branch_Information.Phone_No, vw_Branch_Information.Web, 
                                        vw_Branch_Information.Address, vw_Branch_Information.Branch_Logo
                                 FROM tbl_PriceQuotationMaster 
                                 INNER JOIN vw_Branch_Information ON tbl_PriceQuotationMaster.ReceiveBranchID = vw_Branch_Information.Branch_ID
                                 WHERE tbl_PriceQuotationMaster.QuotationID = @QuotationID";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@QuotationID", quotationId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            lblBranchName.Text = reader["Branch_Name"].ToString();
                            lblAddress.Text = reader["Address"].ToString();
                            lblPhone.Text = reader["Phone_No"].ToString();
                            lblEmail.Text = reader["E_Mail"].ToString();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Response.Write("Error loading branch info: " + ex.Message);
                Response.End();
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) con.Close();
            }
        }

        private void LoadMaster(int quotationId)
        {
            try
            {
                con = conn.openConnection();
                string query = @"SELECT m.QuotationCode,
                                        CONVERT(VARCHAR(10), m.CreateDate, 105) AS CreateDate,
                                        c.PartyName AS Customer,
                                        m.QuotationName,
                                        m.OthersCost,
                                        m.GTotalCost,
                                        CASE WHEN m.Status = 1 THEN 'Active' ELSE 'Inactive' END AS Status
                                 FROM tbl_PriceQuotationMaster m
                                 LEFT JOIN tbl_CustomerSupplier c ON m.CustomerID = c.PartyID
                                 WHERE m.QuotationID = @QuotationID";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@QuotationID", quotationId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            lblQuotationCode.Text = reader["QuotationCode"].ToString();
                            lblCreateDate.Text = reader["CreateDate"].ToString();
                            lblCustomer.Text = reader["Customer"].ToString();
                            lblQuotationName.Text = reader["QuotationName"].ToString();
                            lblStatus.Text = reader["Status"].ToString();

                            decimal othersCost = reader["OthersCost"] == DBNull.Value ? 0 : Convert.ToDecimal(reader["OthersCost"]);
                            decimal gTotal = reader["GTotalCost"] == DBNull.Value ? 0 : Convert.ToDecimal(reader["GTotalCost"]);

                            lblOthersCost.Text = othersCost.ToString("0.00");
                            lblGTotalCost.Text = gTotal.ToString("0.00");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Response.Write("Error loading master: " + ex.Message);
                Response.End();
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) con.Close();
            }
        }

        private void LoadDetails(int quotationId)
        {
            try
            {
                con = conn.openConnection();

                string query = @"SELECT ROW_NUMBER() OVER(ORDER BY ta_ItemName.ItemName, DetailID) AS SlNo, 
                                        ta_ItemName.ItemName, 
                                        ta_RawMaterial.RawMaterialName, 
                                        tbl_PriceQuotationDetails.ReqQty, 
                                        tbl_PriceQuotationDetails.Unit, 
                                        tbl_PriceQuotationDetails.UnitPrice, 
                                        tbl_PriceQuotationDetails.Currency, 
                                        tbl_PriceQuotationDetails.Loss, 
                                        tbl_PriceQuotationDetails.TotalCost, 
                                        tbl_PriceQuotationDetails.Remarks
                                 FROM tbl_PriceQuotationDetails 
                                 INNER JOIN ta_ItemName ON tbl_PriceQuotationDetails.ItemID = ta_ItemName.ItemID 
                                 INNER JOIN ta_RawMaterial ON tbl_PriceQuotationDetails.RawMaterialID = ta_RawMaterial.RawMaterialID
                                 WHERE QuotationID = @QuotationID
                                 ORDER BY ta_ItemName.ItemName, DetailID";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@QuotationID", quotationId);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    currentGroupItem = null;
                    currentGroupTotal = 0;
                    insertedRowsCount = 0;

                    gvPrintDetails.DataSource = dt;
                    gvPrintDetails.DataBind();

                    if (dt.Rows.Count > 0)
                    {
                        Table gvTable = gvPrintDetails.Controls[0] as Table;
                        if (gvTable != null)
                        {
                            GridViewRow lastSubtotalRow = BuildSubtotalRow(gvPrintDetails.Columns.Count, currentGroupTotal);
                            gvTable.Controls.Add(lastSubtotalRow);
                        }
                    }

                    decimal totalCostSum = 0;
                    foreach (DataRow row in dt.Rows)
                    {
                        totalCostSum += Convert.ToDecimal(row["TotalCost"]);
                    }
                    lblTotalCostSum.Text = totalCostSum.ToString("0.00");
                }
            }
            catch (Exception ex)
            {
                Response.Write("Error loading details: " + ex.Message);
                Response.End();
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) con.Close();
            }
        }

        protected void gvPrintDetails_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType != DataControlRowType.DataRow) return;

            DataRowView drv = e.Row.DataItem as DataRowView;
            if (drv == null) return;

            string itemName = drv["ItemName"] == DBNull.Value ? "" : drv["ItemName"].ToString();
            decimal totalCost = drv["TotalCost"] == DBNull.Value ? 0 : Convert.ToDecimal(drv["TotalCost"]);

            Table gvTable = gvPrintDetails.Controls[0] as Table;
            if (gvTable == null) return;

            int colCount = e.Row.Cells.Count;
            int headerOffset = (gvPrintDetails.HeaderRow != null) ? 1 : 0;
            int baseIndex = e.Row.RowIndex + headerOffset + insertedRowsCount;

            if (itemName != currentGroupItem)
            {
                if (currentGroupItem != null)
                {
                    GridViewRow subtotalRow = BuildSubtotalRow(colCount, currentGroupTotal);
                    gvTable.Controls.AddAt(baseIndex, subtotalRow);
                    insertedRowsCount++;
                    baseIndex++;
                }

                GridViewRow headerRow = BuildHeaderRow(colCount, itemName);
                gvTable.Controls.AddAt(baseIndex, headerRow);
                insertedRowsCount++;

                currentGroupItem = itemName;
                currentGroupTotal = 0;
            }

            currentGroupTotal += totalCost;
        }

        private GridViewRow BuildHeaderRow(int colCount, string itemName)
        {
            GridViewRow row = new GridViewRow(0, 0, DataControlRowType.DataRow, DataControlRowState.Normal);
            row.CssClass = "group-header";

            TableCell cell = new TableCell();
            cell.ColumnSpan = colCount;
            cell.Text = "Item Name: " + (string.IsNullOrEmpty(itemName) ? "(N/A)" : Server.HtmlEncode(itemName));
            row.Cells.Add(cell);

            return row;
        }

        private GridViewRow BuildSubtotalRow(int colCount, decimal total)
        {
            GridViewRow row = new GridViewRow(0, 0, DataControlRowType.DataRow, DataControlRowState.Normal);
            row.CssClass = "group-subtotal";

            TableCell labelCell = new TableCell();
            labelCell.ColumnSpan = colCount - 2;
            labelCell.Text = "Group Total";
            labelCell.Style.Add("text-align", "right");
            labelCell.Style.Add("font-weight", "bold");
            row.Cells.Add(labelCell);

            TableCell totalCell = new TableCell();
            totalCell.ColumnSpan = 2;
            totalCell.CssClass = "num";
            totalCell.Style.Add("font-weight", "bold");
            totalCell.Text = total.ToString("0.00");
            row.Cells.Add(totalCell);

            return row;
        }
    }
}