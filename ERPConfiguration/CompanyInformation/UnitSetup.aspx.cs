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
                LoadRawMaterialInformation();
            }
        }

        private void LoadRawMaterialInformation()
        {
            try
            {
                con = conn.openConnection();
                // UnitSetup টেবিলের সাথে JOIN করে UnitName নিয়ে আসা হচ্ছে
                string query = @"SELECT r.*, u.UnitName 
                         FROM ta_RawMaterial r 
                         LEFT JOIN tbl_UnitSetup u ON r.Unit = u.UnitID 
                         ORDER BY r.RawMaterialName ASC";

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
        }

        protected void gvUnit_SelectedIndexChanged(object sender, EventArgs e)
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
        }
    }
}