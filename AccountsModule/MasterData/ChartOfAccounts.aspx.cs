using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.AccountsModule.MasterData
{
    public partial class ChartOfAccounts : System.Web.UI.Page
    {
        SqlConnection con;
        DatabaseConectionAccounts conn = new DatabaseConectionAccounts();
        SqlCommand cmd;
        DataTable dt = new DataTable();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadAllData();
            }
        }
        private void LoadAllData()
        {
            LoadDataFromDatabase();
            LoadTree();
        }
        private void LoadDataFromDatabase()
        {
            dt.Clear();
            // আপনার কানেকশন স্ট্রিং এখানে হবে

            con = conn.openConnection();
            {
                string query = @"SELECT AccountsTypeID, AccountsTypeName, ParentID FROM ChartOfAccounts";
                SqlDataAdapter da = new SqlDataAdapter(query, con);
                da.Fill(dt);
            }
            con.Close();
        }

        private void LoadTree()
        {
            tvAccounts.Nodes.Clear();

            // Root nodes (Level 1)
            DataRow[] roots = dt.Select("ParentID = 0");

            foreach (DataRow row in roots)
            {
                TreeNode node = new TreeNode();
                node.Text = row["AccountsTypeName"].ToString();
                node.Value = row["AccountsTypeID"].ToString(); // Tag এর বদলে Value ব্যবহার হয়

                tvAccounts.Nodes.Add(node);

                // চাইল্ড নোড কল করার সময় লেভেল ২ পাস করছি
                AddChildNodes(node, Convert.ToInt32(row["AccountsTypeID"]), 2);
            }

            tvAccounts.ExpandAll();
        }

        private void AddChildNodes(TreeNode parentNode, int parentId, int level)
        {
            DataRow[] children = dt.Select("ParentID = " + parentId);

            foreach (DataRow row in children)
            {
                int currentId = Convert.ToInt32(row["AccountsTypeID"]);
                string currentName = row["AccountsTypeName"].ToString();
                string displayText;

                // যদি লেভেল ৫ বা তার বেশি হয়, তবে ID - Name দেখাবে (আপনার লজিক অনুযায়ী)
                if (level >= 5)
                {
                    displayText = currentId + " - " + currentName;
                }
                else
                {
                    displayText = currentName;
                }

                TreeNode childNode = new TreeNode();
                childNode.Text = displayText;
                childNode.Value = currentId.ToString();

                parentNode.ChildNodes.Add(childNode);

                // পরবর্তী ধাপের জন্য level + 1 পাঠিয়ে রিকার্সিভ কল
                AddChildNodes(childNode, currentId, level + 1);
            }
        }

        protected void tvAccounts_SelectedNodeChanged(object sender, EventArgs e)
        {
            TreeNode selectedNode = tvAccounts.SelectedNode;
            if (selectedNode != null)
            {
                // Current ID
                txtChildID.Text = selectedNode.Value;

                // Parent ID
                if (selectedNode.Parent != null)
                {
                    txtParentID.Text = selectedNode.Parent.Value;
                }
                else
                {
                    // Root node (Parent নাই)
                    txtParentID.Text = "0";
                }
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                // কানেকশন ওপেন (আপনার কানেকশন ক্লাস অনুযায়ী)
                con = conn.openConnection();
                {

                    // কমান্ড সেটআপ
                    SqlCommand cmd = new SqlCommand("Chat_Of_Accounts_Insert", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    // প্যারামিটার অ্যাড করা (ASPX কন্ট্রোল আইডি অনুযায়ী)
                    // নোট: আপনার ডেক্সটপ কোডে textBox2 ছিল ParentID, textBox3 ছিল Name
                    cmd.Parameters.AddWithValue("@ParentID", txtChildID.Text.Trim());
                    cmd.Parameters.AddWithValue("@AccountsTypeName", txtAccountName.Text.Trim());
                    cmd.Parameters.AddWithValue("@VoucherRefName", txtVoucherRef.Text.Trim());

                    cmd.ExecuteNonQuery();

                    // সফলতার মেসেজ (JavaScript Alert এর মাধ্যমে)
                    string message = "Your information has been saved successfully.";
                    ClientScript.RegisterStartupScript(this.GetType(), "alert", $"alert('{message}');", true);
                }
                con.Close() ;
                // ডাটা পুনরায় লোড করা
                LoadAllData();// আপনার আগের মেথড যা TreeView রিফ্রেশ করে
            }
            catch (Exception ex)
            {
                // এরর মেসেজ
                string error = ex.Message.Replace("'", "");
                ClientScript.RegisterStartupScript(this.GetType(), "error", $"alert('Error: {error}');", true);
            }
        }

        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            if(btnUpdate.Text=="Edit")
            {
                try
                {
                    string sql = "Select * from ChartOfAccounts where AccountsTypeID ='" + txtChildID.Text + "'";
                    con = conn.openConnection();
                    cmd = new SqlCommand(sql, con);
                    SqlDataReader reader = cmd.ExecuteReader();
                    if (reader.HasRows)
                    {
                        while (reader.Read())
                        {
                            txtAccountName.Text = reader[1].ToString();

                        }
                    }
                    else
                    {
                        txtAccountName.Text = string.Empty;
                    }
                    con.Close();
                }
                catch (Exception ex)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
                }
            }
            Button1.Visible=true;
            btnUpdate.Visible=false;
        }

        protected void Button1_Click(object sender, EventArgs e)
        {
            //if (btnUpdate.Text == "Update")
            {
                try
                {
                    // কানেকশন ওপেন (আপনার কানেকশন ক্লাস অনুযায়ী)
                    con = conn.openConnection();
                    {

                        // কমান্ড সেটআপ
                        SqlCommand cmd = new SqlCommand("Chat_Of_Accounts_Update", con);
                        cmd.CommandType = CommandType.StoredProcedure;

                        // প্যারামিটার অ্যাড করা (ASPX কন্ট্রোল আইডি অনুযায়ী)
                        // নোট: আপনার ডেক্সটপ কোডে textBox2 ছিল ParentID, textBox3 ছিল Name
                        cmd.Parameters.AddWithValue("@AccountsTypeID", txtChildID.Text.Trim());
                        cmd.Parameters.AddWithValue("@AccountsTypeName", txtAccountName.Text.Trim());

                        cmd.ExecuteNonQuery();

                        // সফলতার মেসেজ (JavaScript Alert এর মাধ্যমে)
                        string message = "Your information has been saved successfully.";
                        ClientScript.RegisterStartupScript(this.GetType(), "alert", $"alert('{message}');", true);
                    }
                    con.Close();
                    // ডাটা পুনরায় লোড করা
                    LoadAllData();// আপনার আগের মেথড যা TreeView রিফ্রেশ করে
                }
                catch (Exception ex)
                {
                    // এরর মেসেজ
                    string error = ex.Message.Replace("'", "");
                    ClientScript.RegisterStartupScript(this.GetType(), "error", $"alert('Error: {error}');", true);
                }
            }
    }

        protected void btnExpand_Click(object sender, EventArgs e)
        {
            tvAccounts.ExpandAll();
        }

        protected void btnCollapse_Click(object sender, EventArgs e)
        {
            tvAccounts.CollapseAll();
            // Optional: Keep the first level visible
            foreach (TreeNode node in tvAccounts.Nodes)
            {
                node.Expand();
            }
        }

        protected void btnOffDuty_Click(object sender, EventArgs e)
        {
            // Clear selection
            if (tvAccounts.SelectedNode != null)
            {
                tvAccounts.SelectedNode.Selected = false;
            }

            // Collapse everything
            tvAccounts.CollapseAll();

            // Custom: Redirect or clear details view if necessary
            // Response.Redirect(Request.RawUrl);
        }
    }
}