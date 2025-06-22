//
//  ContentView.swift
//  Wunderground-IOS
//
//  Created by Olaf Lueg on 18.06.25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var pwsViewModel = PWSViewModel()
    @State private var showingSettingsSheet = false
    var body: some View {
        ZStack{
            LinearGradient(gradient: Gradient(colors: [Color(red: 0.2, green: 0.1, blue: 0.4), Color(red: 0.4, green: 0.1, blue: 0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            ScrollView{
                VStack{
                    if let obs = pwsViewModel.observation, let metric = obs.metric {
                        PWSInfoCard(pwsViewModel: pwsViewModel)
                    }
                }
                .padding(.top)
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
