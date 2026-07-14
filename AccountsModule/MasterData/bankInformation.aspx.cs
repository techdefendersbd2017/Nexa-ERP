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
    public partial class bankInformation : System.Web.UI.Page
    {

        SqlConnection con;
        DatabaseConectionAccounts conn = new DatabaseConectionAccounts();
        SqlCommand cmd;
        String CountryID;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadID();
                LoadView_Country_Information();
                LoadGridViewBankInformation(); 
            }
        }
        private void LoadID()
        {
            con = conn.openConnection();
            SqlCommand cmd = new SqlCommand("SELECT ISNULL(MAX(BankEntryID),0)+1 FROM BankInformation", con);
            txtdepartmentID.Text = cmd.ExecuteScalar().ToString();
            con.Close();
        }
        private void LoadView_Country_Information()
        {
            using (SqlConnection con = conn.openConnection())
            {
                string query = "SELECT * FROM CountryInformation order By Country_Name asc";
                SqlDataAdapter da = new SqlDataAdapter(query, con);
                DataTable dt = new DataTable();
                da.Fill(dt);

                DropDownList1.DataSource = dt;
                DropDownList1.DataTextField = "Country_Name";
                DropDownList1.DataValueField = "CountryID";
                DropDownList1.DataBind();
                DropDownList1.Items.Insert(0, new ListItem("--Select--", "0"));
            }
        }
        private void LoadGridViewBankInformation()
        {
            using (SqlConnection con = conn.openConnection())
            {
                string query = "SELECT * FROM BankInformation";
                SqlCommand cmd = new SqlCommand(query, con);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                GridViewBankList.DataSource = dt;
                GridViewBankList.DataBind();
            }
        }

        private void LoadGridViewBankBranchInformation()
        {
            using (SqlConnection con = conn.openConnection())
            {
                string query = "SELECT * FROM BankBranchInformation  where BankID='"+ txtdepartmentID.Text + "'";
                SqlCommand cmd = new SqlCommand(query, con);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                GridViewBranchInfo.DataSource = dt;
                GridViewBranchInfo.DataBind();
            }
        }

        protected void GridViewBankList_SelectedIndexChanged(object sender, EventArgs e)
        {
            txtdepartmentID.Text = GridViewBankList.SelectedRow.Cells[1].Text;
            try
            {
                string sql = "Select * from BankInformation where BankEntryID ='" + txtdepartmentID.Text + "'";
                con = conn.openConnection();
                cmd = new SqlCommand(sql, con);
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        TextBox1.Text = reader[1].ToString();
                        TextBox2.Text = reader[4].ToString();
                        TextBox3.Text = reader[2].ToString();
                        TextBox5.Text = reader[3].ToString();
                        CountryID = reader[7].ToString();
                        TextBox7.Text = reader[8].ToString();
                        TextBox8.Text = reader[10].ToString();
                        TextBox9.Text = reader[9].ToString();
                        TextBox10.Text = reader[11].ToString();
                        CheckBox1.Checked = reader[12] != DBNull.Value && Convert.ToBoolean(reader[12]); // ✅ CheckBox
                        CheckBox2.Checked = reader[5] != DBNull.Value && Convert.ToBoolean(reader[5]); // ✅ CheckBox
                        CheckBox3.Checked = reader[6] != DBNull.Value && Convert.ToBoolean(reader[6]); // ✅ CheckBox

                    }
                }
                else
                {
                    TextBox3.Text =  TextBox5.Text = TextBox7.Text =  TextBox9.Text = TextBox8.Text = TextBox10.Text = TextBox2.Text = string.Empty;
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
                string query = "SELECT * FROM CountryInformation where CountryID='"+ CountryID + "' order By Country_Name asc";
                SqlDataAdapter da = new SqlDataAdapter(query, con);
                DataTable dt = new DataTable();
                da.Fill(dt);

                DropDownList1.DataSource = dt;
                DropDownList1.DataTextField = "Country_Name";
                DropDownList1.DataValueField = "CountryID";
                DropDownList1.DataBind();
            }

            LoadGridViewBankBranchInformation();
        }

        protected void btnsave_Click(object sender, EventArgs e)
        {
            try
            {
                // Use 'using' for the connection to ensure it closes automatically
                using (SqlConnection con = conn.openConnection())
                {
                    // Check if the connection is already open; if not, open it
                    if (con.State == ConnectionState.Closed)
                    {
                        con.Open();
                    }

                    using (SqlCommand cmd = new SqlCommand("BankInformation_Insert", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;

                        // Adding Parameters
                        cmd.Parameters.AddWithValue("@BankEntryID", txtdepartmentID.Text.Trim());
                        cmd.Parameters.AddWithValue("@Bank_Code", TextBox1.Text.Trim());
                        cmd.Parameters.AddWithValue("@BankNameEn", TextBox3.Text.Trim());
                        cmd.Parameters.AddWithValue("@BankNameBn", TextBox5.Text.Trim());
                        cmd.Parameters.AddWithValue("@BankPrefix", TextBox2.Text.Trim());
                        cmd.Parameters.AddWithValue("@IsLocal", CheckBox2.Checked);
                        cmd.Parameters.AddWithValue("@IsTreasury", CheckBox3.Checked);
                        cmd.Parameters.AddWithValue("@Country", DropDownList1.SelectedValue);
                        cmd.Parameters.AddWithValue("@SwiftCode", TextBox7.Text.Trim());
                        cmd.Parameters.AddWithValue("@IbnNo", TextBox9.Text.Trim());
                        cmd.Parameters.AddWithValue("@CallCenterNo", TextBox8.Text.Trim());
                        cmd.Parameters.AddWithValue("@WebURL", TextBox10.Text.Trim());
                        cmd.Parameters.AddWithValue("@IsActive", CheckBox1.Checked);

                        cmd.ExecuteNonQuery();
                    }
                } // Connection is automatically closed here
                LoadGridViewBankInformation();

                string message = "Your information has been saved successfully.";
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + message + "');", true);
            }
            catch (Exception ex)
            {
                string error = ex.Message.Replace("'", "");
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error: " + error + "');", true);
            }
        }

        protected void btnupdate_Click(object sender, EventArgs e)
        {
            try
            {
                // Use 'using' for the connection to ensure it closes automatically
                using (SqlConnection con = conn.openConnection())
                {
                    // Check if the connection is already open; if not, open it
                    if (con.State == ConnectionState.Closed)
                    {
                        con.Open();
                    }

                    using (SqlCommand cmd = new SqlCommand("BankInformation_Update", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;

                        // Adding Parameters
                        cmd.Parameters.AddWithValue("@BankEntryID", txtdepartmentID.Text.Trim());
                        cmd.Parameters.AddWithValue("@Bank_Code", TextBox1.Text.Trim());
                        cmd.Parameters.AddWithValue("@BankNameEn", TextBox3.Text.Trim());
                        cmd.Parameters.AddWithValue("@BankNameBn", TextBox5.Text.Trim());
                        cmd.Parameters.AddWithValue("@BankPrefix", TextBox2.Text.Trim());
                        cmd.Parameters.AddWithValue("@IsLocal", CheckBox2.Checked);
                        cmd.Parameters.AddWithValue("@IsTreasury", CheckBox3.Checked);
                        cmd.Parameters.AddWithValue("@Country", DropDownList1.SelectedValue);
                        cmd.Parameters.AddWithValue("@SwiftCode", TextBox7.Text.Trim());
                        cmd.Parameters.AddWithValue("@IbnNo", TextBox9.Text.Trim());
                        cmd.Parameters.AddWithValue("@CallCenterNo", TextBox8.Text.Trim());
                        cmd.Parameters.AddWithValue("@WebURL", TextBox10.Text.Trim());
                        cmd.Parameters.AddWithValue("@IsActive", CheckBox1.Checked);

                        cmd.ExecuteNonQuery();
                    }
                } // Connection is automatically closed here
                LoadGridViewBankInformation();

                string message = "Your information has been saved successfully.";
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + message + "');", true);
            }
            catch (Exception ex)
            {
                string error = ex.Message.Replace("'", "");
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error: " + error + "');", true);
            }
        }

        protected void Button3_Click(object sender, EventArgs e)
        {
            try
            {
                // Use 'using' for the connection to ensure it closes automatically
                using (SqlConnection con = conn.openConnection())
                {
                    // Check if the connection is already open; if not, open it
                    if (con.State == ConnectionState.Closed)
                    {
                        con.Open();
                    }

                    using (SqlCommand cmd = new SqlCommand("BankInformation_Delete", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@BankEntryID", txtdepartmentID.Text.Trim());
                        cmd.ExecuteNonQuery();
                    }
                } // Connection is automatically closed here
                LoadGridViewBankInformation();

                string message = "Your information has been saved successfully.";
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + message + "');", true);
            }
            catch (Exception ex)
            {
                string error = ex.Message.Replace("'", "");
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error: " + error + "');", true);
            }
        }

        protected void Button2_Click(object sender, EventArgs e)
        {
            TextBox3.Text = TextBox5.Text = TextBox7.Text = TextBox9.Text = TextBox8.Text = TextBox10.Text = TextBox2.Text = string.Empty;
            CheckBox1.Checked = CheckBox2.Checked= CheckBox3.Checked= false;
            LoadID();
            LoadView_Country_Information();
            LoadGridViewBankInformation();
        }

        protected void LinkButton1_Click(object sender, EventArgs e)
        {

            LoadView_Country_Information();
        }

        protected void LinkButton3_Click(object sender, EventArgs e)
        {
            PanelBankEntry.Visible= false;
            PanelBranchInfo.Visible= true;
        }

        protected void btnShowBank_Click(object sender, EventArgs e)
        {
            PanelBankEntry.Visible = true;
            PanelBranchInfo.Visible = false;
        }
    }
}