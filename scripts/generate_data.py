#!/usr/bin/env python3
"""
Energy Retail Demo - Synthetic Data Generator
Generates realistic German energy retail data for Snowflake AI Demo

Version 2.0 - Enhanced with:
- 20,000 customers (up from 1,000)
- customer_products table for product ownership tracking
- Realistic consumption patterns linked to products
"""

import pandas as pd
import numpy as np
from faker import Faker
import random
from datetime import datetime, timedelta
import os

fake = Faker('de_DE')
Faker.seed(42)
np.random.seed(42)
random.seed(42)

OUTPUT_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'demo_data')
os.makedirs(OUTPUT_DIR, exist_ok=True)

NUM_CUSTOMERS = 20000
NUM_CONTRACTS = 240000
NUM_SERVICE_LOGS = 100000

GERMAN_CITIES = {
    'North': [
        ('Hamburg', '20', 1850000),
        ('Bremen', '28', 570000),
        ('Kiel', '24', 250000),
        ('Lübeck', '23', 220000),
        ('Hannover', '30', 535000),
        ('Rostock', '18', 210000),
        ('Oldenburg', '26', 170000),
        ('Osnabrück', '49', 165000),
        ('Braunschweig', '38', 250000),
        ('Wolfsburg', '38', 125000),
    ],
    'South': [
        ('München', '80', 1490000),
        ('Stuttgart', '70', 635000),
        ('Nürnberg', '90', 520000),
        ('Augsburg', '86', 300000),
        ('Freiburg', '79', 230000),
        ('Ulm', '89', 130000),
        ('Regensburg', '93', 155000),
        ('Würzburg', '97', 130000),
        ('Ingolstadt', '85', 140000),
        ('Karlsruhe', '76', 310000),
    ],
    'West': [
        ('Köln', '50', 1080000),
        ('Düsseldorf', '40', 620000),
        ('Dortmund', '44', 590000),
        ('Essen', '45', 580000),
        ('Duisburg', '47', 500000),
        ('Bonn', '53', 330000),
        ('Wuppertal', '42', 355000),
        ('Bochum', '44', 365000),
        ('Münster', '48', 315000),
        ('Aachen', '52', 250000),
    ],
    'East': [
        ('Berlin', '10', 3650000),
        ('Dresden', '01', 560000),
        ('Leipzig', '04', 600000),
        ('Potsdam', '14', 180000),
        ('Magdeburg', '39', 240000),
        ('Chemnitz', '09', 245000),
        ('Halle', '06', 240000),
        ('Erfurt', '99', 215000),
        ('Jena', '07', 110000),
        ('Cottbus', '03', 100000),
    ]
}

def get_city_weights(region):
    cities = GERMAN_CITIES[region]
    populations = [c[2] for c in cities]
    total = sum(populations)
    return [p / total for p in populations]

def generate_german_zip(city_prefix):
    return f"{city_prefix}{random.randint(100, 999)}"

def generate_german_street():
    street_types = ['Straße', 'Weg', 'Allee', 'Platz', 'Ring', 'Gasse']
    street_names = [
        'Haupt', 'Bahnhof', 'Goethe', 'Schiller', 'Mozart', 'Beethoven',
        'Linden', 'Eichen', 'Birken', 'Rosen', 'Tannen', 'Kirch',
        'Markt', 'Rathaus', 'Schul', 'Park', 'Wald', 'Berg', 'Tal', 'See',
        'Sonnen', 'Mond', 'Stern', 'Blumen', 'Wiesen', 'Heide', 'Brunnen'
    ]
    return f"{random.choice(street_names)}{random.choice(street_types)} {random.randint(1, 150)}"

print("=" * 60)
print("EPOWER Energy Retail Demo - Data Generator v2.0")
print("=" * 60)
print(f"Generating data for {NUM_CUSTOMERS:,} customers...")
print()

print("1. Generating product_category_dim...")
product_categories = pd.DataFrame({
    'category_key': [1, 2, 3, 4, 5, 6],
    'category_name': ['Electricity', 'Gas', 'Solar', 'Heat Pumps', 'Smart Home', 'E-Mobility'],
    'vertical': ['Energy', 'Energy', 'Future Energy', 'Future Energy', 'Smart Home', 'E-Mobility']
})
product_categories.to_csv(f'{OUTPUT_DIR}/product_category_dim.csv', index=False)

