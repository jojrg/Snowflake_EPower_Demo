-- ========================================================================
-- Energy Retail AI Demo - Complete Setup Script (EPOWER Style)
-- This script creates the database, schema, tables, and loads all data
-- Adapted from Retail Demo for Energy B2C use case
-- ========================================================================

-- Switch to accountadmin role to create warehouse
USE ROLE accountadmin;

-- Enable Cross Region Inferencing
//ALTER ACCOUNT SET CORTEX_ENABLED_CROSS_REGION = 'AWS_EU';

-- ========================================================================
-- SNOWFLAKE INTELLIGENCE SETUP
-- ========================================================================
CREATE SNOWFLAKE INTELLIGENCE IF NOT EXISTS snowflake_intelligence_object_default;

CREATE OR REPLACE ROLE Energy_Intelligence_Demo;

SET current_user_name = CURRENT_USER();

GRANT ROLE Energy_Intelligence_Demo TO USER IDENTIFIER($current_user_name);
GRANT CREATE DATABASE ON ACCOUNT TO ROLE Energy_Intelligence_Demo;

-- Create a dedicated warehouse for the demo
CREATE OR REPLACE WAREHOUSE Energy_Intelligence_demo_wh 
    WITH WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE;

GRANT USAGE ON WAREHOUSE ENERGY_INTELLIGENCE_DEMO_WH TO ROLE Energy_Intelligence_Demo;

ALTER USER IDENTIFIER($current_user_name) SET DEFAULT_ROLE = Energy_Intelligence_Demo;
ALTER USER IDENTIFIER($current_user_name) SET DEFAULT_WAREHOUSE = Energy_Intelligence_demo_wh;

-- Switch to demo role
USE ROLE Energy_Intelligence_Demo;

-- Create database and schema
CREATE OR REPLACE DATABASE ENERGY_AI_DEMO;
USE DATABASE ENERGY_AI_DEMO;

CREATE SCHEMA IF NOT EXISTS ENERGY_SCHEMA;
USE SCHEMA ENERGY_SCHEMA;

-- ========================================================================
-- FILE FORMAT
-- ========================================================================
CREATE OR REPLACE FILE FORMAT CSV_FORMAT
    TYPE = 'CSV'
    FIELD_DELIMITER = ','
    RECORD_DELIMITER = '\n'
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    TRIM_SPACE = TRUE
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
    ESCAPE = 'NONE'
    ESCAPE_UNENCLOSED_FIELD = '\134'
    DATE_FORMAT = 'YYYY-MM-DD'
    TIMESTAMP_FORMAT = 'YYYY-MM-DD HH24:MI:SS'
    NULL_IF = ('NULL', 'null', '', 'N/A', 'n/a');

-- ========================================================================
-- GIT INTEGRATION (Update with your repository)
-- ========================================================================
USE ROLE accountadmin;

CREATE OR REPLACE API INTEGRATION git_api_integration_energy
    API_PROVIDER = git_https_api
    API_ALLOWED_PREFIXES = ('https://github.com/jojrg/')
    ENABLED = TRUE;

GRANT USAGE ON INTEGRATION git_api_integration_energy TO ROLE Energy_Intelligence_Demo;

USE ROLE Energy_Intelligence_Demo;

-- Create Git repository integration
-- NOTE: Using branch 'domain_migratiion_experiment' which contains the energy demo data
CREATE OR REPLACE GIT REPOSITORY ENERGY_AI_DEMO_REPO
    API_INTEGRATION = git_api_integration_energy
    GIT_CREDENTIALS = null
    ORIGIN = 'https://github.com/jojrg/Snowflake_AI_DEMO.git';

-- Create internal stage
CREATE OR REPLACE STAGE ENERGY_STAGE
    FILE_FORMAT = CSV_FORMAT
    COMMENT = 'Internal stage for Energy demo data'
    DIRECTORY = (ENABLE = TRUE)
    ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE');

ALTER GIT REPOSITORY ENERGY_AI_DEMO_REPO FETCH;

-- ========================================================================
-- COPY DATA FROM GIT TO INTERNAL STAGE
-- Data is in branch 'domain_migratiion_experiment' at top level
-- ========================================================================
COPY FILES INTO @ENERGY_STAGE/demo_data/ FROM @ENERGY_AI_DEMO_REPO/branches/domain_migratiion_experiment/demo_data/;
COPY FILES INTO @ENERGY_STAGE/unstructured_docs/ FROM @ENERGY_AI_DEMO_REPO/branches/domain_migratiion_experiment/unstructured_docs/;

-- For local testing (alternative to Git), upload files manually:
-- PUT file:///path/to/demo_data/*.csv @ENERGY_STAGE/demo_data/;
-- PUT file:///path/to/unstructured_docs/**/* @ENERGY_STAGE/unstructured_docs/;

ALTER STAGE ENERGY_STAGE REFRESH;

-- ========================================================================
-- DIMENSION TABLES
-- ========================================================================

-- Product Category Dimension (Energy categories)
CREATE OR REPLACE TABLE product_category_dim (
    category_key INT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    vertical VARCHAR(50) NOT NULL
) COMMENT = 'Energy product categories: Electricity, Gas, Solar, Heat Pumps, Smart Home, E-Mobility';

-- Product Dimension (Energy products/tariffs)
CREATE OR REPLACE TABLE product_dim (
    product_key INT PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    category_key INT NOT NULL,
    category_name VARCHAR(100),
    vertical VARCHAR(50)
) COMMENT = 'Energy products and tariffs including EPOWER Strom, Gas, Solar, Wärmepumpe offerings';

-- Customer Dimension (German residential and business customers)
CREATE OR REPLACE TABLE customer_dim (
    customer_key INT PRIMARY KEY,
    customer_name VARCHAR(200) NOT NULL,
    customer_type VARCHAR(50),
    housing_type VARCHAR(100),
    vertical VARCHAR(50),
    address VARCHAR(200),
    city VARCHAR(100),
    state VARCHAR(50),
    zip VARCHAR(20),
    region_key INT
) COMMENT = 'German energy customers with housing type for consumption analysis';

-- Vendor Dimension (Installation and service partners)
CREATE OR REPLACE TABLE vendor_dim (
    vendor_key INT PRIMARY KEY,
    vendor_name VARCHAR(200) NOT NULL,
    vendor_type VARCHAR(100),
    vertical VARCHAR(50),
    address VARCHAR(200),
    city VARCHAR(100),
    state VARCHAR(50),
    zip VARCHAR(20)
) COMMENT = 'Installation partners, service providers, and suppliers';

