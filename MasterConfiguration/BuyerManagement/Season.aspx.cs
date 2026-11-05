using Nexa_ERP.Connection;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.MasterConfiguration.BuyerManagement
{
    public partial class Season : System.Web.UI.Page
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
                ShowList();
                LoadSeasonList();
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
        //  LOAD SEASON LIST (Code/Name + Status filter)
        // ================================================================
        private void LoadSeasonList()
        {
            try
            {
                string query = @"
                    SELECT  SeasonID AS SeasonId, SeasonCode, SeasonName,
                            CAST(ISNULL(IsActive, 0) AS BIT) AS IsActive, CreatedDate
                    FROM    Season
                    WHERE   1 = 1";

                string search = txtSearch.Text.Trim();
                if (search.Length > 0)
                    query += " AND (SeasonName LIKE @Search OR SeasonCode LIKE @Search)";

                int status = -1;
                int.TryParse(ddlStatusFilter.SelectedValue, out status);
                if (status == 0 || status == 1)
                    query += " AND ISNULL(IsActive, 0) = @IsActive";

                query += " ORDER BY SeasonName";

                using (ConScope cs = new ConScope(conn.openConnection()))
                using (SqlCommand cmd = new SqlCommand(query, cs.Con))
                {
                    if (search.Length > 0)
                        cmd.Parameters.Add("@Search", SqlDbType.NVarChar, 200).Value = "%" + search + "%";

                    if (status == 0 || status == 1)
                        cmd.Parameters.Add("@IsActive", SqlDbType.Bit).Value = (status == 1);

                    DataTable dt = new DataTable();
                    new SqlDataAdapter(cmd).Fill(dt);

                    GridView1.DataSource = dt;
                    GridView1.DataBind();
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
            LoadSeasonList();
        }

        protected void btnClearFilter_Click(object sender, EventArgs e)
        {
            txtSearch.Text = string.Empty;
            ddlStatusFilter.SelectedIndex = 0;
            LoadSeasonList();
        }

        // ================================================================
        //  GRIDVIEW : Edit / Delete
        // ================================================================
        protected void GridView1_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int seasonId;
            if (!int.TryParse(Convert.ToString(e.CommandArgument), out seasonId)) return;

            if (e.CommandName == "EditRow")
            {
                LoadSeasonForEdit(seasonId);
            }
            else if (e.CommandName == "DeleteRow")
            {
                DeleteSeason(seasonId);
            }
        }

        private void LoadSeasonForEdit(int seasonId)
        {
            try
            {
                using (ConScope cs = new ConScope(conn.openConnection()))
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT SeasonID, SeasonCode, SeasonName, IsActive FROM Season WHERE SeasonID = @SeasonID", cs.Con))
                {
                    cmd.Parameters.Add("@SeasonID", SqlDbType.Int).Value = seasonId;

                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (!r.Read())
                        {
                            ShowMessage("Season not found!");
                            return;
                        }

                        hfSeasonId.Value = r["SeasonID"].ToString();
                        txtSeasonCode.Text = r["SeasonCode"] != DBNull.Value ? r["SeasonCode"].ToString() : string.Empty;
                        txtSeasonName.Text = r["SeasonName"] != DBNull.Value ? r["SeasonName"].ToString() : string.Empty;
                        chkActive.Checked = r["IsActive"] != DBNull.Value && Convert.ToBoolean(r["IsActive"]);
                    }
                }

                ShowEntry();
            }
            catch (Exception ex)
            {
                ShowMessage(ex.Message);
            }
        }

        private void DeleteSeason(int seasonId)
        {
            try
            {
                using (ConScope cs = new ConScope(conn.openConnection()))
                using (SqlCommand cmd = new SqlCommand("Pro_Season_Delete", cs.Con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@SeasonID", SqlDbType.Int).Value = seasonId;
                    cmd.ExecuteNonQuery();
                }

                ShowMessage("Deleted Successfully!");
                LoadSeasonList();
            }
            catch (SqlException ex)
            {
                // 547 = Foreign key conflict (অন্য table এ এই Season ব্যবহার হচ্ছে)
                if (ex.Number == 547)
                    ShowMessage("This season is already in use. You cannot delete it.");
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
            LoadSeasonList();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ClearForm();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            // ---------- Validation ----------
            string code = txtSeasonCode.Text.Trim();
            string name = txtSeasonName.Text.Trim();

            if (code == "") { ShowMessage("Season Code is required!"); return; }
            if (name == "") { ShowMessage("Season Name is required!"); return; }

            int seasonId = 0;
            int.TryParse(hfSeasonId.Value, out seasonId);

            // ---------- Save / Update ----------
            try
            {
                using (ConScope cs = new ConScope(conn.openConnection()))
                using (SqlCommand cmd = new SqlCommand("Pro_Season_SaveUpdate", cs.Con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.Add("@SeasonID", SqlDbType.Int).Value = seasonId;
                    cmd.Parameters.Add("@SeasonCode", SqlDbType.NVarChar, 50).Value = code;
                    cmd.Parameters.Add("@SeasonName", SqlDbType.NVarChar, 150).Value = name;
                    cmd.Parameters.Add("@IsActive", SqlDbType.Bit).Value = chkActive.Checked;

                    cmd.ExecuteNonQuery();
                }

                ShowMessage(seasonId == 0 ? "Saved Successfully!" : "Updated Successfully!");

                ClearForm();
                ShowList();
                LoadSeasonList();
            }
            catch (Exception ex)
            {
                ShowMessage(ex.Message);
            }
        }

        // ================================================================
        //  HELPERS
        // ================================================================
        private void ClearForm()
        {
            hfSeasonId.Value = "0";
            txtSeasonCode.Text = string.Empty;
            txtSeasonName.Text = string.Empty;
            chkActive.Checked = true;
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