//
//  BeaconAdSDKTests.swift
//  BeaconAdSDKTests
//
//  Created by Nikita Konstantinovskiy on 18.04.17.
//  Copyright © 2017 BeaconAd. All rights reserved.
//

import XCTest
@testable import BeaconAdSDK

class BeaconAdSDKTests: XCTestCase, BeaconAdDelegate{
    var ad: BeaconAd!
    
    override func setUp() {
        super.setUp()
        ad = BeaconAd(companyUID: "uisaid")
        ad.delegate = self
    }
    
    override func tearDown() {
        ad = nil
        super.tearDown()
    }
    
    func testGetBeacons() {
        ad.GetBeacons()
        //XCTAssertEqual(ad.GetBeacons(), "FUCK", "Ok")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock { 
            
        }
    }
    
}
