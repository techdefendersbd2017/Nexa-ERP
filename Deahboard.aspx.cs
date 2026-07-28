using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Reflection.Emit;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP
{
    public partial class Deahboard : System.Web.UI.Page
    {
        SqlConnection con;
        Database_Connection conn = new Database_Connection();
        SqlCommand cmd;
        //SqlDataAdapter da;
        //DataSet ds;

        string User_ID;
        string username;
        string password;
        string Role_ID;
        //string Permission_Status;

        protected void Page_Load(object sender, EventArgs e)
        {
            username = Session["Username"].ToString();
            password = Session["Password"].ToString();

            //===========Call User_Information=============
            try
            {
                string sql = "Select * from User_Information where username='" + username + "' and password_hash='" + password + "'";
                con = conn.openConnection();
                cmd = new SqlCommand(sql, con);
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        User_ID = reader[0].ToString();
                        lblUser.Text = reader[4].ToString();
                        lblUserName.Text = reader[4].ToString(); // sidebar-এর নাম dynamic ভাবে সেট হবে
                    }
                }
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }

            // IMPORTANT: Get Role first
            UserToRolePermission();

            if (!IsPostBack)
            {
                LoadFullTreeMenu();
            }
        }

        private void UserToRolePermission()
        {
            try
            {
                string sql = "Select * from UserToRolePermission where User_ID='" + User_ID + "' and Permission_Status=1";
                con = conn.openConnection();
                cmd = new SqlCommand(sql, con);
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        Role_ID = reader[1].ToString();
                    }
                }
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
        }


        private void LoadFullTreeMenu()
        {
            using (SqlConnection con = conn.openConnection())
            {
                // Load Modules
                DataTable dtModules = new DataTable();
                using (SqlCommand cmdModule = new SqlCommand(
                    "SELECT dbo.roles.role_id, dbo.Module_Information.Module_ID, dbo.Module_Information.Module_Name, dbo.Module_Information.Icon_Class, dbo.Module_Information.is_Active, " +
                         "dbo.User_Module_Access_Information.Permission_Status FROM dbo.User_Module_Access_Information INNER JOIN " +
                         "dbo.Module_Information ON dbo.User_Module_Access_Information.Module_ID = dbo.Module_Information.Module_ID INNER JOIN " +
                         "dbo.roles ON dbo.User_Module_Access_Information.Role_ID = dbo.roles.role_id " +
                    "WHERE dbo.roles.role_id=@RoleID AND dbo.Module_Information.is_Active=1 AND dbo.User_Module_Access_Information.Permission_Status=1 ORDER BY dbo.Module_Information.Module_ID", con))
                {
                    cmdModule.Parameters.AddWithValue("@RoleID", Role_ID);
                    new SqlDataAdapter(cmdModule).Fill(dtModules);
                }
                // Load ALL Menus (no role filter - will be filtered by module)
                DataTable dtMenus = new DataTable();
                using (SqlCommand cmdMenu = new SqlCommand(
                    "SELECT Menu_ID, Module_ID, Menu_Name, Icon_Class FROM Menu_Information WHERE Is_Active=1 ORDER BY Menu_ID", con))
                {
                    new SqlDataAdapter(cmdMenu).Fill(dtMenus);
                }

                // Load ALL Forms (no role filter - will be filtered by menu)
                DataTable dtForms = new DataTable();
                using (SqlCommand cmdForm = new SqlCommand(
                    @"SELECT        f.Form_ID, f.Module_ID, f.Menu_ID, f.Form_Name, f.Form_Url, f.Icon_Class, f.Is_Active, r.role_id, p.Form_Permission, f.SortingNo
                        FROM            dbo.RoleBasedPermission p INNER JOIN dbo.roles r ON p.Role_ID = r.role_id INNER JOIN dbo.Form_Information f ON p.Form_ID = f.Form_ID
                    Where r.role_id=@RoleID and p.Form_Permission=1 and f.Is_Active=1 Order by f.SortingNo asc", con))
                {
                    cmdForm.Parameters.AddWithValue("@RoleID", Role_ID);
                    new SqlDataAdapter(cmdForm).Fill(dtForms);
                }

                // Add child columns
                dtModules.Columns.Add("Menus", typeof(DataTable));
                dtMenus.Columns.Add("Forms", typeof(DataTable));

                // Attach Forms to Menus
                foreach (DataRow menuRow in dtMenus.Rows)
                {
                    DataTable formsTable = dtForms.Clone();

                    foreach (DataRow formRow in dtForms.Rows)
                    {
                        if (formRow["Menu_ID"].ToString() == menuRow["Menu_ID"].ToString())
                        {
                            formsTable.ImportRow(formRow);
                        }
                    }

                    menuRow["Forms"] = formsTable;
                }

                // Attach Menus to Modules
                foreach (DataRow moduleRow in dtModules.Rows)
                {
                    DataTable menusTable = dtMenus.Clone();

                    foreach (DataRow menuRow in dtMenus.Rows)
                    {
                        if (menuRow["Module_ID"].ToString() == moduleRow["Module_ID"].ToString())
                        {
                            menusTable.ImportRow(menuRow);
                        }
                    }

                    moduleRow["Menus"] = menusTable;
                }

                // Bind to repeater
                rptModules.DataSource = dtModules;
                rptModules.DataBind();
            }
        }

        // CRITICAL: ItemDataBound events for nested repeaters
        protected void rptModules_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                DataRowView drv = (DataRowView)e.Item.DataItem;
                Repeater rptMenus = (Repeater)e.Item.FindControl("rptMenus");

                if (rptMenus != null && drv["Menus"] != DBNull.Value)
                {
                    DataTable menusTable = (DataTable)drv["Menus"];
                    rptMenus.DataSource = menusTable;
                    rptMenus.DataBind();
                }
            }
        }

        protected void rptMenus_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                DataRowView drv = (DataRowView)e.Item.DataItem;
                Repeater rptForms = (Repeater)e.Item.FindControl("rptForms");

                if (rptForms != null && drv["Forms"] != DBNull.Value)
                {
                    DataTable formsTable = (DataTable)drv["Forms"];
                    rptForms.DataSource = formsTable;
                    rptForms.DataBind();
                }
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Default.aspx");
        }
    }
}
