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
    public partial class RoleBasedPermission : System.Web.UI.Page
    {
        SqlConnection con;
        Database_Connection conn = new Database_Connection();
        //SqlCommand cmd;

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
                Roleload();
            }
        }

        void LoadForms()
        {
            con = conn.openConnection();
            {
                using (SqlCommand cmd = new SqlCommand(@"
        SELECT 
            r.role_id, 
            r.role_name, 
            m.Module_ID, 
            m.Module_Name, 
            mn.Menu_ID, 
            mn.Menu_Name, 
            f.Form_ID, 
            f.Form_Name, 
            ISNULL(rb.Form_Permission, 0) AS Form_Permission,
            ISNULL(rb.View_Permission, 0) AS View_Permission,
            ISNULL(rb.Add_Permission, 0) AS Add_Permission,
            ISNULL(rb.Edit_Permission, 0) AS Edit_Permission,
            ISNULL(rb.Delete_Permission, 0) AS Delete_Permission
        FROM 
            Form_Information f
        INNER JOIN Menu_Information mn ON f.Menu_ID = mn.Menu_ID
        INNER JOIN Module_Information m ON mn.Module_ID = m.Module_ID
        LEFT JOIN RoleBasedPermission rb ON f.Form_ID = rb.Form_ID AND rb.Role_ID = @RoleID
        LEFT JOIN roles r ON r.role_id = @RoleID
        WHERE (@ModuleID IS NULL OR m.Module_ID = @ModuleID)
          AND (@MenuID IS NULL OR mn.Menu_ID = @MenuID)
        ORDER BY m.Module_Name, mn.Menu_Name, f.Form_Name
        ", con))
                {
                    cmd.Parameters.AddWithValue("@RoleID", ddlRole.SelectedValue);

                    // Optional: filter by ModuleID and MenuID
                    if (!string.IsNullOrEmpty(ddlmodule.SelectedValue))
                        cmd.Parameters.AddWithValue("@ModuleID", ddlmodule.SelectedValue);
                    else
                        cmd.Parameters.AddWithValue("@ModuleID", DBNull.Value);

                    if (!string.IsNullOrEmpty(ddlMenu.SelectedValue))
                        cmd.Parameters.AddWithValue("@MenuID", ddlMenu.SelectedValue);
                    else
                        cmd.Parameters.AddWithValue("@MenuID", DBNull.Value);

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    gvModule.DataSource = dt;
                    gvModule.DataBind();
                }
            }
            con.Close();
        }
        void Roleload()
        {
            try
            {
                con = conn.openConnection();
                {
                    string query = "SELECT * FROM roles";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataSet ds = new DataSet();
                        da.Fill(ds);

                        ddlRole.DataSource = ds.Tables[0];
                        ddlRole.DataTextField = "role_name";
                        ddlRole.DataValueField = "role_id";
                        ddlRole.DataBind();

                        ddlRole.Items.Insert(0, new ListItem("--Select--", "0"));
                    }
                }
                con.Close();
            }
            catch (Exception ex)
            {
                Response.Write("Error: " + ex.Message);
            }
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

        protected void ddlmodule_SelectedIndexChanged(object sender, EventArgs e)
        {
            Menuload();
        }

        protected void ddlMenu_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadForms();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            using (SqlConnection con = conn.openConnection())
            {
                foreach (GridViewRow row in gvModule.Rows)
                {
                    int formId = Convert.ToInt32(gvModule.DataKeys[row.RowIndex].Value);

                    CheckBox chkView = (CheckBox)row.FindControl("chkViewAll");
                    CheckBox chkAdd = (CheckBox)row.FindControl("chkAdd");
                    CheckBox chkEdit = (CheckBox)row.FindControl("chkEdit");
                    CheckBox chkDelete = (CheckBox)row.FindControl("chkDelete");

                    bool view = chkView.Checked;
                    bool add = chkAdd.Checked;
                    bool edit = chkEdit.Checked;
                    bool delete = chkDelete.Checked;

                    bool formPermission = view || add || edit || delete;

                    using (SqlCommand cmd = new SqlCommand("sp_RolePermission_Upsert", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;

                        cmd.Parameters.AddWithValue("@Role_ID", ddlRole.SelectedValue);
                        cmd.Parameters.AddWithValue("@Form_ID", formId);
                        cmd.Parameters.AddWithValue("@Form_Permission", formPermission);
                        cmd.Parameters.AddWithValue("@View_Permission", view);
                        cmd.Parameters.AddWithValue("@Add_Permission", add);
                        cmd.Parameters.AddWithValue("@Edit_Permission", edit);
                        cmd.Parameters.AddWithValue("@Delete_Permission", delete);

                        cmd.ExecuteNonQuery();
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Save Successfully!');", true);
                    }
                }
            }
        }


        protected void ddlRole_SelectedIndexChanged(object sender, EventArgs e)
        {
        }

        protected void gvModule_RowDataBound1(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                // Get the data item
                DataRowView drv = (DataRowView)e.Row.DataItem;

                // Find the checkboxes
                CheckBox chkView = (CheckBox)e.Row.FindControl("chkViewAll");
                CheckBox chkAdd = (CheckBox)e.Row.FindControl("chkAdd");
                CheckBox chkEdit = (CheckBox)e.Row.FindControl("chkEdit");
                CheckBox chkDelete = (CheckBox)e.Row.FindControl("chkDelete");

                // Set Checked = false if null or 0
                chkView.Checked = drv["View_Permission"] != DBNull.Value && Convert.ToBoolean(drv["View_Permission"]);
                chkAdd.Checked = drv["Add_Permission"] != DBNull.Value && Convert.ToBoolean(drv["Add_Permission"]);
                chkEdit.Checked = drv["Edit_Permission"] != DBNull.Value && Convert.ToBoolean(drv["Edit_Permission"]);
                chkDelete.Checked = drv["Delete_Permission"] != DBNull.Value && Convert.ToBoolean(drv["Delete_Permission"]);
            }
        }
    }
}