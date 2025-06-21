//
//  DailyForecastView.swift
//  DeineApp
//
//  Created by [Dein Name] on [Aktuelles Datum].
//  Copyright © [Aktuelles Jahr] [Dein Unternehmen]. All rights reserved.
//

import SwiftUI


struct DailyForecastView: View {
    @StateObject var dailyForecastViewModel = DailyForecastViewModel()

    var body: some View {
        ZStack {
            // MARK: - Hintergrund-Farbverlauf
            LinearGradient(gradient: Gradient(colors: [Color(red: 0.1, green: 0.1, blue: 0.3), Color(red: 0.3, green: 0.1, blue: 0.5)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)

            VStack(alignment: .leading, spacing: 20) {
                Text("Tägliche Vorhersage (Nächste 10 Tage)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal)

                if dailyForecastViewModel.isLoading {
                    ProgressView("Lade tägliche Vorhersage...")
                        .tint(.white)
                        .padding()
                } else if !dailyForecastViewModel.dailyForecasts.isEmpty {
                    ScrollView(.horizontal, showsIndicators: true) {
                        HStack(spacing: 15) {
                            ForEach(dailyForecastViewModel.dailyForecasts) { forecast in
                                DailyForecastCard(forecast: forecast)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                } else {
                    Text(dailyForecastViewModel.errorMessage ?? "Keine täglichen Vorhersagedaten verfügbar.")
                        .foregroundColor(.gray)
                        .font(.footnote)
                        .padding(.horizontal)
                        .padding(.bottom)
                }
                Spacer() // Schiebt den Inhalt nach oben
            }
        }
        .onAppear {
            dailyForecastViewModel.startFetchingDataAutomatically()
        }
        .onDisappear {
            dailyForecastViewModel.stopFetchingDataAutomatically()
        }
    }
}

// MARK: - DailyForecastCard für die tägliche Vorhersage
struct DailyForecastCard: View {
    let forecast: DailyForecast

    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            Text(forecast.formattedDateString) // Verwendet die neue formatierte Eigenschaft
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.bottom, 2)

            Divider().background(Color.white.opacity(0.3))

            // Tagestemperatur und Icon
            HStack(spacing: 5) {
                // Icon für den Tagesteil
                Image(systemName: iconNameForCode(forecast.dayPart?.iconCode, isNight: false))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.yellow)
                Text("Tag: \(forecast.maxTemp)°C") // Direkt von DailyForecast
                    .font(.callout)
                    .foregroundColor(.white)
            }

            // Nachttemperatur und Icon
            HStack(spacing: 5) {
                // Icon für den Nachttil
                Image(systemName: iconNameForCode(forecast.nightPart?.iconCode, isNight: true))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.blue)
                Text("Nacht: \(forecast.minTemp)°C") // Direkt von DailyForecast
                    .font(.callout)
                    .foregroundColor(.white)
            }
            
            // Beschreibung (Gesamt-Narrative vom Tag)
            Text(forecast.narrative)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .lineLimit(2) // Begrenzung, falls Narrative zu lang ist
                .minimumScaleFactor(0.7) // Verkleinert Text, falls nötig
                .padding(.vertical, 1)

            // Niederschlagswahrscheinlichkeit (vom Tagesteil oder direkt qpf)
            if let dayPartPop = forecast.dayPart?.precipChance {
                Text("POP (Tag): \(dayPartPop)%")
                    .font(.caption2)
                    .foregroundColor(.green)
            } else if let nightPartPop = forecast.nightPart?.precipChance {
                Text("POP (Nacht): \(nightPartPop)%")
                    .font(.caption2)
                    .foregroundColor(.green)
            }
            // Oder falls Sie QPF anzeigen möchten:
            Text(String(format: "Regen: %.1f l", forecast.qpf))
                .font(.caption2)
                .foregroundColor(.green)
        }
        .padding(10)
        .frame(width: 150, height: 200) // Angepasste Größe
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }

    // Hilfsfunktion zur Umwandlung von iconCode in SF Symbols Namen
    func iconNameForCode(_ code: Int?, isNight: Bool = false) -> String {
        print( code)
        guard let code = code else { return "questionmark.circle" }
        switch code {
        case 1...4: return isNight ? "moon.stars.fill" : "sun.max.fill" // Sunny, Mostly Sunny
        case 5...8: return isNight ? "cloud.moon.fill" : "cloud.sun.fill" // Partly Cloudy, Scattered Clouds
        case 9...10: return "cloud.fill" // Cloudy, Overcast
        case 11...12: return "cloud.drizzle.fill" // Showers
        case 13...14: return "cloud.rain.fill" // Rain
        case 15...16: return "cloud.bolt.rain.fill" // Thunderstorms
        case 17...18: return "cloud.heavyrain.fill" // Heavy Rain
        case 19...22: return "cloud.snow.fill" // Snow
        case 23...26: return "cloud.fog.fill" // Fog, Mist
        case 27...28: return "wind" // Windy
        case 29...30: return "tornado" // Tornado
        case 31...32: return isNight ? "moon.fill" : "thermometer.sun.fill" // Hot (Placeholder for night)
        case 33...34: return "thermometer.snowflake" // Cold
        default: return "questionmark.circle"
        }
    }
}


// MARK: - Previews
struct DailyForecastView_Previews: PreviewProvider {
    static var previews: some View {
        DailyForecastView()
    }
}
