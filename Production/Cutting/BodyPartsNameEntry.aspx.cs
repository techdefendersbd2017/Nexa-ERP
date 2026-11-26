using Nexa_ERP.Connection;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.Production.Cutting
{
    public partial class BodyPartsNameEntry : System.Web.UI.Page
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
                hfUserId.Value = Session["UserId"] != null ? Session["UserId"].ToString() : "0";

                LoadGrid();
                ResetForm();
            }
        }

        #endregion

        #region Load Data

        private void LoadGrid()
        {
            try
            {
                using (ConScope cs = new ConScope(conn.openConnection()))
                using (SqlCommand cmd = new SqlCommand("dbo.usp_BodyPart_GetAll", cs.Con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    DataTable dt = new DataTable();
                    new SqlDataAdapter(cmd).Fill(dt);

                    gvBodyParts.DataSource = dt;
                    gvBodyParts.DataBind();
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Could not load list. " + ex.Message, false);
            }
        }

        #endregion

        #region Grid Events

        protected void gvBodyParts_SelectedIndexChanged(object sender, EventArgs e)
        {
            try
            {
                int id = Convert.ToInt32(gvBodyParts.SelectedDataKey.Value);

                using (ConScope cs = new ConScope(conn.openConnection()))
                using (SqlCommand cmd = new SqlCommand("dbo.usp_BodyPart_GetById", cs.Con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@BodyPartId", SqlDbType.Int).Value = id;

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
                    txtBodyPartId.Text = r["BodyPartId"].ToString();
                    txtName.Text = r["Name"].ToString();
                    chkIsEmbroidery.Checked = Convert.ToBoolean(r["IsEmbroidery"]);
                    chkIsSmoke.Checked = Convert.ToBoolean(r["IsSmoke"]);
                    chkIsActive.Checked = Convert.ToBoolean(r["IsActive"]);

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

            bool isNew = string.IsNullOrWhiteSpace(txtBodyPartId.Text);

            try
            {
                using (ConScope cs = new ConScope(conn.openConnection()))
                using (SqlCommand cmd = new SqlCommand(
                    isNew ? "dbo.usp_BodyPart_Insert" : "dbo.usp_BodyPart_Update", cs.Con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.Add("@Name", SqlDbType.NVarChar, 100).Value = txtName.Text.Trim();
                    cmd.Parameters.Add("@IsEmbroidery", SqlDbType.Bit).Value = chkIsEmbroidery.Checked;
                    cmd.Parameters.Add("@IsSmoke", SqlDbType.Bit).Value = chkIsSmoke.Checked;
                    cmd.Parameters.Add("@IsActive", SqlDbType.Bit).Value = chkIsActive.Checked;

                    object userId = GetUserId();

                    if (isNew)
                    {
                        cmd.Parameters.Add("@CreatedBy", SqlDbType.Int).Value = userId;

                        SqlParameter pId = new SqlParameter("@BodyPartId", SqlDbType.Int)
                        {
                            Direction = ParameterDirection.Output
                        };
                        cmd.Parameters.Add(pId);

                        cmd.ExecuteNonQuery();

                        ShowMessage("Body part saved successfully. ID: " + pId.Value, true);
                    }
                    else
                    {
                        cmd.Parameters.Add("@BodyPartId", SqlDbType.Int).Value = Convert.ToInt32(txtBodyPartId.Text);
                        cmd.Parameters.Add("@UpdatedBy", SqlDbType.Int).Value = userId;

                        cmd.ExecuteNonQuery();

                        ShowMessage("Body part updated successfully.", true);
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
            if (string.IsNullOrWhiteSpace(txtBodyPartId.Text))
            {
                ShowMessage("Please select a row to delete.", false);
                return;
            }

            try
            {
                using (ConScope cs = new ConScope(conn.openConnection()))
                using (SqlCommand cmd = new SqlCommand("dbo.usp_BodyPart_Delete", cs.Con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@BodyPartId", SqlDbType.Int).Value = Convert.ToInt32(txtBodyPartId.Text);
                    cmd.ExecuteNonQuery();
                }

                LoadGrid();
                ResetForm();
                ShowMessage("Body part deleted successfully.", true);
            }
            catch (SqlException ex)
            {
                if (ex.Number == 547) // Foreign key conflict
                    ShowMessage("This body part is already in use and cannot be deleted. Mark it as inactive instead.", false);
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
            txtBodyPartId.Text = "";
            txtName.Text = "";
            chkIsEmbroidery.Checked = false;
            chkIsSmoke.Checked = false;
            chkIsActive.Checked = true;

            gvBodyParts.SelectedIndex = -1;
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
