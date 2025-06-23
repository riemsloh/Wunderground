//
//  ContentView.swift
//  Wunderground-IOS
//
//  Created by Olaf Lueg on 18.06.25.
//

import SwiftUI


let smallCardWidth: CGFloat = 150
let smallCardHeight: CGFloat = 150
let bigCardWidth: CGFloat = 315
let bigCardheight: CGFloat = 150


struct ContentView: View {
    @StateObject var pwsViewModel = PWSViewModel()
    @State private var showingSettingsSheet = false
    var body: some View {
        ZStack{
            LinearGradient(gradient: Gradient(colors: [Color(red: 0.2, green: 0.1, blue: 0.4), Color(red: 0.4, green: 0.1, blue: 0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            ScrollView{
                VStack{
                    MainCard(pwsViewModel: pwsViewModel)
                    
                    /*
                    if let obs = pwsViewModel.observation, let metric = obs.metric {
                        PWSInfoCard(pwsViewModel: pwsViewModel)
                    }
                     */
                }
                .padding(.top)
                HStack{
                 //   DummyCard()
                    PrecipitationCard(pwsViewModel: pwsViewModel)
                }
                
            }
        }
        .padding()
        // IMPORTANT: Start data fetching and timer as soon as this View appears.
        .onAppear {
            pwsViewModel.startFetchingDataAutomatically()
        }
        .onDisappear {
            // Stop the timer when the menu bar popover is closed.
            pwsViewModel.stopFetchingDataAutomatically()
        }
        Spacer()
        Button(action: {
            showingSettingsSheet = true
        }){
            Image(systemName: "gearshape.fill") // Ein Zahnrad-Symbol
                .font(.title)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .clipShape(Circle())
                .shadow(radius: 5)
        }
        .sheet(isPresented: $showingSettingsSheet){
            SettingsView()
        }
    }
}

#Preview {
    ContentView()
}

// MARK: - Die Hauptkarte Für Staion Name und Temperatur. Ohne Rahmen
struct MainCard: View {
    @ObservedObject var pwsViewModel: PWSViewModel  // PWS Model
    var body: some View {
        VStack{
            HStack{
                Text("\(pwsViewModel.observation?.neighborhood ?? "N/A")")  //Stations Name
                    .font(.largeTitle)
            }
            .padding(.vertical, 4.0)
            HStack{
                Text(pwsViewModel.observation?.metric?.temp.map { String(format: "%0.f°C", $0) } ?? "N/A") // Die Aktuelle Temperatur
                    .font(.largeTitle)
            }
            .padding(.bottom)
        }
        .foregroundColor(.white)
    }
}

// MARK - Die Niederschlags Karte
// Anzeigen der Regen Mengen von Heute, Gestern und diese Woche
struct PrecipitationCard: View {
    @ObservedObject var pwsViewModel: PWSViewModel
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "umbrella")
                    .foregroundColor(.white.opacity(0.7))
                Text("Niederschlag")
                    .font(.footnote)
                    .foregroundColor(.white)
                Spacer()
            }
            Divider()
            VStack{
                HStack{
                    Text("Regen heute")
                    Spacer()
                    Text(pwsViewModel.observation?.metric?.precipTotal.map { String(format: "%0.f Liter", $0)} ?? "N/A")
                }
                Divider()
                HStack{
                    Text("Regen gestern")
                    Spacer()
                    Text(pwsViewModel.lastDayPrecipitation.map { String(format: "%0.f Liter", $0)} ?? "N/A")
                }
                Divider()
                HStack{
                    Text("Regen woche")
                    Spacer()
                    Text(pwsViewModel.currentWeekPrecipitation.map { String(format: "%0.f Liter", $0)} ?? "N/A")
                }
            }
            .font(.footnote)
            Spacer()
        }
      .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(width: bigCardWidth, height: bigCardheight) // Fixed height for a consistent grid
        .cardBackground()

    }
}
// MARK: - PWSInfoCard
struct PWSInfoCard: View {
    @ObservedObject var pwsViewModel: PWSViewModel // --- Changed line: no initialization here anymore
    

    // Explicit Initializer to fix Ambiguous Use error
    init(pwsViewModel: PWSViewModel) {
        self._pwsViewModel = ObservedObject(wrappedValue: pwsViewModel)
    }

    var body: some View {
        let currentStatusColor: Color = pwsViewModel.isLoading ? Color.yellow : Color.green
        let automaticLoading: String = pwsViewModel.autoRefreshEnabled ? "ON" : "OFF"
        let obs = pwsViewModel.observation
        VStack(alignment: .leading, spacing: 10) { // A VStack to group the two text lines
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(currentStatusColor)
                    .font(.title2)
                Text("Weather Station")
                    .foregroundColor(.white)
                    .font(.headline)
                Image(systemName: "lock.fill") // Placeholder for Moonlock symbol
                    .foregroundColor(.white)
                Text("\(obs?.neighborhood ?? "N/A")")
                    .foregroundColor(.white)
                    .font(.headline)
                Spacer()
               // Text("\(obs?.metric?.temp ?? 0)")
                Text(String(format: "%.0f °", obs?.metric?.temp ?? "N/A"))
                    .font(.headline )
                Spacer()
                Image(systemName: "checkmark.shield.fill")
                    .foregroundColor(.green)
                Text("Protected")
                    .foregroundColor(.white)
            }
            .padding([.top, .horizontal]) // Padding only top and horizontal for this HStack

            VStack(alignment: .leading) {
                Text("Real-time Weather Monitoring \(automaticLoading)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                Text("Last update: \(obs?.formattedDayAndDate ?? "N/A")")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding([.bottom, .horizontal]) // Padding only bottom and horizontal for this VStack
        }
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}

struct DummyCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(width: 150, height: 150) // Fixed height for a consistent grid
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}
