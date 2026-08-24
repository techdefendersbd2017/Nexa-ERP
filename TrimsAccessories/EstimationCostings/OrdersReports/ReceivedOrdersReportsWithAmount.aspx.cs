using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.TrimsAccessories.EstimationCostings.OrdersReports
{
    public partial class ReceivedOrdersReportsWithAmount : System.Web.UI.Page
    {
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();
        decimal totalGrandReqQty = 0;
        decimal totalGrandAmount = 0;

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
                string query = @"
                SELECT        WorkOrderHeader.WORcvID, WorkOrderHeader.WORcvNo, WorkOrderHeader.WORcvDate, WorkOrderHeader.DeliveryDate, tbl_CustomerSupplier.PartyName, WorkOrderHeader.RefWorkOrderNo, 
                WorkOrderHeader.QuotationNo, WorkOrderDetails.Buyer, WorkOrderDetails.Style, WorkOrderDetails.PO, WorkOrderDetails.ItemName, WorkOrderDetails.ItemDescription, WorkOrderDetails.ColorName, WorkOrderDetails.Size, 
                WorkOrderDetails.Measurement, WorkOrderDetails.ReqQty, WorkOrderDetails.Unit, WorkOrderDetails.RateUnit, WorkOrderDetails.ExtraPercent, WorkOrderDetails.TotalReqQty, WorkOrderDetails.TotalAmount, 
                WorkOrderDetails.Remarks, WorkOrderHeader.SubTotalAmount, WorkOrderHeader.TransportCost, WorkOrderHeader.VatPercent, WorkOrderHeader.GrandTotal, vw_Branch_Information.Branch_Name, 
                vw_Branch_Information.E_Mail, vw_Branch_Information.Phone_No, vw_Branch_Information.Web, vw_Branch_Information.Address, vw_Branch_Information.Branch_Logo, tbl_UnitSetup.UnitName, WorkOrderDetails.JobNo, 
                WorkOrderDetails.RateUnitName, CurrencyMaster.CurrencyID, CurrencyMaster.CurrencyCode, CurrencyMaster.Symbol, CurrencyMaster.ExchangeRate
                FROM            WorkOrderHeader INNER JOIN
                WorkOrderDetails ON WorkOrderHeader.WORcvID = WorkOrderDetails.WORcvID INNER JOIN
                tbl_CustomerSupplier ON WorkOrderHeader.CustomerID = tbl_CustomerSupplier.PartyID INNER JOIN
                vw_Branch_Information ON WorkOrderHeader.ReceivingBranchID = vw_Branch_Information.Branch_ID INNER JOIN
                CurrencyMaster ON WorkOrderDetails.RateUnitName = CurrencyMaster.CurrencyCode INNER JOIN
                tbl_UnitSetup ON WorkOrderDetails.Unit = tbl_UnitSetup.UnitName
                WHERE WorkOrderHeader.WORcvID = @WORcvID;";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@WORcvID", rcvId);

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        if (dt.Rows.Count > 0)
                        {
                            // 1st & 2nd Part Data Binding (Master & Branch)
                            DataRow headerRow = dt.Rows[0];
                            lblBranchName.Text = headerRow["Branch_Name"]?.ToString();
                            lblBranchAddress.Text = headerRow["Address"]?.ToString();
                            lblBranchPhone.Text = headerRow["Phone_No"]?.ToString();
                            lblBranchEmail.Text = headerRow["E_Mail"]?.ToString();
                            lblBranchWeb.Text = headerRow["Web"]?.ToString();

                            // Branch Logo Binding Logic (Handles both Binary Byte Array & Image URL Path)
                            if (headerRow["Branch_Logo"] != DBNull.Value)
                            {
                                object logoData = headerRow["Branch_Logo"];

                                if (logoData is byte[] logoBytes && logoBytes.Length > 0)
                                {
                                    // If Logo is stored as Varbinary/Byte Array
                                    string base64String = Convert.ToBase64String(logoBytes);
                                    imgBranchLogo.ImageUrl = "data:image/png;base64," + base64String;
                                    imgBranchLogo.Visible = true;
                                }
                                else
                                {
                                    // If Logo is stored as URL/File Path String
                                    string logoPath = logoData.ToString();
                                    if (!string.IsNullOrWhiteSpace(logoPath))
                                    {
                                        imgBranchLogo.ImageUrl = logoPath;
                                        imgBranchLogo.Visible = true;
                                    }
                                }
                            }

                            lblWORcvNo.Text = headerRow["WORcvNo"]?.ToString();
                            lblPartyName.Text = headerRow["PartyName"]?.ToString();
                            lblWORcvDate.Text = headerRow["WORcvDate"] != DBNull.Value ? Convert.ToDateTime(headerRow["WORcvDate"]).ToString("dd-MMM-yyyy") : "";
                            lblDeliveryDate.Text = headerRow["DeliveryDate"] != DBNull.Value ? Convert.ToDateTime(headerRow["DeliveryDate"]).ToString("dd-MMM-yyyy") : "";
                            lblRefWorkOrderNo.Text = headerRow["RefWorkOrderNo"]?.ToString();

                            // Currency Code for "Amount in Words" - falls back to BDT if not found.
                            // NOTE: We deliberately do NOT depend on a "CurrencyName" column in the query
                            // (the query only selects CurrencyID/CurrencyCode/Symbol/ExchangeRate).
                            // If a CurrencyName column IS present in the result set, it is used as an
                            // override; otherwise the currency word-map below resolves the name
                            // automatically from CurrencyCode, so no manual correction is needed per currency.
                            string currencyCode = (dt.Columns.Contains("CurrencyCode") && headerRow["CurrencyCode"] != DBNull.Value)
                                ? headerRow["CurrencyCode"].ToString() : "BDT";

                            string currencyNameOverride = (dt.Columns.Contains("CurrencyName") && headerRow["CurrencyName"] != DBNull.Value)
                                ? headerRow["CurrencyName"].ToString() : null;

                            // Calculate total Grand Total Req Qty
                            if (dt.Columns.Contains("TotalReqQty"))
                            {
                                totalGrandReqQty = dt.AsEnumerable().Sum(row => row.Field<decimal?>("TotalReqQty") ?? 0);
                            }
                            lblGrandTotalReqQty.Text = totalGrandReqQty.ToString("N2");

                            // Calculate Grand Total Amount
                            if (dt.Columns.Contains("TotalAmount"))
                            {
                                totalGrandAmount = dt.AsEnumerable().Sum(row => row.Field<decimal?>("TotalAmount") ?? 0);
                            }
                            lblGrandTotalAmount.Text = totalGrandAmount.ToString("N2");

                            // Grand Total Amount in words, according to currency (auto-detected)
                            lblGrandTotalAmountInWords.Text = ConvertAmountToWords(totalGrandAmount, currencyCode, currencyNameOverride);

                            // 3rd Part: Grouping data by Buyer, Style, and PO
                            var groups = dt.AsEnumerable()
                                .GroupBy(r => new {
                                    Buyer = r.Field<string>("Buyer") ?? "",
                                    Style = r.Field<string>("Style") ?? "",
                                    PO = r.Field<string>("PO") ?? ""
                                })
                                .Select(g => new {
                                    g.Key.Buyer,
                                    g.Key.Style,
                                    g.Key.PO,
                                    Rows = g.CopyToDataTable()
                                }).ToList();

                            rptGroupedOrders.DataSource = groups;
                            rptGroupedOrders.DataBind();
                        }
                    }
                }
            }
        }

        protected void rptGroupedOrders_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                var gvGroupDetails = (GridView)e.Item.FindControl("gvGroupDetails");
                var groupData = (DataTable)((dynamic)e.Item.DataItem).Rows;

                // Add RowNo (SL No) dynamically
                if (!groupData.Columns.Contains("RowNo"))
                {
                    groupData.Columns.Add("RowNo", typeof(int));
                    for (int i = 0; i < groupData.Rows.Count; i++)
                    {
                        groupData.Rows[i]["RowNo"] = i + 1;
                    }
                }

                gvGroupDetails.DataSource = groupData;
                gvGroupDetails.DataBind();
            }
        }

        protected void gvGroupDetails_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            // Column Auto-Hide Logic
            if (e.Row.RowType == DataControlRowType.Header)
            {
                GridView gv = (GridView)sender;
                DataTable dt = (DataTable)gv.DataSource;

                if (dt != null)
                {
                    for (int i = 0; i < gv.Columns.Count; i++)
                    {
                        string dataField = ((BoundField)gv.Columns[i]).DataField;
                        if (!string.IsNullOrEmpty(dataField) && dt.Columns.Contains(dataField))
                        {
                            bool hasData = dt.AsEnumerable().Any(r => r[dataField] != DBNull.Value && !string.IsNullOrWhiteSpace(r[dataField].ToString()));
                            if (!hasData)
                            {
                                e.Row.Cells[i].Visible = false;
                            }
                        }
                    }
                }
            }
            else if (e.Row.RowType == DataControlRowType.DataRow)
            {
                GridView gv = (GridView)sender;
                for (int i = 0; i < gv.Columns.Count; i++)
                {
                    if (!gv.HeaderRow.Cells[i].Visible)
                    {
                        e.Row.Cells[i].Visible = false;
                    }
                }
            }
            else if (e.Row.RowType == DataControlRowType.Footer)
            {
                // Per-group subtotal ("Group Total") row for Total Req Qty & Amount
                GridView gv = (GridView)sender;
                DataTable dt = (DataTable)gv.DataSource;
                if (dt == null) return;

                int idxTotalReqQty = FindColumnIndex(gv, "TotalReqQty");
                int idxTotalAmount = FindColumnIndex(gv, "TotalAmount");

                decimal sumTotalReqQty = dt.Columns.Contains("TotalReqQty")
                    ? dt.AsEnumerable().Sum(r => r["TotalReqQty"] != DBNull.Value ? Convert.ToDecimal(r["TotalReqQty"]) : 0)
                    : 0;
                decimal sumTotalAmount = dt.Columns.Contains("TotalAmount")
                    ? dt.AsEnumerable().Sum(r => r["TotalAmount"] != DBNull.Value ? Convert.ToDecimal(r["TotalAmount"]) : 0)
                    : 0;

                // Hide footer cells for columns that were hidden in the header, then
                // merge the remaining leading cells into a single "Group Total" label.
                int firstVisible = -1;
                int labelSpan = 0;
                for (int i = 0; i < gv.Columns.Count; i++)
                {
                    bool headerVisible = gv.HeaderRow.Cells[i].Visible;
                    e.Row.Cells[i].Visible = headerVisible;

                    if (!headerVisible) continue;
                    if (i == idxTotalReqQty || i == idxTotalAmount) continue;

                    if (firstVisible == -1) firstVisible = i;
                    labelSpan++;
                }

                if (firstVisible != -1)
                {
                    e.Row.Cells[firstVisible].Text = "Group Total";
                    e.Row.Cells[firstVisible].CssClass = "num";
                    if (labelSpan > 1)
                    {
                        e.Row.Cells[firstVisible].Attributes["colspan"] = labelSpan.ToString();
                        for (int i = firstVisible + 1; i < gv.Columns.Count; i++)
                        {
                            if (i != idxTotalReqQty && i != idxTotalAmount)
                            {
                                e.Row.Cells[i].Visible = false;
                            }
                        }
                    }
                }

                if (idxTotalReqQty >= 0 && gv.HeaderRow.Cells[idxTotalReqQty].Visible)
                {
                    e.Row.Cells[idxTotalReqQty].Text = sumTotalReqQty.ToString("N2");
                    e.Row.Cells[idxTotalReqQty].CssClass = "num";
                }
                if (idxTotalAmount >= 0 && gv.HeaderRow.Cells[idxTotalAmount].Visible)
                {
                    e.Row.Cells[idxTotalAmount].Text = sumTotalAmount.ToString("N2");
                    e.Row.Cells[idxTotalAmount].CssClass = "num";
                }

                e.Row.CssClass = "group-total-row";
            }
        }

        private int FindColumnIndex(GridView gv, string dataField)
        {
            for (int i = 0; i < gv.Columns.Count; i++)
            {
                if (gv.Columns[i] is BoundField bf && bf.DataField == dataField)
                {
                    return i;
                }
            }
            return -1;
        }

        #region Amount in Words

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

        // Auto currency word-map, keyed by CurrencyCode (ISO-4217 style codes).
        // Add more entries any time; unknown/new codes still work automatically
        // via the fallback logic inside ConvertAmountToWords (code itself is used as the name),
        // so this list does NOT need to be exhaustive to avoid errors.
        private static readonly Dictionary<string, (string Major, string Minor)> CurrencyWordsMap =
            new Dictionary<string, (string, string)>(StringComparer.OrdinalIgnoreCase)
            {
                { "BDT", ("Taka", "Poisha") },
                { "USD", ("US Dollar", "Cents") },
                { "EUR", ("Euro", "Cents") },
                { "GBP", ("Pound Sterling", "Pence") },
                { "INR", ("Indian Rupee", "Paisa") },
                { "AED", ("UAE Dirham", "Fils") },
                { "SAR", ("Saudi Riyal", "Halalas") },
                { "CNY", ("Chinese Yuan", "Fen") },
                { "JPY", ("Japanese Yen", "Sen") },
                { "AUD", ("Australian Dollar", "Cents") },
                { "CAD", ("Canadian Dollar", "Cents") },
                { "SGD", ("Singapore Dollar", "Cents") },
                { "HKD", ("Hong Kong Dollar", "Cents") },
                { "MYR", ("Malaysian Ringgit", "Sen") },
                { "THB", ("Thai Baht", "Satang") },
                { "PKR", ("Pakistani Rupee", "Paisa") },
                { "NPR", ("Nepalese Rupee", "Paisa") },
                { "LKR", ("Sri Lankan Rupee", "Cents") },
                { "CHF", ("Swiss Franc", "Rappen") },
                { "SEK", ("Swedish Krona", "Ore") },
                { "NOK", ("Norwegian Krone", "Ore") },
                { "DKK", ("Danish Krone", "Ore") },
                { "ZAR", ("South African Rand", "Cents") },
                { "KWD", ("Kuwaiti Dinar", "Fils") },
                { "QAR", ("Qatari Riyal", "Dirhams") },
                { "OMR", ("Omani Rial", "Baisa") },
                { "BHD", ("Bahraini Dinar", "Fils") },
                { "TRY", ("Turkish Lira", "Kurus") },
                { "RUB", ("Russian Ruble", "Kopeks") },
                { "KRW", ("South Korean Won", "Jeon") },
                { "IDR", ("Indonesian Rupiah", "Sen") },
                { "VND", ("Vietnamese Dong", "Xu") },
                { "PHP", ("Philippine Peso", "Centavos") },
                { "EGP", ("Egyptian Pound", "Piastres") },
                { "NZD", ("New Zealand Dollar", "Cents") },
                { "BRL", ("Brazilian Real", "Centavos") },
                { "MXN", ("Mexican Peso", "Centavos") }
            };

        // Only currencies using the Bangladeshi/Indian (Crore/Lakh) grouping system.
        // Everything else automatically uses the International (Million/Billion) system.
        private static readonly HashSet<string> CroreLakhCurrencies =
            new HashSet<string>(StringComparer.OrdinalIgnoreCase) { "BDT", "INR", "PKR", "NPR","USD", "EUR" };

        // Converts a Grand Total amount to words, fully automatically based on currencyCode.
        // currencyNameOverride: optional; used only if the query/table actually provides a
        // CurrencyName column. Pass null when not available (recommended default).
        private string ConvertAmountToWords(decimal amount, string currencyCode, string currencyNameOverride = null)
        {
            if (string.IsNullOrWhiteSpace(currencyCode)) currencyCode = "BDT";
            currencyCode = currencyCode.Trim();

            bool useCroreLakh = CroreLakhCurrencies.Contains(currencyCode);

            string majorUnit, minorUnit;
            if (!string.IsNullOrWhiteSpace(currencyNameOverride))
            {
                // DB explicitly gave a name -> respect it, default minor unit to "Cents"
                majorUnit = currencyNameOverride.Trim();
                minorUnit = CurrencyWordsMap.TryGetValue(currencyCode, out var overrideMinor) ? overrideMinor.Minor : "Cents";
            }
            else if (CurrencyWordsMap.TryGetValue(currencyCode, out var found))
            {
                majorUnit = found.Major;
                minorUnit = found.Minor;
            }
            else
            {
                // Unknown/new currency code: still works automatically, no manual fix needed.
                majorUnit = currencyCode;
                minorUnit = "Cents";
            }

            long integerPart = (long)Math.Floor(Math.Abs(amount));
            int fractionPart = (int)Math.Round((Math.Abs(amount) - integerPart) * 100);

            string words = integerPart == 0
                ? "Zero"
                : (useCroreLakh ? NumberToWordsBangladeshi(integerPart) : NumberToWordsInternational(integerPart));

            string result = majorUnit + " " + words;

            if (fractionPart > 0)
            {
                string fractionWords = useCroreLakh ? NumberToWordsBangladeshi(fractionPart) : NumberToWordsInternational(fractionPart);
                result += " and " + fractionWords + " " + minorUnit;
            }

            result += " Only";
            return result;
        }

        // 0-999 in words
        private string NumberToWordsBelowThousand(long n)
        {
            string s = "";
            if (n >= 100)
            {
                s += Ones[n / 100] + " Hundred ";
                n %= 100;
            }
            if (n >= 20)
            {
                s += Tens[n / 10] + " ";
                n %= 10;
                if (n > 0) s += Ones[n] + " ";
            }
            else if (n > 0)
            {
                s += Ones[n] + " ";
            }
            return s.Trim();
        }

        // Bangladeshi/Indian numbering: Crore (10,000,000), Lakh (100,000), Thousand, Hundred
        private string NumberToWordsBangladeshi(long number)
        {
            if (number == 0) return "Zero";

            string words = "";
            long crore = number / 10000000; number %= 10000000;
            long lakh = number / 100000; number %= 100000;
            long thousand = number / 1000; number %= 1000;
            long remainder = number;

            if (crore > 0) words += NumberToWordsBelowThousand(crore) + " Crore ";
            if (lakh > 0) words += NumberToWordsBelowThousand(lakh) + " Lakh ";
            if (thousand > 0) words += NumberToWordsBelowThousand(thousand) + " Thousand ";
            if (remainder > 0) words += NumberToWordsBelowThousand(remainder);

            return words.Trim();
        }

        // International numbering: Billion, Million, Thousand, Hundred
        private string NumberToWordsInternational(long number)
        {
            if (number == 0) return "Zero";

            string words = "";
            long billion = number / 1000000000; number %= 1000000000;
            long million = number / 1000000; number %= 1000000;
            long thousand = number / 1000; number %= 1000;
            long remainder = number;

            if (billion > 0) words += NumberToWordsBelowThousand(billion) + " Billion ";
            if (million > 0) words += NumberToWordsBelowThousand(million) + " Million ";
            if (thousand > 0) words += NumberToWordsBelowThousand(thousand) + " Thousand ";
            if (remainder > 0) words += NumberToWordsBelowThousand(remainder);

            return words.Trim();
        }

        #endregion
    }
}