print("2. Generating product_dim...")
products = [
    (1, 'EPOWER Strom Basis', 1, 'Electricity', 'Energy'),
    (2, 'EPOWER Strom Plus', 1, 'Electricity', 'Energy'),
    (3, 'EPOWER Ökostrom 100%', 1, 'Electricity', 'Energy'),
    (4, 'EPOWER Strom Fix 24', 1, 'Electricity', 'Energy'),
    (5, 'EPOWER Wärmestrom', 1, 'Electricity', 'Energy'),
    (6, 'EPOWER Gas Basis', 2, 'Gas', 'Energy'),
    (7, 'EPOWER Gas Plus', 2, 'Gas', 'Energy'),
    (8, 'EPOWER Biogas 10%', 2, 'Gas', 'Energy'),
    (9, 'EPOWER Gas Fix 24', 2, 'Gas', 'Energy'),
    (10, 'EPOWER Solar S 5kWp', 3, 'Solar', 'Future Energy'),
    (11, 'EPOWER Solar M 8kWp', 3, 'Solar', 'Future Energy'),
    (12, 'EPOWER Solar L 12kWp', 3, 'Solar', 'Future Energy'),
    (13, 'EPOWER SolarCloud', 3, 'Solar', 'Future Energy'),
    (14, 'EPOWER Speicher 5kWh', 3, 'Solar', 'Future Energy'),
    (15, 'EPOWER Speicher 10kWh', 3, 'Solar', 'Future Energy'),
    (16, 'EPOWER Wärmepumpe Luft-Wasser', 4, 'Heat Pumps', 'Future Energy'),
    (17, 'EPOWER Wärmepumpe Sole-Wasser', 4, 'Heat Pumps', 'Future Energy'),
    (18, 'EPOWER Wärmepumpe Split', 4, 'Heat Pumps', 'Future Energy'),
    (19, 'EPOWER Wärmepumpe Kompakt', 4, 'Heat Pumps', 'Future Energy'),
    (20, 'EPOWER Smart Meter', 5, 'Smart Home', 'Smart Home'),
    (21, 'EPOWER Home Energy Manager', 5, 'Smart Home', 'Smart Home'),
    (22, 'EPOWER Smart Thermostat', 5, 'Smart Home', 'Smart Home'),
    (23, 'EPOWER Energy Monitor', 5, 'Smart Home', 'Smart Home'),
    (24, 'EPOWER Wallbox 11kW', 6, 'E-Mobility', 'E-Mobility'),
    (25, 'EPOWER Wallbox 22kW', 6, 'E-Mobility', 'E-Mobility'),
    (26, 'EPOWER Drive Tarif', 6, 'E-Mobility', 'E-Mobility'),
    (27, 'EPOWER Solar Carport', 6, 'E-Mobility', 'E-Mobility'),
]
product_dim = pd.DataFrame(products, columns=['product_key', 'product_name', 'category_key', 'category_name', 'vertical'])
product_dim.to_csv(f'{OUTPUT_DIR}/product_dim.csv', index=False)

print("3. Generating region_dim...")
region_dim = pd.DataFrame({
    'region_key': [400, 401, 402, 403],
    'region_name': ['North', 'South', 'West', 'East']
})
region_dim.to_csv(f'{OUTPUT_DIR}/region_dim.csv', index=False)

print("4. Generating location_dim...")
locations = []
loc_key = 900
for region, cities in GERMAN_CITIES.items():
    for city, _, _ in cities[:3]:
        locations.append((loc_key, f"{city}, DE"))
        loc_key += 1
location_dim = pd.DataFrame(locations, columns=['location_key', 'location_name'])
location_dim.to_csv(f'{OUTPUT_DIR}/location_dim.csv', index=False)

print("5. Generating department_dim...")
departments = [
    (10, 'Finanzen'), (11, 'Buchhaltung'), (12, 'Controlling'), (13, 'Steuern'),
    (14, 'Revision'), (15, 'Treasury'), (16, 'Einkauf'), (17, 'Recht'),
    (18, 'Compliance'), (19, 'Risikomanagement'), (20, 'Vertrieb Privatkunden'),
    (21, 'Vertrieb Gewerbekunden'), (22, 'Kundenservice'), (23, 'Vertriebssteuerung'),
    (24, 'Partnermanagement'), (25, 'Technischer Vertrieb'), (26, 'Key Account Management'),
    (27, 'Innendienst'), (28, 'Außendienst'), (29, 'Vertriebssupport'),
    (30, 'Marketing'), (31, 'Digital Marketing'), (32, 'Content Marketing'),
    (33, 'Produktmarketing'), (34, 'Markenführung'), (35, 'Event Marketing'),
    (36, 'Marktforschung'), (37, 'Unternehmenskommunikation'), (38, 'Social Media'),
    (39, 'Marketing Operations'), (40, 'Personal'),
]
department_dim = pd.DataFrame(departments, columns=['department_key', 'department_name'])
department_dim.to_csv(f'{OUTPUT_DIR}/department_dim.csv', index=False)

