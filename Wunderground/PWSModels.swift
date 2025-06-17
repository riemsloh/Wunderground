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
    let stationID: String?      // ID der PWS-Station
    let obsTimeUtc: String?     // GMT(UTC) Zeit der Beobachtung im ISO 8601 Format (z.B. "2019-02-04T14:53:14Z")
    let obsTimeLocal: String?   // Lokale Zeit der Beobachtung (z.B. "2019-02-04 09:53:14")
    let neighborhood: String?   // Nachbarschaft, die mit dem PWS-Standort verbunden ist
    let softwareType: String?   // Software-Typ der PWS (z.B. "GoWunder 1337.9041ac1")
    let country: String?        // Ländercode (z.B. "US")
    let solarRadiation: Double? // Solare Strahlung (z.B. 436.0)
    let lon: Double?            // Längengrad des PWS (z.B. -78.8759613)
    let realtimeFrequency: Int? // Frequenz...

    // Fügen Sie hier alle anderen Felder hinzu, die in Ihrer API-Antwort für die aktuelle Beobachtung enthalten sind.
    let lat: Double?
    let epoch: Int?
    let qcStatus: Int? // Quality Control Status
    let humidity: Int? // Relative Luftfeuchtigkeit
    let winddir: Int? // Windrichtung in Grad (direkt, nicht als Avg wie in Historical)
    let imperial: UnitsData? // Imperiale Maßeinheiten-Daten

    // Die "metric" Daten werden oft in einem Unterobjekt geliefert
    let metric: UnitsData?

    // Wichtig: Alle Properties MÜSSEN hier gelistet sein, wenn CodingKeys definiert ist.
    enum CodingKeys: String, CodingKey {
        case stationID = "stationId"
        case obsTimeUtc
        case obsTimeLocal
        case neighborhood
        case softwareType
        case country
        case solarRadiation
        case lon
        case realtimeFrequency
        case lat
        case epoch
        case humidity
        case qcStatus
        case winddir // Hinzugefügt
        case imperial
        case metric
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
    let precipRate: Double? // Niederschlagsrate (aktuell, pro Stunde in mm/h)
    let precipTotal: Double? // Gesamter Niederschlag seit Mitternacht (in mm)
    let elev: Double? // Höhe der Station

    // Zusätzliche Felder, die in den historischen Daten vorkommen können (falls sie im "metric"-Objekt liegen)
    let tempAvg: Double?
    let tempHigh: Double?
    let tempLow: Double?
    let humidityAvg: Double?
    let humidityHigh: Double?
    let humidityLow: Double?

    let winddirAvg: Double?     // Durchschnittliche Windrichtung des Zeitraums
    let windgustAvg: Double?    // Durchschnittliche Windböe des Zeitraums
    let windgustHigh: Double?   // Höchste Windböe des Zeitraums
    let windgustLow: Double?    // Niedrigste Windböe des Zeitraums
    let windspeedAvg: Double?   // Durchschnittliche Windgeschwindigkeit des Zeitraums
    let windspeedHigh: Double?  // Höchste Windgeschwindigkeit des Zeitraums
    let windspeedLow: Double?   // Niedrigste Windgeschwindigkeit des Zeitraums

    let heatindexAvg: Double?   // Durchschnittlicher Hitzeindex des Zeitraums
    let heatindexHigh: Double?  // Höchster Hitzeindex des Zeitraums
    let heatindexLow: Double?   // Niedrigster Hitzeindex des Zeitraums

    let dewptAvg: Double?       // Durchschnittlicher Taupunkt des Zeitraums
    let dewptHigh: Double?      // Höchster Taupunkt des Zeitraums
    let dewptLow: Double?       // Niedrigster Taupunkt des Zeitraums

    let windchillAvg: Double?   // Durchschnittlicher Windchill des Zeitraums
    let windchillHigh: Double?  // Höchster Windchill des Zeitraums
    let windchillLow: Double?   // Niedrigster Windchill des Zeitraums

    let solarRadiationHigh: Double? // Höchste solare Strahlung des Zeitraums
    let uvHigh: Double?         // Höchster UV-Index des Zeitraums
    // Füge hier weitere Felder hinzu, die in der API-Antwort unter 'metric' oder 'imperial' erscheinen können.
}


