//
//  Modifier.swift
//  Wunderground
//
//  Created by Olaf Lueg on 23.06.25.
//

import SwiftUI

// MARK: - CardBackgroundModifier
/// Ein benutzerdefinierter ViewModifier, um einen konsistenten Hintergrund- und Randstil f\u00FCr Karten zu definieren.
struct CardBackgroundModifier: ViewModifier {
    // Der body(content:) der ViewModifier-Methode empf\u00E4ngt die View,
    // auf die der Modifikator angewendet wird (hier als 'content' bezeichnet).
    func body(content: Content) -> some View {
        content
            .background(Color.white.opacity(0.1)) // Hintergrundfarbe mit Transparenz
            .cornerRadius(15) // Abgerundete Ecken
            .overlay(
                // Ein abgerundetes Rechteck als Rand, ebenfalls mit Transparenz
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(radius: 5) // F\u00FCgen Sie hier optional einen Schatten hinzu
    }
}

// MARK: - View Extension
/// Eine Erweiterung auf View, um den ViewModifier einfacher anwenden zu k\u00F6nnen.
extension View {
    func cardBackground() -> some View {
        self.modifier(CardBackgroundModifier())
    }
}

