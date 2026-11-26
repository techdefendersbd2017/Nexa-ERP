using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.MasterConfiguration.BuyerManagement
{
    public partial class FabricBookingSheet : System.Web.UI.Page
    {
        // ---- কোম্পানির তথ্য (দরকার হলে এখানে বদলান) ----
        const string CompanyName = "Pantex Dress Ltd.";
        const string CompanyAddr = "Plot #56, Hariharpara, Enayatnagar, BSCIC Area, Fatullah, Narayanganj-1420";
        const string LogoPath = "~/images/logo.png";

        SqlConnection con;
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();

        // ============================================================
        // PAGE LOAD
        // ============================================================
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            lblUser.Text = Session["UserName"] != null ? Convert.ToString(Session["UserName"]) : "User";
            LoadPODropdown();

            int qPo;
            if (int.TryParse(Request.QueryString["poid"], out qPo) && qPo > 0)
            {
                ListItem it = ddlPO.Items.FindByValue(qPo.ToString());
                if (it != null) { ddlPO.ClearSelection(); it.Selected = true; ddlBooked.SelectedValue = ""; }
            }
            if (ddlPO.SelectedValue != "0") ShowSheet();
        }

        protected void btnShow_Click(object sender, EventArgs e) { ShowSheet(); }

        // ============================================================
        // HELPERS
        // ============================================================
        private void ShowAlert(string msg)
        {
            string safe = (msg ?? "").Replace("'", "").Replace("\r", "").Replace("\n", " ");
            ScriptManager.RegisterStartupScript(this, GetType(), Guid.NewGuid().ToString("N"), "alert('" + safe + "');", true);
        }

        private void CloseConnection()
        {
            if (con != null && con.State == ConnectionState.Open) con.Close();
        }

        private DataTable Q(string sql, params SqlParameter[] ps)
        {
            DataTable dt = new DataTable();
            try
            {
                con = conn.openConnection();
                using (SqlCommand c = new SqlCommand(sql, con))
                {
                    if (ps != null) c.Parameters.AddRange(ps);
                    new SqlDataAdapter(c).Fill(dt);
                }
            }
            finally { CloseConnection(); }
            return dt;
        }

        private static string H(string s) { return HttpUtility.HtmlEncode(s ?? ""); }

        // প্রথম যে কলামটা আছে ও ফাঁকা নয়, তার মান দেয় (কলাম না থাকলে ফাঁকা)
        private static string G(DataRow r, params string[] names)
        {
            if (r == null) return "";
            foreach (string n in names)
                if (r.Table.Columns.Contains(n) && r[n] != DBNull.Value && r[n].ToString().Trim().Length > 0)
                    return r[n].ToString().Trim();
            return "";
        }

        private static DateTime? GD(DataRow r, params string[] names)
        {
            DateTime d;
            return DateTime.TryParse(G(r, names), out d) ? (DateTime?)d : null;
        }

        private static string D(DateTime? d) { return d.HasValue ? d.Value.ToString("d-MMM-yy", CultureInfo.InvariantCulture) : ""; }

        private static decimal N(DataRow r, params string[] names)
        {
            decimal v;
            return decimal.TryParse(G(r, names), out v) ? v : 0m;
        }

        private static string F2(decimal v) { return v.ToString("N2", CultureInfo.InvariantCulture); }

        private static int SizeRank(string s)
        {
            string[] order = { "XXS", "XS", "S", "M", "L", "XL", "XXL", "2XL", "3XL", "XXXL", "4XL", "5XL" };
            int i = Array.IndexOf(order, (s ?? "").ToUpper());
            return i < 0 ? 100 : i;
        }

        // ============================================================
        // PO DROPDOWN
        // ============================================================
        private void LoadPODropdown()
        {
            try
            {
                DataTable dt = Q(@"SELECT p.POID, p.PONo FROM dbo.POHeader p
                                   WHERE ISNULL(p.IsActive,1)=1
                                     AND EXISTS (SELECT 1 FROM dbo.POFabricBooking f WHERE f.POID=p.POID)
                                   ORDER BY p.POID DESC");
                ddlPO.DataSource = dt;
                ddlPO.DataTextField = "PONo";
                ddlPO.DataValueField = "POID";
                ddlPO.DataBind();
                ddlPO.Items.Insert(0, new ListItem("-- Select PO --", "0"));
            }
            catch (Exception ex) { ShowAlert("PO list error: " + ex.Message); }
        }

        // ============================================================
        // BUILD SHEET
        // ============================================================
        private void ShowSheet()
        {
            int poId;
            if (!int.TryParse(ddlPO.SelectedValue, out poId) || poId <= 0)
            {
                pnlSheet.Visible = false;
                ShowAlert("Please select a PO.");
                return;
            }

            try
            {
                DataTable hdr = Q(@"SELECT p.*, b.BuyerName, s.StyleNo AS S_StyleNo
                                    FROM dbo.POHeader p
                                    LEFT JOIN dbo.StyleMaster s ON s.StyleID = p.StyleID
                                    LEFT JOIN dbo.Buyer b       ON b.BuyerID = s.BuyerID
                                    WHERE p.POID=@id", new SqlParameter("@id", poId));
                if (hdr.Rows.Count == 0) { pnlSheet.Visible = false; ShowAlert("PO not found."); return; }
                DataRow h = hdr.Rows[0];

                string sql = "SELECT f.* FROM dbo.POFabricBooking f WHERE f.POID=@id";
                if (ddlBooked.SelectedValue == "1") sql += " AND f.IsBooked=1";
                sql += " ORDER BY f.FabricCode, f.ColorCode, f.PartName, f.SizeCode";
                DataTable bk = Q(sql, new SqlParameter("@id", poId));

                // কালার x সাইজ কোয়ান্টিটি (টেবিল না থাকলে বুকিং লাইন থেকে হিসাব)
                DataTable cs = null;
                try { cs = Q("SELECT * FROM dbo.POColorSize WHERE POID=@id", new SqlParameter("@id", poId)); }
                catch { cs = null; }

                StringBuilder sb = new StringBuilder();
                AppendHeader(sb, h);
                decimal orderQty = AppendBreakdown(sb, h, cs, bk);
                AppendFabrics(sb, bk);
                AppendSign(sb, h);

                // Order Qty হেডারে বসানো (ডাটাবেসে না থাকলে breakdown এর মোট)
                litSheet.Text = sb.ToString().Replace("{{ORDERQTY}}", orderQty.ToString("N0", CultureInfo.InvariantCulture));
                pnlSheet.Visible = true;
            }
            catch (Exception ex)
            {
                CloseConnection();
                ShowAlert("Sheet error: " + ex.Message);
            }
        }

        // ---------------- HEADER ----------------
        private void AppendHeader(StringBuilder sb, DataRow h)
        {
            DateTime? rcv = GD(h, "PORcvDate", "PORecvDate", "POReceiveDate", "PODate");
            DateTime? ship = GD(h, "ShipmentDate", "ShipDate", "DeliveryDate");
            string lead = G(h, "LeadTime");
            if (lead == "" && rcv.HasValue && ship.HasValue) lead = ((int)(ship.Value - rcv.Value).TotalDays) + " Days";

            string styleNo = G(h, "S_StyleNo", "StyleNo");
            string img = G(h, "StyleImage", "ImagePath", "Image");

            sb.Append("<div class='co'><div class='name'>" + H(CompanyName) + "</div>");
            sb.Append("<div class='addr'>" + H(CompanyAddr) + "</div>");
            sb.Append("<div class='title'>FABRICS BOOKING SHEET</div></div>");

            sb.Append("<div class='hdr'>");

            // logo + বাম কলাম
            sb.Append("<div class='logo'><img src='" + ResolveUrl(LogoPath) + "' onerror=\"this.style.display='none'\" /></div>");

            sb.Append("<table>");
            Row(sb, "Job No.", G(h, "JobNo"));
            Row(sb, "Buyer Name", G(h, "BuyerName"));
            Row(sb, "Article / PO", G(h, "PONo"));
            Row(sb, "Style", styleNo);
            Row(sb, "Season", G(h, "Season"));
            Row(sb, "Order Qty", "{{ORDERQTY}} (PCS)");
            sb.Append("</table>");

            sb.Append("<table>");
            Row(sb, "Buyer Brand", G(h, "BuyerBrand", "Brand"));
            Row(sb, "Po Rcv Date", D(rcv));
            Row(sb, "B.Release Date", D(GD(h, "BReleaseDate", "ReleaseDate", "BookingReleaseDate")));
            Row(sb, "Fabric Source", G(h, "FabricSource"));
            Row(sb, "Embellishment", G(h, "Embellishment"));
            sb.Append("</table>");

            sb.Append("<table>");
            Row(sb, "Shipment Date", D(ship));
            Row(sb, "Ship Mode", G(h, "ShipMode"));
            Row(sb, "Lead Time", lead);
            Row(sb, "Item Type", G(h, "ItemType"));
            Row(sb, "Dealing Merchant", G(h, "DealingMerchant", "MerchantName"));
            Row(sb, "Update Date", D(GD(h, "UpdateDate", "UpdatedOn", "ModifiedDate")));
            sb.Append("</table>");

            sb.Append("<div class='img'>");
            if (img != "") sb.Append("<img src='" + ResolveUrl(img.StartsWith("~") ? img : "~/" + img.TrimStart('/')) + "' onerror=\"this.style.display='none'\" />");
            sb.Append("</div>");

            sb.Append("</div>");
        }

        private static void Row(StringBuilder sb, string label, string val)
        {
            sb.Append("<tr><td class='l'>" + H(label) + "</td><td>: " + H(val) + "</td></tr>");
        }

        // ---------------- ORDER BREAKDOWN ----------------
        // রিটার্ন: মোট Order Qty
        private decimal AppendBreakdown(StringBuilder sb, DataRow h, DataTable cs, DataTable bk)
        {
            string poNo = G(h, "PONo");
            string styleNo = G(h, "S_StyleNo", "StyleNo");

            List<string> sizes = new List<string>();
            // color -> (size -> qty), color -> shipDate
            Dictionary<string, Dictionary<string, decimal>> data = new Dictionary<string, Dictionary<string, decimal>>();
            Dictionary<string, string> ship = new Dictionary<string, string>();
            List<string> colors = new List<string>();

            bool useCs = cs != null && cs.Rows.Count > 0 && cs.Columns.Contains("ColorCode") && cs.Columns.Contains("SizeCode");
            if (useCs)
            {
                foreach (DataRow r in cs.Rows)
                {
                    string c = G(r, "ColorCode"), s = G(r, "SizeCode");
                    if (!data.ContainsKey(c)) { data[c] = new Dictionary<string, decimal>(); colors.Add(c); }
                    if (!sizes.Contains(s)) sizes.Add(s);
                    decimal q = N(r, "Qty", "OrderQty");
                    decimal old; data[c].TryGetValue(s, out old); data[c][s] = old + q;
                    string sd = D(GD(r, "ShipDate", "ShipmentDate"));
                    if (sd != "" && !ship.ContainsKey(c)) ship[c] = sd;
                }
                sizes = sizes.OrderBy(x => SizeRank(x)).ThenBy(x => x).ToList();
            }
            else
            {
                // fallback: বুকিং লাইন থেকে কালার-wise Qty (একই কালারের Part এর সর্বোচ্চ Qty)
                sizes.Add("ALL");
                foreach (var g in bk.AsEnumerable().GroupBy(r => G(r, "ColorCode")))
                {
                    colors.Add(g.Key);
                    data[g.Key] = new Dictionary<string, decimal>();
                    data[g.Key]["ALL"] = g.Max(r => N(r, "Qty"));
                }
            }

            string hdrShip = D(GD(h, "ShipmentDate", "ShipDate", "DeliveryDate"));

            sb.Append("<div class='sec-title'>Order Breakdown</div>");
            sb.Append("<table class='t'><tr><th class='ob'>Style No</th><th class='ob'>Po No</th><th class='ob' style='min-width:200px'>Main Color</th><th class='ob'>Ship Date</th>");
            foreach (string s in sizes) sb.Append("<th class='ob'>" + H(s) + "</th>");
            sb.Append("<th class='ob'>Total</th></tr>");

            Dictionary<string, decimal> colTot = new Dictionary<string, decimal>();
            decimal grand = 0m;
            foreach (string c in colors)
            {
                string sd; if (!ship.TryGetValue(c, out sd)) sd = hdrShip;
                sb.Append("<tr><td>" + H(styleNo) + "</td><td>" + H(poNo) + "</td><td style='text-align:left'>" + H(c) + "</td><td>" + H(sd) + "</td>");
                decimal rowTot = 0m;
                foreach (string s in sizes)
                {
                    decimal q; data[c].TryGetValue(s, out q);
                    rowTot += q;
                    decimal ct; colTot.TryGetValue(s, out ct); colTot[s] = ct + q;
                    sb.Append("<td class='num'>" + q.ToString("N0", CultureInfo.InvariantCulture) + "</td>");
                }
                grand += rowTot;
                sb.Append("<td class='num'><b>" + rowTot.ToString("N0", CultureInfo.InvariantCulture) + "</b></td></tr>");
            }
            sb.Append("<tr class='gt'><td colspan='4' class='num'>Grand Total</td>");
            foreach (string s in sizes)
            {
                decimal q; colTot.TryGetValue(s, out q);
                sb.Append("<td class='num'>" + q.ToString("N0", CultureInfo.InvariantCulture) + "</td>");
            }
            sb.Append("<td class='num'>" + grand.ToString("N0", CultureInfo.InvariantCulture) + "</td></tr></table>");

            // PO তে TotalQty / OrderQty কলাম থাকলে সেটাই ব্যবহার
            decimal poQty = N(h, "OrderQty", "TotalQty", "POQty");
            return poQty > 0 ? poQty : grand;
        }

        // ---------------- FABRIC BOOKING + YARN ----------------
        private void AppendFabrics(StringBuilder sb, DataTable bk)
        {
            // yarn description -> label (A, B, C ...)
            Dictionary<string, string> yarnLabel = new Dictionary<string, string>();
            Dictionary<string, decimal> yarnQty = new Dictionary<string, decimal>();
            List<string> yarnOrder = new List<string>();

            var fabGroups = bk.AsEnumerable()
                .GroupBy(r => G(r, "FabricCode") + "|" + G(r, "FabricName") + "|" + G(r, "GSM") + "|" + G(r, "FabricForm"));

            int n = 0;
            foreach (var fg in fabGroups)
            {
                n++;
                DataRow first = fg.First();
                string yarnDesc = G(first, "YarnDesc", "YarnDescription", "YarnCount", "Yarn");
                if (yarnDesc.Equals("Yes", StringComparison.OrdinalIgnoreCase) || yarnDesc.Equals("No", StringComparison.OrdinalIgnoreCase)) yarnDesc = "";
                string yLabel = "";
                if (yarnDesc != "")
                {
                    if (!yarnLabel.TryGetValue(yarnDesc, out yLabel))
                    {
                        yLabel = ((char)('A' + yarnLabel.Count)).ToString();
                        yarnLabel[yarnDesc] = yLabel; yarnOrder.Add(yarnDesc); yarnQty[yarnDesc] = 0m;
                    }
                }

                sb.Append("<div class='fab-line'>(" + n + ") Fabric: " + H(G(first, "FabricName")) +
                          " &nbsp;&nbsp; Fabric Form: " + H(G(first, "FabricForm").ToUpper()));
                if (yarnDesc != "") sb.Append(" &nbsp;&nbsp; <b>Yarn:</b>(" + yLabel + ") " + H(yarnDesc));
                sb.Append("</div>");

                // এই ফেব্রিকের সাইজ কলাম
                List<string> sizes = fg.Select(r => G(r, "SizeCode")).Where(s => s != "").Distinct()
                                       .OrderBy(s => SizeRank(s)).ThenBy(s => s).ToList();
                if (sizes.Count == 0) sizes.Add("ALL SIZE");

                Dictionary<string, string> dia = new Dictionary<string, string>();
                Dictionary<string, string> con = new Dictionary<string, string>();
                foreach (string s in sizes)
                {
                    DataRow r0 = fg.FirstOrDefault(r => (G(r, "SizeCode") == "" ? "ALL SIZE" : G(r, "SizeCode")) == s) ?? first;
                    dia[s] = G(r0, "FinishDia", "Dia");
                    decimal kd = N(r0, "KgPerDzn");
                    con[s] = kd == 0 ? "" : kd.ToString("0.###", CultureInfo.InvariantCulture);
                }

                sb.Append("<table class='t' style='width:100%'>");
                sb.Append("<tr><th rowspan='3'>GMT Color</th><th rowspan='3'>Fabric Color</th><th rowspan='3'>GMT Part</th><th rowspan='3'>Lab<br/>Ref.LD</th><th rowspan='3'>GSM</th>");
                sb.Append("<th>Size</th>");
                foreach (string s in sizes) sb.Append("<th>" + H(s) + "</th>");
                sb.Append("<th rowspan='3'>Total<br/>Fabric Fin</th><th rowspan='3'>Total Yarn<br/>Grey</th><th rowspan='3'>Total Finish<br/>Fabric(Length)</th><th rowspan='3'>Yarn</th>");
                sb.Append("<th rowspan='3'>Fabric<br/>Wastage %</th><th rowspan='3'>GMT<br/>Wastage %</th><th rowspan='3'>Sample<br/>Fabric Qty</th><th rowspan='3'>UOM</th></tr>");
                sb.Append("<tr><th>Finish Dia</th>");
                foreach (string s in sizes) sb.Append("<th class='fin'>" + H(dia[s]) + "</th>");
                sb.Append("</tr><tr><th>Fin. Con/Dz</th>");
                foreach (string s in sizes) sb.Append("<th class='fin'>" + H(con[s]) + "</th>");
                sb.Append("</tr>");

                decimal tFin = 0m, tGrey = 0m, tLen = 0m, tSample = 0m;
                Dictionary<string, decimal> sizeTot = new Dictionary<string, decimal>();

                foreach (var rg in fg.GroupBy(r => G(r, "ColorCode") + "|" + G(r, "PartName") + "|" + G(r, "LabRef", "LabRefLD")))
                {
                    DataRow r1 = rg.First();
                    decimal fin = 0m, len = 0m;
                    StringBuilder cells = new StringBuilder();
                    foreach (string s in sizes)
                    {
                        decimal kg = rg.Where(r => (G(r, "SizeCode") == "" ? "ALL SIZE" : G(r, "SizeCode")) == s).Sum(r => N(r, "TotalKg"));
                        fin += kg;
                        decimal st; sizeTot.TryGetValue(s, out st); sizeTot[s] = st + kg;
                        cells.Append("<td class='num'>" + F2(kg) + "</td>");
                    }
                    len = rg.Sum(r => N(r, "TotalYd"));

                    // Fabric Wastage % = Process Loss %, GMT Wastage % = Extra Cutting % (POFabricBooking.ExtraCutPct)
                    decimal fabW = N(r1, "LossPct", "FabricWastagePct");
                    decimal gmtW = N(r1, "ExtraCutPct", "GmtLossPct", "GmtWastagePct", "GMTWastage");
                    decimal grey = fabW > 0 && fabW < 100 ? fin / (1m - fabW / 100m) : fin;   // Grey = Fin / (1 - wastage%)
                    decimal sample = N(r1, "SampleQty", "SampleFabricQty");
                    string uom = G(r1, "UOM", "Uom"); if (uom == "") uom = "KG";

                    tFin += fin; tGrey += grey; tLen += len; tSample += sample;
                    if (yarnDesc != "") yarnQty[yarnDesc] += grey;

                    sb.Append("<tr><td>" + H(G(r1, "ColorCode")) + "</td><td>" + H(G(r1, "FabricColor", "ColorCode")) + "</td><td>" + H(G(r1, "PartName")) + "</td>");
                    sb.Append("<td>" + H(G(r1, "LabRef", "LabRefLD")) + "</td><td>" + H(G(r1, "GSM")) + "</td><td class='fin'></td>");
                    sb.Append(cells.ToString());
                    sb.Append("<td class='num'>" + F2(fin) + "</td><td class='num'>" + F2(grey) + "</td><td class='num'>" + F2(len) + "</td>");
                    sb.Append("<td>" + yLabel + "</td><td>" + (fabW == 0 ? "" : fabW.ToString("0.##", CultureInfo.InvariantCulture)) + "</td>");
                    sb.Append("<td>" + (gmtW == 0 ? "" : gmtW.ToString("0.##", CultureInfo.InvariantCulture)) + "</td>");
                    sb.Append("<td>" + F2(sample) + "</td><td>" + H(uom.ToUpper()) + "</td></tr>");
                }

                sb.Append("<tr class='gt'><td colspan='6' class='num'>Grand Total</td>");
                foreach (string s in sizes) { decimal st; sizeTot.TryGetValue(s, out st); sb.Append("<td class='num'>" + F2(st) + "</td>"); }
                sb.Append("<td class='num'>" + F2(tFin) + "</td><td class='num'>" + F2(tGrey) + "</td><td class='num'>" + F2(tLen) + "</td>");
                sb.Append("<td></td><td></td><td></td><td>" + F2(tSample) + "</td><td></td></tr></table>");
            }

            if (bk.Rows.Count == 0)
                sb.Append("<div class='fab-line'><i>No fabric booking found for this PO.</i></div>");

            // Yarn Required Summary
            if (yarnOrder.Count > 0)
            {
                sb.Append("<table class='t' style='margin-top:12px;min-width:480px'>");
                sb.Append("<tr><th colspan='5'>Yarn Required Summary</th></tr>");
                sb.Append("<tr><th>SL#</th><th>Yarn Description</th><th>Color</th><th>Qty (KG)</th><th>Total Qty (KG)</th></tr>");
                int i = 0; decimal tot = 0m;
                foreach (string y in yarnOrder)
                {
                    i++; tot += yarnQty[y];
                    sb.Append("<tr><td>" + i + "</td><td>" + H(y) + "</td><td></td><td class='num'>" + F2(yarnQty[y]) + "</td><td class='num'><b>" + F2(yarnQty[y]) + "</b></td></tr>");
                }
                sb.Append("<tr><td colspan='3'><b>Total</b></td><td class='num'><b>" + F2(tot) + "</b></td><td class='num'><b>" + F2(tot) + "</b></td></tr></table>");
            }
            sb.Append("<div class='fab-line'><b>Special Treatment:</b></div>");
        }

        // ---------------- SIGNATURE ----------------
        private void AppendSign(StringBuilder sb, DataRow h)
        {
            string merchant = G(h, "DealingMerchant", "MerchantName");
            sb.Append("<div style='margin-top:30px;margin-left:50px'>" + H(merchant) + "</div>");
            sb.Append("<div class='sign' style='margin-top:20px'>");
            foreach (string s in new[] { "Prepared By", "Approved By", "Team Leader", "Planning", "Authorised" })
                sb.Append("<div>" + s + "</div>");
            sb.Append("</div>");
        }
    }
}