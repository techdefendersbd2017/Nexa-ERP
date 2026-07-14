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
        //SqlCommand cmd;
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            {
                con = conn.openConnection();
                SqlDataAdapter dt = new SqlDataAdapter("Select * from User_Information where username='" + txtUser.Text + "' And password_hash='" + txtPass.Text + "'", con);
                DataTable ds = new System.Data.DataTable();
                dt.Fill(ds);
                if (ds.Rows.Count == 1)
                {
                    Session["Username"] = txtUser.Text;
                    Session["Password"] = txtPass.Text;
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