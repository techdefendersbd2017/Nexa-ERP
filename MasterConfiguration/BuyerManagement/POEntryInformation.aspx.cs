using Nexa_ERP.Connection;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.MerchandisingMarketing.OrderInformation
{
    public partial class POEntryInformation : System.Web.UI.Page
    {
        SqlConnection con;
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadBuyerDropdown();
                LoadPOList();
            }
        }

        // ==========================================
        // LOAD DROPDOWNS
        // ==========================================
        private void LoadBuyerDropdown()
        {
            try
            {
                con = conn.openConnection();
                string query = @"SELECT BuyerID, BuyerName FROM vw_BuyerInformation WHERE IsActive = 1 ORDER BY BuyerName ASC";
                SqlDataAdapter da = new SqlDataAdapter(query, con);
                DataTable dt = new DataTable();
                da.Fill(dt);

                ddlBuyer.DataSource = dt;
                ddlBuyer.DataTextField = "BuyerName";
                ddlBuyer.DataValueField = "BuyerID";
                ddlBuyer.DataBind();
                ddlBuyer.Items.Insert(0, new ListItem("--Select Buyer--", ""));
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

        // Style_Master -এ Style, BuyerID দিয়ে না বরং BuyerName (text) দিয়ে লিংকড,
        // তাই এখানে Buyer-এর Name অনুযায়ী Style ফিল্টার করা হচ্ছে।
        private void LoadStyleDropdown()
        {
            try
            {
                con = conn.openConnection();
                string query = @"SELECT StyleId, StyleName 
                                  FROM  Style_Master 
                                  WHERE BuyerName = @BuyerName AND IsActive = 1 
                                  ORDER BY StyleName ASC";
                using (SqlCommand cmdStyle = new SqlCommand(query, con))
                {
                    cmdStyle.Parameters.AddWithValue("@BuyerName", ddlBuyer.SelectedValue);
                    SqlDataAdapter da = new SqlDataAdapter(cmdStyle);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlStyle.DataSource = dt;
                    ddlStyle.DataTextField = "StyleName";
                    ddlStyle.DataValueField = "StyleId";
                    ddlStyle.DataBind();
                    ddlStyle.Items.Insert(0, new ListItem("--Select Style--", ""));
                }
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

        private void ClearStyleDropdown()
        {
            ddlStyle.DataSource = null;
            ddlStyle.DataBind();
            ddlStyle.Items.Insert(0, new ListItem("--Select Style--", ""));
        }

        protected void ddlBuyer_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(ddlBuyer.SelectedValue))
            {
                LoadStyleDropdown();
            }
            else
            {
                ClearStyleDropdown();
            }
        }

        protected void ddlStyle_SelectedIndexChanged(object sender, EventArgs e)
        {
            // বর্তমানে আলাদা কোনো লজিক দরকার নেই; aspx-এ handler রেফারেন্স আছে বলে রাখা হলো
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
        // PO LIST
        // ==========================================
        private void LoadPOList()
        {
            try
            {
                con = conn.openConnection();
                string query = @"SELECT p.POId, b.BuyerName, s.StyleName, p.PONumber, p.OrderQty, p.ShipmentDate
                                  FROM tbl_POEntryInformation p
                                  LEFT JOIN [nexamar].[techdefendersbd].[vw_BuyerInformation] b ON p.BuyerID = b.BuyerID
                                  LEFT JOIN [nexamar].[techdefendersbd].[Style_Master] s ON p.StyleId = s.StyleId
                                  WHERE p.Status = 'Active'
                                  ORDER BY p.POId DESC";
                SqlDataAdapter da = new SqlDataAdapter(query, con);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvPOList.DataSource = dt;
                gvPOList.DataBind();
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "\\'") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open)
                {
                    con.Close();
                }
            }
        }

        protected void gvPOList_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "EditPO")
            {
                string poId = e.CommandArgument.ToString();
                LoadPOForEdit(poId);
            }
        }

        private void LoadPOForEdit(string poId)
        {
            try
            {
                con = conn.openConnection();
                string query = @"SELECT POId, BuyerID, StyleId, PONumber, OrderQty, ShipmentDate 
                                  FROM tbl_POEntryInformation 
                                  WHERE POId = @POId";
                using (SqlCommand cmdEdit = new SqlCommand(query, con))
                {
                    cmdEdit.Parameters.AddWithValue("@POId", poId);
                    using (SqlDataReader reader = cmdEdit.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            txtPOID.Text = reader["POId"].ToString();

                            string buyerId = reader["BuyerID"].ToString();
                            SetSelectedValueSafe(ddlBuyer, buyerId);

                            // Buyer সিলেক্ট হওয়ার পর সেই Buyer-এর Style লিস্ট লোড করে
                            // তারপর সংশ্লিষ্ট StyleId সিলেক্ট করা হচ্ছে।
                            if (!string.IsNullOrEmpty(ddlBuyer.SelectedValue))
                            {
                                LoadStyleDropdown();
                                SetSelectedValueSafe(ddlStyle, reader["StyleId"].ToString());
                            }

                            txtPONumber.Text = reader["PONumber"].ToString();
                            txtOrderQty.Text = reader["OrderQty"].ToString();
                            txtShipmentDate.Text = Convert.ToDateTime(reader["ShipmentDate"]).ToString("yyyy-MM-dd");

                            btnSave.Text = "Update";
                        }
                    }
                }
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error loading PO: " + ex.Message.Replace("'", "\\'") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open)
                {
                    con.Close();
                }
            }
        }

        // ==========================================
        // SAVE / CLEAR
        // ==========================================
        private void clearform()
        {
            txtPOID.Text = string.Empty;
            ddlBuyer.SelectedValue = "";
            ClearStyleDropdown();
            txtPONumber.Text = string.Empty;
            txtOrderQty.Text = string.Empty;
            txtShipmentDate.Text = string.Empty;
            btnSave.Text = "Save";
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            clearform();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(ddlBuyer.SelectedValue))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Please select a Buyer!');", true);
                return;
            }
            if (string.IsNullOrEmpty(ddlStyle.SelectedValue))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Please select a Style!');", true);
                return;
            }
            if (string.IsNullOrEmpty(txtPONumber.Text.Trim()))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Please enter the PO / Order No!');", true);
                return;
            }
            if (!decimal.TryParse(txtOrderQty.Text.Trim(), out decimal orderQty) || orderQty <= 0)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Please enter a valid Order Quantity!');", true);
                return;
            }
            if (!DateTime.TryParse(txtShipmentDate.Text.Trim(), out DateTime shipmentDate))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Please enter a valid Shipment Date!');", true);
                return;
            }

            try
            {
                con = conn.openConnection();
                using (SqlCommand cmd = new SqlCommand("sp_InsertUpdate_POEntryInformation", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    int poId = 0;
                    if (!string.IsNullOrEmpty(txtPOID.Text.Trim()))
                    {
                        int.TryParse(txtPOID.Text.Trim(), out poId);
                    }

                    int currentUserId = Session["UserID"] != null ? Convert.ToInt32(Session["UserID"]) : 0;

                    cmd.Parameters.AddWithValue("@POId", poId == 0 ? (object)DBNull.Value : poId);
                    cmd.Parameters.AddWithValue("@BuyerID", Convert.ToInt32(ddlBuyer.SelectedValue));
                    cmd.Parameters.AddWithValue("@StyleId", Convert.ToInt32(ddlStyle.SelectedValue));
                    cmd.Parameters.AddWithValue("@PONumber", txtPONumber.Text.Trim());
                    cmd.Parameters.AddWithValue("@OrderQty", orderQty);
                    cmd.Parameters.AddWithValue("@ShipmentDate", shipmentDate);
                    cmd.Parameters.AddWithValue("@Status", "Active");
                    cmd.Parameters.AddWithValue("@UserID", currentUserId == 0 ? (object)DBNull.Value : currentUserId);

                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            string actionResult = rdr["ActionType"].ToString();
                            string newId = rdr["ResultID"].ToString();

                            if (actionResult == "Inserted")
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('PO Saved Successfully! ID: " + newId + "');", true);
                            }
                            else if (actionResult == "Updated")
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('PO Updated Successfully!');", true);
                            }
                        }
                    }
                }
                clearform();
                LoadPOList();
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
    }
}
