//
//  Ad.swift
//  BeaconAdSDK
//
//  Created by Nikita Konstantinovskiy on 19.04.17.
//  Copyright © 2017 BeaconAd. All rights reserved.
//

import Foundation
import ZXingObjC

public class Ad {
    let client_uid: String
    let adcompany_uid: String
    var _status = false
    var picture_pass: String?
    var message: String?
    var ad_uid: String?
    
    internal init(client_uid: String, adcompany_uid: String) {
        self.client_uid = client_uid
        self.adcompany_uid = adcompany_uid
    }
    
    internal func getAd(completion: (result: Bool) -> ()) {
        WebRequest.GetAd(client_uid, adcompany_uid: adcompany_uid) { (data, response, err) in
            if (err != nil) {
                completion(result: false)
            }
            else {
                var jsonData = NSDictionary()
                do {
                    jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! NSDictionary
                } catch
                {
                    completion(result: false)
                }
                
                var dict: [String: AnyObject] = jsonData as! [String: AnyObject]
                
                if dict["status"] as! String == "error" {
                    completion(result: false)
                }
                else {
                    self._status = true
                    
                    self.picture_pass = dict["ad"]!["picture_pass"] as! String
                    self.message = dict["ad"]!["message"] as! String
                    self.ad_uid = dict["ad"]!["auid"] as! String
                    completion(result: true)
                }
                
            }
        }
    }
    
    public func getPicture() -> UIImage {
        var image: UIImage?
        if (picture_pass != nil) {
            if let data = NSData(contentsOfURL: NSURL(string: picture_pass!)!) {
                image = UIImage(data: data)
            }
        }
        return image!
    }
    
    public func getQRCode() -> UIImage {
        var image: UIImage?
        
        if (ad_uid != nil) {
            let qrData = ["ad_uid": ad_uid! as String, "client_uid": client_uid]
        
            var jsonData = NSData()
            do {
                jsonData = try NSJSONSerialization.dataWithJSONObject(qrData, options: NSJSONWritingOptions.PrettyPrinted)
            } catch let e {
                return image!
            }
            
            let code = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as! String
        
            let writer: ZXMultiFormatWriter = ZXMultiFormatWriter.writer() as! ZXMultiFormatWriter
            
            var result: ZXBitMatrix?
            do { result = try writer.encode(code, format: kBarcodeFormatQRCode, width: 500, height: 500)} catch {return image! }
            
            if result != nil {
                let cgimage = ZXImage(matrix: result).cgimage
                image = UIImage(CGImage: cgimage)
            }
        }
        
        return image!
    }
    
    public func getMessage() -> String {
        return message!
    }
}