print("6. Generating job_dim...")
jobs = [
    (800, 'Ingenieur', 3), (801, 'Personalleiter', 4), (802, 'Datenanalyst', 2),
    (803, 'Recruiter', 2), (804, 'Finanzspezialist', 3), (805, 'Vertriebsleiter', 4),
    (806, 'Marketing Koordinator', 2), (807, 'Betriebsleiter', 3),
    (808, 'Service-Mitarbeiter', 1), (809, 'IT-Administrator', 2),
    (810, 'Energieberater', 2), (811, 'Techniker Außendienst', 2),
    (812, 'Kundenberater', 1), (813, 'Installateur Solar', 2),
    (814, 'Installateur Wärmepumpe', 2), (815, 'Smart Home Spezialist', 3),
]
job_dim = pd.DataFrame(jobs, columns=['job_key', 'job_title', 'job_level'])
job_dim.to_csv(f'{OUTPUT_DIR}/job_dim.csv', index=False)

print("7. Generating channel_dim...")
channel_dim = pd.DataFrame({
    'channel_key': [600, 601, 602, 603, 604, 605],
    'channel_name': ['Email', 'Webseite', 'Facebook', 'Instagram', 'Google Ads', 'TV']
})
channel_dim.to_csv(f'{OUTPUT_DIR}/channel_dim.csv', index=False)

print("8. Generating account_dim...")
account_dim = pd.DataFrame({
    'account_key': [1, 2, 3],
    'account_name': ['Umsatz', 'Aufwand', 'Wareneinsatz'],
    'account_type': ['Einnahmen', 'Ausgaben', 'Ausgaben']
})
account_dim.to_csv(f'{OUTPUT_DIR}/account_dim.csv', index=False)

print(f"9. Generating customer_dim ({NUM_CUSTOMERS:,} German customers)...")
region_keys = {'North': 400, 'South': 401, 'West': 402, 'East': 403}
region_weights = [0.22, 0.28, 0.30, 0.20]
customer_types = ['Privatkunde', 'Kleingewerbe', 'Gewerbekunde']
housing_types_private = ['Einfamilienhaus', 'Reihenhaus', 'Wohnung', 'Mehrfamilienhaus']
housing_types_business = ['Gewerbeimmobilie']

customers = []
for i in range(1, NUM_CUSTOMERS + 1):
    region = random.choices(list(GERMAN_CITIES.keys()), weights=region_weights)[0]
    cities = GERMAN_CITIES[region]
    city_idx = random.choices(range(len(cities)), weights=get_city_weights(region))[0]
    city, zip_prefix, _ = cities[city_idx]
    
    customer_type = random.choices(customer_types, weights=[0.75, 0.18, 0.07])[0]
    if customer_type == 'Gewerbekunde':
        housing = 'Gewerbeimmobilie'
    elif customer_type == 'Kleingewerbe':
        housing = random.choices(housing_types_private + housing_types_business, weights=[0.3, 0.2, 0.2, 0.1, 0.2])[0]
    else:
        housing = random.choices(housing_types_private, weights=[0.35, 0.20, 0.35, 0.10])[0]
    
    name = fake.company() if customer_type in ['Gewerbekunde', 'Kleingewerbe'] and random.random() > 0.3 else fake.name()
    
    customers.append({
        'customer_key': i,
        'customer_name': name,
        'customer_type': customer_type,
        'housing_type': housing,
        'vertical': 'Energy',
        'address': generate_german_street(),
        'city': city,
        'state': region,
        'zip': generate_german_zip(zip_prefix),
        'region_key': region_keys[region]
    })
customer_dim = pd.DataFrame(customers)
customer_dim.to_csv(f'{OUTPUT_DIR}/customer_dim.csv', index=False)

print("10. Generating vendor_dim...")
vendor_types = [
    ('Installateur', 'Future Energy'), ('Wartungspartner', 'Future Energy'),
    ('Smart Home Partner', 'Smart Home'), ('E-Mobility Partner', 'E-Mobility'),
    ('Lieferant', 'Energy'),
]
vendors = []
for i in range(1, 201):
    region = random.choice(list(GERMAN_CITIES.keys()))
    cities = GERMAN_CITIES[region]
    city, zip_prefix, _ = random.choice(cities)
    vtype, vertical = random.choice(vendor_types)
    vendor_suffixes = ['GmbH', 'AG', 'KG', 'e.K.', 'UG']
    vendor_names = ['Solar', 'Energie', 'Wärme', 'Klima', 'Haustechnik', 'Elektro', 'Power', 'Green', 'Eco', 'Smart', 'Tech', 'Service']
    vendor_name = f"{fake.last_name()} {random.choice(vendor_names)} {random.choice(vendor_suffixes)}"
    
    vendors.append({
        'vendor_key': i, 'vendor_name': vendor_name, 'vendor_type': vtype, 'vertical': vertical,
        'address': generate_german_street(), 'city': city, 'state': region, 'zip': generate_german_zip(zip_prefix)
    })
