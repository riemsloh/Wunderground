//
//  MoonCardView.swift
//  Wunderground
//
//  Created by Olaf Lueg on 24.06.25.
//

import SwiftUI

struct MoonCard: View {
    @ObservedObject var dailyForecastViewModel: DailyForecastViewModel
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    var body: some View {
        let obs = dailyForecastViewModel.dailyForecasts.first
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "moon.zzz")
                    .foregroundColor(.white.opacity(0.7))
                Text(obs?.moonPhase ?? "Mond Phase")
                    .font(.footnote)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.top, 8)
            Divider()
            HStack{
                VStack{
                    HStack{
                        Image(systemName: "moonrise.fill")
                        Text("Mondaufgang")
                        Spacer()
                        Text("\(obs?.moonriseTimeLocal ?? "N/A")")
                            .foregroundColor(.white)
                      
                    }
                    Divider()
                    HStack{
                        Image(systemName: "moonset.fill")
                        Text("Monduntergang")
                        Spacer()
                        Text("\(obs?.moonsetTimeLocal ?? "N/A")")
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                Spacer()
                
                VStack{
                    Image(systemName: moonPhaseSymbolName(forCode: obs?.moonPhaseCode))
                        .resizable()
                        .frame(width: 60, height: 60)
                }
                .frame(width: 90, height: 90)
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(width: cardWidth, height: cardHeight) 
        .cardBackground()
    }
}



// MARK: - NEU: Hilfsfunktion zur Umwandlung von MoonPhaseCode in SF Symbols Namen
 func moonPhaseSymbolName(forCode code: String?) -> String {
     guard let code = code else { return "moon.circle" } // Standard-Icon
     switch code {
     case "N": // Neumond
         return "moonphase.new.moon"
     case "WXC": // Zunehmender Sichelmond
         return "moon.waxing.crescent.fill"
     case "FQ": // Erstes Viertel
         return "moon.first.quarter.fill"
     case "WXG": // Zunehmender Halbmond
         return "moon.waxing.gibbous.fill"
     case "F": // Vollmond (nicht in Ihrem JSON-Beispiel, aber häufig)
         return "moon.fill"
     case "WNG": // Abnehmender Halbmond (nicht in Ihrem JSON-Beispiel)
         return "moon.waning.gibbous.fill"
     case "LQ": // Letztes Viertel (nicht in Ihrem JSON-Beispiel)
         return "moon.last.quarter.fill"
     case "WNC": // Abnehmender Sichelmond
         return "moon.waning.crescent.fill"
     default:
         return "moon.circle" // Fallback f\u00FCr unbekannte Codes
     }
 }
