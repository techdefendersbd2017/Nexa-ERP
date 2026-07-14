using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.HRMPayroll.HRConfiguration.HRMSetting
{
    public partial class SectionInformation : System.Web.UI.Page
    {
        SqlConnection con;
        PayrollDB conn = new PayrollDB();
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
                LoadSectionInformation();
            }
        }
        private void LoadSectionInformation()
        {
            con = conn.openConnection();
            {
                SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM TB_Section Order by Section_Name asc", con);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvSection.DataSource = dt;
                gvSection.DataBind();
            }
            con.Close();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                con = conn.openConnection();
                {
                    using (SqlCommand cmd = new SqlCommand("Pro_Section_Save_Web", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Add("@Section_Code", SqlDbType.Int).Value = string.IsNullOrEmpty(txtSectionID.Text) ? 0 : Convert.ToInt32(txtSectionID.Text); 
                        cmd.Parameters.Add("@Section_Name", SqlDbType.NVarChar).Value = txtSectionName.Text;
                        cmd.Parameters.Add("@Section_bangla_Name", SqlDbType.NVarChar).Value = txtSectionNameLocal.Text;
                        cmd.Parameters.Add("@SecPrefix", SqlDbType.NVarChar).Value = txtPrefix.Text;
                        cmd.Parameters.Add("@SectionRequiredManpower", SqlDbType.BigInt).Value = string.IsNullOrEmpty(txtRequiredManpower.Text) ? 0 : Convert.ToInt32(txtRequiredManpower.Text); 
                        cmd.Parameters.Add("@SectionExtra_Required_Manpower", SqlDbType.BigInt).Value = string.IsNullOrEmpty(txtExtraRequiredManpower.Text) ? 0 : Convert.ToInt32(txtExtraRequiredManpower.Text);
                        cmd.Parameters.Add("@IsActive", SqlDbType.Bit).Value = chkIsActive.Checked;
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
            LoadSectionInformation();
        }

        

        protected void gvSection_SelectedIndexChanged(object sender, EventArgs e)
        {
            txtSectionID.Text = gvSection.SelectedRow.Cells[1].Text;
            try
            {
                string sql = "Select * from TB_Section where Section_Code ='" + txtSectionID.Text + "'";
                con = conn.openConnection();
                cmd = new SqlCommand(sql, con);
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        txtSectionName.Text = reader[1].ToString();
                        txtSectionNameLocal.Text = reader[2].ToString();
                        txtPrefix.Text = reader[4].ToString();
                        txtRequiredManpower.Text = reader[5].ToString();
                        txtExtraRequiredManpower.Text = reader[6].ToString();
                        chkIsActive.Checked = reader[7] != DBNull.Value && Convert.ToBoolean(reader[7]); // ✅ CheckBox

                    }
                }
                else
                {
                    txtSectionID.Text = txtSectionName.Text = txtPrefix.Text = txtSectionNameLocal.Text = txtRequiredManpower.Text = txtExtraRequiredManpower.Text = string.Empty;
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
            txtSectionName.Text = txtPrefix.Text = txtSectionNameLocal.Text = txtRequiredManpower.Text = txtExtraRequiredManpower.Text = string.Empty;
            chkIsActive.Checked = false;
        }
    }
}