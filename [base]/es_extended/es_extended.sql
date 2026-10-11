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

    -- read by illenium-appearance (esx) to migrate legacy esx_skin into playerskins
    `skin`        LONGTEXT     NULL DEFAULT NULL,

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

INSERT IGNORE INTO `jobs` (`name`, `label`, `type`) VALUES
    ('unemployed',  'Unemployed', 'civ'),
    ('police',      'LSPD',       'leo'),
    ('ambulance',   'EMS',        'ems'),
    ('mechanic',    'Mechanic',   'mechanic'),
    ('cardealer',   'Cardealer',  'civ'),
    ('taxi',        'Taxi',       'civ'),
    ('lumberjack',  'Lumberjack', 'civ'),
    ('fisherman',   'Fisherman',  'civ'),
    ('fueler',      'Fueler',     'civ'),
    ('reporter',    'Reporter',   'civ'),
    ('tailor',      'Tailor',     'civ'),
    ('miner',       'Miner',      'civ'),
    ('slaughterer', 'Butcher',    'civ');

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

INSERT IGNORE INTO `job_grades` (`job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES
    ('unemployed',  0, 'unemployed',   'Unemployed',     200, '{}', '{}'),

    ('police',      0, 'recruit',      'Recruit',         20, '{}', '{}'),
    ('police',      1, 'officer',      'Officer',         40, '{}', '{}'),
    ('police',      2, 'sergeant',     'Sergeant',        60, '{}', '{}'),
    ('police',      3, 'lieutenant',   'Lieutenant',      85, '{}', '{}'),
    ('police',      4, 'boss',         'Captain',        100, '{}', '{}'),

    ('ambulance',   0, 'ambulance',    'Jr. EMT',         20, '{}', '{}'),
    ('ambulance',   1, 'doctor',       'EMT',             40, '{}', '{}'),
    ('ambulance',   2, 'chief_doctor', 'Sr. EMT',         60, '{}', '{}'),
    ('ambulance',   3, 'boss',         'EMT Supervisor',  80, '{}', '{}'),

    ('mechanic',    0, 'recrue',       'Recruit',         12, '{}', '{}'),
    ('mechanic',    1, 'novice',       'Novice',          24, '{}', '{}'),
    ('mechanic',    2, 'experimente',  'Experienced',     36, '{}', '{}'),
    ('mechanic',    3, 'chief',        'Leader',          48, '{}', '{}'),
    ('mechanic',    4, 'boss',         'Boss',             0, '{}', '{}'),

    ('cardealer',   0, 'recruit',      'Recruit',         10, '{}', '{}'),
    ('cardealer',   1, 'novice',       'Novice',          25, '{}', '{}'),
    ('cardealer',   2, 'experienced',  'Experienced',     40, '{}', '{}'),
    ('cardealer',   3, 'boss',         'Boss',             0, '{}', '{}'),

    ('taxi',        0, 'recrue',       'Recruit',         12, '{}', '{}'),
    ('taxi',        1, 'novice',       'Cabby',           24, '{}', '{}'),
    ('taxi',        2, 'experimente',  'Experienced',     36, '{}', '{}'),
    ('taxi',        3, 'uber',         'Uber Cabby',      48, '{}', '{}'),
    ('taxi',        4, 'boss',         'Lead Cabby',       0, '{}', '{}'),

    ('lumberjack',  0, 'employee',     'Employee',         0, '{}', '{}'),
    ('fisherman',   0, 'employee',     'Employee',         0, '{}', '{}'),
    ('fueler',      0, 'employee',     'Employee',         0, '{}', '{}'),
    ('reporter',    0, 'employee',     'Employee',         0, '{}', '{}'),
    ('tailor',      0, 'employee',     'Employee',         0, '{}', '{}'),
    ('miner',       0, 'employee',     'Employee',         0, '{}', '{}'),
    ('slaughterer', 0, 'employee',     'Employee',         0, '{}', '{}');

-- ─────────────────────────────────────────────────────────────────────────────
-- licenses / user_licenses
-- Required by the ox_inventory ESX bridge (weapon license + license checks).
-- ox_inventory seeds the 'weapon' license itself on first start.
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS `licenses` (
    `type`  VARCHAR(60) NOT NULL,
    `label` VARCHAR(60) NOT NULL,

    PRIMARY KEY (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO `licenses` (`type`, `label`) VALUES
    ('dmv',         'Driving Permit'),
    ('drive',       'Drivers License'),
    ('drive_bike',  'Motorcycle License'),
    ('drive_truck', 'Commercial Drivers License'),
    ('weapon',      'Weapon License');

CREATE TABLE IF NOT EXISTS `user_licenses` (
    `id`    INT         NOT NULL AUTO_INCREMENT,
    `type`  VARCHAR(60) NOT NULL,
    `owner` VARCHAR(60) NOT NULL,

    PRIMARY KEY (`id`),
    KEY `owner` (`owner`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─────────────────────────────────────────────────────────────────────────────
-- owned_vehicles
-- Required by the ox_inventory ESX bridge for trunk / glovebox storage.
-- ox_inventory auto-adds the `glovebox` and `trunk` columns on first start.
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS `owned_vehicles` (
    `owner`   VARCHAR(60)  DEFAULT NULL,
    `plate`   VARCHAR(12)  NOT NULL,
    `vehicle` LONGTEXT     DEFAULT NULL,
    `type`    VARCHAR(20)  NOT NULL DEFAULT 'car',
    `job`     VARCHAR(20)  DEFAULT NULL,
    `stored`  TINYINT(4)   NOT NULL DEFAULT 0,

    PRIMARY KEY (`plate`),
    KEY `owner` (`owner`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
