package conexao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class Conexao {
    private static final String URL = "jdbc:mysql://localhost:3306/db_libritech";
    private final Connection conexao;

    public Conexao(String usuario, String senha) throws SQLException {
        this.conexao = DriverManager.getConnection(URL, usuario, senha);
    }

    public Connection getConexao() {
        return conexao;
    }

    public void fecharConexao() throws SQLException {
        if (conexao != null && !conexao.isClosed()) {
            conexao.close();
        }
    }
}