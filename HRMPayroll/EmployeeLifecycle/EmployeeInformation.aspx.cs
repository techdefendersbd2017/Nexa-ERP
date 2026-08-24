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
                using (SqlCommand cmd = new SqlCommand("sp_SaveEmployeeFullInformation", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    // Parameters Mapping
                    cmd.Parameters.AddWithValue("@EmployeeIDNo", txtEmpID.Text.Trim());
                    cmd.Parameters.AddWithValue("@Name", txtName.Text.Trim());
                    cmd.Parameters.AddWithValue("@BanglaName", string.IsNullOrEmpty(txtBanglaName.Text) ? (object)DBNull.Value : txtBanglaName.Text.Trim());
                    cmd.Parameters.AddWithValue("@JoiningDate", string.IsNullOrEmpty(txtJoiningDate.Text) ? (object)DBNull.Value : Convert.ToDateTime(txtJoiningDate.Text));
                    cmd.Parameters.AddWithValue("@ProbationPeriod", string.IsNullOrEmpty(txtProbationPeriod.Text) ? (object)DBNull.Value : Convert.ToDateTime(txtProbationPeriod.Text));
                    cmd.Parameters.AddWithValue("@EmployeeStatus", ddlEmployeeStatus.SelectedValue);
                    cmd.Parameters.AddWithValue("@SeparationDate", string.IsNullOrEmpty(txtSeparationDate.Text) ? (object)DBNull.Value : Convert.ToDateTime(txtSeparationDate.Text));
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

                    cmd.Parameters.AddWithValue("@GrossSalary", txtGrossSalary.Text);
                    cmd.Parameters.AddWithValue("@BankHolderID", ddlBankHolder.SelectedValue);
                    cmd.Parameters.AddWithValue("@BankID", ddlBank.SelectedValue);
                    cmd.Parameters.AddWithValue("@AccountNumber", txtAccountNumber.Text);
                    cmd.Parameters.AddWithValue("@RoutingNo", txtRoutingNo.Text);
                    cmd.Parameters.AddWithValue("@PayTypeID", ddlPayType.SelectedValue);
                    cmd.Parameters.AddWithValue("@TaxableGrossSalary", txtTaxableGrossSalary.Text);
                    cmd.Parameters.AddWithValue("@NonTaxableGrossSalary", txtNonTaxableGrossSalary.Text);
                    cmd.Parameters.AddWithValue("@TaxHolderID", ddlTaxHolder.SelectedValue);
                    cmd.Parameters.AddWithValue("@TaxAmount", txtTaxAmount.Text);

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

                    cmd.Parameters.AddWithValue("@PermanentDistrictID",ddlPermanentDistrict.SelectedValue );
                    cmd.Parameters.AddWithValue("@PermanentPoliceStationID", ddlPermanentPoliceStation.SelectedValue);
                    cmd.Parameters.AddWithValue("@PermanentPostOfficeEnglish", txtPermanentPostOfficeEnglish.Text);
                    cmd.Parameters.AddWithValue("@PermanentPostOfficeBangla", txtPermanentPostOfficeBangla.Text);
                    cmd.Parameters.AddWithValue("@PermanentVillageEnglish", txtPermanentVillageEnglish.Text);
                    cmd.Parameters.AddWithValue("@PermanentVillageBangla", txtPermanentVillageBangla.Text);
                    cmd.Parameters.AddWithValue("@presentpermanentaddresssame", chkSame.Checked);
                    cmd.Parameters.AddWithValue("@PresentDistrictID", ddlPresentDistrict.SelectedValue);
                    cmd.Parameters.AddWithValue("@PresentPoliceStationID", ddlPresentPoliceStation.SelectedValue);
                    cmd.Parameters.AddWithValue("@PresentPostOfficeEnglish", txtPresentPostOfficeEnglish.Text);
                    cmd.Parameters.AddWithValue("@PresentPostOfficeBangla", txtPresentPostOfficeBangla.Text);
                    cmd.Parameters.AddWithValue("@PresentVillageEnglish", txtPresentVillageEnglish.Text);
                    cmd.Parameters.AddWithValue("@PresentVillageBangla", txtPresentVillageBangla.Text);

                    cmd.Parameters.AddWithValue("@HouseHolderNameEnglish", txtHouseHolderNameEnglish.Text);
                    cmd.Parameters.AddWithValue("@HouseHolderNameBangla", txtHouseHolderNameBangla.Text);
                    cmd.Parameters.AddWithValue("@HouseHolderPhoneNo", txtHouseHolderPhoneNo.Text);

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

                    // --- Tab 6: Experience Parameters ---
                    cmd.Parameters.AddWithValue("@FactoryName", txtFactoryName.Text.Trim());
                    cmd.Parameters.AddWithValue("@FactoryAddress", txtFactoryAddress.Text.Trim());
                    cmd.Parameters.AddWithValue("@TotalExperienceYear", string.IsNullOrEmpty(txtTotalExpYear.Text) ? (object)DBNull.Value : Convert.ToInt32(txtTotalExpYear.Text));
                    cmd.Parameters.AddWithValue("@TotalExperienceMonth", string.IsNullOrEmpty(txtTotalExpMonth.Text) ? (object)DBNull.Value : Convert.ToInt32(txtTotalExpMonth.Text));
                    cmd.Parameters.AddWithValue("@UseExperienceDateRange", chkUseExpDate.Checked);
                    cmd.Parameters.AddWithValue("@ExperienceFromDate", string.IsNullOrEmpty(txtExpFromDate.Text) ? (object)DBNull.Value : Convert.ToDateTime(txtExpFromDate.Text));
                    cmd.Parameters.AddWithValue("@ExperienceTillDate", string.IsNullOrEmpty(txtExpTillDate.Text) ? (object)DBNull.Value : Convert.ToDateTime(txtExpTillDate.Text));

                    // --- Tab 7: Reference Parameters ---
                    cmd.Parameters.AddWithValue("@RefEmployeeIDNo", txtRefEmpID.Text.Trim());
                    cmd.Parameters.AddWithValue("@RefName", txtRefName.Text.Trim());
                    cmd.Parameters.AddWithValue("@RefDesignation", txtRefDesignation.Text.Trim());
                    cmd.Parameters.AddWithValue("@RefCompany", txtRefCompany.Text.Trim());
                    cmd.Parameters.AddWithValue("@RefEmail", txtRefEmail.Text.Trim());
                    cmd.Parameters.AddWithValue("@RefPhone", txtRefPhone.Text.Trim());

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
                        // Error handling logic here
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
                                txtName.Text = reader["Name"] == DBNull.Value ? "" : reader["Name"].ToString();
                                txtBanglaName.Text = reader["BanglaName"] == DBNull.Value ? "" : reader["BanglaName"].ToString();
                                txtJoiningDate.Text = reader["JoiningDate"] == DBNull.Value ? "" : Convert.ToDateTime(reader["JoiningDate"]).ToString("yyyy-MM-dd");
                                txtProbationPeriod.Text = reader["ProbationPeriod"] == DBNull.Value ? "" : Convert.ToDateTime(reader["ProbationPeriod"]).ToString("yyyy-MM-dd");
                                txtSeparationDate.Text = reader["SeparationDate"] == DBNull.Value ? "" : Convert.ToDateTime(reader["SeparationDate"]).ToString("yyyy-MM-dd");
                                string status = reader["EmployeeStatus"] == DBNull.Value ? "" : reader["EmployeeStatus"].ToString();
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
                                string BranchID = reader["BranchID"] == DBNull.Value ? "" : reader["BranchID"].ToString();
                                if (ddlBranch.Items.FindByValue(BranchID) != null)
                                {
                                    ddlBranch.SelectedValue = BranchID;
                                }
                                string DepartmentID = reader["DepartmentID"] == DBNull.Value ? "" : reader["DepartmentID"].ToString();
                                if (ddlDepartment.Items.FindByValue(DepartmentID) != null)
                                {
                                    ddlDepartment.SelectedValue = DepartmentID;
                                }
                                string SectionID = reader["SectionID"] == DBNull.Value ? "" : reader["SectionID"].ToString();
                                if (ddlSection.Items.FindByValue(SectionID) != null)
                                {
                                    ddlSection.SelectedValue = SectionID;
                                }
                                string LineID = reader["LineID"] == DBNull.Value ? "" : reader["LineID"].ToString();
                                if (ddlLine.Items.FindByValue(LineID) != null)
                                {
                                    ddlLine.SelectedValue = LineID;
                                }
                                string DesignationID = reader["DesignationID"] == DBNull.Value ? "" : reader["DesignationID"].ToString();
                                if (ddlDesignation.Items.FindByValue(DesignationID) != null)
                                {
                                    ddlDesignation.SelectedValue = DesignationID;
                                }
                                string CategoryID = reader["CategoryID"] == DBNull.Value ? "" : reader["CategoryID"].ToString();
                                if (ddlCategory.Items.FindByValue(CategoryID) != null)
                                {
                                    ddlCategory.SelectedValue = CategoryID;
                                }
                                string ShiftID = reader["ShiftID"] == DBNull.Value ? "" : reader["ShiftID"].ToString();
                                if (ddlShift.Items.FindByValue(ShiftID) != null)
                                {
                                    ddlShift.SelectedValue = ShiftID;
                                }
                                string FloorID = reader["FloorID"] == DBNull.Value ? "" : reader["FloorID"].ToString();
                                if (ddlFloor.Items.FindByValue(FloorID) != null)
                                {
                                    ddlFloor.SelectedValue = FloorID;
                                }
                                string WeeklyHolidayID = reader["WeeklyHolidayID"] == DBNull.Value ? "" : reader["WeeklyHolidayID"].ToString();
                                if (ddlWeekoff.Items.FindByValue(WeeklyHolidayID) != null)
                                {
                                    ddlWeekoff.SelectedValue = WeeklyHolidayID;
                                }
                                txtGrossSalary.Text = reader["GrossSalary"] == DBNull.Value ? "" : reader["GrossSalary"].ToString();
                                txtAccountNumber.Text = reader["AccountNumber"] == DBNull.Value ? "" : reader["AccountNumber"].ToString();
                                txtRoutingNo.Text = reader["RoutingNo"] == DBNull.Value ? "" : reader["RoutingNo"].ToString();
                                txtTaxableGrossSalary.Text = reader["TaxableGrossSalary"] == DBNull.Value ? "" : reader["TaxableGrossSalary"].ToString();
                                txtNonTaxableGrossSalary.Text = reader["NonTaxableGrossSalary"] == DBNull.Value ? "" : reader["NonTaxableGrossSalary"].ToString();
                                txtTaxAmount.Text = reader["TaxAmount"] == DBNull.Value ? "" : reader["TaxAmount"].ToString();
                                string BankHolderID = reader["BankHolderID"] == DBNull.Value ? "" : reader["BankHolderID"].ToString();
                                if (ddlBankHolder.Items.FindByValue(BankHolderID) != null)
                                {
                                    ddlBankHolder.SelectedValue = BankHolderID;
                                }
                                string BankID = reader["BankID"] == DBNull.Value ? "" : reader["BankID"].ToString();
                                if (ddlBank.Items.FindByValue(BankID) != null)
                                {
                                    ddlBank.SelectedValue = BankID;
                                }
                                string PayTypeID = reader["PayTypeID"] == DBNull.Value ? "" : reader["PayTypeID"].ToString();
                                if (ddlPayType.Items.FindByValue(PayTypeID) != null)
                                {
                                    ddlPayType.SelectedValue = PayTypeID;
                                }
                                string TaxHolderID = reader["TaxHolderID"] == DBNull.Value ? "" : reader["TaxHolderID"].ToString();
                                if (ddlTaxHolder.Items.FindByValue(TaxHolderID) != null)
                                {
                                    ddlTaxHolder.SelectedValue = TaxHolderID;
                                }
                                txtFatherEnglish.Text = reader["FatherEnglish"] == DBNull.Value ? "" : reader["FatherEnglish"].ToString();
                                txtFatherBangla.Text = reader["FatherBangla"] == DBNull.Value ? "" : reader["FatherBangla"].ToString();
                                txtMotherEnglish.Text = reader["MotherEnglish"] == DBNull.Value ? "" : reader["MotherEnglish"].ToString();
                                txtMotherBangla.Text = reader["MotherBangla"] == DBNull.Value ? "" : reader["MotherBangla"].ToString();
                                txtSpouseEnglish.Text = reader["SpouseEnglish"] == DBNull.Value ? "" : reader["SpouseEnglish"].ToString();
                                txtSpouseBangla.Text = reader["SpouseBangla"] == DBNull.Value ? "" : reader["SpouseBangla"].ToString();
                                txtNID.Text = reader["NID"] == DBNull.Value ? "" : reader["NID"].ToString();
                                txtBID.Text = reader["BID"] == DBNull.Value ? "" : reader["BID"].ToString();
                                txtDateOfBirth.Text = reader["DateOfBirth"] == DBNull.Value ? "" : reader["DateOfBirth"].ToString();
                                string maritalStatus = reader["MaritalStatus"] == DBNull.Value ? "" : reader["MaritalStatus"].ToString();
                                if (ddlMaritalStatus.Items.FindByValue(maritalStatus) != null)
                                {
                                    ddlMaritalStatus.SelectedValue = maritalStatus;
                                }
                                string religion = reader["Religion"] == DBNull.Value ? "" : reader["Religion"].ToString();
                                if (ddlReligion.Items.FindByValue(religion) != null)
                                {
                                    ddlReligion.SelectedValue = religion;
                                }
                                txtNoofChild.Text = reader["NoofChild"] == DBNull.Value ? "" : reader["NoofChild"].ToString();
                                string gender = reader["Gender"] == DBNull.Value ? "" : reader["Gender"].ToString();
                                if (ddlGender.Items.FindByValue(gender) != null)
                                {
                                    ddlGender.SelectedValue = gender;
                                }
                                txtHeightFeet.Text = reader["HeightFeet"] == DBNull.Value ? "" : reader["HeightFeet"].ToString();
                                txtHeightInch.Text = reader["HeightInch"] == DBNull.Value ? "" : reader["HeightInch"].ToString();
                                txtWeightKG.Text = reader["WeightKG"] == DBNull.Value ? "" : reader["WeightKG"].ToString();
                                string bloodGroup = reader["BloodGroup"] == DBNull.Value ? "" : reader["BloodGroup"].ToString();
                                if (ddlBloodGroup.Items.FindByValue(bloodGroup) != null)
                                {
                                    ddlBloodGroup.SelectedValue = bloodGroup;
                                }
                                txtTIN.Text = reader["TIN"] == DBNull.Value ? "" : reader["TIN"].ToString();
                                txtPersonalPhone.Text = reader["PersonalPhone"] == DBNull.Value ? "" : reader["PersonalPhone"].ToString();
                                txtHomePhone.Text = reader["HomePhone"] == DBNull.Value ? "" : reader["HomePhone"].ToString();
                                string education = reader["Education"] == DBNull.Value ? "" : reader["Education"].ToString();
                                if (ddlEducation.Items.FindByValue(education) != null)
                                {
                                    ddlEducation.SelectedValue = education;
                                }
                                txtEmail.Text = reader["Email"] == DBNull.Value ? "" : reader["Email"].ToString();
                                string PermanentDistrictID = reader["PermanentDistrictID"] == DBNull.Value ? "" : reader["PermanentDistrictID"].ToString();
                                if (ddlPermanentDistrict.Items.FindByValue(PermanentDistrictID) != null)
                                {
                                    ddlPermanentDistrict.SelectedValue = PermanentDistrictID;
                                }
                                string PermanentPoliceStationID = reader["PermanentPoliceStationID"] == DBNull.Value ? "" : reader["PermanentPoliceStationID"].ToString();
                                if (ddlPermanentPoliceStation.Items.FindByValue(PermanentPoliceStationID) != null)
                                {
                                    ddlPermanentPoliceStation.SelectedValue = PermanentPoliceStationID;
                                }
                                txtPermanentPostOfficeEnglish.Text = reader["PermanentPostOfficeEnglish"] == DBNull.Value ? "" : reader["PermanentPostOfficeEnglish"].ToString();
                                txtPermanentPostOfficeBangla.Text = reader["PermanentPostOfficeBangla"] == DBNull.Value ? "" : reader["PermanentPostOfficeBangla"].ToString();
                                txtPermanentVillageEnglish.Text = reader["PermanentVillageEnglish"] == DBNull.Value ? "" : reader["PermanentVillageEnglish"].ToString();
                                txtPermanentVillageBangla.Text = reader["PermanentVillageBangla"] == DBNull.Value ? "" : reader["PermanentVillageBangla"].ToString();
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
                                string PresentDistrictID = reader["PresentDistrictID"] == DBNull.Value ? "" : reader["PresentDistrictID"].ToString();
                                if (ddlPresentDistrict.Items.FindByValue(PresentDistrictID) != null)
                                {
                                    ddlPresentDistrict.SelectedValue = PresentDistrictID;
                                }
                                string PresentPoliceStationID = reader["PresentPoliceStationID"] == DBNull.Value ? "" : reader["PresentPoliceStationID"].ToString();
                                if (ddlPresentPoliceStation.Items.FindByValue(PresentPoliceStationID) != null)
                                {
                                    ddlPresentPoliceStation.SelectedValue = PresentPoliceStationID;
                                }
                                txtPresentPostOfficeEnglish.Text = reader["PresentPostOfficeEnglish"] == DBNull.Value ? "" : reader["PresentPostOfficeEnglish"].ToString();
                                txtPresentPostOfficeBangla.Text = reader["PresentPostOfficeBangla"] == DBNull.Value ? "" : reader["PresentPostOfficeBangla"].ToString();
                                txtPresentVillageEnglish.Text = reader["PresentVillageEnglish"] == DBNull.Value ? "" : reader["PresentVillageEnglish"].ToString();
                                txtPresentVillageBangla.Text = reader["PresentVillageBangla"] == DBNull.Value ? "" : reader["PresentVillageBangla"].ToString();

                                txtHouseHolderNameEnglish.Text = reader["HouseHolderNameEnglish"] == DBNull.Value ? "" : reader["HouseHolderNameEnglish"].ToString();
                                txtHouseHolderNameBangla.Text = reader["HouseHolderNameBangla"] == DBNull.Value ? "" : reader["HouseHolderNameBangla"].ToString();
                                txtHouseHolderPhoneNo.Text = reader["HouseHolderPhoneNo"] == DBNull.Value ? "" : reader["HouseHolderPhoneNo"].ToString();

                                // --- Nominee Details (Tab 5) ---
                                if (reader["RelationWithNominee"] != DBNull.Value) ddlNomineeRelation.SelectedValue = reader["RelationWithNominee"].ToString();
                                txtNomineesName.Text = reader["NomineesName"] != DBNull.Value ? reader["NomineesName"].ToString() : string.Empty;
                                txtNomineeNameBangla.Text = reader["NomineeNameBangla"] != DBNull.Value ? reader["NomineeNameBangla"].ToString() : string.Empty;
                                txtNomineesNID.Text = reader["NomineesNID"] != DBNull.Value ? reader["NomineesNID"].ToString() : string.Empty;
                                txtNomineesBID.Text = reader["NomineesBID"] != DBNull.Value ? reader["NomineesBID"].ToString() : string.Empty;
                                txtNomineesDateOfBirth.Text = reader["NomineesDateOfBirth"] != DBNull.Value ? reader["NomineesDateOfBirth"].ToString() : string.Empty;
                                txtNomineesPhoneNo.Text = reader["NomineesPhoneNo"] != DBNull.Value ? reader["NomineesPhoneNo"].ToString() : string.Empty;

                                if (reader["EmployeeNomineeAddressSame"] != DBNull.Value)
                                {
                                    CheckNominee.Checked = Convert.ToBoolean(reader["EmployeeNomineeAddressSame"]);
                                }
                                if (reader["NomineesDistrictID"] != DBNull.Value) ddlNomineeDistrict.SelectedValue = reader["NomineesDistrictID"].ToString();
                                if (reader["NomineesPoliceStationID"] != DBNull.Value) ddlNomineePoliceStation.SelectedValue = reader["NomineesPoliceStationID"].ToString();
                                txtNomineePostOfficeEnglish.Text = reader["NomineesPostOfficeEnglish"] != DBNull.Value ? reader["NomineesPostOfficeEnglish"].ToString() : string.Empty;
                                txtNomineePostOfficeBangla.Text = reader["NomineesPostOfficeBangla"] != DBNull.Value ? reader["NomineesPostOfficeBangla"].ToString() : string.Empty;
                                txtNomineeVillageEnglish.Text = reader["NomineesVillageEnglish"] != DBNull.Value ? reader["NomineesVillageEnglish"].ToString() : string.Empty;
                                txtNomineeVillageBangla.Text = reader["NomineesVillageBangla"] != DBNull.Value ? reader["NomineesVillageBangla"].ToString() : string.Empty;


                                // --- Tab 6: Experience Details ---
                                txtFactoryName.Text = reader["FactoryName"] != DBNull.Value ? reader["FactoryName"].ToString() : string.Empty;
                                txtFactoryAddress.Text = reader["FactoryAddress"] != DBNull.Value ? reader["FactoryAddress"].ToString() : string.Empty;
                                txtTotalExpYear.Text = reader["TotalExperienceYear"] != DBNull.Value ? reader["TotalExperienceYear"].ToString() : string.Empty;
                                txtTotalExpMonth.Text = reader["TotalExperienceMonth"] != DBNull.Value ? reader["TotalExperienceMonth"].ToString() : string.Empty;

                                if (reader["UseExperienceDateRange"] != DBNull.Value)
                                {
                                    chkUseExpDate.Checked = Convert.ToBoolean(reader["UseExperienceDateRange"]);
                                }

                                if (reader["ExperienceFromDate"] != DBNull.Value)
                                    txtExpFromDate.Text = Convert.ToDateTime(reader["ExperienceFromDate"]).ToString("yyyy-MM-dd");

                                if (reader["ExperienceTillDate"] != DBNull.Value)
                                    txtExpTillDate.Text = Convert.ToDateTime(reader["ExperienceTillDate"]).ToString("yyyy-MM-dd");

                                // --- Tab 7: Reference Details ---
                                txtRefEmpID.Text = reader["RefEmployeeIDNo"] != DBNull.Value ? reader["RefEmployeeIDNo"].ToString() : string.Empty;
                                txtRefName.Text = reader["RefName"] != DBNull.Value ? reader["RefName"].ToString() : string.Empty;
                                txtRefDesignation.Text = reader["RefDesignation"] != DBNull.Value ? reader["RefDesignation"].ToString() : string.Empty;
                                txtRefCompany.Text = reader["RefCompany"] != DBNull.Value ? reader["RefCompany"].ToString() : string.Empty;
                                txtRefEmail.Text = reader["RefEmail"] != DBNull.Value ? reader["RefEmail"].ToString() : string.Empty;
                                txtRefPhone.Text = reader["RefPhone"] != DBNull.Value ? reader["RefPhone"].ToString() : string.Empty;
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
                        string safeMsg = ex.Message.Replace("'", "").Replace("\n", " ").Replace("\r", ""); ClientScript.RegisterStartupScript(this.GetType(), "SearchError", "alert('DEBUG ERROR: " + safeMsg + "');", true);
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