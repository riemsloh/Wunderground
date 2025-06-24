//
//  DailyForecastViewModel.swift
//  DeineApp
//
//  Created by [Dein Name] on [Aktuelles Datum].
//  Copyright © [Aktuelles Jahr] [Dein Unternehmen]. All rights reserved.
//

import Foundation
import SwiftUI // For ObservableObject, @Published, @MainActor, @AppStorage


class DailyForecastViewModel: ObservableObject {
    @Published var dailyForecasts: [DailyForecast] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // Read configuration values directly from AppStorage
    @AppStorage("hourlyApiKey") private var storedApiKey: String = "YOUR_WEATHER_API_KEY"
    @AppStorage("latitude") private var storedLatitude: Double = 52.2039 // Example: Melle Latitude
    @AppStorage("longitude") private var storedLongitude: Double = 8.3374 // Example: Melle Longitude
    @AppStorage("autoRefreshEnabled") var autoRefreshEnabled: Bool = true // Must also be read here

    private var timer: Timer?
    private let dailyForecastBaseURL = "https://api.weather.com/v3/wx/forecast/daily/10day" // Example

    init() {
        // The first fetch is started in the onAppear method of the View,
        // to ensure that the AppStorage values are loaded.
    }

    /// Fetches the daily forecast.
    @MainActor
    func fetchDailyForecast(units: String = "m") async {
        guard autoRefreshEnabled else { return } // Only fetch if auto-refresh is enabled

        isLoading = true
        errorMessage = nil

        // Check if API key and coordinates are available
        guard !storedApiKey.isEmpty, storedApiKey != "YOUR_WEATHER_API_KEY",
              storedLatitude != 0.0, storedLongitude != 0.0 else {
            errorMessage = "Warning: API key or coordinates missing for daily forecast. Please check in settings."
            dailyForecasts = []
            isLoading = false
            return
        }

        // Create URL components
        var components = URLComponents(string: dailyForecastBaseURL)
        components?.queryItems = [
            URLQueryItem(name: "geocode", value: "\(storedLatitude),\(storedLongitude)"), // Geocoordinates
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "units", value: units),
            URLQueryItem(name: "language", value: "de-DE"), // Set language to German
            URLQueryItem(name: "apiKey", value: storedApiKey)
        ]

        guard let url = components?.url else {
            errorMessage = "Invalid URL configuration for daily forecast."
            dailyForecasts = []
            isLoading = false
            return
        }

        print("Attempting to fetch daily forecast from URL: \(url.absoluteString)")

        do {
            let (data, response) = try await URLSession.shared.data(from: url)

            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code for daily forecast: \(httpResponse.statusCode)")
                guard (200...299).contains(httpResponse.statusCode) else {
                    let receivedDataString = String(data: data, encoding: .utf8) ?? "No readable data."
                    errorMessage = "Server error fetching daily forecast. Status code: \(httpResponse.statusCode). Response: \(receivedDataString)"
                    dailyForecasts = []
                    isLoading = false
                    return
                }
            }

            if let jsonString = String(data: data, encoding: .utf8) {
                print("--- Raw JSON response for daily forecast ---")
               // debugPrint(jsonString)
                print("--------------------------------------------------")
            } else {
                print("Error: Could not decode JSON data as String.")
            }

            let decoder = JSONDecoder()
            // Here we decode the raw data structure
            let apiResponse = try decoder.decode(DailyForecastAPIResponse.self, from: data)
            
            var newForecasts: [DailyForecast] = []
            // Ensure that the daypart array exists and is not empty
            if let validTimes = apiResponse.validTimeLocal {
                for i in 0..<validTimes.count {
                    if let forecast = DailyForecast(index: i, apiResponse: apiResponse) {
                        newForecasts.append(forecast)
                    }
                }
            }
            self.dailyForecasts = newForecasts

            if dailyForecasts.isEmpty {
                errorMessage = "No daily forecast data found."
            } else {
                print("Daily forecast successfully loaded! Number of observations: \(dailyForecasts.count)")
            }

        } catch let decodingError as DecodingError {
            print("Decoding error for daily forecast: \(decodingError.localizedDescription)")
            switch decodingError {
            case .typeMismatch(let type, let context):
                errorMessage = "Type mismatch for \(type) in context: \(context.codingPath.map { $0.stringValue }.joined(separator: ".")) - \(context.debugDescription)"
            case .valueNotFound(let type, let context):
                errorMessage = "Value not found for \(type) in context: \(context.codingPath.map { $0.stringValue }.joined(separator: ".")) - \(context.debugDescription)"
            case .keyNotFound(let key, let context):
                errorMessage = "Key '\(key.stringValue)' not found in context: \(context.codingPath.map { $0.stringValue }.joined(separator: ".")) - \(context.debugDescription)"
            case .dataCorrupted(let context):
                errorMessage = "Data corrupted in context: \(context.codingPath.map { $0.stringValue }.joined(separator: ".")) - \(context.debugDescription)"
            @unknown default:
                errorMessage = "Unknown decoding error: \(decodingError.localizedDescription)"
            }
            dailyForecasts = []
        } catch {
            print("Error fetching daily forecast: \(error.localizedDescription)")
            errorMessage = "Error fetching daily forecast data: \(error.localizedDescription)"
            dailyForecasts = []
        }
        isLoading = false
    }

    /// Starts a timer that fetches the daily forecast every 5 minutes.
    func startFetchingDataAutomatically() {
        timer?.invalidate() // Invalidate existing timer

        guard autoRefreshEnabled else { return } // Only start if auto-refresh is enabled

        timer = Timer.scheduledTimer(withTimeInterval: 60.0 * 5, repeats: true) { [weak self] _ in
#if swift(>=6.0)
            Task { @MainActor in
                await self?.fetchDailyForecast()
            }
            #else
            Task {
                await self?.fetchDailyForecast()
                
            }
            #endif
        }
        // First fetch immediately
        Task { @MainActor in
            await self.fetchDailyForecast()
        }
    }

    /// Stops the automatic data fetching timer.
    func stopFetchingDataAutomatically() {
        timer?.invalidate()
        timer = nil
    }

    deinit {
        stopFetchingDataAutomatically()
    }
}
