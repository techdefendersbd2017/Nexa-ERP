using Nexa_ERP.Connection;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.TrimsAccessories
{
    public partial class PriceQuotation : System.Web.UI.Page
    {
        SqlConnection con;
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();
        SqlCommand cmd;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadQuotationList();
                LoadRawMaterial();
                LoadCustomer();
                LoadItemCategory();
                LoadddlSearchCustomer();

                txtCreateDate.Text = DateTime.Now.ToString("dd-MM-yy");
                ViewState["QuotationID"] = "0";

                InitialiseDetailsTable();
            }
        }

        // ==========================================
        // ITEM DETAILS TABLE STATE (VIEWSTATE)
        // ==========================================
        private DataTable CurrentTable
        {
            get
            {
                if (ViewState["ItemDetailsTable"] == null)
                {
                    InitialiseDetailsTable();
                }
                return (DataTable)ViewState["ItemDetailsTable"];
            }
            set
            {
                ViewState["ItemDetailsTable"] = value;
            }
        }


        private void InitialiseDetailsTable()
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("SlNo", typeof(int));
            dt.Columns.Add("RawMaterialID", typeof(int));
            dt.Columns.Add("RawMaterialName", typeof(string));
            dt.Columns.Add("ReqQty", typeof(decimal));
            dt.Columns.Add("Unit", typeof(string));
            dt.Columns.Add("UnitPrice", typeof(decimal));
            dt.Columns.Add("Currency", typeof(string));
            dt.Columns.Add("Loss", typeof(decimal));
            dt.Columns.Add("TotalCost", typeof(decimal));
            dt.Columns.Add("Remarks", typeof(string));
            ViewState["ItemDetailsTable"] = dt;
        }

        // ==========================================
        // LOAD ALL DROPDOWNS FROM DATABASE
        // ==========================================
        private void LoadItemCategory()
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT * FROM ta_ItemCategory WHERE Status='Active' ORDER BY CategoryName ASC";
                SqlDataAdapter da = new SqlDataAdapter(query, con);
                DataTable dt = new DataTable();
                da.Fill(dt);

                ddlItemCategory.DataSource = dt;
                ddlItemCategory.DataTextField = "CategoryName";
                ddlItemCategory.DataValueField = "CategoryID";
                ddlItemCategory.DataBind();
                ddlItemCategory.Items.Insert(0, new ListItem("--Select Item Category--", "0"));
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

                ddlSearchCustomer.DataSource = dt;
                ddlSearchCustomer.DataTextField = "PartyName";
                ddlSearchCustomer.DataValueField = "PartyID";
                ddlSearchCustomer.DataBind();
                ddlSearchCustomer.Items.Insert(0, new ListItem("--Select Party--", "0"));
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

        private void LoadCustomer()
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

        private void LoadRawMaterial()
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT * FROM ta_RawMaterial WHERE Status='Active' ORDER BY RawMaterialName ASC";
                SqlDataAdapter da = new SqlDataAdapter(query, con);
                DataTable dt = new DataTable();
                da.Fill(dt);

                ddlRawMaterial.DataSource = dt;
                ddlRawMaterial.DataTextField = "RawMaterialName";
                ddlRawMaterial.DataValueField = "RawMaterialID";
                ddlRawMaterial.DataBind();
                ddlRawMaterial.Items.Insert(0, new ListItem("--Select Category--", "0"));
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

        //private void BindDropdown(string query, DropDownList ddl, string textField, string valueField)
        //{
        //    using (SqlCommand cmd = new SqlCommand(query, con))
        //    {
        //        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
        //        {
        //            DataTable dt = new DataTable();
        //            da.Fill(dt);
        //            ddl.DataSource = dt;
        //            ddl.DataTextField = textField;
        //            ddl.DataValueField = valueField;
        //            ddl.DataBind();
        //            ddl.Items.Insert(0, new ListItem("--Select--", "0"));
        //        }
        //    }
        //}
        private string GetNextQuotationCode()
        {
            string prefix = "QT-";
            int nextNumber = 1;

            try
            {
                con = conn.openConnection();
                string query = @"SELECT TOP 1 QuotationCode 
                          FROM tbl_PriceQuotationMaster 
                          ORDER BY QuotationID DESC";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                    {
                        string lastCode = result.ToString().Trim(); // e.g. "QT-0002"
                        int dashIndex = lastCode.LastIndexOf('-');

                        if (dashIndex >= 0)
                        {
                            string numberPart = lastCode.Substring(dashIndex + 1);
                            if (int.TryParse(numberPart, out int lastNumber))
                            {
                                nextNumber = lastNumber + 1;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert",
                    "alert('Error generating Quotation Code: " + ex.Message.Replace("'", "\\'") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) con.Close();
            }

            // পুরনো কোড যত সংখ্যায় ছিল (যেমন 4 digit: 0001, 0002) সেভাবেই zero-pad হবে
            return prefix + nextNumber.ToString("D4");
        }
        protected void btnAddNew_Click(object sender, EventArgs e)
        {
            pnlList.Visible = false;
            pnlEntry.Visible = true;
            ClearForm();
            txtQuotationCode.Text = GetNextQuotationCode();   // <-- যোগ করা হলো
        }

        protected void btnBackToList_Click(object sender, EventArgs e)
        {
            pnlList.Visible = true;
            pnlEntry.Visible = false;
            ClearForm();
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            pnlList.Visible = true;
            pnlEntry.Visible = false;
            ClearForm();
        }

        private void ClearForm()
        {
            ViewState["QuotationID"] = "0";
            txtQuotationCode.Text = "QT-0003";
            txtQuotationName.Text = string.Empty;
            txtSameAs.Text = string.Empty;
            txtQty.Text = "1";
            txtOthersCost.Text = "0.00";
            txtGTotalCost.Text = "0.00";
            txtTotalCostSum.Text = "0.00";

            if (ddlCustomer.Items.Count > 0) ddlCustomer.SelectedIndex = 0;
            if (ddlItemName.Items.Count > 0) ddlItemName.SelectedIndex = 0;
            if (ddlSubCategory.Items.Count > 0) ddlSubCategory.SelectedIndex = 0;
            if (ddlItemName.Items.Count > 0) ddlItemName.SelectedIndex = 0;
            if (ddlItemUnit.Items.Count > 0) ddlItemUnit.SelectedIndex = 0;
            if (ddlStatus.Items.Count > 0) ddlStatus.SelectedIndex = 0;
            if (ddlRawMaterial.Items.Count > 0) ddlRawMaterial.SelectedIndex = 0;

            InitialiseDetailsTable();
            gvQuotationDetails.DataSource = CurrentTable;
            gvQuotationDetails.DataBind();

            ClearItemDetailsInput();

            btnSave.Text = "Save";
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadQuotationList();
        }

        private void LoadQuotationList()
        {
            try
            {
                con = conn.openConnection();
                string query = @"SELECT m.QuotationID, ROW_NUMBER() OVER(ORDER BY m.QuotationID DESC) AS SlNo,
                         m.QuotationCode, CONVERT(VARCHAR(10), m.CreateDate, 105) AS CreateDate,
                         c.PartyName AS Customer, m.QuotationName, m.GTotalCost,
                         CASE WHEN m.Status = 1 THEN 'Active' ELSE 'Inactive' END AS Status
                         FROM tbl_PriceQuotationMaster m
                         LEFT JOIN tbl_CustomerSupplier c ON m.CustomerID = c.PartyID
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

                query += " ORDER BY m.QuotationID DESC";

                using (SqlCommand cmdList = new SqlCommand(query, con))
                {
                    if (!string.IsNullOrEmpty(txtSearchQuotationNo.Text.Trim()))
                        cmdList.Parameters.AddWithValue("@QuotationCode", "%" + txtSearchQuotationNo.Text.Trim() + "%");
                    if (ddlSearchCustomer.SelectedValue != "0")
                        cmdList.Parameters.AddWithValue("@CustomerID", ddlSearchCustomer.SelectedValue);
                    if (!string.IsNullOrEmpty(txtFromDate.Text) && !string.IsNullOrEmpty(txtTillDate.Text))
                    {
                        cmdList.Parameters.AddWithValue("@FromDate", txtFromDate.Text);
                        cmdList.Parameters.AddWithValue("@TillDate", txtTillDate.Text);
                    }

                    SqlDataAdapter da = new SqlDataAdapter(cmdList);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    gvQuotationList.DataSource = dt;
                    gvQuotationList.DataBind();
                }
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error loading list: " + ex.Message.Replace("'", "\\'") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) con.Close();
            }
        }

        protected void gvQuotationList_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "EditQuotation")
            {
                string quotationID = e.CommandArgument.ToString();
                ViewState["QuotationID"] = quotationID;

                pnlList.Visible = false;
                pnlEntry.Visible = true;
                btnSave.Text = "Update";

                LoadQuotationDataForEdit(quotationID);
                LoadQuotationDetailsForEdit(quotationID); 
            }
            else if (e.CommandName == "PrintQuotation")
            {
                string quotationID = e.CommandArgument.ToString();
                string script = "window.open('PriceQuotationPrint.aspx?QID=" + quotationID + "', '_blank');";
                ScriptManager.RegisterStartupScript(this, this.GetType(), "printWin", script, true);
            }
        }

        private void LoadQuotationDataForEdit(string quotationID)
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT * FROM tbl_PriceQuotationMaster WHERE QuotationID = @QuotationID";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@QuotationID", quotationID);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            txtQuotationCode.Text = reader["QuotationCode"].ToString();
                            txtCreateDate.Text = Convert.ToDateTime(reader["CreateDate"]).ToString("dd-MM-yy");
                            txtQuotationName.Text = reader["QuotationName"].ToString();
                            txtSameAs.Text = reader["SameAs"].ToString();
                            txtQty.Text = reader["Qty"].ToString();
                            txtOthersCost.Text = reader["OthersCost"].ToString();
                            txtGTotalCost.Text = reader["GTotalCost"].ToString();

                            ddlCustomer.SelectedValue = reader["CustomerID"].ToString();
                            ddlItemName.SelectedValue = reader["CategoryID"].ToString();
                            ddlSubCategory.SelectedValue = reader["SubCategoryID"].ToString();
                            ddlItemName.SelectedValue = reader["ItemID"].ToString();
                            ddlItemUnit.SelectedValue = reader["ItemUnit"].ToString();
                            ddlStatus.SelectedValue = reader["Status"].ToString();
                        }
                    }
                }
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error loading data: " + ex.Message.Replace("'", "\\'") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) con.Close();
            }
        }
        private void LoadQuotationDetailsForEdit(string quotationID)
        {
            try
            {
                InitialiseDetailsTable();
                DataTable dt = CurrentTable;

                con = conn.openConnection();
                string query = @"SELECT RawMaterialID, RawMaterialName, ReqQty, Unit, UnitPrice, Currency, Loss, TotalCost, Remarks
                                  FROM tbl_PriceQuotationDetails
                                  WHERE QuotationID = @QuotationID
                                  ORDER BY DetailID";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@QuotationID", quotationID);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        int slNo = 1;
                        while (reader.Read())
                        {
                            DataRow dr = dt.NewRow();
                            dr["SlNo"] = slNo++;
                            dr["RawMaterialID"] = reader["RawMaterialID"] == DBNull.Value ? 0 : Convert.ToInt32(reader["RawMaterialID"]);
                            dr["RawMaterialName"] = reader["RawMaterialName"].ToString();
                            dr["ReqQty"] = Convert.ToDecimal(reader["ReqQty"]);
                            dr["Unit"] = reader["Unit"].ToString();
                            dr["UnitPrice"] = Convert.ToDecimal(reader["UnitPrice"]);
                            dr["Currency"] = reader["Currency"].ToString();
                            dr["Loss"] = Convert.ToDecimal(reader["Loss"]);
                            dr["TotalCost"] = Convert.ToDecimal(reader["TotalCost"]);
                            dr["Remarks"] = reader["Remarks"].ToString();
                            dt.Rows.Add(dr);
                        }
                    }
                }
                con.Close();

                CurrentTable = dt;
                gvQuotationDetails.DataSource = dt;
                gvQuotationDetails.DataBind();

                CalculateTotalCost();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error loading item details: " + ex.Message.Replace("'", "\\'") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) con.Close();
            }
        }
        protected void btnAdd_Click(object sender, EventArgs e)
        {
            try
            {
                if (ddlRawMaterial.SelectedValue == "0" || !int.TryParse(ddlRawMaterial.SelectedValue, out int rawMaterialID))
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Please select a valid Raw Material!');", true);
                    return;
                }
                if (!decimal.TryParse(txtReqQty.Text.Trim(), System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out decimal reqQty))
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Please enter a valid number in the Req. Qty field! (You wrote: " + txtReqQty.Text.Trim().Replace("'", "\\'") + "')');", true);
                    return;
                }

                if (!decimal.TryParse(txtUnitPrice.Text.Trim(), System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out decimal unitPrice))
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Please enter a valid number in the Unit Price field! (You wrote: " + txtUnitPrice.Text.Trim().Replace("'", "\\'") + "')');", true);
                    return;
                }

                string lossStr = txtLoss.Text.Trim().Replace("%", "");
                if (!string.IsNullOrEmpty(lossStr) && !decimal.TryParse(lossStr, System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out decimal lossPercent))
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Please enter a valid number in the Loss % field! (You wrote: " + txtLoss.Text.Trim().Replace("'", "\\'") + "')');", true);
                    return;
                }
                decimal.TryParse(lossStr, System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out decimal lossPercentValue);

                decimal subTotal = reqQty * unitPrice;
                decimal totalCost = subTotal + (subTotal * (lossPercentValue / 100));

                DataTable dt = CurrentTable;
                DataRow dr = dt.NewRow();

                int rowIndex = dt.Rows.Count + 1;
                dr["SlNo"] = rowIndex;
                dr["RawMaterialID"] = ddlRawMaterial.SelectedValue;
                dr["RawMaterialName"] = ddlRawMaterial.SelectedItem.Text;
                dr["ReqQty"] = reqQty;
                dr["Unit"] = ddlDetailUnit.SelectedValue;
                dr["UnitPrice"] = unitPrice;
                dr["Currency"] = ddlCurrency.SelectedValue;
                dr["Loss"] = lossPercentValue;
                dr["TotalCost"] = Math.Round(totalCost, 2);
                dr["Remarks"] = "-";

                dt.Rows.Add(dr);
                CurrentTable = dt;

                gvQuotationDetails.DataSource = dt;
                gvQuotationDetails.DataBind();

                CalculateTotalCost();
                ClearItemDetailsInput();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error adding item: " + ex.Message.Replace("'", "\\'") + "');", true);
            }
        }

        protected void gvQuotationDetails_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            int rowIndex = e.RowIndex;
            DataTable dt = CurrentTable;
            if (rowIndex >= 0 && rowIndex < dt.Rows.Count)
            {
                dt.Rows.RemoveAt(rowIndex);

                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    dt.Rows[i]["SlNo"] = i + 1;
                }

                CurrentTable = dt;
                gvQuotationDetails.DataSource = dt;
                gvQuotationDetails.DataBind();

                CalculateTotalCost();
            }
        }

        private void ClearItemDetailsInput()
        {
            if (ddlRawMaterial.Items.Count > 0) ddlRawMaterial.SelectedIndex = 0;
            txtReqQty.Text = "1";
            if (ddlDetailUnit.Items.Count > 0) ddlDetailUnit.SelectedIndex = 0;
            txtUnitPrice.Text = "1";
            if (ddlCurrency.Items.Count > 0) ddlCurrency.SelectedIndex = 0;
            txtLoss.Text = "5";
            txtTotalCostInput.Text = "1.05";
        }

        private void CalculateTotalCost()
        {
            DataTable dt = CurrentTable;
            decimal totalCostSum = 0;

            foreach (DataRow row in dt.Rows)
            {
                decimal cost = 0;
                if (decimal.TryParse(row["TotalCost"].ToString(), out cost))
                {
                    totalCostSum += cost;
                }
            }

            txtTotalCostSum.Text = totalCostSum.ToString("0.00");

            decimal othersCost = 0;
            decimal.TryParse(txtOthersCost.Text, out othersCost);

            decimal grandTotal = totalCostSum + othersCost;
            txtGTotalCost.Text = grandTotal.ToString("0.00");
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            SqlConnection con = null;

            try
            {
                if (CurrentTable.Rows.Count == 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(),
                        "alert", "alert('Please add at least one item detail row before saving.');", true);
                    return;
                }

                con = conn.openConnection();

                int currentUserId = Session["UserID"] != null ? Convert.ToInt32(Session["UserID"]) : 0;
                int existingId = string.IsNullOrEmpty(Costing_No.Value) ? 0 : Convert.ToInt32(Costing_No.Value);

                // ---------- STEP 1: Save Master ONCE ----------
                int savedQuotationId;
                using (SqlCommand cmdMaster = new SqlCommand("sp_InsertUpdatePriceQuotationMaster", con))
                {
                    cmdMaster.CommandType = CommandType.StoredProcedure;

                    cmdMaster.Parameters.Add("@ID", SqlDbType.Int).Value = existingId == 0 ? (object)DBNull.Value : existingId;
                    cmdMaster.Parameters.Add("@QuotationCode", SqlDbType.VarChar, 50).Value = txtQuotationCode.Text.Trim();
                    cmdMaster.Parameters.Add("@CreateDate", SqlDbType.Date).Value = Convert.ToDateTime(txtCreateDate.Text);
                    cmdMaster.Parameters.Add("@CustomerID", SqlDbType.Int).Value = ddlCustomer.SelectedValue;
                    cmdMaster.Parameters.Add("@CategoryID", SqlDbType.Int).Value = ddlItemCategory.SelectedValue;
                    cmdMaster.Parameters.Add("@SubCategoryID", SqlDbType.Int).Value = ddlSubCategory.SelectedValue;
                    cmdMaster.Parameters.Add("@ItemID", SqlDbType.Int).Value = ddlItemName.SelectedValue;
                    cmdMaster.Parameters.Add("@QuotationName", SqlDbType.VarChar, 250).Value = txtQuotationName.Text.Trim();
                    cmdMaster.Parameters.Add("@SameAs", SqlDbType.VarChar, 100).Value =
                        string.IsNullOrEmpty(txtSameAs.Text) ? (object)DBNull.Value : txtSameAs.Text.Trim();
                    cmdMaster.Parameters.Add("@Qty", SqlDbType.Decimal).Value = Convert.ToDecimal(txtQty.Text);
                    cmdMaster.Parameters.Add("@ItemUnit", SqlDbType.VarChar, 50).Value = ddlItemUnit.SelectedValue;
                    cmdMaster.Parameters.Add("@Status", SqlDbType.Int).Value = ddlStatus.SelectedValue;
                    cmdMaster.Parameters.Add("@OthersCost", SqlDbType.Decimal).Value = Convert.ToDecimal(txtOthersCost.Text);
                    cmdMaster.Parameters.Add("@GTotalCost", SqlDbType.Decimal).Value = Convert.ToDecimal(txtGTotalCost.Text);
                    cmdMaster.Parameters.Add("@CreatedBy", SqlDbType.Int).Value = currentUserId;
                    cmdMaster.Parameters.Add("@CreatedAt", SqlDbType.DateTime).Value = DateTime.Now;
                    cmdMaster.Parameters.Add("@UpdatedBy", SqlDbType.Int).Value = currentUserId;
                    cmdMaster.Parameters.Add("@UpdatedAt", SqlDbType.DateTime).Value = DateTime.Now;

                    cmdMaster.Parameters.Add("@IsMasterCall", SqlDbType.Bit).Value = true;

                    SqlParameter outputId = cmdMaster.Parameters.Add("@QuotationID", SqlDbType.Int);
                    outputId.Direction = ParameterDirection.Output;

                    cmdMaster.ExecuteNonQuery();
                    savedQuotationId = Convert.ToInt32(outputId.Value);
                }

                // Remember the ID so future saves on this form are UPDATEs, not new inserts
                Costing_No.Value = savedQuotationId.ToString();
                ViewState["QuotationID"] = savedQuotationId.ToString();

                // ---------- STEP 2: Save each Detail row ----------
                foreach (DataRow row in CurrentTable.Rows)
                {
                    using (SqlCommand cmdDetail = new SqlCommand("sp_InsertUpdatePriceQuotationMaster", con))
                    {
                        cmdDetail.CommandType = CommandType.StoredProcedure;

                        cmdDetail.Parameters.Add("@ID", SqlDbType.Int).Value = savedQuotationId;
                        cmdDetail.Parameters.Add("@IsMasterCall", SqlDbType.Bit).Value = false;

                        cmdDetail.Parameters.Add("@RawMaterialID", SqlDbType.Int).Value = row["RawMaterialID"];
                        cmdDetail.Parameters.Add("@RawMaterialName", SqlDbType.VarChar, 150).Value = row["RawMaterialName"];
                        cmdDetail.Parameters.Add("@ReqQty", SqlDbType.Decimal).Value = row["ReqQty"];
                        cmdDetail.Parameters.Add("@Unit", SqlDbType.VarChar, 50).Value = row["Unit"];
                        cmdDetail.Parameters.Add("@UnitPrice", SqlDbType.Decimal).Value = row["UnitPrice"];
                        cmdDetail.Parameters.Add("@Currency", SqlDbType.VarChar, 20).Value = row["Currency"];
                        cmdDetail.Parameters.Add("@Loss", SqlDbType.VarChar, 50).Value = row["Loss"].ToString();
                        cmdDetail.Parameters.Add("@TotalCost", SqlDbType.Decimal).Value = row["TotalCost"];
                        cmdDetail.Parameters.Add("@Remarks", SqlDbType.VarChar, 250).Value =
                            string.IsNullOrEmpty(row["Remarks"].ToString()) ? (object)DBNull.Value : row["Remarks"].ToString();

                        SqlParameter outParam = cmdDetail.Parameters.Add("@QuotationID", SqlDbType.Int);
                        outParam.Direction = ParameterDirection.Output;

                        cmdDetail.ExecuteNonQuery();
                    }
                }

                ScriptManager.RegisterStartupScript(this, this.GetType(),
                    "alert", "alert('Save Successfully!');", true);

                pnlList.Visible = true;
                pnlEntry.Visible = false;
                LoadQuotationList();
                ClearForm();
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

        protected void ddlItemName_SelectedIndexChanged(object sender, EventArgs e)
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT * FROM tbl_UnitSetup WHERE Status='Active' ORDER BY UnitName ASC";
                SqlDataAdapter da = new SqlDataAdapter(query, con);
                DataTable dt = new DataTable();
                da.Fill(dt);

                ddlItemUnit.DataSource = dt;
                ddlItemUnit.DataTextField = "UnitName";
                ddlItemUnit.DataValueField = "UnitID";
                ddlItemUnit.DataBind();
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

        protected void ddlItemCategory_SelectedIndexChanged(object sender, EventArgs e)
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT * FROM ta_SubCategory WHERE CategoryID='" + ddlItemCategory.SelectedValue + "' and Status='Active' ORDER BY SubCategoryName ASC";
                SqlDataAdapter da = new SqlDataAdapter(query, con);
                DataTable dt = new DataTable();
                da.Fill(dt);
                ddlSubCategory.DataSource = dt;
                ddlSubCategory.DataTextField = "SubCategoryName";
                ddlSubCategory.DataValueField = "SubCategoryID";
                ddlSubCategory.DataBind();
                ddlSubCategory.Items.Insert(0, new ListItem("--Select Sub Category--", "0"));
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

        protected void ddlSubCategory_SelectedIndexChanged(object sender, EventArgs e)
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT * FROM ta_ItemName WHERE SubCategoryID='"+ ddlSubCategory.SelectedValue + "' and Status='Active' ORDER BY ItemName ASC";
                SqlDataAdapter da = new SqlDataAdapter(query, con);
                DataTable dt = new DataTable();
                da.Fill(dt);

                ddlItemName.DataSource = dt;
                ddlItemName.DataTextField = "ItemName";
                ddlItemName.DataValueField = "ItemID";
                ddlItemName.DataBind();
                ddlItemName.Items.Insert(0, new ListItem("--Select Item Name--", "0"));
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

        protected void ddlRawMaterial_SelectedIndexChanged(object sender, EventArgs e)
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT * FROM tbl_UnitSetup where UnitID='" + ddlRawMaterial.SelectedValue + "' and Status='Active' ORDER BY UnitName ASC";
                SqlDataAdapter da = new SqlDataAdapter(query, con);
                DataTable dt = new DataTable();
                da.Fill(dt);

                ddlDetailUnit.DataSource = dt;
                ddlDetailUnit.DataTextField = "UnitName";
                ddlDetailUnit.DataValueField = "UnitID";
                ddlDetailUnit.DataBind();
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
    }
}
