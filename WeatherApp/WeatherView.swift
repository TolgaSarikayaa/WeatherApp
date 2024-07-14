//
//  WeatherView.swift
//  WeatherApp
//
//  Created by Tolga Sarikaya on 14.07.24.
//

import SwiftUI

struct WeatherView: View {
    @StateObject private var viewModel = WeatherViewModel()

    var body: some View {
        VStack {
            if let weatherData = viewModel.weatherData {
                Text("Current Temperature: \(Int(weatherData.current.temperature2m.rounded()))°C")
                List(weatherData.hourly.time.indices, id: \.self) { index in
                    VStack(alignment: .leading) {
                        Text("Time: \(viewModel.dateFormatter.string(from: weatherData.hourly.time[index]))")
                        Text("Temperature: \(Int(weatherData.hourly.temperature2m[index].rounded()))°C")
                        Text("Rain: \(Int((weatherData.hourly.rain[index]).rounded())) mm")
                        Text("Showers: \(Int((weatherData.hourly.showers[index]).rounded())) mm")
                        Text("Cloud: \(weatherData.current.cloudCover)")
                        
                    }
                }
            } else {
                ProgressView()
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchWeather()
            }
        }
    }
}

#Preview {
    WeatherView()
}

