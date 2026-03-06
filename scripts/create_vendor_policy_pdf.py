from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer
from reportlab.lib.units import cm

def create_pdf(output_path):
    doc = SimpleDocTemplate(output_path, pagesize=A4, 
                           leftMargin=2.5*cm, rightMargin=2.5*cm,
                           topMargin=2*cm, bottomMargin=2*cm)
    
    styles = getSampleStyleSheet()
    title_style = ParagraphStyle('Title', parent=styles['Heading1'], fontSize=14, alignment=1, spaceAfter=12)
    heading_style = ParagraphStyle('Heading', parent=styles['Heading2'], fontSize=12, spaceBefore=12, spaceAfter=6)
    body_style = ParagraphStyle('Body', parent=styles['Normal'], fontSize=10, spaceAfter=4)
    header_style = ParagraphStyle('Header', parent=styles['Normal'], fontSize=12, alignment=1, spaceAfter=20, fontName='Helvetica-Bold')
    
    story = []
    
    story.append(Paragraph("EPOWER Energie Deutschland GmbH", header_style))
    story.append(Paragraph("Richtlinie fuer Lieferanten- und Partnermanagement", title_style))
    story.append(Paragraph("EPOWER INTERNE RICHTLINIE - VERTRAULICH", body_style))
    story.append(Spacer(1, 12))
    
    story.append(Paragraph("1. GELTUNGSBEREICH", heading_style))
    story.append(Paragraph("Diese Richtlinie gilt fuer alle Beschaffungsvorgaenge der EPOWER Energie Deutschland GmbH, insbesondere fuer:", body_style))
    for item in ["Installationspartner (Solar, Waermepumpe, Wallbox)", "Wartungsdienstleister", "IT-Dienstleister", "Marketingagenturen", "Material- und Komponentenlieferanten"]:
        story.append(Paragraph(f"- {item}", body_style))
    
    story.append(Paragraph("2. BESCHAFFUNGSGRUNDSAETZE", heading_style))
    story.append(Paragraph("2.1 Ausschreibungspflicht", body_style))
    for item in ["Ab 10.000 EUR: Mind. 3 Angebote einholen", "Ab 50.000 EUR: Formelle Ausschreibung erforderlich", "Ab 100.000 EUR: EU-weite Ausschreibung pruefen"]:
        story.append(Paragraph(f"- {item}", body_style))
    
    story.append(Paragraph("2.2 Lieferantenauswahl", body_style))
    story.append(Paragraph("Bewertungskriterien:", body_style))
    for item in ["Preis-Leistungs-Verhaeltnis (40%)", "Qualitaet und Referenzen (25%)", "Nachhaltigkeit und Umweltstandards (20%)", "Zuverlaessigkeit und Lieferfaehigkeit (15%)"]:
        story.append(Paragraph(f"- {item}", body_style))
    
    story.append(Paragraph("3. VERTRAGSGESTALTUNG", heading_style))
    story.append(Paragraph("3.1 Pflichtklauseln", body_style))
    for item in ["Compliance und Anti-Korruption", "Datenschutz (DSGVO)", "Nachhaltigkeitsstandards", "Kuendigungsrechte", "Haftung und Gewaehrleistung"]:
        story.append(Paragraph(f"- {item}", body_style))
    
    story.append(Paragraph("3.2 Zahlungsbedingungen", body_style))
    for item in ["Standard: 30 Tage netto", "Bei Skonto: 2% bei Zahlung innerhalb 14 Tagen", "Vorauszahlungen nur in begruendeten Ausnahmefaellen"]:
        story.append(Paragraph(f"- {item}", body_style))
    
    story.append(Paragraph("4. LIEFERANTENBEWERTUNG", heading_style))
    story.append(Paragraph("Jaehrliche Bewertung nach:", body_style))
    for item in ["Termintreue", "Qualitaet der Leistung", "Reklamationsquote", "Kommunikation und Erreichbarkeit", "Preisgestaltung"]:
        story.append(Paragraph(f"- {item}", body_style))
    
    story.append(Paragraph("Bewertungsskala:", body_style))
    for item in ["A - Bevorzugter Partner", "B - Zugelassener Partner", "C - Unter Beobachtung", "D - Gesperrt"]:
        story.append(Paragraph(f"{item}", body_style))
    
    story.append(Paragraph("5. NACHHALTIGKEITSANFORDERUNGEN", heading_style))
    story.append(Paragraph("Lieferanten muessen nachweisen:", body_style))
    for item in ["CO2-Reduktionsziele", "Einhaltung von Arbeitsstandards", "Umweltzertifizierung (ISO 14001)", "Kreislaufwirtschaft-Konzepte"]:
        story.append(Paragraph(f"- {item}", body_style))
    
    story.append(Paragraph("6. COMPLIANCE", heading_style))
    story.append(Paragraph("Nulltoleranz bei:", body_style))
    for item in ["Korruption und Bestechung", "Kartellrechtsverstoessen", "Kinderarbeit", "Menschenrechtsverletzungen"]:
        story.append(Paragraph(f"- {item}", body_style))
    story.append(Paragraph("Verstaesse fuehren zur sofortigen Vertragsbeendigung.", body_style))
    
    story.append(Paragraph("7. GENEHMIGUNGSEBENEN", heading_style))
    for item in ["Bis 5.000 EUR: Abteilungsleiter", "Bis 25.000 EUR: Bereichsleiter", "Bis 100.000 EUR: Geschaeftsfuehrung", "Ueber 100.000 EUR: Vorstand"]:
        story.append(Paragraph(f"- {item}", body_style))
    
    story.append(Spacer(1, 20))
    story.append(Paragraph("Kontakt: einkauf@epower-energie.de", body_style))
    
    doc.build(story)
    print(f"PDF erstellt: {output_path}")

if __name__ == "__main__":
    output_path = "/Users/jjoerg/sfl/dev/cortexcode/Snowflake_EPower_Demo/unstructured_docs/energy/Vendor_Management_Policy.pdf"
    create_pdf(output_path)
