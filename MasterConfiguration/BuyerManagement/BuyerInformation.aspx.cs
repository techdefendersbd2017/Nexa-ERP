using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.MerchandisingMarketing.MerchandisingConfiguration
{
    public partial class BuyerInformation : System.Web.UI.Page
    {
        SqlConnection con;
        Database_Connection conn = new Database_Connection();
        SqlCommand cmd;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadCountries();
                LoadBuyerInformation();
            }
        }

        // 1. Country DropDown List Load
        private void LoadCountries()
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT CountryID, CountryName FROM CountryInformation ORDER BY CountryName";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlCountry.DataSource = dt;
                    ddlCountry.DataTextField = "CountryName";
                    ddlCountry.DataValueField = "CountryID";
                    ddlCountry.DataBind();

                    ddlCountry.Items.Insert(0, new ListItem("--Select Country--", "0"));
                }
                con.Close();
            }
            catch (Exception ex)
            {
                Response.Write("Error: " + ex.Message);
            }
        }

        // 2. GridView Data Load & Search
        private void LoadBuyerInformation()
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT BuyerID, BuyerCode, BuyerName FROM BuyerInformation WHERE 1=1";

                if (!string.IsNullOrEmpty(txtSearchBuyer.Text.Trim()))
                {
                    query += " AND BuyerName LIKE @BuyerName";
                }

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    if (!string.IsNullOrEmpty(txtSearchBuyer.Text.Trim()))
                    {
                        cmd.Parameters.AddWithValue("@BuyerName", "%" + txtSearchBuyer.Text.Trim() + "%");
                    }

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    gvBuyer.DataSource = dt;
                    gvBuyer.DataBind();
                }
                con.Close();
            }
            catch (Exception ex)
            {
                Response.Write("Error: " + ex.Message);
            }
        }

        // 3. Save / Update Button Click Event (Using Stored Procedure)
        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                con = conn.openConnection();
                using (SqlCommand cmd = new SqlCommand("sp_SaveUpdateBuyerInformation", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    // ViewState ব্যবহার করে চেক করা হচ্ছে এটি Insert নাকি Update
                    int buyerId = ViewState["BuyerID"] != null ? Convert.ToInt32(ViewState["BuyerID"]) : 0;

                    cmd.Parameters.Add("@BuyerID", SqlDbType.Int).Value = buyerId == 0 ? (object)DBNull.Value : buyerId;
                    cmd.Parameters.Add("@BuyerCode", SqlDbType.VarChar).Value = txtBuyerCode.Text.Trim();
                    cmd.Parameters.Add("@BuyerName", SqlDbType.VarChar).Value = txtBuyerName.Text.Trim();
                    cmd.Parameters.Add("@DisplayName", SqlDbType.VarChar).Value = txtDisplayName.Text.Trim();
                    cmd.Parameters.Add("@Currency", SqlDbType.VarChar).Value = txtCurrency.Text.Trim();
                    cmd.Parameters.Add("@ContactNo", SqlDbType.VarChar).Value = txtContact.Text.Trim();
                    cmd.Parameters.Add("@Email", SqlDbType.VarChar).Value = txtEmail.Text.Trim();
                    cmd.Parameters.Add("@CountryID", SqlDbType.Int).Value = Convert.ToInt32(ddlCountry.SelectedValue);
                    cmd.Parameters.Add("@Address", SqlDbType.VarChar).Value = txtAddress.Text.Trim();
                    cmd.Parameters.Add("@IsActive", SqlDbType.Bit).Value = chkActive.Checked;
                    cmd.Parameters.Add("@IsLocal", SqlDbType.Bit).Value = chkLocal.Checked;

                    cmd.ExecuteNonQuery();

                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Save Successfully!');", true);
                }
                con.Close();

                ClearForm();
                LoadBuyerInformation();
            }
            catch (Exception ex)
            {
                if (con.State == ConnectionState.Open) con.Close();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
        }

        // 4. GridView Selection for Editing / Loading Data
        protected void gvBuyer_SelectedIndexChanged(object sender, EventArgs e)
        {
            try
            {
                string buyerId = gvBuyer.SelectedRow.Cells[1].Text;
                ViewState["BuyerID"] = buyerId;

                string sql = "SELECT * FROM BuyerInformation WHERE BuyerID = @BuyerID";
                con = conn.openConnection();
                cmd = new SqlCommand(sql, con);
                cmd.Parameters.AddWithValue("@BuyerID", buyerId);

                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        ViewState["BuyerID"] = reader["BuyerID"].ToString();
                        txtBuyerCode.Text = reader["BuyerCode"].ToString();
                        txtBuyerName.Text = reader["BuyerName"].ToString();
                        txtDisplayName.Text = reader["DisplayName"].ToString();
                        txtCurrency.Text = reader["Currency"].ToString();
                        txtContact.Text = reader["ContactNo"].ToString();
                        txtEmail.Text = reader["Email"].ToString();
                        ddlCountry.SelectedValue = reader["CountryID"] != DBNull.Value ? reader["CountryID"].ToString() : "0";
                        txtAddress.Text = reader["Address"].ToString();
                        chkActive.Checked = reader["IsActive"] != DBNull.Value && Convert.ToBoolean(reader["IsActive"]);
                        chkLocal.Checked = reader["IsLocal"] != DBNull.Value && Convert.ToBoolean(reader["IsLocal"]);
                    }
                }
                else
                {
                    ClearForm();
                }
                con.Close();
            }
            catch (Exception ex)
            {
                if (con.State == ConnectionState.Open) con.Close();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
        }

        // 5. Clear Form Method
        private void ClearForm()
        {
            txtBuyerCode.Text = string.Empty;
            txtBuyerName.Text = string.Empty;
            txtDisplayName.Text = string.Empty;
            txtCurrency.Text = string.Empty;
            txtContact.Text = string.Empty;
            txtEmail.Text = string.Empty;
            ddlCountry.SelectedIndex = 0;
            txtAddress.Text = string.Empty;
            chkActive.Checked = false;
            chkLocal.Checked = false;
            ViewState["BuyerID"] = null;
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ClearForm();
        }

        // 6. Search Button Event
        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadBuyerInformation();
        }
    }
}