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
                       HStack {
                           Text("Current Temperature: \(Int(weatherData.current.temperature2m.rounded()))°C")
                           Image(systemName: determineWeatherIcon(current: weatherData.current))
                       }
                       .padding(.top, 20) // Wir haben oben etwas Platz hinzugefügt

                       ScrollView(.horizontal) {
                           ScrollViewReader { proxy in
                               LazyHStack(spacing: 20) {
                                   ForEach(weatherData.hourly.time.indices, id: \.self) { index in
                                       VStack(alignment: .leading) {
                                           Text("Time: \(viewModel.dateFormatter.string(from: weatherData.hourly.time[index]))")
                                           Text("Temperature: \(Int(weatherData.hourly.temperature2m[index].rounded()))°C")
                                           Text("Rain: \(Int((weatherData.hourly.rain[index]).rounded())) mm")
                                           Text("Showers: \(Int((weatherData.hourly.showers[index]).rounded())) mm")
                                           Text("Cloud: \(Int((weatherData.current.cloudCover).rounded()))")
                                           Image(systemName: determineHourlyWeatherIcon(weatherData: weatherData, index: index))
                                       }
                                       .padding()
                                       .background(Color.gray.opacity(0.1))
                                       .cornerRadius(10)
                                       .id(index) //Wir haben eine ID für ScrollViewReader hinzugefügt
                                   }
                               }
                               .padding()
                           }
                       }
                       .frame(height: 200) // Wir legen die Höhe von ScrollView fest
                       .cornerRadius(10)
                       
                       ClothesRecommendationView(currentWeather: weatherData.current)

                       Spacer() // Wir haben Spacer hinzugefügt, um andere Inhalte nach oben zu bringen
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
    
    func determineWeatherIcon(current: WeatherData.Current) -> String {
           if current.cloudCover > 0 && current.rain > 0 {
               return "cloud.sun.rain"
           } else if current.cloudCover > 0 {
               return "cloud.sun"
           } else if current.rain > 0 {
               return "cloud.rain"
           } else {
               return "sun.max"
           }
       }
    
    func determineHourlyWeatherIcon(weatherData: WeatherData, index: Int) -> String {
        let hourly = weatherData.hourly
        
        if hourly.temperature2m[index] > 25 {
            return "thermometer.sun.fill"
        } else if hourly.rain[index] > 0 {
            return "cloud.drizzle.fill"
        } else {
            return "sun.max.fill"
        }
    }
    
   }

struct ClothesRecommendationView: View {
    let currentWeather: WeatherData.Current
    
    var body: some View {
        VStack {
            Text("Bekleidungsempfehlungen")
                .font(.title)
                .padding(.top,20)
            
            if currentWeather.cloudCover == 0 && currentWeather.rain == 0 {
                Image("t-shirt")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                Text("Ein sonniger Tag! Sie können ein T-Shirt tragen.")
                    .padding()
            } else if currentWeather.temperature2m < 20 {
                Image("sweatshirt")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                Text("Das Wetter ist etwas kühl. Ich empfehle das Tragen eines Sweatshirts.")
                    .padding()
            } else if currentWeather.rain > 0 {
                Image("regenschirm")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                Text("Es ist regnerisch heute! Vergessen Sie nicht, Ihren Regenschirm mitzunehmen.")
                    .padding()
            } else {
                Image("t-shirt")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                Text("Es ist ein schöner Tag! Sie können bequem ausgehen")
                    .padding()
            }
        }
        .cornerRadius(10)
        .padding()
    }
    
}

#Preview {
    WeatherView()
}

