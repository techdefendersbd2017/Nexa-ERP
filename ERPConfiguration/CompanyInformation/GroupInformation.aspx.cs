using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.ERPConfiguration.CompanyInformation
{
    public partial class GroupInformation : System.Web.UI.Page
    {
        SqlConnection con;
        Database_Connection conn = new Database_Connection();
        SqlCommand cmd;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string user = Request.QueryString["user"];
                if (!string.IsNullOrEmpty(user))
                {
                    Label1.Text = "Welcome, " + user;
                }
                LoadGroupInformation();
                LoadNextGroupID();
            }
        }

        void LoadNextGroupID()
        {
            con = conn.openConnection();
            {
                SqlCommand cmd = new SqlCommand("SELECT ISNULL(MAX(Group_ID ),0)+1 FROM Group_Information", con);
                txtGroupID.Text = cmd.ExecuteScalar().ToString();
            }
            con.Close();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                con = conn.openConnection();
                {
                    using (SqlCommand cmd = new SqlCommand("sp_GroupInformation_InsertUpdate", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add("@Group_ID", SqlDbType.Int).Value = txtGroupID.Text;
                        cmd.Parameters.Add("@Group_Name", SqlDbType.NVarChar).Value = txtGroupName.Text;
                        cmd.Parameters.Add("@Prifix", SqlDbType.NVarChar).Value = txtPrefix.Text;
                        cmd.Parameters.Add("@E_Mail", SqlDbType.NVarChar).Value = txtEmail.Text;
                        cmd.Parameters.Add("@Phone_No", SqlDbType.NVarChar).Value = txtPhone.Text;
                        cmd.Parameters.Add("@Web", SqlDbType.NVarChar).Value = txtWeb.Text;
                        cmd.Parameters.Add("@Address", SqlDbType.NVarChar).Value = txtAddress.Text;
                        cmd.Parameters.Add("@is_active", SqlDbType.Bit).Value = chkIsActive.Checked;
                        cmd.ExecuteNonQuery();
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Save Successfully!');", true);
                    }
                }
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message + "');", true);
            }
            LoadGroupInformation();
        }

        private void LoadGroupInformation()
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
            txtGroupID.Text = gvGroup.SelectedRow.Cells[1].Text;
            try
            {
                string sql = "Select * from Group_Information where Group_ID ='" + txtGroupID.Text + "'";
                con = conn.openConnection();
                cmd = new SqlCommand(sql, con);
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        txtGroupID.Text = reader[0].ToString();
                        txtGroupName.Text = reader[1].ToString();
                        txtPrefix.Text = reader[2].ToString();
                        txtEmail.Text = reader[3].ToString();
                        txtPhone.Text = reader[4].ToString();
                        txtWeb.Text = reader[5].ToString();
                        txtAddress.Text = reader[6].ToString();
                        chkIsActive.Checked = reader[7] != DBNull.Value && Convert.ToBoolean(reader[7]); // ✅ CheckBox
                    }
                }
                else
                {
                    txtGroupID.Text = txtGroupName.Text = txtPrefix.Text = txtEmail.Text = string.Empty;
                    txtPhone.Text =txtWeb.Text = txtAddress.Text = string.Empty;
                    chkIsActive.Checked = false;
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
            LoadNextGroupID();
            txtGroupID.Text = txtGroupName.Text = txtPrefix.Text = txtEmail.Text = string.Empty;
            txtPhone.Text = txtWeb.Text = txtAddress.Text = string.Empty;
            chkIsActive.Checked = false;
        }
    }
}