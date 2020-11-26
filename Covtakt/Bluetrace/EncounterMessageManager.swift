import Foundation
import FirebaseFunctions
import FirebaseAuth
class EncounterMessageManager {
    let userDefaultsTempIdKey = "BROADCAST_MSG"
    let userDefaultsTempIdArrayKey = "BROAD_MSG_ARRAY"
    let userDefaultsAdvtKey = "ADVT_DATA"
    let userDefaultsAdvtExpiryKey = "ADVT_EXPIRY"

    static let shared = EncounterMessageManager()

    lazy var functions = Functions.functions(region: "europe-west1")

    var tempId: String? {
        guard var tempIds = UserDefaults.standard.array(forKey: userDefaultsTempIdArrayKey) as! [[String: Any]]? else {
            return "not_found"
        }
        if(tempIds == nil || tempIds.count == 0){
            return "tempId_error"
        }
//        if let bmExpiry = tempIds.first?["expiryTime"] {
//
//            print(date, Date())
//            while (Date() > date as Date && tempIds.count > 0 ){
//                tempIds.removeFirst()
//                print("tempIds " , tempIds.count)
//            }
//        }
        var validTempId = tempIds.first
        for item in tempIds{
            let bmExpiry = item["expiryTime"]
            let date = NSDate(timeIntervalSince1970: bmExpiry as! TimeInterval)
            if(Date() < date as Date){
                validTempId = item
                break
            }
        }

        guard let validBm = validTempId?["tempID"] as? String else { return "" }
//        print("validBm", validBm)
        return validBm
    }

    var advtPayload: Data? {
        return UserDefaults.standard.data(forKey: userDefaultsAdvtKey)
    }

    // This variable stores the expiry date of the broadcast message. At the same time, we will use this expiry date as the expiry date for the encryted advertisement payload
    var advtPayloadExpiry: Date? {
        return UserDefaults.standard.object(forKey: userDefaultsAdvtExpiryKey) as? Date
    }

    func setup() {
        
        if(Auth.auth().currentUser == nil){
            return
        }
        print(Auth.auth().currentUser!.uid)
        // Check payload validity
        if advtPayloadExpiry == nil ||  Date() > advtPayloadExpiry! {

            fetchBatchTempIdsFromFirebase { [unowned self](error: Error?, resp: (tempIds: [[String: Any]], refreshDate: Date)?) in
                guard let response = resp else {
                    Logger.DLog("No response, Error: \(String(describing: error))")
                    return
                }
                _ = self.setAdvtPayloadIntoUserDefaultsv2(response)
                UserDefaults.standard.set(response.tempIds, forKey: self.userDefaultsTempIdArrayKey)

            }

        }
    }

    func getTempId(onComplete: @escaping (String?) -> Void) {
        // Check refreshDate
        if advtPayloadExpiry == nil ||  Date() > advtPayloadExpiry! {
            fetchBatchTempIdsFromFirebase { [unowned self](error: Error?, resp: (tempIds: [[String: Any]], refreshDate: Date)?) in
                guard let response = resp else {
                    Logger.DLog("No response, Error: \(String(describing: error))")
                    return
                }

                _ = self.setAdvtPayloadIntoUserDefaultsv2(response)
                UserDefaults.standard.set(response.tempIds, forKey: self.userDefaultsTempIdArrayKey)
                UserDefaults.standard.set(response.refreshDate, forKey: self.userDefaultsAdvtExpiryKey)

                var dataArray = response

//                if let bmExpiry = dataArray.tempIds.first?["expiryTime"] as? Date {
//                    while Date() > bmExpiry {
//                        dataArray.tempIds.removeFirst()
//                    }
//                }

                var validTempId =  dataArray.tempIds.first
                for item in  dataArray.tempIds{
                   let bmExpiry = item["expiryTime"]
                   let date = NSDate(timeIntervalSince1970: bmExpiry as! TimeInterval)
                   if(Date() < date as Date){
                       validTempId = item
                       break
                   }
                }
                guard let validBm = validTempId?["tempID"] as? String else { return }
                UserDefaults.standard.set(validBm, forKey: self.userDefaultsTempIdKey)

                onComplete(validBm)
                return

            }
        }

        // We know that tempIdBatch array has not expired, now find the latest usable tempId
        if let msg = tempId {
            onComplete(msg)
        } else {
            // This is not part of usual expected flow, just run setup
            setup()
            onComplete(nil)
        }
    }

