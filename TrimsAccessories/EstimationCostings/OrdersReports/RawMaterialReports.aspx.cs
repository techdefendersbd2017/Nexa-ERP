using Nexa_ERP.Connection;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls; // GridViewRow এর জন্য এটি প্রয়োজন

namespace Nexa_ERP.TrimsAccessories.EstimationCostings.OrdersReports
{
    public partial class RawMaterialReports : System.Web.UI.Page
    {
        SqlConnection con;
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();

        // Grand Total হিসাব করার জন্য গ্লোবাল ভেরিয়েবল
        decimal grandTotalCost = 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string workOrderIdStr = Request.QueryString["WORcvID"];
                int workOrderId;

                if (string.IsNullOrEmpty(workOrderIdStr) || !int.TryParse(workOrderIdStr, out workOrderId))
                {
                    Response.Write("Invalid Work Order ID.");
                    Response.End();
                    return;
                }

                LoadReportData(workOrderId);
            }
        }

        private void LoadReportData(int workOrderId)
        {
            try
            {
                con = conn.openConnection();

                // আইটেম অনুযায়ী গ্রুপ বা সাজানোর জন্য কুয়েরির শেষে ORDER BY যোগ করা হয়েছে
                string query = @"SELECT 
                                    tbl_MaterialRequirement.WorkOrderID, 
                                    tbl_WorkOrderReceive.WORcvDate, 
                                    tbl_WorkOrderReceive.DeliveryDate, 
                                    dbo.Items_Information.ItemsName, 
                                    ta_RawMaterial.RawMaterialName, 
                                    tbl_MaterialRequirement.ReqQty, 
                                    tbl_UnitSetup.UnitName, 
                                    tbl_MaterialRequirement.UnitPrice, 
                                    tbl_MaterialRequirement.Currency, 
                                    tbl_MaterialRequirement.Loss, 
                                    tbl_MaterialRequirement.TotalCost, 
                                    tbl_MaterialRequirement.Remarks, 
                                    vw_Branch_Information.Branch_Name, 
                                    vw_Branch_Information.Phone_No, 
                                    vw_Branch_Information.Web, 
                                    vw_Branch_Information.Address, 
                                    vw_Branch_Information.Branch_Logo, 
                                    tbl_WorkOrderReceive.WORcvNo
                                FROM tbl_MaterialRequirement 
                                INNER JOIN tbl_WorkOrderReceive 
                                    ON tbl_MaterialRequirement.WorkOrderID = tbl_WorkOrderReceive.WORcvID 
                                INNER JOIN dbo.Items_Information 
                                    ON tbl_MaterialRequirement.ItemID = dbo.Items_Information.ItemsID 
                                INNER JOIN ta_RawMaterial 
                                    ON tbl_MaterialRequirement.RawMaterialID = ta_RawMaterial.RawMaterialID 
                                INNER JOIN vw_Branch_Information 
                                    ON tbl_WorkOrderReceive.ReceiveBranchID = vw_Branch_Information.Branch_ID 
                                INNER JOIN tbl_UnitSetup 
                                    ON ta_RawMaterial.Unit = tbl_UnitSetup.UnitID
                                WHERE tbl_WorkOrderReceive.WORcvID = @WorkOrderID
                                ORDER BY dbo.Items_Information.ItemsName"; // আইটেম অনুযায়ী সাজানো

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@WorkOrderID", workOrderId);

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count > 0)
                    {
                        DataRow row = dt.Rows[0];

                        lblBranchName.Text = row["Branch_Name"].ToString();
                        lblAddress.Text = row["Address"].ToString();
                        lblPhone.Text = row["Phone_No"].ToString();
                        lblWeb.Text = row["Web"].ToString();

                        lblWorkOrderNo.Text = row["WorkOrderID"].ToString();

                        if (row["WORcvDate"] != DBNull.Value)
                            lblWORcvDate.Text = Convert.ToDateTime(row["WORcvDate"]).ToString("dd-MMM-yyyy");

                        if (row["DeliveryDate"] != DBNull.Value)
                            lblDeliveryDate.Text = Convert.ToDateTime(row["DeliveryDate"]).ToString("dd-MMM-yyyy");

                        if (!dt.Columns.Contains("SlNo"))
                        {
                            dt.Columns.Add("SlNo", typeof(int));
                            for (int i = 0; i < dt.Rows.Count; i++)
                            {
                                dt.Rows[i]["SlNo"] = i + 1;
                            }
                        }

                        gvRawMaterialReport.DataSource = dt;
                        gvRawMaterialReport.DataBind();
                    }
                    else
                    {
                        Response.Write("Raw material requirements not found for this Work Order.");
                        Response.End();
                    }
                }
            }
            catch (Exception ex)
            {
                Response.Write("Error loading raw material report: " + ex.Message);
                Response.End();
            }
            finally
            {
                if (con != null && con.State == ConnectionState.Open) con.Close();
            }
        }

        // গ্রিডভিউতে ডেটা রো বাইন্ড হওয়ার সময় TotalCost যোগ করার লজিক
        protected void gvRawMaterialReport_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                // TotalCost কলামের ডেটা যোগ করা (আপনার গ্রিডভিউতে কলামের ইন্ডেক্স বা নাম অনুযায়ী মিলবে)
                decimal totalCost = 0;
                // ধরে নিচ্ছি TotalCost ডেটাতাবিলের 'TotalCost' ফিল্ড থেকে আসছে
                if (DataBinder.Eval(e.Row.DataItem, "TotalCost") != DBNull.Value)
                {
                    decimal.TryParse(DataBinder.Eval(e.Row.DataItem, "TotalCost").ToString(), out totalCost);
                    grandTotalCost += totalCost;
                }
            }
            else if (e.Row.RowType == DataControlRowType.Footer)
            {
                // ফুটার রো-তে Grand Total প্রিন্ট করা
                // লজিক: গ্রিডভিউ এর ফুটারের নির্দিষ্ট লেবেল বা সেল এ বসাতে পারেন
                Label lblGrandTotal = (Label)e.Row.FindControl("lblGrandTotal");
                if (lblGrandTotal != null)
                {
                    lblGrandTotal.Text = grandTotalCost.ToString("N2"); // দশমিকের পর দুই ঘর দেখানোর জন্য
                }
                else
                {
                    // যদি ফুটার টেমপ্লেটে লেবেল না থাকে সরাসরি সেলে প্রিন্ট করবে
                    e.Row.Cells[0].Text = "<b>Grand Total:</b>";
                    // TotalCost এর কলাম পজিশন অনুযায়ী সেল ইন্ডেক্স বসাতে হবে (যেমন: ১১ নাম্বার কলাম হতে পারে)
                    // নিরাপত্তার জন্য আপনি ASPX পেজে ফুটার টেমপ্লেট ব্যবহার করা ভালো।
                }
            }
        }
    }
}