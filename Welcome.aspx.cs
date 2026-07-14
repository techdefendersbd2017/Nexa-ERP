using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Drawing.Printing;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;

namespace Nexa_ERP
{
    public partial class Welcome : System.Web.UI.Page
    {
        SqlConnection con;
        Database_Connection conn = new Database_Connection();
        //SqlCommand cmd;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadBranchInformation();
            }
        }
        private void LoadBranchInformation()
        {
            con = conn.openConnection();
            {
                SqlDataAdapter da = new SqlDataAdapter("SELECT Form_ID,Form_Name,WorkingStage,WorkUnder FROM Form_Information", con);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvWorkProgress.DataSource = dt;
                gvWorkProgress.DataBind();
            }
            con.Close();
        }

        protected void btnExportPDF_Click(object sender, EventArgs e)
        {
           
        }
        protected void gvWorkProgress_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvWorkProgress.PageIndex = e.NewPageIndex;
            LoadBranchInformation();
        }
    }
}