//
//  WeatherPreviewViewController.swift
//  Weather
//
//  Created by Shawn Patel on 12/7/19.
//  Copyright © 2019 Shawn Patel. All rights reserved.
//

import UIKit
import CoreData

class WeatherPreviewViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var temp: UILabel!
    
    var lat: Double!
    var long: Double!
    
    var currentWeatherData: CurrentWeatherData!
    var settings: [String: Any]!
    
    var unitSymbols: [String: [String]]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settings = ["units": 0]
        unitSymbols = ["temp": ["°F", "°C"], "speed": ["mph", "m/s"]]
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        loadSettings()
        getWeatherData(lat: lat, long: long)
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
    
    func getWeatherData(lat: Double, long: Double) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Location", in: context)
        let map = NSManagedObject(entity: entity!, insertInto: context)
        
        map.setValue(lat, forKey: "lat")
        map.setValue(long, forKey: "long")
        
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
                self.updateUI()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func updateUI() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            
            self.weatherIcon.image = self.currentWeatherData.icon
            self.temp.text = "\(self.currentWeatherData.temp!) \(self.unitSymbols["temp"]![self.settings["units"] as! Int])"
        }
    }
}
