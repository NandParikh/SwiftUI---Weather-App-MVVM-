//
//  WeatherResponse.swift
//  WeatherApp
//
//  Created by                     Nand Parikh on 10/11/25.
//

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
