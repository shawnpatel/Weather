//
//  MapViewController.swift
//  Weather
//
//  Created by Shawn Patel on 12/7/19.
//  Copyright © 2019 Shawn Patel. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var lat: Double!
    var long: Double!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.showsUserLocation = true
        
        addLongPressGestureRecognizer()
        
        getCoordinates()
    }
    
    func getCoordinates() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Map")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                lat = (data.value(forKey: "lat") as! Double)
                long = (data.value(forKey: "long") as! Double)
            }
            
            centerAtPin(lat: lat, long: long)
        } catch {
            print("Fetching from Core Data failed.")
        }
    }
    
    func centerAtPin(lat: Double, long: Double) {
        addAnnotation(lat: lat, long: long)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let region = MKCoordinateRegion(center: location, span: span)

        mapView.setRegion(region, animated: false)
    }
    
    func addAnnotation(lat: Double, long: Double) {
        mapView.removeAnnotations(mapView.annotations)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        mapView.addAnnotation(annotation)
    }
    
    @objc func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        let location = gestureReconizer.location(in: mapView)
        let coordinate = mapView.convert(location,toCoordinateFrom: mapView)

        addAnnotation(lat: coordinate.latitude, long: coordinate.longitude)
        
        lat = coordinate.latitude
        long = coordinate.longitude
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Map", in: context)
        let map = NSManagedObject(entity: entity!, insertInto: context)
        
        map.setValue(coordinate.latitude, forKey: "lat")
        map.setValue(coordinate.longitude, forKey: "long")
        
        do {
            try context.save()
        } catch {
            print("Saving to Core Data failed.")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "weatherPreview" {
            configurePopover(segue)
        }
    }
}

extension MapViewController: UIGestureRecognizerDelegate {
    func addLongPressGestureRecognizer() {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureReconizer:)))
        gestureRecognizer.delegate = self
        mapView.addGestureRecognizer(gestureRecognizer)
    }
}

extension MapViewController: UIPopoverPresentationControllerDelegate {
    func configurePopover(_ segue: UIStoryboardSegue) {
        let weatherPreview: WeatherPreviewViewController = segue.destination as! WeatherPreviewViewController
        weatherPreview.popoverPresentationController?.backgroundColor = UIColor.darkGray
        weatherPreview.popoverPresentationController!.delegate = self
        weatherPreview.preferredContentSize = CGSize(width: 200, height: 150)
        
        weatherPreview.lat = lat
        weatherPreview.long = long
        
        let presentationViewController = weatherPreview.popoverPresentationController
        presentationViewController?.permittedArrowDirections = .any
        presentationViewController?.delegate = self
        presentationViewController?.sourceView = mapView
        presentationViewController?.sourceRect = mapView.bounds
    }
    
    func adaptivePresentationStyle(for controller:
        UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        return UINavigationController(rootViewController: controller.presentedViewController)
    }
}
