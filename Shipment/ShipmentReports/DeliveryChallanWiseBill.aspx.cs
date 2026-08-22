using iTextSharp.text;
using iTextSharp.text.pdf;
using iTextSharp.tool.xml;
using iTextSharp.tool.xml.css;
using iTextSharp.tool.xml.html;
using iTextSharp.tool.xml.parser;
using iTextSharp.tool.xml.pipeline.css;
using iTextSharp.tool.xml.pipeline.end;
using iTextSharp.tool.xml.pipeline.html;
using Nexa_ERP.Connection;
using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Web;
using System.Web.UI;

namespace Nexa_ERP.Shipment.ShipmentReports
{
    public partial class DeliveryChallanWiseBill : System.Web.UI.Page
    {
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Request.QueryString["challanId"] != null)
                {
                    if (int.TryParse(Request.QueryString["challanId"], out int challanHeaderId))
                    {
                        ViewState["ChallanHeaderID"] = challanHeaderId;
                        LoadCommercialBillReport(challanHeaderId);
                    }
                }
            }
        }

        private void LoadCommercialBillReport(int challanHeaderId)
        {
            using (SqlConnection con = conn.openConnection())
            {
                string headerQuery = @"
                    SELECT h.DeliveryChallanNumber, h.DeliveryChallanDate, h.WorkOrderReceiveID, h.VehicleTransportNumber, h.DriverNameAndPhone, h.DeliveryRemarks, p.PartyName AS CustomerName, p.Address AS CustomerAddress, 
                    b.Branch_Name AS BranchName, b.Web, b.Phone_No, b.E_Mail, b.Address, p.ContactPerson, p.Phone AS CustomerPhone, p.Email AS CustomerEmail, WorkOrderHeader.RefWorkOrderNo, WorkOrderHeader.WORcvNo, 
                    dbo.vw_User_Information_Top1000.full_name
                    FROM dbo.DeliveryChallanHeader h INNER JOIN
                    WorkOrderHeader ON h.WorkOrderReceiveID = WorkOrderHeader.WORcvID INNER JOIN
                    dbo.vw_User_Information_Top1000 ON h.CreatedByUserID = dbo.vw_User_Information_Top1000.user_id LEFT OUTER JOIN
                    tbl_CustomerSupplier p ON h.CustomerPartyID = p.PartyID LEFT OUTER JOIN
                    vw_Branch_Information b ON h.ReceivingBranchID = b.Branch_ID
                    WHERE h.DeliveryChallanHeaderID = @ChallanHeaderID AND h.IsActive = 1";

                using (SqlCommand cmd = new SqlCommand(headerQuery, con))
                {
                    cmd.Parameters.AddWithValue("@ChallanHeaderID", challanHeaderId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            lblCompanyName.Text = reader["BranchName"] != DBNull.Value ? reader["BranchName"].ToString() : "";
                            lblCompanyAddress.Text = reader["Address"] != DBNull.Value ? reader["Address"].ToString() : "";
                            lblCompanyPhone.Text = reader["Phone_No"] != DBNull.Value ? reader["Phone_No"].ToString() : "";
                            lblCompanyEmail.Text = reader["E_Mail"] != DBNull.Value ? reader["E_Mail"].ToString() : "";

                            lblCustomerName.Text = reader["CustomerName"] != DBNull.Value ? reader["CustomerName"].ToString() : "";
                            lblBillingAddress.Text = reader["CustomerAddress"] != DBNull.Value ? reader["CustomerAddress"].ToString() : "";
                            lblBinVatNo.Text = "";

                            lblChallanNo.Text = reader["DeliveryChallanNumber"] != DBNull.Value ? reader["DeliveryChallanNumber"].ToString() : "";
                            lblWoNo.Text = reader["RefWorkOrderNo"] != DBNull.Value ? reader["RefWorkOrderNo"].ToString() : "";

                            lblAccountsOfficer.Text = reader["full_name"] != DBNull.Value ? reader["full_name"].ToString() : "";
                            lblBillNo.Text = "";
                            lblBillDate.Text = DateTime.Now.ToString("dd-MMM-yyyy");
                        }
                    }
                }

                string billItemsQuery = @"
                    SELECT ItemName, BuyerName, StyleName, ColorName, SizeName, DeliveryQuantity, ItemUnit,
                           UnitRateAmount, RateUnitName, TotalAmount,
                           CAST(0 AS DECIMAL(5,2)) AS ExtraPercentage
                    FROM dbo.DeliveryChallanDetails
                    WHERE DeliveryChallanHeaderID = @ChallanHeaderID ORDER BY SerialNumber ASC, DeliveryChallanDetailID ASC";

                decimal subTotal = 0;
                string rateUnitName = "USD";

                using (SqlCommand cmd = new SqlCommand(billItemsQuery, con))
                {
                    cmd.Parameters.AddWithValue("@ChallanHeaderID", challanHeaderId);
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dtBill = new DataTable();
                        da.Fill(dtBill);

                        gvBillItems.DataSource = dtBill;
                        gvBillItems.DataBind();

                        foreach (DataRow row in dtBill.Rows)
                        {
                            if (row["TotalAmount"] != DBNull.Value)
                                subTotal += Convert.ToDecimal(row["TotalAmount"]);
                        }

                        if (dtBill.Rows.Count > 0 && dtBill.Rows[0]["RateUnitName"] != DBNull.Value)
                        {
                            rateUnitName = dtBill.Rows[0]["RateUnitName"].ToString();
                        }

                        ViewState["BillItemsTable"] = dtBill;
                    }
                }

                var currency = GetCurrencyInfo(rateUnitName);

                decimal transportCost = 0;
                decimal vatPercentage = 0.02m;
                decimal vatAmount = subTotal * vatPercentage;
                decimal grandTotal = subTotal + transportCost + vatAmount;

                lblItemsSubTotal.Text = currency.Symbol + " " + subTotal.ToString("N2");
                lblTransportCost.Text = currency.Symbol + " " + transportCost.ToString("N2");
                lblVatAmount.Text = currency.Symbol + " " + vatAmount.ToString("N2");
                lblGrandTotal.Text = currency.Symbol + " " + grandTotal.ToString("N2");
                lblAmountInWords.Text = ConvertAmountToWords(grandTotal, currency.MajorUnit, currency.MinorUnit);
            }
        }

        // =================================================================
        // ---------------- PDF Download (পুনর্লিখিত অংশ) ------------------
        // =================================================================

        protected void btnDownloadPdf_Click(object sender, EventArgs e)
        {
            Response.ContentType = "application/pdf";
            Response.AddHeader("content-disposition", "attachment;filename=CommercialBill_" + lblChallanNo.Text + ".pdf");
            Response.Cache.SetCacheability(HttpCacheability.NoCache);

            using (MemoryStream ms = new MemoryStream())
            {
                Document pdfDoc = new Document(PageSize.A4, 25, 25, 25, 25);
                PdfWriter writer = PdfWriter.GetInstance(pdfDoc, ms);
                pdfDoc.Open();

                // ---- Unicode ফন্ট রেজিস্টার (বাংলা/৳ চিহ্নের জন্য) ----
                string fontPath = Server.MapPath("~/App_Data/Fonts/Kalpurush.ttf");

                var fontProvider = new XMLWorkerFontProvider();
                if (File.Exists(fontPath))
                {
                    fontProvider.Register(fontPath, "AppFont");
                }

                string htmlBody = BuildPdfHtml();
                string css = GetPdfCss();

                var cssResolver = new StyleAttrCSSResolver();
                using (var cssStream = new MemoryStream(Encoding.UTF8.GetBytes(css)))
                {
                    cssResolver.AddCss(XMLWorkerHelper.GetCSS(cssStream));
                }

                var cssAppliers = new CssAppliersImpl(fontProvider);
                var htmlContext = new HtmlPipelineContext(cssAppliers);
                htmlContext.SetTagFactory(Tags.GetHtmlTagProcessorFactory());
                htmlContext.AutoBookmark(false);

                var pdfWriterPipeline = new PdfWriterPipeline(pdfDoc, writer);
                var htmlPipeline = new HtmlPipeline(htmlContext, pdfWriterPipeline);
                var cssPipeline = new CssResolverPipeline(cssResolver, htmlPipeline);

                var worker = new XMLWorker(cssPipeline, true);
                var xmlParser = new XMLParser(true, worker, Encoding.UTF8);

                using (var sr = new StringReader(htmlBody))
                {
                    xmlParser.Parse(sr);
                }

                pdfDoc.Close();
                Response.BinaryWrite(ms.ToArray());
            }

            Response.End();
        }

        // PDF-এর জন্য সম্পূর্ণ স্বয়ংসম্পূর্ণ (self-contained) HTML — Bootstrap/Tailwind/flex ছাড়া
        private string BuildPdfHtml()
        {
            DataTable dtBill = ViewState["BillItemsTable"] as DataTable;
            var sb = new StringBuilder();

            sb.Append("<html><body>");

            // ---- হেডার ----
            sb.Append("<table style='width:100%;'>");
            sb.Append("<tr>");
            sb.Append("<td style='width:65%; vertical-align:top;'>");
            sb.Append($"<div class='company-name'>{HttpUtility.HtmlEncode(lblCompanyName.Text)}</div>");
            sb.Append($"<div class='muted'>{HttpUtility.HtmlEncode(lblCompanyAddress.Text)}</div>");
            sb.Append($"<div class='muted'>{HttpUtility.HtmlEncode(lblCompanyPhone.Text)} &nbsp; {HttpUtility.HtmlEncode(lblCompanyEmail.Text)}</div>");
            sb.Append("</td>");
            sb.Append("<td style='width:35%; text-align:right; vertical-align:top;'>");
            sb.Append("<div class='badge-title'>COMMERCIAL BILL</div>");
            sb.Append("<div class='muted'>Bill / Tax Invoice</div>");
            sb.Append("</td>");
            sb.Append("</tr>");
            sb.Append("</table>");
            sb.Append("<div class='divider'></div>");

            // ---- Billed To / Bill Reference ----
            sb.Append("<table style='width:100%; margin-top:10px;'>");
            sb.Append("<tr>");

            sb.Append("<td style='width:50%; vertical-align:top; padding-right:8px;'>");
            sb.Append("<div class='info-box'>");
            sb.Append("<div class='info-title'>Billed To</div>");
            sb.Append($"<div><b>Customer Name:</b> {HttpUtility.HtmlEncode(lblCustomerName.Text)}</div>");
            sb.Append($"<div><b>Billing Address:</b> {HttpUtility.HtmlEncode(lblBillingAddress.Text)}</div>");
            sb.Append($"<div><b>BIN / VAT Reg No:</b> {HttpUtility.HtmlEncode(lblBinVatNo.Text)}</div>");
            sb.Append("</div>");
            sb.Append("</td>");

            sb.Append("<td style='width:50%; vertical-align:top; padding-left:8px;'>");
            sb.Append("<div class='info-box'>");
            sb.Append("<div class='info-title'>Bill / Invoice Reference</div>");
            sb.Append($"<div><b>Bill No:</b> {HttpUtility.HtmlEncode(lblBillNo.Text)}</div>");
            sb.Append($"<div><b>Bill Date:</b> {HttpUtility.HtmlEncode(lblBillDate.Text)}</div>");
            sb.Append($"<div><b>Challan Ref:</b> {HttpUtility.HtmlEncode(lblChallanNo.Text)}</div>");
            sb.Append($"<div><b>Work Order Ref:</b> {HttpUtility.HtmlEncode(lblWoNo.Text)}</div>");
            sb.Append("</div>");
            sb.Append("</td>");

            sb.Append("</tr>");
            sb.Append("</table>");

            // ---- আইটেম টেবিল ----
            sb.Append("<table class='item-table' style='margin-top:12px;'>");
            sb.Append("<tr>");
            sb.Append("<th style='width:4%;'>SL</th>");
            sb.Append("<th style='width:16%;'>Item</th>");
            sb.Append("<th style='width:13%;'>Buyer / Style</th>");
            sb.Append("<th style='width:10%;'>Color / Size</th>");
            sb.Append("<th style='width:9%;'>Qty</th>");
            sb.Append("<th style='width:5%;'>Unit</th>");
            sb.Append("<th style='width:8%;'>Rate</th>");
            sb.Append("<th style='width:7%;'>Ccy</th>");
            sb.Append("<th style='width:6%;'>Extra %</th>");
            sb.Append("<th style='width:10%;'>Total</th>");
            sb.Append("</tr>");

            if (dtBill != null)
            {
                int sl = 1;
                foreach (DataRow row in dtBill.Rows)
                {
                    sb.Append("<tr>");
                    sb.Append($"<td style='text-align:center;'>{sl++}</td>");
                    sb.Append($"<td>{HttpUtility.HtmlEncode(row["ItemName"].ToString())}</td>");
                    sb.Append($"<td>{HttpUtility.HtmlEncode(row["BuyerName"].ToString())} / {HttpUtility.HtmlEncode(row["StyleName"].ToString())}</td>");
                    sb.Append($"<td style='text-align:center;'>{HttpUtility.HtmlEncode(row["ColorName"].ToString())} / {HttpUtility.HtmlEncode(row["SizeName"].ToString())}</td>");
                    sb.Append($"<td style='text-align:right;'>{Convert.ToDecimal(row["DeliveryQuantity"]).ToString("N0")}</td>");
                    sb.Append($"<td style='text-align:center;'>{HttpUtility.HtmlEncode(row["ItemUnit"].ToString())}</td>");
                    sb.Append($"<td style='text-align:right;'>{Convert.ToDecimal(row["UnitRateAmount"]).ToString("N3")}</td>");
                    sb.Append($"<td style='text-align:center;'>{HttpUtility.HtmlEncode(row["RateUnitName"].ToString())}</td>");
                    sb.Append($"<td style='text-align:center;'>{Convert.ToDecimal(row["ExtraPercentage"]).ToString("N0")}%</td>");
                    sb.Append($"<td style='text-align:right;'>{Convert.ToDecimal(row["TotalAmount"]).ToString("N2")}</td>");
                    sb.Append("</tr>");
                }
            }
            sb.Append("</table>");

            // ---- টোটাল (flex এর বদলে table) ----
            sb.Append("<table class='totals-table' style='width:280px; margin-left:auto; margin-top:12px;'>");
            sb.Append($"<tr><td>Items Sub Total:</td><td style='text-align:right;'>{HttpUtility.HtmlEncode(lblItemsSubTotal.Text)}</td></tr>");
            sb.Append($"<tr><td>Transport Cost:</td><td style='text-align:right;'>{HttpUtility.HtmlEncode(lblTransportCost.Text)}</td></tr>");
            sb.Append($"<tr><td>VAT / Tax:</td><td style='text-align:right;'>{HttpUtility.HtmlEncode(lblVatAmount.Text)}</td></tr>");
            sb.Append($"<tr class='grand-total'><td>Grand Total:</td><td style='text-align:right;'>{HttpUtility.HtmlEncode(lblGrandTotal.Text)}</td></tr>");
            sb.Append("</table>");

            // ---- Amount in Words + Payment Terms ----
            sb.Append($"<div class='amount-words'><b>In Words:</b> {HttpUtility.HtmlEncode(lblAmountInWords.Text)}</div>");
            sb.Append($"<div style='margin-top:6px;'><b>Payment Terms:</b> {HttpUtility.HtmlEncode(lblPaymentTerms.Text)}</div>");

            // ---- স্বাক্ষর ----
            sb.Append("<table class='sig-table' style='margin-top:70px;'>");
            sb.Append("<tr>");
            sb.Append(BuildSignatureCell(lblAccountsOfficer.Text, "Accounts Officer"));
            sb.Append(BuildSignatureCell(lblCheckedBy.Text, "Checked By"));
            sb.Append(BuildSignatureCell(lblManagerDGM.Text, "Manager / DGM"));
            sb.Append(BuildSignatureCell(lblCustomerAuthSign.Text, "Customer Authorized Sign"));
            sb.Append("</tr>");
            sb.Append("</table>");

            sb.Append("</body></html>");
            return sb.ToString();
        }

        private string BuildSignatureCell(string name, string label)
        {
            var cell = new StringBuilder();
            cell.Append("<td style='width:25%; text-align:center;'>");
            cell.Append($"<div style='min-height:16px;'>{HttpUtility.HtmlEncode(name)}</div>");
            cell.Append("<div class='sig-line'></div>");
            cell.Append($"<div><b>{label}</b></div>");
            cell.Append("</td>");
            return cell.ToString();
        }

        // XMLWorker-এর জন্য সরল, CSS2.1-কম্প্যাটিবল স্টাইল (flexbox/grid একদমই নেই)
        private string GetPdfCss()
        {
            return @"
                body { font-family: AppFont; font-size: 10px; color:#1e293b; }
                .company-name { font-size: 18px; font-weight: bold; color:#1f4e78; }
                .badge-title { font-size: 15px; font-weight: bold; color:#2e7d32; }
                .muted { font-size: 9px; color:#64748b; }
                .divider { border-top: 1px solid #cbd5e1; margin: 6px 0; }

                .info-box { background-color:#f1f5fa; border:1px solid #dbe6f2; padding:8px; }
                .info-title { font-weight:bold; color:#2e7d32; font-size:9px;
                               border-bottom:1px solid #cbd5e1; padding-bottom:3px; margin-bottom:5px; }

                .item-table { width:100%; border-collapse: collapse; }
                .item-table th { background-color:#2e7d32; color:#ffffff; font-size:9px; padding:5px; text-align:center; }
                .item-table td { border:1px solid #cbd5e1; padding:5px; font-size:9px; }

                .totals-table { border-collapse: collapse; }
                .totals-table td { padding:3px 4px; font-size:10px; }
                .grand-total td { font-weight:bold; color:#2e7d32; border-top:1px solid #64748b; font-size:11px; }

                .amount-words { font-style: italic; font-size: 10px; margin-top:10px; }

                .sig-table { width:100%; border-collapse: collapse; }
                .sig-table td { text-align:center; font-size:9px; padding:0 8px; }
                .sig-line { border-top:1px solid #64748b; margin:4px 0; }
            ";
        }

        // =================================================================
        // ---------------- Excel Download (অপরিবর্তিত) --------------------
        // =================================================================

        protected void btnDownloadExcel_Click(object sender, EventArgs e)
        {
            Response.Clear();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", "attachment;filename=CommercialBill_" + lblChallanNo.Text + ".xls");
            Response.Charset = "";
            Response.ContentType = "application/vnd.ms-excel";

            DataTable dtBill = ViewState["BillItemsTable"] as DataTable;
            StringBuilder sb = new StringBuilder();

            sb.Append("<html><head><meta charset='utf-8'></head><body>");
            sb.Append("<h2>" + lblCompanyName.Text + "</h2>");
            sb.Append("<p>" + lblCompanyAddress.Text + " | " + lblCompanyPhone.Text + " | " + lblCompanyEmail.Text + "</p>");
            sb.Append("<h3>COMMERCIAL BILL</h3>");

            sb.Append("<table border='1'>");
            sb.Append("<tr><td><b>Customer Name</b></td><td>" + lblCustomerName.Text + "</td>");
            sb.Append("<td><b>Bill No</b></td><td>" + lblBillNo.Text + "</td></tr>");
            sb.Append("<tr><td><b>Billing Address</b></td><td>" + lblBillingAddress.Text + "</td>");
            sb.Append("<td><b>Bill Date</b></td><td>" + lblBillDate.Text + "</td></tr>");
            sb.Append("<tr><td><b>BIN/VAT No</b></td><td>" + lblBinVatNo.Text + "</td>");
            sb.Append("<td><b>Challan Ref</b></td><td>" + lblChallanNo.Text + "</td></tr>");
            sb.Append("<tr><td></td><td></td><td><b>WO Ref</b></td><td>" + lblWoNo.Text + "</td></tr>");
            sb.Append("</table><br/>");

            sb.Append("<table border='1'>");
            sb.Append("<tr style='background:#2e7d32;color:#fff;'>");
            sb.Append("<th>SL</th><th>Item</th><th>Buyer/Style</th><th>Color/Size</th><th>Qty</th><th>Unit</th><th>Rate</th><th>Currency</th><th>Extra %</th><th>Total</th></tr>");

            if (dtBill != null)
            {
                int sl = 1;
                foreach (DataRow row in dtBill.Rows)
                {
                    sb.Append("<tr>");
                    sb.Append("<td>" + sl++ + "</td>");
                    sb.Append("<td>" + row["ItemName"] + "</td>");
                    sb.Append("<td>" + row["BuyerName"] + " / " + row["StyleName"] + "</td>");
                    sb.Append("<td>" + row["ColorName"] + " / " + row["SizeName"] + "</td>");
                    sb.Append("<td>" + row["DeliveryQuantity"] + "</td>");
                    sb.Append("<td>" + row["ItemUnit"] + "</td>");
                    sb.Append("<td>" + Convert.ToDecimal(row["UnitRateAmount"]).ToString("N3") + "</td>");
                    sb.Append("<td>" + row["RateUnitName"] + "</td>");
                    sb.Append("<td>" + Convert.ToDecimal(row["ExtraPercentage"]).ToString("N0") + "%</td>");
                    sb.Append("<td>" + Convert.ToDecimal(row["TotalAmount"]).ToString("N2") + "</td>");
                    sb.Append("</tr>");
                }
            }
            sb.Append("</table><br/>");

            sb.Append("<table border='1'>");
            sb.Append("<tr><td><b>Items Sub Total</b></td><td>" + lblItemsSubTotal.Text + "</td></tr>");
            sb.Append("<tr><td><b>Transport Cost</b></td><td>" + lblTransportCost.Text + "</td></tr>");
            sb.Append("<tr><td><b>VAT / Tax</b></td><td>" + lblVatAmount.Text + "</td></tr>");
            sb.Append("<tr><td><b>Grand Total</b></td><td>" + lblGrandTotal.Text + "</td></tr>");
            sb.Append("</table><br/>");

            sb.Append("<p><b>In Words:</b> " + lblAmountInWords.Text + "</p>");
            sb.Append("<p><b>Payment Terms:</b> " + lblPaymentTerms.Text + "</p>");

            sb.Append("</body></html>");

            Response.Output.Write(sb.ToString());
            Response.Flush();
            Response.End();
        }

        public override void VerifyRenderingInServerForm(Control control)
        {
            // GridView/Panel-কে RenderControl দিয়ে বাইরে থেকে render করার জন্য এই override বাধ্যতামূলক
        }

        // ---------------- কারেন্সি হেল্পার ----------------

        private (string Symbol, string MajorUnit, string MinorUnit) GetCurrencyInfo(string rateUnitName)
        {
            string unit = (rateUnitName ?? "").Trim().ToUpper();

            if (unit.Contains("EUR"))
                return ("€", "Euro", "Cent");

            if (unit.Contains("BDT") || unit.Contains("TAKA"))
                return ("৳", "Taka", "Paisa");

            if (unit.Contains("RUP") || unit.Contains("INR"))
                return ("₹", "Rupee", "Paisa");

            return ("$", "US Dollar", "Cent");
        }

        private string ConvertAmountToWords(decimal amount, string majorUnit, string minorUnit)
        {
            if (amount < 0) amount = 0;

            long majorPart = (long)Math.Truncate(amount);
            int minorPart = (int)Math.Round((amount - majorPart) * 100);

            StringBuilder result = new StringBuilder();

            string majorWords = NumberToWords(majorPart);
            string majorLabel = majorPart == 1 ? majorUnit : majorUnit + "s";
            result.Append(majorWords).Append(" ").Append(majorLabel);

            if (minorPart > 0)
            {
                string minorWords = NumberToWords(minorPart);
                string minorLabel = minorPart == 1 ? minorUnit : minorUnit + "s";
                result.Append(" and ").Append(minorWords).Append(" ").Append(minorLabel);
            }

            result.Append(" Only.");
            return result.ToString();
        }

        private static readonly string[] Ones =
        {
            "", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine",
            "Ten", "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen",
            "Seventeen", "Eighteen", "Nineteen"
        };

        private static readonly string[] Tens =
        {
            "", "", "Twenty", "Thirty", "Forty", "Fifty", "Sixty", "Seventy", "Eighty", "Ninety"
        };

        private string NumberToWords(long number)
        {
            if (number == 0) return "Zero";
            if (number < 0) return "Minus " + NumberToWords(-number);

            StringBuilder words = new StringBuilder();

            if (number / 1000000000 > 0)
            {
                words.Append(NumberToWords(number / 1000000000)).Append(" Billion ");
                number %= 1000000000;
            }
            if (number / 1000000 > 0)
            {
                words.Append(NumberToWords(number / 1000000)).Append(" Million ");
                number %= 1000000;
            }
            if (number / 1000 > 0)
            {
                words.Append(NumberToWords(number / 1000)).Append(" Thousand ");
                number %= 1000;
            }
            if (number / 100 > 0)
            {
                words.Append(NumberToWords(number / 100)).Append(" Hundred ");
                number %= 100;
            }
            if (number > 0)
            {
                if (words.Length > 0) words.Append("and ");

                if (number < 20)
                {
                    words.Append(Ones[number]);
                }
                else
                {
                    words.Append(Tens[number / 10]);
                    if (number % 10 > 0)
                        words.Append("-").Append(Ones[number % 10]);
                }
            }

            return words.ToString().Trim();
        }
    }
}