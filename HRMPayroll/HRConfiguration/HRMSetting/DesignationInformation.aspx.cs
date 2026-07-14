using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Reflection.Emit;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using static System.Collections.Specialized.BitVector32;

namespace Nexa_ERP.HRMPayroll.HRConfiguration.HRMSetting
{
    public partial class DesignationInformation : System.Web.UI.Page
    {
        SqlConnection con;
        PayrollDB conn = new PayrollDB();
        SqlCommand cmd;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string user = Request.QueryString["user"];
                LoadSectionInformation();
                LoadDDLTafsil();
                LoadddlDesignationLeval();
            }
        }
        private void LoadddlDesignationLeval()
        {
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    string query = "SELECT * FROM Designation_Catagory order By Designation_Catagory_ID asc";
                    SqlDataAdapter da = new SqlDataAdapter(query, con);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlDesignationLeval.DataSource = dt;
                    ddlDesignationLeval.DataTextField = "Designation_Catagory_Name";
                    ddlDesignationLeval.DataValueField = "Designation_Catagory_ID";
                    ddlDesignationLeval.DataBind();
                    ddlDesignationLeval.Items.Insert(0, new ListItem("--Select--", "0"));
                }
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


        private void LoadDDLTafsil()
        {
            try
            {
                con = conn.openConnection();

                string query = "SELECT * FROM TB_Designation_Tofsil ORDER BY Tofsil_Code ASC";
                SqlDataAdapter da = new SqlDataAdapter(query, con);
                DataTable dt = new DataTable();
                da.Fill(dt);

                ddlTafsil.DataSource = dt;
                ddlTafsil.DataTextField = "Tofsil_Name";
                ddlTafsil.DataValueField = "Tofsil_Code";
                ddlTafsil.DataBind();
                ddlTafsil.Items.Insert(0, new ListItem("--Select--", "0"));
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert",
                    "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open)
                {
                    con.Close();
                }
            }
        }

        private void LoadSectionInformation()
        {
            try
            {
                con = conn.openConnection();

                SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM TB_Designation ORDER BY Desigation_name ASC", con);
                DataTable dt = new DataTable();
                da.Fill(dt);

                gvDesignation.DataSource = dt;
                gvDesignation.DataBind();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert",
                    "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open)
                {
                    con.Close();
                }
            }
        }

        public void DataloadFromGridtotxtBox()
        {
            txtDesignationId.Text = gvDesignation.SelectedRow.Cells[1].Text;
            try
            {
                string sql = "Select * from TB_Designation where Designation_Code ='" + txtDesignationId.Text + "'";
                con = conn.openConnection();
                cmd = new SqlCommand(sql, con);
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        txtDesignationName.Text = reader[1].ToString();
                        txtDesignationNameBangla.Text = reader[2].ToString();
                        txtGrade.Text = reader[3].ToString();
                        txtAttBonus.Text = reader[4].ToString();
                        txtMinimumWages.Text = reader[5].ToString();
                        txtWorkType.Text = reader[6].ToString();
                        txtWorkTypeBangla.Text = reader[7].ToString();
                        ddlTafsil.SelectedValue = reader[8].ToString();
                        ddlDesignationLeval.SelectedValue = reader[29].ToString();

                        //================Tiffin================
                        txtTiffin1stMin.Text = reader[9].ToString();
                        txtTiffin1stAllowance.Text = reader[10].ToString();
                        txtTiffin2ndMin.Text = reader[11].ToString();
                        txtTiffin2ndAllowance.Text = reader[12].ToString();
                        txtTiffin3rdMin.Text = reader[13].ToString();
                        txtTiffin3rdAllowance.Text = reader[14].ToString();
                        txtTiffin4thMin.Text = reader[15].ToString();
                        txtTifin4thAllowance.Text = reader[16].ToString();

                        //===================Night=======================
                        txtNight1stMin.Text = reader[17].ToString();
                        txtNight1stAllowance.Text = reader[18].ToString();
                        txtNight2ndMin.Text = reader[19].ToString();
                        txtNight2ndAllowance.Text = reader[20].ToString();
                        txt3rdNightMin.Text = reader[21].ToString();
                        TxtNight3rdAllowance.Text = reader[22].ToString();
                        txtNight4thMin.Text = reader[23].ToString();
                        txtNight4thAllowance.Text = reader[24].ToString();

                        //===================Holiday==============
                        txtHoliday1stMin.Text = reader[25].ToString();
                        txtHoliday1stAllowance.Text = reader[26].ToString();
                        txtHoliday2ndMin.Text = reader[27].ToString();
                        txtHoliday2ndAllowance.Text = reader[28].ToString();



                        //chkIsActive.Checked = reader[7] != DBNull.Value && Convert.ToBoolean(reader[7]); // ✅ CheckBox

                    }
                }
                else
                {
                    //================Designation & Basic Info================
                    txtDesignationName.Text = txtDesignationNameBangla.Text = txtGrade.Text = txtAttBonus.Text = txtMinimumWages.Text = txtWorkType.Text = txtWorkTypeBangla.Text = ddlTafsil.SelectedValue = ddlDesignationLeval.SelectedValue = "";

                    //================Tiffin================
                    txtTiffin1stMin.Text = txtTiffin1stAllowance.Text = txtTiffin2ndMin.Text = txtTiffin2ndAllowance.Text = txtTiffin3rdMin.Text = txtTiffin3rdAllowance.Text = txtTiffin4thMin.Text = txtTifin4thAllowance.Text = "";

                    //===================Night=======================
                    txtNight1stMin.Text = txtNight1stAllowance.Text = txtNight2ndMin.Text = txtNight2ndAllowance.Text = txt3rdNightMin.Text = TxtNight3rdAllowance.Text = txtNight4thMin.Text = txtNight4thAllowance.Text = "";

                    //===================Holiday==============
                    txtHoliday1stMin.Text = txtHoliday1stAllowance.Text = txtHoliday2ndAllowance.Text = "";
                    chkIsActive.Checked = false;
                }
                con.Close();
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

        protected void gvSection_SelectedIndexChanged(object sender, EventArgs e)
        {
            DataloadFromGridtotxtBox();
        }

        protected void ddlTafsil_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

        private void btnRefreshs()
        {
            LoadSectionInformation();
            LoadDDLTafsil();
            LoadddlDesignationLeval();
            //================Designation & Basic Info================
            txtDesignationId.Text =txtDesignationName.Text = txtDesignationNameBangla.Text = txtGrade.Text = txtAttBonus.Text = txtMinimumWages.Text = txtWorkType.Text = txtWorkTypeBangla.Text = "";

            //================Tiffin================
            txtTiffin1stMin.Text = txtTiffin1stAllowance.Text = txtTiffin2ndMin.Text = txtTiffin2ndAllowance.Text = txtTiffin3rdMin.Text = txtTiffin3rdAllowance.Text = txtTiffin4thMin.Text = txtTifin4thAllowance.Text = "";

            //===================Night=======================
            txtNight1stMin.Text = txtNight1stAllowance.Text = txtNight2ndMin.Text = txtNight2ndAllowance.Text = txt3rdNightMin.Text = TxtNight3rdAllowance.Text = txtNight4thMin.Text = txtNight4thAllowance.Text = "";

            //===================Holiday==============
            txtHoliday1stMin.Text = txtHoliday1stAllowance.Text = txtHoliday2ndAllowance.Text = "";
            chkIsActive.Checked = false;
        }

        protected void btnSave2_Click(object sender, EventArgs e)
        {
            try
            {
                con = conn.openConnection();

                using (SqlCommand cmd = new SqlCommand("Pro_Designation_Save_Web", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.Add("@Designation_Code", SqlDbType.BigInt).Value = txtDesignationId.Text == "" ? 0 : Convert.ToInt64(txtDesignationId.Text);

                    cmd.Parameters.Add("@Desigation_name", SqlDbType.VarChar).Value = txtDesignationName.Text;
                    cmd.Parameters.Add("@Designation_Bangla", SqlDbType.VarChar).Value = txtDesignationNameBangla.Text;
                    cmd.Parameters.Add("@Grade", SqlDbType.VarChar).Value = txtGrade.Text;
                    cmd.Parameters.Add("@Attendance_Bonus", SqlDbType.BigInt).Value = txtAttBonus.Text == "" ? 0 : Convert.ToInt64(txtAttBonus.Text);
                    cmd.Parameters.Add("@Minimum_Wages", SqlDbType.BigInt).Value = txtMinimumWages.Text == "" ? 0 : Convert.ToInt64(txtMinimumWages.Text);
                    cmd.Parameters.Add("@Designation_Catagory", SqlDbType.VarChar).Value = txtWorkType.Text;
                    cmd.Parameters.Add("@Designation_Catagory_Bangla", SqlDbType.VarChar).Value = txtWorkTypeBangla.Text;
                    cmd.Parameters.Add("@Tafsil_Code", SqlDbType.BigInt).Value = ddlTafsil.SelectedValue;

                    //========== Tiffin ==========
                    cmd.Parameters.Add("@F_Tifin_Min", SqlDbType.BigInt).Value = txtTiffin1stMin.Text == "" ? 0 : Convert.ToInt64(txtTiffin1stMin.Text);
                    cmd.Parameters.Add("@F_Tifin_Amount", SqlDbType.BigInt).Value = txtTiffin1stAllowance.Text == "" ? 0 : Convert.ToInt64(txtTiffin1stAllowance.Text);

                    cmd.Parameters.Add("@S_Tifin_min", SqlDbType.BigInt).Value = txtTiffin2ndMin.Text == "" ? 0 : Convert.ToInt64(txtTiffin2ndMin.Text);
                    cmd.Parameters.Add("@S_Tifin_Amount", SqlDbType.BigInt).Value = txtTiffin2ndAllowance.Text == "" ? 0 : Convert.ToInt64(txtTiffin2ndAllowance.Text);

                    cmd.Parameters.Add("@T_Tifin_Min", SqlDbType.BigInt).Value = txtTiffin3rdMin.Text == "" ? 0 : Convert.ToInt64(txtTiffin3rdMin.Text);
                    cmd.Parameters.Add("@T_Tifin_Amount", SqlDbType.BigInt).Value = txtTiffin3rdAllowance.Text == "" ? 0 : Convert.ToInt64(txtTiffin3rdAllowance.Text);

                    cmd.Parameters.Add("@Fo_Tifin_min", SqlDbType.BigInt).Value = txtTiffin4thMin.Text == "" ? 0 : Convert.ToInt64(txtTiffin4thMin.Text);
                    cmd.Parameters.Add("@Fo_Tifin_Amount", SqlDbType.BigInt).Value = txtTifin4thAllowance.Text == "" ? 0 : Convert.ToInt64(txtTifin4thAllowance.Text);

                    //========== Night ==========
                    cmd.Parameters.Add("@F_Night_min", SqlDbType.BigInt).Value = txtNight1stMin.Text == "" ? 0 : Convert.ToInt64(txtNight1stMin.Text);
                    cmd.Parameters.Add("@F_Night_Allow", SqlDbType.BigInt).Value = txtNight1stAllowance.Text == "" ? 0 : Convert.ToInt64(txtNight1stAllowance.Text);

                    cmd.Parameters.Add("@secend_Night_min", SqlDbType.BigInt).Value = txtNight2ndMin.Text == "" ? 0 : Convert.ToInt64(txtNight2ndMin.Text);
                    cmd.Parameters.Add("@Secend_Night_Allow", SqlDbType.BigInt).Value = txtNight2ndAllowance.Text == "" ? 0 : Convert.ToInt64(txtNight2ndAllowance.Text);

                    cmd.Parameters.Add("@thard_Night_Min", SqlDbType.BigInt).Value = txt3rdNightMin.Text == "" ? 0 : Convert.ToInt64(txt3rdNightMin.Text);
                    cmd.Parameters.Add("@Thard_Night_Allow", SqlDbType.BigInt).Value = TxtNight3rdAllowance.Text == "" ? 0 : Convert.ToInt64(TxtNight3rdAllowance.Text);

                    cmd.Parameters.Add("@Forth_Night_Min", SqlDbType.BigInt).Value = txtNight4thMin.Text == "" ? 0 : Convert.ToInt64(txtNight4thMin.Text);
                    cmd.Parameters.Add("@Forth__NightAmount", SqlDbType.BigInt).Value = txtNight4thAllowance.Text == "" ? 0 : Convert.ToInt64(txtNight4thAllowance.Text);

                    //========== Holiday ==========
                    cmd.Parameters.Add("@Fast_H_min", SqlDbType.BigInt).Value = txtHoliday1stMin.Text == "" ? 0 : Convert.ToInt64(txtHoliday1stMin.Text);
                    cmd.Parameters.Add("@Fast_H_Allow", SqlDbType.BigInt).Value = txtHoliday1stAllowance.Text == "" ? 0 : Convert.ToInt64(txtHoliday1stAllowance.Text);

                    cmd.Parameters.Add("@Secend_H_min", SqlDbType.BigInt).Value = txtHoliday2ndMin.Text == "" ? 0 : Convert.ToInt64(txtHoliday2ndMin.Text);
                    cmd.Parameters.Add("@Secend_H_Allow", SqlDbType.BigInt).Value = txtHoliday2ndAllowance.Text == "" ? 0 : Convert.ToInt64(txtHoliday2ndAllowance.Text);

                    //========== Others ==========
                    cmd.Parameters.Add("@Designation_Category_ID", SqlDbType.BigInt).Value = ddlDesignationLeval.SelectedValue;

                    cmd.ExecuteNonQuery();
                }

                ScriptManager.RegisterStartupScript(this, GetType(), "msg", "alert('Saved Successfully');", true);
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "msg", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open)
                    con.Close();
            }
        }

        protected void btnRefresh2_Click(object sender, EventArgs e)
        {
            btnRefreshs();
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            btnRefreshs();
        }
    }
}