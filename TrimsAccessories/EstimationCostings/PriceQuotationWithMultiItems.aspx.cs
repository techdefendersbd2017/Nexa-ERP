using Nexa_ERP.Connection;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.TrimsAccessories.EstimationCostings
{
    public partial class PriceQuotationWithMultiItems : System.Web.UI.Page
    {
        SqlConnection con;
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadQuotationList();
                LoadRawMaterial();
                LoadCustomer();
                LoadItemCategory();
                LoadddlSearchCustomer();

                txtCreateDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                ViewState["QuotationID"] = "0";
                Costing_No.Value = "0";
                hdnSelectedItemSlNo.Value = "0";

                InitialiseItemsTable();
                InitialiseDetailsTable();
            }
        }

        // ==========================================
        // VIEWSTATE TABLES
        //   ItemsTable   -> one row per Item added in "Item List" grid (gvItemList)
        //   DetailsTable -> one row per Raw Material, linked back to its Item via ItemSlNo
        // ==========================================
        private DataTable CurrentItemsTable
        {
            get
            {
                if (ViewState["ItemsTable"] == null) InitialiseItemsTable();
                return (DataTable)ViewState["ItemsTable"];
            }
            set { ViewState["ItemsTable"] = value; }
        }

        private DataTable CurrentDetailsTable
        {
            get
            {
                if (ViewState["DetailsTable"] == null) InitialiseDetailsTable();
                return (DataTable)ViewState["DetailsTable"];
            }
            set { ViewState["DetailsTable"] = value; }
        }

        private int NextItemSlNo
        {
            get { return ViewState["NextItemSlNo"] == null ? 1 : (int)ViewState["NextItemSlNo"]; }
            set { ViewState["NextItemSlNo"] = value; }
        }

        private int NextDetailSlNo
        {
            get { return ViewState["NextDetailSlNo"] == null ? 1 : (int)ViewState["NextDetailSlNo"]; }
            set { ViewState["NextDetailSlNo"] = value; }
        }

        // Which Item (row in gvItemList) is currently active for "Add Materials"
        private int SelectedItemSlNo
        {
            get { return string.IsNullOrEmpty(hdnSelectedItemSlNo.Value) ? 0 : Convert.ToInt32(hdnSelectedItemSlNo.Value); }
            set { hdnSelectedItemSlNo.Value = value.ToString(); }
        }

        private void InitialiseItemsTable()
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("ItemSlNo", typeof(int));
            dt.Columns.Add("CategoryID", typeof(int));
            dt.Columns.Add("ItemCategory", typeof(string));
            dt.Columns.Add("SubCategoryID", typeof(int));
            dt.Columns.Add("SubCategory", typeof(string));
            dt.Columns.Add("ItemID", typeof(int));
            dt.Columns.Add("ItemName", typeof(string));
            dt.Columns.Add("UnitID", typeof(int));
            dt.Columns.Add("Unit", typeof(string));
            dt.Columns.Add("Qty", typeof(decimal));
            dt.Columns.Add("ItemTotalCost", typeof(decimal));
            ViewState["ItemsTable"] = dt;
            ViewState["NextItemSlNo"] = 1;
        }

        private void InitialiseDetailsTable()
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("SlNo", typeof(int));
            dt.Columns.Add("ItemSlNo", typeof(int)); // FK -> ItemsTable.ItemSlNo
            dt.Columns.Add("RawMaterialID", typeof(int));
            dt.Columns.Add("RawMaterialName", typeof(string));
            dt.Columns.Add("ReqQty", typeof(decimal));
            dt.Columns.Add("Unit", typeof(string));
            dt.Columns.Add("UnitPrice", typeof(decimal));
            dt.Columns.Add("Currency", typeof(string));
            dt.Columns.Add("Loss", typeof(decimal));
            dt.Columns.Add("TotalCost", typeof(decimal));
            dt.Columns.Add("Remarks", typeof(string));
            ViewState["DetailsTable"] = dt;
            ViewState["NextDetailSlNo"] = 1;
        }

        private void SetSelectedValueSafe(DropDownList ddl, string value)
        {
            if (ddl == null || string.IsNullOrEmpty(value)) return;
            if (ddl.Items.FindByValue(value) != null)
            {
                ddl.SelectedValue = value;
            }
        }

        // ==========================================
        // LOAD DROPDOWNS
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
                ddlItemCategory.Items.Insert(0, new ListItem("--Select Category--", "0"));
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) con.Close();
            }
        }

        private void LoadddlSearchCustomer()
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT * FROM tbl_CustomerSupplier WHERE Status='Active'  and PartyType='1' ORDER BY PartyName ASC";
                SqlDataAdapter da = new SqlDataAdapter(query, con);
                DataTable dt = new DataTable();
                da.Fill(dt);

                ddlSearchCustomer.DataSource = dt;
                ddlSearchCustomer.DataTextField = "PartyName";
                ddlSearchCustomer.DataValueField = "PartyID";
                ddlSearchCustomer.DataBind();
                ddlSearchCustomer.Items.Insert(0, new ListItem("--Select Customer--", "0"));
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) con.Close();
            }
        }

        private void LoadCustomer()
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT * FROM tbl_CustomerSupplier WHERE Status='Active'  and PartyType='1' ORDER BY PartyName ASC";
                SqlDataAdapter da = new SqlDataAdapter(query, con);
                DataTable dt = new DataTable();
                da.Fill(dt);

                ddlCustomer.DataSource = dt;
                ddlCustomer.DataTextField = "PartyName";
                ddlCustomer.DataValueField = "PartyID";
                ddlCustomer.DataBind();
                ddlCustomer.Items.Insert(0, new ListItem("--Select Customer--", "0"));
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) con.Close();
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
                ddlRawMaterial.Items.Insert(0, new ListItem("--Select Raw Material--", "0"));
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) con.Close();
            }
        }

        private void LoadSubCategoryList(string categoryId)
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT * FROM ta_SubCategory WHERE CategoryID=@CategoryID AND Status='Active' ORDER BY SubCategoryName ASC";
                using (SqlCommand cmdSub = new SqlCommand(query, con))
                {
                    cmdSub.Parameters.AddWithValue("@CategoryID", categoryId);
                    SqlDataAdapter da = new SqlDataAdapter(cmdSub);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlSubCategory.DataSource = dt;
                    ddlSubCategory.DataTextField = "SubCategoryName";
                    ddlSubCategory.DataValueField = "SubCategoryID";
                    ddlSubCategory.DataBind();
                    ddlSubCategory.Items.Insert(0, new ListItem("--Select Sub Category--", "0"));
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) con.Close();
            }
        }

        private void LoadItemNameList(string subCategoryId)
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT * FROM ta_ItemName WHERE SubCategoryID=@SubCategoryID AND Status='Active' ORDER BY ItemName ASC";
                using (SqlCommand cmdItem = new SqlCommand(query, con))
                {
                    cmdItem.Parameters.AddWithValue("@SubCategoryID", subCategoryId);
                    SqlDataAdapter da = new SqlDataAdapter(cmdItem);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlItemName.DataSource = dt;
                    ddlItemName.DataTextField = "ItemName";
                    ddlItemName.DataValueField = "ItemID";
                    ddlItemName.DataBind();
                    ddlItemName.Items.Insert(0, new ListItem("--Select Item Name--", "0"));
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) con.Close();
            }
        }
        private void LoadItemUnitList()
        {
            if (!int.TryParse(ddlItemName.SelectedValue, out int itemId) || itemId <= 0)
            {
                ddlItemUnit.DataSource = null;
                ddlItemUnit.DataBind();
                return;
            }

            try
            {
                con = conn.openConnection();
                string query = @"SELECT ta_ItemName.ItemID, tbl_UnitSetup.UnitID, tbl_UnitSetup.UnitName, tbl_UnitSetup.Status
                        FROM ta_ItemName INNER JOIN tbl_UnitSetup ON ta_ItemName.Unit = tbl_UnitSetup.UnitID 
                        WHERE tbl_UnitSetup.Status='Active' AND ta_ItemName.ItemID = @ItemID
                        ORDER BY tbl_UnitSetup.UnitName ASC";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.Add("@ItemID", SqlDbType.Int).Value = itemId;
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    ddlItemUnit.DataSource = dt;
                    ddlItemUnit.DataTextField = "UnitName";
                    ddlItemUnit.DataValueField = "UnitID";
                    ddlItemUnit.DataBind();
                }
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) con.Close();
            }
        }

        private void LoadddlDetailUnit()
        {
            if (!int.TryParse(ddlRawMaterial.SelectedValue, out int rawMaterialId) || rawMaterialId <= 0)
            {
                ddlDetailUnit.DataSource = null;
                ddlDetailUnit.DataBind();
                return;
            }

            try
            {
                con = conn.openConnection();
                string query = @"SELECT tbl_UnitSetup.UnitID, tbl_UnitSetup.UnitName, tbl_UnitSetup.Status, ta_RawMaterial.RawMaterialID
                        FROM tbl_UnitSetup INNER JOIN ta_RawMaterial ON tbl_UnitSetup.UnitID = ta_RawMaterial.Unit
                        WHERE tbl_UnitSetup.Status='Active' AND ta_RawMaterial.RawMaterialID = @RawMaterialID
                        ORDER BY tbl_UnitSetup.UnitName ASC";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.Add("@RawMaterialID", SqlDbType.Int).Value = rawMaterialId;
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    ddlDetailUnit.DataSource = dt;
                    ddlDetailUnit.DataTextField = "UnitName";
                    ddlDetailUnit.DataValueField = "UnitID";
                    ddlDetailUnit.DataBind();
                }
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) con.Close();
            }
        }
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
                        string lastCode = result.ToString().Trim();
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

            return prefix + nextNumber.ToString("D4");
        }

        // ==========================================
        // TOP-LEVEL BUTTONS
        // ==========================================
        protected void btnAddNew_Click(object sender, EventArgs e)
        {
            pnlList.Visible = false;
            pnlEntry.Visible = true;
            ClearForm();
            txtQuotationCode.Text = GetNextQuotationCode();
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

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadQuotationList();
        }

        private void ClearForm()
        {
            ViewState["QuotationID"] = "0";
            Costing_No.Value = "0";
            SelectedItemSlNo = 0;

            txtQuotationCode.Text = string.Empty;
            txtQuotationName.Text = string.Empty;
            txtSameAs.Text = string.Empty;
            txtOthersCost.Text = "0.00";
            txtTotalCostSum.Text = "0.00";
            txtGTotalCost.Text = "0.00";
            txtItemTotalCost.Text = "0.00";
            lblSelectedItemName.Text = "-- No item selected --";

            if (ddlCustomer.Items.Count > 0) ddlCustomer.SelectedIndex = 0;
            if (ddlStatus.Items.Count > 0) ddlStatus.SelectedIndex = 0;

            InitialiseItemsTable();
            InitialiseDetailsTable();
            gvItemList.DataSource = CurrentItemsTable;
            gvItemList.DataBind();
            gvQuotationDetails.DataSource = CurrentDetailsTable;
            gvQuotationDetails.DataBind();

            ClearItemEntryInputs();
            ClearMaterialEntryInputs();

            btnSave.Text = "Save";
            btnAddItem.Text = "Add Item";
            btnAdd.Text = "Add";
            ViewState["EditingItemSlNo"] = null;
            ViewState["EditingDetailSlNo"] = null;
        }

        // ==========================================
        // QUOTATION LIST
        // ==========================================
        private void LoadQuotationList()
        {
            try
            {
                con = conn.openConnection();

                // ---- পরিবর্তন: CTE দিয়ে QuotationCode অনুযায়ী duplicate বাদ (latest QuotationID রাখা হবে) ----
                string query = @"
            ;WITH QuotationData AS (
                SELECT m.QuotationID, m.QuotationCode, m.CreateDate, m.CustomerID,
                       c.PartyName AS Customer, m.QuotationName, m.GTotalCost, m.Status,
                       ROW_NUMBER() OVER (PARTITION BY m.QuotationCode ORDER BY m.QuotationID DESC) AS RowRank
                FROM tbl_PriceQuotationMaster m
                LEFT JOIN tbl_CustomerSupplier c ON m.CustomerID = c.PartyID
                WHERE 1=1";

                if (!string.IsNullOrEmpty(txtSearchQuotationNo.Text.Trim()))
                    query += " AND m.QuotationCode LIKE @QuotationCode";
                if (ddlSearchCustomer.SelectedValue != "0")
                    query += " AND m.CustomerID = @CustomerID";
                if (!string.IsNullOrEmpty(txtFromDate.Text) && !string.IsNullOrEmpty(txtTillDate.Text))
                    query += " AND m.CreateDate BETWEEN @FromDate AND @TillDate";

                query += @"
            )
            SELECT QuotationID,
                   ROW_NUMBER() OVER(ORDER BY QuotationID DESC) AS SlNo,
                   QuotationCode,
                   CONVERT(VARCHAR(10), CreateDate, 105) AS CreateDate,
                   Customer, QuotationName, GTotalCost,
                   CASE WHEN Status = 1 THEN 'Active' ELSE 'Inactive' END AS Status
            FROM QuotationData
            WHERE RowRank = 1
            ORDER BY QuotationID DESC";
                // -----------------------------------------------------------------------------------------

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
                Costing_No.Value = quotationID; // critical: btnSave_Click reads existingId from this field

                pnlList.Visible = false;
                pnlEntry.Visible = true;
                btnSave.Text = "Update";

                LoadQuotationDataForEdit(quotationID);
                LoadQuotationDetailsForEdit(quotationID);
            }
            else if (e.CommandName == "PrintQuotation")
            {
                string quotationID = e.CommandArgument.ToString();
                string script = "window.open('OrdersReports/PriceQuotationPrint.aspx?QID=" + quotationID + "', '_blank');";
                ScriptManager.RegisterStartupScript(this, this.GetType(), "printWin", script, true);
            }
            else if (e.CommandName == "PrintQuotationShort")
            {
                string quotationID = e.CommandArgument.ToString();
                string script = "window.open('OrdersReports/PriceQuotationPrintItemsWise.aspx?QID=" + quotationID + "', '_blank');";
                ScriptManager.RegisterStartupScript(this, this.GetType(), "printWin", script, true);
            }
        }

        private void LoadQuotationDataForEdit(string quotationID)
        {
            try
            {
                con = conn.openConnection();
                string query = @"SELECT 
    m.QuotationID, m.QuotationCode, m.CreateDate, m.CustomerID, 
    m.CategoryID, c.CategoryName, m.SubCategoryID, s.SubCategoryName,
    m.ItemID, n.ItemName, m.QuotationName, m.SameAs, 
    m.Qty, m.ItemUnit, m.Status, m.OthersCost, m.GTotalCost, 
    m.CreatedBy, m.CreatedAt, m.UpdatedBy, m.UpdatedAt
FROM tbl_PriceQuotationMaster AS m
LEFT JOIN ta_ItemCategory AS c ON m.CategoryID = c.CategoryID
LEFT JOIN ta_SubCategory AS s ON m.SubCategoryID = s.SubCategoryID
LEFT JOIN ta_ItemName AS n ON m.ItemID = n.ItemID
WHERE m.QuotationID = @QuotationID";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@QuotationID", quotationID);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        bool isFirstRow = true;
                        InitialiseItemsTable();
                        DataTable itemsDt = CurrentItemsTable;
                        int slNo = 1;
                        while (reader.Read())
                        {
                            if (isFirstRow)
                            {
                                txtQuotationCode.Text = reader["QuotationCode"].ToString();
                                txtCreateDate.Text = Convert.ToDateTime(reader["CreateDate"]).ToString("yyyy-MM-dd");
                                txtQuotationName.Text = reader["QuotationName"].ToString();
                                txtSameAs.Text = reader["SameAs"].ToString();
                                txtOthersCost.Text = reader["OthersCost"].ToString();
                                txtGTotalCost.Text = reader["GTotalCost"].ToString();
                                SetSelectedValueSafe(ddlCustomer, reader["CustomerID"].ToString());
                                SetSelectedValueSafe(ddlStatus, reader["Status"].ToString());
                                isFirstRow = false;
                            }
                            DataRow itemRow = itemsDt.NewRow();
                            itemRow["ItemSlNo"] = slNo;
                            itemRow["CategoryID"] = reader["CategoryID"] == DBNull.Value ? 0 : Convert.ToInt32(reader["CategoryID"]);
                            itemRow["SubCategoryID"] = reader["SubCategoryID"] == DBNull.Value ? 0 : Convert.ToInt32(reader["SubCategoryID"]);
                            itemRow["ItemID"] = reader["ItemID"] == DBNull.Value ? 0 : Convert.ToInt32(reader["ItemID"]);
                            itemRow["Qty"] = reader["Qty"] == DBNull.Value ? 0 : Convert.ToDecimal(reader["Qty"]);
                            itemRow["Unit"] = reader["ItemUnit"].ToString();
                            itemRow["UnitID"] = 0;
                            itemRow["ItemTotalCost"] = 0m; // recalculated after details load
                            itemRow["ItemCategory"] = reader["CategoryName"] == DBNull.Value ? "" : reader["CategoryName"].ToString();
                            itemRow["SubCategory"] = reader["SubCategoryName"] == DBNull.Value ? "" : reader["SubCategoryName"].ToString();
                            itemRow["ItemName"] = reader["ItemName"] == DBNull.Value ? "" : reader["ItemName"].ToString();
                            itemsDt.Rows.Add(itemRow);
                            slNo++;
                        }
                        CurrentItemsTable = itemsDt;
                        NextItemSlNo = slNo;
                        SelectedItemSlNo = 1;
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
                DataTable dt = CurrentDetailsTable;
                con = conn.openConnection();
                string query = @"SELECT RawMaterialID, RawMaterialName, ReqQty, Unit, UnitPrice, Currency, Loss, TotalCost, Remarks FROM tbl_PriceQuotationDetails WHERE QuotationID = @QuotationID ORDER BY DetailID";
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
                            dr["ItemSlNo"] = 1; // all legacy details attach to the single reconstructed item
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
                        NextDetailSlNo = slNo;
                    }
                }
                con.Close();
                CurrentDetailsTable = dt;
                RecalculateItemTotal(1);
                BindItemList();
                BindDetailsForSelectedItem();
                RecalculateGrandTotal();
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
        protected void ddlItemCategory_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadSubCategoryList(ddlItemCategory.SelectedValue);
        }
        protected void ddlSubCategory_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadItemNameList(ddlSubCategory.SelectedValue);
        }
        protected void ddlItemName_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadItemUnitList();
        }
        private void ClearItemEntryInputs()
        {
            if (ddlItemCategory.Items.Count > 0) ddlItemCategory.SelectedIndex = 0;
            if (ddlSubCategory.Items.Count > 0) ddlSubCategory.SelectedIndex = 0;
            if (ddlItemName.Items.Count > 0) ddlItemName.SelectedIndex = 0;
            if (ddlItemUnit.Items.Count > 0) ddlItemUnit.SelectedIndex = 0;
            txtQty.Text = "1";
        }

        protected void btnAddItem_Click(object sender, EventArgs e)
        {
            try
            {
                if (ddlItemCategory.SelectedValue == "0")
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Please select an Item Category!');", true);
                    return;
                }
                if (ddlSubCategory.SelectedValue == "0")
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Please select a Sub Category!');", true);
                    return;
                }
                if (ddlItemName.SelectedValue == "0")
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Please select an Item Name!');", true);
                    return;
                }
                if (!decimal.TryParse(txtQty.Text.Trim(), System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out decimal qty) || qty <= 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Please enter a valid Qty!');", true);
                    return;
                }
                DataTable dt = CurrentItemsTable;
                object editingObj = ViewState["EditingItemSlNo"];
                if (editingObj != null)
                {
                    int editingSlNo = (int)editingObj;
                    DataRow[] found = dt.Select("ItemSlNo = " + editingSlNo);
                    if (found.Length > 0)
                    {
                        DataRow dr = found[0];
                        dr["CategoryID"] = ddlItemCategory.SelectedValue;
                        dr["ItemCategory"] = ddlItemCategory.SelectedItem.Text;
                        dr["SubCategoryID"] = ddlSubCategory.SelectedValue;
                        dr["SubCategory"] = ddlSubCategory.SelectedItem.Text;
                        dr["ItemID"] = ddlItemName.SelectedValue;
                        dr["ItemName"] = ddlItemName.SelectedItem.Text;
                        dr["UnitID"] = ddlItemUnit.SelectedValue;
                        dr["Unit"] = ddlItemUnit.SelectedItem.Text;
                        dr["Qty"] = qty;
                    }
                    ViewState["EditingItemSlNo"] = null;
                    btnAddItem.Text = "Add Item";
                }
                else
                {
                    DataRow dr = dt.NewRow();
                    int slNo = NextItemSlNo;
                    dr["ItemSlNo"] = slNo;
                    dr["CategoryID"] = ddlItemCategory.SelectedValue;
                    dr["ItemCategory"] = ddlItemCategory.SelectedItem.Text;
                    dr["SubCategoryID"] = ddlSubCategory.SelectedValue;
                    dr["SubCategory"] = ddlSubCategory.SelectedItem.Text;
                    dr["ItemID"] = ddlItemName.SelectedValue;
                    dr["ItemName"] = ddlItemName.SelectedItem.Text;
                    dr["UnitID"] = ddlItemUnit.SelectedValue;
                    dr["Unit"] = ddlItemUnit.SelectedItem.Text;
                    dr["Qty"] = qty;
                    dr["ItemTotalCost"] = 0m;
                    dt.Rows.Add(dr);
                    NextItemSlNo = slNo + 1;
                }

                CurrentItemsTable = dt;
                BindItemList();
                ClearItemEntryInputs();
                RecalculateGrandTotal();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error adding item: " + ex.Message.Replace("'", "\\'") + "');", true);
            }
        }

        protected void gvItemList_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int itemSlNo = Convert.ToInt32(e.CommandArgument);
            DataRow[] found = CurrentItemsTable.Select("ItemSlNo = " + itemSlNo);
            if (found.Length == 0) return;
            DataRow itemRow = found[0];

            if (e.CommandName == "SelectItem")
            {
                SelectedItemSlNo = itemSlNo;
                lblSelectedItemName.Text = itemRow["ItemName"].ToString();
                txtItemTotalCost.Text = Convert.ToDecimal(itemRow["ItemTotalCost"]).ToString("0.00");
                BindItemList(); // refresh so the row highlight (active-item-row) applies
                BindDetailsForSelectedItem();
            }
            else if (e.CommandName == "EditItem")
            {
                LoadSubCategoryList(itemRow["CategoryID"].ToString());
                LoadItemNameList(itemRow["SubCategoryID"].ToString());
                LoadItemUnitList();
                SetSelectedValueSafe(ddlItemCategory, itemRow["CategoryID"].ToString());
                SetSelectedValueSafe(ddlSubCategory, itemRow["SubCategoryID"].ToString());
                SetSelectedValueSafe(ddlItemName, itemRow["ItemID"].ToString());
                SetSelectedValueSafe(ddlItemUnit, itemRow["UnitID"].ToString());
                txtQty.Text = itemRow["Qty"].ToString();
                ViewState["EditingItemSlNo"] = itemSlNo;
                btnAddItem.Text = "Update Item";
            }
            else if (e.CommandName == "DeleteItem")
            {
                CurrentItemsTable.Rows.Remove(itemRow);
                DataTable detailsDt = CurrentDetailsTable;
                foreach (DataRow d in detailsDt.Select("ItemSlNo = " + itemSlNo))
                {
                    detailsDt.Rows.Remove(d);
                }
                CurrentDetailsTable = detailsDt;

                if (SelectedItemSlNo == itemSlNo)
                {
                    SelectedItemSlNo = 0;
                    lblSelectedItemName.Text = "-- No item selected --";
                    txtItemTotalCost.Text = "0.00";
                }
                BindItemList();
                BindDetailsForSelectedItem();
                RecalculateGrandTotal();
            }
        }
        protected void gvItemList_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                DataRowView drv = e.Row.DataItem as DataRowView;
                if (drv != null && Convert.ToInt32(drv["ItemSlNo"]) == SelectedItemSlNo && SelectedItemSlNo != 0)
                {
                    e.Row.CssClass += " active-item-row";
                }
            }
        }
        private void BindItemList()
        {
            gvItemList.DataSource = CurrentItemsTable;
            gvItemList.DataBind();
        }
        private void SetSelectedTextSafe(DropDownList ddl, string text)
        {
            if (ddl == null || string.IsNullOrEmpty(text)) return;
            ListItem item = ddl.Items.FindByText(text);
            if (item != null)
            {
                ddl.ClearSelection();
                item.Selected = true;
            }
        }
        protected void ddlRawMaterial_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadddlDetailUnit();
        }
        private void ClearMaterialEntryInputs()
        {
            if (ddlRawMaterial.Items.Count > 0) ddlRawMaterial.SelectedIndex = 0;
            txtReqQty.Text = "0";
            if (ddlDetailUnit.Items.Count > 0) ddlDetailUnit.SelectedIndex = 0;
            txtUnitPrice.Text = "0";
            if (ddlCurrency.Items.Count > 0) ddlCurrency.SelectedIndex = 0;
            txtLoss.Text = "0";
            txtTotalCostInput.Text = "0.00";
        }
        protected void btnAdd_Click(object sender, EventArgs e)
        {
            try
            {
                if (SelectedItemSlNo == 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Please select an Item first (click \"Add Materials\" on an item in the Item List).');", true);
                    return;
                }
                if (ddlRawMaterial.SelectedValue == "0")
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Please select a valid Raw Material!');", true);
                    return;
                }
                if (ddlDetailUnit.SelectedItem.Text == "")
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Please select a valid Unit!');", true);
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
                if (!string.IsNullOrEmpty(lossStr) && !decimal.TryParse(lossStr, System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out decimal _))
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Please enter a valid number in the Loss % field! (You wrote: " + txtLoss.Text.Trim().Replace("'", "\\'") + "')');", true);
                    return;
                }
                decimal.TryParse(lossStr, System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out decimal lossPercentValue);
                decimal subTotal = reqQty * unitPrice;
                decimal totalCost = Math.Round(subTotal + (subTotal * (lossPercentValue / 100)), 2);
                string selectedUnitId = ddlDetailUnit.SelectedValue;
                string selectedUnitName = ddlDetailUnit.SelectedItem.Text;
                DataTable dt = CurrentDetailsTable;
                object editingObj = ViewState["EditingDetailSlNo"];
                if (editingObj != null)
                {
                    int editingSlNo = (int)editingObj;
                    DataRow[] found = dt.Select("SlNo = " + editingSlNo);
                    if (found.Length > 0)
                    {
                        DataRow dr = found[0];
                        dr["RawMaterialID"] = ddlRawMaterial.SelectedValue;
                        dr["RawMaterialName"] = ddlRawMaterial.SelectedItem.Text;
                        dr["ReqQty"] = reqQty;
                        dr["Unit"] = selectedUnitName;
                        dr["UnitPrice"] = unitPrice;
                        dr["Currency"] = ddlCurrency.SelectedValue;
                        dr["Loss"] = lossPercentValue;
                        dr["TotalCost"] = totalCost;
                    }
                    ViewState["EditingDetailSlNo"] = null;
                    btnAdd.Text = "Add";
                }
                else
                {
                    DataRow dr = dt.NewRow();
                    int slNo = NextDetailSlNo;
                    dr["SlNo"] = slNo;
                    dr["ItemSlNo"] = SelectedItemSlNo;
                    dr["RawMaterialID"] = ddlRawMaterial.SelectedValue;
                    dr["RawMaterialName"] = ddlRawMaterial.SelectedItem.Text;
                    dr["ReqQty"] = reqQty;
                    dr["Unit"] = selectedUnitName;
                    dr["UnitPrice"] = unitPrice;
                    dr["Currency"] = ddlCurrency.SelectedValue;
                    dr["Loss"] = lossPercentValue;
                    dr["TotalCost"] = totalCost;
                    dr["Remarks"] = "-";
                    dt.Rows.Add(dr);
                    NextDetailSlNo = slNo + 1;
                }

                CurrentDetailsTable = dt;
                BindDetailsForSelectedItem();
                RecalculateItemTotal(SelectedItemSlNo);
                BindItemList();
                RecalculateGrandTotal();
                ClearMaterialEntryInputs();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error adding material: " + ex.Message.Replace("'", "\\'") + "');", true);
            }
        }
        protected void gvQuotationDetails_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "EditDetail")
            {
                int rowIndex = Convert.ToInt32(e.CommandArgument);
                DataView view = new DataView(CurrentDetailsTable);
                view.RowFilter = "ItemSlNo = " + SelectedItemSlNo;
                if (rowIndex < 0 || rowIndex >= view.Count) return;
                DataRowView drv = view[rowIndex];
                SetSelectedValueSafe(ddlRawMaterial, drv["RawMaterialID"].ToString());
                LoadddlDetailUnit();                                    // ✅ নতুন লাইন — Unit dropdown রিলোড
                txtReqQty.Text = drv["ReqQty"].ToString();
                SetSelectedValueSafe(ddlDetailUnit, drv["Unit"].ToString()); // ✅ Value নয়, Text দিয়ে match
                txtUnitPrice.Text = drv["UnitPrice"].ToString();
                SetSelectedValueSafe(ddlCurrency, drv["Currency"].ToString());
                txtLoss.Text = drv["Loss"].ToString();
                txtTotalCostInput.Text = Convert.ToDecimal(drv["TotalCost"]).ToString("0.00");
                ViewState["EditingDetailSlNo"] = Convert.ToInt32(drv["SlNo"]);
                btnAdd.Text = "Update";
            }
        }
        protected void gvQuotationDetails_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            int slNo = Convert.ToInt32(gvQuotationDetails.DataKeys[e.RowIndex]["SlNo"]);
            DataTable dt = CurrentDetailsTable;
            DataRow[] found = dt.Select("SlNo = " + slNo);
            if (found.Length > 0)
            {
                dt.Rows.Remove(found[0]);
                CurrentDetailsTable = dt;
                BindDetailsForSelectedItem();
                RecalculateItemTotal(SelectedItemSlNo);
                BindItemList();
                RecalculateGrandTotal();
            }
        }
        private void BindDetailsForSelectedItem()
        {
            DataView view = new DataView(CurrentDetailsTable);
            view.RowFilter = SelectedItemSlNo == 0 ? "1=0" : "ItemSlNo = " + SelectedItemSlNo;
            gvQuotationDetails.DataSource = view;
            gvQuotationDetails.DataBind();
        }
        private void RecalculateItemTotal(int itemSlNo)
        {
            if (itemSlNo == 0) return;
            decimal itemSum = 0;
            foreach (DataRow row in CurrentDetailsTable.Select("ItemSlNo = " + itemSlNo))
            {
                itemSum += Convert.ToDecimal(row["TotalCost"]);
            }
            DataRow[] itemRows = CurrentItemsTable.Select("ItemSlNo = " + itemSlNo);
            if (itemRows.Length > 0)
            {
                itemRows[0]["ItemTotalCost"] = itemSum;
            }
            if (SelectedItemSlNo == itemSlNo)
            {
                txtItemTotalCost.Text = itemSum.ToString("0.00");
            }
        }
        private void RecalculateGrandTotal()
        {
            decimal totalCostSum = 0;
            foreach (DataRow row in CurrentItemsTable.Rows)
            {
                totalCostSum += Convert.ToDecimal(row["ItemTotalCost"]);
            }
            txtTotalCostSum.Text = totalCostSum.ToString("0.00");

            decimal othersCost = 0;
            decimal.TryParse(txtOthersCost.Text, out othersCost);

            txtGTotalCost.Text = (totalCostSum + othersCost).ToString("0.00");
        }
        protected void btnSave_Click(object sender, EventArgs e)
        {
            SqlConnection con = null;
            if (ddlCustomer.SelectedValue == "0")
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Please select a Customer!');", true);
                return;
            }
            if (string.IsNullOrEmpty(txtQuotationName.Text.Trim()))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Please enter the Quotation Name!');", true);
                return;
            }
            if (string.IsNullOrEmpty(txtQuotationCode.Text.Trim()))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Quotation Code is missing!');", true);
                return;
            }
            if (!DateTime.TryParse(txtCreateDate.Text.Trim(), out DateTime _))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Please enter a valid Create Date!');", true);
                return;
            }
            if (ddlStatus.SelectedValue == "0")
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Please select a Status!');", true);
                return;
            }
            foreach (DataRow itemRow in CurrentItemsTable.Rows)
            {
                int itemSlNo = Convert.ToInt32(itemRow["ItemSlNo"]);
                if (CurrentDetailsTable.Select("ItemSlNo = " + itemSlNo).Length == 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Item \"" + itemRow["ItemName"] + "\" has no Raw Material added!');", true);
                    return;
                }
            }
            if (!decimal.TryParse(txtGTotalCost.Text.Trim(), out decimal gTotal) || gTotal <= 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Grand Total Cost must be greater than 0!');", true);
                return;
            }
            try
            {
                if (CurrentItemsTable.Rows.Count == 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Please add at least one Item before saving.');", true);
                    return;
                }

                con = conn.openConnection();
                int currentUserId = Session["UserID"] != null ? Convert.ToInt32(Session["UserID"]) : 0;
                int existingId = string.IsNullOrEmpty(Costing_No.Value) ? 0 : Convert.ToInt32(Costing_No.Value);
                DataRow firstItem = CurrentItemsTable.Rows[0];
                int savedQuotationId;
                using (SqlCommand cmdMaster = new SqlCommand("sp_InsertUpdatePriceQuotationMaster", con))
                {
                    cmdMaster.CommandType = CommandType.StoredProcedure;
                    cmdMaster.Parameters.Add("@ID", SqlDbType.Int).Value = existingId == 0 ? (object)DBNull.Value : existingId;
                    cmdMaster.Parameters.Add("@QuotationCode", SqlDbType.VarChar, 50).Value = txtQuotationCode.Text.Trim();
                    cmdMaster.Parameters.Add("@CreateDate", SqlDbType.Date).Value = Convert.ToDateTime(txtCreateDate.Text);
                    cmdMaster.Parameters.Add("@CustomerID", SqlDbType.Int).Value = ddlCustomer.SelectedValue;
                    cmdMaster.Parameters.Add("@CategoryID", SqlDbType.Int).Value = firstItem["CategoryID"];
                    cmdMaster.Parameters.Add("@SubCategoryID", SqlDbType.Int).Value = firstItem["SubCategoryID"];
                    cmdMaster.Parameters.Add("@ItemID", SqlDbType.Int).Value = firstItem["ItemID"];
                    cmdMaster.Parameters.Add("@QuotationName", SqlDbType.VarChar, 250).Value = txtQuotationName.Text.Trim();
                    cmdMaster.Parameters.Add("@SameAs", SqlDbType.VarChar, 100).Value = string.IsNullOrEmpty(txtSameAs.Text) ? (object)DBNull.Value : txtSameAs.Text.Trim();
                    cmdMaster.Parameters.Add("@Qty", SqlDbType.Decimal).Value = firstItem["Qty"];
                    cmdMaster.Parameters.Add("@ItemUnit", SqlDbType.VarChar, 50).Value = firstItem["UnitID"];
                    cmdMaster.Parameters.Add("@Status", SqlDbType.Int).Value = ddlStatus.SelectedValue;
                    cmdMaster.Parameters.Add("@OthersCost", SqlDbType.Decimal).Value = Convert.ToDecimal(txtOthersCost.Text);
                    cmdMaster.Parameters.Add("@GTotalCost", SqlDbType.Decimal).Value = Convert.ToDecimal(txtGTotalCost.Text);
                    cmdMaster.Parameters.Add("@CreatedBy", SqlDbType.Int).Value = currentUserId;
                    cmdMaster.Parameters.Add("@CreatedAt", SqlDbType.DateTime).Value = DateTime.Now;
                    cmdMaster.Parameters.Add("@UpdatedBy", SqlDbType.Int).Value = currentUserId;
                    cmdMaster.Parameters.Add("@UpdatedAt", SqlDbType.DateTime).Value = DateTime.Now;
                    cmdMaster.Parameters.Add("@IsMasterCall", SqlDbType.Bit).Value = true;
                    cmdMaster.Parameters.Add("@IsItemCall", SqlDbType.Bit).Value = false;
                    SqlParameter outputId = cmdMaster.Parameters.Add("@QuotationID", SqlDbType.Int);
                    outputId.Direction = ParameterDirection.Output;
                    cmdMaster.ExecuteNonQuery();
                    savedQuotationId = Convert.ToInt32(outputId.Value);
                }
                Costing_No.Value = savedQuotationId.ToString();
                ViewState["QuotationID"] = savedQuotationId.ToString();
                foreach (DataRow itemRow in CurrentItemsTable.Rows)
                {
                    int itemId = itemRow["ItemID"] == DBNull.Value ? 0 : Convert.ToInt32(itemRow["ItemID"]);
                    using (SqlCommand cmdItem = new SqlCommand("sp_InsertUpdatePriceQuotationMaster", con))
                    {
                        cmdItem.CommandType = CommandType.StoredProcedure;
                        cmdItem.Parameters.Add("@ID", SqlDbType.Int).Value = savedQuotationId;
                        cmdItem.Parameters.Add("@IsMasterCall", SqlDbType.Bit).Value = false;
                        cmdItem.Parameters.Add("@IsItemCall", SqlDbType.Bit).Value = true;
                        cmdItem.Parameters.Add("@ItemSlNo", SqlDbType.Int).Value = itemRow["ItemSlNo"];
                        cmdItem.Parameters.Add("@CategoryID", SqlDbType.Int).Value = itemRow["CategoryID"];
                        cmdItem.Parameters.Add("@SubCategoryID", SqlDbType.Int).Value = itemRow["SubCategoryID"];
                        cmdItem.Parameters.Add("@ItemID", SqlDbType.Int).Value = itemRow["ItemID"];
                        cmdItem.Parameters.Add("@Qty", SqlDbType.Decimal).Value = itemRow["Qty"];
                        cmdItem.Parameters.Add("@ItemUnit", SqlDbType.VarChar, 50).Value = itemRow["UnitID"];
                        SqlParameter outItemId = cmdItem.Parameters.Add("@QuotationID", SqlDbType.Int);
                        outItemId.Direction = ParameterDirection.Output;
                        cmdItem.ExecuteNonQuery();
                    }
                    foreach (DataRow row in CurrentDetailsTable.Select("ItemSlNo = " + itemRow["ItemSlNo"]))
                    {
                        using (SqlCommand cmdDetail = new SqlCommand("sp_InsertUpdatePriceQuotationMaster", con))
                        {
                            cmdDetail.CommandType = CommandType.StoredProcedure;
                            cmdDetail.Parameters.Add("@ID", SqlDbType.Int).Value = savedQuotationId;
                            cmdDetail.Parameters.Add("@IsMasterCall", SqlDbType.Bit).Value = false;
                            cmdDetail.Parameters.Add("@IsItemCall", SqlDbType.Bit).Value = false;
                            cmdDetail.Parameters.Add("@RawMaterialID", SqlDbType.Int).Value = row["RawMaterialID"];
                            cmdDetail.Parameters.Add("@RawMaterialName", SqlDbType.VarChar, 150).Value = row["RawMaterialName"];
                            cmdDetail.Parameters.Add("@ReqQty", SqlDbType.Decimal).Value = row["ReqQty"];
                            cmdDetail.Parameters.Add("@Unit", SqlDbType.VarChar, 50).Value = row["Unit"];
                            cmdDetail.Parameters.Add("@UnitPrice", SqlDbType.Decimal).Value = row["UnitPrice"];
                            cmdDetail.Parameters.Add("@Currency", SqlDbType.VarChar, 20).Value = row["Currency"];
                            cmdDetail.Parameters.Add("@Loss", SqlDbType.VarChar, 50).Value = row["Loss"].ToString();
                            cmdDetail.Parameters.Add("@TotalCost", SqlDbType.Decimal).Value = row["TotalCost"];
                            cmdDetail.Parameters.Add("@ItemID", SqlDbType.Int).Value = itemId;
                            string remarks = row["Remarks"] == null || row["Remarks"] == DBNull.Value ? "" : row["Remarks"].ToString();
                            if (remarks == "-") remarks = "";
                            cmdDetail.Parameters.Add("@Remarks", SqlDbType.VarChar, 250).Value = string.IsNullOrEmpty(remarks) ? (object)DBNull.Value : remarks;SqlParameter outParam = cmdDetail.Parameters.Add("@QuotationID", SqlDbType.Int);
                            outParam.Direction = ParameterDirection.Output;
                            cmdDetail.ExecuteNonQuery();
                        }
                    }
                }

                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Save Successfully!');", true);

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
        private string GetQuotationIdFromCode(string quotationCodeSearch)
        {
            string id = "0";
            try
            {
                con = conn.openConnection();
                // Same search pattern as txtSearchQuotationNo in LoadQuotationList (LIKE match)
                string query = @"SELECT TOP 1 QuotationID 
                          FROM tbl_PriceQuotationMaster 
                          WHERE QuotationCode LIKE @QuotationCode
                          ORDER BY QuotationID DESC";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@QuotationCode", "%" + quotationCodeSearch + "%");
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                        id = result.ToString();
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert",
                    "alert('Error finding quotation: " + ex.Message.Replace("'", "\\'") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) con.Close();
            }
            return id;
        }

        protected void btnCopy_Click(object sender, EventArgs e)
        {
            string enteredCode = txtSameAs.Text.Trim();
            if (string.IsNullOrEmpty(enteredCode))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert",
                    "alert('Please enter a Quotation No to copy from!');", true);
                return;
            }

            string sourceQuotationId = GetQuotationIdFromCode(enteredCode); // ✅ List page-এর মতোই LIKE সার্চ
            if (sourceQuotationId == "0")
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert",
                    "alert('No quotation found matching that Quotation No!');", true);
                return;
            }

            pnlList.Visible = false;
            pnlEntry.Visible = true;
            LoadQuotationDataForEdit(sourceQuotationId);
            LoadQuotationDetailsForEdit(sourceQuotationId);
            ViewState["QuotationID"] = "0";
            Costing_No.Value = "0";
            txtQuotationCode.Text = GetNextQuotationCode();
            txtSameAs.Text = enteredCode;
            btnSave.Text = "Save";
        }

        protected void gvQuotationDetails_SelectedIndexChanged(object sender, EventArgs e)
        {

        }
    }
}