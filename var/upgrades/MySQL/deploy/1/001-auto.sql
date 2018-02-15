-- 
-- Created by SQL::Translator::Producer::MySQL
-- Created on Sat Feb  4 22:03:00 2017
-- 
;
SET foreign_key_checks=0;
--
-- Table: `alliance_log`
--
CREATE TABLE `alliance_log` (
  `id` integer(11) NOT NULL auto_increment,
  `date_stamp` datetime NOT NULL,
  `alliance_id` integer NOT NULL,
  `alliance_name` varchar(30) NOT NULL,
  `member_count` integer NOT NULL,
  `space_station_count` integer NOT NULL,
  `space_station_count_rank` integer NOT NULL,
  `influence` integer NOT NULL,
  `influence_rank` integer NOT NULL,
  `colony_count` integer NOT NULL,
  `population` bigint NOT NULL,
  `population_rank` integer NOT NULL,
  `average_empire_size` bigint NOT NULL,
  `average_empire_size_rank` integer NOT NULL,
  `average_university_level` float(5, 2) NOT NULL,
  `building_count` integer NOT NULL,
  `average_building_level` float(5, 2) NOT NULL,
  `spy_count` integer(11) NOT NULL,
  `offense_success_rate` float(6, 6) NOT NULL,
  `offense_success_rate_rank` integer(11) NOT NULL,
  `defense_success_rate` float(6, 6) NOT NULL,
  `defense_success_rate_rank` integer(11) NOT NULL,
  `dirtiest` integer(11) NOT NULL DEFAULT 0,
  `dirtiest_rank` integer(11) NOT NULL DEFAULT 0,
  INDEX `idx_average_empire_size_rank` (`average_empire_size_rank`),
  INDEX `idx_offense_success_rate_rank` (`offense_success_rate_rank`),
  INDEX `idx_defense_success_rate_rank` (`defense_success_rate_rank`),
  INDEX `idx_dirtiest_rank` (`dirtiest_rank`),
  INDEX `idx_population_rank` (`population_rank`),
  INDEX `idx_influence_rank` (`influence_rank`),
  PRIMARY KEY (`id`)
);
--
-- Table: `api_key`
--
CREATE TABLE `api_key` (
  `id` integer(11) NOT NULL auto_increment,
  `date_stamp` datetime NOT NULL,
  `public_key` varchar(36) NOT NULL,
  `private_key` varchar(36) NOT NULL,
  `name` varchar(30) NULL,
  `ip_address` varchar(15) NULL,
  `email` varchar(255) NULL,
  INDEX `idx_private_key` (`private_key`),
  INDEX `idx_public_key` (`public_key`),
  PRIMARY KEY (`id`)
);
--
-- Table: `battle_log`
--
CREATE TABLE `battle_log` (
  `id` integer(11) NOT NULL auto_increment,
  `date_stamp` datetime NOT NULL,
  `attacking_empire_id` integer(11) NOT NULL,
  `attacking_empire_name` varchar(30) NOT NULL,
  `attacking_body_id` integer(11) NOT NULL,
  `attacking_body_name` varchar(30) NOT NULL,
  `attacking_unit_name` varchar(60) NOT NULL,
  `attacking_type` varchar(60) NOT NULL,
  `attacking_number` integer(11) NOT NULL,
  `defending_empire_id` integer(11) NULL,
  `defending_empire_name` varchar(30) NULL,
  `defending_body_id` integer(11) NOT NULL,
  `defending_body_name` varchar(30) NOT NULL,
  `defending_unit_name` varchar(60) NOT NULL,
  `defending_type` varchar(60) NOT NULL,
  `defending_number` integer(11) NOT NULL,
  `victory_to` varchar(8) NOT NULL,
  `attacked_body_id` integer(11) NOT NULL,
  `attacked_body_name` varchar(30) NOT NULL,
  `attacked_empire_id` integer(11) NULL,
  `attacked_empire_name` varchar(30) NULL,
  INDEX `idx_datestamp` (`date_stamp`),
  INDEX `idx_attacking_empire_id` (`attacking_empire_id`),
  INDEX `idx_attacking_empire_name` (`attacking_empire_name`),
  INDEX `idx_attacking_body_id` (`attacking_body_id`),
  INDEX `idx_attacking_body_name` (`attacking_body_name`),
  INDEX `idx_defending_empire_id` (`defending_empire_id`),
  INDEX `idx_defending_empire_name` (`defending_empire_name`),
  INDEX `idx_defending_body_id` (`defending_body_id`),
  INDEX `idx_defending_body_name` (`defending_body_name`),
  PRIMARY KEY (`id`)
);
--
-- Table: `captcha`
--
CREATE TABLE `captcha` (
  `id` integer(11) NOT NULL auto_increment,
  `riddle` varchar(12) NOT NULL,
  `solution` varchar(5) NOT NULL,
  `guid` varchar(36) NOT NULL,
  `created` datetime NOT NULL,
  PRIMARY KEY (`id`)
);
--
-- Table: `cargo_log`
--
CREATE TABLE `cargo_log` (
  `id` integer(11) NOT NULL auto_increment,
  `date_stamp` datetime NOT NULL,
  `object_type` varchar(255) NOT NULL,
  `object_id` integer NOT NULL,
  `body_id` integer NOT NULL,
  `message` varchar(255) NOT NULL,
  `data` mediumblob NULL,
  PRIMARY KEY (`id`)
);
--
-- Table: `colony_log`
--
CREATE TABLE `colony_log` (
  `id` integer(11) NOT NULL auto_increment,
  `date_stamp` datetime NOT NULL,
  `empire_id` integer(11) NOT NULL,
  `empire_name` varchar(30) NOT NULL,
  `planet_id` integer(11) NOT NULL,
  `planet_name` varchar(30) NOT NULL,
  `population` integer(11) NOT NULL,
  `population_rank` integer(11) NOT NULL,
  `population_delta` integer(11) NOT NULL,
  `building_count` tinyint NOT NULL,
  `average_building_level` float(5, 2) NOT NULL,
  `highest_building_level` tinyint NOT NULL,
  `food_hour` integer(11) NOT NULL,
  `energy_hour` integer(11) NOT NULL,
  `waste_hour` integer(11) NOT NULL,
  `ore_hour` integer(11) NOT NULL,
  `water_hour` integer(11) NOT NULL,
  `happiness_hour` integer(11) NOT NULL,
  `spy_count` integer(11) NOT NULL,
  `average_spy_success_rate` float(6, 6) NOT NULL DEFAULT 0,
  `offense_success_rate` float(6, 6) NOT NULL DEFAULT 0,
  `offense_success_rate_delta` float(6, 6) NOT NULL DEFAULT 0,
  `defense_success_rate` float(6, 6) NOT NULL DEFAULT 0,
  `defense_success_rate_delta` float(6, 6) NOT NULL DEFAULT 0,
  `dirtiest` integer(11) NOT NULL DEFAULT 0,
  `dirtiest_delta` integer(11) NOT NULL DEFAULT 0,
  `is_space_station` integer(11) NOT NULL DEFAULT 0,
  `influence` integer(11) NOT NULL DEFAULT 0,
  `x` integer(11) NOT NULL DEFAULT 0,
  `y` integer(11) NOT NULL DEFAULT 0,
  `body_id` integer(11) NOT NULL DEFAULT 0,
  `zone` varchar(16) NOT NULL DEFAULT '0',
  INDEX `idx_empire_id` (`empire_id`),
  INDEX `idx_empire_name` (`empire_name`),
  INDEX `idx_population_rank` (`population_rank`),
  INDEX `idx_planet_id` (`planet_id`),
  INDEX `idx_planet_name` (`planet_name`),
  PRIMARY KEY (`id`)
);
--
-- Table: `config`
--
CREATE TABLE `config` (
  `id` integer(11) NOT NULL auto_increment,
  `name` varchar(30) NOT NULL,
  `value` text NOT NULL,
  INDEX `c_idx_key` (`name`),
  PRIMARY KEY (`id`)
);
--
-- Table: `db_version`
--
CREATE TABLE `db_version` (
  `id` integer(11) NOT NULL auto_increment,
  `major_version` integer(11) NOT NULL,
  `minor_version` integer(11) NOT NULL,
  `description` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
);
--
-- Table: `economy_log`
--
CREATE TABLE `economy_log` (
  `id` integer(11) NOT NULL auto_increment,
  `date_stamp` date NOT NULL,
  `total_users` integer NOT NULL DEFAULT 0,
  `purchases_30` integer NOT NULL DEFAULT 0,
  `purchases_100` integer NOT NULL DEFAULT 0,
  `purchases_200` integer NOT NULL DEFAULT 0,
  `purchases_600` integer NOT NULL DEFAULT 0,
  `purchases_1300` integer NOT NULL DEFAULT 0,
  `in_purchase` integer NOT NULL DEFAULT 0,
  `in_trade` integer NOT NULL DEFAULT 0,
  `in_redemption` integer NOT NULL DEFAULT 0,
  `in_vein` integer NOT NULL DEFAULT 0,
  `in_vote` integer NOT NULL DEFAULT 0,
  `in_tutorial` integer NOT NULL DEFAULT 0,
  `in_mission` integer NOT NULL DEFAULT 0,
  `in_other` integer NOT NULL DEFAULT 0,
  `out_boost` integer NOT NULL DEFAULT 0,
  `out_mission` integer NOT NULL DEFAULT 0,
  `out_recycle` integer NOT NULL DEFAULT 0,
  `out_ship` integer NOT NULL DEFAULT 0,
  `out_spy` integer NOT NULL DEFAULT 0,
  `out_glyph` integer NOT NULL DEFAULT 0,
  `out_party` integer NOT NULL DEFAULT 0,
  `out_building` integer NOT NULL DEFAULT 0,
  `out_trade` integer NOT NULL DEFAULT 0,
  `out_delete` integer NOT NULL DEFAULT 0,
  `out_other` integer NOT NULL DEFAULT 0,
  INDEX `idx_date_stamp` (`date_stamp`),
  PRIMARY KEY (`id`)
);
--
-- Table: `empire_admin_notes`
--
CREATE TABLE `empire_admin_notes` (
  `id` integer(11) NOT NULL auto_increment,
  `date_stamp` datetime NOT NULL,
  `empire_id` integer(11) NOT NULL,
  `empire_name` varchar(30) NOT NULL,
  `notes` text NOT NULL,
  `creator` varchar(30) NOT NULL,
  INDEX `idx_empire_id` (`empire_id`),
  INDEX `idx_empire_name` (`empire_name`),
  PRIMARY KEY (`id`)
);
--
-- Table: `empire_log`
--
CREATE TABLE `empire_log` (
  `id` integer(11) NOT NULL auto_increment,
  `date_stamp` datetime NOT NULL,
  `empire_id` integer(11) NOT NULL,
  `empire_name` varchar(30) NOT NULL,
  `colony_count` tinyint NOT NULL,
  `colony_count_delta` tinyint NOT NULL,
  `population` integer(11) NOT NULL,
  `population_delta` integer(11) NOT NULL,
  `empire_size` bigint(11) NOT NULL,
  `empire_size_delta` integer(11) NOT NULL,
  `empire_size_rank` integer(11) NOT NULL,
  `building_count` smallint NOT NULL,
  `university_level` tinyint NOT NULL,
  `university_level_rank` tinyint NOT NULL,
  `average_building_level` float(5, 2) NOT NULL,
  `highest_building_level` tinyint(3) NOT NULL,
  `food_hour` integer(11) NOT NULL,
  `energy_hour` integer(11) NOT NULL,
  `waste_hour` integer(11) NOT NULL,
  `ore_hour` integer(11) NOT NULL,
  `water_hour` integer(11) NOT NULL,
  `happiness_hour` integer(11) NOT NULL,
  `spy_count` integer(11) NOT NULL,
  `offense_success_rate` float(6, 6) NOT NULL,
  `offense_success_rate_rank` integer(11) NOT NULL,
  `offense_success_rate_delta` float(6, 6) NOT NULL DEFAULT 0,
  `defense_success_rate` float(6, 6) NOT NULL,
  `defense_success_rate_rank` integer(11) NOT NULL,
  `defense_success_rate_delta` float(6, 6) NOT NULL DEFAULT 0,
  `dirtiest` integer(11) NOT NULL DEFAULT 0,
  `dirtiest_rank` integer(11) NOT NULL DEFAULT 0,
  `dirtiest_delta` integer(11) NOT NULL DEFAULT 0,
  `alliance_id` integer NULL,
  `alliance_name` varchar(30) NULL,
  `space_station_count` integer(11) NOT NULL DEFAULT 0,
  `influence` integer(11) NOT NULL DEFAULT 0,
  INDEX `idx_empire_id` (`empire_id`),
  INDEX `idx_empire_name` (`empire_name`),
  INDEX `idx_empire_size_rank` (`empire_size_rank`),
  INDEX `idx_university_level_rank` (`university_level_rank`),
  INDEX `idx_offense_success_rate_rank` (`offense_success_rate_rank`),
  INDEX `idx_defense_success_rate_rank` (`defense_success_rate_rank`),
  INDEX `idx_dirtiest_rank` (`dirtiest_rank`),
  PRIMARY KEY (`id`)
);
--
-- Table: `empire_name_change_log`
--
CREATE TABLE `empire_name_change_log` (
  `id` integer(11) NOT NULL auto_increment,
  `date_stamp` datetime NOT NULL,
  `empire_id` integer(11) NOT NULL,
  `empire_name` varchar(30) NOT NULL,
  `old_empire_name` varchar(30) NOT NULL,
  INDEX `idx_empire_id` (`empire_id`),
  INDEX `idx_empire_name` (`empire_name`),
  PRIMARY KEY (`id`)
);
--
-- Table: `empire_rpc_log`
--
CREATE TABLE `empire_rpc_log` (
  `id` integer(11) NOT NULL auto_increment,
  `date_stamp` datetime NOT NULL,
  `empire_id` integer(11) NOT NULL,
  `empire_name` varchar(30) NOT NULL,
  `rpc` integer(11) NOT NULL DEFAULT 0,
  `limits` integer(11) NOT NULL DEFAULT 0,
  INDEX `idx_empire_id` (`empire_id`),
  INDEX `idx_empire_name` (`empire_name`),
  PRIMARY KEY (`id`)
);
--
-- Table: `essentia_code`
--
CREATE TABLE `essentia_code` (
  `id` integer(11) NOT NULL auto_increment,
  `code` varchar(36) NOT NULL,
  `amount` float(11, 1) NOT NULL,
  `date_created` datetime NOT NULL,
  `description` varchar(50) NOT NULL,
  `used` tinyint NOT NULL DEFAULT 0,
  `empire_id` integer(11) NOT NULL,
  INDEX `idx_code` (`code`),
  PRIMARY KEY (`id`)
);
--
-- Table: `essentia_log`
--
CREATE TABLE `essentia_log` (
  `id` integer(11) NOT NULL auto_increment,
  `date_stamp` datetime NOT NULL,
  `empire_id` integer(11) NOT NULL,
  `empire_name` varchar(30) NOT NULL,
  `api_key` varchar(40) NULL,
  `amount` float(11, 1) NOT NULL,
  `description` varchar(90) NOT NULL,
  `transaction_id` varchar(36) NULL,
  `from_id` integer(11) NOT NULL,
  `from_name` varchar(30) NOT NULL,
  INDEX `idx_empire_id` (`empire_id`),
  INDEX `idx_empire_name` (`empire_name`),
  INDEX `idx_api_key` (`api_key`),
  INDEX `idx_transaction_id` (`transaction_id`),
  INDEX `idx_essentiacode` (`empire_id`, `description`, `amount`),
  PRIMARY KEY (`id`)
);
--
-- Table: `login_log`
--
CREATE TABLE `login_log` (
  `id` integer(11) NOT NULL auto_increment,
  `date_stamp` datetime NOT NULL,
  `empire_id` integer(11) NOT NULL,
  `empire_name` varchar(30) NOT NULL,
  `api_key` varchar(36) NULL,
  `session_id` char(36) NOT NULL,
  `ip_address` varchar(15) NULL,
  `log_out_date` datetime NULL,
  `extended` integer(11) NOT NULL DEFAULT 0,
  `is_sitter` integer(1) NOT NULL DEFAULT 0,
  `browser_fingerprint` varchar(32) NULL,
  INDEX `idx_empire_id` (`empire_id`),
  INDEX `idx_empire_name` (`empire_name`),
  INDEX `idx_api_key` (`api_key`),
  INDEX `idx_session_id` (`session_id`),
  INDEX `idx_fingerprint` (`browser_fingerprint`),
  PRIMARY KEY (`id`)
);
--
-- Table: `lottery_log`
--
CREATE TABLE `lottery_log` (
  `id` integer(11) NOT NULL auto_increment,
  `date_stamp` datetime NOT NULL,
  `empire_id` integer(11) NOT NULL,
  `empire_name` varchar(30) NOT NULL,
  `api_key` varchar(40) NULL,
  `url` varchar(255) NOT NULL,
  `ip_address` varchar(15) NULL,
  INDEX `idx_empire_id` (`empire_id`),
  INDEX `idx_empire_name` (`empire_name`),
  INDEX `idx_api_key` (`api_key`),
  INDEX `idx_url` (`url`),
  INDEX `idx_ip_address` (`ip_address`),
  PRIMARY KEY (`id`)
);
--
-- Table: `mission`
--
CREATE TABLE `mission` (
  `id` integer(11) NOT NULL auto_increment,
  `mission_file_name` varchar(100) NOT NULL,
  `zone` varchar(16) NOT NULL,
  `date_posted` datetime NOT NULL,
  `max_university_level` tinyint NOT NULL,
  `scratch` mediumblob NULL,
  INDEX `idx_zone_date_posted` (`zone`, `date_posted`),
  PRIMARY KEY (`id`)
);
--
-- Table: `mission_log`
--
CREATE TABLE `mission_log` (
  `id` integer(11) NOT NULL auto_increment,
  `filename` varchar(255) NOT NULL,
  `offers` integer NOT NULL DEFAULT 0,
  `skips` integer NOT NULL DEFAULT 0,
  `skip_uni_level` bigint NOT NULL DEFAULT 0,
  `completes` integer NOT NULL DEFAULT 0,
  `complete_uni_level` bigint NOT NULL DEFAULT 0,
  `seconds_to_complete` bigint NOT NULL DEFAULT 0,
  `incompletes` integer NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
);
--
-- Table: `news`
--
CREATE TABLE `news` (
  `id` integer(11) NOT NULL auto_increment,
  `headline` varchar(140) NOT NULL,
  `zone` varchar(16) NOT NULL,
  `date_posted` datetime NOT NULL,
  INDEX `idx_zone_date_posted` (`zone`, `date_posted`),
  INDEX `idx_date_posted` (`date_posted`),
  PRIMARY KEY (`id`)
);
--
-- Table: `noexist_with_empire_log`
--
CREATE TABLE `noexist_with_empire_log` (
  `id` integer(11) NOT NULL auto_increment,
  `date_stamp` datetime NOT NULL,
  `empire_id` integer(11) NOT NULL,
  `empire_name` varchar(30) NOT NULL,
  INDEX `idx_empire_id` (`empire_id`),
  INDEX `idx_empire_name` (`empire_name`),
  PRIMARY KEY (`id`)
);
--
-- Table: `promotion`
--
CREATE TABLE `promotion` (
  `id` integer(11) NOT NULL auto_increment,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `type` varchar(30) NOT NULL,
  `min_purchase` integer NULL,
  `max_purchase` integer NULL,
  `payload` mediumblob NULL,
  PRIMARY KEY (`id`)
);
--
-- Table: `rpc_log`
--
CREATE TABLE `rpc_log` (
  `id` integer(11) NOT NULL auto_increment,
  `date_stamp` datetime NOT NULL,
  `empire_id` integer(11) NOT NULL,
  `empire_name` varchar(30) NOT NULL,
  `api_key` varchar(40) NULL,
  `module` varchar(255) NOT NULL,
  INDEX `idx_empire_id` (`empire_id`),
  INDEX `idx_empire_name` (`empire_name`),
  INDEX `idx_api_key` (`api_key`),
  INDEX `idx_module` (`module`),
  PRIMARY KEY (`id`)
);
--
-- Table: `schedule`
--
CREATE TABLE `schedule` (
  `id` integer(11) NOT NULL auto_increment,
  `queue` varchar(30) NOT NULL,
  `job_id` integer(11) NOT NULL,
  `delivery` datetime NOT NULL,
  `priority` integer(11) NOT NULL DEFAULT 2000,
  `route` varchar(64) NOT NULL,
  `db_id` integer(11) NOT NULL,
  `payload` mediumblob NULL,
  PRIMARY KEY (`id`)
);
--
-- Table: `spy_log`
--
CREATE TABLE `spy_log` (
  `id` integer(11) NOT NULL auto_increment,
  `date_stamp` datetime NOT NULL,
  `empire_id` integer(11) NOT NULL,
  `empire_name` varchar(30) NOT NULL,
  `spy_name` varchar(30) NOT NULL,
  `spy_id` integer(11) NOT NULL,
  `planet_name` varchar(30) NOT NULL,
  `planet_id` integer(11) NOT NULL,
  `level` integer(11) NOT NULL,
  `level_rank` integer(11) NOT NULL,
  `level_delta` integer(11) NOT NULL DEFAULT 0,
  `offense_success_rate` float(6, 6) NOT NULL,
  `offense_success_rate_delta` float(6, 6) NOT NULL DEFAULT 0,
  `defense_success_rate` float(6, 6) NOT NULL,
  `defense_success_rate_delta` float(6, 6) NOT NULL DEFAULT 0,
  `success_rate` float(6, 6) NOT NULL,
  `success_rate_rank` integer(11) NOT NULL,
  `success_rate_delta` float(6, 6) NOT NULL DEFAULT 0,
  `age` integer(11) NOT NULL,
  `times_captured` integer(11) NOT NULL DEFAULT 0,
  `times_turned` integer(11) NOT NULL DEFAULT 0,
  `seeds_planted` integer(11) NOT NULL DEFAULT 0,
  `spies_killed` integer(11) NOT NULL DEFAULT 0,
  `spies_captured` integer(11) NOT NULL DEFAULT 0,
  `spies_turned` integer(11) NOT NULL DEFAULT 0,
  `things_destroyed` integer(11) NOT NULL DEFAULT 0,
  `things_stolen` integer(11) NOT NULL DEFAULT 0,
  `dirtiest` integer(11) NOT NULL DEFAULT 0,
  `dirtiest_rank` integer(11) NOT NULL,
  `dirtiest_delta` integer(11) NOT NULL DEFAULT 0,
  INDEX `idx_empire_id` (`empire_id`),
  INDEX `idx_empire_name` (`empire_name`),
  INDEX `idx_level_rank` (`level_rank`),
  INDEX `idx_success_rate_rank` (`success_rate_rank`),
  INDEX `idx_dirtiest_rank` (`dirtiest_rank`),
  INDEX `idx_planet_id` (`planet_id`),
  INDEX `idx_planet_name` (`planet_name`),
  INDEX `idx_spy_id` (`spy_id`),
  INDEX `idx_spy_name` (`spy_name`),
  PRIMARY KEY (`id`)
);
--
-- Table: `user`
--
CREATE TABLE `user` (
  `id` integer(11) NOT NULL auto_increment,
  `username` varchar(30) NOT NULL,
  `password` char(45) NOT NULL,
  `email` varchar(255) NULL,
  `password_recovery_key` varchar(36) NULL,
  `registration_stage` varchar(16) NULL,
  INDEX `idx_password_recovery_key` (`password_recovery_key`),
  PRIMARY KEY (`id`)
);
--
-- Table: `viral_log`
--
CREATE TABLE `viral_log` (
  `id` integer(11) NOT NULL auto_increment,
  `date_stamp` date NOT NULL,
  `total_users` integer NOT NULL DEFAULT 0,
  `creates` integer NOT NULL DEFAULT 0,
  `invites` integer NOT NULL DEFAULT 0,
  `accepts` integer NOT NULL DEFAULT 0,
  `deletes` integer NOT NULL DEFAULT 0,
  `abandons` integer NOT NULL DEFAULT 0,
  `active_duration` integer NOT NULL DEFAULT 0,
  INDEX `idx_date_stamp` (`date_stamp`),
  PRIMARY KEY (`id`)
);
--
-- Table: `weekly_medal_winner`
--
CREATE TABLE `weekly_medal_winner` (
  `id` integer(11) NOT NULL auto_increment,
  `date_stamp` datetime NOT NULL,
  `empire_id` integer(11) NOT NULL,
  `empire_name` varchar(30) NOT NULL,
  `medal_id` integer NOT NULL,
  `medal_name` varchar(50) NOT NULL,
  `times_earned` integer NOT NULL,
  `medal_image` varchar(50) NOT NULL,
  INDEX `idx_empire_id` (`empire_id`),
  INDEX `idx_empire_name` (`empire_name`),
  PRIMARY KEY (`id`)
);
--
-- Table: `alliance`
--
CREATE TABLE `alliance` (
  `id` integer(11) NOT NULL auto_increment,
  `name` varchar(30) NOT NULL,
  `leader_id` integer(11) NULL,
  `forum_uri` varchar(255) NOT NULL,
  `description` text NULL,
  `announcements` text NULL,
  `date_created` datetime NOT NULL,
  `stash` mediumblob NULL,
  `image` varchar(255) NOT NULL DEFAULT 'default',
  INDEX `alliance_idx_leader_id` (`leader_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `alliance_fk_leader_id` FOREIGN KEY (`leader_id`) REFERENCES `empire` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB;
--
-- Table: `message`
--
CREATE TABLE `message` (
  `id` integer(11) NOT NULL auto_increment,
  `in_reply_to` integer(11) NULL,
  `subject` varchar(64) NOT NULL,
  `body` mediumtext NULL,
  `date_sent` datetime NOT NULL,
  `from_id` integer(11) NOT NULL,
  `from_name` varchar(30) NOT NULL,
  `to_id` integer(11) NULL,
  `to_name` varchar(30) NOT NULL,
  `recipients` mediumblob NULL,
  `tag` varchar(15) NULL,
  `has_read` tinyint NOT NULL DEFAULT 0,
  `has_replied` tinyint NOT NULL DEFAULT 0,
  `has_archived` tinyint NOT NULL DEFAULT 0,
  `has_trashed` tinyint NOT NULL DEFAULT 0,
  `attachments` mediumblob NULL,
  `repeat_check` varchar(30) NULL,
  INDEX `message_idx_to_id` (`to_id`),
  INDEX `message_idx_from_id` (`from_id`),
  INDEX `idx_repeat_check_date_sent` (`repeat_check`, `date_sent`),
  INDEX `idx_recent_messages` (`has_archived`, `has_read`, `to_id`, `date_sent`),
  INDEX `idx_inbox_only` (`has_archived`, `to_id`, `date_sent`),
  INDEX `idx_trash_only` (`has_trashed`, `to_id`, `date_sent`),
  PRIMARY KEY (`id`),
  CONSTRAINT `message_fk_to_id` FOREIGN KEY (`to_id`) REFERENCES `empire` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `message_fk_from_id` FOREIGN KEY (`from_id`) REFERENCES `empire` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
--
-- Table: `star`
--
CREATE TABLE `star` (
  `id` integer(11) NOT NULL auto_increment,
  `name` varchar(30) NOT NULL,
  `x` integer(11) NOT NULL DEFAULT 0,
  `y` integer(11) NOT NULL DEFAULT 0,
  `zone` varchar(16) NOT NULL,
  `color` varchar(7) NOT NULL,
  `station_id` integer NULL,
  `influence` integer NULL,
  `needs_recalc` tinyint NOT NULL DEFAULT 0,
  INDEX `star_idx_station_id` (`station_id`),
  INDEX `idx_recalc` (`needs_recalc`),
  PRIMARY KEY (`id`),
  CONSTRAINT `star_fk_station_id` FOREIGN KEY (`station_id`) REFERENCES `body` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;
--
-- Table: `body`
--
CREATE TABLE `body` (
  `id` integer(11) NOT NULL auto_increment,
  `name` varchar(30) NOT NULL,
  `x` integer(11) NOT NULL DEFAULT 0,
  `y` integer(11) NOT NULL DEFAULT 0,
  `zone` varchar(16) NOT NULL,
  `star_id` integer NOT NULL,
  `alliance_id` integer NULL,
  `orbit` integer NOT NULL DEFAULT 0,
  `class` varchar(255) NOT NULL,
  `size` integer NOT NULL DEFAULT 0,
  `usable_as_starter` integer NOT NULL DEFAULT 0,
  `usable_as_starter_enabled` tinyint NOT NULL DEFAULT 0,
  `empire_id` integer NULL,
  `last_tick` datetime NOT NULL,
  `boost_enabled` tinyint NOT NULL DEFAULT 0,
  `needs_recalc` tinyint NOT NULL DEFAULT 0,
  `needs_surface_refresh` tinyint NOT NULL DEFAULT 0,
  `restrict_coverage` tinyint NOT NULL DEFAULT 0,
  `plots_available` tinyint NOT NULL DEFAULT 0,
  `surface_version` tinyint NOT NULL DEFAULT 0,
  `max_berth` tinyint NOT NULL DEFAULT 1,
  `unhappy_date` datetime NOT NULL,
  `unhappy` tinyint NOT NULL DEFAULT 0,
  `propaganda_boost` integer NOT NULL DEFAULT 0,
  `neutral_entry` datetime NOT NULL,
  `notes` text NULL,
  INDEX `body_idx_alliance_id` (`alliance_id`),
  INDEX `body_idx_empire_id` (`empire_id`),
  INDEX `body_idx_star_id` (`star_id`),
  INDEX `idx_x_y` (`x`, `y`),
  INDEX `idx_zone` (`zone`),
  INDEX `idx_name` (`name`),
  INDEX `idx_class` (`class`),
  INDEX `idx_usable_as_starter` (`usable_as_starter`),
  INDEX `idx_usable_as_starter_enabled` (`usable_as_starter_enabled`),
  INDEX `idx_planet_search` (`usable_as_starter_enabled`, `usable_as_starter`),
  PRIMARY KEY (`id`),
  CONSTRAINT `body_fk_alliance_id` FOREIGN KEY (`alliance_id`) REFERENCES `alliance` (`id`) ON DELETE SET NULL,
  CONSTRAINT `body_fk_empire_id` FOREIGN KEY (`empire_id`) REFERENCES `empire` (`id`),
  CONSTRAINT `body_fk_star_id` FOREIGN KEY (`star_id`) REFERENCES `star` (`id`)
) ENGINE=InnoDB;
--
-- Table: `empire`
--
CREATE TABLE `empire` (
  `id` integer(11) NOT NULL auto_increment,
  `name` varchar(30) NOT NULL,
  `stage` varchar(30) NOT NULL DEFAULT 'new',
  `date_created` datetime NOT NULL,
  `self_destruct_date` datetime NOT NULL,
  `self_destruct_active` tinyint NOT NULL DEFAULT 0,
  `description` text NULL,
  `notes` text NULL,
  `home_planet_id` integer NULL,
  `status_message` varchar(255) NOT NULL,
  `password` char(43) NOT NULL,
  `sitter_password` varchar(30) NOT NULL,
  `email` varchar(255) NULL,
  `city` varchar(100) NULL,
  `country` varchar(100) NULL,
  `skype` varchar(100) NULL,
  `player_name` varchar(100) NULL,
  `password_recovery_key` varchar(36) NULL,
  `last_login` datetime NOT NULL,
  `essentia_free` float(11, 1) NOT NULL DEFAULT 0,
  `essentia_game` float(11, 1) NOT NULL DEFAULT 0,
  `essentia_paid` float(11, 1) NOT NULL DEFAULT 0,
  `university_level` tinyint NOT NULL DEFAULT 0,
  `tutorial_stage` varchar(30) NOT NULL DEFAULT 'explore_the_ui',
  `tutorial_scratch` text NULL,
  `is_isolationist` tinyint NOT NULL DEFAULT 1,
  `storage_boost` datetime NOT NULL,
  `food_boost` datetime NOT NULL,
  `water_boost` datetime NOT NULL,
  `ore_boost` datetime NOT NULL,
  `energy_boost` datetime NOT NULL,
  `happiness_boost` datetime NOT NULL,
  `building_boost` datetime NOT NULL,
  `spy_training_boost` datetime NOT NULL,
  `facebook_uid` bigint NULL,
  `facebook_token` varchar(100) NULL,
  `alliance_id` integer NULL,
  `species_name` varchar(30) NOT NULL DEFAULT 'Human',
  `species_description` text NULL,
  `min_orbit` tinyint NOT NULL DEFAULT 3,
  `max_orbit` tinyint NOT NULL DEFAULT 3,
  `manufacturing_affinity` tinyint NOT NULL DEFAULT 4,
  `deception_affinity` tinyint NOT NULL DEFAULT 4,
  `research_affinity` tinyint NOT NULL DEFAULT 4,
  `management_affinity` tinyint NOT NULL DEFAULT 4,
  `farming_affinity` tinyint NOT NULL DEFAULT 4,
  `mining_affinity` tinyint NOT NULL DEFAULT 4,
  `science_affinity` tinyint NOT NULL DEFAULT 4,
  `environmental_affinity` tinyint NOT NULL DEFAULT 4,
  `political_affinity` tinyint NOT NULL DEFAULT 4,
  `trade_affinity` tinyint NOT NULL DEFAULT 4,
  `growth_affinity` tinyint NOT NULL DEFAULT 4,
  `skip_medal_messages` tinyint NOT NULL DEFAULT 0,
  `skip_pollution_warnings` tinyint NOT NULL DEFAULT 0,
  `skip_resource_warnings` tinyint NOT NULL DEFAULT 0,
  `skip_happiness_warnings` tinyint NOT NULL DEFAULT 0,
  `skip_facebook_wall_posts` tinyint NOT NULL DEFAULT 0,
  `is_admin` tinyint NOT NULL DEFAULT 0,
  `is_mission_curator` tinyint NOT NULL DEFAULT 0,
  `skip_found_nothing` tinyint NOT NULL DEFAULT 0,
  `skip_excavator_resources` tinyint NOT NULL DEFAULT 0,
  `skip_excavator_glyph` tinyint NOT NULL DEFAULT 0,
  `skip_excavator_plan` tinyint NOT NULL DEFAULT 0,
  `skip_spy_recovery` tinyint NOT NULL DEFAULT 0,
  `skip_probe_detected` tinyint NOT NULL DEFAULT 0,
  `skip_attack_messages` tinyint NOT NULL DEFAULT 0,
  `skip_excavator_artifact` tinyint NOT NULL DEFAULT 0,
  `skip_excavator_destroyed` tinyint NOT NULL DEFAULT 0,
  `skip_excavator_replace_msg` tinyint NOT NULL DEFAULT 0,
  `dont_replace_excavator` tinyint NOT NULL DEFAULT 0,
  `latest_message_id` integer NULL,
  `skip_incoming_ships` tinyint NOT NULL DEFAULT 0,
  `chat_admin` integer NOT NULL DEFAULT 0,
  `in_stasis` tinyint NOT NULL DEFAULT 0,
  `timeout` tinyint NOT NULL DEFAULT 0,
  `outlaw` tinyint NOT NULL DEFAULT 0,
  `outlaw_date` datetime NOT NULL DEFAULT '2010-10-03 18:17:26',
  INDEX `empire_idx_alliance_id` (`alliance_id`),
  INDEX `empire_idx_home_planet_id` (`home_planet_id`),
  INDEX `empire_idx_latest_message_id` (`latest_message_id`),
  INDEX `idx_self_destruct` (`self_destruct_active`, `self_destruct_date`),
  INDEX `idx_password_recovery_key` (`password_recovery_key`),
  INDEX `idx_inactives` (`last_login`, `self_destruct_active`),
  INDEX `idx_admins` (`name`, `is_admin`),
  PRIMARY KEY (`id`),
  UNIQUE `name` (`name`),
  CONSTRAINT `empire_fk_alliance_id` FOREIGN KEY (`alliance_id`) REFERENCES `alliance` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `empire_fk_home_planet_id` FOREIGN KEY (`home_planet_id`) REFERENCES `body` (`id`),
  CONSTRAINT `empire_fk_latest_message_id` FOREIGN KEY (`latest_message_id`) REFERENCES `message` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB;
--
-- Table: `ai_battle_summary`
--
CREATE TABLE `ai_battle_summary` (
  `id` integer(11) NOT NULL,
  `attacking_empire_id` integer(11) NOT NULL,
  `defending_empire_id` integer(11) NOT NULL,
  `attack_victories` integer(11) NOT NULL,
  `defense_victories` integer(11) NOT NULL,
  `attack_spy_hours` integer(11) NOT NULL,
  INDEX `ai_battle_summary_idx_defending_empire_id` (`defending_empire_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `ai_battle_summary_fk_defending_empire_id` FOREIGN KEY (`defending_empire_id`) REFERENCES `empire` (`id`)
) ENGINE=InnoDB;
--
-- Table: `alliance_invite`
--
CREATE TABLE `alliance_invite` (
  `id` integer(11) NOT NULL auto_increment,
  `alliance_id` integer NOT NULL,
  `empire_id` integer NOT NULL,
  `date_created` datetime NOT NULL,
  INDEX `alliance_invite_idx_alliance_id` (`alliance_id`),
  INDEX `alliance_invite_idx_empire_id` (`empire_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `alliance_invite_fk_alliance_id` FOREIGN KEY (`alliance_id`) REFERENCES `alliance` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `alliance_invite_fk_empire_id` FOREIGN KEY (`empire_id`) REFERENCES `empire` (`id`)
) ENGINE=InnoDB;
--
-- Table: `body_resource`
--
CREATE TABLE `body_resource` (
  `id` integer(11) NOT NULL auto_increment,
  `body_id` integer NOT NULL,
  `type` varchar(63) NOT NULL,
  `production` integer NOT NULL,
  `consumption` integer NOT NULL,
  `stored` integer NOT NULL,
  `capacity` integer NOT NULL,
  INDEX `body_resource_idx_body_id` (`body_id`),
  INDEX `idx_resource_body` (`body_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `body_resource_fk_body_id` FOREIGN KEY (`body_id`) REFERENCES `body` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
--
-- Table: `building`
--
CREATE TABLE `building` (
  `id` integer(11) NOT NULL auto_increment,
  `date_created` datetime NOT NULL,
  `body_id` integer(11) NOT NULL,
  `x` integer(11) NOT NULL DEFAULT 0,
  `y` integer(11) NOT NULL DEFAULT 0,
  `level` integer(11) NOT NULL DEFAULT 0,
  `class` varchar(255) NOT NULL,
  `upgrade_started` datetime NOT NULL,
  `upgrade_ends` datetime NOT NULL,
  `is_upgrading` tinyint NOT NULL DEFAULT '0',
  `work_started` datetime NOT NULL,
  `work_ends` datetime NOT NULL,
  `is_working` tinyint NOT NULL DEFAULT '0',
  `work` mediumblob NULL,
  `efficiency` integer NOT NULL DEFAULT 100,
  `last_check` datetime NOT NULL,
  INDEX `building_idx_body_id` (`body_id`),
  INDEX `idx_x_y` (`x`, `y`),
  INDEX `idx_class` (`class`),
  INDEX `idx_is_upgrading` (`is_upgrading`),
  INDEX `idx_is_working` (`is_working`),
  PRIMARY KEY (`id`),
  CONSTRAINT `building_fk_body_id` FOREIGN KEY (`body_id`) REFERENCES `body` (`id`)
) ENGINE=InnoDB;
--
-- Table: `fleet`
--
CREATE TABLE `fleet` (
  `id` integer(11) NOT NULL auto_increment,
  `body_id` integer NOT NULL,
  `mark` varchar(10) NOT NULL,
  `shipyard_id` integer NOT NULL,
  `date_started` datetime NOT NULL,
  `date_available` datetime NOT NULL,
  `type` varchar(30) NOT NULL,
  `task` varchar(30) NOT NULL,
  `name` varchar(30) NOT NULL,
  `speed` integer NOT NULL,
  `stealth` integer NOT NULL,
  `combat` integer NOT NULL,
  `hold_size` integer NOT NULL,
  `payload` mediumblob NULL,
  `roundtrip` tinyint NOT NULL DEFAULT '0',
  `direction` varchar(3) NOT NULL,
  `foreign_body_id` integer NULL,
  `foreign_star_id` integer NULL,
  `berth_level` integer NOT NULL,
  `quantity` float(11, 1) NOT NULL,
  `efficiency` integer NOT NULL,
  INDEX `fleet_idx_body_id` (`body_id`),
  INDEX `fleet_idx_foreign_body_id` (`foreign_body_id`),
  INDEX `fleet_idx_foreign_star_id` (`foreign_star_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `fleet_fk_body_id` FOREIGN KEY (`body_id`) REFERENCES `body` (`id`),
  CONSTRAINT `fleet_fk_foreign_body_id` FOREIGN KEY (`foreign_body_id`) REFERENCES `body` (`id`),
  CONSTRAINT `fleet_fk_foreign_star_id` FOREIGN KEY (`foreign_star_id`) REFERENCES `star` (`id`)
) ENGINE=InnoDB;
--
-- Table: `glyph`
--
CREATE TABLE `glyph` (
  `id` integer(11) NOT NULL auto_increment,
  `body_id` integer NOT NULL,
  `type` varchar(20) NOT NULL,
  `quantity` integer NOT NULL DEFAULT 0,
  INDEX `glyph_idx_body_id` (`body_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `glyph_fk_body_id` FOREIGN KEY (`body_id`) REFERENCES `body` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
--
-- Table: `invite`
--
CREATE TABLE `invite` (
  `id` integer(11) NOT NULL auto_increment,
  `inviter_id` integer NOT NULL,
  `zone` varchar(16) NOT NULL,
  `invitee_id` integer NULL,
  `email` varchar(255) NULL,
  `code` varchar(36) NOT NULL,
  `invite_date` datetime NOT NULL,
  `accept_date` datetime NOT NULL,
  INDEX `invite_idx_invitee_id` (`invitee_id`),
  INDEX `invite_idx_inviter_id` (`inviter_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `invite_fk_invitee_id` FOREIGN KEY (`invitee_id`) REFERENCES `empire` (`id`),
  CONSTRAINT `invite_fk_inviter_id` FOREIGN KEY (`inviter_id`) REFERENCES `empire` (`id`)
) ENGINE=InnoDB;
--
-- Table: `law`
--
CREATE TABLE `law` (
  `id` integer(11) NOT NULL auto_increment,
  `name` varchar(30) NOT NULL,
  `station_id` integer(11) NOT NULL,
  `description` text NULL,
  `type` varchar(30) NOT NULL,
  `scratch` mediumblob NULL,
  `date_enacted` datetime NOT NULL,
  `star_id` integer NULL,
  INDEX `law_idx_star_id` (`star_id`),
  INDEX `law_idx_station_id` (`station_id`),
  INDEX `idx_date_enacted` (`date_enacted`),
  PRIMARY KEY (`id`),
  CONSTRAINT `law_fk_star_id` FOREIGN KEY (`star_id`) REFERENCES `star` (`id`) ON DELETE SET NULL,
  CONSTRAINT `law_fk_station_id` FOREIGN KEY (`station_id`) REFERENCES `body` (`id`)
) ENGINE=InnoDB;
--
-- Table: `medal`
--
CREATE TABLE `medal` (
  `id` integer(11) NOT NULL auto_increment,
  `type` varchar(30) NOT NULL,
  `empire_id` integer(11) NOT NULL,
  `public` tinyint NOT NULL DEFAULT '1',
  `datestamp` datetime NOT NULL,
  `times_earned` integer(11) NOT NULL DEFAULT 1,
  INDEX `medal_idx_empire_id` (`empire_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `medal_fk_empire_id` FOREIGN KEY (`empire_id`) REFERENCES `empire` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
--
-- Table: `mercenary_market`
--
CREATE TABLE `mercenary_market` (
  `id` integer(11) NOT NULL auto_increment,
  `date_offered` datetime NOT NULL,
  `body_id` integer NOT NULL,
  `ship_id` integer NOT NULL,
  `ask` float(11, 1) NOT NULL,
  `cost` float(11, 1) NOT NULL,
  `payload` mediumblob NULL,
  INDEX `mercenary_market_idx_body_id` (`body_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `mercenary_market_fk_body_id` FOREIGN KEY (`body_id`) REFERENCES `body` (`id`)
) ENGINE=InnoDB;
--
-- Table: `mining_platform`
--
CREATE TABLE `mining_platform` (
  `id` integer(11) NOT NULL auto_increment,
  `planet_id` integer(11) NOT NULL,
  `asteroid_id` integer(11) NOT NULL,
  `rutile_hour` integer(11) NOT NULL DEFAULT 0,
  `chromite_hour` integer(11) NOT NULL DEFAULT 0,
  `chalcopyrite_hour` integer(11) NOT NULL DEFAULT 0,
  `galena_hour` integer(11) NOT NULL DEFAULT 0,
  `gold_hour` integer(11) NOT NULL DEFAULT 0,
  `uraninite_hour` integer(11) NOT NULL DEFAULT 0,
  `bauxite_hour` integer(11) NOT NULL DEFAULT 0,
  `goethite_hour` integer(11) NOT NULL DEFAULT 0,
  `halite_hour` integer(11) NOT NULL DEFAULT 0,
  `gypsum_hour` integer(11) NOT NULL DEFAULT 0,
  `trona_hour` integer(11) NOT NULL DEFAULT 0,
  `kerogen_hour` integer(11) NOT NULL DEFAULT 0,
  `methane_hour` integer(11) NOT NULL DEFAULT 0,
  `anthracite_hour` integer(11) NOT NULL DEFAULT 0,
  `sulfur_hour` integer(11) NOT NULL DEFAULT 0,
  `zircon_hour` integer(11) NOT NULL DEFAULT 0,
  `monazite_hour` integer(11) NOT NULL DEFAULT 0,
  `fluorite_hour` integer(11) NOT NULL DEFAULT 0,
  `beryl_hour` integer(11) NOT NULL DEFAULT 0,
  `magnetite_hour` integer(11) NOT NULL DEFAULT 0,
  `percent_ship_capacity` integer NOT NULL DEFAULT -1,
  INDEX `mining_platform_idx_asteroid_id` (`asteroid_id`),
  INDEX `mining_platform_idx_planet_id` (`planet_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `mining_platform_fk_asteroid_id` FOREIGN KEY (`asteroid_id`) REFERENCES `body` (`id`),
  CONSTRAINT `mining_platform_fk_planet_id` FOREIGN KEY (`planet_id`) REFERENCES `body` (`id`)
) ENGINE=InnoDB;
--
-- Table: `plan`
--
CREATE TABLE `plan` (
  `id` integer(11) NOT NULL auto_increment,
  `body_id` integer(11) NOT NULL,
  `class` varchar(255) NOT NULL,
  `level` tinyint NOT NULL,
  `extra_build_level` tinyint NULL DEFAULT 0,
  `quantity` integer(11) NOT NULL,
  INDEX `plan_idx_body_id` (`body_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `plan_fk_body_id` FOREIGN KEY (`body_id`) REFERENCES `body` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
--
-- Table: `sitter_auth`
--
CREATE TABLE `sitter_auth` (
  `baby_id` integer NOT NULL,
  `sitter_id` integer NOT NULL,
  `expiry` datetime NOT NULL,
  INDEX `sitter_auth_idx_baby_id` (`baby_id`),
  INDEX `sitter_auth_idx_sitter_id` (`sitter_id`),
  PRIMARY KEY (`baby_id`, `sitter_id`),
  CONSTRAINT `sitter_auth_fk_baby_id` FOREIGN KEY (`baby_id`) REFERENCES `empire` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sitter_auth_fk_sitter_id` FOREIGN KEY (`sitter_id`) REFERENCES `empire` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
--
-- Table: `stationinfluence`
--
CREATE TABLE `stationinfluence` (
  `id` integer(11) NOT NULL auto_increment,
  `station_id` integer NOT NULL,
  `star_id` integer NOT NULL,
  `alliance_id` integer NOT NULL,
  `oldinfluence` integer NOT NULL,
  `oldstart` datetime NOT NULL,
  `influence` integer NOT NULL,
  `started_influence` datetime NOT NULL,
  INDEX `stationinfluence_idx_alliance_id` (`alliance_id`),
  INDEX `stationinfluence_idx_star_id` (`star_id`),
  INDEX `stationinfluence_idx_station_id` (`station_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `stationinfluence_fk_alliance_id` FOREIGN KEY (`alliance_id`) REFERENCES `alliance` (`id`),
  CONSTRAINT `stationinfluence_fk_star_id` FOREIGN KEY (`star_id`) REFERENCES `star` (`id`),
  CONSTRAINT `stationinfluence_fk_station_id` FOREIGN KEY (`station_id`) REFERENCES `body` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB;
--
-- Table: `waste_chain`
--
CREATE TABLE `waste_chain` (
  `id` integer(11) NOT NULL auto_increment,
  `planet_id` integer(11) NOT NULL,
  `star_id` integer(11) NOT NULL,
  `waste_hour` integer(11) NOT NULL DEFAULT 0,
  `percent_transferred` integer(11) NOT NULL DEFAULT 0,
  INDEX `waste_chain_idx_planet_id` (`planet_id`),
  INDEX `waste_chain_idx_star_id` (`star_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `waste_chain_fk_planet_id` FOREIGN KEY (`planet_id`) REFERENCES `body` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `waste_chain_fk_star_id` FOREIGN KEY (`star_id`) REFERENCES `star` (`id`)
) ENGINE=InnoDB;
--
-- Table: `ai_scratch_pad`
--
CREATE TABLE `ai_scratch_pad` (
  `id` integer(11) NOT NULL,
  `ai_empire_id` integer(11) NOT NULL,
  `body_id` integer(11) NULL,
  `pad` mediumblob NULL,
  INDEX `ai_scratch_pad_idx_body_id` (`body_id`),
  INDEX `ai_scratch_pad_idx_ai_empire_id` (`ai_empire_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `ai_scratch_pad_fk_body_id` FOREIGN KEY (`body_id`) REFERENCES `body` (`id`),
  CONSTRAINT `ai_scratch_pad_fk_ai_empire_id` FOREIGN KEY (`ai_empire_id`) REFERENCES `empire` (`id`)
) ENGINE=InnoDB;
--
-- Table: `excavator`
--
CREATE TABLE `excavator` (
  `id` integer(11) NOT NULL auto_increment,
  `planet_id` integer(11) NOT NULL,
  `body_id` integer(11) NOT NULL,
  `empire_id` integer(11) NOT NULL,
  `date_landed` datetime NOT NULL,
  INDEX `excavator_idx_body_id` (`body_id`),
  INDEX `excavator_idx_empire_id` (`empire_id`),
  INDEX `excavator_idx_planet_id` (`planet_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `excavator_fk_body_id` FOREIGN KEY (`body_id`) REFERENCES `body` (`id`),
  CONSTRAINT `excavator_fk_empire_id` FOREIGN KEY (`empire_id`) REFERENCES `empire` (`id`),
  CONSTRAINT `excavator_fk_planet_id` FOREIGN KEY (`planet_id`) REFERENCES `body` (`id`)
) ENGINE=InnoDB;
--
-- Table: `market`
--
CREATE TABLE `market` (
  `id` integer(11) NOT NULL auto_increment,
  `date_offered` datetime NOT NULL,
  `body_id` integer NOT NULL,
  `transfer_type` varchar(16) NOT NULL,
  `ship_id` integer NULL,
  `fleet_id` integer NULL,
  `ask` float(11, 1) NOT NULL,
  `payload` mediumblob NULL,
  `offer_cargo_space_needed` integer NOT NULL DEFAULT 0,
  `has_water` tinyint NOT NULL DEFAULT 0,
  `has_energy` tinyint NOT NULL DEFAULT 0,
  `has_food` tinyint NOT NULL DEFAULT 0,
  `has_waste` tinyint NOT NULL DEFAULT 0,
  `has_ore` tinyint NOT NULL DEFAULT 0,
  `has_ship` tinyint NOT NULL DEFAULT 0,
  `has_prisoner` tinyint NOT NULL DEFAULT 0,
  `has_glyph` tinyint NOT NULL DEFAULT 0,
  `has_plan` tinyint NOT NULL DEFAULT 0,
  `x` integer NOT NULL DEFAULT 0,
  `y` integer NOT NULL DEFAULT 0,
  `speed` integer NOT NULL DEFAULT 0,
  `trade_range` integer NOT NULL DEFAULT 0,
  `max_university` integer NULL,
  INDEX `market_idx_body_id` (`body_id`),
  INDEX `market_idx_fleet_id` (`fleet_id`),
  INDEX `market_idx_ship_id` (`ship_id`),
  INDEX `idx_market_zone` (`body_id`, `transfer_type`),
  PRIMARY KEY (`id`),
  CONSTRAINT `market_fk_body_id` FOREIGN KEY (`body_id`) REFERENCES `body` (`id`),
  CONSTRAINT `market_fk_fleet_id` FOREIGN KEY (`fleet_id`) REFERENCES `fleet` (`id`),
  CONSTRAINT `market_fk_ship_id` FOREIGN KEY (`ship_id`) REFERENCES `fleet` (`id`)
) ENGINE=InnoDB;
--
-- Table: `probe`
--
CREATE TABLE `probe` (
  `id` integer(11) NOT NULL auto_increment,
  `empire_id` integer NOT NULL,
  `star_id` integer NOT NULL,
  `body_id` integer NOT NULL,
  `alliance_id` integer NULL,
  `virtual` integer NULL DEFAULT 0,
  INDEX `probe_idx_alliance_id` (`alliance_id`),
  INDEX `probe_idx_body_id` (`body_id`),
  INDEX `probe_idx_empire_id` (`empire_id`),
  INDEX `probe_idx_star_id` (`star_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `probe_fk_alliance_id` FOREIGN KEY (`alliance_id`) REFERENCES `alliance` (`id`),
  CONSTRAINT `probe_fk_body_id` FOREIGN KEY (`body_id`) REFERENCES `body` (`id`),
  CONSTRAINT `probe_fk_empire_id` FOREIGN KEY (`empire_id`) REFERENCES `empire` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `probe_fk_star_id` FOREIGN KEY (`star_id`) REFERENCES `star` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
--
-- Table: `proposition`
--
CREATE TABLE `proposition` (
  `id` integer(11) NOT NULL auto_increment,
  `name` varchar(30) NOT NULL,
  `station_id` integer(11) NOT NULL,
  `description` text NULL,
  `type` varchar(30) NOT NULL,
  `scratch` mediumblob NULL,
  `date_ends` datetime NOT NULL,
  `proposed_by_id` integer(11) NOT NULL,
  `status` varchar(10) NOT NULL DEFAULT 'Pending',
  INDEX `proposition_idx_proposed_by_id` (`proposed_by_id`),
  INDEX `proposition_idx_station_id` (`station_id`),
  INDEX `idx_status_date_ends` (`status`, `date_ends`),
  PRIMARY KEY (`id`),
  CONSTRAINT `proposition_fk_proposed_by_id` FOREIGN KEY (`proposed_by_id`) REFERENCES `empire` (`id`),
  CONSTRAINT `proposition_fk_station_id` FOREIGN KEY (`station_id`) REFERENCES `body` (`id`)
) ENGINE=InnoDB;
--
-- Table: `spies`
--
CREATE TABLE `spies` (
  `id` integer(11) NOT NULL auto_increment,
  `empire_id` integer NOT NULL,
  `name` varchar(30) NOT NULL DEFAULT 'Agent Null',
  `from_body_id` integer NOT NULL,
  `on_body_id` integer NOT NULL,
  `task` varchar(30) NOT NULL DEFAULT 'Idle',
  `started_assignment` datetime NOT NULL,
  `available_on` datetime NOT NULL,
  `offense` integer NOT NULL DEFAULT 1,
  `defense` integer NOT NULL DEFAULT 1,
  `date_created` datetime NOT NULL,
  `offense_mission_count` integer NOT NULL DEFAULT 0,
  `defense_mission_count` integer NOT NULL DEFAULT 0,
  `offense_mission_successes` integer NOT NULL DEFAULT 0,
  `defense_mission_successes` integer NOT NULL DEFAULT 0,
  `times_captured` integer NOT NULL DEFAULT 0,
  `times_turned` integer NOT NULL DEFAULT 0,
  `seeds_planted` integer NOT NULL DEFAULT 0,
  `spies_killed` integer NOT NULL DEFAULT 0,
  `spies_captured` integer NOT NULL DEFAULT 0,
  `spies_turned` integer NOT NULL DEFAULT 0,
  `things_destroyed` integer NOT NULL DEFAULT 0,
  `things_stolen` integer NOT NULL DEFAULT 0,
  `intel_xp` integer NOT NULL DEFAULT 0,
  `mayhem_xp` integer NOT NULL DEFAULT 0,
  `politics_xp` integer NOT NULL DEFAULT 0,
  `theft_xp` integer NOT NULL DEFAULT 0,
  `level` tinyint NOT NULL DEFAULT 0,
  `next_task` varchar(30) NOT NULL DEFAULT 'Idle',
  INDEX `spies_idx_empire_id` (`empire_id`),
  INDEX `spies_idx_from_body_id` (`from_body_id`),
  INDEX `spies_idx_on_body_id` (`on_body_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `spies_fk_empire_id` FOREIGN KEY (`empire_id`) REFERENCES `empire` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `spies_fk_from_body_id` FOREIGN KEY (`from_body_id`) REFERENCES `body` (`id`),
  CONSTRAINT `spies_fk_on_body_id` FOREIGN KEY (`on_body_id`) REFERENCES `body` (`id`)
) ENGINE=InnoDB;
--
-- Table: `supply_chain`
--
CREATE TABLE `supply_chain` (
  `id` integer(11) NOT NULL auto_increment,
  `planet_id` integer(11) NOT NULL,
  `building_id` integer(11) NOT NULL,
  `target_id` integer(11) NOT NULL,
  `resource_hour` integer(11) NOT NULL DEFAULT 0,
  `resource_type` varchar(255) NOT NULL DEFAULT '',
  `percent_transferred` integer(11) NOT NULL DEFAULT 0,
  `stalled` integer(11) NOT NULL DEFAULT 0,
  INDEX `supply_chain_idx_building_id` (`building_id`),
  INDEX `supply_chain_idx_planet_id` (`planet_id`),
  INDEX `supply_chain_idx_target_id` (`target_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `supply_chain_fk_building_id` FOREIGN KEY (`building_id`) REFERENCES `building` (`id`),
  CONSTRAINT `supply_chain_fk_planet_id` FOREIGN KEY (`planet_id`) REFERENCES `body` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `supply_chain_fk_target_id` FOREIGN KEY (`target_id`) REFERENCES `body` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
--
-- Table: `tax`
--
CREATE TABLE `tax` (
  `id` integer(11) NOT NULL auto_increment,
  `empire_id` integer(11) NOT NULL,
  `station_id` integer(11) NOT NULL,
  `paid_6` integer(11) NOT NULL,
  `paid_5` integer(11) NOT NULL,
  `paid_4` integer(11) NOT NULL,
  `paid_3` integer(11) NOT NULL,
  `paid_2` integer(11) NOT NULL,
  `paid_1` integer(11) NOT NULL,
  `paid_0` integer(11) NOT NULL,
  INDEX `tax_idx_empire_id` (`empire_id`),
  INDEX `tax_idx_station_id` (`station_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `tax_fk_empire_id` FOREIGN KEY (`empire_id`) REFERENCES `empire` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `tax_fk_station_id` FOREIGN KEY (`station_id`) REFERENCES `body` (`id`)
) ENGINE=InnoDB;
--
-- Table: `vote`
--
CREATE TABLE `vote` (
  `id` integer(11) NOT NULL auto_increment,
  `proposition_id` integer NOT NULL,
  `empire_id` integer NOT NULL,
  `vote` integer NOT NULL DEFAULT 0,
  INDEX `vote_idx_empire_id` (`empire_id`),
  INDEX `vote_idx_proposition_id` (`proposition_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `vote_fk_empire_id` FOREIGN KEY (`empire_id`) REFERENCES `empire` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `vote_fk_proposition_id` FOREIGN KEY (`proposition_id`) REFERENCES `proposition` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
SET foreign_key_checks=1;
