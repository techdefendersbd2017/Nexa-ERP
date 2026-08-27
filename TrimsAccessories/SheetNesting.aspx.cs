using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

namespace Nexa_ERP.TrimsAccessories
{
    public partial class SheetNesting : System.Web.UI.Page
    {
        // Drawing area pixel budget (matches #drawingArea CSS: 900x500, minus border/padding)
        private const double MaxDrawWidthPx = 860;
        private const double MaxDrawHeightPx = 460;

        // All internal calculation/drawing is done in INCHES. Convert every field
        // to inches right after reading it, based on the unit dropdown next to it.
        private const double InchPerCm = 1.0 / 2.54;
        private const double InchPerMm = 1.0 / 25.4;

        private static double ToInches(double value, string unit)
        {
            switch ((unit ?? "inch").ToLowerInvariant())
            {
                case "cm": return value * InchPerCm;
                case "mm": return value * InchPerMm;
                default: return value; // "inch"
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // Dynamically added controls do NOT survive postback automatically.
            // If we already have a valid result (e.g. user clicked Save), redraw it
            // before any other postback logic runs.
            if (IsPostBack && ViewState["HasResult"] is bool hasResult && hasResult)
            {
                RedrawFromViewState();
            }
        }

        protected void btnCalculate_Click(object sender, EventArgs e)
        {
            lblMessage.Text = "";

            if (!TryReadInputs(out NestingInput input, out string error))
            {
                lblMessage.Text = error;
                ClearResults();
                return;
            }

            NestingResult result = CalculateNesting(input);

            lblNormalQty.Text = result.NormalQty.ToString();
            lblRotateQty.Text = result.RotateQty.ToString();
            lblTotalQty.Text = result.TotalQty.ToString();
            lblUtilization.Text = result.Utilization.ToString("0.00", CultureInfo.InvariantCulture) + " %";

            DrawLayout(input, result);

            // Persist everything needed to redraw on a later postback (Save/Clear won't wipe it)
            SaveToViewState(input, result);
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            // TODO: persist 'input' + 'result' (from ViewState) into the database here.
            // The drawing itself will remain visible because Page_Load redraws it
            // from ViewState on every postback.
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            txtSheetLength.Text = "";
            txtSheetWidth.Text = "";
            txtWasteTop.Text = "0";
            txtWasteBottom.Text = "0";
            txtWasteLeft.Text = "0";
            txtWasteRight.Text = "0";
            txtLength.Text = "";
            txtWidth.Text = "";
            txtGap.Text = "0";
            chkRotate.Checked = true;

            ddlUnitSheetLength.SelectedValue = "inch";
            ddlUnitSheetWidth.SelectedValue = "inch";
            ddlUnitWasteTop.SelectedValue = "cm";
            ddlUnitWasteBottom.SelectedValue = "cm";
            ddlUnitWasteLeft.SelectedValue = "cm";
            ddlUnitWasteRight.SelectedValue = "cm";
            ddlUnitLength.SelectedValue = "inch";
            ddlUnitWidth.SelectedValue = "inch";
            ddlUnitGap.SelectedValue = "inch";

            ClearResults();
            lblMessage.Text = "";

            drawingArea.Controls.Clear();
            ViewState["HasResult"] = false;
        }

        // ---------- Input handling ----------

        private struct NestingInput
        {
            public double SheetLength, SheetWidth;
            public double WasteTop, WasteBottom, WasteLeft, WasteRight;
            public double ItemLength, ItemWidth;
            public double Gap;
            public bool Rotate;

            public double EffectiveLength => SheetLength - WasteTop - WasteBottom;
            public double EffectiveWidth => SheetWidth - WasteLeft - WasteRight;
        }

        private struct NestingResult
        {
            public int Row, Col;             // normal grid: Row = count along length, Col = count along width
            public int RotateRow, RotateCol;  // rotated grid filling the leftover strip
            public int NormalQty, RotateQty, TotalQty;
            public double Utilization;
            public double Scale;              // px per inch used for drawing
        }

        private bool TryReadInputs(out NestingInput input, out string error)
        {
            input = new NestingInput();
            error = "";

            double rawSheetLength, rawSheetWidth;
            double rawWasteTop, rawWasteBottom, rawWasteLeft, rawWasteRight;
            double rawItemLength, rawItemWidth, rawGap;

            bool ok = true;
            ok &= double.TryParse(txtSheetLength.Text, NumberStyles.Any, CultureInfo.InvariantCulture, out rawSheetLength);
            ok &= double.TryParse(txtSheetWidth.Text, NumberStyles.Any, CultureInfo.InvariantCulture, out rawSheetWidth);
            ok &= double.TryParse(txtWasteTop.Text, NumberStyles.Any, CultureInfo.InvariantCulture, out rawWasteTop);
            ok &= double.TryParse(txtWasteBottom.Text, NumberStyles.Any, CultureInfo.InvariantCulture, out rawWasteBottom);
            ok &= double.TryParse(txtWasteLeft.Text, NumberStyles.Any, CultureInfo.InvariantCulture, out rawWasteLeft);
            ok &= double.TryParse(txtWasteRight.Text, NumberStyles.Any, CultureInfo.InvariantCulture, out rawWasteRight);
            ok &= double.TryParse(txtLength.Text, NumberStyles.Any, CultureInfo.InvariantCulture, out rawItemLength);
            ok &= double.TryParse(txtWidth.Text, NumberStyles.Any, CultureInfo.InvariantCulture, out rawItemWidth);
            ok &= double.TryParse(txtGap.Text, NumberStyles.Any, CultureInfo.InvariantCulture, out rawGap);
            input.Rotate = chkRotate.Checked;

            if (!ok)
            {
                error = "সব ফিল্ডে সঠিক সংখ্যা লিখুন।";
                return false;
            }

            // Convert every value to inches using the unit selected next to that field.
            // Defaults on the page: Sheet Length/Width = Inch, Waste (Top/Bottom/Left/Right) = CM,
            // Hantech Length/Width = Inch, Gap = Inch — but the user can change any dropdown
            // and the calculation below will still be correct.
            input.SheetLength = ToInches(rawSheetLength, ddlUnitSheetLength.SelectedValue);
            input.SheetWidth = ToInches(rawSheetWidth, ddlUnitSheetWidth.SelectedValue);
            input.WasteTop = ToInches(rawWasteTop, ddlUnitWasteTop.SelectedValue);
            input.WasteBottom = ToInches(rawWasteBottom, ddlUnitWasteBottom.SelectedValue);
            input.WasteLeft = ToInches(rawWasteLeft, ddlUnitWasteLeft.SelectedValue);
            input.WasteRight = ToInches(rawWasteRight, ddlUnitWasteRight.SelectedValue);
            input.ItemLength = ToInches(rawItemLength, ddlUnitLength.SelectedValue);
            input.ItemWidth = ToInches(rawItemWidth, ddlUnitWidth.SelectedValue);
            input.Gap = ToInches(rawGap, ddlUnitGap.SelectedValue);
            if (input.SheetLength <= 0 || input.SheetWidth <= 0)
            {
                error = "Sheet Length/Width অবশ্যই ০ এর বড় হতে হবে।";
                return false;
            }
            if (input.ItemLength <= 0 || input.ItemWidth <= 0)
            {
                error = "Hantech Length/Width অবশ্যই ০ এর বড় হতে হবে।";
                return false;
            }
            if (input.Gap < 0)
            {
                error = "Gap ঋণাত্মক হতে পারবে না।";
                return false;
            }
            if (input.EffectiveLength <= 0 || input.EffectiveWidth <= 0)
            {
                error = "Waste margin বাদ দেওয়ার পর ব্যবহারযোগ্য শীট এলাকা শূন্য বা ঋণাত্মক হয়ে যাচ্ছে।";
                return false;
            }

            return true;
        }

        private void ClearResults()
        {
            lblNormalQty.Text = "";
            lblRotateQty.Text = "";
            lblTotalQty.Text = "";
            lblUtilization.Text = "";
        }

        // ---------- Core nesting calculation ----------

        private NestingResult CalculateNesting(NestingInput input)
        {
            NestingResult r = new NestingResult();

            r.Row = (int)(input.EffectiveLength / (input.ItemLength + input.Gap));
            r.Col = (int)(input.EffectiveWidth / (input.ItemWidth + input.Gap));
            r.NormalQty = r.Row * r.Col;

            double usedLength = r.Row * (input.ItemLength + input.Gap);
            double remainLength = input.EffectiveLength - usedLength;

            if (input.Rotate && remainLength > 0)
            {
                r.RotateRow = (int)(remainLength / (input.ItemWidth + input.Gap));
                r.RotateCol = (int)(input.EffectiveWidth / (input.ItemLength + input.Gap));
                r.RotateQty = r.RotateRow * r.RotateCol;
            }

            r.TotalQty = r.NormalQty + r.RotateQty;

            double sheetArea = input.EffectiveLength * input.EffectiveWidth;
            double usedArea = r.TotalQty * input.ItemLength * input.ItemWidth;
            r.Utilization = sheetArea > 0 ? (usedArea / sheetArea) * 100.0 : 0;

            // Auto-fit scale so the whole sheet (not just usable area) fits inside drawingArea
            double scaleX = MaxDrawWidthPx / input.SheetWidth;
            double scaleY = MaxDrawHeightPx / input.SheetLength;
            r.Scale = Math.Min(scaleX, scaleY);
            if (r.Scale <= 0 || double.IsNaN(r.Scale) || double.IsInfinity(r.Scale)) r.Scale = 1;

            return r;
        }

        // ---------- Drawing ----------

        private void DrawLayout(NestingInput input, NestingResult result)
        {
            drawingArea.Controls.Clear();
            double s = result.Scale;

            // 1) Full sheet outline
            AddDiv(drawingArea, "sheetOutline",
                0, 0,
                input.SheetWidth * s, input.SheetLength * s, null);

            // 2) Waste margins (drawn on top of the sheet, around the usable area)
            if (input.WasteTop > 0)
                AddDiv(drawingArea, "wasteMargin", 0, 0, input.SheetWidth * s, input.WasteTop * s, null);

            if (input.WasteBottom > 0)
                AddDiv(drawingArea, "wasteMargin", 0, (input.SheetLength - input.WasteBottom) * s,
                    input.SheetWidth * s, input.WasteBottom * s, null);

            if (input.WasteLeft > 0)
                AddDiv(drawingArea, "wasteMargin", 0, 0, input.WasteLeft * s, input.SheetLength * s, null);

            if (input.WasteRight > 0)
                AddDiv(drawingArea, "wasteMargin", (input.SheetWidth - input.WasteRight) * s, 0,
                    input.WasteRight * s, input.SheetLength * s, null);

            // 3) Normal pieces, offset by the waste margin so they sit inside the usable area
            string sizeLabel = FormatNumber(input.ItemLength) + "×" + FormatNumber(input.ItemWidth);
            int pieceNo = 1;
            for (int r = 0; r < result.Row; r++)
            {
                for (int c = 0; c < result.Col; c++)
                {
                    double left = input.WasteLeft * s + c * (input.ItemWidth + input.Gap) * s;
                    double top = input.WasteTop * s + r * (input.ItemLength + input.Gap) * s;

                    AddDiv(drawingArea, "piece", left, top,
                        input.ItemWidth * s, input.ItemLength * s,
                        "#" + pieceNo + "\n" + sizeLabel);
                    pieceNo++;
                }
            }

            // 4) Rotated pieces, placed in their real nested position: the leftover strip
            //    right after the last normal row, dimensions swapped (L/W)
            if (result.RotateQty > 0)
            {
                double rotStripTop = input.WasteTop * s + result.Row * (input.ItemLength + input.Gap) * s;

                for (int i = 0; i < result.RotateRow; i++)
                {
                    for (int j = 0; j < result.RotateCol; j++)
                    {
                        double left = input.WasteLeft * s + j * (input.ItemLength + input.Gap) * s;
                        double top = rotStripTop + i * (input.ItemWidth + input.Gap) * s;

                        AddDiv(drawingArea, "piece rotate", left, top,
                            input.ItemLength * s, input.ItemWidth * s,
                            "R" + (i * result.RotateCol + j + 1) + "\n" + sizeLabel);
                    }
                }
            }
        }

        private static void AddDiv(Panel container, string cssClass,
            double leftPx, double topPx, double widthPx, double heightPx, string text)
        {
            HtmlGenericControl div = new HtmlGenericControl("div");
            div.Attributes["class"] = cssClass;
            div.Style["left"] = leftPx.ToString("0.##", CultureInfo.InvariantCulture) + "px";
            div.Style["top"] = topPx.ToString("0.##", CultureInfo.InvariantCulture) + "px";
            div.Style["width"] = widthPx.ToString("0.##", CultureInfo.InvariantCulture) + "px";
            div.Style["height"] = heightPx.ToString("0.##", CultureInfo.InvariantCulture) + "px";

            if (!string.IsNullOrEmpty(text))
            {
                // preserve the line break we put in the label
                div.InnerHtml = HttpUtility.HtmlEncode(text).Replace("\n", "<br/>");
            }

            container.Controls.Add(div);
        }

        private static string FormatNumber(double v)
        {
            return v == Math.Floor(v) ? v.ToString("0", CultureInfo.InvariantCulture)
                                       : v.ToString("0.##", CultureInfo.InvariantCulture);
        }

        // ---------- ViewState persistence (so drawing survives Save/Clear postbacks) ----------

        private void SaveToViewState(NestingInput input, NestingResult result)
        {
            ViewState["HasResult"] = true;
            ViewState["SheetLength"] = input.SheetLength;
            ViewState["SheetWidth"] = input.SheetWidth;
            ViewState["WasteTop"] = input.WasteTop;
            ViewState["WasteBottom"] = input.WasteBottom;
            ViewState["WasteLeft"] = input.WasteLeft;
            ViewState["WasteRight"] = input.WasteRight;
            ViewState["ItemLength"] = input.ItemLength;
            ViewState["ItemWidth"] = input.ItemWidth;
            ViewState["Gap"] = input.Gap;
            ViewState["Rotate"] = input.Rotate;
        }

        private void RedrawFromViewState()
        {
            NestingInput input = new NestingInput
            {
                SheetLength = (double)ViewState["SheetLength"],
                SheetWidth = (double)ViewState["SheetWidth"],
                WasteTop = (double)ViewState["WasteTop"],
                WasteBottom = (double)ViewState["WasteBottom"],
                WasteLeft = (double)ViewState["WasteLeft"],
                WasteRight = (double)ViewState["WasteRight"],
                ItemLength = (double)ViewState["ItemLength"],
                ItemWidth = (double)ViewState["ItemWidth"],
                Gap = (double)ViewState["Gap"],
                Rotate = (bool)ViewState["Rotate"]
            };

            NestingResult result = CalculateNesting(input);
            DrawLayout(input, result);
        }
    }
}
