-- MySQL dump 10.13  Distrib 9.6.0, for macos26.2 (arm64)
--
-- Host: localhost    Database: db_libritech
-- ------------------------------------------------------
-- Server version	9.6.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;
SET @@SESSION.SQL_LOG_BIN= 0;

--
-- GTID state at the beginning of the backup 
--

SET @@GLOBAL.GTID_PURGED=/*!80000 '+'*/ '4ef7a3d0-2271-11f1-92ff-ce0cd2f761fe:1-515';

--
-- Table structure for table `Emprestimos`
--

DROP TABLE IF EXISTS `Emprestimos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Emprestimos` (
  `id_emprestimo` int NOT NULL AUTO_INCREMENT,
  `id_usuario_fk` int NOT NULL,
  `id_livro_fk` int NOT NULL,
  `data_saida` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `data_prevista` date NOT NULL,
  `data_devolucao` datetime DEFAULT NULL,
  PRIMARY KEY (`id_emprestimo`),
  KEY `fk_emprestimo_usuario` (`id_usuario_fk`),
  KEY `fk_emprestimo_livro` (`id_livro_fk`),
  CONSTRAINT `fk_emprestimo_livro` FOREIGN KEY (`id_livro_fk`) REFERENCES `Livros` (`id_livro`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_emprestimo_usuario` FOREIGN KEY (`id_usuario_fk`) REFERENCES `Usuarios` (`id_usuario`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Emprestimos`
--

LOCK TABLES `Emprestimos` WRITE;
/*!40000 ALTER TABLE `Emprestimos` DISABLE KEYS */;
INSERT INTO `Emprestimos` VALUES (1,2,1,'2026-06-17 11:37:11','2026-06-01','2026-06-17 12:00:53'),(2,2,2,'2026-06-17 11:38:58','2026-06-24',NULL),(3,2,3,'2026-06-17 11:39:05','2026-06-24',NULL),(4,1,2,'2026-06-17 12:23:50','2026-06-24',NULL);
/*!40000 ALTER TABLE `Emprestimos` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_trava_horario_emprestimos` BEFORE INSERT ON `emprestimos` FOR EACH ROW BEGIN
    IF HOUR(NOW()) < 8 OR HOUR(NOW()) >= 18 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ERRO: Operacoes permitidas apenas em horario comercial (08h as 18h).';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_limite_emprestimos` BEFORE INSERT ON `emprestimos` FOR EACH ROW BEGIN
    DECLARE v_total INT DEFAULT 0;

    SELECT COUNT(*) INTO v_total
    FROM Emprestimos
    WHERE id_usuario_fk = NEW.id_usuario_fk
      AND data_devolucao IS NULL;

    IF v_total >= 3 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ERRO: Limite de 3 emprestimos simultaneos atingido.';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `Enderecos`
--

DROP TABLE IF EXISTS `Enderecos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Enderecos` (
  `id_endereco` int NOT NULL AUTO_INCREMENT,
  `logradouro` varchar(150) NOT NULL,
  `bairro` varchar(100) NOT NULL,
  `cidade` varchar(100) NOT NULL,
  `uf` char(2) NOT NULL,
  `id_usuario_fk` int NOT NULL,
  PRIMARY KEY (`id_endereco`),
  KEY `fk_endereco_usuario` (`id_usuario_fk`),
  CONSTRAINT `fk_endereco_usuario` FOREIGN KEY (`id_usuario_fk`) REFERENCES `Usuarios` (`id_usuario`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Enderecos`
--

LOCK TABLES `Enderecos` WRITE;
/*!40000 ALTER TABLE `Enderecos` DISABLE KEYS */;
INSERT INTO `Enderecos` VALUES (1,'Rua Principal','Centro','Campina Grande','PB',1),(2,'Rua das Flores','Bodocongó','Campina Grande','PB',2);
/*!40000 ALTER TABLE `Enderecos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Livros`
--

DROP TABLE IF EXISTS `Livros`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Livros` (
  `id_livro` int NOT NULL AUTO_INCREMENT,
  `titulo` varchar(200) NOT NULL,
  `autor` varchar(150) NOT NULL,
  `isbn` varchar(20) NOT NULL,
  `preco_custo` decimal(10,2) NOT NULL,
  `quantidade_estoque` int NOT NULL DEFAULT '0',
  `status` enum('DISPONIVEL','INDISPONIVEL') NOT NULL DEFAULT 'DISPONIVEL',
  PRIMARY KEY (`id_livro`),
  UNIQUE KEY `uq_isbn` (`isbn`),
  KEY `idx_livros_titulo` (`titulo`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Livros`
--

LOCK TABLES `Livros` WRITE;
/*!40000 ALTER TABLE `Livros` DISABLE KEYS */;
INSERT INTO `Livros` VALUES (1,'Dom Casmurro','Machado de Assis','9788535902778',45.90,4,'DISPONIVEL'),(2,'O Cortiço','Aluísio Azevedo','9788535902779',30.00,2,'DISPONIVEL'),(3,'Iracema','José de Alencar','9788535902780',25.00,2,'DISPONIVEL'),(5,'1Q83','Haruki Murakami','12312242354',20.00,1,'DISPONIVEL');
/*!40000 ALTER TABLE `Livros` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_trava_horario_livros` BEFORE INSERT ON `livros` FOR EACH ROW BEGIN
    IF HOUR(NOW()) < 8 OR HOUR(NOW()) >= 18 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ERRO: Operacoes permitidas apenas em horario comercial (08h as 18h).';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_preventiva_estoque` BEFORE UPDATE ON `livros` FOR EACH ROW BEGIN
    IF NEW.quantidade_estoque < 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'ERRO: Estoque nao pode ficar negativo.';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_auditoria_delecao` AFTER DELETE ON `livros` FOR EACH ROW BEGIN
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `Log_Auditoria`
--

DROP TABLE IF EXISTS `Log_Auditoria`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Log_Auditoria` (
  `id_log` int NOT NULL AUTO_INCREMENT,
  `tabela_afetada` varchar(50) NOT NULL,
  `acao` varchar(50) NOT NULL,
  `usuario_responsavel` varchar(100) NOT NULL,
  `dados_antigos` text,
  `data_hora` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_log`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Log_Auditoria`
--

LOCK TABLES `Log_Auditoria` WRITE;
/*!40000 ALTER TABLE `Log_Auditoria` DISABLE KEYS */;
INSERT INTO `Log_Auditoria` VALUES (1,'Livros','DELETE','usr_gerente@localhost','id:4 | titulo:Memórias Póstumas | isbn:9788535902781 | preco:35.00 | estoque:3','2026-06-17 15:01:50');
/*!40000 ALTER TABLE `Log_Auditoria` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Multas`
--

DROP TABLE IF EXISTS `Multas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Multas` (
  `id_multa` int NOT NULL AUTO_INCREMENT,
  `id_emprestimo_fk` int NOT NULL,
  `valor` decimal(10,2) NOT NULL,
  `pago` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id_multa`),
  KEY `fk_multa_emprestimo` (`id_emprestimo_fk`),
  CONSTRAINT `fk_multa_emprestimo` FOREIGN KEY (`id_emprestimo_fk`) REFERENCES `Emprestimos` (`id_emprestimo`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Multas`
--

LOCK TABLES `Multas` WRITE;
/*!40000 ALTER TABLE `Multas` DISABLE KEYS */;
INSERT INTO `Multas` VALUES (4,1,32.00,0);
/*!40000 ALTER TABLE `Multas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Usuarios`
--

DROP TABLE IF EXISTS `Usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Usuarios` (
  `id_usuario` int NOT NULL AUTO_INCREMENT,
  `nome` varchar(100) NOT NULL,
  `cpf` char(11) NOT NULL,
  `email` varchar(100) NOT NULL,
  `senha` varchar(255) NOT NULL,
  `tipo` enum('ALUNO','GERENTE','BIBLIOTECARIO','ESTAGIARIO') NOT NULL,
  PRIMARY KEY (`id_usuario`),
  UNIQUE KEY `uq_cpf` (`cpf`),
  UNIQUE KEY `uq_email` (`email`),
  KEY `idx_usuarios_cpf` (`cpf`),
  KEY `idx_usuarios_email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Usuarios`
--

LOCK TABLES `Usuarios` WRITE;
/*!40000 ALTER TABLE `Usuarios` DISABLE KEYS */;
INSERT INTO `Usuarios` VALUES (1,'Admin Gerente','00000000000','gerente@libritech.com','123456','GERENTE'),(2,'João Aluno','11111111111','joao@libritech.com','123456','ALUNO');
/*!40000 ALTER TABLE `Usuarios` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `vw_acervo_publico`
--

DROP TABLE IF EXISTS `vw_acervo_publico`;
/*!50001 DROP VIEW IF EXISTS `vw_acervo_publico`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_acervo_publico` AS SELECT 
 1 AS `id_livro`,
 1 AS `titulo`,
 1 AS `autor`,
 1 AS `isbn`,
 1 AS `status`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_dashboard_financeiro`
--

DROP TABLE IF EXISTS `vw_dashboard_financeiro`;
/*!50001 DROP VIEW IF EXISTS `vw_dashboard_financeiro`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_dashboard_financeiro` AS SELECT 
 1 AS `total_multas`,
 1 AS `total_arrecadado`,
 1 AS `total_pendente`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_livros_atrasados`
--

DROP TABLE IF EXISTS `vw_livros_atrasados`;
/*!50001 DROP VIEW IF EXISTS `vw_livros_atrasados`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_livros_atrasados` AS SELECT 
 1 AS `id_emprestimo`,
 1 AS `usuario`,
 1 AS `contato`,
 1 AS `livro`,
 1 AS `data_prevista`,
 1 AS `dias_atraso`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_ranking_leitura`
--

DROP TABLE IF EXISTS `vw_ranking_leitura`;
/*!50001 DROP VIEW IF EXISTS `vw_ranking_leitura`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_ranking_leitura` AS SELECT 
 1 AS `titulo`,
 1 AS `autor`,
 1 AS `total_emprestimos`*/;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `vw_acervo_publico`
--

/*!50001 DROP VIEW IF EXISTS `vw_acervo_publico`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_acervo_publico` AS select `livros`.`id_livro` AS `id_livro`,`livros`.`titulo` AS `titulo`,`livros`.`autor` AS `autor`,`livros`.`isbn` AS `isbn`,`livros`.`status` AS `status` from `livros` where (`livros`.`status` = 'DISPONIVEL') */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_dashboard_financeiro`
--

/*!50001 DROP VIEW IF EXISTS `vw_dashboard_financeiro`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_dashboard_financeiro` AS select count(0) AS `total_multas`,sum(`multas`.`valor`) AS `total_arrecadado`,sum((case when (`multas`.`pago` = 0) then `multas`.`valor` else 0 end)) AS `total_pendente` from `multas` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_livros_atrasados`
--

/*!50001 DROP VIEW IF EXISTS `vw_livros_atrasados`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_livros_atrasados` AS select `e`.`id_emprestimo` AS `id_emprestimo`,`u`.`nome` AS `usuario`,`u`.`email` AS `contato`,`l`.`titulo` AS `livro`,`e`.`data_prevista` AS `data_prevista`,(to_days(curdate()) - to_days(`e`.`data_prevista`)) AS `dias_atraso` from ((`emprestimos` `e` join `usuarios` `u` on((`e`.`id_usuario_fk` = `u`.`id_usuario`))) join `livros` `l` on((`e`.`id_livro_fk` = `l`.`id_livro`))) where ((`e`.`data_devolucao` is null) and (`e`.`data_prevista` < curdate())) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_ranking_leitura`
--

/*!50001 DROP VIEW IF EXISTS `vw_ranking_leitura`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_ranking_leitura` AS select `l`.`titulo` AS `titulo`,`l`.`autor` AS `autor`,count(`e`.`id_emprestimo`) AS `total_emprestimos` from (`livros` `l` join `emprestimos` `e` on((`l`.`id_livro` = `e`.`id_livro_fk`))) group by `l`.`id_livro`,`l`.`titulo`,`l`.`autor` order by `total_emprestimos` desc limit 10 */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
SET @@SESSION.SQL_LOG_BIN = @MYSQLDUMP_TEMP_LOG_BIN;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-06-17 12:28:06
