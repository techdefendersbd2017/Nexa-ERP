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
                string sql = "Select * from UserToRolePermission where User_ID='" + User_ID + "'";
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
                    "SELECT Module_ID, Module_Name, Icon_Class FROM View_Module_Information WHERE role_id=@RoleID AND is_Active=1 ORDER BY Module_ID", con))
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
                    "SELECT Form_ID, Module_ID, Menu_ID, Form_Name, Form_Url, Icon_Class FROM Form_Information WHERE Is_Active=1 ORDER BY Form_ID", con))
                {
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
    }
}
