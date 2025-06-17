// Copyright by Olaf Lueg

import Foundation // Für URL, URLSession, JSONDecoder
import SwiftUI // Für ObservableObject, @Published, @MainActor, @AppStorage

// MARK: - PWSViewModel
/// Ein ViewModel, das die Logik für den Abruf und die Verwaltung von Wetterdaten kapselt.
/// Es ist ein ObservableObject, damit Views auf Änderungen seiner @Published-Eigenschaften reagieren können.
class PWSViewModel: ObservableObject {
    // Veröffentlichte Eigenschaften, die die UI aktualisieren, wenn sie sich ändern.
    @Published var observation: Observation? // Das aktuelle Wetterbeobachtungs-Objekt
    @Published var historicalObservations: [HistoricalObservation] = [] // Neu: Für historische Daten
    @Published var isLoading: Bool = false // Zeigt an, ob Daten geladen werden
    @Published var errorMessage: String? // Speichert Fehlermeldungen
    
    // Timer-Instanz für den automatischen Datenabruf
    private var timer: Timer?
    
    // Lese die Konfigurationswerte direkt aus AppStorage
    @AppStorage("selectedStationId") private var storedStationId: String = "YOUR_STATION_ID"
    @AppStorage("apiKey") private var storedApiKey: String = "YOUR_WEATHER_API_KEY"
    @AppStorage("autoRefreshEnabled")  var autoRefreshEnabled: Bool = true // Auch diese Einstellung wird hier benötigt

    // Die Basis-URL für die Weather Company PWS Observations API.
    private let baseURL = "https://api.weather.com/v2/pws/observations/current"

