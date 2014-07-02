#!/usr/bin/perl -w

# generated by gen-fit-enum.pl from FIT SDK Profile.xls

package Workout::Fit::Enum;
use strict;
use warnings;
use Exporter;

our( @ISA, @EXPORT );
BEGIN {
	@ISA = qw( Exporter );
	@EXPORT = ( qw(
		FIT_activity_subtype
		FIT_activity_subtype_id
		FIT_activity_type
		FIT_activity_type_id
		FIT_antplus_device_type
		FIT_antplus_device_type_id
		FIT_autolap_trigger
		FIT_autolap_trigger_id
		FIT_battery_status
		FIT_battery_status_id
		FIT_event
		FIT_event_id
		FIT_event_type
		FIT_event_type_id
		FIT_file
		FIT_file_id
		FIT_fitness_equipment_state
		FIT_fitness_equipment_state_id
		FIT_garmin_product
		FIT_garmin_product_id
		FIT_intensity
		FIT_intensity_id
		FIT_lap_trigger
		FIT_lap_trigger_id
		FIT_manufacturer
		FIT_manufacturer_id
		FIT_mesg_num
		FIT_mesg_num_id
		FIT_session_trigger
		FIT_session_trigger_id
		FIT_sport
		FIT_sport_id
		FIT_sub_sport
		FIT_sub_sport_id
		FIT_timer_trigger
		FIT_timer_trigger_id
	) );
}

our %activity_subtype = (
	"generic" => 0,
	"treadmill" => 1,
	"street" => 2,
	"trail" => 3,
	"track" => 4,
	"spin" => 5,
	"indoor_cycling" => 6,
	"road" => 7,
	"mountain" => 8,
	"downhill" => 9,
	"recumbent" => 10,
	"cyclocross" => 11,
	"hand_cycling" => 12,
	"track_cycling" => 13,
	"indoor_rowing" => 14,
	"elliptical" => 15,
	"stair_climbing" => 16,
	"lap_swimming" => 17,
	"open_water" => 18,
	"all" => 254,
);

our %activity_subtype_id = reverse %activity_subtype;

sub FIT_activity_subtype {
	exists $activity_subtype{$_[0]} or return;
	return $activity_subtype{$_[0]}
}

sub FIT_activity_subtype_id {
	exists $activity_subtype_id{$_[0]} or return;
	return $activity_subtype_id{$_[0]}
}

our %activity_type = (
	"generic" => 0,
	"running" => 1,
	"cycling" => 2,
	"transition" => 3,
	"fitness_equipment" => 4,
	"swimming" => 5,
	"walking" => 6,
	"all" => 254,
);

our %activity_type_id = reverse %activity_type;

sub FIT_activity_type {
	exists $activity_type{$_[0]} or return;
	return $activity_type{$_[0]}
}

sub FIT_activity_type_id {
	exists $activity_type_id{$_[0]} or return;
	return $activity_type_id{$_[0]}
}

our %antplus_device_type = (
	"antfs" => 1,
	"bike_power" => 11,
	"environment_sensor_legacy" => 12,
	"multi_sport_speed_distance" => 15,
	"control" => 16,
	"fitness_equipment" => 17,
	"blood_pressure" => 18,
	"geocache_node" => 19,
	"light_electric_vehicle" => 20,
	"env_sensor" => 25,
	"racquet" => 26,
	"weight_scale" => 119,
	"heart_rate" => 120,
	"bike_speed_cadence" => 121,
	"bike_cadence" => 122,
	"bike_speed" => 123,
	"stride_speed_distance" => 124,
);

our %antplus_device_type_id = reverse %antplus_device_type;

sub FIT_antplus_device_type {
	exists $antplus_device_type{$_[0]} or return;
	return $antplus_device_type{$_[0]}
}

sub FIT_antplus_device_type_id {
	exists $antplus_device_type_id{$_[0]} or return;
	return $antplus_device_type_id{$_[0]}
}

