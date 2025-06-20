//
//  DailyForecastModels.swift
//  Wunderground
//
//  Created by Olaf Lueg on 20.06.25.
//

import Foundation
//
//  DailyForecastModels.swift


import Foundation

// MARK: - Daily Forecast Models
/// Top-Level-Struktur für die tägliche Vorhersage-API-Antwort
struct DailyForecastResponse: Codable {
    let forecasts: [DailyForecast]?
}

/// Repräsentiert eine einzelne tägliche Vorhersage
struct DailyForecast: Codable, Identifiable {
    let id = UUID() // Für SwiftUI ForEach

    let classProperty: String? // "day"
    let expireTimeGmt: Int?
    let fcstValid: Int?
    let fcstValidLocal: String? // z.B. "2025-06-18T07:00:00+0200"
    let num: Int? // Tägliche Nummer (Tag 1, Tag 2, etc.)
    let maxTemp: Int? // Höchste Tagestemperatur
    let minTemp: Int? // Niedrigste Tagestemperatur
    let phrase32Char: String? // Kurze Textbeschreibung (z.B. "Slight Chance Rain")
    let phrase22Char: String?
    let phrase12Char: String?
    let dayOfWeek: String? // z.B. "Wed"
    let dow: String? // z.B. "WED"
    let sunriseTimeLocal: String? // z.B. "05:07:00"
    let sunsetTimeLocal: String? // z.B. "21:30:00"
    let moonriseTimeLocal: String?
    let moonsetTimeLocal: String?
    let moonPhase: String? // z.B. "Waning Crescent"
    let moonPhaseCode: String?
    let tempMax: Int? // (Alternativ zu maxTemp)
    let tempMin: Int? // (Alternativ zu minTemp)
    let precipChance: Int? // Precipitation Probability
    let precipType: String? // z.B. "rain"
    let qpf: Double? // Quantitative Precipitation Forecast (Niederschlagsmenge)
    let snowQpf: Double?
    let daytime: DailyPeriodForecast? // Details für den Tag
    let nighttime: DailyPeriodForecast? // Details für die Nacht
    
    // CodingKeys, um JSON-Schlüssel zu Eigenschaftsnamen zuzuordnen
    enum CodingKeys: String, CodingKey {
        case classProperty = "class"
        case expireTimeGmt = "expire_time_gmt"
        case fcstValid = "fcst_valid"
        case fcstValidLocal = "fcst_valid_local"
        case num
        case maxTemp = "max_temp"
        case minTemp = "min_temp"
        case phrase32Char = "phrase_32char"
        case phrase22Char = "phrase_22char"
        case phrase12Char = "phrase_12char"
        case dayOfWeek = "day_of_week"
        case dow
        case sunriseTimeLocal = "sunrise_time_local"
        case sunsetTimeLocal = "sunset_time_local"
        case moonriseTimeLocal = "moonrise_time_local"
        case moonsetTimeLocal = "moonset_time_local"
        case moonPhase = "moon_phase"
        case moonPhaseCode = "moon_phase_code"
        case tempMax = "temp_max"
        case tempMin = "temp_min"
        case precipChance = "precip_chance"
        case precipType = "precip_type"
        case qpf
        case snowQpf = "snow_qpf"
        case daytime = "day" // 'day' Feld im JSON
        case nighttime = "night" // 'night' Feld im JSON
    }

    // Formatiert das lokale Vorhersagedatum (z.B. "Mittwoch, 18. Juni")
    var formattedDate: String {
        guard let dateString = fcstValidLocal else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" // Passt zum ISO 8601 Format
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "EEEE, dd. MMMM" // z.B. "Mittwoch, 18. Juni"
            formatter.locale = Locale(identifier: "de_DE")
            return formatter.string(from: date)
        }
        return "N/A"
    }
}

/// Details für eine Tages- oder Nachtperiode innerhalb einer täglichen Vorhersage
struct DailyPeriodForecast: Codable {
    let precipsAllowed: Bool?
    let wxPhraseLong: String?
    let wxPhraseShort: String?
    let wxIcon: Int?
    let iconCode: Int?
    let temperature: Int? // Hier könnte 'temp' oder 'temperature' sein
    let humidity: Int?
    let windSpeed: Int?
    let windDir: Int?
    let windDirCardinal: String?
    let gust: Int?
    let pop: Int? // Precipitation Probability
    let precipType: String?
    let qpf: Double? // Niederschlagsmenge
    let snowQpf: Double?
    let uvIndex: Int?
    let uvDescription: String?
    let cloudCover: Int?
    let pressureMeanSeaLevel: Double? // Mittlerer Meeresspiegeldruck

    enum CodingKeys: String, CodingKey {
        case precipsAllowed = "precip_allowed"
        case wxPhraseLong = "wx_phrase_long"
        case wxPhraseShort = "wx_phrase_short"
        case wxIcon = "wx_icon"
        case iconCode = "icon_code"
        case temperature = "temp" // Passt den Schlüssel an, falls API "temp" statt "temperature" verwendet
        case humidity
        case windSpeed = "wind_speed"
        case windDir = "wind_dir"
        case windDirCardinal = "wind_dir_cardinal"
        case gust
        case pop
        case precipType = "precip_type"
        case qpf
        case snowQpf = "snow_qpf"
        case uvIndex = "uv_index"
        case uvDescription = "uv_description"
        case cloudCover = "cloud_cover"
        case pressureMeanSeaLevel = "pressure_mean_sea_level"
    }
}