    /// Ruft Wetterdaten asynchron von der Weather Company API ab.
    /// Verwendet die in AppStorage gespeicherten Werte für Station ID und API-Schlüssel.
    @MainActor // Stellt sicher, dass UI-Updates auf dem Haupt-Thread erfolgen
    func fetchWeatherData(units: String = "m") async { // Parameter für stationId und apiKey entfernt
        // Nur abrufen, wenn automatische Aktualisierung aktiviert ist oder manuell ausgelöst wird
        guard autoRefreshEnabled || !isLoading else { return } // Verhindert unnötige Aufrufe

        isLoading = true // Ladezustand aktivieren
        errorMessage = nil // Vorherige Fehlermeldungen zurücksetzen
        
        // Überprüfen, ob API-Schlüssel und Station ID vorhanden sind
        guard !storedStationId.isEmpty, !storedApiKey.isEmpty,
              storedStationId != "YOUR_STATION_ID", storedApiKey != "YOUR_WEATHER_API_KEY" else {
            errorMessage = "Bitte geben Sie eine gültige Station ID und einen API-Schlüssel in den Einstellungen ein."
            isLoading = false
            return
        }

        // URL-Komponenten erstellen, um die URL sicher zusammenzusetzen.
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "stationId", value: storedStationId), // Nutze den gespeicherten Wert
            URLQueryItem(name: "format", value: "json"), // Wir erwarten JSON-Format
            URLQueryItem(name: "units", value: units), // Metrische Einheiten
            URLQueryItem(name: "apiKey", value: storedApiKey) // Nutze den gespeicherten Wert
        ]
        
        // Überprüfen, ob die URL gültig ist.
        guard let url = components?.url else {
            errorMessage = "Ungültige URL-Konfiguration."
            isLoading = false
            return
        }
        
        do {
            // Daten von der URL abrufen.
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // HTTP-Antwort überprüfen.
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                errorMessage = "Serverfehler oder ungültige Antwort. Statuscode: \(statusCode)"
                isLoading = false
                return
            }
            
            // JSON-Daten decodieren.
            let decoder = JSONDecoder()
            let PWSResponse = try decoder.decode(PWSObservationResponse.self, from: data)
            
            // Die erste Beobachtung (falls vorhanden) speichern.
            // Die API liefert ein Array, auch wenn es meist nur eine aktuelle Beobachtung ist.
            observation = PWSResponse.observations?.first
            
            // Wenn keine Beobachtungen gefunden wurden, eine entsprechende Meldung setzen.
            if observation == nil {
                errorMessage = "Keine Wetterdaten für die angegebene Station gefunden."
            }
            else{
                print("Wetterdaten erfolgreich von Wunderground für \(observation?.neighborhood ?? "N/A") geladen!")
                print("Rohdaten: \(observation?.obsTimeLocal ?? "N/A")")
            }
            
        } catch let decodingError as DecodingError {
            // Spezifische Fehler beim Decodieren abfangen.
            print("Decodierungsfehler: \(decodingError.localizedDescription)") // Angepasst
            errorMessage = "Fehler beim Decodieren der Wetterdaten. Bitte überprüfen Sie das Datenformat."
        } catch {
            // Allgemeine Netzwerk- oder andere Fehler abfangen.
            print("Netzwerkfehler: \(error)")
            errorMessage = "Fehler beim Abrufen der Wetterdaten: \(error.localizedDescription)"
        }
        
        isLoading = false // Ladezustand deaktivieren
    }
    
    /// Ruft historische Wetterdaten asynchron von der Weather Company API ab.
    /// Verwendet die in AppStorage gespeicherten Werte für Station ID und API-Schlüssel.
    /// - Parameter date: Das Datum für die historischen Daten im Format "YYYYMMDD".
    /// - Parameter units: Die Maßeinheit für die Daten (Standard: "m" für metrisch).
    @MainActor
    func fetchHistoricalWeatherData(date: String, units: String = "m") async {
        isLoading = true // Ladezustand aktivieren
        errorMessage = nil // Vorherige Fehlermeldungen zurücksetzen

        guard !storedStationId.isEmpty, !storedApiKey.isEmpty,
              storedStationId != "YOUR_STATION_ID", storedApiKey != "YOUR_WEATHER_API_KEY" else {
            errorMessage = "Bitte geben Sie eine gültige Station ID und einen API-Schlüssel in den Einstellungen ein."
            isLoading = false
            return
        }

        let historyBaseURL = "https://api.weather.com/v2/pws/history/hourly" // Oder /daily, /all
        var components = URLComponents(string: historyBaseURL)
        components?.queryItems = [
            URLQueryItem(name: "stationId", value: storedStationId),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "units", value: units),
            URLQueryItem(name: "date", value: date), // Das Datum im Format "YYYYMMDD"
            URLQueryItem(name: "apiKey", value: storedApiKey)
        ]

        guard let url = components?.url else {
            errorMessage = "Ungültige URL-Konfiguration für historische Daten."
            isLoading = false
            return
        }
        
        print("Versuche, historische Daten abzurufen von URL: \(url.absoluteString)") // NEU: URL loggen

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // NEU: HTTP Status Code loggen
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code für historische Daten: \(httpResponse.statusCode)")
                guard (200...299).contains(httpResponse.statusCode) else {
                    errorMessage = "Serverfehler beim Abruf historischer Daten. Statuscode: \(httpResponse.statusCode)"
                    isLoading = false
                    // NEU: Rohe Antwort bei Fehler loggen
                    print("Fehlerhafte rohe Antwort für historische Daten: \(String(data: data, encoding: .utf8) ?? "Keine Daten")")
                    return
                }
            }
            
            // NEU: Rohe JSON-Daten loggen (vorsicht bei sehr großen Antworten)
            print("Rohe JSON-Antwort für historische Daten: \(String(data: data, encoding: .utf8) ?? "Ungültige Daten")")

            let decoder = JSONDecoder()
            let historicalResponse = try decoder.decode(PWSHistoricalResponse.self, from: data)
            historicalObservations = historicalResponse.observations ?? []

            if historicalObservations.isEmpty {
                errorMessage = "Keine historischen Daten für das angegebene Datum gefunden."
            } else {
                print("Historische Wetterdaten für \(date) erfolgreich geladen! Anzahl Beobachtungen: \(historicalObservations.count)")
            }

        } catch let decodingError as DecodingError {
            print("Decodierungsfehler für historische Daten: \(decodingError.localizedDescription)") // Angepasst
            errorMessage = "Fehler beim Decodieren der historischen Wetterdaten. Bitte überprüfen Sie das Datenformat der API-Antwort und des Modells."
        } catch {
            print("Netzwerkfehler für historische Daten: \(error)")
            errorMessage = "Fehler beim Abrufen der historischen Wetterdaten: \(error.localizedDescription)"
        }
        isLoading = false
    }

    /// Startet einen Timer, der alle 60 Sekunden Wetterdaten abruft.
    /// Ungültig macht jeden zuvor gestarteten Timer.
    ///

    func startFetchingDataAutomatically() {
            // Vorhandenen Timer ungültig machen, um doppelte Timer zu vermeiden
            timer?.invalidate()
            
            // Nur starten, wenn automatische Aktualisierung aktiviert ist
            guard autoRefreshEnabled else { return }

            // Neuen Timer erstellen, der alle 60 Sekunden feuert
            // [weak self] in der Timer-Closure verwenden, um Retain-Cycles zu vermeiden
            timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
                // Sicherstellen, dass self noch existiert, bevor fetchWeatherData aufgerufen wird
#if swift(>=6.0)
                Task { @MainActor in
                    await self?.fetchWeatherData() // Hier self? verwenden
                }
#elseif swift(<5.9)
                Task {
                    await self?.fetchWeatherData() // Hier self? verwenden
                }
#else
                Task {
                    await self?.fetchWeatherData() // Hier self? verwenden
                }
#endif
            }
            // Sofortigen ersten Abruf starten
            // Auch hier [weak self] verwenden, um Probleme bei der Deallokation von ViewModel zu vermeiden
#if swift(>=6.0)
        Task { @MainActor in
            await self.fetchWeatherData() // Hier self? verwenden
            }
#elseif swift(<5.9)
        Task {
            await self.fetchWeatherData() // Hier self? verwenden
            }
#else
        Task {
            await self.fetchWeatherData() // Hier self? verwenden
            }
        #endif
        }
    
    /// Stoppt den automatischen Datenabruf-Timer.
    func stopFetchingDataAutomatically() {
        timer?.invalidate()
        timer = nil
    }
    
    // Beim Deinitialisieren des ViewModels den Timer stoppen, um Memory Leaks zu vermeiden
    deinit {
        stopFetchingDataAutomatically()
    }
}
