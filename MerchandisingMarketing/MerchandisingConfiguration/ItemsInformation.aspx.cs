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
    public partial class ItemsInformation : System.Web.UI.Page
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
                LoadgvItemsInformation();
            }
        }

        private void LoadgvItemsInformation()
        {
            con = conn.openConnection();
            {
                SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM Items_Information", con);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvItemsInformation.DataSource = dt;
                gvItemsInformation.DataBind();
            }
            con.Close();
        }

        protected void LinkButton1_Click(object sender, EventArgs e)
        {
            try
            {
                con = conn.openConnection();

                using (SqlCommand cmd = new SqlCommand("sp_InsertUpdate_Items", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@ItemsID", string.IsNullOrEmpty(txtItemsID.Text) ? 0 : Convert.ToInt64(txtItemsID.Text));
                    cmd.Parameters.AddWithValue("@ItemsName", txtItemsName.Text.Trim());
                    cmd.Parameters.AddWithValue("@IsActive", chkIsActive.Checked);
                    cmd.ExecuteNonQuery();
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Saved Successfully!');", true);
                }

                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert",
                    "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
            LoadgvItemsInformation();
        }

        protected void Button1_Click(object sender, EventArgs e)
        {
            txtItemsID.Text = txtItemsName.Text = string.Empty;
            chkIsActive.Checked = false;
        }

        protected void gvItemsInformation_SelectedIndexChanged(object sender, EventArgs e)
        {
            txtItemsID.Text = gvItemsInformation.SelectedRow.Cells[1].Text;
            try
            {
                string sql = "Select * from Items_Information where ItemsID ='" + txtItemsID.Text + "'";
                con = conn.openConnection();
                cmd = new SqlCommand(sql, con);
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        txtItemsID.Text = reader[0].ToString();
                        txtItemsName.Text = reader[1].ToString();
                        chkIsActive.Checked = reader[2] != DBNull.Value && Convert.ToBoolean(reader[2]); // ✅ CheckBox
                    }
                }
                else
                {
                    txtItemsID.Text = txtItemsName.Text = string.Empty;
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