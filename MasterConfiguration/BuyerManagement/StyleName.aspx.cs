using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.MerchandisingMarketing.OrderInformation
{
    public partial class StyleName : System.Web.UI.Page
    {
        SqlConnection con;
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();
        SqlCommand cmd;
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadBuyerDropdown();
                LoadStyleNameInformation();
            }
        }
        // ১. বায়ার ড্রপডাউন লোড করার মেথড
        private void LoadBuyerDropdown()
        {
            try
            {
                con = conn.openConnection();
                SqlDataAdapter da = new SqlDataAdapter("SELECT BuyerID, BuyerName FROM vw_BuyerInformation WHERE IsActive=1 ORDER BY BuyerName ASC", con);
                DataTable dt = new DataTable();
                da.Fill(dt);

                ddlBuyer.DataSource = dt;
                ddlBuyer.DataTextField = "BuyerName";
                ddlBuyer.DataValueField = "BuyerID";
                ddlBuyer.DataBind();
                ddlBuyer.Items.Insert(0, new ListItem("--Select Buyer--", "0"));
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

        // ২. স্টাইল লিস্ট গ্রিডভিউতে লোড করার মেথড
        private void LoadStyleNameInformation()
        {
            try
            {
                con = conn.openConnection();
                string query = @"SELECT s.StyleId, b.BuyerName, s.StyleName, s.ArticleNo, s.IsActive 
                                 FROM Style_Master s 
                                 INNER JOIN vw_BuyerInformation b ON s.BuyerName = b.BuyerID 
                                 ORDER BY s.StyleName ASC";
                SqlDataAdapter da = new SqlDataAdapter(query, con);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvStyleList.DataSource = dt;
                gvStyleList.DataBind();
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

        // ৩. ফরম খালি বা রিফ্রেশ করার মেথড
        private void clearform()
        {
            txtStyleID.Text = txtStyleName.Text = txtArticleNo.Text = string.Empty;
            ddlBuyer.SelectedValue = "0";
            gvStyleList.SelectedIndex = -1;
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            clearform();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                con = conn.openConnection();
                using (SqlCommand cmd = new SqlCommand("Sp_SaveUpdate_StyleMaster", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    int styleId = 0;
                    if (!string.IsNullOrEmpty(txtStyleID.Text.Trim()))
                    {
                        int.TryParse(txtStyleID.Text.Trim(), out styleId);
                    }

                    cmd.Parameters.AddWithValue("@StyleId", styleId == 0 ? (object)DBNull.Value : styleId);
                    cmd.Parameters.AddWithValue("@BuyerName", Convert.ToInt32(ddlBuyer.SelectedValue));
                    cmd.Parameters.AddWithValue("@StyleName", string.IsNullOrEmpty(txtStyleName.Text.Trim()) ? (object)DBNull.Value : txtStyleName.Text.Trim());
                    cmd.Parameters.AddWithValue("@ArticleNo", string.IsNullOrEmpty(txtArticleNo.Text.Trim()) ? (object)DBNull.Value : txtArticleNo.Text.Trim());

                    cmd.ExecuteNonQuery();

                    if (styleId == 0)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Style Saved Successfully!');", true);
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Style Updated Successfully!');", true);
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
            LoadStyleNameInformation();
        }

        protected void gvStyleList_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "EditStyle")
            {
                try
                {
                    string styleId = e.CommandArgument.ToString();
                    txtStyleID.Text = styleId;

                    string query = "SELECT * FROM Style_Master WHERE StyleId = @StyleId";
                    con = conn.openConnection();
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@StyleId", styleId);

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                string buyerId = reader["BuyerName"].ToString();
                                txtStyleName.Text = reader["StyleName"] != DBNull.Value ? reader["StyleName"].ToString() : string.Empty;
                                txtArticleNo.Text = reader["ArticleNo"] != DBNull.Value ? reader["ArticleNo"].ToString() : string.Empty;

                                ListItem item = ddlBuyer.Items.FindByValue(buyerId);
                                ddlBuyer.SelectedValue = item != null ? buyerId : "0";
                            }
                        }
                    }
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
            }
        }

        protected void gvStyleList_SelectedIndexChanged(object sender, EventArgs e)
        {
            //txtStyleID.Text = gvStyleList.SelectedRow.Cells[0].Text;
        }
    }
}