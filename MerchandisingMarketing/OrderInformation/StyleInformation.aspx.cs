using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Reflection.Emit;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.MerchandisingMarketing.OrderInformation
{
    public partial class StyleInformation : System.Web.UI.Page
    {
        SqlConnection con;
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();
        //SqlCommand cmd;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string user = Request.QueryString["user"];
                if (!string.IsNullOrEmpty(user))
                {
                    Label1.Text = "Welcome, " + user;
                }
                LoadBuyerInformation();
                LoadProductType();
                LoadItems_Information();
                LoadProduct_Department();
            }
        }
        private void LoadBuyerInformation()
        {
            try
            {
                con = conn.openConnection();
                {
                    string query = "SELECT * FROM BuyerInformation";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataSet ds = new DataSet();
                        da.Fill(ds);

                        ddlBuyer.DataSource = ds.Tables[0];
                        ddlBuyer.DataTextField = "BuyerName";
                        ddlBuyer.DataValueField = "BuyerID";
                        ddlBuyer.DataBind();
                        ddlBuyer.Items.Insert(0, new ListItem("--Select--", "0"));
                    }
                }
                con.Close();
            }
            catch (Exception ex)
            {
                Response.Write("Error: " + ex.Message);
            }
        }
        private void LoadProductType()
        {
            try
            {
                con = conn.openConnection();
                {
                    string query = "SELECT * FROM ProductType where IsActive=1";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataSet ds = new DataSet();
                        da.Fill(ds);

                        ddlProductType.DataSource = ds.Tables[0];
                        ddlProductType.DataTextField = "ProductType_Name";
                        ddlProductType.DataValueField = "ProductTypeID";
                        ddlProductType.DataBind();
                        ddlProductType.Items.Insert(0, new ListItem("--Select--", "0"));
                    }
                }
                con.Close();
            }
            catch (Exception ex)
            {
                Response.Write("Error: " + ex.Message);
            }
        }
        private void LoadItems_Information()
        {
            try
            {
                con = conn.openConnection();
                {
                    string query = "SELECT * FROM Items_Information where IsActive=1";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataSet ds = new DataSet();
                        da.Fill(ds);

                        ddlCategory.DataSource = ds.Tables[0];
                        ddlCategory.DataTextField = "ItemsName";
                        ddlCategory.DataValueField = "ItemsID";
                        ddlCategory.DataBind();
                        ddlCategory.Items.Insert(0, new ListItem("--Select--", "0"));
                    }
                }
                con.Close();
            }
            catch (Exception ex)
            {
                Response.Write("Error: " + ex.Message);
            }
        }
        private void LoadProduct_Department()
        {
            try
            {
                con = conn.openConnection();
                {
                    string query = "SELECT * FROM Product_Department where IsActive=1";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataSet ds = new DataSet();
                        da.Fill(ds);

                        ddlProductDepartment.DataSource = ds.Tables[0];
                        ddlProductDepartment.DataTextField = "DepartmentName";
                        ddlProductDepartment.DataValueField = "DepartmentID";
                        ddlProductDepartment.DataBind();
                        ddlProductDepartment.Items.Insert(0, new ListItem("--Select--", "0"));
                    }
                }
                con.Close();
            }
            catch (Exception ex)
            {
                Response.Write("Error: " + ex.Message);
            }
        }
    }
}