using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
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

        // ===== আগে TreeMenuHelper.cs -তে ছিল, এখন এই ফাইলেই private ক্লাস হিসেবে আছে =====
        private class TreeNode
        {
            public string Id { get; set; }
            public string ParentId { get; set; }
            public string Name { get; set; }
            public string IconClass { get; set; }
            public string Url { get; set; }
            public bool IsLeaf { get; set; }
            public List<TreeNode> Children { get; set; } = new List<TreeNode>();
        }

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
        private void LoadFullTreeMenu()
        {
            List<TreeNode> flatList = new List<TreeNode>();

            using (SqlConnection con = conn.openConnection())
            {
                DataTable dtChart = new DataTable();
                using (SqlCommand cmdChart = new SqlCommand(
                    @"SELECT COA_ID, Parent_ID, Node_Name, Icon_Class, URL, Is_Leaf
                      FROM dbo.ChartOfMenus
                      WHERE Is_Active = 1
                      ORDER BY Node_Level, Parent_ID, SortingNo", con))
                {
                    new SqlDataAdapter(cmdChart).Fill(dtChart);
                }

                foreach (DataRow row in dtChart.Rows)
                {
                    flatList.Add(new TreeNode
                    {
                        Id = row["COA_ID"].ToString(),
                        ParentId = row["Parent_ID"] == DBNull.Value ? null : row["Parent_ID"].ToString(),
                        Name = row["Node_Name"].ToString(),
                        IconClass = row["Icon_Class"] == DBNull.Value || string.IsNullOrEmpty(row["Icon_Class"].ToString())
                                        ? "bi bi-dot"
                                        : row["Icon_Class"].ToString(),
                        Url = row["URL"] == DBNull.Value ? null : row["URL"].ToString(),
                        IsLeaf = row["Is_Leaf"] != DBNull.Value && Convert.ToBoolean(row["Is_Leaf"])
                    });
                }
            }

            List<TreeNode> tree = BuildTree(flatList, null);
            ltrMenu.Text = RenderTree(tree, "tree-root");
        }

        // ফ্ল্যাট লিস্ট থেকে Parent_ID মিলিয়ে recursive tree বানায় — depth যত গভীরই হোক চলবে
        private List<TreeNode> BuildTree(List<TreeNode> flatList, string rootParentId)
        {
            var roots = flatList.Where(n => n.ParentId == rootParentId).ToList();

            foreach (var node in roots)
            {
                node.Children = BuildTree(flatList, node.Id);
            }

            return roots;
        }

        // Tree থেকে nested <ul><li> HTML বানায়। cssClass শুধু সবচেয়ে বাইরের <ul>-এ বসে (যেমন "tree-root")
        private string RenderTree(List<TreeNode> nodes, string cssClass = null)
        {
            var sb = new StringBuilder();
            sb.Append(cssClass != null ? $"<ul class='{cssClass}'>" : "<ul>");

            foreach (var node in nodes)
            {
                sb.Append("<li>");

                if (node.IsLeaf)
                {
                    // এটা একটা form/page — ক্লিক করলে iframe-এ লোড হবে
                    sb.AppendFormat(
                        "<a href='Deahboard.aspx?form={0}' data-formurl='{1}' onclick=\"return loadPage(event, this);\">" +
                        "<i class='{2} me-1'></i>{3}</a>",
                        HttpUtility.UrlEncode(node.Url),
                        HttpUtility.HtmlEncode(node.Url),
                        node.IconClass,
                        HttpUtility.HtmlEncode(node.Name));
                }
                else
                {
                    // এটা folder-node (Module/Menu/SubMenu...) — expand/collapse হবে
                    sb.AppendFormat(
                        "<a onclick=\"toggleMenu('node_{0}', this); return false;\" " +
                        "class='d-flex justify-content-between align-items-center'>" +
                        "<span><i class='{1} me-1'></i>{2}</span>" +
                        "<i class='bi bi-chevron-down toggle-icon'></i></a>",
                        node.Id, node.IconClass, HttpUtility.HtmlEncode(node.Name));

                    if (node.Children != null && node.Children.Count > 0)
                    {
                        sb.AppendFormat("<div id='node_{0}' class='submenu' style='display:none; padding-left:20px;'>", node.Id);
                        sb.Append(RenderTree(node.Children)); // <-- recursion, তাই depth automatic
                        sb.Append("</div>");
                    }
                }

                sb.Append("</li>");
            }

            sb.Append("</ul>");
            return sb.ToString();
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
