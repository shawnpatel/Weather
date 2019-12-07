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
    var temp: Double? // [°C]
    var maxTemp: Double? // [°C]
    var minTemp: Double? // [°C]
    
    var description: String?
    var icon: UIImage?
    
    var pressure: Double? // [Pa]
    var humidity: Int? // [%]
    var windSpeed: Double? // [m/s]
    
    var sunrise: Int? // [s] - Unix Time
    var sunset: Int? // [s] - Unix Time
}
