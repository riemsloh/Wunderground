import SwiftUI
import CoreLocation // Für CLLocationDirection
import MapKit


// MARK: -
// Kleine Kachel 150*150
// Grße Kachel 300*150 + padding
struct ContentView: View {
       @StateObject var pwsViewModel = PWSViewModel()

    var body: some View {
        ZStack {
            // MARK: - Hintergrund-Farbverlauf
            LinearGradient(gradient: Gradient(colors: [Color(red: 0.2, green: 0.1, blue: 0.4), Color(red: 0.4, green: 0.1, blue: 0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            // Überprüfen, ob Beobachtungsdaten und metrische Daten verfügbar sind.
            if let obs = pwsViewModel.observation, let metricData = obs.metric {
                ScrollView { // Verwenden Sie ScrollView, wenn der Inhalt die Bildschirmhöhe überschreiten könnte
                    VStack(alignment: .leading, spacing: 20) {
                        PWSInfoCard(pwsViewModel: pwsViewModel)
                            .padding([.top, .leading, .trailing])
                        // MARK: - NEU: Haupt-HStack für die Zwei-Spalten-Anordnung
                        HStack(alignment: .top, spacing: 15){// Haupt-HStack für die Aufteilung in linke und rechte Spalte
                            // Linke Spalte: Die Niederschlags-Karte
                           
                            VStack(spacing: 15){
                                HStack(spacing: 15){
                                    WindCard(title: "Wind", value: "15", iconName: "wind")
                                    RegenHeuteCard(title: "Regen heute", value: metricData.precipTotal.map { String(format: "%.1f", $0) } ?? "N/A", iconName: "umbrella")
                                    RegenGesternCard(title: "Regen heute", value: metricData.precipTotal.map { String(format: "%.1f", $0) } ?? "N/A", iconName: "umbrella")
                                }
                                HStack(spacing: 15){
                                    TemperaturCard(title: "Temperatur", value: metricData.temp.map { String(format: "%.0f", $0) } ?? "N/A", iconName: "thermometer.sun.circle")
                                    LuftdruckCard(title: "Luftdruck", value: metricData.pressure.map { String(format: "%.0f", $0) } ?? "N/A", iconName: "barometer")
                                    RegenHeuteCard(title: "Regen heute", value: metricData.precipTotal.map { String(format: "%.1f", $0) } ?? "N/A", iconName: "umbrella")
                                    KompassCard(title: "Wind", value: metricData.windSpeed.map {String(format: "%.0f", $0)} ?? "N/A", iconName: "wind")
                                }
                                
                            }
                            .frame(maxWidth: .infinity)
                            MapCard(locationName: "Riemsloh", latitude: 52.1833, longitude: 8.4167)
                            
                            
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                        
                    }
                    .padding(.bottom)
                }
            }
        }
        // WICHTIG: Starte den Datenabruf und den Timer, sobald dieses View erscheint.
        .onAppear {
            // stationId und apiKey Parameter entfernt, da ViewModel sie direkt aus AppStorage liest.
            pwsViewModel.startFetchingDataAutomatically()
            // Daten für die stündliche Vorhersage beim Erscheinen der ContentView laden
            // Nur laden, wenn noch keine Daten vorhanden sind und nicht bereits geladen wird
          //  if hourlyViewModel.hourlyForecasts.isEmpty && !hourlyViewModel.isLoading {
           //     Task {
            //        await hourlyViewModel.fetchHourlyWeatherData()
            //    }
           // }
        }
        .onDisappear {
            // Stoppe den Timer, wenn das Menüleisten-Pop-over geschlossen wird.
            pwsViewModel.stopFetchingDataAutomatically()
            
        }
    }
 
}

// MARK: - ContentView_Previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct PWSInfoCard: View {
    @ObservedObject var pwsViewModel = PWSViewModel()
    var body: some View {
        let currentStatusColor: Color = pwsViewModel.isLoading ? Color.yellow : Color.green
        let automaticLoading: String = pwsViewModel.autoRefreshEnabled ? "EIN" : "AUS"
        let obs = pwsViewModel.observation
        VStack(alignment: .leading, spacing: 10) { // Ein VStack, um die zwei Textzeilen zu gruppieren
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(currentStatusColor)
                    .font(.title2)
                Text("Wetterstation")
                    .foregroundColor(.white)
                    .font(.headline)
                Image(systemName: "lock.fill") // Platzhalter für Moonlock-Symbol
                    .foregroundColor(.white)
                Text("\(obs?.neighborhood ?? "N/A")")
                    .foregroundColor(.white)
                    .font(.headline)
                Spacer()
                Image(systemName: "checkmark.shield.fill")
                    .foregroundColor(.green)
                Text("Geschützt")
                    .foregroundColor(.white)
            }
            .padding([.top, .horizontal]) // Padding nur oben und horizontal für diese HStack

            VStack(alignment: .leading) {
                Text("Echtzeit-Wetterüberwachung \(automaticLoading)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                Text("Letztes update: \(obs?.formattedDayAndDate ?? "N/A")")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding([.bottom, .horizontal]) // Padding nur unten und horizontal für diese VStack
        }
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}

let smallCardWidth: CGFloat = 150
let smallCardHeight: CGFloat = 150
let bigCardWidth: CGFloat = 315
let bigCardheight: CGFloat = 150
// MARK: - Die Info Karte
struct TemperaturCard: View {
    let title: String
    let value: String
    let iconName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(.white.opacity(0.7))
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white)
                Spacer()
            }
            Spacer()
            HStack(alignment: .center){
                Spacer()
                Text("\(value)°")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2) // Erlaubt den Zeilenumbruch, falls nötig
                Spacer()
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(width: 150, height: 150) // Feste Höhe für ein konsistentes Raster
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}
// MARK: - Die Luftfeuchtigkeits Karte
struct LuftdruckCard: View {
    let title: String
    let value: String
    let iconName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(.white.opacity(0.7))
                Text(title)
                    .font(.footnote)
                    .foregroundColor(.white)
                Spacer()
            }
            Spacer()
            HStack(alignment: .center){
                Spacer()
                Text("\(value)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2) // Erlaubt den Zeilenumbruch, falls nötig
                Spacer()
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(width: 150, height: 150) // Feste Höhe für ein konsistentes Raster
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}

struct RegenHeuteCard: View {
    let title: String
    let value: String
    let iconName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(.white.opacity(0.7))
                Text(title)
                    .font(.footnote)
                    .foregroundColor(.white)
                Spacer()
            }
            Spacer()
            HStack(alignment: .center){
                Spacer()
                Text("\(value)l")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2) // Erlaubt den Zeilenumbruch, falls nötig
                Spacer()
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(width: 150, height: 150) // Feste Höhe für ein konsistentes Raster
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}
// MARK: - Regen gestern
struct RegenGesternCard: View {
    let title: String
    let value: String
    let iconName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(.white.opacity(0.7))
                Text(title)
                    .font(.footnote)
                    .foregroundColor(.white)
                Spacer()
            }
            Spacer()
            HStack(alignment: .center){
                Spacer()
                Text("\(value)l")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2) // Erlaubt den Zeilenumbruch, falls nötig
                Spacer()
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(width: 150, height: 150) // Feste Höhe für ein konsistentes Raster
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}
struct WindCard: View {
    let title: String
    let value: String
    let iconName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(.white.opacity(0.7))
                Text(title)
                    .font(.footnote)
                    .foregroundColor(.white)
                Spacer()
            }
            Spacer()
            HStack(alignment: .center){
                Spacer()
                Text("\(value)l")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2) // Erlaubt den Zeilenumbruch, falls nötig
                Spacer()
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(width: bigCardWidth, height: bigCardheight) // Feste Höhe für ein konsistentes Raster
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}
struct KompassCard: View {
    let title: String
    let value: String
    let iconName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(.white.opacity(0.7))
                Text(title)
                    .font(.footnote)
                    .foregroundColor(.white)
                Spacer()
            }
            Spacer()
            HStack(alignment: .center){
                Spacer()
                Text("\(value) km/h")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2) // Erlaubt den Zeilenumbruch, falls nötig
                Spacer()
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(width: 150, height: 150) // Feste Höhe für ein konsistentes Raster
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}

/// Wandelt eine Gradzahl (Himmelsrichtung) in eine kardinale Himmelsrichtung (z.B. "N", "NW") um.
/// Verwendet 16 Himmelsrichtungen für eine feinere Granularität.
///
/// - Parameter heading: Die Himmelsrichtung in Grad (0-359.9, wobei 0 Grad Norden ist).
/// - Returns: Der String der entsprechenden Himmelsrichtung.
func getCardinalDirection(for heading: CLLocationDirection) -> String {
    // Array mit den 16 Himmelsrichtungen im Uhrzeigersinn, beginnend mit Nord (N)
    let directions = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE",
                      "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
    
    // Die Breite jedes Richtungssegments in Grad (360 Grad / 16 Richtungen)
    let segmentWidth = 360.0 / Double(directions.count) // 22.5 Grad pro Segment
    
    // Verschieben des Winkels, um sicherzustellen, dass die Mitte des "N"-Segments
    // bei 0 Grad liegt. Normalerweise beginnt jedes Segment bei x und endet bei x + segmentWidth.
    // Durch das Hinzufügen von der Hälfte der Segmentbreite (`segmentWidth / 2`) wird der Winkel
    // so verschoben, dass 0 Grad genau in die Mitte des "N"-Segments fällt.
    // Die 360-Grad-Modulo-Operation (`.truncatingRemainder(dividingBy: 360)`)
    // stellt sicher, dass der Winkel im Bereich [0, 360) bleibt.
    let shiftedHeading = (heading + segmentWidth / 2).truncatingRemainder(dividingBy: 360)
    
    // Berechne den Index im 'directions'-Array.
    // Teilen durch die Segmentbreite ergibt, in welchem Segment der Winkel liegt.
    // Int() schneidet Nachkommastellen ab, um den Array-Index zu erhalten.
    let index = Int(shiftedHeading / segmentWidth)
    
    // Der resultierende Index sollte immer im gültigen Bereich des Arrays liegen.
    // Aber zur Sicherheit nochmals modulo der Array-Größe anwenden, falls es zu Rundungsfehlern kommt
    // oder wenn der `heading`-Wert außerhalb von 0-360 liegt.
    let safeIndex = (index % directions.count + directions.count) % directions.count
    
    return directions[safeIndex]
}

struct MapCard: View {
    // Dies muss ein @State sein, da die Karte die Region ändern kann (z.B. durch Zoomen/Schwenken des Benutzers).
        @State private var region: MKCoordinateRegion
        // Optional: Ein Marker für den Standort
        let locationName: String
        let coordinate: CLLocationCoordinate2D
        init(locationName: String, latitude: Double, longitude: Double) {
            self.locationName = locationName
            self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            // Initialisiere die Region mit dem übergebenen Standort
            _region = State(initialValue: MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1) // Zoom-Level (kleinere Werte = stärkerer Zoom)
            ))
        }
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "umbrella.fill")
                    .foregroundColor(.white.opacity(0.7))
                Text("Niederschlag")
                    .font(.footnote)
                    .foregroundColor(.white)
                Spacer()
            }
           // Spacer()
            HStack(alignment: .center){
                Spacer()
                Map(coordinateRegion: $region, annotationItems: [IdentifiableLocation(id: UUID(), name: locationName, coordinate: coordinate)]) { location in
                    // Optionale Annotation (Marker oder benutzerdefinierte Ansicht)
                    MapMarker(coordinate: location.coordinate, tint: .red) // Ein einfacher roter Marker
                }
                .edgesIgnoringSafeArea(.all) // Karte über den gesamten Bildschirmbereich ausdehnen (optional)
                .frame(width: 180, height: 250.0)
        //        Spacer()
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(width: 200, height: 300) // Feste Höhe für ein konsistentes Raster
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}
struct IdentifiableLocation: Identifiable {
    let id: UUID // Eine eindeutige ID
    let name: String
    let coordinate: CLLocationCoordinate2D // Die Koordinaten des Standorts
}
