//
//  WeatherError.swift
//  WeatherApp
//
//  Created by                     Nand Parikh on 10/11/25.
//

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
