# EPOWER Energy Intelligence Demo

## Snowflake Intelligence Demo für Energieversorger (EPOWER Style)

Diese Demo simuliert die Datenlandschaft eines großen deutschen Energieversorgers mit:
- **Strom & Gas** - Klassische Energietarife
- **Future Energy Home** - Solar, Wärmepumpen, Speicher
- **Smart Home** - Smart Meter, Energiemanagement
- **E-Mobility** - Wallbox, Ladetarife

---

## Schnellfragen für die Demo

### Deutsch
- Was ist der durchschnittliche Stromverbrauch für Kunden mit Wärmepumpen in Hamburg?
- Zeige mir alle negativen Service-Tickets zum Thema Smart Meter.
- Welche Produkte haben wir letzten Monat am meisten verkauft?
- Wie ist der Zahlungsstatus unserer Rechnungen aufgeteilt?

### English
- What is the average electricity consumption for customers with Heat Pumps in Hamburg?
- Show me all negative service tickets related to Smart Meters.
- Which products sold the most last month?

---

## Demo Flow

### 1. Produktübersicht

**Frage:** *"Gib mir einen Überblick über unser Produktportfolio. Welche Kategorien und Produkte bieten wir an?"*

- Agent nutzt Energy Sales Datamart
- Zeigt die 6 Kategorien: Electricity, Gas, Solar, Heat Pumps, Smart Home, E-Mobility
- Listet die 27 Produkte auf

---

### 2. Vertriebsanalyse - Was ist passiert?

**Frage:** *"Zeige mir die monatlichen Vertragszahlen für 2024. Wie hat sich der Umsatz entwickelt?"*

- Typische "Was ist passiert" Frage
- Agent nutzt Energy Sales Semantic View
- Visualisierung als Liniendiagramm
- Key Insights: Saisonale Muster, Spitzen

---

### 3. Cross-Domain Analyse - Verbrauch und Produkte

**Frage:** *"Was ist der durchschnittliche Stromverbrauch für Kunden mit Wärmepumpen in Hamburg?"*

**Diese Frage demonstriert:**
- Verknüpfung von Billing-Daten (Verbrauch) mit Customer-Daten (Stadt, Produkte)
- Cross-Domain Query zwischen Billing und Sales Datamart
- Geografische Filterung (Hamburg = North Region)

**Erwartete Ergebnisse:**
- Durchschnittlicher Verbrauch: ~4.500-6.000 kWh/Jahr (Basis) + ~3.000-5.000 kWh (Wärmepumpe)
- Vergleich mit Nicht-Wärmepumpen-Haushalten

---

### 4. Kundenservice-Analyse

**Frage:** *"Zeige mir alle negativen Service-Tickets zum Thema Smart Meter. Was sind die häufigsten Beschwerden?"*

**Diese Frage demonstriert:**
- Semantische Suche in Service-Logs
- Sentiment-Analyse (Negativ-Filter)
- Topic-Filterung (Smart Meter)

**Typische Smart Meter Beschwerden:**
- Smart Meter defekt
- Smart Meter Ablesung fehlerhaft
- Keine Verbindung zum Smart Meter

---

### 5. Dokumentensuche (RAG)

**Frage:** *"Was sind die Voraussetzungen für die Wärmepumpen-Förderung 2024?"*

- Agent nutzt Cortex Search über Energy Documents
- Findet: Waermepumpe_Foerderung_2024.md
- Liefert Details zu BAFA-Förderung, KfW-Kredit, Boni

**Frage:** *"Erkläre mir, wie ich meine Stromrechnung lesen kann."*

- Agent durchsucht Service Documents
- Findet: Invoice_Explanation_FAQ.pdf
- Erklärt Preisbestandteile, Abschläge, etc.

---

### 6. Produktvergleich und Beratung

**Frage:** *"Was ist der Unterschied zwischen einer Luft-Wasser und einer Sole-Wasser Wärmepumpe? Welche ist effizienter?"*

- Agent nutzt Product Documents
- Findet: Heat_Pump_Efficiency_Guide.pdf
- Vergleicht COP, Schallpegel, Anwendungsbereiche

---

### 7. Cross-Funktionale Analyse

**Frage:** *"Welche Marketing-Kampagnen haben die meisten Leads für Solarprodukte generiert? Wie hoch war der Cost per Lead?"*

- Verknüpfung Marketing-Daten mit Produktkategorien
- ROI-Berechnung
- Channel-Vergleich

---

### 8. HR-Daten Analyse

**Frage:** *"Wie viele Mitarbeiter haben wir pro Abteilung? Wie hoch ist die Fluktuation im Vertrieb?"*

- HR Semantic View
- Abteilungsverteilung
- Attrition-Analyse

---

### 9. Web-Scraping Integration

**Frage:** *"Hole mir aktuelle Informationen von der BAFA-Webseite zu Wärmepumpen-Förderung und vergleiche sie mit unseren internen Dokumenten."*

- Zeigt Web-Scraping Capability
- Externe Datenintegration
- Vergleich mit internen Dokumenten

---

## Beispielhafte SQL-Queries (für Referenz)

### Durchschnittlicher Verbrauch mit Wärmepumpe in Hamburg
```sql
SELECT 
    c.city,
    AVG(b.consumption_kwh) as avg_monthly_consumption,
    COUNT(DISTINCT c.customer_key) as customer_count
FROM billing_history b
JOIN customer_dim c ON b.customer_key = c.customer_key
JOIN sales_fact s ON c.customer_key = s.customer_key
JOIN product_dim p ON s.product_key = p.product_key
WHERE c.city = 'Hamburg'
  AND p.category_name = 'Heat Pumps'
  AND b.billing_type = 'Electricity'
GROUP BY c.city;
```

### Negative Smart Meter Tickets
```sql
SELECT 
    log_date,
    description,
    priority,
    channel
FROM service_logs
WHERE topic = 'Smart Meter'
  AND sentiment = 'Negativ'
ORDER BY log_date DESC;
```

---

## Key Demo Points

1. **Multilinguale Fähigkeit**: Agent antwortet auf Deutsch oder Englisch
2. **Cross-Domain Analytics**: Verknüpfung von Sales, Billing, Service, HR
3. **RAG/Document Search**: Interne Dokumente durchsuchbar
4. **Sentiment Analysis**: Service-Ticket Analyse
5. **Energy-spezifische Metriken**: kWh-Verbrauch, Abschläge, Förderungen

---

## Technische Komponenten

| Komponente | Beschreibung |
|------------|--------------|
| **Database** | ENERGY_AI_DEMO.ENERGY_SCHEMA |
| **Warehouse** | ENERGY_INTELLIGENCE_DEMO_WH |
| **Semantic Views** | 4 (Energy Sales, Billing, Service, HR) |
| **Cortex Search** | 4 Services (Energy, Product, Service Docs + Service Logs) |
| **Agent** | Energy_Chatbot_Agent |

---

## Datenvolumen

| Tabelle | Anzahl Datensätze |
|---------|-------------------|
| customer_dim | 1.000 |
| product_dim | 27 |
| sales_fact (Verträge) | 12.000 |
| billing_history | 25.540 |
| service_logs | 5.000 |
| sf_opportunities | 25.000 |
| sf_contacts | 37.000 |

---

*EPOWER Energy Intelligence Demo - Powered by Snowflake*
