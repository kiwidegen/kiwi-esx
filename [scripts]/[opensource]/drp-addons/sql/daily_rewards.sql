-- Daily Reward System Database Table
-- This table tracks player daily reward claims

CREATE TABLE IF NOT EXISTS `daily_rewards` (
    `identifier` VARCHAR(60) NOT NULL,
    `last_claim` INT(11) UNSIGNED DEFAULT 0,
    `total_claims` INT(11) UNSIGNED DEFAULT 0,
    PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
