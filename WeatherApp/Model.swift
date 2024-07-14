//
//  Model.swift
//  WeatherApp
//
//  Created by Tolga Sarikaya on 14.07.24.
//

import Foundation

struct WeatherData {
    let current: Current
    let hourly: Hourly

    struct Current {
        let time: Date
        let temperature2m: Float
        let rain: Float
        let windSpeed10m: Float
        let cloudCover: Float
    }
    struct Hourly {
        let time: [Date]
        let temperature2m: [Float]
        let precipitation: [Float]
        let showers: [Float]
        let rain: [Float]
    }
}

struct SearchResponse: Decodable {
    struct Result: Decodable {
        let id: Int
        let name: String
        let latitude: Double
        let longitude: Double
        
    }
    
    let results: [Result]
}
