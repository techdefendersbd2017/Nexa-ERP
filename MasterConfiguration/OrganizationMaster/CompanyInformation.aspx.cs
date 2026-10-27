using Nexa_ERP.Connection;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace Nexa_ERP.HRMPayroll
{
    public partial class CompanyInformation : System.Web.UI.Page
    {
        PayrollDB conn = new PayrollDB();

        // PayrollDB এর openConnection() একটি খোলা SqlConnection ফেরত দেয় ধরে নেওয়া হয়েছে।
        // মেথডের নাম আলাদা হলে শুধু এখানে বদলান।
        private SqlConnection GetCon()
        {
            SqlConnection c = conn.openConnection();
            if (c.State != ConnectionState.Open) c.Open();
            return c;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadGrid();
            }
        }

        // ---------- Grid ----------
        // TB_Company এর কলাম ক্রম:
        // 0 Code, 1 Name, 2 Short, 3 Phone, 4 Email, 5 Address, 6 Logo,
        // 7 Bangla, 8 BanglaAddress, 9 OtDeductOrg, 10 OtDeductComp,
        // 11 CompOtStart, 12 EarlyOutCount, 13 OutPunchStart
        private void LoadGrid()
        {
            DataTable src = new DataTable();
            using (SqlConnection con = GetCon())
            using (SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM TB_Company", con))
            {
                da.Fill(src);
            }

            DataTable dt = new DataTable();
            dt.Columns.Add("Company_Code", typeof(string));
            dt.Columns.Add("Company_Name", typeof(string));
            dt.Columns.Add("Short_Name", typeof(string));
            dt.Columns.Add("Phone", typeof(string));
            dt.Columns.Add("EMail", typeof(string));
            dt.Columns.Add("Logo", typeof(byte[]));

            foreach (DataRow r in src.Rows)
            {
                dt.Rows.Add(
                    r[0].ToString(), r[1].ToString(), r[2].ToString(),
                    r[3].ToString(), r[4].ToString(),
                    r[6] == DBNull.Value ? (object)DBNull.Value : r[6]);
            }

            gvCompany.DataSource = dt;
            gvCompany.DataBind();
        }

        // ---------- Select ----------
        protected void gvCompany_SelectedIndexChanged(object sender, EventArgs e)
        {
            string code = gvCompany.SelectedDataKey.Value.ToString();

            using (SqlConnection con = GetCon())
            using (SqlCommand cmd = new SqlCommand("SELECT * FROM TB_Company WHERE Company_Code=@code", con))
            {
                cmd.Parameters.AddWithValue("@code", code);
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    if (r.Read())
                    {
                        txtCompanyCode.Text = r[0].ToString();
                        txtCompanyName.Text = r[1].ToString();
                        txtShortName.Text = r[2].ToString();
                        txtPhone.Text = r[3].ToString();
                        txtEmail.Text = r[4].ToString();
                        txtAddress.Text = r[5].ToString();
                        txtCompanyBangla.Text = r[7].ToString();
                        txtBanglaAddress.Text = r[8].ToString();
                        txtOtDeductOrg.Text = r[9].ToString();
                        txtOtDeductComp.Text = r[10].ToString();
                        txtExtOtStart.Text = r[11].ToString();
                        txtEarlyDeduct.Text = r[12].ToString();
                        txtOutTimeStart.Text = r[13].ToString();

                        if (r[6] != DBNull.Value)
                            imgLogoPreview.ImageUrl = "data:image/png;base64," + Convert.ToBase64String((byte[])r[6]);
                        else
                            imgLogoPreview.ImageUrl = "~/Images/no-image.png";
                    }
                }
            }
        }

        // ---------- Save / Update ----------
        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            try
            {
                bool isNew = string.IsNullOrWhiteSpace(txtCompanyCode.Text) || txtCompanyCode.Text == "0";

                using (SqlConnection con = GetCon())
                {
                    // 1) মূল তথ্য সেভ (Pro_Company SP)
                    using (SqlCommand cmd = new SqlCommand("Pro_Company", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@Company_Code", txtCompanyCode.Text.Trim());
                        cmd.Parameters.AddWithValue("@Company_Name", txtCompanyName.Text.Trim());
                        cmd.Parameters.AddWithValue("@Short_Name", txtShortName.Text.Trim());
                        cmd.Parameters.AddWithValue("@phone", txtPhone.Text.Trim());
                        cmd.Parameters.AddWithValue("@EMail", txtEmail.Text.Trim());
                        cmd.Parameters.AddWithValue("@Address", txtAddress.Text.Trim());
                        cmd.Parameters.AddWithValue("@Conmany_Bangla", txtCompanyBangla.Text.Trim());
                        cmd.Parameters.AddWithValue("@Bangla_Address", txtBanglaAddress.Text.Trim());
                        cmd.Parameters.AddWithValue("@Deduct_OT_Org", txtOtDeductOrg.Text.Trim());
                        cmd.Parameters.AddWithValue("@Deduct_OT_Comp", txtOtDeductComp.Text.Trim());
                        cmd.Parameters.AddWithValue("@Comp_OT_Start", txtExtOtStart.Text.Trim());
                        cmd.Parameters.AddWithValue("@Early_Out_Count", txtEarlyDeduct.Text.Trim());
                        cmd.Parameters.AddWithValue("@Out_Punch_Start", txtOutTimeStart.Text.Trim());
                        cmd.ExecuteNonQuery();
                    }

                    // 2) Company Code বের করা (নতুন হলে নাম + শর্ট নেম দিয়ে)
                    string code = txtCompanyCode.Text.Trim();
                    if (isNew)
                    {
                        using (SqlCommand cmd = new SqlCommand(
                            "SELECT TOP 1 Company_Code FROM TB_Company WHERE Company_Name=@n AND Short_Name=@s", con))
                        {
                            cmd.Parameters.AddWithValue("@n", txtCompanyName.Text.Trim());
                            cmd.Parameters.AddWithValue("@s", txtShortName.Text.Trim());
                            object o = cmd.ExecuteScalar();
                            code = o == null ? "" : o.ToString();
                        }
                    }

                    // 3) নতুন লোগো দিলে আপডেট
                    if (fuLogo.HasFile && !string.IsNullOrEmpty(code))
                    {
                        using (SqlCommand cmd = new SqlCommand(
                            "UPDATE TB_Company SET Company_Logo=@photo WHERE Company_Code=@code", con))
                        {
                            cmd.Parameters.Add("@photo", SqlDbType.VarBinary, -1).Value = fuLogo.FileBytes;
                            cmd.Parameters.AddWithValue("@code", code);
                            cmd.ExecuteNonQuery();
                        }
                    }

                    txtCompanyCode.Text = code;
                }

                ShowMessage(isNew ? "Save Successful" : "Update Successful", true);
                LoadGrid();
            }
            catch (Exception ex)
            {
                ShowMessage("Error: " + ex.Message, false);
            }
        }

        // ---------- Clear ----------
        protected void btnClear_Click(object sender, EventArgs e)
        {
            txtCompanyCode.Text = "0";
            txtCompanyName.Text = string.Empty;
            txtCompanyBangla.Text = string.Empty;
            txtShortName.Text = string.Empty;
            txtPhone.Text = string.Empty;
            txtEmail.Text = string.Empty;
            txtAddress.Text = string.Empty;
            txtBanglaAddress.Text = string.Empty;
            txtOtDeductOrg.Text = string.Empty;
            txtOtDeductComp.Text = string.Empty;
            txtExtOtStart.Text = string.Empty;
            txtEarlyDeduct.Text = string.Empty;
            txtOutTimeStart.Text = string.Empty;
            imgLogoPreview.ImageUrl = "~/Images/no-image.png";
            pnlMsg.Visible = false;
            gvCompany.SelectedIndex = -1;
            LoadGrid();
        }

        private void ShowMessage(string msg, bool success)
        {
            lblMsg.Text = Server.HtmlEncode(msg);
            pnlMsg.CssClass = success ? "alert alert-success py-2" : "alert alert-danger py-2";
            pnlMsg.Visible = true;
        }
    }
}