vendor_dim = pd.DataFrame(vendors)
vendor_dim.to_csv(f'{OUTPUT_DIR}/vendor_dim.csv', index=False)

print("11. Generating employee_dim...")
employees = []
for i in range(1, 1001):
    hire_date = fake.date_between(start_date='-10y', end_date='-6m')
    employees.append({'employee_key': i, 'employee_name': fake.name(), 'gender': random.choice(['M', 'F']), 'hire_date': hire_date.strftime('%Y-%m-%d')})
employee_dim = pd.DataFrame(employees)
employee_dim.to_csv(f'{OUTPUT_DIR}/employee_dim.csv', index=False)

print("12. Generating sales_rep_dim...")
sales_reps = []
for i in range(1, 501):
    hire_date = fake.date_between(start_date='-8y', end_date='-3m')
    sales_reps.append({'sales_rep_key': i, 'rep_name': fake.name(), 'hire_date': hire_date.strftime('%Y-%m-%d')})
sales_rep_dim = pd.DataFrame(sales_reps)
sales_rep_dim.to_csv(f'{OUTPUT_DIR}/sales_rep_dim.csv', index=False)

print("13. Generating campaign_dim...")
campaign_names = [
    ('Grüner Strom Aktion', 'Neukundengewinnung'), ('Wärmepumpen Förderung 2024', 'Produktlaunch'),
    ('Solar Frühlings-Rabatt', 'Upsell'), ('Smart Home Einführungsangebot', 'Produktlaunch'),
    ('E-Mobility Bonus', 'Neukundengewinnung'), ('Ökostrom für alle', 'Markenbekanntheit'),
    ('Wintercheck Heizung', 'Kundenbindung'), ('Energiespar-Challenge', 'Engagement'),
    ('Nachbarschafts-Empfehlung', 'Empfehlung'), ('Business Energy Paket', 'Lead-Generierung'),
]
campaigns = []
for i, (name, objective) in enumerate(campaign_names, 1):
    campaigns.append({'campaign_key': i, 'campaign_name': name, 'objective': objective})
for i in range(11, 101):
    campaigns.append({'campaign_key': i, 'campaign_name': f"Energie Kampagne {i}", 'objective': random.choice(['Neukundengewinnung', 'Kundenbindung', 'Upsell', 'Lead-Generierung'])})
campaign_dim = pd.DataFrame(campaigns)
campaign_dim.to_csv(f'{OUTPUT_DIR}/campaign_dim.csv', index=False)

print(f"14. Generating sales_fact ({NUM_CONTRACTS:,} contracts)...")
electricity_products, gas_products = [1,2,3,4,5], [6,7,8,9]
solar_products, heatpump_products = [10,11,12,13,14,15], [16,17,18,19]
smarthome_products, emobility_products = [20,21,22,23], [24,25,26,27]

contracts = []
start_date, end_date = datetime(2022, 1, 1), datetime(2025, 12, 31)
for contract_id in range(1, NUM_CONTRACTS + 1):
    contract_date = fake.date_between(start_date=start_date, end_date=end_date)
    customer_key = random.randint(1, NUM_CUSTOMERS)
    customer = customer_dim[customer_dim['customer_key'] == customer_key].iloc[0]
    region_key = customer['region_key']
    housing = customer['housing_type']
    
    if housing == 'Einfamilienhaus':
        product_weights = [0.30, 0.20, 0.18, 0.15, 0.10, 0.07]
    elif housing == 'Gewerbeimmobilie':
        product_weights = [0.40, 0.25, 0.12, 0.08, 0.08, 0.07]
    else:
        product_weights = [0.38, 0.28, 0.12, 0.08, 0.08, 0.06]
    
    product_type = random.choices(['electricity', 'gas', 'solar', 'heatpump', 'smarthome', 'emobility'], weights=product_weights)[0]
    
    if product_type == 'electricity':
        product_key, amount, units = random.choice(electricity_products), random.uniform(600, 2400), random.randint(2000, 6000)
    elif product_type == 'gas':
        product_key, amount, units = random.choice(gas_products), random.uniform(800, 3000), random.randint(10000, 25000)
    elif product_type == 'solar':
        product_key, amount, units = random.choice(solar_products), random.uniform(8000, 35000), random.randint(5, 15)
    elif product_type == 'heatpump':
        product_key, amount, units = random.choice(heatpump_products), random.uniform(15000, 45000), 1
    elif product_type == 'smarthome':
        product_key, amount, units = random.choice(smarthome_products), random.uniform(200, 800), 1
    else:
        product_key, amount, units = random.choice(emobility_products), random.uniform(1500, 5000), 1
    
    contracts.append({
        'sale_id': contract_id, 'date': contract_date.strftime('%Y-%m-%d'), 'customer_key': customer_key,
        'product_key': product_key, 'sales_rep_key': random.randint(1, 500), 'region_key': region_key,
        'vendor_key': random.randint(1, 200), 'amount': round(amount, 2), 'units': units
    })
