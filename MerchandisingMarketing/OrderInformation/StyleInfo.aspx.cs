using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.MerchandisingMarketing.OrderInformation
{
    public partial class StyleInfo : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void Button7_Click(object sender, EventArgs e)
        {
            Panel_Style_Details.Visible = true;
            PanelStyle_List.Visible = false;
        }

        protected void Button8_Click(object sender, EventArgs e)
        {
            Panel_Style_Details.Visible = false;
            PanelStyle_List.Visible = true;
        }

        protected void Button5_Click(object sender, EventArgs e)
        {

        }

        protected void btnSelectSize1_Click(object sender, EventArgs e)
        {
            PanelSizePopup.Visible = true;
        }
    }
}