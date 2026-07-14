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

namespace Nexa_ERP.AccountsModule.MasterData
{
    public partial class costCenterGroupInfo : System.Web.UI.Page
    {

        SqlConnection con;
        DatabaseConectionAccounts conn = new DatabaseConectionAccounts();
        SqlCommand cmd;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadCostCenterGroupID();
                LoadGridViewPaymentModeList();
            }
        }
        public void LoadCostCenterGroupID()
        {
            con = conn.openConnection();
            {
                SqlCommand cmd = new SqlCommand("SELECT ISNULL(MAX(CostCenterGroupID),0)+1 FROM Cost_Center_Group", con);
                txtdepartmentID.Text = cmd.ExecuteScalar().ToString();
            }
            con.Close();
        }
        private void LoadGridViewPaymentModeList()
        {
            using (SqlConnection con = conn.openConnection())
            {
                string query = "SELECT * FROM Cost_Center_Group  order By ShortingName asc";
                SqlCommand cmd = new SqlCommand(query, con);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                GridViewCostCenterList.DataSource = dt;
                GridViewCostCenterList.DataBind();
            }
        }

        protected void GridViewCostCenterList_SelectedIndexChanged(object sender, EventArgs e)
        {
            txtdepartmentID.Text = GridViewCostCenterList.SelectedRow.Cells[1].Text;
            try
            {
                string sql = "Select * from Cost_Center_Group where CostCenterGroupID ='" + txtdepartmentID.Text + "'";
                con = conn.openConnection();
                cmd = new SqlCommand(sql, con);
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        TextBox1.Text = reader[1].ToString();
                        TextBox2.Text = reader[2].ToString();
                        TextBox4.Text = reader[3].ToString();
                        CheckBox1.Checked = reader[4] != DBNull.Value && Convert.ToBoolean(reader[4]); // ✅ CheckBox

                    }
                }
                else
                {
                    TextBox1.Text = TextBox2.Text = TextBox4.Text = string.Empty;
                    CheckBox1.Checked = false;
                }
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
        }

        protected void TextBox3_TextChanged(object sender, EventArgs e)
        {
            using (SqlConnection con = conn.openConnection())
            {
                // Use the LIKE operator with % wildcards
                // @SearchTerm is a parameter to prevent SQL Injection
                string query = "SELECT * FROM Cost_Center_Group WHERE CostCenterGroupName LIKE @SearchTerm ORDER BY CostCenterGroupID ASC";

                SqlCommand cmd = new SqlCommand(query, con);

                // This adds the % wildcards around your textbox value
                // Example: If you type "Ads", it searches for "%Ads%" (matches anything containing "Ads")
                cmd.Parameters.AddWithValue("@SearchTerm", "%" + TextBox3.Text.Trim() + "%");

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                GridViewCostCenterList.DataSource = dt;
                GridViewCostCenterList.DataBind();
            }
        }

        protected void btnsave_Click(object sender, EventArgs e)
        {
            try
            {
                con = conn.openConnection();
                using (SqlCommand cmd = new SqlCommand("Cost_Center_Group_Insert", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@CostCenterGroupID", txtdepartmentID.Text.Trim());
                    cmd.Parameters.AddWithValue("@CostCenterGroupName", TextBox1.Text.Trim());
                    cmd.Parameters.AddWithValue("@ShortingName", TextBox2.Text.Trim());
                    cmd.Parameters.AddWithValue("@Remarks", TextBox4.Text.Trim());
                    cmd.Parameters.AddWithValue("@Is_Active", CheckBox1.Checked);

                    cmd.ExecuteNonQuery();
                }

                con.Close();

                LoadGridViewPaymentModeList();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Saved Successfully!');", true);
            }
            catch (Exception ex)
            {
                string msg = ex.Message.Replace("'", "");
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + msg + "');", true);
            }
            finally
            {
                if (con.State == ConnectionState.Open) { con.Close(); }
            }
        }

        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            try
            {
                con = conn.openConnection();
                using (SqlCommand cmd = new SqlCommand("Cost_Center_Group_Update", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@CostCenterGroupID", txtdepartmentID.Text.Trim());
                    cmd.Parameters.AddWithValue("@CostCenterGroupName", TextBox1.Text.Trim());
                    cmd.Parameters.AddWithValue("@ShortingName", TextBox2.Text.Trim());
                    cmd.Parameters.AddWithValue("@Remarks", TextBox4.Text.Trim());
                    cmd.Parameters.AddWithValue("@Is_Active", CheckBox1.Checked);

                    cmd.ExecuteNonQuery();
                }

                con.Close();

                LoadGridViewPaymentModeList();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Saved Successfully!');", true);
            }
            catch (Exception ex)
            {
                string msg = ex.Message.Replace("'", "");
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + msg + "');", true);
            }
            finally
            {
                if (con.State == ConnectionState.Open) { con.Close(); }
            }
        }

        protected void Button3_Click(object sender, EventArgs e)
        {            
            try
            {
                con = conn.openConnection();
                using (SqlCommand cmd = new SqlCommand("Cost_Center_Group_Delete", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@CostCenterGroupID", txtdepartmentID.Text.Trim());

                    cmd.ExecuteNonQuery();
                }

                con.Close();

                LoadGridViewPaymentModeList();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Saved Successfully!');", true);
            }
            catch (Exception ex)
            {
                string msg = ex.Message.Replace("'", "");
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + msg + "');", true);
            }
            finally
            {
                if (con.State == ConnectionState.Open) { con.Close(); }
            }
        }

        protected void Button2_Click(object sender, EventArgs e)
        {

        }
    }
}