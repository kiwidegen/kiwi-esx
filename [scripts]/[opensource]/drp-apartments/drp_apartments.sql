-- ========================================
-- DRP Apartments Database Schema (ESX)
-- ========================================
-- This schema is designed for ESX Legacy Framework
-- Stores apartment ownership and configuration data

-- Drop existing table if it exists
DROP TABLE IF EXISTS `drp_apartments`;

-- Create apartments table
CREATE TABLE `drp_apartments` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL COMMENT 'Unique apartment ID (e.g., apartment112345)',
  `type` VARCHAR(255) NOT NULL COMMENT 'Location type/template (e.g., apartment1, apartment2)',
  `label` VARCHAR(255) NOT NULL COMMENT 'Display name for the apartment',
  `identifier` VARCHAR(60) NOT NULL COMMENT 'ESX player identifier (license:xxx or steam:xxx)',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Apartment creation timestamp',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `identifier` (`identifier`),
  KEY `type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================
-- EXAMPLE DATA
-- ========================================
-- Uncomment to insert test data:
--
-- INSERT INTO drp_apartments (name, type, label, identifier) VALUES
-- ('apartment112345', 'apartment1', 'South Rockford Drive 1', 'license:1234567890abcdef'),
-- ('apartment256789', 'apartment2', 'Morningwood Blvd 2', 'license:abcdef1234567890');
