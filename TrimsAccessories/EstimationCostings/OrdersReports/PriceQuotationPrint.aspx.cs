using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.TrimsAccessories.EstimationCostings
{
    public partial class PriceQuotationPrint : System.Web.UI.Page
    {
        SqlConnection con;
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();

        private string currentGroupRemarks = null;
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
                        else
                        {
                            Response.Write("Quotation not found.");
                            Response.End();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Response.Write("Error loading quotation: " + ex.Message);
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

                string query = @"SELECT ROW_NUMBER() OVER(ORDER BY ISNULL(Remarks,''), DetailID) AS SlNo,
                                         RawMaterialName, ReqQty, Unit, UnitPrice, Currency, Loss, TotalCost, Remarks
                                  FROM tbl_PriceQuotationDetails
                                  WHERE QuotationID = @QuotationID
                                  ORDER BY ISNULL(Remarks,''), DetailID";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@QuotationID", quotationId);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    currentGroupRemarks = null;
                    currentGroupTotal = 0;
                    insertedRowsCount = 0;

                    gvPrintDetails.DataSource = dt;
                    gvPrintDetails.DataBind();

                    // শেষ গ্রুপের subtotal row
                    if (dt.Rows.Count > 0)
                    {
                        Table gvTable = gvPrintDetails.Controls[0] as Table;
                        if (gvTable != null)
                        {
                            GridViewRow lastSubtotalRow = BuildSubtotalRow(gvPrintDetails.Columns.Count, currentGroupTotal);
                            gvTable.Controls.Add(lastSubtotalRow); // শেষে append, তাই index সমস্যা নেই
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
                Response.Write("Error loading item details: " + ex.Message);
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

            string remarks = drv["Remarks"] == DBNull.Value ? "" : drv["Remarks"].ToString();
            decimal totalCost = drv["TotalCost"] == DBNull.Value ? 0 : Convert.ToDecimal(drv["TotalCost"]);

            Table gvTable = gvPrintDetails.Controls[0] as Table;
            if (gvTable == null) return;

            int colCount = e.Row.Cells.Count;

            // ---- ফিক্স: হেডার রো (index 0) এর জন্য +1 অফসেট ----
            int headerOffset = (gvPrintDetails.HeaderRow != null) ? 1 : 0;
            int baseIndex = e.Row.RowIndex + headerOffset + insertedRowsCount;
            // -------------------------------------------------------

            if (remarks != currentGroupRemarks)
            {
                if (currentGroupRemarks != null)
                {
                    GridViewRow subtotalRow = BuildSubtotalRow(colCount, currentGroupTotal);
                    gvTable.Controls.AddAt(baseIndex, subtotalRow);
                    insertedRowsCount++;
                    baseIndex++; // পরের insert-এর জন্য index আপডেট
                }

                GridViewRow headerRow = BuildHeaderRow(colCount, remarks);
                gvTable.Controls.AddAt(baseIndex, headerRow);
                insertedRowsCount++;

                currentGroupRemarks = remarks;
                currentGroupTotal = 0;
            }

            currentGroupTotal += totalCost;
        }

        private GridViewRow BuildHeaderRow(int colCount, string remarks)
        {
            GridViewRow row = new GridViewRow(0, 0, DataControlRowType.DataRow, DataControlRowState.Normal);
            row.CssClass = "group-header";

            TableCell cell = new TableCell();
            cell.ColumnSpan = colCount;
            cell.Text = "Item: " + (string.IsNullOrEmpty(remarks) ? "(N/A)" : Server.HtmlEncode(remarks));
            row.Cells.Add(cell);

            return row;
        }

        private GridViewRow BuildSubtotalRow(int colCount, decimal total)
        {
            GridViewRow row = new GridViewRow(0, 0, DataControlRowType.DataRow, DataControlRowState.Normal);
            row.CssClass = "group-subtotal";

            TableCell labelCell = new TableCell();
            labelCell.ColumnSpan = colCount - 1;
            labelCell.Text = "Group Total";
            row.Cells.Add(labelCell);

            TableCell totalCell = new TableCell();
            totalCell.CssClass = "num";
            totalCell.Text = total.ToString("0.00");
            row.Cells.Add(totalCell);

            return row;
        }
    }
}