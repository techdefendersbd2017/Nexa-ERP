using Nexa_ERP.Connection;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.ERPConfiguration.CompanyInformation
{
    public partial class GroupInformation : System.Web.UI.Page
    {
        SqlConnection con;
        Database_Connection conn = new Database_Connection();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string user = Request.QueryString["user"];
                if (!string.IsNullOrEmpty(user))
                {
                    Label1.Text = "Welcome, " + user;
                }
                LoadNextGroupID();
                LoadGroupInformation();
            }
        }

        void LoadNextGroupID()
        {
            con = conn.openConnection();
            {
                SqlCommand cmd = new SqlCommand("SELECT ISNULL(MAX(Group_ID),0)+1 FROM Group_Information", con);
                txtGroupID.Text = cmd.ExecuteScalar().ToString();
            }
            con.Close();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                byte[] logoBytes = null;

                if (fuLogo.HasFile)
                {
                    int fileSize = fuLogo.PostedFile.ContentLength;
                    logoBytes = new byte[fileSize];
                    fuLogo.PostedFile.InputStream.Read(logoBytes, 0, fileSize);
                }

                con = conn.openConnection();
                using (SqlCommand cmd = new SqlCommand("sp_GroupInformation_Insert", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@Group_ID", SqlDbType.Int).Value = Convert.ToInt32(txtGroupID.Text);
                    cmd.Parameters.Add("@Group_Name", SqlDbType.NVarChar, 150).Value = txtGroup.Text.Trim();
                    cmd.Parameters.Add("@Prifix", SqlDbType.NVarChar, 50).Value = txtPrefix.Text.Trim();
                    cmd.Parameters.Add("@E_Mail", SqlDbType.NVarChar, 150).Value = txtEmail.Text.Trim();
                    cmd.Parameters.Add("@Phone_No", SqlDbType.NVarChar, 50).Value = txtPhone.Text.Trim();
                    cmd.Parameters.Add("@Web", SqlDbType.NVarChar, 150).Value = txtWeb.Text.Trim();
                    cmd.Parameters.Add("@Address", SqlDbType.NVarChar, 300).Value = txtAddress.Text.Trim();
                    cmd.Parameters.Add("@Is_Active", SqlDbType.Bit).Value = chkIsActive.Checked;

                    SqlParameter paramLogo = new SqlParameter("@Logo", SqlDbType.VarBinary, -1);
                    if (logoBytes != null)
                    {
                        paramLogo.Value = logoBytes;
                    }
                    else
                    {
                        paramLogo.Value = DBNull.Value;
                    }
                    cmd.Parameters.Add(paramLogo);

                    cmd.ExecuteNonQuery();

                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Save Successfully!');", true);
                }
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message + "');", true);
            }
            LoadGroupInformation();
            ClearForm();
        }

        void LoadGroupInformation()
        {
            con = conn.openConnection();
            {
                SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM Group_Information", con);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvGroup.DataSource = dt;
                gvGroup.DataBind();
            }
            con.Close();
        }

        protected void gvGroup_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (gvGroup.SelectedDataKey == null ||
                !int.TryParse(gvGroup.SelectedDataKey.Value?.ToString(), out int groupId))
            {
                return;
            }

            const string sql = "SELECT * FROM Group_Information WHERE Group_ID = @GroupID";

            try
            {
                using (SqlConnection con = conn.openConnection())
                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.Add("@GroupID", SqlDbType.Int).Value = groupId;

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            txtGroupID.Text = reader["Group_ID"].ToString();
                            txtGroup.Text = reader["Group_Name"].ToString();
                            txtPrefix.Text = reader["Prifix"].ToString();
                            txtEmail.Text = reader["E_Mail"].ToString();
                            txtPhone.Text = reader["Phone_No"].ToString();
                            txtWeb.Text = reader["Web"].ToString();
                            txtAddress.Text = reader["Address"].ToString();
                            chkIsActive.Checked = Convert.ToBoolean(reader["Is_Active"]);

                            if (reader["Logo"] != DBNull.Value)
                            {
                                byte[] bytes = (byte[])reader["Logo"];
                                string base64String = Convert.ToBase64String(bytes);
                                imgLogoPreview.ImageUrl = "data:image/png;base64," + base64String;
                            }
                            else
                            {
                                imgLogoPreview.ImageUrl = "~/Images/no-image.png";
                            }
                        }
                    }
                }
            }
            catch (Exception)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "alert",
                    "alert('Could not load the selected group. Please try again.');", true);
            }
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ClearForm();
        }

        private void ClearForm()
        {
            txtGroup.Text = string.Empty;
            txtPrefix.Text = string.Empty;
            txtEmail.Text = string.Empty;
            txtPhone.Text = string.Empty;
            txtWeb.Text = string.Empty;
            txtAddress.Text = string.Empty;
            chkIsActive.Checked = true;
            imgLogoPreview.ImageUrl = "~/Images/no-image.png";
            LoadNextGroupID();
        }
    }
}