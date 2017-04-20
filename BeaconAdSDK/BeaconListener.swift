//
//  BeaconListener.swift
//  BeaconAdSDK
//
//  Created by Nikita Konstantinovskiy on 18.04.17.
//  Copyright © 2017 BeaconAd. All rights reserved.
//

import Foundation
import CoreLocation
import UserNotifications

public protocol BeaconListenerDelegate {
    func notificationWasPushed(ad: Ad)
}

public class BeaconListener: UIViewController, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {
    let locationManager = CLLocationManager()
    private var _beaconAd: BeaconAd? = nil
    var regions = [CLBeaconRegion]()
    var isListening = false
    var curAd: Ad?
    
    var client: Client?
    var data: BeaconsData?
    
    public var delegate: BeaconListenerDelegate?
    
    var beaconAd: BeaconAd {
        set {
            _beaconAd = newValue
        }
        get {
            return _beaconAd!
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        self.locationManager.allowsBackgroundLocationUpdates = true
    }
    
    func beaconNotification(ad: Ad) {
        curAd = ad
        
        let p = ad.getPicture()
        let m = ad.getMessage()
        
        if UIApplication.sharedApplication().applicationState == UIApplicationState.Active {
            let alert = UIAlertController(title: "BeaconAd", message: m, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
            alert.addAction(UIAlertAction(title: "Open", style: UIAlertActionStyle.Default, handler: { (act: UIAlertAction) in
                    self.sendToDelegate()
                }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else {
            let content = UNMutableNotificationContent()
            content.title = NSString.localizedUserNotificationStringForKey("BeaconAd", arguments: nil)
            content.body = NSString.localizedUserNotificationStringForKey(m, arguments: nil)
            content.attachments.append(create(p)!)
            
        
            content.sound = UNNotificationSound.defaultSound()
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
            let request = UNNotificationRequest(identifier: "FiveSecond", content: content, trigger: trigger)
            let center = UNUserNotificationCenter.currentNotificationCenter()
            center.delegate = self
            center.addNotificationRequest(request, withCompletionHandler: { (err: NSError?) in
                print("\(err)")
            })
        }
    }
    
    func sendToDelegate() {
        if delegate != nil && curAd != nil {
            delegate?.notificationWasPushed(curAd!)
        }
    }
    
    public func userNotificationCenter(center: UNUserNotificationCenter, didReceiveNotificationResponse response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Void) {
        sendToDelegate()
    }
    
    func create(image: UIImage) -> UNNotificationAttachment? {
        let file = "img.png"
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true)
        let fileManager = NSFileManager.defaultManager()
        let path = paths[0] + "/" + file
        
        if !fileManager.fileExistsAtPath(path) {
            fileManager.createFileAtPath(path, contents: nil, attributes: nil)
        }
        
        let img = UIImagePNGRepresentation(image)
        
        do {
            try img!.writeToFile(path, options: .AtomicWrite)
            let iA = try UNNotificationAttachment(identifier: "img", URL: NSURL(fileURLWithPath: path), options: nil)
            return iA
        } catch{}
        return nil
    }
    
    public func initListener(uid: String, hoursToWait: UInt, completion: (status: Bool) -> ()) {
        data = BeaconsData(hoursNotActive: hoursToWait)
        createBeaconAdComapny(uid, completion: completion)
    }
    
    public func initClient(email: String, completion: (status: Bool, uid: String) -> ()) {
        client = Client(email: email, completion: { (result) in
            completion(status: result, uid: (self.client?.uid)!)
        })
    }
    
    func createBeaconAdComapny(uid: String, completion: (status: Bool) -> ()) {
        if (client != nil) {
            print(CLLocationManager.authorizationStatus())
            if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedAlways) {
                locationManager.requestAlwaysAuthorization()
                
            }
        
            beaconAd = BeaconAd(companyUID: uid, completion: { (result) in
                if result {
                    self.createRegions()
                }
                completion(status: result)
            })
        }
    }
    
    func createRegions() {
        if (_beaconAd != nil) {
            if _beaconAd?.status["status"] as! Bool {                
                for beacon in (_beaconAd?.beaconsUUID)! {
                    let UUID = NSUUID(UUIDString: beacon)
                    let region = CLBeaconRegion(proximityUUID: UUID!, identifier: beacon)
                    regions.append(region)
                }
                startListen()
            }
        }
    }
    
    public func startListen() {
        self.locationManager.startUpdatingLocation()
        for region in regions {
            locationManager.startMonitoringForRegion(region)
            locationManager.startRangingBeaconsInRegion(region)
        }
    }
    
    public func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        print(beacons)
        if beacons.count > 0 {
            if data?.getBeacons()[beacons[0].proximityUUID.UUIDString] == nil {
                data?.addBeacon(beacons[0].proximityUUID.UUIDString)
                
                let ad = Ad(client_uid: client!.uid, adcompany_uid: beaconAd.UID)
                ad.getAd({ (result) in
                    if result {
                        self.beaconNotification(ad)
                    }
                })
            }
        }
    }
}
