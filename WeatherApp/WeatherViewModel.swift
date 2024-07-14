//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Tolga Sarikaya on 14.07.24.
//

import Foundation
import OpenMeteoSdk

class WeatherViewModel: ObservableObject {
    @Published var weatherData: WeatherData?

    private let weatherService = WeatherService()
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = .gmt
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter
    }()

    func fetchWeather() async {
        do {
            let data = try await weatherService.fetchWeatherData(latitude: 52.52, longitude: 13.41)
            DispatchQueue.main.async {
                self.weatherData = data
            }
        } catch {
            print("Failed to fetch weather data: \(error)")
        }
    }
}
