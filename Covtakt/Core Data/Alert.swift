//
//  Alert.swift
//  Covtakt
//
//  Created by IPification on 28/4/2020.
//  Copyright © 2020 OpenTrace. All rights reserved.
//

import Foundation
import UIKit
class Alert {
    static func showSimpleAlert(_ view : UIViewController) {
        let alert = UIAlertController(title: "Sign out?", message: "You can always access your content by signing back in", preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { _ in
            //Cancel Action
        }))
        alert.addAction(UIAlertAction(title: "Sign out",
                                      style: UIAlertAction.Style.default,
                                      handler: {(_: UIAlertAction!) in
                                        //Sign out action
        }))
        view.present(alert, animated: true, completion: nil)
    }
    
    static func showMessage(_ container: UIViewController, title: String, message: String) {
       let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
       
       alert.addAction(UIAlertAction(title: "Detail".localized(), style: .default, handler: { (action: UIAlertAction!) in
           
           alert .dismiss(animated: true, completion: nil)
           
           
       }))
       
       DispatchQueue.main.async {
           container.present(alert, animated: true, completion: nil)
       }
       
   }
    
    static func writeLocalNotification(message: String, date : Date) {
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formatedDate = formatter.string(from: date) // string purpose I add here

        var dictionary = readLocalNotification()
        if(dictionary == nil){
            dictionary = [["message": message, "created_at": formatedDate]]
        }else{
            dictionary?.append(["message": message, "created_at": formatedDate])
        }
        do {
            let fileURL = try FileManager.default
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("notification.json")

            try JSONSerialization.data(withJSONObject: dictionary)
                .write(to: fileURL)
        } catch {
            print(error)
        }
    }
    
    
    static func readLocalNotification() -> [[String : String]]?{
        do {
            let fileURL = try FileManager.default
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent("notification.json")

            let data = try Data(contentsOf: fileURL)
            let dictionary = try JSONSerialization.jsonObject(with: data)
            return dictionary as? [[String : String]]
        } catch {
            print(error)
        }
        return nil
    }
}