our %autolap_trigger = (
	"time" => 0,
	"distance" => 1,
	"position_start" => 2,
	"position_lap" => 3,
	"position_waypoint" => 4,
	"position_marked" => 5,
	"off" => 6,
);

our %autolap_trigger_id = reverse %autolap_trigger;

sub FIT_autolap_trigger {
	exists $autolap_trigger{$_[0]} or return;
	return $autolap_trigger{$_[0]}
}

sub FIT_autolap_trigger_id {
	exists $autolap_trigger_id{$_[0]} or return;
	return $autolap_trigger_id{$_[0]}
}

our %battery_status = (
	"new" => 1,
	"good" => 2,
	"ok" => 3,
	"low" => 4,
	"critical" => 5,
);

our %battery_status_id = reverse %battery_status;

sub FIT_battery_status {
	exists $battery_status{$_[0]} or return;
	return $battery_status{$_[0]}
}

sub FIT_battery_status_id {
	exists $battery_status_id{$_[0]} or return;
	return $battery_status_id{$_[0]}
}

our %event = (
	"timer" => 0,
	"workout" => 3,
	"workout_step" => 4,
	"power_down" => 5,
	"power_up" => 6,
	"off_course" => 7,
	"session" => 8,
	"lap" => 9,
	"course_point" => 10,
	"battery" => 11,
	"virtual_partner_pace" => 12,
	"hr_high_alert" => 13,
	"hr_low_alert" => 14,
	"speed_high_alert" => 15,
	"speed_low_alert" => 16,
	"cad_high_alert" => 17,
	"cad_low_alert" => 18,
	"power_high_alert" => 19,
	"power_low_alert" => 20,
	"recovery_hr" => 21,
	"battery_low" => 22,
	"time_duration_alert" => 23,
	"distance_duration_alert" => 24,
	"calorie_duration_alert" => 25,
	"activity" => 26,
	"fitness_equipment" => 27,
	"length" => 28,
	"user_marker" => 32,
	"sport_point" => 33,
	"calibration" => 36,
	"front_gear_change" => 42,
	"rear_gear_change" => 43,
);

our %event_id = reverse %event;

sub FIT_event {
	exists $event{$_[0]} or return;
	return $event{$_[0]}
}

sub FIT_event_id {
	exists $event_id{$_[0]} or return;
	return $event_id{$_[0]}
}

our %event_type = (
	"start" => 0,
	"stop" => 1,
	"consecutive_depreciated" => 2,
	"marker" => 3,
	"stop_all" => 4,
	"begin_depreciated" => 5,
	"end_depreciated" => 6,
	"end_all_depreciated" => 7,
	"stop_disable" => 8,
	"stop_disable_all" => 9,
);

our %event_type_id = reverse %event_type;

sub FIT_event_type {
	exists $event_type{$_[0]} or return;
	return $event_type{$_[0]}
}

sub FIT_event_type_id {
	exists $event_type_id{$_[0]} or return;
	return $event_type_id{$_[0]}
}

our %file = (
	"device" => 1,
	"settings" => 2,
	"sport" => 3,
	"activity" => 4,
	"workout" => 5,
	"course" => 6,
	"schedules" => 7,
	"weight" => 9,
	"totals" => 10,
	"goals" => 11,
	"blood_pressure" => 14,
	"monitoring_a" => 15,
	"activity_summary" => 20,
	"monitoring_daily" => 28,
	"monitoring_b" => 32,
);

our %file_id = reverse %file;

sub FIT_file {
	exists $file{$_[0]} or return;
	return $file{$_[0]}
}

sub FIT_file_id {
	exists $file_id{$_[0]} or return;
	return $file_id{$_[0]}
}

our %fitness_equipment_state = (
	"ready" => 0,
	"in_use" => 1,
	"paused" => 2,
	"unknown" => 3,
);

our %fitness_equipment_state_id = reverse %fitness_equipment_state;

sub FIT_fitness_equipment_state {
	exists $fitness_equipment_state{$_[0]} or return;
	return $fitness_equipment_state{$_[0]}
}

