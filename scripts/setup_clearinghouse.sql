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