// MARK: - Top-Level Structure for Historical API Response
/// Repräsentiert die gesamte API-Antwort für historische Wetterbeobachtungen.
/// Enthält ein Array von 'HistoricalObservation'-Objekten.
struct PWSHistoricalResponse: Codable {
    let observations: [HistoricalObservation]? // Das Array der historischen Wetterbeobachtungen
}

// MARK: - HistoricalObservation
/// Repräsentiert eine einzelne historische Wetterbeobachtung von einer Personal Weather Station (PWS).
/// Kann für stündliche oder tägliche Daten verwendet werden, je nach API-Endpunkt.
struct HistoricalObservation: Codable, Identifiable {
    let id = UUID() // Eine eindeutige ID für die Verwendung in SwiftUI Listen

    let stationID: String?      // ID der PWS-Station
    let obsTimeUtc: String?     // GMT(UTC) Zeit der Beobachtung im ISO 8601 Format
    let obsTimeLocal: String?   // Lokale Zeit der Beobachtung

    // Felder, die direkt auf Top-Level der HistoricalObservation liegen (nicht im "metric"-Objekt)
    // Basierend auf deiner JSON-Rückmeldung:
    let humidityHigh: Int? // Hier war es Int in deinem JSON
    let humidityLow: Int?  // Hier war es Int in deinem JSON
    let humidityAvg: Int?  // Hier war es Int in deinem JSON
    let winddirAvg: Int?   // Hier war es Int in deinem JSON

    let solarRadiationHigh: Double? // Höchste solare Strahlung des Zeitraums
    let uvHigh: Double?         // Höchster UV-Index des Zeitraums

    let epoch: Int?             // Zeit in UNIX-Sekunden
    let lat: Double?            // Breitengrad der PWS
    let lon: Double?            // Längengrad der PWS
    let tz: String?             // Zeitzone der PWS
    let qcStatus: Int? // Quality Control Status

    // Das 'metric' Objekt ist ebenfalls optional, da es nicht immer vorhanden sein muss
    // oder bestimmte Unterfelder enthalten kann.
    let metric: UnitsData?

    /// `CodingKeys` werden verwendet, um die JSON-Schlüsselnamen den Swift-Eigenschaftsnamen zuzuordnen,
    /// falls sie nicht exakt übereinstimmen.
    enum CodingKeys: String, CodingKey {
        case stationID = "stationId"
        case obsTimeUtc
        case obsTimeLocal
        // Direkte Felder
        case humidityAvg
        case humidityHigh
        case humidityLow
        case winddirAvg
        case solarRadiationHigh
        case uvHigh
        case epoch
        case lat
        case lon
        case tz
        case qcStatus
        case metric // Der Name des Objekts für die metrischen Maßeinheiten-Daten
    }

    // Optional: Formatierter Tag und Datum für die Anzeige, ähnlich wie in Observation
    var formattedDateTime: String {
        guard let timeString = obsTimeLocal else { return "N/A" }
        let formatter = DateFormatter()
        // Das Format im PDF für obsTimeLocal ist "YYYYY-MM-dd HH:mm:ss"
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = formatter.date(from: timeString) {
            formatter.dateFormat = "dd.MM. HH:mm" // Z.B. "09.06. 22:44"
            formatter.locale = Locale(identifier: "de_DE") // Für deutsches Format
            return formatter.string(from: date)
        }
        return "N/A"
    }

    var formattedDate: String {
        guard let timeString = obsTimeLocal else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = formatter.date(from: timeString) {
            formatter.dateFormat = "dd.MM.yyyy" // Z.B. "09.06.2025"
            formatter.locale = Locale(identifier: "de_DE")
            return formatter.string(from: date)
        }
        return "N/A"
    }
}
