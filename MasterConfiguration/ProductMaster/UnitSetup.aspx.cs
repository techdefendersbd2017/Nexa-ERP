using Nexa_ERP.Connection;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.ERPConfiguration.CompanyInformation
{
    public partial class UnitSetup : System.Web.UI.Page
    {
        SqlConnection con;
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();
        SqlCommand cmd;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadUnitInformation();
            }
        }

        // Unit লিস্ট গ্রিডভিউতে লোড করা (আগে ভুলবশত Raw Material ডেটা লোড হচ্ছিল)
        private void LoadUnitInformation()
        {
            try
            {
                con = conn.openConnection();
                string query = @"SELECT UnitID, UnitName, ShortCode, Status 
                                  FROM tbl_UnitSetup 
                                  ORDER BY UnitName ASC";

                SqlDataAdapter da = new SqlDataAdapter(query, con);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvRawMaterial.DataSource = dt;
                gvRawMaterial.DataBind();
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert",
                    "alert('" + ex.Message.Replace("'", "\\'") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open)
                {
                    con.Close();
                }
            }
        }

        private void ClearForm()
        {
            txtUnitID.Text = string.Empty;
            txtUnitName.Text = string.Empty;
            txtShortCode.Text = string.Empty;
            ddlStatus.SelectedValue = "Active";
            btnSave.Text = "Save";
            gvRawMaterial.SelectedIndex = -1;
        }

        // NOTE: renamed to match the markup's OnSelectedIndexChanged="gvRawMaterial_SelectedIndexChanged"
        protected void gvRawMaterial_SelectedIndexChanged(object sender, EventArgs e)
        {
            string unitId = gvRawMaterial.SelectedDataKey.Value.ToString();
            txtUnitID.Text = unitId;

            try
            {
                string sql = "SELECT * FROM tbl_UnitSetup WHERE UnitID = @UnitID";
                con = conn.openConnection();
                cmd = new SqlCommand(sql, con);
                cmd.Parameters.AddWithValue("@UnitID", unitId);

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.HasRows)
                    {
                        while (reader.Read())
                        {
                            txtUnitName.Text = reader["UnitName"].ToString();
                            txtShortCode.Text = reader["ShortCode"].ToString();
                            ddlStatus.SelectedValue = reader["Status"].ToString();
                            btnSave.Text = "Update";
                            break;
                        }
                    }
                    else
                    {
                        ClearForm();
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
            ClearForm();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(txtUnitName.Text.Trim()))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Please enter Unit Name.');", true);
                return;
            }

            try
            {
                con = conn.openConnection();
                using (SqlCommand cmd = new SqlCommand("sp_UnitSetup_SaveUpdate", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    int unitId = 0;
                    if (!string.IsNullOrEmpty(txtUnitID.Text.Trim()))
                    {
                        int.TryParse(txtUnitID.Text.Trim(), out unitId);
                    }

                    cmd.Parameters.AddWithValue("@UnitID", unitId == 0 ? (object)DBNull.Value : unitId);
                    cmd.Parameters.AddWithValue("@UnitName", txtUnitName.Text.Trim());
                    cmd.Parameters.AddWithValue("@ShortCode", string.IsNullOrEmpty(txtShortCode.Text.Trim()) ? (object)DBNull.Value : txtShortCode.Text.Trim());
                    cmd.Parameters.AddWithValue("@Status", ddlStatus.SelectedValue);

                    cmd.ExecuteNonQuery();

                    if (unitId == 0)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Unit Saved Successfully!');", true);
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Unit Updated Successfully!');", true);
                    }

                    ClearForm();
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

            LoadUnitInformation();
        }

        protected void txtUnitName_TextChanged(object sender, EventArgs e)
        {
            string unitName = txtUnitName.Text.Trim().ToUpper();
            txtUnitName.Text = unitName;
            txtShortCode.Text = unitName;
        }
        // Unit লিস্ট গ্রিডভিউতে লোড করা (সার্চ প্যারামিটার সহ)
        private void LoadUnitInformation(string searchKeyword = "")
        {
            try
            {
                con = conn.openConnection();
                string query = @"SELECT UnitID, UnitName, ShortCode, Status 
                                  FROM tbl_UnitSetup 
                                  WHERE (@Search = '' OR UnitName LIKE '%' + @Search + '%' OR ShortCode LIKE '%' + @Search + '%')
                                  ORDER BY UnitName ASC";

                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@Search", searchKeyword);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvRawMaterial.DataSource = dt;
                gvRawMaterial.DataBind();
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert",
                    "alert('" + ex.Message.Replace("'", "\\'") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open)
                {
                    con.Close();
                }
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadUnitInformation(txtSearch.Text.Trim());
        }

        protected void txtSearch_TextChanged(object sender, EventArgs e)
        {
            LoadUnitInformation(txtSearch.Text.Trim());
        }
    }
}
