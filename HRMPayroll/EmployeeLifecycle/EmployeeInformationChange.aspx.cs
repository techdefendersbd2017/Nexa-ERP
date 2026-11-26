using Nexa_ERP.Connection;
using Nexa_ERP.HRMPayroll.Common;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.HRMPayroll.EmployeeLifecycle
{
    public partial class EmployeeInformationChange : System.Web.UI.Page
    {
        // Attendance_Reports এর মতোই একই ডাটাবেস কানেকশন
        PayrollDB conn = new PayrollDB();

        readonly List<string> loadErrors = new List<string>();

        const string DateFmt = "dd-MMM-yyyy";   // WinForms DateTimePicker এর Text ফরম্যাট

        // ---------- মডেল (নিচের তালিকার জন্য) ----------
        public class EntryRow
        {
            public string EntryNo { get; set; }
            public string IdNo { get; set; }
            public string Name { get; set; }
            public string Designation { get; set; }
            public string Status { get; set; }
        }

        // TODO: আপনার Login/Session এর key অনুযায়ী বদলান
        long UserCode { get { return HRFilters.UserCode; } }
        string UserName
        {
            get
            {
                object v = Session["User_Name"] ?? Session["UserName"];
                return v == null ? "" : Convert.ToString(v);
            }
        }

        // ================= Page Load =================
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                lblUserName.Text = string.IsNullOrEmpty(UserName) ? "User Name" : UserName;
                txtEffectiveDate.Text = DateTime.Today.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);

                FillCombos();
                LoadDesignations(txtDesignation1.Text, txtDesignation.Text);
                LoadEntries();
            }

            if (loadErrors.Count > 0)
                Toast("Load error: " + string.Join(" | ", loadErrors));
        }

        // ================= ড্রপডাউন ভরা (Form_Load এর নিচের অংশ) =================
        void FillCombos()
        {
            BindCombo(ddlCategory2, "SELECT * FROM TB_Catagory ORDER BY Catagory_Name ASC", "Catagory_Name", "Catagory_Code");
            BindCombo(ddlDepartment, "SELECT * FROM TB_Department ORDER BY Department_Name ASC", "Department_Name", "Department_Code");
            BindCombo(ddlSection, "SELECT * FROM TB_Section ORDER BY Section_Name ASC", "Section_Name", "Section_Code");
            BindCombo(ddlLine, "SELECT * FROM TB_Line ORDER BY Line_Name ASC", "Line_Name", "Line_Code");
        }

        void BindCombo(DropDownList dd, string sql, string textField, string valueField, params SqlParameter[] ps)
        {
            try
            {
                DataTable dt = Query(sql, ps);
                dd.DataSource = dt;
                dd.DataTextField = textField;
                dd.DataValueField = valueField;
                dd.DataBind();
            }
            catch (Exception ex)
            {
                loadErrors.Add(dd.ID + ": " + ex.Message);
            }
        }

        // New Designation: Category অনুযায়ী (comboBox_Designation_New_Click এর লজিক)
        void LoadDesignations(string grade, string tafsil)
        {
            string cat = ddlCategory2.SelectedItem != null ? ddlCategory2.SelectedItem.Text : "";

            if (cat == "Worker" || cat == "Non Management" || cat == "Finishing Iron")
            {
                BindCombo(ddlDesignation,
                    "SELECT * FROM TB_Designation WHERE Grade=@g AND Tafsil_Code=@t ORDER BY Desigation_name ASC",
                    "Desigation_name", "Designation_Code",
                    new SqlParameter("@g", grade ?? ""), new SqlParameter("@t", tafsil ?? ""));
            }
            else
            {
                BindCombo(ddlDesignation,
                    "SELECT * FROM TB_Designation WHERE Grade NOT IN (1,2,3,4,5,6,7) ORDER BY Desigation_name ASC",
                    "Desigation_name", "Designation_Code");
            }
        }

        protected void ddlCategory2_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadDesignations(txtDesignation1.Text, txtDesignation.Text);
        }

        // ================= Employee ID তে Enter (textBox_ID_KeyDown) =================
        protected void txtEmployeeId_TextChanged(object sender, EventArgs e)
        {
            string id = txtEmployeeId.Text.Trim();
            if (id.Length == 0) return;

            try
            {
                DataTable dt = Query("SELECT * FROM Employee_View_By_Code WHERE ID_no=@id",
                    new SqlParameter("@id", id));

                if (dt.Rows.Count == 0)
                {
                    Toast("This ID- '" + id + "' Not Exists In your Database.");
                    ClearFields(false);
                    return;
                }

                DataRow r = dt.Rows[0];
                txtName.Text = S(r, 3);
                txtBanglaName.Text = S(r, 4);
                txtJoiningDate.Text = FormatDate(S(r, 5));

                txtDepartment.Text = S(r, 11);
                txtSection.Text = S(r, 12);
                txtLine.Text = S(r, 13);
                txtDesignationOld.Text = S(r, 14);
                txtCategory.Text = S(r, 15);

                // New এর ডিফল্ট = বর্তমান মান
                SelectByText(ddlDepartment, S(r, 11));
                SelectByText(ddlSection, S(r, 12));
                SelectByText(ddlLine, S(r, 13));
                SelectByText(ddlCategory2, S(r, 15));

                // ===== TB_Designation =====
                DataTable dd = Query("SELECT * FROM TB_Designation WHERE Desigation_name=@n",
                    new SqlParameter("@n", txtDesignationOld.Text));

                if (dd.Rows.Count > 0)
                {
                    txtDesignation1.Text = Convert.ToString(dd.Rows[0]["Grade"]);
                    txtDesignation2.Text = Convert.ToString(dd.Rows[0]["Grade"]);
                    txtDesignation.Text = Convert.ToString(dd.Rows[0]["Tafsil_Code"]);
                }
                else
                {
                    Toast("This ID- '" + id + "' Not Exists In your Database.");
                    txtDesignation1.Text = txtDesignation2.Text = txtDesignation.Text = "";
                }

                LoadDesignations(txtDesignation1.Text, txtDesignation.Text);
                SelectByText(ddlDesignation, S(r, 14));
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message);
            }
        }

        // ================= Add (button2_Click) =================
        protected void btnAdd_Click(object sender, EventArgs e)
        {
            string id = txtEmployeeId.Text.Trim();
            if (id.Length == 0)
            {
                Toast("Employee ID দিন।");
                return;
            }

            DateTime eff;
            if (!DateTime.TryParse(txtEffectiveDate.Text, CultureInfo.InvariantCulture, DateTimeStyles.None, out eff))
            {
                Toast("Effective Date সঠিক নয়।");
                return;
            }

            try
            {
                // একই মাসে একই ID আগে থাকলে বাদ
                DataTable ex = Query(
                    "SELECT * FROM [Employee_Information_Change] WHERE [ID_no]=@id " +
                    "AND DATEPART(MONTH,[Effective_Date])=@m AND DATEPART(YEAR,[Effective_Date])=@y",
                    new SqlParameter("@id", id),
                    new SqlParameter("@m", eff.Month),
                    new SqlParameter("@y", eff.Year));

                if (ex.Rows.Count > 0)
                {
                    Toast("Your Selected ID Already Exists in This Database.");
                    return;
                }

                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();

                    ExecProc(con, "PRo_Employee_Information_Change",
                        Sp("@ID_no", id),
                        Sp("@New_Department", Txt(ddlDepartment)),
                        Sp("@New_Section", Txt(ddlSection)),
                        Sp("@New_Line", Txt(ddlLine)),
                        Sp("@new_Designation", Txt(ddlDesignation)),
                        Sp("@New_Category_Name", Txt(ddlCategory2)),
                        Sp("@Effective_Date", eff.ToString(DateFmt, CultureInfo.InvariantCulture)));
                }

                Toast("Your Operation Successful");
            }
            catch (Exception exn)
            {
                Toast("Error: " + exn.Message);
            }

            LoadEntries();
        }

        // ================= তালিকা থেকে এন্ট্রি বাছা (listView1_SelectedIndexChanged) =================
        protected void rptEntries_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "select") return;

            string autoNo = Convert.ToString(e.CommandArgument);
            txtEntryNo.Text = autoNo;

            try
            {
                DataTable dt = Query("SELECT * FROM View_Employee_Information_Change_New WHERE Auto_no=@a",
                    new SqlParameter("@a", autoNo));

                if (dt.Rows.Count == 0)
                {
                    ClearFields(true);
                    return;
                }

                DataRow r = dt.Rows[0];
                txtEmployeeId.Text = S(r, 0);
                txtName.Text = S(r, 1);
                txtBanglaName.Text = S(r, 2);
                txtJoiningDate.Text = FormatDate(S(r, 3));

                DateTime eff;
                if (DateTime.TryParse(S(r, 4), out eff))
                    txtEffectiveDate.Text = eff.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);

                txtCategory.Text = S(r, 5);
                txtDesignationOld.Text = S(r, 7);
                txtDepartment.Text = S(r, 9);
                txtSection.Text = S(r, 11);
                txtLine.Text = S(r, 13);

                SelectByText(ddlCategory2, S(r, 6));
                SelectByText(ddlDepartment, S(r, 10));
                SelectByText(ddlSection, S(r, 12));
                SelectByText(ddlLine, S(r, 14));

                DataTable dd = Query("SELECT * FROM TB_Designation WHERE Desigation_name=@n",
                    new SqlParameter("@n", txtDesignationOld.Text));
                if (dd.Rows.Count > 0)
                {
                    txtDesignation1.Text = Convert.ToString(dd.Rows[0]["Grade"]);
                    txtDesignation2.Text = Convert.ToString(dd.Rows[0]["Grade"]);
                    txtDesignation.Text = Convert.ToString(dd.Rows[0]["Tafsil_Code"]);
                }

                LoadDesignations(txtDesignation1.Text, txtDesignation.Text);
                SelectByText(ddlDesignation, S(r, 8));
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message);
            }
        }

        // ================= Delete (button3_Click) =================
        protected void btnDelete_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtEntryNo.Text))
            {
                Toast("তালিকা থেকে একটি Entry বাছুন।");
                return;
            }

            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();
                    ExecProc(con, "PRo_Employee_Information_Change_Delete",
                        Sp("@Auto_no", txtEntryNo.Text.Trim()));
                }
                Toast("Your Operation Successful");
                ClearFields(true);
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message);
            }

            LoadEntries();
        }

        // ================= Refresh (button4_Click) =================
        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            ClearFields(true);
            LoadEntries();
        }

        // ================= Open Status এর তালিকা =================
        void LoadEntries()
        {
            var list = new List<EntryRow>();
            try
            {
                DataTable dt = Query("SELECT * FROM View_Employee_Information_Change_New WHERE [Open_Status]='Open'");
                foreach (DataRow r in dt.Rows)
                {
                    list.Add(new EntryRow
                    {
                        EntryNo = S(r, 15),
                        IdNo = S(r, 0),
                        Name = S(r, 1),
                        Designation = S(r, 7),
                        Status = S(r, 16)
                    });
                }
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message);
            }

            rptEntries.DataSource = list;
            rptEntries.DataBind();
            trEmpty.Visible = list.Count == 0;
        }

        // ================= সাহায্যকারী =================
        // string প্যারামিটারের জন্য (HRDb.P শুধু long নেয়)
        static SqlParameter Sp(string name, string value)
        {
            return new SqlParameter(name, SqlDbType.NVarChar, 200) { Value = value ?? "" };
        }

        static void ExecProc(SqlConnection con, string proc, params SqlParameter[] ps)
        {
            using (var cmd = new SqlCommand(proc, con))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandTimeout = 120;
                if (ps != null && ps.Length > 0) cmd.Parameters.AddRange(ps);
                cmd.ExecuteNonQuery();
            }
        }

        DataTable Query(string sql, params SqlParameter[] ps)
        {
            using (SqlConnection con = conn.openConnection())
            {
                if (con.State != ConnectionState.Open) con.Open();
                using (var cmd = new SqlCommand(sql, con))
                {
                    if (ps != null && ps.Length > 0) cmd.Parameters.AddRange(ps);
                    var dt = new DataTable();
                    using (var da = new SqlDataAdapter(cmd)) da.Fill(dt);
                    return dt;
                }
            }
        }

        static string S(DataRow r, int i)
        {
            return i < r.Table.Columns.Count && r[i] != DBNull.Value ? Convert.ToString(r[i]) : "";
        }

        static string Txt(DropDownList dd)
        {
            return dd.SelectedItem != null ? dd.SelectedItem.Text : "";
        }

        static void SelectByText(DropDownList dd, string text)
        {
            ListItem it = dd.Items.FindByText((text ?? "").Trim());
            if (it != null)
            {
                dd.ClearSelection();
                it.Selected = true;
            }
        }

        static string FormatDate(string s)
        {
            DateTime d;
            return DateTime.TryParse(s, out d) ? d.ToString(DateFmt, CultureInfo.InvariantCulture) : s;
        }

        void ClearFields(bool includeId)
        {
            if (includeId) { txtEmployeeId.Text = ""; txtEntryNo.Text = ""; }
            txtName.Text = txtBanglaName.Text = txtJoiningDate.Text = "";
            txtCategory.Text = txtDesignationOld.Text = txtDepartment.Text = txtSection.Text = txtLine.Text = "";
            txtDesignation1.Text = txtDesignation2.Text = txtDesignation.Text = "";
            txtEffectiveDate.Text = DateTime.Today.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);

            foreach (var d in new[] { ddlCategory2, ddlDepartment, ddlSection, ddlLine })
                if (d.Items.Count > 0) d.SelectedIndex = 0;

            LoadDesignations("", "");
        }

        void Toast(string msg)
        {
            string js = "document.addEventListener('DOMContentLoaded',function(){showNotification(" +
                        new JavaScriptSerializer().Serialize(msg) + ");});";
            ClientScript.RegisterStartupScript(GetType(), "toast" + Guid.NewGuid().ToString("N"), js, true);
        }
    }
}