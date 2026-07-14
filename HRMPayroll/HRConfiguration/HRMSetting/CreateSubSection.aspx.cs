using Nexa_ERP.Connection;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.HRMPayroll.HRConfiguration.HRMSetting
{
    public partial class CreateSubSection : System.Web.UI.Page
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

            SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM TB_Line Order by Line_Name asc", con);
            DataTable dt = new DataTable();
            da.Fill(dt);

            gvsubSection.DataSource = dt;
            gvsubSection.DataBind();

            con.Close();
        }

        protected void gvsubSection_SelectedIndexChanged(object sender, EventArgs e)
        {
            txtSubSectionId.Text = gvsubSection.SelectedRow.Cells[1].Text;

            try
            {
                string sql = "Select * from TB_Line where Line_Code ='" + txtSubSectionId.Text + "'";

                con = conn.openConnection();
                cmd = new SqlCommand(sql, con);
                SqlDataReader reader = cmd.ExecuteReader();

                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        txtLineName.Text = reader[1].ToString();
                        txtBanglaName.Text = reader[2].ToString();
                        txtPrefix.Text = reader[4].ToString();
                        txtRequiredManpower.Text = reader[5].ToString();
                        txtExtraRequiredManpower.Text = reader[6].ToString();
                        chkIsActive.Checked = reader[7] != DBNull.Value && Convert.ToBoolean(reader[7]);
                    }
                }
                else
                {
                    txtSubSectionId.Text=txtLineName.Text = txtBanglaName.Text = txtPrefix.Text = txtRequiredManpower.Text = txtExtraRequiredManpower.Text = txtBanglaName.Text = string.Empty;
                    chkIsActive.Checked = false;
                }

                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                con = conn.openConnection();

                using (SqlCommand cmd = new SqlCommand("Pro_Line_Save_Web", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.Add("@Line_Code", SqlDbType.Int).Value =
                        string.IsNullOrEmpty(txtSubSectionId.Text) ? 0 : Convert.ToInt32(txtSubSectionId.Text);

                    cmd.Parameters.Add("@Line_Name", SqlDbType.NVarChar, 200).Value = txtLineName.Text.Trim();
                    cmd.Parameters.Add("@Line_bangla_Name", SqlDbType.NVarChar, 200).Value = txtBanglaName.Text.Trim();

                    cmd.Parameters.Add("@SubSectionPrefix", SqlDbType.NVarChar, 50).Value =
                        txtPrefix.Text.Trim();

                    cmd.Parameters.Add("@SubSectionRequiredManpower", SqlDbType.Int).Value =
                        string.IsNullOrEmpty(txtRequiredManpower.Text) ? 0 : Convert.ToInt32(txtRequiredManpower.Text);

                    cmd.Parameters.Add("@SubSectionExtra_Required_Manpower", SqlDbType.Int).Value =
                        string.IsNullOrEmpty(txtExtraRequiredManpower.Text) ? 0 : Convert.ToInt32(txtExtraRequiredManpower.Text);

                    cmd.Parameters.Add("@IsActive", SqlDbType.Bit).Value = chkIsActive.Checked;

                    cmd.ExecuteNonQuery();

                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert",
                        "alert('Save Successfully!');", true);
                }

                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert",
                    "alert('" + ex.Message.Replace("'", "") + "');", true);
            }

            LoadSectionInformation();
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            txtLineName.Text = txtBanglaName.Text = txtPrefix.Text = txtRequiredManpower.Text = txtExtraRequiredManpower.Text = txtBanglaName.Text = string.Empty;
            chkIsActive.Checked = false;
        }
    }
}