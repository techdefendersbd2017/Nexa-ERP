using Nexa_ERP.Connection;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace Nexa_ERP.Tools
{
    public partial class TableViewer : System.Web.UI.Page
    {
        // ড্রপডাউনে সিলেক্ট করা ডাটাবেস অনুযায়ী আপনার বিদ্যমান কানেকশন ক্লাস ব্যবহার হবে।
        // নতুন ডাটাবেস যোগ করতে: aspx এ নতুন ListItem দিন + নিচের switch এ একটি case যোগ করুন।
        private SqlConnection GetConnection()
        {
            switch (ddlDatabase.SelectedValue)
            {
                case "ACC": return new DatabaseConectionAccounts().openConnection();       // nexa_acc
                case "MER": return new DatabaseConnectionMerchandising().openConnection(); // NexaDBs
                case "PAY": return new PayrollDB().openConnection();                       // Tech_Pay
                case "MST": return new Database_Connection().openConnection();             // NexaMaster
                default: throw new InvalidOperationException("অজানা ডাটাবেস সিলেক্ট করা হয়েছে।");
            }
        }

        // ডাটাবেস বদলালে সেই ডাটাবেসের টেবিল লিস্ট নতুন করে আসবে
        protected void ddlDatabase_SelectedIndexChanged(object sender, EventArgs e)
        {
            lblError.Visible = false;
            gvData.DataSource = null;
            gvData.DataBind();
            lblInfo.Text = "কোনো টেবিল লোড হয়নি";
            LoadTableList();
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadTableList();
            }
        }

        // ডাটাবেসের সব টেবিলের নাম ড্রপডাউনে আনে
        private void LoadTableList()
        {
            try
            {
                using (SqlConnection con = GetConnection())
                {
                    string sql = @"SELECT TABLE_SCHEMA, TABLE_NAME
                                   FROM INFORMATION_SCHEMA.TABLES
                                   WHERE TABLE_TYPE = 'BASE TABLE'
                                   ORDER BY TABLE_SCHEMA, TABLE_NAME";
                    SqlDataAdapter da = new SqlDataAdapter(sql, con);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlTables.Items.Clear();
                    ddlTables.Items.Add(new ListItem("-- Select a table --", ""));
                    foreach (DataRow r in dt.Rows)
                    {
                        string schema = r["TABLE_SCHEMA"].ToString();
                        string table = r["TABLE_NAME"].ToString();
                        ddlTables.Items.Add(new ListItem(schema + "." + table, schema + "|" + table));
                    }
                }
            }
            catch (Exception ex)
            {
                ShowError("টেবিল লিস্ট আনা যায়নি: " + ex.Message);
            }
        }

        protected void btnLoad_Click(object sender, EventArgs e)
        {
            lblError.Visible = false;

            if (string.IsNullOrEmpty(ddlTables.SelectedValue))
            {
                ShowError("আগে একটি টেবিল সিলেক্ট করুন।");
                return;
            }

            string[] parts = ddlTables.SelectedValue.Split('|');
            string schema = parts[0];
            string table = parts[1];

            try
            {
                using (SqlConnection con = GetConnection())
                {
                    // নিরাপত্তা: টেবিলটি সত্যিই ডাটাবেসে আছে কিনা যাচাই (SQL Injection ঠেকাতে)
                    SqlCommand chk = new SqlCommand(
                        @"SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
                          WHERE TABLE_SCHEMA = @s AND TABLE_NAME = @t AND TABLE_TYPE = 'BASE TABLE'", con);
                    chk.Parameters.AddWithValue("@s", schema);
                    chk.Parameters.AddWithValue("@t", table);
                    if ((int)chk.ExecuteScalar() == 0)
                    {
                        ShowError("টেবিলটি পাওয়া যায়নি।");
                        return;
                    }

                    string sql = "SELECT * FROM [" + schema.Replace("]", "]]") + "].[" + table.Replace("]", "]]") + "]";
                    SqlDataAdapter da = new SqlDataAdapter(sql, con);
                    da.SelectCommand.CommandTimeout = 0; // টাইমআউট নেই, যত সময় লাগে লাগুক
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    gvData.DataSource = dt;
                    gvData.DataBind();
                    lblInfo.Text = "Table: " + schema + "." + table + " | Rows shown: " + dt.Rows.Count
                                   + " | Columns: " + dt.Columns.Count;
                }
            }
            catch (Exception ex)
            {
                ShowError("ডাটা লোড ব্যর্থ: " + ex.Message);
            }
        }

        private void ShowError(string msg)
        {
            lblError.Text = Server.HtmlEncode(msg);
            lblError.Visible = true;
        }
    }
}
