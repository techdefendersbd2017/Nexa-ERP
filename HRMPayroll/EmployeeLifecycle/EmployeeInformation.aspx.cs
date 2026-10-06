using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.HRMPayroll.EmployeeLifecycle
{
    public partial class EmployeeInformation : System.Web.UI.Page
    {
        SqlConnection con;
        PayrollDB conn = new PayrollDB();
        SqlCommand cmd;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string user = Request.QueryString["user"];
                //------Office Informatin-------
                LoadBranch();LoadDepartment(); LoadSection();LoadLine();LoadDesignation();LoadCategory();LoadShift();LoadFloor();LoadWeekoff();LoadPayType();
                //------Personal Informatin-------
                LoadReligion(); LoadGender();LoadEducation();LoadMaritalStatus();
                //------Address Informatin-------
                LoadPermanentDistrict();LoadPermanentPoliceStation();LoadPresentDistrict();LoadPresentPoliceStation();
                //======Nominee Information=======
                LoadNomineeRelation(); LoadNomineetDistrict(); LoadNomineePoliceStation();
                //======Salary Information==============
                LoadBankName();
            }

        }
        private void LoadBranch()
        {
            Database_Connection conn = new Database_Connection();
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    string query = "SELECT * FROM Branch_Information order By Branch_Name asc";
                    SqlDataAdapter da = new SqlDataAdapter(query, con);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlBranch.DataSource = dt;
                    ddlBranch.DataTextField = "Branch_Name";
                    ddlBranch.DataValueField = "Branch_ID";
                    ddlBranch.DataBind();
                    ddlBranch.Items.Insert(0, new ListItem("--Select--", "0"));
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
        private void LoadDepartment()
        {
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    string query = "SELECT * FROM TB_Department order By Branch_Name asc";
                    SqlDataAdapter da = new SqlDataAdapter(query, con);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlDepartment.DataSource = dt;
                    ddlDepartment.DataTextField = "Department_Name";
                    ddlDepartment.DataValueField = "Department_Code";
                    ddlDepartment.DataBind();
                    ddlDepartment.Items.Insert(0, new ListItem("--Select--", "0"));
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
        private void LoadSection()
        {
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    string query = "SELECT * FROM TB_Section order By Section_Name asc";
                    SqlDataAdapter da = new SqlDataAdapter(query, con);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlSection.DataSource = dt;
                    ddlSection.DataTextField = "Section_Name";
                    ddlSection.DataValueField = "Section_Code";
                    ddlSection.DataBind();
                    ddlSection.Items.Insert(0, new ListItem("--Select--", "0"));
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
        private void LoadLine()
        {
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    string query = "SELECT * FROM TB_Line order By Line_Name asc";
                    SqlDataAdapter da = new SqlDataAdapter(query, con);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlLine.DataSource = dt;
                    ddlLine.DataTextField = "Line_Name";
                    ddlLine.DataValueField = "Line_Code";
                    ddlLine.DataBind();
                    ddlLine.Items.Insert(0, new ListItem("--Select--", "0"));
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
        private void LoadDesignation()
        {
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    string query = "SELECT * FROM TB_Designation order By Desigation_name asc";
                    SqlDataAdapter da = new SqlDataAdapter(query, con);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlDesignation.DataSource = dt;
                    ddlDesignation.DataTextField = "Desigation_name";
                    ddlDesignation.DataValueField = "Designation_Code";
                    ddlDesignation.DataBind();
                    ddlDesignation.Items.Insert(0, new ListItem("--Select--", "0"));
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
        private void LoadCategory()
        {
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    string query = "SELECT * FROM TB_Catagory order By Catagory_Name asc";
                    SqlDataAdapter da = new SqlDataAdapter(query, con);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlCategory.DataSource = dt;
                    ddlCategory.DataTextField = "Catagory_Name";
                    ddlCategory.DataValueField = "Catagory_Code";
                    ddlCategory.DataBind();
                    ddlCategory.Items.Insert(0, new ListItem("--Select--", "0"));
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
        private void LoadShift()
        {
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    string query = "SELECT * FROM TB_Shift order By Shift_Name asc";
                    SqlDataAdapter da = new SqlDataAdapter(query, con);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlShift.DataSource = dt;
                    ddlShift.DataTextField = "Shift_Name";
                    ddlShift.DataValueField = "Shift_Code";
                    ddlShift.DataBind();
                    ddlShift.Items.Insert(0, new ListItem("--Select--", "0"));
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
        private void LoadFloor()
        {
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    string query = "SELECT * FROM TB_Floor order By Floor_Name asc";
                    SqlDataAdapter da = new SqlDataAdapter(query, con);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlFloor.DataSource = dt;
                    ddlFloor.DataTextField = "Floor_Name";
                    ddlFloor.DataValueField = "Foor_code";
                    ddlFloor.DataBind();
                    ddlFloor.Items.Insert(0, new ListItem("--Select--", "0"));
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
        private void LoadWeekoff()
        {
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    string query = "SELECT * FROM TB_Weekly_Off order By Weekly_Name asc";
                    SqlDataAdapter da = new SqlDataAdapter(query, con);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlWeekoff.DataSource = dt;
                    ddlWeekoff.DataTextField = "Weekly_Name";
                    ddlWeekoff.DataValueField = "Weekly_Off_Code";
                    ddlWeekoff.DataBind();
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
        private void LoadPayType()
        {
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    string query = "SELECT * FROM Payment_Type order By Pay_Type_ID asc";
                    SqlDataAdapter da = new SqlDataAdapter(query, con);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlPayType.DataSource = dt;
                    ddlPayType.DataTextField = "Pay_Type_Name";
                    ddlPayType.DataValueField = "Pay_Type_ID";
                    ddlPayType.DataBind();
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
        private void LoadBankName()
        {
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    string query = "SELECT * FROM Bank_Information order By Bank_Name asc";
                    SqlDataAdapter da = new SqlDataAdapter(query, con);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlBank.DataSource = dt;
                    ddlBank.DataTextField = "Bank_Name";
                    ddlBank.DataValueField = "Bank_Code";
                    ddlBank.DataBind();
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
        private void LoadReligion()
        {
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    string query = "SELECT * FROM Religion order By Religion_ID asc";
                    SqlDataAdapter da = new SqlDataAdapter(query, con);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlReligion.DataSource = dt;
                    ddlReligion.DataTextField = "Religion_Name";
                    ddlReligion.DataValueField = "Religion_ID";
                    ddlReligion.DataBind();
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
        private void LoadGender()
        {
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    string query = "SELECT * FROM Gender order By Gender_Name asc";
                    SqlDataAdapter da = new SqlDataAdapter(query, con);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlGender.DataSource = dt;
                    ddlGender.DataTextField = "Gender_Name";
                    ddlGender.DataValueField = "Gender_Code";
                    ddlGender.DataBind();
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
        private void LoadEducation()
        {
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    string query = "SELECT * FROM tb_Education order By Education_Code asc";
                    SqlDataAdapter da = new SqlDataAdapter(query, con);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlEducation.DataSource = dt;
                    ddlEducation.DataTextField = "Education_Name";
                    ddlEducation.DataValueField = "Education_Code";
                    ddlEducation.DataBind();
                    ddlEducation.Items.Insert(0, new ListItem("--Select--", "0"));
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
        private void LoadMaritalStatus()
        {
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    string query = "SELECT * FROM Marital_Status order By Marital_Status_Code asc";
                    SqlDataAdapter da = new SqlDataAdapter(query, con);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlMaritalStatus.DataSource = dt;
                    ddlMaritalStatus.DataTextField = "Marital_Status_name";
                    ddlMaritalStatus.DataValueField = "Marital_Status_Code";
                    ddlMaritalStatus.DataBind();
                    ddlMaritalStatus.Items.Insert(0, new ListItem("--Select--", "0"));
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
        private void LoadPermanentDistrict()
        {
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    string query = "SELECT * FROM District_Name_List order By District_Name asc";
                    SqlDataAdapter da = new SqlDataAdapter(query, con);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    ddlPermanentDistrict.DataSource = dt;
                    ddlPermanentDistrict.DataTextField = "District_Name";
                    ddlPermanentDistrict.DataValueField = "District_Code";
                    ddlPermanentDistrict.DataBind();
                    ddlPermanentDistrict.Items.Insert(0, new ListItem("--Select--", "0"));
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
        private void LoadPermanentPoliceStation()
        {
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    string query = "SELECT * FROM Upazila_Name_List order By Upazila_Name asc";
                    SqlDataAdapter da = new SqlDataAdapter(query, con);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    ddlPermanentPoliceStation.DataSource = dt;
                    ddlPermanentPoliceStation.DataTextField = "Upazila_Name";
                    ddlPermanentPoliceStation.DataValueField = "Upazila_Code";
                    ddlPermanentPoliceStation.DataBind();
                    ddlPermanentPoliceStation.Items.Insert(0, new ListItem("--Select--", "0"));
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
        private void LoadPresentDistrict()
        {
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    string query = "SELECT * FROM District_Name_List order By District_Name asc";
                    SqlDataAdapter da = new SqlDataAdapter(query, con);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    ddlPresentDistrict.DataSource = dt;
                    ddlPresentDistrict.DataTextField = "District_Name";
                    ddlPresentDistrict.DataValueField = "District_Code";
                    ddlPresentDistrict.DataBind();
                    ddlPresentDistrict.Items.Insert(0, new ListItem("--Select--", "0"));
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
        private void LoadPresentPoliceStation()
        {
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    string query = "SELECT * FROM Upazila_Name_List order By Upazila_Name asc";
                    SqlDataAdapter da = new SqlDataAdapter(query, con);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    ddlPresentPoliceStation.DataSource = dt;
                    ddlPresentPoliceStation.DataTextField = "Upazila_Name";
                    ddlPresentPoliceStation.DataValueField = "Upazila_Code";
                    ddlPresentPoliceStation.DataBind();
                    ddlPresentPoliceStation.Items.Insert(0, new ListItem("--Select--", "0"));
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
        private void LoadNomineeRelation()
        {
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    string query = "SELECT * FROM Relation order By Relation_Name asc";
                    SqlDataAdapter da = new SqlDataAdapter(query, con);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    ddlNomineeRelation.DataSource = dt;
                    ddlNomineeRelation.DataTextField = "Relation_Name";
                    ddlNomineeRelation.DataValueField = "Relation_ID";
                    ddlNomineeRelation.DataBind();
                    ddlNomineeRelation.Items.Insert(0, new ListItem("--Select--", "0"));
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
        private void LoadNomineetDistrict()
        {
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    string query = "SELECT * FROM District_Name_List order By District_Name asc";
                    SqlDataAdapter da = new SqlDataAdapter(query, con);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    ddlNomineeDistrict.DataSource = dt;
                    ddlNomineeDistrict.DataTextField = "District_Name";
                    ddlNomineeDistrict.DataValueField = "District_Code";
                    ddlNomineeDistrict.DataBind();
                    ddlNomineeDistrict.Items.Insert(0, new ListItem("--Select--", "0"));
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
        private void LoadNomineePoliceStation()
        {
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    string query = "SELECT * FROM Upazila_Name_List order By Upazila_Name asc";
                    SqlDataAdapter da = new SqlDataAdapter(query, con);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    ddlNomineePoliceStation.DataSource = dt;
                    ddlNomineePoliceStation.DataTextField = "Upazila_Name";
                    ddlNomineePoliceStation.DataValueField = "Upazila_Code";
                    ddlNomineePoliceStation.DataBind();
                    ddlNomineePoliceStation.Items.Insert(0, new ListItem("--Select--", "0"));
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
        protected void chkSame_CheckedChanged(object sender, EventArgs e)
        {
            presentpermanentaddresssame();
        }

        public void presentpermanentaddresssame()
        {
            bool isSame = chkSame.Checked;

            ddlPresentDistrict.Enabled = !isSame;
            ddlPresentPoliceStation.Enabled = !isSame;
            txtPresentPostOfficeEnglish.Enabled = !isSame;
            txtPresentPostOfficeBangla.Enabled = !isSame;
            txtPresentVillageEnglish.Enabled = !isSame;
            txtPresentVillageBangla.Enabled = !isSame;

            if (isSame)
            {
                ddlPresentDistrict.SelectedValue = ddlPermanentDistrict.SelectedValue;
                ddlPresentPoliceStation.SelectedValue = ddlPermanentPoliceStation.SelectedValue;

                txtPresentPostOfficeEnglish.Text = txtPermanentPostOfficeEnglish.Text;
                txtPresentPostOfficeBangla.Text = txtPermanentPostOfficeBangla.Text;

                txtPresentVillageEnglish.Text = txtPermanentVillageEnglish.Text;
                txtPresentVillageBangla.Text = txtPermanentVillageBangla.Text;
            }
        }
        protected void CheckNominee_CheckedChanged(object sender, EventArgs e)
        {
            
        }
        public void EmployeeNomineeaddresssame()
        {
            bool isSame = CheckNominee.Checked;

            ddlNomineeDistrict.Enabled = !isSame;
            ddlNomineePoliceStation.Enabled = !isSame;
            txtNomineePostOfficeEnglish.Enabled = !isSame;
            txtNomineePostOfficeBangla.Enabled = !isSame;
            txtNomineeVillageEnglish.Enabled = !isSame;
            txtNomineeVillageBangla.Enabled = !isSame;

            if (isSame)
            {
                ddlNomineeDistrict.SelectedValue = ddlPermanentDistrict.SelectedValue;
                ddlNomineePoliceStation.SelectedValue = ddlPermanentPoliceStation.SelectedValue;

                txtNomineePostOfficeEnglish.Text = txtPermanentPostOfficeEnglish.Text;
                txtNomineePostOfficeBangla.Text = txtPermanentPostOfficeBangla.Text;

                txtNomineeVillageEnglish.Text = txtPermanentVillageEnglish.Text;
                txtNomineeVillageBangla.Text = txtPermanentVillageBangla.Text;
            }
        }
        protected void btnSave_Click(object sender, EventArgs e)
        {
            const int MAX_PHOTO_SIZE_BYTES = 300 * 1024;
            if (FileUpload1.HasFile && FileUpload1.PostedFile.ContentLength > MAX_PHOTO_SIZE_BYTES)
            {
                ClientScript.RegisterStartupScript(this.GetType(), "PhotoTooLarge", "alert('The photo size must not exceed 300 KB. Please upload a smaller image.');", true);
                return;
            }

            using (SqlConnection con = conn.openConnection())
            {
                using (SqlCommand cmd = new SqlCommand("Pro_Employee_Entry_Web", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    // ---------- Office Information ----------
                    cmd.Parameters.AddWithValue("@Employee_ID", txtEmpID.Text.Trim());
                    cmd.Parameters.AddWithValue("@Name", txtName.Text.Trim());
                    cmd.Parameters.AddWithValue("@Bangal_Name", string.IsNullOrEmpty(txtBanglaName.Text) ? (object)DBNull.Value : txtBanglaName.Text.Trim());
                    cmd.Parameters.AddWithValue("@Joining_Date", string.IsNullOrEmpty(txtJoiningDate.Text) ? (object)DBNull.Value : Convert.ToDateTime(txtJoiningDate.Text));
                    cmd.Parameters.AddWithValue("@Probationary_Date", txtProbationPeriod.Text);
                    cmd.Parameters.AddWithValue("@EmployeeStatus", ddlEmployeeStatus.SelectedValue);
                    cmd.Parameters.AddWithValue("@SeparationDate", txtSeparationDate.Text);

                    if (FileUpload1.HasFile)
                    {
                        using (MemoryStream ms = new MemoryStream())
                        {
                            FileUpload1.PostedFile.InputStream.CopyTo(ms);
                            byte[] imageBytes = ms.ToArray();
                            cmd.Parameters.Add("@Photo", SqlDbType.VarBinary, -1).Value = imageBytes;
                        }
                    }
                    else
                    {
                        cmd.Parameters.Add("@Photo", SqlDbType.VarBinary, -1).Value = DBNull.Value;
                    }

                    cmd.Parameters.AddWithValue("@BranchID", ddlBranch.SelectedValue);
                    cmd.Parameters.AddWithValue("@DepartmentID", ddlDepartment.SelectedValue);
                    cmd.Parameters.AddWithValue("@SectionID", ddlSection.SelectedValue);
                    cmd.Parameters.AddWithValue("@LineID", ddlLine.SelectedValue);
                    cmd.Parameters.AddWithValue("@DesignationID", ddlDesignation.SelectedValue);
                    cmd.Parameters.AddWithValue("@CategoryID", ddlCategory.SelectedValue);
                    cmd.Parameters.AddWithValue("@ShiftID", ddlShift.SelectedValue);
                    cmd.Parameters.AddWithValue("@FloorID", ddlFloor.SelectedValue);
                    cmd.Parameters.AddWithValue("@WeeklyHolidayID", ddlWeekoff.SelectedValue);

                    // ---------- Salary Information ----------
                    cmd.Parameters.AddWithValue("@GrossSalary", txtGrossSalary.Text);
                    // JoiningGross / NonComplianceGross এর টেক্সটবক্স পেজে থাকলে নিচের দুই লাইনের // তুলুন
                    cmd.Parameters.AddWithValue("@JoiningGross", txtJoiningGross.Text);
                    cmd.Parameters.AddWithValue("@NonComplianceGross", txtNonComplianceGross.Text);
                    cmd.Parameters.AddWithValue("@PayTypeID", ddlPayType.SelectedValue);
                    cmd.Parameters.AddWithValue("@TaxableGrossSalary", txtTaxableGrossSalary.Text);
                    cmd.Parameters.AddWithValue("@NonTaxableGrossSalary", txtNonTaxableGrossSalary.Text);
                    cmd.Parameters.AddWithValue("@TaxHolderID", ddlTaxHolder.SelectedValue);
                    cmd.Parameters.AddWithValue("@TaxAmount", txtTaxAmount.Text);
                    cmd.Parameters.AddWithValue("@BankHolderID", ddlBankHolder.SelectedValue);
                    cmd.Parameters.AddWithValue("@BankID", ddlBank.SelectedValue);
                    cmd.Parameters.AddWithValue("@AccountNumber", txtAccountNumber.Text);
                    cmd.Parameters.AddWithValue("@RoutingNo", txtRoutingNo.Text);

                    // ---------- Personal Information ----------
                    cmd.Parameters.AddWithValue("@FatherEnglish", txtFatherEnglish.Text);
                    cmd.Parameters.AddWithValue("@FatherBangla", txtFatherBangla.Text);
                    cmd.Parameters.AddWithValue("@MotherEnglish", txtMotherEnglish.Text);
                    cmd.Parameters.AddWithValue("@MotherBangla", txtMotherBangla.Text);
                    cmd.Parameters.AddWithValue("@SpouseEnglish", txtSpouseEnglish.Text);
                    cmd.Parameters.AddWithValue("@SpouseBangla", txtSpouseBangla.Text);
                    cmd.Parameters.AddWithValue("@NID", txtNID.Text);
                    cmd.Parameters.AddWithValue("@BID", txtBID.Text);
                    cmd.Parameters.AddWithValue("@DateOfBirth", txtDateOfBirth.Text);
                    cmd.Parameters.AddWithValue("@MaritalStatus", ddlMaritalStatus.SelectedValue);
                    cmd.Parameters.AddWithValue("@Religion", ddlReligion.SelectedValue);
                    cmd.Parameters.AddWithValue("@NoofChild", txtNoofChild.Text);
                    cmd.Parameters.AddWithValue("@Gender", ddlGender.SelectedValue);
                    cmd.Parameters.AddWithValue("@HeightFeet", txtHeightFeet.Text);
                    cmd.Parameters.AddWithValue("@HeightInch", txtHeightInch.Text);
                    cmd.Parameters.AddWithValue("@WeightKG", txtWeightKG.Text);
                    cmd.Parameters.AddWithValue("@BloodGroup", ddlBloodGroup.SelectedValue);
                    cmd.Parameters.AddWithValue("@TIN", txtTIN.Text);
                    cmd.Parameters.AddWithValue("@PersonalPhone", txtPersonalPhone.Text);
                    cmd.Parameters.AddWithValue("@HomePhone", txtHomePhone.Text);
                    cmd.Parameters.AddWithValue("@Education", ddlEducation.SelectedValue);
                    cmd.Parameters.AddWithValue("@Email", txtEmail.Text);

                    // ---------- Permanent Address ----------
                    cmd.Parameters.AddWithValue("@PermanentDistrictID", ddlPermanentDistrict.SelectedValue);
                    cmd.Parameters.AddWithValue("@PermanentPoliceStationID", ddlPermanentPoliceStation.SelectedValue);
                    cmd.Parameters.AddWithValue("@PermanentPostOfficeEnglish", txtPermanentPostOfficeEnglish.Text);
                    cmd.Parameters.AddWithValue("@PermanentPostOfficeBangla", txtPermanentPostOfficeBangla.Text);
                    cmd.Parameters.AddWithValue("@PermanentVillageEnglish", txtPermanentVillageEnglish.Text);
                    cmd.Parameters.AddWithValue("@PermanentVillageBangla", txtPermanentVillageBangla.Text);

                    // ---------- Present Address ----------
                    cmd.Parameters.AddWithValue("@presentpermanentaddresssame", chkSame.Checked);
                    cmd.Parameters.AddWithValue("@PresentDistrictID", ddlPresentDistrict.SelectedValue);
                    cmd.Parameters.AddWithValue("@PresentPoliceStationID", ddlPresentPoliceStation.SelectedValue);
                    cmd.Parameters.AddWithValue("@PresentPostOfficeEnglish", txtPresentPostOfficeEnglish.Text);
                    cmd.Parameters.AddWithValue("@PresentPostOfficeBangla", txtPresentPostOfficeBangla.Text);
                    cmd.Parameters.AddWithValue("@PresentVillageEnglish", txtPresentVillageEnglish.Text);
                    cmd.Parameters.AddWithValue("@PresentVillageBangla", txtPresentVillageBangla.Text);

                    // ---------- House Holder ----------
                    cmd.Parameters.AddWithValue("@HouseHolderNameEnglish", txtHouseHolderNameEnglish.Text);
                    cmd.Parameters.AddWithValue("@HouseHolderNameBangla", txtHouseHolderNameBangla.Text);
                    cmd.Parameters.AddWithValue("@HouseHolderPhoneNo", txtHouseHolderPhoneNo.Text);

                    // ---------- Nominee Information ----------
                    cmd.Parameters.AddWithValue("@RelationWithNominee", string.IsNullOrEmpty(ddlNomineeRelation.SelectedValue) ? (object)DBNull.Value : ddlNomineeRelation.SelectedValue);
                    cmd.Parameters.AddWithValue("@NomineesName", txtNomineesName.Text.Trim());
                    cmd.Parameters.AddWithValue("@NomineeNameBangla", txtNomineeNameBangla.Text.Trim());
                    cmd.Parameters.AddWithValue("@NomineesNID", txtNomineesNID.Text.Trim());
                    cmd.Parameters.AddWithValue("@NomineesBID", txtNomineesBID.Text.Trim());
                    cmd.Parameters.AddWithValue("@NomineesDateOfBirth", string.IsNullOrEmpty(txtNomineesDateOfBirth.Text) ? (object)DBNull.Value : txtNomineesDateOfBirth.Text);
                    cmd.Parameters.AddWithValue("@NomineesPhoneNo", txtNomineesPhoneNo.Text.Trim());
                    cmd.Parameters.AddWithValue("@EmployeeNomineeAddressSame", CheckNominee.Checked);
                    cmd.Parameters.AddWithValue("@NomineesDistrictID", string.IsNullOrEmpty(ddlNomineeDistrict.SelectedValue) ? (object)DBNull.Value : ddlNomineeDistrict.SelectedValue);
                    cmd.Parameters.AddWithValue("@NomineesPoliceStationID", string.IsNullOrEmpty(ddlNomineePoliceStation.SelectedValue) ? (object)DBNull.Value : ddlNomineePoliceStation.SelectedValue);
                    cmd.Parameters.AddWithValue("@NomineesPostOfficeEnglish", txtNomineePostOfficeEnglish.Text.Trim());
                    cmd.Parameters.AddWithValue("@NomineesPostOfficeBangla", txtNomineePostOfficeBangla.Text.Trim());
                    cmd.Parameters.AddWithValue("@NomineesVillageEnglish", txtNomineeVillageEnglish.Text.Trim());
                    cmd.Parameters.AddWithValue("@NomineesVillageBangla", txtNomineeVillageBangla.Text.Trim());

                    // ---------- Experience ----------
                    cmd.Parameters.AddWithValue("@FactoryName", txtFactoryName.Text.Trim());
                    cmd.Parameters.AddWithValue("@FactoryNameBangla", txtFactoryNameBangla.Text.Trim());
                    cmd.Parameters.AddWithValue("@FactoryAddress", txtFactoryAddress.Text.Trim());
                    cmd.Parameters.AddWithValue("@FactoryAddressBangla", txtFactoryAddressBangla.Text.Trim());
                    cmd.Parameters.AddWithValue("@TotalExperienceYear", txtTotalExpYear.Text.Trim());

                    try
                    {
                        if (con.State != ConnectionState.Open)
                        {
                            con.Open();
                        }
                        cmd.ExecuteNonQuery();
                        ClientScript.RegisterStartupScript(this.GetType(), "SaveSuccess",
                            "alert('The employee information was saved successfully.');", true);
                    }
                    catch (Exception ex)
                    {
                        ClientScript.RegisterStartupScript(this.GetType(), "SaveError",
                            "alert('Unable to save the information. Please try again or contact the system administrator.');", true);
                    }
                }
            }
        }
        protected void btnSearch_Click(object sender, EventArgs e)
        {
            string employeeIdNo = txtEmpID.Text.Trim();

            if (string.IsNullOrEmpty(employeeIdNo))
            {
                ClientScript.RegisterStartupScript(this.GetType(), "SearchEmpty", "alert('Employee ID is required. Please enter a valid Employee ID to continue.');", true);
                return;
            }

            using (SqlConnection con = conn.openConnection())
            {
                using (SqlCommand cmd = new SqlCommand("sp_GetEmployeeFullInformationByID", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@EmployeeIDNo", employeeIdNo);

                    try
                    {
                        if (con.State != ConnectionState.Open)
                        {
                            con.Open();
                        }

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                // ---------- Office Information ----------
                                txtName.Text = reader["Name"] == DBNull.Value ? "" : reader["Name"].ToString();
                                txtBanglaName.Text = reader["Bangla_name"] == DBNull.Value ? "" : reader["Bangla_name"].ToString();
                                txtJoiningDate.Text = reader["Joining_Date"] == DBNull.Value ? "" : Convert.ToDateTime(reader["Joining_Date"]).ToString("yyyy-MM-dd");
                                txtProbationPeriod.Text = reader["Probationary_Date"] == DBNull.Value ? "" : Convert.ToDateTime(reader["Probationary_Date"]).ToString("yyyy-MM-dd");
                                txtSeparationDate.Text = reader["Resign_Date"] == DBNull.Value ? "" : Convert.ToDateTime(reader["Resign_Date"]).ToString("yyyy-MM-dd");

                                string status = reader["Resign_Status"] == DBNull.Value ? "" : reader["Resign_Status"].ToString();
                                if (ddlEmployeeStatus.Items.FindByValue(status) != null)
                                {
                                    ddlEmployeeStatus.SelectedValue = status;
                                }

                                if (reader["Photo"] != DBNull.Value)
                                {
                                    byte[] photoBytes = (byte[])reader["Photo"];
                                    string base64Photo = Convert.ToBase64String(photoBytes);
                                    imgPhotoPreview.Src = "data:image/jpeg;base64," + base64Photo;
                                    imgPhotoPreview.Style["display"] = "block";
                                    photoPlaceholderText.Style["display"] = "none";
                                }
                                else
                                {
                                    imgPhotoPreview.Src = "#";
                                    imgPhotoPreview.Style["display"] = "none";
                                    photoPlaceholderText.Style["display"] = "block";
                                }

                                string BranchID = reader["Branch_Code"] == DBNull.Value ? "" : reader["Branch_Code"].ToString();
                                if (ddlBranch.Items.FindByValue(BranchID) != null)
                                {
                                    ddlBranch.SelectedValue = BranchID;
                                }
                                string DepartmentID = reader["Department_Code"] == DBNull.Value ? "" : reader["Department_Code"].ToString();
                                if (ddlDepartment.Items.FindByValue(DepartmentID) != null)
                                {
                                    ddlDepartment.SelectedValue = DepartmentID;
                                }
                                string SectionID = reader["Section_Code"] == DBNull.Value ? "" : reader["Section_Code"].ToString();
                                if (ddlSection.Items.FindByValue(SectionID) != null)
                                {
                                    ddlSection.SelectedValue = SectionID;
                                }
                                string LineID = reader["Line_Code"] == DBNull.Value ? "" : reader["Line_Code"].ToString();
                                if (ddlLine.Items.FindByValue(LineID) != null)
                                {
                                    ddlLine.SelectedValue = LineID;
                                }
                                string DesignationID = reader["Designation_Code"] == DBNull.Value ? "" : reader["Designation_Code"].ToString();
                                if (ddlDesignation.Items.FindByValue(DesignationID) != null)
                                {
                                    ddlDesignation.SelectedValue = DesignationID;
                                }
                                string CategoryID = reader["Catagory_Code"] == DBNull.Value ? "" : reader["Catagory_Code"].ToString();
                                if (ddlCategory.Items.FindByValue(CategoryID) != null)
                                {
                                    ddlCategory.SelectedValue = CategoryID;
                                }
                                string ShiftID = reader["Shift_Code"] == DBNull.Value ? "" : reader["Shift_Code"].ToString();
                                if (ddlShift.Items.FindByValue(ShiftID) != null)
                                {
                                    ddlShift.SelectedValue = ShiftID;
                                }
                                string FloorID = reader["Floor_Code"] == DBNull.Value ? "" : reader["Floor_Code"].ToString();
                                if (ddlFloor.Items.FindByValue(FloorID) != null)
                                {
                                    ddlFloor.SelectedValue = FloorID;
                                }
                                string WeeklyHolidayID = reader["week_off_Code"] == DBNull.Value ? "" : reader["week_off_Code"].ToString();
                                if (ddlWeekoff.Items.FindByValue(WeeklyHolidayID) != null)
                                {
                                    ddlWeekoff.SelectedValue = WeeklyHolidayID;
                                }

                                // ---------- Salary Information ----------
                                txtGrossSalary.Text = reader["Gross_Salary"] == DBNull.Value ? "" : reader["Gross_Salary"].ToString();
                                txtJoiningGross.Text = reader["JoiningGross"] == DBNull.Value ? "" : reader["JoiningGross"].ToString();
                                txtNonComplianceGross.Text = reader["NonComplianceGross"] == DBNull.Value ? "" : reader["NonComplianceGross"].ToString();

                                string PayTypeID = reader["Pay_Type"] == DBNull.Value ? "" : reader["Pay_Type"].ToString();
                                if (ddlPayType.Items.FindByValue(PayTypeID) != null)
                                {
                                    ddlPayType.SelectedValue = PayTypeID;
                                }

                                txtTaxableGrossSalary.Text = reader["Bank_Salary"] == DBNull.Value ? "" : reader["Bank_Salary"].ToString();
                                txtNonTaxableGrossSalary.Text = reader["Cash_Salary"] == DBNull.Value ? "" : reader["Cash_Salary"].ToString();

                                string TaxHolderID = reader["Tex_Holder"] == DBNull.Value ? "" : reader["Tex_Holder"].ToString();
                                if (ddlTaxHolder.Items.FindByValue(TaxHolderID) != null)
                                {
                                    ddlTaxHolder.SelectedValue = TaxHolderID;
                                }
                                txtTaxAmount.Text = reader["Tex_Amount"] == DBNull.Value ? "" : reader["Tex_Amount"].ToString();

                                string BankHolderID = reader["Bank_Holder"] == DBNull.Value ? "" : reader["Bank_Holder"].ToString();
                                if (ddlBankHolder.Items.FindByValue(BankHolderID) != null)
                                {
                                    ddlBankHolder.SelectedValue = BankHolderID;
                                }
                                string BankID = reader["Bank_Code"] == DBNull.Value ? "" : reader["Bank_Code"].ToString();
                                if (ddlBank.Items.FindByValue(BankID) != null)
                                {
                                    ddlBank.SelectedValue = BankID;
                                }
                                txtAccountNumber.Text = reader["A_C_No"] == DBNull.Value ? "" : reader["A_C_No"].ToString();
                                txtRoutingNo.Text = reader["RoutingNo"] == DBNull.Value ? "" : reader["RoutingNo"].ToString();

                                // ---------- Personal Information ----------
                                txtFatherEnglish.Text = reader["Fathers"] == DBNull.Value ? "" : reader["Fathers"].ToString();
                                txtFatherBangla.Text = reader["Fathers_Bangla"] == DBNull.Value ? "" : reader["Fathers_Bangla"].ToString();
                                txtMotherEnglish.Text = reader["Mothers"] == DBNull.Value ? "" : reader["Mothers"].ToString();
                                txtMotherBangla.Text = reader["Mothers_Bangla"] == DBNull.Value ? "" : reader["Mothers_Bangla"].ToString();
                                txtSpouseEnglish.Text = reader["SpousNameEnglish"] == DBNull.Value ? "" : reader["SpousNameEnglish"].ToString();
                                txtSpouseBangla.Text = reader["SpousNameBangla"] == DBNull.Value ? "" : reader["SpousNameBangla"].ToString();
                                txtNID.Text = reader["NID"] == DBNull.Value ? "" : reader["NID"].ToString();
                                txtBID.Text = reader["BID"] == DBNull.Value ? "" : reader["BID"].ToString();
                                txtDateOfBirth.Text = reader["Date_of_Birth"] == DBNull.Value ? "" : Convert.ToDateTime(reader["Date_of_Birth"]).ToString("yyyy-MM-dd");

                                string gender = reader["Gender"] == DBNull.Value ? "" : reader["Gender"].ToString();
                                if (ddlGender.Items.FindByValue(gender) != null)
                                {
                                    ddlGender.SelectedValue = gender;
                                }
                                string religion = reader["Religion"] == DBNull.Value ? "" : reader["Religion"].ToString();
                                if (ddlReligion.Items.FindByValue(religion) != null)
                                {
                                    ddlReligion.SelectedValue = religion;
                                }
                                string bloodGroup = reader["Blood_Group"] == DBNull.Value ? "" : reader["Blood_Group"].ToString();
                                if (ddlBloodGroup.Items.FindByValue(bloodGroup) != null)
                                {
                                    ddlBloodGroup.SelectedValue = bloodGroup;
                                }
                                txtPersonalPhone.Text = reader["Personal_Phone"] == DBNull.Value ? "" : reader["Personal_Phone"].ToString();

                                string education = reader["Education_Code"] == DBNull.Value ? "" : reader["Education_Code"].ToString();
                                if (ddlEducation.Items.FindByValue(education) != null)
                                {
                                    ddlEducation.SelectedValue = education;
                                }
                                string maritalStatus = reader["Marital_Status_Code"] == DBNull.Value ? "" : reader["Marital_Status_Code"].ToString();
                                if (ddlMaritalStatus.Items.FindByValue(maritalStatus) != null)
                                {
                                    ddlMaritalStatus.SelectedValue = maritalStatus;
                                }

                                txtNoofChild.Text = reader["Number_of_Child"] == DBNull.Value ? "" : reader["Number_of_Child"].ToString();
                                txtHeightFeet.Text = reader["Hight"] == DBNull.Value ? "" : reader["Hight"].ToString();
                                txtHeightInch.Text = reader["Hight_inchi"] == DBNull.Value ? "" : reader["Hight_inchi"].ToString();
                                txtWeightKG.Text = reader["Weight"] == DBNull.Value ? "" : reader["Weight"].ToString();
                                txtTIN.Text = reader["TIN"] == DBNull.Value ? "" : reader["TIN"].ToString();
                                txtHomePhone.Text = reader["Home_Phone"] == DBNull.Value ? "" : reader["Home_Phone"].ToString();
                                txtEmail.Text = reader["Email"] == DBNull.Value ? "" : reader["Email"].ToString();

                                // ---------- Permanent Address ----------
                                string PermanentDistrictID = reader["District_Code"] == DBNull.Value ? "" : reader["District_Code"].ToString();
                                if (ddlPermanentDistrict.Items.FindByValue(PermanentDistrictID) != null)
                                {
                                    ddlPermanentDistrict.SelectedValue = PermanentDistrictID;
                                }
                                string PermanentPoliceStationID = reader["Upzila_Code"] == DBNull.Value ? "" : reader["Upzila_Code"].ToString();
                                if (ddlPermanentPoliceStation.Items.FindByValue(PermanentPoliceStationID) != null)
                                {
                                    ddlPermanentPoliceStation.SelectedValue = PermanentPoliceStationID;
                                }
                                txtPermanentPostOfficeEnglish.Text = reader["Post"] == DBNull.Value ? "" : reader["Post"].ToString();
                                txtPermanentPostOfficeBangla.Text = reader["B_Post"] == DBNull.Value ? "" : reader["B_Post"].ToString();
                                txtPermanentVillageEnglish.Text = reader["Village"] == DBNull.Value ? "" : reader["Village"].ToString();
                                txtPermanentVillageBangla.Text = reader["B_Village"] == DBNull.Value ? "" : reader["B_Village"].ToString();

                                // ---------- Present Address ----------
                                object dbValue = reader["PresentPermanentAddressSame"];
                                if (dbValue == DBNull.Value || dbValue == null)
                                {
                                    chkSame.Checked = false;
                                }
                                else if (dbValue is bool)
                                {
                                    chkSame.Checked = (bool)dbValue;
                                }
                                else
                                {
                                    string valStr = dbValue.ToString().Trim();
                                    chkSame.Checked = valStr == "1" || valStr.Equals("Y", StringComparison.OrdinalIgnoreCase)
                                                       || valStr.Equals("True", StringComparison.OrdinalIgnoreCase)
                                                       || valStr.Equals("Yes", StringComparison.OrdinalIgnoreCase);
                                }
                                string PresentDistrictID = reader["PresentDistrict_Code"] == DBNull.Value ? "" : reader["PresentDistrict_Code"].ToString();
                                if (ddlPresentDistrict.Items.FindByValue(PresentDistrictID) != null)
                                {
                                    ddlPresentDistrict.SelectedValue = PresentDistrictID;
                                }
                                string PresentPoliceStationID = reader["PresentUpzila_Code"] == DBNull.Value ? "" : reader["PresentUpzila_Code"].ToString();
                                if (ddlPresentPoliceStation.Items.FindByValue(PresentPoliceStationID) != null)
                                {
                                    ddlPresentPoliceStation.SelectedValue = PresentPoliceStationID;
                                }
                                txtPresentPostOfficeEnglish.Text = reader["P_Post"] == DBNull.Value ? "" : reader["P_Post"].ToString();
                                txtPresentPostOfficeBangla.Text = reader["B_P_Post"] == DBNull.Value ? "" : reader["B_P_Post"].ToString();
                                txtPresentVillageEnglish.Text = reader["P_Village"] == DBNull.Value ? "" : reader["P_Village"].ToString();
                                txtPresentVillageBangla.Text = reader["B_P_Village"] == DBNull.Value ? "" : reader["B_P_Village"].ToString();

                                // ---------- House Holder ----------
                                txtHouseHolderNameEnglish.Text = reader["House_Holder_name"] == DBNull.Value ? "" : reader["House_Holder_name"].ToString();
                                txtHouseHolderNameBangla.Text = reader["House_Hodler_Bangla"] == DBNull.Value ? "" : reader["House_Hodler_Bangla"].ToString();
                                txtHouseHolderPhoneNo.Text = reader["House_Holder_Phone"] == DBNull.Value ? "" : reader["House_Holder_Phone"].ToString();

                                // ---------- Nominee Details ----------
                                string RelationID = reader["Relation_ID"] == DBNull.Value ? "" : reader["Relation_ID"].ToString();
                                if (ddlNomineeRelation.Items.FindByValue(RelationID) != null)
                                {
                                    ddlNomineeRelation.SelectedValue = RelationID;
                                }
                                txtNomineesName.Text = reader["Nominee_Name"] != DBNull.Value ? reader["Nominee_Name"].ToString() : string.Empty;
                                txtNomineeNameBangla.Text = reader["Nominee_Name_Bangla"] != DBNull.Value ? reader["Nominee_Name_Bangla"].ToString() : string.Empty;
                                txtNomineesNID.Text = reader["NomineesNID"] != DBNull.Value ? reader["NomineesNID"].ToString() : string.Empty;
                                txtNomineesBID.Text = reader["NomineesBID"] != DBNull.Value ? reader["NomineesBID"].ToString() : string.Empty;
                                txtNomineesDateOfBirth.Text = reader["Nominee_Date_of_Birth"] == DBNull.Value ? "" : Convert.ToDateTime(reader["Nominee_Date_of_Birth"]).ToString("yyyy-MM-dd");
                                txtNomineesPhoneNo.Text = reader["Nominee_Phone_no"] != DBNull.Value ? reader["Nominee_Phone_no"].ToString() : string.Empty;

                                CheckNominee.Checked = reader["EmployeeNomineeAddressSame"] != DBNull.Value && Convert.ToBoolean(reader["EmployeeNomineeAddressSame"]);

                                string NomineeDistrictID = reader["NomineesDistrictID"] == DBNull.Value ? "" : reader["NomineesDistrictID"].ToString();
                                if (ddlNomineeDistrict.Items.FindByValue(NomineeDistrictID) != null)
                                {
                                    ddlNomineeDistrict.SelectedValue = NomineeDistrictID;
                                }
                                string NomineePoliceStationID = reader["NomineesPoliceStationID"] == DBNull.Value ? "" : reader["NomineesPoliceStationID"].ToString();
                                if (ddlNomineePoliceStation.Items.FindByValue(NomineePoliceStationID) != null)
                                {
                                    ddlNomineePoliceStation.SelectedValue = NomineePoliceStationID;
                                }
                                txtNomineePostOfficeEnglish.Text = reader["N_Post_En"] != DBNull.Value ? reader["N_Post_En"].ToString() : string.Empty;
                                txtNomineePostOfficeBangla.Text = reader["N_Post_Ba"] != DBNull.Value ? reader["N_Post_Ba"].ToString() : string.Empty;
                                txtNomineeVillageEnglish.Text = reader["N_Village_En"] != DBNull.Value ? reader["N_Village_En"].ToString() : string.Empty;
                                txtNomineeVillageBangla.Text = reader["N_Village_Ba"] != DBNull.Value ? reader["N_Village_Ba"].ToString() : string.Empty;

                                // ---------- Experience Details ----------
                                txtFactoryName.Text = reader["Factory_Name"] != DBNull.Value ? reader["Factory_Name"].ToString() : string.Empty;
                                txtFactoryNameBangla.Text = reader["Factory_Name_Bangla"] != DBNull.Value ? reader["Factory_Name_Bangla"].ToString() : string.Empty;
                                txtFactoryAddress.Text = reader["Factory_Address"] != DBNull.Value ? reader["Factory_Address"].ToString() : string.Empty;
                                txtFactoryAddressBangla.Text = reader["Factory_Address_Bangla"] != DBNull.Value ? reader["Factory_Address_Bangla"].ToString() : string.Empty;
                                txtTotalExpYear.Text = reader["Total_Exprience"] != DBNull.Value ? reader["Total_Exprience"].ToString() : string.Empty;
                            }
                            else
                            {
                                txtName.Text = "";
                                txtBanglaName.Text = "";
                                txtJoiningDate.Text = "";
                                txtProbationPeriod.Text = "";
                                txtSeparationDate.Text = "";
                                ddlEmployeeStatus.ClearSelection();
                                imgPhotoPreview.Src = "#";
                                imgPhotoPreview.Style["display"] = "none";
                                photoPlaceholderText.Style["display"] = "block";
                                ClientScript.RegisterStartupScript(this.GetType(), "SearchNotFound", "alert('No employee record exists for the provided Employee ID.');", true);
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        string safeMsg = ex.Message.Replace("'", "").Replace("\n", " ").Replace("\r", "");
                        ClientScript.RegisterStartupScript(this.GetType(), "SearchError", "alert('DEBUG ERROR: " + safeMsg + "');", true);
                    }
                }
                EmployeeNomineeaddresssame();
                presentpermanentaddresssame();
            }
        }

        protected void txtJoiningDate_TextChanged(object sender, EventArgs e)
        {
            // Joining Date ইনপুট থেকে মান নেওয়া
            if (DateTime.TryParse(txtJoiningDate.Text, out DateTime joiningDate))
            {
                // ৩ মাস যোগ করা
                DateTime probationDate = joiningDate.AddMonths(3);

                // Probation Period টেক্সটবক্সে YYYY-MM-DD ফরম্যাটে বসানো
                txtProbationPeriod.Text = probationDate.ToString("yyyy-MM-dd");
            }
            else
            {
                txtProbationPeriod.Text = string.Empty;
            }
        }
    }
}