-- Account Dimension (Finance)
CREATE OR REPLACE TABLE account_dim (
    account_key INT PRIMARY KEY,
    account_name VARCHAR(100) NOT NULL,
    account_type VARCHAR(50)
);

-- Department Dimension (German department names)
CREATE OR REPLACE TABLE department_dim (
    department_key INT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL
) COMMENT = 'EPOWER organizational departments';

-- Region Dimension (German regions)
CREATE OR REPLACE TABLE region_dim (
    region_key INT PRIMARY KEY,
    region_name VARCHAR(100) NOT NULL
) COMMENT = 'German geographic regions: North, South, West, East';

-- Sales Rep Dimension (Energy consultants)
CREATE OR REPLACE TABLE sales_rep_dim (
    sales_rep_key INT PRIMARY KEY,
    rep_name VARCHAR(200) NOT NULL,
    hire_date DATE
) COMMENT = 'Energy consultants and sales representatives';

-- Campaign Dimension (Energy marketing campaigns)
CREATE OR REPLACE TABLE campaign_dim (
    campaign_key INT PRIMARY KEY,
    campaign_name VARCHAR(300) NOT NULL,
    objective VARCHAR(100)
) COMMENT = 'Marketing campaigns for energy products';

-- Channel Dimension
CREATE OR REPLACE TABLE channel_dim (
    channel_key INT PRIMARY KEY,
    channel_name VARCHAR(100) NOT NULL
);

-- Employee Dimension
CREATE OR REPLACE TABLE employee_dim (
    employee_key INT PRIMARY KEY,
    employee_name VARCHAR(200) NOT NULL,
    gender VARCHAR(1),
    hire_date DATE
);

-- Job Dimension (German job titles)
CREATE OR REPLACE TABLE job_dim (
    job_key INT PRIMARY KEY,
    job_title VARCHAR(100) NOT NULL,
    job_level INT
);

-- Location Dimension (German cities)
CREATE OR REPLACE TABLE location_dim (
    location_key INT PRIMARY KEY,
    location_name VARCHAR(200) NOT NULL
);

-- ========================================================================
-- FACT TABLES
-- ========================================================================

-- Contracts/Sales Fact Table (Energy contracts)
CREATE OR REPLACE TABLE sales_fact (
    sale_id INT PRIMARY KEY,
    date DATE NOT NULL,
    customer_key INT NOT NULL,
    product_key INT NOT NULL,
    sales_rep_key INT NOT NULL,
    region_key INT NOT NULL,
    vendor_key INT NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    units INT NOT NULL
) COMMENT = 'Energy contracts and product sales. Amount in EUR, Units = kWh for tariffs or count for hardware';

-- Billing History Table (NEW - Energy-specific)
CREATE OR REPLACE TABLE billing_history (
    billing_id INT PRIMARY KEY,
    customer_key INT NOT NULL,
    billing_date DATE NOT NULL,
    billing_type VARCHAR(50) NOT NULL,
    consumption_kwh INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_status VARCHAR(50)
) COMMENT = 'Monthly energy consumption and billing records. billing_type = Electricity or Gas';

-- Service Logs Table (NEW - Customer service tickets)
CREATE OR REPLACE TABLE service_logs (
    log_id INT PRIMARY KEY,
    customer_key INT NOT NULL,
    log_date DATE NOT NULL,
    topic VARCHAR(100) NOT NULL,
    category VARCHAR(100),
    description VARCHAR(500),
    sentiment VARCHAR(50),
    channel VARCHAR(50),
    priority VARCHAR(50),
    resolution_date DATE,
    agent_key INT
) COMMENT = 'Customer service tickets and support requests. Sentiment = Positiv/Neutral/Negativ';

-- Finance Transactions Fact Table
CREATE OR REPLACE TABLE finance_transactions (
    transaction_id INT PRIMARY KEY,
    date DATE NOT NULL,
    account_key INT NOT NULL,
    department_key INT NOT NULL,
    vendor_key INT NOT NULL,
    product_key INT NOT NULL,
    customer_key INT NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    approval_status VARCHAR(20) DEFAULT 'Pending',
    procurement_method VARCHAR(50),
    approver_id INT,
    approval_date DATE,
    purchase_order_number VARCHAR(50),
    contract_reference VARCHAR(100)
);

-- Marketing Campaign Fact Table
CREATE OR REPLACE TABLE marketing_campaign_fact (
    campaign_fact_id INT PRIMARY KEY,
    date DATE NOT NULL,
    campaign_key INT NOT NULL,
    product_key INT NOT NULL,
    channel_key INT NOT NULL,
    region_key INT NOT NULL,
    spend DECIMAL(10,2) NOT NULL,
    leads_generated INT NOT NULL,
    impressions INT NOT NULL
);

-- HR Employee Fact Table
CREATE OR REPLACE TABLE hr_employee_fact (
    hr_fact_id INT PRIMARY KEY,
    date DATE NOT NULL,
    employee_key INT NOT NULL,
    department_key INT NOT NULL,
    job_key INT NOT NULL,
    location_key INT NOT NULL,
    salary DECIMAL(10,2) NOT NULL,
    attrition_flag INT NOT NULL
);

-- ========================================================================
-- SALESFORCE CRM TABLES
-- ========================================================================

CREATE OR REPLACE TABLE sf_accounts (
    account_id VARCHAR(20) PRIMARY KEY,
    account_name VARCHAR(200) NOT NULL,
    customer_key INT NOT NULL,
    industry VARCHAR(100),
    vertical VARCHAR(50),
    billing_street VARCHAR(200),
    billing_city VARCHAR(100),
    billing_state VARCHAR(50),
    billing_postal_code VARCHAR(20),
    account_type VARCHAR(50),
    annual_revenue DECIMAL(15,2),
    employees INT,
    created_date DATE
);

CREATE OR REPLACE TABLE sf_opportunities (
    opportunity_id VARCHAR(20) PRIMARY KEY,
    sale_id INT,
    account_id VARCHAR(20) NOT NULL,
    opportunity_name VARCHAR(200) NOT NULL,
    stage_name VARCHAR(100) NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    probability DECIMAL(5,2),
    close_date DATE,
    created_date DATE,
    lead_source VARCHAR(100),
    type VARCHAR(100),
    campaign_id INT
);

