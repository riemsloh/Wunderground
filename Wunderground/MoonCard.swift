//
//  MoonCardView.swift
//  Wunderground
//
//  Created by Olaf Lueg on 24.06.25.
//

import SwiftUI

struct MoonCard: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    MoonCard()
}

// MARK: - NEU: Hilfsfunktion zur Umwandlung von MoonPhaseCode in SF Symbols Namen
 func moonPhaseSymbolName(forCode code: String?) -> String {
     guard let code = code else { return "moon.circle" } // Standard-Icon
     switch code {
     case "N": // Neumond
         return "moon.new.fill"
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