sub FIT_fitness_equipment_state_id {
	exists $fitness_equipment_state_id{$_[0]} or return;
	return $fitness_equipment_state_id{$_[0]}
}

our %garmin_product = (
	"hrm1" => 1,
	"axh01" => 2,
	"axb01" => 3,
	"axb02" => 4,
	"hrm2ss" => 5,
	"dsi_alf02" => 6,
	"hrm3ss" => 7,
	"hrm_run_single_byte_product_id" => 8,
	"bsm" => 9,
	"bcm" => 10,
	"fr301_china" => 473,
	"fr301_japan" => 474,
	"fr301_korea" => 475,
	"fr301_taiwan" => 494,
	"fr405" => 717,
	"fr50" => 782,
	"fr405_japan" => 987,
	"fr60" => 988,
	"dsi_alf01" => 1011,
	"fr310xt" => 1018,
	"edge500" => 1036,
	"fr110" => 1124,
	"edge800" => 1169,
	"edge500_taiwan" => 1199,
	"edge500_japan" => 1213,
	"chirp" => 1253,
	"fr110_japan" => 1274,
	"edge200" => 1325,
	"fr910xt" => 1328,
	"edge800_taiwan" => 1333,
	"edge800_japan" => 1334,
	"alf04" => 1341,
	"fr610" => 1345,
	"fr210_japan" => 1360,
	"vector_ss" => 1380,
	"vector_cp" => 1381,
	"edge800_china" => 1386,
	"edge500_china" => 1387,
	"fr610_japan" => 1410,
	"edge500_korea" => 1422,
	"fr70" => 1436,
	"fr310xt_4t" => 1446,
	"amx" => 1461,
	"fr10" => 1482,
	"edge800_korea" => 1497,
	"swim" => 1499,
	"fr910xt_china" => 1537,
	"fenix" => 1551,
	"edge200_taiwan" => 1555,
	"edge510" => 1561,
	"edge810" => 1567,
	"tempe" => 1570,
	"fr910xt_japan" => 1600,
	"fr620" => 1623,
	"fr220" => 1632,
	"fr910xt_korea" => 1664,
	"fr10_japan" => 1688,
	"edge810_japan" => 1721,
	"virb_elite" => 1735,
	"edge_touring" => 1736,
	"edge510_japan" => 1742,
	"hrm_run" => 1752,
	"edge510_asia" => 1821,
	"edge810_china" => 1822,
	"edge810_taiwan" => 1823,
	"edge1000" => 1836,
	"vivo_fit" => 1837,
	"virb_remote" => 1853,
	"vivo_ki" => 1885,
	"edge510_korea" => 1918,
	"fr620_japan" => 1928,
	"fr620_china" => 1929,
	"fr220_japan" => 1930,
	"fr220_china" => 1931,
	"sdm4" => 10007,
	"edge_remote" => 10014,
	"training_center" => 20119,
	"android_antplus_plugin" => 65532,
	"connect" => 65534,
);

our %garmin_product_id = reverse %garmin_product;

sub FIT_garmin_product {
	exists $garmin_product{$_[0]} or return;
	return $garmin_product{$_[0]}
}

sub FIT_garmin_product_id {
	exists $garmin_product_id{$_[0]} or return;
	return $garmin_product_id{$_[0]}
}

our %intensity = (
	"active" => 0,
	"rest" => 1,
	"warmup" => 2,
	"cooldown" => 3,
);

our %intensity_id = reverse %intensity;

sub FIT_intensity {
	exists $intensity{$_[0]} or return;
	return $intensity{$_[0]}
}

sub FIT_intensity_id {
	exists $intensity_id{$_[0]} or return;
	return $intensity_id{$_[0]}
}

our %lap_trigger = (
	"manual" => 0,
	"time" => 1,
	"distance" => 2,
	"position_start" => 3,
	"position_lap" => 4,
	"position_waypoint" => 5,
	"position_marked" => 6,
	"session_end" => 7,
	"fitness_equipment" => 8,
);

