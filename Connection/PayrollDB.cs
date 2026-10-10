using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace Nexa_ERP.Connection
{
    public class PayrollDB
    {
        private readonly string connString = @"Server=103.125.255.21,9438; Database=techpay; User Id=techdefenders_bd; Password=KamrujamaN@12110;";
        //private readonly string connString = @"Server=.; Database=Tech_Pay; User Id=sa; Password=bip1#;";
        public SqlConnection openConnection()
        {
            SqlConnection con = new SqlConnection(connString);
            con.Open();
            return con;
        }
    }
    public class Database_Connection
    {
        private readonly string connString = @"Server=103.125.255.21,9438; Database=NexaMaster; User Id=techdefenders_bd; Password=KamrujamaN@12110;";


        public SqlConnection openConnection()
        {
            SqlConnection con = new SqlConnection(connString);
            con.Open();
            return con;
        }
    }
}