CREATE OR REPLACE TABLE sf_contacts (
    contact_id VARCHAR(20) PRIMARY KEY,
    opportunity_id VARCHAR(20) NOT NULL,
    account_id VARCHAR(20) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(200),
    phone VARCHAR(50),
    title VARCHAR(100),
    department VARCHAR(100),
    lead_source VARCHAR(100),
    campaign_no INT,
    created_date DATE
);

-- ========================================================================
-- LOAD DATA FROM STAGE
-- ========================================================================

COPY INTO product_category_dim FROM @ENERGY_STAGE/demo_data/product_category_dim.csv FILE_FORMAT = CSV_FORMAT ON_ERROR = 'CONTINUE';
COPY INTO product_dim FROM @ENERGY_STAGE/demo_data/product_dim.csv FILE_FORMAT = CSV_FORMAT ON_ERROR = 'CONTINUE';
COPY INTO customer_dim FROM @ENERGY_STAGE/demo_data/customer_dim.csv FILE_FORMAT = CSV_FORMAT ON_ERROR = 'CONTINUE';
COPY INTO vendor_dim FROM @ENERGY_STAGE/demo_data/vendor_dim.csv FILE_FORMAT = CSV_FORMAT ON_ERROR = 'CONTINUE';
COPY INTO account_dim FROM @ENERGY_STAGE/demo_data/account_dim.csv FILE_FORMAT = CSV_FORMAT ON_ERROR = 'CONTINUE';
COPY INTO department_dim FROM @ENERGY_STAGE/demo_data/department_dim.csv FILE_FORMAT = CSV_FORMAT ON_ERROR = 'CONTINUE';
COPY INTO region_dim FROM @ENERGY_STAGE/demo_data/region_dim.csv FILE_FORMAT = CSV_FORMAT ON_ERROR = 'CONTINUE';
COPY INTO sales_rep_dim FROM @ENERGY_STAGE/demo_data/sales_rep_dim.csv FILE_FORMAT = CSV_FORMAT ON_ERROR = 'CONTINUE';
COPY INTO campaign_dim FROM @ENERGY_STAGE/demo_data/campaign_dim.csv FILE_FORMAT = CSV_FORMAT ON_ERROR = 'CONTINUE';
COPY INTO channel_dim FROM @ENERGY_STAGE/demo_data/channel_dim.csv FILE_FORMAT = CSV_FORMAT ON_ERROR = 'CONTINUE';
COPY INTO employee_dim FROM @ENERGY_STAGE/demo_data/employee_dim.csv FILE_FORMAT = CSV_FORMAT ON_ERROR = 'CONTINUE';
COPY INTO job_dim FROM @ENERGY_STAGE/demo_data/job_dim.csv FILE_FORMAT = CSV_FORMAT ON_ERROR = 'CONTINUE';
COPY INTO location_dim FROM @ENERGY_STAGE/demo_data/location_dim.csv FILE_FORMAT = CSV_FORMAT ON_ERROR = 'CONTINUE';

COPY INTO sales_fact FROM @ENERGY_STAGE/demo_data/sales_fact.csv FILE_FORMAT = CSV_FORMAT ON_ERROR = 'CONTINUE';
COPY INTO billing_history FROM @ENERGY_STAGE/demo_data/billing_history.csv FILE_FORMAT = CSV_FORMAT ON_ERROR = 'CONTINUE';
COPY INTO service_logs FROM @ENERGY_STAGE/demo_data/service_logs.csv FILE_FORMAT = CSV_FORMAT ON_ERROR = 'CONTINUE';
COPY INTO finance_transactions FROM @ENERGY_STAGE/demo_data/finance_transactions.csv FILE_FORMAT = CSV_FORMAT ON_ERROR = 'CONTINUE';
COPY INTO marketing_campaign_fact FROM @ENERGY_STAGE/demo_data/marketing_campaign_fact.csv FILE_FORMAT = CSV_FORMAT ON_ERROR = 'CONTINUE';
COPY INTO hr_employee_fact FROM @ENERGY_STAGE/demo_data/hr_employee_fact.csv FILE_FORMAT = CSV_FORMAT ON_ERROR = 'CONTINUE';

COPY INTO sf_accounts FROM @ENERGY_STAGE/demo_data/sf_accounts.csv FILE_FORMAT = CSV_FORMAT ON_ERROR = 'CONTINUE';
COPY INTO sf_opportunities FROM @ENERGY_STAGE/demo_data/sf_opportunities.csv FILE_FORMAT = CSV_FORMAT ON_ERROR = 'CONTINUE';
COPY INTO sf_contacts FROM @ENERGY_STAGE/demo_data/sf_contacts.csv FILE_FORMAT = CSV_FORMAT ON_ERROR = 'CONTINUE';

-- ========================================================================
-- VERIFICATION
-- ========================================================================
SELECT 'DIMENSION TABLES' as category, '' as table_name, NULL as row_count
UNION ALL SELECT '', 'product_category_dim', COUNT(*) FROM product_category_dim
UNION ALL SELECT '', 'product_dim', COUNT(*) FROM product_dim
UNION ALL SELECT '', 'customer_dim', COUNT(*) FROM customer_dim
UNION ALL SELECT '', 'vendor_dim', COUNT(*) FROM vendor_dim
UNION ALL SELECT '', 'region_dim', COUNT(*) FROM region_dim
UNION ALL SELECT '', '', NULL
UNION ALL SELECT 'FACT TABLES', '', NULL
UNION ALL SELECT '', 'sales_fact', COUNT(*) FROM sales_fact
UNION ALL SELECT '', 'billing_history', COUNT(*) FROM billing_history
UNION ALL SELECT '', 'service_logs', COUNT(*) FROM service_logs
UNION ALL SELECT '', 'finance_transactions', COUNT(*) FROM finance_transactions
UNION ALL SELECT '', 'marketing_campaign_fact', COUNT(*) FROM marketing_campaign_fact
UNION ALL SELECT '', 'hr_employee_fact', COUNT(*) FROM hr_employee_fact;

-- ========================================================================
-- SEMANTIC VIEWS FOR CORTEX ANALYST
-- ========================================================================

