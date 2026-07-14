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
    public partial class BuyingHouseAgent : System.Web.UI.Page
    {
        SqlConnection con;
        DatabaseConnectionMerchandising conn = new DatabaseConnectionMerchandising();
        SqlCommand cmd;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string user = Request.QueryString["user"];
                if (!string.IsNullOrEmpty(user))
                {
                    Label1.Text = "Welcome, " + user;
                }
                BuyingAgentTypeInformationLoad();
                LoadBuyingAgentInformation();
                CountryInformationLoad();
            }
        }

        private void BuyingAgentTypeInformationLoad()
        {
            try
            {
                con = conn.openConnection();
                {
                    string query = "SELECT * FROM BuyingHouseType";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataSet ds = new DataSet();
                        da.Fill(ds);

                        ddlHouseType.DataSource = ds.Tables[0];
                        ddlHouseType.DataTextField = "HouseTypeName";
                        ddlHouseType.DataValueField = "HouseTypeID";
                        ddlHouseType.DataBind();

                        ddlHouseType.Items.Insert(0, new ListItem("--Select--", "0"));
                    }
                }
                con.Close();
            }
            catch (Exception ex)
            {
                Response.Write("Error: " + ex.Message);
            }
        }
        private void CountryInformationLoad()
        {
            try
            {
                con = conn.openConnection();
                {
                    string query = "SELECT * FROM CountryMaster";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataSet ds = new DataSet();
                        da.Fill(ds);

                        ddlCountryName.DataSource = ds.Tables[0];
                        ddlCountryName.DataTextField = "CountryName";
                        ddlCountryName.DataValueField = "CountryID";
                        ddlCountryName.DataBind();

                        ddlCountryName.Items.Insert(0, new ListItem("--Select--", "0"));
                    }
                }
                con.Close();
            }
            catch (Exception ex)
            {
                Response.Write("Error: " + ex.Message);
            }
        }

        protected void CheckBox1_CheckedChanged(object sender, EventArgs e)
        {
            if (CheckBox1.Checked == true)
            {
                txtAddressLocal.Text = txtAddress.Text;
                txtAddressLocal.ReadOnly = true;
            }
            else
            {
                txtAddressLocal.ReadOnly = false;
            }
        }
        private void LoadBuyingAgentInformation()
        {
            con = conn.openConnection();
            {
                SqlDataAdapter da = new SqlDataAdapter("SELECT * FROM BuyingHouseAgent", con);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvBuyingAgent.DataSource = dt;
                gvBuyingAgent.DataBind();
            }
            con.Close();
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                con = conn.openConnection();

                using (SqlCommand cmd = new SqlCommand("sp_InsertUpdate_BuyingHouseAgent", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.Parameters.AddWithValue("@AgentID", string.IsNullOrEmpty(txtHouseID.Text) ? 0 : Convert.ToInt64(txtHouseID.Text));
                    cmd.Parameters.AddWithValue("@HouseName", txtHouseName.Text);
                    cmd.Parameters.AddWithValue("@Prefix", txtPrefix.Text);
                    cmd.Parameters.AddWithValue("@HouseTypeID", ddlHouseType.SelectedValue);
                    cmd.Parameters.AddWithValue("@CountryID", ddlCountryName.SelectedValue);
                    cmd.Parameters.AddWithValue("@ContactPerson", txtContractPerson.Text);
                    cmd.Parameters.AddWithValue("@Phone", txtPhone.Text);
                    cmd.Parameters.AddWithValue("@Email", txtEmail.Text);
                    cmd.Parameters.AddWithValue("@Address", txtAddress.Text);
                    cmd.Parameters.AddWithValue("@SamaeAddress", CheckBox1.Checked);
                    cmd.Parameters.AddWithValue("@LocalAddress", txtAddressLocal.Text);
                    cmd.Parameters.AddWithValue("@IsActive", chkIsActive.Checked);



                    cmd.ExecuteNonQuery();

                    ScriptManager.RegisterStartupScript(this, this.GetType(), "alert",
                        "alert('Saved Successfully!');", true);
                }

                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert",
                    "alert('" + ex.Message.Replace("'", "") + "');", true);
            }
            LoadBuyingAgentInformation();
        }

        protected void gvBuyingAgent_SelectedIndexChanged(object sender, EventArgs e)
        {
            txtHouseID.Text = gvBuyingAgent.SelectedRow.Cells[1].Text;
            try
            {
                string sql = "Select * from BuyingHouseAgent where AgentID ='" + txtHouseID.Text + "'";
                con = conn.openConnection();
                cmd = new SqlCommand(sql, con);
                SqlDataReader reader = cmd.ExecuteReader();
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        txtHouseID.Text = reader[0].ToString();
                        txtHouseName.Text = reader[1].ToString();
                        txtPrefix.Text = reader[2].ToString();
                        ddlHouseType.SelectedValue = reader[3].ToString();
                        ddlCountryName.SelectedValue = reader[4].ToString();
                        txtContractPerson.Text = reader[5].ToString();
                        txtPhone.Text = reader[6].ToString();
                        txtAddress.Text = reader[7].ToString();
                        CheckBox1.Checked = reader[13] != DBNull.Value && Convert.ToBoolean(reader[13]); // ✅ CheckBox
                        txtAddressLocal.Text = reader[9].ToString();
                        chkIsActive.Checked = reader[10] != DBNull.Value && Convert.ToBoolean(reader[10]); // ✅ CheckBox
                    }
                }
                else
                {
                    txtHouseID.Text = txtHouseName.Text = txtPrefix.Text = txtContractPerson.Text = string.Empty;
                    txtPhone.Text = txtAddress.Text = txtAddressLocal.Text = string.Empty;
                    CheckBox1.Checked = false;
                    chkIsActive.Checked = false;
                }
                con.Close();
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "alert", "alert('" + ex.Message.Replace("'", "") + "');", true);
            }

            if (CheckBox1.Checked == true)
            {
                txtAddressLocal.ReadOnly = true;
            }

        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            txtHouseID.Text = txtHouseName.Text = txtPrefix.Text = txtContractPerson.Text = string.Empty;
            txtPhone.Text = txtAddress.Text = txtAddressLocal.Text = string.Empty;
            CheckBox1.Checked = false;
            chkIsActive.Checked = false;
            BuyingAgentTypeInformationLoad();
            CountryInformationLoad();
        }
    }
}