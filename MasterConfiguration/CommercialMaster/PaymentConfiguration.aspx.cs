using Nexa_ERP.Connection;
using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.MasterConfiguration.CommercialMaster
{
    public partial class PaymentConfiguration : System.Web.UI.Page
    {
        SqlConnection con;
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindGrid();
            }
        }

        private void BindGrid()
        {
            try
            {
                con = conn.openConnection();
                using (SqlCommand cmd = new SqlCommand("techdefendersbd.sp_PaymentTerm_GetAll", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    DataTable dt = new DataTable();
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        da.Fill(dt);
                    }

                    gvPaymentTermList.DataSource = dt;
                    gvPaymentTermList.DataBind();
                }
            }
            catch (Exception ex)
            {
                ShowAlert(ex.Message);
            }
            finally
            {
                con?.Close();
            }
        }

        protected void btnAddNew_Click(object sender, EventArgs e)
        {
            ClearForm();
            ClientScript.RegisterStartupScript(this.GetType(), "showForm", "showFormView();", true);
        }

        protected void gvPaymentTermList_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "EditPaymentTerm")
            {
                int termId = Convert.ToInt32(e.CommandArgument);
                LoadPaymentTerm(termId);
                ClientScript.RegisterStartupScript(this.GetType(), "showForm", "showFormView();", true);
            }
        }

        private void LoadPaymentTerm(int termId)
        {
            try
            {
                con = conn.openConnection();
                using (SqlCommand cmd = new SqlCommand("techdefendersbd.sp_PaymentTerm_GetById", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@TermId", termId);

                    using (SqlDataReader dr = cmd.ExecuteReader())
                    {
                        if (dr.Read())
                        {
                            txtTermName.Text = dr["TermName"].ToString();
                            txtDueDay.Text = dr["DueDay"].ToString();
                            ViewState["TermId"] = termId;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowAlert(ex.Message);
            }
            finally
            {
                con?.Close();
            }
        }

        protected void btnUpdate_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtTermName.Text) || string.IsNullOrWhiteSpace(txtDueDay.Text))
            {
                ShowAlert("Term Name and Due Day are required.");
                return;
            }

            int termId = ViewState["TermId"] != null ? Convert.ToInt32(ViewState["TermId"]) : 0;
            int currentUserId = Session["UserId"] != null ? Convert.ToInt32(Session["UserId"]) : 0;
            string actionType = null;

            try
            {
                con = conn.openConnection();
                using (SqlCommand cmd = new SqlCommand("techdefendersbd.sp_PaymentTerm_InsertUpdate", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@TermId", termId);
                    cmd.Parameters.AddWithValue("@TermName", txtTermName.Text.Trim());
                    cmd.Parameters.AddWithValue("@DueDay", Convert.ToInt32(txtDueDay.Text.Trim()));
                    cmd.Parameters.AddWithValue("@CreatedBy", currentUserId);
                    cmd.Parameters.AddWithValue("@ModifiedBy", currentUserId);

                    SqlParameter pResultID = new SqlParameter("@ResultID", SqlDbType.Int) { Direction = ParameterDirection.Output };
                    SqlParameter pActionType = new SqlParameter("@ActionType", SqlDbType.VarChar, 10) { Direction = ParameterDirection.Output };
                    cmd.Parameters.Add(pResultID);
                    cmd.Parameters.Add(pActionType);

                    cmd.ExecuteNonQuery();

                    actionType = pActionType.Value?.ToString();
                }
            }
            catch (Exception ex)
            {
                ShowAlert(ex.Message);
                return;
            }
            finally
            {
                con?.Close();
            }

            if (actionType == "DUPLICATE")
            {
                ShowAlert("A Payment Term with this name already exists.");
                return;
            }

            ClearForm();
            BindGrid();
            ClientScript.RegisterStartupScript(this.GetType(), "showList", "showListView();", true);
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            if (ViewState["TermId"] == null)
            {
                ShowAlert("Please select a Payment Term from the list, edit it, and then delete it.");
                return;
            }

            int termId = Convert.ToInt32(ViewState["TermId"]);

            try
            {
                con = conn.openConnection();
                using (SqlCommand cmd = new SqlCommand("techdefendersbd.sp_PaymentTerm_Delete", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@TermId", termId);
                    cmd.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                ShowAlert(ex.Message);
                return;
            }
            finally
            {
                con?.Close();
            }

            ClearForm();
            BindGrid();
            ClientScript.RegisterStartupScript(this.GetType(), "showList", "showListView();", true);
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            ClearForm();
        }

        private void ClearForm()
        {
            txtTermName.Text = string.Empty;
            txtDueDay.Text = string.Empty;
            ViewState["TermId"] = null;
        }

        private void ShowAlert(string message)
        {
            string safeMessage = message.Replace("'", "\\'");
            ClientScript.RegisterStartupScript(this.GetType(), "alertMsg", "alert('" + safeMessage + "');", true);
        }
    }
}
