using Nexa_ERP.Connection;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.Shipment
{
    public partial class DeliveryChallanAndBill : System.Web.UI.Page
    {
        SqlConnection con;
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtChallanNo.Text = LoadDeliveryChallanNo();
                txtInvoiceNo.Text = LoadInvoiceNo();

                LoadReceivingBranch();
                LoadPartyName();
                LoadChallanList();
            }
        }

        // ==================== LIST ====================
        private void LoadChallanList()
        {
            try
            {
                con = conn.openConnection();
                string query = @"
                    SELECT 
                        ROW_NUMBER() OVER (ORDER BY dch.DeliveryChallanHeaderID DESC) AS SL,
                        dch.DeliveryChallanHeaderID,
                        dch.DeliveryChallanNumber AS ChallanNo,
                        CONVERT(VARCHAR(10), dch.DeliveryChallanDate, 120) AS ChallanDate,
                        ISNULL(wo.RefWorkOrderNo, wo.WORcvNo) AS WORefNo,
                        cs.PartyName AS Customer,
                        ISNULL(cb.GrandTotalAmount, 0) AS BillAmount
                    FROM DeliveryChallanHeader dch
                    LEFT JOIN CommercialBillHeader cb 
                           ON cb.DeliveryChallanHeaderID = dch.DeliveryChallanHeaderID 
                          AND cb.IsActive = 1
                    LEFT JOIN tbl_CustomerSupplier cs 
                           ON cs.PartyID = dch.CustomerPartyID
                    LEFT JOIN WorkOrderHeader wo 
                           ON wo.WORcvID = dch.WorkOrderReceiveID
                    WHERE dch.IsActive = 1
                    ORDER BY dch.DeliveryChallanHeaderID DESC";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    gvChallans.DataSource = dt;
                    gvChallans.DataBind();
                }
            }
            catch (Exception ex)
            {
                ShowAlert("Error: " + ex.Message);
            }
            finally
            {
                CloseConnection();
            }
        }

        // ==================== GRID ROW COMMAND (Edit বাটন) ====================
        protected void gvChallans_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "EditChallan")
            {
                int challanHeaderID = Convert.ToInt32(e.CommandArgument);
                LoadChallanForEdit(challanHeaderID);
            }
        }

        private void LoadChallanForEdit(int challanHeaderID)
        {
            try
            {
                con = conn.openConnection();

                // ---------- Header + Bill ----------
                string headerQuery = @"
                    SELECT dch.*, 
                           cb.InvoiceNumber, cb.BillDate, cb.PaymentTerms,
                           cb.SubTotalAmount, cb.TransportCostAmount, cb.VatPercentage, cb.GrandTotalAmount
                    FROM DeliveryChallanHeader dch
                    LEFT JOIN CommercialBillHeader cb 
                           ON cb.DeliveryChallanHeaderID = dch.DeliveryChallanHeaderID AND cb.IsActive = 1
                    WHERE dch.DeliveryChallanHeaderID = @ID";

                DataTable dtHeader = new DataTable();
                using (SqlCommand cmd = new SqlCommand(headerQuery, con))
                {
                    cmd.Parameters.AddWithValue("@ID", challanHeaderID);
                    new SqlDataAdapter(cmd).Fill(dtHeader);
                }

                if (dtHeader.Rows.Count == 0)
                {
                    ShowAlert("Challan not found (ID: " + challanHeaderID + ")");
                    return;
                }

                DataRow h = dtHeader.Rows[0];

                hdnChallanHeaderID.Value = challanHeaderID.ToString();

                txtChallanNo.Text = h["DeliveryChallanNumber"].ToString();

                if (h["DeliveryTypeID"] != DBNull.Value)
                    ddlDeliveryType.SelectedValue = h["DeliveryTypeID"].ToString();

                txtChallanDate.Text = Convert.ToDateTime(h["DeliveryChallanDate"]).ToString("yyyy-MM-dd");
                txtVehicle.Text = h["VehicleTransportNumber"] as string;
                txtDriver.Text = h["DriverNameAndPhone"] as string;
                txtRemarks.Text = h["DeliveryRemarks"] as string;

                if (h["ReceivingBranchID"] != DBNull.Value)
                    ddlReceivingBranch.SelectedValue = h["ReceivingBranchID"].ToString();

                // Work Order dropdown লোড করার জন্য আগে Branch দরকার (LoadWorkOrderList এটাই ব্যবহার করে)
                LoadWorkOrderList();

                if (h["WorkOrderReceiveID"] != DBNull.Value &&
                    ddlWorkOrder.Items.FindByValue(h["WorkOrderReceiveID"].ToString()) != null)
                {
                    ddlWorkOrder.SelectedValue = h["WorkOrderReceiveID"].ToString();
                }

                if (h["CustomerPartyID"] != DBNull.Value &&
                    ddlCustomer.Items.FindByValue(h["CustomerPartyID"].ToString()) != null)
                {
                    ddlCustomer.SelectedValue = h["CustomerPartyID"].ToString();
                }

                if (h["InvoiceNumber"] != DBNull.Value)
                {
                    txtInvoiceNo.Text = h["InvoiceNumber"].ToString();
                    txtBillDate.Text = Convert.ToDateTime(h["BillDate"]).ToString("yyyy-MM-dd");
                    txtPaymentTerms.Text = h["PaymentTerms"] as string;
                    txtSubTotal.Text = Convert.ToDecimal(h["SubTotalAmount"]).ToString("0.00");
                    txtTransport.Text = Convert.ToDecimal(h["TransportCostAmount"]).ToString("0.00");
                    txtVat.Text = Convert.ToDecimal(h["VatPercentage"]).ToString("0.00");
                    txtGrandTotal.Text = Convert.ToDecimal(h["GrandTotalAmount"]).ToString("0.00");
                }

                // ---------- Item Details ----------
                string detailQuery = "SELECT * FROM DeliveryChallanDetails WHERE DeliveryChallanHeaderID=@ID ORDER BY SerialNumber";
                DataTable dtDetail = new DataTable();
                using (SqlCommand cmd = new SqlCommand(detailQuery, con))
                {
                    cmd.Parameters.AddWithValue("@ID", challanHeaderID);
                    new SqlDataAdapter(cmd).Fill(dtDetail);
                }

                DataTable gridDt = new DataTable();
                foreach (string col in new[] { "JobNo","ItemName","Buyer","Style","POName","Color","Size",
                    "Measurement","WOQty","ReadyQty","ChallanQty","UnitRate","RateUnit","TotalAmount","ItemRemarks" })
                    gridDt.Columns.Add(col);

                foreach (DataRow d in dtDetail.Rows)
                {
                    DataRow r = gridDt.NewRow();
                    r["JobNo"] = d["JobNumber"];
                    r["ItemName"] = d["ItemName"];
                    r["Buyer"] = d["BuyerName"];
                    r["Style"] = d["StyleName"];
                    r["POName"] = d["PurchaseOrderName"];
                    r["Color"] = d["ColorName"];
                    r["Size"] = d["SizeName"];
                    r["Measurement"] = d["MeasurementDetails"];
                    r["WOQty"] = d["OrderQuantityWithUnit"];
                    r["ReadyQty"] = d["ReadyQuantityWithUnit"];
                    r["ChallanQty"] = d["DeliveryQuantity"];
                    r["UnitRate"] = d["UnitRateAmount"];
                    r["RateUnit"] = d["RateUnitName"];
                    r["TotalAmount"] = d["TotalAmount"];
                    r["ItemRemarks"] = d["ItemSpecificationRemarks"];
                    gridDt.Rows.Add(r);
                }

                gvDeliveryItems.DataSource = gridDt;
                gvDeliveryItems.DataBind();

                // postback হওয়ায় JS প্যানেল ক্লাস রিসেট হয়ে যায় — তাই আবার active করে দেওয়া হচ্ছে
                RunScript("showPanel('pnlForm'); calculateTotal();");
            }
            catch (Exception ex)
            {
                ShowAlert("Error: " + ex.Message);
            }
            finally
            {
                CloseConnection();
            }
        }

        // ==================== DROPDOWNS ====================
        protected void ddlCustomer_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadWorkOrderList();
        }

        protected void ddlWorkOrder_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadDeliveryItems(ddlWorkOrder.SelectedValue);
        }

        private void LoadWorkOrderList()
        {
            try
            {
                con = conn.openConnection();
                string query = @"SELECT WORcvID, WORcvNo + '' + RefWorkOrderNo AS WORcvNoRefWorkOrderNo 
                                  FROM WorkOrderHeader 
                                  WHERE ReceivingBranchID = @BranchID AND IsActive = 1 
                                  ORDER BY WORcvNoRefWorkOrderNo";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@BranchID",
                        string.IsNullOrEmpty(ddlReceivingBranch.SelectedValue) ? (object)DBNull.Value : ddlReceivingBranch.SelectedValue);

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlWorkOrder.DataSource = dt;
                    ddlWorkOrder.DataTextField = "WORcvNoRefWorkOrderNo";
                    ddlWorkOrder.DataValueField = "WORcvID";
                    ddlWorkOrder.DataBind();

                    ddlWorkOrder.Items.Insert(0, new ListItem("-- Select Work Order --", "0"));
                }
            }
            catch (Exception ex)
            {
                ShowAlert("Error: " + ex.Message);
            }
            finally
            {
                CloseConnection();
            }
        }

        private void LoadDeliveryItems(string worcvID)
        {
            if (string.IsNullOrEmpty(worcvID) || worcvID == "0")
            {
                gvDeliveryItems.DataSource = null;
                gvDeliveryItems.DataBind();
                return;
            }

            try
            {
                con = conn.openConnection();
                string query = @"SELECT WORcvID, JobNo, ItemName, Buyer, Style, PO AS POName, 
                                 ColorName, Size, Measurement, ReqQty, Unit, TotalReqQty, 
                                 RateUnit, RateUnitName, TotalAmount, Remarks,
                                 SubTotalAmount, TransportCost, VatPercent, GrandTotal
                          FROM vw_WorkOrderComplete
                          WHERE WORcvID = @WORcvID";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@WORcvID", worcvID);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count > 0)
                    {
                        DataTable gridDt = new DataTable();
                        foreach (string col in new[] { "JobNo","ItemName","Buyer","Style","POName","Color","Size",
                            "Measurement","WOQty","ReadyQty","ChallanQty","UnitRate","RateUnit","TotalAmount","ItemRemarks" })
                            gridDt.Columns.Add(col);

                        foreach (DataRow row in dt.Rows)
                        {
                            DataRow gridRow = gridDt.NewRow();
                            gridRow["JobNo"] = row["JobNo"];
                            gridRow["ItemName"] = row["ItemName"];
                            gridRow["Buyer"] = row["Buyer"];
                            gridRow["Style"] = row["Style"];
                            gridRow["POName"] = row["POName"];
                            gridRow["Color"] = row["ColorName"];
                            gridRow["Size"] = row["Size"];
                            gridRow["Measurement"] = row["Measurement"];
                            gridRow["WOQty"] = row["ReqQty"] + " " + row["Unit"];
                            gridRow["ReadyQty"] = 0 + " " + row["Unit"];
                            gridRow["ChallanQty"] = 0;
                            gridRow["UnitRate"] = row["RateUnit"];
                            gridRow["RateUnit"] = row["RateUnitName"];
                            gridRow["TotalAmount"] = row["TotalAmount"];
                            gridRow["ItemRemarks"] = row["Remarks"];
                            gridDt.Rows.Add(gridRow);
                        }

                        gvDeliveryItems.DataSource = gridDt;
                        gvDeliveryItems.DataBind();

                        DataRow h = dt.Rows[0];
                        txtSubTotal.Text = Convert.ToDecimal(h["SubTotalAmount"]).ToString("0.00");
                        txtTransport.Text = Convert.ToDecimal(h["TransportCost"]).ToString("0.00");
                        txtVat.Text = Convert.ToDecimal(h["VatPercent"]).ToString("0.00");
                        txtGrandTotal.Text = Convert.ToDecimal(h["GrandTotal"]).ToString("0.00");
                    }
                    else
                    {
                        gvDeliveryItems.DataSource = null;
                        gvDeliveryItems.DataBind();
                    }
                }
            }
            catch (Exception ex)
            {
                ShowAlert("Error: " + ex.Message);
            }
            finally
            {
                CloseConnection();
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

                    ddlCustomer.DataSource = dt;
                    ddlCustomer.DataTextField = "PartyName";
                    ddlCustomer.DataValueField = "PartyID";
                    ddlCustomer.DataBind();

                    ddlCustomer.Items.Insert(0, new ListItem("--Select Party Name--", "0"));
                }
            }
            catch (Exception ex)
            {
                ShowAlert("Error: " + ex.Message);
            }
            finally
            {
                CloseConnection();
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

                    ddlReceivingBranch.DataSource = dt;
                    ddlReceivingBranch.DataTextField = "Branch_Name";
                    ddlReceivingBranch.DataValueField = "Branch_ID";
                    ddlReceivingBranch.DataBind();
                }
            }
            catch (Exception ex)
            {
                ShowAlert("Error: " + ex.Message);
            }
            finally
            {
                CloseConnection();
            }
        }

        private string LoadDeliveryChallanNo()
        {
            string prefix = "CH-" + DateTime.Today.Year + "-";
            int nextNumber = 1;
            return prefix + nextNumber.ToString("D6");
        }

        private string LoadInvoiceNo()
        {
            string prefix = "INV-" + DateTime.Today.Year + "-";
            int nextNumber = 1;
            return prefix + nextNumber.ToString("D6");
        }

        protected void gvDeliveryItems_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            // প্রয়োজনে ভবিষ্যতে ব্যবহার
        }

        // ==================== SAVE ====================
        protected void btnSave_Click(object sender, EventArgs e)
        {
            con = conn.openConnection();
            SqlTransaction transaction = con.BeginTransaction();

            try
            {
                int challanHeaderID = Convert.ToInt32(hdnChallanHeaderID.Value);
                bool isUpdateMode = challanHeaderID > 0;

                if (!isUpdateMode)
                {
                    string insertChallanQuery = @"
                        INSERT INTO DeliveryChallanHeader
                            (DeliveryChallanNumber, DeliveryTypeID, DeliveryChallanDate, VehicleTransportNumber,
                             DriverNameAndPhone, DeliveryRemarks, ReceivingBranchID, CustomerPartyID,
                             WorkOrderReceiveID, CreatedByUserID, CreatedDate, IsActive)
                        VALUES
                            (@DeliveryChallanNumber, @DeliveryTypeID, @DeliveryChallanDate, @VehicleTransportNumber,
                             @DriverNameAndPhone, @DeliveryRemarks, @ReceivingBranchID, @CustomerPartyID,
                             @WorkOrderReceiveID, @CreatedByUserID, GETDATE(), 1);
                        SELECT SCOPE_IDENTITY();";

                    using (SqlCommand cmd = new SqlCommand(insertChallanQuery, con, transaction))
                    {
                        AddChallanHeaderParameters(cmd);
                        challanHeaderID = Convert.ToInt32(cmd.ExecuteScalar());
                    }
                }
                else
                {
                    string updateChallanQuery = @"
                        UPDATE DeliveryChallanHeader SET
                            DeliveryTypeID = @DeliveryTypeID,
                            DeliveryChallanDate = @DeliveryChallanDate,
                            VehicleTransportNumber = @VehicleTransportNumber,
                            DriverNameAndPhone = @DriverNameAndPhone,
                            DeliveryRemarks = @DeliveryRemarks,
                            ReceivingBranchID = @ReceivingBranchID,
                            CustomerPartyID = @CustomerPartyID,
                            WorkOrderReceiveID = @WorkOrderReceiveID
                        WHERE DeliveryChallanHeaderID = @DeliveryChallanHeaderID";

                    using (SqlCommand cmd = new SqlCommand(updateChallanQuery, con, transaction))
                    {
                        AddChallanHeaderParameters(cmd);
                        cmd.Parameters.AddWithValue("@DeliveryChallanHeaderID", challanHeaderID);
                        cmd.ExecuteNonQuery();
                    }
                }

                int billHeaderID = 0;
                string checkBillQuery = "SELECT CommercialBillHeaderID FROM CommercialBillHeader WHERE DeliveryChallanHeaderID = @DeliveryChallanHeaderID";
                using (SqlCommand cmd = new SqlCommand(checkBillQuery, con, transaction))
                {
                    cmd.Parameters.AddWithValue("@DeliveryChallanHeaderID", challanHeaderID);
                    object result = cmd.ExecuteScalar();
                    if (result != null) billHeaderID = Convert.ToInt32(result);
                }

                if (billHeaderID == 0)
                {
                    string insertBillQuery = @"
                        INSERT INTO CommercialBillHeader
                            (DeliveryChallanHeaderID, InvoiceNumber, BillDate, PaymentTerms,
                             SubTotalAmount, TransportCostAmount, VatPercentage, GrandTotalAmount,
                             PaymentStatus, PaidAmount, CreatedByUserID, CreatedDate, IsActive)
                        VALUES
                            (@DeliveryChallanHeaderID, @InvoiceNumber, @BillDate, @PaymentTerms,
                             @SubTotalAmount, @TransportCostAmount, @VatPercentage, @GrandTotalAmount,
                             'Unpaid', 0, @CreatedByUserID, GETDATE(), 1);";

                    using (SqlCommand cmd = new SqlCommand(insertBillQuery, con, transaction))
                    {
                        cmd.Parameters.AddWithValue("@DeliveryChallanHeaderID", challanHeaderID);
                        AddBillHeaderParameters(cmd);
                        cmd.ExecuteNonQuery();
                    }
                }
                else
                {
                    string updateBillQuery = @"
                        UPDATE CommercialBillHeader SET
                            InvoiceNumber = @InvoiceNumber,
                            BillDate = @BillDate,
                            PaymentTerms = @PaymentTerms,
                            SubTotalAmount = @SubTotalAmount,
                            TransportCostAmount = @TransportCostAmount,
                            VatPercentage = @VatPercentage,
                            GrandTotalAmount = @GrandTotalAmount
                        WHERE CommercialBillHeaderID = @CommercialBillHeaderID";

                    using (SqlCommand cmd = new SqlCommand(updateBillQuery, con, transaction))
                    {
                        AddBillHeaderParameters(cmd);
                        cmd.Parameters.AddWithValue("@CommercialBillHeaderID", billHeaderID);
                        cmd.ExecuteNonQuery();
                    }
                }

                string deleteDetailsQuery = "DELETE FROM DeliveryChallanDetails WHERE DeliveryChallanHeaderID = @DeliveryChallanHeaderID";
                using (SqlCommand cmd = new SqlCommand(deleteDetailsQuery, con, transaction))
                {
                    cmd.Parameters.AddWithValue("@DeliveryChallanHeaderID", challanHeaderID);
                    cmd.ExecuteNonQuery();
                }

                string insertDetailQuery = @"
                    INSERT INTO DeliveryChallanDetails
                        (DeliveryChallanHeaderID, SerialNumber, JobNumber, ItemName, BuyerName, StyleName,
                         PurchaseOrderName, ColorName, SizeName, MeasurementDetails,
                         OrderQuantityWithUnit, ReadyQuantityWithUnit, DeliveryQuantity,
                         UnitRateAmount, RateUnitName, TotalAmount, ItemSpecificationRemarks, WorkOrderDetailsID)
                    VALUES
                        (@DeliveryChallanHeaderID, @SerialNumber, @JobNumber, @ItemName, @BuyerName, @StyleName,
                         @PurchaseOrderName, @ColorName, @SizeName, @MeasurementDetails,
                         @OrderQuantityWithUnit, @ReadyQuantityWithUnit, @DeliveryQuantity,
                         @UnitRateAmount, @RateUnitName, @TotalAmount, @ItemSpecificationRemarks, @WorkOrderDetailsID)";

                int serial = 1;
                foreach (GridViewRow row in gvDeliveryItems.Rows)
                {
                    if (row.RowType != DataControlRowType.DataRow) continue;

                    TextBox txtQty = (TextBox)row.FindControl("txtRowQty");
                    TextBox txtItemRemarks = (TextBox)row.FindControl("txtItemRemarks");
                    Label lblJobNo = (Label)row.FindControl("lblJobNo");
                    Label lblItemName = (Label)row.FindControl("lblItemName");
                    Label lblBuyer = (Label)row.FindControl("lblBuyer");
                    Label lblStyle = (Label)row.FindControl("lblStyle");
                    Label lblPOName = (Label)row.FindControl("lblPOName");
                    Label lblColor = (Label)row.FindControl("lblColor");
                    Label lblSize = (Label)row.FindControl("lblSize");
                    Label lblMeasurement = (Label)row.FindControl("lblMeasurement");
                    Label lblWOQty = (Label)row.FindControl("lblWOQty");
                    Label lblReadyQty = (Label)row.FindControl("lblReadyQty");
                    Label lblUnitRate = (Label)row.FindControl("lblUnitRate");
                    Label lblRateUnit = (Label)row.FindControl("lblRateUnit");

                    decimal deliveryQty = 0;
                    decimal.TryParse(txtQty?.Text, out deliveryQty);

                    decimal unitRate = 0;
                    decimal.TryParse(lblUnitRate?.Text, out unitRate);

                    decimal totalAmount = deliveryQty * unitRate;

                    using (SqlCommand cmd = new SqlCommand(insertDetailQuery, con, transaction))
                    {
                        cmd.Parameters.AddWithValue("@DeliveryChallanHeaderID", challanHeaderID);
                        cmd.Parameters.AddWithValue("@SerialNumber", serial);
                        cmd.Parameters.AddWithValue("@JobNumber", (object)lblJobNo?.Text ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@ItemName", (object)lblItemName?.Text ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@BuyerName", (object)lblBuyer?.Text ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@StyleName", (object)lblStyle?.Text ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@PurchaseOrderName", (object)lblPOName?.Text ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@ColorName", (object)lblColor?.Text ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@SizeName", (object)lblSize?.Text ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@MeasurementDetails", (object)lblMeasurement?.Text ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@OrderQuantityWithUnit", (object)lblWOQty?.Text ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@ReadyQuantityWithUnit", (object)lblReadyQty?.Text ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@DeliveryQuantity", deliveryQty);
                        cmd.Parameters.AddWithValue("@UnitRateAmount", unitRate);
                        cmd.Parameters.AddWithValue("@RateUnitName", (object)lblRateUnit?.Text ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@TotalAmount", totalAmount);
                        cmd.Parameters.AddWithValue("@ItemSpecificationRemarks", (object)txtItemRemarks?.Text ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@WorkOrderDetailsID", DBNull.Value);

                        cmd.ExecuteNonQuery();
                    }
                    serial++;
                }

                transaction.Commit();
                hdnChallanHeaderID.Value = challanHeaderID.ToString();

                RunScript($"alert('Successfully {(isUpdateMode ? "Updated" : "Saved")}.'); showPanel('pnlList');");

                ResetFormAndGoToList();
                LoadChallanList();
            }
            catch (Exception ex)
            {
                transaction.Rollback();
                ShowAlert("Error: " + ex.Message);
            }
            finally
            {
                CloseConnection();
            }
        }

        private void AddChallanHeaderParameters(SqlCommand cmd)
        {
            cmd.Parameters.AddWithValue("@DeliveryChallanNumber", txtChallanNo.Text);
            cmd.Parameters.AddWithValue("@DeliveryTypeID", Convert.ToInt32(ddlDeliveryType.SelectedValue));
            cmd.Parameters.AddWithValue("@DeliveryChallanDate", Convert.ToDateTime(txtChallanDate.Text));
            cmd.Parameters.AddWithValue("@VehicleTransportNumber", string.IsNullOrEmpty(txtVehicle.Text) ? (object)DBNull.Value : txtVehicle.Text);
            cmd.Parameters.AddWithValue("@DriverNameAndPhone", string.IsNullOrEmpty(txtDriver.Text) ? (object)DBNull.Value : txtDriver.Text);
            cmd.Parameters.AddWithValue("@DeliveryRemarks", string.IsNullOrEmpty(txtRemarks.Text) ? (object)DBNull.Value : txtRemarks.Text);
            cmd.Parameters.AddWithValue("@ReceivingBranchID", string.IsNullOrEmpty(ddlReceivingBranch.SelectedValue) ? (object)DBNull.Value : Convert.ToInt32(ddlReceivingBranch.SelectedValue));
            cmd.Parameters.AddWithValue("@CustomerPartyID", Convert.ToInt32(ddlCustomer.SelectedValue));
            cmd.Parameters.AddWithValue("@WorkOrderReceiveID", Convert.ToInt32(ddlWorkOrder.SelectedValue));
            cmd.Parameters.AddWithValue("@CreatedByUserID", DBNull.Value);
        }

        private void AddBillHeaderParameters(SqlCommand cmd)
        {
            cmd.Parameters.AddWithValue("@InvoiceNumber", txtInvoiceNo.Text);
            cmd.Parameters.AddWithValue("@BillDate", Convert.ToDateTime(txtBillDate.Text));
            cmd.Parameters.AddWithValue("@PaymentTerms", string.IsNullOrEmpty(txtPaymentTerms.Text) ? (object)DBNull.Value : txtPaymentTerms.Text);
            cmd.Parameters.AddWithValue("@SubTotalAmount", Convert.ToDecimal(txtSubTotal.Text));
            cmd.Parameters.AddWithValue("@TransportCostAmount", Convert.ToDecimal(txtTransport.Text));
            cmd.Parameters.AddWithValue("@VatPercentage", Convert.ToDecimal(txtVat.Text));
            cmd.Parameters.AddWithValue("@GrandTotalAmount", Convert.ToDecimal(txtGrandTotal.Text));
            cmd.Parameters.AddWithValue("@CreatedByUserID", DBNull.Value);
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            ResetFormAndGoToList();
        }

        private void ResetFormAndGoToList()
        {
            hdnChallanHeaderID.Value = "0";
            txtVehicle.Text = "";
            txtDriver.Text = "";
            txtRemarks.Text = "";
            txtPaymentTerms.Text = "30 Days Net";
            ddlDeliveryType.SelectedIndex = 0;
            ddlReceivingBranch.ClearSelection();
            ddlCustomer.ClearSelection();
            ddlWorkOrder.Items.Clear();
            ddlWorkOrder.Items.Insert(0, new ListItem("-- Select Work Order --", ""));

            txtChallanDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
            txtBillDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
            txtChallanNo.Text = LoadDeliveryChallanNo();
            txtInvoiceNo.Text = LoadInvoiceNo();

            txtSubTotal.Text = "0.00";
            txtTransport.Text = "0.00";
            txtVat.Text = "0";
            txtGrandTotal.Text = "0.00";

            gvDeliveryItems.DataSource = null;
            gvDeliveryItems.DataBind();
        }

        // ==================== HELPERS ====================
        private void ShowAlert(string message)
        {
            RunScript($"alert('{message.Replace("'", "")}');");
        }

        private void RunScript(string script)
        {
            ScriptManager.RegisterStartupScript(this, GetType(), Guid.NewGuid().ToString(), script, true);
        }

        private void CloseConnection()
        {
            if (con != null && con.State == ConnectionState.Open)
                con.Close();
        }
    }
}