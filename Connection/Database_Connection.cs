using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace Nexa_ERP.Connection
{
    public class Database_Connection
    {
        private SqlConnection con;


        public Database_Connection()
        {
            //con = new SqlConnection(@"Server =  .; Database = NexaMaster; User Id = sa; Password = bip1#;");
            con = new SqlConnection(@"Server =  103.125.255.14,9436; Database = NexaMaster; User Id = techdefendersbd; Password = KamrujamaN@12110;");
        }

        public SqlConnection openConnection()
        {
            con.Open();
            return con;
        }
    }
}