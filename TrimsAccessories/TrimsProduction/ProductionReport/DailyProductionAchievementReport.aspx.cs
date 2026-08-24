using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.TrimsAccessories.TrimsProduction.ProductionReport
{
    public partial class DailyProductionAchievementReport : System.Web.UI.Page
    {
        SqlConnection con;
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();
        SqlCommand cmd;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // কুয়েরি স্ট্রিং থেকে তারিখ বা আইডি রিসিভ করা (যেমন: ProdDate বা AchievementDate)
                if (Request.QueryString["ProdDate"] != null)
                {
                    string prodDate = Request.QueryString["ProdDate"].ToString();
                    LoadReportData(prodDate);
                }
            }
        }

        private void LoadReportData(string prodDate)
        {
            try
            {
                con = conn.openConnection();
                string query = @"SELECT Trims_DailyProductionAchievement.AchievementID, Trims_DailyProductionAchievement.ProdDate, vw_Branch_Information.Branch_Name, vw_Branch_Information.E_Mail, vw_Branch_Information.Phone_No, 
                                 vw_Branch_Information.Web, vw_Branch_Information.Address, vw_Branch_Information.Branch_Logo, vw_BuildingInformation.Building_Name, vw_Floor_Information.Floor_Name, tbl_CustomerSupplier.PartyName, 
                                 WorkOrder_Master.WorkOrderNo, Trims_DailyProductionAchievement.ItemName, Trims_DailyProductionAchievement.TotalTargetQty, Trims_DailyProductionAchievement.TotalActualQty, 
                                 Trims_DailyProductionAchievement.AchievementPercent, Trims_DailyProductionAchievement.ShiftRemarks
                                 FROM Trims_DailyProductionAchievement 
                                 INNER JOIN vw_Branch_Information ON Trims_DailyProductionAchievement.CompanyID = vw_Branch_Information.Branch_ID 
                                 INNER JOIN vw_BuildingInformation ON Trims_DailyProductionAchievement.BuildingID = vw_BuildingInformation.Building_ID 
                                 INNER JOIN vw_Floor_Information ON vw_BuildingInformation.Building_ID = vw_Floor_Information.Building_ID 
                                 INNER JOIN tbl_CustomerSupplier ON Trims_DailyProductionAchievement.CustomerID = tbl_CustomerSupplier.PartyID 
                                 INNER JOIN WorkOrder_Master ON Trims_DailyProductionAchievement.WorkOrderID = WorkOrder_Master.WorkOrderID
                                 WHERE Trims_DailyProductionAchievement.ProdDate = @ProdDate";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@ProdDate", prodDate);
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        sda.Fill(dt);

                        if (dt.Rows.Count > 0)
                        {
                            // প্রথম রো থেকে ব্রাঞ্চ বা কোম্পানির সাধারণ তথ্য সেট করা হলো
                            DataRow firstRow = dt.Rows[0];
                            lblBranchName.Text = firstRow["Branch_Name"] != DBNull.Value ? firstRow["Branch_Name"].ToString() : "";
                            lblAddress.Text = firstRow["Address"] != DBNull.Value ? firstRow["Address"].ToString() : "";
                            lblPhone.Text = firstRow["Phone_No"] != DBNull.Value ? firstRow["Phone_No"].ToString() : "";
                            lblWeb.Text = firstRow["Web"] != DBNull.Value ? firstRow["Web"].ToString() : "";

                            if (firstRow["ProdDate"] != DBNull.Value)
                            {
                                lblProdDate.Text = Convert.ToDateTime(firstRow["ProdDate"]).ToString("dd-MMM-yyyy");
                            }

                            // গ্রিডভিউ বাইন্ড করা হলো
                            gvProductionAchievement.DataSource = dt;
                            gvProductionAchievement.DataBind();

                            // মোট টার্গেট ও প্রকৃত উৎপাদনের (Actual Qty) যোগফল এবং গড় অ্যাচিভমেন্ট হিসাব করা হলো
                            decimal totalTargetSum = 0;
                            decimal totalActualSum = 0;

                            foreach (DataRow row in dt.Rows)
                            {
                                if (row["TotalTargetQty"] != DBNull.Value)
                                {
                                    decimal.TryParse(row["TotalTargetQty"].ToString(), out decimal t);
                                    totalTargetSum += t;
                                }
                                if (row["TotalActualQty"] != DBNull.Value)
                                {
                                    decimal.TryParse(row["TotalActualQty"].ToString(), out decimal a);
                                    totalActualSum += a;
                                }
                            }

                            lblTotalTargetQty.Text = totalTargetSum.ToString("N0");
                            lblTotalActualQty.Text = totalActualSum.ToString("N0");

                            if (totalTargetSum > 0)
                            {
                                decimal overallPercentage = (totalActualSum / totalTargetSum) * 100;
                                lblOverallPercentage.Text = overallPercentage.ToString("N2");
                            }
                            else
                            {
                                lblOverallPercentage.Text = "0";
                            }
                        }
                        else
                        {
                            gvProductionAchievement.DataSource = null;
                            gvProductionAchievement.DataBind();
                            lblTotalTargetQty.Text = "0";
                            lblTotalActualQty.Text = "0";
                            lblOverallPercentage.Text = "0";
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

        // PDF Download Handler (Browser Print to PDF / HTML Export Alternative)
        protected void btnPdfDownload_Click(object sender, EventArgs e)
        {
            // ব্রাউজারের ডিফল্ট প্রিন্ট উইন্ডো ওপেন করে ইউজার সহজেই "Save as PDF" সিলেক্ট করতে পারবেন
            ScriptManager.RegisterStartupScript(this, this.GetType(), "window.print", "window.print();", true);
        }
    }
}