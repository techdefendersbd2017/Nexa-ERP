using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP
{
    public partial class DashboardNew : System.Web.UI.Page
    {
        SqlConnection con;
        Database_Connection conn = new Database_Connection();
        SqlCommand cmd;

        string User_ID;
        string Role_ID;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["User_ID"] == null)
            {
                Response.Redirect("~/Default.aspx");
                return;
            }
            User_ID = Session["User_ID"].ToString();
            try
            {
                con = conn.openConnection();
                string sql = "SELECT * FROM User_Information WHERE User_ID = @UserID";
                cmd = new SqlCommand(sql, con);
                cmd.Parameters.AddWithValue("@UserID", User_ID);

                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        lblUser.Text = reader[4].ToString();
                        lblUserName.Text = reader[4].ToString();
                    }
                }
                reader.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
            finally
            {
                CloseConnection();
            }
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
                con = conn.openConnection();
                string sql = "SELECT * FROM UserToRolePermission WHERE User_ID = @UserID AND Permission_Status = 1";
                cmd = new SqlCommand(sql, con);
                cmd.Parameters.AddWithValue("@UserID", User_ID);

                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        Role_ID = reader[1].ToString();
                    }
                }
                reader.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
            finally
            {
                CloseConnection();
            }
        }

        /* ============================================================================
           LoadFullTreeMenu -- এখন আর Module_Information / Menu_Information /
           Form_Information থেকে আলাদাভাবে ডাটা টানা হচ্ছে না।
           পুরো ট্রি একটামাত্র কোয়েরিতে dbo.ChartOfMenus থেকে লোড হচ্ছে,
           শুধু Is_Active = 1 শর্তে, এবং Node_Type / Parent_ID / COA_ID
           দিয়ে ৩-লেভেল (MODULE -> MENU -> FORM) hierarchy বানানো হচ্ছে।
           ============================================================================ */
        private void LoadFullTreeMenu()
        {
            using (SqlConnection con = conn.openConnection())
            {
                DataTable dtChart = new DataTable();
                using (SqlCommand cmdChart = new SqlCommand(
                    @"SELECT COA_ID, Parent_ID, Node_Code, Node_Name, Node_Type, Node_Level,
                             Reference_ID, Icon_Class, URL, SortingNo, Is_Active, Is_Leaf
                      FROM dbo.ChartOfMenus
                      WHERE Is_Active = 1
                      ORDER BY Node_Level, Parent_ID, SortingNo", con))
                {
                    new SqlDataAdapter(cmdChart).Fill(dtChart);
                }

                DataTable dtModules = dtChart.Clone();
                DataTable dtMenus = dtChart.Clone();
                DataTable dtForms = dtChart.Clone();

                foreach (DataRow row in dtChart.Rows)
                {
                    switch (row["Node_Type"].ToString())
                    {
                        case "MODULE":
                            dtModules.ImportRow(row);
                            break;
                        case "MENU":
                            dtMenus.ImportRow(row);
                            break;
                        case "FORM":
                            dtForms.ImportRow(row);
                            break;
                    }
                }

                dtModules.Columns.Add("Menus", typeof(DataTable));
                dtMenus.Columns.Add("Forms", typeof(DataTable));

                foreach (DataRow menuRow in dtMenus.Rows)
                {
                    DataTable formsTable = dtForms.Clone();
                    int menuCoaId = Convert.ToInt32(menuRow["COA_ID"]);

                    foreach (DataRow formRow in dtForms.Rows)
                    {
                        if (formRow["Parent_ID"] != DBNull.Value &&
                            Convert.ToInt32(formRow["Parent_ID"]) == menuCoaId)
                        {
                            formsTable.ImportRow(formRow);
                        }
                    }
                    menuRow["Forms"] = formsTable;
                }

                foreach (DataRow moduleRow in dtModules.Rows)
                {
                    DataTable menusTable = dtMenus.Clone();
                    int moduleCoaId = Convert.ToInt32(moduleRow["COA_ID"]);

                    foreach (DataRow menuRow in dtMenus.Rows)
                    {
                        if (menuRow["Parent_ID"] != DBNull.Value &&
                            Convert.ToInt32(menuRow["Parent_ID"]) == moduleCoaId)
                        {
                            menusTable.ImportRow(menuRow);
                        }
                    }
                    moduleRow["Menus"] = menusTable;
                }

                rptModules.DataSource = dtModules;
                rptModules.DataBind();
            }
        }

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

        private void CloseConnection()
        {
            if (con != null && con.State == ConnectionState.Open)
                con.Close();
        }
    }
}
