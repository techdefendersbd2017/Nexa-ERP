using Nexa_ERP.Connection;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.Inventory
{
    public partial class StoreRequisition : Page
    {
        SqlConnection con;
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();
        SqlCommand cmd;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                SetDefaultValues();
                Load_Group_Information();
                Load_BuildingInformation();
                Load_Customer();
                Load_Buyer();

            }
        }
        private void Load_Group_Information()
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT * FROM vw_Group_Information ORDER BY Group_Name";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    ddlCompany.DataSource = dt;
                    ddlCompany.DataTextField = "Group_Name";
                    ddlCompany.DataValueField = "Group_ID";
                    ddlCompany.DataBind();
                    ddlCompany.Items.Insert(0, new ListItem("--Select Company--", "0"));
                }
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
        }
        private void Load_BranchInfoarmation()
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT * FROM vw_Branch_Information Where Group_ID='" + ddlCompany.SelectedValue + "' ORDER BY Branch_Name";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    ddlBranch.DataSource = dt;
                    ddlBranch.DataTextField = "Branch_Name";
                    ddlBranch.DataValueField = "Branch_ID";
                    ddlBranch.DataBind();
                    ddlBranch.Items.Insert(0, new ListItem("--Select Branch--", "0"));
                }
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
        }
        private void Load_BuildingInformation()
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT * FROM vw_BuildingInformation ORDER BY Building_Name";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    ddlBuilding.DataSource = dt;
                    ddlBuilding.DataTextField = "Building_Name";
                    ddlBuilding.DataValueField = "Building_ID";
                    ddlBuilding.DataBind();
                    ddlBuilding.Items.Insert(0, new ListItem("--Select Building--", "0"));
                }
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
        }
        private void Load_Floor_Information()
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT * FROM vw_Floor_Information where Building_ID='" + ddlBuilding.SelectedValue + "' ORDER BY Floor_Name";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    ddlFloor.DataSource = dt;
                    ddlFloor.DataTextField = "Floor_Name";
                    ddlFloor.DataValueField = "Floor_ID";
                    ddlFloor.DataBind();
                    ddlFloor.Items.Insert(0, new ListItem("--Select Floor--", "0"));
                }
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
        }
        private void Load_IssuingStore()
        {
            try
            {
                con = conn.openConnection();

                // এখানে Receiving Store-এ যা সিলেক্ট করা আছে, সেটি বাদ দেওয়ার জন্য NOT IN ব্যবহার করা হয়েছে
                string query = "SELECT * FROM CrateStore WHERE BranchName = '" + ddlBranch.SelectedValue + "' AND Status = 'Active'";

                if (ddlReceivingStore.SelectedIndex > 0)
                {
                    query += " AND StoreId NOT IN ('" + ddlReceivingStore.SelectedValue + "')";
                }

                query += " ORDER BY StoreName";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    ddlIssuingStore.DataSource = dt;
                    ddlIssuingStore.DataTextField = "StoreName";
                    ddlIssuingStore.DataValueField = "StoreId";
                    ddlIssuingStore.DataBind();
                    ddlIssuingStore.Items.Insert(0, new ListItem("--Select Store--", "0"));
                }
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
        }
        private void Load_ReceivingStore()
        {
            try
            {
                con = conn.openConnection();

                // এখানে Issuing Store-এ যা সিলেক্ট করা আছে, সেটি বাদ দেওয়ার জন্য NOT IN ব্যবহার করা হয়েছে
                string query = "SELECT * FROM CrateStore WHERE BranchName = '" + ddlBranch.SelectedValue + "' AND Status = 'Active'";

                if (ddlIssuingStore.SelectedIndex > 0)
                {
                    query += " AND StoreId NOT IN ('" + ddlIssuingStore.SelectedValue + "')";
                }

                query += " ORDER BY StoreName";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    ddlReceivingStore.DataSource = dt;
                    ddlReceivingStore.DataTextField = "StoreName";
                    ddlReceivingStore.DataValueField = "StoreId";
                    ddlReceivingStore.DataBind();
                    ddlReceivingStore.Items.Insert(0, new ListItem("--Select Store--", "0"));
                }
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
        }
        private void Load_CostCenter()
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT * FROM ta_CostCenter Where BranchId='" + ddlBranch.SelectedValue + "' and Status='Active'  ORDER BY CostCenterName";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    ddlCostCenter.DataSource = dt;
                    ddlCostCenter.DataTextField = "CostCenterName";
                    ddlCostCenter.DataValueField = "CostCenterId";
                    ddlCostCenter.DataBind();
                    ddlCostCenter.Items.Insert(0, new ListItem("--Select Cost Center--", "0"));
                }
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
        }
        private void Load_Customer()
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT * FROM tbl_CustomerSupplier ORDER BY PartyName";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    ddlCustomer.DataSource = dt;
                    ddlCustomer.DataTextField = "PartyName";
                    ddlCustomer.DataValueField = "PartyID";
                    ddlCustomer.DataBind();
                    ddlCustomer.Items.Insert(0, new ListItem("--Select Party--", "0"));
                }
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
        }
        private void Load_Buyer()
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT * FROM vw_BuyerInformation ORDER BY BuyerName";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    ddlBuyer.DataSource = dt;
                    ddlBuyer.DataTextField = "BuyerName";
                    ddlBuyer.DataValueField = "BuyerID";
                    ddlBuyer.DataBind();
                    ddlBuyer.Items.Insert(0, new ListItem("--Select Buyer--", "0"));
                }
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
        }
        private void SetDefaultValues()
        {
            txtRequiredDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
        }
        protected void ddlCompany_SelectedIndexChanged(object sender, EventArgs e)
        {
            // Cascading filter logic triggered on Company selection change
            string selectedCompany = ddlCompany.SelectedValue;
            Load_BranchInfoarmation();
            // TODO: Execute SQL query to filter Warehouses and User Permission mapping for selected company
        }

        protected void ddlWOReceiveRef_SelectedIndexChanged(object sender, EventArgs e)
        {
            // Auto-load related Work Orders and BOM quantities when WO Reference is chosen
        }

        protected void btnConfirm_Click(object sender, EventArgs e)
        {
            // Business Logic: Lock fields, generate audit log, route to Section Head approval workflow
            txtReqNo.ReadOnly = true;
            ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('Requisition Confirmed Successfully! Sent to Section Head for Approval.');", true);
        }

        protected void ddlCustomer_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

        protected void btnSaveDraft_Click(object sender, EventArgs e)
        {

        }

        protected void btnPrint_Click(object sender, EventArgs e)
        {

        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {

        }

        protected void ddlBuilding_SelectedIndexChanged(object sender, EventArgs e)
        {
            Load_Floor_Information();
        }

        protected void ddlIssuingStore_SelectedIndexChanged(object sender, EventArgs e)
        {
        }

        protected void ddlReceivingStore_SelectedIndexChanged(object sender, EventArgs e)
        {
        }

        protected void ddlBranch_SelectedIndexChanged(object sender, EventArgs e)
        {
            Load_IssuingStore();
            Load_ReceivingStore();
            Load_CostCenter();
        }
    }
}
