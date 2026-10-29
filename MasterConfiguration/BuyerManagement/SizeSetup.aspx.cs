using Nexa_ERP.Connection;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.MerchandisingMarketing.BasicSetup
{
    public partial class SizeSetup : System.Web.UI.Page
    {
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();

        // openConnection() shared connection ফেরত দিলে Dispose না করে শুধু Close করা হচ্ছে।
        private sealed class ConScope : IDisposable
        {
            public SqlConnection Con { get; private set; }
            public ConScope(SqlConnection con) { Con = con; }
            public void Dispose()
            {
                if (Con != null && Con.State != ConnectionState.Closed) Con.Close();
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Login user (আপনার project এর Session key অনুযায়ী পরিবর্তন করুন)
                hfUserId.Value = Session["UserId"] != null ? Session["UserId"].ToString() : "0";

                ShowList();
                LoadSizeList();
            }
        }

        // ================================================================
        //  PANEL SWITCH
        // ================================================================
        private void ShowList()
        {
            pnlList.Visible = true;
            pnlEntry.Visible = false;
        }

        private void ShowEntry()
        {
            pnlList.Visible = false;
            pnlEntry.Visible = true;
        }

        // ================================================================
        //  LOAD SIZE LIST (দুইটা Grid এ একসাথে bind হবে)
        //  Search : SizeCode / SizeName / SizeRange,  Filter : Status
        // ================================================================
        private void LoadSizeList()
        {
            try
            {
                string search = txtSearch.Text.Trim();

                int status = -1;
                int.TryParse(ddlStatusFilter.SelectedValue, out status);

                string query = @"
                    SELECT  SizeID, SizeCode, SizeName, SizeRange, SortOrder,
                            CAST(ISNULL(IsActive, 0) AS BIT) AS IsActive
                    FROM    SizeMaster
                    WHERE   1 = 1";

                if (search.Length > 0)
                    query += " AND (SizeCode LIKE @Search OR SizeName LIKE @Search OR SizeRange LIKE @Search)";

                if (status != -1)
                    query += " AND ISNULL(IsActive, 0) = @IsActive";

                query += " ORDER BY SortOrder, SizeName";

                using (ConScope cs = new ConScope(conn.openConnection()))
                using (SqlCommand cmd = new SqlCommand(query, cs.Con))
                {
                    if (search.Length > 0)
                        cmd.Parameters.Add("@Search", SqlDbType.NVarChar, 200).Value = "%" + search + "%";

                    if (status != -1)
                        cmd.Parameters.Add("@IsActive", SqlDbType.Bit).Value = (status == 1);

                    DataTable dt = new DataTable();
                    new SqlDataAdapter(cmd).Fill(dt);

                    // List panel grid
                    GridView1.DataSource = dt;
                    GridView1.DataBind();

                    // Entry panel grid (Save button এর নিচে)
                    GridView2.DataSource = dt;
                    GridView2.DataBind();
                }
            }
            catch (Exception ex)
            {
                ShowMessage(ex.Message);
            }
        }

        // ================================================================
        //  LIST PANEL EVENTS
        // ================================================================
        protected void btnAddNew_Click(object sender, EventArgs e)
        {
            ClearForm();
            ShowEntry();
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadSizeList();
        }

        protected void btnClearFilter_Click(object sender, EventArgs e)
        {
            txtSearch.Text = string.Empty;
            ddlStatusFilter.SelectedIndex = 0;
            LoadSizeList();
        }

        // ================================================================
        //  GRIDVIEW : Edit / Delete (GridView1 ও GridView2 দুইটারই handler)
        // ================================================================
        protected void Grid_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int sizeId;
            if (!int.TryParse(Convert.ToString(e.CommandArgument), out sizeId)) return;

            if (e.CommandName == "EditRow")
            {
                LoadSizeForEdit(sizeId);
            }
            else if (e.CommandName == "DeleteRow")
            {
                DeleteSize(sizeId);
            }
        }

        private void LoadSizeForEdit(int sizeId)
        {
            try
            {
                using (ConScope cs = new ConScope(conn.openConnection()))
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT SizeID, SizeCode, SizeName, SizeRange, SortOrder, IsActive FROM SizeMaster WHERE SizeID = @SizeID", cs.Con))
                {
                    cmd.Parameters.Add("@SizeID", SqlDbType.Int).Value = sizeId;

                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (!r.Read())
                        {
                            ShowMessage("Size not found!");
                            return;
                        }

                        hfSizeId.Value = r["SizeID"].ToString();
                        txtSizeCode.Text = r["SizeCode"] != DBNull.Value ? r["SizeCode"].ToString() : string.Empty;
                        txtSizeName.Text = r["SizeName"] != DBNull.Value ? r["SizeName"].ToString() : string.Empty;
                        txtSizeRange.Text = r["SizeRange"] != DBNull.Value ? r["SizeRange"].ToString() : string.Empty;
                        txtSortOrder.Text = r["SortOrder"] != DBNull.Value ? r["SortOrder"].ToString() : "0";
                        chkIsActive.Checked = r["IsActive"] != DBNull.Value && Convert.ToBoolean(r["IsActive"]);
                    }
                }

                ShowEntry();
            }
            catch (Exception ex)
            {
                ShowMessage(ex.Message);
            }
        }

        // Pro_Size_Delete
        private void DeleteSize(int sizeId)
        {
            try
            {
                using (ConScope cs = new ConScope(conn.openConnection()))
                using (SqlCommand cmd = new SqlCommand("Pro_Size_Delete", cs.Con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@SizeID", SqlDbType.Int).Value = sizeId;
                    cmd.ExecuteNonQuery();
                }

                // যেটা edit হচ্ছিল সেটাই delete হলে form clear করে দাও
                if (hfSizeId.Value == sizeId.ToString())
                    ClearForm();

                ShowMessage("Deleted Successfully!");
                LoadSizeList();
            }
            catch (SqlException ex)
            {
                // 547 = Foreign key conflict (অন্য table এ এই Size ব্যবহার হচ্ছে)
                if (ex.Number == 547)
                    ShowMessage("This size is already in use. You cannot delete it.");
                else
                    ShowMessage(ex.Message);
            }
            catch (Exception ex)
            {
                ShowMessage(ex.Message);
            }
        }

        // ================================================================
        //  ENTRY PANEL EVENTS
        // ================================================================
        protected void btnBackToList_Click(object sender, EventArgs e)
        {
            ClearForm();
            ShowList();
            LoadSizeList();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ClearForm();
        }

        // Pro_Size_SaveUpdate
        protected void btnSave_Click(object sender, EventArgs e)
        {
            // ---------- Validation ----------
            string code = txtSizeCode.Text.Trim();
            string name = txtSizeName.Text.Trim();
            string sizeRange = txtSizeRange.Text.Trim();

            if (code == "") { ShowMessage("Size Code is required!"); return; }
            if (name == "") { ShowMessage("Size Name is required!"); return; }

            int sortOrder = 0;
            if (!int.TryParse(txtSortOrder.Text.Trim(), out sortOrder)) { ShowMessage("Sort Order must be a valid number!"); return; }

            int sizeId = 0;
            int.TryParse(hfSizeId.Value, out sizeId);

            // ---------- Save / Update ----------
            try
            {
                using (ConScope cs = new ConScope(conn.openConnection()))
                using (SqlCommand cmd = new SqlCommand("Pro_Size_SaveUpdate", cs.Con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.Add("@SizeID", SqlDbType.Int).Value = sizeId;
                    cmd.Parameters.Add("@SizeCode", SqlDbType.NVarChar, 50).Value = code;
                    cmd.Parameters.Add("@SizeName", SqlDbType.NVarChar, 100).Value = name;
                    cmd.Parameters.Add("@SizeRange", SqlDbType.NVarChar, 100).Value = sizeRange == "" ? (object)DBNull.Value : sizeRange;
                    cmd.Parameters.Add("@SortOrder", SqlDbType.Int).Value = sortOrder;
                    cmd.Parameters.Add("@IsActive", SqlDbType.Bit).Value = chkIsActive.Checked;

                    cmd.ExecuteNonQuery();
                }

                ShowMessage(sizeId == 0 ? "Saved Successfully!" : "Updated Successfully!");

                // Save এর পরে List panel এ যাবে না: form clear হবে, Entry panel এই থাকবে,
                // আর নিচের GridView2 refresh হবে।
                ClearForm();
                ShowEntry();
                LoadSizeList();
            }
            catch (Exception ex)
            {
                // Duplicate Size Code এর মত SP error এখানে দেখাবে, form খোলা থাকবে
                ShowMessage(ex.Message);
            }
        }

        // ================================================================
        //  HELPERS
        // ================================================================
        private void ClearForm()
        {
            hfSizeId.Value = "0";
            txtSizeCode.Text = string.Empty;
            txtSizeName.Text = string.Empty;
            txtSizeRange.Text = string.Empty;
            txtSortOrder.Text = "0";
            chkIsActive.Checked = true;
        }

        private void ShowMessage(string message)
        {
            string safe = (message ?? string.Empty)
                .Replace("\\", "\\\\")
                .Replace("'", "\\'")
                .Replace("\r", " ")
                .Replace("\n", " ");

            ScriptManager.RegisterStartupScript(this, this.GetType(), Guid.NewGuid().ToString(), "alert('" + safe + "');", true);
        }
    }
}
