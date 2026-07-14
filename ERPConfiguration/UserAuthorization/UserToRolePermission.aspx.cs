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

namespace Nexa_ERP.ERPConfiguration.UserAuthorization
{
    public partial class UserToRolePermission : System.Web.UI.Page
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
                Roleload();
                LoadUsersByRole();
            }

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
        void LoadUsersByRole()
        {
            con = conn.openConnection();

            using (SqlCommand cmd = new SqlCommand(@"
    SELECT 
        u.user_id,
        u.email,
        u.full_name,
        r.role_id,
        r.role_name,
        ISNULL(urp.Permission_Status, 0) AS Permission_Status
    FROM User_Information u
    LEFT JOIN UserToRolePermission urp 
        ON u.user_id = urp.User_ID 
        AND urp.Role_ID = @RoleID
    LEFT JOIN roles r 
        ON urp.Role_ID = r.role_id
    ORDER BY u.full_name
", con))
            {
                cmd.Parameters.AddWithValue("@RoleID", ddlRole.SelectedValue);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                gvModule.DataSource = dt;
                gvModule.DataBind();
            }

            con.Close();

        }

        protected void ddlRole_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadUsersByRole();
        }

        protected void gvModule_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                // Get the data item
                DataRowView drv = (DataRowView)e.Row.DataItem;

                // Find the checkboxes
                CheckBox chkView = (CheckBox)e.Row.FindControl("chkAcction");

                // Set Checked = false if null or 0
                chkView.Checked = drv["Permission_Status"] != DBNull.Value && Convert.ToBoolean(drv["Permission_Status"]);
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            con = conn.openConnection();
            {
                foreach (GridViewRow row in gvModule.Rows)
                {
                    int formId = Convert.ToInt32(gvModule.DataKeys[row.RowIndex].Value);

                    CheckBox chkView = (CheckBox)row.FindControl("chkAcction");
                    bool P_Action = chkView.Checked;

                    using (SqlCommand cmd = new SqlCommand("sp_UserToRolePermission_InsertUpdate", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;

                        cmd.Parameters.Add("@Role_ID", SqlDbType.BigInt).Value = Convert.ToInt64(ddlRole.SelectedValue);
                        cmd.Parameters.Add("@User_ID", SqlDbType.BigInt).Value = formId;
                        cmd.Parameters.Add("@Permission_Status", SqlDbType.Bit).Value = P_Action;

                        cmd.ExecuteNonQuery();
                    }
                }

                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Save Successfully!');", true);
            }
        }
    }
}