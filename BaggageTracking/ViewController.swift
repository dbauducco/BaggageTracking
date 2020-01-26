//
//  ViewController.swift
//  BaggageTracking
//
//  Created by David Bauducco on 1/25/20.
//  Copyright © 2020 David Bauducco. All rights reserved.
//

import UIKit
import CoreNFC
import Alamofire

class ViewController: UIViewController, NFCNDEFReaderSessionDelegate {

    var setStatus = "Loaded off plane"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    var nfcSession: NFCNDEFReaderSession?
    
    @IBAction func checkInLuggage(_ sender: Any) {
        nfcSession = NFCNDEFReaderSession.init(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        nfcSession?.begin()
        setStatus = "Checked In"
    }
    
    @IBAction func luggageEnteredPlane(_ sender: Any) {
        nfcSession = NFCNDEFReaderSession.init(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        nfcSession?.begin()
        setStatus = "Loaded on aircreaft"
    }
    
    @IBAction func luggageLeftPlane(_ sender: Any) {
        nfcSession = NFCNDEFReaderSession.init(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        nfcSession?.begin()
        setStatus = "Offloaded from aircraft"
    }
    
    @IBAction func luggageEnteredPickup(_ sender: Any) {
        nfcSession = NFCNDEFReaderSession.init(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        nfcSession?.begin()
        setStatus = "In baggage claim area"
    }
    
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        
        let nfcData = String(data: messages[0].records[0].payload.advanced(by: 3), encoding: .utf8)!
        
        let data = Data(nfcData.utf8)
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String:AnyObject]
            {
                let postData = LuggageData(id: json["id"] as! String, status: setStatus, deviceId: "493483", bagName: json["bagName"] as! String, weight: json["weight"] as! String)
                AF.request("https://us-central1-tamuhackair.cloudfunctions.net/update", method: .post, parameters: postData, encoder: JSONParameterEncoder.default).response { response in
                    
                    debugPrint(response)
                }
            }
        } catch let error as NSError {
            print(error)
        }
        
    }
    
    
}

struct LuggageData: Encodable {
    
    let id: String
    let status: String
    let deviceId: String
    let bagName: String
    let weight: String
}
