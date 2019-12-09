//
//  ForecastCollectionViewController.swift
//  Weather
//
//  Created by Shawn Patel on 12/8/19.
//  Copyright © 2019 Shawn Patel. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "forecastCell"

class ForecastCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var forecastWeatherData: [ForecastWeatherData]!
    var settings: [String: Any]!
    
    var unitSymbols: [String: [String]]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        forecastWeatherData = []
        settings = ["units": 0]
        unitSymbols = ["temp": ["°F", "°C"], "speed": ["mph", "m/s"]]
        
        loadSettings()
        getSavedForecastWeatherData()
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
    
    func getSavedForecastWeatherData() {
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
            
            if lat != nil && long != nil {
                getForecastWeatherData(lat: lat, long: long)
            }
        } catch {
            print("Fetching from Core Data failed.")
        }
    }
    
    func getForecastWeatherData(lat: Double, long: Double) {
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
        
        NetworkCalls().getWeatherForecast(lat: lat, long: long, units: units) { response in
            switch response {
            case .success(let forecastWeatherData):
                self.forecastWeatherData = forecastWeatherData
                self.collectionView.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "dailyForecast" {
            let dailyForecast: DailyForecastTableViewController = segue.destination as! DailyForecastTableViewController
            dailyForecast.forecastWeatherData = forecastWeatherData[sender as! Int]
        }
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return forecastWeatherData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width / 3, height: 150)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ForecastCellCollectionViewCell
        
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.borderWidth = 1
        
        cell.weatherIcon.image = forecastWeatherData[indexPath.row].icon!
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, MMM d"
        
        let date = Date(timeIntervalSince1970: forecastWeatherData[indexPath.row].time!)
        cell.date.text = "\(dateFormatter.string(from: date))"
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "dailyForecast", sender: indexPath.row)
    }
}

class ForecastCellCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var date: UILabel!
}
