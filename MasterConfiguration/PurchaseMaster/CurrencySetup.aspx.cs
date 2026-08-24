using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.MasterConfiguration.PurchaseMaster
{
    public partial class CurrencySetup : System.Web.UI.Page
    {
        SqlConnection con;
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();
        SqlCommand cmd;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadCurrencyList();
            }
        }

        // কারেন্সি লিস্ট গ্রিডভিউতে লোড করার জন্য
        private void LoadCurrencyList(string searchKeyword = "")
        {
            try
            {
                con = conn.openConnection();
                string query = "SELECT CurrencyID, CurrencyName, CurrencyCode, Symbol, ExchangeRate, Status FROM CurrencyMaster";

                if (!string.IsNullOrEmpty(searchKeyword))
                {
                    query += " WHERE CurrencyName LIKE @Search OR CurrencyCode LIKE @Search";
                }

                query += " ORDER BY CurrencyID DESC";

                SqlCommand cmdGrid = new SqlCommand(query, con);
                if (!string.IsNullOrEmpty(searchKeyword))
                {
                    cmdGrid.Parameters.AddWithValue("@Search", "%" + searchKeyword + "%");
                }

                SqlDataAdapter da = new SqlDataAdapter(cmdGrid);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvCurrency.DataSource = dt;
                gvCurrency.DataBind();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "\\'") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) { con.Close(); }
            }
        }

        // ফর্মের ইনপুট ফিল্ডগুলো পরিষ্কার করার জন্য
        private void clearform()
        {
            txtCurrencyID.Text = string.Empty;
            txtCurrencyName.Text = string.Empty;
            txtCurrencyCode.Text = string.Empty;
            txtSymbol.Text = string.Empty;
            txtExchangeRate.Text = string.Empty;

            if (ddlStatus != null && ddlStatus.Items.Count > 0)
                ddlStatus.SelectedValue = "Active";

            btnSave.Text = "Save";
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            clearform();
        }

        // কারেন্সি সেভ অথবা আপডেট করার জন্য
        protected void btnSave_Click(object sender, EventArgs e)
        {
            // ASP.NET Validators (RequiredField / RegEx / Compare) আগেই ক্লায়েন্ট ও সার্ভার সাইডে চেক করে দিচ্ছে,
            // তারপরও IsValid ডাবল-চেক করা হচ্ছে যাতে JS বন্ধ থাকলেও সুরক্ষা থাকে।
            if (!Page.IsValid)
            {
                return;
            }

            string currencyCode = txtCurrencyCode.Text.Trim().ToUpper();

            // Exchange Rate নিরাপদে পার্স করা - ভুল ইনপুটে যেন এক্সসেপশন না হয়ে সুন্দর মেসেজ দেখায়
            decimal exchangeRate = 1.0000m;
            if (!string.IsNullOrEmpty(txtExchangeRate.Text.Trim()))
            {
                if (!decimal.TryParse(txtExchangeRate.Text.Trim(), out exchangeRate) || exchangeRate <= 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('সঠিক Exchange Rate দিন (0 এর বেশি সংখ্যা)!');", true);
                    return;
                }
            }

            // Currency ID (যদি এডিট মোডে থাকে) নিরাপদে পার্স করা
            int? currencyId = null;
            if (!string.IsNullOrEmpty(txtCurrencyID.Text.Trim()))
            {
                if (!int.TryParse(txtCurrencyID.Text.Trim(), out int parsedId))
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Currency ID সঠিক নয়!');", true);
                    return;
                }
                currencyId = parsedId;
            }

            try
            {
                con = conn.openConnection();
                using (SqlCommand cmdSave = new SqlCommand("sp_Currency_SaveUpdate", con))
                {
                    cmdSave.CommandType = CommandType.StoredProcedure;

                    cmdSave.Parameters.AddWithValue("@CurrencyID", currencyId.HasValue ? (object)currencyId.Value : DBNull.Value);
                    cmdSave.Parameters.AddWithValue("@CurrencyName", txtCurrencyName.Text.Trim());
                    cmdSave.Parameters.AddWithValue("@CurrencyCode", currencyCode);
                    cmdSave.Parameters.AddWithValue("@Symbol", string.IsNullOrEmpty(txtSymbol.Text.Trim()) ? (object)DBNull.Value : txtSymbol.Text.Trim());
                    cmdSave.Parameters.AddWithValue("@ExchangeRate", exchangeRate);
                    cmdSave.Parameters.AddWithValue("@Status", ddlStatus.SelectedValue);

                    using (SqlDataReader rdr = cmdSave.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            string message = rdr["Message"].ToString();
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + message.Replace("'", "\\'") + "');", true);
                        }
                    }
                }
                clearform();
                LoadCurrencyList();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('Error: " + ex.Message.Replace("'", "\\'") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) { con.Close(); }
            }
        }

        // গ্রিডভিউ থেকে এডিট করার জন্য সিলেকশন (ডেটাবেজ থেকে সরাসরি ডেটা এনে টেক্সটবক্সে বসানো হয়েছে)
        protected void gvCurrency_SelectedIndexChanged(object sender, EventArgs e)
        {
            txtCurrencyID.Text = gvCurrency.SelectedDataKey.Value.ToString();
            try
            {
                string sql = "SELECT CurrencyID, CurrencyName, CurrencyCode, Symbol, ExchangeRate, Status FROM CurrencyMaster WHERE CurrencyID = @CurrencyID";
                con = conn.openConnection();
                cmd = new SqlCommand(sql, con);
                cmd.Parameters.AddWithValue("@CurrencyID", txtCurrencyID.Text);

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.HasRows)
                    {
                        while (reader.Read())
                        {
                            txtCurrencyName.Text = reader["CurrencyName"].ToString();
                            txtCurrencyCode.Text = reader["CurrencyCode"].ToString();
                            txtSymbol.Text = reader["Symbol"].ToString();
                            txtExchangeRate.Text = reader["ExchangeRate"].ToString();
                            ddlStatus.SelectedValue = reader["Status"].ToString();
                        }
                        btnSave.Text = "Update";
                    }
                    else
                    {
                        clearform();
                    }
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "\\'") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) { con.Close(); }
            }
        }

        protected void txtSearch_TextChanged(object sender, EventArgs e)
        {
            LoadCurrencyList(txtSearch.Text.Trim());
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadCurrencyList(txtSearch.Text.Trim());
        }
    }
}