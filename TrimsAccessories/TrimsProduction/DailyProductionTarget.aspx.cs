using iTextSharp.text.pdf;
using Nexa_ERP.Connection;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Globalization;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections.Generic;

namespace Nexa_ERP.TrimsAccessories.TrimsProduction
{
    public partial class DailyProductionTarget : Page
    {
        // Safe upper bound so a bad value in Working Hours can't create thousands of rows
        private const int MAX_WORKING_HOURS = 24;

        // Session key used to track which existing DB row (TargetID) is
        // currently loaded into the form for editing. Null = not editing.
        private const string SESSION_EDITING_ID = "EditingTargetID";

        SqlConnection con;
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();
        SqlCommand cmd;


        [Serializable]
        private class PendingTargetItem
        {
            public string ItemName { get; set; }
            public int? BranchID { get; set; }
            public int? BuildingID { get; set; }
            public int? FloorID { get; set; }
            public int? LineID { get; set; }
            public int? BuyerID { get; set; }
            public int? WorkOrderID { get; set; }
            public int? ItemID { get; set; }
            public int? OrderQty { get; set; }
            public int? ProductionCompleteQty { get; set; }
            public int? ProductionDueQty { get; set; }
            public int Operator { get; set; }
            public int Helper { get; set; }
            public decimal WorkingHours { get; set; }
            public int PerHourTarget { get; set; }
            public decimal SMV { get; set; }
            public decimal Efficiency { get; set; }
            public int TotalHours { get; set; }
            public int TotalTargetQty { get; set; }
            public string TargetRemarks { get; set; }
            public DataTable HourlyDetails { get; set; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Session["PendingTargets"] = null; // নতুন পেজ লোডে আগের অসম্পূর্ণ লিস্ট মুছে ফেলা হচ্ছে
                Session[SESSION_EDITING_ID] = null; // নতুন পেজ লোডে আগের এডিট স্টেট মুছে ফেলা হচ্ছে

                txtTargetDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                BindHourlyGrid(GetWorkingHours(), 0);
                RecalculateSummary();
                LoadCompany();
                LoadItemCategory();
                LoadCustomerSupplier();
                BindPendingGrid();
            }

            // Postback হলেও (dropdown change ইত্যাদি) Edit-mode বাটনগুলো ঠিক অবস্থায় রাখা হচ্ছে
            int? editingId = Session[SESSION_EDITING_ID] != null
                ? Convert.ToInt32(Session[SESSION_EDITING_ID])
                : (int?)null;
            SetEditModeUI(editingId.HasValue, editingId);
        }

        // Unused placeholder - left as-is (was already empty in the original file)
        private void LoadOrderQTY()
        {

        }


