using CrystalDecisions.Windows.Forms;
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
using static iTextSharp.tool.xml.html.HTML;

namespace Nexa_ERP.TrimsAccessories.EstimationCostings
{
    public partial class WorkOrderReceived : System.Web.UI.Page
    {
        string DetailsID;
        SqlConnection con;
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();
        SqlCommand cmd;

        #region ---------- In-memory model class ----------
        [Serializable]
        public class SizeDetail
        {
            public int SlNo { get; set; }
            public int ItemID { get; set; }
            public string ItemName { get; set; }
            public string JobNo { get; set; }
            public string Buyer { get; set; }
            public string Style { get; set; }
            public string PO { get; set; }
            public string ItemDescription { get; set; }
            public int ColorID { get; set; }
            public string ColorName { get; set; }
            public string Size { get; set; }
            public string Measurement { get; set; }
            public decimal ReqQty { get; set; }
            public string Unit { get; set; }
            public decimal RateUnit { get; set; }
            public string RateUnitName { get; set; }   // ★ NEW: Rate যে ইউনিটে দেওয়া হয়েছে (Per PCS/Dozen/KG ইত্যাদি)
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
                string user = Request.QueryString["user"];
                LoadColorNameDropdown();
                LoadPartyName();
                LoadReceivingBranch();
                LoadRateUnit(); // ★ NEW

                Session["WO_SizeList"] = new List<SizeDetail>();
                hdnWorkOrderNo.Value = string.Empty;

                txtWoDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                txtWoRef.Text = GenerateNextWorkOrderRef();

                //BindWorkOrderList();
                LoadItemsName();
                LoadSizeGroup();
                LoadPartyList();
                ShowWorkOrderList();

