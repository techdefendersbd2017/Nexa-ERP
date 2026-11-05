using Nexa_ERP.Connection;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.MerchandisingMarketing.BasicSetup
{
    public partial class BuyingAgentSetup : System.Web.UI.Page
    {
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();

        // openConnection() যদি shared connection ফেরত দেয়, using দিয়ে Dispose করলে
        // পরের বার "ConnectionString property has not been initialized" error আসে।
        // তাই Dispose এর বদলে শুধু Close করা হচ্ছে।
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
                LoadAgentList();
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
        //  LOAD AGENT LIST (Search by code / name / country)
        // ================================================================
        private void LoadAgentList()
        {
            try
            {
                string query = @"
                    SELECT  a.AgentID,
                            ISNULL(a.AgentCode, '')     AS AgentCode,
                            ISNULL(a.AgentName, '')     AS AgentName,
                            ISNULL(a.Country, '')       AS Country,
                            ISNULL(a.ContactPerson, '') AS ContactPerson,
                            ISNULL(a.ContactEmail, '')  AS ContactEmail,
                            CAST(ISNULL(a.IsActive, 0) AS BIT) AS IsActive
                    FROM    dbo.Agent a
                    WHERE   1 = 1";

                string search = txtSearch.Text.Trim();
                if (search.Length > 0)
                    query += " AND (a.AgentName LIKE @Search OR a.AgentCode LIKE @Search OR a.Country LIKE @Search)";

                query += " ORDER BY a.AgentName";

                using (ConScope cs = new ConScope(conn.openConnection()))
                using (SqlCommand cmd = new SqlCommand(query, cs.Con))
                {
                    if (search.Length > 0)
                        cmd.Parameters.Add("@Search", SqlDbType.VarChar, 200).Value = "%" + search + "%";

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

        protected void txtSearch_TextChanged(object sender, EventArgs e)
        {
            LoadAgentList();
        }

        protected void btnClearFilter_Click(object sender, EventArgs e)
        {
            txtSearch.Text = string.Empty;
            LoadAgentList();
        }

        // ================================================================
        //  GRIDVIEW : Edit / Delete
        // ================================================================
        protected void GridView1_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            long agentId;
            if (!long.TryParse(Convert.ToString(e.CommandArgument), out agentId)) return;

            if (e.CommandName == "EditRow")
            {
                LoadAgentForEdit(agentId);
            }
            else if (e.CommandName == "DeleteRow")
            {
                DeleteAgent(agentId);
            }
        }

        private void LoadAgentForEdit(long agentId)
        {
            try
            {
                ClearForm();

                using (ConScope cs = new ConScope(conn.openConnection()))
                using (SqlCommand cmd = new SqlCommand(
                    @"SELECT AgentID, AgentCode, AgentName, Country, ContactPerson, ContactEmail, IsActive
                      FROM dbo.Agent WHERE AgentID = @AgentID", cs.Con))
                {
                    cmd.Parameters.Add("@AgentID", SqlDbType.BigInt).Value = agentId;

                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (!r.Read())
                        {
                            ShowMessage("Buying agent not found!");
                            return;
                        }

                        hfBuyingAgentId.Value = r["AgentID"].ToString();

                        txtCode.Text = r["AgentCode"].ToString();
                        txtName.Text = r["AgentName"].ToString();
                        txtCountry.Text = r["Country"].ToString();
                        txtContactPerson.Text = r["ContactPerson"].ToString();
                        txtContactEmail.Text = r["ContactEmail"].ToString();
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

        private void DeleteAgent(long agentId)
        {
            try
            {
                using (ConScope cs = new ConScope(conn.openConnection()))
                using (SqlCommand cmd = new SqlCommand("Pro_BuyingAgent_Delete", cs.Con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@AgentID", SqlDbType.BigInt).Value = agentId;
                    cmd.ExecuteNonQuery();
                }

                ShowMessage("Deleted Successfully!");
                LoadAgentList();
            }
            catch (SqlException ex)
            {
                // 547 = Foreign key conflict (অন্য table এ এই Agent ব্যবহার হচ্ছে)
                if (ex.Number == 547)
                    ShowMessage("This buying agent is already in use. You cannot delete it.");
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
            LoadAgentList();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ClearForm();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            // ---------- Validation ----------
            if (txtCode.Text.Trim() == "") { ShowMessage("Agent Code is required!"); return; }
            if (txtName.Text.Trim() == "") { ShowMessage("Agent Name is required!"); return; }

            long agentId = 0;
            long.TryParse(hfBuyingAgentId.Value, out agentId);

            // ---------- Save / Update ----------
            try
            {
                using (ConScope cs = new ConScope(conn.openConnection()))
                using (SqlCommand cmd = new SqlCommand("Pro_BuyingAgent_SaveUpdate", cs.Con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.Add("@AgentID", SqlDbType.BigInt).Value = agentId;
                    cmd.Parameters.Add("@AgentCode", SqlDbType.VarChar, 50).Value = txtCode.Text.Trim();
                    cmd.Parameters.Add("@AgentName", SqlDbType.VarChar, 200).Value = txtName.Text.Trim();
                    cmd.Parameters.Add("@Country", SqlDbType.VarChar, 100).Value = txtCountry.Text.Trim();
                    cmd.Parameters.Add("@ContactPerson", SqlDbType.VarChar, 150).Value = txtContactPerson.Text.Trim();
                    cmd.Parameters.Add("@ContactEmail", SqlDbType.VarChar, 150).Value = txtContactEmail.Text.Trim();
                    cmd.Parameters.Add("@IsActive", SqlDbType.Bit).Value = chkIsActive.Checked;
                    cmd.Parameters.Add("@UserID", SqlDbType.VarChar, 50).Value = hfUserId.Value;

                    cmd.ExecuteNonQuery();
                }

                ShowMessage(agentId == 0 ? "Saved Successfully!" : "Updated Successfully!");

                ClearForm();
                ShowList();
                LoadAgentList();
            }
            catch (Exception ex)
            {
                // Duplicate name/code এর মত SP error এখানে দেখাবে, form খোলা থাকবে
                ShowMessage(ex.Message);
            }
        }

        // ================================================================
        //  HELPERS
        // ================================================================
        private void ClearForm()
        {
            hfBuyingAgentId.Value = "0";

            txtCode.Text = string.Empty;
            txtName.Text = string.Empty;
            txtCountry.Text = string.Empty;
            txtContactPerson.Text = string.Empty;
            txtContactEmail.Text = string.Empty;
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