        private void LoadItems()
        {
            try
            {
                con = conn.openConnection();
                string query = @"SELECT WorkOrder_Master.WorkOrderID, ta_ItemName.ItemID, ta_ItemName.ItemName
                    FROM   WorkOrder_Master INNER JOIN ta_ItemName ON WorkOrder_Master.ItemID = ta_ItemName.ItemID WHERE WorkOrder_Master.WorkOrderID = @WorkOrderID ORDER BY ItemName";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@WorkOrderID", ddlWONo.SelectedValue);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlItemName.DataSource = dt;
                    ddlItemName.DataTextField = "ItemName";
                    ddlItemName.DataValueField = "ItemID";
                    ddlItemName.DataBind();
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

        // ---------------------------------------------------------------
        // FIX: was filtering WorkOrder_Master by CustomerName = @CustomerName
        // while passing ddlCustomer.SelectedValue, which is PartyID (an ID,
        // not the customer's name) because ddlCustomer.DataValueField =
        // "PartyID" (see LoadCustomerSupplier). CustomerName never equals a
        // numeric PartyID, so this always returned zero rows and left
        // ddlWONo (and everything downstream: ddlItemName, txtOrderQty)
        // empty.
        //
        // Filtering by the FK column that actually matches PartyID instead.
        // CONFIRM: if WorkOrder_Master's real FK column to
        // tbl_CustomerSupplier is named something other than "PartyID"
        // (e.g. "CustomerID"), change only the column name below.
        // ---------------------------------------------------------------
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
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
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
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) con.Close();
            }
        }

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
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
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

        // ---------------------------------------------------------------
        // Builds "1st Hour", "2nd Hour", "3rd Hour" ... dynamically based
        // on the Working Hours value. defaultQtyPerHour is used to
        // pre-fill each row (e.g. after Calculate distributes the target).
        // ---------------------------------------------------------------
        private void BindHourlyGrid(int workingHours, int defaultQtyPerHour)
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("HourSlot", typeof(string));
            dt.Columns.Add("TargetQty", typeof(int));

            for (int i = 1; i <= workingHours; i++)
            {
                dt.Rows.Add(GetOrdinal(i) + " Hour", defaultQtyPerHour);
            }

            gvHourlyTarget.DataSource = dt;
            gvHourlyTarget.DataBind();
        }

        // Converts 1 -> "1st", 2 -> "2nd", 3 -> "3rd", 4 -> "4th", 11 -> "11th" ...
        private string GetOrdinal(int number)
        {
            if (number % 100 >= 11 && number % 100 <= 13)
                return number + "th";

            switch (number % 10)
            {
                case 1: return number + "st";
                case 2: return number + "nd";
                case 3: return number + "rd";
                default: return number + "th";
            }
        }

        private int GetWorkingHours()
        {
            int hours;
            if (!int.TryParse(txtWorkingHours.Text.Trim(), out hours) || hours <= 0)
                hours = 0; // fallback default

            if (hours > MAX_WORKING_HOURS)
                hours = MAX_WORKING_HOURS;

            return hours;
        }

        // ---------------------------------------------------------------
        // Fires when the user changes Working Hours (AutoPostBack).
        // Rebuilds the grid to have exactly that many rows, keeping
        // whatever Per Hour Target is currently set.
        // ---------------------------------------------------------------
        protected void txtWorkingHours_TextChanged(object sender, EventArgs e)
        {
            int workingHours = GetWorkingHours();
            txtWorkingHours.Text = workingHours.ToString();

            int perHourTarget;
            int.TryParse(txtParHRTaget.Text.Trim(), out perHourTarget);

            BindHourlyGrid(workingHours, perHourTarget);
            RecalculateSummary();
        }

        // ---------------------------------------------------------------
        // Fires when the user directly edits Per Hour Target (AutoPostBack).
        // Whatever value is entered here is pushed into EVERY row of the
        // hourly grid, no matter how many rows (hours) exist.
        // ---------------------------------------------------------------
        protected void txtParHRTaget_TextChanged(object sender, EventArgs e)
        {
            int perHourTarget;
            int.TryParse(txtParHRTaget.Text.Trim(), out perHourTarget);

            int workingHours = GetWorkingHours();

            BindHourlyGrid(workingHours, perHourTarget);
            RecalculateSummary();
        }

        // ---------------------------------------------------------------
        // Calculates Per Hour Target from Manpower, SMV & Efficiency,
        // then distributes it into every row of the hourly grid.
        //
        //   Per Hour Target = (Total Manpower x 60 x Efficiency%) / SMV
        // ---------------------------------------------------------------
        protected void btnCalculate_Click(object sender, EventArgs e)
        {
            try
            {
                int operatorCount, helperCount, workingHours;
                double smv, efficiency;

                int.TryParse(txtOperator.Text.Trim(), out operatorCount);
                int.TryParse(txtHelper.Text.Trim(), out helperCount);
                double.TryParse(txtSMV.Text.Trim(), out smv);
                double.TryParse(txtEfficiency.Text.Trim(), out efficiency);
                workingHours = GetWorkingHours();

                int totalManpower = operatorCount + helperCount;

                if (totalManpower <= 0 || smv <= 0)
                {
                    pnlCalcResult.CssClass = "alert alert-warning d-flex align-items-center gap-2 mb-0";
                    lblCalcResult.Text = "Before calculating, Operator/Helper (Total Manpower) and Style SMV** must be entered.";
                    pnlCalcResult.Visible = true;
                    return;
                }

                int perHourTarget = (int)Math.Round((totalManpower * 60 * (efficiency / 100.0)) / smv);
                int dailyCapacity = perHourTarget * workingHours;

                txtParHRTaget.Text = perHourTarget.ToString();

                // Rebuild the hourly grid using the newly calculated per-hour target
                BindHourlyGrid(workingHours, perHourTarget);

                RecalculateSummary();

                // Show the result clearly to the user
                pnlCalcResult.CssClass = "alert alert-success d-flex align-items-center gap-2 mb-0";
                lblCalcResult.Text = string.Format(
                    "Capacity Calculated → Total Manpower: {0} | Per Hour Capacity: {1} pcs/hr | Working Hours: {2} | Daily Capacity: {3} pcs",
                    totalManpower, perHourTarget, workingHours, dailyCapacity);
                pnlCalcResult.Visible = true;
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error: " + ex.Message.Replace("'", "\\'") + "');", true);
            }
        }

        // ---------------------------------------------------------------
        // Sums whatever quantities currently sit in the hourly grid
        // (server-side fallback in case JS is disabled / on postback)
        // and pushes the totals into the Output Summary boxes.
        // ---------------------------------------------------------------
        private void RecalculateSummary()
        {
            int totalQty = 0;

            foreach (GridViewRow row in gvHourlyTarget.Rows)
            {
                if (row.RowType != DataControlRowType.DataRow) continue;

                TextBox txtHourlyQty = row.FindControl("txtHourlyQty") as TextBox;
                if (txtHourlyQty != null)
                {
                    int qty;
                    int.TryParse(txtHourlyQty.Text.Trim(), out qty);
                    totalQty += qty;
                }
            }

            txtTotalHours.Text = gvHourlyTarget.Rows.Count.ToString();
            txtTotalTargetQty.Text = totalQty.ToString();
        }

        protected void btnSaveTarget_Click(object sender, EventArgs e)
        {
            List<PendingTargetItem> pendingList = Session["PendingTargets"] as List<PendingTargetItem> ?? new List<PendingTargetItem>();

            if (pendingList.Count == 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('The Pending List is empty. Please add at least one item first.');", true);
                return;
            }

            int userId = Session["UserID"] != null ? Convert.ToInt32(Session["UserID"]) : 1;
            int savedCount = 0;

            try
            {
                con = conn.openConnection();

                foreach (var p in pendingList)
                {
                    using (SqlCommand cmd = new SqlCommand("sp_SaveDailyProductionTarget", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;

                        cmd.Parameters.Add("@TargetID", SqlDbType.Int).Value = DBNull.Value;
                        cmd.Parameters[0].Direction = ParameterDirection.InputOutput;

                        cmd.Parameters.Add("@TargetDate", SqlDbType.Date).Value = Convert.ToDateTime(txtTargetDate.Text);
                        cmd.Parameters.Add("@BranchID", SqlDbType.Int).Value = (object)p.BranchID ?? DBNull.Value;
                        cmd.Parameters.Add("@BuildingID", SqlDbType.Int).Value = (object)p.BuildingID ?? DBNull.Value;
                        cmd.Parameters.Add("@FloorID", SqlDbType.Int).Value = (object)p.FloorID ?? DBNull.Value;
                        cmd.Parameters.Add("@LineID", SqlDbType.Int).Value = (object)p.LineID ?? DBNull.Value;
                        cmd.Parameters.Add("@BuyerID", SqlDbType.Int).Value = (object)p.BuyerID ?? DBNull.Value;
                        cmd.Parameters.Add("@WorkOrderID", SqlDbType.Int).Value = (object)p.WorkOrderID ?? DBNull.Value;
                        cmd.Parameters.Add("@ItemID", SqlDbType.Int).Value = (object)p.ItemID ?? DBNull.Value;
                        cmd.Parameters.Add("@OrderQty", SqlDbType.Int).Value = (object)p.OrderQty ?? DBNull.Value;
                        cmd.Parameters.Add("@ProductionCompleteQty", SqlDbType.Int).Value = (object)p.ProductionCompleteQty ?? DBNull.Value;
                        cmd.Parameters.Add("@ProductionDueQty", SqlDbType.Int).Value = (object)p.ProductionDueQty ?? DBNull.Value;
                        cmd.Parameters.Add("@Operator", SqlDbType.Int).Value = p.Operator;
                        cmd.Parameters.Add("@Helper", SqlDbType.Int).Value = p.Helper;
                        cmd.Parameters.Add("@WorkingHours", SqlDbType.Decimal).Value = p.WorkingHours;
                        cmd.Parameters.Add("@PerHourTarget", SqlDbType.Int).Value = p.PerHourTarget;
                        cmd.Parameters.Add("@SMV", SqlDbType.Decimal).Value = p.SMV;
                        cmd.Parameters.Add("@Efficiency", SqlDbType.Decimal).Value = p.Efficiency;
                        cmd.Parameters.Add("@TotalHours", SqlDbType.Int).Value = p.TotalHours;
                        cmd.Parameters.Add("@TotalTargetQty", SqlDbType.Int).Value = p.TotalTargetQty;
                        cmd.Parameters.Add("@TargetRemarks", SqlDbType.VarChar).Value = string.IsNullOrEmpty(p.TargetRemarks) ? (object)DBNull.Value : p.TargetRemarks;
                        cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = userId;

                        SqlParameter tvpParam = cmd.Parameters.AddWithValue("@HourlyDetails", p.HourlyDetails);
                        tvpParam.SqlDbType = SqlDbType.Structured;
                        tvpParam.TypeName = "dbo.HourlyTargetTableType";

                        cmd.ExecuteNonQuery();
                        savedCount++;
                    }
                }

                Session["PendingTargets"] = null;
                BindPendingGrid();

                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert",
                    "alert('" + savedCount + " Production Target has been saved successfully!');", true);

                btnClear_Click(sender, e);
                LoadExistingEntries();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error: " + ex.Message.Replace("'", "\\'") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open)
                    con.Close();
            }
            string url = ResolveUrl($"~/TrimsAccessories/TrimsProduction/ProductionReport/ProductionTargetReport.aspx?TargetDate={txtTargetDate.Text}");
            string script = $"window.open('{url}', '_blank');";
            ScriptManager.RegisterStartupScript(this, this.GetType(), "OpenRawMaterialReport", script, true);
        }

        // ---------- Helper methods ----------
        private object ParseIntOrNull(string text)
        {
            int val;
            if (string.IsNullOrWhiteSpace(text) || text.Trim() == "0" || !int.TryParse(text.Trim(), out val))
                return DBNull.Value;
            return val;
        }

        private int ParseIntOrZero(string text)
        {
            int val;
            if (string.IsNullOrWhiteSpace(text) || !int.TryParse(text.Trim(), out val))
                return 0;
            return val;
        }

        private decimal ParseDecimalOrZero(string text)
        {
            decimal val;
            if (string.IsNullOrWhiteSpace(text) ||
                !decimal.TryParse(text.Trim(), NumberStyles.Any, CultureInfo.InvariantCulture, out val))
                return 0;
            return val;
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            txtTargetDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            ddlCompany.SelectedIndex = 0;
            //ddlFactory.SelectedIndex = 0;
            ddlFloor.SelectedIndex = 0;
            ddlLine.SelectedIndex = 0;
            ddlItemName.SelectedIndex = 0;
            txtOperator.Text = string.Empty;
            txtHelper.Text = string.Empty;
            txtWorkingHours.Text = "0";
            txtParHRTaget.Text = "0";
            txtSMV.Text = string.Empty;
            txtEfficiency.Text = "0";
            txtTotalHours.Text = "0";
            txtTotalTargetQty.Text = "0";
            txtTargetRemarks.Text = string.Empty;
            pnlCalcResult.Visible = false;

            // Clear করলে এডিট-মোডও বন্ধ হয়ে যাবে
            Session[SESSION_EDITING_ID] = null;
            SetEditModeUI(false, null);

            BindHourlyGrid(GetWorkingHours(), 0);
        }

        protected void ddlCompany_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadBuilding();
        }

        protected void ddlBuilding_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadFloor();
        }

        protected void ddlBuyer_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadWorkOrder();
        }

        protected void ddlWONo_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadItems();
            try
            {
                string sql = @"SELECT SUM(TotalReqQty) AS TotalReqQty 
                                FROM WorkOrder_Size_Details 
                                WHERE ItemID = '" + ddlItemName.SelectedValue + "' AND WorkOrderNo = '" + ddlWONo.SelectedItem.Text + "'";
                con = conn.openConnection();
                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read() && reader["TotalReqQty"] != DBNull.Value)
                        {
                            txtOrderQty.Text = reader["TotalReqQty"].ToString();
                        }
                        else
                        {
                            txtOrderQty.Text = "0";
                        }
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

        protected void ddlItemName_SelectedIndexChanged(object sender, EventArgs e)
        {

            try
            {
                string sql = @"SELECT SUM(TotalReqQty) AS TotalReqQty 
                                FROM WorkOrder_Size_Details 
                                WHERE ItemID = '" + ddlItemName.SelectedValue + "' AND WorkOrderNo = '" + ddlWONo.SelectedItem.Text + "'";
                con = conn.openConnection();
                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read() && reader["TotalReqQty"] != DBNull.Value)
                        {
                            txtOrderQty.Text = reader["TotalReqQty"].ToString();
                        }
                        else
                        {
                            txtOrderQty.Text = "0";
                        }
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

        protected void btnAddItem_Click(object sender, EventArgs e)
        {
            {
                if (string.IsNullOrEmpty(txtTargetDate.Text))
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Please select Target Date.');", true);
                    return;
                }
                if (string.IsNullOrEmpty(ddlItemName.SelectedValue) || ddlItemName.SelectedValue == "0")
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Add করার আগে একটি Item সিলেক্ট করুন।');", true);
                    return;
                }

                RecalculateSummary();

                DataTable dtHourly = new DataTable();
                dtHourly.Columns.Add("HourSlot", typeof(string));
                dtHourly.Columns.Add("TargetQty", typeof(int));
                dtHourly.Columns.Add("Remarks", typeof(string));

                foreach (GridViewRow row in gvHourlyTarget.Rows)
                {
                    if (row.RowType == DataControlRowType.DataRow)
                    {
                        string hourSlot = row.Cells[0].Text;
                        TextBox txtQty = (TextBox)row.FindControl("txtHourlyQty");
                        TextBox txtRem = (TextBox)row.FindControl("txtRemarks");
                        int qty = ParseIntOrZero(txtQty?.Text);
                        dtHourly.Rows.Add(hourSlot, qty, (object)txtRem?.Text ?? DBNull.Value);
                    }
                }

                var pendingItem = new PendingTargetItem
                {
                    ItemName = ddlItemName.SelectedItem.Text,
                    BranchID = ParseNullableInt(ddlCompany.SelectedValue),
                    BuildingID = ParseNullableInt(ddlBuilding.SelectedValue),
                    FloorID = ParseNullableInt(ddlFloor.SelectedValue),
                    LineID = ParseNullableInt(ddlLine.SelectedValue),
                    BuyerID = ParseNullableInt(ddlCustomer.SelectedValue),
                    WorkOrderID = ParseNullableInt(ddlWONo.SelectedValue),
                    ItemID = ParseNullableInt(ddlItemName.SelectedValue),
                    OrderQty = ParseNullableInt(txtOrderQty.Text),
                    ProductionCompleteQty = ParseNullableInt(txtProductionCompleteQty.Text),
                    ProductionDueQty = ParseNullableInt(txtProductionDueQty.Text),
                    Operator = ParseIntOrZero(txtOperator.Text),
                    Helper = ParseIntOrZero(txtHelper.Text),
                    WorkingHours = ParseDecimalOrZero(txtWorkingHours.Text),
                    PerHourTarget = ParseIntOrZero(txtParHRTaget.Text),
                    SMV = ParseDecimalOrZero(txtSMV.Text),
                    Efficiency = ParseDecimalOrZero(txtEfficiency.Text),
                    TotalHours = ParseIntOrZero(txtTotalHours.Text),
                    TotalTargetQty = ParseIntOrZero(txtTotalTargetQty.Text),
                    TargetRemarks = txtTargetRemarks.Text?.Trim(),
                    HourlyDetails = dtHourly
                };

                List<PendingTargetItem> pendingList = Session["PendingTargets"] as List<PendingTargetItem> ?? new List<PendingTargetItem>();
                pendingList.Add(pendingItem);
                Session["PendingTargets"] = pendingList;

                BindPendingGrid();

                // Item-নির্ভর ফিল্ড রিসেট, Date/Company/Building/Floor/Line/Customer/WONo অক্ষত রাখা হচ্ছে
                // (কারণ একই তারিখ+সেকশনে পরের Item Add করার সময় এগুলো আবার লাগবে)
                ddlItemName.SelectedIndex = 0;
                txtOrderQty.Text = string.Empty;
                txtProductionCompleteQty.Text = string.Empty;
                txtProductionDueQty.Text = string.Empty;
                txtOperator.Text = string.Empty;
                txtHelper.Text = string.Empty;
                txtWorkingHours.Text = "0";
                txtParHRTaget.Text = "0";
                txtSMV.Text = string.Empty;
                txtEfficiency.Text = "0";
                txtTargetRemarks.Text = string.Empty;
                pnlCalcResult.Visible = false;
                BindHourlyGrid(GetWorkingHours(), 0);
                RecalculateSummary();

                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Item has been added to the list. Add more items or click Save All.');", true);
            }
        }
        // ---------------------------------------------------------------
        // Session-এর pending list টা Pending Items গ্রিডে বাইন্ড করে
        // ---------------------------------------------------------------
        private void BindPendingGrid()
        {
            List<PendingTargetItem> pendingList = Session["PendingTargets"] as List<PendingTargetItem> ?? new List<PendingTargetItem>();

            DataTable dt = new DataTable();
            dt.Columns.Add("SL", typeof(int));
            dt.Columns.Add("ItemName", typeof(string));
            dt.Columns.Add("Operator", typeof(int));
            dt.Columns.Add("Helper", typeof(int));
            dt.Columns.Add("WorkingHours", typeof(decimal));
            dt.Columns.Add("PerHourTarget", typeof(int));
            dt.Columns.Add("TotalTargetQty", typeof(int));

            for (int i = 0; i < pendingList.Count; i++)
            {
                var p = pendingList[i];
                dt.Rows.Add(i, p.ItemName, p.Operator, p.Helper, p.WorkingHours, p.PerHourTarget, p.TotalTargetQty);
            }

            gvPendingItems.DataSource = dt;
            gvPendingItems.DataBind();

            lblPendingCount.Text = pendingList.Count.ToString();
        }

        // ---------------------------------------------------------------
        // Existing (already-saved) entries grid: handles Edit and Delete
        // ---------------------------------------------------------------
        protected void gvExistingEntries_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int targetID;
            if (!int.TryParse(Convert.ToString(e.CommandArgument), out targetID)) return;

            if (e.CommandName == "EditEntry")
            {
                LoadEntryForEdit(targetID);
            }
            else if (e.CommandName == "DeleteEntry")
            {
                DeleteEntryFromDb(targetID);
                LoadExistingEntries();
            }
        }

        protected void gvPendingItems_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "RemovePending")
            {
                int index = Convert.ToInt32(e.CommandArgument);
                List<PendingTargetItem> pendingList = Session["PendingTargets"] as List<PendingTargetItem> ?? new List<PendingTargetItem>();
                if (index >= 0 && index < pendingList.Count)
                {
                    pendingList.RemoveAt(index);
                    Session["PendingTargets"] = pendingList;
                }
                BindPendingGrid();
            }
        }

        protected void txtTargetDate_TextChanged(object sender, EventArgs e)
        {
            LoadExistingEntries();
        }

        protected void ddlLine_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadExistingEntries();
        }
        private void LoadExistingEntries()
        {
            if (string.IsNullOrEmpty(txtTargetDate.Text)) return;

            if (string.IsNullOrEmpty(ddlLine.SelectedValue) || ddlLine.SelectedValue == "0")
            {
                pnlExistingEntries.Visible = false;
                gvExistingEntries.DataSource = null;
                gvExistingEntries.DataBind();
                return;
            }

            try
            {
                con = conn.openConnection();
                string query = @"SELECT d.TargetID, i.ItemName, d.Operator, d.Helper, d.WorkingHours, 
                                 d.PerHourTarget, d.TotalTargetQty
                          FROM DailyProductionTarget d
                          LEFT JOIN ta_ItemName i ON d.ItemID = i.ItemID
                          WHERE d.TargetDate = @TargetDate AND d.LineID = @LineID
                          ORDER BY d.TargetID";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@TargetDate", Convert.ToDateTime(txtTargetDate.Text));
                    cmd.Parameters.AddWithValue("@LineID", Convert.ToInt32(ddlLine.SelectedValue));
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    gvExistingEntries.DataSource = dt;
                    gvExistingEntries.DataBind();
                    pnlExistingEntries.Visible = dt.Rows.Count > 0;
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error loading existing entries: " + ex.Message.Replace("'", "\\'") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) con.Close();
            }
        }

        // =================================================================
        //  EDIT existing entry
        // =================================================================
        private void LoadEntryForEdit(int targetID)
        {
            try
            {
                con = conn.openConnection();

                // CONFIRM: column names below must match your actual
                // DailyProductionTarget table.
                string query = @"SELECT TargetID, TargetDate, BranchID, BuildingID, FloorID, LineID, BuyerID,
                                         WorkOrderID, ItemID, OrderQty, ProductionCompleteQty, ProductionDueQty,
                                         Operator, Helper, WorkingHours, PerHourTarget, SMV, Efficiency,
                                         TotalHours, TotalTargetQty, TargetRemarks
                                  FROM DailyProductionTarget
                                  WHERE TargetID = @TargetID";

                DataTable dt = new DataTable();
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@TargetID", targetID);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(dt);
                }

                if (dt.Rows.Count == 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Entry not found. It may have already been deleted.');", true);
                    return;
                }

                DataRow r = dt.Rows[0];

                txtTargetDate.Text = Convert.ToDateTime(r["TargetDate"]).ToString("yyyy-MM-dd");

                // Cascading dropdowns: select parent first, reload child list, then select child
                SetDropDownValue(ddlCompany, r["BranchID"]);
                LoadBuilding();
                SetDropDownValue(ddlBuilding, r["BuildingID"]);
                LoadFloor();
                SetDropDownValue(ddlFloor, r["FloorID"]);

                SetDropDownValue(ddlLine, r["LineID"]);

                SetDropDownValue(ddlCustomer, r["BuyerID"]);
                LoadWorkOrder();
                SetDropDownValue(ddlWONo, r["WorkOrderID"]);
                LoadItems();
                SetDropDownValue(ddlItemName, r["ItemID"]);

                txtOrderQty.Text = r["OrderQty"] == DBNull.Value ? "0" : r["OrderQty"].ToString();
                txtProductionCompleteQty.Text = r["ProductionCompleteQty"] == DBNull.Value ? "0" : r["ProductionCompleteQty"].ToString();
                txtProductionDueQty.Text = r["ProductionDueQty"] == DBNull.Value ? "0" : r["ProductionDueQty"].ToString();
                txtOperator.Text = r["Operator"] == DBNull.Value ? "0" : r["Operator"].ToString();
                txtHelper.Text = r["Helper"] == DBNull.Value ? "0" : r["Helper"].ToString();
                txtWorkingHours.Text = r["WorkingHours"] == DBNull.Value ? "0" : r["WorkingHours"].ToString();
                txtParHRTaget.Text = r["PerHourTarget"] == DBNull.Value ? "0" : r["PerHourTarget"].ToString();
                txtSMV.Text = r["SMV"] == DBNull.Value ? "" : r["SMV"].ToString();
                txtEfficiency.Text = r["Efficiency"] == DBNull.Value ? "0" : r["Efficiency"].ToString();
                txtTargetRemarks.Text = r["TargetRemarks"] == DBNull.Value ? "" : r["TargetRemarks"].ToString();

                LoadHourlyDetailsForEdit(targetID);
                RecalculateSummary();

                Session[SESSION_EDITING_ID] = targetID;
                SetEditModeUI(true, targetID);
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error loading entry: " + ex.Message.Replace("'", "\\'") + "');", true);
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

        // CONFIRM: table/column names below must match wherever the hourly
        // rows (the ones that go into the "dbo.HourlyTargetTableType" TVP)
        // actually get stored. If your child table has a different name,
        // change only the query below.
        private void LoadHourlyDetailsForEdit(int targetID)
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("HourSlot", typeof(string));
            dt.Columns.Add("TargetQty", typeof(int));
            dt.Columns.Add("Remarks", typeof(string));

            try
            {
                con = conn.openConnection();
                string query = @"SELECT HourSlot, TargetQty, Remarks
                                  FROM DailyProductionTargetHourly
                                  WHERE TargetID = @TargetID";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@TargetID", targetID);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(dt);
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error loading hourly details: " + ex.Message.Replace("'", "\\'") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) con.Close();
            }

            if (dt.Rows.Count == 0)
            {
                // কোনো hourly row না পেলে Working Hours অনুযায়ী খালি গ্রিড দেখানো হচ্ছে
                BindHourlyGrid(GetWorkingHours(), 0);
                return;
            }

            gvHourlyTarget.DataSource = dt;
            gvHourlyTarget.DataBind();

            // Remarks কলামটা Eval দিয়ে বাইন্ড করা নেই বলে ম্যানুয়ালি বসানো হচ্ছে
            int i = 0;
            foreach (GridViewRow row in gvHourlyTarget.Rows)
            {
                if (row.RowType != DataControlRowType.DataRow) continue;
                TextBox txtRem = row.FindControl("txtRemarks") as TextBox;
                if (txtRem != null && i < dt.Rows.Count)
                    txtRem.Text = dt.Rows[i]["Remarks"] == DBNull.Value ? "" : dt.Rows[i]["Remarks"].ToString();
                i++;
            }
        }

        // Shows/hides the Update/Cancel buttons and the edit banner
        private void SetEditModeUI(bool isEditing, int? targetID)
        {
            btnUpdateTarget.Visible = isEditing;
            btnCancelEdit.Visible = isEditing;
            btnAddItem.Visible = !isEditing;
            btnSaveTarget.Visible = !isEditing;
            pnlEditBanner.Visible = isEditing;

            if (isEditing && targetID.HasValue)
                lblEditBanner.Text = "You are editing Entry #" + targetID.Value + ". Click “Update Entry” to save changes or “Cancel Edit” to cancel.";
        }

        // ---------------------------------------------------------------
        // Saves changes made to an existing entry back to the database.
        // Reuses sp_SaveDailyProductionTarget, passing the real TargetID.
        // CONFIRM: the SP must UPDATE (not insert a duplicate) when a
        // non-null/non-zero @TargetID is supplied.
        // ---------------------------------------------------------------
        protected void btnUpdateTarget_Click(object sender, EventArgs e)
        {
            if (Session[SESSION_EDITING_ID] == null)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('No entry is currently being edited.');", true);
                return;
            }

            int targetID = Convert.ToInt32(Session[SESSION_EDITING_ID]);
            int userId = Session["UserID"] != null ? Convert.ToInt32(Session["UserID"]) : 1;

            RecalculateSummary();

            DataTable dtHourly = new DataTable();
            dtHourly.Columns.Add("HourSlot", typeof(string));
            dtHourly.Columns.Add("TargetQty", typeof(int));
            dtHourly.Columns.Add("Remarks", typeof(string));

            foreach (GridViewRow row in gvHourlyTarget.Rows)
            {
                if (row.RowType != DataControlRowType.DataRow) continue;
                string hourSlot = row.Cells[0].Text;
                TextBox txtQty = row.FindControl("txtHourlyQty") as TextBox;
                TextBox txtRem = row.FindControl("txtRemarks") as TextBox;
                int qty = ParseIntOrZero(txtQty?.Text);
                dtHourly.Rows.Add(hourSlot, qty, (object)txtRem?.Text ?? DBNull.Value);
            }

            try
            {
                con = conn.openConnection();
                using (SqlCommand cmd = new SqlCommand("sp_SaveDailyProductionTarget", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.Add("@TargetID", SqlDbType.Int).Value = targetID;
                    cmd.Parameters[0].Direction = ParameterDirection.InputOutput;

                    cmd.Parameters.Add("@TargetDate", SqlDbType.Date).Value = Convert.ToDateTime(txtTargetDate.Text);
                    cmd.Parameters.Add("@BranchID", SqlDbType.Int).Value = ParseIntOrNull(ddlCompany.SelectedValue);
                    cmd.Parameters.Add("@BuildingID", SqlDbType.Int).Value = ParseIntOrNull(ddlBuilding.SelectedValue);
                    cmd.Parameters.Add("@FloorID", SqlDbType.Int).Value = ParseIntOrNull(ddlFloor.SelectedValue);
                    cmd.Parameters.Add("@LineID", SqlDbType.Int).Value = ParseIntOrNull(ddlLine.SelectedValue);
                    cmd.Parameters.Add("@BuyerID", SqlDbType.Int).Value = ParseIntOrNull(ddlCustomer.SelectedValue);
                    cmd.Parameters.Add("@WorkOrderID", SqlDbType.Int).Value = ParseIntOrNull(ddlWONo.SelectedValue);
                    cmd.Parameters.Add("@ItemID", SqlDbType.Int).Value = ParseIntOrNull(ddlItemName.SelectedValue);
                    cmd.Parameters.Add("@OrderQty", SqlDbType.Int).Value = ParseIntOrNull(txtOrderQty.Text);
                    cmd.Parameters.Add("@ProductionCompleteQty", SqlDbType.Int).Value = ParseIntOrNull(txtProductionCompleteQty.Text);
                    cmd.Parameters.Add("@ProductionDueQty", SqlDbType.Int).Value = ParseIntOrNull(txtProductionDueQty.Text);
                    cmd.Parameters.Add("@Operator", SqlDbType.Int).Value = ParseIntOrZero(txtOperator.Text);
                    cmd.Parameters.Add("@Helper", SqlDbType.Int).Value = ParseIntOrZero(txtHelper.Text);
                    cmd.Parameters.Add("@WorkingHours", SqlDbType.Decimal).Value = ParseDecimalOrZero(txtWorkingHours.Text);
                    cmd.Parameters.Add("@PerHourTarget", SqlDbType.Int).Value = ParseIntOrZero(txtParHRTaget.Text);
                    cmd.Parameters.Add("@SMV", SqlDbType.Decimal).Value = ParseDecimalOrZero(txtSMV.Text);
                    cmd.Parameters.Add("@Efficiency", SqlDbType.Decimal).Value = ParseDecimalOrZero(txtEfficiency.Text);
                    cmd.Parameters.Add("@TotalHours", SqlDbType.Int).Value = ParseIntOrZero(txtTotalHours.Text);
                    cmd.Parameters.Add("@TotalTargetQty", SqlDbType.Int).Value = ParseIntOrZero(txtTotalTargetQty.Text);
                    cmd.Parameters.Add("@TargetRemarks", SqlDbType.VarChar).Value = string.IsNullOrEmpty(txtTargetRemarks.Text) ? (object)DBNull.Value : txtTargetRemarks.Text.Trim();
                    cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = userId;

                    SqlParameter tvpParam = cmd.Parameters.AddWithValue("@HourlyDetails", dtHourly);
                    tvpParam.SqlDbType = SqlDbType.Structured;
                    tvpParam.TypeName = "dbo.HourlyTargetTableType";

                    cmd.ExecuteNonQuery();
                }

                Session[SESSION_EDITING_ID] = null;
                SetEditModeUI(false, null);

                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Entry #" + targetID + " updated successfully!');", true);

                btnClear_Click(sender, e);
                LoadExistingEntries();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error updating entry: " + ex.Message.Replace("'", "\\'") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) con.Close();
            }
        }

        protected void btnCancelEdit_Click(object sender, EventArgs e)
        {
            Session[SESSION_EDITING_ID] = null;
            SetEditModeUI(false, null);
            btnClear_Click(sender, e);
        }

        // =================================================================
        //  DELETE existing entry
        // =================================================================
        // CONFIRM: table name "DailyProductionTargetHourlyDetails" must
        // match your actual child (hourly) table.
        private void DeleteEntryFromDb(int targetID)
        {
            SqlTransaction trans = null;
            try
            {
                con = conn.openConnection();
                trans = con.BeginTransaction();

                using (SqlCommand cmdChild = new SqlCommand(
                    "DELETE FROM DailyProductionTargetHourly WHERE TargetID=@TargetID", con, trans))
                {
                    cmdChild.Parameters.AddWithValue("@TargetID", targetID);
                    cmdChild.ExecuteNonQuery();
                }

                using (SqlCommand cmdParent = new SqlCommand(
                    "DELETE FROM DailyProductionTarget WHERE TargetID=@TargetID", con, trans))
                {
                    cmdParent.Parameters.AddWithValue("@TargetID", targetID);
                    cmdParent.ExecuteNonQuery();
                }

                trans.Commit();

                // যদি এই entry-ই এডিট করার মাঝে ছিল, তাহলে ফর্ম রিসেট করে দেওয়া হচ্ছে
                if (Session[SESSION_EDITING_ID] != null && Convert.ToInt32(Session[SESSION_EDITING_ID]) == targetID)
                {
                    Session[SESSION_EDITING_ID] = null;
                    SetEditModeUI(false, null);
                    btnClear_Click(this, EventArgs.Empty);
                }

                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Entry deleted successfully.');", true);
            }
            catch (Exception ex)
            {
                if (trans != null)
                {
                    try { trans.Rollback(); } catch { /* ignore rollback failure */ }
                }
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error deleting entry: " + ex.Message.Replace("'", "\\'") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) con.Close();
            }
        }

        // ---------------------------------------------------------------
        // Parse Helpers
        // ---------------------------------------------------------------
        private int? ParseNullableInt(string text)
        {
            int val;
            if (string.IsNullOrWhiteSpace(text) || text.Trim() == "0" || !int.TryParse(text.Trim(), out val))
                return null;
            return val;
        }

        protected void btnView_Click(object sender, EventArgs e)
        {
            string url = ResolveUrl($"~/TrimsAccessories/TrimsProduction/ProductionReport/ProductionTargetReport.aspx?TargetDate={txtTargetDate.Text}");
            string script = $"window.open('{url}', '_blank');";
            ScriptManager.RegisterStartupScript(this, this.GetType(), "OpenRawMaterialReport", script, true);
        }
    }
}
