using Nexa_ERP.Connection;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.Shipment
{
    public partial class DeliveryBill : Page
    {
        SqlConnection con;
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();
        SqlCommand cmd;

        private const string SK_BillItems = "DeliveryBill_Items";
        private const string SK_EditHeaderId = "DeliveryBill_EditHeaderId";   
        private const string SK_WorkOrderId = "DeliveryBill_WorkOrderId";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["User_ID"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }

            if (!IsPostBack)
            {
                txtBillDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                txtPaymentTerms.Text = "30 Days Net";
                txtTransport.Text = "0.00";
                txtVat.Text = "0";
                LoadPartyName();
                LoadReceivingBranch();
                pnlList.Visible = true;
                pnlForm.Visible = false;
                LoadChallanBillList();
            }
            else if (pnlForm.Visible)
            {
                RecalculateAndBindItems();
            }
        }
        private void LoadChallanBillList()
        {
            try
            {
                con = conn.openConnection();
                string query = @" SELECT SubmitedCommercialBillHeader.InvoiceNo, SubmitedCommercialBillHeader.BillDate, tbl_CustomerSupplier.PartyName, SubmitedCommercialBillHeader.GrandTotalAmount
                        FROM SubmitedCommercialBillHeader INNER JOIN tbl_CustomerSupplier ON SubmitedCommercialBillHeader.CustomerPartyID = tbl_CustomerSupplier.PartyID";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    gvChallanList.DataSource = dt;
                    gvChallanList.DataBind();
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
            finally
            {
                con.Close();
            }
        }

        protected void gvChallanList_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName != "ViewBill") return;

            int deliveryChallanHeaderId = Convert.ToInt32(e.CommandArgument);
            OpenBillForChallan(deliveryChallanHeaderId);
        }

        private void OpenBillForChallan(int deliveryChallanHeaderId)
        {
            try
            {
                con = conn.openConnection();

                string query = @"
                    SELECT  dch.CustomerPartyID, dch.WorkOrderReceiveID, dch.ReceivingBranchID,
                            cb.CommercialBillHeaderID, cb.InvoiceNo,
                            CONVERT(VARCHAR(10), cb.BillDate,120) AS BillDate,
                            cb.PaymentTerms, cb.Remarks, cb.TransportCost, cb.VatPercent
                    FROM DeliveryChallanHeader dch
                    LEFT JOIN CommercialBillHeader cb ON cb.DeliveryChallanHeaderID = dch.DeliveryChallanHeaderID AND cb.IsActive = 1
                    WHERE dch.DeliveryChallanHeaderID = @Id";

                DataRow row = null;
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@Id", deliveryChallanHeaderId);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    if (dt.Rows.Count > 0) row = dt.Rows[0];
                }

                if (row == null)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Challan not found.');", true);
                    return;
                }

                ddlReceivingBranch.SelectedValue = row["ReceivingBranchID"].ToString();
                ddlCustomer.SelectedValue = row["CustomerPartyID"].ToString();
                LoadWorkOrderList();
                ddlWorkOrder.SelectedValue = row["WorkOrderReceiveID"].ToString();

                int workOrderId = Convert.ToInt32(row["WorkOrderReceiveID"]);
                Session[SK_WorkOrderId] = workOrderId;

                if (row["CommercialBillHeaderID"] != DBNull.Value)
                {
                    int billHeaderId = Convert.ToInt32(row["CommercialBillHeaderID"]);
                    Session[SK_EditHeaderId] = billHeaderId;

                    txtInvoiceNo.Text = row["InvoiceNo"].ToString();
                    txtBillDate.Text = row["BillDate"].ToString();
                    txtPaymentTerms.Text = row["PaymentTerms"].ToString();
                    txtRemarks.Text = row["Remarks"].ToString();
                    txtTransport.Text = Convert.ToDecimal(row["TransportCost"]).ToString("0.00");
                    txtVat.Text = row["VatPercent"].ToString();

                }
                else
                {
                    txtInvoiceNo.Text = GenerateNextInvoiceNo();
                    txtBillDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                    txtPaymentTerms.Text = "30 Days Net";
                    txtRemarks.Text = "";
                    txtTransport.Text = "0.00";
                    txtVat.Text = "0";
                }

                RecalculateAndBindItems();

                pnlList.Visible = false;
                pnlForm.Visible = true;
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
            finally
            {
                con.Close();
            }
        }

        // ================= DROPDOWNS =================

        private void LoadWorkOrderList()
        {
            try
            {
                con = conn.openConnection();
                string query = @"SELECT WORcvID, RefWorkOrderNo AS WORcvNoRefWorkOrderNo  FROM WorkOrderHeader 
                                  WHERE CustomerID = @CustomerID AND IsActive = 1 
                                  ORDER BY WORcvNoRefWorkOrderNo";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@CustomerID",
                        string.IsNullOrEmpty(ddlCustomer.SelectedValue) ? (object)DBNull.Value : ddlCustomer.SelectedValue);

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlWorkOrder.DataSource = dt;
                    ddlWorkOrder.DataTextField = "WORcvNoRefWorkOrderNo";
                    ddlWorkOrder.DataValueField = "WORcvID";
                    ddlWorkOrder.DataBind();

                    ddlWorkOrder.Items.Insert(0, new ListItem("-- Select Work Order --", ""));
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
            finally
            {
                con.Close();
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
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
            finally
            {
                con.Close();
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

                    ddlCustomer.Items.Insert(0, new ListItem("--Select Party Name--", ""));
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
            finally
            {
                con.Close();
            }
        }

        protected void ddlCustomer_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadWorkOrderList();
            gvPendingChallans.DataSource = null;
            gvPendingChallans.DataBind();
            RecalculateAndBindItems();
        }

        protected void ddlWorkOrder_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadPendingChallans();
        }

        // ================= PENDING CHALLANS GRID (header level) =================

        private void LoadPendingChallans()
        {
            try
            {
                con = conn.openConnection();
                {
                    SqlDataAdapter da = new SqlDataAdapter(@"Select * From vw_CommercialBillChallanwise where RefWorkOrderNo = @RefWorkOrderNo and BillStatus not in(1)", con);

                    da.SelectCommand.Parameters.AddWithValue("@RefWorkOrderNo", ddlWorkOrder.SelectedItem.Text);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    gvPendingChallans.DataSource = dt;
                    gvPendingChallans.DataBind();
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
            finally
            {
                con.Close();
            }
        }
        protected void gvPendingChallans_RowDataBound(object sender, GridViewRowEventArgs e)
        {

        }
        // ================= SELECTED CHALLANS "CART" (Session-based) =================
        private DataTable GetSelectedChallansTable()
        {
            DataTable dt = Session[SK_BillItems] as DataTable;
            if (dt == null)
            {
                dt = new DataTable();
                dt.Columns.Add("DeliveryChallanHeaderID", typeof(int));
                dt.Columns.Add("DeliveryChallanNumber", typeof(string));
                dt.Columns.Add("DeliveryChallanDate", typeof(string));
                dt.Columns.Add("RefWorkOrderNo", typeof(string));
                dt.Columns.Add("PartyName", typeof(string));
                dt.Columns.Add("GrandTotalAmount", typeof(decimal));
                Session[SK_BillItems] = dt;
            }
            return dt;
        }

        protected void btnAddSelectedChallans_Click(object sender, EventArgs e)
        {
            DataTable dt = GetSelectedChallansTable();

            foreach (GridViewRow row in gvPendingChallans.Rows)
            {
                if (row.RowType != DataControlRowType.DataRow) continue;

                CheckBox chkRow = (CheckBox)row.FindControl("chkRow");
                if (chkRow == null || !chkRow.Checked) continue;

                int challanId = Convert.ToInt32(gvPendingChallans.DataKeys[row.RowIndex].Value);

                // একই চালান দুইবার যোগ হওয়া থেকে আটকানো
                bool alreadyAdded = false;
                foreach (DataRow existing in dt.Rows)
                {
                    if (Convert.ToInt32(existing["DeliveryChallanHeaderID"]) == challanId)
                    {
                        alreadyAdded = true;
                        break;
                    }
                }
                if (alreadyAdded) continue;

                string challanNo = row.Cells[2].Text;
                string challanDate = row.Cells[3].Text;
                string woRefNo = row.Cells[4].Text;
                string partyName = row.Cells[5].Text;

                decimal grandTotal;
                decimal.TryParse(row.Cells[6].Text, out grandTotal);

                DataRow newRow = dt.NewRow();
                newRow["DeliveryChallanHeaderID"] = challanId;
                newRow["DeliveryChallanNumber"] = challanNo;
                newRow["DeliveryChallanDate"] = challanDate;
                newRow["RefWorkOrderNo"] = woRefNo;
                newRow["PartyName"] = partyName;
                newRow["GrandTotalAmount"] = grandTotal;
                dt.Rows.Add(newRow);
            }
            Session[SK_BillItems] = dt;
            RecalculateAndBindItems();
        }

        /// <summary>
        /// gvSelectedChallans-এর "Delete" বাটনে ক্লিক করলে সেই চালানটি cart থেকে বাদ যাবে।
        /// </summary>
        protected void gvSelectedChallans_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName != "Delete") return;

            int rowIndex = Convert.ToInt32(e.CommandArgument);
            int challanId = Convert.ToInt32(gvSelectedChallans.DataKeys[rowIndex].Value);

            DataTable dt = GetSelectedChallansTable();
            for (int i = dt.Rows.Count - 1; i >= 0; i--)
            {
                if (Convert.ToInt32(dt.Rows[i]["DeliveryChallanHeaderID"]) == challanId)
                {
                    dt.Rows.RemoveAt(i);
                    break;
                }
            }

            Session[SK_BillItems] = dt;
            RecalculateAndBindItems();
        }

        protected void gvDeliveryItems_RowCommand(object sender, GridViewCommandEventArgs e)
        {

        }

        protected void txtQty_TextChanged(object sender, EventArgs e)
        {

        }

        /// <summary>
        /// gvSelectedChallans গ্রিড রিফ্রেশ করে, SubTotal / Transport / VAT / GrandTotal হিসাব করে বসায়।
        /// </summary>
        private void RecalculateAndBindItems()
        {
            DataTable dt = GetSelectedChallansTable();

            gvSelectedChallans.DataSource = dt;
            gvSelectedChallans.DataBind();

            decimal subTotal = 0;
            foreach (DataRow row in dt.Rows)
            {
                subTotal += Convert.ToDecimal(row["GrandTotalAmount"]);
            }

            decimal transport;
            decimal.TryParse(txtTransport.Text, out transport);

            decimal vatPercent;
            decimal.TryParse(txtVat.Text, out vatPercent);

            decimal vatAmount = (subTotal * vatPercent) / 100;
            decimal grandTotal = subTotal + transport + vatAmount;

            txtSubTotal.Text = subTotal.ToString("0.00");
            txtGrandTotal.Text = grandTotal.ToString("0.00");
        }

        private string GenerateNextInvoiceNo()
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT ISNULL(MAX(CommercialBillHeaderID), 0) + 1 FROM SubmitedCommercialBillHeader";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    int nextId = (int)cmd.ExecuteScalar();
                    return "INV-" + DateTime.Today.Year + "-" + nextId.ToString("D6");
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert",
                    "alert('InvoiceNo Error: " + ex.Message.Replace("'", "") + "');", true);
                return "INV-" + DateTime.Today.Year + "-" + DateTime.Now.ToString("HHmmss");
            }
            finally
            {
                con.Close();
            }
        }


        // ================= SAVE / CANCEL =================

        protected void btnSave_Click(object sender, EventArgs e)
        {
            // ---------- Basic validation ----------
            if (string.IsNullOrEmpty(ddlCustomer.SelectedValue))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('অনুগ্রহ করে একটি Customer সিলেক্ট করুন।');", true);
                return;
            }

            DataTable cart = GetSelectedChallansTable();
            if (cart.Rows.Count == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('বিল করার জন্য অন্তত একটি Delivery Challan যোগ করুন।');", true);
                return;
            }

            decimal subTotal = 0;
            foreach (DataRow row in cart.Rows)
                subTotal += Convert.ToDecimal(row["GrandTotalAmount"]);

            decimal transport;
            decimal.TryParse(txtTransport.Text, out transport);

            decimal vatPercent;
            decimal.TryParse(txtVat.Text, out vatPercent);

            decimal vatAmount = (subTotal * vatPercent) / 100;
            decimal grandTotal = subTotal + transport + vatAmount;

            DateTime billDate;
            if (!DateTime.TryParse(txtBillDate.Text, out billDate))
                billDate = DateTime.Today;

            int existingHeaderId = 0;
            if (Session[SK_EditHeaderId] != null)
                existingHeaderId = Convert.ToInt32(Session[SK_EditHeaderId]);

            int userId = Convert.ToInt32(Session["User_ID"]);

            SqlTransaction trans = null;

            try
            {
                con = conn.openConnection();
                trans = con.BeginTransaction();

                // ---------- 1) Header Insert/Update ----------
                int headerId;
                using (SqlCommand cmdHeader = new SqlCommand("techdefendersbd.sp_CommercialBillHeader_InsertUpdate", con, trans))
                {
                    cmdHeader.CommandType = CommandType.StoredProcedure;

                    cmdHeader.Parameters.AddWithValue("@CommercialBillHeaderID", existingHeaderId);
                    cmdHeader.Parameters.AddWithValue("@InvoiceNo", txtInvoiceNo.Text);
                    cmdHeader.Parameters.AddWithValue("@BillDate", billDate);
                    cmdHeader.Parameters.AddWithValue("@CustomerPartyID", Convert.ToInt32(ddlCustomer.SelectedValue));
                    cmdHeader.Parameters.AddWithValue("@ReceivingBranchID",
                        string.IsNullOrEmpty(ddlReceivingBranch.SelectedValue) ? (object)DBNull.Value : Convert.ToInt32(ddlReceivingBranch.SelectedValue));
                    cmdHeader.Parameters.AddWithValue("@PaymentTerms", (object)txtPaymentTerms.Text ?? DBNull.Value);
                    cmdHeader.Parameters.AddWithValue("@Remarks", (object)txtRemarks.Text ?? DBNull.Value);
                    cmdHeader.Parameters.AddWithValue("@SubTotalAmount", subTotal);
                    cmdHeader.Parameters.AddWithValue("@TransportCost", transport);
                    cmdHeader.Parameters.AddWithValue("@VatPercent", vatPercent);
                    cmdHeader.Parameters.AddWithValue("@VatAmount", vatAmount);
                    cmdHeader.Parameters.AddWithValue("@GrandTotalAmount", grandTotal);
                    cmdHeader.Parameters.AddWithValue("@UserID", userId);

                    SqlParameter pResultId = new SqlParameter("@ResultID", SqlDbType.Int) { Direction = ParameterDirection.Output };
                    SqlParameter pAction = new SqlParameter("@ActionType", SqlDbType.VarChar, 200) { Direction = ParameterDirection.Output };
                    cmdHeader.Parameters.Add(pResultId);
                    cmdHeader.Parameters.Add(pAction);

                    cmdHeader.ExecuteNonQuery();

                    string headerAction = pAction.Value.ToString();
                    if (headerAction.StartsWith("Error"))
                        throw new Exception(headerAction);

                    headerId = Convert.ToInt32(pResultId.Value);
                }

                // ---------- 2) Detail Insert/Update (TVP দিয়ে পুরো cart পাঠানো) ----------
                DataTable tvp = new DataTable();
                tvp.Columns.Add("DeliveryChallanHeaderID", typeof(int));
                tvp.Columns.Add("ChallanAmount", typeof(decimal));
                foreach (DataRow row in cart.Rows)
                    tvp.Rows.Add(Convert.ToInt32(row["DeliveryChallanHeaderID"]), Convert.ToDecimal(row["GrandTotalAmount"]));

                using (SqlCommand cmdDetail = new SqlCommand("techdefendersbd.sp_CommercialBillDetail_InsertUpdate", con, trans))
                {
                    cmdDetail.CommandType = CommandType.StoredProcedure;
                    cmdDetail.Parameters.AddWithValue("@CommercialBillHeaderID", headerId);

                    SqlParameter pDetailList = cmdDetail.Parameters.AddWithValue("@DetailList", tvp);
                    pDetailList.SqlDbType = SqlDbType.Structured;
                    pDetailList.TypeName = "techdefendersbd.TVP_CommercialBillDetail";

                    SqlParameter pAction2 = new SqlParameter("@ActionType", SqlDbType.VarChar, 200) { Direction = ParameterDirection.Output };
                    cmdDetail.Parameters.Add(pAction2);

                    cmdDetail.ExecuteNonQuery();

                    string detailAction = pAction2.Value.ToString();
                    if (detailAction.StartsWith("Error"))
                        throw new Exception(detailAction);
                }

                trans.Commit();

                // ---------- সফলভাবে সেভ হওয়ার পর cart/session পরিষ্কার করে লিস্টে ফিরে যাও ----------
                Session[SK_BillItems] = null;
                Session[SK_EditHeaderId] = null;
                Session[SK_WorkOrderId] = null;

                pnlForm.Visible = false;
                pnlList.Visible = true;
                LoadChallanBillList();

                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('বিল সফলভাবে সেভ হয়েছে।');", true);
            }
            catch (Exception ex)
            {
                if (trans != null)
                {
                    try { trans.Rollback(); } catch { /* rollback failed silently */ }
                }
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
            finally
            {
                con.Close();
            }
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            Session[SK_BillItems] = null;
            pnlForm.Visible = false;
            pnlList.Visible = true;
            LoadChallanBillList();
        }

        protected void btnNewChallan_Click(object sender, EventArgs e)
        {
            Session[SK_BillItems] = null;
            ddlCustomer.SelectedIndex = 0;
            ddlWorkOrder.Items.Clear();
            gvPendingChallans.DataSource = null;
            gvPendingChallans.DataBind();

            txtInvoiceNo.Text = GenerateNextInvoiceNo();

            txtBillDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
            txtPaymentTerms.Text = "30 Days Net";
            txtRemarks.Text = "";
            txtTransport.Text = "0.00";
            txtVat.Text = "0";
            RecalculateAndBindItems();

            pnlList.Visible = false;
            pnlForm.Visible = true;
        }

        protected void btnBackList_Click(object sender, EventArgs e)
        {
            Session[SK_BillItems] = null;

            pnlForm.Visible = false;
            pnlList.Visible = true;
            LoadChallanBillList();
        }


    }
}