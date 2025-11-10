//
//  WeatherCard.swift
//  WeatherApp
//
//  Created by                     Nand Parikh on 10/11/25.
//

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
    WeatherCard(weather: WeatherResponse(location: Location(name: "Ahmedabad", country: "India"), current: Current(tempC: 10, tempF: 30, condition: Condition(text: "Sunny", icon: "", code: 1), feelslikeC: 5, feelslikeF: 8)), useFahrenheit: true)
}
