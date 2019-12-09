//
//  DailyForecastTableViewController.swift
//  Weather
//
//  Created by Shawn Patel on 12/8/19.
//  Copyright © 2019 Shawn Patel. All rights reserved.
//

import UIKit
import CoreData

class DailyForecastTableViewController: UITableViewController {
    
    var forecastWeatherData: ForecastWeatherData!
    var settings: [String: Any]!
    
    var unitSymbols: [String: [String]]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        settings = ["units": 0]
        unitSymbols = ["temp": ["°F", "°C"], "speed": ["mph", "m/s"]]
        
        loadSettings()
    }
    
    func loadSettings() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                settings["units"] = data.value(forKey: "units") as! Int
            }
        } catch {
            print("Fetching from Core Data failed.")
        }
    }

    // MARK: - Table View Data Source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 { // Conditions Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "fConditions", for: indexPath) as! FConditionsTableViewCell
            
            let tempUnitSymbol = unitSymbols["temp"]![settings["units"] as! Int]

            cell.weatherIcon.image = forecastWeatherData.icon
            cell.weatherDescription.text = forecastWeatherData.conditions
            
            cell.location.text = "\(forecastWeatherData.city!), \(forecastWeatherData.country!)"
            cell.temp.text = "\(forecastWeatherData.dayTemp!) \(tempUnitSymbol) / \(forecastWeatherData.nightTemp!) \(tempUnitSymbol)"
            cell.lowTemp.text = "L: \(forecastWeatherData.minTemp!) \(unitSymbols["temp"]![settings["units"] as! Int])"
            cell.highTemp.text = "H: \(forecastWeatherData.maxTemp!) \(unitSymbols["temp"]![settings["units"] as! Int])"

            return cell
        } else if indexPath.row == 1 { // Supplement Conditions Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "fSupplementConditions", for: indexPath) as! FSupplementConditionsTableViewCell
            
            cell.pressure.text = "\(forecastWeatherData.pressure!) hPa"
            cell.humidity.text = "\(forecastWeatherData.humidity!) %"
            cell.wind.text = "\(forecastWeatherData.windSpeed!) \(unitSymbols["speed"]![settings["units"] as! Int])"
            
            return cell
            
        } else if indexPath.row == 2 { // Sun Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "fSun", for: indexPath) as! FSunTableViewCell
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm a"
            
            let sunrise = Date(timeIntervalSince1970: forecastWeatherData.sunrise!)
            let sunset = Date(timeIntervalSince1970: forecastWeatherData.sunset!)
            
            cell.sunrise.text = "\(dateFormatter.string(from: sunrise))"
            cell.sunset.text = "\(dateFormatter.string(from: sunset))"
            
            return cell
        }
        
        return UITableViewCell()
    }
}

class FConditionsTableViewCell: UITableViewCell {
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var weatherDescription: UILabel!
    
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var temp: UILabel!
    @IBOutlet weak var lowTemp: UILabel!
    @IBOutlet weak var highTemp: UILabel!
}

class FSupplementConditionsTableViewCell: UITableViewCell {
    @IBOutlet weak var pressure: UILabel!
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var wind: UILabel!
}

class FSunTableViewCell: UITableViewCell {
    @IBOutlet weak var sunrise: UILabel!
    @IBOutlet weak var sunset: UILabel!
}
