//
//  DailyForecastModels.swift
//  DeineApp
//
//  Created by [Dein Name] on [Aktuelles Datum].
//  Copyright © [Aktuelles Jahr] [Dein Unternehmen]. All rights reserved.
//

import Foundation

// MARK: - Daily Forecast API Response - Matches the EXACT provided JSON structure
/// Repräsentiert die gesamte Rohdaten-API-Antwort für die tägliche Vorhersage,
/// wie sie im von Ihnen bereitgestellten JSON-Beispiel vorliegt.
struct DailyForecastAPIResponse: Codable {
    let calendarDayTemperatureMax: [Int?]?
    let calendarDayTemperatureMin: [Int?]?
    let dayOfWeek: [String]?
    let expirationTimeUtc: [Int]?
    let moonPhase: [String]?
    let moonPhaseCode: [String]?
    let moonPhaseDay: [Int]?
    let moonriseTimeLocal: [String?]?
    let moonriseTimeUtc: [Int?]?
    let moonsetTimeLocal: [String?]?
    let moonsetTimeUtc: [Int?]?
    let narrative: [String]?
    let qpf: [Double]? // Quantitative Precipitation Forecast
    let qpfSnow: [Double]? // Quantitative Precipitation Forecast Snow
    let sunriseTimeLocal: [String?]?
    let sunriseTimeUtc: [Int?]?
    let sunsetTimeLocal: [String?]?
    let sunsetTimeUtc: [Int?]?
    let temperatureMax: [Int?]?
    let temperatureMin: [Int?]?
    let validTimeLocal: [String]?
    let validTimeUtc: [Int]?
    let daypart: [DaypartDataArrays]? // Dies ist ein Array, das ein oder mehrere DaypartDataArrays-Objekte enthält
}

// MARK: - DaypartDataArrays - Matches the object INSIDE the 'daypart' array
/// Diese Struktur repräsentiert das Objekt innerhalb des 'daypart'-Arrays der API-Antwort.
/// Jede Eigenschaft ist hier ein Array von Werten, da das JSON diese so strukturiert.
struct DaypartDataArrays: Codable {
    let cloudCover: [Int?]?
    let dayOrNight: [String?]?
    let daypartName: [String?]?
    let iconCode: [Int?]?
    let iconCodeExtend: [Int?]?
    let narrative: [String?]?
    let precipChance: [Int?]?
    let precipType: [String?]?
    let qpf: [Double?]?
    let qpfSnow: [Double?]?
    let qualifierCode: [String?]?
    let qualifierPhrase: [String?]?
    let relativeHumidity: [Int?]?
    let snowRange: [String?]?
    let temperature: [Int?]?
    let temperatureHeatIndex: [Int?]?
    let temperatureWindChill: [Int?]?
    let thunderCategory: [String?]?
    let thunderIndex: [Int?]?
    let uvDescription: [String?]?
    let uvIndex: [Int?]?
    let windDirection: [Int?]?
    let windDirectionCardinal: [String?]?
    let windPhrase: [String?]?
    let windSpeed: [Int?]?
    let wxPhraseLong: [String?]?
    let wxPhraseShort: [String?]?
}

// MARK: - SingleDaypartForecast (Helper for individual Day/Night periods)
/// Eine Hilfsstruktur, die die Daten für einen einzelnen Tages- oder Nachtteil enthält.
/// Diese wird aus den Arrays in DaypartDataArrays bei einem bestimmten Index erstellt.
struct SingleDaypartForecast: Identifiable {
    let id = UUID()
    
    let cloudCover: Int?
    let dayOrNight: String?
    let daypartName: String?
    let iconCode: Int?
    let iconCodeExtend: Int?
    let narrative: String?
    let precipChance: Int?
    let precipType: String?
    let qpf: Double?
    let qpfSnow: Double?
    let qualifierCode: String?
    let qualifierPhrase: String?
    let relativeHumidity: Int?
    let snowRange: String?
    let temperature: Int?
    let temperatureHeatIndex: Int?
    let temperatureWindChill: Int?
    let thunderCategory: String?
    let thunderIndex: Int?
    let uvDescription: String?
    let uvIndex: Int?
    let windDirection: Int?
    let windDirectionCardinal: String?
    let windPhrase: String?
    let windSpeed: Int?
    let wxPhraseLong: String?
    let wxPhraseShort: String?
    
