-- MySQL dump 10.13  Distrib 8.0.18, for Win64 (x86_64)
--
-- ------------------------------------------------------
-- This dump was using 5.5.64-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `players`
--

DROP TABLE IF EXISTS `players`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `players` (
  `idUnique` int(32) unsigned NOT NULL AUTO_INCREMENT,
  `idSteam` varchar(82) DEFAULT NULL,
  `idSocialClub` varchar(99) DEFAULT NULL,
  `idFiveM` varchar(100) DEFAULT NULL,
  `idDiscord` varchar(99) DEFAULT NULL,
  `idClan` int(16) unsigned NOT NULL DEFAULT '0',
  `ip` varchar(15) DEFAULT NULL,
  `username` varchar(32) DEFAULT NULL,
  `cop` int(16) NOT NULL DEFAULT '1',
  `civ` int(16) NOT NULL DEFAULT '1',
  `wanted` int(4) unsigned NOT NULL DEFAULT '0',
  `warns` int(11) NOT NULL DEFAULT '0',
  `kicks` int(11) NOT NULL DEFAULT '0',
  `bans` int(11) NOT NULL DEFAULT '0',
  `perms` int(4) NOT NULL DEFAULT '1' COMMENT '0=Banned 1=Player 2=Mod 3=Admin',
  `bantime` timestamp NULL DEFAULT NULL,
  `reason` text,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `lastjoin` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`idUnique`),
  UNIQUE KEY `idUnique_UNIQUE` (`idUnique`),
  UNIQUE KEY `idSocialClub_UNIQUE` (`idSocialClub`),
  UNIQUE KEY `idSteam_UNIQUE` (`idSteam`),
  UNIQUE KEY `idFiveM_UNIQUE` (`idFiveM`),
  UNIQUE KEY `idDiscord_UNIQUE` (`idDiscord`)
) ENGINE=InnoDB AUTO_INCREMENT=53 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `characters`
--

