using Nexa_ERP.Connection;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.AccountsModule.MasterData
{
    public partial class ChartOfMenus : System.Web.UI.Page
    {
        SqlConnection con;
        Database_Connection conn = new Database_Connection();
        DataTable dt = new DataTable();

        protected void Page_Load(object sender, EventArgs e)
        {
            // dt is an instance field, so it is empty on every new request/postback
            // (ASP.NET creates a fresh Page object each time). It must be re-populated
            // on EVERY postback too, otherwise event handlers like
            // tvAccounts_SelectedNodeChanged (which run after Page_Load, on the same
            // postback that loaded the tree row) will see a DataTable with no columns
            // at all and dt.Select("COA_ID = ...") throws:
            //   "Cannot find column [COA_ID]".
            LoadDataFromDatabase();

            if (!IsPostBack)
            {
                LoadTree();     // build the tree only on first load; ViewState keeps
                                // the TreeView's nodes/expansion/selection afterwards
                ClearForm();
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

            con = conn.openConnection();
            try
            {
                string query = @"SELECT * FROM ChartOfMenus
                                  WHERE Is_Active = 1
                                  ORDER BY SortingNo";
                SqlDataAdapter da = new SqlDataAdapter(query, con);
                da.Fill(dt);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open)
                    con.Close();
            }
        }

        private void LoadTree()
        {
            tvAccounts.Nodes.Clear();

            if (dt.Rows.Count == 0)
                return;

            // "=" can't be used to compare against NULL in DataTable.Select(), it must be "IS NULL".
            // Some rows may have Parent_ID = NULL, others Parent_ID = 0 for roots, so both are covered.
            DataRow[] roots = dt.Select("Parent_ID IS NULL OR Parent_ID = 0", "SortingNo");

            foreach (DataRow row in roots)
            {
                TreeNode node = new TreeNode();
                node.Text = row["Node_Name"].ToString();
                node.Value = row["COA_ID"].ToString();
                node.ToolTip = row["Node_Code"] == DBNull.Value ? "" : row["Node_Code"].ToString();

                tvAccounts.Nodes.Add(node);

                AddChildNodes(node, Convert.ToInt32(row["COA_ID"]), 2);
            }

            tvAccounts.ExpandAll();
        }

        private void AddChildNodes(TreeNode parentNode, int parentId, int level)
        {
            DataRow[] children = dt.Select("Parent_ID = " + parentId, "SortingNo");

            foreach (DataRow row in children)
            {
                int currentId = Convert.ToInt32(row["COA_ID"]);
                string currentName = row["Node_Name"].ToString();
                string currentCode = row["Node_Code"] == DBNull.Value ? "" : row["Node_Code"].ToString();

                string displayText = (level >= 5)
                    ? (string.IsNullOrEmpty(currentCode) ? currentId.ToString() : currentCode) + " - " + currentName
                    : currentName;

                TreeNode childNode = new TreeNode();
                childNode.Text = displayText;
                childNode.Value = currentId.ToString();
                childNode.ToolTip = currentCode;

                parentNode.ChildNodes.Add(childNode);

                AddChildNodes(childNode, currentId, level + 1);
            }
        }

        protected void tvAccounts_SelectedNodeChanged(object sender, EventArgs e)
        {
            TreeNode selectedNode = tvAccounts.SelectedNode;
            if (selectedNode == null)
                return;

            int coaId = Convert.ToInt32(selectedNode.Value);
            DataRow[] rows = dt.Select("COA_ID = " + coaId);

            if (rows.Length == 0)
                return;

            DataRow row = rows[0];

            txtCoaID.Text = row["COA_ID"].ToString();
            txtParentID.Text = row["Parent_ID"] == DBNull.Value ? "0" : row["Parent_ID"].ToString();
        }

        // Save = insert a NEW node. If a node is currently selected in the tree,
        // the new node is created as its CHILD (txtParentID carries that context);
        // otherwise it is created as a ROOT node (Parent_ID = 0).
        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
                return;

            try
            {
                int parentId = string.IsNullOrWhiteSpace(txtCoaID.Text) ? 0 : Convert.ToInt32(txtCoaID.Text.Trim());

                con = conn.openConnection();
                try
                {
                    SqlCommand cmd = new SqlCommand("ChartOfMenus_Insert", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@Parent_ID", parentId);
                    cmd.Parameters.AddWithValue("@Node_Name", txtAccountName.Text.Trim());
                    cmd.Parameters.AddWithValue("@Node_Type", string.IsNullOrWhiteSpace(txtNodeType.Text) ? (object)"Account" : txtNodeType.Text.Trim());
                    cmd.Parameters.AddWithValue("@Reference_ID", string.IsNullOrWhiteSpace(txtReferenceID.Text) ? (object)DBNull.Value : Convert.ToInt32(txtReferenceID.Text.Trim()));
                    cmd.Parameters.AddWithValue("@Icon_Class", string.IsNullOrWhiteSpace(txtIconClass.Text) ? (object)DBNull.Value : txtIconClass.Text.Trim());
                    cmd.Parameters.AddWithValue("@URL", string.IsNullOrWhiteSpace(txtURL.Text) ? (object)DBNull.Value : txtURL.Text.Trim());
                    cmd.Parameters.AddWithValue("@SortingNo", string.IsNullOrWhiteSpace(txtSortingNo.Text) ? 0 : Convert.ToInt32(txtSortingNo.Text.Trim()));

                    cmd.ExecuteNonQuery();

                    ShowAlert("Account saved successfully.");
                }
                finally
                {
                    if (con != null && con.State == ConnectionState.Open)
                        con.Close();
                }

                LoadAllData();
                ClearForm();
            }
            catch (Exception ex)
            {
                ShowAlert("Error: " + ex.Message.Replace("'", ""));
            }
        }

        // Update = edit the node currently loaded in the form (identified by txtCoaID,
        // which is populated by selecting a node in the tree).
        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
                return;

            if (string.IsNullOrWhiteSpace(txtCoaID.Text))
            {
                ShowAlert("Please select an account from the tree first.");
                return;
            }

            try
            {
                con = conn.openConnection();
                try
                {
                    SqlCommand cmd = new SqlCommand("ChartOfMenus_Update", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@COA_ID", Convert.ToInt32(txtCoaID.Text.Trim()));
                    cmd.Parameters.AddWithValue("@Node_Name", txtAccountName.Text.Trim());
                    cmd.Parameters.AddWithValue("@Node_Type", string.IsNullOrWhiteSpace(txtNodeType.Text) ? (object)"Account" : txtNodeType.Text.Trim());
                    cmd.Parameters.AddWithValue("@Reference_ID", string.IsNullOrWhiteSpace(txtReferenceID.Text) ? (object)DBNull.Value : Convert.ToInt32(txtReferenceID.Text.Trim()));
                    cmd.Parameters.AddWithValue("@Icon_Class", string.IsNullOrWhiteSpace(txtIconClass.Text) ? (object)DBNull.Value : txtIconClass.Text.Trim());
                    cmd.Parameters.AddWithValue("@URL", string.IsNullOrWhiteSpace(txtURL.Text) ? (object)DBNull.Value : txtURL.Text.Trim());
                    cmd.Parameters.AddWithValue("@SortingNo", string.IsNullOrWhiteSpace(txtSortingNo.Text) ? 0 : Convert.ToInt32(txtSortingNo.Text.Trim()));
                    cmd.Parameters.AddWithValue("@Is_Active", chkIsActive.Checked);
                    cmd.Parameters.AddWithValue("@Is_Leaf", chkIsLeaf.Checked);

                    cmd.ExecuteNonQuery();

                    ShowAlert("Account updated successfully.");
                }
                finally
                {
                    if (con != null && con.State == ConnectionState.Open)
                        con.Close();
                }

                LoadAllData();
                ClearForm();
            }
            catch (Exception ex)
            {
                ShowAlert("Error: " + ex.Message.Replace("'", ""));
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtCoaID.Text))
            {
                ShowAlert("Please select an account from the tree first.");
                return;
            }

            int coaId = Convert.ToInt32(txtCoaID.Text.Trim());

            // Don't allow deleting a node that still has children in the loaded data.
            bool hasChildren = dt.Select("Parent_ID = " + coaId).Length > 0;
            if (hasChildren)
            {
                ShowAlert("This account has child accounts. Remove or reassign them before deleting.");
                return;
            }

            try
            {
                con = conn.openConnection();
                try
                {
                    // Soft delete, consistent with the WHERE Is_Active = 1 filter used when loading data.
                    string sql = "UPDATE ChartOfMenus SET Is_Active = 0 WHERE COA_ID = @COA_ID";
                    SqlCommand cmd = new SqlCommand(sql, con);
                    cmd.Parameters.AddWithValue("@COA_ID", coaId);
                    cmd.ExecuteNonQuery();

                    ShowAlert("Account deleted successfully.");
                }
                finally
                {
                    if (con != null && con.State == ConnectionState.Open)
                        con.Close();
                }

                LoadAllData();
                ClearForm();
            }
            catch (Exception ex)
            {
                ShowAlert("Error: " + ex.Message.Replace("'", ""));
            }
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ClearForm();
            if (tvAccounts.SelectedNode != null)
                tvAccounts.SelectedNode.Selected = false;
        }

        private void ClearForm()
        {
            txtCoaID.Text = string.Empty;
            txtParentID.Text = "0";
            txtNodeCode.Text = string.Empty;
            txtAccountName.Text = string.Empty;
            txtNodeType.Text = string.Empty;
            txtNodeLevel.Text = "0";
            txtSortingNo.Text = "0";
            txtReferenceID.Text = string.Empty;
            txtIconClass.Text = string.Empty;
            txtURL.Text = string.Empty;
            chkIsActive.Checked = true;
            chkIsLeaf.Checked = true;
        }

        protected void btnExpand_Click(object sender, EventArgs e)
        {
            tvAccounts.ExpandAll();
        }

        protected void btnCollapse_Click(object sender, EventArgs e)
        {
            tvAccounts.CollapseAll();
            foreach (TreeNode node in tvAccounts.Nodes)
            {
                node.Expand();
            }
        }

        protected void btnOffDuty_Click(object sender, EventArgs e)
        {
            if (tvAccounts.SelectedNode != null)
            {
                tvAccounts.SelectedNode.Selected = false;
            }
            tvAccounts.CollapseAll();
            ClearForm();
        }

        private void ShowAlert(string message)
        {
            string script = "alert('" + message.Replace("'", "") + "');";
            ClientScript.RegisterStartupScript(this.GetType(), "alert" + Guid.NewGuid().ToString("N"), script, true);
        }
    }
}