sales_fact = pd.DataFrame(contracts)
sales_fact.to_csv(f'{OUTPUT_DIR}/sales_fact.csv', index=False)

print("15. Generating customer_products (product ownership tracking)...")
customer_products = []
cp_id = 1

customer_product_map = {}

for _, contract in sales_fact.iterrows():
    customer_key = contract['customer_key']
    product_key = contract['product_key']
    contract_date = contract['date']
    
    if customer_key not in customer_product_map:
        customer_product_map[customer_key] = set()
    
    if product_key not in customer_product_map[customer_key]:
        customer_product_map[customer_key].add(product_key)
        product_info = product_dim[product_dim['product_key'] == product_key].iloc[0]
        
        customer_products.append({
            'customer_product_id': cp_id,
            'customer_key': customer_key,
            'product_key': product_key,
            'category_key': product_info['category_key'],
            'category_name': product_info['category_name'],
            'acquisition_date': contract_date,
            'status': random.choices(['Active', 'Inactive'], weights=[0.95, 0.05])[0]
        })
        cp_id += 1

customer_products_df = pd.DataFrame(customer_products)
customer_products_df.to_csv(f'{OUTPUT_DIR}/customer_products.csv', index=False)

customers_with_heatpumps = set(customer_products_df[customer_products_df['category_name'] == 'Heat Pumps']['customer_key'].unique())
customers_with_solar = set(customer_products_df[customer_products_df['category_name'] == 'Solar']['customer_key'].unique())
customers_with_emobility = set(customer_products_df[customer_products_df['category_name'] == 'E-Mobility']['customer_key'].unique())

print(f"   - Customers with Heat Pumps: {len(customers_with_heatpumps):,}")
print(f"   - Customers with Solar: {len(customers_with_solar):,}")
print(f"   - Customers with E-Mobility: {len(customers_with_emobility):,}")

print("16. Generating billing_history (with realistic consumption based on products)...")
billing = []
bill_id = 1

billing_customers = list(range(1, min(NUM_CUSTOMERS + 1, 10001)))

for customer_key in billing_customers:
    customer = customer_dim[customer_dim['customer_key'] == customer_key].iloc[0]
    housing = customer['housing_type']
    
    base_kwh_e = {'Einfamilienhaus': 4200, 'Reihenhaus': 3200, 'Wohnung': 2000, 'Mehrfamilienhaus': 2800, 'Gewerbeimmobilie': 12000}.get(housing, 3000)
    base_kwh_g = {'Einfamilienhaus': 16000, 'Reihenhaus': 12000, 'Wohnung': 6000, 'Mehrfamilienhaus': 10000, 'Gewerbeimmobilie': 30000}.get(housing, 15000)
    
    has_heatpump = customer_key in customers_with_heatpumps
    has_solar = customer_key in customers_with_solar
    has_emobility = customer_key in customers_with_emobility
    
    if has_heatpump:
        base_kwh_e += random.randint(3500, 5500)
        base_kwh_g = int(base_kwh_g * 0.2)
    
    if has_emobility:
        base_kwh_e += random.randint(2000, 3500)
    
    if has_solar:
        base_kwh_e = int(base_kwh_e * random.uniform(0.5, 0.7))
    
    for year in [2023, 2024, 2025]:
        for month in range(1, 13):
            if year == 2025 and month > 6:
                continue
            
            seasonal_e = {1: 1.3, 2: 1.3, 3: 1.1, 11: 1.2, 12: 1.4, 6: 0.75, 7: 0.7, 8: 0.7}.get(month, 1.0)
            seasonal_g = {1: 1.8, 2: 1.7, 3: 1.4, 4: 0.8, 5: 0.4, 6: 0.2, 7: 0.15, 8: 0.15, 9: 0.3, 10: 0.7, 11: 1.3, 12: 1.6}.get(month, 1.0)
            
            kwh_e = int(base_kwh_e / 12 * seasonal_e * random.uniform(0.85, 1.15))
            kwh_g = int(base_kwh_g / 12 * seasonal_g * random.uniform(0.80, 1.20))
            
            billing.append({
                'billing_id': bill_id, 
                'customer_key': customer_key, 
                'billing_date': f"{year}-{month:02d}-15",
                'billing_type': 'Electricity', 
                'consumption_kwh': kwh_e, 
                'amount': round(kwh_e * random.uniform(0.30, 0.40) + 12.50, 2),
                'payment_status': random.choices(['Bezahlt', 'Offen', 'Überfällig'], weights=[0.88, 0.08, 0.04])[0]
            })
            bill_id += 1
            
            if not has_heatpump or random.random() < 0.3:
                if kwh_g > 50:
                    billing.append({
                        'billing_id': bill_id, 
                        'customer_key': customer_key, 
                        'billing_date': f"{year}-{month:02d}-15",
                        'billing_type': 'Gas', 
                        'consumption_kwh': kwh_g, 
                        'amount': round(kwh_g * random.uniform(0.09, 0.13) + 8.90, 2),
                        'payment_status': random.choices(['Bezahlt', 'Offen', 'Überfällig'], weights=[0.88, 0.08, 0.04])[0]
                    })
                    bill_id += 1

