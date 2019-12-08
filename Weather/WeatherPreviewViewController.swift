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

    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var temp: UILabel!
    
    var lat: Double!
    var long: Double!
    
    var weatherData: WeatherData!
    var settings: [String: Any] = [:]
    
    var unitSymbols: [String: [String]] = ["temp": ["°F", "°C"], "speed": ["mph", "m/s"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        let entity = NSEntityDescription.entity(forEntityName: "Map", in: context)
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
        
        NetworkCalls().getWeather(lat: lat, long: long, units: units) {response in
            switch response {
            case .success(let weatherData):
                self.weatherData = weatherData
                self.updateUI()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func updateUI() {
        DispatchQueue.main.async {
            self.weatherIcon.image = self.weatherData.icon
            self.temp.text = "\(self.weatherData.temp!) \(self.unitSymbols["temp"]![self.settings["units"] as! Int])"
        }
    }
}
