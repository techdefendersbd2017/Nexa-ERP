using Nexa_ERP.Connection;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.TrimsAccessories.TrimsProduction
{
    public partial class DailyProductionTarget : Page
    {
        // Safe upper bound so a bad value in Working Hours can't create thousands of rows
        private const int MAX_WORKING_HOURS = 24;

        SqlConnection con;
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtTargetDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                LoadInitialDropdowns();
                BindHourlyGrid(GetWorkingHours(), 0);
                RecalculateSummary();
                LoadItemsName();
                LoadCompany();
                LoadItemCategory();
                LoadBuyer();
            }
        }
        private void LoadStyle()
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT * FROM Style_Master WHERE IsActive=1 and BuyerName='"+ddlBuyer.SelectedValue+"' ORDER BY StyleName ASC";
                SqlDataAdapter da = new SqlDataAdapter(query, con);
                DataTable dt = new DataTable();
                da.Fill(dt);
                ddlStyle.DataSource = dt;
                ddlStyle.DataTextField = "StyleName";
                ddlStyle.DataValueField = "StyleId";
                ddlStyle.DataBind();
                ddlStyle.Items.Insert(0, new ListItem("--Select Style--", "0"));
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
        private void LoadBuyer()
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT * FROM vw_BuyerInformation WHERE IsActive=1 ORDER BY BuyerName ASC";
                SqlDataAdapter da = new SqlDataAdapter(query, con);
                DataTable dt = new DataTable();
                da.Fill(dt);

                ddlBuyer.DataSource = dt;
                ddlBuyer.DataTextField = "BuyerName";
                ddlBuyer.DataValueField = "BuyerID";
                ddlBuyer.DataBind();
                ddlBuyer.Items.Insert(0, new ListItem("--Select Category--", "0"));
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
        private void LoadBuilding()
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT * FROM vw_BuildingInformation where Branch_ID='"+ddlCompany.SelectedValue+"' ORDER BY Building_Name";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlBuilding.DataSource = dt;
                    ddlBuilding.DataTextField = "Building_Name";
                    ddlBuilding.DataValueField = "Building_ID";
                    ddlBuilding.DataBind();

                    ddlBuilding.Items.Insert(0, new ListItem("--Select Floor--", "0"));
                }
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error: " + ex.Message.Replace("'", "\\'") + "');", true);
            }
        }
        private void LoadFloor()
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT Floor_ID, Floor_Name FROM vw_Floor_Information where Building_ID='"+ ddlBuilding.SelectedValue+ "' ORDER BY Floor_Name";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlFloor.DataSource = dt;
                    ddlFloor.DataTextField = "Floor_Name";
                    ddlFloor.DataValueField = "Floor_ID";
                    ddlFloor.DataBind();

                    ddlFloor.Items.Insert(0, new ListItem("--Select Floor--", "0"));
                }
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error: " + ex.Message.Replace("'", "\\'") + "');", true);
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
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error: " + ex.Message.Replace("'", "\\'") + "');", true);
            }
        }
        private void LoadItemsName()
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT * FROM ta_ItemName ORDER BY ItemName";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlItemName.DataSource = dt;
                    ddlItemName.DataTextField = "ItemName";
                    ddlItemName.DataValueField = "ItemID";
                    ddlItemName.DataBind();

                    ddlItemName.Items.Insert(0, new ListItem("--Select Item --", "0"));
                }
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error: " + ex.Message.Replace("'", "\\'") + "');", true);
            }
        }

        private void LoadInitialDropdowns()
        {
            // আপনার প্রজেক্টের নিয়ম অনুযায়ী Company, Factory, Floor, Line, Buyer, Style
            // ড্রপডাউন লোড করার কোড এখানে লিখবেন
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
                    lblCalcResult.Text = "Calculate করার আগে Operator/Helper (Total Manpower) এবং Style SMV অবশ্যই দিতে হবে।";
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
            if (string.IsNullOrEmpty(txtTargetDate.Text))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Please select Target Date.');", true);
                return;
            }

            // Make sure the summary reflects whatever the user last typed
            // into the hourly grid before persisting.
            RecalculateSummary();

            try
            {
                con = conn.openConnection();
                using (SqlCommand cmd = new SqlCommand("sp_SaveDailyProductionTarget", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    int targetID = 0; // আপডেট মোড হলে এখানে HiddenField বা ViewState থেকে আইডি নিতে হবে

                    cmd.Parameters.Add("@TargetID", SqlDbType.Int).Value = targetID == 0 ? (object)DBNull.Value : targetID;
                    cmd.Parameters[0].Direction = ParameterDirection.InputOutput;

                    cmd.Parameters.Add("@TargetDate", SqlDbType.Date).Value = Convert.ToDateTime(txtTargetDate.Text);
                    cmd.Parameters.Add("@CompanyID", SqlDbType.Int).Value = string.IsNullOrEmpty(ddlCompany.SelectedValue) ? (object)DBNull.Value : Convert.ToInt32(ddlCompany.SelectedValue);
                    //cmd.Parameters.Add("@FactoryID", SqlDbType.Int).Value = string.IsNullOrEmpty(ddlFactory.SelectedValue) ? (object)DBNull.Value : Convert.ToInt32(ddlFactory.SelectedValue);
                    cmd.Parameters.Add("@FloorID", SqlDbType.Int).Value = string.IsNullOrEmpty(ddlFloor.SelectedValue) ? (object)DBNull.Value : Convert.ToInt32(ddlFloor.SelectedValue);
                    cmd.Parameters.Add("@LineID", SqlDbType.Int).Value = string.IsNullOrEmpty(ddlLine.SelectedValue) ? (object)DBNull.Value : Convert.ToInt32(ddlLine.SelectedValue);
                    cmd.Parameters.Add("@BuyerID", SqlDbType.Int).Value = string.IsNullOrEmpty(ddlBuyer.SelectedValue) ? (object)DBNull.Value : Convert.ToInt32(ddlBuyer.SelectedValue);
                    cmd.Parameters.Add("@StyleID", SqlDbType.Int).Value = string.IsNullOrEmpty(ddlStyle.SelectedValue) ? (object)DBNull.Value : Convert.ToInt32(ddlStyle.SelectedValue);
                    cmd.Parameters.Add("@ItemName", SqlDbType.VarChar, 250).Value = string.IsNullOrEmpty(ddlItemName.SelectedItem.Text) ? (object)DBNull.Value : ddlItemName.SelectedItem.Text.Trim();
                    cmd.Parameters.Add("@Operator", SqlDbType.Int).Value = string.IsNullOrEmpty(txtOperator.Text) ? 0 : Convert.ToInt32(txtOperator.Text);
                    cmd.Parameters.Add("@Helper", SqlDbType.Int).Value = string.IsNullOrEmpty(txtHelper.Text) ? 0 : Convert.ToInt32(txtHelper.Text);
                    cmd.Parameters.Add("@WorkingHours", SqlDbType.Decimal).Value = string.IsNullOrEmpty(txtWorkingHours.Text) ? 0 : Convert.ToDecimal(txtWorkingHours.Text);
                    cmd.Parameters.Add("@PerHourTarget", SqlDbType.Int).Value = string.IsNullOrEmpty(txtParHRTaget.Text) ? 0 : Convert.ToInt32(txtParHRTaget.Text);
                    cmd.Parameters.Add("@SMV", SqlDbType.Decimal).Value = string.IsNullOrEmpty(txtSMV.Text) ? 0 : Convert.ToDecimal(txtSMV.Text);
                    cmd.Parameters.Add("@Efficiency", SqlDbType.Decimal).Value = string.IsNullOrEmpty(txtEfficiency.Text) ? 0 : Convert.ToDecimal(txtEfficiency.Text);
                    cmd.Parameters.Add("@TotalHours", SqlDbType.Int).Value = string.IsNullOrEmpty(txtTotalHours.Text) ? 0 : Convert.ToInt32(txtTotalHours.Text);
                    cmd.Parameters.Add("@TotalTargetQty", SqlDbType.Int).Value = string.IsNullOrEmpty(txtTotalTargetQty.Text) ? 0 : Convert.ToInt32(txtTotalTargetQty.Text);
                    cmd.Parameters.Add("@TargetRemarks", SqlDbType.VarChar).Value = string.IsNullOrEmpty(txtTargetRemarks.Text) ? (object)DBNull.Value : txtTargetRemarks.Text.Trim();

                    // সেশন থেকে ইউজার আইডি নেওয়া (যদি সেশন থাকে)
                    int userId = Session["UserID"] != null ? Convert.ToInt32(Session["UserID"]) : 1;
                    cmd.Parameters.Add("@UserID", SqlDbType.Int).Value = userId;

                    // গ্রিডভিউ থেকে আওয়ারলি ডেটা DataTable এ রূপান্তর
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

                            int qty = 0;
                            int.TryParse(txtQty?.Text, out qty);

                            dtHourly.Rows.Add(hourSlot, qty, txtRem?.Text);
                        }
                    }

                    SqlParameter tvpParam = cmd.Parameters.AddWithValue("@HourlyDetails", dtHourly);
                    tvpParam.SqlDbType = SqlDbType.Structured;
                    tvpParam.TypeName = "dbo.HourlyTargetTableType";

                    cmd.ExecuteNonQuery();

                    if (targetID == 0)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Production Target Saved Successfully!');", true);
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Production Target Updated Successfully!');", true);
                    }

                    btnClear_Click(sender, e);
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error: " + ex.Message.Replace("'", "\\'") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open)
                {
                    con.Close();
                }
            }
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            txtTargetDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            ddlCompany.SelectedIndex = 0;
            //ddlFactory.SelectedIndex = 0;
            ddlFloor.SelectedIndex = 0;
            ddlLine.SelectedIndex = 0;
            ddlBuyer.SelectedIndex = 0;
            ddlStyle.SelectedIndex = 0;
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
            LoadStyle();
        }
    }
}
