using System;

namespace Nexa_ERP.MerchandisingMarketing.BasicSetup
{
    public partial class JobSerialFormat : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // TODO: load current active pattern + "same for PO" selection
                // and set rbActive1/2/3, rbSameForPO1/2/3 accordingly
            }
        }

        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            // TODO: determine which rbActiveX / rbSameForPOX is checked
            // and save the selected Job Serial Format pattern
        }
    }
}