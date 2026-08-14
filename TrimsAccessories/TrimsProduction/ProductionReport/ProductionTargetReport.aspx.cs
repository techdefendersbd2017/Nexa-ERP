using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.TrimsAccessories.TrimsProduction.ProductionReport
{
    public partial class ProductionTargetReport : System.Web.UI.Page
    {
        SqlConnection con;
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();
        SqlCommand cmd;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Request.QueryString["TargetDate"] != null)
                {
                    string targetId = Request.QueryString["TargetDate"].ToString();
                    LoadReportData(targetId);
                }
            }
        }

        private void LoadReportData(string targetId)
        {
            try
            {
                con = conn.openConnection();
                string query = @"SELECT DailyProductionTarget.TargetID, DailyProductionTarget.TargetDate, vw_Branch_Information.Branch_Name, vw_Branch_Information.Phone_No, vw_Branch_Information.Web, vw_Branch_Information.Address, 
                                 vw_Branch_Information.Branch_Logo, vw_Floor_Information.Floor_Name, ta_ItemCategory.CategoryName, ta_ItemName.ItemName, DailyProductionTarget.Operator, DailyProductionTarget.Helper, 
                                 DailyProductionTarget.WorkingHours, DailyProductionTarget.PerHourTarget, DailyProductionTarget.SMV, DailyProductionTarget.Efficiency, DailyProductionTarget.TotalHours, DailyProductionTarget.TotalTargetQty, 
                                 DailyProductionTarget.TargetRemarks
                                 FROM DailyProductionTarget 
                                 INNER JOIN ta_ItemName ON DailyProductionTarget.ItemID = ta_ItemName.ItemID 
                                 INNER JOIN ta_ItemCategory ON ta_ItemName.CategoryID = ta_ItemCategory.CategoryID 
                                 INNER JOIN vw_Branch_Information ON DailyProductionTarget.BranchID = vw_Branch_Information.Branch_ID 
                                 INNER JOIN vw_Floor_Information ON DailyProductionTarget.FloorID = vw_Floor_Information.Floor_ID
                                 WHERE DailyProductionTarget.TargetDate = @TargetDate";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@TargetDate", targetId);
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        sda.Fill(dt);

                        if (dt.Rows.Count > 0)
                        {
                            // কমন ব্রাঞ্চের তথ্য প্রথম রো থেকে সেট করা হলো
                            DataRow firstRow = dt.Rows[0];
                            lblBranchName.Text = firstRow["Branch_Name"] != DBNull.Value ? firstRow["Branch_Name"].ToString() : "";
                            lblAddress.Text = firstRow["Address"] != DBNull.Value ? firstRow["Address"].ToString() : "";
                            lblPhone.Text = firstRow["Phone_No"] != DBNull.Value ? firstRow["Phone_No"].ToString() : "";
                            lblWeb.Text = firstRow["Web"] != DBNull.Value ? firstRow["Web"].ToString() : "";

                            if (firstRow["TargetDate"] != DBNull.Value)
                            {
                                lblTargetDate.Text = Convert.ToDateTime(firstRow["TargetDate"]).ToString("dd-MMM-yyyy");
                            }

                            // গ্রিডভিউতে ওই তারিখের সব আইটেমের টার্গেট বাইন্ড করা হলো
                            gvProductionTarget.DataSource = dt;
                            gvProductionTarget.DataBind();

                            // ওই তারিখের মোট টার্গেট কোয়ান্টিটি এবং মোট কাজের ঘণ্টার সাম বের করা হলো
                            decimal totalHoursSum = 0;
                            decimal totalTargetQtySum = 0;

                            foreach (DataRow row in dt.Rows)
                            {
                                if (row["TotalHours"] != DBNull.Value)
                                {
                                    decimal.TryParse(row["TotalHours"].ToString(), out decimal h);
                                    totalHoursSum += h;
                                }
                                if (row["TotalTargetQty"] != DBNull.Value)
                                {
                                    decimal.TryParse(row["TotalTargetQty"].ToString(), out decimal q);
                                    totalTargetQtySum += q;
                                }
                            }

                            lblTotalHours.Text = totalHoursSum.ToString();
                            lblTotalTargetQty.Text = totalTargetQtySum.ToString();
                        }
                        else
                        {
                            gvProductionTarget.DataSource = null;
                            gvProductionTarget.DataBind();
                            lblTotalHours.Text = "0";
                            lblTotalTargetQty.Text = "0";
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) con.Close();
            }
        }
    }
}