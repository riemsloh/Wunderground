// MARK: - Info
/// Copyright
/// Copyright

// MARK: - Import

import Foundation

// MARK: - Top-Level Structure
/// Repräsentiert die gesamte API-Antwort für Wetterbeobachtungen.
/// Enthält ein Array von 'Observation'-Objekten.
struct PWSObservationResponse: Codable {
    let observations: [Observation]? // Das Array der Wetterbeobachtungen
}

// MARK: - Observation
/// Repräsentiert eine einzelne Wetterbeobachtung von einer Personal Weather Station (PWS).
struct Observation: Codable {
    let stationID: String? // ID der PWS-Station
    let obsTimeUtc: String? // GMT(UTC) Zeit der Beobachtung im ISO 8601 Format (z.B. "2019-02-04T14:53:14Z")
    let obsTimeLocal: String? // Lokale Zeit der Beobachtung (z.B. "2019-02-04 09:53:14")
    let neighborhood: String? // Nachbarschaft, die mit dem PWS-Standort verbunden ist
    let softwareType: String? // Software-Typ der PWS (z.B. "GoWunder 1337.9041ac1")
    let country: String? // Ländercode (z.B. "US")
    let solarRadiation: Double? // Solare Strahlung (z.B. 436.0)
    let lon: Double? // Längengrad des PWS (z.B. -78.8759613)
    let realtimeFrequency: Int? // Frequenz der Datenaktualisierungen in Minuten (z.B. 5, oder null)
    let epoch: Int? // Zeit in UNIX-Sekunden (z.B. 1549291994)
    let lat: Double? // Breitengrad des PWS (z.B. 35.80221176)
    let uv: Double? // UV-Wert der Intensität der Sonnenstrahlung (z.B. 1.2)
    let winddir: Int? // Windrichtung in Grad (z.B. 329)
    let humidity: Int? // Relative Luftfeuchtigkeit in Prozent (z.B. 71)
    let qcStatus: Int? // Qualitätskontrollindikator (-1: kein Check, 0: möglicherweise inkorrekt, 1: Check bestanden)
    
    // Enthält Felder, die eine definierte Maßeinheit verwenden.
    // Hier wird nur 'metric' verwendet, da dies angefragt wurde.
    let metric: UnitsData?

    /// `CodingKeys` werden verwendet, um die JSON-Schlüsselnamen den Swift-Eigenschaftsnamen zuzuordnen,
    /// falls sie nicht exakt übereinstimmen (z.B. `stationId` in JSON vs. `stationID` in Swift).
    enum CodingKeys: String, CodingKey {
        case stationID = "stationId" // JSON-Schlüssel "stationId" wird der Swift-Eigenschaft "stationID" zugeordnet
        case obsTimeUtc
        case obsTimeLocal
        case neighborhood
        case softwareType
        case country
        case solarRadiation
        case lon
        case realtimeFrequency
        case epoch
        case lat
        case uv
        case winddir
        case humidity
        case qcStatus
        case metric // Der Name des Objekts für die metrischen Maßeinheiten-Daten
    }
    // Optional: Formatierter Tag und Datum für die Anzeige
    var formattedDayAndDate: String {
        guard let timeString = obsTimeUtc else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let date = formatter.date(from: timeString) {
            formatter.dateFormat = "EEEE, dd.MM., HH:mm:ss" // z.B. "Montag, 09.06., 22:44:01"
            formatter.locale = Locale(identifier: "de_DE") // Für deutschen Wochentag
            return formatter.string(from: date)
        }
        return "N/A"
    }
}

// MARK: - UnitsData
/// Eine generische Struktur, die wetterbezogene Daten enthält,
/// die von der gewählten Maßeinheit (z.B. Imperial, Metric) abhängen.
struct UnitsData: Codable {
    let temp: Double? // Temperatur
    let heatIndex: Double? // Hitzeindex
    let dewpt: Double? // Taupunkt (Dew Point)
    let windChill: Double? // Windchill
    let windSpeed: Double? // Windgeschwindigkeit (durchschnittlich über 10 Minuten)
    let windGust: Double? // Windböe (maximale Windböe während der Beobachtungsperiode)
    let pressure: Double? // Mittlerer Meeresspiegeldruck
    let precipRate: Double? // Niederschlagsrate (momentane Niederschlagsintensität)
    let precipTotal: Double? // Gesamter Niederschlag für heute (von Mitternacht bis jetzt)
    let elev: Double? // Höhe
}

