//
//  WeatherView.swift
//  WeatherApp
//
//  Created by Tolga Sarikaya on 14.07.24.
//

import SwiftUI

struct WeatherView: View {
    @StateObject private var viewModel = WeatherViewModel()
    @State private var cityQuery = ""

    var body: some View {
        ZStack {
            Color.blue.ignoresSafeArea()

            VStack {
                Text("Willkommen")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding()

                TextField("Geben Sie den Namen der Stadt ein", text: $cityQuery)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal)

                Button(action: {
                    Task {
                        await viewModel.fetchWeather(for: cityQuery)
                    }
                }) {
                    Text("Wetter anzeigen")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue.opacity(0.7))
                        .cornerRadius(10)
                }

                Spacer()

                if let weatherData = viewModel.weatherData {
                    VStack {
                        HStack {
                            Text("Current Temperature: \(Int(weatherData.current.temperature2m.rounded()))°C")
                                .foregroundColor(.white)
                            Image(systemName: determineWeatherIcon(current: weatherData.current))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 20)

                        ScrollView(.horizontal) {
                            ScrollViewReader { proxy in
                                LazyHStack(spacing: 20) {
                                    ForEach(weatherData.hourly.time.indices, id: \.self) { index in
                                        VStack(alignment: .leading) {
                                            Text("Time: \(viewModel.dateFormatter.string(from: weatherData.hourly.time[index]))")
                                                .foregroundColor(.white)
                                            Text("Temperature: \(Int(weatherData.hourly.temperature2m[index].rounded()))°C")
                                                .foregroundColor(.white)
                                            Text("Rain: \(Int((weatherData.hourly.rain[index]).rounded())) mm")
                                                .foregroundColor(.white)
                                            Text("Showers: \(Int((weatherData.hourly.showers[index]).rounded())) mm")
                                                .foregroundColor(.white)
                                            Text("Cloud: \(Int((weatherData.current.cloudCover).rounded()))%")
                                                .foregroundColor(.white)
                                            Image(systemName: determineHourlyWeatherIcon(weatherData: weatherData, index: index))
                                                .foregroundColor(.white)
                                        }
                                        .padding()
                                        .background(Color.gray.opacity(0.5))
                                        .cornerRadius(10)
                                        .id(index)
                                    }
                                }
                                .padding()
                            }
                        }
                        .frame(height: 200)
                        .cornerRadius(10)

                        ClothesRecommendationView(currentWeather: weatherData.current)

                        Spacer()
                    }
                } else {
                    Text("Bitte geben Sie eine Stadt ein, um das Wetter anzuzeigen.")
                        .foregroundColor(.white)
                        .padding()
                }
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

