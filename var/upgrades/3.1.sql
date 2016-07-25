# Factor out resource columns from body into separate table.

alter table body drop column algae_stored;
alter table body drop column cheese_stored;
alter table body drop column bean_stored;
alter table body drop column lapis_stored;
alter table body drop column potato_stored;
alter table body drop column apple_stored;
alter table body drop column root_stored;
alter table body drop column corn_stored;
alter table body drop column cider_stored;
alter table body drop column wheat_stored;
alter table body drop column bread_stored;
alter table body drop column soup_stored;
alter table body drop column chip_stored;
alter table body drop column pie_stored;
alter table body drop column pancake_stored;
alter table body drop column milk_stored;
alter table body drop column meal_stored;
alter table body drop column syrup_stored;
alter table body drop column fungus_stored;
alter table body drop column burger_stored;
alter table body drop column shake_stored;
alter table body drop column beetle_stored;

alter table body drop column rutile_stored;
alter table body drop column chromite_stored;
alter table body drop column chalcopyrite_stored;
alter table body drop column galena_stored;
alter table body drop column gold_stored;
alter table body drop column uraninite_stored;
alter table body drop column bauxite_stored;
alter table body drop column goethite_stored;
alter table body drop column halite_stored;
alter table body drop column gypsum_stored;
alter table body drop column trona_stored;
alter table body drop column kerogen_stored;
alter table body drop column methane_stored;
alter table body drop column anthracite_stored;
alter table body drop column sulfur_stored;
alter table body drop column zircon_stored;
alter table body drop column monazite_stored;
alter table body drop column fluorite_stored;
alter table body drop column beryl_stored;
alter table body drop column magnetite_stored;

alter table body drop column algae_production_hour;
alter table body drop column cheese_production_hour;
alter table body drop column bean_production_hour;
alter table body drop column lapis_production_hour;
alter table body drop column potato_production_hour;
alter table body drop column apple_production_hour;
alter table body drop column root_production_hour;
alter table body drop column corn_production_hour;
alter table body drop column cider_production_hour;
alter table body drop column wheat_production_hour;
alter table body drop column bread_production_hour;
alter table body drop column soup_production_hour;
alter table body drop column chip_production_hour;
alter table body drop column pie_production_hour;
alter table body drop column pancake_production_hour;
alter table body drop column milk_production_hour;
alter table body drop column meal_production_hour;
alter table body drop column syrup_production_hour;
alter table body drop column fungus_production_hour;
alter table body drop column burger_production_hour;
alter table body drop column shake_production_hour;
alter table body drop column beetle_production_hour;

alter table body drop column rutile_hour;
alter table body drop column chromite_hour;
alter table body drop column chalcopyrite_hour;
alter table body drop column galena_hour;
alter table body drop column gold_hour;
alter table body drop column uraninite_hour;
alter table body drop column bauxite_hour;
alter table body drop column goethite_hour;
alter table body drop column halite_hour;
alter table body drop column gypsum_hour;
alter table body drop column trona_hour;
alter table body drop column kerogen_hour;
alter table body drop column methane_hour;
alter table body drop column anthracite_hour;
alter table body drop column sulfur_hour;
alter table body drop column zircon_hour;
alter table body drop column monazite_hour;
alter table body drop column fluorite_hour;
alter table body drop column beryl_hour;
alter table body drop column magnetite_hour;

alter table body drop column happiness_hour;
alter table body drop column happiness;
alter table body drop column waste_hour;
alter table body drop column waste_stored;
alter table body drop column waste_capacity;
alter table body drop column energy_hour;
alter table body drop column energy_stored;
alter table body drop column energy_capacity;
alter table body drop column water_hour;
alter table body drop column water_stored;
alter table body drop column water_capacity;
alter table body drop column ore_capacity;
alter table body drop column ore_consumption_hour;
alter table body drop column food_capacity;
alter table body drop column food_consumption_hour;

CREATE TABLE body_resource (
    id          integer(11) NOT NULL auto_increment,
    body_id     integer(11) NOT NULL,
    type        varchar(64) NOT NULL,
    production  integer(11) NOT NULL default 0, 
    consumption integer(11) NOT NULL default 0, 
    stored      integer(11) NOT NULL default 0, 
    capacity    integer(11) NOT NULL default 0,
    PRIMARY KEY (id) 
);

INSERT INTO db_version (major_version, minor_version, description) values (3, 1, "factor out resource columns from body");

