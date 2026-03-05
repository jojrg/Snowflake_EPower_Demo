-- ========================================================================
-- EPOWER Energy AI Demo - Complete Cleanup Script
-- This script removes all demo objects from the Snowflake account
-- Run with ACCOUNTADMIN role to ensure all objects can be dropped
-- ========================================================================

-- Switch to accountadmin role for full cleanup permissions
USE ROLE accountadmin;

-- ========================================================================
-- REMOVE AGENT FROM SNOWFLAKE INTELLIGENCE AND DROP
-- ========================================================================
-- Remove agent from Snowflake Intelligence object first (if it exists)
ALTER SNOWFLAKE INTELLIGENCE snowflake_intelligence_object_default DROP AGENT EPOWER_RETAIL.DEMO_ASSETS.Energy_Chatbot_Agent;

-- Drop the agent
DROP AGENT IF EXISTS EPOWER_RETAIL.DEMO_ASSETS.Energy_Chatbot_Agent;

-- ========================================================================
-- DROP INTEGRATIONS (must be done with accountadmin)
-- ========================================================================
DROP EXTERNAL ACCESS INTEGRATION IF EXISTS Energy_Intelligence_ExternalAccess_Integration;
DROP API INTEGRATION IF EXISTS git_api_integration_energy;

-- ========================================================================
-- DROP DATABASE AND ALL CONTAINED OBJECTS
-- (This will drop all tables, views, stages, functions, procedures, 
--  semantic views, cortex search services, etc.)
-- ========================================================================
DROP DATABASE IF EXISTS EPOWER_RETAIL;

-- ========================================================================
-- SNOWFLAKE INTELLIGENCE OBJECT
-- ========================================================================
-- NOTE: The account-level Snowflake Intelligence object is NOT dropped
-- as it may be shared by other demos. Only agents are removed from it.
-- To drop: DROP SNOWFLAKE INTELLIGENCE IF EXISTS snowflake_intelligence_object_default;

-- ========================================================================
-- DROP WAREHOUSE
-- ========================================================================
DROP WAREHOUSE IF EXISTS EPOWER_WH;

-- ========================================================================
-- DROP ROLE (must revoke grants first)
-- ========================================================================
-- set new defaul role 
SET current_user_name = CURRENT_USER();
ALTER USER IDENTIFIER($current_user_name) SET DEFAULT_ROLE = 'SYSADMIN';

-- Drop the demo role
DROP ROLE IF EXISTS AI_ENGINEER;

-- ========================================================================
-- RESET ACCOUNT SETTINGS (optional - uncomment if needed)
-- ========================================================================
-- ALTER ACCOUNT UNSET CORTEX_ENABLED_CROSS_REGION;

-- ========================================================================
-- VERIFICATION
-- ========================================================================
-- Verify cleanup was successful
SHOW DATABASES LIKE 'EPOWER_RETAIL';
SHOW WAREHOUSES LIKE 'EPOWER_WH';
SHOW ROLES LIKE 'AI_ENGINEER';
SHOW INTEGRATIONS LIKE '%energy%';
SHOW INTEGRATIONS LIKE 'git_api_integration_energy';

SELECT 'EPOWER Energy AI Demo cleanup completed successfully!' AS status;
