using Nexa_ERP.Connection;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.ERPConfiguration.CompanyInformation
{
    public partial class CustomerSupplier : System.Web.UI.Page
    {
        SqlConnection con;
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();
        SqlCommand cmd;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadPartyInformation();
            }
        }

        private void LoadPartyInformation()
        {
            try
            {
                con = conn.openConnection();
                // PartyType কে টেক্সট আকারে দেখানোর জন্য CASE ব্যবহার করা হয়েছে 
                string query = @"SELECT PartyID, ROW_NUMBER() OVER(ORDER BY PartyID) AS SlNo, 
                                 CASE PartyType 
                                     WHEN 1 THEN 'Customer' 
                                     WHEN 2 THEN 'Supplier' 
                                     WHEN 3 THEN 'Both' 
                                     ELSE 'Unknown' 
                                 END AS PartyType, 
                                 PartyName, Phone, Status 
                                 FROM tbl_CustomerSupplier 
                                 ORDER BY PartyName ASC";

                SqlDataAdapter da = new SqlDataAdapter(query, con);
                DataTable dt = new DataTable();
                da.Fill(dt);

                gvParty.DataSource = dt;
                gvParty.DataBind();
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
            txtPartyID.Text = string.Empty;
            ddlPartyType.SelectedIndex = 0;
            txtPartyName.Text = string.Empty;
            txtContactPerson.Text = string.Empty;
            txtPhone.Text = string.Empty;
            txtEmail.Text = string.Empty;
            txtAddress.Text = string.Empty;
            ddlStatus.SelectedValue = "Active";
            btnSave.Text = "Save";
        }

        protected void gvParty_SelectedIndexChanged(object sender, EventArgs e)
        {
            string partyId = gvParty.SelectedDataKey.Value.ToString();
            txtPartyID.Text = partyId;

            try
            {
                string sql = "SELECT * FROM tbl_CustomerSupplier WHERE PartyID = @PartyID";
                con = conn.openConnection();
                cmd = new SqlCommand(sql, con);
                cmd.Parameters.AddWithValue("@PartyID", partyId);

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.HasRows)
                    {
                        while (reader.Read())
                        {
                            ddlPartyType.SelectedValue = reader["PartyType"].ToString();
                            txtPartyName.Text = reader["PartyName"].ToString();
                            txtContactPerson.Text = reader["ContactPerson"].ToString();
                            txtPhone.Text = reader["Phone"].ToString();
                            txtEmail.Text = reader["Email"].ToString();
                            txtAddress.Text = reader["Address"].ToString();
                            ddlStatus.SelectedValue = reader["Status"].ToString();
                            btnSave.Text = "Update";
                            break;
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
                if (con != null && con.State == ConnectionState.Open)
                {
                    con.Close();
                }
            }
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
                using (SqlCommand cmd = new SqlCommand("sp_CustomerSupplier_SaveUpdate", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    int partyId = 0;
                    if (!string.IsNullOrEmpty(txtPartyID.Text.Trim()))
                    {
                        int.TryParse(txtPartyID.Text.Trim(), out partyId);
                    }

                    cmd.Parameters.AddWithValue("@PartyID", partyId == 0 ? (object)DBNull.Value : partyId);
                    cmd.Parameters.AddWithValue("@PartyType", Convert.ToInt32(ddlPartyType.SelectedValue));
                    cmd.Parameters.AddWithValue("@PartyName", txtPartyName.Text.Trim());
                    cmd.Parameters.AddWithValue("@ContactPerson", string.IsNullOrEmpty(txtContactPerson.Text.Trim()) ? (object)DBNull.Value : txtContactPerson.Text.Trim());
                    cmd.Parameters.AddWithValue("@Phone", string.IsNullOrEmpty(txtPhone.Text.Trim()) ? (object)DBNull.Value : txtPhone.Text.Trim());
                    cmd.Parameters.AddWithValue("@Email", string.IsNullOrEmpty(txtEmail.Text.Trim()) ? (object)DBNull.Value : txtEmail.Text.Trim());
                    cmd.Parameters.AddWithValue("@Address", string.IsNullOrEmpty(txtAddress.Text.Trim()) ? (object)DBNull.Value : txtAddress.Text.Trim());
                    cmd.Parameters.AddWithValue("@Status", ddlStatus.SelectedValue);

                    cmd.ExecuteNonQuery();

                    if (partyId == 0)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Party Saved Successfully!');", true);
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Party Updated Successfully!');", true);
                    }

                    clearform();
                    LoadPartyInformation();
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
        }
    }
}