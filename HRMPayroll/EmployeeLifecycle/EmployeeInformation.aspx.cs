using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
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
                                txtJoiningDate.Text = reader["JoiningDate"] == DBNull.Value? "" : Convert.ToDateTime(reader["JoiningDate"]).ToString("yyyy-MM-dd");
                                txtProbationPeriod.Text = reader["ProbationPeriod"] == DBNull.Value? "" : Convert.ToDateTime(reader["ProbationPeriod"]).ToString("yyyy-MM-dd");
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
                                if (ddlBranch.Items.FindByValue(BranchID ) != null)
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
                                string CategoryID= reader["CategoryID"] == DBNull.Value ? "" : reader["CategoryID"].ToString();
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
                                    ddlWeekoff.SelectedValue = WeeklyHolidayID    ;
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

                                ClientScript.RegisterStartupScript(this.GetType(), "SearchNotFound","alert('No employee record exists for the provided Employee ID.');", true);
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        ClientScript.RegisterStartupScript(this.GetType(), "SearchError",    "alert('Unable to complete the search. Please try again or contact the system administrator.');", true);
                    }
                }
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