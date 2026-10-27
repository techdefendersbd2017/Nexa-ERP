using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.HRMPayroll.Payrollinformation
{
    public partial class IncrementEntry : System.Web.UI.Page
    {
        // EmployeeRe_Active_Approval পেজের মতোই PayrollDB দিয়ে কানেকশন
        static SqlConnection NewCon()
        {
            SqlConnection con = new PayrollDB().openConnection();
            if (con.State != ConnectionState.Open) con.Open();
            return con;
        }

        // ------------------------------------------------------------------ Load
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            string today = DateTime.Today.ToString("yyyy-MM-dd");
            txtIncEffDate.Text = today;
            txtProEffDate.Text = today;
            txtIwpEffDate.Text = today;

            LoadCombos();
        }

        void LoadCombos()
        {
            foreach (var d in new[] { ddlIncStatus, ddlProStatus, ddlIwpStatus })
            {
                Bind(d, "SELECT * FROM Seperation_Status", "Seperation_Name", "Seperation_Code", "Emp. Status");
                var active = d.Items.FindByText("Active");
                if (active != null) d.SelectedValue = active.Value;
            }
            foreach (var d in new[] { ddlIncCategory, ddlProCategory, ddlIwpCategory })
                Bind(d, "SELECT * FROM TB_Catagory", "Catagory_Name", "Catagory_Code", "Select Catagory");
            foreach (var d in new[] { ddlIncDepartment, ddlProDepartment, ddlIwpDepartment })
                Bind(d, "SELECT * FROM TB_Department", "Department_Name", "Department_Code", "Select Department");
            foreach (var d in new[] { ddlIncSection, ddlProSection, ddlIwpSection })
                Bind(d, "SELECT * FROM TB_Section", "Section_Name", "Section_Code", "Select Section");
            foreach (var d in new[] { ddlIncLine, ddlProLine, ddlIwpLine })
                Bind(d, "SELECT * FROM TB_Line", "Line_Name", "Line_Code", "--");
            foreach (var d in new[] { ddlIncDesignation, ddlProDesignation, ddlIwpDesignation })
                Bind(d, "SELECT * FROM TB_Designation ORDER BY Desigation_name", "Desigation_name", "Designation_Code", "Select Designation");
            // From Month: শুধু Jan–Dec (value = মাসের নম্বর 1–12)
            string[] mon = { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" };
            foreach (var d in new[] { ddlIncFromMonth, ddlProFromMonth, ddlIwpFromMonth })
            {
                d.Items.Clear();
                d.Items.Add(new ListItem("Select", "0"));
                for (int i = 0; i < 12; i++) d.Items.Add(new ListItem(mon[i], (i + 1).ToString()));
            }

            // Increment Type: Fixed / Percentage
            foreach (var d in new[] { ddlIncType, ddlIwpIncType })
            {
                d.Items.Clear();
                d.Items.Add(new ListItem("Type", "0"));
                d.Items.Add(new ListItem("Fixed", "1"));
                d.Items.Add(new ListItem("Percentage", "2"));
            }
            // Increment From: Basic Salary / Gross Salary
            foreach (var d in new[] { ddlIncFrom, ddlIwpIncWith })
            {
                d.Items.Clear();
                d.Items.Add(new ListItem("Increment From", "0"));
                d.Items.Add(new ListItem("Basic Salary", "1"));
                d.Items.Add(new ListItem("Gross Salary", "2"));
            }

            // Promotion (new values)
            ddlProType.Items.Clear();
            ddlProType.Items.Add("No");
            ddlProType.Items.Add("Yes");
            Bind(ddlProNewDesignation, "SELECT * FROM TB_Designation ORDER BY Desigation_name", "Desigation_name", "Designation_Code", "Designation");
            Bind(ddlProNewCategory, "SELECT * FROM TB_Catagory", "Catagory_Name", "Catagory_Code", "Select Catagory");
            Bind(ddlProNewDepartment, "SELECT * FROM TB_Department", "Department_Name", "Department_Code", "Select Department");
            Bind(ddlProNewSection, "SELECT * FROM TB_Section", "Section_Name", "Section_Code", "Select Section");

            Bind(ddlIwpNewDesignation, "SELECT * FROM TB_Designation ORDER BY Desigation_name", "Desigation_name", "Designation_Code", "Designation");
            Bind(ddlIwpNewCategory, "SELECT * FROM TB_Catagory", "Catagory_Name", "Catagory_Code", "Select Catagory");
            Bind(ddlIwpNewDepartment, "SELECT * FROM TB_Department", "Department_Name", "Department_Code", "Select Department");
            Bind(ddlIwpNewSection, "SELECT * FROM TB_Section", "Section_Name", "Section_Code", "Select Section");
        }

        // ------------------------------------------------------------------ Helpers
        static DataTable Query(string sql)
        {
            using (var con = NewCon())
            using (var da = new SqlDataAdapter(sql, con))
            {
                var dt = new DataTable();
                da.Fill(dt);
                return dt;
            }
        }

        static void Bind(DropDownList d, string sql, string text, string value, string placeholder)
        {
            d.DataSource = Query(sql);
            d.DataTextField = text;
            d.DataValueField = value;
            d.DataBind();
            d.Items.Insert(0, new ListItem(placeholder, "0"));
            d.SelectedIndex = 0;
        }

        void Toast(string msg, bool ok)
        {
            string js = "showNotification(" + HttpUtility.JavaScriptStringEncode(msg, true) + "," + (ok ? "true" : "false") + ");";
            ScriptManager.RegisterStartupScript(this, GetType(), Guid.NewGuid().ToString("N"), js, true);
        }

        // "1001, 1002 1003" -> [1001,1002,1003]
        static List<long> ParseIds(string text)
        {
            var list = new List<long>();
            if (string.IsNullOrWhiteSpace(text)) return list;
            foreach (var p in text.Split(new[] { ',', ';', ' ', '\n', '\r', '\t' }, StringSplitOptions.RemoveEmptyEntries))
            {
                long v;
                if (long.TryParse(p.Trim(), out v)) list.Add(v);
            }
            return list.Distinct().ToList();
        }

        static List<long> IdsOf(DataTable dt)
        {
            return dt.AsEnumerable().Select(r => Convert.ToInt64(r["ID_no"])).Distinct().ToList();
        }

        static List<long> PostedIds(string name)
        {
            var raw = HttpContext.Current.Request.Form.GetValues(name);
            var list = new List<long>();
            if (raw == null) return list;
            foreach (var s in raw)
            {
                long v;
                if (long.TryParse(s, out v)) list.Add(v);
            }
            return list.Distinct().ToList();
        }

        static bool TryDate(string s, out DateTime d)
        {
            return DateTime.TryParse(s, out d);
        }

        // ID লেখা থাকলে সেই ID গুলো (parameterized), না থাকলে procedure দিয়ে ফিল্টার
        static DataTable GetEmployees(string idText, DropDownList status, DropDownList cat, DropDownList dept,
                                      DropDownList sec, DropDownList line, DropDownList desig, DropDownList month)
        {
            var ids = ParseIds(idText);
            using (var con = NewCon())
            {
                SqlCommand cmd;
                if (ids.Count > 0)
                {
                    var names = new List<string>();
                    cmd = new SqlCommand();
                    for (int i = 0; i < ids.Count; i++)
                    {
                        names.Add("@p" + i);
                        cmd.Parameters.AddWithValue("@p" + i, ids[i]);
                    }
                    cmd.CommandText = "SELECT * FROM View_For_Increment WHERE ID_no IN (" + string.Join(",", names) + ")";
                    cmd.Connection = con;
                }
                else
                {
                    cmd = new SqlCommand("Pro_Monthly_Increment_View", con) { CommandType = CommandType.StoredProcedure };
                    cmd.Parameters.AddWithValue("@Department", dept.SelectedItem.Text);
                    cmd.Parameters.AddWithValue("@Section", sec.SelectedItem.Text);
                    cmd.Parameters.AddWithValue("@Line", line.SelectedItem.Text);
                    cmd.Parameters.AddWithValue("@Designation", desig.SelectedItem.Text);
                    cmd.Parameters.AddWithValue("@Catagory", cat.SelectedItem.Text);
                    cmd.Parameters.AddWithValue("@ID", 0L);
                    cmd.Parameters.AddWithValue("@status", status.SelectedItem.Text);
                    cmd.Parameters.AddWithValue("@Inc_From_Month", long.Parse(month.SelectedValue));
                }
                var dt = new DataTable();
                using (var da = new SqlDataAdapter(cmd)) da.Fill(dt);
                return dt;
            }
        }

        // after-increment / pending procedure (Open / Pending)
        static DataTable GetListByProc(string proc, string idText, DropDownList status, DropDownList cat, DropDownList dept,
                                       DropDownList sec, DropDownList line, DropDownList desig, DropDownList month)
        {
            var ids = ParseIds(idText);
            using (var con = NewCon())
            {
                var dt = new DataTable();
                if (ids.Count > 1)
                {
                    // procedure এ একটি ID যায়; একাধিক হলে প্রতিটির জন্য কল করে জোড়া লাগানো
                    foreach (var id in ids)
                        dt.Merge(CallListProc(con, proc, id, status, cat, dept, sec, line, desig, month));
                    return dt;
                }
                return CallListProc(con, proc, ids.Count == 1 ? ids[0] : 0L, status, cat, dept, sec, line, desig, month);
            }
        }

        static DataTable CallListProc(SqlConnection con, string proc, long id, DropDownList status, DropDownList cat,
                                      DropDownList dept, DropDownList sec, DropDownList line, DropDownList desig, DropDownList month)
        {
            var cmd = new SqlCommand(proc, con) { CommandType = CommandType.StoredProcedure };
            cmd.Parameters.AddWithValue("@Department", dept.SelectedItem.Text);
            cmd.Parameters.AddWithValue("@Section", sec.SelectedItem.Text);
            cmd.Parameters.AddWithValue("@Line", line.SelectedItem.Text);
            cmd.Parameters.AddWithValue("@Designation", desig.SelectedItem.Text);
            cmd.Parameters.AddWithValue("@Catagory", cat.SelectedItem.Text);
            cmd.Parameters.AddWithValue("@ID", id);
            cmd.Parameters.AddWithValue("@status", status.SelectedItem.Text);
            cmd.Parameters.AddWithValue("@Inc_From_Month", long.Parse(month.SelectedValue));
            var dt = new DataTable();
            using (var da = new SqlDataAdapter(cmd)) da.Fill(dt);
            return dt;
        }

        static void ExecProc(string proc)
        {
            using (var con = NewCon())
            using (var cmd = new SqlCommand(proc, con) { CommandType = CommandType.StoredProcedure })
            {
                cmd.ExecuteNonQuery();
            }
        }

        // প্রতিটি ID এর জন্য procedure চালায় — একটি transaction এ (কোনোটা ফেল করলে সব rollback)
        static void RunPerEmployee(IEnumerable<long> ids, string proc, Action<SqlCommand, long> addParams)
        {
            using (var con = NewCon())
            {
                using (var tx = con.BeginTransaction())
                {
                    try
                    {
                        foreach (var id in ids)
                        {
                            using (var cmd = new SqlCommand(proc, con, tx) { CommandType = CommandType.StoredProcedure })
                            {
                                addParams(cmd, id);
                                cmd.ExecuteNonQuery();
                            }
                        }
                        tx.Commit();
                    }
                    catch
                    {
                        tx.Rollback();
                        throw;
                    }
                }
            }
        }

        void BindGrid(GridView gv, Label lbl, DataTable dt, string sessKey)
        {
            Session[sessKey] = dt;
            gv.DataSource = dt;
            gv.DataBind();
            if (gv.HeaderRow != null) gv.HeaderRow.TableSection = TableRowSection.TableHeader;
            lbl.Text = dt.Rows.Count + " Records";
        }

        void Export(string sessKey, string fileName)
        {
            var dt = Session[sessKey] as DataTable;
            if (dt == null || dt.Rows.Count == 0) { Toast("Export করার মতো কোনো ডাটা নেই।", false); return; }

            var sb = new StringBuilder();
            sb.Append("<html><head><meta charset='utf-8'></head><body><table border='1'><tr>");
            foreach (DataColumn c in dt.Columns) sb.Append("<th>").Append(HttpUtility.HtmlEncode(c.ColumnName)).Append("</th>");
            sb.Append("</tr>");
            foreach (DataRow r in dt.Rows)
            {
                sb.Append("<tr>");
                foreach (DataColumn c in dt.Columns) sb.Append("<td>").Append(HttpUtility.HtmlEncode(Convert.ToString(r[c]))).Append("</td>");
                sb.Append("</tr>");
            }
            sb.Append("</table></body></html>");

            Response.Clear();
            Response.ContentType = "application/vnd.ms-excel";
            Response.Charset = "utf-8";
            Response.AddHeader("Content-Disposition", "attachment; filename=" + fileName + "_" + DateTime.Now.ToString("yyyyMMdd_HHmm") + ".xls");
            Response.Write(sb.ToString());
            Response.End();
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            Response.Redirect(Request.RawUrl);
        }

        // ================================================================== INCREMENT
        protected void btnIncShow_Click(object sender, EventArgs e)
        {
            hfActiveTab.Value = "increment";
            try
            {
                ExecProc("Pro_Monthly_Increment_Delete");

                var emp = GetEmployees(txtIncId.Text, ddlIncStatus, ddlIncCategory, ddlIncDepartment,
                                       ddlIncSection, ddlIncLine, ddlIncDesignation, ddlIncFromMonth);

                double value; double.TryParse(txtIncValue.Text, out value);
                bool typeChosen = ddlIncType.SelectedValue != "0";
                DateTime eff;

                if (value != 0 && typeChosen && emp.Rows.Count > 0)
                {
                    if (!TryDate(txtIncEffDate.Text, out eff)) { Toast("Effective Date দিন।", false); BindGrid(gvIncrement, lblIncCount, emp, "dtInc"); return; }

                    long type = long.Parse(ddlIncType.SelectedValue);
                    long from = ddlIncType.SelectedItem.Text == "Fixed" ? 3 : long.Parse(ddlIncFrom.SelectedValue);

                    RunPerEmployee(IdsOf(emp), "Pro_Monthly_Increment", (cmd, id) =>
                    {
                        cmd.Parameters.Add("@ID_No", SqlDbType.BigInt).Value = id;
                        cmd.Parameters.Add("@increment_type", SqlDbType.BigInt).Value = type;
                        cmd.Parameters.Add("@increment_Value", SqlDbType.Float).Value = value;
                        cmd.Parameters.Add("@increment_from", SqlDbType.BigInt).Value = from;
                        cmd.Parameters.Add("@efective_Date", SqlDbType.DateTime).Value = eff;
                    });

                    var after = GetListByProc("Pro_Monthly_Increment_View_after_increment", txtIncId.Text, ddlIncStatus,
                                              ddlIncCategory, ddlIncDepartment, ddlIncSection, ddlIncLine, ddlIncDesignation, ddlIncFromMonth);
                    BindGrid(gvIncrement, lblIncCount, after, "dtInc");
                    Toast(emp.Rows.Count + " জনের Increment প্রসেস হয়েছে। Save চাপলে নিশ্চিত হবে।", true);
                }
                else
                {
                    BindGrid(gvIncrement, lblIncCount, emp, "dtInc");
                }
            }
            catch (Exception ex) { Toast(ex.Message, false); }
        }

        protected void btnIncOpenList_Click(object sender, EventArgs e)
        {
            hfActiveTab.Value = "increment";
            try
            {
                var dt = GetListByProc("Pro_Monthly_Increment_View_after_increment", txtIncId.Text, ddlIncStatus,
                                       ddlIncCategory, ddlIncDepartment, ddlIncSection, ddlIncLine, ddlIncDesignation, ddlIncFromMonth);
                BindGrid(gvIncrement, lblIncCount, dt, "dtInc");
            }
            catch (Exception ex) { Toast(ex.Message, false); }
        }

        protected void btnIncSave_Click(object sender, EventArgs e)
        {
            hfActiveTab.Value = "increment";
            try
            {
                var ids = PostedIds("selIdInc");
                DateTime eff;
                if (ids.Count == 0) { Toast("কমপক্ষে একজন কর্মচারী নির্বাচন করুন।", false); return; }
                if (!TryDate(txtIncEffDate.Text, out eff)) { Toast("Effective Date দিন।", false); return; }

                RunPerEmployee(ids, "Pro_Monthly_Increment_Confirm", (cmd, id) =>
                {
                    cmd.Parameters.Add("@ID_No", SqlDbType.BigInt).Value = id;
                    cmd.Parameters.Add("@efective_Date", SqlDbType.DateTime).Value = eff;
                });
                Toast("Increment Save Successful (" + ids.Count + " জন)", true);
            }
            catch (Exception ex) { Toast(ex.Message, false); }
        }

        protected void btnIncExport_Click(object sender, EventArgs e) { Export("dtInc", "Increment"); }

        // ================================================================== PROMOTION
        protected void btnProShow_Click(object sender, EventArgs e)
        {
            hfActiveTab.Value = "promotion";
            try
            {
                ExecProc("Pro_Monthly_Increment_Delete");

                var emp = GetEmployees(txtProId.Text, ddlProStatus, ddlProCategory, ddlProDepartment,
                                       ddlProSection, ddlProLine, ddlProDesignation, ddlProFromMonth);
                DateTime eff;
                if (!TryDate(txtProEffDate.Text, out eff)) { Toast("Effective Date দিন।", false); BindGrid(gvPromotion, lblProCount, emp, "dtPro"); return; }

                if (emp.Rows.Count > 0)
                {
                    RunPerEmployee(IdsOf(emp), "Pro_Monthly_Promotion", (cmd, id) =>
                    {
                        cmd.Parameters.Add("@ID_No", SqlDbType.BigInt).Value = id;
                        cmd.Parameters.Add("@promtion_Types", SqlDbType.VarChar).Value = ddlProType.SelectedItem.Text;
                        cmd.Parameters.Add("@promotion_Designation", SqlDbType.BigInt).Value = long.Parse(ddlProNewDesignation.SelectedValue);
                        cmd.Parameters.Add("@promotion_Catagory", SqlDbType.BigInt).Value = long.Parse(ddlProNewCategory.SelectedValue);
                        cmd.Parameters.Add("@efective_Date", SqlDbType.DateTime).Value = eff;
                        cmd.Parameters.Add("@New_Department", SqlDbType.BigInt).Value = long.Parse(ddlProNewDepartment.SelectedValue);
                        cmd.Parameters.Add("@New_Section", SqlDbType.BigInt).Value = long.Parse(ddlProNewSection.SelectedValue);
                    });
                }

                DataTable after;
                var ids = ParseIds(txtProId.Text);
                if (ids.Count > 0)
                {
                    after = Query("SELECT * FROM View_Promotion");
                    var f = string.Join(",", ids);
                    after.DefaultView.RowFilter = "ID_no IN (" + f + ")";
                    after = after.DefaultView.ToTable();
                }
                else
                {
                    using (var con = NewCon())
                    using (var cmd = new SqlCommand("Pro_Monthly_Promotion_View_after_Promotion", con) { CommandType = CommandType.StoredProcedure })
                    {
                        cmd.Parameters.AddWithValue("@Department", ddlProDepartment.SelectedItem.Text);
                        cmd.Parameters.AddWithValue("@Section", ddlProSection.SelectedItem.Text);
                        cmd.Parameters.AddWithValue("@Line", ddlProLine.SelectedItem.Text);
                        cmd.Parameters.AddWithValue("@Designation", ddlProDesignation.SelectedItem.Text);
                        cmd.Parameters.AddWithValue("@Catagory", ddlProCategory.SelectedItem.Text);
                        cmd.Parameters.AddWithValue("@ID", 0L);
                        cmd.Parameters.AddWithValue("@status", ddlProStatus.SelectedItem.Text);
                        cmd.Parameters.AddWithValue("@Efective_Date", eff);
                        after = new DataTable();
                        using (var da = new SqlDataAdapter(cmd)) da.Fill(after);
                    }
                }
                BindGrid(gvPromotion, lblProCount, after, "dtPro");
                Toast("Process Successful", true);
            }
            catch (Exception ex) { Toast(ex.Message, false); }
        }

        protected void btnProSave_Click(object sender, EventArgs e)
        {
            hfActiveTab.Value = "promotion";
            try
            {
                var ids = PostedIds("selIdPro");
                DateTime eff;
                if (ids.Count == 0) { Toast("কমপক্ষে একজন কর্মচারী নির্বাচন করুন।", false); return; }
                if (!TryDate(txtProEffDate.Text, out eff)) { Toast("Effective Date দিন।", false); return; }

                RunPerEmployee(ids, "Pro_Monthly_Promotion_Confirm", (cmd, id) =>
                {
                    cmd.Parameters.Add("@ID_No", SqlDbType.BigInt).Value = id;
                    cmd.Parameters.Add("@efective_Date", SqlDbType.DateTime).Value = eff;
                });
                Toast("Promotion Save Successful (" + ids.Count + " জন)", true);
            }
            catch (Exception ex) { Toast(ex.Message, false); }
        }

        protected void btnProExport_Click(object sender, EventArgs e) { Export("dtPro", "Promotion"); }

        // ================================================================== INCREMENT WITH PROMOTION
        protected void btnIwpShow_Click(object sender, EventArgs e)
        {
            hfActiveTab.Value = "incrementWithPromotion";
            try
            {
                ExecProc("Pro_Monthly_Increment_Delete");

                var emp = GetEmployees(txtIwpId.Text, ddlIwpStatus, ddlIwpCategory, ddlIwpDepartment,
                                       ddlIwpSection, ddlIwpLine, ddlIwpDesignation, ddlIwpFromMonth);
                DateTime eff;
                if (!TryDate(txtIwpEffDate.Text, out eff)) { Toast("Effective Date দিন।", false); BindGrid(gvIwp, lblIwpCount, emp, "dtIwp"); return; }

                double value; double.TryParse(txtIwpIncValue.Text, out value);
                if (ddlIwpIncType.SelectedValue == "0") { Toast("Inc. Type নির্বাচন করুন।", false); BindGrid(gvIwp, lblIwpCount, emp, "dtIwp"); return; }

                long type = long.Parse(ddlIwpIncType.SelectedValue);
                long from = ddlIwpIncType.SelectedItem.Text == "Fixed" ? 3 : long.Parse(ddlIwpIncWith.SelectedValue);
                var ids = IdsOf(emp);

                if (ids.Count > 0)
                {
                    RunPerEmployee(ids, "Pro_Monthly_Promotion_With_Increment", (cmd, id) =>
                    {
                        cmd.Parameters.Add("@ID_No", SqlDbType.BigInt).Value = id;
                        cmd.Parameters.Add("@increment_type", SqlDbType.BigInt).Value = type;
                        cmd.Parameters.Add("@increment_Value", SqlDbType.Float).Value = value;
                        cmd.Parameters.Add("@increment_from", SqlDbType.BigInt).Value = from;
                        cmd.Parameters.Add("@promtion_Types", SqlDbType.VarChar).Value = "Yes";
                        cmd.Parameters.Add("@promotion_Designation", SqlDbType.BigInt).Value = long.Parse(ddlIwpNewDesignation.SelectedValue);
                        cmd.Parameters.Add("@promotion_Catagory", SqlDbType.BigInt).Value = long.Parse(ddlIwpNewCategory.SelectedValue);
                        cmd.Parameters.Add("@efective_Date", SqlDbType.DateTime).Value = eff;
                        cmd.Parameters.Add("@New_Department", SqlDbType.BigInt).Value = long.Parse(ddlIwpNewDepartment.SelectedValue);
                        cmd.Parameters.Add("@New_Section", SqlDbType.BigInt).Value = long.Parse(ddlIwpNewSection.SelectedValue);
                    });
                }

                DataTable after;
                using (var con = NewCon())
                using (var cmd = new SqlCommand("SELECT * FROM View_Promotion WHERE Efective_Date=@d", con))
                {
                    cmd.Parameters.AddWithValue("@d", eff);
                    after = new DataTable();
                    using (var da = new SqlDataAdapter(cmd)) da.Fill(after);
                }
                if (ids.Count > 0)
                {
                    after.DefaultView.RowFilter = "ID_no IN (" + string.Join(",", ids) + ")";
                    after = after.DefaultView.ToTable();
                }
                else after.Clear();

                BindGrid(gvIwp, lblIwpCount, after, "dtIwp");
                Toast("Process Successful", true);
            }
            catch (Exception ex) { Toast(ex.Message, false); }
        }

        protected void btnIwpPending_Click(object sender, EventArgs e)
        {
            hfActiveTab.Value = "incrementWithPromotion";
            try
            {
                var dt = Query("SELECT * FROM View_Increment_Promotion WHERE Increment_Name='Promotion and Increment' AND Status_Name='Pending'");
                BindGrid(gvIwp, lblIwpCount, dt, "dtIwp");
            }
            catch (Exception ex) { Toast(ex.Message, false); }
        }

        protected void btnIwpSave_Click(object sender, EventArgs e)
        {
            hfActiveTab.Value = "incrementWithPromotion";
            try
            {
                var ids = PostedIds("selIdIwp");
                DateTime eff;
                if (ids.Count == 0) { Toast("কমপক্ষে একজন কর্মচারী নির্বাচন করুন।", false); return; }
                if (!TryDate(txtIwpEffDate.Text, out eff)) { Toast("Effective Date দিন।", false); return; }

                RunPerEmployee(ids, "Pro_Monthly_Promotion_Confirm", (cmd, id) =>
                {
                    cmd.Parameters.Add("@ID_No", SqlDbType.BigInt).Value = id;
                    cmd.Parameters.Add("@efective_Date", SqlDbType.DateTime).Value = eff;
                });
                Toast("Promotion and Increment Save Successful (" + ids.Count + " জন)", true);
            }
            catch (Exception ex) { Toast(ex.Message, false); }
        }

        protected void btnIwpExport_Click(object sender, EventArgs e) { Export("dtIwp", "IncrementWithPromotion"); }
    }
}