-- ENERGY SALES SEMANTIC VIEW (Contracts and Products)
CREATE OR REPLACE SEMANTIC VIEW ENERGY_AI_DEMO.ENERGY_SCHEMA.ENERGY_SALES_SEMANTIC_VIEW
    tables (
        CUSTOMERS as ENERGY_AI_DEMO.ENERGY_SCHEMA.CUSTOMER_DIM primary key (CUSTOMER_KEY) 
            with synonyms=('Kunden','customers','Privatkunden','Gewerbekunden') 
            comment='German energy customers with housing type for consumption analysis',
        PRODUCTS as ENERGY_AI_DEMO.ENERGY_SCHEMA.PRODUCT_DIM primary key (PRODUCT_KEY) 
            with synonyms=('Produkte','Tarife','products','tariffs') 
            comment='Energy products: Strom, Gas, Solar, Wärmepumpe, Smart Home, E-Mobility',
        PRODUCT_CATEGORIES as ENERGY_AI_DEMO.ENERGY_SCHEMA.PRODUCT_CATEGORY_DIM primary key (CATEGORY_KEY)
            with synonyms=('Kategorien','categories')
            comment='Product categories: Electricity, Gas, Solar, Heat Pumps, Smart Home, E-Mobility',
        REGIONS as ENERGY_AI_DEMO.ENERGY_SCHEMA.REGION_DIM primary key (REGION_KEY) 
            with synonyms=('Regionen','regions','Gebiete') 
            comment='German regions: North, South, West, East',
        CONTRACTS as ENERGY_AI_DEMO.ENERGY_SCHEMA.SALES_FACT primary key (SALE_ID) 
            with synonyms=('Verträge','contracts','sales','Aufträge') 
            comment='Energy contracts and product sales',
        SALES_REPS as ENERGY_AI_DEMO.ENERGY_SCHEMA.SALES_REP_DIM primary key (SALES_REP_KEY) 
            with synonyms=('Berater','Energieberater','consultants') 
            comment='Energy consultants',
        VENDORS as ENERGY_AI_DEMO.ENERGY_SCHEMA.VENDOR_DIM primary key (VENDOR_KEY) 
            with synonyms=('Partner','Installateure','vendors','suppliers') 
            comment='Installation and service partners'
    )
    relationships (
        PRODUCT_TO_CATEGORY as PRODUCTS(CATEGORY_KEY) references PRODUCT_CATEGORIES(CATEGORY_KEY),
        CONTRACTS_TO_CUSTOMERS as CONTRACTS(CUSTOMER_KEY) references CUSTOMERS(CUSTOMER_KEY),
        CONTRACTS_TO_PRODUCTS as CONTRACTS(PRODUCT_KEY) references PRODUCTS(PRODUCT_KEY),
        CONTRACTS_TO_REGIONS as CONTRACTS(REGION_KEY) references REGIONS(REGION_KEY),
        CONTRACTS_TO_REPS as CONTRACTS(SALES_REP_KEY) references SALES_REPS(SALES_REP_KEY),
        CONTRACTS_TO_VENDORS as CONTRACTS(VENDOR_KEY) references VENDORS(VENDOR_KEY),
        CUSTOMERS_TO_REGIONS as CUSTOMERS(REGION_KEY) references REGIONS(REGION_KEY)
    )
    facts (
        CONTRACTS.CONTRACT_AMOUNT as AMOUNT comment='Contract value in EUR',
        CONTRACTS.CONTRACT_UNITS as UNITS comment='kWh for tariffs or unit count for hardware',
        CONTRACTS.CONTRACT_RECORD as 1 comment='Count of contracts'
    )
    dimensions (
        CUSTOMERS.CUSTOMER_KEY as CUSTOMER_KEY,
        CUSTOMERS.CUSTOMER_NAME as customer_name with synonyms=('Kunde','Name') comment='Customer name',
        CUSTOMERS.CUSTOMER_TYPE as customer_type with synonyms=('Kundentyp','Segment') comment='Privatkunde, Kleingewerbe, Gewerbekunde',
        CUSTOMERS.HOUSING_TYPE as housing_type with synonyms=('Wohnform','Gebäudetyp') comment='Einfamilienhaus, Reihenhaus, Wohnung, etc.',
        CUSTOMERS.CITY as city with synonyms=('Stadt','Ort') comment='German city',
        CUSTOMERS.STATE as state with synonyms=('Region','Bundesland') comment='North, South, West, East',
        PRODUCTS.PRODUCT_KEY as PRODUCT_KEY,
        PRODUCTS.PRODUCT_NAME as product_name with synonyms=('Produkt','Tarif') comment='Product/tariff name',
        PRODUCTS.CATEGORY_NAME as category_name with synonyms=('Kategorie') comment='Product category',
        PRODUCTS.VERTICAL as vertical with synonyms=('Bereich','Segment') comment='Energy, Future Energy, Smart Home, E-Mobility',
        PRODUCT_CATEGORIES.CATEGORY_KEY as CATEGORY_KEY,
        PRODUCT_CATEGORIES.MAINCATEGORY as CATEGORY_NAME with synonyms=('Produktkategorie','product_category','main_category') comment='Electricity, Gas, Solar, Heat Pumps, Smart Home, E-Mobility',
        REGIONS.REGION_KEY as REGION_KEY,
        REGIONS.REGION_NAME as region_name with synonyms=('Region','Gebiet') comment='German region',
        CONTRACTS.CONTRACT_ID as SALE_ID,
        CONTRACTS.CONTRACT_DATE as "DATE" with synonyms=('Vertragsdatum','Datum') comment='Contract date',
        CONTRACTS.SALES_REP_KEY as SALES_REP_KEY,
        SALES_REPS.CONSULTANT_NAME as REP_NAME with synonyms=('Berater','Vertriebsmitarbeiter') comment='Energy consultant name',
        VENDORS.VENDOR_KEY as VENDOR_KEY,
        VENDORS.VENDOR_NAME as vendor_name with synonyms=('Partner','Installateur') comment='Installation partner'
    )
    metrics (
        CONTRACTS.TOTAL_REVENUE as SUM(contracts.contract_amount) comment='Total contract revenue in EUR',
        CONTRACTS.TOTAL_CONTRACTS as COUNT(contracts.contract_record) comment='Total number of contracts',
        CONTRACTS.AVERAGE_CONTRACT_VALUE as AVG(contracts.contract_amount) comment='Average contract value',
        CONTRACTS.TOTAL_UNITS as SUM(contracts.contract_units) comment='Total units sold'
    )
    comment='Semantic view for energy sales analysis - contracts, products, customers';

