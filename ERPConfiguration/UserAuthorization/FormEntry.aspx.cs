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
    public partial class FormEntry : System.Web.UI.Page
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
                LoadForms();
                Moduleload();
                Menuload();
                LoadNextMenuID();
            }
        }

        void LoadNextMenuID()
        {
            con = conn.openConnection();
            {
                SqlCommand cmd = new SqlCommand("SELECT ISNULL(MAX(Form_ID),0)+1 FROM Form_Information", con);
                txtformID.Text = cmd.ExecuteScalar().ToString();
            }
            con.Close();
        }

        void LoadForms()
        {
            con = conn.openConnection();
            {
                SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM Form_Information where Module_ID='" + ddlmodule.SelectedValue + "' and Menu_ID='" + ddlMenu.SelectedValue + "'", con);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvModule.DataSource = dt;
                gvModule.DataBind();
            }
            con.Close();

        }
        void Moduleload()
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

        void Menuload()
        {
            try
            {
                con = conn.openConnection();
                {
                    string query = "SELECT * FROM Menu_Information where Module_ID='" + ddlmodule.SelectedValue + "'";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataSet ds = new DataSet();
                        da.Fill(ds);

                        ddlMenu.DataSource = ds.Tables[0];
                        ddlMenu.DataTextField = "Menu_Name";
                        ddlMenu.DataValueField = "Menu_ID";
                        ddlMenu.DataBind();

                        ddlMenu.Items.Insert(0, new ListItem("--Select--", "0"));
                    }
                }
                con.Close();
            }
            catch (Exception ex)
            {
                Response.Write("Error: " + ex.Message);
            }
        }

        protected void ddlMenu_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadForms();
        }

        protected void ddlmodule_SelectedIndexChanged(object sender, EventArgs e)
        {
            Menuload();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                con = conn.openConnection();
                {
                    using (SqlCommand cmd = new SqlCommand("sp_FormInformation_Upsert", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add("@Form_ID", SqlDbType.BigInt).Value = txtformID.Text;
                        cmd.Parameters.Add("@Module_ID", SqlDbType.VarChar).Value = ddlmodule.Text;
                        cmd.Parameters.Add("@Menu_ID", SqlDbType.VarChar).Value = ddlMenu.Text;
                        cmd.Parameters.Add("@Form_Name", SqlDbType.VarChar).Value = txtForm.Text;
                        cmd.Parameters.Add("@Menu_description", SqlDbType.VarChar).Value = txtFormdiscription.Text;
                        cmd.Parameters.Add("@is_active", SqlDbType.Bit).Value = chkIsActive.Checked;
                        cmd.Parameters.Add("@Form_Url", SqlDbType.VarChar).Value = txturl.Text;
                        cmd.Parameters.Add("@Icon_Class", SqlDbType.VarChar).Value = txtCss.Text;
                        cmd.Parameters.Add("@WorkingStage", SqlDbType.VarChar).Value = ddlWorkingStage.Text;
                        cmd.Parameters.Add("@WorkUnder", SqlDbType.VarChar).Value = ddlUIDesigner.Text;
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
            LoadForms();
            LoadNextMenuID();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {

        }

        protected void gvModule_SelectedIndexChanged(object sender, EventArgs e)
        {
            txtformID.Text= gvModule.SelectedRow.Cells[1].Text;
            try
            {
                string sql = "Select * from Form_Information where Form_ID='" + txtformID.Text + "'";
                con = conn.openConnection();
                cmd = new SqlCommand(sql, con);
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        txtForm.Text = reader[3].ToString();
                        txtFormdiscription.Text = reader[4].ToString();
                        txturl.Text = reader[6].ToString();
                        txtCss.Text = reader[7].ToString();
                        chkIsActive.Checked = reader[5] != DBNull.Value && Convert.ToBoolean(reader[5]); // ✅ CheckBox
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