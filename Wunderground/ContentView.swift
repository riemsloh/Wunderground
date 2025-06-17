import SwiftUI
import CoreLocation // For CLLocationDirection
import MapKit


// MARK: -
// Small tile 150*150
// Large tile 300*150 + padding
struct ContentView: View {
    @StateObject var pwsViewModel = PWSViewModel()
    @State private var selectedHistoricalDate: Date = Date() // For selecting the historical date

    var body: some View {
        ZStack {
            // MARK: - Background gradient
            LinearGradient(gradient: Gradient(colors: [Color(red: 0.2, green: 0.1, blue: 0.4), Color(red: 0.4, green: 0.1, blue: 0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView { // Use ScrollView if content might exceed screen height
                VStack(alignment: .leading, spacing: 20) {
                    
                    // MARK: - Current weather data (PWSInfoCard and current weather cards)
                    // NOTE: pwsViewModel is now passed directly to PWSInfoCard
                    if let obs = pwsViewModel.observation, let metricData = obs.metric {
                        PWSInfoCard(pwsViewModel: pwsViewModel) // --- Changed line
                            .padding([.top, .leading, .trailing])
                        
                        HStack(alignment: .top, spacing: 15){ // Main HStack for dividing into left and right columns
                            VStack(spacing: 15){
                                HStack(spacing: 15){
                                    WindCard(windSpeed: metricData.windSpeed ?? Double(Int(0.0)), windGust: metricData.windGust ?? Double(Int(0.0)), windDirection: Double(obs.winddir ?? Int(0.0)))
                                    NiederschlagsCard(rainToday: metricData.precipTotal ?? 0.0, rainYesterday: pwsViewModel.lastDayPrecipitation ?? 0.0, rainWeek: pwsViewModel.currentWeekPrecipitation ?? 0.0)
                                }
                                HStack(spacing: 15){
                                    TemperaturCard(title: "Temperatur", value: metricData.temp.map { String(format: "%.0f", $0) } ?? "N/A", iconName: "thermometer.sun.circle")
                                    LuftdruckCard(title: "Luftdruck", value: metricData.pressure.map { String(format: "%.0f", $0) } ?? "N/A", iconName: "barometer")
                                    RegenHeuteCard(title: "Regen heute", value: metricData.precipTotal.map { String(format: "%.1f", $0) } ?? "N/A", iconName: "umbrella")
                                    KompassCard(title: "Wind", value: metricData.windSpeed.map {String(format: "%.0f", $0)} ?? "N/A", iconName: "wind")
                                }
                            }
                            .frame(maxWidth: .infinity)
                            MapCard(locationName: obs.neighborhood ?? "N/A", latitude: obs.lat ?? 0.0, longitude: obs.lon ?? 0.0)
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    } else if pwsViewModel.isLoading {
                        ProgressView("Loading current weather data...")
                            .tint(.white)
                            .padding()
                    } else if let errorMessage = pwsViewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    // MARK: - Historical weather data
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Historical Weather Data")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        // Date selection for historical data
                        HStack {
                            Text("Select Date:")
                                .foregroundColor(.white.opacity(0.8))
                            DatePicker("", selection: $selectedHistoricalDate, in: ...Date(), displayedComponents: .date)
                                .datePickerStyle(.field)
                                .labelsHidden() // Hide label as text is next to it
                                .frame(width: 150) // Fixed width for DatePicker
                                .onChange(of: selectedHistoricalDate) { newDate in
                                    let formatter = DateFormatter()
                                    formatter.dateFormat = "yyyyMMdd"
                                    let dateString = formatter.string(from: newDate)
                                    Task {
                                        await pwsViewModel.fetchHistoricalWeatherData(date: dateString)
                                    }
                                }
                        }
                        .padding(.horizontal)
                        
                        if pwsViewModel.isLoading {
                            ProgressView("Loading historical data...")
                                .tint(.white)
                                .padding()
                        } else if !pwsViewModel.historicalObservations.isEmpty {
                            ScrollView(.horizontal, showsIndicators: true) {
                                HStack(spacing: 15) {
                                    ForEach(pwsViewModel.historicalObservations) { obs in
                                        HistoricalDataCard(observation: obs)
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom)
                            }
                        } else {
                            // Show specific error message if available, otherwise generic message
                            if let error = pwsViewModel.errorMessage {
                                Text("Error loading historical data: \(error)")
                                    .foregroundColor(.red)
                                    .font(.footnote)
                                    .padding(.horizontal)
                                    .padding(.bottom)
                            } else {
                                Text("No historical data available for the selected date or station ID/API key missing.")
                                    .foregroundColor(.gray)
                                    .font(.footnote)
                                    .padding(.horizontal)
                                    .padding(.bottom)
                            }
                        }
                    }
                }
                .padding(.bottom)
            }
        }
        // IMPORTANT: Start data fetching and timer as soon as this View appears.
        .onAppear {
            pwsViewModel.startFetchingDataAutomatically()
            // Load historical data for today's date on first appearance
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd"
            let dateString = formatter.string(from: selectedHistoricalDate)
            Task {
                await pwsViewModel.fetchHistoricalWeatherData(date: dateString)
            }
        }
        .onDisappear {
            // Stop the timer when the menu bar popover is closed.
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

let smallCardWidth: CGFloat = 150
let smallCardHeight: CGFloat = 150
let bigCardWidth: CGFloat = 315
let bigCardheight: CGFloat = 150
// MARK: - The Info Card
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
                    .lineLimit(2) // Allows line breaks if necessary
                Spacer()
            }
            Spacer()
        }
        .padding()
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
// MARK: - The Humidity Card
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
                    .lineLimit(2) // Allows line breaks if necessary
                Spacer()
            }
            Spacer()
        }
        .padding()
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
                    .lineLimit(2) // Allows line breaks if necessary
                Spacer()
            }
            Spacer()
        }
        .padding()
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
// MARK: - Rain yesterday
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
                    .lineLimit(2) // Allows line breaks if necessary
                Spacer()
            }
            Spacer()
        }
        .padding()
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
struct NiederschlagsCard: View {
    let rainToday: Double
    let rainYesterday: Double
    let rainWeek: Double
    
