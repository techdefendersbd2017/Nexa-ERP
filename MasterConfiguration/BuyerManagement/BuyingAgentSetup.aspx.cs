using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
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

        // Entry panel এ যোগ করা Buyer গুলো ("BuyerID|BuyerName") ViewState এ থাকে
        private List<string> BuyerItems
        {
            get
            {
                if (ViewState["BuyerItems"] == null) ViewState["BuyerItems"] = new List<string>();
                return (List<string>)ViewState["BuyerItems"];
            }
            set { ViewState["BuyerItems"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Login user (আপনার project এর Session key অনুযায়ী পরিবর্তন করুন)
                hfUserId.Value = Session["UserId"] != null ? Session["UserId"].ToString() : "0";

                LoadAgentTypes();
                LoadBuyers();
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
        //  LOAD DROPDOWNS
        // ================================================================
        private void LoadAgentTypes()
        {
            try
            {
                // TODO: BuyingHouseType এর column নাম (HouseTypeName) মিলিয়ে নিন
                using (ConScope cs = new ConScope(conn.openConnection()))
                using (SqlCommand cmd = new SqlCommand("SELECT HouseTypeID, HouseTypeName FROM BuyingHouseType ORDER BY HouseTypeName", cs.Con))
                {
                    DataTable dt = new DataTable();
                    new SqlDataAdapter(cmd).Fill(dt);

                    ddlAgentType.DataSource = dt;
                    ddlAgentType.DataTextField = "HouseTypeName";
                    ddlAgentType.DataValueField = "HouseTypeID";
                    ddlAgentType.DataBind();

                    ddlAgentType.Items.Insert(0, new ListItem("--Select Agent Type--", "0"));
                }
            }
            catch (Exception ex)
            {
                ShowMessage(ex.Message);
            }
        }

        private void LoadBuyers()
        {
            try
            {
                using (ConScope cs = new ConScope(conn.openConnection()))
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT BuyerID, BuyerName FROM BuyerInformation WHERE ISNULL(IsActive, 1) = 1 ORDER BY BuyerName", cs.Con))
                {
                    DataTable dt = new DataTable();
                    new SqlDataAdapter(cmd).Fill(dt);

                    ddlSelectBuyer.DataSource = dt;
                    ddlSelectBuyer.DataTextField = "BuyerName";
                    ddlSelectBuyer.DataValueField = "BuyerID";
                    ddlSelectBuyer.DataBind();

                    ddlSelectBuyer.Items.Insert(0, new ListItem("--Select Buyer--", "0"));
                }
            }
            catch (Exception ex)
            {
                ShowMessage(ex.Message);
            }
        }

        // ================================================================
        //  LOAD AGENT LIST (Search by name / code)
        // ================================================================
        private void LoadAgentList()
        {
            try
            {
                string query = @"
                    SELECT  a.AgentID,
                            ISNULL(a.Prefix, '')        AS Code,
                            a.HouseName                 AS Name,
                            ISNULL(t.HouseTypeName, '') AS AgentType,
                            ISNULL(a.ContactPerson, '') AS ContactPerson,
                            ISNULL(a.Mobile, '')        AS Mobile,
                            ISNULL(a.Email, '')         AS Email,
                            (SELECT COUNT(*) FROM BuyingHouseAgentBuyer ab WHERE ab.AgentID = a.AgentID) AS BuyerCount,
                            CAST(ISNULL(a.IsActive, 0) AS BIT) AS IsActive
                    FROM    BuyingHouseAgent a
                            LEFT JOIN BuyingHouseType t ON t.HouseTypeID = a.HouseTypeID
                    WHERE   1 = 1";

                string search = txtSearch.Text.Trim();
                if (search.Length > 0)
                    query += " AND (a.HouseName LIKE @Search OR a.Prefix LIKE @Search)";

                query += " ORDER BY a.HouseName";

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
                using (SqlCommand cmd = new SqlCommand("SELECT * FROM BuyingHouseAgent WHERE AgentID = @AgentID", cs.Con))
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

                        txtCode.Text = r["Prefix"].ToString();
                        txtName.Text = r["HouseName"].ToString();

                        string typeId = r["HouseTypeID"] != DBNull.Value ? r["HouseTypeID"].ToString() : "0";
                        ddlAgentType.SelectedValue = ddlAgentType.Items.FindByValue(typeId) != null ? typeId : "0";

                        txtContactPerson.Text = r["ContactPerson"].ToString();
                        txtMobile.Text = r["Mobile"].ToString();
                        txtPhone.Text = r["Phone"].ToString();
                        txtAddress.Text = r["Address"].ToString();
                        txtFax.Text = r["Fax"].ToString();
                        txtEmail.Text = r["Email"].ToString();
                        txtWeb.Text = r["Web"].ToString();
                        chkIsActive.Checked = r["IsActive"] != DBNull.Value && Convert.ToBoolean(r["IsActive"]);
                    }
                }

                // এই Agent এর Buyer তালিকা
                List<string> items = new List<string>();
                using (ConScope cs = new ConScope(conn.openConnection()))
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT bi.BuyerID, bi.BuyerName
                    FROM   BuyingHouseAgentBuyer ab
                           INNER JOIN BuyerInformation bi ON bi.BuyerID = ab.BuyerID
                    WHERE  ab.AgentID = @AgentID
                    ORDER BY bi.BuyerName", cs.Con))
                {
                    cmd.Parameters.Add("@AgentID", SqlDbType.BigInt).Value = agentId;

                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                            items.Add(r["BuyerID"].ToString() + "|" + r["BuyerName"].ToString());
                    }
                }
                BuyerItems = items;
                BindBuyerGrid();

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
        //  BUYERS GRID (Add / Remove, Save এর আগ পর্যন্ত ViewState এ)
        // ================================================================
        private void BindBuyerGrid()
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("BuyerID", typeof(string));
            dt.Columns.Add("BuyerName", typeof(string));

            foreach (string item in BuyerItems)
            {
                string[] p = item.Split(new char[] { '|' }, 2);
                dt.Rows.Add(p[0], p.Length > 1 ? p[1] : "");
            }

            gvBuyers.DataSource = dt;
            gvBuyers.DataBind();
        }

        protected void btnAddBuyer_Click(object sender, EventArgs e)
        {
            if (ddlSelectBuyer.SelectedValue == "0" || ddlSelectBuyer.SelectedValue == "")
            {
                ShowMessage("Please select a Buyer!");
                return;
            }

            string buyerId = ddlSelectBuyer.SelectedValue;
            List<string> items = BuyerItems;

            foreach (string item in items)
            {
                if (item.StartsWith(buyerId + "|"))
                {
                    ShowMessage("This buyer is already added!");
                    return;
                }
            }

            items.Add(buyerId + "|" + ddlSelectBuyer.SelectedItem.Text);
            BuyerItems = items;

            ddlSelectBuyer.SelectedIndex = 0;
            BindBuyerGrid();
        }

        protected void gvBuyers_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName != "RemoveBuyer") return;

            string buyerId = Convert.ToString(e.CommandArgument);
            List<string> items = BuyerItems;
            items.RemoveAll(x => x.StartsWith(buyerId + "|"));
            BuyerItems = items;

            BindBuyerGrid();
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
            if (txtCode.Text.Trim() == "") { ShowMessage("Code is required!"); return; }
            if (txtName.Text.Trim() == "") { ShowMessage("Name is required!"); return; }

            long agentId = 0;
            long.TryParse(hfBuyingAgentId.Value, out agentId);

            int typeId = 0;
            int.TryParse(ddlAgentType.SelectedValue, out typeId);

            // Buyer ID গুলো comma separated string হিসেবে SP তে যাবে
            List<string> ids = new List<string>();
            foreach (string item in BuyerItems)
                ids.Add(item.Split('|')[0]);
            string buyerIds = string.Join(",", ids.ToArray());

            // ---------- Save / Update ----------
            try
            {
                using (ConScope cs = new ConScope(conn.openConnection()))
                using (SqlCommand cmd = new SqlCommand("Pro_BuyingAgent_SaveUpdate", cs.Con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.Add("@AgentID", SqlDbType.BigInt).Value = agentId;
                    cmd.Parameters.Add("@Prefix", SqlDbType.VarChar, 50).Value = txtCode.Text.Trim();
                    cmd.Parameters.Add("@HouseName", SqlDbType.VarChar, 200).Value = txtName.Text.Trim();
                    cmd.Parameters.Add("@HouseTypeID", SqlDbType.Int).Value = typeId == 0 ? (object)DBNull.Value : typeId;
                    cmd.Parameters.Add("@ContactPerson", SqlDbType.VarChar, 150).Value = txtContactPerson.Text.Trim();
                    cmd.Parameters.Add("@Mobile", SqlDbType.VarChar, 50).Value = txtMobile.Text.Trim();
                    cmd.Parameters.Add("@Phone", SqlDbType.VarChar, 50).Value = txtPhone.Text.Trim();
                    cmd.Parameters.Add("@Address", SqlDbType.VarChar, 500).Value = txtAddress.Text.Trim();
                    cmd.Parameters.Add("@Fax", SqlDbType.VarChar, 50).Value = txtFax.Text.Trim();
                    cmd.Parameters.Add("@Email", SqlDbType.VarChar, 150).Value = txtEmail.Text.Trim();
                    cmd.Parameters.Add("@Web", SqlDbType.VarChar, 150).Value = txtWeb.Text.Trim();
                    cmd.Parameters.Add("@IsActive", SqlDbType.Bit).Value = chkIsActive.Checked;
                    cmd.Parameters.Add("@BuyerIDs", SqlDbType.VarChar, -1).Value = buyerIds;

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
            ddlAgentType.SelectedIndex = 0;
            txtContactPerson.Text = string.Empty;
            txtMobile.Text = string.Empty;
            txtPhone.Text = string.Empty;
            txtAddress.Text = string.Empty;
            txtFax.Text = string.Empty;
            txtEmail.Text = string.Empty;
            txtWeb.Text = string.Empty;
            chkIsActive.Checked = true;

            ddlSelectBuyer.SelectedIndex = 0;
            BuyerItems = new List<string>();
            BindBuyerGrid();
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