-- BILLING AND CONSUMPTION SEMANTIC VIEW
CREATE OR REPLACE SEMANTIC VIEW ENERGY_AI_DEMO.ENERGY_SCHEMA.BILLING_SEMANTIC_VIEW
    tables (
        CUSTOMERS as ENERGY_AI_DEMO.ENERGY_SCHEMA.CUSTOMER_DIM primary key (CUSTOMER_KEY)
            with synonyms=('Kunden','customers')
            comment='Energy customers',
        BILLING as ENERGY_AI_DEMO.ENERGY_SCHEMA.BILLING_HISTORY primary key (BILLING_ID)
            with synonyms=('Rechnungen','Abrechnungen','billing','invoices')
            comment='Monthly energy billing and consumption'
    )
    relationships (
        BILLING_TO_CUSTOMERS as BILLING(CUSTOMER_KEY) references CUSTOMERS(CUSTOMER_KEY)
    )
    facts (
        BILLING.CONSUMPTION as CONSUMPTION_KWH comment='Energy consumption in kWh',
        BILLING.BILLING_AMOUNT as AMOUNT comment='Invoice amount in EUR',
        BILLING.BILLING_RECORD as 1 comment='Count of billing records'
    )
    dimensions (
        CUSTOMERS.CUSTOMER_KEY as CUSTOMER_KEY,
        CUSTOMERS.CUSTOMER_NAME as customer_name comment='Customer name',
        CUSTOMERS.HOUSING_TYPE as housing_type comment='Housing type',
        CUSTOMERS.CITY as city comment='City',
        BILLING.BILLING_ID as BILLING_ID,
        BILLING.BILLING_DATE as billing_date with synonyms=('Rechnungsdatum','Abrechnungsdatum') comment='Billing date',
        BILLING.BILLING_TYPE as billing_type with synonyms=('Energieart','Art') comment='Electricity or Gas',
        BILLING.PAYMENT_STATUS as payment_status with synonyms=('Zahlungsstatus','Status') comment='Bezahlt, Offen, Überfällig'
    )
    metrics (
        BILLING.TOTAL_CONSUMPTION as SUM(billing.consumption) comment='Total consumption in kWh',
        BILLING.AVERAGE_CONSUMPTION as AVG(billing.consumption) comment='Average consumption in kWh',
        BILLING.TOTAL_BILLING_AMOUNT as SUM(billing.billing_amount) comment='Total billing amount',
        BILLING.TOTAL_INVOICES as COUNT(billing.billing_record) comment='Number of invoices'
    )
    comment='Semantic view for energy consumption and billing analysis';

-- SERVICE LOGS SEMANTIC VIEW
CREATE OR REPLACE SEMANTIC VIEW ENERGY_AI_DEMO.ENERGY_SCHEMA.SERVICE_SEMANTIC_VIEW
    tables (
        CUSTOMERS as ENERGY_AI_DEMO.ENERGY_SCHEMA.CUSTOMER_DIM primary key (CUSTOMER_KEY)
            with synonyms=('Kunden','customers')
            comment='Energy customers',
        SERVICE_TICKETS as ENERGY_AI_DEMO.ENERGY_SCHEMA.SERVICE_LOGS primary key (LOG_ID)
            with synonyms=('Tickets','Anfragen','service requests','Kundenservice')
            comment='Customer service tickets and support requests'
    )
    relationships (
        SERVICE_TO_CUSTOMERS as SERVICE_TICKETS(CUSTOMER_KEY) references CUSTOMERS(CUSTOMER_KEY)
    )
    facts (
        SERVICE_TICKETS.TICKET_RECORD as 1 comment='Count of service tickets'
    )
    dimensions (
        CUSTOMERS.CUSTOMER_KEY as CUSTOMER_KEY,
        CUSTOMERS.CUSTOMER_NAME as customer_name comment='Customer name',
        CUSTOMERS.CITY as city comment='City',
        SERVICE_TICKETS.TICKET_ID as LOG_ID,
        SERVICE_TICKETS.TICKET_DATE as LOG_DATE with synonyms=('Datum','Erstelldatum') comment='Ticket creation date',
        SERVICE_TICKETS.TOPIC as topic with synonyms=('Thema','Betreff') comment='Topic: Smart Meter, Rechnung, Wärmepumpe, Solar, Tarif, Wallbox, Allgemein',
        SERVICE_TICKETS.CATEGORY as category with synonyms=('Kategorie') comment='Category: Installation, Abrechnung, Technisch, Vertrag, E-Mobility, Service',
        SERVICE_TICKETS.DESCRIPTION as description with synonyms=('Beschreibung','Details') comment='Ticket description',
        SERVICE_TICKETS.SENTIMENT as sentiment with synonyms=('Stimmung','Bewertung') comment='Customer sentiment: Positiv, Neutral, Negativ',
        SERVICE_TICKETS.CHANNEL as channel with synonyms=('Kanal','Kontaktweg') comment='Contact channel: Telefon, Email, Chat, App',
        SERVICE_TICKETS.PRIORITY as priority with synonyms=('Priorität','Dringlichkeit') comment='Priority: Niedrig, Mittel, Hoch, Kritisch',
        SERVICE_TICKETS.RESOLUTION_DATE as resolution_date with synonyms=('Lösungsdatum') comment='Resolution date'
    )
    metrics (
        SERVICE_TICKETS.TOTAL_TICKETS as COUNT(service_tickets.ticket_record) comment='Total number of tickets',
        SERVICE_TICKETS.NEGATIVE_TICKETS as SUM(CASE WHEN service_tickets.sentiment = 'Negativ' THEN 1 ELSE 0 END) comment='Negative sentiment tickets'
    )
    comment='Semantic view for customer service analysis';

