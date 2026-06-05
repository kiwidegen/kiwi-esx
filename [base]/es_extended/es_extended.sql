-- es_extended lean core — SQL schema
-- Run this once on a FRESH database.
-- For existing databases, see the ALTER TABLE section at the bottom.

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ─────────────────────────────────────────────────────────────────────────────
-- users
-- Note: inventory / loadout columns are kept so existing data is not lost,
-- but es_extended no longer reads or writes them (ox_inventory owns that).
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS `users` (
    `identifier`  VARCHAR(60)  NOT NULL,
    `ssn`         VARCHAR(11)  NOT NULL,
    `accounts`    LONGTEXT     NULL DEFAULT NULL,
    `group`       VARCHAR(50)  NULL DEFAULT 'user',
    `job`         VARCHAR(50)  NULL DEFAULT 'unemployed',
    `job_grade`   INT          NULL DEFAULT 0,
    `position`    LONGTEXT     NULL DEFAULT NULL,
    `metadata`    LONGTEXT     NULL DEFAULT NULL,

    -- identity (was esx_identity — now part of the core)
    `firstname`   VARCHAR(50)  NULL DEFAULT NULL,
    `lastname`    VARCHAR(50)  NULL DEFAULT NULL,
    `dateofbirth` VARCHAR(15)  NULL DEFAULT NULL,
    `sex`         VARCHAR(1)   NULL DEFAULT NULL,
    `height`      INT          NULL DEFAULT NULL,

    -- kept for data preservation only — no longer written by es_extended
    `inventory`   LONGTEXT     NULL DEFAULT NULL,
    `loadout`     LONGTEXT     NULL DEFAULT NULL,

    PRIMARY KEY (`identifier`),
    UNIQUE KEY `unique_ssn` (`ssn`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─────────────────────────────────────────────────────────────────────────────
-- jobs
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS `jobs` (
    `name`  VARCHAR(50) NOT NULL,
    `label` VARCHAR(50) NULL DEFAULT NULL,
    `type`  VARCHAR(50) NULL DEFAULT 'civ',

    PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO `jobs` VALUES ('unemployed', 'Unemployed', 'civ');

-- ─────────────────────────────────────────────────────────────────────────────
-- job_grades
-- skin_male / skin_female retained for schema compatibility — unused by core
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS `job_grades` (
    `id`         INT          NOT NULL AUTO_INCREMENT,
    `job_name`   VARCHAR(50)  NULL DEFAULT NULL,
    `grade`      INT          NOT NULL,
    `name`       VARCHAR(50)  NOT NULL,
    `label`      VARCHAR(50)  NOT NULL,
    `salary`     INT          NOT NULL DEFAULT 0,
    `skin_male`  LONGTEXT     NULL DEFAULT NULL,
    `skin_female` LONGTEXT    NULL DEFAULT NULL,

    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO `job_grades` (`job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`)
VALUES ('unemployed', 0, 'unemployed', 'Unemployed', 200, '{}', '{}');

SET FOREIGN_KEY_CHECKS = 1;


-- =============================================================================
-- EXISTING DATABASE MIGRATION
-- If you already have an es_extended database, run ONLY the ALTER statements
-- below instead of the CREATE TABLE blocks above.
-- These are safe to run even if the columns already exist (MariaDB 10.0.2+).
-- =============================================================================

-- ALTER TABLE `users`
--     ADD COLUMN IF NOT EXISTS `firstname`   VARCHAR(50) NULL DEFAULT NULL,
--     ADD COLUMN IF NOT EXISTS `lastname`    VARCHAR(50) NULL DEFAULT NULL,
--     ADD COLUMN IF NOT EXISTS `dateofbirth` VARCHAR(15) NULL DEFAULT NULL,
--     ADD COLUMN IF NOT EXISTS `sex`         VARCHAR(1)  NULL DEFAULT NULL,
--     ADD COLUMN IF NOT EXISTS `height`      INT         NULL DEFAULT NULL;

-- ALTER TABLE `jobs`
--     ADD COLUMN IF NOT EXISTS `type` VARCHAR(50) NULL DEFAULT 'civ';
