//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by                     Nand Parikh on 10/11/25.
//

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



