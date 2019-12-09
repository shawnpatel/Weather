//
//  HomeTableViewController.swift
//  
//
//  Created by Shawn Patel on 12/6/19.
//

import UIKit
import CoreLocation
import CoreData
import GooglePlaces

class HomeTableViewController: UITableViewController {
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    var currentWeatherData: CurrentWeatherData!
    var settings: [String: Any]!
    
    var unitSymbols: [String: [String]]!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadSettings()
        getSavedWeather()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        settings = ["units": 0]
        unitSymbols = ["temp": ["°F", "°C"], "speed": ["mph", "m/s"]]
        
        locationManager.delegate = self
        
        tableView.isHidden = true
        
        loadSettings()
        loadSavedWeather()
        getSavedWeather()
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
    
    func loadSavedWeather() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Weather")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                guard let city = data.value(forKey: "city") as? String else {
                    return
                }
                
                currentWeatherData = CurrentWeatherData()
                
                currentWeatherData.city = city
                currentWeatherData.country = (data.value(forKey: "country") as! String)
                
                currentWeatherData.temp = (data.value(forKey: "temp") as! Double)
                currentWeatherData.minTemp = (data.value(forKey: "minTemp") as! Double)
                currentWeatherData.maxTemp = (data.value(forKey: "maxTemp") as! Double)
                
                currentWeatherData.conditions = (data.value(forKey: "conditions") as! String)
                currentWeatherData.icon = UIImage(data: data.value(forKey: "icon") as! Data)
                
                currentWeatherData.pressure = (data.value(forKey: "pressure") as! Double)
                currentWeatherData.humidity = (data.value(forKey: "humidity") as! Int)
                currentWeatherData.windSpeed = data.value(forKey: "windSpeed") as? Double
                
                currentWeatherData.sunrise = (data.value(forKey: "sunrise") as! Double)
                currentWeatherData.sunset = (data.value(forKey: "sunset") as! Double)
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
            
            getWeatherData(lat: lat, long: long)
        }
    }
    
    func getSavedWeather() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        request.returnsObjectsAsFaults = false
        
        var lat: Double!
        var long: Double!
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                lat = (data.value(forKey: "lat") as! Double)
                long = (data.value(forKey: "long") as! Double)
            }
            
            if lat == nil && long == nil {
                getCurrentWeather()
            } else {
                getWeatherData(lat: lat, long: long)
            }
        } catch {
            print("Fetching from Core Data failed.")
        }
    }
    
    func getWeatherData(lat: Double, long: Double) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Location", in: context)
        let location = NSManagedObject(entity: entity!, insertInto: context)
        
        location.setValue(lat, forKey: "lat")
        location.setValue(long, forKey: "long")
        
        do {
            try context.save()
        } catch {
            print("Saving to Core Data failed.")
        }
        
        var units: String
        if settings["units"] as! Int == 0 {
            units = "imperial"
        } else {
            units = "metric"
        }
        
        NetworkCalls().getCurrentWeather(lat: lat, long: long, units: units) {response in
            switch response {
            case .success(let currentWeatherData):
                self.currentWeatherData = currentWeatherData
                self.tableView.reloadData()
                
                self.tableView.isHidden = false
                
                self.saveWeatherData()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func saveWeatherData() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Weather", in: context)
        let weather = NSManagedObject(entity: entity!, insertInto: context)
        
        weather.setValuesForKeys(currentWeatherData.dictionary!)
        
        do {
            try context.save()
        } catch {
            print("Saving to Core Data failed.")
        }
    }
    
    @IBAction func currentLocationButton(_ sender: UIBarButtonItem) {
        getCurrentWeather()
    }
    
    @IBAction func searchButton(_ sender: UIBarButtonItem) {
        googlePlaceSearch()
    }
    
    func googlePlaceSearch() {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self

        // Specify the place data types to return.
        /*let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
        UInt(GMSPlaceField.placeID.rawValue))!
        autocompleteController.placeFields = fields*/

        // Specify a filter.
        let filter = GMSAutocompleteFilter()
        filter.type = .city
        autocompleteController.autocompleteFilter = filter

        // Display the autocomplete view controller.
        present(autocompleteController, animated: true, completion: nil)
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
            
            if currentWeatherData != nil {
                cell.weatherIcon.image = currentWeatherData.icon
                cell.weatherDescription.text = currentWeatherData.conditions
                
                cell.location.text = "\(currentWeatherData.city!), \(currentWeatherData.country!)"
                cell.temp.text = "\(currentWeatherData.temp!) \(unitSymbols["temp"]![settings["units"] as! Int])"
                cell.lowTemp.text = "L: \(currentWeatherData.minTemp!) \(unitSymbols["temp"]![settings["units"] as! Int])"
                cell.highTemp.text = "H: \(currentWeatherData.maxTemp!) \(unitSymbols["temp"]![settings["units"] as! Int])"
            }
            
            return cell
        } else if indexPath.row == 1 { // Supplement Conditions Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "supplementConditions", for: indexPath) as! SupplementConditionsTableViewCell
            
            if currentWeatherData != nil {
                cell.pressure.text = "\(currentWeatherData.pressure!) hPa"
                cell.humidity.text = "\(currentWeatherData.humidity!) %"
                cell.wind.text = "\(currentWeatherData.windSpeed!) \(unitSymbols["speed"]![settings["units"] as! Int])"
            }
            
            return cell
        } else if indexPath.row == 2 { // Sun Cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "sun", for: indexPath) as! SunTableViewCell
            
            if currentWeatherData != nil {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "h:mm a"
                
                let sunrise = Date(timeIntervalSince1970: currentWeatherData.sunrise!)
                let sunset = Date(timeIntervalSince1970: currentWeatherData.sunset!)
                
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

extension HomeTableViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            getCurrentWeather()
        }
    }
}

extension HomeTableViewController: GMSAutocompleteViewControllerDelegate {
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        let lat = place.coordinate.latitude
        let long = place.coordinate.longitude
        
        getWeatherData(lat: lat, long: long)
        
        dismiss(animated: true, completion: nil)
    }

    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }

    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
}
