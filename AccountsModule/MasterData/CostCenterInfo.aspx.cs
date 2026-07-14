using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.AccountsModule.MasterData
{
    public partial class CostCenterInfo : System.Web.UI.Page
    {

        SqlConnection con;
        DatabaseConectionAccounts conn = new DatabaseConectionAccounts();
        SqlCommand cmd;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadCostCenterID(); 
                LoadGridViewCostCenterInfo();
                LoadView_Group_Information();
                LoadView_Branch_Information();
                LoadView_CostingDepartment();
            }
        }

        private void LoadCostCenterID()
        {
            con = conn.openConnection();
            SqlCommand cmd = new SqlCommand("SELECT ISNULL(MAX(CostCenterID),0)+1 FROM Cost_Center", con);
            txtdepartmentID.Text = cmd.ExecuteScalar().ToString();
            con.Close();
        }

        private void LoadGridViewCostCenterInfo()
        {
            using (SqlConnection con = conn.openConnection())
            {
                string query = "Select * from Cost_Center order By CostCenterID asc";
                SqlCommand cmd = new SqlCommand(query, con);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                GridViewCostCenterInfo.DataSource = dt;
                GridViewCostCenterInfo.DataBind();
            }
        }

        private void LoadView_Group_Information()
        {
            using (SqlConnection con = conn.openConnection())
            {
                string query = "SELECT * FROM View_Group_Information order By Group_ID asc";
                SqlDataAdapter da = new SqlDataAdapter(query, con);
                DataTable dt = new DataTable();
                da.Fill(dt);

                DropDownList1.DataSource = dt;
                DropDownList1.DataTextField = "Group_Name";
                DropDownList1.DataValueField = "Group_ID";
                DropDownList1.DataBind();
                DropDownList1.Items.Insert(0, new ListItem("--Select--", "0"));
            }
        }

        private void LoadView_Branch_Information()
        {
            using (SqlConnection con = conn.openConnection())
            {
                string query = "SELECT * FROM View_Branch_Information where IsAccounting=1 order By Branch_ID asc";
                SqlDataAdapter da = new SqlDataAdapter(query, con);
                DataTable dt = new DataTable();
                da.Fill(dt);

                DropDownList2.DataSource = dt;
                DropDownList2.DataTextField = "Branch_Name";
                DropDownList2.DataValueField = "Branch_ID";
                DropDownList2.DataBind();
                DropDownList2.Items.Insert(0, new ListItem("--Select--", "0"));
            }
        }
        private void LoadView_CostingDepartment()
        {
            using (SqlConnection con = conn.openConnection())
            {
                string query = "SELECT * FROM CostingDepartment order By Department_Code asc";
                SqlDataAdapter da = new SqlDataAdapter(query, con);
                DataTable dt = new DataTable();
                da.Fill(dt);

                DropDownList3.DataSource = dt;
                DropDownList3.DataTextField = "Department_Name";
                DropDownList3.DataValueField = "Department_Code";
                DropDownList3.DataBind();
                DropDownList3.Items.Insert(0, new ListItem("--Select--", "0"));
            }
        }
        protected void btnsave_Click(object sender, EventArgs e)
        {
            try
            {
                con = conn.openConnection();
                cmd = new SqlCommand("Cost_Center_Insert", con);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@CostCenterID", txtdepartmentID.Text.Trim());
                cmd.Parameters.AddWithValue("@CostCenterCode", TextBox2.Text.Trim());
                cmd.Parameters.AddWithValue("@CostCenertName", TextBox1.Text.Trim());
                cmd.Parameters.AddWithValue("@CompanyID", DropDownList1.SelectedValue);
                cmd.Parameters.AddWithValue("@OfficeID", DropDownList2.SelectedValue);
                cmd.Parameters.AddWithValue("@DepartmentID", DropDownList3.SelectedValue);
                cmd.Parameters.AddWithValue("@Remarks", TextBox4.Text.Trim());
                cmd.Parameters.AddWithValue("@iS_Active", CheckBox1.Checked);
                cmd.ExecuteNonQuery();
                con.Close();
                string script = "alert('Your information has been saved successfully.');";
                ClientScript.RegisterStartupScript(this.GetType(), "SuccessMessage", script, true);
            }
            catch (Exception ex)
            {
                string errorScript = $"alert('Error: {ex.Message.Replace("'", "\\'")}');";
                ClientScript.RegisterStartupScript(this.GetType(), "ErrorMessage", errorScript, true);
            }
            finally
            {
                if (con.State == ConnectionState.Open)
                {
                    con.Close();
                }
            }
            LoadCostCenterID();
            LoadGridViewCostCenterInfo();
        }

        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            try
            {
                con = conn.openConnection();
                cmd = new SqlCommand("Cost_Center_Update", con);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@CostCenterID", txtdepartmentID.Text.Trim());
                cmd.Parameters.AddWithValue("@CostCenterCode", TextBox2.Text.Trim());
                cmd.Parameters.AddWithValue("@CostCenertName", TextBox1.Text.Trim());
                cmd.Parameters.AddWithValue("@CompanyID", DropDownList1.SelectedValue);
                cmd.Parameters.AddWithValue("@OfficeID", DropDownList2.SelectedValue);
                cmd.Parameters.AddWithValue("@DepartmentID", DropDownList3.SelectedValue);
                cmd.Parameters.AddWithValue("@Remarks", TextBox4.Text.Trim());
                cmd.Parameters.AddWithValue("@iS_Active", CheckBox1.Checked);
                cmd.ExecuteNonQuery();
                con.Close();
                string script = "alert('Your information has been saved successfully.');";
                ClientScript.RegisterStartupScript(this.GetType(), "SuccessMessage", script, true);
            }
            catch (Exception ex)
            {
                string errorScript = $"alert('Error: {ex.Message.Replace("'", "\\'")}');";
                ClientScript.RegisterStartupScript(this.GetType(), "ErrorMessage", errorScript, true);
            }
            finally
            {
                if (con.State == ConnectionState.Open)
                {
                    con.Close();
                }
            }
            LoadCostCenterID();
            LoadGridViewCostCenterInfo();
        }

        protected void Button2_Click(object sender, EventArgs e)
        {
            LoadCostCenterID();
            LoadGridViewCostCenterInfo();
            LoadView_Group_Information();
            LoadView_Branch_Information();
            LoadView_CostingDepartment();
            TextBox1.Text = TextBox2.Text = TextBox4.Text = string.Empty;
            CheckBox1.Checked = false;
        }

        protected void Button3_Click(object sender, EventArgs e)
        {
            try
            {
                con = conn.openConnection();
                cmd = new SqlCommand("Cost_Center_Delete", con);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@CostCenterID", txtdepartmentID.Text.Trim());
                cmd.ExecuteNonQuery();
                con.Close();
                string script = "alert('Your information has been saved successfully.');";
                ClientScript.RegisterStartupScript(this.GetType(), "SuccessMessage", script, true);
                
            }
            catch (Exception ex)
            {
                string errorScript = $"alert('Error: {ex.Message.Replace("'", "\\'")}');";
                ClientScript.RegisterStartupScript(this.GetType(), "ErrorMessage", errorScript, true);
            }
            finally
            {
                if (con.State == ConnectionState.Open)
                {
                    con.Close();
                }
            }
            LoadCostCenterID();
            LoadGridViewCostCenterInfo();
        }

        protected void GridViewCostCenterInfo_SelectedIndexChanged(object sender, EventArgs e)
        {
            txtdepartmentID.Text = GridViewCostCenterInfo.SelectedRow.Cells[1].Text;
            try
            {
                string sql = "Select * from View_Cost_Center where CostCenterID='" + txtdepartmentID.Text + "'";
                con = conn.openConnection();
                cmd = new SqlCommand(sql, con);
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        TextBox1.Text = reader[2].ToString();
                        TextBox2.Text = reader[1].ToString();
                        TextBox4.Text = reader[9].ToString();
                        CheckBox1.Checked = reader[10] != DBNull.Value && Convert.ToBoolean(reader[10]); // ✅ CheckBox

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

            using (SqlConnection con = conn.openConnection())
            {
                string query = "Select * from View_Cost_Center where CostCenterID='" + txtdepartmentID.Text +"'";
                SqlDataAdapter da = new SqlDataAdapter(query, con);
                DataTable dt = new DataTable();
                da.Fill(dt);

                DropDownList1.DataSource = dt;
                DropDownList1.DataTextField = "Group_Name";
                DropDownList1.DataValueField = "Group_ID";
                DropDownList1.DataBind();
            }
            using (SqlConnection con = conn.openConnection())
            {
                string query = "Select * from View_Cost_Center where CostCenterID='" + txtdepartmentID.Text + "'";
                SqlDataAdapter da = new SqlDataAdapter(query, con);
                DataTable dt = new DataTable();
                da.Fill(dt);

                DropDownList2.DataSource = dt;
                DropDownList2.DataTextField = "Branch_Name";
                DropDownList2.DataValueField = "Branch_ID";
                DropDownList2.DataBind();
            }
            using (SqlConnection con = conn.openConnection())
            {
                string query = "Select * from View_Cost_Center where CostCenterID='" + txtdepartmentID.Text + "'";
                SqlDataAdapter da = new SqlDataAdapter(query, con);
                DataTable dt = new DataTable();
                da.Fill(dt);

                DropDownList3.DataSource = dt;
                DropDownList3.DataTextField = "Department_Name";
                DropDownList3.DataValueField = "Department_Code";
                DropDownList3.DataBind();
            }
        }

        protected void DropDownList1_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadView_Group_Information();
        }

        protected void DropDownList2_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadView_Branch_Information();
        }

        protected void DropDownList3_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadView_CostingDepartment();
        }

        protected void DropDownList1_Load(object sender, EventArgs e)
        {
            LoadView_Group_Information();
        }
    }
}