using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.OleDb;
using System.Data.SqlClient;
using System.IO;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.HRMPayroll.Payrollinformation
{
    // Desktop ফর্ম (Account_No_Upload.cs) এর ওয়েব রূপ
    public partial class BankAccountNumberUpload : Page
    {
        PayrollDB conn = new PayrollDB();

        const int MaxRows = 5000;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;
            ClearRows();
        }

        // ================= Excel ফাইল পড়া =================
        protected void btnLoad_Click(object sender, EventArgs e)
        {
            if (!fuExcel.HasFile)
            {
                Toast("Please Upload Your File");
                return;
            }

            string ext = Path.GetExtension(fuExcel.FileName).ToLowerInvariant();
            if (ext != ".xls" && ext != ".xlsx")
            {
                Toast("শুধু .xls বা .xlsx ফাইল দিন।");
                return;
            }

            string sheet = (txtSheet.Text ?? "").Trim();
            if (sheet.Length == 0) sheet = "Sheet1";
            if (sheet.IndexOfAny(new[] { '[', ']', '$', '\'', '"', ';' }) >= 0)
            {
                Toast("Sheet Name সঠিক নয়।");
                return;
            }

            string tmp = Path.Combine(Path.GetTempPath(), Guid.NewGuid().ToString("N") + ext);
            try
            {
                fuExcel.SaveAs(tmp);

                string props = ext == ".xlsx" ? "Excel 12.0 Xml;HDR=Yes;IMEX=1" : "Excel 8.0;HDR=Yes;IMEX=1";
                string cs = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=" + tmp + ";Extended Properties=\"" + props + "\";";

                DataTable src = new DataTable();
                using (var oc = new OleDbConnection(cs))
                using (var da = new OleDbDataAdapter("SELECT * FROM [" + sheet + "$]", oc))
                {
                    da.Fill(src);
                }

                if (src.Columns.Count < 6)
                {
                    Toast("Excel এ কমপক্ষে ৬টি কলাম লাগবে: ID No, Name, Designation, Bank, Bank Name, Account No।");
                    return;
                }

                // কলামের ক্রম অনুযায়ী পড়া (Desktop এর গ্রিডের মতোই)
                var dt = new DataTable();
                foreach (string c in new[] { "ID_no", "Name", "Designation", "Bank", "Bank_Name", "Account_No" })
                    dt.Columns.Add(c, typeof(string));

                foreach (DataRow r in src.Rows)
                {
                    string id = Cell(r[0]);
                    if (id.Length == 0) continue;            // ফাঁকা সারি বাদ

                    dt.Rows.Add(id, Cell(r[1]), Cell(r[2]), Cell(r[3]), Cell(r[4]), Cell(r[5]));

                    if (dt.Rows.Count > MaxRows)
                    {
                        Toast("Too many rows (max " + MaxRows + ").");
                        return;
                    }
                }

                rptRows.DataSource = dt;
                rptRows.DataBind();                      // সব সারি Checked (Desktop এর মতো)
                trEmpty.Visible = dt.Rows.Count == 0;
                lblCount.Text = dt.Rows.Count + " Records";
                lblFile.Text = fuExcel.FileName;

                if (dt.Rows.Count == 0) Toast("Excel এ কোনো ডাটা পাওয়া যায়নি।");
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message);
            }
            finally
            {
                try { if (File.Exists(tmp)) File.Delete(tmp); } catch { }
            }
        }

        // ================= Pro_Account_no_Update =================
        protected void btnUpload_Click(object sender, EventArgs e)
        {
            var rows = new List<string[]>();
            int skipped = 0;

            foreach (RepeaterItem it in rptRows.Items)
            {
                var chk = it.FindControl("chk") as CheckBox;
                if (chk == null || !chk.Checked) continue;

                string idText = ((HiddenField)it.FindControl("hfId")).Value;
                long id;
                if (!long.TryParse(idText, out id)) { skipped++; continue; }

                rows.Add(new[]
                {
                    id.ToString(),
                    ((HiddenField)it.FindControl("hfBank")).Value,
                    ((HiddenField)it.FindControl("hfBankName")).Value,
                    ((HiddenField)it.FindControl("hfAcNo")).Value
                });
            }

            if (rows.Count == 0)
            {
                Toast("কমপক্ষে একটি সারি নির্বাচন করুন।");
                return;
            }

            try
            {
                using (SqlConnection con = conn.openConnection())
                {
                    if (con.State != ConnectionState.Open) con.Open();

                    // সব একসাথে সেভ হবে, মাঝপথে ভুল হলে কিছুই সেভ হবে না
                    using (SqlTransaction tx = con.BeginTransaction())
                    {
                        foreach (string[] r in rows)
                        {
                            using (var cmd = new SqlCommand("Pro_Account_no_Update", con, tx))
                            {
                                cmd.CommandType = CommandType.StoredProcedure;
                                cmd.Parameters.Add("@id_no", SqlDbType.BigInt).Value = long.Parse(r[0]);
                                cmd.Parameters.Add("@bank_holder", SqlDbType.VarChar).Value = r[1];
                                cmd.Parameters.Add("@Bank_Name", SqlDbType.VarChar).Value = r[2];
                                cmd.Parameters.Add("@A_C_No", SqlDbType.VarChar).Value = r[3];
                                cmd.ExecuteNonQuery();
                            }
                        }
                        tx.Commit();
                    }
                }
            }
            catch (Exception ex)
            {
                Toast("Error: " + ex.Message);
                return;
            }

            string msg = "Upload Successful (" + rows.Count + ")";
            if (skipped > 0) msg += " — ভুল ID এর " + skipped + "টি সারি বাদ গেছে।";
            Toast(msg);
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ClearRows();
            Toast("Cleared.");
        }

        // ================= সাহায্যকারী =================
        void ClearRows()
        {
            rptRows.DataSource = null;
            rptRows.DataBind();
            trEmpty.Visible = true;
            lblCount.Text = "0 Records";
            lblFile.Text = "";
        }

        // Excel এর সংখ্যা (যেমন 1.23E+15) যেন বিজ্ঞানসম্মত রূপে না আসে
        static string Cell(object v)
        {
            if (v == null || v == DBNull.Value) return "";
            if (v is double) return ((double)v).ToString("0.##########", System.Globalization.CultureInfo.InvariantCulture);
            return Convert.ToString(v).Trim();
        }

        void Toast(string msg)
        {
            string js = "document.addEventListener('DOMContentLoaded',function(){showNotification(" +
                        new JavaScriptSerializer().Serialize(msg) + ");});";
            ClientScript.RegisterStartupScript(GetType(), "toast" + Guid.NewGuid().ToString("N"), js, true);
        }
    }
}
