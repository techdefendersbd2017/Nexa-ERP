using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.HRMPayroll.HRConfiguration.AttendanceSetting
{
    public partial class CreateShift : System.Web.UI.Page
    {
        SqlConnection con;
        PayrollDB conn = new PayrollDB();
        SqlCommand cmd;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string user = Request.QueryString["user"];
                LoadShift();
            }
        }
        private void LoadShift()
        {
            try
            {
                con = conn.openConnection();
                {
                    SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM TB_Shift Order by Shift_Name asc", con);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    gvShift.DataSource = dt;
                    gvShift.DataBind();
                }
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert",
                    "alert('" + ex.Message.Replace("'", "\\'") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open)
                {
                    con.Close();
                }
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            con = conn.openConnection();
            {
                // ২. আমাদের তৈরি করা Upsert (Insert/Update) প্রসিডিউরটি কল করা
                using (SqlCommand cmd = new SqlCommand("sp_TB_Shift_Upsert", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    // ৩. আইডি চেক করা: ফাকা বা ০ থাকলে Insert, আইডি থাকলে সেটি পাস হবে (Update)
                    long shiftCode = 0;
                    if (!string.IsNullOrEmpty(txtShiftId.Text.Trim()))
                    {
                        long.TryParse(txtShiftId.Text.Trim(), out shiftCode);
                    }

                    // ৪. প্রসিডিউরের প্যারামিটারগুলোতে ডেটা পাস করা
                    cmd.Parameters.AddWithValue("@Shift_Code", shiftCode);
                    cmd.Parameters.AddWithValue("@Shift_Name", string.IsNullOrEmpty(txtShiftName.Text.Trim()) ? (object)DBNull.Value : txtShiftName.Text.Trim());
                    // Datetime ফিল্ডগুলোর ভ্যালিডেশন এবং নাল হ্যান্ডেলিং (যদি ফাকা থাকে তবে DBNull যাবে)
                    DateTime tempDateTime;
                    cmd.Parameters.AddWithValue("@In_Time", DateTime.TryParse(txtInTime.Text.Trim(), out tempDateTime) ? (object)tempDateTime : DBNull.Value);
                    cmd.Parameters.AddWithValue("@Out_Time", DateTime.TryParse(txtOutTime.Text.Trim(), out tempDateTime) ? (object)tempDateTime : DBNull.Value);
                    cmd.Parameters.AddWithValue("@Shift_Start", DateTime.TryParse(txtShiftStart.Text.Trim(), out tempDateTime) ? (object)tempDateTime : DBNull.Value);
                    cmd.Parameters.AddWithValue("@Shift_End", DateTime.TryParse(txtShiftEnd.Text.Trim(), out tempDateTime) ? (object)tempDateTime : DBNull.Value);
                    cmd.Parameters.AddWithValue("@Lanch_Start", DateTime.TryParse(txtLunchStart.Text.Trim(), out tempDateTime) ? (object)tempDateTime : DBNull.Value); // টেবিল স্ক্রিপ্টের বানান অনুযায়ী Lanch
                    cmd.Parameters.AddWithValue("@Lanch_End", DateTime.TryParse(txtLunchEnd.Text.Trim(), out tempDateTime) ? (object)tempDateTime : DBNull.Value);     // টেবিল স্ক্রিপ্টের বানান অনুযায়ী Lanch
                    cmd.Parameters.AddWithValue("@Late_Start", DateTime.TryParse(txtLateStart.Text.Trim(), out tempDateTime) ? (object)tempDateTime : DBNull.Value);
                    cmd.Parameters.AddWithValue("@Early_Exist", DateTime.TryParse(txtEarlyExit.Text.Trim(), out tempDateTime) ? (object)tempDateTime : DBNull.Value); // টেবিল স্ক্রিপ্টের বানান অনুযায়ী Early_Exist
                    cmd.Parameters.AddWithValue("@Night_policy", Convert.ToInt32(ddlNightPolicy.SelectedValue));
                    cmd.Parameters.AddWithValue("@IsActive", chkIsActive.Checked);

                    try
                    {
                        // যদি আগে থেকে ওপেন না থাকে, তবে কানেকশন ওপেন করা
                        if (con.State == ConnectionState.Closed)
                        {
                            con = conn.openConnection();
                        }

                        // ৫. প্রসিডিউর রান করে রেজাল্ট (INSERTED বা UPDATED) রিড করা
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                string actionResult = rdr["Action"].ToString();
                                string newId = rdr["Shift_Code"].ToString(); // প্রসিডিউরের সিলেক্ট কলাম অনুযায়ী Shift_Code

                                if (actionResult == "INSERTED")
                                {
                                    // নতুন ইনসার্ট হলে মেসেজ দেখাবে
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Shift Saved Successfully! New ID: " + newId + "');", true);
                                }
                                else if (actionResult == "UPDATED")
                                {
                                    // আপডেট হলে মেসেজ দেখাবে
                                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Shift Updated Successfully!');", true);
                                }
                            }
                        }


                        // এখানে আপনার GridView রিফ্রেশ করার মেথড কল করতে পারেন। যেমন: LoadShiftGrid();
                    }
                    catch (Exception ex)
                    {
                        // কোনো এরর হলে তা হ্যান্ডেল করা
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error: " + ex.Message.Replace("'", "\\'") + "');", true);
                    }
                }
            }
            LoadShift();
        }

        protected void gvShift_SelectedIndexChanged(object sender, EventArgs e)
        {
            txtShiftId.Text = gvShift.SelectedRow.Cells[1].Text;
            try
            {
                string sql = "SELECT * FROM TB_Shift WHERE Shift_Code = @ShiftCode";
                con = conn.openConnection();
                cmd = new SqlCommand(sql, con);
                cmd.Parameters.AddWithValue("@ShiftCode", txtShiftId.Text.Trim());

                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        ddlNightPolicy.SelectedValue = reader[10].ToString();
                        txtShiftName.Text = reader[1].ToString();
                        txtShiftStart.Text = reader[2] != DBNull.Value ? DateTime.Parse(reader[2].ToString()).ToString("HH:mm") : "";
                        txtShiftEnd.Text = reader[3] != DBNull.Value ? DateTime.Parse(reader[3].ToString()).ToString("HH:mm") : "";
                        txtInTime.Text = reader[4] != DBNull.Value ? DateTime.Parse(reader[4].ToString()).ToString("HH:mm") : "";
                        txtOutTime.Text = reader[5] != DBNull.Value ? DateTime.Parse(reader[5].ToString()).ToString("HH:mm") : "";
                        txtLunchStart.Text = reader[6] != DBNull.Value ? DateTime.Parse(reader[6].ToString()).ToString("HH:mm") : "";
                        txtLunchEnd.Text = reader[7] != DBNull.Value ? DateTime.Parse(reader[7].ToString()).ToString("HH:mm") : "";
                        txtLateStart.Text = reader[8] != DBNull.Value ? DateTime.Parse(reader[8].ToString()).ToString("HH:mm") : "";
                        txtEarlyExit.Text = reader[9] != DBNull.Value ? DateTime.Parse(reader[9].ToString()).ToString("HH:mm") : "";
                        chkIsActive.Checked = reader[11] != DBNull.Value && Convert.ToBoolean(reader[11]);
                    }
                }
                else
                {
                    txtShiftName.Text = txtShiftStart.Text = txtShiftEnd.Text = txtInTime.Text =
                    txtLunchStart.Text = txtLunchEnd.Text = txtLateStart.Text = txtEarlyExit.Text = "";
                    chkIsActive.Checked = false;

                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('কোনো ডাটা পাওয়া যায়নি!');", true);
                }
                reader.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open)
                {
                    con.Close();
                }
            }
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            // সব টেক্সটবক্স খালি করার জন্য
            txtShiftId.Text = "";
            txtShiftName.Text = "";
            txtShiftStart.Text = "";
            txtShiftEnd.Text = "";
            txtInTime.Text = "";
            txtOutTime.Text = "";
            txtLunchStart.Text = "";
            txtLunchEnd.Text = "";
            txtLateStart.Text = "";
            txtEarlyExit.Text = "";

            // চেকবস এবং ড্রপডাউন রিসেট
            chkIsActive.Checked = false;
            if (ddlNightPolicy.Items.Count > 0)
            {
                ddlNightPolicy.SelectedIndex = 0; // প্রথম আইটেম সিলেক্ট হবে
            }

            // ফোকাস আবার প্রথম ইনপুটে নিয়ে যাওয়ার জন্য (ঐচ্ছিক)
            txtShiftId.Focus();
        }
    }
}