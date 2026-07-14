using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.ERPConfiguration
{
    public partial class MenuEntry : System.Web.UI.Page
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
                LoadMenus();
                Menudataload();
                LoadNextMenuID();
            }
        }
        void LoadNextMenuID()
        {
            con = conn.openConnection();
            {
                SqlCommand cmd = new SqlCommand("SELECT ISNULL(MAX(Menu_ID),0)+1 FROM Menu_Information", con);
                txtMenuID.Text = cmd.ExecuteScalar().ToString();
            }
            con.Close();
        }
        void LoadMenus()
        {
            con = conn.openConnection();
            {
                SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM Menu_Information where Module_ID='"+ddlmodule.SelectedValue+"'", con);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvModule.DataSource = dt;
                gvModule.DataBind();
            }
            con.Close();

        }
        void Menudataload()
        {
            try
            {
                con = conn.openConnection();
                {
                    string query = "SELECT * FROM Module_Information";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataSet ds = new DataSet();
                        da.Fill(ds);

                        ddlmodule.DataSource = ds.Tables[0];
                        ddlmodule.DataTextField = "Module_Name";
                        ddlmodule.DataValueField = "Module_ID";
                        ddlmodule.DataBind();

                        ddlmodule.Items.Insert(0, new ListItem("--Select--", "0"));
                    }
                }
                con.Close();
            }
            catch (Exception ex)
            {
                Response.Write("Error: " + ex.Message);
            }
        }

        protected void gvModule_SelectedIndexChanged(object sender, EventArgs e)
        {
            txtMenuID.Text = gvModule.SelectedRow.Cells[1].Text;
            try
            {
                string sql = "Select * from Menu_Information where Menu_ID='" + txtMenuID.Text + "'";
                con = conn.openConnection();
                cmd = new SqlCommand(sql, con);
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        ddlmodule.SelectedValue = reader[1].ToString();
                        txtmenu.Text = reader[2].ToString();
                        txtMenudiscription.Text = reader[3].ToString();
                        txtCss.Text = reader[5].ToString();
                        chkIsActive.Checked = reader[4] != DBNull.Value && Convert.ToBoolean(reader[4]); // ✅ CheckBox
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

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                con = conn.openConnection();
                {
                    using (SqlCommand cmd = new SqlCommand("sp_MenuInformation_Upsert", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add("@Menu_ID", SqlDbType.BigInt).Value = txtMenuID.Text;
                        cmd.Parameters.Add("@Module_ID", SqlDbType.VarChar).Value = ddlmodule.Text;
                        cmd.Parameters.Add("@Menu_Name", SqlDbType.VarChar).Value = txtmenu.Text;
                        cmd.Parameters.Add("@Menu_description", SqlDbType.VarChar).Value = txtMenudiscription.Text;
                        cmd.Parameters.Add("@is_active", SqlDbType.Bit).Value = chkIsActive.Checked;
                        cmd.Parameters.Add("@Icon_Class", SqlDbType.VarChar).Value = txtCss.Text;
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
            LoadMenus();
            LoadNextMenuID();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {

        }

        protected void ddlmodule_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadMenus();
        }
    }
}