//
//  MainView.swift
//  Wunderground
//
//  Created by Olaf Lueg on 03.07.25.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        ScrollView{
            VStack{
                HStack{
                    Text("Donnerstag, 3 Juli 22:14")
                    Spacer()
                }
               
                HStack{
                    Text("Heute")
                        .font(.title)
                    Spacer()
                    Image(systemName: "house.and.flag.circle.fill")
                        .foregroundColor(.green)
                        .font(.title)
                    
                }
                .padding(.top, 1.0)
                HStack {
                    // MARK: - Die Karte mit einfachem Schatten
                    VStack {
                        /*
                        Image("29")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 250, height: 200, alignment: .center)
                          */
                        ZStack{
                            Circle()
                                .stroke(Color.blue, lineWidth: 5) // Zeichnet einen blauen Ring mit 5 Punkten Dicke
                                .frame(width: 110, height: 110) // Legt die Gr\u00F6\u00DFe des Rings fest
                                .padding(.top, 20) // Abstand zum oberen Inhalt
                                
                            Text("18°C")
                                .font(.title)
                                .multilineTextAlignment(.center)
                                .padding(.top)
                                .frame(width: 100, height: 100, alignment: .center)
                        }
                        Text("18°C")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding()
                        
                        Text("Dies ist eine Karte mit einem einfachen Schattenrahmen.")
                            .font(.body)
                            .foregroundColor(.black.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(width: 500, height: 400) // Feste Gr\u00F6\u00DFe der Karte
                    // Hintergrund der Karte (einfache Farbe oder subtiler Gradient)
                    .background(Color.white) // Ein einfacher, leicht transparenter grauer Hintergrund
                    .cornerRadius(15) // Abgerundete Ecken
                    
                    // MARK: - Einfacher Schatten f\u00FCr die Karte
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5) // Ein einziger, einfacher Schatten
                    
                    // MARK: - Optionaler, einfacher Rand (nicht transparent, wenn gew\u00FCnscht)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1) // Ein subtiler, heller Rand
                    )
                    
                    Spacer() // Schiebt die Karte nach links
                }
                
            }
            .padding()
        }
        
    }
}

#Preview {
    MainView()
}
