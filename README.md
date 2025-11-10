


https://github.com/user-attachments/assets/94b0107c-fd76-48df-aa37-c069cf4c29df


# 🌦️ WeatherApp — SwiftUI MVVM Example

## 📘 Overview
This SwiftUI application demonstrates the **MVVM (Model-View-ViewModel)** architecture using a **Weather App** example.  
It fetches live weather data from the [WeatherAPI](https://www.weatherapi.com/) and displays it beautifully with SwiftUI components such as `AsyncImage`, `NavigationStack`, `ProgressView`, and custom views.  
The app handles **loading**, **error**, and **data states** elegantly with reactive UI updates.

---

## 📂 Folder Structure

WeatherApp

  - WeatherAppApp.swift

Model

  - WeatherResponse.swift
  - WeatherError.swift

View

  - WeatherView.swift
  - WeatherCard.swift
  - ErrorMessageView.swift

ViewModel

  - WeatherViewModel.swift


## 🚀 Features
- 🌍 Fetch live weather data from WeatherAPI  
- 🧭 Uses **Swift Concurrency (async/await)**  
- 📱 Designed using **SwiftUI + MVVM pattern**  
- ⚡ Real-time UI updates using `@Observable` and `@State`  
- ❄️ Celsius / Fahrenheit toggle  
- 💬 Friendly error handling and retry prompts  

---

## 🧩 Code Implementation
---
Model
---

### **WeatherResponse.swift**
```swift
import Foundation

// MARK: - WeatherResponse
struct WeatherResponse: Codable {
    let location: Location
    let current: Current
}

// MARK: - Current
struct Current: Codable {
    let tempC, tempF: Double
    let condition: Condition
    let feelslikeC, feelslikeF: Double
    
    
    enum CodingKeys: String, CodingKey {
        case tempC = "temp_c"
        case tempF = "temp_f"
        case condition
        case feelslikeC = "feelslike_c"
        case feelslikeF = "feelslike_f"
    }
}

// MARK: - Condition
struct Condition: Codable {
    let text, icon: String
    let code: Int
}

// MARK: - Location
struct Location: Codable {
    let name, country: String
    
    enum CodingKeys: String, CodingKey {
        case name, country
    }
}
```
---
ViewModel
---
### **WeatherViewModel.swift**
```swift

import Foundation
@Observable
class WeatherViewModel {
    var city : String = ""
    var weatherResponse : WeatherResponse?
    var isLoading : Bool = false
    var errorMessage : String?
    private let apiKey : String = "YOUR_API_KEY"

    private func fetchWeatherData(for city: String) async throws -> WeatherResponse{
        
        // Build URL
        let urlString = "https://api.weatherapi.com/v1/current.json?key=\(apiKey)&q=\(city)&aqi=no"
        
        guard let url = URL(string: urlString) else {
            throw WeatherError.invalidURL
        }
        
        // Fetch data
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherError.unknown
        }
        
        guard httpResponse.statusCode == 200 else {
            throw WeatherError.requestFailed(statusCode: httpResponse.statusCode)
        }
        
        // Decode Model
        do {
            return try JSONDecoder().decode(WeatherResponse.self, from: data)
        } catch  {
            throw WeatherError.decodingFailed
        }
    }
    
    @MainActor
    func fetch() async {
        do {
            weatherResponse = try await fetchWeatherData(for: city)
            errorMessage = nil
        } catch {
            if let weatherError = error as? WeatherError {
                errorMessage = weatherError.localizedDescription
            }else {
                errorMessage = "Unexped error : \(error.localizedDescription)"
            }
            
            // Reset weather
            weatherResponse = nil
        }
        
    }
}
```

### **WeatherError.swift**
```swift
import Foundation

enum WeatherError: LocalizedError {
    case invalidURL
    case requestFailed(statusCode : Int)
    case decodingFailed
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "Proivded city name is invalid."
        case .unknown:
            "Unknown error."
        case .requestFailed(statusCode: let statusCode):
            "Request failed with error code: \(statusCode). Please try again later."
        case .decodingFailed:
            "Unable to decode weather data. Server may change response format."
        }
    }    
}
```


---
View
---
### **WeatherViewModel.swift**
```swift
import SwiftUI

struct WeatherView: View {
    
    @State private var vm = WeatherViewModel()
    @State var useFarenheit = false
    
    var body: some View {
        NavigationStack{
            VStack{
                TextField("Enter city name", text: $vm.city)
                    .textFieldStyle(.roundedBorder)
                    .padding(8)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(style: StrokeStyle(lineWidth: 1))
                        
                    }.padding()
                
                Button {
                    Task{
                        
                        await vm.fetch()
                    }
                    
                } label: {
                    Label("Get Weather", systemImage: "cloud.sun.fill")
                }.buttonStyle(.borderedProminent)
                    .padding()
                    .disabled(vm.city.count < 3)
                
                if vm.isLoading {
                    ProgressView("Fetching Weather...")
                        .padding()
                }else if let weather = vm.weatherResponse{
                    WeatherCard(weather: weather, useFahrenheit: useFarenheit)
                }
                
                if vm.errorMessage != nil {
                    ErrorMessageView()
                }
                
                Spacer()
            }
            .navigationTitle("Weather App")
            .toolbar {
                ToolbarItem {
                    Menu {
                        Toggle(isOn: $useFarenheit) {
                            Label(useFarenheit ? "Use Celsius" : "Use Farenheit", systemImage: "thermometer.sun")
                        }
                        
                    } label: {
                        Image(systemName: "gear")
                    }
                    
                }
            }
        }
    }
}

#Preview {
    WeatherView()
}
```


---
View
---
### **WeatherCard.swift**
```swift
import SwiftUI

struct WeatherCard: View {
    
    let weather: WeatherResponse
    let useFahrenheit: Bool
    
    var iconUrlString: String {
        "https:\(weather.current.condition.icon)"
    }
    
    var displayTemp: String {
        useFahrenheit ? String(format: "%.1f°F", weather.current.tempF) : String(format: "%.1f°C", weather.current.tempC)
    }
    
    var displayFeelsLike: String {
        useFahrenheit ? String(format: "Feels like %.1f°F", weather.current.feelslikeF) : String(format: "Feels like %.1f°C", weather.current.feelslikeC)
    }
    
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: iconUrlString)) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
            } placeholder: {
                ProgressView()
            }
            
            Text("\(weather.location.name), \(weather.location.country)")
                .font(.title2)
                .bold()
            
            Text(displayTemp)
                .font(.largeTitle)
                .bold()
                .foregroundStyle(.white)
            
            Text(weather.current.condition.text)
                .font(.headline)
                .foregroundStyle(.white.opacity(0.9))
            
            Text(displayFeelsLike)
                .font(.headline)
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [.blue, .teal],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(.rect(cornerRadius: 20))
        .shadow(radius: 10)
        .padding()
    }
}

#Preview {
    WeatherCard(
        weather: WeatherResponse(
            location: Location(
                name: "Ahmedabad",
                country: "India"
            ),
            current: Current(
                tempC: 10,
                tempF: 30,
                condition: Condition(
                    text: "Sunny",
                    icon: "",
                    code: 1
                ),
                feelslikeC: 5,
                feelslikeF: 8
            )
        ),
        useFahrenheit: true
    )
}
```

### **WeatherView.swift**
```swift
import SwiftUI

struct WeatherView: View {
    
    @State private var vm = WeatherViewModel()
    @State var useFarenheit = false
    
    var body: some View {
        NavigationStack{
            VStack{
                TextField("Enter city name", text: $vm.city)
                    .textFieldStyle(.roundedBorder)
                    .padding(8)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(style: StrokeStyle(lineWidth: 1))
                        
                    }.padding()
                
                Button {
                    Task{
                        
                        await vm.fetch()
                    }
                    
                } label: {
                    Label("Get Weather", systemImage: "cloud.sun.fill")
                }.buttonStyle(.borderedProminent)
                    .padding()
                    .disabled(vm.city.count < 3)
                
                if vm.isLoading {
                    ProgressView("Fetching Weather...")
                        .padding()
                }else if let weather = vm.weatherResponse{
                    WeatherCard(weather: weather, useFahrenheit: useFarenheit)
                }
                
                if vm.errorMessage != nil {
                    ErrorMessageView()
                }
                
                Spacer()
            }
            .navigationTitle("Weather App")
            .toolbar {
                ToolbarItem {
                    Menu {
                        Toggle(isOn: $useFarenheit) {
                            Label(useFarenheit ? "Use Celsius" : "Use Farenheit", systemImage: "thermometer.sun")
                        }
                        
                    } label: {
                        Image(systemName: "gear")
                    }
                    
                }
            }
        }
    }
}

#Preview {
    WeatherView()
}

```



### **ErrorMessageView.swift**
```swift
import SwiftUI

struct ErrorMessageView: View {
    
    private let friendlyMessages: [String] = [
        "Something went wrong — please try again.",
        "We couldn’t fetch the weather. Maybe the clouds are blocking the signal?",
        "A minor hiccup occurred. Try again in a bit.",
        "Looks like the connection took a coffee break. Please retry.",
        "Weather data failed to load. Let’s give it another go soon."
    ]
    
    var message: String {
        friendlyMessages.randomElement() ?? ""
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "cloud.drizzle.fill")
                .font(.largeTitle)
            
            Text("Weather Unavailable")
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .bold()
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [.blue, .teal],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(.rect(cornerRadius: 20))
        .shadow(radius: 10)
        .padding()
        .foregroundStyle(.white.opacity(0.9))
    }
}

#Preview {
    ErrorMessageView()
}

```

