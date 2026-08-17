using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.TrimsAccessories.EstimationCostings
{
    public partial class WorkOrderReceived : System.Web.UI.Page
    {
        SqlConnection con;
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();
        SqlCommand cmd;

        #region ---------- In-memory model class ----------
        [Serializable]
        public class SizeDetail
        {
            public int SlNo { get; set; }
            public int ItemID { get; set; }   // শুধু UI-তে ddlUnit লোড করার জন্য ব্যবহৃত, DB-তে সেভ হয় না (নতুন WorkOrderDetails টেবিলে ItemID কলাম নেই, শুধু ItemName আছে)
            public string ItemName { get; set; }
            public string Buyer { get; set; }
            public string Style { get; set; }
            public string PO { get; set; }
            // ★★★ NEW: নতুন WorkOrderDetails টেবিলে প্রতি-লাইন-আইটেম ItemDescription কলাম আছে।
            // হেডারের "Items Description" (TextBox1) থেকে Add করার সময় এখানে কপি হয়।
            public string ItemDescription { get; set; }
            public int ColorID { get; set; }
            public string ColorName { get; set; }
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

        #region ---------- Session-backed state helper ----------

        private List<SizeDetail> SizeList
        {
            get
            {
                if (Session["WO_SizeList"] == null)
                    Session["WO_SizeList"] = new List<SizeDetail>();
                return (List<SizeDetail>)Session["WO_SizeList"];
            }
            set { Session["WO_SizeList"] = value; }
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

                Session["WO_SizeList"] = new List<SizeDetail>();
                hdnWorkOrderNo.Value = string.Empty;

                txtWoDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                txtWoRef.Text = GenerateNextWorkOrderRef();

                BindWorkOrderList();
                BindSizeDetails();
                LoadItemsName();
                LoadSizeGroup();
            }
        }

        // ★★★ CHANGED: WorkOrder_Master -> techdefendersbd.WorkOrderHeader, WorkOrderNo -> WORcvNo
        private string GenerateNextWorkOrderRef()
        {
            string prefix = "WO-" + DateTime.Today.Year + "-";
            int nextNumber = 1;
            try
            {
                con = conn.openConnection();
                string query = @"SELECT MAX(CAST(RIGHT(WORcvNo, 4) AS INT)) 
                                  FROM techdefendersbd.WorkOrderHeader 
                                  WHERE WORcvNo LIKE @Prefix + '%'";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@Prefix", prefix);
                    object result = cmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value)
                        nextNumber = Convert.ToInt32(result) + 1;
                }
            }
            catch
            {
                nextNumber = 1;
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) con.Close();
            }
            return prefix + nextNumber.ToString("D4");
        }

        private void LoadUnit()
        {
            try
            {
                con = conn.openConnection();
                string query = @"SELECT ta_ItemName.ItemID, tbl_UnitSetup.UnitID, tbl_UnitSetup.UnitName
                    FROM ta_ItemName INNER JOIN tbl_UnitSetup ON ta_ItemName.Unit = tbl_UnitSetup.UnitName Where ta_ItemName.ItemID='" + ddlItemNameDetails.SelectedValue + "'";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlUnit.DataSource = dt;
                    ddlUnit.DataTextField = "UnitName";
                    ddlUnit.DataValueField = "UnitID";
                    ddlUnit.DataBind();
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, "warning");
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) con.Close();
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

                    ddlItemNameDetails.DataSource = dt;
                    ddlItemNameDetails.DataTextField = "ItemName";
                    ddlItemNameDetails.DataValueField = "ItemID";
                    ddlItemNameDetails.DataBind();

                    ddlItemNameDetails.Items.Insert(0, new ListItem("--Select Items Name--", "0"));
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, "warning");
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) con.Close();
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
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, "warning");
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) con.Close();
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
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, "warning");
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) con.Close();
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
                ShowMessage("Error: " + ex.Message, "warning");
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) con.Close();
            }
        }

        private void LoadColorNameDropdown()
        {
            Database_Connection conn = new Database_Connection();
            SqlConnection localCon = null;
            try
            {
                localCon = conn.openConnection();
                string query = "SELECT ColorID, ColorName FROM ColorInformation ORDER BY ColorName";
                using (SqlCommand cmd = new SqlCommand(query, localCon))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    DropDownList1.DataSource = dt;
                    DropDownList1.DataTextField = "ColorName";
                    DropDownList1.DataValueField = "ColorID";
                    DropDownList1.DataBind();

                    DropDownList1.Items.Insert(0, new ListItem("--Select Color (Optional)--", "0"));
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, "warning");
            }
            finally
            {
                if (localCon != null && localCon.State == ConnectionState.Open) localCon.Close();
            }
        }

        // ★★★ CHANGED: WorkOrder_Master -> techdefendersbd.WorkOrderHeader, নতুন কলাম নাম সরাসরি
        // WORcvID/WORcvNo/WORcvDate/DeliveryDate/GrandTotal — টেবিলে আগে থেকেই এই নামে আছে, তাই
        // আর কোনো AS alias দরকার নেই। শুধু active (IsActive=1) রেকর্ড দেখানো হচ্ছে।
        private void BindWorkOrderList()
        {
            try
            {
                con = conn.openConnection();
                string query = @"SELECT TOP 50 
                                      WORcvID,
                                      WORcvNo,
                                      WORcvDate,
                                      DeliveryDate,
                                      GrandTotal
                                  FROM techdefendersbd.WorkOrderHeader 
                                  WHERE IsActive = 1
                                  ORDER BY WORcvID DESC";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    gvWorkOrderReceive.DataSource = dt;
                    gvWorkOrderReceive.DataBind();
                }
            }
            catch (Exception ex)
            {
                gvWorkOrderReceive.DataSource = null;
                gvWorkOrderReceive.DataBind();
                ShowMessage("List Load Error: " + ex.Message, "warning");
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) con.Close();
            }
        }

        #endregion

        #region ---------- Autocomplete Suggestion WebMethods (Buyer / Style / Order No) ----------
        // অপরিবর্তিত — এগুলো একটা আলাদা লুকআপ ভিউ/টেবিল থেকে সাজেশন আনে, WorkOrderHeader/
        // WorkOrderDetails এর সাথে সরাসরি সম্পর্কিত না।

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
            catch { }
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
            catch { }
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
            catch { }
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
                // ★★★ CHANGED: Physical DELETE এর বদলে soft-delete (IsActive = 0)।
                // WorkOrderDetails টেবিল অক্ষত থাকে (হিস্টোরি/রিপোর্টিং এর জন্য সংরক্ষিত থাকে),
                // এবং BindWorkOrderList() যেহেতু WHERE IsActive = 1 ফিল্টার করে, তাই তালিকা
                // থেকে সাথে সাথে হাইড হয়ে যাবে।
                try
                {
                    con = conn.openConnection();
                    using (SqlCommand cmd = new SqlCommand(
                        "UPDATE techdefendersbd.WorkOrderHeader SET IsActive = 0 WHERE WORcvNo = @WORcvNo", con))
                    {
                        cmd.Parameters.AddWithValue("@WORcvNo", arg);
                        cmd.ExecuteNonQuery();
                    }
                    ShowMessage("Work Order Deleted Successfully!", "success");
                    BindWorkOrderList();
                }
                catch (Exception ex)
                {
                    ShowMessage("Delete Error: " + ex.Message, "warning");
                }
                finally
                {
                    if (con != null && con.State == ConnectionState.Open) con.Close();
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

        // ★★★ CHANGED (schema rewrite): নতুন স্কিমায় Color আলাদা টেবিলে নেই — ColorName সরাসরি
        // WorkOrderDetails-এ flat কলাম হিসেবে থাকে, তাই আগের ColorSlNo lookup query পুরোপুরি
        // বাদ দেওয়া হয়েছে। এবং ItemID কলামও নেই, তাই Item ম্যাচ হচ্ছে ItemName (Text) দিয়ে।
        // Buyer/Style/PO/ItemDescription এখন প্রতি-ডিটেইল-রো থেকে সরাসরি পড়া হচ্ছে এবং প্রথম
        // রো এর মান দিয়ে হেডার-লেভেল ইনপুট বক্সগুলো (txtBuyer/txtStyle/txtOrderNo/TextBox1)
        // প্রি-ফিল করা হচ্ছে যাতে এডিট করার সময় ইউজার সেগুলো দেখতে পায়।
        private void LoadWorkOrderForEdit(string workOrderNo)
        {
            try
            {
                con = conn.openConnection();

                int woID = 0;
                string headerQuery = "SELECT * FROM techdefendersbd.WorkOrderHeader WHERE WORcvNo = @WORcvNo";
                using (SqlCommand cmd = new SqlCommand(headerQuery, con))
                {
                    cmd.Parameters.AddWithValue("@WORcvNo", workOrderNo);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            woID = Convert.ToInt32(reader["WORcvID"]);
                            hdnWorkOrderNo.Value = woID.ToString();
                            txtWoRef.Text = reader["WORcvNo"].ToString();
                            txtWoNoDetails.Text = reader["RefWorkOrderNo"]?.ToString();

                            if (reader["WORcvDate"] != DBNull.Value)
                                txtWoDate.Text = Convert.ToDateTime(reader["WORcvDate"]).ToString("yyyy-MM-dd");

                            if (reader["DeliveryDate"] != DBNull.Value)
                                txtDeliveryDate.Text = Convert.ToDateTime(reader["DeliveryDate"]).ToString("yyyy-MM-dd");

                            string customerID = reader["CustomerID"] != DBNull.Value ? reader["CustomerID"].ToString() : null;
                            if (!string.IsNullOrEmpty(customerID) && ddlCustomerName.Items.FindByValue(customerID) != null)
                                ddlCustomerName.SelectedValue = customerID;

                            string branchID = reader["ReceivingBranchID"] != DBNull.Value ? reader["ReceivingBranchID"].ToString() : null;
                            if (!string.IsNullOrEmpty(branchID) && ddlReceivingBranch.Items.FindByValue(branchID) != null)
                                ddlReceivingBranch.SelectedValue = branchID;

                            txtQuotationNo.Text = reader["QuotationNo"]?.ToString();

                            txtTransportCost.Text = Convert.ToDecimal(reader["TransportCost"]).ToString("0.00");
                            txtVatPercent.Text = Convert.ToDecimal(reader["VatPercent"]).ToString("0.00");
                            txtSubTotalAmount.Text = Convert.ToDecimal(reader["SubTotalAmount"]).ToString("0.00");
                            txtGrandTotalAmount.Text = Convert.ToDecimal(reader["GrandTotal"]).ToString("0.00");
                        }
                    }
                }

                if (woID == 0)
                {
                    ShowMessage("Work Order not found.", "warning");
                    return;
                }

                var newSizeList = new List<SizeDetail>();
                // NOTE: এখানে ORDER BY (SELECT NULL) ব্যবহার করা হয়েছে যাতে আপনার Details
                // টেবিলের প্রকৃত Identity/PK কলামের নাম যাই হোক না কেন কোনো এরর না দেয়।
                // যদি টেবিলে যেমন WorkOrderDetailsID (identity) থাকে, সেটার নাম বসিয়ে
                // "ORDER BY WorkOrderDetailsID" করে দিলে ইনসার্শন-অর্ডার অনুযায়ী সাজানো থাকবে।
                string detailsQuery = @"SELECT * FROM techdefendersbd.WorkOrderDetails 
                                         WHERE WORcvID = @WORcvID 
                                         ORDER BY (SELECT NULL)";
                using (SqlCommand cmd = new SqlCommand(detailsQuery, con))
                {
                    cmd.Parameters.AddWithValue("@WORcvID", woID);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        int slNo = 1;
                        while (reader.Read())
                        {
                            string itemName = reader["ItemName"]?.ToString() ?? string.Empty;
                            ListItem matchedItem = ddlItemNameDetails.Items.FindByText(itemName);

                            newSizeList.Add(new SizeDetail
                            {
                                SlNo = slNo++,
                                ItemID = matchedItem != null ? Convert.ToInt32(matchedItem.Value) : 0,
                                ItemName = itemName,
                                Buyer = reader["Buyer"]?.ToString(),
                                Style = reader["Style"]?.ToString(),
                                PO = reader["PO"]?.ToString(),
                                ItemDescription = reader["ItemDescription"]?.ToString(),
                                ColorID = 0,
                                ColorName = reader["ColorName"]?.ToString() ?? string.Empty,
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

                SizeList = newSizeList;

                // হেডার-লেভেল ইনপুট বক্সে প্রথম ডিটেইল-রো এর Buyer/Style/PO/Description প্রি-ফিল
                if (newSizeList.Count > 0)
                {
                    txtBuyer.Text = newSizeList[0].Buyer;
                    txtStyle.Text = newSizeList[0].Style;
                    txtOrderNo.Text = newSizeList[0].PO;
                    TextBox1.Text = newSizeList[0].ItemDescription;
                }

                BindSizeDetails();
                RecalculateGrandTotal();
            }
            catch (Exception ex)
            {
                ShowMessage("Edit Load Error: " + ex.Message, "warning");
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) con.Close();
            }
        }

        #endregion

        #region ---------- Size-wise Variant Entry (Item + Color(Optional) + Size in one row) ----------

        protected void btnAddSize_Click(object sender, EventArgs e)
        {
            try
            {
                if (ddlItemNameDetails.SelectedValue == "0" || string.IsNullOrEmpty(ddlItemNameDetails.SelectedValue))
                {
                    ShowMessage("Please select an Item Name first.", "warning");
                    ShowFormPanel();
                    return;
                }

                decimal.TryParse(txtReqQty.Text, out decimal reqQty);
                decimal.TryParse(txtRate.Text, out decimal rateUnit);
                decimal.TryParse(txtExtraPercent.Text, out decimal extraPercent);

                decimal totalReqQty = reqQty + (reqQty * (extraPercent / 100m));
                decimal totalAmount = totalReqQty * rateUnit;

                var list = SizeList;
                int nextSlNo = list.Any() ? list.Max(s => s.SlNo) + 1 : 1;

                int.TryParse(ddlItemNameDetails.SelectedValue, out int selectedItemID);
                int.TryParse(DropDownList1.SelectedValue, out int selectedColorID);

                string selectedColorName = (selectedColorID > 0 && DropDownList1.SelectedItem != null)
                    ? DropDownList1.SelectedItem.Text
                    : string.Empty;
                if (selectedColorID <= 0) selectedColorID = 0;

                list.Add(new SizeDetail
                {
                    SlNo = nextSlNo,
                    ItemID = selectedItemID,
                    Buyer = txtBuyer.Text.Trim(),
                    Style = txtStyle.Text.Trim(),
                    PO = txtOrderNo.Text.Trim(),
                    ItemDescription = TextBox1.Text.Trim(), // ★★★ NEW
                    ItemName = ddlItemNameDetails.SelectedItem?.Text ?? string.Empty,
                    ColorID = selectedColorID,
                    ColorName = selectedColorName,
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
                SizeList = list;

                ClearSizeInputRow();

                BindSizeDetails();
                RecalculateGrandTotal();
            }
            catch (Exception ex)
            {
                ShowMessage("Add Size Error: " + ex.Message, "warning");
            }
            ShowFormPanel();
        }

        protected void btnAddAllsize_Click(object sender, EventArgs e)
        {
            if (ddlsizeGroup.SelectedValue == "0")
            {
                ShowMessage("Please select a Size Group first.", "warning");
                ShowFormPanel();
                return;
            }

            if (ddlItemNameDetails.SelectedValue == "0")
            {
                ShowMessage("Please select an Item Name first.", "warning");
                ShowFormPanel();
                return;
            }

            decimal.TryParse(txtRate.Text, out decimal rateVal);
            decimal.TryParse(txtReqQty.Text, out decimal RequiresQtyVal);
            int.TryParse(ddlItemNameDetails.SelectedValue, out int selectedItemID);
            int.TryParse(DropDownList1.SelectedValue, out int selectedColorID);
            string selectedItemName = ddlItemNameDetails.SelectedItem?.Text ?? string.Empty;
            string selectedColorName = (selectedColorID > 0 && DropDownList1.SelectedItem != null)
                ? DropDownList1.SelectedItem.Text
                : string.Empty;
            if (selectedColorID <= 0) selectedColorID = 0;

            string buyer = txtBuyer.Text.Trim();
            string style = txtStyle.Text.Trim();
            string po = txtOrderNo.Text.Trim();
            string itemDescription = TextBox1.Text.Trim(); // ★★★ NEW

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

                    var list = SizeList;
                    int nextSlNo = list.Any() ? list.Max(s => s.SlNo) + 1 : 1;

                    foreach (DataRow row in dt.Rows)
                    {
                        string sizeName = row["Size"].ToString();

                        bool alreadyExists = list.Any(s => s.Size == sizeName
                                                            && s.ItemID == selectedItemID
                                                            && s.ColorName == selectedColorName);
                        if (alreadyExists) continue;

                        list.Add(new SizeDetail
                        {
                            SlNo = nextSlNo++,
                            ItemID = selectedItemID,
                            ItemName = selectedItemName,
                            Buyer = buyer,
                            Style = style,
                            PO = po,
                            ItemDescription = itemDescription,
                            ColorID = selectedColorID,
                            ColorName = selectedColorName,
                            Size = sizeName,
                            Measurement = string.Empty,
                            ReqQty = RequiresQtyVal,
                            Unit = ddlUnit.SelectedValue,
                            RateUnit = rateVal,
                            ExtraPercent = 0,
                            TotalReqQty = 0,
                            TotalAmount = 0,
                            Remarks = string.Empty
                        });
                    }
                    SizeList = list;
                }

                BindSizeDetails();
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

        protected void gvSizeDetails_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (!int.TryParse(e.CommandArgument?.ToString(), out int slNo))
            {
                ShowFormPanel();
                return;
            }

            var list = SizeList;
            var size = list.FirstOrDefault(s => s.SlNo == slNo);
            if (size == null)
            {
                ShowFormPanel();
                return;
            }

            switch (e.CommandName)
            {
                case "EditSize":
                    if (ddlItemNameDetails.Items.FindByValue(size.ItemID.ToString()) != null)
                        ddlItemNameDetails.SelectedValue = size.ItemID.ToString();

                    if (size.ColorID > 0 && DropDownList1.Items.FindByValue(size.ColorID.ToString()) != null)
                        DropDownList1.SelectedValue = size.ColorID.ToString();
                    else
                        DropDownList1.SelectedIndex = 0;

                    txtBuyer.Text = size.Buyer;
                    txtStyle.Text = size.Style;
                    txtOrderNo.Text = size.PO;
                    TextBox1.Text = size.ItemDescription;

                    txtSize.Text = size.Size;
                    txtMeasurement.Text = size.Measurement;
                    txtReqQty.Text = size.ReqQty.ToString("0.##");
                    ddlUnit.SelectedValue = size.Unit;
                    txtRate.Text = size.RateUnit.ToString("0.##");
                    txtExtraPercent.Text = size.ExtraPercent.ToString("0.##");
                    txtTotalReqQtyInput.Text = size.TotalReqQty.ToString("0.00");
                    txtTotalAmountInput.Text = size.TotalAmount.ToString("0.00");
                    txtSizeRemarks.Text = size.Remarks;

                    list.Remove(size);
                    SizeList = list;

                    BindSizeDetails();
                    RecalculateGrandTotal();
                    break;

                case "DeleteSize":
                    list.Remove(size);
                    SizeList = list;

                    BindSizeDetails();
                    RecalculateGrandTotal();
                    break;

                case "UpdateSize":
                    GridViewRow row = ((Control)e.CommandSource).NamingContainer as GridViewRow;
                    if (row != null)
                    {
                        ApplySizeRowEdits(row, size);

                        BindSizeDetails();
                        RecalculateGrandTotal();
                    }
                    break;
            }

            ShowFormPanel();
        }

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

        protected void txtSizeGridField_TextChanged(object sender, EventArgs e)
        {
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
            var size = SizeList.FirstOrDefault(s => s.SlNo == slNo);
            if (size == null)
            {
                ShowFormPanel();
                return;
            }

            ApplySizeRowEdits(row, size);

            BindSizeDetails();
            RecalculateGrandTotal();
            ShowFormPanel();
        }

        private void BindSizeDetails()
        {
            var list = SizeList.OrderBy(s => s.SlNo).ToList();
            gvSizeDetails.DataSource = list;
            gvSizeDetails.DataBind();
            txtColorTotalAmount.Text = list.Sum(s => s.TotalAmount).ToString("0.00");
        }

        private void ClearSizeInputRow()
        {
            txtSize.Text = string.Empty;
            txtMeasurement.Text = string.Empty;
            txtReqQty.Text = "0";
            ddlUnit.SelectedIndex = 0;
            txtExtraPercent.Text = "0";
            txtTotalReqQtyInput.Text = "0.00";
            txtTotalAmountInput.Text = "0.00";
            txtSizeRemarks.Text = string.Empty;
        }

        #endregion

        #region ---------- Grand Total Summary ----------

        private void RecalculateGrandTotal()
        {
            decimal subTotal = SizeList.Sum(s => s.TotalAmount);
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

        // ★★★ CHANGED: sp_SaveOrUpdateWorkOrder এর নতুন সংস্করণ কল করছে (দেখুন
        // sp_SaveOrUpdateWorkOrder.sql), যেটা techdefendersbd.WorkOrderHeader ও
        // techdefendersbd.WorkOrderDetails-এ Insert/Update করে। dtDetails-এ এখন
        // "ItemDescription" কলাম যোগ হয়েছে, এবং Buyer/Style/PO/ItemDescription এর মান
        // GridView সেলের টেক্সট স্ক্র্যাপ করার বদলে আগে SizeList (session state) থেকে
        // নেওয়া হচ্ছে — কারণ ওই কলামগুলো গ্রিডে এডিটেবল কন্ট্রোল হিসেবে নেই।
        protected void btnSave_Click(object sender, EventArgs e)
        {
            // বেসিক ভ্যালিডেশন
            if (ddlCustomerName.SelectedValue == "0")
            {
                ShowMessage("Please select a Customer Name.", "warning");
                ShowFormPanel();
                return;
            }
            if (ddlReceivingBranch.SelectedValue == "0" || string.IsNullOrEmpty(ddlReceivingBranch.SelectedValue))
            {
                ShowMessage("Please select a Receiving Branch.", "warning");
                ShowFormPanel();
                return;
            }
            if (!SizeList.Any())
            {
                ShowMessage("Please add at least one Item/Size row before saving.", "warning");
                ShowFormPanel();
                return;
            }

            try
            {
                con = conn.openConnection();

                using (SqlCommand cmd = new SqlCommand("sp_SaveOrUpdateWorkOrder", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    int workOrderId = string.IsNullOrEmpty(hdnWorkOrderNo.Value) ? 0 : Convert.ToInt32(hdnWorkOrderNo.Value);

                    SqlParameter pId = cmd.Parameters.Add("@WORcvID", SqlDbType.Int);
                    pId.Value = workOrderId;
                    pId.Direction = ParameterDirection.InputOutput;

                    cmd.Parameters.AddWithValue("@WORcvNo", txtWoRef.Text.Trim());
                    cmd.Parameters.AddWithValue("@WORcvDate", string.IsNullOrEmpty(txtWoDate.Text) ? (object)DBNull.Value : Convert.ToDateTime(txtWoDate.Text));
                    cmd.Parameters.AddWithValue("@DeliveryDate", string.IsNullOrEmpty(txtDeliveryDate.Text) ? (object)DBNull.Value : Convert.ToDateTime(txtDeliveryDate.Text));
                    cmd.Parameters.AddWithValue("@CustomerID", Convert.ToInt32(ddlCustomerName.SelectedValue));
                    cmd.Parameters.AddWithValue("@ReceivingBranchID", Convert.ToInt32(ddlReceivingBranch.SelectedValue));
                    cmd.Parameters.AddWithValue("@RefWorkOrderNo", txtWoNoDetails.Text.Trim());
                    cmd.Parameters.AddWithValue("@QuotationNo", txtQuotationNo.Text.Trim());
                    cmd.Parameters.AddWithValue("@SubTotalAmount", Convert.ToDecimal(string.IsNullOrEmpty(txtSubTotalAmount.Text) ? "0" : txtSubTotalAmount.Text));
                    cmd.Parameters.AddWithValue("@TransportCost", Convert.ToDecimal(string.IsNullOrEmpty(txtTransportCost.Text) ? "0" : txtTransportCost.Text));
                    cmd.Parameters.AddWithValue("@VatPercent", Convert.ToDecimal(string.IsNullOrEmpty(txtVatPercent.Text) ? "0" : txtVatPercent.Text));
                    cmd.Parameters.AddWithValue("@GrandTotal", Convert.ToDecimal(string.IsNullOrEmpty(txtGrandTotalAmount.Text) ? "0" : txtGrandTotalAmount.Text));

                    // ----- Details TVP: dbo.WorkOrderDetailsType এর সাথে হুবহু কলাম মিলিয়ে -----
                    DataTable dtDetails = new DataTable();
                    dtDetails.Columns.Add("Buyer", typeof(string));
                    dtDetails.Columns.Add("Style", typeof(string));
                    dtDetails.Columns.Add("PO", typeof(string));
                    dtDetails.Columns.Add("ItemName", typeof(string));
                    dtDetails.Columns.Add("ItemDescription", typeof(string)); // ★★★ NEW
                    dtDetails.Columns.Add("ColorName", typeof(string));
                    dtDetails.Columns.Add("Size", typeof(string));
                    dtDetails.Columns.Add("Measurement", typeof(string));
                    dtDetails.Columns.Add("ReqQty", typeof(decimal));
                    dtDetails.Columns.Add("Unit", typeof(string));
                    dtDetails.Columns.Add("RateUnit", typeof(decimal));
                    dtDetails.Columns.Add("ExtraPercent", typeof(decimal));
                    dtDetails.Columns.Add("TotalReqQty", typeof(decimal));
                    dtDetails.Columns.Add("TotalAmount", typeof(decimal));
                    dtDetails.Columns.Add("Remarks", typeof(string));

                    foreach (GridViewRow row in gvSizeDetails.Rows)
                    {
                        if (row.RowType != DataControlRowType.DataRow) continue;

                        // এই রো-র SlNo দিয়ে SizeList (session) থেকে Buyer/Style/PO/ItemDescription
                        // এর প্রকৃত মান বের করা হচ্ছে, কারণ গ্রিডে এগুলোর এডিটেবল কন্ট্রোল নেই।
                        int slNo = Convert.ToInt32(gvSizeDetails.DataKeys[row.RowIndex].Value);
                        var sizeItem = SizeList.FirstOrDefault(s => s.SlNo == slNo);

                        TextBox txtMeasurement = (TextBox)row.FindControl("txtMeasurement");
                        TextBox txtReqQty = (TextBox)row.FindControl("txtReqQty");
                        TextBox txtUnit = (TextBox)row.FindControl("txtUnit");
                        TextBox txtRateUnit = (TextBox)row.FindControl("txtRateUnit");
                        TextBox txtExtraPercent = (TextBox)row.FindControl("txtExtraPercent");
                        Label lblTotalReqQty = (Label)row.FindControl("lblTotalReqQty");
                        Label lblTotalAmount = (Label)row.FindControl("lblTotalAmount");
                        TextBox txtRemarks = (TextBox)row.FindControl("txtRemarks");

                        DataRow dr = dtDetails.NewRow();
                        dr["Buyer"] = sizeItem?.Buyer ?? row.Cells[2].Text.Trim();
                        dr["Style"] = sizeItem?.Style ?? row.Cells[3].Text.Trim();
                        dr["PO"] = sizeItem?.PO ?? row.Cells[4].Text.Trim();
                        dr["ItemName"] = sizeItem?.ItemName ?? row.Cells[1].Text.Trim();
                        dr["ItemDescription"] = (object)sizeItem?.ItemDescription ?? (object)TextBox1.Text.Trim() ?? DBNull.Value;
                        dr["ColorName"] = sizeItem?.ColorName ?? row.Cells[5].Text.Trim();
                        dr["Size"] = sizeItem?.Size ?? row.Cells[6].Text.Trim();
                        dr["Measurement"] = txtMeasurement != null ? txtMeasurement.Text : "";
                        dr["ReqQty"] = Convert.ToDecimal(string.IsNullOrEmpty(txtReqQty?.Text) ? "0" : txtReqQty.Text);
                        dr["Unit"] = txtUnit != null ? txtUnit.Text : "";
                        dr["RateUnit"] = Convert.ToDecimal(string.IsNullOrEmpty(txtRateUnit?.Text) ? "0" : txtRateUnit.Text);
                        dr["ExtraPercent"] = Convert.ToDecimal(string.IsNullOrEmpty(txtExtraPercent?.Text) ? "0" : txtExtraPercent.Text);
                        dr["TotalReqQty"] = Convert.ToDecimal(string.IsNullOrEmpty(lblTotalReqQty?.Text) ? "0" : lblTotalReqQty.Text);
                        dr["TotalAmount"] = Convert.ToDecimal(string.IsNullOrEmpty(lblTotalAmount?.Text) ? "0" : lblTotalAmount.Text);
                        dr["Remarks"] = txtRemarks != null ? txtRemarks.Text : "";

                        dtDetails.Rows.Add(dr);
                    }

                    SqlParameter pDetails = cmd.Parameters.AddWithValue("@DetailsType", dtDetails);
                    pDetails.SqlDbType = SqlDbType.Structured;
                    pDetails.TypeName = "dbo.WorkOrderDetailsType";

                    cmd.ExecuteNonQuery();

                    hdnWorkOrderNo.Value = pId.Value.ToString();

                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Work Order Saved Successfully!');", true);

                    BindWorkOrderList();
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", $"alert('Error: {ex.Message.Replace("'", "")}');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open)
                {
                    con.Close();
                }
            }
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            Session["WO_SizeList"] = new List<SizeDetail>();
            hdnWorkOrderNo.Value = string.Empty;

            ClearHeaderFields();
            ClearSizeInputRow();

            txtWoRef.Text = GenerateNextWorkOrderRef();

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
            DropDownList1.SelectedIndex = 0;
            ddlReceivingBranch.SelectedIndex = 0;
            txtQuotationNo.Text = string.Empty;
            TextBox1.Text = string.Empty;
            txtTransportCost.Text = "0.00";
            txtVatPercent.Text = "0.00";
            txtRate.Text = "0";
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

        protected void LinkButton1_Click(object sender, EventArgs e)
        {
            LoadColorNameDropdown();
        }

        protected void Button1_Click(object sender, EventArgs e)
        {
            LoadItemsName();
        }

        protected void ddlItemNameDetails_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadUnit();
        }

        protected void btnRefreshCustomer_Click(object sender, EventArgs e)
        {

        }
    }
}
