//
//  DailyForecastViewModel.swift


import Foundation
import SwiftUI // Für ObservableObject, @Published, @MainActor, @AppStorage


class DailyForecastViewModel: ObservableObject {
    @Published var dailyForecasts: [DailyForecast] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // Lese die Konfigurationswerte direkt aus AppStorage
    @AppStorage("apiKey") private var storedApiKey: String = "YOUR_WEATHER_API_KEY"
    @AppStorage("latitude") private var storedLatitude: Double = 52.2039 // Beispiel: Melle Latitude
    @AppStorage("longitude") private var storedLongitude: Double = 8.3374 // Beispiel: Melle Longitude
    @AppStorage("autoRefreshEnabled") var autoRefreshEnabled: Bool = true // Muss hier auch gelesen werden

    private var timer: Timer?
    // Basis-URL für die tägliche Vorhersage-API
    private let dailyForecastBaseURL = "https://api.weather.com/v1/forecast/daily/10day" // Beispiel für 10-Tages-Vorhersage

    init() {
        // Der erste Abruf wird in der onAppear-Methode der View gestartet,
        // um sicherzustellen, dass die AppStorage-Werte geladen sind.
    }

    /// Ruft die tägliche Vorhersage ab.
    @MainActor
    func fetchDailyForecast(units: String = "m") async {
        guard autoRefreshEnabled else { return } // Nur abrufen, wenn Auto-Refresh aktiviert ist

        isLoading = true
        errorMessage = nil

        // Überprüfen, ob API-Schlüssel und Koordinaten vorhanden sind
        guard !storedApiKey.isEmpty, storedApiKey != "YOUR_WEATHER_API_KEY",
              storedLatitude != 0.0, storedLongitude != 0.0 else {
            errorMessage = "Warnung: API-Schlüssel oder Koordinaten fehlen für tägliche Vorhersage. Bitte in den Einstellungen prüfen."
            dailyForecasts = []
            isLoading = false
            return
        }

        // URL-Komponenten erstellen
        var components = URLComponents(string: dailyForecastBaseURL)
        components?.queryItems = [
            URLQueryItem(name: "geocode", value: "\(storedLatitude),\(storedLongitude)"), // Geokoordinaten
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "units", value: units),
            URLQueryItem(name: "language", value: "de-DE"), // Sprache auf Deutsch setzen
            URLQueryItem(name: "apiKey", value: storedApiKey)
        ]

        guard let url = components?.url else {
            errorMessage = "Ungültige URL-Konfiguration für tägliche Vorhersage."
            dailyForecasts = []
            isLoading = false
            return
        }

        print("Versuche, tägliche Vorhersage abzurufen von URL: \(url.absoluteString)")

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code für tägliche Vorhersage: \(httpResponse.statusCode)")
                guard (200...299).contains(httpResponse.statusCode) else {
                    errorMessage = "Serverfehler beim Abruf täglicher Vorhersage. Statuscode: \(httpResponse.statusCode)"
                    dailyForecasts = []
                    print("Fehlerhafte rohe Antwort für tägliche Vorhersage: \(String(data: data, encoding: .utf8) ?? "Keine Daten")")
                    isLoading = false
                    return
                }
            }

            print("Rohe JSON-Antwort für tägliche Vorhersage: \(String(data: data, encoding: .utf8) ?? "Ungültige Daten")")

            let decoder = JSONDecoder()
            let dailyResponse = try decoder.decode(DailyForecastResponse.self, from: data)
            dailyForecasts = dailyResponse.forecasts ?? []

            if dailyForecasts.isEmpty {
                errorMessage = "Keine täglichen Vorhersagedaten gefunden."
            } else {
                print("Tägliche Vorhersage erfolgreich geladen! Anzahl Beobachtungen: \(dailyForecasts.count)")
            }

        } catch let decodingError as DecodingError {
            print("Decodierungsfehler für tägliche Vorhersage: \(decodingError.localizedDescription)")
            errorMessage = "Fehler beim Decodieren der täglichen Vorhersagedaten."
            dailyForecasts = []
        } catch {
            print("Fehler beim Abrufen täglicher Vorhersage: \(error.localizedDescription)")
            errorMessage = "Fehler beim Abrufen der täglichen Vorhersagedaten: \(error.localizedDescription)"
            dailyForecasts = []
        }
        isLoading = false
    }

    /// Startet einen Timer, der alle 5 Minuten die tägliche Vorhersage abruft.
    func startFetchingDataAutomatically() {
        timer?.invalidate() // Vorhandenen Timer ungültig machen

        guard autoRefreshEnabled else { return } // Nur starten, wenn Auto-Refresh aktiviert ist

        timer = Timer.scheduledTimer(withTimeInterval: 60.0 * 5, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.fetchDailyForecast()
            }
        }
        // Erster Abruf sofort
        Task { @MainActor in
            await self.fetchDailyForecast()
        }
    }

    /// Stoppt den automatischen Datenabruf-Timer.
    func stopFetchingDataAutomatically() {
        timer?.invalidate()
        timer = nil
    }

    deinit {
        stopFetchingDataAutomatically()
    }
}
