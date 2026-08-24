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

namespace Nexa_ERP
{
    public partial class Default : System.Web.UI.Page
    {
        SqlConnection con;
        Database_Connection conn = new Database_Connection();
        SqlCommand cmd;

        String User_ID;

        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            try
            {
                string sql = "Select * from User_Information where username='" + txtUser.Text + "' and password_hash='" + txtPass.Text + "'";
                con = conn.openConnection();
                cmd = new SqlCommand(sql, con);
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        User_ID = reader[0].ToString();
                    }
                }
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
            {
                con = conn.openConnection();
                SqlDataAdapter dt = new SqlDataAdapter("Select * from User_Information where username='" + txtUser.Text + "' And password_hash='" + txtPass.Text + "'", con);
                DataTable ds = new System.Data.DataTable();
                dt.Fill(ds);
                if (ds.Rows.Count == 1)
                {
                    Session["Username"] = txtUser.Text;
                    Session["Password"] = txtPass.Text;
                    Session["User_ID"] = User_ID;
                    Response.Redirect("Deahboard.aspx");
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Employee Information Saved Successfully!');", true);
                }
                else
                {
                    lblMessage.Text = "Invalid username or password!";
                }
                con.Close();
            }




        }
    }
}