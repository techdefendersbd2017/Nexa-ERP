using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.ERPConfiguration
{
    public partial class Roles : System.Web.UI.Page
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
                LoadRoles();
            }
        }

        void LoadRoles()
        {
            con = conn.openConnection();
            {
                SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM roles", con);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvRoles.DataSource = dt;
                gvRoles.DataBind();
            }
            con.Close();

        }

        protected void gvRoles_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                con = conn.openConnection();
                {
                    using (SqlCommand cmd = new SqlCommand("sp_roles_save", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add("@role_id", SqlDbType.Int).Value = txtroleid.Text;
                        cmd.Parameters.Add("@role_name", SqlDbType.NVarChar).Value = txtRoleName.Text;
                        cmd.Parameters.Add("@description", SqlDbType.NVarChar).Value = txtRolediscription.Text;
                        cmd.Parameters.Add("@is_active", SqlDbType.Bit).Value = chkIsActive.Checked;
                        cmd.ExecuteNonQuery();
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Save Successfully!');", true);
                    }
                }
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message + "');", true);
            }
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            txtroleid.Text = "0"; txtRoleName.Text = txtRolediscription.Text = "";            chkIsActive.Checked =false;
        }

        protected void gvUsers_SelectedIndexChanged(object sender, EventArgs e)
        {
            
        }

        protected void gvRoles_SelectedIndexChanged1(object sender, EventArgs e)
        {
            txtroleid.Text = gvRoles.SelectedRow.Cells[1].Text;
            try
            {
                string sql = "Select * from roles where role_id='" + txtroleid.Text + "'";
                con = conn.openConnection();
                cmd = new SqlCommand(sql, con);
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        txtroleid.Text = reader[0].ToString();
                        txtRoleName.Text = reader[1].ToString();
                        txtRolediscription.Text = reader[2].ToString();
                        chkIsActive.Checked = reader[3] != DBNull.Value && Convert.ToBoolean(reader[3]); // ✅ CheckBox
                    }
                }
                else
                {
                    //User_ID = string.Empty;
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