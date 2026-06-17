package view;

import conexao.Conexao;
import dao.EmprestimoDAO;
import dao.LivroDAO;
import dao.UsuarioDAO;
import model.Livro;
import model.Usuario;

import javax.swing.JOptionPane;
import java.math.BigDecimal;
import java.text.NumberFormat;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Locale;
import java.util.List;

public class Main {
    public static void main(String[] args) {
        while (true) {
            String perfil = escolherPerfil();
            if (perfil == null || "Sair".equals(perfil)) {
                return;
            }

            String usuarioBanco = JOptionPane.showInputDialog(null, "Usuário do banco:");
            if (usuarioBanco == null) {
                continue;
            }

            String senhaBanco = JOptionPane.showInputDialog(null, "Senha do banco:");
            if (senhaBanco == null) {
                continue;
            }

            Conexao conexao = null;
            try {
                conexao = new Conexao(usuarioBanco, senhaBanco);
                UsuarioDAO usuarioDAO = new UsuarioDAO(conexao);
                LivroDAO livroDAO = new LivroDAO(conexao);
                EmprestimoDAO emprestimoDAO = new EmprestimoDAO(conexao);

                String cpf = JOptionPane.showInputDialog(null, "CPF do sistema:");
                String senhaSistema = JOptionPane.showInputDialog(null, "Senha do sistema:");
                if (cpf == null || senhaSistema == null) {
                    continue;
                }

                Usuario usuarioAutenticado = usuarioDAO.autenticar(cpf, senhaSistema);
                if (usuarioAutenticado == null) {
                    JOptionPane.showMessageDialog(null, "CPF ou senha inválidos.");
                    continue;
                }

                if ("Aluno".equals(perfil)) {
                    menuAluno(livroDAO, emprestimoDAO, usuarioAutenticado);
                } else {
                    menuFuncionario(conexao, livroDAO, emprestimoDAO, usuarioAutenticado);
                }
            } catch (SQLException e) {
                JOptionPane.showMessageDialog(null, e.getMessage());
            } finally {
                if (conexao != null) {
                    try {
                        conexao.fecharConexao();
                    } catch (SQLException e) {
                        JOptionPane.showMessageDialog(null, e.getMessage());
                    }
                }
            }
        }
    }

    private static String escolherPerfil() {
        Object[] opcoes = {"Funcionário", "Aluno", "Sair"};
        int escolha = JOptionPane.showOptionDialog(
                null,
                "Selecione o perfil:",
                "LibriTech",
                JOptionPane.DEFAULT_OPTION,
                JOptionPane.QUESTION_MESSAGE,
                null,
                opcoes,
                opcoes[0]
        );

        if (escolha < 0 || escolha >= opcoes.length) {
            return "Sair";
        }

        return (String) opcoes[escolha];
    }

    private static void menuAluno(LivroDAO livroDAO, EmprestimoDAO emprestimoDAO, Usuario usuario) {
        while (true) {
            String opcao = JOptionPane.showInputDialog(null,
                    "1. Consultar Acervo\n2. Meus Empréstimos\n3. Sair");

            if (opcao == null || "3".equals(opcao)) {
                return;
            }

            try {
                if ("1".equals(opcao)) {
                    List<Livro> livros = livroDAO.listarAcervo();
                    JOptionPane.showMessageDialog(null, formatarLivros(livros));
                } else if ("2".equals(opcao)) {
                    StringBuilder builder = new StringBuilder();
                    try (ResultSet resultSet = emprestimoDAO.listarPorUsuario(usuario.getIdUsuario())) {
                        while (resultSet.next()) {
                            builder.append("Empréstimo ID: ")
                                    .append(resultSet.getInt("id_emprestimo"))
                                    .append(" | Livro: ")
                                    .append(resultSet.getString("id_livro_fk"))
                                    .append(" | Data: ")
                                    .append(resultSet.getString("data_saida"))
                                    .append('\n');
                        }
                    }
                    JOptionPane.showMessageDialog(null, builder.length() == 0 ? "Nenhum empréstimo encontrado." : builder.toString());
                }
            } catch (SQLException e) {
                JOptionPane.showMessageDialog(null, e.getMessage());
            }
        }
    }

    private static void menuFuncionario(Conexao conexao, LivroDAO livroDAO, EmprestimoDAO emprestimoDAO, Usuario usuario) {
        while (true) {
            String opcao = JOptionPane.showInputDialog(null,
                    "1. Cadastrar Livro\n2. Realizar Empréstimo\n3. Renovar Empréstimo\n4. Realizar Devolução\n5. Excluir Livro\n6. Relatórios\n7. Sair");

            if (opcao == null || "7".equals(opcao)) {
                return;
            }

            try {
                switch (opcao) {
                    case "1" -> cadastrarLivro(livroDAO);
                    case "2" -> realizarEmprestimo(emprestimoDAO);
                    case "3" -> renovarEmprestimo(emprestimoDAO);
                    case "4" -> devolverLivro(emprestimoDAO);
                    case "5" -> excluirLivro(livroDAO);
                    case "6" -> menuRelatorios(conexao);
                    default -> JOptionPane.showMessageDialog(null, "Opção inválida.");
                }
            } catch (SQLException e) {
                JOptionPane.showMessageDialog(null, e.getMessage());
            }
        }
    }

    private static void menuRelatorios(Conexao conexao) {
        while (true) {
            String opcao = JOptionPane.showInputDialog(null,
                    "1. Livros Atrasados\n2. Dashboard Financeiro\n3. Voltar");

            if (opcao == null || "3".equals(opcao)) {
                return;
            }

            try {
                switch (opcao) {
                    case "1" -> exibirLivrosAtrasados(conexao);
                    case "2" -> exibirDashboardFinanceiro(conexao);
                    default -> JOptionPane.showMessageDialog(null, "Opção inválida.");
                }
            } catch (SQLException e) {
                JOptionPane.showMessageDialog(null, e.getMessage());
            }
        }
    }

