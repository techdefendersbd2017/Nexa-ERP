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
                string query = @"SELECT ROW_NUMBER() OVER(ORDER BY DetailID) AS SlNo,
                                         RawMaterialName, ReqQty, Unit, UnitPrice, Currency, Loss, TotalCost, Remarks
                                  FROM tbl_PriceQuotationDetails
                                  WHERE QuotationID = @QuotationID
                                  ORDER BY DetailID";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@QuotationID", quotationId);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    gvPrintDetails.DataSource = dt;
                    gvPrintDetails.DataBind();

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
    }
}
