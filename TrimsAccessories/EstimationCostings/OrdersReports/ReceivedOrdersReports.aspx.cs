using Nexa_ERP.Connection;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.TrimsAccessories.EstimationCostings.OrdersReports
{
    public partial class ReceivedOrdersReports : System.Web.UI.Page
    {
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();
        decimal totalGrandReqQty = 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Request.QueryString["WORcvID"] != null &&
                    int.TryParse(Request.QueryString["WORcvID"], out int rcvId))
                {
                    LoadReportData(rcvId);
                }
            }
        }

        private void LoadReportData(int rcvId)
        {
            using (SqlConnection con = conn.openConnection())
            {
                string query = @"
SELECT 
    WorkOrderHeader.WORcvID, 
    WorkOrderHeader.WORcvNo, 
    WorkOrderHeader.WORcvDate, 
    WorkOrderHeader.DeliveryDate, 
    tbl_CustomerSupplier.PartyName, 
    WorkOrderHeader.RefWorkOrderNo, 
    WorkOrderHeader.QuotationNo, 
    WorkOrderDetails.Buyer, 
    WorkOrderDetails.Style, 
    WorkOrderDetails.PO, 
    WorkOrderDetails.ItemName, 
    WorkOrderDetails.ItemDescription, 
    WorkOrderDetails.ColorName, 
    WorkOrderDetails.Size, 
    WorkOrderDetails.Measurement, 
    WorkOrderDetails.ReqQty, 
    WorkOrderDetails.Unit, 
    WorkOrderDetails.RateUnit, 
    WorkOrderDetails.ExtraPercent, 
    WorkOrderDetails.TotalReqQty, 
    WorkOrderDetails.TotalAmount, 
    WorkOrderDetails.Remarks, 
    WorkOrderHeader.SubTotalAmount, 
    WorkOrderHeader.TransportCost, 
    WorkOrderHeader.VatPercent, 
    WorkOrderHeader.GrandTotal, 
    vw_Branch_Information.Branch_Name, 
    vw_Branch_Information.E_Mail, 
    vw_Branch_Information.Phone_No, 
    vw_Branch_Information.Web, 
    vw_Branch_Information.Address, 
    vw_Branch_Information.Branch_Logo
FROM WorkOrderHeader 
INNER JOIN WorkOrderDetails ON WorkOrderHeader.WORcvID = WorkOrderDetails.WORcvID 
INNER JOIN tbl_CustomerSupplier ON WorkOrderHeader.CustomerID = tbl_CustomerSupplier.PartyID 
INNER JOIN vw_Branch_Information ON WorkOrderHeader.ReceivingBranchID = vw_Branch_Information.Branch_ID
WHERE WorkOrderHeader.WORcvID = @WORcvID;";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@WORcvID", rcvId);

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        if (dt.Rows.Count > 0)
                        {
                            // 1st & 2nd Part Data Binding (Master & Branch)
                            DataRow headerRow = dt.Rows[0];
                            lblBranchName.Text = headerRow["Branch_Name"]?.ToString();
                            lblBranchAddress.Text = headerRow["Address"]?.ToString();
                            lblBranchPhone.Text = headerRow["Phone_No"]?.ToString();
                            lblBranchEmail.Text = headerRow["E_Mail"]?.ToString();
                            lblBranchWeb.Text = headerRow["Web"]?.ToString();

                            // Branch Logo Binding Logic (Handles both Binary Byte Array & Image URL Path)
                            if (headerRow["Branch_Logo"] != DBNull.Value)
                            {
                                object logoData = headerRow["Branch_Logo"];

                                if (logoData is byte[] logoBytes && logoBytes.Length > 0)
                                {
                                    // If Logo is stored as Varbinary/Byte Array
                                    string base64String = Convert.ToBase64String(logoBytes);
                                    imgBranchLogo.ImageUrl = "data:image/png;base64," + base64String;
                                    imgBranchLogo.Visible = true;
                                }
                                else
                                {
                                    // If Logo is stored as URL/File Path String
                                    string logoPath = logoData.ToString();
                                    if (!string.IsNullOrWhiteSpace(logoPath))
                                    {
                                        imgBranchLogo.ImageUrl = logoPath;
                                        imgBranchLogo.Visible = true;
                                    }
                                }
                            }

                            lblWORcvNo.Text = headerRow["WORcvNo"]?.ToString();
                            lblPartyName.Text = headerRow["PartyName"]?.ToString();
                            lblWORcvDate.Text = headerRow["WORcvDate"] != DBNull.Value ? Convert.ToDateTime(headerRow["WORcvDate"]).ToString("dd-MMM-yyyy") : "";
                            lblDeliveryDate.Text = headerRow["DeliveryDate"] != DBNull.Value ? Convert.ToDateTime(headerRow["DeliveryDate"]).ToString("dd-MMM-yyyy") : "";
                            lblRefWorkOrderNo.Text = headerRow["RefWorkOrderNo"]?.ToString();

                            // Calculate total Grand Total Req Qty
                            if (dt.Columns.Contains("TotalReqQty"))
                            {
                                totalGrandReqQty = dt.AsEnumerable().Sum(row => row.Field<decimal?>("TotalReqQty") ?? 0);
                            }
                            lblGrandTotalReqQty.Text = totalGrandReqQty.ToString("N2");

                            // 3rd Part: Grouping data by Buyer, Style, and PO
                            var groups = dt.AsEnumerable()
                                .GroupBy(r => new {
                                    Buyer = r.Field<string>("Buyer") ?? "",
                                    Style = r.Field<string>("Style") ?? "",
                                    PO = r.Field<string>("PO") ?? ""
                                })
                                .Select(g => new {
                                    g.Key.Buyer,
                                    g.Key.Style,
                                    g.Key.PO,
                                    Rows = g.CopyToDataTable()
                                }).ToList();

                            rptGroupedOrders.DataSource = groups;
                            rptGroupedOrders.DataBind();
                        }
                    }
                }
            }
        }

        protected void rptGroupedOrders_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                var gvGroupDetails = (GridView)e.Item.FindControl("gvGroupDetails");
                var groupData = (DataTable)((dynamic)e.Item.DataItem).Rows;

                // Add RowNo (SL No) dynamically
                if (!groupData.Columns.Contains("RowNo"))
                {
                    groupData.Columns.Add("RowNo", typeof(int));
                    for (int i = 0; i < groupData.Rows.Count; i++)
                    {
                        groupData.Rows[i]["RowNo"] = i + 1;
                    }
                }

                gvGroupDetails.DataSource = groupData;
                gvGroupDetails.DataBind();
            }
        }

        protected void gvGroupDetails_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            // Column Auto-Hide Logic
            if (e.Row.RowType == DataControlRowType.Header)
            {
                GridView gv = (GridView)sender;
                DataTable dt = (DataTable)gv.DataSource;

                if (dt != null)
                {
                    for (int i = 0; i < gv.Columns.Count; i++)
                    {
                        string dataField = ((BoundField)gv.Columns[i]).DataField;
                        if (!string.IsNullOrEmpty(dataField) && dt.Columns.Contains(dataField))
                        {
                            bool hasData = dt.AsEnumerable().Any(r => r[dataField] != DBNull.Value && !string.IsNullOrWhiteSpace(r[dataField].ToString()));
                            if (!hasData)
                            {
                                e.Row.Cells[i].Visible = false;
                            }
                        }
                    }
                }
            }
            else if (e.Row.RowType == DataControlRowType.DataRow)
            {
                GridView gv = (GridView)sender;
                for (int i = 0; i < gv.Columns.Count; i++)
                {
                    if (!gv.HeaderRow.Cells[i].Visible)
                    {
                        e.Row.Cells[i].Visible = false;
                    }
                }
            }
        }
    }
}