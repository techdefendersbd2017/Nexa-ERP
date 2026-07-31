using Nexa_ERP.Connection;
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace Nexa_ERP.TrimsAccessories.EstimationCostings.OrdersReports
{
    public partial class ReceivedOrdersReports : System.Web.UI.Page
    {
        SqlConnection con;
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();
        SqlCommand cmd;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Request.QueryString["WORcvID"] != null)
                {
                    int rcvId = Convert.ToInt32(Request.QueryString["WORcvID"]);
                    LoadReportData(rcvId);
                }
            }
        }
        protected void btnDownload_Click(object sender, EventArgs e)
        {
            ClientScript.RegisterStartupScript(this.GetType(), "onclick", "<script>window.print();</script>");

        }

        private void LoadReportData(int rcvId)
        {
            con=conn.openConnection();
            {
                string query = @"
                    SELECT 
                        wo.[WORcvID], wo.[WORcvNo], wo.[WONo], wo.[WORcvDate], wo.[DeliveryDate], wo.[GrandTotal],
                        b.[Branch_Name], b.[E_Mail] AS BranchEmail, b.[Phone_No] AS BranchPhone, b.[Web], b.[Address] AS BranchAddress,
                        c.[PartyName], c.[ContactPerson], c.[Phone] AS CustPhone, c.[Email] AS CustEmail, c.[Address] AS CustAddress
                    FROM [nexamar].[techdefendersbd].[tbl_WorkOrderReceive] wo
                    LEFT JOIN [nexamar].[techdefendersbd].[vw_Branch_Information] b ON wo.[ReceiveBranchID] = b.[Branch_ID]
                    LEFT JOIN [nexamar].[techdefendersbd].[tbl_CustomerSupplier] c ON wo.[CustomerID] = c.[PartyID]
                    WHERE wo.[WORcvID] = @WORcvID;

                    SELECT [WORcvDtlID], [FinishedItemName], [Rate], [OrderQty], [Amount], [IsIncluded]
                    FROM [nexamar].[techdefendersbd].[tbl_WorkOrderReceiveDetails]
                    WHERE [WORcvID] = @WORcvID;";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@WORcvID", rcvId);

                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataSet ds = new DataSet();
                        da.Fill(ds);

                        if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                        {
                            DataRow row = ds.Tables[0].Rows[0];

                            lblWONo.Text = row["WONo"] != DBNull.Value ? row["WONo"].ToString() : "";
                            lblWORcvNo.Text = row["WORcvNo"] != DBNull.Value ? row["WORcvNo"].ToString() : "";
                            lblWORcvDate.Text = row["WORcvDate"] != DBNull.Value ? Convert.ToDateTime(row["WORcvDate"]).ToString("dd-MMM-yyyy") : "";
                            lblDeliveryDate.Text = row["DeliveryDate"] != DBNull.Value ? Convert.ToDateTime(row["DeliveryDate"]).ToString("dd-MMM-yyyy") : "";
                            lblGrandTotal.Text = row["GrandTotal"] != DBNull.Value ? Convert.ToDecimal(row["GrandTotal"]).ToString("N2") : "0.00";

                            // Branch Info
                            lblBranchName.Text = row["Branch_Name"] != DBNull.Value ? row["Branch_Name"].ToString() : "";
                            lblBranchAddress.Text = row["BranchAddress"] != DBNull.Value ? row["BranchAddress"].ToString() : "";
                            lblBranchPhone.Text = row["BranchPhone"] != DBNull.Value ? row["BranchPhone"].ToString() : "";
                            lblBranchEmail.Text = row["BranchEmail"] != DBNull.Value ? row["BranchEmail"].ToString() : "";
                            lblBranchWeb.Text = row["Web"] != DBNull.Value ? row["Web"].ToString() : "";

                            // Customer Info
                            lblPartyName.Text = row["PartyName"] != DBNull.Value ? row["PartyName"].ToString() : "";
                            lblContactPerson.Text = row["ContactPerson"] != DBNull.Value ? row["ContactPerson"].ToString() : "";
                            lblCustomerPhone.Text = row["CustPhone"] != DBNull.Value ? row["CustPhone"].ToString() : "";
                            lblCustomerEmail.Text = row["CustEmail"] != DBNull.Value ? row["CustEmail"].ToString() : "";
                            lblCustomerAddress.Text = row["CustAddress"] != DBNull.Value ? row["CustAddress"].ToString() : "";
                        }

                        // --- ২. গ্রিডভিউতে আইটেম ডিটেইলস বাইন্ড করা (Table 1) ---
                        if (ds.Tables.Count > 1)
                        {
                            gvOrderDetails.DataSource = ds.Tables[1];
                            gvOrderDetails.DataBind();
                        }
                    }
                }
            }
            con.Close();
        }
    }
}