-- Project: Netherlands Housing Analytics
-- File: 01_create_database_and_schemas.sql
-- Purpose: Create the SQL Server database and organize objects into separate processing layers.
-- Database: Microsoft SQL Server

-- Create the project database.
CREATE DATABASE NetherlandsHousingAnalytics;

-- Switch the current connection to the project database.
USE NetherlandsHousingAnalytics;

-- Stores data in its original imported form.
CREATE SCHEMA raw;

-- Stores cleaned and standardized data used for transformation.
CREATE SCHEMA staging;

-- Stores reporting views, analytical objects, and stored procedures.
CREATE SCHEMA analytics;

-- Stores reusable data validation and quality-check objects.
CREATE SCHEMA quality;