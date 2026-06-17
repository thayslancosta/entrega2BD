package dao;

import conexao.Conexao;
import model.Aluno;
import model.Funcionario;
import model.Usuario;

import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UsuarioDAO {
    private final Conexao conexao;

    public UsuarioDAO(Conexao conexao) {
        this.conexao = conexao;
    }

    public Usuario autenticar(String cpf, String senha) throws SQLException {
        String sql = "SELECT id_usuario, nome, cpf, email, senha, tipo FROM Usuarios WHERE cpf = ? AND senha = ?";

        try (PreparedStatement statement = conexao.getConexao().prepareStatement(sql)) {
            statement.setString(1, cpf);
            statement.setString(2, senha);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (!resultSet.next()) {
                    return null;
                }

                Usuario usuario = "ALUNO".equals(resultSet.getString("tipo"))
                        ? new Aluno()
                        : new Funcionario();

                usuario.setIdUsuario(resultSet.getInt("id_usuario"));
                usuario.setNome(resultSet.getString("nome"));
                usuario.setCpf(resultSet.getString("cpf"));
                usuario.setEmail(resultSet.getString("email"));
                usuario.setSenha(resultSet.getString("senha"));
                usuario.setTipo(resultSet.getString("tipo"));
                return usuario;
            }
        }
    }

    public void cadastrarCompleto(Usuario usuario, String logradouro, String bairro, String cidade, String uf) throws SQLException {
        String sql = "{call sp_transacao_cadastro_completo(?, ?, ?, ?, ?, ?, ?, ?, ?)}";

        try (CallableStatement statement = conexao.getConexao().prepareCall(sql)) {
            statement.setString(1, usuario.getNome());
            statement.setString(2, usuario.getCpf());
            statement.setString(3, usuario.getEmail());
            statement.setString(4, usuario.getSenha());
            statement.setString(5, usuario.getTipo());
            statement.setString(6, logradouro);
            statement.setString(7, bairro);
            statement.setString(8, cidade);
            statement.setString(9, uf);
            statement.execute();
        }
    }
}
