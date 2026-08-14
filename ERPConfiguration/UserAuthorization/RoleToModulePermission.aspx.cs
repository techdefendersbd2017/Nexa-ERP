using Nexa_ERP.Connection;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.ERPConfiguration.UserAuthorization
{
    public partial class RoleToModulePermission : System.Web.UI.Page
    {
        SqlConnection con;
        Database_Connection conn = new Database_Connection();
        SqlCommand cmd;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadRoleDropdown();

                if (ddlRole.Items.Count > 0)
                {
                    hfRoleId.Value = ddlRole.SelectedValue;
                    LoadModulePermissionGrid(ddlRole.SelectedValue);
                }
            }
        }

        // ================= Load Role Dropdown =================
        // ধরে নেওয়া হয়েছে টেবিলের নাম: Role_Information (Role_ID, Role_Name)
        // আপনার আসল টেবিল/কলামের নাম অনুযায়ী নিচের SQL পরিবর্তন করুন
        private void LoadRoleDropdown()
        {
            try
            {
                con = conn.openConnection();
                string sql = "SELECT Role_ID, Role_Name FROM roles WHERE Is_Active = 1 ORDER BY role_name";
                cmd = new SqlCommand(sql, con);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                con.Close();

                ddlRole.DataSource = dt;
                ddlRole.DataTextField = "role_name";
                ddlRole.DataValueField = "Role_ID";
                ddlRole.DataBind();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert",
                    "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
        }

        // ================= Dropdown Change =================
        protected void ddlRole_SelectedIndexChanged(object sender, EventArgs e)
        {
            hfRoleId.Value = ddlRole.SelectedValue;
            LoadModulePermissionGrid(ddlRole.SelectedValue);
        }

        // ================= Load Module Grid with Existing Permissions =================
        // ধরে নেওয়া হয়েছে:
        //   Module_Information (Module_ID, Module_Name, Is_Active)
        //   RoleToModulePermission (Role_ID, Module_ID, Can_View)
        // আপনার আসল টেবিল/কলাম নাম মিলিয়ে নিন
        private void LoadModulePermissionGrid(string roleId)
        {
            try
            {
                con = conn.openConnection();

                string sql = @"
                      SELECT 
                        m.module_id,
                        m.Module_Name AS module_name,
                        ISNULL(p.Permission_Status, 0) AS can_view
                    FROM Module_Information m
                    LEFT JOIN User_Module_Access_Information p
                        ON p.Module_ID = m.Module_ID AND p.Role_ID=@RoleID
                    WHERE m.Is_Active = 1
                    ORDER BY m.Module_ID";

                cmd = new SqlCommand(sql, con);
                cmd.Parameters.AddWithValue("@RoleID", roleId);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                con.Close();

                gvModulePermission.DataSource = dt;
                gvModulePermission.DataBind();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert",
                    "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
        }

        // ================= Set Checkbox State per Row =================
        protected void gvModulePermission_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                DataRowView drv = (DataRowView)e.Row.DataItem;

                CheckBox chkItemView = (CheckBox)e.Row.FindControl("chkItemView");
                if (chkItemView != null && drv["can_view"] != DBNull.Value)
                {
                    chkItemView.Checked = Convert.ToBoolean(drv["can_view"]);
                }
            }
        }

        // GridView-এ Select command এখনো ব্যবহার হচ্ছে না, তবে markup-এ
        // OnSelectedIndexChanged ওয়্যার করা আছে বলে handler থাকা জরুরি (compile error এড়াতে)
        protected void gvModulePermission_SelectedIndexChanged(object sender, EventArgs e)
        {
            // প্রয়োজন হলে এখানে ভবিষ্যতে row-select লজিক লেখা যাবে
        }

        // ================= Save Permissions =================
        protected void btnSave_Click(object sender, EventArgs e)
        {
            string roleId = hfRoleId.Value;

            if (string.IsNullOrEmpty(roleId))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert",
                    "alert('অনুগ্রহ করে আগে একটি Role সিলেক্ট করুন।');", true);
                return;
            }

            try
            {
                con = conn.openConnection();

                foreach (GridViewRow row in gvModulePermission.Rows)
                {
                    if (row.RowType == DataControlRowType.DataRow)
                    {
                        string moduleId = gvModulePermission.DataKeys[row.RowIndex].Value.ToString();

                        CheckBox chkItemView = (CheckBox)row.FindControl("chkItemView");
                        bool canView = chkItemView != null && chkItemView.Checked;

                        // MERGE: থাকলে UPDATE, না থাকলে INSERT
                        string sql = @"
                            IF EXISTS (SELECT 1 FROM User_Module_Access_Information WHERE Role_ID = @RoleID AND Module_ID = @ModuleID)
                                UPDATE User_Module_Access_Information
                                SET Permission_Status = @CanView
                                WHERE Role_ID = @RoleID AND Module_ID = @ModuleID
                            ELSE
                                INSERT INTO User_Module_Access_Information (Role_ID, Module_ID, Permission_Status)
                                VALUES (@RoleID, @ModuleID, @CanView)";

                        cmd = new SqlCommand(sql, con);
                        cmd.Parameters.AddWithValue("@RoleID", roleId);
                        cmd.Parameters.AddWithValue("@ModuleID", moduleId);
                        cmd.Parameters.AddWithValue("@CanView", canView);
                        cmd.ExecuteNonQuery();
                    }
                }

                con.Close();

                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert",
                    "alert('Permission সফলভাবে সংরক্ষণ করা হয়েছে।');", true);
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert",
                    "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
        }
    }
}