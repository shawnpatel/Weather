//
//  Structures.swift
//  Weather
//
//  Created by Shawn Patel on 12/6/19.
//  Copyright © 2019 Shawn Patel. All rights reserved.
//

import Foundation
import UIKit

struct WeatherData {
    var city: String?
    var country: String?
    
    var temp: Double? // [°C]
    var minTemp: Double? // [°C]
    var maxTemp: Double? // [°C]
    
    var conditions: String?
    var icon: UIImage?
    
    var pressure: Double? // [hPa]
    var humidity: Int? // [%]
    var windSpeed: Double? // [m/s]
    
    var sunrise: Double? // [s] - Unix Time
    var sunset: Double? // [s] - Unix Time
    
    var dictionary: [String: Any]? {
        if city != nil {
            return [
                "city": city!,
                "country": country!,
                
                "temp": temp!,
                "minTemp": minTemp!,
                "maxTemp": maxTemp!,
                
                "conditions": conditions!,
                "icon": icon!.pngData()!,
                
                "pressure": pressure!,
                "humidity": humidity!,
                "windSpeed": windSpeed!,
                
                "sunrise": sunrise!,
                "sunset": sunset!
            ]
        } else {
            return nil
        }
    }
}
