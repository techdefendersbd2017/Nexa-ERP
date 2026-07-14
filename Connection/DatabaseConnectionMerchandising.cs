using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace Nexa_ERP.Connection
{
    public class DatabaseConnectionMerchandising
    {
        private SqlConnection con;


        public DatabaseConnectionMerchandising()
        {
            con = new SqlConnection(@"Server = .; Database = NexaMerchandising; User Id = sa; Password = bip1#;");
            //con = new SqlConnection(@"Server = 103.106.34.101\sql2012,1433; Database = NexaMerchandising; User Id = sa; Password = bip1#; Connection Timeout=60;");
        }

        public SqlConnection openConnection()
        {
            if (con.State == System.Data.ConnectionState.Closed)
            {
                con.Open();
            }
            return con;
        }
    }
}