using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.TrimsAccessories.EstimationCostings.OrdersReports
{
    public partial class BookingInformation : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // প্রাথমিক ডাটা লোড
                LoadDropdowns();
                LoadBookingList();

                // ডিফল্ট ফিল্টার ডেট সেট করা
                txtFromDate.Text = DateTime.Now.AddMonths(-1).ToString("yyyy-MM-dd");
                txtTillDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
                txtBookingDate.Text = DateTime.Now.ToString("yyyy-MM-dd");
            }
        }

        #region Dropdown & Grid Load Methods

        private void LoadDropdowns()
        {
            // Branch Dropdown Populating Example
            ddlBranch.Items.Clear();
            ddlBranch.Items.Add(new ListItem("--Select--", ""));
            ddlBranch.Items.Add(new ListItem("Main Branch", "1"));
            ddlBranch.Items.Add(new ListItem("Chittagong Factory", "2"));

            // Customer Dropdowns Populating Example
            ddlCustomer.Items.Clear();
            ddlCustomer.Items.Add(new ListItem("--Select--", ""));
            ddlCustomer.Items.Add(new ListItem("Apex Holdings Ltd", "101"));
            ddlCustomer.Items.Add(new ListItem("Envoy Textiles Ltd", "102"));
            ddlCustomer.Items.Add(new ListItem("Square Fashions Ltd", "103"));

            ddlSearchCustomer.Items.Clear();
            ddlSearchCustomer.Items.Add(new ListItem("--All Customer--", "0"));
            ddlSearchCustomer.Items.Add(new ListItem("Apex Holdings Ltd", "101"));
            ddlSearchCustomer.Items.Add(new ListItem("Envoy Textiles Ltd", "102"));
            ddlSearchCustomer.Items.Add(new ListItem("Square Fashions Ltd", "103"));
        }

        private void LoadBookingList()
        {
            // ডামি ডাটা দিয়ে লিস্ট টেবিল টেস্ট করার জন্য
            DataTable dtList = new DataTable();
            dtList.Columns.Add("BookingID", typeof(int));
            dtList.Columns.Add("BookingCode", typeof(string));
            dtList.Columns.Add("BookingDate", typeof(DateTime));
            dtList.Columns.Add("DeliveryDate", typeof(DateTime));
            dtList.Columns.Add("GrandTotal", typeof(decimal));

            // নমুনা তথ্য (আপনার ডাটাবেজ কোয়েরি দিয়ে পরিবর্তন করুন)
            dtList.Rows.Add(1, "BK-2026-001", DateTime.Now.AddDays(-5), DateTime.Now.AddDays(10), 15500.00m);
            dtList.Rows.Add(2, "BK-2026-002", DateTime.Now.AddDays(-2), DateTime.Now.AddDays(12), 28400.00m);

            gvBookingList.DataSource = dtList;
            gvBookingList.DataBind();
        }

        #endregion

        #region Grid Events & Button Actions

        protected void gvBookingList_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            string bookingCode = e.CommandArgument.ToString();

            if (e.CommandName == "EditRow")
            {
                // এডিট প্যানেল ওপেন ও ডাটা ফিল করা
                LoadBookingForEdit(bookingCode);
                hdnActivePanel.Value = "pnlForm";
                hdnActiveTab.Value = "tabMasterInfo";
            }
            else if (e.CommandName == "DeleteRow")
            {
                // মুছে ফেলার লজিক
                DeleteBooking(bookingCode);
                LoadBookingList();
            }
            else if (e.CommandName == "ReportView")
            {
                // রিপোর্ট প্রিভিউ পেজ চালু বা প্রিন্ট উইন্ডো কল
                string script = $"window.open('BookingInformationPrint.aspx?BookingID={bookingCode}', '_blank');";
                ClientScript.RegisterStartupScript(this.GetType(), "OpenPrint", script, true);
            }
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            // কোটেশন বা বুকিং আইটেম ফিল্টার করার লজিক
            hdnActivePanel.Value = "pnlForm";
            hdnActiveTab.Value = "tabOrderInfo";

            // ফিল্টার অনুসারে গ্রিড আইটেম রিফ্রেশ করা
        }

        protected void btnLoadItems_Click(object sender, EventArgs e)
        {
            // কোটেশন থেকে আইটেম লোড করা
            DataTable dtItems = new DataTable();
            dtItems.Columns.Add("ItemID", typeof(string));
            dtItems.Columns.Add("ItemName", typeof(string));
            dtItems.Columns.Add("Rate", typeof(decimal));

            // নমুনা ডাটাবেজ রেজাল্ট
            dtItems.Rows.Add("ITM-001", "Woven Label - Main Label", 2.50m);
            dtItems.Rows.Add("ITM-002", "Hang Tag - FSC Certified", 1.80m);
            dtItems.Rows.Add("ITM-003", "Poly Bag - Printed", 0.75m);

            gvBookingItems.DataSource = dtItems;
            gvBookingItems.DataBind();

            hdnActivePanel.Value = "pnlForm";
            hdnActiveTab.Value = "tabOrderInfo";
        }

        protected void chkIncludeItem_CheckedChanged(object sender, EventArgs e)
        {
            CalculateGrandTotal();
            hdnActivePanel.Value = "pnlForm";
            hdnActiveTab.Value = "tabOrderInfo";
        }

        protected void txtBookingQty_TextChanged(object sender, EventArgs e)
        {
            CalculateGrandTotal();
            hdnActivePanel.Value = "pnlForm";
            hdnActiveTab.Value = "tabOrderInfo";
        }

        #endregion

        #region Calculation & Save Logic

        private void CalculateGrandTotal()
        {
            decimal grandTotal = 0;

            foreach (GridViewRow row in gvBookingItems.Rows)
            {
                CheckBox chkInclude = (CheckBox)row.FindControl("chkIncludeItem");
                TextBox txtQty = (TextBox)row.FindControl("txtBookingQty");
                HiddenField hdnRate = (HiddenField)row.FindControl("hdnRate");
                Label lblAmount = (Label)row.FindControl("lblAmount");

                if (chkInclude != null && chkInclude.Checked)
                {
                    decimal qty = 0;
                    decimal rate = 0;

                    decimal.TryParse(txtQty.Text, out qty);
                    decimal.TryParse(hdnRate.Value, out rate);

                    decimal amount = qty * rate;
                    if (lblAmount != null)
                    {
                        lblAmount.Text = amount.ToString("0.00");
                    }

                    grandTotal += amount;
                }
                else
                {
                    if (lblAmount != null)
                    {
                        lblAmount.Text = "0.00";
                    }
                }
            }

            txtGTotal.Text = grandTotal.ToString("0.00");
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                // ১. Master Information ফিল্ড থেকে ডাটা রিড করা
                string branch = ddlBranch.SelectedValue;
                string bookingCode = txtBookingCode.Text.Trim();
                string bookingDate = txtBookingDate.Text;
                string customer = ddlCustomer.SelectedValue;
                decimal grandTotal = Convert.ToDecimal(txtGTotal.Text);

                // ২. ডাটাবেজে Save / Update প্রসেস চালান (Stored Procedure / EF)

                // ৩. GridView এর Details Items লুপ করে সেভ করা
                foreach (GridViewRow row in gvBookingItems.Rows)
                {
                    CheckBox chkInclude = (CheckBox)row.FindControl("chkIncludeItem");
                    if (chkInclude != null && chkInclude.Checked)
                    {
                        string itemID = row.Cells[2].Text;
                        TextBox txtQty = (TextBox)row.FindControl("txtBookingQty");
                        HiddenField hdnRate = (HiddenField)row.FindControl("hdnRate");

                        // Details Item Save Logic Here...
                    }
                }

                // সফল মেসেজ এবং তালিকা রিফ্রেশ
                ClearForm();
                LoadBookingList();
                hdnActivePanel.Value = "pnlList";

                ScriptManager.RegisterStartupScript(this, GetType(), "SaveSuccess", "alert('Booking Information Saved Successfully!');", true);
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "SaveError", $"alert('Error: {ex.Message}');", true);
            }
        }

        private void LoadBookingForEdit(string bookingCode)
        {
            // ডাটাবেজ থেকে তথ্য এনে ফর্ম এর ফিল্ডে বসানোর কোড
            txtBookingCode.Text = bookingCode;
            // অন্যান্য ফিল্ড ডাটাবেজ ডাটা দিয়ে পূরণ করুন...
        }

        private void DeleteBooking(string bookingCode)
        {
            // ডাটাবেজ থেকে মুছে ফেলার কোড
        }

        private void ClearForm()
        {
            txtBookingCode.Text = string.Empty;
            txtAutoNo.Text = string.Empty;
            txtBookingName.Text = string.Empty;
            txtGTotal.Text = "0.00";
            gvBookingItems.DataSource = null;
            gvBookingItems.DataBind();
        }

        #endregion
    }
}