billing_history = pd.DataFrame(billing)
billing_history.to_csv(f'{OUTPUT_DIR}/billing_history.csv', index=False)

print(f"17. Generating service_logs ({NUM_SERVICE_LOGS:,} tickets)...")
ticket_types = [
    ('Smart Meter', 'Installation', ['Smart Meter Installation angefragt', 'Smart Meter defekt', 'Smart Meter Ablesung fehlerhaft', 'Smart Meter zeigt keine Daten', 'Smart Meter App funktioniert nicht']),
    ('Rechnung', 'Abrechnung', ['Rechnungsfrage', 'Unstimmigkeit in Rechnung', 'Zahlungsplan angefragt', 'Abschlag zu hoch', 'Abschlag anpassen', 'Gutschrift angefragt']),
    ('Wärmepumpe', 'Technisch', ['Wärmepumpe Störung', 'Wartung angefragt', 'Effizienz zu niedrig', 'Wärmepumpe läuft nicht', 'Geräuschentwicklung zu hoch', 'Fehlercode E01 angezeigt']),
    ('Solar', 'Technisch', ['Solaranlage Ertrag niedrig', 'Wechselrichter Fehler', 'Monitoring nicht verfügbar', 'Solaranlage produziert nicht', 'Einspeisevergütung Frage']),
    ('Tarif', 'Vertrag', ['Tarifwechsel angefragt', 'Kündigung', 'Umzug melden', 'Vertragsverlängerung', 'Preisgarantie Frage', 'Ökostrom Umstellung']),
    ('Wallbox', 'E-Mobility', ['Wallbox Installation angefragt', 'Wallbox defekt', 'Ladekarte Probleme', 'Wallbox lädt nicht', 'App-Verbindung unterbrochen']),
    ('Allgemein', 'Service', ['Allgemeine Anfrage', 'Beschwerde', 'Lob', 'Informationsanfrage', 'Kontaktdaten ändern']),
    ('Speicher', 'Technisch', ['Batteriespeicher Störung', 'Speicher lädt nicht', 'Kapazität gesunken']),
]
sentiments, priorities = ['Positiv', 'Neutral', 'Negativ'], ['Niedrig', 'Mittel', 'Hoch', 'Kritisch']

service_logs = []
for log_id in range(1, NUM_SERVICE_LOGS + 1):
    log_date = fake.date_between(start_date=datetime(2023, 1, 1), end_date=datetime(2025, 6, 30))
    topic, category, descriptions = random.choice(ticket_types)
    description = random.choice(descriptions)
    
    if 'defekt' in description or 'Störung' in description or 'Beschwerde' in description or 'nicht' in description:
        sentiment = 'Negativ'
        priority = random.choices(priorities, weights=[0.1, 0.3, 0.4, 0.2])[0]
    elif 'Lob' in description:
        sentiment = 'Positiv'
        priority = 'Niedrig'
    else:
        sentiment = random.choices(sentiments, weights=[0.15, 0.65, 0.20])[0]
        priority = random.choices(priorities, weights=[0.3, 0.5, 0.15, 0.05])[0]
    
    resolution_days = random.randint(0, 14) if priority in ['Niedrig', 'Mittel'] else random.randint(0, 7)
    
    service_logs.append({
        'log_id': log_id, 
        'customer_key': random.randint(1, NUM_CUSTOMERS), 
        'log_date': log_date.strftime('%Y-%m-%d'),
        'topic': topic, 
        'category': category, 
        'description': description, 
        'sentiment': sentiment,
        'channel': random.choice(['Telefon', 'Email', 'Chat', 'App']), 
        'priority': priority,
        'resolution_date': (log_date + timedelta(days=resolution_days)).strftime('%Y-%m-%d'), 
        'agent_key': random.randint(1, 200)
    })
service_logs_df = pd.DataFrame(service_logs)
service_logs_df.to_csv(f'{OUTPUT_DIR}/service_logs.csv', index=False)

