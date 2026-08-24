using Nexa_ERP.Connection;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.TrimsAccessories.MsterSetup
{
    public partial class ModelSetup : System.Web.UI.Page
    {
        SqlConnection con;
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();
        SqlCommand cmd;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadModelInformation();
            }
        }

        // গ্রিডভিউতে মডেলের তালিকা লোড করার মেথড
        private void LoadModelInformation()
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT ModelID, ROW_NUMBER() OVER(ORDER BY ModelID) AS SlNo, ModelName, Status FROM ModelSetup ORDER BY ModelName ASC";
                SqlDataAdapter da = new SqlDataAdapter(query, con);
                DataTable dt = new DataTable();
                da.Fill(dt);

                gvModels.DataSource = dt;
                gvModels.DataBind();
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "\\'") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) con.Close();
            }
        }

        // ফর্ম ক্লিয়ার বা রিসেট করার মেথড
        private void clearform()
        {
            txtModelID.Text = string.Empty;
            txtModelName.Text = string.Empty;
            ddlStatus.SelectedValue = "Active";
            btnSave.Text = "Save";
        }

        // গ্রিডভিউ থেকে এডিট (Select) করার জন্য
        protected void gvModels_SelectedIndexChanged(object sender, EventArgs e)
        {
            // GridView-এর DataKeyNames এ "ModelID" সেট থাকতে হবে
            string modelId = gvModels.SelectedDataKey.Value.ToString();
            txtModelID.Text = modelId;

            try
            {
                string sql = "SELECT * FROM ModelSetup WHERE ModelID = @ModelID";
                con = conn.openConnection();
                cmd = new SqlCommand(sql, con);
                cmd.Parameters.AddWithValue("@ModelID", modelId);

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.HasRows)
                    {
                        while (reader.Read())
                        {
                            txtModelName.Text = reader["ModelName"].ToString();
                            ddlStatus.SelectedValue = reader["Status"].ToString();
                            btnSave.Text = "Update"; // এডিট মোডে আসলে বাটন টেক্সট Update হয়ে যাবে
                            break;
                        }
                    }
                    else
                    {
                        clearform();
                    }
                }
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open)
                {
                    con.Close();
                }
            }
        }

        // রিফ্রেশ বা ক্যানসেল বাটন ক্লিক
        protected void btnCancel_Click(object sender, EventArgs e)
        {
            clearform();
        }

        // সেভ অথবা আপডেট বাটন ক্লিক
        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                con = conn.openConnection();
                using (SqlCommand cmd = new SqlCommand("sp_ModelSetup_SaveUpdate", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    int modelId = 0;
                    if (!string.IsNullOrEmpty(txtModelID.Text.Trim()))
                    {
                        int.TryParse(txtModelID.Text.Trim(), out modelId);
                    }

                    cmd.Parameters.AddWithValue("@ModelID", modelId == 0 ? (object)DBNull.Value : modelId);
                    cmd.Parameters.AddWithValue("@ModelName", string.IsNullOrEmpty(txtModelName.Text.Trim()) ? (object)DBNull.Value : txtModelName.Text.Trim());
                    cmd.Parameters.AddWithValue("@Status", ddlStatus.SelectedValue);

                    cmd.ExecuteNonQuery();

                    if (modelId == 0)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Model Saved Successfully!');", true);
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Model Updated Successfully!');", true);
                    }

                    clearform();
                    LoadModelInformation();
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error: " + ex.Message.Replace("'", "\\'") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) con.Close();
            }
        }
    }
}