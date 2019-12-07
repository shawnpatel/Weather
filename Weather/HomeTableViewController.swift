//
//  HomeTableViewController.swift
//  
//
//  Created by Shawn Patel on 12/6/19.
//

import UIKit
import CoreLocation

class HomeTableViewController: UITableViewController {
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    var weatherData: WeatherData!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getCurrentWeather()
    }
    
    func getCurrentWeather() {
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            currentLocation = locationManager.location
            
            let lat = currentLocation.coordinate.latitude
            let long = currentLocation.coordinate.longitude
            getWeatherData(lat: lat, long: long)
        }
    }
    
    func getWeatherData(lat: Double, long: Double) {
        NetworkCalls().getWeather(lat: lat, long: long) {response in
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
        getCurrentWeather()
    }
    
    // MARK: - Table View Data Source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 125
        } else if indexPath.row == 1 {
            return 100
        }
        
        return 50
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 { // Current Weather Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "currentWeather", for: indexPath) as! CurrentWeatherTableViewCell
            
            if weatherData != nil {
                cell.weatherIcon.image = weatherData.icon
                cell.weatherDescription.text = weatherData.description
                
                cell.location.text = "\(weatherData.city!), \(weatherData.country!)"
                cell.temp.text = "\(weatherData.temp!) °C"
                cell.lowTemp.text = "L: \(weatherData.minTemp!) °C"
                cell.highTemp.text = "H: \(weatherData.maxTemp!) °C"
            }
            
            return cell
        } else if indexPath.row == 1 { // Sun Cell
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

class CurrentWeatherTableViewCell: UITableViewCell {
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var weatherDescription: UILabel!
    
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var temp: UILabel!
    @IBOutlet weak var lowTemp: UILabel!
    @IBOutlet weak var highTemp: UILabel!
}

class SunTableViewCell: UITableViewCell {
    @IBOutlet weak var sunrise: UILabel!
    @IBOutlet weak var sunset: UILabel!
}
