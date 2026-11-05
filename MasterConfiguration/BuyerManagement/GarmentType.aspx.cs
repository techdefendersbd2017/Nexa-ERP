using Nexa_ERP.Connection;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.MasterConfiguration.BuyerManagement
{
    public partial class GarmentType : System.Web.UI.Page
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
                LoadGarmentTypeList();
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
        //  LOAD GARMENT TYPE LIST (দুইটা Grid এ একসাথে bind হবে)
        //  Pro_GarmentType_GetList
        // ================================================================
        private void LoadGarmentTypeList()
        {
            try
            {
                string search = txtSearch.Text.Trim();

                int status = -1;
                int.TryParse(ddlStatusFilter.SelectedValue, out status);

                using (ConScope cs = new ConScope(conn.openConnection()))
                using (SqlCommand cmd = new SqlCommand("Pro_GarmentType_GetList", cs.Con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@Search", SqlDbType.NVarChar, 200).Value =
                        search.Length > 0 ? (object)search : DBNull.Value;
                    cmd.Parameters.Add("@IsActive", SqlDbType.Int).Value = status;

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
            LoadGarmentTypeList();
        }

        protected void btnClearFilter_Click(object sender, EventArgs e)
        {
            txtSearch.Text = string.Empty;
            ddlStatusFilter.SelectedIndex = 0;
            LoadGarmentTypeList();
        }

        // ================================================================
        //  GRIDVIEW : Edit / Delete (GridView1 ও GridView2 দুইটারই handler)
        // ================================================================
        protected void Grid_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int garmentTypeId;
            if (!int.TryParse(Convert.ToString(e.CommandArgument), out garmentTypeId)) return;

            if (e.CommandName == "EditRow")
            {
                LoadGarmentTypeForEdit(garmentTypeId);
            }
            else if (e.CommandName == "DeleteRow")
            {
                DeleteGarmentType(garmentTypeId);
            }
        }

        // Pro_GarmentType_GetById
        private void LoadGarmentTypeForEdit(int garmentTypeId)
        {
            try
            {
                using (ConScope cs = new ConScope(conn.openConnection()))
                using (SqlCommand cmd = new SqlCommand("Pro_GarmentType_GetById", cs.Con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@GarmentTypeID", SqlDbType.Int).Value = garmentTypeId;

                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (!r.Read())
                        {
                            ShowMessage("Garment type not found!");
                            return;
                        }

                        hfGarmentTypeId.Value = r["GarmentTypeID"].ToString();
                        txtGarmentCode.Text = r["GarmentCode"] != DBNull.Value ? r["GarmentCode"].ToString() : string.Empty;
                        txtGarmentName.Text = r["GarmentName"] != DBNull.Value ? r["GarmentName"].ToString() : string.Empty;
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

        // Pro_GarmentType_Delete
        private void DeleteGarmentType(int garmentTypeId)
        {
            try
            {
                using (ConScope cs = new ConScope(conn.openConnection()))
                using (SqlCommand cmd = new SqlCommand("Pro_GarmentType_Delete", cs.Con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@GarmentTypeID", SqlDbType.Int).Value = garmentTypeId;
                    cmd.ExecuteNonQuery();
                }

                // যেটা edit হচ্ছিল সেটাই delete হলে form clear করে দাও
                if (hfGarmentTypeId.Value == garmentTypeId.ToString())
                    ClearForm();

                ShowMessage("Deleted Successfully!");
                LoadGarmentTypeList();
            }
            catch (SqlException ex)
            {
                // 547 = Foreign key conflict (অন্য table এ এই Garment Type ব্যবহার হচ্ছে)
                if (ex.Number == 547)
                    ShowMessage("This garment type is already in use. You cannot delete it.");
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
            LoadGarmentTypeList();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ClearForm();
        }

        // Pro_GarmentType_SaveUpdate
        protected void btnSave_Click(object sender, EventArgs e)
        {
            // ---------- Validation ----------
            string code = txtGarmentCode.Text.Trim();
            string name = txtGarmentName.Text.Trim();

            if (code == "") { ShowMessage("Garment Code is required!"); return; }
            if (name == "") { ShowMessage("Garment Name is required!"); return; }

            int garmentTypeId = 0;
            int.TryParse(hfGarmentTypeId.Value, out garmentTypeId);

            // ---------- Save / Update ----------
            try
            {
                using (ConScope cs = new ConScope(conn.openConnection()))
                using (SqlCommand cmd = new SqlCommand("Pro_GarmentType_SaveUpdate", cs.Con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.Add("@GarmentTypeID", SqlDbType.Int).Value = garmentTypeId;
                    cmd.Parameters.Add("@GarmentCode", SqlDbType.NVarChar, 50).Value = code;
                    cmd.Parameters.Add("@GarmentName", SqlDbType.NVarChar, 150).Value = name;
                    cmd.Parameters.Add("@IsActive", SqlDbType.Bit).Value = chkActive.Checked;

                    cmd.ExecuteNonQuery();
                }

                ShowMessage(garmentTypeId == 0 ? "Saved Successfully!" : "Updated Successfully!");

                // Save এর পরে List tab এ যাবে না: form clear হবে, Entry panel এই থাকবে,
                // আর নিচের GridView2 refresh হবে।
                ClearForm();
                ShowEntry();
                LoadGarmentTypeList();
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
            hfGarmentTypeId.Value = "0";
            txtGarmentCode.Text = string.Empty;
            txtGarmentName.Text = string.Empty;
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
