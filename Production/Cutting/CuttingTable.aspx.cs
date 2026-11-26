using Nexa_ERP.Connection;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.Production.Cutting
{
    public partial class CuttingTable : System.Web.UI.Page
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

        #region Page Load

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Login user (আপনার project এর Session key অনুযায়ী পরিবর্তন করুন)
                hfUserId.Value = Session["UserId"] != null ? Session["UserId"].ToString() : "0";

                LoadFloors();
                LoadGrid();
                ResetForm();
            }
        }

        #endregion

        #region Load Data

        private void LoadFloors()
        {
            try
            {
                using (ConScope cs = new ConScope(conn.openConnection()))
                using (SqlCommand cmd = new SqlCommand("dbo.usp_Floor_GetList", cs.Con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    DataTable dt = new DataTable();
                    new SqlDataAdapter(cmd).Fill(dt);

                    ddlFloor.DataSource = dt;
                    ddlFloor.DataTextField = "FloorName";
                    ddlFloor.DataValueField = "FloorId";
                    ddlFloor.DataBind();
                    ddlFloor.Items.Insert(0, new ListItem("-- Select Floor --", ""));
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Could not load floors. " + ex.Message, false);
            }
        }

        private void LoadGrid()
        {
            try
            {
                using (ConScope cs = new ConScope(conn.openConnection()))
                using (SqlCommand cmd = new SqlCommand("dbo.usp_CuttingTable_GetAll", cs.Con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    DataTable dt = new DataTable();
                    new SqlDataAdapter(cmd).Fill(dt);

                    gvCuttingTable.DataSource = dt;
                    gvCuttingTable.DataBind();
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Could not load list. " + ex.Message, false);
            }
        }

        #endregion

        #region Grid Events

        protected void gvCuttingTable_SelectedIndexChanged(object sender, EventArgs e)
        {
            try
            {
                int id = Convert.ToInt32(gvCuttingTable.SelectedDataKey.Value);

                using (ConScope cs = new ConScope(conn.openConnection()))
                using (SqlCommand cmd = new SqlCommand("dbo.usp_CuttingTable_GetById", cs.Con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@CuttingTableId", SqlDbType.Int).Value = id;

                    DataTable dt = new DataTable();
                    new SqlDataAdapter(cmd).Fill(dt);

                    if (dt.Rows.Count == 0)
                    {
                        ShowMessage("Record not found.", false);
                        LoadGrid();
                        ResetForm();
                        return;
                    }

                    DataRow r = dt.Rows[0];
                    txtCuttingTableId.Text = r["CuttingTableId"].ToString();
                    txtName.Text = r["Name"].ToString();
                    txtRemarks.Text = r["Remarks"] == DBNull.Value ? "" : r["Remarks"].ToString();
                    chkIsActive.Checked = Convert.ToBoolean(r["IsActive"]);

                    ddlFloor.ClearSelection();
                    ListItem floorItem = ddlFloor.Items.FindByValue(r["FloorId"].ToString());
                    if (floorItem != null) floorItem.Selected = true;

                    btnDelete.Enabled = true;
                    btnSave.Text = "Update";
                    HideMessage();
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Could not load the record. " + ex.Message, false);
            }
        }

        #endregion

        #region Button Events

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            LoadGrid();
            ResetForm();
            HideMessage();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            bool isNew = string.IsNullOrWhiteSpace(txtCuttingTableId.Text);

            try
            {
                using (ConScope cs = new ConScope(conn.openConnection()))
                using (SqlCommand cmd = new SqlCommand(
                    isNew ? "dbo.usp_CuttingTable_Insert" : "dbo.usp_CuttingTable_Update", cs.Con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.Add("@FloorId", SqlDbType.Int).Value = Convert.ToInt32(ddlFloor.SelectedValue);
                    cmd.Parameters.Add("@Name", SqlDbType.NVarChar, 100).Value = txtName.Text.Trim();
                    cmd.Parameters.Add("@Remarks", SqlDbType.NVarChar, 500).Value =
                        string.IsNullOrWhiteSpace(txtRemarks.Text) ? (object)DBNull.Value : txtRemarks.Text.Trim();
                    cmd.Parameters.Add("@IsActive", SqlDbType.Bit).Value = chkIsActive.Checked;

                    object userId = GetUserId();

                    if (isNew)
                    {
                        cmd.Parameters.Add("@CreatedBy", SqlDbType.Int).Value = userId;

                        SqlParameter pId = new SqlParameter("@CuttingTableId", SqlDbType.Int)
                        {
                            Direction = ParameterDirection.Output
                        };
                        cmd.Parameters.Add(pId);

                        cmd.ExecuteNonQuery();

                        ShowMessage("Cutting table saved successfully. ID: " + pId.Value, true);
                    }
                    else
                    {
                        cmd.Parameters.Add("@CuttingTableId", SqlDbType.Int).Value = Convert.ToInt32(txtCuttingTableId.Text);
                        cmd.Parameters.Add("@UpdatedBy", SqlDbType.Int).Value = userId;

                        cmd.ExecuteNonQuery();

                        ShowMessage("Cutting table updated successfully.", true);
                    }
                }

                LoadGrid();
                ResetForm();
            }
            catch (SqlException ex)
            {
                // 50001/50002 = SP থেকে THROW করা business message
                if (ex.Number >= 50000)
                    ShowMessage(ex.Message, false);
                else
                    ShowMessage("A database error occurred while saving. Please try again.", false);
            }
            catch (Exception ex)
            {
                ShowMessage("Unexpected error: " + ex.Message, false);
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtCuttingTableId.Text))
            {
                ShowMessage("Please select a row to delete.", false);
                return;
            }

            try
            {
                using (ConScope cs = new ConScope(conn.openConnection()))
                using (SqlCommand cmd = new SqlCommand("dbo.usp_CuttingTable_Delete", cs.Con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@CuttingTableId", SqlDbType.Int).Value = Convert.ToInt32(txtCuttingTableId.Text);
                    cmd.ExecuteNonQuery();
                }

                LoadGrid();
                ResetForm();
                ShowMessage("Cutting table deleted successfully.", true);
            }
            catch (SqlException ex)
            {
                if (ex.Number == 547) // Foreign key conflict
                    ShowMessage("This cutting table is already in use and cannot be deleted. Mark it as inactive instead.", false);
                else if (ex.Number >= 50000)
                    ShowMessage(ex.Message, false);
                else
                    ShowMessage("A database error occurred while deleting. Please try again.", false);
            }
            catch (Exception ex)
            {
                ShowMessage("Unexpected error: " + ex.Message, false);
            }
        }

        #endregion

        #region Helpers

        private object GetUserId()
        {
            int uid;
            return int.TryParse(hfUserId.Value, out uid) && uid > 0 ? (object)uid : DBNull.Value;
        }

        private void ResetForm()
        {
            txtCuttingTableId.Text = "";
            txtName.Text = "";
            txtRemarks.Text = "";
            chkIsActive.Checked = true;
            ddlFloor.ClearSelection();
            if (ddlFloor.Items.Count > 0) ddlFloor.SelectedIndex = 0;

            gvCuttingTable.SelectedIndex = -1;
            btnDelete.Enabled = false;
            btnSave.Text = "Save";
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            pnlMessage.Visible = true;
            pnlMessage.CssClass = "alert " + (isSuccess ? "alert-success" : "alert-danger") + " d-flex align-items-center gap-2";
            lblMessage.Text = Server.HtmlEncode(message);
        }

        private void HideMessage()
        {
            pnlMessage.Visible = false;
            lblMessage.Text = "";
        }

        #endregion
    }
}