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
    @State private var isTapped: Bool = false
    @State private var showingDetailPopover: Bool = false
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
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0)) {
                isTapped.toggle()
            }
            // Optional: Nach einer kurzen Verz\u00F6gerung zur\u00FCcksetzen, wenn es ein tempor\u00E4rer Effekt sein soll
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0)) {
                    isTapped = false
                }
            }
            showingDetailPopover = true
        }
        // Wende die Animationseffekte basierend auf 'isTapped' an
        .scaleEffect(isTapped ? 1.05 : 1.0) // Leicht vergr\u00F6\u00DFern beim Tippen
        .rotationEffect(.degrees(isTapped ? 3.0 : 0)) // Leicht kippen
        .shadow(color: isTapped ? .blue.opacity(0.6) : .black.opacity(0.3), radius: isTapped ? 10 : 5) // St\u00E4rkerer Schatten
        // ... (Deine bestehenden Modifier wie .cardBackground(), .frame() etc.) ...
        .popover(isPresented: $showingDetailPopover){
            VStack{
                DetailMoonCardView()
            }
            .padding()
            .onTapGesture {
                showingDetailPopover = false
            }
            .presentationCompactAdaptation(.popover)
        }
                
                
    }
}

struct DetailMoonCardView: View {
    var body: some View {
        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Hello, world!@*/Text("Hello, world!")/*@END_MENU_TOKEN@*/
    }
}

// MARK: - NEU: Hilfsfunktion zur Umwandlung von MoonPhaseCode in SF Symbols Namen
 func moonPhaseSymbolName(forCode code: String?) -> String {
     guard let code = code else { return "moon.circle" } // Standard-Icon
     switch code {
     case "N": // Neumond
         return "moonphase.new.moon"
     case "WXC": // Zunehmender Sichelmond
         return "moonphase.waxing.crescent"
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