    // Initialisierer, um einen SingleDaypartForecast aus DaypartDataArrays und einem Index zu erstellen
    init(data: DaypartDataArrays, index: Int) {
        self.cloudCover = data.cloudCover?.indices.contains(index) == true ? data.cloudCover?[index] : nil
        self.dayOrNight = data.dayOrNight?.indices.contains(index) == true ? data.dayOrNight?[index] : nil
        self.daypartName = data.daypartName?.indices.contains(index) == true ? data.daypartName?[index] : nil
        self.iconCode = data.iconCode?.indices.contains(index) == true ? data.iconCode?[index] : nil
        self.iconCodeExtend = data.iconCodeExtend?.indices.contains(index) == true ? data.iconCodeExtend?[index] : nil
        self.narrative = data.narrative?.indices.contains(index) == true ? data.narrative?[index] : nil
        self.precipChance = data.precipChance?.indices.contains(index) == true ? data.precipChance?[index] : nil
        self.precipType = data.precipType?.indices.contains(index) == true ? data.precipType?[index] : nil
        self.qpf = data.qpf?.indices.contains(index) == true ? data.qpf?[index] : nil
        self.qpfSnow = data.qpfSnow?.indices.contains(index) == true ? data.qpfSnow?[index] : nil
        self.qualifierCode = data.qualifierCode?.indices.contains(index) == true ? data.qualifierCode?[index] : nil
        self.qualifierPhrase = data.qualifierPhrase?.indices.contains(index) == true ? data.qualifierPhrase?[index] : nil
        self.relativeHumidity = data.relativeHumidity?.indices.contains(index) == true ? data.relativeHumidity?[index] : nil
        self.snowRange = data.snowRange?.indices.contains(index) == true ? data.snowRange?[index] : nil
        self.temperature = data.temperature?.indices.contains(index) == true ? data.temperature?[index] : nil
        self.temperatureHeatIndex = data.temperatureHeatIndex?.indices.contains(index) == true ? data.temperatureHeatIndex?[index] : nil
        self.temperatureWindChill = data.temperatureWindChill?.indices.contains(index) == true ? data.temperatureWindChill?[index] : nil
        self.thunderCategory = data.thunderCategory?.indices.contains(index) == true ? data.thunderCategory?[index] : nil
        self.thunderIndex = data.thunderIndex?.indices.contains(index) == true ? data.thunderIndex?[index] : nil
        self.uvDescription = data.uvDescription?.indices.contains(index) == true ? data.uvDescription?[index] : nil
        self.uvIndex = data.uvIndex?.indices.contains(index) == true ? data.uvIndex?[index] : nil
        self.windDirection = data.windDirection?.indices.contains(index) == true ? data.windDirection?[index] : nil
        self.windDirectionCardinal = data.windDirectionCardinal?.indices.contains(index) == true ? data.windDirectionCardinal?[index] : nil
        self.windPhrase = data.windPhrase?.indices.contains(index) == true ? data.windPhrase?[index] : nil
        self.windSpeed = data.windSpeed?.indices.contains(index) == true ? data.windSpeed?[index] : nil
        self.wxPhraseLong = data.wxPhraseLong?.indices.contains(index) == true ? data.wxPhraseLong?[index] : nil
        self.wxPhraseShort = data.wxPhraseShort?.indices.contains(index) == true ? data.wxPhraseShort?[index] : nil
    }
}

// MARK: - DailyForecast (Aggregated for easy display)
/// Repräsentiert die konsolidierte tägliche Vorhersage für einen einzelnen Tag.
/// Diese Struktur wird aus DailyForecastAPIResponse und DaypartDataArrays zusammengestellt.
struct DailyForecast: Identifiable {
    let id = UUID()
    
    let date: Date // Das Datum des Vorhersagetags
    let dayOfWeek: String // z.B. "Montag"
    let maxTemp: Int // Höchsttemperatur
    let minTemp: Int // Tiefsttemperatur
    let narrative: String // Gesamtbeschreibung für den Tag
    let qpf: Double // Niederschlagsmenge für den Tag

    let dayPart: SingleDaypartForecast?
    let nightPart: SingleDaypartForecast?