    var body: some View {
          
          VStack(alignment: .leading, spacing: 10) {
              HStack {
                  Image(systemName: "umbrella")
                      .foregroundColor(.white.opacity(0.7))
                  Text("Precipitation")
                      .font(.footnote)
                      .foregroundColor(.white)
                  Spacer()
              }
              //Spacer()
              HStack{
                  VStack{
                      HStack{
                          Text("Today")
                          Spacer()
                          Text(String(format: "%.0f liter", rainToday))
                      }
                      Divider()
                      HStack{
                          Text("Yesterday")
                          Spacer()
                          Text(String(format: "%.0f liter", rainYesterday))
                      }
                      Divider()
                      HStack{
                          Text("This Week")
                          Spacer()
                          Text(String(format: "%.0f liter", rainWeek))
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
               .lineLimit(2) // Allows line breaks if necessary
               Spacer()
               }
               Spacer()
               */
          }
          .padding()
          .frame(maxWidth: .infinity, alignment: .leading)
          .frame(width: bigCardWidth, height: bigCardheight) // Fixed height for a consistent grid
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
    var arrowWeight: Font.Weight = .ultraLight // NEW: Weight of the arrow font
   
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
                        Text("Wind Gusts")
                        Spacer()
                        Text(String(format: "%.0f km/h", windGust))
                    }
                    Divider()
                    HStack{
                        Text("Wind Direction")
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
                            .rotationEffect(.degrees(windDirection))
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
                    .lineLimit(2) // Allows line breaks if necessary
                Spacer()
            }
            Spacer()
             */
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(width: bigCardWidth, height: bigCardheight) // Fixed height for a consistent grid
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
                    .lineLimit(2) // Allows line breaks if necessary
                Spacer()
            }
            Spacer()
        }
        .padding()
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

/// Converts a degree (direction) into a cardinal direction (e.g. "N", "NW").
/// Uses 16 cardinal directions for finer granularity.
///
/// - Parameter heading: The direction in degrees (0-359.9, where 0 degrees is North).
/// - Returns: The string of the corresponding cardinal direction.
/*
 // Example within your KompassCard or another View:
 // Assuming you have a WindDirection value, e.g. from metricData.winddir or metricData.windDirection
 let windDirection: CLLocationDirection = metricData?.winddir.map { Double($0) } ?? 0.0 // Or metricData.windDirection ?? 0.0
 let cardinalDirection = WeatherHelpers.getCardinalDirection(for: windDirection)

 // Then you can display `cardinalDirection` in your Text View
 Text(cardinalDirection)
*/
 // MARK: - Helper structure for weather functions
// This structure can be placed in a suitable location in your file (e.g. above, or in a separate Helper file).
struct WeatherHelpers {

    // The array of cardinal directions as a static constant
    static let cardinalDirections: [String] = [
        "N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE",
        "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"
    ]

