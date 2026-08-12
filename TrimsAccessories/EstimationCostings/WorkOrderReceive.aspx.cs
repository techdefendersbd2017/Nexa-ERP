using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web.Services;
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
            public string ColorRate { get; set; }
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
                LoadReceivingBranch();

                Session["WO_ColorList"] = new List<ColorItem>();
                hdnSelectedColorSlNo.Value = "0";
                hdnWorkOrderNo.Value = string.Empty;

                txtWoDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                txtWoRef.Text = GenerateNextWorkOrderRef();

                BindWorkOrderList();
                BindColorList();
                BindSizeDetails();
                LoadItemsName();
                LoadSizeGroup();
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
                string query = "SELECT * FROM ta_ItemName ORDER BY ItemName";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlItemNameDetails.DataSource = dt;
                    ddlItemNameDetails.DataTextField = "ItemName";
                    ddlItemNameDetails.DataValueField = "ItemID";
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
        private void LoadSizeGroup()
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT GroupID, GroupName FROM SizeGroups ORDER BY GroupName";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlsizeGroup.DataSource = dt;
                    ddlsizeGroup.DataTextField = "GroupName";
                    ddlsizeGroup.DataValueField = "GroupID";
                    ddlsizeGroup.DataBind();

                    ddlsizeGroup.Items.Insert(0, new ListItem("--Select Size Group--", "0"));
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

                    ddlReceivingBranch.Items.Insert(0, new ListItem("--Select Receiving Branch--", "0"));
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

        #region ---------- Autocomplete Suggestion WebMethods (Buyer / Style / Order No) ----------
        // NOTE: These MUST be public static and decorated with [WebMethod] so that
        // jQuery can call them directly as ASP.NET PageMethods (POST to
        // WorkOrderReceive.aspx/GetBuyerSuggestions etc). ScriptManager1 on the .aspx
        // page must have EnablePageMethods="true" for this to work.

        [WebMethod]
        public static List<string> GetBuyerSuggestions(string prefixText)
        {
            List<string> result = new List<string>();
            if (string.IsNullOrWhiteSpace(prefixText)) return result;

            DatabaseConnectionMerchandising connHelper = new DatabaseConnectionMerchandising();
            SqlConnection localCon = null;
            try
            {
                localCon = connHelper.openConnection();
                // vw_BuyerInformation : BuyerName column, only active buyers
                string query = @"SELECT DISTINCT TOP 10 BuyerName 
                                  FROM vw_BuyerInformation 
                                  WHERE BuyerName LIKE @Prefix + '%' 
                                    AND IsActive = 1
                                  ORDER BY BuyerName";
                using (SqlCommand cmd = new SqlCommand(query, localCon))
                {
                    cmd.Parameters.AddWithValue("@Prefix", prefixText.Trim());
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            if (reader["BuyerName"] != DBNull.Value)
                                result.Add(reader["BuyerName"].ToString());
                        }
                    }
                }
            }
            catch
            {
                // Fail silently for autocomplete - just return empty list
            }
            finally
            {
                if (localCon != null && localCon.State == ConnectionState.Open)
                    localCon.Close();
            }
            return result;
        }

        [WebMethod]
        public static List<string> GetStyleSuggestions(string prefixText)
        {
            List<string> result = new List<string>();
            if (string.IsNullOrWhiteSpace(prefixText)) return result;

            DatabaseConnectionMerchandising connHelper = new DatabaseConnectionMerchandising();
            SqlConnection localCon = null;
            try
            {
                localCon = connHelper.openConnection();
                // Style_Master : StyleName column, only active styles
                string query = @"SELECT DISTINCT TOP 10 StyleName 
                                  FROM Style_Master 
                                  WHERE StyleName LIKE @Prefix + '%' 
                                    AND IsActive = 1
                                  ORDER BY StyleName";
                using (SqlCommand cmd = new SqlCommand(query, localCon))
                {
                    cmd.Parameters.AddWithValue("@Prefix", prefixText.Trim());
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            if (reader["StyleName"] != DBNull.Value)
                                result.Add(reader["StyleName"].ToString());
                        }
                    }
                }
            }
            catch
            {
                // Fail silently for autocomplete - just return empty list
            }
            finally
            {
                if (localCon != null && localCon.State == ConnectionState.Open)
                    localCon.Close();
            }
            return result;
        }

        [WebMethod]
        public static List<string> GetOrderSuggestions(string prefixText)
        {
            List<string> result = new List<string>();
            if (string.IsNullOrWhiteSpace(prefixText)) return result;

            DatabaseConnectionMerchandising connHelper = new DatabaseConnectionMerchandising();
            SqlConnection localCon = null;
            try
            {
                localCon = connHelper.openConnection();
                // tbl_POEntryInformation : PONumber column (used as "Order No")
                string query = @"SELECT DISTINCT TOP 10 PONumber 
                                  FROM tbl_POEntryInformation 
                                  WHERE PONumber LIKE @Prefix + '%'
                                  ORDER BY PONumber";
                using (SqlCommand cmd = new SqlCommand(query, localCon))
                {
                    cmd.Parameters.AddWithValue("@Prefix", prefixText.Trim());
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            if (reader["PONumber"] != DBNull.Value)
                                result.Add(reader["PONumber"].ToString());
                        }
                    }
                }
            }
            catch
            {
                // Fail silently for autocomplete - just return empty list
            }
            finally
            {
                if (localCon != null && localCon.State == ConnectionState.Open)
                    localCon.Close();
            }
            return result;
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
            else if (e.CommandName == "ReportView")
            {
                string url = ResolveUrl($"~/TrimsAccessories/EstimationCostings/OrdersReports/ReceivedOrdersReports.aspx?WORcvID={arg}");
                string script = $"window.open('{url}', '_blank');";
                ScriptManager.RegisterStartupScript(this, this.GetType(), "OpenReport", script, true);
            }
            else if (e.CommandName == "RawMatrialView")
            {
                string url = ResolveUrl($"~/TrimsAccessories/EstimationCostings/OrdersReports/RawMaterialReports.aspx?WORcvID={arg}");
                string script = $"window.open('{url}', '_blank');";
                ScriptManager.RegisterStartupScript(this, this.GetType(), "OpenRawMaterialReport", script, true);
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

                            // ★★★ FIXED: ItemName টেক্সট এর বদলে ItemID কলাম দিয়ে সিলেক্ট করা হচ্ছে
                            // (ddlItemNameDetails.DataValueField = "CategoryID" অর্থাৎ ID প্রয়োজন)
                            string itemID = reader["ItemID"] != DBNull.Value ? reader["ItemID"].ToString() : null;
                            if (!string.IsNullOrEmpty(itemID) && ddlItemNameDetails.Items.FindByValue(itemID) != null)
                                ddlItemNameDetails.SelectedValue = itemID;

                            // ★★★ NEW: Receiving Branch এডিট মোডে সিলেক্ট করা
                            string branchID = reader["ReceivingBranch"] != DBNull.Value ? reader["ReceivingBranch"].ToString() : null;
                            if (!string.IsNullOrEmpty(branchID) && ddlReceivingBranch.Items.FindByValue(branchID) != null)
                                ddlReceivingBranch.SelectedValue = branchID;

                            // ★★★ NEW: Quotation No এবং Items Description লোড করা
                            txtQuotationNo.Text = reader["QuotationNo"]?.ToString();
                            TextBox1.Text = reader["ItemsDescription"]?.ToString();

                            txtTransportCost.Text = Convert.ToDecimal(reader["TransportCost"]).ToString("0.00");
                            txtVatPercent.Text = Convert.ToDecimal(reader["VatPercent"]).ToString("0.00");
                            txtSubTotalAmount.Text = Convert.ToDecimal(reader["SubTotalAmount"]).ToString("0.00");
                            txtGrandTotalAmount.Text = Convert.ToDecimal(reader["GrandTotalAmount"]).ToString("0.00");
                        }
                    }
                }

                var newColorList = new List<ColorItem>();
                // ★★★ FIXED: ColorRate কলাম যোগ করা হয়েছে
                string colorQuery = @"SELECT ColorSlNo, ColorName, ColorRate, ColorRemarks, TotalReqQty, ColorTotalAmount 
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
                                ColorRate = reader["ColorRate"] != DBNull.Value ? reader["ColorRate"].ToString() : string.Empty,
                                ColorRemarks = reader["ColorRemarks"]?.ToString(),
                                TotalReqQty = Convert.ToDecimal(reader["TotalReqQty"]),
                                ColorTotalAmount = Convert.ToDecimal(reader["ColorTotalAmount"]),
                                SizeDetails = new List<SizeDetail>()
                            });
                        }
                    }
                }

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
                ColorRate = txtRate.Text.Trim(),
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
                    // ★ FIX (Issue 1): কালার সিলেক্ট করার পর ইনপুট রো ক্লিয়ার করার সাথে সাথে
                    // এই কালারের Rate টা txtRateUnit-এ বসিয়ে দেওয়া হচ্ছে (ClearSizeInputRow দেখুন)
                    ClearSizeInputRow();
                    BindColorList();
                    BindSizeDetails();
                    break;

                case "EditColor":
                    ddlColorName.ClearSelection();
                    var item = ddlColorName.Items.FindByText(color.ColorName);
                    if (item != null) item.Selected = true;
                    txtRate.Text = color.ColorRate;
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
            decimal totalAmount = totalReqQty * rateUnit;

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

                case "UpdateSize":
                    GridViewRow row = ((Control)e.CommandSource).NamingContainer as GridViewRow;
                    if (row != null)
                    {
                        ApplySizeRowEdits(row, size);
                        RecalculateColorTotals(color);

                        BindSizeDetails();
                        BindColorList();
                        RecalculateGrandTotal();
                    }
                    break;
            }

            ShowFormPanel();
        }

        // ★ NEW (Issue 2): "Update" বাটন এবং grid-এর AutoPostBack টেক্সটবক্স —
        // উভয় জায়গা থেকেই GridViewRow পড়ে SizeDetail-এ মান বসানোর কমন লজিক
        private void ApplySizeRowEdits(GridViewRow row, SizeDetail size)
        {
            TextBox txtM = (TextBox)row.FindControl("txtMeasurement");
            TextBox txtQ = (TextBox)row.FindControl("txtReqQty");
            TextBox txtU = (TextBox)row.FindControl("txtUnit");
            TextBox txtR = (TextBox)row.FindControl("txtRateUnit");
            TextBox txtE = (TextBox)row.FindControl("txtExtraPercent");
            TextBox txtRem = (TextBox)row.FindControl("txtRemarks");

            decimal.TryParse(txtQ?.Text, out decimal uReqQty);
            decimal.TryParse(txtR?.Text, out decimal uRateUnit);
            decimal.TryParse(txtE?.Text, out decimal uExtraPercent);

            size.Measurement = txtM?.Text.Trim();
            size.ReqQty = uReqQty;
            size.Unit = txtU?.Text.Trim();
            size.RateUnit = uRateUnit;
            size.ExtraPercent = uExtraPercent;
            size.TotalReqQty = uReqQty + (uReqQty * (uExtraPercent / 100m));
            size.TotalAmount = size.TotalReqQty * uRateUnit;
            size.Remarks = txtRem?.Text.Trim();
        }

        // ★ NEW (Issue 2): gvSizeDetails-এর ReqQty/RateUnit/ExtraPercent টেক্সটবক্সে
        // AutoPostBack="true" + OnTextChanged বসানো আছে (aspx দেখুন)। ফিল্ড থেকে
        // ফোকাস সরালেই (blur) এটা ফায়ার হয়ে সার্ভার-সাইড টোটাল রিক্যালকুলেট করে —
        // ফলে This Color's Total, Sub Total ও Grand Total সাথে সাথে আপডেট হয়ে যায়,
        // আলাদা করে "Update" বাটনে ক্লিক করা লাগে না।
        protected void txtSizeGridField_TextChanged(object sender, EventArgs e)
        {
            var color = GetSelectedColor();
            if (color == null)
            {
                ShowFormPanel();
                return;
            }

            TextBox tb = sender as TextBox;
            if (tb == null)
            {
                ShowFormPanel();
                return;
            }

            GridViewRow row = tb.NamingContainer as GridViewRow;
            if (row == null || row.RowIndex < 0)
            {
                ShowFormPanel();
                return;
            }

            int slNo = Convert.ToInt32(gvSizeDetails.DataKeys[row.RowIndex].Value);
            var size = color.SizeDetails.FirstOrDefault(s => s.SlNo == slNo);
            if (size == null)
            {
                ShowFormPanel();
                return;
            }

            ApplySizeRowEdits(row, size);
            RecalculateColorTotals(color);

            BindSizeDetails();
            BindColorList();
            RecalculateGrandTotal();
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

            // ★ FIX (Issue 1): সিলেক্টেড কালারের Rate থাকলে সেটা Rate/Unit ইনপুটে বসিয়ে দিন,
            // যাতে Add / Add All Size করার সময় কালারের রেটটাই সাইজ গ্রিডে চলে যায়
            var color = GetSelectedColor();
            txtRateUnit.Text = (color != null && !string.IsNullOrWhiteSpace(color.ColorRate))
                ? color.ColorRate
                : "0";

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

        protected void txtTransportCost_TextChanged(object sender, EventArgs e)
        {
            RecalculateGrandTotal();
            ShowFormPanel();
        }

        protected void txtVatPercent_TextChanged(object sender, EventArgs e)
        {
            RecalculateGrandTotal();
            ShowFormPanel();
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

            // ★★★ Receiving Branch বাধ্যতামূলক ভ্যালিডেশন
            if (ddlReceivingBranch.SelectedValue == "0")
            {
                ShowMessage("Please select a Receiving Branch before saving.", "warning");
                ShowFormPanel();
                return;
            }

            if (string.IsNullOrWhiteSpace(txtWoRef.Text)) txtWoRef.Text = GenerateNextWorkOrderRef();
            RecalculateGrandTotal();

            // ★★★ FIXED: ColorRate কলাম যোগ করা হয়েছে
            DataTable dtColors = new DataTable();
            dtColors.Columns.Add("ColorSlNo", typeof(int));
            dtColors.Columns.Add("ColorName", typeof(string));
            dtColors.Columns.Add("ColorRate", typeof(decimal));
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
                decimal.TryParse(col.ColorRate, out decimal colorRateVal);
                dtColors.Rows.Add(col.ColorSlNo, col.ColorName, colorRateVal, col.ColorRemarks, col.TotalReqQty, col.ColorTotalAmount);
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
                    cmd.Parameters.AddWithValue("@ItemName", ddlItemNameDetails.SelectedItem.Text);
                    cmd.Parameters.AddWithValue("@ItemID", ddlItemNameDetails.SelectedValue);
                    cmd.Parameters.AddWithValue("@ReceivingBranch", ddlReceivingBranch.SelectedValue);
                    // ★★★ NEW: Quotation No এবং Items Description
                    cmd.Parameters.AddWithValue("@QuotationNo", string.IsNullOrEmpty(txtQuotationNo.Text) ? (object)DBNull.Value : txtQuotationNo.Text.Trim());
                    cmd.Parameters.AddWithValue("@ItemsDescription", string.IsNullOrEmpty(TextBox1.Text) ? (object)DBNull.Value : TextBox1.Text.Trim());
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
            ddlReceivingBranch.SelectedIndex = 0;
            txtQuotationNo.Text = string.Empty;   // ★★★ NEW
            TextBox1.Text = string.Empty;         // ★★★ NEW
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

        protected void txtRate_TextChanged(object sender, EventArgs e)
        {
            txtRateUnit.Text = txtRate.Text;
        }

        protected void txtRateUnit_TextChanged(object sender, EventArgs e)
        {

        }

        protected void txtColorRemarks_TextChanged(object sender, EventArgs e)
        {

        }

        protected void btnAddAllsize_Click(object sender, EventArgs e)
        {
            if (ddlsizeGroup.SelectedValue == "0")
            {
                ShowMessage("Please select a Size Group first.", "warning");
                ShowFormPanel();
                return;
            }

            var color = GetSelectedColor();
            if (color == null)
            {
                ShowMessage("Please select a Color from the Color List first.", "warning");
                ShowFormPanel();
                return;
            }

            // ★ FIX (Issue 1): কালারের Rate টা এখানে "Add All Size" এর সময় প্রতিটা সাইজ রো-তে বসানো হবে
            decimal.TryParse(color.ColorRate, out decimal colorRateVal);

            try
            {
                con = conn.openConnection();
                string query = @"SELECT s.SizeID, s.SizeName AS Size
                          FROM Sizes s 
                          INNER JOIN SizeGroups g ON s.GroupID = g.GroupID 
                          WHERE s.GroupID = @GroupID
                          ORDER BY s.SizeID ASC";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@GroupID", ddlsizeGroup.SelectedValue);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    int nextSlNo = color.SizeDetails.Any() ? color.SizeDetails.Max(s => s.SlNo) + 1 : 1;

                    foreach (DataRow row in dt.Rows)
                    {
                        string sizeName = row["Size"].ToString();

                        if (color.SizeDetails.Any(s => s.Size == sizeName))
                            continue;

                        color.SizeDetails.Add(new SizeDetail
                        {
                            SlNo = nextSlNo++,
                            Size = sizeName,
                            Measurement = string.Empty,
                            ReqQty = 0,
                            Unit = ddlUnit.SelectedValue,
                            RateUnit = colorRateVal,   // ★ FIX: 0 এর বদলে কালারের Rate ব্যবহার করা হচ্ছে
                            ExtraPercent = 0,
                            TotalReqQty = 0,
                            TotalAmount = 0,
                            Remarks = string.Empty
                        });
                    }

                    RecalculateColorTotals(color);
                }
                con.Close();

                BindSizeDetails();
                BindColorList();
                RecalculateGrandTotal();
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, "warning");
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) { con.Close(); }
            }

            ShowFormPanel();
        }

    }
}
