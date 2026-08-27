using Nexa_ERP.Connection;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.MerchandisingMarketing.MerchandisingConfiguration
{
    public partial class ColorInformation : System.Web.UI.Page
    {
        SqlConnection con;
        Database_Connection conn = new Database_Connection();
        SqlCommand cmd;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadNextColorCode();
                LoadColorInformation();
            }
        }

        // অটো কালার কোড জেনারেট করার জন্য
        void LoadNextColorCode()
        {
            try
            {
                con = conn.openConnection();
                SqlCommand cmd = new SqlCommand("SELECT 'COL-' + RIGHT('0000' + CAST(ISNULL(MAX(ColorID), 0) + 1 AS VARCHAR(5)), 4) FROM ColorInformation", con);
                object result = cmd.ExecuteScalar();
                txtColorCode.Text = result != null ? result.ToString() : "COL-0001";
                con.Close();
            }
            catch (Exception ex)
            {
                if (con.State == ConnectionState.Open) con.Close();
                txtColorCode.Text = "COL-0001";
            }
        }

        // গ্রিডভিউ ডেটা লোড
        private void LoadColorInformation()
        {
            try
            {
                con = conn.openConnection();
                SqlDataAdapter da = new SqlDataAdapter("SELECT ColorID, ColorCode, 'Standard' AS ColorType, ColorName, CASE WHEN IsActive = 1 then 'Yes' ELSE 'No' END AS IsActive FROM ColorInformation ORDER BY ColorID DESC", con);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvColorList.DataSource = dt;
                gvColorList.DataBind();
                con.Close();
            }
            catch (Exception ex)
            {
                if (con.State == ConnectionState.Open) con.Close();
                lblMessage.Text = "Error: " + ex.Message;
                lblMessage.ForeColor = System.Drawing.Color.Red;
            }
        }

        // Save & Update Button Click
        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(txtColorName.Text.Trim()))
            {
                lblMessage.Text = "Please enter color name!";
                lblMessage.ForeColor = System.Drawing.Color.Red;
                return;
            }

            try
            {
                con = conn.openConnection();
                using (SqlCommand cmd = new SqlCommand("sp_SaveUpdateColorInformation", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    int colorId = !string.IsNullOrEmpty(hfColorID.Value) ? Convert.ToInt32(hfColorID.Value) : 0;

                    cmd.Parameters.Add("@ColorID", SqlDbType.Int).Value = colorId == 0 ? (object)DBNull.Value : colorId;
                    cmd.Parameters.Add("@ColorCode", SqlDbType.VarChar).Value = txtColorCode.Text.Trim();
                    cmd.Parameters.Add("@ColorName", SqlDbType.VarChar).Value = txtColorName.Text.Trim();
                    cmd.Parameters.Add("@PantenName", SqlDbType.VarChar).Value = txtPantenName.Text.Trim();
                    cmd.Parameters.Add("@IsActive", SqlDbType.Bit).Value = chkIsActive.Checked;

                    cmd.ExecuteNonQuery();

                    lblMessage.Text = colorId == 0 ? "Saved Successfully!" : "Updated Successfully!";
                    lblMessage.ForeColor = System.Drawing.Color.Green;
                }
                con.Close();

                ClearForm();
                LoadNextColorCode();
                LoadColorInformation();
            }
            catch (Exception ex)
            {
                if (con.State == ConnectionState.Open) con.Close();
                lblMessage.Text = "Error: " + ex.Message;
                lblMessage.ForeColor = System.Drawing.Color.Red;
            }
        }

        // GridView Row Command (Edit & Delete)
        protected void gvColorList_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            try
            {
                int colorId = Convert.ToInt32(e.CommandArgument);

                if (e.CommandName == "EditRow")
                {
                    hfColorID.Value = colorId.ToString();
                    con = conn.openConnection();
                    SqlCommand cmd = new SqlCommand("SELECT * FROM ColorInformation WHERE ColorID = @ColorID", con);
                    cmd.Parameters.AddWithValue("@ColorID", colorId);
                    SqlDataReader reader = cmd.ExecuteReader();
                    if (reader.HasRows)
                    {
                        while (reader.Read())
                        {
                            txtColorCode.Text = reader["ColorCode"].ToString();
                            txtColorName.Text = reader["ColorName"].ToString();
                            txtPantenName.Text = reader["PantenName"].ToString();
                            chkIsActive.Checked = reader["IsActive"] != DBNull.Value && Convert.ToBoolean(reader["IsActive"]);
                        }
                    }
                    con.Close();
                    btnSave.Text = "Update";
                }
                else if (e.CommandName == "DeleteRow")
                {
                    con = conn.openConnection();
                    SqlCommand cmd = new SqlCommand("DELETE FROM ColorInformation WHERE ColorID = @ColorID", con);
                    cmd.Parameters.AddWithValue("@ColorID", colorId);
                    cmd.ExecuteNonQuery();
                    con.Close();

                    lblMessage.Text = "Deleted Successfully!";
                    lblMessage.ForeColor = System.Drawing.Color.Red;

                    ClearForm();
                    LoadNextColorCode();
                    LoadColorInformation();
                }
            }
            catch (Exception ex)
            {
                if (con.State == ConnectionState.Open) con.Close();
                lblMessage.Text = "Error: " + ex.Message;
                lblMessage.ForeColor = System.Drawing.Color.Red;
            }
        }

        // Reset Button Click
        protected void btnReset_Click(object sender, EventArgs e)
        {
            ClearForm();
            LoadNextColorCode();
        }

        private void ClearForm()
        {
            txtColorName.Text = string.Empty;
            txtPantenName.Text = string.Empty;
            chkIsActive.Checked = true;
            hfColorID.Value = "0";
            btnSave.Text = "Save";
            lblMessage.Text = string.Empty;
        }

        // Pager Events (যদি পেজিনেশন ব্যবহার করতে চান)
        protected void lbFirst_Click(object sender, EventArgs e) { }
        protected void lbPrev_Click(object sender, EventArgs e) { }
        protected void lbNext_Click(object sender, EventArgs e) { }
        protected void lbLast_Click(object sender, EventArgs e) { }
        protected void ddlPageSize_Changed(object sender, EventArgs e) { LoadColorInformation(); }

        protected void txtSearch_TextChanged(object sender, EventArgs e)
        {
            try
            {
                con = conn.openConnection();
                SqlDataAdapter da = new SqlDataAdapter("SELECT ColorID, ColorCode, 'Standard' AS ColorType, ColorName, CASE WHEN IsActive = 1 then 'Yes' ELSE 'No' END AS IsActive FROM ColorInformation where ColorName LIKE @SearchTerm ORDER BY ColorID DESC", con);
                da.SelectCommand.Parameters.AddWithValue("@SearchTerm", "%" + txtSearch.Text + "%");
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvColorList.DataSource = dt;
                gvColorList.DataBind();
                con.Close();
            }
            catch (Exception ex)
            {
                if (con.State == ConnectionState.Open) con.Close();
                lblMessage.Text = "Error: " + ex.Message;
                lblMessage.ForeColor = System.Drawing.Color.Red;
            }
        }
    }
}