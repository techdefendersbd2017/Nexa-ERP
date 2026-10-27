using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.HRMPayroll.EmployeeLifecycle
{
    public partial class EmployeePersonalInformationUpdate : System.Web.UI.Page
    {
        PayrollDB conn = new PayrollDB();
        const int MaxPhotoBytes = 300 * 1024;   // 300 KB

        string UserName
        {
            get { return Convert.ToString(Session["User_Name"] ?? Session["UserName"] ?? ""); }
        }

        // ================= Page Load =================
        protected void Page_Load(object sender, EventArgs e)
        {
            lblUser.Text = UserName;
            if (!IsPostBack)
            {
                BindLists();
                ResetForm();
            }
        }

        // ================= ড্রপডাউনের তালিকা (Desktop এর Load এর মতো) =================
        void BindLists()
        {
            FillList(ddlGender, new List<string> { "Male", "Female", "Other" });   // TODO: Desktop এর comboBox_Gender এর আইটেমের সঙ্গে মিলিয়ে নিন
            FillList(ddlBloodGroup, new List<string> { "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-" });

            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();

                    FillList(ddlReligion, Names(con, "SELECT Religion_Name FROM Religion ORDER BY Religion_Name", "Religion_Name"));
                    FillList(ddlMaritalStatus, Names(con, "SELECT Marital_Status_name FROM Marital_Status ORDER BY Marital_Status_name", "Marital_Status_name"));
                    FillList(ddlEducation, Names(con, "SELECT Education_Name FROM tb_Education ORDER BY Education_Name", "Education_Name"));
                    FillList(ddlNomineeRelation, Names(con, "SELECT Relation_Name FROM Relation ORDER BY Relation_Name", "Relation_Name"));

                    var dt = new DataTable();
                    using (var da = new SqlDataAdapter("SELECT Training_ID, Training_Head_Name FROM Training_Head_Informations", con)) da.Fill(dt);
                    ddlTrainingHead.DataSource = dt;
                    ddlTrainingHead.DataValueField = "Training_ID";
                    ddlTrainingHead.DataTextField = "Training_Head_Name";
                    ddlTrainingHead.DataBind();
                }
            }
            catch (Exception ex)
            {
                Toast("List load error: " + ex.Message);
            }
        }

        static List<string> Names(SqlConnection con, string sql, string col)
        {
            var list = new List<string>();
            var dt = new DataTable();
            using (var da = new SqlDataAdapter(sql, con)) da.Fill(dt);
            foreach (DataRow r in dt.Rows)
            {
                string s = Convert.ToString(r[col]).Trim();
                if (s != "" && !list.Contains(s)) list.Add(s);
            }
            return list;
        }

        static void FillList(DropDownList ddl, List<string> items)
        {
            ddl.Items.Clear();
            ddl.Items.Add(new ListItem("Select", ""));
            foreach (string s in items) ddl.Items.Add(new ListItem(s, s));
        }

        // তালিকায় মান না থাকলে যোগ করে সিলেক্ট করে
        static void SetDdl(DropDownList ddl, string v)
        {
            ddl.ClearSelection();
            v = (v ?? "").Trim();
            if (v == "") { if (ddl.Items.Count > 0) ddl.SelectedIndex = 0; return; }
            ListItem li = ddl.Items.FindByValue(v);
            if (li == null) { li = new ListItem(v, v); ddl.Items.Add(li); }
            li.Selected = true;
        }

        // ================= Search =================
        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadEmployee(txtEmpID.Text.Trim());
        }

        static string S(IDataRecord rd, int i)
        {
            if (i >= rd.FieldCount || rd.IsDBNull(i)) return "";
            return Convert.ToString(rd[i]).Trim();
        }

        static bool IsTrue(string s)
        {
            return s.Equals("True", StringComparison.OrdinalIgnoreCase) || s == "1";
        }

        void LoadEmployee(string empId)
        {
            if (empId == "") { Toast("Please enter ID No."); return; }

            bool found = false;
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();

                    using (var cmd = new SqlCommand("SELECT * FROM View_Employee_Personal_information_With_Code WHERE ID_no=@id", con))
                    {
                        cmd.Parameters.Add("@id", SqlDbType.NVarChar, 50).Value = empId;
                        using (var rd = cmd.ExecuteReader())
                        {
                            if (rd.Read()) { found = true; FillFromReader(rd); }
                        }
                    }

                    if (found) LoadDivision(con, txtPerDistrictEn.Text.Trim());
                }
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message);
                return;
            }

            if (!found)
            {
                ResetForm();
                Toast("This ID- '" + empId + "' Not Exists In your Database.");
                return;
            }

            LoadPhoto(txtEmpID.Text.Trim());
            LoadTraining(txtEmpID.Text.Trim());
            ApplyLock();
        }

        // Desktop (Personal_Information_Update.button1_Click) এর সঙ্গে একই column index
        void FillFromReader(IDataRecord rd)
        {
            txtEmpID.Text = S(rd, 1);
            txtName.Text = S(rd, 2);
            txtBanglaName.Text = S(rd, 3);
            txtJoiningDate.Text = ToHtmlDate(rd[4]);
            txtProbationPeriod.Text = ToHtmlDate(rd[5]);
            txtStatus.Text = S(rd, 6);
            txtSeparationDate.Text = ToHtmlDate(rd[7]);

            txtFatherEnglish.Text = S(rd, 8);
            txtFatherBangla.Text = S(rd, 9);
            txtMotherEnglish.Text = S(rd, 10);
            txtMotherBangla.Text = S(rd, 11);
            txtHusbandEnglish.Text = S(rd, 12);
            txtHusbandBangla.Text = S(rd, 13);
            txtSpouseEnglish.Text = S(rd, 14);
            txtSpouseBangla.Text = S(rd, 15);
            txtNID.Text = S(rd, 16);
            txtBID.Text = S(rd, 17);
            txtDateOfBirth.Text = ToHtmlDate(rd[18]);
            SetDdl(ddlMaritalStatus, S(rd, 19));
            SetDdl(ddlReligion, S(rd, 20));
            txtNoofChild.Text = S(rd, 21);
            SetDdl(ddlGender, S(rd, 22));
            txtHeightFeet.Text = S(rd, 23);
            SetDdl(ddlBloodGroup, S(rd, 24));
            txtTIN.Text = S(rd, 25);
            txtPersonalPhone.Text = S(rd, 26);
            txtHomePhone.Text = S(rd, 27);
            SetDdl(ddlEducation, S(rd, 28));
            txtEmail.Text = S(rd, 29);

            // Permanent
            txtPerDistrictEn.Text = S(rd, 98);
            txtPerDistrictBa.Text = S(rd, 99);
            txtPerThanaEn.Text = S(rd, 96);
            txtPerThanaBa.Text = S(rd, 97);
            txtPerPostEn.Text = S(rd, 34);
            txtPerPostBa.Text = S(rd, 35);
            txtPerVillageEn.Text = S(rd, 36);
            txtPerVillageBa.Text = S(rd, 37);

            // Present
            txtPreDistrictEn.Text = S(rd, 38);
            txtPreDistrictBa.Text = S(rd, 39);
            txtPreThanaEn.Text = S(rd, 40);
            txtPreThanaBa.Text = S(rd, 41);
            txtPrePostEn.Text = S(rd, 42);
            txtPrePostBa.Text = S(rd, 43);
            txtPreVillageEn.Text = S(rd, 44);
            txtPreVillageBa.Text = S(rd, 45);
            txtHouseHolderEn.Text = S(rd, 46);
            txtHouseHolderBa.Text = S(rd, 47);
            txtHouseHolderPhone.Text = S(rd, 48);

            // Nominee
            SetDdl(ddlNomineeRelation, S(rd, 49));
            txtRelationBangla.Text = S(rd, 50);
            txtNomineeNameEn.Text = S(rd, 51);
            txtNomineeNameBa.Text = S(rd, 52);
            txtNomineeNID.Text = S(rd, 53);
            txtNomineeBID.Text = S(rd, 54);
            txtNomineeDOB.Text = ToHtmlDate(rd[55]);
            txtNomAddressEn.Text = S(rd, 56);
            txtNomAddressBa.Text = S(rd, 57);

            // Job experience
            txtFactoryName.Text = S(rd, 58);
            txtFactoryNameBangla.Text = S(rd, 59);
            txtFactoryAddress.Text = S(rd, 60);
            txtFactoryAddressBangla.Text = S(rd, 61);
            txtTotalExpYear.Text = S(rd, 62);
            txtExpFrom.Text = ToHtmlDate(rd[63]);
            txtExpTill.Text = ToHtmlDate(rd[64]);
            chkExpDates.Checked = IsTrue(S(rd, 65));

            // Reference
            txtRefID.Text = S(rd, 66);
            txtRefName.Text = S(rd, 67);
            txtRefDesignation.Text = S(rd, 68);
            txtRefCompany.Text = S(rd, 69);
            txtRefEmail.Text = S(rd, 70);
            txtRefPhone.Text = S(rd, 71);
            txtWeightKG.Text = S(rd, 72);
            txtHeightInch.Text = S(rd, 73);

            // Nominee address
            txtNomVillageEn.Text = S(rd, 74);
            txtNomVillageBa.Text = S(rd, 75);
            txtNomPostEn.Text = S(rd, 76);
            txtNomPostBa.Text = S(rd, 77);
            txtNomThanaEn.Text = S(rd, 78);
            txtNomThanaBa.Text = S(rd, 79);
            txtNomDistrictEn.Text = S(rd, 80);
            txtNomDistrictBa.Text = S(rd, 81);
            txtTotalExpMonth.Text = S(rd, 82);

            hfLock.Value = S(rd, 83);

            // Covid
            txtVaccineStatus.Text = S(rd, 84);
            txtVaccineRegDate.Text = ToHtmlDate(rd[85]);
            txtVaccineName.Text = S(rd, 86);
            chkDose1.Checked = IsTrue(S(rd, 87));
            txtDose1Date.Text = ToHtmlDate(rd[88]);
            chkDose2.Checked = IsTrue(S(rd, 89));
            txtDose2Date.Text = ToHtmlDate(rd[90]);
            chkDose3.Checked = IsTrue(S(rd, 91));
            txtDose3Date.Text = ToHtmlDate(rd[92]);
            txtDose4Date.Text = ToHtmlDate(rd[93]);
            txtNomineePhone.Text = S(rd, 94);
            chkDose4.Checked = IsTrue(S(rd, 95));

            // Status অনুযায়ী Separation Date (Active হলে লুকানো)
            bool active = txtStatus.Text == "Active";
            lblSepLabel.Visible = !active;
            txtSeparationDate.Visible = !active;
            lblSepLabel.Text = txtStatus.Text + " Date:";
        }

        // Desktop: জেলা লিখে Enter দিলে Division আসত। এখানে লোডের সময়ই এনে রাখি।
        void LoadDivision(SqlConnection con, string district)
        {
            txtPerDivisionEn.Text = "";
            txtPerDivisionBa.Text = "";
            if (district == "") return;
            try
            {
                using (var cmd = new SqlCommand("SELECT * FROM Address_View WHERE District_Name=@d", con))
                {
                    cmd.Parameters.Add("@d", SqlDbType.NVarChar, 200).Value = district;
                    using (var rd = cmd.ExecuteReader())
                    {
                        if (rd.Read())
                        {
                            txtPerDivisionEn.Text = S(rd, 3);
                            txtPerDivisionBa.Text = S(rd, 4);
                        }
                    }
                }
            }
            catch { }
        }

        // ================= Photo =================
        void LoadPhoto(string empId)
        {
            imgEmp.ImageUrl = "~/Images/user-default.png";
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();
                    using (var cmd = new SqlCommand("SELECT Photo FROM Emp_Photo WHERE Emp_no=@e", con))
                    {
                        cmd.Parameters.Add("@e", SqlDbType.NVarChar, 50).Value = empId;
                        object o = cmd.ExecuteScalar();
                        if (o != null && o != DBNull.Value)
                            imgEmp.ImageUrl = "data:image/jpeg;base64," + Convert.ToBase64String((byte[])o);
                    }
                }
            }
            catch (Exception ex)
            {
                Toast("Photo error: " + ex.Message);
            }
        }

        byte[] GetUploadedPhoto(out bool invalid)
        {
            invalid = false;
            if (!fuPhoto.HasFile) return null;

            if (fuPhoto.PostedFile.ContentLength > MaxPhotoBytes) { invalid = true; return null; }

            string ext = Path.GetExtension(fuPhoto.FileName).ToLowerInvariant();
            if (ext != ".jpg" && ext != ".jpeg" && ext != ".png" && ext != ".bmp") { invalid = true; return null; }
            return fuPhoto.FileBytes;
        }

        static void SavePhoto(SqlConnection con, string empId, byte[] photo)
        {
            if (photo == null) return;

            using (var up = new SqlCommand("UPDATE Emp_Photo SET Photo=@p WHERE Emp_no=@e", con))
            {
                up.Parameters.Add("@p", SqlDbType.VarBinary, -1).Value = photo;
                up.Parameters.Add("@e", SqlDbType.NVarChar, 50).Value = empId;
                if (up.ExecuteNonQuery() > 0) return;
            }
            using (var ins = new SqlCommand("INSERT INTO Emp_Photo (Emp_no, Photo) VALUES (@e, @p)", con))
            {
                ins.Parameters.Add("@p", SqlDbType.VarBinary, -1).Value = photo;
                ins.Parameters.Add("@e", SqlDbType.NVarChar, 50).Value = empId;
                ins.ExecuteNonQuery();
            }
        }

        // ================= Save (Pro_Employee_Personal_info_Update) =================
        protected void btnSave_Click(object sender, EventArgs e)
        {
            string id = txtEmpID.Text.Trim();
            if (id == "") { Toast("Please enter ID No."); return; }
            if (!EmpExists(id)) { Toast("This ID- '" + id + "' Not Exists In your Database."); return; }

            bool invalid;
            byte[] photo = GetUploadedPhoto(out invalid);
            if (invalid) { Toast("ছবির সাইজ সর্বোচ্চ 300 KB এবং ফরম্যাট JPG/PNG/BMP হতে হবে।"); return; }

            bool ok = false;
            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();
                    using (var cmd = new SqlCommand("Pro_Employee_Personal_info_Update", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        Action<string, string> p = delegate (string n, string v) { cmd.Parameters.AddWithValue(n, v ?? ""); };

                        p("@Emp_ID", id);
                        p("@Name", txtName.Text.Trim());
                        p("@Bangal_Name", txtBanglaName.Text.Trim());
                        p("@Fathers", txtFatherEnglish.Text.Trim());
                        p("@Fathers_Bangla", txtFatherBangla.Text.Trim());
                        p("@Mothers", txtMotherEnglish.Text.Trim());
                        p("@Mothers_Bangla", txtMotherBangla.Text.Trim());
                        p("@Husband", txtHusbandEnglish.Text.Trim());
                        p("@Husband_Bangla", txtHusbandBangla.Text.Trim());
                        p("@Wife", txtSpouseEnglish.Text.Trim());
                        p("@Wife_Bangla", txtSpouseBangla.Text.Trim());
                        p("@NID", txtNID.Text.Trim());
                        p("@BID", txtBID.Text.Trim());
                        p("@Gender", ddlGender.SelectedValue);
                        p("@Religion", ddlReligion.SelectedValue);
                        p("@Marital_Status", ddlMaritalStatus.SelectedValue);
                        p("@Personal_Phone", txtPersonalPhone.Text.Trim());
                        p("@Home_Phone", txtHomePhone.Text.Trim());
                        p("@TIN", txtTIN.Text.Trim());
                        p("@Email", txtEmail.Text.Trim());
                        p("@Village", txtPerVillageEn.Text.Trim());
                        p("@Post", txtPerPostEn.Text.Trim());
                        p("@Thana", txtPerThanaEn.Text.Trim());
                        p("@District", txtPerDistrictEn.Text.Trim());
                        p("@P_Village", txtPreVillageEn.Text.Trim());
                        p("@P_Post", txtPrePostEn.Text.Trim());
                        p("@P_Thana", txtPreThanaEn.Text.Trim());
                        p("@P_District", txtPreDistrictEn.Text.Trim());
                        p("@Nominee_Name", txtNomineeNameEn.Text.Trim());
                        p("@Relation", ddlNomineeRelation.SelectedValue);
                        p("@N_BID", txtNomineeBID.Text.Trim());
                        p("@N_NID", txtNomineeNID.Text.Trim());
                        p("@Address", txtNomAddressEn.Text.Trim());
                        p("@Nominee_Name_Bangla", txtNomineeNameBa.Text.Trim());
                        p("@Relation_Bangla", txtRelationBangla.Text.Trim());
                        p("@Address_Bangla", txtNomAddressBa.Text.Trim());
                        p("@Nominee_Date_of_Birth", D(txtNomineeDOB.Text));
                        p("@B_Village", txtPerVillageBa.Text.Trim());
                        p("@B_Post", txtPerPostBa.Text.Trim());
                        p("@B_Thana", txtPerThanaBa.Text.Trim());
                        p("@B_District", txtPerDistrictBa.Text.Trim());
                        p("@B_P_Village", txtPreVillageBa.Text.Trim());
                        p("@B_P_Post", txtPrePostBa.Text.Trim());
                        p("@B_P_Thana", txtPreThanaBa.Text.Trim());
                        p("@B_P_District", txtPreDistrictBa.Text.Trim());
                        p("@Blood_Group", ddlBloodGroup.SelectedValue);
                        p("@Entry", UserName);
                        p("@Division_name", txtPerDivisionEn.Text.Trim());
                        p("@Education", ddlEducation.SelectedValue);
                        p("@Number_of_Child", txtNoofChild.Text.Trim());
                        p("@Hight", txtHeightFeet.Text.Trim());
                        p("@house_holder_name", txtHouseHolderEn.Text.Trim());
                        p("@house_holder_Bangla_name", txtHouseHolderBa.Text.Trim());
                        p("@house_holder_Phone", txtHouseHolderPhone.Text.Trim());
                        p("@Factory_Name", txtFactoryName.Text.Trim());
                        p("@Factory_Name_Bangla", txtFactoryNameBangla.Text.Trim());
                        p("@Factory_Address", txtFactoryAddress.Text.Trim());
                        p("@Factory_Address_Bangla", txtFactoryAddressBangla.Text.Trim());
                        p("@From_Date", D(txtExpFrom.Text));
                        p("@To_Date", D(txtExpTill.Text));
                        p("@Total_Exprience", txtTotalExpYear.Text.Trim());
                        p("@exp_time", chkExpDates.Checked.ToString());
                        p("@DOB", D(txtDateOfBirth.Text));

                        p("@Referance_ID", txtRefID.Text.Trim());
                        p("@R_Name", txtRefName.Text.Trim());
                        p("@R_Designation", txtRefDesignation.Text.Trim());
                        p("@R_Company_name", txtRefCompany.Text.Trim());
                        p("@R_Email", txtRefEmail.Text.Trim());
                        p("@R_Phone_no", txtRefPhone.Text.Trim());
                        p("@weight", txtWeightKG.Text.Trim());
                        p("@Hight_inchi", txtHeightInch.Text.Trim());

                        p("@N_Village_En", txtNomVillageEn.Text.Trim());
                        p("@N_Post_En", txtNomPostEn.Text.Trim());
                        p("@N_Than_En", txtNomThanaEn.Text.Trim());
                        p("@N_District_En", txtNomDistrictEn.Text.Trim());
                        p("@N_Village_Ba", txtNomVillageBa.Text.Trim());
                        p("@N_Post_Ba", txtNomPostBa.Text.Trim());
                        p("@N_Thana_Ba", txtNomThanaBa.Text.Trim());
                        p("@N_District_Ba", txtNomDistrictBa.Text.Trim());

                        p("@Total_Exprience_Month", txtTotalExpMonth.Text.Trim());

                        p("@Vaccine_S", txtVaccineStatus.Text.Trim());
                        p("@Vaccine", txtVaccineName.Text.Trim());
                        p("@Fast_Dose", chkDose1.Checked.ToString());
                        p("@Secnd_Dose", chkDose2.Checked.ToString());
                        p("@Third_Dose", chkDose3.Checked.ToString());
                        p("@Fast_Dose_Date", D(txtDose1Date.Text));
                        p("@Secnd_Dose_Date", D(txtDose2Date.Text));
                        p("@Third_Dose_Date", D(txtDose3Date.Text));
                        p("@Vaccine_Registration_Date", D(txtVaccineRegDate.Text));
                        p("@Nominee_Phone_no", txtNomineePhone.Text.Trim());
                        p("@Forth_Dose_Date", D(txtDose4Date.Text));
                        p("@Forth_Dose", chkDose4.Checked.ToString());

                        int a = cmd.ExecuteNonQuery();
                        ok = a < 0;   // Desktop এর মতো: a < 0 হলে Update Successfull
                    }

                    SavePhoto(con, id, photo);
                }
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message);
                return;
            }

            LoadEmployee(id);
            Toast(ok ? "Update Successfull" : "Update Fail");
        }

        bool EmpExists(string empId)
        {
            if (empId == "") return false;
            using (SqlConnection con = conn.openConnection())
            {
                if (con.State != ConnectionState.Open) con.Open();
                using (var cmd = new SqlCommand("SELECT TOP 1 1 FROM View_Employee_Personal_information_With_Code WHERE ID_no=@id", con))
                {
                    cmd.Parameters.Add("@id", SqlDbType.NVarChar, 50).Value = empId;
                    return cmd.ExecuteScalar() != null;
                }
            }
        }

        // ================= Training (Pro_Employee_Wise_Training_Informations) =================
        protected void btnTrainingSave_Click(object sender, EventArgs e)
        {
            string id = txtEmpID.Text.Trim();
            if (id == "") { Toast("Please enter ID No."); return; }
            if (ddlTrainingHead.SelectedValue == "") { Toast("Please select Training Head."); return; }
            if ((hfSubjectId.Value ?? "").Trim() == "") { Toast("Please select Training Subject."); return; }

            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();
                    using (var cmd = new SqlCommand("Pro_Employee_Wise_Training_Informations", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@ID_no", id);
                        cmd.Parameters.AddWithValue("@Training_ID", ddlTrainingHead.SelectedValue);
                        cmd.Parameters.AddWithValue("@Subject_ID", hfSubjectId.Value.Trim());
                        cmd.Parameters.AddWithValue("@From_Date", D(txtTrFrom.Text));
                        cmd.Parameters.AddWithValue("@Till_Date", D(txtTrTill.Text));
                        cmd.Parameters.AddWithValue("@Duration_Days", txtTrDays.Text.Trim());
                        cmd.Parameters.AddWithValue("@Trainer_Name", txtTrainer.Text.Trim());
                        cmd.Parameters.AddWithValue("@Organization", txtTrOrg.Text.Trim());
                        cmd.Parameters.AddWithValue("@Organization_Address", txtTrOrgAddress.Text.Trim());
                        cmd.ExecuteNonQuery();
                    }
                }
                LoadTraining(id);
                Toast("Save Successfull");
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message);
            }
        }

        void LoadTraining(string empId)
        {
            var dt = new DataTable();
            dt.Columns.Add("Entry No");
            dt.Columns.Add("Training Head");
            dt.Columns.Add("Subject");
            try
            {
                if (empId != "")
                {
                    using (SqlConnection con = conn.openConnection())
                    {
                        if (con.State != ConnectionState.Open) con.Open();
                        using (var cmd = new SqlCommand("SELECT * FROM View_Training_Informations WHERE ID_no=@id", con))
                        {
                            cmd.Parameters.Add("@id", SqlDbType.NVarChar, 50).Value = empId;
                            using (var rd = cmd.ExecuteReader())
                            {
                                while (rd.Read()) dt.Rows.Add(S(rd, 0), S(rd, 2), S(rd, 3));
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Toast("Training error: " + ex.Message);
            }
            gvTraining.DataSource = dt;
            gvTraining.DataBind();
        }

        // ================= Refresh =================
        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            ResetForm();
        }

        // ================= Lock (Desktop এর label54 == "1" লজিক) =================
        void ApplyLock()
        {
            bool locked = hfLock.Value == "1";
            lblLock.Visible = locked;

            var controls = new WebControl[]
            {
                txtName, txtBanglaName,
                txtFatherEnglish, txtFatherBangla, txtMotherEnglish, txtMotherBangla, txtHusbandEnglish, txtHusbandBangla,
                txtSpouseEnglish, txtSpouseBangla, txtNID, txtBID, txtDateOfBirth, ddlMaritalStatus, ddlReligion, txtNoofChild,
                ddlGender, txtHeightFeet, txtHeightInch, txtWeightKG, ddlBloodGroup, txtTIN, txtPersonalPhone, txtHomePhone,
                ddlEducation, txtEmail,
                txtPerVillageEn, txtPerVillageBa, txtPerPostEn, txtPerPostBa, txtPerThanaEn, txtPerThanaBa, txtPerDistrictEn, txtPerDistrictBa,
                txtPreVillageEn, txtPreVillageBa, txtPrePostEn, txtPrePostBa, txtPreThanaEn, txtPreThanaBa, txtPreDistrictEn, txtPreDistrictBa,
                txtHouseHolderEn, txtHouseHolderBa, txtHouseHolderPhone,
                ddlNomineeRelation, txtRelationBangla, txtNomineeNameEn, txtNomineeNameBa, txtNomineeNID, txtNomineeBID, txtNomineeDOB,
                txtNomAddressEn, txtNomAddressBa, txtNomVillageEn, txtNomVillageBa, txtNomPostEn, txtNomPostBa,
                txtNomThanaEn, txtNomThanaBa, txtNomDistrictEn, txtNomDistrictBa, txtNomineePhone,
                txtFactoryName, txtFactoryNameBangla, txtFactoryAddress, txtFactoryAddressBangla, txtTotalExpYear, txtTotalExpMonth,
                chkExpDates, txtExpFrom, txtExpTill,
                txtRefID, txtRefName, txtRefDesignation, txtRefCompany, txtRefEmail, txtRefPhone,
                fuPhoto, btnSave
            };
            foreach (var c in controls) c.Enabled = !locked;
        }

        // ================= সাহায্যকারী =================
        void ResetForm()
        {
            ClearControls(form1);
            hfLock.Value = "";
            hfSubjectId.Value = "";

            string today = DateTime.Today.ToString("yyyy-MM-dd");
            foreach (var t in new[] { txtDateOfBirth, txtNomineeDOB, txtExpFrom, txtExpTill, txtVaccineRegDate,
                                      txtDose1Date, txtDose2Date, txtDose3Date, txtDose4Date, txtTrFrom, txtTrTill })
                t.Text = today;

            lblSepLabel.Visible = false;
            txtSeparationDate.Visible = false;
            imgEmp.ImageUrl = "~/Images/user-default.png";
            LoadTraining("");
            ApplyLock();
        }

        void ClearControls(Control parent)
        {
            foreach (Control c in parent.Controls)
            {
                if (c is TextBox) ((TextBox)c).Text = "";
                else if (c is CheckBox) ((CheckBox)c).Checked = false;
                else if (c is DropDownList)
                {
                    var d = (DropDownList)c;
                    if (d.ID != "ddlTrainingHead" && d.Items.Count > 0) d.SelectedIndex = 0;
                }
                if (c.HasControls()) ClearControls(c);
            }
        }

        static string ToHtmlDate(object v)
        {
            if (v == null || v == DBNull.Value) return "";
            if (v is DateTime) return ((DateTime)v).ToString("yyyy-MM-dd");
            DateTime d;
            string s = Convert.ToString(v);
            if (DateTime.TryParse(s, CultureInfo.InvariantCulture, DateTimeStyles.None, out d) || DateTime.TryParse(s, out d))
                return d.ToString("yyyy-MM-dd");
            return "";
        }

        // Desktop যেমন "10-Oct-2026" টেক্সট পাঠাত (তারিখ ফাঁকা হলে আজকের তারিখ, Desktop এর DateTimePicker এর মতো)
        static string D(string htmlDate)
        {
            DateTime d;
            if (!DateTime.TryParse(htmlDate, CultureInfo.InvariantCulture, DateTimeStyles.None, out d)) d = DateTime.Today;
            return d.ToString("dd-MMM-yyyy", CultureInfo.InvariantCulture);
        }

        void Toast(string msg)
        {
            string js = "document.addEventListener('DOMContentLoaded',function(){showNotification(" +
                        new JavaScriptSerializer().Serialize(msg) + ");});";
            ClientScript.RegisterStartupScript(GetType(), "toast" + Guid.NewGuid().ToString("N"), js, true);
        }

        // =====================================================================
        //  Page Methods (JavaScript থেকে কল হয়: Autocomplete, Bangla নাম, Subject তালিকা)
        // =====================================================================
        static string LikeEscape(string s)
        {
            return (s ?? "").Replace("[", "[[]").Replace("%", "[%]").Replace("_", "[_]");
        }

        [WebMethod(EnableSession = true)]
        public static List<string> Suggest(string kind, string term)
        {
            var list = new List<string>();
            string table, col;
            switch (kind)
            {
                case "village": table = "TB_Village_Info"; col = "Villege_name"; break;
                case "post": table = "Post_office_Information"; col = "Post_Office_name"; break;
                case "thana": table = "Upazila_Name_List"; col = "Upazila_Name"; break;
                case "district": table = "District_Name_List"; col = "District_Name"; break;
                case "factory": table = "Expriance_Factory_Information"; col = "Factory_Name_English"; break;
                case "vstatus": table = "Covid19_Vaccine_Status"; col = "Vaccine_Status_Name"; break;
                case "vname": table = "Covid19_Vaccine_Information"; col = "Vaccine_name"; break;
                default: return list;
            }

            using (SqlConnection con = new PayrollDB().openConnection())
            {
                if (con.State != ConnectionState.Open) con.Open();
                string sql = "SELECT DISTINCT TOP 15 " + col + " FROM " + table + " WHERE " + col + " LIKE @t ORDER BY " + col;
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.Add("@t", SqlDbType.NVarChar, 200).Value = LikeEscape((term ?? "").Trim()) + "%";
                    using (var rd = cmd.ExecuteReader())
                    {
                        while (rd.Read())
                        {
                            string s = Convert.ToString(rd[0]).Trim();
                            if (s != "") list.Add(s);
                        }
                    }
                }
            }
            return list;
        }

        // Desktop এর KeyDown(Enter) এর মতো: English নাম থেকে Bangla নাম আনে। না পেলে ফাঁকা Dictionary।
        [WebMethod(EnableSession = true)]
        public static Dictionary<string, string> Lookup(string kind, string value)
        {
            var res = new Dictionary<string, string>();
            string sql;
            switch (kind)
            {
                case "district": sql = "SELECT * FROM Address_View WHERE District_Name=@v"; break;
                case "thana": sql = "SELECT * FROM Upazila_Name_List WHERE Upazila_Name=@v"; break;
                case "post": sql = "SELECT * FROM Post_office_Information WHERE Post_Office_name=@v"; break;
                case "village": sql = "SELECT * FROM TB_Village_Info WHERE Villege_name=@v"; break;
                case "relation": sql = "SELECT * FROM Relation WHERE Relation_Name=@v"; break;
                case "factory": sql = "SELECT * FROM Expriance_Factory_Information WHERE Factory_Name_English=@v"; break;
                case "refemp": sql = "SELECT * FROM Employee_View_new WHERE ID_no=@v"; break;
                default: return res;
            }

            using (SqlConnection con = new PayrollDB().openConnection())
            {
                if (con.State != ConnectionState.Open) con.Open();
                using (var cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.Add("@v", SqlDbType.NVarChar, 200).Value = (value ?? "").Trim();
                    using (var rd = cmd.ExecuteReader())
                    {
                        if (rd.Read())
                        {
                            switch (kind)
                            {
                                case "district":
                                    res["ba"] = S(rd, 2); res["divEn"] = S(rd, 3); res["divBa"] = S(rd, 4); break;
                                case "thana":
                                case "post":
                                case "village":
                                case "relation":
                                    res["ba"] = S(rd, 2); break;
                                case "factory":
                                    res["en"] = S(rd, 1); res["ba"] = S(rd, 2); res["addrEn"] = S(rd, 3); res["addrBa"] = S(rd, 4); break;
                                case "refemp":
                                    res["name"] = S(rd, 2); res["designation"] = S(rd, 13); res["company"] = S(rd, 8);
                                    res["email"] = S(rd, 35); res["phone"] = S(rd, 32); break;
                            }
                        }
                    }
                }
            }
            return res;
        }

        [WebMethod(EnableSession = true)]
        public static List<string[]> Subjects(string trainingId)
        {
            var list = new List<string[]>();
            using (SqlConnection con = new PayrollDB().openConnection())
            {
                if (con.State != ConnectionState.Open) con.Open();
                using (var cmd = new SqlCommand("SELECT Subject_ID, Subject_Name FROM View_Training_Subject_Information WHERE Training_ID=@t", con))
                {
                    cmd.Parameters.Add("@t", SqlDbType.NVarChar, 50).Value = (trainingId ?? "").Trim();
                    using (var rd = cmd.ExecuteReader())
                    {
                        while (rd.Read()) list.Add(new[] { S(rd, 0), S(rd, 1) });
                    }
                }
            }
            return list;
        }
    }
}
