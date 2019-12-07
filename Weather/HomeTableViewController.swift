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
                print(weatherData.temp!)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    @IBAction func currentLocationButton(_ sender: UIBarButtonItem) {
        getCurrentWeather()
    }
    

    // MARK: - Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        return cell
    }
}

class CurrentWeatherTableViewCell: UITableViewCell {
    @IBOutlet weak var weatherIcon: UIImageView!
    
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var temp: UILabel!
    @IBOutlet weak var weatherDescription: UILabel!
}
