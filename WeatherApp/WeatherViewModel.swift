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

    func fetchWeather(for city: String) async {
            do {
                let (latitude, longitude) = try await weatherService.searchCoordinates(for: city)
                let data = try await weatherService.fetchWeatherData(latitude: latitude, longitude: longitude)
                
                DispatchQueue.main.async {
                    self.weatherData = data
                }
            } catch {
                print("Failed to fetch weather data for \(city): \(error)")
            }
        }
        
    private func getCoordinates(for city: String) async throws -> (latitude: Double, longitude: Double) {
            let formattedCity = city.replacingOccurrences(of: " ", with: "+")
            let urlString = "https://geocoding-api.open-meteo.com/v1/search?name=\(formattedCity)&count=1&language=en&format=json"

            guard let url = URL(string: urlString) else {
                throw URLError(.badURL)
            }

            print("Fetching coordinates for \(city) from URL: \(url)")

            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            
            do {
                struct SearchResponse: Decodable {
                    struct Result: Decodable {
                        let latitude: Double
                        let longitude: Double
                    }
                    let results: [Result]
                }
                
                let searchResponse = try decoder.decode(SearchResponse.self, from: data)
                guard let result = searchResponse.results.first else {
                    throw URLError(.badServerResponse)
                }

                let latitude = result.latitude
                let longitude = result.longitude

                return (latitude, longitude)
            } catch {
                throw error
            }
        }

    }
