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
                                    WindCard(windSpeed: metricData.windSpeed ?? Double(Int(0.0)), windGust: metricData.windGust ?? Double(Int(0.0)), windDirection: Double(obs.winddir ?? Int(0.0)))
                                    NiederschlagsCard(rainToday: metricData.precipTotal ?? 0.0, rainYesterday: 0.0, rainWeek: 0.0)
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
struct NiederschlagsCard: View {
    let rainToday: Double
    let rainYesterday: Double
    let rainWeek: Double
    
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
              //Spacer()
              HStack{
                  VStack{
                      HStack{
                          Text("Heute")
                          Spacer()
                          Text(String(format: "%.0f liter", rainToday))
                      }
                      Divider()
                      HStack{
                          Text("Gestern")
                          Spacer()
                          Text(String(format: "%.0f liter", rainYesterday))
                      }
                      Divider()
                      HStack{
                          Text("Diese Woche")
                          Spacer()
                          Text(String(format: "%.0f liter ", rainWeek))
                      }
                  }
                  Spacer()
                  HStack{
                      ZStack{
                          Spacer()
                          Circle()
                              .stroke(Color.blue, lineWidth: 1)
                              .frame(width: 60, height: 60, alignment: .center)
                          Image(systemName: "arrow.up")
                              .resizable()
                              .aspectRatio(contentMode: .fit)
                              .rotationEffect(.degrees(175))
                              .frame(width: 40, height: 40, alignment: .center)
                           //   .fontWeight(arrowWeight)
                      }
                      .frame(width: 100.0, height: 100.0)
                  }
              }
              
              Spacer()
              /*
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
               */
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

struct WindCard: View {
    let windSpeed: Double
    let windGust: Double
    let windDirection: Double
    var arrowWeight: Font.Weight = .ultraLight // NEU: Gewicht des Pfeil-Fonts
   
    var body: some View {
      //  let windDirektion1: CLLocationDirection = windDirection
        let cardinalDirection = WeatherHelpers.getCardinalDirection(for: windDirection)
        
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "wind")
                    .foregroundColor(.white.opacity(0.7))
                Text("Wind")
                    .font(.footnote)
                    .foregroundColor(.white)
                Spacer()
            }
            //Spacer()
            HStack{
                VStack{
                    HStack{
                        Text("Wind")
                        Spacer()
                        Text(String(format: "%.0f km/h", windSpeed))
                    }
                    Divider()
                    HStack{
                        Text("Windböen")
                        Spacer()
                        Text(String(format: "%.0f km/h", windGust))
                    }
                    Divider()
                    HStack{
                        Text("Windrichtung")
                        Spacer()
                        Text("\(String(format: "%.0f° ", windDirection)) ,\(cardinalDirection)")
                    }
                }
                Spacer()
                HStack{
                    ZStack{
                        Spacer()
                        Circle()
                            .stroke(Color.blue, lineWidth: 1)
                            .frame(width: 60, height: 60, alignment: .center)
                        Image(systemName: "arrow.up")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .rotationEffect(.degrees(175))
                            .frame(width: 40, height: 40, alignment: .center)
                            .fontWeight(arrowWeight)
                    }
                    .frame(width: 100.0, height: 100.0)
                }
            }
            
            Spacer()
            /*
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
             */
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
/*
 // Beispiel innerhalb deiner KompassCard oder einer anderen View:
 // Angenommen, du hast einen WindDirection-Wert, z.B. von metricData.winddir oder metricData.windDirection
 let windDirection: CLLocationDirection = metricData?.winddir.map { Double($0) } ?? 0.0 // Oder metricData.windDirection ?? 0.0
 let cardinalDirection = WeatherHelpers.getCardinalDirection(for: windDirection)

 // Dann kannst du `cardinalDirection` in deiner Text-View anzeigen
 Text(cardinalDirection)
*/
 // MARK: - Hilfsstruktur für Wetterfunktionen
// Diese Struktur kann an einer geeigneten Stelle in deiner Datei (z.B. oben, oder in einer eigenen Helper-Datei) platziert werden.
struct WeatherHelpers {

    // Das Array der Himmelsrichtungen als statische Konstante
    static let cardinalDirections: [String] = [
        "N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE",
        "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"
    ]

    // Funktion zur Ermittlung der Himmelsrichtung
    // Sie sollte weiterhin in ContentView.swift, aber mit diesen Anpassungen, funktionieren
    static func getCardinalDirection(for heading: CLLocationDirection) -> String {
        // Sicherstellen, dass der übergebene Wert explizit als Double behandelt wird
        let headingValue = Double(heading)

        // Sicherstellen, dass der Winkel positiv ist und im Bereich [0, 360) liegt
        let normalizedHeading = headingValue.truncatingRemainder(dividingBy: 360.0)

        // Um 22.5 Grad verschieben für korrekte Segmentzuweisung (halbe Segmentbreite)
        let shiftedHeading = (normalizedHeading + 22.5).truncatingRemainder(dividingBy: 360.0)

        // Jeder Himmelsrichtung entspricht einem 22.5-Grad-Segment (360 / 16)
        let segmentWidth = 360.0 / Double(cardinalDirections.count)

        // Teilen durch die Segmentbreite ergibt, in welchem Segment der Winkel liegt.
        // Explizite Konvertierung zu Double vor der Division und dann zu Int
        let rawIndex = shiftedHeading / segmentWidth
        let index = Int(rawIndex)

        // Der resultierende Index sollte immer im gültigen Bereich des Arrays liegen.
        // Eine Sicherheitsprüfung, falls doch ein unerwarteter Wert entsteht.
        guard index >= 0 && index < cardinalDirections.count else {
            return "N/A" // Oder eine geeignete Standardrichtung bei einem unerwarteten Index
        }

        return cardinalDirections[index]
    }
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
                Image(systemName: "cloud.sun.rain.circle.fill")
                    .foregroundColor(.white.opacity(0.7))
                Text("Wetter Karte")
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