    private static void exibirLivrosAtrasados(Conexao conexao) throws SQLException {
        String sql = "SELECT * FROM vw_livros_atrasados";
        StringBuilder builder = new StringBuilder();

        try (PreparedStatement statement = conexao.getConexao().prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {
            while (resultSet.next()) {
                builder.append("Empréstimo ID: ")
                        .append(resultSet.getInt("id_emprestimo"))
                        .append(" | Usuário: ")
                        .append(resultSet.getString("usuario"))
                        .append(" | Contato: ")
                        .append(resultSet.getString("contato"))
                        .append(" | Livro: ")
                        .append(resultSet.getString("livro"))
                        .append(" | Data Prevista: ")
                        .append(resultSet.getString("data_prevista"))
                        .append(" | Dias de Atraso: ")
                        .append(resultSet.getInt("dias_atraso"))
                        .append('\n');
            }
        }

        JOptionPane.showMessageDialog(null, builder.length() == 0 ? "Nenhum livro atrasado encontrado." : builder.toString());
    }

    private static void exibirDashboardFinanceiro(Conexao conexao) throws SQLException {
        String sql = "SELECT * FROM vw_dashboard_financeiro";
        StringBuilder builder = new StringBuilder();
        NumberFormat formatoMoeda = NumberFormat.getCurrencyInstance(Locale.forLanguageTag("pt-BR"));

        try (PreparedStatement statement = conexao.getConexao().prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {
            while (resultSet.next()) {
                builder.append("Total de Multas: ")
                        .append(resultSet.getInt("total_multas"))
                        .append(" | Total Arrecadado: ")
                        .append(formatoMoeda.format(resultSet.getBigDecimal("total_arrecadado")))
                        .append(" | Total Pendente: ")
                        .append(formatoMoeda.format(resultSet.getBigDecimal("total_pendente")))
                        .append('\n');
            }
        }

        JOptionPane.showMessageDialog(null, builder.length() == 0 ? "Nenhum dado financeiro encontrado." : builder.toString());
    }

    private static void cadastrarLivro(LivroDAO livroDAO) throws SQLException {
        Livro livro = new Livro();
        livro.setTitulo(JOptionPane.showInputDialog(null, "Título:"));
        livro.setAutor(JOptionPane.showInputDialog(null, "Autor:"));
        livro.setIsbn(JOptionPane.showInputDialog(null, "ISBN:"));
        livro.setPrecoCusto(new BigDecimal(JOptionPane.showInputDialog(null, "Preço de custo:")));
        livro.setQuantidadeEstoque(Integer.parseInt(JOptionPane.showInputDialog(null, "Quantidade em estoque:")));
        livro.setStatus(JOptionPane.showInputDialog(null, "Status:"));
        livroDAO.cadastrar(livro);
        JOptionPane.showMessageDialog(null, "Livro cadastrado com sucesso.");
    }

    private static void realizarEmprestimo(EmprestimoDAO emprestimoDAO) throws SQLException {
        int idUsuario = Integer.parseInt(JOptionPane.showInputDialog(null, "ID do usuário:"));
        int idLivro = Integer.parseInt(JOptionPane.showInputDialog(null, "ID do livro:"));
        emprestimoDAO.realizarEmprestimo(idUsuario, idLivro);
        JOptionPane.showMessageDialog(null, "Empréstimo realizado com sucesso.");
    }

    private static void renovarEmprestimo(EmprestimoDAO emprestimoDAO) throws SQLException {
        int idEmprestimo = Integer.parseInt(JOptionPane.showInputDialog(null, "ID do empréstimo:"));
        emprestimoDAO.renovar(idEmprestimo);
        JOptionPane.showMessageDialog(null, "Empréstimo renovado com sucesso.");
    }

    private static void devolverLivro(EmprestimoDAO emprestimoDAO) throws SQLException {
        int idEmprestimo = Integer.parseInt(JOptionPane.showInputDialog(null, "ID do empréstimo:"));
        BigDecimal multa = emprestimoDAO.devolver(idEmprestimo);
        if (multa.compareTo(BigDecimal.ZERO) > 0) {
            NumberFormat formatoMoeda = NumberFormat.getCurrencyInstance(Locale.forLanguageTag("pt-BR"));
            JOptionPane.showMessageDialog(null, "Devolução realizada. Multa gerada: " + formatoMoeda.format(multa));
        } else {
            JOptionPane.showMessageDialog(null, "Devolução realizada. Nenhuma multa gerada.");
        }
    }

    private static void excluirLivro(LivroDAO livroDAO) throws SQLException {
        int idLivro = Integer.parseInt(JOptionPane.showInputDialog(null, "ID do livro para excluir:"));
        try {
            livroDAO.deletar(idLivro);
            JOptionPane.showMessageDialog(null, "Livro excluído com sucesso.");
        } catch (SQLException e) {
            JOptionPane.showMessageDialog(null, "ERRO: Acesso Negado! Seu perfil de usuário não tem permissão para excluir registros do sistema.");
        }
    }

    private static String formatarLivros(List<Livro> livros) {
        if (livros == null || livros.isEmpty()) {
            return "Nenhum livro encontrado.";
        }

        StringBuilder builder = new StringBuilder();
        for (Livro livro : livros) {
            builder.append(livro.toStringPublico()).append('\n');
        }
        return builder.toString();
    }
}
