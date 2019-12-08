//
//  SettingsTableViewController.swift
//  Weather
//
//  Created by Shawn Patel on 12/6/19.
//  Copyright © 2019 Shawn Patel. All rights reserved.
//

import UIKit
import CoreData

class SettingsTableViewController: UITableViewController {
    
    let segments = [["Units", "Imperial", "Metric"]]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table View Data Source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return segments.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "segment", for: indexPath) as! SegmentTableViewCell
        
        cell.segment.tag = indexPath.row
        cell.label.text = segments[indexPath.row][0]
        cell.segment.setTitle(segments[indexPath.row][1], forSegmentAt: 0)
        cell.segment.setTitle(segments[indexPath.row][2], forSegmentAt: 1)
        
        if indexPath.row == 0 {
            // Fetch Data
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Settings")
            request.returnsObjectsAsFaults = false
            
            do {
                let result = try context.fetch(request)
                for data in result as! [NSManagedObject] {
                    cell.segment.selectedSegmentIndex = data.value(forKey: "units") as! Int
                }
            } catch {
                print("Fetching from Core Data failed.")
            }
        }
        
        cell.segment.addTarget(self, action: #selector(segmentValueChanged(sender:)), for: .valueChanged)

        return cell
    }
    
    @objc func segmentValueChanged(sender: UISegmentedControl) {
        // Save Data
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Settings", in: context)
        let settings = NSManagedObject(entity: entity!, insertInto: context)
        
        if sender.tag == 0 {
            settings.setValue(sender.selectedSegmentIndex, forKey: "units")
        }
        
        do {
            try context.save()
        } catch {
            print("Saving to Core Data failed.")
        }
    }
}

class SegmentTableViewCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var segment: UISegmentedControl!
}
