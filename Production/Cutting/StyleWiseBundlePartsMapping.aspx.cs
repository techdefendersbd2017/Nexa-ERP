using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.Production.Cutting
{
    public partial class StyleWiseBundlePartsMapping : System.Web.UI.Page
    {
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();

        // openConnection() shared connection হলে Dispose না করে শুধু Close করা হচ্ছে।
        private sealed class ConScope : IDisposable
        {
            public SqlConnection Con { get; private set; }
            public ConScope(SqlConnection con) { Con = con; }
            public void Dispose()
            {
                if (Con != null && Con.State != ConnectionState.Closed) Con.Close();
            }
        }

        // Grid এ যুক্ত করা Body Part + Embellishment (Save এর আগ পর্যন্ত ViewState এ থাকবে)
        // Embellishment null হতে পারে (Embellishment ছাড়াও Body Part সেভ হবে)
        [Serializable]
        public class MapItem
        {
            public int BodyPartId { get; set; }
            public string BodyPartName { get; set; }
            public string Embellishment { get; set; }
        }

        private List<MapItem> Items
        {
            get
            {
                var list = ViewState["MapItems"] as List<MapItem>;
                if (list == null)
                {
                    list = new List<MapItem>();
                    ViewState["MapItems"] = list;
                }
                return list;
            }
        }

        #region Page Load

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                hfUserId.Value = Session["UserId"] != null ? Session["UserId"].ToString() : "0";

                LoadBuyers();
                LoadBodyParts();
                LoadSaved();
                ResetForm();
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

        #endregion

        #region Load dropdowns

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

        // Buyer সিলেক্ট থাকলে সেই Buyer এর Style, না থাকলে সব Style
        private void LoadStyles(object buyerId)
        {
            try
            {
                Fill(ddlStyle,
                    Query(@"SELECT StyleID, StyleNo + ISNULL(' - ' + StyleName, '') AS StyleText
                            FROM dbo.StyleMaster
                            WHERE IsActive = 1 AND (@BuyerID IS NULL OR BuyerID = @BuyerID)
                            ORDER BY StyleNo",
                          P("@BuyerID", buyerId)),
                    "StyleText", "StyleID", "-- Select Style --");
            }
            catch (Exception ex) { ShowMessage("Could not load styles. " + ex.Message, false); }
        }

        // Style সিলেক্ট থাকলে সেই Style এর PO; Style না থাকলে Buyer অনুযায়ী (Buyer ও না থাকলে সব PO)
        private void LoadPOs(object buyerId, object styleId)
        {
            try
            {
                Fill(ddlPO,
                    Query(@"SELECT p.POID, p.PONo
                            FROM dbo.POHeader p
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

        private void LoadBodyParts()
        {
            try
            {
                Fill(ddlBodyPart,
                    Query("SELECT BodyPartId, Name FROM dbo.CuttingBodyPart WHERE IsActive = 1 ORDER BY Name"),
                    "Name", "BodyPartId", "-- Select Body Part --");
            }
            catch (Exception ex) { ShowMessage("Could not load body parts. " + ex.Message, false); }
        }

        private void LoadSaved()
        {
            try
            {
                gvSaved.DataSource = Query(@"
                    SELECT m.MappingId, b.BuyerName,
                           s.StyleNo + ISNULL(' - ' + s.StyleName, '') AS StyleText,
                           p.PONo, m.IsActive,
                           (SELECT COUNT(1) FROM dbo.CuttingBodyPartPrint d WHERE d.MappingId = m.MappingId) AS ItemCount
                    FROM dbo.CuttingStyleMapping m
                    INNER JOIN dbo.Buyer b       ON b.BuyerID = m.BuyerID
                    INNER JOIN dbo.StyleMaster s ON s.StyleID = m.StyleID
                    INNER JOIN dbo.POHeader p    ON p.POID    = m.POID
                    ORDER BY m.MappingId DESC");
                gvSaved.DataBind();
            }
            catch (Exception ex) { ShowMessage("Could not load saved mappings. " + ex.Message, false); }
        }

        #endregion

        #region Dropdown events (cascade)

        protected void ddlBuyer_SelectedIndexChanged(object sender, EventArgs e)
        {
            object buyer = IntOrNull(ddlBuyer.SelectedValue);
            LoadStyles(buyer);
            LoadPOs(buyer, null);
            HideMessage();
        }

        protected void ddlStyle_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadPOs(IntOrNull(ddlBuyer.SelectedValue), IntOrNull(ddlStyle.SelectedValue));
            HideMessage();
        }

        #endregion

        #region Add / Remove grid items

        protected void btnAdd_Click(object sender, EventArgs e)
        {
            if (ddlBuyer.SelectedValue == "") { ShowMessage("Please select a buyer.", false); return; }
            if (ddlStyle.SelectedValue == "") { ShowMessage("Please select a style.", false); return; }
            if (ddlPO.SelectedValue == "") { ShowMessage("Please select a PO.", false); return; }
            if (ddlBodyPart.SelectedValue == "") { ShowMessage("Please select a body part.", false); return; }

            int bodyPartId = int.Parse(ddlBodyPart.SelectedValue);

            // Embellishment ঐচ্ছিক: না বেছে নিলে null (Embellishment ছাড়া)
            string emb = ddlEmbellishment.SelectedValue == "" ? null : ddlEmbellishment.SelectedValue;

            // একই Body Part + একই Embellishment দুইবার নয়; তবে একই Body Part এ ভিন্ন Embellishment যোগ করা যাবে
            if (Items.Exists(i => i.BodyPartId == bodyPartId &&
                                  string.Equals(i.Embellishment ?? "", emb ?? "", StringComparison.OrdinalIgnoreCase)))
            {
                ShowMessage(emb == null
                    ? "This body part is already added without embellishment."
                    : "This body part with '" + emb + "' is already added.", false);
                return;
            }

            Items.Add(new MapItem
            {
                BodyPartId = bodyPartId,
                BodyPartName = ddlBodyPart.SelectedItem.Text,
                Embellishment = emb
            });

            ddlBodyPart.SelectedIndex = 0;
            ddlEmbellishment.SelectedIndex = 0;

            BindGrid();
            HideMessage();
        }

        protected void gvMap_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "RemoveItem")
            {
                int index = Convert.ToInt32(e.CommandArgument);
                if (index >= 0 && index < Items.Count) Items.RemoveAt(index);
                BindGrid();
            }
        }

        private void BindGrid()
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("Buyer");
            dt.Columns.Add("Style");
            dt.Columns.Add("PO");
            dt.Columns.Add("BodyPart");
            dt.Columns.Add("Embellishment");

            foreach (MapItem it in Items)
                dt.Rows.Add(ddlBuyer.SelectedItem.Text, ddlStyle.SelectedItem.Text,
                            ddlPO.SelectedItem.Text, it.BodyPartName,
                            string.IsNullOrWhiteSpace(it.Embellishment) ? (object)DBNull.Value : it.Embellishment);

            gvMap.DataSource = dt;
            gvMap.DataBind();

            // Item থাকলে Buyer/Style/PO লক (একটি Mapping = একটি Buyer+Style+PO)
            bool lockHeader = Items.Count > 0;
            ddlBuyer.Enabled = !lockHeader;
            ddlStyle.Enabled = !lockHeader;
            ddlPO.Enabled = !lockHeader;
        }

        #endregion

        #region Saved grid

        protected void gvSaved_SelectedIndexChanged(object sender, EventArgs e)
        {
            try
            {
                int id = Convert.ToInt32(gvSaved.SelectedDataKey.Value);

                DataTable h = Query("SELECT BuyerID, StyleID, POID, IsActive FROM dbo.CuttingStyleMapping WHERE MappingId = @Id", P("@Id", id));
                if (h.Rows.Count == 0)
                {
                    ShowMessage("Record not found.", false);
                    LoadSaved();
                    ResetForm();
                    return;
                }

                DataRow r = h.Rows[0];

                ddlBuyer.Enabled = ddlStyle.Enabled = ddlPO.Enabled = true;

                SafeSelect(ddlBuyer, r["BuyerID"].ToString());
                LoadStyles(r["BuyerID"]);
                SafeSelect(ddlStyle, r["StyleID"].ToString());
                LoadPOs(r["BuyerID"], r["StyleID"]);
                SafeSelect(ddlPO, r["POID"].ToString());

                txtStylePartsMappingId.Text = id.ToString();
                chkIsActive.Checked = Convert.ToBoolean(r["IsActive"]);

                Items.Clear();
                DataTable d = Query(@"SELECT d.BodyPartId, bp.Name, d.EmbellishmentType
                                      FROM dbo.CuttingBodyPartPrint d
                                      INNER JOIN dbo.CuttingBodyPart bp ON bp.BodyPartId = d.BodyPartId
                                      WHERE d.MappingId = @Id
                                      ORDER BY d.BodyPartPrintId", P("@Id", id));
                foreach (DataRow dr in d.Rows)
                {
                    string emb = dr["EmbellishmentType"] == DBNull.Value ? null : dr["EmbellishmentType"].ToString();
                    if (string.IsNullOrWhiteSpace(emb)) emb = null;

                    Items.Add(new MapItem
                    {
                        BodyPartId = Convert.ToInt32(dr["BodyPartId"]),
                        BodyPartName = dr["Name"].ToString(),
                        Embellishment = emb
                    });
                }

                BindGrid();

                btnDelete.Enabled = true;
                btnSave.Text = "Update";
                HideMessage();
            }
            catch (Exception ex)
            {
                ShowMessage("Could not load the record. " + ex.Message, false);
            }
        }

        #endregion

        #region Button events

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            LoadBuyers();
            LoadBodyParts();
            LoadSaved();
            ResetForm();
            HideMessage();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ResetForm();
            HideMessage();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (ddlBuyer.SelectedValue == "" || ddlStyle.SelectedValue == "" || ddlPO.SelectedValue == "")
            {
                ShowMessage("Please select buyer, style and PO.", false);
                return;
            }
            if (Items.Count == 0)
            {
                ShowMessage("Please add at least one body part.", false);
                return;
            }

            bool isNew = string.IsNullOrWhiteSpace(txtStylePartsMappingId.Text);
            int mappingId = isNew ? 0 : Convert.ToInt32(txtStylePartsMappingId.Text);
            int buyerId = int.Parse(ddlBuyer.SelectedValue);
            int styleId = int.Parse(ddlStyle.SelectedValue);
            int poId = int.Parse(ddlPO.SelectedValue);
            object userId = GetUserId();
            bool merged = false; // একই Buyer+Style+PO আগে থাকলে সেই Mapping এ যোগ হবে

            try
            {
                using (ConScope cs = new ConScope(conn.openConnection()))
                {
                    SqlTransaction tx = cs.Con.BeginTransaction();
                    try
                    {
                        // একই Buyer+Style+PO আগে থেকে থাকলে বাধা
                        object existing = ExecScalar(cs.Con, tx,
                            @"SELECT TOP 1 MappingId FROM dbo.CuttingStyleMapping
                              WHERE BuyerID = @B AND StyleID = @S AND POID = @P AND MappingId <> @M",
                            P("@B", buyerId), P("@S", styleId), P("@P", poId), P("@M", mappingId));

                        if (existing != null && existing != DBNull.Value)
                        {
                            if (!isNew)
                            {
                                // Edit করার সময় অন্য Mapping এর সাথে মিলে গেলে বাধা
                                tx.Rollback();
                                ShowMessage("A mapping already exists for this Buyer, Style and PO.", false);
                                return;
                            }

                            // নতুন এন্ট্রি, কিন্তু Mapping আগে আছে → সেই Mapping এ Body Part যোগ হবে
                            mappingId = Convert.ToInt32(existing);
                            merged = true;
                        }

                        if (merged)
                        {
                            // header অপরিবর্তিত, আগের Body Part গুলো থাকবে
                        }
                        else if (isNew)
                        {
                            mappingId = Convert.ToInt32(ExecScalar(cs.Con, tx,
                                @"INSERT INTO dbo.CuttingStyleMapping (BuyerID, StyleID, POID, IsActive, CreatedBy, CreatedDate)
                                  VALUES (@B, @S, @P, @A, @U, GETDATE());
                                  SELECT CAST(SCOPE_IDENTITY() AS INT);",
                                P("@B", buyerId), P("@S", styleId), P("@P", poId),
                                P("@A", chkIsActive.Checked), P("@U", userId)));
                        }
                        else
                        {
                            ExecScalar(cs.Con, tx,
                                @"UPDATE dbo.CuttingStyleMapping
                                  SET BuyerID = @B, StyleID = @S, POID = @P, IsActive = @A,
                                      UpdatedBy = @U, UpdatedDate = GETDATE()
                                  WHERE MappingId = @M",
                                P("@B", buyerId), P("@S", styleId), P("@P", poId),
                                P("@A", chkIsActive.Checked), P("@U", userId), P("@M", mappingId));

                            ExecScalar(cs.Con, tx, "DELETE FROM dbo.CuttingBodyPartPrint WHERE MappingId = @M", P("@M", mappingId));
                        }

                        // Embellishment null হলে DBNull হিসেবে সেভ হবে (P() নিজেই null → DBNull করে)
                        foreach (MapItem it in Items)
                        {
                            if (merged)
                            {
                                // আগে থেকে থাকা একই Body Part + Embellishment বাদ
                                object has = ExecScalar(cs.Con, tx,
                                    @"SELECT COUNT(1) FROM dbo.CuttingBodyPartPrint
                                      WHERE MappingId = @M AND BodyPartId = @BP
                                        AND ISNULL(EmbellishmentType, '') = ISNULL(@E, '')",
                                    P("@M", mappingId), P("@BP", it.BodyPartId), P("@E", it.Embellishment));
                                if (Convert.ToInt32(has) > 0) continue;
                            }

                            ExecScalar(cs.Con, tx,
                                @"INSERT INTO dbo.CuttingBodyPartPrint (MappingId, BodyPartId, EmbellishmentType)
                                  VALUES (@M, @BP, @E)",
                                P("@M", mappingId), P("@BP", it.BodyPartId), P("@E", it.Embellishment));
                        }

                        tx.Commit();
                    }
                    catch
                    {
                        tx.Rollback();
                        throw;
                    }
                }

                LoadSaved();
                ResetForm();
                if (merged)
                    ShowMessage("Body parts added to the existing mapping. ID: " + mappingId, true);
                else
                    ShowMessage(isNew ? "Mapping saved successfully. ID: " + mappingId : "Mapping updated successfully.", true);
            }
            catch (SqlException ex)
            {
                // ডিবাগের জন্য আসল error দেখানো হচ্ছে (সমস্যা মিটলে আগের সাধারণ মেসেজে ফিরিয়ে নেবেন)
                ShowMessage("Database error (" + ex.Number + "): " + ex.Message, false);
            }
            catch (Exception ex)
            {
                ShowMessage("Unexpected error: " + ex.Message, false);
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtStylePartsMappingId.Text))
            {
                ShowMessage("Please select a row to delete.", false);
                return;
            }

            int mappingId = Convert.ToInt32(txtStylePartsMappingId.Text);

            try
            {
                using (ConScope cs = new ConScope(conn.openConnection()))
                {
                    SqlTransaction tx = cs.Con.BeginTransaction();
                    try
                    {
                        ExecScalar(cs.Con, tx, "DELETE FROM dbo.CuttingBodyPartPrint WHERE MappingId = @M", P("@M", mappingId));
                        ExecScalar(cs.Con, tx, "DELETE FROM dbo.CuttingStyleMapping WHERE MappingId = @M", P("@M", mappingId));
                        tx.Commit();
                    }
                    catch
                    {
                        tx.Rollback();
                        throw;
                    }
                }

                LoadSaved();
                ResetForm();
                ShowMessage("Mapping deleted successfully.", true);
            }
            catch (SqlException ex)
            {
                if (ex.Number == 547)
                    ShowMessage("This mapping is already in use and cannot be deleted. Mark it as inactive instead.", false);
                else
                    ShowMessage("A database error occurred while deleting. Please try again.", false);
            }
            catch (Exception ex)
            {
                ShowMessage("Unexpected error: " + ex.Message, false);
            }
        }

        #endregion

        #region Helpers

        private static object ExecScalar(SqlConnection con, SqlTransaction tx, string sql, params SqlParameter[] ps)
        {
            using (SqlCommand cmd = new SqlCommand(sql, con, tx))
            {
                if (ps != null && ps.Length > 0) cmd.Parameters.AddRange(ps);
                return cmd.ExecuteScalar();
            }
        }

        private object GetUserId()
        {
            int uid;
            return int.TryParse(hfUserId.Value, out uid) && uid > 0 ? (object)uid : DBNull.Value;
        }

        private void ResetForm()
        {
            txtStylePartsMappingId.Text = "";
            chkIsActive.Checked = true;

            ddlBuyer.Enabled = ddlStyle.Enabled = ddlPO.Enabled = true;
            ddlBuyer.SelectedIndex = 0;
            LoadStyles(null);
            LoadPOs(null, null);

            ddlBodyPart.SelectedIndex = 0;
            ddlEmbellishment.SelectedIndex = 0;

            Items.Clear();
            BindGrid();

            gvSaved.SelectedIndex = -1;
            btnDelete.Enabled = false;
            btnSave.Text = "Save";
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            pnlMessage.Visible = true;
            pnlMessage.CssClass = "alert " + (isSuccess ? "alert-success" : "alert-danger") + " d-flex align-items-center gap-2";
            lblMessage.Text = Server.HtmlEncode(message);
        }

        private void HideMessage()
        {
            pnlMessage.Visible = false;
            lblMessage.Text = "";
        }

        #endregion
    }
}