using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
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
                LoadItemNameInformation();
                loadUnit();
            }
        }
        private void loadUnit()
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT * FROM tbl_UnitSetup WHERE Status='Active' ORDER BY UnitName ASC";
                SqlDataAdapter da = new SqlDataAdapter(query, con);
                DataTable dt = new DataTable();
                da.Fill(dt);

                ddlUnit.DataSource = dt;
                ddlUnit.DataTextField = "UnitName";
                ddlUnit.DataValueField = "UnitID";
                ddlUnit.DataBind();
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

        private void LoadCategoryDropdown()
        {
            try
            {
                con = conn.openConnection();
                SqlDataAdapter da = new SqlDataAdapter("SELECT CategoryID, CategoryName FROM ta_ItemCategory WHERE Status='Active' ORDER BY CategoryName ASC", con);
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

        protected void ddlItemCategory_SelectedIndexChanged(object sender, EventArgs e)
        {
            try
            {
                int catId = Convert.ToInt32(ddlItemCategory.SelectedValue);

                // নিজস্ব using ব্লক ব্যবহার করার ফলে ডেটাবেস রিডার বা কমান্ড স্বয়ংক্রিয়ভাবে ক্লোজ হয়ে যাবে
                using (SqlConnection localCon = conn.openConnection())
                {
                    using (SqlCommand localCmd = new SqlCommand("SELECT SubCategoryID, SubCategoryName FROM ta_SubCategory WHERE CategoryID = @CatID AND Status = 'Active'", localCon))
                    {
                        localCmd.Parameters.AddWithValue("@CatID", catId);
                        using (SqlDataAdapter da = new SqlDataAdapter(localCmd))
                        {
                            DataTable dt = new DataTable();
                            da.Fill(dt);

                            ddlSubCategory.DataSource = dt;
                            ddlSubCategory.DataTextField = "SubCategoryName";
                            ddlSubCategory.DataValueField = "SubCategoryID";
                            ddlSubCategory.DataBind();
                            ddlSubCategory.Items.Insert(0, new ListItem("--Select Sub Category--", "0"));
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
        }

        private void LoadItemNameInformation()
        {
            try
            {
                con = conn.openConnection();
                string query = @"SELECT i.ItemID, c.CategoryName, s.SubCategoryName, i.ItemName, i.Unit, i.Status 
                                 FROM ta_ItemName i
                                 INNER JOIN ta_ItemCategory c ON i.CategoryID = c.CategoryID
                                 INNER JOIN ta_SubCategory s ON i.SubCategoryID = s.SubCategoryID
                                 ORDER BY i.ItemName ASC";
                SqlDataAdapter da = new SqlDataAdapter(query, con);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvItemName.DataSource = dt;
                gvItemName.DataBind();
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "\\'") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) con.Close();
            }
        }

        private void clearform()
        {
            txtItemID.Text = txtItemName.Text = string.Empty;
            ddlItemCategory.SelectedValue = "0";
            ddlSubCategory.Items.Clear();
            ddlSubCategory.Items.Insert(0, new ListItem("--Select Sub Category--", "0"));
            ddlUnit.SelectedValue = "Pcs";
            ddlStatus.SelectedValue = "Active";
        }

        protected void gvItemName_SelectedIndexChanged(object sender, EventArgs e)
        {
            txtItemID.Text = gvItemName.SelectedRow.Cells[0].Text;
            try
            {
                string sql = "Select * from ta_ItemName where ItemID = '" + txtItemID.Text + "'";
                con = conn.openConnection();
                cmd = new SqlCommand(sql, con);

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.HasRows)
                    {
                        while (reader.Read())
                        {
                            string catId = reader["CategoryID"].ToString();
                            string subCatId = reader["SubCategoryID"].ToString();

                            txtItemName.Text = reader["ItemName"].ToString();
                            ddlUnit.SelectedValue = reader["Unit"].ToString();
                            ddlStatus.SelectedValue = reader["Status"].ToString();

                            // রিডার বন্ধ করার আগেই কানেকশন বা রিডার নিয়ে যেন সমস্যা না হয়, 
                            // তাই রিডার রিড করার পর ক্যাটেগরি ও সাব-ক্যাটেগরি ভ্যালু সেট করা হলো
                            reader.Close(); // রিডারটি এখানে ক্লোজ করে দেওয়া হলো

                            ddlItemCategory.SelectedValue = catId;
                            ddlItemCategory_SelectedIndexChanged(sender, e); // সাব-ক্যাটেগরি ড্রপডাউন লোড হবে
                            ddlSubCategory.SelectedValue = subCatId;        // সাব-ক্যাটেগরি সিলেক্ট হবে

                            break; // যেহেতু আইডি দিয়ে একটিই রেকর্ড আসবে, তাই লুপ ব্রেক করা ভালো
                        }
                    }
                    else
                    {
                        clearform();
                    }
                }
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
            finally
            {
                if (con != null && con.State == System.Data.ConnectionState.Open)
                {
                    con.Close();
                }
            }
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            clearform();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                con = conn.openConnection();
                using (SqlCommand cmd = new SqlCommand("sp_ta_InsertUpdate_ItemName", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    int itemId = 0;
                    if (!string.IsNullOrEmpty(txtItemID.Text.Trim()))
                    {
                        int.TryParse(txtItemID.Text.Trim(), out itemId);
                    }

                    cmd.Parameters.AddWithValue("@ItemID", itemId == 0 ? (object)DBNull.Value : itemId);
                    cmd.Parameters.AddWithValue("@CategoryID", Convert.ToInt32(ddlItemCategory.SelectedValue));
                    cmd.Parameters.AddWithValue("@SubCategoryID", Convert.ToInt32(ddlSubCategory.SelectedValue));
                    cmd.Parameters.AddWithValue("@ItemName", string.IsNullOrEmpty(txtItemName.Text.Trim()) ? (object)DBNull.Value : txtItemName.Text.Trim());
                    cmd.Parameters.AddWithValue("@Unit", ddlUnit.SelectedValue);
                    cmd.Parameters.AddWithValue("@Status", ddlStatus.SelectedValue);

                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            string actionResult = rdr["ActionType"].ToString();
                            string newId = rdr["ResultID"].ToString();

                            if (actionResult == "Inserted")
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Item Name Saved Successfully! ID: " + newId + "');", true);
                            }
                            else if (actionResult == "Updated")
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Item Name Updated Successfully!');", true);
                            }
                        }
                    }
                    clearform();
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
            LoadItemNameInformation();
        }
    }
}