print("18. Generating finance_transactions...")
finance_transactions = []
for txn_id in range(1, 30001):
    txn_date = fake.date_between(start_date=datetime(2022, 1, 1), end_date=datetime(2025, 6, 30))
    account_key = random.choices([1, 2, 3], weights=[0.4, 0.4, 0.2])[0]
    amount = round(random.uniform(50, 5000) if account_key == 1 else random.uniform(10, 2000), 2)
    approval_status = random.choices(['Approved', 'Pending', 'Rejected'], weights=[0.85, 0.10, 0.05])[0]
    
    finance_transactions.append({
        'transaction_id': txn_id, 'date': txn_date.strftime('%Y-%m-%d'), 'account_key': account_key,
        'department_key': random.randint(10, 40), 'vendor_key': random.randint(1, 200),
        'product_key': random.randint(1, 27), 'customer_key': random.randint(1, NUM_CUSTOMERS),
        'amount': amount, 'approval_status': approval_status,
        'procurement_method': random.choice(['Vertrag', 'Ausschreibung', 'Direktvergabe']),
        'approver_id': random.randint(1, 1000) if approval_status != 'Pending' else '',
        'approval_date': (txn_date + timedelta(days=random.randint(1, 7))).strftime('%Y-%m-%d') if approval_status != 'Pending' else '',
        'purchase_order_number': f"PO-{random.randint(100000, 999999)}" if random.random() > 0.3 else '',
        'contract_reference': f"VTR-{random.randint(2020, 2025)}-{random.randint(1000, 9999)}" if random.random() > 0.4 else ''
    })
finance_df = pd.DataFrame(finance_transactions)
finance_df.to_csv(f'{OUTPUT_DIR}/finance_transactions.csv', index=False)

print("19. Generating marketing_campaign_fact...")
marketing_facts = []
for fact_id in range(1, 16001):
    fact_date = fake.date_between(start_date=datetime(2022, 1, 1), end_date=datetime(2025, 6, 30))
    marketing_facts.append({
        'campaign_fact_id': fact_id, 'date': fact_date.strftime('%Y-%m-%d'),
        'campaign_key': random.randint(1, 100), 'product_key': random.randint(1, 27),
        'channel_key': random.choice([600, 601, 602, 603, 604, 605]), 'region_key': random.choice([400, 401, 402, 403]),
        'spend': round(random.uniform(50, 500), 2), 'leads_generated': random.randint(5, 100), 'impressions': random.randint(100, 15000)
    })
marketing_df = pd.DataFrame(marketing_facts)
marketing_df.to_csv(f'{OUTPUT_DIR}/marketing_campaign_fact.csv', index=False)

print("20. Generating hr_employee_fact...")
hr_facts = []
hr_id = 1
for emp_key in range(1, 1001):
    emp = employee_dim[employee_dim['employee_key'] == emp_key].iloc[0]
    hire_date = datetime.strptime(emp['hire_date'], '%Y-%m-%d')
    current_date, salary = hire_date, random.randint(35000, 85000)
    left = random.random() < 0.15
    potential_leave = hire_date + timedelta(days=180)
    leave_date = None
    if left and potential_leave < datetime(2025, 6, 30):
        leave_date = fake.date_between(start_date=potential_leave, end_date=datetime(2025, 6, 30))
    
    while current_date < datetime(2025, 7, 1):
        attrition = 1 if leave_date and current_date.date() == leave_date else 0
        hr_facts.append({
            'hr_fact_id': hr_id, 'date': current_date.strftime('%Y-%m-%d'), 'employee_key': emp_key,
            'department_key': random.randint(10, 40), 'job_key': random.choice([800,801,802,803,804,805,806,807,808,809,810,811,812,813,814,815]),
            'location_key': random.randint(900, 911), 'salary': salary, 'attrition_flag': attrition
        })
        hr_id += 1
        if attrition == 1: break
        current_date += timedelta(days=random.randint(180, 360))
        if random.random() < 0.1: salary = int(salary * random.uniform(1.03, 1.10))
hr_df = pd.DataFrame(hr_facts)
hr_df.to_csv(f'{OUTPUT_DIR}/hr_employee_fact.csv', index=False)

print("21. Generating sf_accounts...")
sf_accounts = []
for i in range(1, NUM_CUSTOMERS + 1):
    customer = customer_dim[customer_dim['customer_key'] == i].iloc[0]
    sf_accounts.append({
        'account_id': f"ACC{i:06d}", 'account_name': customer['customer_name'], 'customer_key': i,
        'industry': customer['customer_type'], 'vertical': 'Energy', 'billing_street': customer['address'],
        'billing_city': customer['city'], 'billing_state': customer['state'], 'billing_postal_code': customer['zip'],
        'account_type': random.choice(['Kunde', 'Interessent', 'Partner']),
        'annual_revenue': random.randint(0, 500000) if customer['customer_type'] == 'Privatkunde' else random.randint(100000, 5000000),
        'employees': 1 if customer['customer_type'] == 'Privatkunde' else random.choice([5, 10, 25, 50, 100]),
        'created_date': fake.date_between(start_date=datetime(2020, 1, 1), end_date=datetime(2023, 12, 31)).strftime('%Y-%m-%d')
    })
