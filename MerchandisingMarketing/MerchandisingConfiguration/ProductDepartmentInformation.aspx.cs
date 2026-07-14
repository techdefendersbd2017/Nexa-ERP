using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.MerchandisingMarketing.MerchandisingConfiguration
{
    public partial class ProductDepartmentInformation : System.Web.UI.Page
    {
        SqlConnection con;
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();
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
                LoadgvDepartmentInformation();
            }
        }

        private void LoadgvDepartmentInformation()
        {
            con = conn.openConnection();
            {
                SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM Product_Department", con);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvDepartmentInformation.DataSource = dt;
                gvDepartmentInformation.DataBind();
            }
            con.Close();
        }

        protected void LinkButton1_Click(object sender, EventArgs e)
        {
            try
            {
                con = conn.openConnection();

                using (SqlCommand cmd = new SqlCommand("sp_ProductDepartment_Save", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@DepartmentID", string.IsNullOrEmpty(txtDepartmentID.Text) ? 0 : Convert.ToInt64(txtDepartmentID.Text));
                    cmd.Parameters.AddWithValue("@DepartmentName", txtDepartmentName.Text.Trim());
                    cmd.Parameters.AddWithValue("@IsActive", chkIsActive.Checked);
                    cmd.ExecuteNonQuery();

                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert",
                        "alert('Saved Successfully!');", true);
                }

                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert",
                    "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
            LoadgvDepartmentInformation();
        }

        protected void Button1_Click(object sender, EventArgs e)
        {
            txtDepartmentID.Text = txtDepartmentName.Text = string.Empty;
            chkIsActive.Checked = false;
        }

        protected void gvDepartmentInformation_SelectedIndexChanged(object sender, EventArgs e)
        {
            txtDepartmentID.Text = gvDepartmentInformation.SelectedRow.Cells[1].Text;
            try
            {
                string sql = "Select * from Product_Department where DepartmentID ='" + txtDepartmentID.Text + "'";
                con = conn.openConnection();
                cmd = new SqlCommand(sql, con);
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        txtDepartmentID.Text = reader[0].ToString();
                        txtDepartmentName.Text = reader[1].ToString();
                        chkIsActive.Checked = reader[2] != DBNull.Value && Convert.ToBoolean(reader[2]); // ✅ CheckBox
                    }
                }
                else
                {
                    txtDepartmentID.Text = txtDepartmentName.Text =  string.Empty;
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