using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.MasterConfiguration.OrganizationMaster
{
    public partial class HRBranchInformation : System.Web.UI.Page
    {
        PayrollDB conn = new PayrollDB();

        // PayrollDB এর openConnection() একটি খোলা SqlConnection ফেরত দেয় ধরে নেওয়া হয়েছে।
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
                LoadCompanies();
                LoadGrid();
            }
        }

        // ---------- Company Dropdown ----------
        private void LoadCompanies()
        {
            DataTable dt = new DataTable();
            using (SqlConnection con = GetCon())
            using (SqlDataAdapter da = new SqlDataAdapter("SELECT Company_Code, Company_Name FROM TB_Company", con))
            {
                da.Fill(dt);
            }

            ddlCompany.DataSource = dt;
            ddlCompany.DataTextField = "Company_Name";
            ddlCompany.DataValueField = "Company_Code";
            ddlCompany.DataBind();
        }

        // ---------- Grid ----------
        // TB_Branch কলাম ক্রম (WinForm অনুযায়ী):
        // 0 Code, 1 Name, 2 Short, 3 Phone, 4 Email, 5 Address, 6 Bangla Name, 7 Bangla Address
        // লোগো কলামের নাম: Branch_logo
        private void LoadGrid()
        {
            DataTable src = new DataTable();
            using (SqlConnection con = GetCon())
            using (SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM TB_Branch", con))
            {
                da.Fill(src);
            }

            bool hasLogo = src.Columns.Contains("Branch_logo");

            DataTable dt = new DataTable();
            dt.Columns.Add("Branch_Code", typeof(string));
            dt.Columns.Add("Branch_Name", typeof(string));
            dt.Columns.Add("Short_Name", typeof(string));
            dt.Columns.Add("Phone", typeof(string));
            dt.Columns.Add("EMail", typeof(string));
            dt.Columns.Add("Logo", typeof(byte[]));

            foreach (DataRow r in src.Rows)
            {
                object logo = (hasLogo && r["Branch_logo"] != DBNull.Value) ? r["Branch_logo"] : DBNull.Value;
                dt.Rows.Add(
                    r[0].ToString(), r[1].ToString(), r[2].ToString(),
                    r[3].ToString(), r[4].ToString(), logo);
            }

            gvBranch.DataSource = dt;
            gvBranch.DataBind();
        }

        // ---------- Select ----------
        protected void gvBranch_SelectedIndexChanged(object sender, EventArgs e)
        {
            string code = gvBranch.SelectedDataKey.Value.ToString();

            using (SqlConnection con = GetCon())
            using (SqlCommand cmd = new SqlCommand("SELECT * FROM TB_Branch WHERE Branch_Code=@code", con))
            {
                cmd.Parameters.AddWithValue("@code", code);
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    if (r.Read())
                    {
                        txtBranchCode.Text = r[0].ToString();
                        txtBranchName.Text = r[1].ToString();
                        txtShortName.Text = r[2].ToString();
                        txtPhone.Text = r[3].ToString();
                        txtEmail.Text = r[4].ToString();
                        txtAddress.Text = r[5].ToString();
                        txtBanglaName.Text = r[6].ToString();
                        txtBanglaAddress.Text = r[7].ToString();

                        // Company ও Logo কলাম নাম দিয়ে খোঁজা হচ্ছে
                        for (int i = 0; i < r.FieldCount; i++)
                        {
                            string col = r.GetName(i);

                            if (col.Equals("Company_Code", StringComparison.OrdinalIgnoreCase) && !r.IsDBNull(i))
                            {
                                ListItem li = ddlCompany.Items.FindByValue(r[i].ToString());
                                if (li != null)
                                {
                                    ddlCompany.ClearSelection();
                                    li.Selected = true;
                                }
                            }

                            if (col.Equals("Branch_logo", StringComparison.OrdinalIgnoreCase))
                            {
                                imgLogoPreview.ImageUrl = r.IsDBNull(i)
                                    ? "~/Images/no-image.png"
                                    : "data:image/png;base64," + Convert.ToBase64String((byte[])r[i]);
                            }
                        }
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
                bool isNew = string.IsNullOrWhiteSpace(txtBranchCode.Text) || txtBranchCode.Text == "0";

                using (SqlConnection con = GetCon())
                {
                    // 1) মূল তথ্য সেভ (Pro_Branch SP)
                    using (SqlCommand cmd = new SqlCommand("Pro_Branch", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@Branch_Code", txtBranchCode.Text.Trim());
                        cmd.Parameters.AddWithValue("@Branch_Name", txtBranchName.Text.Trim());
                        cmd.Parameters.AddWithValue("@Short_Name", txtShortName.Text.Trim());
                        cmd.Parameters.AddWithValue("@phone", txtPhone.Text.Trim());
                        cmd.Parameters.AddWithValue("@EMail", txtEmail.Text.Trim());
                        cmd.Parameters.AddWithValue("@Address", txtAddress.Text.Trim());
                        cmd.Parameters.AddWithValue("@Company_Code", ddlCompany.SelectedValue);
                        cmd.Parameters.AddWithValue("@Branch_Bangla", txtBanglaName.Text.Trim());
                        cmd.Parameters.AddWithValue("@Bangla_Address_Branch", txtBanglaAddress.Text.Trim());
                        cmd.ExecuteNonQuery();
                    }

                    // 2) Branch Code বের করা (নতুন হলে নাম দিয়ে)
                    string code = txtBranchCode.Text.Trim();
                    if (isNew)
                    {
                        using (SqlCommand cmd = new SqlCommand(
                            "SELECT TOP 1 Branch_Code FROM TB_Branch WHERE Branch_Name=@n", con))
                        {
                            cmd.Parameters.AddWithValue("@n", txtBranchName.Text.Trim());
                            object o = cmd.ExecuteScalar();
                            code = o == null ? "" : o.ToString();
                        }
                    }

                    // 3) নতুন লোগো দিলে আপডেট
                    if (fuLogo.HasFile && !string.IsNullOrEmpty(code))
                    {
                        using (SqlCommand cmd = new SqlCommand(
                            "UPDATE TB_Branch SET Branch_logo=@photo WHERE Branch_Code=@code", con))
                        {
                            cmd.Parameters.Add("@photo", SqlDbType.VarBinary, -1).Value = fuLogo.FileBytes;
                            cmd.Parameters.AddWithValue("@code", code);
                            cmd.ExecuteNonQuery();
                        }
                    }

                    txtBranchCode.Text = code;
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
            txtBranchCode.Text = "0";
            ddlCompany.ClearSelection();
            ddlCompany.SelectedIndex = 0;
            txtBranchName.Text = string.Empty;
            txtBanglaName.Text = string.Empty;
            txtShortName.Text = string.Empty;
            txtPhone.Text = string.Empty;
            txtEmail.Text = string.Empty;
            txtAddress.Text = string.Empty;
            txtBanglaAddress.Text = string.Empty;
            imgLogoPreview.ImageUrl = "~/Images/no-image.png";
            pnlMsg.Visible = false;
            gvBranch.SelectedIndex = -1;
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
