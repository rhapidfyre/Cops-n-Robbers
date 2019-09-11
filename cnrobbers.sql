-- phpMyAdmin SQL Dump
-- version 4.4.15.10
-- https://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Sep 11, 2019 at 09:41 PM
-- Server version: 5.5.60-MariaDB
-- PHP Version: 5.4.16

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `cnrobbers`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`localhost`@`%` PROCEDURE `offline_inmate`(IN `uid` INT(16) UNSIGNED, IN `serve` INT(32), IN `isBigJail` TINYINT(1))
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

END$$

--
-- Functions
--
CREATE DEFINER=`localhost`@`%` FUNCTION `bank_transaction`(`uid` INT(16) UNSIGNED, `amt` INT(32)) RETURNS int(32)
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
END$$

CREATE DEFINER=`localhost`@`%` FUNCTION `cash_transaction`(`uid` INT(16) UNSIGNED, `amt` INT(32)) RETURNS int(32)
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
END$$

CREATE DEFINER=`localhost`@`%` FUNCTION `new_player`(`steam` VARCHAR(50), `fivem` VARCHAR(50), `ip` VARCHAR(15), `username` VARCHAR(56)) RETURNS int(16) unsigned
    NO SQL
BEGIN

	DECLARE uid INT UNSIGNED DEFAULT 0;
    DECLARE tst TIMESTAMP;
    
    SET tst = CURRENT_TIMESTAMP;
    
    # If Steam ID or FiveM License is Valid, Continue
    IF steam IS NOT NULL OR fivem IS NOT NULL THEN 
      SET uid = 1;
    END IF;
    
    # If UID is not 0 (no Steam/5M License), continue
    IF uid != 9999 THEN 
    
      # Insert new Entry
      INSERT INTO players (
          idSteam, idFiveM, ip, username, created, lastjoin
      )
      VALUES (
          steam, fivem, ip, username, tst, tst
      );
      
      # Get the new Entry's UID
      SELECT idUnique INTO uid FROM players
        WHERE created = tst LIMIT 1;
  
    END IF;
    
    RETURN uid;

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `characters`
--

CREATE TABLE IF NOT EXISTS `characters` (
  `dbid` int(16) NOT NULL,
  `idUnique` int(16) unsigned NOT NULL,
  `model` varchar(36) NOT NULL DEFAULT 'mp_m_freemode_01',
  `cash` int(32) NOT NULL DEFAULT '1000',
  `bank` int(32) NOT NULL DEFAULT '5000',
  `blenddata` text NOT NULL COMMENT 'The ped blend data',
  `hairstyle` text NOT NULL COMMENT 'hair style, color, highlight',
  `bodystyle` text NOT NULL COMMENT 'Permanent body features of the player',
  `overlay` text NOT NULL COMMENT 'changeable body style of the player',
  `clothes` text NOT NULL COMMENT 'active outfit',
  `preset1` text NOT NULL,
  `preset2` text NOT NULL,
  `preset3` text NOT NULL,
  `position` varchar(48) NOT NULL DEFAULT '{"x":0.1,"y":0.1,"z":0.1}'
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `clans`
--

CREATE TABLE IF NOT EXISTS `clans` (
  `idClan` int(16) unsigned NOT NULL,
  `idLeader` int(11) NOT NULL,
  `tag` varchar(8) NOT NULL DEFAULT 'TAG',
  `title` varchar(26) NOT NULL DEFAULT 'My Clan Name',
  `cop` int(16) unsigned NOT NULL DEFAULT '1',
  `civ` int(16) unsigned NOT NULL DEFAULT '1'
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `inmates`
--

CREATE TABLE IF NOT EXISTS `inmates` (
  `idPrisoner` int(16) unsigned NOT NULL,
  `idUnique` int(16) unsigned NOT NULL,
  `sentence` int(32) NOT NULL,
  `isPrison` tinyint(1) NOT NULL DEFAULT '0' COMMENT '1=Prison'
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `players`
--

CREATE TABLE IF NOT EXISTS `players` (
  `idUnique` int(16) unsigned NOT NULL,
  `idSteam` varchar(82) DEFAULT NULL,
  `idFiveM` varchar(32) DEFAULT NULL,
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
  `lastjoin` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `robberies`
--

CREATE TABLE IF NOT EXISTS `robberies` (
  `idRobbery` int(16) unsigned NOT NULL,
  `idUnique` int(16) unsigned NOT NULL,
  `cash` int(11) NOT NULL,
  `committed` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=latin1;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `characters`
--
ALTER TABLE `characters`
  ADD UNIQUE KEY `dbid` (`dbid`),
  ADD KEY `idUnique` (`idUnique`);

--
-- Indexes for table `clans`
--
ALTER TABLE `clans`
  ADD UNIQUE KEY `idClan` (`idClan`);

--
-- Indexes for table `inmates`
--
ALTER TABLE `inmates`
  ADD PRIMARY KEY (`idPrisoner`);

--
-- Indexes for table `players`
--
ALTER TABLE `players`
  ADD PRIMARY KEY (`idUnique`);

--
-- Indexes for table `robberies`
--
ALTER TABLE `robberies`
  ADD PRIMARY KEY (`idRobbery`),
  ADD KEY `idUnique` (`idUnique`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `characters`
--
ALTER TABLE `characters`
  MODIFY `dbid` int(16) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=27;
--
-- AUTO_INCREMENT for table `clans`
--
ALTER TABLE `clans`
  MODIFY `idClan` int(16) unsigned NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT for table `inmates`
--
ALTER TABLE `inmates`
  MODIFY `idPrisoner` int(16) unsigned NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=8;
--
-- AUTO_INCREMENT for table `players`
--
ALTER TABLE `players`
  MODIFY `idUnique` int(16) unsigned NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=8;
--
-- AUTO_INCREMENT for table `robberies`
--
ALTER TABLE `robberies`
  MODIFY `idRobbery` int(16) unsigned NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=31;
--
-- Constraints for dumped tables
--

--
-- Constraints for table `characters`
--
ALTER TABLE `characters`
  ADD CONSTRAINT `characters_ibfk_1` FOREIGN KEY (`idUnique`) REFERENCES `players` (`idUnique`);

--
-- Constraints for table `robberies`
--
ALTER TABLE `robberies`
  ADD CONSTRAINT `robberies_idfk_1` FOREIGN KEY (`idUnique`) REFERENCES `players` (`idUnique`);

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
