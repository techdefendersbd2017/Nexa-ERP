using Nexa_ERP.Connection;
using Nexa_ERP.TrimsAccessories.MsterSetup;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.TrimsAccessories.EstimationCostings
{
    public partial class WorkOrderReceiveByQuotation : System.Web.UI.Page
    {
        SqlConnection con;
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();
        SqlCommand cmd;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                loadBranch_Name();
                LoadddlSearchCustomer();
                LoadWorkOrderReceiveList();

                txtWORcvDT.Text = DateTime.Now.ToString("dd-MM-yyyy");
                txtDeliveryDT.Text = DateTime.Now.AddDays(7).ToString("dd-MM-yyyy");
            }
        }

        private void LoadWorkOrderReceiveList()
        {
            SqlConnection listCon = null;
            try
            {
                listCon = conn.openConnection();
                string query = @"SELECT * From tbl_WorkOrderReceive";

                using (SqlCommand cmdList = new SqlCommand(query, listCon))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmdList);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    gvWorkOrderReceive.DataSource = dt;
                    gvWorkOrderReceive.DataBind();
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "listErr",
                    "alert('Error loading list: " + ex.Message.Replace("'", "\\'") + "');", true);
            }
            finally
            {
                if (listCon != null && listCon.State == ConnectionState.Open) listCon.Close();
            }
        }

        private void loadBranch_Name()
        {
            Database_Connection conn = new Database_Connection();
            try
            {
                con = conn.openConnection();
                string query = "SELECT * FROM Branch_Information ORDER BY Branch_Name ASC";
                SqlDataAdapter da = new SqlDataAdapter(query, con);
                DataTable dt = new DataTable();
                da.Fill(dt);

                ddlReceiveBranch.DataSource = dt;
                ddlReceiveBranch.DataTextField = "Branch_Name";
                ddlReceiveBranch.DataValueField = "Branch_ID";
                ddlReceiveBranch.DataBind();
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open)
                {
                    con.Close();
                }
            }
        }

        private void LoadddlSearchCustomer()
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT * FROM tbl_CustomerSupplier WHERE Status='Active' ORDER BY PartyName ASC";
                SqlDataAdapter da = new SqlDataAdapter(query, con);
                DataTable dt = new DataTable();
                da.Fill(dt);

                ddlCustomer.DataSource = dt;
                ddlCustomer.DataTextField = "PartyName";
                ddlCustomer.DataValueField = "PartyID";
                ddlCustomer.DataBind();
                ddlCustomer.Items.Insert(0, new ListItem("--Select Party--", "0"));
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open)
                {
                    con.Close();
                }
            }
        }
        private void LoadQuotationItems()
        {
            try
            {
                con = conn.openConnection();
                string query = @"SELECT 
                                m.ItemID           AS FinishedItemID,
                                i.ItemName          AS FinishedItemName,
                                SUM(ISNULL(d.TotalCost, 0)) AS Rate
                             FROM [nexamar].[techdefendersbd].[tbl_PriceQuotationDetails] d
                             INNER JOIN [nexamar].[techdefendersbd].[tbl_PriceQuotationMaster] m
                                 ON d.QuotationID = m.QuotationID
                                AND d.ItemID = m.ItemID
                             INNER JOIN [nexamar].[techdefendersbd].[ta_ItemName] i
                                 ON m.ItemID = i.ItemID
                             WHERE 1=1";

                if (!string.IsNullOrEmpty(txtSearchQuotationNo.Text.Trim()))
                {
                    query += " AND m.QuotationCode LIKE @QuotationCode";
                }
                if (ddlSearchCustomer.SelectedValue != "0")
                {
                    query += " AND m.CustomerID = @CustomerID";
                }
                if (!string.IsNullOrEmpty(txtFromDate.Text) && !string.IsNullOrEmpty(txtTillDate.Text))
                {
                    query += " AND m.CreateDate BETWEEN @FromDate AND @TillDate";
                }

                query += " GROUP BY m.ItemID, i.ItemName ORDER BY m.ItemID ASC";

                using (SqlCommand cmdItems = new SqlCommand(query, con))
                {
                    if (!string.IsNullOrEmpty(txtSearchQuotationNo.Text.Trim()))
                        cmdItems.Parameters.AddWithValue("@QuotationCode", "%" + txtSearchQuotationNo.Text.Trim() + "%");
                    if (ddlSearchCustomer.SelectedValue != "0")
                        cmdItems.Parameters.AddWithValue("@CustomerID", ddlSearchCustomer.SelectedValue);
                    if (!string.IsNullOrEmpty(txtFromDate.Text) && !string.IsNullOrEmpty(txtTillDate.Text))
                    {
                        cmdItems.Parameters.AddWithValue("@FromDate", txtFromDate.Text);
                        cmdItems.Parameters.AddWithValue("@TillDate", txtTillDate.Text);
                    }

                    SqlDataAdapter da = new SqlDataAdapter(cmdItems);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    gvQuotationItems.DataSource = dt;
                    gvQuotationItems.DataBind();
                }
                txtGTotal.Text = "0.00";
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error loading items: " + ex.Message.Replace("'", "\\'") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) con.Close();
            }
        }
        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadQuotationItems();
        }

        protected void btnLoadItems_Click(object sender, EventArgs e)
        {
            LoadQuotationItems();
        }

        // ================= Live Grand Total recalculation =================
        protected void txtOrderQty_TextChanged(object sender, EventArgs e)
        {
            RecalculateGrandTotal();
        }

        protected void chkIncludeItem_CheckedChanged(object sender, EventArgs e)
        {
            RecalculateGrandTotal();
        }
        private void RecalculateGrandTotal()
        {
            decimal itemsTotal = 0;
            foreach (GridViewRow row in gvQuotationItems.Rows)
            {
                if (row.RowType != DataControlRowType.DataRow) continue; // header/footer বাদ

                CheckBox chkInclude = (CheckBox)row.FindControl("chkIncludeItem");
                if (chkInclude != null && !chkInclude.Checked) continue; // uncheck করা item বাদ

                TextBox txtOrderQty = (TextBox)row.FindControl("txtOrderQty");
                HiddenField hdnRate = (HiddenField)row.FindControl("hdnRate");

                decimal orderQtyPcs = 0, rate = 0;
                decimal.TryParse(txtOrderQty?.Text, NumberStyles.Any, CultureInfo.InvariantCulture, out orderQtyPcs);
                decimal.TryParse(hdnRate?.Value, NumberStyles.Any, CultureInfo.InvariantCulture, out rate);

                if (orderQtyPcs < 0 || rate < 0) continue; // negative guard

                Label lblAmount = (Label)row.FindControl("lblAmount");
                decimal rowAmount = rate * orderQtyPcs;
                if (lblAmount != null)
                {
                    lblAmount.Text = rowAmount.ToString("0.00", CultureInfo.InvariantCulture);
                }

                itemsTotal += rowAmount; // সব row এর subtotal যোগ হচ্ছে
            }

            txtGTotal.Text = itemsTotal.ToString("0.00", CultureInfo.InvariantCulture); // মোট এখানে বসছে
        }
        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                if (gvQuotationItems.Rows.Count == 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(),
                        "alert", "alert('Please load at least one Item before saving.');", true);
                    return;
                }

                con = conn.openConnection();

                int currentUserId = Session["UserID"] != null ? Convert.ToInt32(Session["UserID"]) : 0;

                int existingId = ViewState["WORcvID"] != null && !string.IsNullOrEmpty(ViewState["WORcvID"].ToString())
                    ? Convert.ToInt32(ViewState["WORcvID"])
                    : 0;

                int savedWORcvId = existingId;
                bool anyRowSaved = false;
                foreach (GridViewRow row in gvQuotationItems.Rows)
                {
                    if (row.RowType != DataControlRowType.DataRow) continue;

                    TextBox txtOrderQty = (TextBox)row.FindControl("txtOrderQty");

                    if (txtOrderQty == null || string.IsNullOrWhiteSpace(txtOrderQty.Text))
                        continue;

                    CheckBox chkInclude = (CheckBox)row.FindControl("chkIncludeItem");
                    HiddenField hdnRate = (HiddenField)row.FindControl("hdnRate");
                    Label lblAmount = (Label)row.FindControl("lblAmount");
                    int finishedItemId = Convert.ToInt32(row.Cells[2].Text);
                    string finishedItemName = row.Cells[3].Text;
                    decimal rate = hdnRate != null && !string.IsNullOrWhiteSpace(hdnRate.Value)
                        ? Convert.ToDecimal(hdnRate.Value) : 0;
                    decimal orderQty = Convert.ToDecimal(txtOrderQty.Text);
                    decimal amount = lblAmount != null && !string.IsNullOrWhiteSpace(lblAmount.Text)
                        ? Convert.ToDecimal(lblAmount.Text) : rate * orderQty;
                    bool isIncluded = chkInclude != null && chkInclude.Checked;
                    using (SqlCommand cmd = new SqlCommand("techdefendersbd.usp_WorkOrderReceive_InsUpd", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        SqlParameter idParam = cmd.Parameters.Add("@WORcvID", SqlDbType.Int);
                        idParam.Direction = ParameterDirection.InputOutput;
                        idParam.Value = savedWORcvId; 
                        cmd.Parameters.Add("@WORcvNo", SqlDbType.VarChar, 50).Value = txtWORcvNo.Text.Trim();
                        cmd.Parameters.Add("@WONo", SqlDbType.VarChar, 50).Value =
                            string.IsNullOrEmpty(txtWONo.Text) ? (object)DBNull.Value : txtWONo.Text.Trim();
                        cmd.Parameters.Add("@ReceiveBranchID", SqlDbType.Int).Value =
                            string.IsNullOrEmpty(ddlReceiveBranch.SelectedValue) ? (object)DBNull.Value : Convert.ToInt32(ddlReceiveBranch.SelectedValue);
                        cmd.Parameters.Add("@WORcvDate", SqlDbType.Date).Value =
                            string.IsNullOrEmpty(txtWORcvDT.Text) ? (object)DBNull.Value : Convert.ToDateTime(txtWORcvDT.Text);
                        cmd.Parameters.Add("@DeliveryDate", SqlDbType.Date).Value =
                            string.IsNullOrEmpty(txtDeliveryDT.Text) ? (object)DBNull.Value : Convert.ToDateTime(txtDeliveryDT.Text);
                        cmd.Parameters.Add("@ApprovedDate", SqlDbType.Date).Value =
                            string.IsNullOrEmpty(txtApprovedDT.Text) ? (object)DBNull.Value : Convert.ToDateTime(txtApprovedDT.Text);
                        cmd.Parameters.Add("@WOStatus", SqlDbType.Int).Value = ddlWOStatus.SelectedValue;
                        cmd.Parameters.Add("@ShippingMode", SqlDbType.Int).Value = ddlShippingMode.SelectedValue;
                        cmd.Parameters.Add("@Revision", SqlDbType.VarChar, 20).Value =
                            string.IsNullOrEmpty(txtRevision.Text) ? (object)DBNull.Value : txtRevision.Text.Trim();
                        cmd.Parameters.Add("@RevisionDate", SqlDbType.Date).Value =
                            string.IsNullOrEmpty(txtRevisionDate.Text) ? (object)DBNull.Value : Convert.ToDateTime(txtRevisionDate.Text);
                        cmd.Parameters.Add("@RevisionReason", SqlDbType.VarChar, 255).Value =
                            string.IsNullOrEmpty(txtRevisionReason.Text) ? (object)DBNull.Value : txtRevisionReason.Text.Trim();
                        cmd.Parameters.Add("@Subject", SqlDbType.VarChar, -1).Value =
                            string.IsNullOrEmpty(txtSubject.Text) ? (object)DBNull.Value : txtSubject.Text.Trim();
                        cmd.Parameters.Add("@QuotationNo", SqlDbType.VarChar, 50).Value =
                            string.IsNullOrEmpty(txtSearchQuotationNo.Text) ? (object)DBNull.Value : txtSearchQuotationNo.Text.Trim();
                        cmd.Parameters.Add("@CustomerID", SqlDbType.Int).Value =
                            string.IsNullOrEmpty(ddlCustomer.SelectedValue) ? (object)DBNull.Value : Convert.ToInt32(ddlCustomer.SelectedValue);
                        cmd.Parameters.Add("@PaymentTerms", SqlDbType.Int).Value = ddlPaymentTerms.SelectedValue;
                        cmd.Parameters.Add("@Currency", SqlDbType.Int).Value = ddlCurrency.SelectedValue;
                        cmd.Parameters.Add("@PaymentMode", SqlDbType.Int).Value = ddlPaymentMode.SelectedValue;
                        cmd.Parameters.Add("@CurrConv", SqlDbType.Decimal).Value =
                            string.IsNullOrEmpty(txtCurrConv.Text) ? (object)1 : Convert.ToDecimal(txtCurrConv.Text);
                        cmd.Parameters.Add("@TermsConditions", SqlDbType.VarChar, -1).Value =
                            string.IsNullOrEmpty(txtTermsConditions.Text) ? (object)DBNull.Value : txtTermsConditions.Text.Trim();
                        cmd.Parameters.Add("@GrandTotal", SqlDbType.Decimal).Value =
                            string.IsNullOrEmpty(txtGTotal.Text) ? (object)0 : Convert.ToDecimal(txtGTotal.Text);
                        cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = currentUserId;
                        cmd.Parameters.Add("@FinishedItemID", SqlDbType.Int).Value = finishedItemId;
                        cmd.Parameters.Add("@FinishedItemName", SqlDbType.VarChar, 255).Value = finishedItemName;
                        cmd.Parameters.Add("@Rate", SqlDbType.Decimal).Value = rate;
                        cmd.Parameters.Add("@OrderQty", SqlDbType.Decimal).Value = orderQty;
                        cmd.Parameters.Add("@Amount", SqlDbType.Decimal).Value = amount;
                        cmd.Parameters.Add("@IsIncluded", SqlDbType.Bit).Value = isIncluded;
                        cmd.ExecuteNonQuery();

                        savedWORcvId = Convert.ToInt32(idParam.Value);
                        anyRowSaved = true;
                    }
                }

                if (!anyRowSaved)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(),
                        "alert", "alert('Please enter Order Qty for at least one Item before saving.');", true);
                    return;
                }

                ViewState["WORcvID"] = savedWORcvId;

                ScriptManager.RegisterStartupScript(this, this.GetType(),
                    "alert", "alert('Save Successfully!');", true);

                hdnActivePanel.Value = "pnlList";
                BindWorkOrderReceiveList();
            }
            catch (Exception ex)
            {
                string safeMsg = ex.Message.Replace("'", "\\'");
                ScriptManager.RegisterStartupScript(this, this.GetType(),
                    "alert", "alert('Save failed: " + safeMsg + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open)
                    con.Close();
            }
        }

        // Refreshes gvWorkOrderReceive on the list panel after a successful save.
        private void BindWorkOrderReceiveList()
        {
            SqlConnection listCon = null;
            try
            {
                listCon = conn.openConnection();
                using (SqlCommand cmdList = new SqlCommand("usp_WorkOrderReceive_List", listCon))
                {
                    cmdList.CommandType = CommandType.StoredProcedure;
                    SqlDataAdapter da = new SqlDataAdapter(cmdList);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    gvWorkOrderReceive.DataSource = dt;
                    gvWorkOrderReceive.DataBind();
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "listErr",
                    "alert('Error loading list: " + ex.Message.Replace("'", "") + "');", true);
            }
            finally
            {
                if (listCon != null && listCon.State == ConnectionState.Open) listCon.Close();
            }
        }

        protected void gvWorkOrderReceive_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            string woRcvNo = e.CommandArgument.ToString();

            if (e.CommandName == "EditRow")
            {
                LoadWorkOrderReceiveForEdit(woRcvNo);
                hdnActivePanel.Value = "pnlForm";
            }
            else if (e.CommandName == "DeleteRow")
            {
                DeleteWorkOrderReceive(woRcvNo);
                LoadWorkOrderReceiveList();
            }
            else if (e.CommandName == "ReportView")
            {
                int worcvId = Convert.ToInt32(e.CommandArgument);

                string url = ResolveUrl("~/TrimsAccessories/EstimationCostings/OrdersReports/ReceivedOrdersReports.aspx?WORcvID=" + worcvId);

                ScriptManager.RegisterStartupScript(
                    this,
                    this.GetType(),
                    "OpenReport",
                    "window.open('" + url + "', '_blank');",
                    true
                );
            }
        }
        private void LoadWorkOrderReceiveForEdit(string woRcvNo)
        {
            SqlConnection editCon = null;
            try
            {
                editCon = conn.openConnection();

                // ---------- Master ----------
                int woRcvId = 0;
                using (SqlCommand cmdMaster = new SqlCommand(
                    "SELECT * FROM [techdefendersbd].[tbl_WorkOrderReceive] WHERE WORcvNo = @WORcvNo", editCon))
                {
                    cmdMaster.Parameters.AddWithValue("@WORcvNo", woRcvNo);
                    using (SqlDataReader rdr = cmdMaster.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            woRcvId = Convert.ToInt32(rdr["WORcvID"]);

                            txtWORcvNo.Text = rdr["WORcvNo"].ToString();
                            txtWONo.Text = rdr["WONo"] == DBNull.Value ? "" : rdr["WONo"].ToString();
                            ddlReceiveBranch.SelectedValue = rdr["ReceiveBranchID"] == DBNull.Value ? "" : rdr["ReceiveBranchID"].ToString();
                            txtWORcvDT.Text = rdr["WORcvDate"] == DBNull.Value ? "" : Convert.ToDateTime(rdr["WORcvDate"]).ToString("yyyy-MM-dd");
                            txtDeliveryDT.Text = rdr["DeliveryDate"] == DBNull.Value ? "" : Convert.ToDateTime(rdr["DeliveryDate"]).ToString("yyyy-MM-dd");
                            txtApprovedDT.Text = rdr["ApprovedDate"] == DBNull.Value ? "" : Convert.ToDateTime(rdr["ApprovedDate"]).ToString("yyyy-MM-dd");
                            ddlWOStatus.SelectedValue = rdr["WOStatus"] == DBNull.Value ? "0" : rdr["WOStatus"].ToString();
                            ddlShippingMode.SelectedValue = rdr["ShippingMode"] == DBNull.Value ? "0" : rdr["ShippingMode"].ToString();
                            txtRevision.Text = rdr["Revision"] == DBNull.Value ? "" : rdr["Revision"].ToString();
                            txtRevisionDate.Text = rdr["RevisionDate"] == DBNull.Value ? "" : Convert.ToDateTime(rdr["RevisionDate"]).ToString("yyyy-MM-dd");
                            txtRevisionReason.Text = rdr["RevisionReason"] == DBNull.Value ? "" : rdr["RevisionReason"].ToString();
                            txtSubject.Text = rdr["Subject"] == DBNull.Value ? "" : rdr["Subject"].ToString();
                            txtSearchQuotationNo.Text = rdr["QuotationNo"] == DBNull.Value ? "" : rdr["QuotationNo"].ToString();
                            ddlCustomer.SelectedValue = rdr["CustomerID"] == DBNull.Value ? "0" : rdr["CustomerID"].ToString();
                            ddlPaymentTerms.SelectedValue = rdr["PaymentTerms"] == DBNull.Value ? "0" : rdr["PaymentTerms"].ToString();
                            ddlCurrency.SelectedValue = rdr["Currency"] == DBNull.Value ? "0" : rdr["Currency"].ToString();
                            ddlPaymentMode.SelectedValue = rdr["PaymentMode"] == DBNull.Value ? "0" : rdr["PaymentMode"].ToString();
                            txtCurrConv.Text = rdr["CurrConv"] == DBNull.Value ? "1" : rdr["CurrConv"].ToString();
                            txtTermsConditions.Text = rdr["TermsConditions"] == DBNull.Value ? "" : rdr["TermsConditions"].ToString();
                            txtGTotal.Text = rdr["GrandTotal"] == DBNull.Value ? "0.00" : Convert.ToDecimal(rdr["GrandTotal"]).ToString("0.00");
                        }
                    }
                }

                if (woRcvId == 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "editErr",
                        "alert('Record not found.');", true);
                    return;
                }

                ViewState["WORcvID"] = woRcvId;

                // ---------- Details (Items) ----------
                using (SqlCommand cmdDetails = new SqlCommand(
                    @"SELECT FinishedItemID, FinishedItemName, Rate, OrderQty, Amount, IsIncluded 
              FROM [techdefendersbd].[tbl_WorkOrderReceiveDetails] 
              WHERE WORcvID = @WORcvID", editCon))
                {
                    cmdDetails.Parameters.AddWithValue("@WORcvID", woRcvId);
                    SqlDataAdapter da = new SqlDataAdapter(cmdDetails);
                    DataTable dtDetails = new DataTable();
                    da.Fill(dtDetails);

                    gvQuotationItems.DataSource = dtDetails;
                    gvQuotationItems.DataBind();

                    // BoundField এ নেই এমন কলাম (Rate/OrderQty/IsIncluded) row-by-row বসাতে হবে,
                    // কারণ hdnRate/txtOrderQty/chkIncludeItem টেমপ্লেট কলাম, DataBind এ auto বসে না।
                    for (int i = 0; i < gvQuotationItems.Rows.Count; i++)
                    {
                        GridViewRow row = gvQuotationItems.Rows[i];
                        DataRow dr = dtDetails.Rows[i];

                        HiddenField hdnRate = (HiddenField)row.FindControl("hdnRate");
                        Label lblRate = (Label)row.FindControl("lblRate");
                        TextBox txtOrderQty = (TextBox)row.FindControl("txtOrderQty");
                        Label lblAmount = (Label)row.FindControl("lblAmount");
                        CheckBox chkInclude = (CheckBox)row.FindControl("chkIncludeItem");

                        decimal rate = Convert.ToDecimal(dr["Rate"]);
                        if (hdnRate != null) hdnRate.Value = rate.ToString("0.00", CultureInfo.InvariantCulture);
                        if (lblRate != null) lblRate.Text = rate.ToString("0.00", CultureInfo.InvariantCulture);
                        if (txtOrderQty != null) txtOrderQty.Text = Convert.ToDecimal(dr["OrderQty"]).ToString("0.##");
                        if (lblAmount != null) lblAmount.Text = Convert.ToDecimal(dr["Amount"]).ToString("0.00", CultureInfo.InvariantCulture);
                        if (chkInclude != null) chkInclude.Checked = Convert.ToBoolean(dr["IsIncluded"]);

                        if (chkInclude != null && !chkInclude.Checked)
                            row.CssClass = (row.CssClass + " row-excluded").Trim();
                    }
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "editErr",
                    "alert('Error loading record: " + ex.Message.Replace("'", "\\'") + "');", true);
            }
            finally
            {
                if (editCon != null && editCon.State == ConnectionState.Open) editCon.Close();
            }
        }

        // =========================================================================
        // DELETE: Master ও তার সব Detail রো একসাথে ডিলিট
        // =========================================================================
        private void DeleteWorkOrderReceive(string woRcvNo)
        {
            SqlConnection delCon = null;
            try
            {
                delCon = conn.openConnection();
                using (SqlCommand cmdDel = new SqlCommand(
                    @"DELETE FROM [techdefendersbd].[tbl_WorkOrderReceiveDetails] 
              WHERE WORcvID = (SELECT WORcvID FROM [techdefendersbd].[tbl_WorkOrderReceive] WHERE WORcvNo = @WORcvNo);

              DELETE FROM [techdefendersbd].[tbl_WorkOrderReceive] 
              WHERE WORcvNo = @WORcvNo;", delCon))
                {
                    cmdDel.Parameters.AddWithValue("@WORcvNo", woRcvNo);
                    cmdDel.ExecuteNonQuery();
                }

                ScriptManager.RegisterStartupScript(this, this.GetType(), "delOk",
                    "alert('Deleted successfully.');", true);
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "delErr",
                    "alert('Delete failed: " + ex.Message.Replace("'", "\\'") + "');", true);
            }
            finally
            {
                if (delCon != null && delCon.State == ConnectionState.Open) delCon.Close();
            }
        }
    }
}