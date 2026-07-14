using Nexa_ERP.Connection;
using Nexa_ERP.MerchandisingMarketing.MerchandisingConfiguration;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Reflection;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.MerchandisingMarketing.OrderInformation
{
    public partial class StyleRegistrationSystem : System.Web.UI.Page
    {
        SqlConnection con;
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();
        protected void Page_Load(object sender, EventArgs e)
        {
            if(!IsPostBack)
            {
                string user = Request.QueryString["user"];
                if (!string.IsNullOrEmpty(user))
                {
                    Label1.Text = "Welcome, " + user;
                }
                LoadgvSizeList();
            }
        }
        private void LoadgvSizeList()
        {
            con = conn.openConnection();
            {
                SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM BuyerInformation where BuyingHouseID='" + ddlBuyingHouseName.SelectedValue + "'", con);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvSizeList.DataSource = dt;
                gvSizeList.DataBind();
            }
            con.Close();
        }

        protected void ddlBuyingHouseName_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

        protected void ddlBuyerType_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

        protected void CheckBox1_CheckedChanged(object sender, EventArgs e)
        {
            if(ChkSetItem.Checked== false)
            {
                txtNumberOfSetPcs.Enabled = false;
            }
            else
            {
                txtNumberOfSetPcs.Enabled = true;
                chkModel.Checked = false;
            }
        }

        protected void LinkButton1_Click(object sender, EventArgs e)
        {

        }

        protected void gvBuyerInformation_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

        protected void chkModel_CheckedChanged(object sender, EventArgs e)
        {
            if (chkModel.Checked == true)
            {
                ChkSetItem.Checked = false; 
                txtNumberOfSetPcs.Enabled = false;
                txtNumberOfSetPcs.Text = string.Empty;
            }
        }

        protected void LinkButton3_Click(object sender, EventArgs e)
        {
            PanelItemModelEntryInformation.Visible=true; 
            PanelFabricationList.Visible = false;
            PanelColorInfo.Visible = false;
            PanelOrderEntry.Visible = false;
            PanelOrderInformation.Visible = false;
        }

        protected void LinkButton5_Click(object sender, EventArgs e)
        {
            PanelItemModelEntryInformation.Visible = false;
            PanelFabricationList.Visible = true;
            PanelColorInfo.Visible = false;
            PanelOrderEntry.Visible = false;
            PanelOrderInformation.Visible = false;
        }

        protected void LinkButton6_Click(object sender, EventArgs e)
        {
            PanelItemModelEntryInformation.Visible = false;
            PanelFabricationList.Visible = false;
            PanelColorInfo.Visible = true;
            PanelOrderEntry.Visible = false;
            PanelOrderInformation.Visible = false;
        }

        protected void LinkButton7_Click(object sender, EventArgs e)
        {
            PanelItemModelEntryInformation.Visible = false;
            PanelFabricationList.Visible = false;
            PanelColorInfo.Visible = false;
            PanelOrderEntry.Visible = true;
            PanelOrderInformation.Visible = false;
        }

        protected void LinkButton3_Click1(object sender, EventArgs e)
        {
            PanelItemModelEntryInformation.Visible = false;
            PanelFabricationList.Visible = false;
            PanelColorInfo.Visible = false;
            PanelOrderEntry.Visible = false;
            PanelOrderInformation.Visible = true;
        }
    }
}