                ClientScript.RegisterStartupScript(this.GetType(), "showListPanel", "showPanel('pnlList');", true);
            }
        }
        private void ShowWorkOrderList()
        {
            try
            {
                con = conn.openConnection();
                DataTable dt = new DataTable();
                using (SqlCommand cmd = new SqlCommand("[techdefendersbd].[LoadWorkOrderList]", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    // PartyID - dropdown থেকে
                    int partyId = 0;
                    if (ddlCustomerListPage.SelectedValue != "0" && !string.IsNullOrEmpty(ddlCustomerListPage.SelectedValue))
                        partyId = Convert.ToInt32(ddlCustomerListPage.SelectedValue);

                    cmd.Parameters.AddWithValue("@PartyID",
                        partyId > 0 ? (object)partyId : DBNull.Value);

                    // Work Order No
                    cmd.Parameters.AddWithValue("@workOrderNo",
                        string.IsNullOrEmpty(txtWorderNo.Text.Trim()) ? (object)DBNull.Value : txtWorderNo.Text.Trim());

                    // Ref Work Order No
                    cmd.Parameters.AddWithValue("@RefworkOrderNo",
                        string.IsNullOrEmpty(txtRefWorkOrderNo.Text.Trim()) ? (object)DBNull.Value : txtRefWorkOrderNo.Text.Trim());

                    // Date fields (procedure এ ব্যবহার না হলেও পাঠাতে হবে, কারণ parameter mandatory)
                    cmd.Parameters.AddWithValue("@iSdate", cktilldateshow.Checked);

                    cmd.Parameters.AddWithValue("@FormDate",
                        string.IsNullOrEmpty(txtFormDate.Text.Trim()) ? (object)DBNull.Value : Convert.ToDateTime(txtFormDate.Text.Trim()));

                    cmd.Parameters.AddWithValue("@TillDate",
                        string.IsNullOrEmpty(txtTillDate.Text.Trim()) ? (object)DBNull.Value : Convert.ToDateTime(txtTillDate.Text.Trim()));

                    cmd.Parameters.AddWithValue("@DeliveryDate",
                        string.IsNullOrEmpty(txtdeliveryDated.Text.Trim()) ? (object)DBNull.Value : Convert.ToDateTime(txtdeliveryDated.Text.Trim()));

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }
                }

                gvWorkOrderReceive.DataSource = dt;
                gvWorkOrderReceive.DataBind();
            }
            catch
            {
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) con.Close();
            }

        }

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

        // ★ FIX: parameterized query — SQL Injection ঝুঁকি দূর করা হয়েছে
        private void LoadUnit()
        {
            string a = gvSizeDetails.SelectedDataKey.Value.ToString();
            txtQuotationNo.Text = a;
            try
            {
                string sql = @"SELECT ta_ItemName.ItemID, tbl_UnitSetup.UnitID, tbl_UnitSetup.UnitName
                    FROM ta_ItemName INNER JOIN tbl_UnitSetup ON ta_ItemName.Unit = tbl_UnitSetup.UnitName 
                    WHERE ta_ItemName.ItemID = @ItemID";
                con = conn.openConnection();
                cmd = new SqlCommand(sql, con);
                cmd.Parameters.AddWithValue("@ItemID", ddlItemNameDetails.SelectedValue);
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        txtItemUnit.Text = reader["Unit"].ToString();
                    }
                }
                else
                {
                    //txtCategoryId.Text = txtCategory.Text = string.Empty;
                }
                reader.Close();
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

        // ★ NEW: Rate Unit dropdown লোড করার মেথড (item-নির্ভর না, পুরো ইউনিট লিস্ট)
        private void LoadRateUnit()
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT * FROM CurrencyMaster ORDER BY CurrencyCode";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlRateUnit.DataSource = dt;
                    ddlRateUnit.DataTextField = "CurrencyCode";
                    ddlRateUnit.DataValueField = "CurrencyID";
                    ddlRateUnit.DataBind();

                    ddlRateUnit.Items.Insert(0, new ListItem("--Select Currency--", "0"));
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
        private void LoadPartyList()
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

                    ddlCustomerListPage.DataSource = dt;
                    ddlCustomerListPage.DataTextField = "PartyName";
                    ddlCustomerListPage.DataValueField = "PartyID";
                    ddlCustomerListPage.DataBind();

                    ddlCustomerListPage.Items.Insert(0, new ListItem("--Select Party Name--", "0"));
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

        private void BindWorkOrderList()
        {
            try
            {
                con = conn.openConnection();
                string query = @"SELECT WorkOrderHeader.WORcvID, WorkOrderHeader.WORcvNo,WorkOrderHeader.WOStatus, WorkOrderHeader.WORcvDate, WorkOrderHeader.DeliveryDate, WorkOrderHeader.GrandTotal, tbl_CustomerSupplier.PartyName,WorkOrderHeader.RefWorkOrderNo
                                    FROM WorkOrderHeader INNER JOIN tbl_CustomerSupplier ON WorkOrderHeader.CustomerID = tbl_CustomerSupplier.PartyID
                                  WHERE IsActive = 1
                                  ORDER BY WORcvNo DESC";
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

        #region ---------- Autocomplete Suggestion WebMethods ----------

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
                                  FROM techdefendersbd.vw_BuyerInformation 
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
                                  FROM techdefendersbd.Style_Master 
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
                                  FROM techdefendersbd.tbl_POEntryInformation 
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

        #region ---------- List Panel Row Commands ----------

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
                    using (SqlCommand cmd = new SqlCommand(
                        "UPDATE techdefendersbd.WorkOrderHeader SET IsActive = 0 WHERE WORcvNo = @WORcvNo", con))
                    {
                        cmd.Parameters.AddWithValue("@WORcvNo", arg);
                        cmd.ExecuteNonQuery();
                    }
                    ShowMessage("Work Order Deleted Successfully!", "success");
                    //BindWorkOrderList();
                    ShowWODetailsdata();
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
            else if (e.CommandName == "ReportViewWithAmount")
            {
                string url = ResolveUrl($"~/TrimsAccessories/EstimationCostings/OrdersReports/ReceivedOrdersReportsWithAmount.aspx?WORcvID={arg}");
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
                            ddlWOStatus.SelectedItem.Text= reader["WOStatus"].ToString();
                        }
                    }
                }
                ShowWODetailsdata();
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

        #region ---------- Size-wise Variant Entry ----------

        protected void btnAddSize_Click(object sender, EventArgs e)
        {
            SqlConnection con = null;
            try
            {
                con = conn.openConnection();
                using (SqlCommand cmd = new SqlCommand("Sp_InsertWorkOrderHeader", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@WORcvNo", SqlDbType.NVarChar).Value = txtWoRef.Text;
                    cmd.Parameters.Add("@WORcvDate", SqlDbType.Date).Value = Convert.ToDateTime(txtWoDate.Text);
                    cmd.Parameters.Add("@DeliveryDate", SqlDbType.Date).Value = Convert.ToDateTime(txtDeliveryDate.Text);
                    cmd.Parameters.Add("@CustomerID", SqlDbType.Int).Value = string.IsNullOrEmpty(ddlCustomerName.SelectedValue) ? 0 : Convert.ToInt32(ddlCustomerName.SelectedValue);
                    cmd.Parameters.Add("@ReceivingBranchID", SqlDbType.Int).Value = string.IsNullOrEmpty(ddlReceivingBranch.SelectedValue) ? 0 : Convert.ToInt32(ddlReceivingBranch.SelectedValue);
                    cmd.Parameters.Add("@RefWorkOrderNo", SqlDbType.NVarChar).Value = string.IsNullOrEmpty(txtWoNoDetails.Text) ? "0" : txtWoNoDetails.Text;
                    cmd.Parameters.Add("@QuotationNo", SqlDbType.NVarChar).Value = string.IsNullOrEmpty(txtQuotationNo.Text) ? "0" : txtQuotationNo.Text;
                    cmd.Parameters.Add("@SubTotalAmount", SqlDbType.Decimal).Value = string.IsNullOrEmpty(txtSubTotalAmount.Text) ? 0 : Convert.ToDecimal(txtSubTotalAmount.Text);
                    cmd.Parameters.Add("@TransportCost", SqlDbType.Decimal).Value = string.IsNullOrEmpty(txtTransportCost.Text) ? 0 : Convert.ToDecimal(txtTransportCost.Text);
                    cmd.Parameters.Add("@VatPercent", SqlDbType.Decimal).Value = string.IsNullOrEmpty(txtVatPercent.Text) ? 0 : Convert.ToDecimal(txtVatPercent.Text);
                    cmd.Parameters.Add("@GrandTotal", SqlDbType.Decimal).Value = string.IsNullOrEmpty(txtGrandTotalAmount.Text) ? 0 : Convert.ToDecimal(txtGrandTotalAmount.Text);
                    cmd.Parameters.Add("@WOStatus", SqlDbType.NVarChar).Value = string.IsNullOrEmpty(ddlWOStatus.SelectedItem.Text) ? "0" : ddlWOStatus.SelectedItem.Text;
                    
                    cmd.Parameters.Add("@DetailsID", SqlDbType.NVarChar).Value = string.IsNullOrEmpty(txtItemsEntryID.Text) ? "0" : txtItemsEntryID.Text;
                    cmd.Parameters.Add("@Buyer", SqlDbType.NVarChar).Value = string.IsNullOrEmpty(txtBuyer.Text) ? "0" : txtBuyer.Text;
                    cmd.Parameters.Add("@Style", SqlDbType.NVarChar).Value = string.IsNullOrEmpty(txtStyle.Text) ? "0" : txtStyle.Text;
                    cmd.Parameters.Add("@PO", SqlDbType.NVarChar).Value = string.IsNullOrEmpty(txtOrderNo.Text) ? "0" : txtOrderNo.Text;
                    cmd.Parameters.Add("@ItemName", SqlDbType.NVarChar).Value = string.IsNullOrEmpty(ddlItemNameDetails.SelectedItem.Text) ? "0" : ddlItemNameDetails.SelectedItem.Text;
                    cmd.Parameters.Add("@ItemDescription", SqlDbType.NVarChar).Value = string.IsNullOrEmpty(TextBox1.Text) ? "0" : TextBox1.Text;
                    cmd.Parameters.Add("@ColorName", SqlDbType.NVarChar).Value = string.IsNullOrEmpty(DropDownList1.SelectedItem.Text) ? "0" : DropDownList1.SelectedItem.Text;
                    cmd.Parameters.Add("@Size", SqlDbType.NVarChar).Value = string.IsNullOrEmpty(txtSize.Text) ? "0" : txtSize.Text;
                    cmd.Parameters.Add("@Measurement", SqlDbType.NVarChar).Value = string.IsNullOrEmpty(txtMeasurement.Text) ? "0" : txtMeasurement.Text; 
                    cmd.Parameters.Add("@ReqQty", SqlDbType.Decimal).Value = string.IsNullOrEmpty(txtReqQty.Text) ? 0 : Convert.ToDecimal(txtReqQty.Text);
                    cmd.Parameters.Add("@Unit", SqlDbType.NVarChar).Value = string.IsNullOrEmpty(txtItemUnit.Text) ? "0" : txtItemUnit.Text;
                    cmd.Parameters.Add("@RateUnit", SqlDbType.Decimal).Value = string.IsNullOrEmpty(txtRate.Text) ? 0 : Convert.ToDecimal(txtRate.Text);
                    cmd.Parameters.Add("@ExtraPercent", SqlDbType.Decimal).Value = string.IsNullOrEmpty(txtExtraPercent.Text) ? 0 : Convert.ToDecimal(txtExtraPercent.Text);
                    cmd.Parameters.Add("@TotalReqQty", SqlDbType.Decimal).Value = string.IsNullOrEmpty(txtTotalReqQtyInput.Text) ? 0 : Convert.ToDecimal(txtTotalReqQtyInput.Text);
                    cmd.Parameters.Add("@TotalAmount", SqlDbType.Decimal).Value = string.IsNullOrEmpty(txtTotalAmountInput.Text) ? 0 : Convert.ToDecimal(txtTotalAmountInput.Text);
                    cmd.Parameters.Add("@Remarks", SqlDbType.NVarChar).Value = string.IsNullOrEmpty(txtSizeRemarks.Text) ? "0" : txtSizeRemarks.Text; 
                    cmd.Parameters.Add("@JobNo", SqlDbType.NVarChar).Value = string.IsNullOrEmpty(txtJobNo.Text) ? "0" : txtJobNo.Text; 
                    cmd.Parameters.Add("@RateUnitName", SqlDbType.NVarChar).Value = string.IsNullOrEmpty(ddlRateUnit.SelectedItem.Text) ? "0" : ddlRateUnit.SelectedItem.Text;

                    cmd.ExecuteNonQuery();
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Draft Save Successfully!');", true);
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open)
                    con.Close();
            }
            ShowWODetailsdata();
            txtItemsEntryID.Text = string.Empty;
        }

        private void ShowWODetailsdata()
        {
            try
            {
                con = conn.openConnection();
                string query = @"SELECT WorkOrderHeader.WORcvNo, WorkOrderDetails.WorkOrderDetailsID, WorkOrderDetails.JobNo,WorkOrderDetails.Buyer, WorkOrderDetails.Style, WorkOrderDetails.PO, WorkOrderDetails.ItemName, WorkOrderDetails.ItemDescription, 
                                WorkOrderDetails.ColorName, WorkOrderDetails.Size, WorkOrderDetails.Measurement, WorkOrderDetails.ReqQty, WorkOrderDetails.Unit, WorkOrderDetails.RateUnit, WorkOrderDetails.RateUnitName, 
                                WorkOrderDetails.ExtraPercent, WorkOrderDetails.TotalReqQty, WorkOrderDetails.TotalAmount, WorkOrderDetails.Remarks
                                FROM WorkOrderDetails INNER JOIN WorkOrderHeader ON WorkOrderDetails.WORcvID = WorkOrderHeader.WORcvID
                            WHERE WorkOrderHeader.WORcvNo = @WORcvNo";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@WORcvNo", txtWoRef.Text);

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    gvSizeDetails.DataSource = dt;
                    gvSizeDetails.DataBind();
                }
            }
            catch (Exception ex)
            {
                gvSizeDetails.DataSource = null;
                gvSizeDetails.DataBind();
                ShowMessage("List Load Error: " + ex.Message, "warning");
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) con.Close();
            }
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
            decimal.TryParse(txtExtraPercent.Text, out decimal extraPercentVal); // ★ FIX: এন্ট্রি রো-এর Extra % এখন পড়া হচ্ছে

            int.TryParse(ddlItemNameDetails.SelectedValue, out int selectedItemID);
            int.TryParse(DropDownList1.SelectedValue, out int selectedColorID);
            string selectedItemName = ddlItemNameDetails.SelectedItem?.Text ?? string.Empty;
            string selectedColorName = (selectedColorID > 0 && DropDownList1.SelectedItem != null)
                ? DropDownList1.SelectedItem.Text
                : string.Empty;
            if (selectedColorID <= 0) selectedColorID = 0;

            string selectedUnitName = txtItemUnit.Text ?? string.Empty;

            // ★ Rate Unit নাম সংগ্রহ
            string selectedRateUnitName = (ddlRateUnit.SelectedValue != "0" && ddlRateUnit.SelectedItem != null)
                ? ddlRateUnit.SelectedItem.Text
                : string.Empty;

            string buyer = txtBuyer.Text.Trim();
            string style = txtStyle.Text.Trim();
            string po = txtOrderNo.Text.Trim();
            string itemDescription = TextBox1.Text.Trim();
            string jobNo = txtJobNo.Text.Trim();

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

                    // ★ FIX: TotalReqQty ও TotalAmount আগে থেকেই ক্যালকুলেট করা হচ্ছে,
                    // যাতে "Add All Size" দিয়ে অ্যাড করা রো-গুলোও সাথে সাথেই
                    // Section 4 (Sub Total / Grand Total) সামারিতে সঠিকভাবে যোগ হয়।
                    decimal totalReqQty = RequiresQtyVal + (RequiresQtyVal * (extraPercentVal / 100m));
                    decimal totalAmount = totalReqQty * rateVal;

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
                            JobNo = jobNo,
                            Buyer = buyer,
                            Style = style,
                            PO = po,
                            ItemDescription = itemDescription,
                            ColorID = selectedColorID,
                            ColorName = selectedColorName,
                            Size = sizeName,
                            Measurement = string.Empty,
                            ReqQty = RequiresQtyVal,
                            Unit = selectedUnitName,
                            RateUnit = rateVal,
                            RateUnitName = selectedRateUnitName,
                            ExtraPercent = extraPercentVal,        // ★ FIX: আগে হার্ডকোড 0 ছিল
                            TotalReqQty = totalReqQty,             // ★ FIX: আগে হার্ডকোড 0 ছিল
                            TotalAmount = totalAmount,             // ★ FIX: আগে হার্ডকোড 0 ছিল
                            Remarks = string.Empty
                        });
                    }
                    SizeList = list;
                }

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

            ShowFormPanel();
        }
        #endregion

        #region ---------- Grand Total Summary ----------



        protected void txtTransportCost_TextChanged(object sender, EventArgs e)
        {
            ShowFormPanel();
        }

        protected void txtVatPercent_TextChanged(object sender, EventArgs e)
        {
            ShowFormPanel();
        }

        #endregion

        #region ---------- Bottom Action Buttons ----------

        protected void btnSave_Click(object sender, EventArgs e)
        {
            SqlConnection con = null;
            try
            {
                con = conn.openConnection();
                using (SqlCommand cmd = new SqlCommand("Sp_InsertWorkOrderHeaderSubmit", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@WORcvNo", SqlDbType.NVarChar).Value = txtWoRef.Text;

                    cmd.ExecuteNonQuery();
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Submit & Save Successfully!');", true);
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open)
                    con.Close();
            }

            txtWoRef.Text = GenerateNextWorkOrderRef();
            ClearFormFields();
            ShowWorkOrderList();


            pnlDetails.Visible = false;
            pnlList.Visible = true;
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {           

            txtWoRef.Text = GenerateNextWorkOrderRef();
            ClearFormFields();
            ShowWorkOrderList();
        }
        #endregion

        private void ClearFormFields()
        {
            // হেডার ফিল্ডস ক্লিয়ার করা
            //txtWoRef.Text = "WO-2026-0001"; // অটো জেনারেটেড কোড থাকলে ডিফল্ট রাখতে পারেন
            txtWoDate.Text = string.Empty;
            txtDeliveryDate.Text = string.Empty;
            txtWoNoDetails.Text = string.Empty;
            txtQuotationNo.Text = string.Empty;

            if (ddlCustomerName.Items.Count > 0) ddlCustomerName.SelectedIndex = 0;
            if (ddlReceivingBranch.Items.Count > 0) ddlReceivingBranch.SelectedIndex = 0;

            // আইটেম এন্ট্রি রো ফিল্ডস ক্লিয়ার করা
            txtJobNo.Text = string.Empty;
            txtBuyer.Text = string.Empty;
            txtStyle.Text = string.Empty;
            txtOrderNo.Text = string.Empty;
            TextBox1.Text = string.Empty; // Items Description
            txtRate.Text = string.Empty;
            txtSize.Text = string.Empty;
            txtReqQty.Text = "0";
            txtItemUnit.Text = string.Empty;
            txtExtraPercent.Text = "0";
            txtTotalReqQtyInput.Text = "0.00";
            txtTotalAmountInput.Text = "0.00";
            txtMeasurement.Text = string.Empty;
            txtSizeRemarks.Text = string.Empty;
            txtItemsEntryID.Text = string.Empty;

            if (ddlItemNameDetails.Items.Count > 0) ddlItemNameDetails.SelectedIndex = 0;
            if (DropDownList1.Items.Count > 0) DropDownList1.SelectedIndex = 0;
            if (ddlRateUnit.Items.Count > 0) ddlRateUnit.SelectedIndex = 0;

            // সামারি ফিল্ডস ক্লিয়ার করা
            txtSubTotalAmount.Text = "0.00";
            txtTransportCost.Text = "0.00";
            txtVatPercent.Text = "0.00";
            txtGrandTotalAmount.Text = "0.00";

            // গ্রিডভিউ খালি করা (যদি চান)
            gvSizeDetails.DataSource = null;
            gvSizeDetails.DataBind();

            pnlDetails.Visible = false;
            pnlList.Visible = true;
        }



        #region ---------- UI Feedback ----------
        private void ShowFormPanel()
        {
            pnlDetails.Visible = true;
            pnlList.Visible = false;
            //ScriptManager.RegisterStartupScript(this, this.GetType(), "ShowFormPanel", "showPanel('pnlForm');", true);
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

        // ★ NEW: Rate Unit dropdown-এর জন্য আলাদা, সঠিক রিফ্রেশ হ্যান্ডলার
        protected void LinkButton2_Click(object sender, EventArgs e)
        {
            LoadRateUnit();
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

        protected void txtBuyer_TextChanged(object sender, EventArgs e)
        {

        }

        protected void txtStyle_TextChanged(object sender, EventArgs e)
        {

        }

        protected void txtOrderNo_TextChanged(object sender, EventArgs e)
        {

        }

        protected void cktilldateshow_CheckedChanged(object sender, EventArgs e)
        {
            if (cktilldateshow.Checked == true)
            {
                txtTillDate.Visible = true;
            }
            else
            { 
                txtTillDate.Visible = false; 
            }
        }

        protected void btnShow_Click(object sender, EventArgs e)
        {
            ShowWorkOrderList();
        }

        protected void gvSizeDetails_SelectedIndexChanged(object sender, EventArgs e)
        {
            txtItemsEntryID.Text = gvSizeDetails.SelectedDataKey.Value.ToString();
            try
            {
                string sql = "SELECT * FROM WorkOrderDetails WHERE WorkOrderDetailsID = @WorkOrderDetailsID";
                con = conn.openConnection();
                cmd = new SqlCommand(sql, con);
                cmd.Parameters.AddWithValue("@WorkOrderDetailsID", txtItemsEntryID.Text);
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        txtJobNo.Text = reader["JobNo"].ToString();
                        txtBuyer.Text = reader["Buyer"].ToString();
                        txtStyle.Text = reader["Style"].ToString();
                        txtOrderNo.Text = reader["PO"].ToString();
                        ddlItemNameDetails.SelectedItem.Text = reader["ItemName"].ToString();
                        TextBox1.Text = reader["ItemDescription"].ToString();
                        DropDownList1.SelectedItem.Text = reader["ColorName"].ToString();
                        txtRate.Text = reader["RateUnit"].ToString();
                        ddlRateUnit.SelectedItem.Text = reader["RateUnitName"].ToString();
                        txtSize.Text = reader["Size"].ToString();
                        txtReqQty.Text = reader["ReqQty"].ToString();
                        txtItemUnit.Text = reader["Unit"].ToString();
                        txtExtraPercent.Text = reader["ExtraPercent"].ToString();
                        txtTotalReqQtyInput.Text = reader["TotalReqQty"].ToString();
                        txtTotalAmountInput.Text = reader["TotalAmount"].ToString();
                        txtMeasurement.Text = reader["Measurement"].ToString();
                        txtSizeRemarks.Text = reader["Remarks"].ToString();
                    }
                }
                else
                {
                    //txtCategoryId.Text = txtCategory.Text = string.Empty;
                }
                reader.Close();
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

        protected void chksizeGroupEnable_CheckedChanged(object sender, EventArgs e)
        {
            if (chksizeGroupEnable.Checked == true)
            {
                txtSize.Visible = false;
                ddlsizeGroup.Visible = true;
                btnAddAllsize.Enabled = true;
                btnAddSize.Enabled = false;
            }
            else
            {
                txtSize.Visible = true;
                ddlsizeGroup.Visible = false;
                btnAddAllsize.Enabled = false;
                btnAddSize.Enabled = true;
            }
        }

        protected void BtnAddNew_Click(object sender, EventArgs e)
        {

            ShowFormPanel();
            // হেডার ফিল্ডস ক্লিয়ার করা
            //txtWoRef.Text = "WO-2026-0001"; // অটো জেনারেটেড কোড থাকলে ডিফল্ট রাখতে পারেন
            txtWoDate.Text = string.Empty;
            txtDeliveryDate.Text = string.Empty;
            txtWoNoDetails.Text = string.Empty;
            txtQuotationNo.Text = string.Empty;

            if (ddlCustomerName.Items.Count > 0) ddlCustomerName.SelectedIndex = 0;
            if (ddlReceivingBranch.Items.Count > 0) ddlReceivingBranch.SelectedIndex = 0;

            // আইটেম এন্ট্রি রো ফিল্ডস ক্লিয়ার করা
            txtJobNo.Text = string.Empty;
            txtBuyer.Text = string.Empty;
            txtStyle.Text = string.Empty;
            txtOrderNo.Text = string.Empty;
            TextBox1.Text = string.Empty; // Items Description
            txtRate.Text = string.Empty;
            txtSize.Text = string.Empty;
            txtReqQty.Text = "0";
            txtItemUnit.Text = string.Empty;
            txtExtraPercent.Text = "0";
            txtTotalReqQtyInput.Text = "0.00";
            txtTotalAmountInput.Text = "0.00";
            txtMeasurement.Text = string.Empty;
            txtSizeRemarks.Text = string.Empty;
            txtItemsEntryID.Text = string.Empty;

            if (ddlItemNameDetails.Items.Count > 0) ddlItemNameDetails.SelectedIndex = 0;
            if (DropDownList1.Items.Count > 0) DropDownList1.SelectedIndex = 0;
            if (ddlRateUnit.Items.Count > 0) ddlRateUnit.SelectedIndex = 0;

            // সামারি ফিল্ডস ক্লিয়ার করা
            txtSubTotalAmount.Text = "0.00";
            txtTransportCost.Text = "0.00";
            txtVatPercent.Text = "0.00";
            txtGrandTotalAmount.Text = "0.00";

            // গ্রিডভিউ খালি করা (যদি চান)
            gvSizeDetails.DataSource = null;
            gvSizeDetails.DataBind();
        }

        protected void Button2_Click(object sender, EventArgs e)
        {
            pnlDetails.Visible = false;
            pnlList.Visible = true;
        }

        protected void ddlsizeGroup_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

        protected void gvSizeList_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

        protected void gvSizeList_RowDataBound(object sender, GridViewRowEventArgs e)
        {

        }
    }
}