    func fetchTempIdFromFirebase(onComplete: ((Error?, (String, Date)?) -> Void)?) {
        Logger.DLog("Fetching tempId from firebase")
        functions.httpsCallable("getBroadcastMessage").call { (result, error) in
            // Handle error
            guard error == nil else {
                if let error = error as NSError? {
                    if error.domain == FunctionsErrorDomain {
                        let code = FunctionsErrorCode(rawValue: error.code)
                        let message = error.localizedDescription
                        let details = error.userInfo[FunctionsErrorDetailsKey]
                        Logger.DLog("Cloud function error. Code: \(String(describing: code)), Message: \(message), Details: \(String(describing: details))")
                        onComplete?(error, nil)
                        return
                    }
                } else {
                    Logger.DLog("Cloud function error, unable to convert error to NSError.\(error!)")
                }
                onComplete?(error, nil)
                return
            }

            // Handle getting a valid tempId from Firebase function
            guard let tempIdBase64 = (result?.data as? [String: Any])?["bm"] as? String,
                let bmRefreshTime = (result?.data as? [String: Any])?["refreshTime"] as? Double else {
                    Logger.DLog("Unable to get tempId or refreshTime from Firebase. result of function call: \(String(describing: result))")
                    onComplete?(NSError(domain: "BM", code: 9999, userInfo: nil), nil)
                    return
            }

            onComplete?(nil, (tempIdBase64, Date(timeIntervalSince1970: bmRefreshTime)))
        }
    }

    func fetchBatchTempIdsFromFirebase(onComplete: ((Error?, ([[String: Any]], Date)?) -> Void)?) {
        Logger.DLog("Fetching Batch of tempIds from firebase")
        functions.httpsCallable("getTempIDs").call { (result, error) in
            // Handle error
            guard error == nil else {
                if let error = error as NSError? {
                    if error.domain == FunctionsErrorDomain {
                        let code = FunctionsErrorCode(rawValue: error.code)
                        let message = error.localizedDescription
                        let details = error.userInfo[FunctionsErrorDetailsKey]
                        Logger.DLog("Cloud function error. Code: \(String(describing: code)), Message: \(message), Details: \(String(describing: details))")
                        onComplete?(error, nil)
                        return
                    }
                } else {
                    Logger.DLog("Cloud function error, unable to convert error to NSError.\(error!)")
                }
                onComplete?(error, nil)
                return
            }
//            print("tempids print ",(result?.data as? [String: Any])?["tempIDs"])
            // Handle getting a batch of tempIds from Firebase function
            guard let tempIdsInBase64 = (result?.data as? [String: Any])?["tempIDs"] as? [[String: Any]],
                let bmRefreshTime = (result?.data as? [String: Any])?["refreshTime"] as? Double else {
                    Logger.DLog("Unable to get tempId or refreshTime from Firebase. result of function call: \(String(describing: result))")
                    onComplete?(NSError(domain: "BM", code: 9999, userInfo: nil), nil)
                    return
            }

            onComplete?(nil, (tempIdsInBase64, Date(timeIntervalSince1970: bmRefreshTime)))
        }
    }

    func setAdvtPayloadIntoUserDefaultsv2(_ response: (tempIds: [[String: Any]], refreshDate: Date)) -> Data? {

        var dataArray = response
        if(dataArray.tempIds == nil || dataArray.tempIds.count == 0){
            return nil
        }

//        // Pop out expired tempId
//        if let bmExpiry = dataArray.tempIds.first?["expiryTime"] as? Date {
//            while Date() > bmExpiry {
//                dataArray.tempIds.removeFirst()
//            }
//        }
        var validTempId =  dataArray.tempIds.first
        for item in  dataArray.tempIds{
            let bmExpiry = item["expiryTime"]
            let date = NSDate(timeIntervalSince1970: bmExpiry as! TimeInterval)
            if(Date() < date as Date){
                validTempId = item
                break
            }
        }

        guard let validBm = validTempId?["tempID"] as? String else { return nil }

        let peripheralCharStruct = PeripheralCharacteristicsDataV2(mp: DeviceInfo.getModel(), id: validBm, o: BluetraceConfig.OrgID(), v: BluetraceConfig.ProtocolVersion)

        do {
            let encodedPeriCharStruct = try JSONEncoder().encode(peripheralCharStruct)
            if let string = String(data: encodedPeriCharStruct, encoding: .utf8) {
                Logger.DLog("UserDefaultsv2 \(string)")
            } else {
                print("not a valid UTF-8 sequence")
            }

            UserDefaults.standard.set(encodedPeriCharStruct, forKey: self.userDefaultsAdvtKey)
            UserDefaults.standard.set(response.refreshDate, forKey: self.userDefaultsAdvtExpiryKey)
            return encodedPeriCharStruct
        } catch {
            Logger.DLog("Error: \(error)")
        }

        return nil
    }

}
