using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.TrimsAccessories.EstimationCostings
{
    public partial class WorkOrderReceive : System.Web.UI.Page
    {
        SqlConnection con;
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();
        SqlCommand cmd;

        #region ---------- In-memory model classes ----------

        [Serializable]
        public class ColorItem
        {
            public int ColorSlNo { get; set; }
            public string ColorName { get; set; }
            public string ColorRemarks { get; set; }
            public decimal TotalReqQty { get; set; }
            public decimal ColorTotalAmount { get; set; }
            public List<SizeDetail> SizeDetails { get; set; } = new List<SizeDetail>();
        }

        [Serializable]
        public class SizeDetail
        {
            public int SlNo { get; set; }
            public string Size { get; set; }
            public string Measurement { get; set; }
            public decimal ReqQty { get; set; }
            public string Unit { get; set; }
            public decimal RateUnit { get; set; }
            public decimal ExtraPercent { get; set; }
            public decimal TotalReqQty { get; set; }
            public decimal TotalAmount { get; set; }
            public string Remarks { get; set; }
        }

        #endregion

        #region ---------- Session-backed state helpers ----------

        private List<ColorItem> ColorList
        {
            get
            {
                if (Session["WO_ColorList"] == null)
                    Session["WO_ColorList"] = new List<ColorItem>();
                return (List<ColorItem>)Session["WO_ColorList"];
            }
            set { Session["WO_ColorList"] = value; }
        }

        private int SelectedColorSlNo
        {
            get
            {
                int.TryParse(hdnSelectedColorSlNo.Value, out int slNo);
                return slNo;
            }
            set { hdnSelectedColorSlNo.Value = value.ToString(); }
        }

        private ColorItem GetSelectedColor()
        {
            return ColorList.FirstOrDefault(c => c.ColorSlNo == SelectedColorSlNo);
        }

        #endregion

        #region ---------- Page Lifecycle ----------

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadColorNameDropdown();
                LoadPartyName();

                Session["WO_ColorList"] = new List<ColorItem>();
                hdnSelectedColorSlNo.Value = "0";
                hdnWorkOrderNo.Value = string.Empty;

                txtWoDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                txtWoRef.Text = GenerateNextWorkOrderRef();

                BindWorkOrderList();
                BindColorList();
                BindSizeDetails();
                LoadItemsName();
            }
        }
        private string GenerateNextWorkOrderRef()
        {
            string prefix = "WO-" + DateTime.Today.Year + "-";
            int nextNumber = 1;
            try
            {
                con = conn.openConnection();
                string query = @"SELECT MAX(CAST(RIGHT(WorkOrderNo, 4) AS INT)) 
                                  FROM WorkOrder_Master 
                                  WHERE WorkOrderNo LIKE @Prefix + '%'";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@Prefix", prefix);
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                        nextNumber = Convert.ToInt32(result) + 1;
                }
                con.Close();
            }
            catch
            {
                nextNumber = 1;
            }
            return prefix + nextNumber.ToString("D4");
        }

        private void LoadItemsName()
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT CategoryID, CategoryName FROM ta_ItemCategory ORDER BY CategoryName";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlItemNameDetails.DataSource = dt;
                    ddlItemNameDetails.DataTextField = "CategoryName";
                    ddlItemNameDetails.DataValueField = "CategoryID";
                    ddlItemNameDetails.DataBind();

                    ddlItemNameDetails.Items.Insert(0, new ListItem("--Select Items Name--", "0"));
                }
                con.Close();
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, "warning");
            }
        }

        private void LoadPartyName()
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

                    ddlCustomerName.DataSource = dt;
                    ddlCustomerName.DataTextField = "PartyName";
                    ddlCustomerName.DataValueField = "PartyID";
                    ddlCustomerName.DataBind();

                    ddlCustomerName.Items.Insert(0, new ListItem("--Select Party Name--", "0"));
                }
                con.Close();
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, "warning");
            }
        }

        private void LoadColorNameDropdown()
        {
            Database_Connection maincon = new Database_Connection();
            try
            {
                con = maincon.openConnection();
                string query = "SELECT ColorID, ColorName FROM ColorInformation ORDER BY ColorName";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlColorName.DataSource = dt;
                    ddlColorName.DataTextField = "ColorName";
                    ddlColorName.DataValueField = "ColorID";
                    ddlColorName.DataBind();

                    ddlColorName.Items.Insert(0, new ListItem("--Select Color Name--", "0"));
                }
                con.Close();
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, "warning");
            }
        }
        private void BindWorkOrderList()
        {
            try
            {
                con = conn.openConnection();
                string query = @"SELECT TOP 50 
                                      WorkOrderID   AS WORcvID,
                                      WorkOrderNo   AS WORcvNo,
                                      WoDate        AS WORcvDate,
                                      DeliveryDate,
                                      GrandTotalAmount AS GrandTotal
                                  FROM WorkOrder_Master 
                                  ORDER BY WorkOrderID DESC";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    gvWorkOrderReceive.DataSource = dt;
                    gvWorkOrderReceive.DataBind();
                }
                con.Close();
            }
            catch (Exception ex)
            {
                gvWorkOrderReceive.DataSource = null;
                gvWorkOrderReceive.DataBind();
                ShowMessage("List Load Error: " + ex.Message, "warning");
            }
        }

        #endregion

        #region ---------- List Panel Row Commands (Edit, Delete, Report) ----------

        protected void gvWorkOrderReceive_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            string arg = e.CommandArgument.ToString();

            if (e.CommandName == "EditRow")
            {
                LoadWorkOrderForEdit(arg);
                ShowFormPanel();
            }
            else if (e.CommandName == "DeleteRow")
            {
                try
                {
                    con = conn.openConnection();
                    using (SqlCommand cmd = new SqlCommand("DELETE FROM WorkOrder_Master WHERE WorkOrderNo = @WorkOrderNo", con))
                    {
                        cmd.Parameters.AddWithValue("@WorkOrderNo", arg);
                        cmd.ExecuteNonQuery();
                    }
                    con.Close();
                    ShowMessage("Work Order Deleted Successfully!", "success");
                    BindWorkOrderList();
                }
                catch (Exception ex)
                {
                    ShowMessage("Delete Error: " + ex.Message, "warning");
                }
            }
            else if (e.CommandName == "ReportView" || e.CommandName == "RawMaterialReport")
            {
                Response.Redirect($"~/TrimsAccessories/EstimationCostings/OrdersReports/ReceivedOrdersReports.aspx?WORcvID={arg}");
            }
        }
        private void LoadWorkOrderForEdit(string workOrderNo)
        {
            try
            {
                con = conn.openConnection();
                string headerQuery = "SELECT * FROM WorkOrder_Master WHERE WorkOrderNo = @WorkOrderNo";
                using (SqlCommand cmd = new SqlCommand(headerQuery, con))
                {
                    cmd.Parameters.AddWithValue("@WorkOrderNo", workOrderNo);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            hdnWorkOrderNo.Value = reader["WorkOrderNo"].ToString();
                            txtWoRef.Text = reader["WorkOrderNo"].ToString();
                            txtWoNoDetails.Text = reader["WoRefNoDetails"]?.ToString();

                            if (reader["WoDate"] != DBNull.Value)
                                txtWoDate.Text = Convert.ToDateTime(reader["WoDate"]).ToString("yyyy-MM-dd");

                            if (reader["DeliveryDate"] != DBNull.Value)
                                txtDeliveryDate.Text = Convert.ToDateTime(reader["DeliveryDate"]).ToString("yyyy-MM-dd");

                            txtBuyer.Text = reader["Buyer"]?.ToString();
                            txtStyle.Text = reader["Style"]?.ToString();
                            txtOrderNo.Text = reader["OrderNo"]?.ToString();

                            string customerID = reader["CustomerName"]?.ToString();
                            if (ddlCustomerName.Items.FindByValue(customerID) != null)
                                ddlCustomerName.SelectedValue = customerID;

                            string itemName = reader["ItemName"]?.ToString();
                            if (ddlItemNameDetails.Items.FindByValue(itemName) != null)
                                ddlItemNameDetails.SelectedValue = itemName;

                            txtTransportCost.Text = Convert.ToDecimal(reader["TransportCost"]).ToString("0.00");
                            txtVatPercent.Text = Convert.ToDecimal(reader["VatPercent"]).ToString("0.00");
                            txtSubTotalAmount.Text = Convert.ToDecimal(reader["SubTotalAmount"]).ToString("0.00");
                            txtGrandTotalAmount.Text = Convert.ToDecimal(reader["GrandTotalAmount"]).ToString("0.00");
                        }
                    }
                }

                // ২. কালার ডিটেইলস লোড করা
                var newColorList = new List<ColorItem>();
                string colorQuery = @"SELECT ColorSlNo, ColorName, ColorRemarks, TotalReqQty, ColorTotalAmount 
                                       FROM WorkOrder_Color_Details 
                                       WHERE WorkOrderNo = @WorkOrderNo 
                                       ORDER BY ColorSlNo";
                using (SqlCommand cmd = new SqlCommand(colorQuery, con))
                {
                    cmd.Parameters.AddWithValue("@WorkOrderNo", workOrderNo);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            newColorList.Add(new ColorItem
                            {
                                ColorSlNo = Convert.ToInt32(reader["ColorSlNo"]),
                                ColorName = reader["ColorName"]?.ToString(),
                                ColorRemarks = reader["ColorRemarks"]?.ToString(),
                                TotalReqQty = Convert.ToDecimal(reader["TotalReqQty"]),
                                ColorTotalAmount = Convert.ToDecimal(reader["ColorTotalAmount"]),
                                SizeDetails = new List<SizeDetail>()
                            });
                        }
                    }
                }

                // ৩. প্রতিটা কালারের Size ডিটেইলস লোড করা
                string sizeQuery = @"SELECT SlNo, ColorSlNo, Size, Measurement, ReqQty, Unit, RateUnit, 
                                             ExtraPercent, TotalReqQty, TotalAmount, Remarks 
                                      FROM WorkOrder_Size_Details 
                                      WHERE WorkOrderNo = @WorkOrderNo 
                                      ORDER BY ColorSlNo, SlNo";
                using (SqlCommand cmd = new SqlCommand(sizeQuery, con))
                {
                    cmd.Parameters.AddWithValue("@WorkOrderNo", workOrderNo);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            int colorSlNo = Convert.ToInt32(reader["ColorSlNo"]);
                            var color = newColorList.FirstOrDefault(c => c.ColorSlNo == colorSlNo);
                            if (color == null) continue;

                            color.SizeDetails.Add(new SizeDetail
                            {
                                SlNo = Convert.ToInt32(reader["SlNo"]),
                                Size = reader["Size"]?.ToString(),
                                Measurement = reader["Measurement"]?.ToString(),
                                ReqQty = Convert.ToDecimal(reader["ReqQty"]),
                                Unit = reader["Unit"]?.ToString(),
                                RateUnit = Convert.ToDecimal(reader["RateUnit"]),
                                ExtraPercent = Convert.ToDecimal(reader["ExtraPercent"]),
                                TotalReqQty = Convert.ToDecimal(reader["TotalReqQty"]),
                                TotalAmount = Convert.ToDecimal(reader["TotalAmount"]),
                                Remarks = reader["Remarks"]?.ToString()
                            });
                        }
                    }
                }

                con.Close();

                // সেশনে বসানো
                ColorList = newColorList;
                SelectedColorSlNo = 0;
                lblSelectedColorName.Text = "-- No color selected --";

                BindColorList();
                BindSizeDetails();
                RecalculateGrandTotal();
            }
            catch (Exception ex)
            {
                ShowMessage("Edit Load Error: " + ex.Message, "warning");
            }
        }

        #endregion

        #region ---------- Color List (Master) ----------

        protected void btnAddColor_Click(object sender, EventArgs e)
        {
            if (ddlColorName.SelectedValue == "0")
            {
                ShowMessage("Please select a Color Name before adding.", "warning");
                ShowFormPanel();
                return;
            }

            var list = ColorList;
            int nextSlNo = list.Any() ? list.Max(c => c.ColorSlNo) + 1 : 1;

            list.Add(new ColorItem
            {
                ColorSlNo = nextSlNo,
                ColorName = ddlColorName.SelectedItem.Text,
                ColorRemarks = txtColorRemarks.Text.Trim(),
                TotalReqQty = 0,
                ColorTotalAmount = 0,
                SizeDetails = new List<SizeDetail>()
            });

            ColorList = list;
            ddlColorName.SelectedIndex = 0;
            txtColorRemarks.Text = string.Empty;

            BindColorList();
            ShowFormPanel();
        }

        protected void gvColorList_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (!int.TryParse(e.CommandArgument?.ToString(), out int colorSlNo))
            {
                ShowFormPanel();
                return;
            }

            var color = ColorList.FirstOrDefault(c => c.ColorSlNo == colorSlNo);
            if (color == null)
            {
                ShowFormPanel();
                return;
            }

            switch (e.CommandName)
            {
                case "SelectColor":
                    SelectedColorSlNo = colorSlNo;
                    lblSelectedColorName.Text = color.ColorName;
                    ClearSizeInputRow();
                    BindColorList();
                    BindSizeDetails();
                    break;

                case "EditColor":
                    ddlColorName.ClearSelection();
                    var item = ddlColorName.Items.FindByText(color.ColorName);
                    if (item != null) item.Selected = true;
                    txtColorRemarks.Text = color.ColorRemarks;

                    ColorList.Remove(color);

                    if (SelectedColorSlNo == colorSlNo)
                    {
                        SelectedColorSlNo = 0;
                        lblSelectedColorName.Text = "-- No color selected --";
                        BindSizeDetails();
                    }

                    BindColorList();
                    break;

                case "DeleteColor":
                    ColorList.Remove(color);

                    if (SelectedColorSlNo == colorSlNo)
                    {
                        SelectedColorSlNo = 0;
                        lblSelectedColorName.Text = "-- No color selected --";
                        BindSizeDetails();
                    }

                    BindColorList();
                    RecalculateGrandTotal();
                    break;
            }
            ShowFormPanel();
        }

        protected void gvColorList_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType != DataControlRowType.DataRow) return;

            var color = (ColorItem)e.Row.DataItem;
            if (color.ColorSlNo == SelectedColorSlNo)
            {
                e.Row.CssClass += " active-color-row";
            }
        }

        private void BindColorList()
        {
            gvColorList.DataSource = ColorList;
            gvColorList.DataBind();
        }

        #endregion

        #region ---------- Size-wise Variant Details ----------

        protected void btnAddSize_Click(object sender, EventArgs e)
        {
            var color = GetSelectedColor();
            if (color == null)
            {
                ShowMessage("Please select a Color from the Color List first.", "warning");
                ShowFormPanel();
                return;
            }

            if (string.IsNullOrWhiteSpace(txtSize.Text))
            {
                ShowMessage("Size is required.", "warning");
                ShowFormPanel();
                return;
            }

            decimal.TryParse(txtReqQty.Text, out decimal reqQty);
            decimal.TryParse(txtRateUnit.Text, out decimal rateUnit);
            decimal.TryParse(txtExtraPercent.Text, out decimal extraPercent);

            decimal totalReqQty = reqQty + (reqQty * (extraPercent / 100m));
            decimal totalAmount = reqQty * rateUnit;

            int nextSlNo = color.SizeDetails.Any() ? color.SizeDetails.Max(s => s.SlNo) + 1 : 1;

            color.SizeDetails.Add(new SizeDetail
            {
                SlNo = nextSlNo,
                Size = txtSize.Text.Trim(),
                Measurement = txtMeasurement.Text.Trim(),
                ReqQty = reqQty,
                Unit = ddlUnit.SelectedValue,
                RateUnit = rateUnit,
                ExtraPercent = extraPercent,
                TotalReqQty = totalReqQty,
                TotalAmount = totalAmount,
                Remarks = txtSizeRemarks.Text.Trim()
            });

            RecalculateColorTotals(color);
            ClearSizeInputRow();

            BindSizeDetails();
            BindColorList();
            RecalculateGrandTotal();
            ShowFormPanel();
        }

        protected void gvSizeDetails_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            var color = GetSelectedColor();
            if (color == null)
            {
                ShowFormPanel();
                return;
            }

            if (!int.TryParse(e.CommandArgument?.ToString(), out int slNo))
            {
                ShowFormPanel();
                return;
            }

            var size = color.SizeDetails.FirstOrDefault(s => s.SlNo == slNo);
            if (size == null)
            {
                ShowFormPanel();
                return;
            }

            switch (e.CommandName)
            {
                case "EditSize":
                    txtSize.Text = size.Size;
                    txtMeasurement.Text = size.Measurement;
                    txtReqQty.Text = size.ReqQty.ToString("0.##");
                    ddlUnit.SelectedValue = size.Unit;
                    txtRateUnit.Text = size.RateUnit.ToString("0.##");
                    txtExtraPercent.Text = size.ExtraPercent.ToString("0.##");
                    txtTotalReqQtyInput.Text = size.TotalReqQty.ToString("0.00");
                    txtTotalAmountInput.Text = size.TotalAmount.ToString("0.00");
                    txtSizeRemarks.Text = size.Remarks;

                    color.SizeDetails.Remove(size);
                    RecalculateColorTotals(color);

                    BindSizeDetails();
                    BindColorList();
                    RecalculateGrandTotal();
                    break;

                case "DeleteSize":
                    color.SizeDetails.Remove(size);
                    RecalculateColorTotals(color);

                    BindSizeDetails();
                    BindColorList();
                    RecalculateGrandTotal();
                    break;
            }

            ShowFormPanel();
        }

        private void BindSizeDetails()
        {
            var color = GetSelectedColor();
            gvSizeDetails.DataSource = color?.SizeDetails ?? new List<SizeDetail>();
            gvSizeDetails.DataBind();
            txtColorTotalAmount.Text = (color?.ColorTotalAmount ?? 0).ToString("0.00");
            lblSelectedColorName.Text = color != null ? color.ColorName : "-- No color selected --";
        }

        private void ClearSizeInputRow()
        {
            txtSize.Text = string.Empty;
            txtMeasurement.Text = string.Empty;
            txtReqQty.Text = "0";
            ddlUnit.SelectedIndex = 0;
            txtRateUnit.Text = "0";
            txtExtraPercent.Text = "0";
            txtTotalReqQtyInput.Text = "0.00";
            txtTotalAmountInput.Text = "0.00";
            txtSizeRemarks.Text = string.Empty;
        }

        private void RecalculateColorTotals(ColorItem color)
        {
            color.TotalReqQty = color.SizeDetails.Sum(s => s.TotalReqQty);
            color.ColorTotalAmount = color.SizeDetails.Sum(s => s.TotalAmount);
        }

        #endregion

        #region ---------- Grand Total Summary ----------

        private void RecalculateGrandTotal()
        {
            decimal subTotal = ColorList.Sum(c => c.ColorTotalAmount);
            decimal.TryParse(txtTransportCost.Text, out decimal transportCost);
            decimal.TryParse(txtVatPercent.Text, out decimal vatPercent);
            decimal vatAmount = subTotal * (vatPercent / 100m);
            decimal grandTotal = subTotal + transportCost + vatAmount;
            txtSubTotalAmount.Text = subTotal.ToString("0.00");
            txtGrandTotalAmount.Text = grandTotal.ToString("0.00");
        }

        #endregion

        #region ---------- Bottom Action Buttons ----------

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!ColorList.Any())
            {
                ShowMessage("Please add at least one Color with Size details before saving.", "warning");
                ShowFormPanel();
                return;
            }

            if (string.IsNullOrWhiteSpace(txtWoRef.Text)) txtWoRef.Text = GenerateNextWorkOrderRef();
            RecalculateGrandTotal();
            DataTable dtColors = new DataTable();
            dtColors.Columns.Add("ColorSlNo", typeof(int));
            dtColors.Columns.Add("ColorName", typeof(string));
            dtColors.Columns.Add("ColorRemarks", typeof(string));
            dtColors.Columns.Add("TotalReqQty", typeof(decimal));
            dtColors.Columns.Add("ColorTotalAmount", typeof(decimal));
            DataTable dtSizes = new DataTable();
            dtSizes.Columns.Add("SlNo", typeof(int));
            dtSizes.Columns.Add("ColorSlNo", typeof(int));
            dtSizes.Columns.Add("Size", typeof(string));
            dtSizes.Columns.Add("Measurement", typeof(string));
            dtSizes.Columns.Add("ReqQty", typeof(decimal));
            dtSizes.Columns.Add("Unit", typeof(string));
            dtSizes.Columns.Add("RateUnit", typeof(decimal));
            dtSizes.Columns.Add("ExtraPercent", typeof(decimal));
            dtSizes.Columns.Add("TotalReqQty", typeof(decimal));
            dtSizes.Columns.Add("TotalAmount", typeof(decimal));
            dtSizes.Columns.Add("Remarks", typeof(string));

            foreach (var col in ColorList)
            {
                dtColors.Rows.Add(col.ColorSlNo, col.ColorName, col.ColorRemarks, col.TotalReqQty, col.ColorTotalAmount);
                foreach (var sz in col.SizeDetails)
                {
                    dtSizes.Rows.Add(sz.SlNo, col.ColorSlNo, sz.Size, sz.Measurement, sz.ReqQty, sz.Unit, sz.RateUnit, sz.ExtraPercent, sz.TotalReqQty, sz.TotalAmount, sz.Remarks);
                }
            }

            try
            {
                con = conn.openConnection();
                using (SqlCommand cmd = new SqlCommand("sp_WorkOrder_InsertUpdate", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@WorkOrderNo", txtWoRef.Text.Trim());
                    cmd.Parameters.AddWithValue("@WoRefNoDetails", string.IsNullOrEmpty(txtWoNoDetails.Text) ? (object)DBNull.Value : txtWoNoDetails.Text.Trim());
                    cmd.Parameters.AddWithValue("@CustomerName", ddlCustomerName.SelectedValue);
                    cmd.Parameters.AddWithValue("@WoDate", Convert.ToDateTime(txtWoDate.Text));
                    cmd.Parameters.AddWithValue("@DeliveryDate", string.IsNullOrEmpty(txtDeliveryDate.Text) ? (object)DBNull.Value : Convert.ToDateTime(txtDeliveryDate.Text));
                    cmd.Parameters.AddWithValue("@Buyer", txtBuyer.Text.Trim());
                    cmd.Parameters.AddWithValue("@Style", txtStyle.Text.Trim());
                    cmd.Parameters.AddWithValue("@OrderNo", txtOrderNo.Text.Trim());
                    cmd.Parameters.AddWithValue("@ItemName", ddlItemNameDetails.SelectedValue);
                    cmd.Parameters.AddWithValue("@SubTotalAmount", Convert.ToDecimal(txtSubTotalAmount.Text));
                    cmd.Parameters.AddWithValue("@TransportCost", Convert.ToDecimal(string.IsNullOrEmpty(txtTransportCost.Text) ? "0" : txtTransportCost.Text));
                    cmd.Parameters.AddWithValue("@VatPercent", Convert.ToDecimal(string.IsNullOrEmpty(txtVatPercent.Text) ? "0" : txtVatPercent.Text));
                    cmd.Parameters.AddWithValue("@GrandTotalAmount", Convert.ToDecimal(txtGrandTotalAmount.Text));
                    cmd.Parameters.AddWithValue("@CreatedBy", "Admin");
                    SqlParameter colorParam = cmd.Parameters.AddWithValue("@ColorList", dtColors);
                    colorParam.SqlDbType = SqlDbType.Structured;
                    colorParam.TypeName = "ColorTableType";
                    SqlParameter sizeParam = cmd.Parameters.AddWithValue("@SizeList", dtSizes);
                    sizeParam.SqlDbType = SqlDbType.Structured;
                    sizeParam.TypeName = "SizeTableType";
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            string status = reader["StatusMessage"].ToString();
                            if (status == "Success")
                            {
                                ShowMessage("Work Order Saved Successfully!", "success");
                                reader.Close();
                                con.Close();
                                btnCancel_Click(sender, e);
                                BindWorkOrderList();
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "ShowList", "showPanel('pnlList');", true);
                                return;
                            }
                            else
                            {
                                ShowMessage("Error: " + status, "warning");
                            }
                        }
                    }
                }
                con.Close();
            }
            catch (Exception ex)
            {
                ShowMessage("Database Error: " + ex.Message, "warning");
            }
            ShowFormPanel();
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            Session["WO_ColorList"] = new List<ColorItem>();
            hdnSelectedColorSlNo.Value = "0";
            hdnWorkOrderNo.Value = string.Empty;

            ClearHeaderFields();
            ClearSizeInputRow();
            lblSelectedColorName.Text = "-- No color selected --";

            txtWoRef.Text = GenerateNextWorkOrderRef();

            BindColorList();
            BindSizeDetails();
            RecalculateGrandTotal();
        }

        private void ClearHeaderFields()
        {
            ddlCustomerName.SelectedIndex = 0;
            txtWoDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
            txtDeliveryDate.Text = string.Empty;
            txtBuyer.Text = string.Empty;
            txtStyle.Text = string.Empty;
            txtOrderNo.Text = string.Empty;
            txtWoNoDetails.Text = string.Empty;
            ddlItemNameDetails.SelectedIndex = 0;
            txtTransportCost.Text = "0.00";
            txtVatPercent.Text = "0.00";
        }

        #endregion

        #region ---------- UI Feedback ----------
        private void ShowFormPanel()
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ShowFormPanel", "showPanel('pnlForm');", true);
        }

        private void ShowMessage(string message, string type)
        {
            string script = $"alert('{message.Replace("'", "\\'")}');";
            ScriptManager.RegisterStartupScript(this, this.GetType(), "wo_msg_" + Guid.NewGuid().ToString("N"), script, true);
        }
        #endregion
    }
}
