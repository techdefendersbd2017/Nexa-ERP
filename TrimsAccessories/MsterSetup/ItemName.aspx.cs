using Nexa_ERP.Connection;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.TrimsAccessories.MsterSetup
{
    public partial class ItemName : System.Web.UI.Page
    {
        SqlConnection con;
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();
        SqlCommand cmd;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadCategoryDropdown();
                LoadUnitDropdown();
                LoadItemList();
            }
        }

        // ১. ক্যাটেগরি ড্রপডাউন লোড করা
        private void LoadCategoryDropdown()
        {
            try
            {
                con = conn.openConnection();
                string sql = "SELECT CategoryID, CategoryName FROM ta_ItemCategory WHERE Status = 'Active' ORDER BY CategoryName ASC";
                SqlDataAdapter da = new SqlDataAdapter(sql, con);
                DataTable dt = new DataTable();
                da.Fill(dt);

                ddlItemCategory.DataSource = dt;
                ddlItemCategory.DataTextField = "CategoryName";
                ddlItemCategory.DataValueField = "CategoryID";
                ddlItemCategory.DataBind();
                ddlItemCategory.Items.Insert(0, new ListItem("--Select Item Category--", "0"));
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

        // ২. সাব-ক্যাটেগরি ড্রপডাউন লোড করা (ক্যাটেগরি সিলেক্ট করার পর)
        protected void ddlItemCategory_SelectedIndexChanged(object sender, EventArgs e)
        {
            ddlSubCategory.Items.Clear();
            ddlSubCategory.Items.Insert(0, new ListItem("--Select Sub Category--", "0"));

            int categoryId = 0;
            int.TryParse(ddlItemCategory.SelectedValue, out categoryId);
            if (categoryId <= 0) return;

            try
            {
                con = conn.openConnection();
                string sql = "SELECT SubCategoryID, SubCategoryName FROM ta_SubCategory WHERE Status = 'Active' AND CategoryID = @CategoryID ORDER BY SubCategoryName ASC";
                SqlCommand cmd = new SqlCommand(sql, con);
                cmd.Parameters.AddWithValue("@CategoryID", categoryId);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                if (dt.Rows.Count > 0)
                {
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

        // ৩. ইউনিট ড্রপডাউন লোড করা (স্ট্যাটিক লিস্ট — Unit master table থাকলে DB থেকে বাইন্ড করুন)
        private void LoadUnitDropdown()
        {
            ddlUnit.Items.Clear();
            ddlUnit.Items.Add(new ListItem("--Select Unit--", "0"));
            ddlUnit.Items.Add(new ListItem("Pcs", "Pcs"));
            ddlUnit.Items.Add(new ListItem("Kg", "Kg"));
            ddlUnit.Items.Add(new ListItem("Meter", "Meter"));
            ddlUnit.Items.Add(new ListItem("Yard", "Yard"));
            ddlUnit.Items.Add(new ListItem("Dozen", "Dozen"));
            ddlUnit.Items.Add(new ListItem("Box", "Box"));
            ddlUnit.Items.Add(new ListItem("Set", "Set"));
        }

        // ৪. আইটেম লিস্ট গ্রিডভিউতে লোড করা
        private void LoadItemList()
        {
            try
            {
                con = conn.openConnection();
                string sql = @"SELECT i.ItemID, c.CategoryName, s.SubCategoryName, i.ItemName, i.Unit, i.Status
                                FROM ta_ItemName i
                                LEFT JOIN ta_ItemCategory c ON i.CategoryID = c.CategoryID
                                LEFT JOIN ta_SubCategory s ON i.SubCategoryID = s.SubCategoryID
                                ORDER BY i.ItemID DESC";
                SqlDataAdapter da = new SqlDataAdapter(sql, con);
                DataTable dt = new DataTable();
                da.Fill(dt);

                gvItemName.DataSource = dt;
                gvItemName.DataBind();
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

        // ৫. ফরম খালি করা
        private void ClearForm()
        {
            txtItemID.Text = string.Empty;
            txtItemName.Text = string.Empty;
            ddlItemCategory.SelectedValue = "0";
            ddlSubCategory.Items.Clear();
            ddlSubCategory.Items.Insert(0, new ListItem("--Select Sub Category--", "0"));
            ddlItemsType.SelectedValue = "0";
            ddlUnit.SelectedValue = "0";
            ddlStatus.SelectedValue = "Active";
            gvItemName.SelectedIndex = -1;
        }

        // ৬. গ্রিডভিউ থেকে এডিট করার জন্য সিলেক্ট ইভেন্ট
        protected void gvItemName_SelectedIndexChanged(object sender, EventArgs e)
        {
            string itemId = gvItemName.SelectedRow.Cells[0].Text;

            try
            {
                con = conn.openConnection();
                string sql = "SELECT * FROM ta_ItemName WHERE ItemID = @ItemID";
                SqlCommand cmd = new SqlCommand(sql, con);
                cmd.Parameters.AddWithValue("@ItemID", Convert.ToInt32(itemId));

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        txtItemID.Text = reader["ItemID"].ToString();
                        string categoryId = reader["CategoryID"].ToString();
                        string subCategoryId = reader["SubCategoryID"].ToString();
                        txtItemName.Text = reader["ItemName"].ToString();
                        string unit = reader["Unit"].ToString();
                        string status = reader["Status"].ToString();

                        reader.Close(); // রিডার ক্লোজ করে ড্রপডাউন সেট করা হচ্ছে

                        ddlItemCategory.SelectedValue = categoryId;
                        con.Close();

                        // ক্যাটেগরি সিলেক্ট হওয়ার পর সংশ্লিষ্ট সাব-ক্যাটেগরি লোড করা
                        ddlItemCategory_SelectedIndexChanged(null, null);
                        ddlSubCategory.SelectedValue = subCategoryId;

                        ddlUnit.SelectedValue = unit;
                        ddlStatus.SelectedValue = status;
                    }
                    else
                    {
                        ClearForm();
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

        // ৭. রিফ্রেশ / ক্যান্সেল বাটন
        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            ClearForm();
            LoadItemList();
        }

        // ৮. সেভ / আপডেট বাটন
        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(txtItemName.Text.Trim()) || ddlItemCategory.SelectedValue == "0")
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Please select Category and enter Item Name.');", true);
                return;
            }

            try
            {
                con = conn.openConnection();
                using (SqlCommand cmd = new SqlCommand("techdefendersbd.sp_ta_InsertUpdate_ItemName", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    int itemId = 0;
                    int.TryParse(txtItemID.Text.Trim(), out itemId);

                    cmd.Parameters.AddWithValue("@ItemID", itemId == 0 ? (object)DBNull.Value : itemId);
                    cmd.Parameters.AddWithValue("@CategoryID", Convert.ToInt32(ddlItemCategory.SelectedValue));
                    cmd.Parameters.AddWithValue("@SubCategoryID", Convert.ToInt32(ddlSubCategory.SelectedValue));
                    cmd.Parameters.AddWithValue("@ItemName", txtItemName.Text.Trim());
                    cmd.Parameters.AddWithValue("@Unit", ddlUnit.SelectedValue == "0" ? (object)DBNull.Value : ddlUnit.SelectedValue);
                    cmd.Parameters.AddWithValue("@Status", ddlStatus.SelectedValue);

                    cmd.ExecuteNonQuery();

                    if (itemId == 0)
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Item Saved Successfully!');", true);
                    else
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Item Updated Successfully!');", true);
                }

                ClearForm();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error: " + ex.Message.Replace("'", "\\'") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) con.Close();
            }

            LoadItemList();
        }
    }
}