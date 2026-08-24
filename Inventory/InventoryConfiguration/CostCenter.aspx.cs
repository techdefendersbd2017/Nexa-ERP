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

namespace Nexa_ERP.Inventory.InventoryConfiguration
{
    public partial class CostCenter : System.Web.UI.Page
    {
        SqlConnection con;
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();
        SqlCommand cmd;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                Load_BranchInformation();
            }
        }

        private void Load_BranchInformation()
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT * FROM vw_Branch_Information ORDER BY Branch_Name";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    ddlBranchName.DataSource = dt;
                    ddlBranchName.DataTextField = "Branch_Name";
                    ddlBranchName.DataValueField = "Branch_ID";
                    ddlBranchName.DataBind();
                    ddlBranchName.Items.Insert(0, new ListItem("--Select Branch--", "0"));
                }
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
        }

        private void LoadCostCenterInformation()
        {
            try
            {
                con = conn.openConnection();
                {
                    SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM ta_CostCenter WHERE BranchId = '" + ddlBranchName.SelectedValue + "' ORDER BY CostCenterName ASC", con);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    gvCostCenter.DataSource = dt;
                    gvCostCenter.DataBind();
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
            txtCostCenterId.Text = txtCostCenterName.Text = string.Empty;
            ddlStatus.SelectedValue = "Active";
            btnSave.Text = "Save";
        }

        protected void gvCostCenter_SelectedIndexChanged(object sender, EventArgs e)
        {
            txtCostCenterId.Text = gvCostCenter.SelectedRow.Cells[0].Text;
            try
            {
                string sql = "SELECT * FROM ta_CostCenter WHERE CostCenterId = '" + txtCostCenterId.Text + "'";
                con = conn.openConnection();
                cmd = new SqlCommand(sql, con);
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        ddlBranchName.SelectedValue = reader["BranchId"].ToString();
                        txtCostCenterName.Text = reader["CostCenterName"].ToString();
                        ddlStatus.SelectedValue = reader["Status"].ToString();
                    }
                    btnSave.Text = "Update";
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

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            clearform();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                con = conn.openConnection();
                using (SqlCommand cmd = new SqlCommand("sp_ta_InsertUpdate_CostCenter", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    int costCenterId = 0;
                    if (!string.IsNullOrEmpty(txtCostCenterId.Text.Trim()))
                    {
                        int.TryParse(txtCostCenterId.Text.Trim(), out costCenterId);
                    }

                    cmd.Parameters.AddWithValue("@CostCenterId", costCenterId == 0 ? (object)DBNull.Value : costCenterId);
                    cmd.Parameters.AddWithValue("@BranchId", string.IsNullOrEmpty(ddlBranchName.SelectedValue) || ddlBranchName.SelectedValue == "0" ? (object)DBNull.Value : ddlBranchName.SelectedValue);
                    cmd.Parameters.AddWithValue("@CostCenterName", string.IsNullOrEmpty(txtCostCenterName.Text.Trim()) ? (object)DBNull.Value : txtCostCenterName.Text.Trim());
                    cmd.Parameters.AddWithValue("@Status", ddlStatus.SelectedValue);

                    cmd.ExecuteNonQuery();

                    if (costCenterId == 0)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Cost Center Saved Successfully!');", true);
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Cost Center Updated Successfully!');", true);
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
                {
                    con.Close();
                }
            }
            LoadCostCenterInformation();
        }

        protected void ddlBranchName_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadCostCenterInformation();
        }
    }
}