-- HR SEMANTIC VIEW
CREATE OR REPLACE SEMANTIC VIEW ENERGY_AI_DEMO.ENERGY_SCHEMA.HR_SEMANTIC_VIEW
    tables (
        DEPARTMENTS as ENERGY_AI_DEMO.ENERGY_SCHEMA.DEPARTMENT_DIM primary key (DEPARTMENT_KEY)
            with synonyms=('Abteilungen','departments')
            comment='Company departments',
        EMPLOYEES as ENERGY_AI_DEMO.ENERGY_SCHEMA.EMPLOYEE_DIM primary key (EMPLOYEE_KEY)
            with synonyms=('Mitarbeiter','employees','Personal')
            comment='Employees',
        HR_RECORDS as ENERGY_AI_DEMO.ENERGY_SCHEMA.HR_EMPLOYEE_FACT primary key (HR_FACT_ID)
            with synonyms=('HR-Daten','hr records')
            comment='HR fact records',
        JOBS as ENERGY_AI_DEMO.ENERGY_SCHEMA.JOB_DIM primary key (JOB_KEY)
            with synonyms=('Stellen','jobs','Positionen')
            comment='Job positions',
        LOCATIONS as ENERGY_AI_DEMO.ENERGY_SCHEMA.LOCATION_DIM primary key (LOCATION_KEY)
            with synonyms=('Standorte','locations')
            comment='Office locations'
    )
    relationships (
        HR_TO_DEPARTMENTS as HR_RECORDS(DEPARTMENT_KEY) references DEPARTMENTS(DEPARTMENT_KEY),
        HR_TO_EMPLOYEES as HR_RECORDS(EMPLOYEE_KEY) references EMPLOYEES(EMPLOYEE_KEY),
        HR_TO_JOBS as HR_RECORDS(JOB_KEY) references JOBS(JOB_KEY),
        HR_TO_LOCATIONS as HR_RECORDS(LOCATION_KEY) references LOCATIONS(LOCATION_KEY)
    )
    facts (
        HR_RECORDS.ATTRITION_FLAG as ATTRITION_FLAG comment='1 = employee left, 0 = active',
        HR_RECORDS.EMPLOYEE_SALARY as SALARY comment='Salary in EUR',
        HR_RECORDS.HR_RECORD as 1 comment='HR record count',
        EMPLOYEES.EMPLOYEE_COUNT as 1 comment='Employee count'
    )
    dimensions (
        DEPARTMENTS.DEPARTMENT_KEY as DEPARTMENT_KEY,
        DEPARTMENTS.DEPARTMENT_NAME as department_name with synonyms=('Abteilung') comment='Department name',
        EMPLOYEES.EMPLOYEE_KEY as EMPLOYEE_KEY,
        EMPLOYEES.EMPLOYEE_NAME as employee_name with synonyms=('Mitarbeiter','Name') comment='Employee name',
        EMPLOYEES.GENDER as gender with synonyms=('Geschlecht') comment='M or F',
        EMPLOYEES.HIRE_DATE as hire_date with synonyms=('Eintrittsdatum') comment='Hire date',
        HR_RECORDS.RECORD_DATE as "DATE" comment='HR record date',
        JOBS.JOB_KEY as JOB_KEY,
        JOBS.JOB_TITLE as job_title with synonyms=('Position','Stelle') comment='Job title',
        JOBS.JOB_LEVEL as job_level with synonyms=('Ebene','Level') comment='Job level',
        LOCATIONS.LOCATION_KEY as LOCATION_KEY,
        LOCATIONS.LOCATION_NAME as location_name with synonyms=('Standort') comment='Office location'
    )
    metrics (
        HR_RECORDS.TOTAL_SALARY as SUM(hr_records.employee_salary) comment='Total salary cost',
        HR_RECORDS.AVG_SALARY as AVG(hr_records.employee_salary) comment='Average salary',
        HR_RECORDS.ATTRITION_COUNT as SUM(hr_records.attrition_flag) comment='Attrition count',
        EMPLOYEES.TOTAL_EMPLOYEES as COUNT(employees.employee_count) comment='Total employees'
    )
    comment='Semantic view for HR analytics';

SHOW SEMANTIC VIEWS;

-- ========================================================================
-- UNSTRUCTURED DATA PROCESSING
-- ========================================================================
CREATE OR REPLACE TABLE parsed_content AS 
SELECT 
    relative_path,
    BUILD_STAGE_FILE_URL('@ENERGY_AI_DEMO.ENERGY_SCHEMA.ENERGY_STAGE', relative_path) as file_url,
    TO_FILE(BUILD_STAGE_FILE_URL('@ENERGY_AI_DEMO.ENERGY_SCHEMA.ENERGY_STAGE', relative_path)) file_object,
    SNOWFLAKE.CORTEX.PARSE_DOCUMENT(
        @ENERGY_AI_DEMO.ENERGY_SCHEMA.ENERGY_STAGE,
        relative_path,
        {'mode':'LAYOUT'}
    ):content::string as content
FROM directory(@ENERGY_AI_DEMO.ENERGY_SCHEMA.ENERGY_STAGE) 
WHERE relative_path ILIKE 'unstructured_docs/%.pdf' 
   OR relative_path ILIKE 'unstructured_docs/%.md';

-- ========================================================================
-- CORTEX SEARCH SERVICES
-- ========================================================================
USE ROLE Energy_Intelligence_Demo;

-- Search service for energy documents
CREATE OR REPLACE CORTEX SEARCH SERVICE Search_energy_docs
    ON content
    ATTRIBUTES relative_path, file_url, title
    WAREHOUSE = ENERGY_INTELLIGENCE_DEMO_WH
    TARGET_LAG = '30 day'
    EMBEDDING_MODEL = 'snowflake-arctic-embed-l-v2.0'
    AS (
        SELECT
            relative_path,
            file_url,
            REGEXP_SUBSTR(relative_path, '[^/]+$') as title,
            content
        FROM parsed_content
        WHERE relative_path ILIKE '%/energy/%'
    );

-- Search service for product documents
CREATE OR REPLACE CORTEX SEARCH SERVICE Search_product_docs
    ON content
    ATTRIBUTES relative_path, file_url, title
    WAREHOUSE = ENERGY_INTELLIGENCE_DEMO_WH
    TARGET_LAG = '30 day'
    EMBEDDING_MODEL = 'snowflake-arctic-embed-l-v2.0'
    AS (
        SELECT
            relative_path,
            file_url,
            REGEXP_SUBSTR(relative_path, '[^/]+$') as title,
            content
        FROM parsed_content
        WHERE relative_path ILIKE '%/products/%'
    );