sf_accounts_df = pd.DataFrame(sf_accounts)
sf_accounts_df.to_csv(f'{OUTPUT_DIR}/sf_accounts.csv', index=False)

print("22. Generating sf_opportunities...")
sf_opportunities = []
stages = ['Closed Won', 'Closed Lost', 'Verhandlung', 'Angebot', 'Qualifizierung', 'Interessent']
lead_sources = ['Webseite', 'Empfehlung', 'Messe', 'Telefonakquise', 'Partner', 'Social Media']
for i in range(1, 50001):
    created_date = fake.date_between(start_date=datetime(2021, 1, 1), end_date=datetime(2025, 6, 30))
    stage = random.choices(stages, weights=[0.25, 0.15, 0.15, 0.20, 0.15, 0.10])[0]
    probability = 100.0 if stage == 'Closed Won' else (0.0 if stage == 'Closed Lost' else random.uniform(10, 80))
    close_date = created_date + timedelta(days=random.randint(30, 180))
    sale_id = i if stage == 'Closed Won' and i <= NUM_CONTRACTS else ''
    
    sf_opportunities.append({
        'opportunity_id': f"OPP{i:08d}", 'sale_id': sale_id, 'account_id': f"ACC{random.randint(1, NUM_CUSTOMERS):06d}",
        'opportunity_name': f"Opportunity {i}", 'stage_name': stage, 'amount': round(random.uniform(500, 50000), 2),
        'probability': round(probability, 1), 'close_date': close_date.strftime('%Y-%m-%d'),
        'created_date': created_date.strftime('%Y-%m-%d'), 'lead_source': random.choice(lead_sources),
        'type': random.choice(['Neukunde', 'Bestandskunde - Upgrade', 'Bestandskunde - Zusatzprodukt']),
        'campaign_id': random.randint(1, 16000) if random.random() > 0.3 else ''
    })
sf_opp_df = pd.DataFrame(sf_opportunities)
sf_opp_df.to_csv(f'{OUTPUT_DIR}/sf_opportunities.csv', index=False)

print("23. Generating sf_contacts...")
sf_contacts = []
titles = ['Hausbesitzer', 'Eigentümer', 'Geschäftsführer', 'Facility Manager', 'Technischer Leiter']
for i in range(1, 75001):
    opp_idx = random.randint(1, 50000)
    sf_contacts.append({
        'contact_id': f"CON{i:08d}", 'opportunity_id': f"OPP{opp_idx:08d}", 'account_id': f"ACC{random.randint(1, NUM_CUSTOMERS):06d}",
        'first_name': fake.first_name(), 'last_name': fake.last_name(),
        'email': f"{fake.first_name().lower()}.{fake.last_name().lower()}@{random.choice(['gmail.com', 'web.de', 'gmx.de', 't-online.de', 'outlook.de'])}",
        'phone': f"+49 {random.randint(151, 179)} {random.randint(1000000, 9999999)}",
        'title': random.choice(titles), 'department': random.choice(['Privat', 'Verwaltung', 'Technik', 'Einkauf']),
        'lead_source': random.choice(lead_sources), 'campaign_no': random.randint(1, 16000) if random.random() > 0.4 else '',
        'created_date': fake.date_between(start_date=datetime(2021, 1, 1), end_date=datetime(2025, 6, 30)).strftime('%Y-%m-%d')
    })
sf_contacts_df = pd.DataFrame(sf_contacts)
sf_contacts_df.to_csv(f'{OUTPUT_DIR}/sf_contacts.csv', index=False)

print()
print("=" * 60)
print("DATA GENERATION COMPLETE!")
print("=" * 60)
print(f"Output directory: {OUTPUT_DIR}")
print()
print("Generated files:")
for f in sorted(os.listdir(OUTPUT_DIR)):
    if f.endswith('.csv'):
        filepath = os.path.join(OUTPUT_DIR, f)
        rows = sum(1 for _ in open(filepath)) - 1
        print(f"  - {f}: {rows:,} rows")

print()
print("Key Statistics:")
print(f"  - Total Customers: {NUM_CUSTOMERS:,}")
print(f"  - Customers with Heat Pumps: {len(customers_with_heatpumps):,}")
print(f"  - Customers with Solar: {len(customers_with_solar):,}")
print(f"  - Customers with E-Mobility: {len(customers_with_emobility):,}")
print(f"  - Total Contracts: {NUM_CONTRACTS:,}")
print(f"  - Total Service Logs: {NUM_SERVICE_LOGS:,}")
