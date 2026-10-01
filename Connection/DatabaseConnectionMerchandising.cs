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
            con = new SqlConnection(@"Server =  103.125.255.21,9436; Database = nexamar; User Id = techdefenders_bd; Password = KamrujamaN@12110;");
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