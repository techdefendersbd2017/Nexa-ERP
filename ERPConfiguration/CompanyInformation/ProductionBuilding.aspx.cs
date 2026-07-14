using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.ERPConfiguration.CompanyInformation
{
    public partial class ProductionBuilding : System.Web.UI.Page
    {
        SqlConnection con;
        Database_Connection conn = new Database_Connection();
        SqlCommand cmd;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string user = Request.QueryString["user"];
                if (!string.IsNullOrEmpty(user))
                {
                    Label1.Text = "Welcome, " + user;
                }
                BranchInformationLoad();
                LoadNextBranchID();
                LoadBuildingInformation();
            }
        }
        private void LoadNextBranchID()
        {
            con = conn.openConnection();
            {
                SqlCommand cmd = new SqlCommand("SELECT ISNULL(MAX(Building_ID ),0)+1 FROM BuildingInformation", con);
                txtBuildingID.Text = cmd.ExecuteScalar().ToString();
            }
            con.Close();
        }
        private void BranchInformationLoad()
        {
            try
            {
                con = conn.openConnection();
                {
                    string query = "SELECT * FROM Branch_Information where Is_Active=1";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataSet ds = new DataSet();
                        da.Fill(ds);

                        ddlBranch.DataSource = ds.Tables[0];
                        ddlBranch.DataTextField = "Branch_Name";
                        ddlBranch.DataValueField = "Branch_ID";
                        ddlBranch.DataBind();

                        ddlBranch.Items.Insert(0, new ListItem("--Select--", "0"));
                    }
                }
                con.Close();
            }
            catch (Exception ex)
            {
                Response.Write("Error: " + ex.Message);
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                con = conn.openConnection();
                using (SqlCommand cmd = new SqlCommand("sp_BuildingInformation", con)) // correct SP name
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    // Correct parameter types
                    cmd.Parameters.Add("@Action", SqlDbType.NVarChar, 10).Value = ddlAction.Text; // INSERT/UPDATE/DELETE
                    cmd.Parameters.Add("@Building_ID", SqlDbType.BigInt).Value = Convert.ToInt64(txtBuildingID.Text);
                    cmd.Parameters.Add("@Branch_ID", SqlDbType.BigInt).Value = Convert.ToInt64(ddlBranch.SelectedValue);
                    cmd.Parameters.Add("@Building_Name", SqlDbType.VarChar, 500).Value = txtBuilding.Text;
                    cmd.Parameters.Add("@iS_Active", SqlDbType.Bit).Value = chkIsActive.Checked;

                    cmd.ExecuteNonQuery();

                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Save Successfully!');", true);
                }
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message + "');", true);
            }

            LoadBuildingInformation();
        }
        private void LoadBuildingInformation()
        {
            con = conn.openConnection();
            {
                SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM BuildingInformation", con);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvBuilding.DataSource = dt;
                gvBuilding.DataBind();
            }
            con.Close();
        }

        protected void gvBuilding_SelectedIndexChanged(object sender, EventArgs e)
        {
            txtBuildingID.Text = gvBuilding.SelectedRow.Cells[1].Text;
            try
            {
                string sql = "Select * from BuildingInformation where Building_ID ='" + txtBuildingID.Text + "'";
                con = conn.openConnection();
                cmd = new SqlCommand(sql, con);
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        txtBuildingID.Text = reader[0].ToString();
                        ddlBranch.SelectedValue = reader[1].ToString();
                        txtBuilding.Text = reader[2].ToString();
                        chkIsActive.Checked = reader[3] != DBNull.Value && Convert.ToBoolean(reader[3]); // ✅ CheckBox
                    }
                }
                else
                {
                    txtBuildingID.Text = txtBuilding.Text = string.Empty;
                    chkIsActive.Checked = false;
                }
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
        }
    }
}