# LibriTech

**CESED/UNIFACISA - Sistemas de Informacao**  
Professora: Anna Beatriz Lucena Lira  
Periodo: 2026.1

**Integrantes:**  
Thayslan da Costa  
Walter Luan Lima da Silva  
Pedro Henrique Rodrigues  
Ramon Trindade Camelo  
Joao Vitor Vicente de Queiroz

---

Sistema de gerenciamento bibliotecario desenvolvido como projeto academico da disciplina **Banco de Dados com POO**.

## Sobre o projeto

O LibriTech integra um banco de dados MySQL com uma aplicacao Java desktop para gerenciar acervo, emprestimos, renovacoes, devolucoes, multas e relatorios de uma biblioteca universitaria.

O projeto explora regras de negocio implementadas no banco de dados por meio de stored procedures, triggers, views, indices, transacoes e controle de permissoes por usuario.

## Tecnologias

- **Java 17**
- **Swing** com `JOptionPane`
- **MySQL 8**
- **JDBC** com `mysql-connector-j 9.2.0`
- **Maven**

## Estrutura do projeto

```text
src/main/java/
├── conexao/
│   └── Conexao.java          # conexao JDBC parametrizada por usuario do banco
├── model/
│   ├── Usuario.java          # classe abstrata com prazo de emprestimo
│   ├── Aluno.java            # prazo de 7 dias
│   ├── Funcionario.java      # prazo de 14 dias
│   ├── Livro.java
│   └── Emprestimo.java
├── dao/
│   ├── LivroDAO.java
│   ├── UsuarioDAO.java
│   └── EmprestimoDAO.java
└── view/
    └── Main.java             # interface desktop com JOptionPane
```

## Banco de dados

O script principal do banco esta em:

```text
libritech_completo.sql
```

Ele cria o banco `db_libritech`, as tabelas, usuarios, permissoes, views, stored procedures, triggers, indices, dados iniciais e um plano de testes.

### Tabelas

| Tabela | Descricao |
|---|---|
| `Usuarios` | Usuarios do sistema: aluno, gerente, bibliotecario e estagiario |
| `Enderecos` | Endereco vinculado ao usuario |
| `Livros` | Acervo da biblioteca |
| `Emprestimos` | Registro dos emprestimos realizados |
| `Multas` | Multas geradas por atraso na devolucao |
| `Log_Auditoria` | Registros de auditoria gerados automaticamente por trigger |

### Usuarios do banco

| Usuario | Senha | Perfil | Permissoes principais |
|---|---|---|---|
| `usr_gerente` | `gerente123` | Administrador | Acesso total ao banco `db_libritech` |
| `usr_bibliotecario` | `biblio123` | Operador | Consulta, cadastro e atualizacao em tabelas principais |
| `usr_estagiario` | `estagio123` | Restrito | Consulta e cadastro limitado |
| `usr_aluno` | `aluno123` | Visitante | Consulta a views publicas e autenticacao |

### Stored procedures

- `sp_transacao_emprestimo` - valida pendencias, estoque e prazo; realiza o emprestimo em transacao atomica.
- `sp_renovar_emprestimo` - bloqueia renovacao se houver outro emprestimo ativo para o mesmo livro.
- `sp_calcular_multa` - calcula multa de R$ 2,00 por dia de atraso.
- `sp_transacao_cadastro_completo` - cadastra usuario e endereco em uma unica transacao.

### Triggers

- `trg_trava_horario_livros` - bloqueia cadastro de livros fora do horario comercial.
- `trg_trava_horario_emprestimos` - bloqueia emprestimos fora do horario comercial.
- `trg_trava_horario_livros_update` - bloqueia atualizacao de livros fora do horario comercial.
- `trg_trava_horario_emprestimos_update` - bloqueia atualizacao de emprestimos fora do horario comercial.
- `trg_auditoria_delecao` - registra exclusao de livros em `Log_Auditoria`.
- `trg_limite_emprestimos` - impede mais de 3 emprestimos simultaneos por usuario.
- `trg_preventiva_estoque` - impede que o estoque fique negativo.

### Views

- `vw_acervo_publico` - lista livros disponiveis sem expor `preco_custo`.
- `vw_livros_atrasados` - lista emprestimos vencidos com dados de contato.
- `vw_ranking_leitura` - mostra os livros mais emprestados.
- `vw_emprestimos_aluno` - lista emprestimos para consulta do aluno.
- `vw_dashboard_financeiro` - mostra totais de multas arrecadadas e pendentes.

## Como executar

### Pre-requisitos

- Java 17 ou superior
- MySQL 8 ou superior
- Maven 3.8 ou superior

### 1. Criar o banco

Execute o script completo no MySQL Workbench ou pelo terminal:

```bash
mysql -u root -p < libritech_completo.sql
```

Observacao: o arquivo `libritech_completo.sql` tambem contem um plano de testes no final. Alguns comandos foram feitos para demonstrar erros, bloqueios por trigger e rollback de transacao.

### 2. Compilar e executar a aplicacao

```bash
mvn compile
mvn exec:java
```

### 3. Login

Na tela inicial, selecione o perfil desejado e informe os dados de acesso.

| Perfil selecionado | Usuario do banco | Senha do banco | CPF do sistema | Senha do sistema |
|---|---|---|---|---|
| Funcionario | `usr_gerente` | `gerente123` | `00000000000` | `123456` |
| Funcionario | `usr_bibliotecario` | `biblio123` | `00000000000` | `123456` |
| Funcionario | `usr_estagiario` | `estagio123` | `00000000000` | `123456` |
| Aluno | `usr_aluno` | `aluno123` | `11111111111` | `123456` |

Os acessos com `usr_bibliotecario` e `usr_estagiario` entram no menu de funcionario, mas com permissoes limitadas pelo banco de dados. Por isso, algumas operacoes podem ser bloqueadas, como exclusao de livros.

O script inicial cadastra apenas um gerente e um aluno na tabela `Usuarios`. Por isso, os acessos de funcionario usam o CPF do gerente para passar pela autenticacao do sistema, enquanto o usuario do banco define as permissoes reais da sessao.

## Funcionalidades

### Perfil Aluno

- Consultar acervo disponivel.
- Consultar os proprios emprestimos.

### Perfil Funcionario

- Cadastrar livros.
- Realizar emprestimos.
- Renovar emprestimos.
- Realizar devolucoes.
- Excluir livros.
- Consultar relatorios de livros atrasados.
- Consultar dashboard financeiro de multas.

## Observacoes importantes

- O sistema usa usuarios reais do MySQL para demonstrar controle de acesso por perfil.
- Algumas operacoes podem falhar dependendo do usuario do banco utilizado, pois as permissoes sao controladas diretamente no MySQL.
- As triggers de horario comercial permitem operacoes apenas entre 08h e 18h.
- O menu da aplicacao captura erros do banco e exibe as mensagens em caixas de dialogo.

## Compilacao

Para verificar se o projeto compila:

```bash
mvn compile
```
