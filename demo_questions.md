# EPOWER Energy Intelligence Demo - Questions

## Snowflake Intelligence Demo für Energieversorger (EPOWER Style)

Diese Demo simuliert die Datenlandschaft eines großen deutschen Energieversorgers mit:
- **Strom & Gas** - Klassische Energietarife
- **Future Energy Home** - Solar, Wärmepumpen, Speicher
- **Smart Home** - Smart Meter, Energiemanagement
- **E-Mobility** - Wallbox, Ladetarife

---

## Demo Flow

### 1. Produktübersicht (Structured Data)

**Frage:** *"Gib mir einen Überblick über unser Produktportfolio. Welche Kategorien und Produkte bieten wir an?"*

---

### 2. Vertriebsanalyse (Structured Data)

**Frage:** *"Zeige mir die monatlichen Vertragszahlen für 2024. Wie hat sich der Umsatz entwickelt?"*

**Frage:** *"Which region has the highest sales for Heat Pump products?"*

---

### 3. Cross-Domain Analyse: Verbrauch + Produkte (Structured Data)

**Frage:** *"Was ist der durchschnittliche Stromverbrauch für Kunden mit Wärmepumpen in Hamburg?"*

**Frage:** *"Vergleiche den durchschnittlichen Stromverbrauch zwischen Kunden mit und ohne Wärmepumpe."*

**Frage:** *"Welche Kunden mit Solaranlagen haben den höchsten Stromverbrauch?"*

---

### 4. Kundenservice-Analyse (Structured Data)

**Frage:** *"Zeige mir alle negativen Service-Tickets zum Thema Smart Meter. Was sind die häufigsten Beschwerden?"*

**Frage:** *"What are the most common service ticket topics? Show priority distribution."*

**Frage:** *"Welche Tickets sind noch offen und haben hohe Priorität?"*

---

### 5. Dokumentensuche - RAG (Unstructured Data)

**Frage:** *"Was sind die Voraussetzungen für die Wärmepumpen-Förderung 2024?"*

**Frage:** *"Erkläre mir, wie ich meine Stromrechnung lesen kann."*

**Frage:** *"Was ist der Unterschied zwischen einer Luft-Wasser und einer Sole-Wasser Wärmepumpe?"*

---

### 6. Combined Structured + Unstructured Data Queries

These questions demonstrate the power of Snowflake Intelligence by requiring BOTH database analysis AND document search.

**Frage:** *"Wie viele Kunden haben Wärmepumpen gekauft und welche Wartungsintervalle gelten laut unserer Dokumentation?"*

> Requires: Count from customer_products + Heat_Pump_Efficiency_Guide.pdf

**Frage:** *"Zeige mir Kunden mit hohem Stromverbrauch (>6000 kWh/Jahr) und erkläre mir, welche Energiespartipps für sie relevant wären."*

> Requires: Billing data analysis + Energy_Efficiency_Tips.pdf

**Frage:** *"Welche Beschwerden haben wir zu Wärmepumpen und was sagt unsere technische Dokumentation zu den häufigsten Fehlercodes?"*

> Requires: Service_logs analysis + Heat_Pump_Efficiency_Guide.pdf (error codes)

**Frage:** *"Wie viele Kunden in Hamburg haben E-Mobility Produkte und welche Ladetarife bieten wir laut unserer Dokumentation an?"*

> Requires: customer_products + city filter + E_Mobility_Tarife.md

**Frage:** *"Vergleiche unsere Ökostrom-Verkaufszahlen mit den Vertragsbedingungen - welcher Tarif ist der günstigste?"*

> Requires: Sales data by product + EPOWER_Green_Power_TCs_2024.pdf

**Frage:** *"Zeige mir Kunden mit überfälligen Rechnungen und erkläre, welche Optionen wir laut FAQ für Ratenzahlung anbieten."*

> Requires: billing_history (payment_status = 'Überfällig') + Invoice_Explanation_FAQ.pdf

---

### 7. HR-Daten Analyse (Structured Data)

**Frage:** *"Wie viele Mitarbeiter haben wir pro Abteilung? Wie hoch ist die Fluktuation im Vertrieb?"*

---

### 8. Marketing & ROI (Structured Data)

**Frage:** *"Welche Marketing-Kampagnen haben die meisten Leads für Solarprodukte generiert?"*

---

### 9. Advanced Cross-Domain Questions

**Frage:** *"Erstelle eine Übersicht: Wie viele Kunden mit Wärmepumpen gibt es pro Region und was sind die durchschnittlichen Verbrauchswerte? Füge auch die BAFA-Fördervoraussetzungen hinzu."*

**Frage:** *"Welche Smart Meter Beschwerden hatten wir diesen Monat und was sagt unser Kundenservice-Handbuch zu den Eskalationsstufen?"*

**Frage:** *"Analysiere die Verkaufszahlen für Speicher und erkläre mir anhand der Dokumentation, wie der Eigenverbrauchs-Modus funktioniert."*

---

## Technical Components

| Komponente | Beschreibung |
|------------|--------------|
| **Database** | ENERGY_AI_DEMO.ENERGY_SCHEMA |
| **Warehouse** | ENERGY_INTELLIGENCE_DEMO_WH |
| **Semantic Views** | 5 (Energy Sales, Billing, Service, HR, Customer Energy) |
| **Cortex Search** | 4 Services (Energy, Product, Service Docs + Service Logs) |
| **Agent** | Energy_Chatbot_Agent |

---

## Data Volumes

| Tabelle | Anzahl Datensätze |
|---------|-------------------|
| customer_dim | 20,000 |
| product_dim | 27 |
| customer_products | ~40,000 |
| sales_fact (Verträge) | 240,000 |
| billing_history | ~500,000 |
| service_logs | 100,000 |
| sf_opportunities | 50,000 |
| sf_contacts | 75,000 |

---

*EPOWER Energy Intelligence Demo - Powered by Snowflake*