    // Function to determine the cardinal direction
    // It should still work in ContentView.swift, but with these adjustments
    static func getCardinalDirection(for heading: CLLocationDirection) -> String {
        // Ensure that the passed value is explicitly treated as a Double
        let headingValue = Double(heading)

        // Ensure that the angle is positive and in the range [0, 360)
        let normalizedHeading = headingValue.truncatingRemainder(dividingBy: 360.0)

        // Shift by 22.5 degrees for correct segment assignment (half segment width)
        let shiftedHeading = (normalizedHeading + 22.5).truncatingRemainder(dividingBy: 360.0)

        // Each cardinal direction corresponds to a 22.5-degree segment (360 / 16)
        let segmentWidth = 360.0 / Double(cardinalDirections.count)

        // Dividing by the segment width gives the segment in which the angle lies.
        // Explicit conversion to Double before division and then to Int
        let rawIndex = shiftedHeading / segmentWidth
        let index = Int(rawIndex)

        // The resulting index should always be within the valid range of the array.
        // A safety check in case an unexpected value occurs.
        guard index >= 0 && index < cardinalDirections.count else {
            return "N/A" // Or a suitable default direction for an unexpected index
        }

        return cardinalDirections[index]
    }
}

struct MapCard: View {
    // This must be an @State as the map can change the region (e.g. by zooming/panning by the user).
        @State private var region: MKCoordinateRegion
        // Optional: A marker for the location
        let locationName: String
        let coordinate: CLLocationCoordinate2D
        init(locationName: String, latitude: Double, longitude: Double) {
            self.locationName = locationName
            self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            // Initialize the region with the passed location
            _region = State(initialValue: MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1) // Zoom level (smaller values = stronger zoom)
            ))
        }
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "cloud.sun.rain.circle.fill")
                    .foregroundColor(.white.opacity(0.7))
                Text("Weather Map")
                    .font(.footnote)
                    .foregroundColor(.white)
                Spacer()
            }
           // Spacer()
            HStack(alignment: .center){
                Spacer()
                Map(coordinateRegion: $region, annotationItems: [IdentifiableLocation(id: UUID(), name: locationName, coordinate: coordinate)]) { location in
                    // Optional Annotation (Marker or custom view)
                    MapMarker(coordinate: location.coordinate, tint: .red) // A simple red marker
                }
                .edgesIgnoringSafeArea(.all) // Extend map across entire screen area (optional)
                .frame(width: 180, height: 250.0)
        //        Spacer()
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(width: 200, height: 300) // Fixed height for a consistent grid
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}
struct IdentifiableLocation: Identifiable {
    let id: UUID // A unique ID
    let name: String
    let coordinate: CLLocationCoordinate2D // The coordinates of the location
}

// MARK: - HistoricalDataCard (New component for displaying historical data)
struct HistoricalDataCard: View {
    let observation: HistoricalObservation

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.white.opacity(0.7))
                Text(observation.formattedDateTime) // Displays date and time
                    .font(.footnote)
                    .foregroundColor(.white)
                Spacer()
            }
            Divider().background(Color.white.opacity(0.3)) // Separator line
            
            HStack {
                Text("Avg. Temp.:")
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
                // Access via observation.metric?.tempAvg
                Text(observation.metric?.tempAvg.map { String(format: "%.1f°C", $0) } ?? "N/A")
                    .foregroundColor(.white)
            }
            HStack {
                Text("Max Temp.:")
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
                // Access via observation.metric?.tempHigh
                Text(observation.metric?.tempHigh.map { String(format: "%.1f°C", $0) } ?? "N/A")
                    .foregroundColor(.red)
            }
            HStack {
                Text("Min Temp.:")
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
                // Access via observation.metric?.tempLow
                Text(observation.metric?.tempLow.map { String(format: "%.1f°C", $0) } ?? "N/A")
                    .foregroundColor(.blue)
            }
            Divider().background(Color.white.opacity(0.3)) // Separator line
            
            HStack {
                Text("Precipitation:")
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
                // Access via observation.metric?.precipTotal
                Text(observation.metric?.precipTotal.map { String(format: "%.1f l", $0) } ?? "N/A")
                    .foregroundColor(.white)
            }
            
            HStack {
                Text("Avg. Wind:")
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
                // Access via observation.metric?.windspeedAvg
                Text(observation.metric?.windspeedAvg.map { String(format: "%.0f km/h", Double($0)) } ?? "N/A")
                    .foregroundColor(.white)
            }
            
            HStack {
                Text("Avg. Humidity.:")
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
                // Access via observation.humidityAvg (since it's on top-level as per your JSON and PWSModels)
                Text(observation.humidityHigh.map { String(format: "%.0f%%", Double($0)) } ?? "N/A")
                    .foregroundColor(.white)
            }
            
            // Add more relevant historical data here
        }
        .padding()
        .frame(width: smallCardWidth + 50, height: 220) // Adjusted size for more information
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        // Debug outputs moved to onAppear
        .onAppear {
            print("--- HistoricalDataCard Debug ---")
            print("obsTimeLocal: \(observation.obsTimeLocal ?? "nil")")
            print("tempAvg (from metric): \(observation.metric?.windspeedAvg ?? 100)")
           /* print("tempHigh (from metric): \(observation.metric?.tempHigh.map(String.init) ?? "nil")")
            print("tempLow (from metric): \(observation.metric?.tempLow.map(String.init) ?? "nil")")
            print("precipTotal (from metric): \(observation.metric?.precipTotal.map(String.init) ?? "nil")")
            print("windspeedAvg (from metric): \(observation.metric?.windspeedAvg.map(String.init) ?? "nil")")
            print("humidityAvg (top-level): \(observation.humidityAvg.map(String.init) ?? "nil")")*/
            print("------------------------------")
        }
    }
}
