
-- ========================================================================
-- Snowflake AI Demo - Complete Cleanup Script
-- This script removes all demo objects from the Snowflake account
-- Run with ACCOUNTADMIN role to ensure all objects can be dropped
-- ========================================================================

-- Switch to accountadmin role for full cleanup permissions
USE ROLE accountadmin;

-- ========================================================================
-- REMOVE AGENT FROM SNOWFLAKE INTELLIGENCE AND DROP
-- ========================================================================
-- Remove agent from Snowflake Intelligence object first (if it exists)
ALTER SNOWFLAKE INTELLIGENCE snowflake_intelligence_object_default DROP AGENT SF_AI_DEMO.DEMO_SCHEMA.Company_Chatbot_Agent_Retail;

-- Drop the agent (it's now in SF_AI_DEMO.DEMO_SCHEMA, not SNOWFLAKE_INTELLIGENCE.AGENTS)
DROP AGENT IF EXISTS SF_AI_DEMO.DEMO_SCHEMA.Company_Chatbot_Agent_Retail;

-- ========================================================================
-- DROP INTEGRATIONS (must be done with accountadmin)
-- ========================================================================
DROP NOTIFICATION INTEGRATION IF EXISTS ai_email_int;
DROP EXTERNAL ACCESS INTEGRATION IF EXISTS Snowflake_intelligence_ExternalAccess_Integration;
DROP API INTEGRATION IF EXISTS git_api_integration_jojrg;

-- ========================================================================
-- DROP DATABASE AND ALL CONTAINED OBJECTS
-- (This will drop all tables, views, stages, functions, procedures, etc.)
-- ========================================================================
DROP DATABASE IF EXISTS SF_AI_DEMO;

-- ========================================================================
-- SNOWFLAKE INTELLIGENCE OBJECT
-- ========================================================================
-- NOTE: The account-level Snowflake Intelligence object is NOT dropped
-- as it may be shared by other demos. Only agents are removed from it.
-- To drop: DROP SNOWFLAKE INTELLIGENCE IF EXISTS snowflake_intelligence_object_default;

-- ========================================================================
-- DROP WAREHOUSE
-- ========================================================================
DROP WAREHOUSE IF EXISTS SNOW_INTELLIGENCE_DEMO_WH;

-- ========================================================================
-- DROP ROLE (must revoke grants first)
-- ========================================================================
-- Revoke role from current user before dropping
SET current_user_name = CURRENT_USER();
REVOKE ROLE SF_Intelligence_Demo FROM USER IDENTIFIER($current_user_name);

-- Drop the demo role
DROP ROLE IF EXISTS SF_Intelligence_Demo;

-- ========================================================================
-- RESET ACCOUNT SETTINGS (optional - uncomment if needed)
-- ========================================================================
-- ALTER ACCOUNT UNSET CORTEX_ENABLED_CROSS_REGION;

-- ========================================================================
-- VERIFICATION
-- ========================================================================
-- Verify cleanup was successful
SHOW DATABASES LIKE 'SF_AI_DEMO';
SHOW WAREHOUSES LIKE 'SNOW_INTELLIGENCE_DEMO_WH';
SHOW ROLES LIKE 'SF_Intelligence_Demo';
SHOW INTEGRATIONS LIKE '%intelligence%';
SHOW INTEGRATIONS LIKE 'ai_email_int';
SHOW INTEGRATIONS LIKE 'git_api_integration_jojrg';

SELECT 'Demo cleanup completed successfully!' AS status;
