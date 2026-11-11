using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Web.UI.WebControls;

namespace Nexa_ERP.Tools
{
    public partial class TableViewer : System.Web.UI.Page
    {
        private const int PreviewLimit = 200; // Preview এ সর্বোচ্চ কতটি সেল দেখাবে

        private class CellChange { public string Column; public string Old; public string New; }
        private class RowChange
        {
            public string Label;      // Preview এ দেখানোর জন্য (id=5 / Row #3)
            public object[] Pk;       // Primary key মান
            public List<CellChange> Cells = new List<CellChange>();
        }

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
            pnlGrid.Visible = false;
            pnlConvert.Visible = false;
            pnlPreview.Visible = false;
            ViewState["LoadedTable"] = null;
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

        // ---------------------------------------------------------------- Load Data

        protected void btnLoad_Click(object sender, EventArgs e)
        {
            lblError.Visible = false;
            lblMsg.Text = "";
            lblWarn.Text = "";
            pnlPreview.Visible = false;

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
                    if (!TableExists(con, schema, table))
                    {
                        ShowError("টেবিলটি পাওয়া যায়নি।");
                        return;
                    }

                    BindMainGrid(con, schema, table);
                    LoadColumnList(con, schema, table);
                    ViewState["LoadedTable"] = schema + "|" + table; // Preview/Update এই টেবিলেই কাজ করবে
                }
            }
            catch (Exception ex)
            {
                ShowError("ডাটা লোড ব্যর্থ: " + ex.Message);
            }
        }

        // নিরাপত্তা: টেবিলটি সত্যিই ডাটাবেসে আছে কিনা যাচাই (SQL Injection ঠেকাতে)
        private bool TableExists(SqlConnection con, string schema, string table)
        {
            SqlCommand chk = new SqlCommand(
                @"SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
                  WHERE TABLE_SCHEMA = @s AND TABLE_NAME = @t AND TABLE_TYPE = 'BASE TABLE'", con);
            chk.Parameters.AddWithValue("@s", schema);
            chk.Parameters.AddWithValue("@t", table);
            return (int)chk.ExecuteScalar() > 0;
        }

        private static string Esc(string s) { return s.Replace("]", "]]"); }
        private static string QName(string schema, string table) { return "[" + Esc(schema) + "].[" + Esc(table) + "]"; }

        private DataTable ReadTable(SqlConnection con, string schema, string table)
        {
            SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM " + QName(schema, table), con);
            da.SelectCommand.CommandTimeout = 0; // টাইমআউট নেই, যত সময় লাগে লাগুক
            DataTable dt = new DataTable();
            da.Fill(dt);
            return dt;
        }

        private void BindMainGrid(SqlConnection con, string schema, string table)
        {
            DataTable dt = ReadTable(con, schema, table);
            gvData.DataSource = dt;
            gvData.DataBind();
            pnlGrid.Visible = true;
            lblInfo.Text = "Table: " + schema + "." + table + " | Rows shown: " + dt.Rows.Count
                           + " | Columns: " + dt.Columns.Count;
        }

        // ---------------------------------------------------------------- কলাম / Key তথ্য

        private static bool IsTextType(string t)
        {
            t = t.ToLowerInvariant();
            return t == "varchar" || t == "nvarchar" || t == "char" || t == "nchar" || t == "text" || t == "ntext";
        }

        // ইউনিকোড বাংলা রাখতে পারে শুধু n-টাইপ কলাম
        private static bool IsUnicodeType(string t)
        {
            t = t.ToLowerInvariant();
            return t == "nvarchar" || t == "nchar" || t == "ntext";
        }

        private Dictionary<string, string> GetColumnTypes(SqlConnection con, string schema, string table)
        {
            Dictionary<string, string> d = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
            SqlCommand cmd = new SqlCommand(
                @"SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS
                  WHERE TABLE_SCHEMA = @s AND TABLE_NAME = @t ORDER BY ORDINAL_POSITION", con);
            cmd.Parameters.AddWithValue("@s", schema);
            cmd.Parameters.AddWithValue("@t", table);
            using (SqlDataReader rd = cmd.ExecuteReader())
            {
                while (rd.Read()) d[rd.GetString(0)] = rd.GetString(1);
            }
            return d;
        }

        private List<string> GetPrimaryKey(SqlConnection con, string schema, string table)
        {
            List<string> pk = new List<string>();
            SqlCommand cmd = new SqlCommand(
                @"SELECT k.COLUMN_NAME
                  FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
                  JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE k
                    ON tc.CONSTRAINT_NAME = k.CONSTRAINT_NAME
                   AND tc.TABLE_SCHEMA = k.TABLE_SCHEMA
                   AND tc.TABLE_NAME = k.TABLE_NAME
                  WHERE tc.CONSTRAINT_TYPE = 'PRIMARY KEY' AND tc.TABLE_SCHEMA = @s AND tc.TABLE_NAME = @t
                  ORDER BY k.ORDINAL_POSITION", con);
            cmd.Parameters.AddWithValue("@s", schema);
            cmd.Parameters.AddWithValue("@t", table);
            using (SqlDataReader rd = cmd.ExecuteReader())
            {
                while (rd.Read()) pk.Add(rd.GetString(0));
            }
            return pk;
        }

        // Primary Key থাকলে সেটাই; না থাকলে টেবিলের প্রথম কলামকে Key ধরা হয়
        private List<string> GetKeyColumns(SqlConnection con, string schema, string table, out bool isFallback)
        {
            isFallback = false;
            List<string> pk = GetPrimaryKey(con, schema, table);
            if (pk.Count > 0) return pk;

            SqlCommand cmd = new SqlCommand(
                @"SELECT TOP 1 COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
                  WHERE TABLE_SCHEMA = @s AND TABLE_NAME = @t ORDER BY ORDINAL_POSITION", con);
            cmd.Parameters.AddWithValue("@s", schema);
            cmd.Parameters.AddWithValue("@t", table);
            object first = cmd.ExecuteScalar();
            if (first != null && first != DBNull.Value)
            {
                pk.Add(first.ToString());
                isFallback = true;
            }
            return pk;
        }

        // টেক্সট টাইপের কলামগুলো চেকবক্সে দেখায়
        private void LoadColumnList(SqlConnection con, string schema, string table)
        {
            cblColumns.Items.Clear();
            Dictionary<string, string> types = GetColumnTypes(con, schema, table);
            foreach (KeyValuePair<string, string> kv in types)
            {
                if (!IsTextType(kv.Value)) continue;
                string note = IsUnicodeType(kv.Value) ? "" : " ⚠";
                cblColumns.Items.Add(new ListItem(kv.Key + " (" + kv.Value + ")" + note, kv.Key));
            }

            bool fallback;
            List<string> pk = GetKeyColumns(con, schema, table, out fallback);
            lblPkInfo.Text = (pk.Count == 0 ? "কোনো কলাম পাওয়া যায়নি।"
                : fallback ? "Primary Key নেই — প্রথম কলাম (" + pk[0] + ") কে Key ধরা হবে (ডুপ্লিকেট/NULL থাকলে Update হবে না)"
                           : "Primary Key: " + string.Join(", ", pk))
                + "   |   ⚠ চিহ্নিত (varchar/char/text) কলামে ইউনিকোড বাংলা সেভ হয় না — আগে nvarchar এ বদলাতে হবে।";

            pnlConvert.Visible = cblColumns.Items.Count > 0;
        }

        // ---------------------------------------------------------------- Preview / Update

        protected void btnPreview_Click(object sender, EventArgs e) { RunConvert(false); }
        protected void btnUpdate_Click(object sender, EventArgs e) { RunConvert(true); }

        private void RunConvert(bool apply)
        {
            lblError.Visible = false;
            lblMsg.Text = "";
            lblWarn.Text = "";
            pnlPreview.Visible = false;
            pnlGrid.Visible = false;

            string loaded = ViewState["LoadedTable"] as string;
            if (string.IsNullOrEmpty(loaded))
            {
                ShowError("আগে একটি টেবিল Load করুন।");
                return;
            }
            string[] parts = loaded.Split('|');
            string schema = parts[0];
            string table = parts[1];

            List<string> cols = cblColumns.Items.Cast<ListItem>().Where(i => i.Selected).Select(i => i.Value).ToList();
            if (cols.Count == 0)
            {
                ShowError("কমপক্ষে একটি কলাম সিলেক্ট করুন।");
                return;
            }

            try
            {
                using (SqlConnection con = GetConnection())
                {
                    if (!TableExists(con, schema, table)) { ShowError("টেবিলটি পাওয়া যায়নি।"); return; }

                    Dictionary<string, string> types = GetColumnTypes(con, schema, table);
                    bool keyFallback;
                    List<string> pk = GetKeyColumns(con, schema, table, out keyFallback);

                    foreach (string c in cols)
                        if (!types.ContainsKey(c)) { ShowError("কলাম পাওয়া যায়নি: " + c); return; }

                    if (apply)
                    {
                        if (pk.Count == 0) { ShowError("Key কলাম নির্ধারণ করা যায়নি, তাই Update করা যাবে না।"); return; }
                        if (cols.Any(c => pk.Contains(c, StringComparer.OrdinalIgnoreCase)))
                        { ShowError("Key কলাম (" + string.Join(", ", pk) + ") কনভার্ট করা যাবে না।"); return; }

                        if (keyFallback)
                        {
                            string kt = types[pk[0]].ToLowerInvariant();
                            if (kt == "text" || kt == "ntext" || kt == "image" || kt == "xml")
                            { ShowError("প্রথম কলাম (" + pk[0] + ") " + kt + " টাইপের, একে Key হিসেবে ব্যবহার করা যায় না।"); return; }
                        }

                        List<string> bad = cols.Where(c => !IsUnicodeType(types[c])).ToList();
                        if (bad.Count > 0)
                        {
                            ShowError("এই কলামগুলো varchar/char/text — এগুলোতে ইউনিকোড বাংলা সেভ হলে '?' হয়ে যাবে: "
                                      + string.Join(", ", bad) + "। আগে কলামটি nvarchar করুন।");
                            return;
                        }
                    }

                    DataTable dt = ReadTable(con, schema, table);

                    if (apply && keyFallback)
                    {
                        // প্রথম কলাম আসলেই ইউনিক কিনা — নইলে একই মানের অন্য row ও বদলে যেত
                        HashSet<string> seen = new HashSet<string>(StringComparer.OrdinalIgnoreCase); // SQL এর collation সাধারণত case-insensitive
                        foreach (DataRow r in dt.Rows)
                        {
                            object kv = r[pk[0]];
                            if (kv == DBNull.Value) { ShowError("প্রথম কলাম (" + pk[0] + ") এ NULL মান আছে, তাই Key হিসেবে নিরাপদ নয়। Update হয়নি।"); return; }
                            if (!seen.Add(System.Convert.ToString(kv)))
                            { ShowError("প্রথম কলাম (" + pk[0] + ") এ ডুপ্লিকেট মান আছে (" + kv + "), তাই Key হিসেবে নিরাপদ নয়। Update হয়নি।"); return; }
                        }
                    }

                    Dictionary<char, string> unmapped = new Dictionary<char, string>();
                    List<RowChange> changes = BuildChanges(dt, cols, pk, unmapped);

                    int cellCount = changes.Sum(r => r.Cells.Count);

                    if (!apply)
                    {
                        ShowPreview(changes, cellCount, unmapped);
                        return;
                    }

                    if (changes.Count == 0)
                    {
                        lblMsg.Text = "কনভার্ট করার মতো কোনো ডাটা পাওয়া যায়নি (সব ডাটা হয়তো আগেই ইউনিকোড)।";
                        BindMainGrid(con, schema, table);
                        return;
                    }

                    if (unmapped.Count > 0 && !chkForce.Checked)
                    {
                        ShowPreview(changes, cellCount, unmapped);
                        ShowError("কিছু চিহ্নের ম্যাপিং নেই, তাই Update হয়নি। ম্যাপিং যোগ করুন, অথবা 'অরূপান্তরিত চিহ্ন থাকলেও Update করুন' টিক দিয়ে আবার চালান।");
                        return;
                    }

                    int affected = ApplyChanges(con, schema, table, pk, changes);
                    BindMainGrid(con, schema, table);
                    lblMsg.Text = Server.HtmlEncode("সফল: " + affected + " টি row এর " + cellCount + " টি সেল ইউনিকোডে আপডেট হয়েছে।");
                }
            }
            catch (Exception ex)
            {
                ShowError("কনভার্ট ব্যর্থ (কোনো পরিবর্তন সেভ হয়নি): " + ex.Message);
            }
        }

        private List<RowChange> BuildChanges(DataTable dt, List<string> cols, List<string> pk, Dictionary<char, string> unmapped)
        {
            List<RowChange> list = new List<RowChange>();
            int rowNo = 0;
            foreach (DataRow r in dt.Rows)
            {
                rowNo++;
                RowChange rc = null;
                foreach (string c in cols)
                {
                    string old = r[c] as string;
                    if (string.IsNullOrEmpty(old)) continue;
                    if (BijoyConverter.ContainsBengali(old)) continue; // আগেই ইউনিকোড — আবার কনভার্ট নয়

                    string nw = BijoyConverter.Convert(old);
                    if (nw == old) continue;

                    foreach (char ch in BijoyConverter.FindUnmapped(nw))
                        if (!unmapped.ContainsKey(ch)) unmapped[ch] = old; // নমুনা লেখা সহ সংরক্ষণ

                    if (rc == null)
                    {
                        rc = new RowChange();
                        rc.Pk = pk.Select(k => r[k]).ToArray();
                        rc.Label = pk.Count > 0
                            ? string.Join(", ", pk.Select(k => k + "=" + r[k]))
                            : "Row #" + rowNo;
                    }
                    rc.Cells.Add(new CellChange { Column = c, Old = old, New = nw });
                }
                if (rc != null) list.Add(rc);
            }
            return list;
        }

        private int ApplyChanges(SqlConnection con, string schema, string table, List<string> pk, List<RowChange> changes)
        {
            int affected = 0;
            using (SqlTransaction tx = con.BeginTransaction())
            {
                try
                {
                    foreach (RowChange rc in changes)
                    {
                        SqlCommand cmd = new SqlCommand();
                        cmd.Connection = con;
                        cmd.Transaction = tx;
                        cmd.CommandTimeout = 0;

                        List<string> sets = new List<string>();
                        for (int i = 0; i < rc.Cells.Count; i++)
                        {
                            string pn = "@v" + i;
                            sets.Add("[" + Esc(rc.Cells[i].Column) + "] = " + pn);
                            cmd.Parameters.Add(pn, SqlDbType.NVarChar, -1).Value = rc.Cells[i].New;
                        }

                        List<string> where = new List<string>();
                        for (int k = 0; k < pk.Count; k++)
                        {
                            string pn = "@k" + k;
                            where.Add("[" + Esc(pk[k]) + "] = " + pn);
                            cmd.Parameters.AddWithValue(pn, rc.Pk[k]);
                        }

                        cmd.CommandText = "UPDATE " + QName(schema, table)
                                          + " SET " + string.Join(", ", sets)
                                          + " WHERE " + string.Join(" AND ", where);
                        affected += cmd.ExecuteNonQuery();
                    }
                    tx.Commit(); // সব সফল হলে তবেই সেভ হবে
                }
                catch
                {
                    tx.Rollback(); // একটিও ব্যর্থ হলে পুরোটা আগের অবস্থায়
                    throw;
                }
            }
            return affected;
        }

        private void ShowPreview(List<RowChange> changes, int cellCount, Dictionary<char, string> unmapped)
        {
            DataTable pv = new DataTable();
            pv.Columns.Add("Row");
            pv.Columns.Add("Column");
            pv.Columns.Add("Before");
            pv.Columns.Add("After");

            int shown = 0;
            foreach (RowChange rc in changes)
            {
                foreach (CellChange cc in rc.Cells)
                {
                    if (shown >= PreviewLimit) break;
                    pv.Rows.Add(rc.Label, cc.Column, cc.Old, cc.New);
                    shown++;
                }
                if (shown >= PreviewLimit) break;
            }

            gvPreview.DataSource = pv;
            gvPreview.DataBind();
            pnlPreview.Visible = true;

            lblMsg.Text = Server.HtmlEncode("পরিবর্তন হবে: " + changes.Count + " টি row, " + cellCount + " টি সেল"
                + (cellCount > PreviewLimit ? " (প্রথম " + PreviewLimit + " টি দেখানো হচ্ছে)" : "") + "।");

            if (unmapped.Count > 0)
            {
                StringBuilder sb = new StringBuilder();
                foreach (KeyValuePair<char, string> kv in unmapped)
                    sb.Append(kv.Key).Append(" (U+").Append(((int)kv.Key).ToString("X4")).Append(") ← যে লেখায় পাওয়া গেছে: ").Append(kv.Value).Append(" ;   ");
                lblWarn.Text = Server.HtmlEncode("⚠ এই চিহ্নগুলোর ম্যাপিং নেই, ফলাফলে ভুল থাকতে পারে: " + sb);
            }
        }

        private void ShowError(string msg)
        {
            lblError.Text = Server.HtmlEncode(msg);
            lblError.Visible = true;
        }
    }
}
