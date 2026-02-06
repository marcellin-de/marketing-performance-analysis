-- Phase 1: Infrastructure Setup
-- Create warehouse
CREATE WAREHOUSE maven_wh
  WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE;

-- Create database
CREATE DATABASE marketing_performance;

-- Create schemas
CREATE SCHEMA marketing_performance.raw;      -- dlt landing zone
CREATE SCHEMA marketing_performance.intermediate; -- dbt cleaned, transformed models
CREATE SCHEMA marketing_performance.staging;  -- dbt staging models
CREATE SCHEMA marketing_performance.marts;    -- dbt mart models

-- Create service user for dlt
CREATE USER dlt_user
  PASSWORD = 'secure_password'
  DEFAULT_WAREHOUSE = maven_wh;

GRANT USAGE ON WAREHOUSE maven_wh TO ROLE dlt_role;
GRANT ALL ON DATABASE marketing_performance TO ROLE dlt_role;