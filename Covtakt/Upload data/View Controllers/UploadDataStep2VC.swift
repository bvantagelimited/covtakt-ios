//
//  UploadDataStep2VC.swift
//  OpenTrace

import Foundation
import UIKit
import Firebase
import FirebaseFunctions
import CoreData

class UploadDataStep2VC: UIViewController {
    @IBOutlet weak var disclaimerTextLbl: UILabel!
    @IBOutlet weak var codeInputView: CodeInputView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var uploadErrorMsgLbl: UILabel!

    let uploadFailErrMsg = "Upload failed. Please try again later."
    let invalidPinErrMsg = "Neispravan PIN"

    var functions = Functions.functions(region: "europe-west1")
    let storageUrl = PlistHelper.getvalueFromInfoPlist(withKey: "FIREBASE_STORAGE_URL") ?? ""

    override func viewDidLoad() {
        
        disclaimerTextLbl.semiBold(text: "We don’t collect any geolocation or personal data.")
        _ = codeInputView.becomeFirstResponder()
        dismissKeyboardOnTap()
    }
  
    @IBAction func backBtnTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func uploadDataBtnTapped(_ sender: UIButton) {
        let code = codeInputView.text
        if(code == ""){
            return
        }
        sender.isEnabled = false
        
        self.uploadErrorMsgLbl.isHidden = true
        activityIndicator.startAnimating()
        
        
        functions.httpsCallable("getUploadToken").call(code) { [unowned self] (result, error) in
            if let error = error as NSError? {
                sender.isEnabled = true
                self.activityIndicator.stopAnimating()
                self.uploadErrorMsgLbl.text = self.uploadFailErrMsg

                if error.domain == FunctionsErrorDomain {
                    let code = FunctionsErrorCode(rawValue: error.code)
                    let message = error.localizedDescription
                    let details = error.userInfo[FunctionsErrorDetailsKey]

                    Logger.DLog("Cloud Function Error - [\(String(describing: code))][\(message)][\(String(describing: details))]")
                    
                    self.uploadErrorMsgLbl.isHidden = false
                    self.uploadErrorMsgLbl.text = message
                    sender.isEnabled = true
                    self.activityIndicator.stopAnimating()
                }

                Logger.DLog("Error - \(error)")
            }

            if let token = (result?.data as? [String: Any])?["token"] as? String {
                    self.uploadFile(token: token) { success in
                    self.codeInputView.textField!.text = ""
                    sender.isEnabled = true
                    self.activityIndicator.stopAnimating()
                    if success {
                        
                        self.performSegue(withIdentifier: "showSuccessVCSegue", sender: nil)
                    } else {
                        self.uploadErrorMsgLbl.isHidden = false
                        self.uploadErrorMsgLbl.text = self.uploadFailErrMsg
                       
                    }
                }
            }
        }
    }

    func uploadFile(token: String, _ result: @escaping (Bool) -> Void) {
        let manufacturer = "Apple"
        let model = DeviceInfo.getModel().replacingOccurrences(of: " ", with: "")

        let date: Date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH-mm-ss_dd-MM-yyyy"
        let todayDate = dateFormatter.string(from: date)

        let file = "\(manufacturer)_\(model)_\(todayDate).json"

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let managedContext = appDelegate.persistentContainer.viewContext

        let recordsFetchRequest: NSFetchRequest<Encounter> = Encounter.fetchRequestForRecords()
        let eventsFetchRequest: NSFetchRequest<Encounter> = Encounter.fetchRequestForEvents()

        managedContext.perform { [unowned self] in
            guard let records = try? recordsFetchRequest.execute() else {
                Logger.DLog("Error fetching records")
                result(false)
                return
            }

            guard let events = try? eventsFetchRequest.execute() else {
                Logger.DLog("Error fetching events")
                result(false)
                return
            }

            let data = UploadFileData(token: token, records: records, events: events)

            let encoder = JSONEncoder()
            guard let json = try? encoder.encode(data) else {
                Logger.DLog("Error serializing data")
                result(false)
                return
            }

            guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                Logger.DLog("Error locating user documents directory")
                result(false)
                return
            }

            let fileURL = directory.appendingPathComponent(file)

            do {
                try json.write(to: fileURL, options: [])
            } catch {
                Logger.DLog("Error writing to file")
                result(false)
                return
            }
            let date: Date = Date()
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "yyyyMMdd"
           let todayDate = dateFormatter.string(from: date)
            let fileRef = Storage.storage(url: self.storageUrl).reference().child("streetPassRecords").child(todayDate).child("\(file)")

            _ = fileRef.putFile(from: fileURL, metadata: nil) { metadata, error in
                guard let metadata = metadata else {
                    Logger.DLog("Error uploading file - \(String(describing: error))")
                    result(false)
                    return
                }

                let size = metadata.size

                do {
                    try FileManager.default.removeItem(at: fileURL)
                } catch {
                    Logger.DLog("Error deleting uploaded file on local device")
                }

                Logger.DLog("File uploaded [\(size)]")
                result(true)
            }
        }
    }
}