    // Initialisierer, um eine DailyForecast aus den Rohdaten und einem Index zu erstellen
    init?(index: Int, apiResponse: DailyForecastAPIResponse) {
        guard let validTimeLocalStrings = apiResponse.validTimeLocal,
              index < validTimeLocalStrings.count,
              let dayOfWeeks = apiResponse.dayOfWeek,
              index < dayOfWeeks.count,
              let maxTemps = apiResponse.calendarDayTemperatureMax,
              index < maxTemps.count,
              let minTemps = apiResponse.calendarDayTemperatureMin,
              index < minTemps.count,
              let narratives = apiResponse.narrative,
              index < narratives.count,
              let qpfs = apiResponse.qpf,
              index < qpfs.count
        else {
            return nil
        }

        let dateString = validTimeLocalStrings[index]

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" // Passt zum ISO 8601 Format
        guard let parsedDate = dateFormatter.date(from: dateString) else {
            return nil
        }

        self.date = parsedDate
        self.dayOfWeek = dayOfWeeks[index]
        self.maxTemp = maxTemps[index] ?? 0
        self.minTemp = minTemps[index] ?? 0
        self.narrative = narratives[index]
        self.qpf = qpfs[index] 

        var foundDayPart: SingleDaypartForecast?
        var foundNightPart: SingleDaypartForecast?

        if let daypartData = apiResponse.daypart?.first { // Zugriff auf das DaypartDataArrays-Objekt
            
            // Konvertiere das DaypartDataArrays-Objekt in ein flaches Array von SingleDaypartForecast
            var allSingleDayparts: [SingleDaypartForecast] = []
            if let totalDayparts = daypartData.daypartName?.count { // Nutze irgendein Array zur Zählung
                for i in 0..<totalDayparts {
                    allSingleDayparts.append(SingleDaypartForecast(data: daypartData, index: i))
                }
            }
            
            // Versuche, den Tag und die Nacht für das aktuelle Datum zu finden
            // Iteriere über die möglichen Dayparts, die dem aktuellen Datum entsprechen könnten.
            // Die Logik hier ist, dass für Tag 'i' die Daypart-Einträge bei Index (i*2) und (i*2+1) liegen KÖNNTEN,
            // aber es ist sicherer, nach dem `daypartName` UND dem `dayOrNight` zu suchen.

            // Für den Index 'i' (von 0 bis 10 für die Tage) suchen wir nach dem passenden Daypart.
            // Das daypart-Array in der JSON-Antwort ist flach.
            // Der erste Eintrag ist "Heute Abend" (Nacht für Tag 0)
            // Der zweite Eintrag ist "Morgen" (Tag für Tag 0)
            // Der dritte Eintrag ist "Morgen Abend" (Nacht für Tag 1)
            // Der vierte Eintrag ist "Sonntag" (Tag für Tag 1)
            // ...
            // Dies ist KEINE 1:1 Zuordnung mit dem Haupt-Index.
            // Wir müssen die dayparts nach Datum und Tag/Nacht filtern.

            // Am einfachsten ist es, alle dayparts zu iterieren und sie dem richtigen Datum zuzuordnen
            // basierend auf dem 'daypartName' und dem 'dayOrNight' Flag.
            
            // Um die genaue Zuordnung zu gewährleisten, können wir den Wochentag aus parsedDate
            // mit dem daypartName abgleichen.
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE" // "Freitag", "Samstag", etc.
            formatter.locale = Locale(identifier: "de_DE")
            let formattedDayOfWeek = formatter.string(from: parsedDate)
            
            for singleDaypart in allSingleDayparts {
                if let name = singleDaypart.daypartName?.lowercased() {
                    let dayNameLowercased = formattedDayOfWeek.lowercased()

                    // Match für den aktuellen Tag
                    // Sonderfall für "Heute Abend" / "Morgen" für den ersten Tag
                    if index == 0 {
                        if name.contains("heute abend") && singleDaypart.dayOrNight == "N" {
                            foundNightPart = singleDaypart
                        }
                        if name.contains("morgen") && singleDaypart.dayOrNight == "D" {
                            foundDayPart = singleDaypart
                        }
                    } else {
                        // Für alle anderen Tage, die mit ihrem Wochentag benannt sind
                        if name.contains(dayNameLowercased) {
                            if singleDaypart.dayOrNight == "D" {
                                foundDayPart = singleDaypart
                            } else if singleDaypart.dayOrNight == "N" {
                                foundNightPart = singleDaypart
                            }
                        }
                    }
                }
            }
        }
        
        self.dayPart = foundDayPart
        self.nightPart = foundNightPart
    }

    // Formatierte Datumsausgabe
    var formattedDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, dd. MMMM" // z.B. "Mittwoch, 18. Juni"
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.string(from: date)
    }
}
