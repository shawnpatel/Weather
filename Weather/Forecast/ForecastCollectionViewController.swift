//
//  ForecastCollectionViewController.swift
//  Weather
//
//  Created by Shawn Patel on 12/8/19.
//  Copyright © 2019 Shawn Patel. All rights reserved.
//

import UIKit

private let reuseIdentifier = "forecastCell"

class ForecastCollectionViewController: UICollectionViewController {
    
    var weatherData: [WeatherData]!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weatherData.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
    
        return cell
    }
}

class ForecastCellCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var date: UILabel!
}
