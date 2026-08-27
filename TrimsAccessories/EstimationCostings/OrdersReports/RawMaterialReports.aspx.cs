using Nexa_ERP.Connection;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.TrimsAccessories.EstimationCostings.OrdersReports
{
    public partial class RawMaterialReports : System.Web.UI.Page
    {
        SqlConnection con;
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();

        // Raw Material লিস্টের TotalCost যোগফল (তথ্য যাচাইয়ের জন্য; মূল Grand Total WorkOrder_Master থেকে আসে)
        decimal materialsTotalCost = 0;

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

                string query = @"SELECT 
                                    WorkOrder_Master.WorkOrderID,
                                    WorkOrder_Master.WorkOrderNo,
                                    WorkOrder_Master.WoDate,
                                    WorkOrder_Master.DeliveryDate,
                                    WorkOrder_Master.Buyer,
                                    WorkOrder_Master.Style,
                                    WorkOrder_Master.OrderNo,
                                    WorkOrder_Master.ItemName,
                                    WorkOrder_Master.QuotationNo,
                                    WorkOrder_Master.SubTotalAmount,
                                    WorkOrder_Master.TransportCost,
                                    WorkOrder_Master.VatPercent,
                                    WorkOrder_Master.GrandTotalAmount,
                                    tbl_MaterialRequirement.RawMaterialName,
                                    tbl_MaterialRequirement.ReqQty,
                                    tbl_MaterialRequirement.UnitPrice,
                                    tbl_MaterialRequirement.Currency,
                                    tbl_MaterialRequirement.Loss,
                                    tbl_MaterialRequirement.TotalCost,
                                    tbl_MaterialRequirement.Remarks,
                                    tbl_UnitSetup.UnitName,
                                    vw_Branch_Information.Branch_Name,
                                    vw_Branch_Information.Phone_No,
                                    vw_Branch_Information.Web,
                                    vw_Branch_Information.E_Mail,
                                    vw_Branch_Information.Address,
                                    vw_Branch_Information.Branch_Logo
                                FROM WorkOrder_Master
                                INNER JOIN tbl_MaterialRequirement 
                                    ON WorkOrder_Master.WorkOrderID = tbl_MaterialRequirement.WorkOrderID
                                INNER JOIN ta_RawMaterial 
                                    ON tbl_MaterialRequirement.RawMaterialID = ta_RawMaterial.RawMaterialID
                                INNER JOIN ta_ItemName 
                                    ON WorkOrder_Master.ItemID = ta_ItemName.ItemID
                                INNER JOIN vw_Branch_Information 
                                    ON WorkOrder_Master.ReceivingBranch = vw_Branch_Information.Branch_ID
                                INNER JOIN tbl_UnitSetup 
                                    ON ta_RawMaterial.Unit = tbl_UnitSetup.UnitID
                                WHERE WorkOrder_Master.WorkOrderID = @WorkOrderID
                                ORDER BY tbl_MaterialRequirement.RawMaterialName";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@WorkOrderID", workOrderId);

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count > 0)
                    {
                        DataRow row = dt.Rows[0];

                        // ---- কোম্পানি / ব্রাঞ্চ তথ্য ----
                        lblBranchName.Text = row["Branch_Name"].ToString();
                        lblAddress.Text = row["Address"].ToString();
                        lblPhone.Text = row["Phone_No"].ToString();
                        lblWeb.Text = row["Web"].ToString();

                        // ---- Work Order হেডার তথ্য ----
                        lblWorkOrderNo.Text = row["WorkOrderNo"] != DBNull.Value
                            ? row["WorkOrderNo"].ToString()
                            : row["WorkOrderID"].ToString();

                        if (row["WoDate"] != DBNull.Value)
                            lblWORcvDate.Text = Convert.ToDateTime(row["WoDate"]).ToString("dd-MMM-yyyy");

                        if (row["DeliveryDate"] != DBNull.Value)
                            lblDeliveryDate.Text = Convert.ToDateTime(row["DeliveryDate"]).ToString("dd-MMM-yyyy");

                        lblBuyer.Text = row["Buyer"] != DBNull.Value ? row["Buyer"].ToString() : "-";
                        lblStyle.Text = row["Style"] != DBNull.Value ? row["Style"].ToString() : "-";
                        lblOrderNo.Text = row["OrderNo"] != DBNull.Value ? row["OrderNo"].ToString() : "-";
                        lblItemName.Text = row["ItemName"] != DBNull.Value ? row["ItemName"].ToString() : "-";

                        // ---- কস্ট সামারি (WorkOrder_Master থেকে সরাসরি, নির্ভুল হিসাব) ----
                        lblSubTotal.Text = Convert.ToDecimal(row["SubTotalAmount"]).ToString("N2");
                        lblTransportCost.Text = Convert.ToDecimal(row["TransportCost"]).ToString("N2");
                        lblVatPercent.Text = Convert.ToDecimal(row["VatPercent"]).ToString("0.00") + " %";
                        lblGrandTotal.Text = Convert.ToDecimal(row["GrandTotalAmount"]).ToString("N2");

                        // ---- Serial No যোগ করা ----
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

        // Raw Material গ্রিডের ফুটারে TotalCost এর যোগফল (মিলিয়ে দেখার জন্য, WorkOrder_Master.SubTotalAmount এর পাশাপাশি)
        protected void gvRawMaterialReport_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                decimal totalCost = 0;
                if (DataBinder.Eval(e.Row.DataItem, "TotalCost") != DBNull.Value)
                {
                    decimal.TryParse(DataBinder.Eval(e.Row.DataItem, "TotalCost").ToString(), out totalCost);
                    materialsTotalCost += totalCost;
                }
            }
            else if (e.Row.RowType == DataControlRowType.Footer)
            {
                Label lblMaterialsTotal = (Label)e.Row.FindControl("lblMaterialsTotal");
                if (lblMaterialsTotal != null)
                {
                    lblMaterialsTotal.Text = materialsTotalCost.ToString("N2");
                }
            }
        }
    }
}