-- Search service for customer service documents
CREATE OR REPLACE CORTEX SEARCH SERVICE Search_service_docs
    ON content
    ATTRIBUTES relative_path, file_url, title
    WAREHOUSE = ENERGY_INTELLIGENCE_DEMO_WH
    TARGET_LAG = '30 day'
    EMBEDDING_MODEL = 'snowflake-arctic-embed-l-v2.0'
    AS (
        SELECT
            relative_path,
            file_url,
            REGEXP_SUBSTR(relative_path, '[^/]+$') as title,
            content
        FROM parsed_content
        WHERE relative_path ILIKE '%/service/%'
    );

-- Search service for service logs (structured data search)
CREATE OR REPLACE CORTEX SEARCH SERVICE Search_service_logs
    ON description
    ATTRIBUTES log_id, customer_key, topic, category, sentiment, priority
    WAREHOUSE = ENERGY_INTELLIGENCE_DEMO_WH
    TARGET_LAG = '1 day'
    EMBEDDING_MODEL = 'snowflake-arctic-embed-l-v2.0'
    AS (
        SELECT
            log_id,
            customer_key,
            topic,
            category,
            description,
            sentiment,
            priority
        FROM service_logs
    );

SHOW CORTEX SEARCH SERVICES;

-- ========================================================================
-- NETWORK AND EXTERNAL ACCESS
-- ========================================================================
USE ROLE Energy_Intelligence_Demo;

CREATE OR REPLACE NETWORK RULE Energy_Intelligence_WebAccessRule
    MODE = EGRESS
    TYPE = HOST_PORT
    VALUE_LIST = ('0.0.0.0:80', '0.0.0.0:443');

USE ROLE accountadmin;

GRANT ALL PRIVILEGES ON DATABASE ENERGY_AI_DEMO TO ROLE ACCOUNTADMIN;
GRANT ALL PRIVILEGES ON SCHEMA ENERGY_AI_DEMO.ENERGY_SCHEMA TO ROLE ACCOUNTADMIN;
GRANT USAGE ON NETWORK RULE ENERGY_AI_DEMO.ENERGY_SCHEMA.Energy_Intelligence_WebAccessRule TO ROLE accountadmin;

USE SCHEMA ENERGY_AI_DEMO.ENERGY_SCHEMA;

CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION Energy_Intelligence_ExternalAccess_Integration
    ALLOWED_NETWORK_RULES = (Energy_Intelligence_WebAccessRule)
    ENABLED = true;

GRANT USAGE ON INTEGRATION Energy_Intelligence_ExternalAccess_Integration TO ROLE Energy_Intelligence_Demo;

-- ========================================================================
-- HELPER FUNCTIONS AND PROCEDURES
-- ========================================================================
USE ROLE Energy_Intelligence_Demo;

-- Presigned URL procedure
CREATE OR REPLACE PROCEDURE Get_File_Presigned_URL_SP(
    RELATIVE_FILE_PATH STRING, 
    EXPIRATION_MINS INTEGER DEFAULT 60
)
RETURNS STRING
LANGUAGE SQL
COMMENT = 'Generates a presigned URL for files in ENERGY_STAGE'
EXECUTE AS CALLER
AS
$$
DECLARE
    presigned_url STRING;
    sql_stmt STRING;
    expiration_seconds INTEGER;
    stage_name STRING DEFAULT '@ENERGY_AI_DEMO.ENERGY_SCHEMA.ENERGY_STAGE';
BEGIN
    expiration_seconds := EXPIRATION_MINS * 60;
    sql_stmt := 'SELECT GET_PRESIGNED_URL(' || stage_name || ', ' || '''' || RELATIVE_FILE_PATH || '''' || ', ' || expiration_seconds || ') AS url';
    EXECUTE IMMEDIATE :sql_stmt;
    SELECT "URL" INTO :presigned_url FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));
    RETURN :presigned_url;
END;
$$;

-- Web scraping function
CREATE OR REPLACE FUNCTION Web_scrape(weburl STRING)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = 3.11
HANDLER = 'get_page'
EXTERNAL_ACCESS_INTEGRATIONS = (Energy_Intelligence_ExternalAccess_Integration)
PACKAGES = ('requests', 'beautifulsoup4')
AS
$$
import requests
from bs4 import BeautifulSoup

def get_page(weburl):
    response = requests.get(weburl)
    soup = BeautifulSoup(response.text)
    return soup.get_text()
$$;

-- ========================================================================
-- SNOWFLAKE INTELLIGENCE AGENT
-- ========================================================================
USE ROLE Energy_Intelligence_Demo;

