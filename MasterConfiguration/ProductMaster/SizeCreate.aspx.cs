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
    public partial class SizeCreate : System.Web.UI.Page
    {
        SqlConnection con;
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();
        SqlCommand cmd;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadSizeGroupDropdown();
                LoadSizeInformation();
                LoadSizeGroupList();
            }
        }

        // সাইজ গ্রুপ ড্রপডাউন লোড করার জন্য
        private void LoadSizeGroupDropdown()
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT GroupID, GroupName FROM SizeGroups ORDER BY GroupName ASC";
                SqlDataAdapter da = new SqlDataAdapter(query, con);
                DataTable dt = new DataTable();
                da.Fill(dt);

                ddlSizeGroup.DataSource = dt;
                ddlSizeGroup.DataTextField = "GroupName";
                ddlSizeGroup.DataValueField = "GroupID";
                ddlSizeGroup.DataBind();
                ddlSizeGroup.Items.Insert(0, new ListItem("--Select Group--", "0"));
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "\\'") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) { con.Close(); }
            }
        }

        // সাইজ ইনফরমেশন গ্রিডভিউতে লোড করার জন্য
        private void LoadSizeInformation()
        {
            try
            {
                con = conn.openConnection();
                string query = @"SELECT s.SizeID, g.GroupName, s.SizeName, 
                                 'Active' AS Status 
                                 FROM Sizes s 
                                 INNER JOIN SizeGroups g ON s.GroupID = g.GroupID  where s.GroupID ='"+ddlSizeGroup.SelectedValue+ "' ORDER BY g.GroupName,s.SizeID ASC";
                SqlDataAdapter da = new SqlDataAdapter(query, con);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvSizes.DataSource = dt;
                gvSizes.DataBind();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "\\'") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) { con.Close(); }
            }
        }

        // সাইজ গ্রুপ লিস্ট গ্রিডভিউতে লোড করার জন্য
        private void LoadSizeGroupList()
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT GroupID, GroupName FROM SizeGroups ORDER BY GroupName ASC";
                SqlDataAdapter da = new SqlDataAdapter(query, con);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvSizeGroups.DataSource = dt;
                gvSizeGroups.DataBind();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "\\'") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) { con.Close(); }
            }
        }

        // ফর্মের ইনপুট ফিল্ডগুলো পরিষ্কার করার জন্য
        private void clearform()
        {
            txtSizeId.Text = txtSizeName.Text = txtGroupName.Text = string.Empty;
            // Hidden Field-গুলো ক্লিয়ার করার জন্য যদি থাকে
            ViewState["GroupID"] = null;

            if (ddlSizeGroup.Items.Count > 0)
                ddlSizeGroup.SelectedValue = "0";
            if (ddlStatus != null && ddlStatus.Items.Count > 0)
                ddlStatus.SelectedValue = "Active";
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            clearform();
        }

        // সাইজ গ্রুপ সেভ অথবা আপডেট করার জন্য
        protected void btnSaveGroup_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(txtGroupName.Text.Trim()))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Please enter group name!');", true);
                return;
            }

            try
            {
                con = conn.openConnection();
                using (SqlCommand cmd = new SqlCommand("sp_SaveSizeGroup", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    // যদি এডিট করার সময় GroupID থাকে, তবে আপডেট হবে; না থাকলে নতুন সেভ হবে
                    object groupId = ViewState["GroupID"] != null ? ViewState["GroupID"] : (object)DBNull.Value;
                    cmd.Parameters.AddWithValue("@GroupID", groupId);
                    cmd.Parameters.AddWithValue("@GroupName", txtGroupName.Text.Trim());

                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            string message = rdr["Message"].ToString();
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + message + "');", true);
                        }
                    }
                    clearform();
                    LoadSizeGroupDropdown();
                    LoadSizeGroupList();
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error: " + ex.Message.Replace("'", "\\'") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) { con.Close(); }
            }
        }

        // সাইজ সেভ করার জন্য
        protected void btnSaveSize_Click(object sender, EventArgs e)
        {
            if (ddlSizeGroup.SelectedValue == "0")
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Please select a size group!');", true);
                return;
            }

            if (string.IsNullOrEmpty(txtSizeName.Text.Trim()))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Please enter size name!');", true);
                return;
            }

            try
            {
                con = conn.openConnection();
                using (SqlCommand cmd = new SqlCommand("sp_SaveSize", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@SizeID", string.IsNullOrEmpty(txtSizeId.Text) ? (object)DBNull.Value : Convert.ToInt32(txtSizeId.Text));
                    cmd.Parameters.AddWithValue("@SizeName", txtSizeName.Text.Trim());
                    cmd.Parameters.AddWithValue("@GroupID", Convert.ToInt32(ddlSizeGroup.SelectedValue));

                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            string message = rdr["Message"].ToString();
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + message + "');", true);
                        }
                    }
                    LoadSizeInformation();
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error: " + ex.Message.Replace("'", "\\'") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) { con.Close(); }
            }
        }

        // সাইজ এডিট করার জন্য সিলেকশন
        protected void gvSizes_SelectedIndexChanged(object sender, EventArgs e)
        {
            txtSizeId.Text = gvSizes.SelectedRow.Cells[0].Text;
            try
            {
                string sql = "SELECT SizeID, SizeName, GroupID FROM Sizes WHERE SizeID = @SizeID";
                con = conn.openConnection();
                cmd = new SqlCommand(sql, con);
                cmd.Parameters.AddWithValue("@SizeID", txtSizeId.Text);

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.HasRows)
                    {
                        while (reader.Read())
                        {
                            ddlSizeGroup.SelectedValue = reader["GroupID"].ToString();
                            txtSizeName.Text = reader["SizeName"].ToString();
                        }
                    }
                    else
                    {
                        clearform();
                    }
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "\\'") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) { con.Close(); }
            }
        }

        // সাইজ গ্রুপ এডিট করার জন্য সিলেকশন (নতুন যুক্ত করা হয়েছে)
        protected void gvSizeGroups_SelectedIndexChanged(object sender, EventArgs e)
        {
            string groupId = gvSizeGroups.SelectedRow.Cells[0].Text;
            ViewState["GroupID"] = groupId; // আপডেট করার জন্য ID সেভ করে রাখা হলো

            try
            {
                string sql = "SELECT GroupID, GroupName FROM SizeGroups WHERE GroupID = @GroupID";
                con = conn.openConnection();
                cmd = new SqlCommand(sql, con);
                cmd.Parameters.AddWithValue("@GroupID", groupId);

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.HasRows)
                    {
                        while (reader.Read())
                        {
                            txtGroupName.Text = reader["GroupName"].ToString();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "\\'") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) { con.Close(); }
            }
        }

        protected void ddlSizeGroup_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadSizeInformation();
        }
    }
}