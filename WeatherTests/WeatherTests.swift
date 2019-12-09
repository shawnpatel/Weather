//
//  WeatherTests.swift
//  WeatherTests
//
//  Created by Shawn Patel on 12/8/19.
//  Copyright © 2019 Shawn Patel. All rights reserved.
//

import XCTest
@testable import Weather

class WeatherTests: XCTestCase {
    
    var currentWeather: CurrentWeatherData!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testCurrentWeatherData() {
        let lat = 37.871666
        let long = -122.272781
        
        let expectation = self.expectation(description: "WeatherAPI")
        
        NetworkCalls().getCurrentWeather(lat: lat, long: long, units: "imperial") { response in
            switch response {
            case .success(let currentWeather):
                self.currentWeather = currentWeather
                expectation.fulfill()
            case .failure(let error):
                print(error.localizedDescription)
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssert(currentWeather.city == "Berkeley")
    }
}
