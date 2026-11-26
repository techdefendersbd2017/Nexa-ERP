using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.Production.Cutting
{
    public partial class DailyCuttingTargetAndManpowerSet : System.Web.UI.Page
    {
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();

        private sealed class ConScope : IDisposable
        {
            public SqlConnection Con { get; private set; }
            public ConScope(SqlConnection con) { Con = con; }
            public void Dispose()
            {
                if (Con != null && Con.State != ConnectionState.Closed) Con.Close();
            }
        }

        [Serializable]
        public class DetailItem
        {
            public int DetailId { get; set; }
            public int BuyerId { get; set; }
            public string BuyerName { get; set; }
            public int StyleId { get; set; }
            public string StyleNo { get; set; }
            public int PoId { get; set; }
            public string PoNo { get; set; }
            public string ColorCode { get; set; }
            public decimal SMV { get; set; }
            public int OrderQty { get; set; }
            public int CutQty { get; set; }
            public int CutBalance { get; set; }
            public int DayTarget { get; set; }
            public int MarkerPcs { get; set; }
            public int LayQty { get; set; }
            public decimal ReqMin { get; set; }
            public decimal Hour { get; set; }
            public string PlanStartTime { get; set; }
            public string PlanEndTime { get; set; }
            public string Remarks { get; set; }
        }

        private List<DetailItem> Items
        {
            get
            {
                var list = ViewState["DetailItems"] as List<DetailItem>;
                if (list == null) { list = new List<DetailItem>(); ViewState["DetailItems"] = list; }
                return list;
            }
        }

        private int? EditingIndex
        {
            get { return ViewState["EditingIndex"] as int?; }
            set { ViewState["EditingIndex"] = value; }
        }

        #region Page Load

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                hfUserId.Value = Session["UserId"] != null ? Session["UserId"].ToString() : "0";
                txtDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
                LoadFloors();
                LoadTables(null);
                LoadBuyers();
                LoadStyles(null);
                LoadPOs(null, null);
                ResetForm(false);
                HideMessage();
            }
        }

        #endregion

        #region Data helpers

        private static SqlParameter P(string name, object value)
        {
            return new SqlParameter(name, value ?? DBNull.Value);
        }

        private static object IntOrNull(string s)
        {
            int v;
            return int.TryParse(s, out v) ? (object)v : null;
        }

        private DataTable Query(string sql, params SqlParameter[] ps)
        {
            using (ConScope cs = new ConScope(conn.openConnection()))
            using (SqlCommand cmd = new SqlCommand(sql, cs.Con))
            {
                if (ps != null && ps.Length > 0) cmd.Parameters.AddRange(ps);
                DataTable dt = new DataTable();
                new SqlDataAdapter(cmd).Fill(dt);
                return dt;
            }
        }

        private static object ExecScalar(SqlConnection con, SqlTransaction tx, string sql, params SqlParameter[] ps)
        {
            using (SqlCommand cmd = new SqlCommand(sql, con, tx))
            {
                if (ps != null && ps.Length > 0) cmd.Parameters.AddRange(ps);
                return cmd.ExecuteScalar();
            }
        }

        private static void Fill(DropDownList ddl, DataTable dt, string textField, string valueField, string placeholder)
        {
            ddl.DataSource = dt;
            ddl.DataTextField = textField;
            ddl.DataValueField = valueField;
            ddl.DataBind();
            ddl.Items.Insert(0, new ListItem(placeholder, ""));
        }

        private static void SafeSelect(DropDownList ddl, string value)
        {
            ListItem li = ddl.Items.FindByValue(value);
            ddl.ClearSelection();
            if (li != null) li.Selected = true;
        }

        private object GetUserId()
        {
            int uid;
            return int.TryParse(hfUserId.Value, out uid) && uid > 0 ? (object)uid : DBNull.Value;
        }

        #endregion

        #region Load dropdowns

        private void LoadFloors()
        {
            try
            {
                Fill(ddlFloor,
                    Query(@"SELECT DISTINCT FloorId, CAST(FloorId AS NVARCHAR(20)) AS FloorName
                            FROM dbo.CuttingTable ORDER BY FloorId"),
                    "FloorName", "FloorId", "-- Select Floor --");
            }
            catch (Exception ex) { ShowMessage("Could not load floors. " + ex.Message, false); }
        }

        private void LoadTables(object floorId)
        {
            try
            {
                Fill(ddlTable,
                    Query(@"SELECT CuttingTableId, Name FROM dbo.CuttingTable
                            WHERE (@FloorId IS NULL OR FloorId = @FloorId) ORDER BY Name",
                          P("@FloorId", floorId)),
                    "Name", "CuttingTableId", "-- Select Table --");
            }
            catch (Exception ex) { ShowMessage("Could not load tables. " + ex.Message, false); }
        }

        private void LoadBuyers()
        {
            try
            {
                Fill(ddlBuyer,
                    Query("SELECT BuyerID, BuyerName FROM dbo.Buyer WHERE IsActive = 1 ORDER BY BuyerName"),
                    "BuyerName", "BuyerID", "-- Select Buyer --");
            }
            catch (Exception ex) { ShowMessage("Could not load buyers. " + ex.Message, false); }
        }

        private void LoadStyles(object buyerId)
        {
            try
            {
                Fill(ddlStyleNo,
                    Query(@"SELECT StyleID, StyleNo + ISNULL(' - ' + StyleName, '') AS StyleText
                            FROM dbo.StyleMaster
                            WHERE IsActive = 1 AND (@BuyerID IS NULL OR BuyerID = @BuyerID)
                            ORDER BY StyleNo",
                          P("@BuyerID", buyerId)),
                    "StyleText", "StyleID", "-- Select Style --");
            }
            catch (Exception ex) { ShowMessage("Could not load styles. " + ex.Message, false); }
        }

        private void LoadPOs(object buyerId, object styleId)
        {
            try
            {
                Fill(ddlPoNo,
                    Query(@"SELECT p.POID, p.PONo FROM dbo.POHeader p
                            INNER JOIN dbo.StyleMaster s ON s.StyleID = p.StyleID
                            WHERE p.IsActive = 1
                              AND (@StyleID IS NULL OR p.StyleID = @StyleID)
                              AND (@BuyerID IS NULL OR s.BuyerID = @BuyerID)
                            ORDER BY p.PONo",
                          P("@StyleID", styleId), P("@BuyerID", buyerId)),
                    "PONo", "POID", "-- Select PO --");
            }
            catch (Exception ex) { ShowMessage("Could not load POs. " + ex.Message, false); }
        }

        private void LoadColors(object poId)
        {
            try
            {
                Fill(ddlColor,
                    Query(@"SELECT DISTINCT ColorCode FROM dbo.POColorSize
                            WHERE POID = @POID AND ColorCode IS NOT NULL AND ColorCode <> ''
                            ORDER BY ColorCode",
                          P("@POID", poId)),
                    "ColorCode", "ColorCode", "-- Select Color --");
            }
            catch (Exception ex) { ShowMessage("Could not load colors. " + ex.Message, false); }
        }

        #endregion

        #region Cascade events

        protected void ddlFloor_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadTables(IntOrNull(ddlFloor.SelectedValue));
            HideMessage();
        }

        protected void ddlTable_SelectedIndexChanged(object sender, EventArgs e)
        {
            // Table নির্বাচন হলে Master/Detail রিলোড করার প্রয়োজন নেই।
            // শুধু previous error clear করা হচ্ছে।
            HideMessage();
        }

        protected void ddlBuyer_SelectedIndexChanged(object sender, EventArgs e)
        {
            object buyer = IntOrNull(ddlBuyer.SelectedValue);
            LoadStyles(buyer);
            LoadPOs(buyer, null);
            ddlColor.Items.Clear();
            ddlColor.Items.Insert(0, new ListItem("-- Select Color --", ""));
            ClearBalanceFields();
            HideMessage();
        }

        protected void ddlStyleNo_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadPOs(IntOrNull(ddlBuyer.SelectedValue), IntOrNull(ddlStyleNo.SelectedValue));
            ddlColor.Items.Clear();
            ddlColor.Items.Insert(0, new ListItem("-- Select Color --", ""));
            ClearBalanceFields();
            HideMessage();
        }

        protected void ddlPoNo_SelectedIndexChanged(object sender, EventArgs e)
        {
            object poId = IntOrNull(ddlPoNo.SelectedValue);
            LoadColors(poId);
            LoadOrderInfo(poId, null);
            HideMessage();
        }

        protected void ddlColor_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadOrderInfo(IntOrNull(ddlPoNo.SelectedValue), ddlColor.SelectedValue);
            HideMessage();
        }

        private void LoadOrderInfo(object poId, string colorCode)
        {
            ClearBalanceFields();
            if (poId == null) return;

            try
            {
                DataTable dt = Query(@"
                    SELECT ISNULL(SUM(pcs.Qty), 0) AS OrderQty,
                           ISNULL(MAX(s.SMV), 0) AS SMV
                    FROM dbo.POColorSize pcs
                    INNER JOIN dbo.POHeader p ON p.POID = pcs.POID
                    INNER JOIN dbo.StyleMaster s ON s.StyleID = p.StyleID
                    WHERE pcs.POID = @POID
                      AND (@Color IS NULL OR pcs.ColorCode = @Color)",
                    P("@POID", poId),
                    P("@Color", string.IsNullOrEmpty(colorCode) ? null : colorCode));

                if (dt.Rows.Count > 0)
                {
                    txtOrderQty.Text = Convert.ToInt32(dt.Rows[0]["OrderQty"]).ToString();
                    txtCutSMV.Text = Convert.ToDecimal(dt.Rows[0]["SMV"]).ToString("0.00");
                }

                // TODO: Actual Cut Qty / Plan Cut Qty আপনার Cutting production table থেকে আনার লজিক বসান
                txtCutQty.Text = "0";
                txtPlanCutQty.Text = "0";

                int orderQty = 0, cutQty = 0;
                int.TryParse(txtOrderQty.Text, out orderQty);
                int.TryParse(txtCutQty.Text, out cutQty);
                txtCutBalance.Text = (orderQty - cutQty).ToString();
                txtUpperLimit.Text = orderQty.ToString();
            }
            catch (Exception ex)
            {
                ShowMessage("Could not load order info. " + ex.Message, false);
            }
        }

        private void ClearBalanceFields()
        {
            txtOrderQty.Text = "0";
            txtPlanCutQty.Text = "0";
            txtCutQty.Text = "0";
            txtCutBalance.Text = "0";
            txtUpperLimit.Text = "0";
            txtCutSMV.Text = "0.00";
        }

        #endregion

        #region Target hour change

        protected void txtTargetHour_TextChanged(object sender, EventArgs e)
        {
            RecalcTotals();
        }

        #endregion

        #region Add / Edit / Remove grid items

        protected void btnAdd_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(ddlBuyer.SelectedValue) ||
                string.IsNullOrEmpty(ddlStyleNo.SelectedValue) ||
                string.IsNullOrEmpty(ddlPoNo.SelectedValue) ||
                string.IsNullOrEmpty(ddlColor.SelectedValue))
            {
                ShowMessage("Please select Buyer, Style, PO and Color.", false);
                return;
            }

            int dayTarget, markerPcs, layQty;
            decimal reqMin;

            if (!int.TryParse(txtDayTarget.Text, out dayTarget) || dayTarget < 0)
            { ShowMessage("Invalid Day Target.", false); return; }
            if (!int.TryParse(txtMarkerPcs.Text, out markerPcs) || markerPcs <= 0)
            { ShowMessage("Marker Pcs is required and must be > 0.", false); return; }
            if (!int.TryParse(txtLayQty.Text, out layQty) || layQty <= 0)
            { ShowMessage("Lay Qty is required and must be > 0.", false); return; }
            if (!decimal.TryParse(txtReqMin.Text, NumberStyles.Any, CultureInfo.InvariantCulture, out reqMin) || reqMin < 0)
            { ShowMessage("Invalid Req. Min.", false); return; }

            decimal hour = Math.Round(reqMin / 60m, 2);
            decimal smv = 0;
            decimal.TryParse(txtCutSMV.Text, NumberStyles.Any, CultureInfo.InvariantCulture, out smv);

            int orderQty = 0, cutQty = 0, cutBalance = 0;
            int.TryParse(txtOrderQty.Text, out orderQty);
            int.TryParse(txtCutQty.Text, out cutQty);
            int.TryParse(txtCutBalance.Text, out cutBalance);

            var item = new DetailItem
            {
                DetailId = 0,
                BuyerId = int.Parse(ddlBuyer.SelectedValue),
                BuyerName = ddlBuyer.SelectedItem.Text,
                StyleId = int.Parse(ddlStyleNo.SelectedValue),
                StyleNo = ddlStyleNo.SelectedItem.Text,
                PoId = int.Parse(ddlPoNo.SelectedValue),
                PoNo = ddlPoNo.SelectedItem.Text,
                ColorCode = ddlColor.SelectedValue,
                SMV = smv,
                OrderQty = orderQty,
                CutQty = cutQty,
                CutBalance = cutBalance,
                DayTarget = dayTarget,
                MarkerPcs = markerPcs,
                LayQty = layQty,
                ReqMin = reqMin,
                Hour = hour,
                PlanStartTime = string.IsNullOrWhiteSpace(txtPlanStartTime.Text) ? null : txtPlanStartTime.Text,
                PlanEndTime = string.IsNullOrWhiteSpace(txtPlanEndTime.Text) ? null : txtPlanEndTime.Text,
                Remarks = txtRemark.Text.Trim()
            };

            if (EditingIndex.HasValue && EditingIndex.Value >= 0 && EditingIndex.Value < Items.Count)
            {
                Items[EditingIndex.Value] = item;
                EditingIndex = null;
                btnAdd.Text = "<i class=\"bi bi-plus-circle\"></i> Add";
            }
            else
            {
                if (Items.Exists(x => x.BuyerId == item.BuyerId && x.StyleId == item.StyleId &&
                                      x.PoId == item.PoId &&
                                      string.Equals(x.ColorCode, item.ColorCode, StringComparison.OrdinalIgnoreCase)))
                {
                    ShowMessage("This Buyer + Style + PO + Color is already added.", false);
                    return;
                }
                Items.Add(item);
            }

            ClearEntryRow();
            BindGrid();
            RecalcTotals();
            HideMessage();
        }

        protected void btnClearRow_Click(object sender, EventArgs e)
        {
            ClearEntryRow();
            EditingIndex = null;
            btnAdd.Text = "<i class=\"bi bi-plus-circle\"></i> Add";
            HideMessage();
        }

        protected void GridView2_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            int index;
            if (!int.TryParse(e.CommandArgument.ToString(), out index)) return;
            if (index < 0 || index >= Items.Count) return;

            if (e.CommandName == "DeleteRow")
            {
                Items.RemoveAt(index);
                BindGrid();
                RecalcTotals();
            }
            else if (e.CommandName == "EditRow")
            {
                var it = Items[index];
                EditingIndex = index;

                SafeSelect(ddlBuyer, it.BuyerId.ToString());
                LoadStyles(it.BuyerId);
                SafeSelect(ddlStyleNo, it.StyleId.ToString());
                LoadPOs(it.BuyerId, it.StyleId);
                SafeSelect(ddlPoNo, it.PoId.ToString());
                LoadColors(it.PoId);
                SafeSelect(ddlColor, it.ColorCode);

                txtDayTarget.Text = it.DayTarget.ToString();
                txtMarkerPcs.Text = it.MarkerPcs.ToString();
                txtLayQty.Text = it.LayQty.ToString();
                txtReqMin.Text = it.ReqMin.ToString("0.##");
                txtHour.Text = it.Hour.ToString("0.##");
                txtPlanStartTime.Text = it.PlanStartTime ?? "";
                txtPlanEndTime.Text = it.PlanEndTime ?? "";
                txtRemark.Text = it.Remarks ?? "";

                txtOrderQty.Text = it.OrderQty.ToString();
                txtCutQty.Text = it.CutQty.ToString();
                txtCutBalance.Text = it.CutBalance.ToString();
                txtCutSMV.Text = it.SMV.ToString("0.00");

                btnAdd.Text = "<i class=\"bi bi-check2\"></i> Update Row";
            }
        }

        private void ClearEntryRow()
        {
            ddlBuyer.SelectedIndex = 0;
            LoadStyles(null);
            LoadPOs(null, null);
            ddlColor.Items.Clear();
            ddlColor.Items.Insert(0, new ListItem("-- Select Color --", ""));

            txtDayTarget.Text = "0";
            txtMarkerPcs.Text = "0";
            txtLayQty.Text = "0";
            txtReqMin.Text = "0";
            txtHour.Text = "0";
            txtPlanStartTime.Text = "";
            txtPlanEndTime.Text = "";
            txtRemark.Text = "";
            ClearBalanceFields();
        }

        private void BindGrid()
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("Buyer"); dt.Columns.Add("StyleNo"); dt.Columns.Add("PoNo");
            dt.Columns.Add("Color"); dt.Columns.Add("SMV"); dt.Columns.Add("OrderQty");
            dt.Columns.Add("CutQty"); dt.Columns.Add("CutBalance"); dt.Columns.Add("DayTarget");
            dt.Columns.Add("MarkerPcs"); dt.Columns.Add("LayQty"); dt.Columns.Add("ReqMin");
            dt.Columns.Add("Hour"); dt.Columns.Add("StartTime"); dt.Columns.Add("EndTime");
            dt.Columns.Add("Remarks");

            foreach (var it in Items)
            {
                dt.Rows.Add(
                    it.BuyerName, it.StyleNo, it.PoNo, it.ColorCode,
                    it.SMV.ToString("0.00"), it.OrderQty, it.CutQty, it.CutBalance,
                    it.DayTarget, it.MarkerPcs, it.LayQty, it.ReqMin.ToString("0.##"),
                    it.Hour.ToString("0.##"), it.PlanStartTime ?? "",
                    it.PlanEndTime ?? "", it.Remarks ?? "");
            }

            GridView2.DataSource = dt;
            GridView2.DataBind();
        }

        private void RecalcTotals()
        {
            lblTotalDayTarget.Text = Items.Sum(x => x.DayTarget).ToString();

            decimal totalReqMin = Items.Sum(x => x.ReqMin);
            decimal calcHour = Math.Round(totalReqMin / 60m, 2);
            txtCalculativeHour.Text = calcHour.ToString("0.##");

            decimal tgtHour = 0;
            decimal.TryParse(txtTargetHour.Text, NumberStyles.Any, CultureInfo.InvariantCulture, out tgtHour);

            txtTargetEfficiency.Text = tgtHour > 0
                ? Math.Round((calcHour / tgtHour) * 100m, 2).ToString("0.##")
                : "0";
        }

        #endregion

        #region Show / Copy / Save / Delete

        protected void btnShow_Click(object sender, EventArgs e)
        {
            LoadMasterAndDetails();
        }

        protected void btnCopy_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(txtDate.Text) ||
                string.IsNullOrEmpty(ddlFloor.SelectedValue) ||
                string.IsNullOrEmpty(ddlTable.SelectedValue))
            {
                ShowMessage("Please select Date, Floor and Table first.", false);
                return;
            }

            try
            {
                DateTime targetDate = DateTime.Parse(txtDate.Text);
                int floorId = int.Parse(ddlFloor.SelectedValue);
                int tableId = int.Parse(ddlTable.SelectedValue);

                DataTable prev = Query(@"
                    SELECT TOP 1 * FROM dbo.Cutting_DailyTargetMaster
                    WHERE TargetDate < @D AND FloorId = @F AND CuttingTableId = @T
                    ORDER BY TargetDate DESC",
                    P("@D", targetDate), P("@F", floorId), P("@T", tableId));

                if (prev.Rows.Count == 0)
                {
                    ShowMessage("No previous target found for this Floor + Table.", false);
                    return;
                }

                DataRow m = prev.Rows[0];
                int prevMasterId = Convert.ToInt32(m["MasterId"]);

                // Master fields copy
                txtTargetHour.Text = m["TargetHour"] == DBNull.Value ? "" : Convert.ToDecimal(m["TargetHour"]).ToString("0.##");
                txtCuttingMan.Text = m["CuttingMan"].ToString();
                txtCuttingAssistant.Text = m["CuttingAssistant"].ToString();
                if (m["Remarks"] != DBNull.Value) txtRemarks.Text = m["Remarks"].ToString();
                if (m["IsActive"] != DBNull.Value) chkIsActive.Checked = Convert.ToBoolean(m["IsActive"]);

                // Detail rows copy
                LoadDetailsIntoGrid(prevMasterId, copyMode: true);
                ViewState["CurrentMasterId"] = null;   // copy মানে নতুন record হিসেবে save হবে

                ShowMessage("Copied from " + Convert.ToDateTime(m["TargetDate"]).ToString("dd-MMM-yyyy"), true);
            }
            catch (Exception ex)
            {
                ShowMessage("Copy failed. " + ex.Message, false);
            }
        }

        private void LoadMasterAndDetails()
        {
            if (string.IsNullOrEmpty(txtDate.Text) ||
                string.IsNullOrEmpty(ddlFloor.SelectedValue) ||
                string.IsNullOrEmpty(ddlTable.SelectedValue))
            {
                ShowMessage("Please select Date, Floor and Table.", false);
                return;
            }

            try
            {
                DateTime targetDate = DateTime.Parse(txtDate.Text);
                int floorId = int.Parse(ddlFloor.SelectedValue);
                int tableId = int.Parse(ddlTable.SelectedValue);

                DataTable master = Query(@"
                    SELECT * FROM dbo.Cutting_DailyTargetMaster
                    WHERE TargetDate = @D AND FloorId = @F AND CuttingTableId = @T",
                    P("@D", targetDate), P("@F", floorId), P("@T", tableId));

                if (master.Rows.Count == 0)
                {
                    ShowMessage("No data found for this Date + Floor + Table.", false);
                    Items.Clear(); BindGrid(); RecalcTotals();
                    ViewState["CurrentMasterId"] = null;
                    return;
                }

                DataRow m = master.Rows[0];
                ViewState["CurrentMasterId"] = Convert.ToInt32(m["MasterId"]);

                txtTargetHour.Text = Convert.ToDecimal(m["TargetHour"]).ToString("0.##");
                txtCalculativeHour.Text = m["CalculativeHour"] == DBNull.Value ? "" : Convert.ToDecimal(m["CalculativeHour"]).ToString("0.##");
                txtTargetEfficiency.Text = m["TargetEfficiency"] == DBNull.Value ? "" : Convert.ToDecimal(m["TargetEfficiency"]).ToString("0.####");
                txtCuttingMan.Text = m["CuttingMan"].ToString();
                txtCuttingAssistant.Text = m["CuttingAssistant"].ToString();
                txtRemarks.Text = m["Remarks"] == DBNull.Value ? "" : m["Remarks"].ToString();
                chkIsActive.Checked = Convert.ToBoolean(m["IsActive"]);

                LoadDetailsIntoGrid(Convert.ToInt32(m["MasterId"]), copyMode: false);
                ShowMessage("Data loaded successfully.", true);
            }
            catch (Exception ex)
            {
                ShowMessage("Could not load data. " + ex.Message, false);
            }
        }

        private void LoadDetailsIntoGrid(int masterId, bool copyMode)
        {
            Items.Clear();

            DataTable d = Query(@"
                SELECT d.DetailId, d.BuyerId, b.BuyerName, d.StyleId, s.StyleNo,
                       d.PoId, p.PONo, d.ColorCode, d.SMV, d.OrderQty, d.CutQty, d.CutBalance,
                       d.DayTarget, d.MarkerPcs, d.LayQty, d.ReqMin, d.[Hour],
                       CONVERT(VARCHAR(5), d.PlanStartTime, 108) AS PlanStartTime,
                       CONVERT(VARCHAR(5), d.PlanEndTime, 108) AS PlanEndTime,
                       d.Remarks
                FROM dbo.Cutting_DailyTargetDetail d
                JOIN dbo.Buyer b       ON b.BuyerID = d.BuyerId
                JOIN dbo.StyleMaster s ON s.StyleID = d.StyleId
                JOIN dbo.POHeader   p  ON p.POID    = d.PoId
                WHERE d.MasterId = @M
                ORDER BY d.DetailId",
                P("@M", masterId));

            foreach (DataRow r in d.Rows)
            {
                Items.Add(new DetailItem
                {
                    DetailId = copyMode ? 0 : Convert.ToInt32(r["DetailId"]),
                    BuyerId = Convert.ToInt32(r["BuyerId"]),
                    BuyerName = r["BuyerName"].ToString(),
                    StyleId = Convert.ToInt32(r["StyleId"]),
                    StyleNo = r["StyleNo"].ToString(),
                    PoId = Convert.ToInt32(r["PoId"]),
                    PoNo = r["PONo"].ToString(),
                    ColorCode = r["ColorCode"].ToString(),
                    SMV = r["SMV"] == DBNull.Value ? 0 : Convert.ToDecimal(r["SMV"]),
                    OrderQty = Convert.ToInt32(r["OrderQty"]),
                    CutQty = Convert.ToInt32(r["CutQty"]),
                    CutBalance = Convert.ToInt32(r["CutBalance"]),
                    DayTarget = Convert.ToInt32(r["DayTarget"]),
                    MarkerPcs = Convert.ToInt32(r["MarkerPcs"]),
                    LayQty = Convert.ToInt32(r["LayQty"]),
                    ReqMin = Convert.ToDecimal(r["ReqMin"]),
                    Hour = Convert.ToDecimal(r["Hour"]),
                    PlanStartTime = r["PlanStartTime"] == DBNull.Value ? null : r["PlanStartTime"].ToString(),
                    PlanEndTime = r["PlanEndTime"] == DBNull.Value ? null : r["PlanEndTime"].ToString(),
                    Remarks = r["Remarks"] == DBNull.Value ? null : r["Remarks"].ToString()
                });
            }

            BindGrid();
            RecalcTotals();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(txtDate.Text) ||
                string.IsNullOrEmpty(ddlFloor.SelectedValue) ||
                string.IsNullOrEmpty(ddlTable.SelectedValue))
            { ShowMessage("Please select Date, Floor and Table.", false); return; }

            if (Items.Count == 0)
            { ShowMessage("Please add at least one row.", false); return; }

            decimal targetHour = 0;
            int cuttingMan = 0, cuttingAssistant = 0;
            decimal.TryParse(txtTargetHour.Text, NumberStyles.Any, CultureInfo.InvariantCulture, out targetHour);
            int.TryParse(txtCuttingMan.Text, out cuttingMan);
            int.TryParse(txtCuttingAssistant.Text, out cuttingAssistant);

            if (targetHour <= 0)
            { ShowMessage("Target Hour must be greater than 0.", false); return; }

            try
            {
                DateTime targetDate = DateTime.Parse(txtDate.Text);
                int floorId = int.Parse(ddlFloor.SelectedValue);
                int tableId = int.Parse(ddlTable.SelectedValue);
                object userId = GetUserId();

                decimal calcHour = 0, tgtEff = 0;
                decimal.TryParse(txtCalculativeHour.Text, NumberStyles.Any, CultureInfo.InvariantCulture, out calcHour);
                decimal.TryParse(txtTargetEfficiency.Text, NumberStyles.Any, CultureInfo.InvariantCulture, out tgtEff);

                using (ConScope cs = new ConScope(conn.openConnection()))
                {
                    SqlTransaction tx = cs.Con.BeginTransaction();
                    try
                    {
                        object masterIdObj = ExecScalar(cs.Con, tx, @"
                            DECLARE @MasterId INT;
                            SELECT @MasterId = MasterId FROM dbo.Cutting_DailyTargetMaster
                            WHERE TargetDate = @D AND FloorId = @F AND CuttingTableId = @T;

                            IF @MasterId IS NULL
                            BEGIN
                                INSERT INTO dbo.Cutting_DailyTargetMaster
                                    (TargetDate, FloorId, CuttingTableId, TargetHour, CalculativeHour, TargetEfficiency,
                                     CuttingMan, CuttingAssistant, Remarks, IsActive, CreatedBy)
                                VALUES
                                    (@D, @F, @T, @TH, @CH, @TE, @CM, @CA, @R, @A, @U);
                                SET @MasterId = SCOPE_IDENTITY();
                            END
                            ELSE
                            BEGIN
                                UPDATE dbo.Cutting_DailyTargetMaster
                                SET TargetHour = @TH, CalculativeHour = @CH, TargetEfficiency = @TE,
                                    CuttingMan = @CM, CuttingAssistant = @CA, Remarks = @R,
                                    IsActive = @A, UpdatedBy = @U, UpdatedDate = GETDATE()
                                WHERE MasterId = @MasterId;
                            END
                            SELECT @MasterId;",
                            P("@D", targetDate), P("@F", floorId), P("@T", tableId),
                            P("@TH", targetHour), P("@CH", calcHour), P("@TE", tgtEff),
                            P("@CM", cuttingMan), P("@CA", cuttingAssistant),
                            P("@R", string.IsNullOrWhiteSpace(txtRemarks.Text) ? null : txtRemarks.Text),
                            P("@A", chkIsActive.Checked), P("@U", userId));

                        int masterId = Convert.ToInt32(masterIdObj);
                        ViewState["CurrentMasterId"] = masterId;

                        ExecScalar(cs.Con, tx,
                            "DELETE FROM dbo.Cutting_DailyTargetDetail WHERE MasterId = @M",
                            P("@M", masterId));

                        foreach (var it in Items)
                        {
                            ExecScalar(cs.Con, tx, @"
                                INSERT INTO dbo.Cutting_DailyTargetDetail
                                    (MasterId, BuyerId, StyleId, PoId, ColorCode, SMV, OrderQty, CutQty, CutBalance,
                                     DayTarget, MarkerPcs, LayQty, ReqMin, PlanStartTime, PlanEndTime, Remarks)
                                VALUES
                                    (@M, @B, @S, @P, @C, @SMV, @OQ, @CQ, @CB,
                                     @DT, @MP, @LQ, @RM, @ST, @ET, @R)",
                                P("@M", masterId),
                                P("@B", it.BuyerId), P("@S", it.StyleId), P("@P", it.PoId), P("@C", it.ColorCode),
                                P("@SMV", it.SMV), P("@OQ", it.OrderQty), P("@CQ", it.CutQty), P("@CB", it.CutBalance),
                                P("@DT", it.DayTarget), P("@MP", it.MarkerPcs), P("@LQ", it.LayQty), P("@RM", it.ReqMin),
                                P("@ST", string.IsNullOrEmpty(it.PlanStartTime) ? null : (object)TimeSpan.Parse(it.PlanStartTime)),
                                P("@ET", string.IsNullOrEmpty(it.PlanEndTime) ? null : (object)TimeSpan.Parse(it.PlanEndTime)),
                                P("@R", string.IsNullOrWhiteSpace(it.Remarks) ? null : it.Remarks));
                        }

                        tx.Commit();
                        ShowMessage("Saved successfully. Master ID: " + masterId, true);
                    }
                    catch { tx.Rollback(); throw; }
                }
            }
            catch (SqlException ex) { ShowMessage("Database error (" + ex.Number + "): " + ex.Message, false); }
            catch (Exception ex) { ShowMessage("Unexpected error: " + ex.Message, false); }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            object mid = ViewState["CurrentMasterId"];
            if (mid == null)
            { ShowMessage("No record loaded to delete. Please click Show first.", false); return; }

            try
            {
                using (ConScope cs = new ConScope(conn.openConnection()))
                {
                    SqlTransaction tx = cs.Con.BeginTransaction();
                    try
                    {
                        ExecScalar(cs.Con, tx,
                            "DELETE FROM dbo.Cutting_DailyTargetMaster WHERE MasterId = @M",
                            P("@M", mid));
                        tx.Commit();
                    }
                    catch { tx.Rollback(); throw; }
                }

                ViewState["CurrentMasterId"] = null;
                Items.Clear(); BindGrid(); RecalcTotals();
                ResetForm(false);
                ShowMessage("Deleted successfully.", true);
            }
            catch (SqlException ex)
            {
                if (ex.Number == 547)
                    ShowMessage("This record is in use and cannot be deleted.", false);
                else
                    ShowMessage("Database error while deleting. " + ex.Message, false);
            }
            catch (Exception ex) { ShowMessage("Unexpected error: " + ex.Message, false); }
        }

        #endregion

        #region Other buttons

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            LoadFloors();
            LoadTables(null);
            LoadBuyers();
            ResetForm(true);
            HideMessage();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ResetForm(true);
            HideMessage();
        }

        protected void btnCutingTargetSheet_Click(object sender, EventArgs e)
        {
            // TODO: Report / Export
            ShowMessage("Cutting Target Sheet feature will be implemented later.", true);
        }

        private void ResetForm(bool clearDate)
        {
            if (clearDate) txtDate.Text = DateTime.Today.ToString("yyyy-MM-dd");

            ddlFloor.SelectedIndex = 0;
            LoadTables(null);
            txtRemarks.Text = "";

            txtTargetHour.Text = "";
            txtCalculativeHour.Text = "";
            txtTargetEfficiency.Text = "";
            txtCuttingMan.Text = "";
            txtCuttingAssistant.Text = "";

            ClearEntryRow();
            Items.Clear();
            BindGrid();
            RecalcTotals();

            chkIsActive.Checked = true;
            ViewState["CurrentMasterId"] = null;
            EditingIndex = null;
            btnAdd.Text = "<i class=\"bi bi-plus-circle\"></i> Add";
        }

        #endregion

        #region Message helpers

        private void ShowMessage(string message, bool isSuccess)
        {
            // পেজে ScriptManager নেই, তাই ClientScript ব্যবহার করা হয়েছে
            string safe = message.Replace("'", "\\'").Replace("\r", " ").Replace("\n", " ");
            string prefix = isSuccess ? "Success: " : "Error: ";
            string script = "alert('" + prefix + safe + "');";
            Page.ClientScript.RegisterStartupScript(GetType(), "msg_" + Guid.NewGuid().ToString("N"), script, true);
        }

        private void HideMessage() { }

        #endregion
    }
}