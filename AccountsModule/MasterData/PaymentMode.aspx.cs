using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.AccountsModule.MasterData
{
    public partial class PaymentMode : System.Web.UI.Page
    {
        SqlConnection con;
        DatabaseConectionAccounts conn = new DatabaseConectionAccounts();
        SqlCommand cmd;

        String VoucherTypeID;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // প্রথমবার পেজ লোড হলে এগুলো চলবে
                LoadNextID();
                LoadVoucherDropDown();
                ClearTemporaryData();
                LoadVoucherType();
                LoadGridViewPaymentModeList();
            }
        }

        private void LoadNextID()
        {
            using (SqlConnection con = conn.openConnection())
            {
                SqlCommand cmd = new SqlCommand("SELECT ISNULL(MAX(PaymentModeID),0)+1 FROM Payment_Mode", con);
                txtdepartmentID.Text = cmd.ExecuteScalar().ToString();
            }
        }

        private void LoadVoucherDropDown()
        {
            using (SqlConnection con = conn.openConnection())
            {
                string query = "SELECT VoucherID, VoucherName FROM Payment_Voucher_Type ORDER BY VoucherID ASC";
                SqlDataAdapter da = new SqlDataAdapter(query, con);
                DataTable dt = new DataTable();
                da.Fill(dt);

                DropDownList1.DataSource = dt;
                DropDownList1.DataTextField = "VoucherName";
                DropDownList1.DataValueField = "VoucherID";
                DropDownList1.DataBind();
                DropDownList1.Items.Insert(0, new ListItem("--Select--", "0"));
            }
        }

        private void ClearTemporaryData()
        {
            con=conn.openConnection();
            {
                SqlCommand cmd = new SqlCommand("DELETE FROM Payment_Mode_Wise_Voucher_ID WHERE isDraft=0", con);
                cmd.ExecuteNonQuery();
            }
            con.Close();

            con = conn.openConnection();
            {
                SqlCommand cmd2 = new SqlCommand("UPDATE Payment_Mode_Wise_Voucher_ID SET isDraft=1 WHERE isDraft=2", con);
                cmd2.ExecuteNonQuery();
            }
            con.Close();
        }

        protected void Button1_Click(object sender, EventArgs e)
        {
            
            try
            {
                con = conn.openConnection();
                using (SqlCommand cmd = new SqlCommand("sp_InsertPaymentModeWiseVoucher", con)) // correct SP name
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@PID", SqlDbType.BigInt).Value = Convert.ToInt64(txtdepartmentID.Text);
                    cmd.Parameters.Add("@VID", SqlDbType.BigInt).Value = Convert.ToInt64(DropDownList1.SelectedValue);
                    cmd.ExecuteNonQuery();
                }
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message + "');", true);
            }
            LoadVoucherType();
        }

        private void LoadVoucherType()
        {
            using (SqlConnection con = conn.openConnection())
            {
                string query = "SELECT * FROM View_Payment_Mode_Wise_Voucher_ID where PaymentModeID='" + txtdepartmentID.Text+"' ";
                SqlCommand cmd = new SqlCommand(query, con);
                //cmd.Parameters.AddWithValue("@PID", txtdepartmentID.Text);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                GridViewVoucherList.DataSource = dt;
                GridViewVoucherList.DataBind();
            }
        }
        private void LoadGridViewPaymentModeList()
        {
            using (SqlConnection con = conn.openConnection())
            {
                string query = "SELECT * FROM Payment_Mode";
                SqlCommand cmd = new SqlCommand(query, con);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                GridViewPaymentModeList.DataSource = dt;
                GridViewPaymentModeList.DataBind();
            }
        }

        protected void GridViewPaymentModeList_SelectedIndexChanged(object sender, EventArgs e)
        {
            txtdepartmentID.Text = GridViewPaymentModeList.SelectedRow.Cells[1].Text;
            try
            {
                string sql = "Select * from Payment_Mode where PaymentModeID ='" + txtdepartmentID.Text + "'";
                con = conn.openConnection();
                cmd = new SqlCommand(sql, con);
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        TextBox1.Text = reader[1].ToString();
                        TextBox2.Text = reader[2].ToString();
                        TextBox4.Text = reader[2].ToString();
                        CheckBox1.Checked = reader[4] != DBNull.Value && Convert.ToBoolean(reader[4]); // ✅ CheckBox

                    }
                }
                else
                {
                    TextBox1.Text = TextBox2.Text = TextBox4.Text =  string.Empty;
                    CheckBox1.Checked = false;
                }
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
            LoadVoucherType();
        }

        protected void Button2_Click(object sender, EventArgs e)
        {
            con = conn.openConnection();
            {
                SqlCommand cmd = new SqlCommand("SELECT ISNULL(MAX(PaymentModeID),0)+1 FROM Payment_Mode", con);
                txtdepartmentID.Text = cmd.ExecuteScalar().ToString();
            }
            con.Close();
            TextBox1.Text = TextBox2.Text = TextBox4.Text = string.Empty;
            CheckBox1.Checked = false;
            LoadVoucherType();
        }

        protected void btnRemove_Click(object sender, EventArgs e)
        {
            con = conn.openConnection();
            {
                SqlCommand cmd = new SqlCommand("UPDATE Payment_Mode_Wise_Voucher_ID SET isDraft = 2 WHERE PaymentModeID = '"+ txtdepartmentID.Text + "' and VoucherTypeID='"+ txtdepartmentID0.Text + "'", con);
                cmd.ExecuteNonQuery();
            }
            con.Close();
            LoadVoucherTypeRemove();
        }

        private void LoadVoucherTypeRemove()
        {
            using (SqlConnection con = conn.openConnection())
            {
                string query = "SELECT * FROM View_Payment_Mode_Wise_Voucher_ID where PaymentModeID='" + txtdepartmentID.Text + "' and isDraft in(0,1)  ";
                SqlCommand cmd = new SqlCommand(query, con);
                //cmd.Parameters.AddWithValue("@PID", txtdepartmentID.Text);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                GridViewVoucherList.DataSource = dt;
                GridViewVoucherList.DataBind();
            }
        }

        protected void GridViewVoucherList_SelectedIndexChanged(object sender, EventArgs e)
        {
            txtdepartmentID0.Text = GridViewVoucherList.SelectedRow.Cells[1].Text;            
        }

        protected void btnsave_Click(object sender, EventArgs e)
        {
            try
            {
                con = conn.openConnection();
                using (SqlCommand cmd = new SqlCommand("Payment_Mode_Insert", con)) // correct SP name
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@PaymentModeID", SqlDbType.BigInt).Value = Convert.ToInt64(txtdepartmentID.Text);
                    cmd.Parameters.Add("@Name", SqlDbType.NVarChar).Value = Convert.ToInt64(TextBox1.Text);
                    cmd.Parameters.Add("@Short_Name", SqlDbType.NVarChar).Value = Convert.ToInt64(TextBox2.Text);
                    cmd.Parameters.Add("@Remarks", SqlDbType.NVarChar).Value = Convert.ToInt64(TextBox4.Text);
                    cmd.Parameters.Add("@Is_Active", SqlDbType.Bit).Value = Convert.ToInt64(CheckBox1.Checked);
                    cmd.ExecuteNonQuery();
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Save Successfully!');", true);
                }
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message + "');", true);
            }
            LoadGridViewPaymentModeList();
        }

        protected void btnupdate_Click(object sender, EventArgs e)
        {
            try
            {
                con = conn.openConnection();
                using (SqlCommand cmd = new SqlCommand("Payment_Mode_Update", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    // 1. PaymentModeID is BigInt (Correct)
                    cmd.Parameters.Add("@PaymentModeID", SqlDbType.BigInt).Value = Convert.ToInt64(txtdepartmentID.Text);

                    // 2. Name is VarChar/NVarChar - DO NOT convert to Int64
                    cmd.Parameters.Add("@Name", SqlDbType.VarChar).Value = TextBox1.Text;

                    // 3. Short_Name is VarChar - DO NOT convert to Int64
                    cmd.Parameters.Add("@Short_Name", SqlDbType.VarChar).Value = TextBox2.Text;

                    // 4. Remarks is VarChar - DO NOT convert to Int64
                    cmd.Parameters.Add("@Remarks", SqlDbType.VarChar).Value = TextBox4.Text;

                    // 5. Is_Active is Bit - Use the boolean property directly
                    cmd.Parameters.Add("@Is_Active", SqlDbType.Bit).Value = CheckBox1.Checked;

                    cmd.ExecuteNonQuery();
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Save Successfully!');", true);
                }
                con.Close();
            }
            catch (Exception ex)
            {
                // It's safer to use a generic message or log the error to avoid XSS issues with ex.Message
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error: " + ex.Message.Replace("'", "") + "');", true);
            }
            LoadGridViewPaymentModeList();
        }

        protected void Button3_Click(object sender, EventArgs e)
        {
            try
            {
                con = conn.openConnection();
                using (SqlCommand cmd = new SqlCommand("Payment_Mode_Delete", con)) // correct SP name
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.Add("@PaymentModeID", SqlDbType.BigInt).Value = Convert.ToInt64(txtdepartmentID.Text);
                    cmd.ExecuteNonQuery();
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Save Successfully!');", true);
                }
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message + "');", true);
            }
            LoadGridViewPaymentModeList();
        }
    }
}