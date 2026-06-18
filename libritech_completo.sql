-- LibriTech - Sistema de Gestao Bibliotecaria

DROP DATABASE IF EXISTS db_libritech;
CREATE DATABASE IF NOT EXISTS db_libritech;
USE db_libritech;

-- --------------------------------
-- TABELAS
-- --------------------------------

CREATE TABLE Usuarios (
    id_usuario  INT          NOT NULL AUTO_INCREMENT,
    nome        VARCHAR(100) NOT NULL,
    cpf         CHAR(11)     NOT NULL,
    email       VARCHAR(100) NOT NULL,
    senha       VARCHAR(255) NOT NULL,
    tipo        ENUM('ALUNO', 'GERENTE', 'BIBLIOTECARIO', 'ESTAGIARIO') NOT NULL,

    CONSTRAINT pk_usuarios PRIMARY KEY (id_usuario),
    CONSTRAINT uq_cpf      UNIQUE (cpf),
    CONSTRAINT uq_email    UNIQUE (email)
);

CREATE TABLE Enderecos (
    id_endereco   INT          NOT NULL AUTO_INCREMENT,
    logradouro    VARCHAR(150) NOT NULL,
    bairro        VARCHAR(100) NOT NULL,
    cidade        VARCHAR(100) NOT NULL,
    uf            CHAR(2)      NOT NULL,
    id_usuario_fk INT          NOT NULL,

    CONSTRAINT pk_enderecos       PRIMARY KEY (id_endereco),
    CONSTRAINT fk_endereco_usuario
        FOREIGN KEY (id_usuario_fk) REFERENCES Usuarios (id_usuario)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Livros (
    id_livro           INT            NOT NULL AUTO_INCREMENT,
    titulo             VARCHAR(200)   NOT NULL,
    autor              VARCHAR(150)   NOT NULL,
    isbn               VARCHAR(20)    NOT NULL,
    preco_custo        DECIMAL(10, 2) NOT NULL,
    quantidade_estoque INT            NOT NULL DEFAULT 0,
    status             ENUM('DISPONIVEL', 'INDISPONIVEL') NOT NULL DEFAULT 'DISPONIVEL',

    CONSTRAINT pk_livros PRIMARY KEY (id_livro),
    CONSTRAINT uq_isbn   UNIQUE (isbn)
);

CREATE TABLE Emprestimos (
    id_emprestimo  INT      NOT NULL AUTO_INCREMENT,
    id_usuario_fk  INT      NOT NULL,
    id_livro_fk    INT      NOT NULL,
    data_saida     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_prevista  DATE     NOT NULL,
    data_devolucao DATETIME NULL,

    CONSTRAINT pk_emprestimos PRIMARY KEY (id_emprestimo),
    CONSTRAINT fk_emprestimo_usuario
        FOREIGN KEY (id_usuario_fk) REFERENCES Usuarios (id_usuario)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_emprestimo_livro
        FOREIGN KEY (id_livro_fk) REFERENCES Livros (id_livro)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE Multas (
    id_multa         INT           NOT NULL AUTO_INCREMENT,
    id_emprestimo_fk INT           NOT NULL,
    valor            DECIMAL(10,2) NOT NULL,
    pago             TINYINT(1)    NOT NULL DEFAULT 0,

    CONSTRAINT pk_multas PRIMARY KEY (id_multa),
    CONSTRAINT fk_multa_emprestimo
        FOREIGN KEY (id_emprestimo_fk) REFERENCES Emprestimos (id_emprestimo)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

CREATE TABLE Log_Auditoria (
    id_log              INT          NOT NULL AUTO_INCREMENT,
    tabela_afetada      VARCHAR(50)  NOT NULL,
    acao                VARCHAR(50)  NOT NULL,
    usuario_responsavel VARCHAR(100) NOT NULL,
    dados_antigos       TEXT         NULL,
    data_hora           TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_log_auditoria PRIMARY KEY (id_log)
);

-- --------------------------------
-- USUARIOS E PERMISSOES
-- --------------------------------

CREATE USER IF NOT EXISTS 'usr_gerente'@'localhost'       IDENTIFIED BY 'gerente123';
CREATE USER IF NOT EXISTS 'usr_bibliotecario'@'localhost' IDENTIFIED BY 'biblio123';
CREATE USER IF NOT EXISTS 'usr_estagiario'@'localhost'    IDENTIFIED BY 'estagio123';
CREATE USER IF NOT EXISTS 'usr_aluno'@'localhost'         IDENTIFIED BY 'aluno123';

GRANT ALL PRIVILEGES ON db_libritech.* TO 'usr_gerente'@'localhost';

GRANT SELECT, INSERT, UPDATE ON db_libritech.Usuarios      TO 'usr_bibliotecario'@'localhost';
GRANT SELECT, INSERT, UPDATE ON db_libritech.Enderecos     TO 'usr_bibliotecario'@'localhost';
GRANT SELECT, INSERT, UPDATE ON db_libritech.Livros        TO 'usr_bibliotecario'@'localhost';
GRANT SELECT, INSERT, UPDATE ON db_libritech.Emprestimos   TO 'usr_bibliotecario'@'localhost';
GRANT SELECT, INSERT, UPDATE ON db_libritech.Multas        TO 'usr_bibliotecario'@'localhost';
GRANT SELECT                 ON db_libritech.Log_Auditoria TO 'usr_bibliotecario'@'localhost';

GRANT SELECT, INSERT ON db_libritech.Livros      TO 'usr_estagiario'@'localhost';
GRANT SELECT, INSERT ON db_libritech.Emprestimos TO 'usr_estagiario'@'localhost';
GRANT SELECT         ON db_libritech.Usuarios    TO 'usr_estagiario'@'localhost';

GRANT SELECT ON db_libritech.vw_acervo_publico  TO 'usr_aluno'@'localhost';
GRANT SELECT ON db_libritech.vw_ranking_leitura TO 'usr_aluno'@'localhost';
GRANT SELECT ON db_libritech.vw_emprestimos_aluno TO 'usr_aluno'@'localhost';
GRANT SELECT ON db_libritech.Usuarios           TO 'usr_aluno'@'localhost';

FLUSH PRIVILEGES;

-- --------------------------------
-- VIEWS
-- --------------------------------

CREATE OR REPLACE VIEW vw_acervo_publico AS
    SELECT
        id_livro,
        titulo,
        autor,
        isbn,
        status
    FROM Livros
    WHERE status = 'DISPONIVEL';

CREATE OR REPLACE VIEW vw_livros_atrasados AS
    SELECT
        e.id_emprestimo,
        u.nome   AS usuario,
        u.email  AS contato,
        l.titulo AS livro,
        e.data_prevista,
        DATEDIFF(CURDATE(), e.data_prevista) AS dias_atraso
    FROM Emprestimos e
    JOIN Usuarios u ON e.id_usuario_fk = u.id_usuario
    JOIN Livros   l ON e.id_livro_fk   = l.id_livro
    WHERE e.data_devolucao IS NULL
      AND e.data_prevista < CURDATE();

CREATE OR REPLACE VIEW vw_ranking_leitura AS
    SELECT
        l.titulo,
        l.autor,
        COUNT(e.id_emprestimo) AS total_emprestimos
    FROM Livros l
    JOIN Emprestimos e ON l.id_livro = e.id_livro_fk
    GROUP BY l.id_livro, l.titulo, l.autor
    ORDER BY total_emprestimos DESC
    LIMIT 10;

CREATE OR REPLACE VIEW vw_emprestimos_aluno AS
    SELECT
        e.id_emprestimo,
        l.titulo AS livro,
        e.data_saida,
        e.data_prevista,
        e.data_devolucao
    FROM Emprestimos e
    JOIN Livros l ON e.id_livro_fk = l.id_livro;

CREATE OR REPLACE VIEW vw_dashboard_financeiro AS
    SELECT
        COUNT(*)                                       AS total_multas,
        SUM(valor)                                     AS total_arrecadado,
        SUM(CASE WHEN pago = 0 THEN valor ELSE 0 END) AS total_pendente
    FROM Multas;

-- --------------------------------
-- STORED PROCEDURES
-- --------------------------------

DELIMITER $$

CREATE PROCEDURE sp_transacao_emprestimo(
    IN p_id_usuario INT,
    IN p_id_livro   INT
)
BEGIN
    DECLARE v_estoque    INT DEFAULT 0;
    DECLARE v_pendencias INT DEFAULT 0;
    DECLARE v_prazo      INT DEFAULT 7;
    DECLARE v_tipo       VARCHAR(20);

    START TRANSACTION;

    SELECT COUNT(*) INTO v_pendencias
    FROM Multas m
    JOIN Emprestimos e ON m.id_emprestimo_fk = e.id_emprestimo
    WHERE e.id_usuario_fk = p_id_usuario
      AND m.pago = 0;

    IF v_pendencias > 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ERRO: Usuario possui multa pendente. Quite antes de realizar novo emprestimo.';
    END IF;

    SELECT quantidade_estoque INTO v_estoque
    FROM Livros
    WHERE id_livro = p_id_livro;

    IF v_estoque <= 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ERRO: Livro sem estoque disponivel.';
    END IF;

    SELECT tipo INTO v_tipo FROM Usuarios WHERE id_usuario = p_id_usuario;

    IF v_tipo = 'ALUNO' THEN
        SET v_prazo = 7;
    ELSE
        SET v_prazo = 14;
    END IF;

    INSERT INTO Emprestimos (id_usuario_fk, id_livro_fk, data_prevista)
    VALUES (p_id_usuario, p_id_livro, DATE_ADD(CURDATE(), INTERVAL v_prazo DAY));

    UPDATE Livros
    SET quantidade_estoque = quantidade_estoque - 1,
        status = CASE WHEN quantidade_estoque - 1 = 0 THEN 'INDISPONIVEL' ELSE 'DISPONIVEL' END
    WHERE id_livro = p_id_livro;

    COMMIT;
END$$


CREATE PROCEDURE sp_renovar_emprestimo(
    IN p_id_emprestimo INT
)
BEGIN
    DECLARE v_reservas INT DEFAULT 0;
    DECLARE v_id_livro INT;

    START TRANSACTION;

    SELECT id_livro_fk INTO v_id_livro
    FROM Emprestimos
    WHERE id_emprestimo = p_id_emprestimo
      AND data_devolucao IS NULL;

    SELECT COUNT(*) INTO v_reservas
    FROM Emprestimos
    WHERE id_livro_fk   = v_id_livro
      AND id_emprestimo != p_id_emprestimo
      AND data_devolucao IS NULL;

    IF v_reservas > 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ERRO: Nao e possivel renovar. Outro usuario esta aguardando este livro.';
    END IF;

    UPDATE Emprestimos
    SET data_prevista = DATE_ADD(data_prevista, INTERVAL 7 DAY)
    WHERE id_emprestimo = p_id_emprestimo;

    COMMIT;
END$$


CREATE PROCEDURE sp_calcular_multa(
    IN  p_id_emprestimo INT,
    OUT p_valor_multa   DECIMAL(10,2)
)
BEGIN
    DECLARE v_data_prevista  DATE;
    DECLARE v_data_devolucao DATE;
    DECLARE v_dias_atraso    INT DEFAULT 0;

    SELECT data_prevista,
           COALESCE(DATE(data_devolucao), CURDATE())
    INTO v_data_prevista, v_data_devolucao
    FROM Emprestimos
    WHERE id_emprestimo = p_id_emprestimo;

    SET v_dias_atraso = DATEDIFF(v_data_devolucao, v_data_prevista);

    IF v_dias_atraso > 0 THEN
        SET p_valor_multa = v_dias_atraso * 2.00;
    ELSE
        SET p_valor_multa = 0.00;
    END IF;
END$$


CREATE PROCEDURE sp_transacao_cadastro_completo(
    IN p_nome       VARCHAR(100),
    IN p_cpf        CHAR(11),
    IN p_email      VARCHAR(100),
    IN p_senha      VARCHAR(255),
    IN p_tipo       VARCHAR(20),
    IN p_logradouro VARCHAR(150),
    IN p_bairro     VARCHAR(100),
    IN p_cidade     VARCHAR(100),
    IN p_uf         CHAR(2)
)
BEGIN
    DECLARE v_id_usuario INT;

    START TRANSACTION;

    INSERT INTO Usuarios (nome, cpf, email, senha, tipo)
    VALUES (p_nome, p_cpf, p_email, p_senha, p_tipo);

    SET v_id_usuario = LAST_INSERT_ID();

    INSERT INTO Enderecos (logradouro, bairro, cidade, uf, id_usuario_fk)
    VALUES (p_logradouro, p_bairro, p_cidade, p_uf, v_id_usuario);

    COMMIT;
END$$

-- --------------------------------
-- TRIGGERS
-- --------------------------------

CREATE TRIGGER trg_trava_horario_livros
BEFORE INSERT ON Livros
FOR EACH ROW
BEGIN
    IF HOUR(NOW()) < 8 OR HOUR(NOW()) >= 18 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ERRO: Operacoes permitidas apenas em horario comercial (08h as 18h).';
    END IF;
END$$

CREATE TRIGGER trg_trava_horario_emprestimos
BEFORE INSERT ON Emprestimos
FOR EACH ROW
BEGIN
    IF HOUR(NOW()) < 8 OR HOUR(NOW()) >= 18 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ERRO: Operacoes permitidas apenas em horario comercial (08h as 18h).';
    END IF;
END$$

CREATE TRIGGER trg_trava_horario_livros_update
BEFORE UPDATE ON Livros
FOR EACH ROW
BEGIN
    IF HOUR(NOW()) < 8 OR HOUR(NOW()) >= 18 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ERRO: Operacoes permitidas apenas em horario comercial (08h as 18h).';
    END IF;
END$$

CREATE TRIGGER trg_trava_horario_emprestimos_update
BEFORE UPDATE ON Emprestimos
FOR EACH ROW
BEGIN
    IF HOUR(NOW()) < 8 OR HOUR(NOW()) >= 18 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ERRO: Operacoes permitidas apenas em horario comercial (08h as 18h).';
    END IF;
END$$

CREATE TRIGGER trg_auditoria_delecao
AFTER DELETE ON Livros
FOR EACH ROW
BEGIN
    INSERT INTO Log_Auditoria (tabela_afetada, acao, usuario_responsavel, dados_antigos)
    VALUES (
        'Livros',
        'DELETE',
        USER(),
        CONCAT(
            'id:', OLD.id_livro,
            ' | titulo:', OLD.titulo,
            ' | isbn:', OLD.isbn,
            ' | preco:', OLD.preco_custo,
            ' | estoque:', OLD.quantidade_estoque
        )
    );
END$$

CREATE TRIGGER trg_limite_emprestimos
BEFORE INSERT ON Emprestimos
FOR EACH ROW
BEGIN
    DECLARE v_total INT DEFAULT 0;

    SELECT COUNT(*) INTO v_total
    FROM Emprestimos
    WHERE id_usuario_fk = NEW.id_usuario_fk
      AND data_devolucao IS NULL;

    IF v_total >= 3 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ERRO: Limite de 3 emprestimos simultaneos atingido.';
    END IF;
END$$

CREATE TRIGGER trg_preventiva_estoque
BEFORE UPDATE ON Livros
FOR EACH ROW
BEGIN
    IF NEW.quantidade_estoque < 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ERRO: Estoque nao pode ficar negativo.';
    END IF;
END$$

DELIMITER ;

-- --------------------------------
-- INDICES
-- --------------------------------

-- Buscas por titulo sao frequentes no menu de consulta de acervo
CREATE INDEX idx_livros_titulo ON Livros (titulo);

-- CPF e email sao usados no login e no cadastro para checar duplicidade
CREATE INDEX idx_usuarios_cpf   ON Usuarios (cpf);
CREATE INDEX idx_usuarios_email ON Usuarios (email);

-- ================================
-- PLANO DE TESTES
-- ================================

-- --------------------------------
-- DADOS DE TESTE
-- --------------------------------

INSERT INTO Usuarios (nome, cpf, email, senha, tipo)
VALUES ('Admin Gerente', '00000000000', 'gerente@libritech.com', '123456', 'GERENTE');

INSERT INTO Enderecos (logradouro, bairro, cidade, uf, id_usuario_fk)
VALUES ('Rua Principal', 'Centro', 'Campina Grande', 'PB', 1);

INSERT INTO Usuarios (nome, cpf, email, senha, tipo)
VALUES ('Joao Aluno', '11111111111', 'joao@libritech.com', '123456', 'ALUNO');

INSERT INTO Enderecos (logradouro, bairro, cidade, uf, id_usuario_fk)
VALUES ('Rua das Flores', 'Bodocongo', 'Campina Grande', 'PB', 2);

INSERT INTO Livros (titulo, autor, isbn, preco_custo, quantidade_estoque, status)
VALUES
    ('Dom Casmurro',     'Machado de Assis', '9788535902778', 45.90, 5, 'DISPONIVEL'),
    ('O Cortico',        'Aluisio Azevedo',  '9788535902779', 30.00, 3, 'DISPONIVEL'),
    ('Iracema',          'Jose de Alencar',  '9788535902780', 25.00, 3, 'DISPONIVEL'),
    ('Memorias Postumas','Machado de Assis', '9788535902781', 35.00, 3, 'DISPONIVEL');

-- --------------------------------
-- TESTE 1: Restricao de horario comercial (trg_trava_horario_livros)
-- A trigger bloqueia insercoes fora do horario 08h-18h.
-- Para demonstrar em horario comercial, invertemos temporariamente a logica.
-- --------------------------------

-- Passo 1: inverte a logica para bloquear dentro do horario comercial
DROP TRIGGER trg_trava_horario_livros;

DELIMITER $$
CREATE TRIGGER trg_trava_horario_livros
BEFORE INSERT ON Livros
FOR EACH ROW
BEGIN
    IF HOUR(NOW()) >= 8 AND HOUR(NOW()) < 18 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ERRO: Operacoes permitidas apenas em horario comercial (08h as 18h).';
    END IF;
END$$
DELIMITER ;

-- Passo 2: tenta inserir livro via aplicacao Java (opcao 1 do menu Funcionario)
-- Resultado esperado: erro de trigger exibido no JOptionPane

-- Passo 3: restaura a trigger para a logica original
DROP TRIGGER trg_trava_horario_livros;

DELIMITER $$
CREATE TRIGGER trg_trava_horario_livros
BEFORE INSERT ON Livros
FOR EACH ROW
BEGIN
    IF HOUR(NOW()) < 8 OR HOUR(NOW()) >= 18 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ERRO: Operacoes permitidas apenas em horario comercial (08h as 18h).';
    END IF;
END$$
DELIMITER ;

-- --------------------------------
-- TESTE 2: Atomicidade de transacao (sp_transacao_cadastro_completo)
-- Tenta cadastrar usuario com UF invalida (mais de 2 caracteres)
-- Esperado: ROLLBACK - usuario NAO deve ser inserido em Usuarios
-- --------------------------------

CALL sp_transacao_cadastro_completo(
    'Teste Atomicidade', '99999999999', 'teste@t.com',
    '123', 'ALUNO', 'Rua X', 'Bairro', 'Cidade', 'INVALIDO_UF'
);

-- Verificacao: deve retornar vazio
SELECT * FROM Usuarios WHERE cpf = '99999999999';

-- --------------------------------
-- TESTE 3: Seguranca de perfil (usr_estagiario sem DELETE)
-- Realizado via aplicacao Java: logar como usr_estagiario e tentar excluir livro
-- Resultado esperado: "ERRO: Acesso Negado! Seu perfil de usuario nao tem permissao
--                      para excluir registros do sistema."
-- (bloqueio imposto pelo banco, capturado via SQLException no Java)
-- --------------------------------

-- --------------------------------
-- TESTE 4: Auditoria de delecao (trg_auditoria_delecao)
-- Exclusao realizada via aplicacao Java (opcao 5 do menu, logado como usr_gerente)
-- Esperado: registro com dados do livro deletado gravado automaticamente em Log_Auditoria
-- --------------------------------

-- Verificacao:
SELECT * FROM Log_Auditoria;

-- --------------------------------
-- TESTE 5: Limite de emprestimos simultaneos (trg_limite_emprestimos)
-- Realiza 3 emprestimos validos e tenta um 4o
-- Esperado: 3 emprestimos inseridos com sucesso, 4o bloqueado pela trigger
-- --------------------------------

CALL sp_transacao_emprestimo(2, 1);
CALL sp_transacao_emprestimo(2, 2);
CALL sp_transacao_emprestimo(2, 3);
CALL sp_transacao_emprestimo(2, 4);

-- --------------------------------
-- TESTE 6: Renovacao com livro reservado (sp_renovar_emprestimo)
-- Insere segundo emprestimo ativo do mesmo livro e tenta renovar o primeiro
-- Esperado: renovacao bloqueada pela procedure
-- --------------------------------

INSERT INTO Emprestimos (id_usuario_fk, id_livro_fk, data_prevista)
VALUES (1, 2, DATE_ADD(CURDATE(), INTERVAL 7 DAY));

-- Renovacao tentada via aplicacao Java (opcao 3 do menu, emprestimo 2)
-- Resultado: "ERRO: Nao e possivel renovar. Outro usuario esta aguardando este livro."

-- --------------------------------
-- TESTE 6b: Devolucao atrasada com multa (sp_calcular_multa)
-- Simula atraso forcando data_prevista para o passado e realiza devolucao
-- Esperado: multa de R$ 32,00 inserida em Multas (16 dias x R$ 2,00)
-- --------------------------------

UPDATE Emprestimos SET data_prevista = '2026-06-01' WHERE id_emprestimo = 1;

-- Devolucao realizada via aplicacao Java (opcao 4 do menu Funcionario)
-- Verificacao:
SELECT * FROM Multas;

-- --------------------------------
-- TESTE 7: View de acervo publico (vw_acervo_publico)
-- Realizado via aplicacao Java: logar como usr_aluno e consultar acervo
-- Resultado esperado: preco_custo NAO aparece na listagem
-- --------------------------------

-- Verificacao direta no banco:
SELECT * FROM vw_acervo_publico;

-- --------------------------------
-- TESTE 8: Indices e EXPLAIN
-- Demonstra uso dos indices em titulo, cpf e email
-- Resultado: tipo 'Index lookup' ou 'Rows fetched before execution' confirma uso do indice
-- --------------------------------

EXPLAIN SELECT * FROM Livros   WHERE titulo = 'Dom Casmurro';
EXPLAIN SELECT * FROM Usuarios WHERE cpf    = '00000000000';
EXPLAIN SELECT * FROM Usuarios WHERE email  = 'joao@libritech.com';
