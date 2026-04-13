CREATE TABLE IF NOT EXISTS `player_firstjoin` (
    `identifier` VARCHAR(60) NOT NULL PRIMARY KEY,
    `firstjoin` BIGINT NOT NULL,
    INDEX `identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