DROP TABLE IF EXISTS `characters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `characters` (
  `dbid` int(32) NOT NULL AUTO_INCREMENT,
  `idUnique` int(32) unsigned NOT NULL,
  `model` varchar(36) NOT NULL DEFAULT 'mp_m_freemode_01',
  `cash` int(32) NOT NULL DEFAULT '1000',
  `bank` int(32) NOT NULL DEFAULT '5000',
  `blenddata` text COMMENT 'The ped blend data',
  `hairstyle` text COMMENT 'hair style, color, highlight',
  `bodystyle` text COMMENT 'Permanent body features of the player',
  `overlay` text COMMENT 'changeable body style of the player',
  `clothes` text COMMENT 'active outfit',
  `preset1` text,
  `preset2` text,
  `preset3` text,
  `position` varchar(48) NOT NULL DEFAULT '{"x":0.1,"y":0.1,"z":0.1}',
  PRIMARY KEY (`dbid`),
  UNIQUE KEY `dbid` (`dbid`),
  UNIQUE KEY `idUnique_UNIQUE` (`idUnique`),
  KEY `fk_players_idx` (`idUnique`),
  CONSTRAINT `characters_ibfk_players` FOREIGN KEY (`idUnique`) REFERENCES `players` (`idUnique`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `clans`
--

DROP TABLE IF EXISTS `clans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `clans` (
  `idClan` int(32) unsigned NOT NULL,
  `idLeader` int(32) unsigned NOT NULL,
  `tag` varchar(8) NOT NULL DEFAULT 'TAG',
  `title` varchar(26) NOT NULL DEFAULT 'My Clan Name',
  `cop` int(16) unsigned NOT NULL DEFAULT '1',
  `civ` int(16) unsigned NOT NULL DEFAULT '1',
  PRIMARY KEY (`idClan`),
  UNIQUE KEY `idClan` (`idClan`),
  UNIQUE KEY `idLeader_UNIQUE` (`idLeader`),
  CONSTRAINT `clans_ibfk_players` FOREIGN KEY (`idLeader`) REFERENCES `players` (`idUnique`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `inmates`
--

DROP TABLE IF EXISTS `inmates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inmates` (
  `idPrisoner` int(32) unsigned NOT NULL,
  `idUnique` int(32) unsigned NOT NULL,
  `sentence` int(32) NOT NULL,
  `isPrison` tinyint(1) NOT NULL DEFAULT '0' COMMENT '1=Prison',
  PRIMARY KEY (`idPrisoner`),
  UNIQUE KEY `idUnique_UNIQUE` (`idUnique`),
  CONSTRAINT `inmates_ibfk_players` FOREIGN KEY (`idUnique`) REFERENCES `players` (`idUnique`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pickup_spots`
--

DROP TABLE IF EXISTS `pickup_spots`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pickup_spots` (
  `id` int(32) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(99) DEFAULT NULL COMMENT '(opt) The name of the spot',
  `x` decimal(8,2) NOT NULL DEFAULT '1.50',
  `y` decimal(8,2) NOT NULL DEFAULT '1.50',
  `z` decimal(8,2) NOT NULL DEFAULT '70.90',
  `ptype` int(2) unsigned NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=latin1 COMMENT='A list of spots where pickups can be obtained';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pickup_types`
--

DROP TABLE IF EXISTS `pickup_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pickup_types` (
  `id` int(32) unsigned NOT NULL AUTO_INCREMENT,
  `ptype` int(2) unsigned NOT NULL DEFAULT '1' COMMENT '1:Weapon 2:Armor 3:Health 4:Unused',
  `item` varchar(48) NOT NULL DEFAULT 'WEAPON_KNIFE' COMMENT 'The proper name for giving to the player (WEAPON_KNIFE)',
  `model` varchar(48) NOT NULL DEFAULT 'w_pi_knife' COMMENT 'The model for the pickup spinny thing',
  `give_min` int(16) unsigned NOT NULL DEFAULT '1',
  `give_max` int(16) unsigned NOT NULL DEFAULT '1',
  `icon` int(8) unsigned NOT NULL DEFAULT '156',
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=latin1 COMMENT='A list of all the pickup options available';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pickup_waiting`
--

DROP TABLE IF EXISTS `pickup_waiting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pickup_waiting` (
  `id` int(32) unsigned NOT NULL AUTO_INCREMENT,
  `spot_id` int(32) unsigned NOT NULL,
  `type_id` int(32) unsigned NOT NULL,
  `server_hash` varchar(12) NOT NULL,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`),
  UNIQUE KEY `server_hash_UNIQUE` (`server_hash`)
) ENGINE=InnoDB AUTO_INCREMENT=153 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `robberies`
--

DROP TABLE IF EXISTS `robberies`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `robberies` (
  `idRobbery` int(32) unsigned NOT NULL,
  `idUnique` int(32) unsigned NOT NULL,
  `cash` int(11) NOT NULL,
  `committed` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`idRobbery`),
  UNIQUE KEY `idUnique_UNIQUE` (`idUnique`),
  KEY `idUnique` (`idUnique`),
  CONSTRAINT `robberies_idfk_1` FOREIGN KEY (`idUnique`) REFERENCES `players` (`idUnique`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping routines for database 'cnrobbers'
--
/*!50003 DROP FUNCTION IF EXISTS `bank_transaction` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`fxserver`@`localhost` FUNCTION `bank_transaction`(`uid` INT(16) UNSIGNED, `amt` INT(32)) RETURNS int(32)
    NO SQL
BEGIN
  
  # Game script must verify non-negative before calling
  
  DECLARE money INT;
  
  UPDATE characters
    SET bank = bank + amt
    WHERE idUnique = uid;
    
  SELECT bank INTO money
    FROM characters
    WHERE idUnique = uid;
    
  RETURN money;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `cash_transaction` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`fxserver`@`localhost` FUNCTION `cash_transaction`(`uid` INT(16) UNSIGNED, `amt` INT(32)) RETURNS int(32)
    NO SQL
BEGIN
  
  /* The game script verifies this won't be negative
  before SQL receives it */
  
  DECLARE money INT;
  
  UPDATE characters
    SET cash = cash + amt
    WHERE idUnique = uid;
    
  SELECT cash INTO money
    FROM characters
    WHERE idUnique = uid;
    
  RETURN money;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `new_hash` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`fxserver`@`localhost` FUNCTION `new_hash`() RETURNS varchar(12) CHARSET latin1
BEGIN

	DECLARE hash_generated VARCHAR(12) DEFAULT 'NA';
    DECLARE cnt INT(32) UNSIGNED DEFAULT 1;
    DECLARE loops INT(16) UNSIGNED DEFAULT 0;
    WHILE cnt > 0 DO
		SELECT concat(
			substring('ABCDEF0123456789', rand(round(rand()*4294967296))*15+1, 1),
			substring('ABCDEF0123456789', rand(round(rand()*4294967296))*15+1, 1),
			substring('ABCDEF0123456789', rand(round(rand()*4294967296))*15+1, 1),
			substring('ABCDEF0123456789', rand(round(rand()*4294967296))*15+1, 1),
			substring('ABCDEF0123456789', rand(round(rand()*4294967296))*15+1, 1),
			substring('ABCDEF0123456789', rand(round(rand()*4294967296))*15+1, 1),
			substring('ABCDEF0123456789', rand(round(rand()*4294967296))*15+1, 1),
			substring('ABCDEF0123456789', rand(round(rand()*4294967296))*15+1, 1),
			substring('ABCDEF0123456789', rand(round(rand()*4294967296))*15+1, 1),
			substring('ABCDEF0123456789', rand(round(rand()*4294967296))*15+1, 1),
			substring('ABCDEF0123456789', rand(round(rand()*4294967296))*15+1, 1),
			substring('ABCDEF0123456789', rand()*15+1, 1)
		) INTO hash_generated;
		
		SELECT COUNT(*) INTO cnt FROM pickup_waiting
			WHERE server_hash = hash_generated;
		
        # Only loop so many times. Should never be a factor but better safe than sorry
        SET loops = loops + 1;
        IF loops > 100 THEN SET cnt = 0; END IF;
        
    END WHILE;
	RETURN hash_generated;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `new_player` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`fxserver`@`localhost` FUNCTION `new_player`(
  `steam` VARCHAR(99),
  `sclub` VARCHAR(99),
  `fivem` VARCHAR(99),
  `discd` VARCHAR(99),
  `ip` VARCHAR(15),
  `username` VARCHAR(56)
) RETURNS int(16) unsigned
    NO SQL
BEGIN

	DECLARE uid INT(32) UNSIGNED DEFAULT 0;
    DECLARE tst TIMESTAMP;
    SET tst = CURRENT_TIMESTAMP;
    
    # Try to locate the account in prescedence of ID
    IF steam IS NOT NULL THEN
		SELECT idUnique INTO uid FROM players WHERE idSteam = steam;
	ELSEIF sclub IS NOT NULL THEN
		SELECT idUnique INTO uid FROM players WHERE idSocialClub = sclub;
	ELSEIF fivem IS NOT NULL THEN
		SELECT idUnique INTO uid FROM players WHERE idFiveM = fivem;
	ELSEIF discd IS NOT NULL THEN
		SELECT idUnique INTO uid FROM players WHERE idDiscord = discd;
    ELSE 
		SET uid = 0;
    END IF;
    
    # If UID is 0 they have no account or their account was not found
    IF uid = 0 THEN 
    
      # Insert new Entry
      INSERT INTO players (idSteam, idSocialClub, idFiveM, idDiscord, ip, username, created, lastjoin)
        VALUES            (steam,   sclub,        fivem,   discd,     ip, username, tst,     tst);
      
      # Get the new Entry's UID
      SELECT idUnique INTO uid FROM players
        WHERE created = tst LIMIT 1;
  
    END IF;
    
    RETURN uid;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `handle_pickup` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`fxserver`@`localhost` PROCEDURE `handle_pickup`(`pHash` VARCHAR(12))
BEGIN
	
    DECLARE p_item VARCHAR(48);
    DECLARE p_x,p_y,p_z DECIMAL(8,2) DEFAULT 100.01;
    DECLARE p_id,s_id,w_id INT(32) UNSIGNED DEFAULT 0;
    DECLARE qty,p_type INT(32) UNSIGNED DEFAULT 1;
    
	SELECT w.id,s.x,s.y,s.z,t.item,t.ptype,FLOOR(RAND()*(t.give_max - t.give_min + 1) + t.give_min)
		INTO w_id,p_x,p_y,p_z,p_item,p_type,qty 
		FROM pickup_waiting w 
		LEFT JOIN pickup_types t ON t.id = w.type_id
        LEFT JOIN pickup_spots s ON s.id = w.spot_id
		WHERE w.server_hash = pHash;
    
    IF (w_id > 0) THEN
		DELETE FROM pickup_waiting WHERE id = w_id;
		SELECT p_type,p_item,qty,pHash;
    END IF;
    
    
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `new_pickup` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
CREATE DEFINER=`fxserver`@`localhost` PROCEDURE `new_pickup`()
BEGIN

	DECLARE pos_x, pos_y, pos_z DECIMAL(8,2) DEFAULT 100.01;
    DECLARE s_type INT(2) DEFAULT 1;
    DECLARE g_min, g_max INT(16) DEFAULT 1;
    DECLARE p_item,p_model VARCHAR(48) DEFAULT 'ITEM_INVALID';
    DECLARE p_id,s_id,p_icon INT(32) UNSIGNED DEFAULT 0;
    DECLARE spots_open INT(32) UNSIGNED DEFAULT 0;
    DECLARE pHash VARCHAR(12) DEFAULT 'NA';
    
    SELECT COUNT(*) INTO spots_open FROM pickup_spots WHERE id NOT IN (SELECT spot_id FROM pickup_waiting);
    
    IF (spots_open) > 0 THEN
    
		SELECT new_hash() INTO pHash;
    
		# Select any 1 open spot at random. We know at this point spots_open > 0
		SELECT x,y,z,ptype,id INTO pos_x,pos_y,pos_z,s_type,s_id
			FROM pickup_spots 
			WHERE id NOT IN (SELECT spot_id FROM pickup_waiting)
			ORDER BY RAND()
			LIMIT 1;
        
		# Choose any random pickup of the corresponding type
		SELECT item,model,give_min,give_max,id,icon INTO p_item,p_model,g_min,g_max,p_id,p_icon
			FROM pickup_types
            WHERE ptype = s_type
            ORDER BY RAND()
            LIMIT 1;
            
		
        # Correlate the two, and insert into `pickup_waiting`
		INSERT INTO pickup_waiting (spot_id, type_id, server_hash)
			VALUES (s_id, p_id, pHash);
	END IF;
    SELECT pos_x,pos_y,pos_z,p_item,p_model,pHash,p_icon; # Failure check (Passed)
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `offline_inmate` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`fxserver`@`localhost` PROCEDURE `offline_inmate`(IN `uid` INT(16) UNSIGNED, IN `serve` INT(32), IN `isBigJail` TINYINT(1))
    NO SQL
BEGIN
	
  DECLARE temp INT;
  
  # This procedure checks if the inmate who logged off already
  # exists in MySQL. If they don't it will create the record.
  # If it does, it will update the new time.
  
  SELECT COUNT(*) AS temp
    FROM inmates WHERE idUnique = uid;
    
  IF temp < 1 THEN 
  	INSERT INTO inmates (idUnique, sentence, isPrison)
      VALUES (uid, serve, isBigJail);
      
  ELSE
  	UPDATE inmates
    SET sentence = serve, isPrison = isBigJail
    WHERE idUnique = uid;
    
  END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2019-12-20 14:50:22
