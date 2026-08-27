using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.Approval.TrimsAccessoriesApprovl
{
    public partial class PriceQuotationApproval : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // ডিফল্টভাবে Approval Tab (Index 3) সিলেক্ট থাকবে
                MainMultiView.ActiveViewIndex = 3;
                SetActiveTabStyle("Approval");
                CheckUserRoleAndPermissions();
            }
        }
        // ট্যাব ক্লিক ইভেন্ট হ্যান্ডলার
        protected void Tab_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            string tabName = btn.CommandArgument;

            // কোন ট্যাবে ক্লিক করা হলো তার উপর ভিত্তি করে MultiView View পরিবর্তন করা
            switch (tabName)
            {
                case "General":
                    MainMultiView.ActiveViewIndex = 0;
                    break;
                case "ItemDetails":
                    MainMultiView.ActiveViewIndex = 1;
                    break;
                case "Costing":
                    MainMultiView.ActiveViewIndex = 2;
                    break;
                case "Approval":
                    MainMultiView.ActiveViewIndex = 3;
                    break;
                case "History":
                    MainMultiView.ActiveViewIndex = 4;
                    break;
            }

            // ট্যাবের স্টাইল বা অ্যাক্টিভ ক্লাস আপডেট করা
            SetActiveTabStyle(tabName);
        }

        // বুটস্ট্রাপের active ক্লাস হ্যান্ডেল করার মেথড
        private void SetActiveTabStyle(string activeTab)
        {
            btnTabGeneral.CssClass = "nav-link";
            btnTabItemDetails.CssClass = "nav-link";
            btnTabCosting.CssClass = "nav-link";
            btnTabApproval.CssClass = "nav-link";
            btnTabHistory.CssClass = "nav-link";

            switch (activeTab)
            {
                case "General":
                    btnTabGeneral.CssClass += " active fw-bold text-primary";
                    break;
                case "ItemDetails":
                    btnTabItemDetails.CssClass += " active fw-bold text-primary";
                    break;
                case "Costing":
                    btnTabCosting.CssClass += " active fw-bold text-primary";
                    break;
                case "Approval":
                    btnTabApproval.CssClass += " active fw-bold text-primary";
                    break;
                case "History":
                    btnTabHistory.CssClass += " active fw-bold text-primary";
                    break;
            }
        }

        private void CheckUserRoleAndPermissions()
        {
            string userRole = Session["UserRole"]?.ToString() ?? "General Manager";
            string currentApprovalLevelRole = "General Manager";

            if (userRole == currentApprovalLevelRole)
            {
                pnlApprovalActions.Visible = true;
                pnlReadOnlyNotice.Visible = false;
            }
            else
            {
                pnlApprovalActions.Visible = false;
                pnlReadOnlyNotice.Visible = true;
            }
        }
    }
}