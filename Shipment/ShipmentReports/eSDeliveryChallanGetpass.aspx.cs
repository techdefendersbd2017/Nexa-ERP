using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.Shipment.ShipmentReports
{
    public partial class eSDeliveryChallanGetpass : System.Web.UI.Page
    {
        // Web.config থেকে কানেকশন স্ট্রিং রিড করার ব্যবস্থা
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // URL থেকে DeliveryChallanHeaderID নেওয়া (যেমন: DeliveryChallan.aspx?challanId=10)
                if (Request.QueryString["challanId"] != null)
                {
                    if (int.TryParse(Request.QueryString["challanId"], out int challanHeaderId))
                    {
                        LoadDeliveryChallanReport(challanHeaderId);
                    }
                }
            }
        }

        /// <summary>
        /// DataReader থেকে নিরাপদে string ভ্যালু পড়ার হেল্পার মেথড।
        /// কলামটি রিডারে না থাকলে exception না দিয়ে খালি string রিটার্ন করবে।
        /// </summary>
        private static string SafeGetString(SqlDataReader reader, string columnName)
        {
            try
            {
                int ordinal = reader.GetOrdinal(columnName);
                return reader.IsDBNull(ordinal) ? "" : reader.GetValue(ordinal).ToString();
            }
            catch (IndexOutOfRangeException)
            {
                // কলামটি কুয়েরিতে নেই -> খালি রাখা হলো
                return "";
            }
        }

        private static decimal SafeGetDecimal(DataRow row, string columnName)
        {
            if (row.Table.Columns.Contains(columnName) && row[columnName] != DBNull.Value)
            {
                decimal.TryParse(row[columnName].ToString(), out decimal val);
                return val;
            }
            return 0;
        }

        private static string SafeGetString(DataRow row, string columnName)
        {
            if (row.Table.Columns.Contains(columnName) && row[columnName] != DBNull.Value)
            {
                return row[columnName].ToString();
            }
            return "";
        }

        private void LoadDeliveryChallanReport(int challanHeaderId)
        {
            using (SqlConnection con = conn.openConnection())
            {
                // =====================================================================
                // ১. হেডার ও কোম্পানি/কাস্টমার ইনফরমেশন কুয়েরি
                //    (আগের কুয়েরির কলামগুলোই রাখা হয়েছে যাতে এক্সিস্টিং ডেটাবেজে ভাঙে না)
                // =====================================================================
                string headerQuery = @"
                        SELECT        h.DeliveryChallanNumber, h.DeliveryChallanDate, h.WorkOrderReceiveID, h.VehicleTransportNumber, h.DriverNameAndPhone, h.DeliveryRemarks, p.PartyName AS CustomerName, p.Address AS CustomerAddress, 
                        b.Branch_Name AS BranchName, b.Web, b.Phone_No, b.E_Mail, b.Address, p.ContactPerson, p.Phone AS CustomerPhone, p.Email AS CustomerEmail, WorkOrderHeader.RefWorkOrderNo, WorkOrderHeader.WORcvNo, 
                        dbo.vw_User_Information_Top1000.full_name, b.Branch_Logo
                        FROM            dbo.DeliveryChallanHeader h INNER JOIN
                        WorkOrderHeader ON h.WorkOrderReceiveID = WorkOrderHeader.WORcvID INNER JOIN
                        dbo.vw_User_Information_Top1000 ON h.CreatedByUserID = dbo.vw_User_Information_Top1000.user_id LEFT OUTER JOIN
                        tbl_CustomerSupplier p ON h.CustomerPartyID = p.PartyID LEFT OUTER JOIN
                        vw_Branch_Information b ON h.ReceivingBranchID = b.Branch_ID
                                    WHERE h.DeliveryChallanHeaderID = @ChallanHeaderID AND h.IsActive = 1";

                // Gate Pass ও নতুন যোগ হওয়া ফিল্ডগুলোর জন্য লোকাল ভ্যারিয়েবল
                string gpChallanNo = "";
                string gpDate = "";
                string gpCompanyName = "";
                string gpCompanyAddress = "";
                string gpCustomerName = "";
                string gpVehicleNo = "";
                string gpDriverInfo = "";
                string gpRemarks = "";
                string gpPreparedBy = "";

                using (SqlCommand cmd = new SqlCommand(headerQuery, con))
                {
                    cmd.Parameters.AddWithValue("@ChallanHeaderID", challanHeaderId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            // ---------- Challan হেডার ----------
                            lblChallanNo.Text = SafeGetString(reader, "DeliveryChallanNumber");
                            lblChallanNoDisplay.Text = lblChallanNo.Text;
                            lblChallan.Text = SafeGetString(reader, "DeliveryChallanNumber");
                            lblCustomerName.Text = SafeGetString(reader, "CustomerName");
                            lblCompanyName.Text = SafeGetString(reader, "BranchName");
                            lblCompanyAddress.Text = SafeGetString(reader, "Address");
                            lblCustomerAddress.Text = SafeGetString(reader, "CustomerAddress");
                            lblCustomerBillingAddress.Text = SafeGetString(reader, "CustomerAddress");
                            txtContactPerson.Text = SafeGetString(reader, "ContactPerson");
                            lblCompanyPhone.Text = SafeGetString(reader, "Phone_No");
                            lblCompanyEmail.Text = SafeGetString(reader, "E_Mail");
                            lblPreparedBy.Text = SafeGetString(reader, "full_name");
                            lblPreparedDate.Text = DateTime.Now.ToString("dd-MMM-yyyy hh:mm tt");

                            string dcDate = SafeGetString(reader, "DeliveryChallanDate");
                            if (!string.IsNullOrEmpty(dcDate) && DateTime.TryParse(dcDate, out DateTime parsedDcDate))
                            {
                                lblChallanDate.Text = parsedDcDate.ToString("dd-MMM-yyyy");
                            }

                            lblWoNo.Text = SafeGetString(reader, "RefWorkOrderNo");

                            try
                            {
                                int logoOrdinal = reader.GetOrdinal("Branch_Logo");
                                if (!reader.IsDBNull(logoOrdinal))
                                {
                                    object logoValue = reader.GetValue(logoOrdinal);
                                    string logoUrl = null;

                                    if (logoValue is byte[] logoBytes && logoBytes.Length > 0)
                                    {
                                        // varbinary/image টাইপ হলে -> base64 data URI
                                        logoUrl = "data:image/png;base64," + Convert.ToBase64String(logoBytes);
                                    }
                                    else if (logoValue is string logoPath && !string.IsNullOrWhiteSpace(logoPath))
                                    {
                                        // string টাইপ হলে -> সরাসরি path/URL হিসেবে ব্যবহার
                                        logoUrl = logoPath.StartsWith("~") ? ResolveUrl(logoPath) : logoPath;
                                    }

                                    if (!string.IsNullOrEmpty(logoUrl))
                                    {
                                        imgCompanyLogo.ImageUrl = logoUrl;
                                        imgGpLogo.ImageUrl = logoUrl;
                                    }
                                }
                            }
                            catch (IndexOutOfRangeException)
                            {
                                // কলাম না পাওয়া গেলে ডিফল্ট ~/Images/logo.png-ই থেকে যাবে (markup-এ যা আছে)
                            }

                            // ---------- নিচের ফিল্ডগুলো এই মুহূর্তে headerQuery-তে নেই ----------
                            // TODO: আপনার আসল টেবিল/কলামের নাম বসিয়ে headerQuery-তে যোগ করুন,
                            // তারপর SafeGetString(reader, "কলামের নাম") দিয়ে ভ্যালু বসান।
                            lblPoNo.Text = SafeGetString(reader, "PurchaseOrderNo");          // TODO: প্রকৃত PO কলাম
                            lblBuyerName.Text = SafeGetString(reader, "BuyerName");            // TODO: প্রকৃত Buyer কলাম
                            lblPiNo.Text = SafeGetString(reader, "PINo");                      // TODO: প্রকৃত PI No কলাম
                            lblFscCoc.Text = SafeGetString(reader, "FscCoc");                  // TODO: প্রকৃত FSC-COC কলাম
                            lblJobBagNo.Text = SafeGetString(reader, "JobBagNo");               // TODO: প্রকৃত Job Bag No কলাম
                            lblMarketing.Text = SafeGetString(reader, "MarketingPersonName");   // TODO: প্রকৃত Marketing কলাম
                            lblCsName.Text = SafeGetString(reader, "CSPersonName");             // TODO: প্রকৃত CS Name কলাম

                            lblDeliveryBy.Text = SafeGetString(reader, "DeliveryByName");        // TODO
                            lblBoxCount.Text = SafeGetString(reader, "BoxCount");                // TODO
                            lblNetWeight.Text = SafeGetString(reader, "NetWeight");              // TODO
                            lblGrossWeight.Text = SafeGetString(reader, "GrossWeight");           // TODO
                            lblTrackingNo.Text = SafeGetString(reader, "TrackingNo");             // TODO

                            // ---------- Gate Pass এর জন্য ভ্যালুগুলো তুলে রাখা ----------
                            gpChallanNo = SafeGetString(reader, "DeliveryChallanNumber");
                            gpDate = !string.IsNullOrEmpty(dcDate) && DateTime.TryParse(dcDate, out DateTime gDate)
                                        ? gDate.ToString("dd-MMM-yyyy")
                                        : DateTime.Now.ToString("dd-MMM-yyyy");
                            gpCompanyName = SafeGetString(reader, "BranchName");
                            gpCompanyAddress = SafeGetString(reader, "Address");
                            gpCustomerName = SafeGetString(reader, "CustomerName");
                            gpVehicleNo = SafeGetString(reader, "VehicleTransportNumber");
                            gpDriverInfo = SafeGetString(reader, "DriverNameAndPhone");
                            gpRemarks = SafeGetString(reader, "DeliveryRemarks");
                            gpPreparedBy = SafeGetString(reader, "full_name");
                        }
                    }
                }

                // =====================================================================
                // ২. ডিটেইল আইটেম লিস্ট কুয়েরি
                // =====================================================================
                string detailsQuery = @"
                    SELECT DeliveryChallanDetailID, DeliveryChallanHeaderID, SerialNumber, JobNumber, ItemName, BuyerName,
                    StyleName, PurchaseOrderName, ColorName, SizeName, MeasurementDetails, OrderQuantityWithUnit,
                    ReadyQuantityWithUnit, DeliveryQuantity, UnitRateAmount, RateUnitName, TotalAmount,
                    ItemSpecificationRemarks, WorkOrderDetailsID, ItemUnit
                    FROM dbo.DeliveryChallanDetails
                    WHERE DeliveryChallanHeaderID = @ChallanHeaderID ORDER BY SerialNumber ASC, DeliveryChallanDetailID ASC";

                DataTable dt = new DataTable();

                using (SqlCommand cmd = new SqlCommand(detailsQuery, con))
                {
                    cmd.Parameters.AddWithValue("@ChallanHeaderID", challanHeaderId);
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                }

                // ---------- নতুন গ্রিডের কলামগুলোর সাথে ম্যাপ করার জন্য DataTable রিশেপ ----------
                // নতুন ডিজাইনের টেবিলে কিছু কলাম আছে যা মূল detailsQuery-তে নেই
                // (SubCategoryName, BookingNo, JobNo, PoNo, ItemNo, Measurement, OrderQty, PChallanQty, ChallanQty, BalanceQty)
                // তাই যেগুলো ম্যাপ করা যায় সেগুলো এখানে রিনেম/কপি করে দেওয়া হলো, বাকিগুলো TODO হিসেবে খালি থাকবে।
                DataTable gridTable = new DataTable();
                gridTable.Columns.Add("SubCategoryName", typeof(string));   // TODO: আসল সাব-ক্যাটাগরি কলাম বসান
                gridTable.Columns.Add("BookingNo", typeof(string));         // TODO: আসল বুকিং নং কলাম বসান
                gridTable.Columns.Add("StyleName", typeof(string));
                gridTable.Columns.Add("JobNo", typeof(string));
                gridTable.Columns.Add("PoNo", typeof(string));
                gridTable.Columns.Add("ItemNo", typeof(string));            // TODO: আসল Item No কলাম বসান
                gridTable.Columns.Add("ColorName", typeof(string));
                gridTable.Columns.Add("SizeName", typeof(string));
                gridTable.Columns.Add("Measurement", typeof(string));
                gridTable.Columns.Add("ItemName", typeof(string));
                gridTable.Columns.Add("OrderQty", typeof(decimal));         // TODO: numeric Order Qty কলাম বসান
                gridTable.Columns.Add("PChallanQty", typeof(decimal));      // TODO: Previous Challan Qty কলাম বসান
                gridTable.Columns.Add("ChallanQty", typeof(decimal));
                gridTable.Columns.Add("BalanceQty", typeof(decimal));       // OrderQty - (PChallanQty + ChallanQty) হিসেবে নিচে ক্যালকুলেট করা হচ্ছে
                gridTable.Columns.Add("ItemUnit", typeof(string));
                gridTable.Columns.Add("Remarks", typeof(string));

                decimal totalOrderQty = 0, totalPChallanQty = 0, totalChallanQty = 0, totalBalanceQty = 0;

                foreach (DataRow src in dt.Rows)
                {
                    DataRow row = gridTable.NewRow();

                    row["SubCategoryName"] = SafeGetString(src, "BuyerName"); // TODO: আসল Sub Category কলাম দিয়ে বদলান
                    row["BookingNo"] = "";                                     // TODO
                    row["StyleName"] = SafeGetString(src, "StyleName");
                    row["JobNo"] = SafeGetString(src, "JobNumber");
                    row["PoNo"] = SafeGetString(src, "PurchaseOrderName");
                    row["ItemNo"] = "";                                        // TODO
                    row["ColorName"] = SafeGetString(src, "ColorName");
                    row["SizeName"] = SafeGetString(src, "SizeName");
                    row["Measurement"] = SafeGetString(src, "MeasurementDetails");
                    row["ItemName"] = SafeGetString(src, "ItemName");

                    decimal orderQty = SafeGetDecimal(src, "OrderQuantityWithUnit");   // মূল কলামে ইউনিট টেক্সট মেশানো থাকতে পারে, TODO: numeric কলাম দিন
                    decimal pChallanQty = SafeGetDecimal(src, "ReadyQuantityWithUnit"); // TODO: আসল Previous Challan Qty কলাম দিন
                    decimal challanQty = SafeGetDecimal(src, "DeliveryQuantity");
                    decimal balanceQty = orderQty - (pChallanQty + challanQty);
                    if (balanceQty < 0) balanceQty = 0;

                    row["OrderQty"] = orderQty;
                    row["PChallanQty"] = pChallanQty;
                    row["ChallanQty"] = challanQty;
                    row["BalanceQty"] = balanceQty;

                    row["ItemUnit"] = SafeGetString(src, "ItemUnit");
                    row["Remarks"] = SafeGetString(src, "ItemSpecificationRemarks");

                    gridTable.Rows.Add(row);

                    totalOrderQty += orderQty;
                    totalPChallanQty += pChallanQty;
                    totalChallanQty += challanQty;
                    totalBalanceQty += balanceQty;
                }

                gvChallanItems.DataSource = gridTable;
                gvChallanItems.DataBind();

                // ---------- ফুটার রো-তে টোটাল বসানো ----------
                if (gvChallanItems.FooterRow != null)
                {
                    gvChallanItems.FooterRow.Cells[11].Text = totalOrderQty.ToString("N0");
                    gvChallanItems.FooterRow.Cells[12].Text = totalPChallanQty.ToString("N0");
                    gvChallanItems.FooterRow.Cells[13].Text = totalChallanQty.ToString("N0");
                    gvChallanItems.FooterRow.Cells[14].Text = totalBalanceQty.ToString("N0");
                }

                // =====================================================================
                // ৩. গেট পাস পেজ পূরণ করা (এখন একটাই কপি, আগে দুইটা কপি ছিল)
                // =====================================================================
                int totalLines = dt.Rows.Count;

                // TODO: প্রকৃত Gate Pass নাম্বার যদি আলাদা টেবিল থেকে আসে, সেই কুয়েরি এখানে বসান।
                // আপাতত Challan নাম্বারের উপর ভিত্তি করে একটা প্লেসহোল্ডার নাম্বার তৈরি করা হলো।
                string gatePassNo = "GPN-" + gpChallanNo;

                lblGpNo.Text = gatePassNo;
                lblGpNoDisplayH.Text = gatePassNo;
                lblGpNoDisplay.Text = gatePassNo;
                lblGpDate.Text = gpDate;
                lblGpCompanyName.Text = gpCompanyName;
                lblGpCompanyAddress.Text = gpCompanyAddress;
                lblGpCustomerName.Text = gpCustomerName;
                lblGpVehicleNo.Text = gpVehicleNo;
                lblGpPreparedBy.Text = gpPreparedBy;
                lblGpPreparedDate.Text = DateTime.Now.ToString("dd-MMM-yyyy hh:mm tt");

                lblGpJobNo.Text = "";                       // TODO: Gate Pass এর Job No কলাম বসান (ছবিতে "PFL-000037-2026")
                lblGpDeliveryFactory.Text = gpCustomerName; // TODO: প্রকৃত "Delivery Factory" কলাম থাকলে সেটা বসান; আপাতত Customer নাম দেখানো হচ্ছে
                lblGpBuyer.Text = "";                        // TODO: Buyer নাম কলাম বসান (ছবিতে "C&A")

                // ---------- Delivery Man / Driver আলাদা করা ----------
                // মূল ডেটাবেজে DriverNameAndPhone একটাই কম্বাইন্ড ফিল্ড।
                // ছবিতে Delivery Man আলাদা এবং Driver Name/Phone আলাদা বক্স।
                // TODO: যদি ডেটাবেজে আলাদা DeliveryManName/DeliveryManPhone/DriverName/DriverPhone কলাম থাকে
                // তাহলে headerQuery-তে যোগ করে সরাসরি বসান। আপাতত কম্বাইন্ড ফিল্ডটি Delivery Man হিসেবে বসানো হলো।
                lblGpDeliveryMan.Text = gpDriverInfo;
                lblGpDeliveryManMobile.Text = "";
                lblGpDriverName.Text = "";
                lblGpDriverMobile.Text = "";

                // ---------- গেট পাসের আইটেম গ্রিড ----------
                DataTable gpGrid = new DataTable();
                gpGrid.Columns.Add("ItemName", typeof(string));
                gpGrid.Columns.Add("ChallanNo", typeof(string));
                gpGrid.Columns.Add("ChallanQty", typeof(decimal));
                gpGrid.Columns.Add("ItemUnit", typeof(string));
                gpGrid.Columns.Add("Remarks", typeof(string));

                decimal gpTotalQty = 0;
                foreach (DataRow src in dt.Rows)
                {
                    DataRow row = gpGrid.NewRow();
                    row["ItemName"] = SafeGetString(src, "ItemName");
                    row["ChallanNo"] = gpChallanNo;
                    decimal qty = SafeGetDecimal(src, "DeliveryQuantity");
                    row["ChallanQty"] = qty;
                    row["ItemUnit"] = SafeGetString(src, "ItemUnit");
                    row["Remarks"] = SafeGetString(src, "ItemSpecificationRemarks");
                    gpGrid.Rows.Add(row);
                    gpTotalQty += qty;
                }

                gvGatePassItems.DataSource = gpGrid;
                gvGatePassItems.DataBind();

                // ---------- ফুটার রো-তে "Total QTY:" মার্জ করে বসানো ----------
                // TableItemStyle-এ ColumnSpan প্রপার্টি নেই, তাই মার্কআপে ColumnSpan সেট করা যায় না।
                // এখানে সরাসরি TableCell.ColumnSpan সেট করে ২টা এক্সট্রা সেল রিমুভ করে মার্জ করা হচ্ছে।
                // কলাম অর্ডার: 0=SL, 1=ItemName, 2=ChallanNo, 3=ChallanQty, 4=UoM, 5=Remarks
                if (gvGatePassItems.FooterRow != null)
                {
                    TableRow footerRow = gvGatePassItems.FooterRow;

                    footerRow.Cells[0].Text = "Total QTY:";
                    footerRow.Cells[0].HorizontalAlign = HorizontalAlign.Right;
                    footerRow.Cells[0].ColumnSpan = 3; // SL + Item + Challan No মার্জ

                    // মার্জ হয়ে যাওয়া কলাম ২টা (ItemName, ChallanNo) রিমুভ করা - পেছন থেকে রিমুভ করতে হবে যেন index না ঘুরে যায়
                    footerRow.Cells.RemoveAt(2);
                    footerRow.Cells.RemoveAt(1);

                    // এখন index শিফট হয়ে গেছে: index1 = ChallanQty, index2 = UoM, index3 = Remarks
                    footerRow.Cells[1].Text = gpTotalQty.ToString("N0");
                    footerRow.Cells[1].HorizontalAlign = HorizontalAlign.Right;
                }
            }
        }
    }
}
