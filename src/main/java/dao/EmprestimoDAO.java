package dao;

import conexao.Conexao;

import java.math.BigDecimal;
import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class EmprestimoDAO {
    private static final BigDecimal VALOR_MULTA_DIARIA = new BigDecimal("2.00");
    private final Conexao conexao;

    public EmprestimoDAO(Conexao conexao) {
        this.conexao = conexao;
    }

    public void realizarEmprestimo(int idUsuario, int idLivro) throws SQLException {
        String sql = "{call sp_transacao_emprestimo(?, ?)}";

        try (CallableStatement statement = conexao.getConexao().prepareCall(sql)) {
            statement.setInt(1, idUsuario);
            statement.setInt(2, idLivro);
            statement.execute();
        }
    }

    public void renovar(int idEmprestimo) throws SQLException {
        String sql = "{call sp_renovar_emprestimo(?)}";

        try (CallableStatement statement = conexao.getConexao().prepareCall(sql)) {
            statement.setInt(1, idEmprestimo);
            statement.execute();
        }
    }

    public double calcularMulta(int idEmprestimo) throws SQLException {
        String sql = "{call sp_calcular_multa(?, ?)}";

        try (CallableStatement statement = conexao.getConexao().prepareCall(sql)) {
            statement.setInt(1, idEmprestimo);
            statement.registerOutParameter(2, java.sql.Types.DECIMAL);
            statement.execute();
            return statement.getDouble(2);
        }
    }

    public BigDecimal devolver(int idEmprestimo) throws SQLException {
        int diasAtraso = 0;
        BigDecimal multa = BigDecimal.ZERO;
        String sqlAtraso = "SELECT GREATEST(DATEDIFF(CURDATE(), data_prevista), 0) AS dias_atraso "
                + "FROM Emprestimos WHERE id_emprestimo = ?";

        try (PreparedStatement statement = conexao.getConexao().prepareStatement(sqlAtraso)) {
            statement.setInt(1, idEmprestimo);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    diasAtraso = resultSet.getInt("dias_atraso");
                }
            }
        }

        if (diasAtraso > 0) {
            multa = VALOR_MULTA_DIARIA.multiply(BigDecimal.valueOf(diasAtraso));
            String insertMulta = "INSERT INTO Multas (id_emprestimo_fk, valor, pago) VALUES (?, ?, 0)";
            try (PreparedStatement statement = conexao.getConexao().prepareStatement(insertMulta)) {
                statement.setInt(1, idEmprestimo);
                statement.setBigDecimal(2, multa);
                statement.executeUpdate();
            }
        }

        String sqlDevolucao = "UPDATE Emprestimos SET data_devolucao = NOW() WHERE id_emprestimo = ?";

        try (PreparedStatement statement = conexao.getConexao().prepareStatement(sqlDevolucao)) {
            statement.setInt(1, idEmprestimo);
            statement.executeUpdate();
        }

        String sqlEstoque = "UPDATE Livros "
                + "SET quantidade_estoque = quantidade_estoque + 1, status = 'DISPONIVEL' "
                + "WHERE id_livro = (SELECT id_livro_fk FROM Emprestimos WHERE id_emprestimo = ?)";

        try (PreparedStatement statement = conexao.getConexao().prepareStatement(sqlEstoque)) {
            statement.setInt(1, idEmprestimo);
            statement.executeUpdate();
        }

        return multa;
    }

    public ResultSet listarPorUsuario(int idUsuario) throws SQLException {
        String sql = "SELECT * FROM vw_emprestimos_aluno WHERE id_emprestimo IN "
                + "(SELECT id_emprestimo FROM Emprestimos WHERE id_usuario_fk = ?)";
        PreparedStatement statement = conexao.getConexao().prepareStatement(sql);
        statement.setInt(1, idUsuario);
        return statement.executeQuery();
    }
}
