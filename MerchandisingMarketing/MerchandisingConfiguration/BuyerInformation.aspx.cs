using Nexa_ERP.Connection;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Nexa_ERP.MerchandisingMarketing.MerchandisingConfiguration
{
    public partial class BuyerInformation : System.Web.UI.Page
    {
        SqlConnection con;
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();
        SqlCommand cmd;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string user = Request.QueryString["user"];
                LoadBuyerType();
                CountryInformationLoad();
                BuyingAgentTypeInformationLoad();
            }

        }
        private void BuyingAgentTypeInformationLoad()
        {
            //try
            //{
            //    con = conn.openConnection();
            //    {
            //        string query = "SELECT * FROM BuyingHouseAgent";
            //        using (SqlCommand cmd = new SqlCommand(query, con))
            //        {
            //            SqlDataAdapter da = new SqlDataAdapter(cmd);
            //            DataSet ds = new DataSet();
            //            da.Fill(ds);

            //            ddlBuyingHouseName.DataSource = ds.Tables[0];
            //            ddlBuyingHouseName.DataTextField = "HouseName";
            //            ddlBuyingHouseName.DataValueField = "AgentID";
            //            ddlBuyingHouseName.DataBind();

            //            ddlBuyingHouseName.Items.Insert(0, new ListItem("--Select--", "0"));
            //        }
            //    }
            //    con.Close();
            //}
            //catch (Exception ex)
            //{
            //    Response.Write("Error: " + ex.Message);
            //}
        }
        private void LoadBuyerType()
        {
            //try
            //{
            //    con = conn.openConnection();
            //    {
            //        string query = "SELECT * FROM BuyerType";
            //        using (SqlCommand cmd = new SqlCommand(query, con))
            //        {
            //            SqlDataAdapter da = new SqlDataAdapter(cmd);
            //            DataSet ds = new DataSet();
            //            da.Fill(ds);

            //            ddlBuyerType.DataSource = ds.Tables[0];
            //            ddlBuyerType.DataTextField = "BuyerTypeName";
            //            ddlBuyerType.DataValueField = "BuyerTypeID";
            //            ddlBuyerType.DataBind();

            //            ddlBuyerType.Items.Insert(0, new ListItem("--Select--", "0"));
            //        }
            //    }
            //    con.Close();
            //}
            //catch (Exception ex)
            //{
            //    Response.Write("Error: " + ex.Message);
            //}
        }
        private void CountryInformationLoad()
        {
            //try
            //{
            //    con = conn.openConnection();
            //    {
            //        string query = "SELECT * FROM CountryMaster";
            //        using (SqlCommand cmd = new SqlCommand(query, con))
            //        {
            //            SqlDataAdapter da = new SqlDataAdapter(cmd);
            //            DataSet ds = new DataSet();
            //            da.Fill(ds);

            //            ddlCountryName.DataSource = ds.Tables[0];
            //            ddlCountryName.DataTextField = "CountryName";
            //            ddlCountryName.DataValueField = "CountryID";
            //            ddlCountryName.DataBind();

            //            ddlCountryName.Items.Insert(0, new ListItem("--Select--", "0"));
            //        }
            //    }
            //    con.Close();
            //}
            //catch (Exception ex)
            //{
            //    Response.Write("Error: " + ex.Message);
            //}
        }
        private void LoadBuyerInformation()
        {
            //con = conn.openConnection();
            //{
            //    SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM BuyerInformation where BuyingHouseID='"+ddlBuyingHouseName.SelectedValue+"'", con);
            //    DataTable dt = new DataTable();
            //    da.Fill(dt);
            //    gvBuyerInformation.DataSource = dt;
            //    gvBuyerInformation.DataBind();
            //}
            //con.Close();
        }

        protected void LinkButton1_Click(object sender, EventArgs e)
        {
            //try
            //{
            //    con = conn.openConnection();

            //    using (SqlCommand cmd = new SqlCommand("sp_InsertUpdate_Buyer", con))
            //    {
            //        cmd.CommandType = CommandType.StoredProcedure;

            //        cmd.Parameters.AddWithValue("@BuyerID", string.IsNullOrEmpty(txtBuyerID.Text) ? 0 : Convert.ToInt64(txtBuyerID.Text));
            //        cmd.Parameters.AddWithValue("@BuyingHouseID", ddlBuyingHouseName.SelectedValue);
            //        cmd.Parameters.AddWithValue("@BuyerName", txtBuyerName.Text.Trim());
            //        cmd.Parameters.AddWithValue("@Prefix", txtPrefix.Text.Trim());
            //        cmd.Parameters.AddWithValue("@BuyerTypeID", ddlBuyerType.SelectedValue);
            //        cmd.Parameters.AddWithValue("@CountryID", ddlCountryName.SelectedValue);
            //        cmd.Parameters.AddWithValue("@ContactPerson", txtContractPerson.Text.Trim());
            //        cmd.Parameters.AddWithValue("@Phone", txtPhone.Text.Trim());
            //        cmd.Parameters.AddWithValue("@Email", txtEmail.Text.Trim());
            //        cmd.Parameters.AddWithValue("@Address", txtAddress.Text.Trim());
            //        cmd.Parameters.AddWithValue("@LocalAddress", txtAddressLocal.Text.Trim());
            //        cmd.Parameters.AddWithValue("@IsActive", chkIsActive.Checked);
            //        cmd.Parameters.AddWithValue("@SamaeAddress", CheckBox1.Checked);
            //        cmd.ExecuteNonQuery();

            //        ScriptManager.RegisterStartupScript(this, this.GetType(), "alert",
            //            "alert('Saved Successfully!');", true);
            //    }

            //    con.Close();
            //}
            //catch (Exception ex)
            //{
            //    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert",
            //        "alert('" + ex.Message.Replace("'", "") + "');", true);
            //}
            LoadBuyerInformation();
        }

        protected void CheckBox1_CheckedChanged(object sender, EventArgs e)
        {
            //if (CheckBox1.Checked == true)
            //{
            //    txtAddressLocal.Text = txtAddress.Text;
            //    txtAddressLocal.ReadOnly = true;
            //}
            //else
            //{
            //    txtAddressLocal.ReadOnly = false;
            //}
        }

        protected void ddlBuyingHouseName_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadBuyerInformation();
        }

        protected void gvBuyerInformation_SelectedIndexChanged(object sender, EventArgs e)
        {
            //txtBuyerID.Text = gvBuyerInformation.SelectedRow.Cells[1].Text;
            //try
            //{
            //    string sql = "Select * from BuyerInformation where BuyerID ='" + txtBuyerID.Text + "'";
            //    con = conn.openConnection();
            //    cmd = new SqlCommand(sql, con);
            //    SqlDataReader reader = cmd.ExecuteReader();
            //    if (reader.HasRows)
            //    {
            //        while (reader.Read())
            //        {
            //            txtBuyerID.Text = reader[0].ToString();
            //            ddlBuyingHouseName.SelectedValue = reader[1].ToString();
            //            txtBuyerName.Text = reader[2].ToString();
            //            txtPrefix.Text = reader[3].ToString();
            //            ddlBuyerType.SelectedValue = reader[4].ToString();
            //            ddlCountryName.SelectedValue = reader[5].ToString();
            //            txtContractPerson.Text = reader[6].ToString();
            //            txtPhone.Text = reader[7].ToString();
            //            txtEmail.Text = reader[8].ToString();
            //            txtAddress.Text = reader[9].ToString();
            //            txtAddressLocal.Text = reader[10].ToString();
            //            chkIsActive.Checked = reader[11] != DBNull.Value && Convert.ToBoolean(reader[11]); // ✅ CheckBox
            //            CheckBox1.Checked = reader[14] != DBNull.Value && Convert.ToBoolean(reader[14]); // ✅ CheckBox
            //        }
            //    }
            //    else
            //    {
            //        txtBuyerID.Text = txtBuyerName.Text = txtPrefix.Text = txtContractPerson.Text = string.Empty;
            //        txtPhone.Text = txtAddress.Text = txtAddressLocal.Text = string.Empty;
            //        CheckBox1.Checked = false;
            //        chkIsActive.Checked = false;
            //    }
            //    con.Close();
            //}
            //catch (Exception ex)
            //{
            //    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            //}

            //if (CheckBox1.Checked == true)
            //{
            //    txtAddressLocal.ReadOnly = true;
            //}
        }

        protected void Button1_Click(object sender, EventArgs e)
        {
            //txtBuyerID.Text = txtBuyerName.Text = txtPrefix.Text = txtContractPerson.Text = string.Empty;
            //txtPhone.Text = txtAddress.Text = txtAddressLocal.Text = string.Empty;
            //CheckBox1.Checked = false;
            //chkIsActive.Checked = false;
            //BuyingAgentTypeInformationLoad();
            //CountryInformationLoad();
            //LoadBuyerType();

        }
    }
}