CREATE OR REPLACE AGENT ENERGY_AI_DEMO.ENERGY_SCHEMA.Energy_Chatbot_Agent
WITH PROFILE='{ "display_name": "EPOWER Energy Intelligence Agent" }'
COMMENT=$$ Agent for energy retail analysis: contracts, consumption, service tickets, and documents. $$
FROM SPECIFICATION $$
{
  "models": {
    "orchestration": ""
  },
  "instructions": {
    "response": "Du bist ein Datenanalyst für EPOWER Energie Deutschland. Du hast Zugriff auf Energie-Vertriebsdaten (Strom, Gas, Solar, Wärmepumpen, Smart Home, E-Mobility), Verbrauchsabrechnungen, Kundenservice-Tickets und interne Dokumente. Antworte auf Deutsch, wenn der Nutzer auf Deutsch fragt. Liefere Visualisierungen wenn möglich.",
    "orchestration": "Nutze Cortex Search für Dokumente und Cortex Analyst für strukturierte Datenanalysen. Bei Fragen zu Verbrauch, nutze das Billing Datamart. Bei Fragen zu Service-Tickets oder Beschwerden, nutze das Service Datamart. Bei Produktfragen, nutze das Energy Sales Datamart.",
    "sample_questions": [
      {"question": "Was ist der durchschnittliche Stromverbrauch für Kunden mit Wärmepumpen in Hamburg?"},
      {"question": "Zeige mir alle negativen Service-Tickets zum Thema Smart Meter."},
      {"question": "Welche Produkte wurden letzten Monat am meisten verkauft?"}
    ]
  },
  "tools": [
    {
      "tool_spec": {
        "type": "cortex_analyst_text_to_sql",
        "name": "Query Energy Sales",
        "description": "Analysiert Energieverträge, Produkte (Strom, Gas, Solar, Wärmepumpen), Kunden und Regionen."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_analyst_text_to_sql",
        "name": "Query Billing Data",
        "description": "Analysiert Energieverbrauch (kWh), Abrechnungen und Zahlungsstatus für Strom und Gas."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_analyst_text_to_sql",
        "name": "Query Service Tickets",
        "description": "Analysiert Kundenservice-Tickets, Beschwerden, Sentiment und Themen wie Smart Meter, Wärmepumpe, Solar."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_analyst_text_to_sql",
        "name": "Query HR Data",
        "description": "Analysiert HR-Daten: Mitarbeiter, Gehälter, Fluktuation, Abteilungen."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_search",
        "name": "Search Energy Documents",
        "description": "Sucht in Energiedokumenten: AGBs, Förderungen, Richtlinien."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_search",
        "name": "Search Product Documents",
        "description": "Sucht in Produktdokumenten: Wärmepumpen-Guide, Solar-Anleitungen, Smart Meter, E-Mobility."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_search",
        "name": "Search Service Documents",
        "description": "Sucht in Service-Dokumenten: Rechnungserklärungen, Energiespar-Tipps, Kundenservice-Handbuch."
      }
    },
    {
      "tool_spec": {
        "type": "cortex_search",
        "name": "Search Service Logs",
        "description": "Semantische Suche in Service-Tickets nach Beschreibungen und Themen."
      }
    },
    {
      "tool_spec": {
        "type": "generic",
        "name": "Web_scraper",
        "description": "Analysiert Inhalte von Webseiten (z.B. für aktuelle Energiepreise, Förderprogramme).",
        "input_schema": {
          "type": "object",
          "properties": {
            "weburl": {"description": "URL der Webseite", "type": "string"}
          },
          "required": ["weburl"]
        }
      }
    },
    {
      "tool_spec": {
        "type": "generic",
        "name": "Dynamic_Doc_URL_Tool",
        "description": "Generiert Download-URLs für Dokumente aus dem Stage.",
        "input_schema": {
          "type": "object",
          "properties": {
            "expiration_mins": {"description": "Gültigkeit in Minuten (Standard: 5)", "type": "number"},
            "relative_file_path": {"description": "Relativer Pfad zur Datei", "type": "string"}
          },
          "required": ["relative_file_path"]
        }
      }
    }
  ],
  "tool_resources": {
    "Query Energy Sales": {
      "semantic_view": "ENERGY_AI_DEMO.ENERGY_SCHEMA.ENERGY_SALES_SEMANTIC_VIEW"
    },
    "Query Billing Data": {
      "semantic_view": "ENERGY_AI_DEMO.ENERGY_SCHEMA.BILLING_SEMANTIC_VIEW"
    },
    "Query Service Tickets": {
      "semantic_view": "ENERGY_AI_DEMO.ENERGY_SCHEMA.SERVICE_SEMANTIC_VIEW"
    },
    "Query HR Data": {
      "semantic_view": "ENERGY_AI_DEMO.ENERGY_SCHEMA.HR_SEMANTIC_VIEW"
    },
    "Search Energy Documents": {
      "id_column": "RELATIVE_PATH",
      "max_results": 5,
      "name": "ENERGY_AI_DEMO.ENERGY_SCHEMA.SEARCH_ENERGY_DOCS",
      "title_column": "TITLE"
    },
    "Search Product Documents": {
      "id_column": "RELATIVE_PATH",
      "max_results": 5,
      "name": "ENERGY_AI_DEMO.ENERGY_SCHEMA.SEARCH_PRODUCT_DOCS",
      "title_column": "TITLE"
    },
    "Search Service Documents": {
      "id_column": "RELATIVE_PATH",
      "max_results": 5,
      "name": "ENERGY_AI_DEMO.ENERGY_SCHEMA.SEARCH_SERVICE_DOCS",
      "title_column": "TITLE"
    },
    "Search Service Logs": {
      "id_column": "LOG_ID",
      "max_results": 10,
      "name": "ENERGY_AI_DEMO.ENERGY_SCHEMA.SEARCH_SERVICE_LOGS",
      "title_column": "TOPIC"
    },
    "Web_scraper": {
      "execution_environment": {
        "type": "warehouse",
        "warehouse": "ENERGY_INTELLIGENCE_DEMO_WH"
      },
      "identifier": "ENERGY_AI_DEMO.ENERGY_SCHEMA.WEB_SCRAPE",
      "name": "WEB_SCRAPE(VARCHAR)",
      "type": "function"
    },
    "Dynamic_Doc_URL_Tool": {
      "execution_environment": {
        "type": "warehouse",
        "warehouse": "ENERGY_INTELLIGENCE_DEMO_WH"
      },
      "identifier": "ENERGY_AI_DEMO.ENERGY_SCHEMA.GET_FILE_PRESIGNED_URL_SP",
      "name": "GET_FILE_PRESIGNED_URL_SP(VARCHAR, DEFAULT NUMBER)",
      "type": "procedure"
    }
  }
}
$$;

-- ========================================================================
-- ASSIGN AGENT TO SNOWFLAKE INTELLIGENCE
-- ========================================================================
USE ROLE accountadmin;

ALTER SNOWFLAKE INTELLIGENCE snowflake_intelligence_object_default ADD AGENT ENERGY_AI_DEMO.ENERGY_SCHEMA.Energy_Chatbot_Agent;
GRANT USAGE ON AGENT ENERGY_AI_DEMO.ENERGY_SCHEMA.Energy_Chatbot_Agent TO ROLE PUBLIC;
GRANT USAGE ON AGENT ENERGY_AI_DEMO.ENERGY_SCHEMA.Energy_Chatbot_Agent TO ROLE Energy_Intelligence_Demo;

USE ROLE Energy_Intelligence_Demo;

-- ========================================================================
-- SETUP COMPLETE
-- ========================================================================
SELECT '✅ Energy AI Demo Setup Complete!' as status;
SELECT 'Database: ENERGY_AI_DEMO.ENERGY_SCHEMA' as info;
SELECT 'Agent: Energy_Chatbot_Agent' as info;
SELECT 'Semantic Views: 4 (Energy Sales, Billing, Service, HR)' as info;
SELECT 'Cortex Search: 4 services (Energy, Product, Service docs + Service logs)' as info;
