using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.ERPConfiguration.UserAuthorization
{
    public partial class UserToBranchPermission : System.Web.UI.Page
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
                Branchload();
                LoadUsersByBranch();
            }

        }
        private void Branchload()
        {
            try
            {
                con = conn.openConnection();
                {
                    string query = "SELECT * FROM Branch_Information where Is_Active=1";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataSet ds = new DataSet();
                        da.Fill(ds);

                        ddlbranch.DataSource = ds.Tables[0];
                        ddlbranch.DataTextField = "Branch_Name";
                        ddlbranch.DataValueField = "Branch_ID";
                        ddlbranch.DataBind();

                        ddlbranch.Items.Insert(0, new ListItem("--Select--", "0"));
                    }
                }
                con.Close();
            }
            catch (Exception ex)
            {
                Response.Write("Error: " + ex.Message);
            }
        }
        void LoadUsersByBranch()
        {
            con = conn.openConnection();

            using (SqlCommand cmd = new SqlCommand(@"
                SELECT 
                    u.user_id,
                    u.email,
                    u.full_name,
                    r.branch_id,
                    r.Branch_name,
                    ISNULL(urp.Permission_Status, 0) AS Permission_Status
                FROM User_Information u
                LEFT JOIN UserToBranchPermission urp 
                    ON u.user_id = urp.User_ID 
                    AND urp.branch_id = @BranchID
                LEFT JOIN Branch_Information r 
                    ON urp.branch_id = r.branch_id
                ORDER BY u.full_name
            ", con))
            {
                cmd.Parameters.AddWithValue("@BranchID", ddlbranch.SelectedValue);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                gvModule.DataSource = dt;
                gvModule.DataBind();
            }

            con.Close();

        }

        protected void gvModule_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                // Get the data item
                DataRowView drv = (DataRowView)e.Row.DataItem;

                // Find the checkboxes
                CheckBox chkView = (CheckBox)e.Row.FindControl("chkAction");

                // Set Checked = false if null or 0
                chkView.Checked = drv["Permission_Status"] != DBNull.Value && Convert.ToBoolean(drv["Permission_Status"]);
            }
        }

        protected void ddlbranch_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadUsersByBranch();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            con = conn.openConnection();
            {
                foreach (GridViewRow row in gvModule.Rows)
                {
                    if (row.RowType == DataControlRowType.DataRow)
                    {
                        int branchId = Convert.ToInt32(gvModule.DataKeys[row.RowIndex].Value);

                        CheckBox chkPermission = (CheckBox)row.FindControl("chkAction");
                        bool permissionStatus = chkPermission.Checked;

                        using (SqlCommand cmd = new SqlCommand("sp_UserToBranchPermission_InsertUpdate", con))
                        {
                            cmd.CommandType = CommandType.StoredProcedure;

                            cmd.Parameters.Add("@User_ID", SqlDbType.BigInt).Value = Convert.ToInt64(ddlbranch.SelectedValue);

                            cmd.Parameters.Add("@Branch_ID", SqlDbType.BigInt).Value = branchId;

                            cmd.Parameters.Add("@Permission_Status", SqlDbType.Bit).Value = permissionStatus;

                            cmd.ExecuteNonQuery();
                        }
                    }
                }

                ScriptManager.RegisterStartupScript(this, this.GetType(),
                    "alert", "alert('Save Successfully!');", true);
            }

        }
    }
}