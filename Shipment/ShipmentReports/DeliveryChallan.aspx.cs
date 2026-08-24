using Nexa_ERP.Connection;
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace Nexa_ERP.Shipment.ShipmentReports
{
    public partial class DeliveryChallan : Page
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

        private void LoadDeliveryChallanReport(int challanHeaderId)
        {
            using (SqlConnection con = conn.openConnection())
            {
                // ১. হেডার ও কোম্পানি/কাস্টমার ইনফরমেশন কুয়েরি
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

                // header row থেকে কিছু ভ্যালু গেট পাসের জন্যও পরে দরকার হবে, তাই লোকাল ভ্যারিয়েবলে রেখে দিচ্ছি
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
                            lblChallanNo.Text = reader["DeliveryChallanNumber"] != DBNull.Value ? reader["DeliveryChallanNumber"].ToString() : "";
                            lblCustomerName.Text = reader["CustomerName"] != DBNull.Value ? reader["CustomerName"].ToString() : "";
                            lblDeliveryDate.Text = reader["BranchName"] != DBNull.Value ? reader["BranchName"].ToString() : "";
                            lblCompanyName.Text = reader["BranchName"] != DBNull.Value ? reader["BranchName"].ToString() : "";
                            lblCompanyAddress.Text = reader["CustomerAddress"] != DBNull.Value ? reader["CustomerAddress"].ToString() : "";
                            txtContactPerson.Text = reader["ContactPerson"] != DBNull.Value ? reader["ContactPerson"].ToString() : "";
                            lblCustomerPhone.Text = reader["CustomerPhone"] != DBNull.Value ? reader["CustomerPhone"].ToString() : "";
                            lblCustomerEmail.Text = reader["CustomerEmail"] != DBNull.Value ? reader["CustomerEmail"].ToString() : "";
                            lblCompanyPhone.Text = reader["Phone_No"] != DBNull.Value ? reader["Phone_No"].ToString() : "";
                            lblCompanyEmail.Text = reader["E_Mail"] != DBNull.Value ? reader["E_Mail"].ToString() : "";
                            lblPreparedBy.Text = reader["full_name"] != DBNull.Value ? reader["full_name"].ToString() : "";
                            if (reader["DeliveryChallanDate"] != DBNull.Value)
                            {
                                lblDeliveryDate.Text = Convert.ToDateTime(reader["DeliveryChallanDate"]).ToString("dd-MMM-yyyy");
                            }
                            lblWoNo.Text = reader["RefWorkOrderNo"] != DBNull.Value ? reader["RefWorkOrderNo"].ToString() : "";
                            lblWoDate.Text = DateTime.Now.ToString("dd-MMM-yyyy");

                            // ---- Gate Pass এর জন্য ভ্যালুগুলো তুলে রাখা ----
                            gpChallanNo = reader["DeliveryChallanNumber"] != DBNull.Value ? reader["DeliveryChallanNumber"].ToString() : "";
                            gpDate = reader["DeliveryChallanDate"] != DBNull.Value ? Convert.ToDateTime(reader["DeliveryChallanDate"]).ToString("dd-MMM-yyyy") : DateTime.Now.ToString("dd-MMM-yyyy");
                            gpCompanyName = reader["BranchName"] != DBNull.Value ? reader["BranchName"].ToString() : "";
                            gpCompanyAddress = reader["Address"] != DBNull.Value ? reader["Address"].ToString() : "";
                            gpCustomerName = reader["CustomerName"] != DBNull.Value ? reader["CustomerName"].ToString() : "";
                            gpVehicleNo = reader["VehicleTransportNumber"] != DBNull.Value ? reader["VehicleTransportNumber"].ToString() : "";
                            gpDriverInfo = reader["DriverNameAndPhone"] != DBNull.Value ? reader["DriverNameAndPhone"].ToString() : "";
                            gpRemarks = reader["DeliveryRemarks"] != DBNull.Value ? reader["DeliveryRemarks"].ToString() : "";
                            gpPreparedBy = reader["full_name"] != DBNull.Value ? reader["full_name"].ToString() : "";
                        }
                    }
                }

                // ২. ডিটেইল আইটেম লিস্ট কুয়েরি
                string detailsQuery = @"
                    SELECT DeliveryChallanDetailID, DeliveryChallanHeaderID, SerialNumber, JobNumber, ItemName, BuyerName, StyleName, PurchaseOrderName, ColorName, SizeName, MeasurementDetails, OrderQuantityWithUnit,ReadyQuantityWithUnit, DeliveryQuantity, UnitRateAmount, RateUnitName, TotalAmount, ItemSpecificationRemarks, WorkOrderDetailsID, ItemUnit
                    FROM dbo.DeliveryChallanDetails
                    WHERE DeliveryChallanHeaderID = @ChallanHeaderID ORDER BY SerialNumber ASC, DeliveryChallanDetailID ASC";

                DataTable dt = new DataTable();

                using (SqlCommand cmd = new SqlCommand(detailsQuery, con))
                {
                    cmd.Parameters.AddWithValue("@ChallanHeaderID", challanHeaderId);
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);

                        gvChallanItems.DataSource = dt;
                        gvChallanItems.DataBind();
                    }
                }

                // ৩. আইটেম লিস্ট থেকে গেট পাসের জন্য টোটাল কোয়ান্টিটি ও লাইন সংখ্যা বের করা
                int totalLines = dt.Rows.Count;
                decimal totalQty = 0;
                foreach (DataRow row in dt.Rows)
                {
                    if (row["DeliveryQuantity"] != DBNull.Value)
                    {
                        totalQty += Convert.ToDecimal(row["DeliveryQuantity"]);
                    }
                }

                // ৪. গেট পাসের দুইটি কপি (Security Copy ও Office Copy) একই ডেটা দিয়ে পূরণ করা
                string gatePassNo = "GP-" + gpChallanNo;

                lblGpNo1.Text = gatePassNo;
                lblGpDate1.Text = gpDate;
                lblGpChallanNo1.Text = gpChallanNo;
                lblGpCompanyName1.Text = gpCompanyName;
                lblGpCompanyAddress1.Text = gpCompanyAddress;
                lblGpCustomerName1.Text = gpCustomerName;
                lblGpVehicleNo1.Text = gpVehicleNo;
                lblGpDriverInfo1.Text = gpDriverInfo;
                lblGpRemarks1.Text = gpRemarks;
                lblGpPreparedBy.Text = gpPreparedBy;
                lblGpTotalLines1.Text = totalLines.ToString();
                lblGpTotalQty1.Text = totalQty.ToString("N2");

                lblGpNo2.Text = gatePassNo;
                lblGpDate2.Text = gpDate;
                lblGpChallanNo2.Text = gpChallanNo;
                lblGpCompanyName2.Text = gpCompanyName;
                lblGpCompanyAddress2.Text = gpCompanyAddress;
                lblGpCustomerName2.Text = gpCustomerName;
                lblGpVehicleNo2.Text = gpVehicleNo;
                lblGpDriverInfo2.Text = gpDriverInfo;
                lblGpRemarks2.Text = gpRemarks;
                lblGpPreparedBy2.Text = gpPreparedBy;
                lblGpTotalLines2.Text = totalLines.ToString();
                lblGpTotalQty2.Text = totalQty.ToString("N2");
            }
        }
    }
}
