//
//  WeatherService.swift
//  WeatherApp
//
//  Created by Tolga Sarikaya on 14.07.24.
//

import Foundation
import OpenMeteoSdk

class WeatherService {
    func fetchWeatherData(latitude: Double, longitude: Double) async throws -> WeatherData {
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&current=temperature_2m,rain&hourly=temperature_2m,rain,showers,weather_code&format=flatbuffers"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        print("Fetching weather data from URL: \(url)")

                let responses = try await WeatherApiResponse.fetch(url: url)
                guard !responses.isEmpty else {
                    throw URLError(.badServerResponse)
                }
        let response = responses[0]
        
        print("Received response: \(response)")

                let utcOffsetSeconds = response.utcOffsetSeconds
                guard let current = response.current, let hourly = response.hourly else {
                    throw URLError(.badServerResponse)
                }
        
        
        print("Current data: \(current), Hourly data: \(hourly)")
        
        let currentTemperature = current.variables(at: 0)?.value ?? 0.0
                let currentRain = current.variables(at: 1)?.value ?? 0.0
                let windSpeed10m = current.variables(at: 4)?.value ?? 0.0
                let cloudCover = current.variables(at: 2)?.value ?? 0.0
                
        let hourlyTimes = hourly.getDateTime(offset: utcOffsetSeconds)
                let hourlyTemperatures = hourly.variables(at: 0)?.values ?? []
                let hourlyPrecipitation = hourly.variables(at: 1)?.values ?? []
                let hourlyShowers = hourly.variables(at: 2)?.values ?? []
                let hourlyRain = hourly.variables(at: 1)?.values ?? []

        let weatherData = WeatherData(
            current: .init(
                time: Date(timeIntervalSince1970: TimeInterval(current.time + Int64(utcOffsetSeconds))),
                temperature2m: currentTemperature,
                rain: currentRain,
                windSpeed10m: windSpeed10m, cloudCover: cloudCover
            ),
            hourly: .init(
                time: hourlyTimes,
                temperature2m: hourlyTemperatures,
                precipitation: hourlyPrecipitation,
                showers: hourlyShowers,
                rain: hourlyRain
                 
            )
        )

        return weatherData
    }
    
    func searchCoordinates(for city: String) async throws -> (latitude: Double, longitude: Double) {
            let formattedCity = city.replacingOccurrences(of: " ", with: "+")
            let urlString = "https://geocoding-api.open-meteo.com/v1/search?name=\(formattedCity)&count=1&language=en&format=json"

            guard let url = URL(string: urlString) else {
                throw URLError(.badURL)
            }

            print("Fetching coordinates for \(city) from URL: \(url)")

            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            
            do {
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



