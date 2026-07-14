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
    public partial class chequeBookRegistration : System.Web.UI.Page
    {

        SqlConnection con;
        DatabaseConectionAccounts conn = new DatabaseConectionAccounts();
        SqlCommand cmd;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadID(); 
                LoadGridViewChequeBookRegister();
                LoadView_Branch_Information();
                //LoadView_CostingDepartment();
            }
        }
        private void LoadID()
        {
            con = conn.openConnection();
            SqlCommand cmd = new SqlCommand("SELECT ISNULL(MAX(ChequeBookRegisterID),0)+1 FROM ChequeBookRegister", con);
            txtdepartmentID.Text = cmd.ExecuteScalar().ToString();
            con.Close();
        }
        private void LoadView_Branch_Information()
        {
            using (SqlConnection con = conn.openConnection())
            {
                string query = "SELECT * FROM View_Branch_Information where IsAccounting=1 order By Branch_ID asc";
                SqlDataAdapter da = new SqlDataAdapter(query, con);
                DataTable dt = new DataTable();
                da.Fill(dt);

                DropDownList1.DataSource = dt;
                DropDownList1.DataTextField = "Branch_Name";
                DropDownList1.DataValueField = "Branch_ID";
                DropDownList1.DataBind();
                DropDownList1.Items.Insert(0, new ListItem("--Select--", "0"));
            }
        }
        private void LoadGridViewChequeBookRegister()
        {
            using (SqlConnection con = conn.openConnection())
            {
                string query = "SELECT * FROM ChequeBookRegister";
                SqlCommand cmd = new SqlCommand(query, con);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                GridViewChequeBookRegister.DataSource = dt;
                GridViewChequeBookRegister.DataBind();
            }
        }

        protected void DropDownList1_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadView_Branch_Information();
        }

        protected void GridViewChequeBookRegister_SelectedIndexChanged(object sender, EventArgs e)
        {
            txtdepartmentID.Text = GridViewChequeBookRegister.SelectedRow.Cells[1].Text;
            try
            {
                string sql = "Select * from ChequeBookRegister where ChequeBookRegisterID ='" + txtdepartmentID.Text + "'";
                con = conn.openConnection();
                cmd = new SqlCommand(sql, con);
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        TextBox3.Text = reader[2].ToString();
                        TextBox6.Text = reader[3].ToString();
                        TextBox5.Text = reader[4].ToString();
                        TextBox7.Text = reader[5].ToString();
                        TextBox11.Text = reader[6].ToString();
                        TextBox12.Text = reader[7].ToString();
                        // TextBox9 (Requisition Date)
                        if (reader[8] != DBNull.Value)
                        {
                            DateTime reqDate = Convert.ToDateTime(reader[8]);
                            TextBox9.Text = reqDate.ToString("yyyy-MM-dd");
                        }

                        // TextBox8 (Est. Receive Date)
                        if (reader[9] != DBNull.Value)
                        {
                            DateTime estDate = Convert.ToDateTime(reader[9]);
                            TextBox8.Text = estDate.ToString("yyyy-MM-dd");
                        }

                        // TextBox10 (Receive Date)
                        if (reader[10] != DBNull.Value)
                        {
                            DateTime recDate = Convert.ToDateTime(reader[10]);
                            TextBox10.Text = recDate.ToString("yyyy-MM-dd");
                        }
                        TextBox2.Text = reader[11].ToString();
                        TextBox4.Text = reader[12].ToString();
                        CheckBox1.Checked = reader[13] != DBNull.Value && Convert.ToBoolean(reader[13]); // ✅ CheckBox

                    }
                }
                else
                {
                    TextBox3.Text = TextBox6.Text = TextBox5.Text = TextBox7.Text = TextBox11.Text = TextBox12.Text = TextBox9.Text = TextBox8.Text = TextBox10.Text = TextBox2.Text = TextBox4.Text = string.Empty;
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
                string query = "Select * from View_ChequeBookRegister_Branch where ChequeBookRegisterID ='" + txtdepartmentID.Text +"'";
                SqlDataAdapter da = new SqlDataAdapter(query, con);
                DataTable dt = new DataTable();
                da.Fill(dt);

                DropDownList1.DataSource = dt;
                DropDownList1.DataTextField = "Branch_Name";
                DropDownList1.DataValueField = "Branch_ID";
                DropDownList1.DataBind();
            }
        }

        protected void btnsave_Click(object sender, EventArgs e)
        {
            try
            {
                // কানেকশন ওপেন (আপনার কানেকশন মেথড অনুযায়ী)
                con = conn.openConnection();

                SqlCommand cmd = new SqlCommand("ChequeBookRegister_Insert", con);
                cmd.CommandType = CommandType.StoredProcedure;

                // ভ্যালু অ্যাসাইন করা হচ্ছে
                cmd.Parameters.AddWithValue("@ChequeBookRegisterID", txtdepartmentID.Text.Trim());
                cmd.Parameters.AddWithValue("@CompanyID", DropDownList1.SelectedValue);
                cmd.Parameters.AddWithValue("@AccountNumber", TextBox3.Text.Trim());
                cmd.Parameters.AddWithValue("@ChequeBookNo", TextBox6.Text.Trim());
                cmd.Parameters.AddWithValue("@ReqiredLeaf", TextBox5.Text.Trim());
                cmd.Parameters.AddWithValue("@ChecquePrefix", TextBox7.Text.Trim());
                cmd.Parameters.AddWithValue("@ChequeNoFrom", TextBox11.Text.Trim()); // আপনার কোডে এটি ছিল
                cmd.Parameters.AddWithValue("@ChequeNoTill", TextBox12.Text.Trim()); // আপনার কোডে এটি ছিল

                // ডেট ভ্যালু হ্যান্ডলিং
                cmd.Parameters.AddWithValue("@RequsitionDate", TextBox9.Text);
                cmd.Parameters.AddWithValue("@EstReceivedDate", TextBox8.Text);
                cmd.Parameters.AddWithValue("@ReceivedDate", TextBox10.Text);

                cmd.Parameters.AddWithValue("@NoOfLeaf", TextBox2.Text.Trim());
                cmd.Parameters.AddWithValue("@Remarks", TextBox4.Text.Trim());

                // Boolean ভ্যালু হিসেবে পাঠানোই ভালো
                cmd.Parameters.AddWithValue("@IsActive", CheckBox1.Checked);

                cmd.ExecuteNonQuery();
                con.Close();
                LoadGridViewChequeBookRegister();

                // সাকসেস মেসেজ (JavaScript Alert)
                string message = "Your information has been saved successfully.";
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + message + "');", true);
            }
            catch (Exception ex)
            {
                // এরর মেসেজ
                string error = ex.Message.Replace("'", ""); // কোটেশন মার্ক হ্যান্ডলিং
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error: " + error + "');", true);
            }
        }

        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            try
            {
                // কানেকশন ওপেন (আপনার কানেকশন মেথড অনুযায়ী)
                con = conn.openConnection();

                SqlCommand cmd = new SqlCommand("ChequeBookRegister_Update", con);
                cmd.CommandType = CommandType.StoredProcedure;

                // ভ্যালু অ্যাসাইন করা হচ্ছে
                cmd.Parameters.AddWithValue("@ChequeBookRegisterID", txtdepartmentID.Text.Trim());
                cmd.Parameters.AddWithValue("@CompanyID", DropDownList1.SelectedValue);
                cmd.Parameters.AddWithValue("@AccountNumber", TextBox3.Text.Trim());
                cmd.Parameters.AddWithValue("@ChequeBookNo", TextBox6.Text.Trim());
                cmd.Parameters.AddWithValue("@ReqiredLeaf", TextBox5.Text.Trim());
                cmd.Parameters.AddWithValue("@ChecquePrefix", TextBox7.Text.Trim());
                cmd.Parameters.AddWithValue("@ChequeNoFrom", TextBox11.Text.Trim()); // আপনার কোডে এটি ছিল
                cmd.Parameters.AddWithValue("@ChequeNoTill", TextBox12.Text.Trim()); // আপনার কোডে এটি ছিল

                // ডেট ভ্যালু হ্যান্ডলিং
                cmd.Parameters.AddWithValue("@RequsitionDate", TextBox9.Text);
                cmd.Parameters.AddWithValue("@EstReceivedDate", TextBox8.Text);
                cmd.Parameters.AddWithValue("@ReceivedDate", TextBox10.Text);

                cmd.Parameters.AddWithValue("@NoOfLeaf", TextBox2.Text.Trim());
                cmd.Parameters.AddWithValue("@Remarks", TextBox4.Text.Trim());

                // Boolean ভ্যালু হিসেবে পাঠানোই ভালো
                cmd.Parameters.AddWithValue("@IsActive", CheckBox1.Checked);

                cmd.ExecuteNonQuery();
                con.Close();
                LoadGridViewChequeBookRegister();

                // সাকসেস মেসেজ (JavaScript Alert)
                string message = "Your information has been saved successfully.";
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + message + "');", true);
            }
            catch (Exception ex)
            {
                // এরর মেসেজ
                string error = ex.Message.Replace("'", ""); // কোটেশন মার্ক হ্যান্ডলিং
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error: " + error + "');", true);
            }
        }

        protected void Button3_Click(object sender, EventArgs e)
        {
            try
            {
                // কানেকশন ওপেন (আপনার কানেকশন মেথড অনুযায়ী)
                con = conn.openConnection();

                SqlCommand cmd = new SqlCommand("ChequeBookRegister_Delete", con);
                cmd.CommandType = CommandType.StoredProcedure;

                // ভ্যালু অ্যাসাইন করা হচ্ছে
                cmd.Parameters.AddWithValue("@ChequeBookRegisterID", txtdepartmentID.Text.Trim());

                cmd.ExecuteNonQuery();
                con.Close();
                LoadGridViewChequeBookRegister();

                // সাকসেস মেসেজ (JavaScript Alert)
                string message = "Your information has been saved successfully.";
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + message + "');", true);
            }
            catch (Exception ex)
            {
                // এরর মেসেজ
                string error = ex.Message.Replace("'", ""); // কোটেশন মার্ক হ্যান্ডলিং
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error: " + error + "');", true);
            }
        }

        protected void Button2_Click(object sender, EventArgs e)
        {
            TextBox3.Text = TextBox6.Text = TextBox5.Text = TextBox7.Text = TextBox11.Text = TextBox12.Text = TextBox9.Text = TextBox8.Text = TextBox10.Text = TextBox2.Text = TextBox4.Text = string.Empty;
            CheckBox1.Checked = false;
            LoadID();
        }
    }
}