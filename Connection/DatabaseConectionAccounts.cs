using System;
using System.Data.SqlClient;
using System.Configuration; // Web.config ব্যবহার করলে লাগবে

namespace Nexa_ERP.Connection
{
    public class DatabaseConectionAccounts
    {
        // কানেকশন স্ট্রিংটি এখানে সরাসরি না রেখে Web.config এ রাখলে ভালো হয়
        private string connectionString = @"Server=.; Database=NexaAccounts; User Id=sa; Password=bip1#;";

        public SqlConnection openConnection()
        {
            SqlConnection con = new SqlConnection(connectionString);
            if (con.State == System.Data.ConnectionState.Closed)
            {
                con.Open();
            }
            return con;
        }
    }
}