our %lap_trigger_id = reverse %lap_trigger;

sub FIT_lap_trigger {
	exists $lap_trigger{$_[0]} or return;
	return $lap_trigger{$_[0]}
}

sub FIT_lap_trigger_id {
	exists $lap_trigger_id{$_[0]} or return;
	return $lap_trigger_id{$_[0]}
}

our %manufacturer = (
	"garmin" => 1,
	"garmin_fr405_antfs" => 2,
	"zephyr" => 3,
	"dayton" => 4,
	"idt" => 5,
	"srm" => 6,
	"quarq" => 7,
	"ibike" => 8,
	"saris" => 9,
	"spark_hk" => 10,
	"tanita" => 11,
	"echowell" => 12,
	"dynastream_oem" => 13,
	"nautilus" => 14,
	"dynastream" => 15,
	"timex" => 16,
	"metrigear" => 17,
	"xelic" => 18,
	"beurer" => 19,
	"cardiosport" => 20,
	"a_and_d" => 21,
	"hmm" => 22,
	"suunto" => 23,
	"thita_elektronik" => 24,
	"gpulse" => 25,
	"clean_mobile" => 26,
	"pedal_brain" => 27,
	"peaksware" => 28,
	"saxonar" => 29,
	"lemond_fitness" => 30,
	"dexcom" => 31,
	"wahoo_fitness" => 32,
	"octane_fitness" => 33,
	"archinoetics" => 34,
	"the_hurt_box" => 35,
	"citizen_systems" => 36,
	"magellan" => 37,
	"osynce" => 38,
	"holux" => 39,
	"concept2" => 40,
	"one_giant_leap" => 42,
	"ace_sensor" => 43,
	"brim_brothers" => 44,
	"xplova" => 45,
	"perception_digital" => 46,
	"bf1systems" => 47,
	"pioneer" => 48,
	"spantec" => 49,
	"metalogics" => 50,
	"4iiiis" => 51,
	"seiko_epson" => 52,
	"seiko_epson_oem" => 53,
	"ifor_powell" => 54,
	"maxwell_guider" => 55,
	"star_trac" => 56,
	"breakaway" => 57,
	"alatech_technology_ltd" => 58,
	"mio_technology_europe" => 59,
	"rotor" => 60,
	"geonaute" => 61,
	"id_bike" => 62,
	"specialized" => 63,
	"wtek" => 64,
	"physical_enterprises" => 65,
	"north_pole_engineering" => 66,
	"bkool" => 67,
	"cateye" => 68,
	"stages_cycling" => 69,
	"sigmasport" => 70,
	"tomtom" => 71,
	"peripedal" => 72,
	"wattbike" => 73,
	"moxy" => 76,
	"ciclosport" => 77,
	"powerbahn" => 78,
	"acorn_projects_aps" => 79,
	"lifebeam" => 80,
	"bontrager" => 81,
	"wellgo" => 82,
	"scosche" => 83,
	"magura" => 84,
	"woodway" => 85,
	"elite" => 86,
	"development" => 255,
	"actigraphcorp" => 5759,
);

our %manufacturer_id = reverse %manufacturer;

sub FIT_manufacturer {
	exists $manufacturer{$_[0]} or return;
	return $manufacturer{$_[0]}
}

sub FIT_manufacturer_id {
	exists $manufacturer_id{$_[0]} or return;
	return $manufacturer_id{$_[0]}
}

