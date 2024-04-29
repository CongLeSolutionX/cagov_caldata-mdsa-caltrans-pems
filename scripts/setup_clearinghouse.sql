CREATE SCHEMA IF NOT EXISTS CLEARINGHOUSE;

CREATE OR REPLACE FILE FORMAT CLEARINGHOUSE.STATION_RAW
TYPE = csv
PARSE_HEADER = false
FIELD_DELIMITER = ','
SKIP_HEADER = 0
COMPRESSION='gzip';

CREATE OR REPLACE FILE FORMAT CLEARINGHOUSE.STATION_META
TYPE = csv
PARSE_HEADER = false
FIELD_DELIMITER = '\t'
SKIP_HEADER = 1;

CREATE OR REPLACE FILE FORMAT CLEARINGHOUSE.STATION_STATUS
TYPE = XML
STRIP_OUTER_ELEMENT = TRUE;

CREATE TABLE IF NOT EXISTS CLEARINGHOUSE.STATION_RAW (
    FILENAME TEXT,
    SAMPLE_TIMESTAMP TIMESTAMP_NTZ,
    SAMPLE_DATE DATE,
    ID TEXT,
    FLOW_1 INT,
    OCCUPANCY_1 FLOAT,
    SPEED_1 FLOAT,
    FLOW_2 INT,
    OCCUPANCY_2 FLOAT,
    SPEED_2 FLOAT,
    FLOW_3 INT,
    OCCUPANCY_3 FLOAT,
    SPEED_3 FLOAT,
    FLOW_4 INT,
    OCCUPANCY_4 FLOAT,
    SPEED_4 FLOAT,
    FLOW_5 INT,
    OCCUPANCY_5 FLOAT,
    SPEED_5 FLOAT,
    FLOW_6 INT,
    OCCUPANCY_6 FLOAT,
    SPEED_6 FLOAT,
    FLOW_7 INT,
    OCCUPANCY_7 FLOAT,
    SPEED_7 FLOAT,
    FLOW_8 INT,
    OCCUPANCY_8 FLOAT,
    SPEED_8 FLOAT
)
CLUSTER BY (SAMPLE_DATE);

CREATE TABLE IF NOT EXISTS CLEARINGHOUSE.STATION_META (
    FILENAME TEXT,
    ID TEXT,
    FWY TEXT,
    DIR TEXT,
    DISTRICT TEXT,
    COUNTY TEXT,
    CITY TEXT,
    STATE_PM TEXT,
    ABS_PM TEXT,
    LATITUDE FLOAT,
    LONGITUDE FLOAT,
    LENGTH FLOAT,
    TYPE TEXT,
    LANES INT,
    NAME TEXT,
    USER_ID_1 TEXT,
    USER_ID_2 TEXT,
    USER_ID_3 TEXT,
    USER_ID_4 TEXT
);

CREATE TABLE IF NOT EXISTS CLEARINGHOUSE.STATION_STATUS (
    FILENAME TEXT,
    CONTENT VARIANT
);

CREATE SCHEMA IF NOT EXISTS DB96;

CREATE OR REPLACE FILE FORMAT DB96.VDS30SEC
TYPE = parquet
COMPRESSION=AUTO;

CREATE TABLE IF NOT EXISTS DB96.VDS30SEC (
    FILENAME TEXT,
    SAMPLE_TIME TIMESTAMP_NTZ,
    RECV_TIME TIMESTAMP_NTZ,
    META VARIANT,
    VDS_ID INT,
    VOLUME_1 INT,
    VOLUME_2 INT,
    VOLUME_3 INT,
    VOLUME_4 INT,
    VOLUME_5 INT,
    VOLUME_6 INT,
    VOLUME_7 INT,
    VOLUME_8 INT,
    VOLUME_9 INT,
    VOLUME_10 INT,
    VOLUME_11 INT,
    VOLUME_12 INT,
    VOLUME_13 INT,
    VOLUME_14 INT,
    OCCUPANCY_1 FLOAT,
    OCCUPANCY_2 FLOAT,
    OCCUPANCY_3 FLOAT,
    OCCUPANCY_4 FLOAT,
    OCCUPANCY_5 FLOAT,
    OCCUPANCY_6 FLOAT,
    OCCUPANCY_7 FLOAT,
    OCCUPANCY_8 FLOAT,
    OCCUPANCY_9 FLOAT,
    OCCUPANCY_10 FLOAT,
    OCCUPANCY_11 FLOAT,
    OCCUPANCY_12 FLOAT,
    OCCUPANCY_13 FLOAT,
    OCCUPANCY_14 FLOAT,
    SPEED_1 FLOAT,
    SPEED_2 FLOAT,
    SPEED_3 FLOAT,
    SPEED_4 FLOAT,
    SPEED_5 FLOAT,
    SPEED_6 FLOAT,
    SPEED_7 FLOAT,
    SPEED_8 FLOAT,
    SPEED_9 FLOAT,
    SPEED_10 FLOAT,
    SPEED_11 FLOAT,
    SPEED_12 FLOAT,
    SPEED_13 FLOAT,
    SPEED_14 FLOAT
);
