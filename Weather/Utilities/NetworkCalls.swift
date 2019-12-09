//
//  NetworkCalls.swift
//  Weather
//
//  Created by Shawn Patel on 12/6/19.
//  Copyright © 2019 Shawn Patel. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class NetworkCalls {
    func getCurrentWeather(lat: Double, long: Double, units: String, completion: @escaping (Result<CurrentWeatherData, NSError>) -> Void) {
        var currentWeatherData = CurrentWeatherData()
        
        let weatherAPIKey = "2152f0ae29eeeb61115e5d7740e1229d"
        let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=\(weatherAPIKey)&lat=\(lat)&lon=\(long)&units=\(units)"
        
        AF.request(weatherURL).response { response in
            if let error = response.error {
                completion(.failure(NSError(domain: "com.shawnpatel.Weather", code: 0, userInfo: [NSLocalizedDescriptionKey: error.errorDescription!])))
                return
            }
            
            let data = JSON(response.data!)
            
            currentWeatherData.city = data["name"].stringValue
            currentWeatherData.country = data["sys"]["country"].stringValue
            
            currentWeatherData.temp = data["main"]["temp"].doubleValue
            currentWeatherData.minTemp = data["main"]["temp_min"].doubleValue
            currentWeatherData.maxTemp = data["main"]["temp_max"].doubleValue
            
            currentWeatherData.conditions = data["weather"][0]["description"].stringValue.localizedCapitalized
            
            currentWeatherData.pressure = data["main"]["pressure"].doubleValue
            currentWeatherData.humidity = data["main"]["humidity"].intValue
            currentWeatherData.windSpeed = data["wind"]["speed"].doubleValue
            
            currentWeatherData.sunrise = data["sys"]["sunrise"].doubleValue
            currentWeatherData.sunset = data["sys"]["sunset"].doubleValue
            
            let icon = data["weather"][0]["icon"].stringValue
            self.getWeatherImage(icon: icon) { response in
                switch response {
                case .failure(let error):
                    completion(.failure(NSError(domain: "com.shawnpatel.Weather", code: 0, userInfo: [NSLocalizedDescriptionKey: error.localizedDescription])))
                case .success(let weatherIcon):
                    currentWeatherData.icon = weatherIcon
                    completion(.success(currentWeatherData))
                }
            }
        }
    }
    
    func getWeatherForecast(lat: Double, long: Double, units: String, completion: @escaping (Result<[ForecastWeatherData], NSError>) -> Void) {
        var forecastWeatherData: [ForecastWeatherData] = []
        
        let weatherAPIKey = "2152f0ae29eeeb61115e5d7740e1229d"
        let weatherURL = "https://api.openweathermap.org/data/2.5/forecast/daily?appid=\(weatherAPIKey)&lat=\(lat)&lon=\(long)&units=\(units)&cnt=16"
        
        AF.request(weatherURL).response { response in
            if let error = response.error {
                completion(.failure(NSError(domain: "com.shawnpatel.Weather", code: 0, userInfo: [NSLocalizedDescriptionKey: error.errorDescription!])))
                return
            }
            
            let data = JSON(response.data!)
            
            let city = data["city"]["name"].stringValue
            let country = data["city"]["country"].stringValue
            
            for conditions in data["list"].arrayValue {
                var dailyWeatherData = ForecastWeatherData()
                
                dailyWeatherData.time = conditions["dt"].doubleValue
                
                dailyWeatherData.city = city
                dailyWeatherData.country = country
                
                dailyWeatherData.dayTemp = conditions["temp"]["day"].doubleValue
                dailyWeatherData.nightTemp = conditions["temp"]["night"].doubleValue
                dailyWeatherData.minTemp = conditions["temp"]["min"].doubleValue
                dailyWeatherData.maxTemp = conditions["temp"]["max"].doubleValue
                
                dailyWeatherData.conditions = conditions["weather"][0]["description"].stringValue.localizedCapitalized
                
                dailyWeatherData.pressure = conditions["pressure"].doubleValue
                dailyWeatherData.humidity = conditions["humidity"].intValue
                dailyWeatherData.windSpeed = conditions["speed"].doubleValue
                
                dailyWeatherData.sunrise = conditions["sunrise"].doubleValue
                dailyWeatherData.sunset = conditions["sunset"].doubleValue
                
                let icon = conditions["weather"][0]["icon"].stringValue
                self.getWeatherImage(icon: icon) { response in
                    switch response {
                    case .failure(let error):
                        completion(.failure(NSError(domain: "com.shawnpatel.Weather", code: 0, userInfo: [NSLocalizedDescriptionKey: error.localizedDescription])))
                    case .success(let weatherIcon):
                        dailyWeatherData.icon = weatherIcon
                        forecastWeatherData.append(dailyWeatherData)
                        
                        if forecastWeatherData.count == 16 {
                            completion(.success(forecastWeatherData))
                        }
                    }
                }
            }
        }
    }
    
    func getWeatherImage(icon: String, completion: @escaping (Result<UIImage, NSError>) -> Void) {
        let weatherIconURL = "https://openweathermap.org/img/wn/\(icon)@2x.png"
        
        AF.request(weatherIconURL).response { response in
            if let error = response.error {
                completion(.failure(NSError(domain: "com.shawnpatel.Weather", code: 0, userInfo: [NSLocalizedDescriptionKey: error.errorDescription!])))
                return
            }
            
            let weatherIcon = UIImage(data: response.data!)
            completion(.success(weatherIcon!))
        }
    }
}