our %mesg_num = (
	"file_id" => 0,
	"capabilities" => 1,
	"device_settings" => 2,
	"user_profile" => 3,
	"hrm_profile" => 4,
	"sdm_profile" => 5,
	"bike_profile" => 6,
	"zones_target" => 7,
	"hr_zone" => 8,
	"power_zone" => 9,
	"met_zone" => 10,
	"sport" => 12,
	"goal" => 15,
	"session" => 18,
	"lap" => 19,
	"record" => 20,
	"event" => 21,
	"device_info" => 23,
	"workout" => 26,
	"workout_step" => 27,
	"schedule" => 28,
	"weight_scale" => 30,
	"course" => 31,
	"course_point" => 32,
	"totals" => 33,
	"activity" => 34,
	"software" => 35,
	"file_capabilities" => 37,
	"mesg_capabilities" => 38,
	"field_capabilities" => 39,
	"file_creator" => 49,
	"blood_pressure" => 51,
	"speed_zone" => 53,
	"monitoring" => 55,
	"hrv" => 78,
	"length" => 101,
	"monitoring_info" => 103,
	"pad" => 105,
	"slave_device" => 106,
	"cadence_zone" => 131,
	"memo_glob" => 145,
);

our %mesg_num_id = reverse %mesg_num;

sub FIT_mesg_num {
	exists $mesg_num{$_[0]} or return;
	return $mesg_num{$_[0]}
}

sub FIT_mesg_num_id {
	exists $mesg_num_id{$_[0]} or return;
	return $mesg_num_id{$_[0]}
}

our %session_trigger = (
	"activity_end" => 0,
	"manual" => 1,
	"auto_multi_sport" => 2,
	"fitness_equipment" => 3,
);

our %session_trigger_id = reverse %session_trigger;

sub FIT_session_trigger {
	exists $session_trigger{$_[0]} or return;
	return $session_trigger{$_[0]}
}

sub FIT_session_trigger_id {
	exists $session_trigger_id{$_[0]} or return;
	return $session_trigger_id{$_[0]}
}

our %sport = (
	"generic" => 0,
	"running" => 1,
	"cycling" => 2,
	"transition" => 3,
	"fitness_equipment" => 4,
	"swimming" => 5,
	"basketball" => 6,
	"soccer" => 7,
	"tennis" => 8,
	"american_football" => 9,
	"training" => 10,
	"walking" => 11,
	"cross_country_skiing" => 12,
	"alpine_skiing" => 13,
	"snowboarding" => 14,
	"rowing" => 15,
	"mountaineering" => 16,
	"hiking" => 17,
	"multisport" => 18,
	"paddling" => 19,
	"all" => 254,
);

our %sport_id = reverse %sport;

sub FIT_sport {
	exists $sport{$_[0]} or return;
	return $sport{$_[0]}
}

sub FIT_sport_id {
	exists $sport_id{$_[0]} or return;
	return $sport_id{$_[0]}
}

our %sub_sport = (
	"generic" => 0,
	"treadmill" => 1,
	"street" => 2,
	"trail" => 3,
	"track" => 4,
	"spin" => 5,
	"indoor_cycling" => 6,
	"road" => 7,
	"mountain" => 8,
	"downhill" => 9,
	"recumbent" => 10,
	"cyclocross" => 11,
	"hand_cycling" => 12,
	"track_cycling" => 13,
	"indoor_rowing" => 14,
	"elliptical" => 15,
	"stair_climbing" => 16,
	"lap_swimming" => 17,
	"open_water" => 18,
	"flexibility_training" => 19,
	"strength_training" => 20,
	"warm_up" => 21,
	"match" => 22,
	"exercise" => 23,
	"challenge" => 24,
	"indoor_skiing" => 25,
	"cardio_training" => 26,
	"all" => 254,
);

our %sub_sport_id = reverse %sub_sport;

sub FIT_sub_sport {
	exists $sub_sport{$_[0]} or return;
	return $sub_sport{$_[0]}
}

sub FIT_sub_sport_id {
	exists $sub_sport_id{$_[0]} or return;
	return $sub_sport_id{$_[0]}
}

our %timer_trigger = (
	"manual" => 0,
	"auto" => 1,
	"fitness_equipment" => 2,
);

our %timer_trigger_id = reverse %timer_trigger;

sub FIT_timer_trigger {
	exists $timer_trigger{$_[0]} or return;
	return $timer_trigger{$_[0]}
}

sub FIT_timer_trigger_id {
	exists $timer_trigger_id{$_[0]} or return;
	return $timer_trigger_id{$_[0]}
}

1;
