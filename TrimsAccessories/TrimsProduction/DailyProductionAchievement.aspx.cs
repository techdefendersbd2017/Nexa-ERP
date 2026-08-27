using Nexa_ERP.Connection;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.TrimsAccessories.TrimsProduction
{
    public partial class DailyProductionAchievement : Page
    {
        SqlConnection con;
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtProdDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                LoadCompany();
                LoadItemCategory();       // binds ddlLine - same source/pattern as DailyProductionTarget
                LoadCustomerSupplier();
                BindEmptyGrid();
                hdnAchievementID.Value = "0";
            }
        }

        // =================================================================
        //  Dropdown data loaders (same queries/pattern as DailyProductionTarget.aspx.cs
        //  so both pages stay consistent with the same master data)
        // =================================================================
        private void LoadCompany()
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

                    ddlCompany.DataSource = dt;
                    ddlCompany.DataTextField = "Branch_Name";
                    ddlCompany.DataValueField = "Branch_ID";
                    ddlCompany.DataBind();

                    ddlCompany.Items.Insert(0, new ListItem("--Select Company--", "0"));
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error: " + ex.Message.Replace("'", "\\'") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) con.Close();
            }
        }

        private void LoadBuilding()
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT * FROM vw_BuildingInformation WHERE Branch_ID=@BranchID ORDER BY Building_Name";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@BranchID", ddlCompany.SelectedValue);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlBuilding.DataSource = dt;
                    ddlBuilding.DataTextField = "Building_Name";
                    ddlBuilding.DataValueField = "Building_ID";
                    ddlBuilding.DataBind();

                    ddlBuilding.Items.Insert(0, new ListItem("--Select Building--", "0"));
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error: " + ex.Message.Replace("'", "\\'") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) con.Close();
            }
        }

        private void LoadFloor()
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT Floor_ID, Floor_Name FROM vw_Floor_Information WHERE Building_ID=@BuildingID ORDER BY Floor_Name";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@BuildingID", ddlBuilding.SelectedValue);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlFloor.DataSource = dt;
                    ddlFloor.DataTextField = "Floor_Name";
                    ddlFloor.DataValueField = "Floor_ID";
                    ddlFloor.DataBind();

                    ddlFloor.Items.Insert(0, new ListItem("--Select Floor--", "0"));
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error: " + ex.Message.Replace("'", "\\'") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) con.Close();
            }
        }

        // NOTE: reproduced from DailyProductionTarget.aspx.cs — "Production Line" is
        // actually populated from ta_ItemCategory there too, so keeping the same
        // source here for consistency between the two pages.
        private void LoadItemCategory()
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT * FROM ta_ItemCategory WHERE Status='Active' ORDER BY CategoryName ASC";
                SqlDataAdapter da = new SqlDataAdapter(query, con);
                DataTable dt = new DataTable();
                da.Fill(dt);

                ddlLine.DataSource = dt;
                ddlLine.DataTextField = "CategoryName";
                ddlLine.DataValueField = "CategoryID";
                ddlLine.DataBind();
                ddlLine.Items.Insert(0, new ListItem("--Select Category--", "0"));
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error: " + ex.Message.Replace("'", "\\'") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) con.Close();
            }
        }

        private void LoadCustomerSupplier()
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT PartyID, PartyName FROM tbl_CustomerSupplier ORDER BY PartyName";
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
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error: " + ex.Message.Replace("'", "\\'") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) con.Close();
            }
        }

        // Same @PartyID-based filter as the (fixed) LoadWorkOrder in DailyProductionTarget.aspx.cs.
        // CONFIRM: if WorkOrder_Master's FK column to tbl_CustomerSupplier is not
        // literally named "CustomerName", change only the column name below.
        private void LoadWorkOrder()
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT * FROM WorkOrder_Master where CustomerName=@PartyID ORDER BY WorkOrderNo";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@PartyID", ddlCustomer.SelectedValue);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlWONo.DataSource = dt;
                    ddlWONo.DataTextField = "WorkOrderNo";
                    ddlWONo.DataValueField = "WorkOrderID";
                    ddlWONo.DataBind();

                    ddlWONo.Items.Insert(0, new ListItem("--Select Work Order--", "0"));
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error: " + ex.Message.Replace("'", "\\'") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) con.Close();
            }
        }

        // Loads the Item dropdown from whatever Target rows exist for the selected
        // Date + Line — NOT gated behind Work Order, because one section/line can
        // have several items (= several Work Orders) targeted the same day, and
        // requiring Work Order first was hiding the whole list. The dropdown value
        // is the TargetID itself, so once an Item is picked, everything else
        // (Total Target Qty, hourly breakdown, Company/Building/Floor/Customer/
        // WorkOrder) can be pulled straight from that one row — no re-matching.
        private void LoadItemsForTarget()
        {
            ddlItemName.Items.Clear();
            ddlItemName.Items.Insert(0, new ListItem("--Select Item--", "0"));
            lblItemHint.Visible = false;

            if (string.IsNullOrEmpty(txtProdDate.Text)) return;
            if (string.IsNullOrEmpty(ddlLine.SelectedValue) || ddlLine.SelectedValue == "0") return;

            try
            {
                con = conn.openConnection();
                // CONFIRM: assumes DailyProductionTarget has an ItemID column (as used
                // in DailyProductionTarget.aspx.cs's LoadEntryForEdit/btnSaveTarget_Click).
                // LEFT JOIN (not INNER) on ta_ItemName: if a Target row's ItemID is
                // orphaned/mismatched (item deleted, ItemID 0/NULL, etc.), an INNER
                // JOIN would silently drop that row from the list entirely, and the
                // row would still exist in DailyProductionTarget — causing the
                // confusing "Target entry no longer exists" error later when the
                // user picks a *different* item whose TargetID collides in logic.
                // With LEFT JOIN every Target row shows up, with a fallback label
                // if the item name can't be resolved, so nothing is hidden.
                string query = @"SELECT dpt.TargetID, ta.ItemName, wo.WorkOrderNo
                                  FROM DailyProductionTarget dpt
                                  LEFT JOIN ta_ItemName ta ON dpt.ItemID = ta.ItemID
                                  LEFT JOIN WorkOrder_Master wo ON dpt.WorkOrderID = wo.WorkOrderID
                                  WHERE dpt.TargetDate = @TargetDate AND dpt.LineID = @LineID
                                  ORDER BY ta.ItemName";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@TargetDate", Convert.ToDateTime(txtProdDate.Text));
                    cmd.Parameters.AddWithValue("@LineID", Convert.ToInt32(ddlLine.SelectedValue));
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    foreach (DataRow r in dt.Rows)
                    {
                        string woNo = r["WorkOrderNo"] == DBNull.Value ? "" : r["WorkOrderNo"].ToString();
                        string itemNm = r["ItemName"] == DBNull.Value ? ("(Unknown Item - TargetID " + r["TargetID"] + ")") : r["ItemName"].ToString();
                        string text = string.IsNullOrEmpty(woNo) ? itemNm : itemNm + " (WO: " + woNo + ")";
                        ddlItemName.Items.Add(new ListItem(text, r["TargetID"].ToString()));
                    }

                    if (dt.Rows.Count == 0)
                    {
                        lblItemHint.Text = "No Production Target found for this Date & Line. Set a target first on the Daily Production Target page.";
                        lblItemHint.Visible = true;
                    }
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

        private void SetDropDownValue(DropDownList ddl, object value)
        {
            if (value == null || value == DBNull.Value) return;
            ListItem item = ddl.Items.FindByValue(value.ToString());
            if (item != null) ddl.SelectedValue = value.ToString();
        }

        // =================================================================
        //  Hourly grid helpers
        // =================================================================
        private DataTable NewHourlyTable()
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("HourSlot", typeof(string));
            dt.Columns.Add("TargetQty", typeof(int));
            dt.Columns.Add("ActualQty", typeof(int));
            dt.Columns.Add("Variance", typeof(int));
            dt.Columns.Add("Remarks", typeof(string));
            return dt;
        }

        private void BindEmptyGrid()
        {
            gvHourlyAchievement.DataSource = NewHourlyTable();
            gvHourlyAchievement.DataBind();
            txtTotalTarget.Text = "0";
            txtTotalActual.Text = "0";
            txtAchievementPercent.Text = "0%";
        }

        // Recomputes totals/variance server-side from whatever is currently in the grid.
        // (The page also does this live in JS, but we never trust the client at save time.)
        private void RecalculateTotals()
        {
            int totalTarget = 0;
            int totalActual = 0;

            foreach (GridViewRow row in gvHourlyAchievement.Rows)
            {
                if (row.RowType != DataControlRowType.DataRow) continue;

                TextBox txtTarget = row.FindControl("txtSlotTarget") as TextBox;
                TextBox txtActual = row.FindControl("txtSlotActual") as TextBox;
                TextBox txtVariance = row.FindControl("txtSlotVariance") as TextBox;

                int targetVal = ParseIntOrZero(txtTarget?.Text);
                int actualVal = ParseIntOrZero(txtActual?.Text);
                int variance = actualVal - targetVal;

                if (txtVariance != null)
                    txtVariance.Text = (variance > 0 ? "+" : "") + variance;

                totalTarget += targetVal;
                totalActual += actualVal;
            }

            txtTotalTarget.Text = totalTarget.ToString();
            txtTotalActual.Text = totalActual.ToString();
            txtAchievementPercent.Text = totalTarget > 0
                ? Math.Round((totalActual / (double)totalTarget) * 100, 1).ToString(CultureInfo.InvariantCulture) + "%"
                : "0%";
        }

        // =================================================================
        //  Load Target Data (button) — validates, then delegates to
        //  LoadTargetDataForSelectedItem (same method the Item dropdown uses).
        // =================================================================
        protected void btnLoadTarget_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(txtProdDate.Text))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Please select Production Date.');", true);
                return;
            }
            if (string.IsNullOrEmpty(ddlLine.SelectedValue) || ddlLine.SelectedValue == "0")
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Please select a Production Line.');", true);
                return;
            }
            if (string.IsNullOrEmpty(ddlItemName.SelectedValue) || ddlItemName.SelectedValue == "0")
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Please select an Item. (If the list is empty, no Target has been set for this Date/Line yet — set one first on the Daily Production Target page.)');", true);
                return;
            }

            int targetID = Convert.ToInt32(ddlItemName.SelectedValue);
            LoadTargetDataForSelectedItem(targetID);
        }

        // =================================================================
        //  Core loader — pulls everything for a given TargetID (= the value
        //  behind the selected Item) and fills: Company/Building/Floor,
        //  Customer/WorkOrder, Total Target Qty, hourly grid, and picks up
        //  any already-saved Achievement for edit. Called from both the
        //  "Load Target Data" button and directly when the Item dropdown
        //  changes — so picking an Item is enough to bring in its target
        //  quantity, no extra click needed. Filter is on the selected
        //  Item/TargetID.
        // =================================================================
        private void LoadTargetDataForSelectedItem(int targetID)
        {
            try
            {
                con = conn.openConnection();

                // 1) Pull the full Target header row and use it to auto-fill/verify
                //    Company, Building, Floor, Customer, Work Order and the item text —
                //    so the rest of the form always matches what was actually targeted,
                //    even if those dropdowns weren't touched by the user.
                //    CONFIRM: column names must match your actual DailyProductionTarget table.
                int totalTargetQty = 0;
                int branchID = 0, buildingID = 0, floorID = 0, buyerID = 0, workOrderID = 0;
                string itemName = string.Empty;

                // LEFT JOIN here too — an INNER JOIN would return zero rows (and
                // trigger the false "Target entry no longer exists" message) if
                // this Target row's ItemID doesn't match anything in ta_ItemName,
                // even though the Target row itself is perfectly real.
                string targetQuery = @"SELECT dpt.TargetID, dpt.TotalTargetQty, dpt.BranchID, dpt.BuildingID, dpt.FloorID,
                                               dpt.BuyerID, dpt.WorkOrderID, ta.ItemName
                                        FROM DailyProductionTarget dpt
                                        LEFT JOIN ta_ItemName ta ON dpt.ItemID = ta.ItemID
                                        WHERE dpt.TargetID = @TargetID";
                using (SqlCommand cmd = new SqlCommand(targetQuery, con))
                {
                    cmd.Parameters.AddWithValue("@TargetID", targetID);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (!reader.Read())
                        {
                            BindEmptyGrid();
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert",
                                "alert('No row found in DailyProductionTarget for TargetID " + targetID + ". Please reselect the Date/Line.');", true);
                            return;
                        }

                        totalTargetQty = reader["TotalTargetQty"] == DBNull.Value ? 0 : Convert.ToInt32(reader["TotalTargetQty"]);
                        branchID = reader["BranchID"] == DBNull.Value ? 0 : Convert.ToInt32(reader["BranchID"]);
                        buildingID = reader["BuildingID"] == DBNull.Value ? 0 : Convert.ToInt32(reader["BuildingID"]);
                        floorID = reader["FloorID"] == DBNull.Value ? 0 : Convert.ToInt32(reader["FloorID"]);
                        buyerID = reader["BuyerID"] == DBNull.Value ? 0 : Convert.ToInt32(reader["BuyerID"]);
                        workOrderID = reader["WorkOrderID"] == DBNull.Value ? 0 : Convert.ToInt32(reader["WorkOrderID"]);
                        itemName = reader["ItemName"] == DBNull.Value ? ("(Unknown Item - TargetID " + targetID + ")") : reader["ItemName"].ToString();
                    }
                }

                // Show Total Target Qty immediately, even before the hourly grid loads.
                txtTotalTarget.Text = totalTargetQty.ToString();

                // Auto-select Company -> Building -> Floor and Customer -> Work Order
                // so the filter section reflects the actual target, then cascade-reload
                // each child list before selecting it (same pattern as
                // DailyProductionTarget.aspx.cs's LoadEntryForEdit).
                if (branchID > 0)
                {
                    SetDropDownValue(ddlCompany, branchID);
                    LoadBuilding();
                    if (buildingID > 0) SetDropDownValue(ddlBuilding, buildingID);
                    LoadFloor();
                    if (floorID > 0) SetDropDownValue(ddlFloor, floorID);
                }
                if (buyerID > 0)
                {
                    SetDropDownValue(ddlCustomer, buyerID);
                    LoadWorkOrder();
                    if (workOrderID > 0) SetDropDownValue(ddlWONo, workOrderID);
                }

                // FIX: LoadBuilding()/LoadFloor()/LoadWorkOrder() each open AND close
                // the shared class-level 'con' field in their own try/finally blocks.
                // After calling them above, 'con' is left CLOSED, so every query below
                // this point ("ExecuteScalar requires an open Connection") was failing.
                // Re-open it here before continuing.
                if (con == null || con.State != ConnectionState.Open)
                {
                    con = conn.openConnection();
                }

                // 2) Pull the hourly target breakdown for that TargetID
                //    FIX: previous query did "ORDER BY HourlyID" but that column
                //    doesn't exist in DailyProductionTargetHourly -> caused
                //    "Invalid column name 'HourlyID'". Ordering by HourSlot instead,
                //    since that column is already confirmed to exist (it's read
                //    right after). If HourSlot values aren't naturally sortable
                //    (e.g. "9AM-10AM" vs "10AM-11AM" sorting as text), tell me the
                //    real identity/sequence column name and I'll switch to that.
                DataTable dtTargetHourly = new DataTable();
                string hourlyQuery = "SELECT HourSlot, TargetQty FROM DailyProductionTargetHourly WHERE TargetID = @TargetID ORDER BY HourSlot";
                using (SqlCommand cmd = new SqlCommand(hourlyQuery, con))
                {
                    cmd.Parameters.AddWithValue("@TargetID", targetID);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(dtTargetHourly);
                }

                if (dtTargetHourly.Rows.Count == 0)
                {
                    BindEmptyGrid();
                    txtTotalTarget.Text = totalTargetQty.ToString();
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert",
                        "alert('This Target has a Total Target Qty of " + totalTargetQty + " but no hourly breakdown rows were found in DailyProductionTargetHourly. Check that table for TargetID " + targetID + ".');", true);
                    return;
                }

                // 3) See if an Achievement record already exists for this Date + Line + WorkOrder + Item
                //    (so the user can re-open and edit today's entry instead of duplicating it).
                int achievementID = 0;
                using (SqlCommand cmd = new SqlCommand(
                    @"SELECT TOP 1 AchievementID FROM Trims_DailyProductionAchievement
                      WHERE ProdDate = @ProdDate AND LineID = @LineID AND WorkOrderID = @WorkOrderID AND ItemName = @ItemName
                      ORDER BY AchievementID DESC", con))
                {
                    cmd.Parameters.AddWithValue("@ProdDate", Convert.ToDateTime(txtProdDate.Text));
                    cmd.Parameters.AddWithValue("@LineID", Convert.ToInt32(ddlLine.SelectedValue));
                    cmd.Parameters.AddWithValue("@WorkOrderID", workOrderID);
                    cmd.Parameters.AddWithValue("@ItemName", itemName);
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                        achievementID = Convert.ToInt32(result);
                }

                DataTable dtExistingDetail = new DataTable();
                // FIX: previously this table only got its columns when achievementID > 0
                // (via da.Fill below). For a brand-new entry (achievementID == 0) it
                // stayed completely columnless, but the code further down always calls
                // dtExistingDetail.Select("HourSlot = ...") regardless -> "Cannot find
                // column [HourSlot]". Defining the schema upfront makes .Select() safe
                // in both cases (existing entry or new one).
                dtExistingDetail.Columns.Add("HourSlot", typeof(string));
                dtExistingDetail.Columns.Add("SlotActual", typeof(int));
                dtExistingDetail.Columns.Add("Remarks", typeof(string));
                string shiftRemarks = string.Empty;
                if (achievementID > 0)
                {
                    using (SqlCommand cmd = new SqlCommand("SELECT ShiftRemarks FROM Trims_DailyProductionAchievement WHERE AchievementID=@ID", con))
                    {
                        cmd.Parameters.AddWithValue("@ID", achievementID);
                        object result = cmd.ExecuteScalar();
                        shiftRemarks = (result != null && result != DBNull.Value) ? result.ToString() : string.Empty;
                    }

                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT HourSlot, SlotActual, Remarks FROM Trims_DailyProductionAchievementDetail WHERE AchievementID=@ID", con))
                    {
                        cmd.Parameters.AddWithValue("@ID", achievementID);
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        // FIX: Fill() into a table that already has explicit columns
                        // defined above works fine and keeps those column types;
                        // it will not duplicate/clear the schema.
                        da.Fill(dtExistingDetail);
                    }
                }

                // 4) Build the working grid: Target from the Target page, Actual/Remarks
                //    prefilled from the existing Achievement record if one was found.
                DataTable dtGrid = NewHourlyTable();
                foreach (DataRow tRow in dtTargetHourly.Rows)
                {
                    string hourSlot = tRow["HourSlot"].ToString();
                    int targetQty = tRow["TargetQty"] == DBNull.Value ? 0 : Convert.ToInt32(tRow["TargetQty"]);

                    int actualQty = 0;
                    string remarks = string.Empty;

                    DataRow[] matches = dtExistingDetail.Select("HourSlot = '" + hourSlot.Replace("'", "''") + "'");
                    if (matches.Length > 0)
                    {
                        actualQty = matches[0]["SlotActual"] == DBNull.Value ? 0 : Convert.ToInt32(matches[0]["SlotActual"]);
                        remarks = matches[0]["Remarks"] == DBNull.Value ? string.Empty : matches[0]["Remarks"].ToString();
                    }

                    dtGrid.Rows.Add(hourSlot, targetQty, actualQty, actualQty - targetQty, remarks);
                }

                gvHourlyAchievement.DataSource = dtGrid;
                gvHourlyAchievement.DataBind();

                txtTotalTarget.Text = totalTargetQty.ToString();
                if (achievementID > 0)
                    txtShiftRemarks.Text = shiftRemarks;

                RecalculateTotals();

                hdnAchievementID.Value = achievementID.ToString();
                pnlEditBanner.Visible = achievementID > 0;
                if (achievementID > 0)
                    lblEditBanner.Text = "An achievement entry already exists for this Date / Line / Work Order (Entry #" + achievementID + "). Loaded for editing — Save Achievement will update it.";
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error loading target data: " + ex.Message.Replace("'", "\\'") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) con.Close();
            }
        }

        // =================================================================
        //  Save Achievement (insert if hdnAchievementID = 0, else update)
        // =================================================================
        protected void btnSaveAchievement_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(txtProdDate.Text))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Please select Production Date.');", true);
                return;
            }
            if (ddlCompany.SelectedValue == "0" || string.IsNullOrEmpty(ddlCompany.SelectedValue) ||
                ddlBuilding.SelectedValue == "0" || string.IsNullOrEmpty(ddlBuilding.SelectedValue) ||
                ddlFloor.SelectedValue == "0" || string.IsNullOrEmpty(ddlFloor.SelectedValue) ||
                ddlLine.SelectedValue == "0" || string.IsNullOrEmpty(ddlLine.SelectedValue) ||
                ddlCustomer.SelectedValue == "0" || string.IsNullOrEmpty(ddlCustomer.SelectedValue) ||
                ddlWONo.SelectedValue == "0" || string.IsNullOrEmpty(ddlWONo.SelectedValue) ||
                ddlItemName.SelectedValue == "0" || string.IsNullOrEmpty(ddlItemName.SelectedValue))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Please select Company, Building, Floor, Line, Customer, Work Order and Item before saving.');", true);
                return;
            }
            if (gvHourlyAchievement.Rows.Count == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Please click \\'Load Target Data\\' first so there is hourly data to save.');", true);
                return;
            }

            RecalculateTotals();

            // REQ 1: If total Achievement (Actual Qty) is 0, don't save at all.
            // (Per-hour zero rows are also skipped individually further below.)
            int totalActualCheck = ParseIntOrZero(txtTotalActual.Text);
            if (totalActualCheck <= 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert",
                    "alert('Total Actual Output Qty শূন্য (0) — কমপক্ষে ১টি Hour-এর Actual Output দিন, তারপর Save করুন।');", true);
                return;
            }

            // REQ 2: Enforce sequential hour completion server-side too (not just
            // client-side JS, which a user could bypass) — once an hour slot is
            // left at 0, no LATER hour slot is allowed to have a value. This
            // guarantees hours are always filled in order, 1st -> 2nd -> 3rd...
            bool sawEmptyHourEarlier = false;
            int hourIndexForMsg = 0;
            foreach (GridViewRow checkRow in gvHourlyAchievement.Rows)
            {
                if (checkRow.RowType != DataControlRowType.DataRow) continue;
                hourIndexForMsg++;

                TextBox txtActualCheck = checkRow.FindControl("txtSlotActual") as TextBox;
                int actualCheckVal = ParseIntOrZero(txtActualCheck?.Text);

                if (actualCheckVal <= 0)
                {
                    sawEmptyHourEarlier = true;
                }
                else if (sawEmptyHourEarlier)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert",
                        "alert('Hour #" + hourIndexForMsg + "-এ Output দেওয়ার আগে তার আগের Hour(গুলো) সম্পূর্ণ করুন। ক্রমানুসারে (1st Hour -> 2nd Hour -> ...) পূরণ করতে হবে।');", true);
                    return;
                }
            }

            int userId = Session["UserID"] != null ? Convert.ToInt32(Session["UserID"]) : 1;
            int achievementID = ParseIntOrZero(hdnAchievementID.Value);

            SqlTransaction trans = null;
            try
            {
                con = conn.openConnection();
                trans = con.BeginTransaction();

                decimal achievementPercent = 0;
                decimal.TryParse(txtAchievementPercent.Text.Replace("%", "").Trim(), NumberStyles.Any, CultureInfo.InvariantCulture, out achievementPercent);

                if (achievementID > 0)
                {
                    // ---- UPDATE existing header ----
                    using (SqlCommand cmd = new SqlCommand(@"
                        UPDATE Trims_DailyProductionAchievement SET
                            ProdDate=@ProdDate, CompanyID=@CompanyID, BuildingID=@BuildingID, FloorID=@FloorID,
                            LineID=@LineID, CustomerID=@CustomerID, WorkOrderID=@WorkOrderID, ItemName=@ItemName,
                            TotalTargetQty=@TotalTargetQty, TotalActualQty=@TotalActualQty, AchievementPercent=@AchievementPercent,
                            ShiftRemarks=@ShiftRemarks, UpdatedBy=@UserID, UpdatedDate=GETDATE()
                        WHERE AchievementID=@AchievementID", con, trans))
                    {
                        AddHeaderParams(cmd, achievementPercent, userId);
                        cmd.Parameters.AddWithValue("@AchievementID", achievementID);
                        cmd.ExecuteNonQuery();
                    }

                    // Replace detail rows wholesale - simplest way to keep them in sync with the grid
                    using (SqlCommand cmd = new SqlCommand("DELETE FROM Trims_DailyProductionAchievementDetail WHERE AchievementID=@AchievementID", con, trans))
                    {
                        cmd.Parameters.AddWithValue("@AchievementID", achievementID);
                        cmd.ExecuteNonQuery();
                    }
                }
                else
                {
                    // ---- INSERT new header, get generated AchievementID back ----
                    using (SqlCommand cmd = new SqlCommand(@"
                        INSERT INTO Trims_DailyProductionAchievement
                            (ProdDate, CompanyID, BuildingID, FloorID, LineID, CustomerID, WorkOrderID, ItemName,
                             TotalTargetQty, TotalActualQty, AchievementPercent, ShiftRemarks, CreatedBy, CreatedDate)
                        VALUES
                            (@ProdDate, @CompanyID, @BuildingID, @FloorID, @LineID, @CustomerID, @WorkOrderID, @ItemName,
                             @TotalTargetQty, @TotalActualQty, @AchievementPercent, @ShiftRemarks, @UserID, GETDATE());
                        SELECT CAST(SCOPE_IDENTITY() AS INT);", con, trans))
                    {
                        AddHeaderParams(cmd, achievementPercent, userId);
                        achievementID = Convert.ToInt32(cmd.ExecuteScalar());
                    }
                }

                // ---- Insert current hourly rows ----
                using (SqlCommand cmd = new SqlCommand(@"
                    INSERT INTO Trims_DailyProductionAchievementDetail (AchievementID, HourSlot, SlotTarget, SlotActual, SlotVariance, Remarks)
                    VALUES (@AchievementID, @HourSlot, @SlotTarget, @SlotActual, @SlotVariance, @Remarks)", con, trans))
                {
                    cmd.Parameters.Add("@AchievementID", SqlDbType.Int);
                    cmd.Parameters.Add("@HourSlot", SqlDbType.NVarChar, 50);
                    cmd.Parameters.Add("@SlotTarget", SqlDbType.Int);
                    cmd.Parameters.Add("@SlotActual", SqlDbType.Int);
                    cmd.Parameters.Add("@SlotVariance", SqlDbType.Int);
                    cmd.Parameters.Add("@Remarks", SqlDbType.NVarChar, 250);

                    foreach (GridViewRow row in gvHourlyAchievement.Rows)
                    {
                        if (row.RowType != DataControlRowType.DataRow) continue;

                        string hourSlot = row.Cells[0].Text;
                        TextBox txtTarget = row.FindControl("txtSlotTarget") as TextBox;
                        TextBox txtActual = row.FindControl("txtSlotActual") as TextBox;
                        TextBox txtRemarks = row.FindControl("txtSlotRemarks") as TextBox;

                        int targetVal = ParseIntOrZero(txtTarget?.Text);
                        int actualVal = ParseIntOrZero(txtActual?.Text);

                        // REQ 1: an hour slot with 0 Actual Output does not get its
                        // own row in the database — skip it entirely.
                        if (actualVal <= 0) continue;

                        cmd.Parameters["@AchievementID"].Value = achievementID;
                        cmd.Parameters["@HourSlot"].Value = hourSlot;
                        cmd.Parameters["@SlotTarget"].Value = targetVal;
                        cmd.Parameters["@SlotActual"].Value = actualVal;
                        cmd.Parameters["@SlotVariance"].Value = actualVal - targetVal;
                        cmd.Parameters["@Remarks"].Value = string.IsNullOrEmpty(txtRemarks?.Text) ? (object)DBNull.Value : txtRemarks.Text.Trim();

                        cmd.ExecuteNonQuery();
                    }
                }

                trans.Commit();

                hdnAchievementID.Value = achievementID.ToString();
                pnlEditBanner.Visible = false;

                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert",
                    "alert('Production Achievement (Entry #" + achievementID + ") saved successfully!');", true);
            }
            catch (Exception ex)
            {
                if (trans != null)
                {
                    try { trans.Rollback(); } catch { /* ignore rollback failure */ }
                }
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error saving achievement: " + ex.Message.Replace("'", "\\'") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) con.Close();
            }

            // Local helper to keep the two header SQL commands (insert/update) in sync
            void AddHeaderParams(SqlCommand cmd, decimal achPercent, int uid)
            {
                cmd.Parameters.AddWithValue("@ProdDate", Convert.ToDateTime(txtProdDate.Text));
                cmd.Parameters.AddWithValue("@CompanyID", Convert.ToInt32(ddlCompany.SelectedValue));
                cmd.Parameters.AddWithValue("@BuildingID", Convert.ToInt32(ddlBuilding.SelectedValue));
                cmd.Parameters.AddWithValue("@FloorID", Convert.ToInt32(ddlFloor.SelectedValue));
                cmd.Parameters.AddWithValue("@LineID", Convert.ToInt32(ddlLine.SelectedValue));
                cmd.Parameters.AddWithValue("@CustomerID", Convert.ToInt32(ddlCustomer.SelectedValue));
                cmd.Parameters.AddWithValue("@WorkOrderID", Convert.ToInt32(ddlWONo.SelectedValue));
                cmd.Parameters.AddWithValue("@ItemName", ddlItemName.SelectedItem != null ? ddlItemName.SelectedItem.Text : "");
                cmd.Parameters.AddWithValue("@TotalTargetQty", ParseIntOrZero(txtTotalTarget.Text));
                cmd.Parameters.AddWithValue("@TotalActualQty", ParseIntOrZero(txtTotalActual.Text));
                cmd.Parameters.AddWithValue("@AchievementPercent", achPercent);
                cmd.Parameters.AddWithValue("@ShiftRemarks", string.IsNullOrEmpty(txtShiftRemarks.Text) ? (object)DBNull.Value : txtShiftRemarks.Text.Trim());
                cmd.Parameters.AddWithValue("@UserID", uid);
            }
        }

        // =================================================================
        //  Clear
        // =================================================================
        protected void btnClear_Click(object sender, EventArgs e)
        {
            txtProdDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            ddlCompany.SelectedIndex = 0;
            ddlBuilding.Items.Clear();
            ddlBuilding.Items.Insert(0, new ListItem("--Select Building--", "0"));
            ddlFloor.Items.Clear();
            ddlFloor.Items.Insert(0, new ListItem("--Select Floor--", "0"));
            ddlLine.SelectedIndex = 0;
            ddlCustomer.SelectedIndex = 0;
            ddlWONo.Items.Clear();
            ddlWONo.Items.Insert(0, new ListItem("--Select Work Order--", "0"));
            ddlItemName.Items.Clear();
            ddlItemName.Items.Insert(0, new ListItem("--Select Item--", "0"));
            lblItemHint.Visible = false;
            txtShiftRemarks.Text = string.Empty;

            hdnAchievementID.Value = "0";
            pnlEditBanner.Visible = false;

            BindEmptyGrid();
        }

        // =================================================================
        //  Dropdown cascades / filter events
        // =================================================================
        protected void txtProdDate_TextChanged(object sender, EventArgs e)
        {
            // Date changed after a grid was loaded — force an explicit reload
            // rather than silently saving against the wrong date.
            LoadItemsForTarget();
            hdnAchievementID.Value = "0";
            pnlEditBanner.Visible = false;
            BindEmptyGrid();
        }

        protected void ddlCompany_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadBuilding();

            // REQ 3: Company changed -> whatever was loaded before (grid, edit
            // state) no longer necessarily matches -> reset and require re-pick.
            hdnAchievementID.Value = "0";
            pnlEditBanner.Visible = false;
            BindEmptyGrid();
        }

        protected void ddlBuilding_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadFloor();

            // REQ 3
            hdnAchievementID.Value = "0";
            pnlEditBanner.Visible = false;
            BindEmptyGrid();
        }

        // REQ 3: Floor didn't have a change handler before at all — wire this up
        // in the .aspx too: add OnSelectedIndexChanged="ddlFloor_SelectedIndexChanged"
        // to the ddlFloor DropDownList tag (it already has AutoPostBack="true").
        protected void ddlFloor_SelectedIndexChanged(object sender, EventArgs e)
        {
            hdnAchievementID.Value = "0";
            pnlEditBanner.Visible = false;
            BindEmptyGrid();
        }

        protected void ddlLine_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadItemsForTarget();
            hdnAchievementID.Value = "0";
            pnlEditBanner.Visible = false;
            BindEmptyGrid();
        }

        protected void ddlCustomer_SelectedIndexChanged(object sender, EventArgs e)
        {
            // Customer/Work Order are informational filters here — the Item dropdown
            // is driven purely by Date + Line (see LoadItemsForTarget), so changing
            // these no longer needs to touch it.
            LoadWorkOrder();

            // REQ 3
            hdnAchievementID.Value = "0";
            pnlEditBanner.Visible = false;
            BindEmptyGrid();
        }

        protected void ddlWONo_SelectedIndexChanged(object sender, EventArgs e)
        {
            // REQ 3: Work Order changed -> reset grid/edit state so stale data
            // from a different Work Order can't accidentally get saved.
            hdnAchievementID.Value = "0";
            pnlEditBanner.Visible = false;
            BindEmptyGrid();
        }

        // =================================================================
        //  Item changed — since the dropdown's value IS the TargetID, its
        //  Target Qty (and hourly breakdown) can be loaded immediately here,
        //  without waiting for a separate "Load Target Data" click. Filter
        //  is on the selected Item/TargetID.
        // =================================================================
        protected void ddlItemName_SelectedIndexChanged(object sender, EventArgs e)
        {
            hdnAchievementID.Value = "0";
            pnlEditBanner.Visible = false;

            if (string.IsNullOrEmpty(ddlItemName.SelectedValue) || ddlItemName.SelectedValue == "0")
            {
                BindEmptyGrid();
                return;
            }

            int targetID = Convert.ToInt32(ddlItemName.SelectedValue);
            LoadTargetDataForSelectedItem(targetID);
        }

        // ---------------------------------------------------------------
        // Parse helpers
        // ---------------------------------------------------------------
        private int ParseIntOrZero(string text)
        {
            int val;
            if (string.IsNullOrWhiteSpace(text) || !int.TryParse(text.Trim(), out val))
                return 0;
            return val;
        }

        protected void btnView_Click(object sender, EventArgs e)
        {
            string url = ResolveUrl($"~/TrimsAccessories/TrimsProduction/ProductionReport/DailyProductionAchievementReport.aspx?ProdDate={txtProdDate.Text}");
            string script = $"window.open('{url}', '_blank');";
            ScriptManager.RegisterStartupScript(this, this.GetType(), "OpenRawMaterialReport", script, true);
        }
    }
}
