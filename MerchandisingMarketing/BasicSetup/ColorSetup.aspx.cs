using Nexa_ERP.Connection;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Text.RegularExpressions;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.MerchandisingMarketing.BasicSetup
{
    public partial class ColorSetup : System.Web.UI.Page
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
                LoadColorList();
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
        //  LOAD COLOR LIST (দুইটা Grid এ একসাথে bind হবে)
        //  Search : ColorCode / ColorName / HexCode,  Filter : Status
        // ================================================================
        private void LoadColorList()
        {
            try
            {
                string search = txtSearch.Text.Trim();

                int status = -1;
                int.TryParse(ddlStatusFilter.SelectedValue, out status);

                string query = @"
                    SELECT  ColorID, ColorCode, ColorName, HexCode,
                            CAST(ISNULL(IsActive, 0) AS BIT) AS IsActive
                    FROM    ColorMaster
                    WHERE   1 = 1";

                if (search.Length > 0)
                    query += " AND (ColorCode LIKE @Search OR ColorName LIKE @Search OR HexCode LIKE @Search)";

                if (status != -1)
                    query += " AND ISNULL(IsActive, 0) = @IsActive";

                query += " ORDER BY ColorName";

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
            LoadColorList();
        }

        protected void btnClearFilter_Click(object sender, EventArgs e)
        {
            txtSearch.Text = string.Empty;
            ddlStatusFilter.SelectedIndex = 0;
            LoadColorList();
        }

        // ================================================================
        //  GRIDVIEW : Edit / Delete (GridView1 ও GridView2 দুইটারই handler)
        // ================================================================
        protected void Grid_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int colorId;
            if (!int.TryParse(Convert.ToString(e.CommandArgument), out colorId)) return;

            if (e.CommandName == "EditRow")
            {
                LoadColorForEdit(colorId);
            }
            else if (e.CommandName == "DeleteRow")
            {
                DeleteColor(colorId);
            }
        }

        private void LoadColorForEdit(int colorId)
        {
            try
            {
                using (ConScope cs = new ConScope(conn.openConnection()))
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT ColorID, ColorCode, ColorName, HexCode, IsActive FROM ColorMaster WHERE ColorID = @ColorID", cs.Con))
                {
                    cmd.Parameters.Add("@ColorID", SqlDbType.Int).Value = colorId;

                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (!r.Read())
                        {
                            ShowMessage("Color not found!");
                            return;
                        }

                        hfColorId.Value = r["ColorID"].ToString();
                        txtColorCode.Text = r["ColorCode"] != DBNull.Value ? r["ColorCode"].ToString() : string.Empty;
                        txtColorName.Text = r["ColorName"] != DBNull.Value ? r["ColorName"].ToString() : string.Empty;
                        txtHexCode.Text = r["HexCode"] != DBNull.Value ? r["HexCode"].ToString() : string.Empty;
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

        // Pro_Color_Delete
        private void DeleteColor(int colorId)
        {
            try
            {
                using (ConScope cs = new ConScope(conn.openConnection()))
                using (SqlCommand cmd = new SqlCommand("Pro_Color_Delete", cs.Con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@ColorID", SqlDbType.Int).Value = colorId;
                    cmd.ExecuteNonQuery();
                }

                // যেটা edit হচ্ছিল সেটাই delete হলে form clear করে দাও
                if (hfColorId.Value == colorId.ToString())
                    ClearForm();

                ShowMessage("Deleted Successfully!");
                LoadColorList();
            }
            catch (SqlException ex)
            {
                // 547 = Foreign key conflict (অন্য table এ এই Color ব্যবহার হচ্ছে)
                if (ex.Number == 547)
                    ShowMessage("This color is already in use. You cannot delete it.");
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
            LoadColorList();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ClearForm();
        }

        // Pro_Color_SaveUpdate
        protected void btnSave_Click(object sender, EventArgs e)
        {
            // ---------- Validation ----------
            string code = txtColorCode.Text.Trim();
            string name = txtColorName.Text.Trim();
            string hex = txtHexCode.Text.Trim();

            if (code == "") { ShowMessage("Color Code is required!"); return; }
            if (name == "") { ShowMessage("Color Name is required!"); return; }

            // Hex Code optional; দিলে #RRGGBB format হতে হবে (# না দিলে নিজে থেকে যোগ হবে)
            if (hex != "")
            {
                if (!hex.StartsWith("#")) hex = "#" + hex;

                if (!Regex.IsMatch(hex, "^#[0-9A-Fa-f]{6}$"))
                {
                    ShowMessage("Hex Code must be in #RRGGBB format (e.g. #FF0000)!");
                    return;
                }

                hex = hex.ToUpper();
            }

            int colorId = 0;
            int.TryParse(hfColorId.Value, out colorId);

            // ---------- Save / Update ----------
            try
            {
                using (ConScope cs = new ConScope(conn.openConnection()))
                using (SqlCommand cmd = new SqlCommand("Pro_Color_SaveUpdate", cs.Con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.Add("@ColorID", SqlDbType.Int).Value = colorId;
                    cmd.Parameters.Add("@ColorCode", SqlDbType.NVarChar, 50).Value = code;
                    cmd.Parameters.Add("@ColorName", SqlDbType.NVarChar, 100).Value = name;
                    cmd.Parameters.Add("@HexCode", SqlDbType.NVarChar, 20).Value = hex == "" ? (object)DBNull.Value : hex;
                    cmd.Parameters.Add("@IsActive", SqlDbType.Bit).Value = chkIsActive.Checked;

                    cmd.ExecuteNonQuery();
                }

                ShowMessage(colorId == 0 ? "Saved Successfully!" : "Updated Successfully!");

                // Save এর পরে List panel এ যাবে না: form clear হবে, Entry panel এই থাকবে,
                // আর নিচের GridView2 refresh হবে।
                ClearForm();
                ShowEntry();
                LoadColorList();
            }
            catch (Exception ex)
            {
                // Duplicate Color Code এর মত SP error এখানে দেখাবে, form খোলা থাকবে
                ShowMessage(ex.Message);
            }
        }

        // ================================================================
        //  HELPERS
        // ================================================================
        private void ClearForm()
        {
            hfColorId.Value = "0";
            txtColorCode.Text = string.Empty;
            txtColorName.Text = string.Empty;
            txtHexCode.Text = string.Empty;
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
