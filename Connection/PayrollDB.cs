using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace Nexa_ERP.Connection
{
    public class PayrollDB
    {
        private readonly string connString = @"Server=103.125.255.14,9436; Database=techpay; User Id=techdefendersbd; Password=KamrujamaN@12110;";

        public SqlConnection openConnection()
        {
            SqlConnection con = new SqlConnection(connString);
            con.Open();
            return con;
        }
    }
    public class Database_Connection
    {
        private readonly string connString = @"Server=103.125.255.14,9436; Database=NexaMaster; User Id=techdefendersbd; Password=KamrujamaN@12110;";

        public SqlConnection openConnection()
        {
            SqlConnection con = new SqlConnection(connString);
            con.Open();
            return con;
        }
    }
}
