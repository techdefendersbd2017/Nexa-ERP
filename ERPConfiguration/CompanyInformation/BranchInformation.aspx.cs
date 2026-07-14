using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.ERPConfiguration.CompanyInformation
{
    public partial class BranchInformation : System.Web.UI.Page
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
                GroupInformationLoad();
                LoadNextBranchID();
                LoadBranchInformation();
            }
        }
        void LoadNextBranchID()
        {
            con = conn.openConnection();
            {
                SqlCommand cmd = new SqlCommand("SELECT ISNULL(MAX(Branch_ID ),0)+1 FROM Branch_Information", con);
                txtBranchID.Text = cmd.ExecuteScalar().ToString();
            }
            con.Close();
        }
        private void GroupInformationLoad()
        {
            try
            {
                con = conn.openConnection();
                {
                    string query = "SELECT * FROM Group_Information where Is_Active=1";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataSet ds = new DataSet();
                        da.Fill(ds);

                        ddlGroup.DataSource = ds.Tables[0];
                        ddlGroup.DataTextField = "Group_Name";
                        ddlGroup.DataValueField = "Group_ID";
                        ddlGroup.DataBind();

                        ddlGroup.Items.Insert(0, new ListItem("--Select--", "0"));
                    }
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
                con = conn.openConnection();
                {
                    using (SqlCommand cmd = new SqlCommand("sp_BranchInformationInsertUpdate", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add("@Branch_ID", SqlDbType.Int).Value = txtBranchID.Text;
                        cmd.Parameters.Add("@Group_ID", SqlDbType.NVarChar).Value = ddlGroup.SelectedValue;
                        cmd.Parameters.Add("@Branch_Name", SqlDbType.NVarChar).Value = txtBranch.Text;
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
            LoadBranchInformation();
        }
        private void LoadBranchInformation()
        {
            con = conn.openConnection();
            {
                SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM Branch_Information", con);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvBranch.DataSource = dt;
                gvBranch.DataBind();
            }
            con.Close();
        }

        protected void gvBranch_SelectedIndexChanged(object sender, EventArgs e)
        {
            txtBranchID.Text = gvBranch.SelectedRow.Cells[1].Text;
            try
            {
                string sql = "Select * from Branch_Information where Branch_ID ='" + txtBranchID.Text + "'";
                con = conn.openConnection();
                cmd = new SqlCommand(sql, con);
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        txtBranchID.Text = reader[0].ToString();
                        ddlGroup.SelectedValue = reader[1].ToString();
                        txtBranch.Text = reader[2].ToString();
                        txtPrefix.Text = reader[3].ToString();
                        txtEmail.Text = reader[4].ToString();
                        txtPhone.Text = reader[5].ToString();
                        txtWeb.Text = reader[6].ToString();
                        txtAddress.Text = reader[7].ToString();
                        chkIsActive.Checked = reader[8] != DBNull.Value && Convert.ToBoolean(reader[8]); // ✅ CheckBox
                    }
                }
                else
                {
                    txtBranchID.Text = txtBranch.Text = txtPrefix.Text = txtEmail.Text = string.Empty;
                    txtPhone.Text = txtWeb.Text = txtAddress.Text = string.Empty;
                    chkIsActive.Checked = false;
                }
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
        }
    }
}