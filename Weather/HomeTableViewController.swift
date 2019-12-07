//
//  HomeTableViewController.swift
//  
//
//  Created by Shawn Patel on 12/6/19.
//

import UIKit
import CoreLocation
import CoreData

class HomeTableViewController: UITableViewController {
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    var weatherData: WeatherData!
    var settings: [String: Any] = [:]
    
    var unitSymbols: [String: [String]] = ["temp": ["°F", "°C"], "speed": ["mph", "m/s"]]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSettings()
        getCurrentWeather()
    }
    
    func loadSettings() {
        // Fetch Data
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
    
    func getCurrentWeather() {
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            currentLocation = locationManager.location
            
            let lat = currentLocation.coordinate.latitude
            let long = currentLocation.coordinate.longitude
            
            var units: String
            if settings["units"] as! Int == 0 {
                units = "imperial"
            } else {
                units = "metric"
            }
            
            getWeatherData(lat: lat, long: long, units: units)
        }
    }
    
    func getWeatherData(lat: Double, long: Double, units: String) {
        NetworkCalls().getWeather(lat: lat, long: long, units: units) {response in
            switch response {
            case .success(let weatherData):
                self.weatherData = weatherData
                self.tableView.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    @IBAction func currentLocationButton(_ sender: UIBarButtonItem) {
        loadSettings()
        getCurrentWeather()
    }
    
    // MARK: - Table View Data Source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 125
        } else if indexPath.row == 1 {
            return 100
        } else if indexPath.row == 2 {
            return 100
        }
        
        return 50
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 { // Conditions Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "conditions", for: indexPath) as! ConditionsTableViewCell
            
            if weatherData != nil {
                cell.weatherIcon.image = weatherData.icon
                cell.weatherDescription.text = weatherData.description
                
                cell.location.text = "\(weatherData.city!), \(weatherData.country!)"
                cell.temp.text = "\(weatherData.temp!) \(unitSymbols["temp"]![settings["units"] as! Int])"
                cell.lowTemp.text = "L: \(weatherData.minTemp!) \(unitSymbols["temp"]![settings["units"] as! Int])"
                cell.highTemp.text = "H: \(weatherData.maxTemp!) \(unitSymbols["temp"]![settings["units"] as! Int])"
            }
            
            return cell
        } else if indexPath.row == 1 { // Supplement Conditions Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "supplementConditions", for: indexPath) as! SupplementConditionsTableViewCell
            
            if weatherData != nil {
                cell.pressure.text = "\(weatherData.pressure!) hPa"
                cell.humidity.text = "\(weatherData.humidity!) %"
                cell.wind.text = "\(weatherData.windSpeed!) \(unitSymbols["speed"]![settings["units"] as! Int])"
            }
            
            return cell
        } else if indexPath.row == 2 { // Sun Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "sun", for: indexPath) as! SunTableViewCell
            
            if weatherData != nil {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "h:mm a"
                
                let sunrise = Date(timeIntervalSince1970: weatherData.sunrise!)
                let sunset = Date(timeIntervalSince1970: weatherData.sunset!)
                
                cell.sunrise.text = "\(dateFormatter.string(from: sunrise))"
                cell.sunset.text = "\(dateFormatter.string(from: sunset))"
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
}

class ConditionsTableViewCell: UITableViewCell {
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var weatherDescription: UILabel!
    
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var temp: UILabel!
    @IBOutlet weak var lowTemp: UILabel!
    @IBOutlet weak var highTemp: UILabel!
}

class SupplementConditionsTableViewCell: UITableViewCell {
    @IBOutlet weak var pressure: UILabel!
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var wind: UILabel!
}

class SunTableViewCell: UITableViewCell {
    @IBOutlet weak var sunrise: UILabel!
    @IBOutlet weak var sunset: UILabel!
}
