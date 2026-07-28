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

namespace Nexa_ERP.TrimsAccessories.MsterSetup
{
    public partial class RawMaterial : System.Web.UI.Page
    {
        SqlConnection con;
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();
        SqlCommand cmd;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadRawMaterialInformation();
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

        private void LoadRawMaterialInformation()
        {
            try
            {
                con = conn.openConnection();
                {
                    SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM ta_RawMaterial Order by RawMaterialName asc", con);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    gvRawMaterial.DataSource = dt;
                    gvRawMaterial.DataBind();
                }
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

        private void clearform()
        {
            txtRawMaterialId.Text = txtMaterialCode.Text = txtRawMaterialName.Text = txtUnitPrice.Text = string.Empty;
            ddlUnit.SelectedValue = "Pcs";
            ddlCurrency.SelectedValue = "BDT";
            ddlStatus.SelectedValue = "Active";
        }

        protected void gvRawMaterial_SelectedIndexChanged(object sender, EventArgs e)
        {
            txtRawMaterialId.Text = gvRawMaterial.SelectedRow.Cells[0].Text.Trim();
            try
            {

                string sql = "Select * from ta_RawMaterial where RawMaterialID = '" + txtRawMaterialId.Text + "'";
                con = conn.openConnection();
                cmd = new SqlCommand(sql, con);
                SqlDataReader reader = cmd.ExecuteReader();

                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        txtMaterialCode.Text = reader["MaterialCode"].ToString();
                        txtRawMaterialName.Text = reader["RawMaterialName"].ToString();
                        ddlUnit.SelectedValue = reader["Unit"].ToString();
                        txtUnitPrice.Text = reader["UnitPrice"].ToString();
                        ddlCurrency.SelectedValue = reader["Currency"].ToString();
                        ddlStatus.SelectedValue = reader["Status"].ToString();
                    }
                }
                else
                {
                    clearform();
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

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            clearform();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                con = conn.openConnection();
                using (SqlCommand cmd = new SqlCommand("sp_ta_InsertUpdate_RawMaterial", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    int rawMaterialId = 0;
                    if (!string.IsNullOrEmpty(txtRawMaterialId.Text.Trim()))
                    {
                        int.TryParse(txtRawMaterialId.Text.Trim(), out rawMaterialId);
                    }

                    cmd.Parameters.AddWithValue("@RawMaterialID", rawMaterialId == 0 ? (object)DBNull.Value : rawMaterialId);
                    cmd.Parameters.AddWithValue("@MaterialCode", string.IsNullOrEmpty(txtMaterialCode.Text.Trim()) ? (object)DBNull.Value : txtMaterialCode.Text.Trim());
                    cmd.Parameters.AddWithValue("@RawMaterialName", string.IsNullOrEmpty(txtRawMaterialName.Text.Trim()) ? (object)DBNull.Value : txtRawMaterialName.Text.Trim());
                    cmd.Parameters.AddWithValue("@Unit", ddlUnit.SelectedValue);
                    cmd.Parameters.AddWithValue("@UnitPrice", string.IsNullOrEmpty(txtUnitPrice.Text.Trim()) ? 0.00m : Convert.ToDecimal(txtUnitPrice.Text.Trim()));
                    cmd.Parameters.AddWithValue("@Currency", ddlCurrency.SelectedValue);
                    cmd.Parameters.AddWithValue("@Status", ddlStatus.SelectedValue);

                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            string actionResult = rdr["ActionType"].ToString();
                            string newId = rdr["ResultID"].ToString();

                            if (actionResult == "Inserted")
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Raw Material Saved Successfully! ID: " + newId + "');", true);
                            }
                            else if (actionResult == "Updated")
                            {
                                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Raw Material Updated Successfully!');", true);
                            }
                        }
                    }

                    clearform();
                    LoadRawMaterialInformation();
                }
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