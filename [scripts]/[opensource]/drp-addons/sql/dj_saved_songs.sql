-- DJ System Saved Songs Table
-- Players can save their favorite songs to replay later

CREATE TABLE IF NOT EXISTS `dj_saved_songs` (
    `id` INT(11) NOT NULL AUTO_INCREMENT,
    `identifier` VARCHAR(60) NOT NULL,
    `label` VARCHAR(30) NOT NULL,
    `link` LONGTEXT NOT NULL,
    PRIMARY KEY (`id`),
    KEY `identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
