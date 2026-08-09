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
                SqlDataAdapter da = new SqlDataAdapter(@"SELECT ta_RawMaterial.RawMaterialID, ta_RawMaterial.MaterialCode, ta_RawMaterial.RawMaterialName, tbl_UnitSetup.UnitID, 
                tbl_UnitSetup.UnitName, ta_RawMaterial.UnitPrice, ta_RawMaterial.Currency, ta_RawMaterial.Status, ta_RawMaterial.CreatedDate, ta_RawMaterial.ItemCategory, 
                ta_RawMaterial.Length, ta_RawMaterial.Width, ta_RawMaterial.Thickness, ta_RawMaterial.DimensionUnit, ta_RawMaterial.Density, ta_RawMaterial.Concentration, 
                ta_RawMaterial.PhValue FROM ta_RawMaterial INNER JOIN tbl_UnitSetup ON ta_RawMaterial.Unit = tbl_UnitSetup.UnitID Order by RawMaterialName asc", con);
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

        private void clearform()
        {
            txtRawMaterialId.Text = txtMaterialCode.Text = txtRawMaterialName.Text = txtUnitPrice.Text = string.Empty;
            txtLength.Text = txtWidth.Text = txtThickness.Text = txtDensity.Text = txtConcentration.Text = txtPhValue.Text = string.Empty;

            ddlItemCategory.SelectedValue = "General";
            pnlGeneralFields.Visible = true;
            pnlLiquidFields.Visible = false;

            if (ddlUnit.Items.Count > 0) ddlUnit.SelectedIndex = 0;
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

                        // Item Category & Dynamic Fields Handling
                        string itemCategory = reader["ItemCategory"] != DBNull.Value ? reader["ItemCategory"].ToString() : "General";
                        ddlItemCategory.SelectedValue = itemCategory;

                        if (itemCategory == "Liquid")
                        {
                            pnlLiquidFields.Visible = true;
                            pnlGeneralFields.Visible = false;

                            txtDensity.Text = reader["Density"].ToString();
                            txtConcentration.Text = reader["Concentration"].ToString();
                            txtPhValue.Text = reader["PhValue"].ToString();
                        }
                        else
                        {
                            pnlLiquidFields.Visible = false;
                            pnlGeneralFields.Visible = true;

                            txtLength.Text = reader["Length"].ToString();
                            txtWidth.Text = reader["Width"].ToString();
                            txtThickness.Text = reader["Thickness"].ToString();
                            if (reader["DimensionUnit"] != DBNull.Value)
                                ddlDimensionUnit.SelectedValue = reader["DimensionUnit"].ToString();
                        }
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

                    // New Parameters mapping based on Item Type
                    string category = ddlItemCategory.SelectedValue;
                    cmd.Parameters.AddWithValue("@ItemCategory", category);

                    if (category == "Liquid")
                    {
                        cmd.Parameters.AddWithValue("@Length", DBNull.Value);
                        cmd.Parameters.AddWithValue("@Width", DBNull.Value);
                        cmd.Parameters.AddWithValue("@Thickness", DBNull.Value);
                        cmd.Parameters.AddWithValue("@DimensionUnit", DBNull.Value);

                        cmd.Parameters.AddWithValue("@Density", string.IsNullOrEmpty(txtDensity.Text.Trim()) ? (object)DBNull.Value : Convert.ToDecimal(txtDensity.Text.Trim()));
                        cmd.Parameters.AddWithValue("@Concentration", string.IsNullOrEmpty(txtConcentration.Text.Trim()) ? (object)DBNull.Value : txtConcentration.Text.Trim());
                        cmd.Parameters.AddWithValue("@PhValue", string.IsNullOrEmpty(txtPhValue.Text.Trim()) ? (object)DBNull.Value : txtPhValue.Text.Trim());
                    }
                    else
                    {
                        cmd.Parameters.AddWithValue("@Length", string.IsNullOrEmpty(txtLength.Text.Trim()) ? (object)DBNull.Value : Convert.ToDecimal(txtLength.Text.Trim()));
                        cmd.Parameters.AddWithValue("@Width", string.IsNullOrEmpty(txtWidth.Text.Trim()) ? (object)DBNull.Value : Convert.ToDecimal(txtWidth.Text.Trim()));
                        cmd.Parameters.AddWithValue("@Thickness", string.IsNullOrEmpty(txtThickness.Text.Trim()) ? (object)DBNull.Value : txtThickness.Text.Trim());
                        cmd.Parameters.AddWithValue("@DimensionUnit", ddlDimensionUnit.SelectedValue);

                        cmd.Parameters.AddWithValue("@Density", DBNull.Value);
                        cmd.Parameters.AddWithValue("@Concentration", DBNull.Value);
                        cmd.Parameters.AddWithValue("@PhValue", DBNull.Value);
                    }

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

            LoadRawMaterialInformation();
        }

        protected void ddlItemCategory_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (ddlItemCategory.SelectedValue == "Liquid")
            {
                pnlLiquidFields.Visible = true;
                pnlGeneralFields.Visible = false;
            }
            else
            {
                pnlLiquidFields.Visible = false;
                pnlGeneralFields.Visible = true;
            }
        }
    }
}