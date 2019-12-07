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
    func getWeather(lat: Double, long: Double, completion: @escaping (Result<WeatherData, NSError>) -> Void) {
        var weatherData = WeatherData()
        
        let weatherAPIKey = "2152f0ae29eeeb61115e5d7740e1229d"
        let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=\(weatherAPIKey)&lat=\(lat)&lon=\(long)&units=metric"
        
        AF.request(weatherURL).response { response in
            if let error = response.error {
                completion(.failure(NSError(domain: error.errorDescription!, code: 0)))
                return
            }
            
            let data = JSON(response.data!)
            
            weatherData.temp = data["main"]["temp"].doubleValue
            weatherData.minTemp = data["main"]["temp_min"].doubleValue
            weatherData.maxTemp = data["main"]["temp_max"].doubleValue
            
            weatherData.description = data["weather"][0]["description"].stringValue.uppercased()
            
            let icon = data["weather"][0]["icon"].stringValue
            self.getWeatherImage(icon: icon) {response in
                switch response {
                case .failure(let error):
                    completion(.failure(NSError(domain: error.localizedDescription, code: 0)))
                case .success(let weatherIcon):
                    weatherData.icon = weatherIcon
                }
            }
            
            weatherData.pressure = data["main"]["pressure"].doubleValue
            weatherData.humidity = data["main"]["humidity"].intValue
            weatherData.windSpeed = data["wind"]["speed"].doubleValue
            
            weatherData.sunrise = data["sys"]["sunrise"].intValue
            weatherData.sunset = data["sys"]["sunset"].intValue
            
            completion(.success(weatherData))
        }
    }
    
    func getWeatherImage(icon: String, completion: @escaping (Result<UIImage, NSError>) -> Void) {
        let weatherIconURL = "https://openweathermap.org/img/wn/\(icon)@2x.png"
        
        AF.request(weatherIconURL).response { response in
            if let error = response.error {
                completion(.failure(NSError(domain: error.errorDescription!, code: 0)))
                return
            }
            
            let weatherIcon = UIImage(data: response.data!)
            completion(.success(weatherIcon!))
        }
    }
}
