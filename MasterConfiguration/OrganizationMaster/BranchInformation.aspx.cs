using Nexa_ERP.Connection;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.ERPConfiguration.CompanyInformation
{
    public partial class BranchInformation : System.Web.UI.Page
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
                LoadNextBranchID();
                GroupInformationLoad();
                LoadBranchInformation();
            }
        }

        void LoadNextBranchID()
        {
            try
            {
                con = conn.openConnection();
                SqlCommand cmd = new SqlCommand("SELECT ISNULL(MAX(Branch_ID),0)+1 FROM Branch_Information", con);
                txtBranchID.Text = cmd.ExecuteScalar().ToString();
                con.Close();
            }
            catch { }
        }

        private void GroupInformationLoad()
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT Group_ID, Group_Name FROM Group_Information WHERE Is_Active=1";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlGroup.DataSource = dt;
                    ddlGroup.DataTextField = "Group_Name";
                    ddlGroup.DataValueField = "Group_ID";
                    ddlGroup.DataBind();

                    ddlGroup.Items.Insert(0, new ListItem("--Select Group--", "0"));
                }
                con.Close();
            }
            catch (Exception ex)
            {
                Response.Write("Error: " + ex.Message);
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                byte[] logoBytes = null;
                if (fuBranchLogo.HasFile)
                {
                    int fileSize = fuBranchLogo.PostedFile.ContentLength;
                    logoBytes = new byte[fileSize];
                    fuBranchLogo.PostedFile.InputStream.Read(logoBytes, 0, fileSize);
                }

                con = conn.openConnection();
                using (SqlCommand cmd = new SqlCommand("sp_BranchInformation", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@Branch_ID", SqlDbType.Int).Value = Convert.ToInt32(txtBranchID.Text);
                    cmd.Parameters.Add("@Group_ID", SqlDbType.Int).Value = Convert.ToInt32(ddlGroup.SelectedValue);
                    cmd.Parameters.Add("@Branch_Name", SqlDbType.NVarChar).Value = txtBranch.Text.Trim();
                    cmd.Parameters.Add("@Prifix", SqlDbType.NVarChar).Value = txtPrefix.Text.Trim();
                    cmd.Parameters.Add("@E_Mail", SqlDbType.NVarChar).Value = txtEmail.Text.Trim();
                    cmd.Parameters.Add("@Phone_No", SqlDbType.NVarChar).Value = txtPhone.Text.Trim();
                    cmd.Parameters.Add("@Web", SqlDbType.NVarChar).Value = txtWeb.Text.Trim();
                    cmd.Parameters.Add("@Address", SqlDbType.NVarChar).Value = txtAddress.Text.Trim();
                    cmd.Parameters.Add("@Is_Active", SqlDbType.Bit).Value = chkIsActive.Checked;

                    SqlParameter paramLogo = new SqlParameter("@Branch_Logo", SqlDbType.VarBinary, -1);
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
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }

            LoadBranchInformation();
            ClearForm();
        }

        private void LoadBranchInformation()
        {
            try
            {
                con = conn.openConnection();
                SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM Branch_Information", con);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvBranch.DataSource = dt;
                gvBranch.DataBind();
                con.Close();
            }
            catch { }
        }

        protected void gvBranch_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (gvBranch.SelectedDataKey == null ||
                !int.TryParse(gvBranch.SelectedDataKey.Value?.ToString(), out int branchId))
            {
                return;
            }

            try
            {
                string sql = "SELECT * FROM Branch_Information WHERE Branch_ID = @BranchID";
                con = conn.openConnection();
                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.Add("@BranchID", SqlDbType.Int).Value = branchId;
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            txtBranchID.Text = reader["Branch_ID"].ToString();
                            ddlGroup.SelectedValue = reader["Group_ID"].ToString();
                            txtBranch.Text = reader["Branch_Name"].ToString();
                            txtPrefix.Text = reader["Prifix"].ToString();
                            txtEmail.Text = reader["E_Mail"].ToString();
                            txtPhone.Text = reader["Phone_No"].ToString();
                            txtWeb.Text = reader["Web"].ToString();
                            txtAddress.Text = reader["Address"].ToString();
                            chkIsActive.Checked = reader["Is_Active"] != DBNull.Value && Convert.ToBoolean(reader["Is_Active"]);

                            // Handle Logo Preview
                            if (reader["Branch_Logo"] != DBNull.Value)
                            {
                                byte[] bytes = (byte[])reader["Branch_Logo"];
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
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ClearForm();
        }

        private void ClearForm()
        {
            txtBranch.Text = string.Empty;
            txtPrefix.Text = string.Empty;
            txtEmail.Text = string.Empty;
            txtPhone.Text = string.Empty;
            txtWeb.Text = string.Empty;
            txtAddress.Text = string.Empty;
            chkIsActive.Checked = true;
            ddlGroup.SelectedIndex = 0;
            imgLogoPreview.ImageUrl = "~/Images/no-image.png";
            LoadNextBranchID();
        }
    }
}