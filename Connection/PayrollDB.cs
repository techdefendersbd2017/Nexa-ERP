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
}

//namespace Nexa_ERP.Connection
//{
//    public class PayrollDB
//    {
//        private SqlConnection con;


//        public PayrollDB()
//        {
//            //con = new SqlConnection(@"Server = .; Database = NexaPayroll; User Id = sa; Password = bip1#;");
//            con = new SqlConnection(@"Server =  103.125.255.14,9436; Database = techpay; User Id = techdefendersbd; Password = KamrujamaN@12110;");
//        }

//        public SqlConnection openConnection()
//        {
//            if (con.State == System.Data.ConnectionState.Closed)
//            {
//                con.Open();
//            }
//            return con;
//        }
//    }
//}