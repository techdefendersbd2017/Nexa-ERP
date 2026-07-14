using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Drawing.Printing;
using System.Linq;
using System.Reflection.Emit;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.MerchandisingMarketing.MerchandisingConfiguration
{
    public partial class ColorInformation : System.Web.UI.Page
    {
        SqlConnection con;
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();
        //SqlCommand cmd;

        private int CurrentPage
        {
            get { return ViewState["CurrentPage"] != null ? (int)ViewState["CurrentPage"] : 1; }
            set { ViewState["CurrentPage"] = value; }
        }
        private int PageSize
        {
            get { return int.Parse(ddlPageSize.SelectedValue); }
        }
        private int TotalRecords
        {
            get { return ViewState["TotalRecords"] != null ? (int)ViewState["TotalRecords"] : 0; }
            set { ViewState["TotalRecords"] = value; }
        }


        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string user = Request.QueryString["user"];
                //if (!string.IsNullOrEmpty(user))
                //{
                //    Label1.Text = "Welcome, " + user;
                //}
                BindColorTypes();
                LoadColorMasterInformation(); 
                LoadNextColorID();
            }
        }

        void LoadNextColorID()
        {
            con = conn.openConnection();
            {
                SqlCommand cmd = new SqlCommand("SELECT ISNULL(MAX(ColorID),0)+1 FROM ColorMaster", con);
                txtColorCode.Text = cmd.ExecuteScalar().ToString();
            }
            con.Close();
        }
        private void BindColorTypes()
        {
            try
            {
                con = conn.openConnection();
                using (SqlCommand cmd = new SqlCommand("sp_ColorType_GetAll", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    DataTable dt = new DataTable();
                    dt.Load(cmd.ExecuteReader());
                    ddlColorType.DataSource = dt;
                    ddlColorType.DataTextField = "ColorTypeName";
                    ddlColorType.DataValueField = "ColorTypeID";
                    ddlColorType.DataBind();
                    ddlColorType.Items.Insert(0, new ListItem("--Select Type--", ""));
                }
                con.Close();
            }
            catch (Exception ex)
            {
                Response.Write("Error: " + ex.Message);
            }
        }
        private void LoadColorMasterInformation()
        {
            try
            {
                con = conn.openConnection();
                using (SqlCommand cmd = new SqlCommand("sp_ColorMaster_GetAll", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@PageNumber", CurrentPage);
                    cmd.Parameters.AddWithValue("@PageSize", PageSize);
                    using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                    {
                        DataSet ds = new DataSet();
                        da.Fill(ds);

                        gvColorList.DataSource = ds.Tables[0];
                        gvColorList.DataBind();

                        if (ds.Tables.Count > 1 && ds.Tables[1].Rows.Count > 0)
                            TotalRecords = Convert.ToInt32(ds.Tables[1].Rows[0]["TotalCount"]);
                    }
                }
                con.Close();
            }
            catch (Exception ex)
            {
                Response.Write("Error: " + ex.Message);
            }
        }


        protected void btnSave_Click(object sender, EventArgs e)
        {
            con=conn.openConnection();
            {
                using (SqlCommand cmd = new SqlCommand("sp_ColorMaster_Update", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@ColorID", txtColorCode.Text);
                    cmd.Parameters.AddWithValue("@ColorTypeID", int.Parse(ddlColorType.SelectedValue));
                    cmd.Parameters.AddWithValue("@ColorName", txtColorName.Text.Trim());
                    cmd.Parameters.AddWithValue("@IsActive", chkIsActive.Checked ? 1 : 0);
                    SqlParameter pMsg = new SqlParameter("@Message", SqlDbType.NVarChar, 200) { Direction = ParameterDirection.Output };
                    cmd.Parameters.Add(pMsg);
                    cmd.ExecuteNonQuery();

                }
            }
            con.Close();
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {

        }

        protected void btnAddType_Click(object sender, EventArgs e)
        {

        }

        protected void gvColorList_RowCommand(object sender, GridViewCommandEventArgs e)
        {

        }

        protected void lbFirst_Click(object sender, EventArgs e)
        {

        }

        protected void lbPrev_Click(object sender, EventArgs e)
        {

        }

        protected void lbNext_Click(object sender, EventArgs e)
        {

        }

        protected void lbLast_Click(object sender, EventArgs e)
        {

        }

        protected void ddlPageSize_Changed(object sender, EventArgs e)
        {

        }
    }
}