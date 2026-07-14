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
    public partial class FloorInformation : System.Web.UI.Page
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
                BuildingInformationLoad();
                LoadNextFloorID();
                LoadFloorInformation();
            }
        }

        private void LoadNextFloorID()
        {
            con = conn.openConnection();
            {
                SqlCommand cmd = new SqlCommand("SELECT ISNULL(MAX(Floor_ID ),0)+1 FROM Floor_Information", con);
                txtFloorID.Text = cmd.ExecuteScalar().ToString();
            }
            con.Close();
        }
        private void BuildingInformationLoad()
        {
            try
            {
                con = conn.openConnection();
                {
                    string query = "SELECT * FROM BuildingInformation where Is_Active=1";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataSet ds = new DataSet();
                        da.Fill(ds);

                        ddlBuilding.DataSource = ds.Tables[0];
                        ddlBuilding.DataTextField = "Building_Name";
                        ddlBuilding.DataValueField = "Building_ID";
                        ddlBuilding.DataBind();

                        ddlBuilding.Items.Insert(0, new ListItem("--Select--", "0"));
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
                using (SqlCommand cmd = new SqlCommand("sp_FloorInformation_InsertUpdateDelete", con)) // correct SP name
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    // Correct parameter types
                    cmd.Parameters.Add("@Action", SqlDbType.NVarChar, 10).Value = ddlAction.Text; // INSERT/UPDATE/DELETE
                    cmd.Parameters.Add("@Floor_ID", SqlDbType.BigInt).Value = Convert.ToInt64(txtFloorID.Text);
                    cmd.Parameters.Add("@Building_ID", SqlDbType.BigInt).Value = Convert.ToInt64(ddlBuilding.SelectedValue);
                    cmd.Parameters.Add("@Floor_Name", SqlDbType.VarChar, 500).Value = txtFloor.Text;
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
        }
        private void LoadFloorInformation()
        {
            con = conn.openConnection();
            {
                SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM Floor_Information", con);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvBuilding.DataSource = dt;
                gvBuilding.DataBind();
            }
            con.Close();
        }

        protected void gvBuilding_SelectedIndexChanged(object sender, EventArgs e)
        {
            txtFloorID.Text = gvBuilding.SelectedRow.Cells[1].Text;
            try
            {
                string sql = "Select * from Floor_Information where Floor_ID ='" + txtFloorID.Text + "'";
                con = conn.openConnection();
                cmd = new SqlCommand(sql, con);
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        txtFloorID.Text = reader[0].ToString();
                        ddlBuilding.SelectedValue = reader[1].ToString();
                        txtFloor.Text = reader[2].ToString();
                        chkIsActive.Checked = reader[3] != DBNull.Value && Convert.ToBoolean(reader[3]); // ✅ CheckBox
                    }
                }
                else
                {
                    ddlBuilding.Text = txtFloorID.Text = string.Empty;
                    chkIsActive.Checked = false;
                }
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
            LoadFloorInformation();
        }
    }
}