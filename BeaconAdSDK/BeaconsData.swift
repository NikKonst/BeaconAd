//
//  BeaconsData.swift
//  BeaconAdSDK
//
//  Created by Nikita Konstantinovskiy on 19.04.17.
//  Copyright © 2017 BeaconAd. All rights reserved.
//

import Foundation

class BeaconsData {
    var waitSeconds: UInt
    var beacons = [String: String]()
    
    let file = "Beacons.txt"
    let applicationSupportDirectory = NSSearchPathDirectory.ApplicationSupportDirectory
    let nsUserDomainMask = NSSearchPathDomainMask.UserDomainMask
    let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true)
    let fileManager = NSFileManager.defaultManager()
    
    internal init(hoursNotActive: UInt) {
        waitSeconds = hoursNotActive * 15
        _getBeacons()
    }
    
    
    private func _getBeacons() -> [String: String] {
        let path = paths[0] + "/" + file
        if !fileManager.fileExistsAtPath(path) {
            fileManager.createFileAtPath(path, contents: nil, attributes: nil)
        }
        let data = NSData(contentsOfFile: path)
        var jsonData = NSDictionary()
        do {jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! NSDictionary} catch {}
        
        beacons = jsonData as! [String: String]
        
        let time = NSDate()
        let ts = time.timeIntervalSince1970
        let timestamp = UInt(ts)
        
        var isChange = false
        
        for beacon in beacons.keys {
            if timestamp - UInt(beacons[beacon]!)! > waitSeconds {
                beacons.removeValueForKey(beacon)
                isChange = true
            }
        }
        
        if isChange {
            writeBeacons()
        }
        
        return beacons
    }
    
    func getBeacons() -> [String: String] {
        var isChange = false
        let time = NSDate()
        let ts = time.timeIntervalSince1970
        let timestamp = UInt(ts)
        
        for beacon in beacons.keys {
            if timestamp - UInt(beacons[beacon]!)! > waitSeconds {
                beacons.removeValueForKey(beacon)
                isChange = true
            }
        }
        
        if isChange {
            getBeacons()
        }
        
        return beacons
    }
    
    private func writeBeacons() {
        let path = paths[0] + "/" + file
        var jsonData = NSData()
        do {
            jsonData = try NSJSONSerialization.dataWithJSONObject(beacons, options: NSJSONWritingOptions.PrettyPrinted)
        } catch let e {
            print(e)
        }
        
        do { try jsonData.writeToFile(path, options: .AtomicWrite)} catch{}
        
        _getBeacons()
    }
    
    internal func addBeacon(uuid: String) {
        let time = NSDate()
        let ts = time.timeIntervalSince1970
        let timestamp = "\(UInt(ts))"
        _getBeacons()
        
        beacons[uuid] = timestamp
        
        writeBeacons()
    }
    
    internal func removeBeacon(uuid: String) {
        if beacons[uuid] != nil {
            beacons.removeValueForKey(uuid)
        }
        writeBeacons()
    }
}
