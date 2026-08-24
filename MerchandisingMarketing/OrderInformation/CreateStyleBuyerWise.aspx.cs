using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.MerchandisingMarketing.OrderInformation
{
    public partial class CreateStyleBuyerWise : System.Web.UI.Page
    {
        // ==================== IN-MEMORY MODELS (No Database) ====================
        [Serializable]
        private class SizeGroupItem
        {
            public int SizeGroupID;
            public string GroupName;
            public string SizesCsv; // "S,M,L,XL"
        }

        [Serializable]
        private class StyleRecord
        {
            public string StyleCode;
            public string StyleName;
            public string BuyerName;
            public string Category;
            public string Season;
            public string Department;
            public string UOM;
            public string SizeGroupName;
            public string Remarks;
            public List<string[]> Colors = new List<string[]>();   // [ColorName, Pantone]
            public List<string> SelectedSizes = new List<string>();
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                InitColorTable();
                BindColorGrid();
                BindSizeGroupDropdown();
                BindStyleList();
                GenerateNewStyleCode();
            }
        }

        // =====================================================================
        // SESSION HELPERS
        // =====================================================================
        private List<SizeGroupItem> GetSizeGroups()
        {
            if (Session["SizeGroups"] == null)
                Session["SizeGroups"] = new List<SizeGroupItem>();
            return (List<SizeGroupItem>)Session["SizeGroups"];
        }

        private List<StyleRecord> GetStyleList()
        {
            if (Session["StyleList"] == null)
                Session["StyleList"] = new List<StyleRecord>();
            return (List<StyleRecord>)Session["StyleList"];
        }

        // =====================================================================
        // COLOR TABLE HELPERS (ViewState এ রাখা হয়, Save করার আগ পর্যন্ত)
        // =====================================================================
        private void InitColorTable()
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("ColorSlNo", typeof(int));
            dt.Columns.Add("ColorName", typeof(string));
            dt.Columns.Add("Pantone", typeof(string));
            ViewState["ColorTable"] = dt;
        }

        private DataTable GetColorTable()
        {
            if (ViewState["ColorTable"] == null)
                InitColorTable();
            return (DataTable)ViewState["ColorTable"];
        }

        private void BindColorGrid()
        {
            gvColorList.DataSource = GetColorTable();
            gvColorList.DataBind();
        }

        // =====================================================================
        // BUTTON: Add Color  (Colorways section)
        // =====================================================================
        protected void btnAddColor_Click(object sender, EventArgs e)
        {
            string colorName = txtColorName.Text.Trim();
            string pantone = txtPantone.Text.Trim();

            if (string.IsNullOrEmpty(colorName))
            {
                ShowMessage("Color Name is required.", false);
                return;
            }

            DataTable dt = GetColorTable();
            DataRow row = dt.NewRow();
            row["ColorSlNo"] = dt.Rows.Count + 1;
            row["ColorName"] = colorName;
            row["Pantone"] = pantone;
            dt.Rows.Add(row);

            ViewState["ColorTable"] = dt;
            BindColorGrid();

            txtColorName.Text = string.Empty;
            txtPantone.Text = string.Empty;
        }

        // =====================================================================
        // GRIDVIEW: gvColorList  (Edit / Delete buttons)
        // =====================================================================
        protected void gvColorList_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int colorSlNo = Convert.ToInt32(e.CommandArgument);
            DataTable dt = GetColorTable();

            if (e.CommandName == "DeleteColor")
            {
                DataRow[] rows = dt.Select("ColorSlNo = " + colorSlNo);
                if (rows.Length > 0)
                {
                    dt.Rows.Remove(rows[0]);
                    RenumberColorSlNo(dt);
                }
            }
            else if (e.CommandName == "EditColor")
            {
                DataRow[] rows = dt.Select("ColorSlNo = " + colorSlNo);
                if (rows.Length > 0)
                {
                    // ইনপুট বক্সে ভ্যালু বসিয়ে দেওয়া, তারপর রো টি সরিয়ে ফেলা
                    // (Add Color চাপলে আপডেটেড ভ্যালু সহ আবার যোগ হবে)
                    txtColorName.Text = rows[0]["ColorName"].ToString();
                    txtPantone.Text = rows[0]["Pantone"].ToString();
                    hdnSelectedColorSlNo.Value = colorSlNo.ToString();

                    dt.Rows.Remove(rows[0]);
                    RenumberColorSlNo(dt);
                }
            }

            ViewState["ColorTable"] = dt;
            BindColorGrid();
        }

        private void RenumberColorSlNo(DataTable dt)
        {
            int sl = 1;
            foreach (DataRow r in dt.Rows)
            {
                r["ColorSlNo"] = sl;
                sl++;
            }
        }

        // =====================================================================
        // BUTTON: Save Size Group  (Modal) — In-memory, No Database
        // =====================================================================
        protected void btnSaveSizeGroup_Click(object sender, EventArgs e)
        {
            string groupName = txtNewSizeGroupName.Text.Trim();
            string sizesCsv = txtNewGroupSizes.Text.Trim();

            if (string.IsNullOrEmpty(groupName) || string.IsNullOrEmpty(sizesCsv))
            {
                ShowMessage("Size Group Name and Sizes are required.", false);
                return;
            }

            List<SizeGroupItem> groups = GetSizeGroups();
            groups.Add(new SizeGroupItem
            {
                SizeGroupID = groups.Count + 1,
                GroupName = groupName,
                SizesCsv = sizesCsv
            });
            Session["SizeGroups"] = groups;

            BindSizeGroupDropdown();

            txtNewSizeGroupName.Text = string.Empty;
            txtNewGroupSizes.Text = string.Empty;

            ShowMessage("Size Group saved successfully.", true);
        }

        private void BindSizeGroupDropdown()
        {
            List<SizeGroupItem> groups = GetSizeGroups();

            ddlSizeGroup.Items.Clear();
            ddlSizeGroup.Items.Add(new ListItem("-- Choose Size Group --", ""));

            foreach (SizeGroupItem g in groups)
                ddlSizeGroup.Items.Add(new ListItem(g.GroupName, g.SizeGroupID.ToString()));
        }

        // =====================================================================
        // DROPDOWN: Size Group selected → populate the Size checkboxes
        // =====================================================================
        protected void ddlSizeGroup_SelectedIndexChanged(object sender, EventArgs e)
        {
            chkSizes.Items.Clear();

            if (string.IsNullOrEmpty(ddlSizeGroup.SelectedValue))
                return;

            int selectedId = Convert.ToInt32(ddlSizeGroup.SelectedValue);
            SizeGroupItem group = GetSizeGroups().FirstOrDefault(g => g.SizeGroupID == selectedId);

            if (group != null)
            {
                foreach (string sz in group.SizesCsv.Split(','))
                {
                    string sizeTrim = sz.Trim();
                    if (!string.IsNullOrEmpty(sizeTrim))
                        chkSizes.Items.Add(new ListItem(sizeTrim, sizeTrim));
                }
            }
        }

        // =====================================================================
        // BUTTON: Save & New / Save & Exit / Cancel  (Footer) — In-memory
        // =====================================================================
        protected void btnSaveAndNew_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            SaveStyle();
            BindStyleList();
            ShowMessage("Style saved successfully. You can add a new style.", true);

            ClearFormForNewEntry();
        }

        protected void btnSaveAndExit_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            SaveStyle();
            BindStyleList();
            ShowMessage("Style saved successfully.", true);

            ClearFormForNewEntry();

            // ফর্ম প্যানেল থেকে লিস্ট প্যানেলে ফিরিয়ে নেওয়া (client-side panel switch)
            ScriptManager.RegisterStartupScript(this, GetType(), "goToList", "showPanel('pnlList');", true);
        }

        protected void btnCancel_Click(object sender, EventArgs e)
        {
            ClearFormForNewEntry();
            ScriptManager.RegisterStartupScript(this, GetType(), "goToList", "showPanel('pnlList');", true);
        }

        // =====================================================================
        // SAVE STYLE  (Header + Colors + Sizes → Session List, No Database)
        // =====================================================================
        private void SaveStyle()
        {
            List<StyleRecord> styleList = GetStyleList();
            string currentCode = txtStyleCode.Text.Trim();

            // Edit মোডে থাকলে (hdnStyleID এ StyleCode রাখা হয়) আগের রেকর্ডটা রিমুভ করে নতুন করে বসানো হচ্ছে
            StyleRecord existing = styleList.FirstOrDefault(s => s.StyleCode == currentCode);
            if (existing != null)
                styleList.Remove(existing);

            StyleRecord record = new StyleRecord
            {
                StyleCode = currentCode,
                StyleName = txtStyleName.Text.Trim(),
                BuyerName = ddlBuyer.SelectedItem != null ? ddlBuyer.SelectedItem.Text : "",
                Category = ddlCategory.SelectedItem != null ? ddlCategory.SelectedItem.Text : "",
                Season = ddlSeason.SelectedItem != null ? ddlSeason.SelectedItem.Text : "",
                Department = ddlDepartment.SelectedItem != null ? ddlDepartment.SelectedItem.Text : "",
                UOM = ddlUOM.SelectedItem != null ? ddlUOM.SelectedItem.Text : "",
                SizeGroupName = ddlSizeGroup.SelectedItem != null ? ddlSizeGroup.SelectedItem.Text : "",
                Remarks = txtRemarks.Text.Trim()
            };

            foreach (DataRow row in GetColorTable().Rows)
                record.Colors.Add(new[] { row["ColorName"].ToString(), row["Pantone"].ToString() });

            foreach (ListItem item in chkSizes.Items)
                if (item.Selected)
                    record.SelectedSizes.Add(item.Text);

            styleList.Add(record);
            Session["StyleList"] = styleList;
        }

        private void ClearFormForNewEntry()
        {
            hdnStyleID.Value = string.Empty;

            ddlBuyer.ClearSelection();
            txtStyleName.Text = string.Empty;
            ddlCategory.ClearSelection();
            ddlSeason.ClearSelection();
            ddlDepartment.ClearSelection();
            ddlUOM.ClearSelection();
            ddlSizeGroup.ClearSelection();
            chkSizes.Items.Clear();

            txtRemarks.Text = string.Empty;

            InitColorTable();
            BindColorGrid();

            GenerateNewStyleCode();
        }

        private void GenerateNewStyleCode()
        {
            int nextId = GetStyleList().Count + 1;
            txtStyleCode.Text = "STY-" + DateTime.Now.Year + "-" + nextId.ToString("D4");
        }

        // =====================================================================
        // LIST PANEL GRID (gvStyleList) — In-memory
        // =====================================================================
        private void BindStyleList()
        {
            gvStyleList.DataSource = GetStyleList();
            gvStyleList.DataBind();
        }

        protected void gvStyleList_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            string styleCode = e.CommandArgument.ToString();

            if (e.CommandName == "EditRow")
            {
                LoadStyleForEdit(styleCode);
                ScriptManager.RegisterStartupScript(this, GetType(), "goToForm", "showPanel('pnlForm');", true);
            }
            else if (e.CommandName == "DeleteRow")
            {
                List<StyleRecord> styleList = GetStyleList();
                StyleRecord toRemove = styleList.FirstOrDefault(s => s.StyleCode == styleCode);
                if (toRemove != null)
                    styleList.Remove(toRemove);

                Session["StyleList"] = styleList;
                BindStyleList();
            }
        }

        private void LoadStyleForEdit(string styleCode)
        {
            StyleRecord record = GetStyleList().FirstOrDefault(s => s.StyleCode == styleCode);
            if (record == null) return;

            hdnStyleID.Value = record.StyleCode;
            txtStyleCode.Text = record.StyleCode;
            txtStyleName.Text = record.StyleName;
            txtRemarks.Text = record.Remarks;

            SafeSelect(ddlBuyer, record.BuyerName);
            SafeSelect(ddlCategory, record.Category);
            SafeSelect(ddlSeason, record.Season);
            SafeSelect(ddlDepartment, record.Department);
            SafeSelect(ddlUOM, record.UOM);
            SafeSelect(ddlSizeGroup, record.SizeGroupName);

            // Selected Size Group এর ভিত্তিতে চেকবক্সগুলো লোড করা, তারপর আগের সিলেকশন বসানো
            ddlSizeGroup_SelectedIndexChanged(null, null);
            foreach (string sizeName in record.SelectedSizes)
            {
                ListItem li = chkSizes.Items.FindByText(sizeName);
                if (li != null) li.Selected = true;
            }

            // কালারগুলো ফিরিয়ে আনা
            InitColorTable();
            DataTable colorTable = GetColorTable();
            int sl = 1;
            foreach (string[] c in record.Colors)
            {
                DataRow row = colorTable.NewRow();
                row["ColorSlNo"] = sl++;
                row["ColorName"] = c[0];
                row["Pantone"] = c[1];
                colorTable.Rows.Add(row);
            }
            ViewState["ColorTable"] = colorTable;
            BindColorGrid();
        }

        private void SafeSelect(DropDownList ddl, string text)
        {
            if (string.IsNullOrEmpty(text)) return;
            ListItem item = ddl.Items.FindByText(text);
            if (item != null)
            {
                ddl.ClearSelection();
                item.Selected = true;
            }
        }

        // =====================================================================
        // MESSAGE HELPER
        // =====================================================================
        private void ShowMessage(string message, bool isSuccess)
        {
            lblMessage.Text = message;
            pnlMessage.CssClass = isSuccess
                ? "alert alert-success alert-dismissible fade show"
                : "alert alert-danger alert-dismissible fade show";
            pnlMessage.Visible = true;
        }
    }
}
