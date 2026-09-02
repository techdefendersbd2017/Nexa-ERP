using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.Shipment.ShipmentReports
{
    public partial class BillInvoiceReport : System.Web.UI.Page
    {
        SqlConnection con;
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["User_ID"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                if (string.IsNullOrEmpty(Request.QueryString["BillId"]) ||
                    !int.TryParse(Request.QueryString["BillId"], out int billHeaderId))
                {
                    Response.Write("Invalid Bill.");
                    Response.End();
                    return;
                }

                LoadBill(billHeaderId);
            }
        }

        private void LoadBill(int billHeaderId)
        {
            try
            {
                con = conn.openConnection();

                // ---------- Header + Customer info ----------
                string headerQuery = @"
                    SELECT  cbh.CommercialBillHeaderID, cbh.InvoiceNo,
                            CONVERT(VARCHAR(11), cbh.BillDate, 106) AS BillDate,
                            cbh.SubTotalAmount, cbh.TransportCost, cbh.VatPercent, cbh.VatAmount, cbh.GrandTotalAmount,
                            cs.PartyName, cs.Address
                    FROM techdefendersbd.SubmitedCommercialBillHeader cbh
                    INNER JOIN tbl_CustomerSupplier cs ON cs.PartyID = cbh.CustomerPartyID
                    WHERE cbh.CommercialBillHeaderID = @Id AND cbh.IsActive = 1";

                DataRow headerRow = null;
                using (SqlCommand cmd = new SqlCommand(headerQuery, con))
                {
                    cmd.Parameters.AddWithValue("@Id", billHeaderId);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    if (dt.Rows.Count > 0) headerRow = dt.Rows[0];
                }

                if (headerRow == null)
                {
                    Response.Write("Bill not found.");
                    Response.End();
                    return;
                }

                litCompanyName.Text = "<div class=\"company-name\">" + headerRow["PartyName"] + "</div>";
                litCompanyAddress.Text = headerRow["Address"].ToString().Replace("\r\n", "<br>");
                litInvoiceNo.Text = headerRow["InvoiceNo"].ToString();
                litBillDate.Text = headerRow["BillDate"].ToString();

                decimal subTotal = Convert.ToDecimal(headerRow["SubTotalAmount"]);
                decimal transport = Convert.ToDecimal(headerRow["TransportCost"]);
                decimal vatPercent = Convert.ToDecimal(headerRow["VatPercent"]);
                decimal vatAmount = Convert.ToDecimal(headerRow["VatAmount"]);
                decimal grandTotal = Convert.ToDecimal(headerRow["GrandTotalAmount"]);

                litSubTotal.Text = subTotal.ToString("0.00");
                litTransport.Text = transport.ToString("0.00");
                litVatPercent.Text = vatPercent.ToString("0.##");
                litVatAmount.Text = vatAmount.ToString("0.00");
                litGrandTotal.Text = grandTotal.ToString("0.00");

                litAmountInWords.Text = "TOTAL :- " + NumberToWords.Convert(grandTotal) + " ONLY";

                // ---------- Line items (challans under this bill) ----------
                string detailQuery = @"
                    SELECT  dch.DeliveryChallanNumber,
                            CONVERT(VARCHAR(10), dch.DeliveryChallanDate, 105) AS DeliveryChallanDate,
                            ISNULL(wo.RefWorkOrderNo, wo.WORcvNo) AS RefWorkOrderNo,
                            cbd.ChallanAmount
                    FROM techdefendersbd.CommercialBillDetail cbd
                    INNER JOIN DeliveryChallanHeader dch ON dch.DeliveryChallanHeaderID = cbd.DeliveryChallanHeaderID
                    LEFT JOIN WorkOrderHeader wo         ON wo.WORcvID = dch.WorkOrderReceiveID
                    WHERE cbd.CommercialBillHeaderID = @Id AND cbd.IsActive = 1
                    ORDER BY dch.DeliveryChallanHeaderID";

                using (SqlCommand cmd = new SqlCommand(detailQuery, con))
                {
                    cmd.Parameters.AddWithValue("@Id", billHeaderId);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    rptItems.DataSource = dt;
                    rptItems.DataBind();
                }
            }
            catch (Exception ex)
            {
                Response.Write("Error: " + ex.Message);
                Response.End();
            }
            finally
            {
                con.Close();
            }
        }
    }

    /// <summary>
    /// একটা সাধারণ সংখ্যা → ইংরেজি শব্দ কনভার্টার, বিলের "Amount in Words" লাইনের জন্য।
    /// </summary>
    public static class NumberToWords
    {
        private static readonly string[] Ones = { "ZERO","ONE","TWO","THREE","FOUR","FIVE","SIX","SEVEN","EIGHT","NINE",
            "TEN","ELEVEN","TWELVE","THIRTEEN","FOURTEEN","FIFTEEN","SIXTEEN","SEVENTEEN","EIGHTEEN","NINETEEN" };
        private static readonly string[] Tens = { "", "", "TWENTY", "THIRTY", "FORTY", "FIFTY", "SIXTY", "SEVENTY", "EIGHTY", "NINETY" };

        public static string Convert(decimal amount)
        {
            long wholePart = (long)Math.Floor(amount);
            int fractionPart = (int)Math.Round((amount - wholePart) * 100);

            StringBuilder sb = new StringBuilder();
            sb.Append(ConvertWhole(wholePart));

            if (fractionPart > 0)
            {
                sb.Append(" AND ");
                sb.Append(ConvertWhole(fractionPart));
                sb.Append(" CENTS");
            }

            return sb.ToString();
        }

        private static string ConvertWhole(long number)
        {
            if (number == 0) return "ZERO";

            StringBuilder sb = new StringBuilder();

            long billion = number / 1000000000; number %= 1000000000;
            long million = number / 1000000; number %= 1000000;
            long thousand = number / 1000; number %= 1000;
            long remainder = number;

            if (billion > 0) sb.Append(ConvertThreeDigit(billion) + " BILLION ");
            if (million > 0) sb.Append(ConvertThreeDigit(million) + " MILLION ");
            if (thousand > 0) sb.Append(ConvertThreeDigit(thousand) + " THOUSAND ");
            if (remainder > 0) sb.Append(ConvertThreeDigit(remainder));

            return sb.ToString().Trim();
        }

        private static string ConvertThreeDigit(long number)
        {
            StringBuilder sb = new StringBuilder();

            if (number >= 100)
            {
                sb.Append(Ones[number / 100] + " HUNDRED ");
                number %= 100;
            }

            if (number >= 20)
            {
                sb.Append(Tens[number / 10] + " ");
                number %= 10;
                if (number > 0) sb.Append(Ones[number] + " ");
            }
            else if (number > 0)
            {
                sb.Append(Ones[number] + " ");
            }

            return sb.ToString().Trim();
        }
    }
}