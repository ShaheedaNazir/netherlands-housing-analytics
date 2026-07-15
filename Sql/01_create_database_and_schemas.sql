-- Project: Netherlands Housing Analytics
-- File: 01_create_database_and_schemas.sql
-- Purpose: Create the SQL Server database and project schemas

CREATE DATABASE NetherlandsHousingAnalytics;

USE NetherlandsHousingAnalytics;

CREATE SCHEMA raw;

CREATE SCHEMA staging;

CREATE SCHEMA analytics;

CREATE SCHEMA quality;