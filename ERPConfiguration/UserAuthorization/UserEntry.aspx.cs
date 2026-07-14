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

namespace Nexa_ERP.ERPConfiguration
{
    public partial class UserEntry : System.Web.UI.Page
    {
        SqlConnection con;
        Database_Connection conn=new Database_Connection ();
        SqlCommand cmd; 
        //SqlDataAdapter da;
        //DataSet ds;

        //String User_ID="0";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string user = Request.QueryString["user"];
                if (!string.IsNullOrEmpty(user))
                {
                    Label1.Text = "Welcome, " + user;
                }
                roledataload();
                gridviewdataload();
            }
        }

        void gridviewdataload()
        {
            try
            {
                con = conn.openConnection();
                {
                    string query = @"SELECT TOP 1000 user_id, username, email, password_hash, full_name, user_type ,is_active
                             FROM User_Information";

                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        gvUsers.DataSource = dt;
                        gvUsers.DataBind();
                    }
                }
                con.Close();
            }
            catch(Exception ex) 
            {
                Response.Write("Error: " + ex.Message);
            }
        }

        void roledataload()
        {
            try
            {
                con = conn.openConnection();
                {
                    string query = "SELECT role_id, role_name FROM roles where is_active=1";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataSet ds = new DataSet();
                        da.Fill(ds);

                        ddlUserType.DataSource = ds.Tables[0];
                        ddlUserType.DataTextField = "role_name";
                        ddlUserType.DataValueField = "role_id";
                        ddlUserType.DataBind();

                        ddlUserType.Items.Insert(0, new ListItem("--Select--", "0"));
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
                {
                    using (SqlCommand cmd = new SqlCommand("sp_User_Information_Save", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add("@user_id", SqlDbType.Int).Value = txtuserid.Text;
                        cmd.Parameters.Add("@username", SqlDbType.NVarChar).Value = txtUsername.Text;
                        cmd.Parameters.Add("@email", SqlDbType.NVarChar).Value = txtEmail.Text;
                        cmd.Parameters.Add("@password_hash", SqlDbType.NVarChar).Value = txtPassword.Text;
                        cmd.Parameters.Add("@full_name", SqlDbType.NVarChar).Value = txtFullName.Text;
                        cmd.Parameters.Add("@phone", SqlDbType.NVarChar).Value = txtPhone.Text;
                        cmd.Parameters.Add("@user_type", SqlDbType.NVarChar).Value = ddlUserType.Text;
                        cmd.Parameters.Add("@is_active", SqlDbType.Bit).Value = chkIsActive.Checked;
                        cmd.Parameters.Add("@created_by", SqlDbType.Int).Value = txtuserid.Text;
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
            ClearFild();
            gridviewdataload();
        }

        protected void gvUsers_SelectedIndexChanged(object sender, EventArgs e)
        {
            GridViewRow row = gvUsers.SelectedRow;
            txtuserid.Text = row.Cells[1].Text;
            try
            {
                string sql = "Select * from User_Information where user_id='" + txtuserid.Text + "'";
                con = conn.openConnection();
                cmd = new SqlCommand(sql, con);
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        txtuserid.Text = reader[0].ToString();
                        txtUsername.Text = reader[1].ToString();
                        txtEmail.Text = reader[2].ToString();
                        txtPassword.Text = reader[3].ToString();
                        txtFullName.Text = reader[4].ToString();
                        txtPhone.Text = reader[5].ToString(); 
                        ddlUserType.SelectedValue = reader[6].ToString();   // ✅ DropDown
                        chkIsActive.Checked = reader[7] != DBNull.Value && Convert.ToBoolean(reader[7]); // ✅ CheckBox
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

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ClearFild();
        }
        private void ClearFild()
        {
            txtuserid.Text = txtUsername.Text = txtEmail.Text = txtPassword.Text = txtFullName.Text = txtPhone.Text = "";
            chkIsActive.Checked = false;
        }
    }
}