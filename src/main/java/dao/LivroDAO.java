package dao;

import conexao.Conexao;
import model.Livro;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class LivroDAO {
    private final Conexao conexao;

    public LivroDAO(Conexao conexao) {
        this.conexao = conexao;
    }

    public List<Livro> listarAcervo() throws SQLException {
        String sql = "SELECT * FROM vw_acervo_publico";
        List<Livro> livros = new ArrayList<>();

        try (PreparedStatement statement = conexao.getConexao().prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {
            while (resultSet.next()) {
                Livro livro = new Livro();
                livro.setIdLivro(resultSet.getInt("id_livro"));
                livro.setTitulo(resultSet.getString("titulo"));
                livro.setAutor(resultSet.getString("autor"));
                livro.setIsbn(resultSet.getString("isbn"));
                livro.setStatus(resultSet.getString("status"));
                livros.add(livro);
            }
        }

        return livros;
    }

    public void cadastrar(Livro livro) throws SQLException {
        String sql = "INSERT INTO Livros (titulo, autor, isbn, preco_custo, quantidade_estoque, status) VALUES (?, ?, ?, ?, ?, ?)";

        try (PreparedStatement statement = conexao.getConexao().prepareStatement(sql)) {
            statement.setString(1, livro.getTitulo());
            statement.setString(2, livro.getAutor());
            statement.setString(3, livro.getIsbn());
            statement.setBigDecimal(4, livro.getPrecoCusto());
            statement.setInt(5, livro.getQuantidadeEstoque());
            statement.setString(6, livro.getStatus());
            statement.executeUpdate();
        }
    }

    public void deletar(int idLivro) throws SQLException {
        String sql = "DELETE FROM Livros WHERE id_livro = ?";

        try (PreparedStatement statement = conexao.getConexao().prepareStatement(sql)) {
            statement.setInt(1, idLivro);
            statement.executeUpdate();
        }
    }
}
