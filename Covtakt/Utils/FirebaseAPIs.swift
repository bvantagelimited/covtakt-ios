import Foundation
import FirebaseFunctions

struct FirebaseAPIs {
    static var functions = Functions.functions(region: "europe-west1")
    
    static func generateJWT(_ onComplete: @escaping (String?) -> Void) {
        functions.httpsCallable("getRequestJwt").call("381692023534") { (resp, error) in
            guard error == nil else {
                if let error = error as NSError? {
                    if error.domain == FunctionsErrorDomain {
                        let code = FunctionsErrorCode(rawValue: error.code)
                        let message = error.localizedDescription
                        let details = error.userInfo[FunctionsErrorDetailsKey]
                        Logger.DLog("Cloud function error. Code: \(String(describing: code)), Message: \(message), Details: \(String(describing: details))")
                        onComplete(nil)
                        return
                    }
                } else {
                    Logger.DLog("Cloud function error, unable to convert error to NSError.\(error!)")
                }
                onComplete(nil)
                return
            }
            guard let signed_jwt = (resp?.data as? [String: Any])?["signed_jwt"] as? String else {
                onComplete(nil)
                return
            }
            onComplete(signed_jwt)
        }
    }
    static func signInIPification(code: String, _ onComplete: @escaping (String?) -> Void) {
        functions.httpsCallable("signinWithIpification").call(["code": code, "redirect_uri": "demoip://oauth2redirect/provider"]) { (resp, error) in
            guard error == nil else {
                if let error = error as NSError? {
                    if error.domain == FunctionsErrorDomain {
                        let code = FunctionsErrorCode(rawValue: error.code)
                        let message = error.localizedDescription
                        let details = error.userInfo[FunctionsErrorDetailsKey]
                        Logger.DLog("Cloud function error. Code: \(String(describing: code)), Message: \(message), Details: \(String(describing: details))")
                        onComplete(nil)
                        return
                    }
                } else {
                    Logger.DLog("Cloud function error, unable to convert error to NSError.\(error!)")
                }
                onComplete(nil)
                return
            }
            print(resp?.data)
            guard let customToken = (resp?.data as? [String: Any])?["customToken"] as? String else {
                onComplete(nil)
                return
            }
            onComplete(customToken)
        }
    }
//    static func getHandshakePin(_ onComplete: @escaping (String?) -> Void) {
//        functions.httpsCallable("getHandshakePin").call { (resp, error) in
//            guard error == nil else {
//                if let error = error as NSError? {
//                    if error.domain == FunctionsErrorDomain {
//                        let code = FunctionsErrorCode(rawValue: error.code)
//                        let message = error.localizedDescription
//                        let details = error.userInfo[FunctionsErrorDetailsKey]
//                        Logger.DLog("Cloud function error. Code: \(String(describing: code)), Message: \(message), Details: \(String(describing: details))")
//                        onComplete(nil)
//                        return
//                    }
//                } else {
//                    Logger.DLog("Cloud function error, unable to convert error to NSError.\(error!)")
//                }
//                onComplete(nil)
//                return
//            }
//            guard let pin = (resp?.data as? [String: Any])?["pin"] as? String else {
//                onComplete(nil)
//                return
//            }
//            onComplete(pin)
//        }
//    }
    static func setDeviceToken(token: String, _ onComplete: @escaping (String?) -> Void) {
        functions.httpsCallable("setDeviceToken").call(token) { (resp, error) in
            guard error == nil else {
                if let error = error as NSError? {
                    if error.domain == FunctionsErrorDomain {
                        let code = FunctionsErrorCode(rawValue: error.code)
                        let message = error.localizedDescription
                        let details = error.userInfo[FunctionsErrorDetailsKey]
                        Logger.DLog("Cloud function error. Code: \(String(describing: code)), Message: \(message), Details: \(String(describing: details))")
                        onComplete(nil)
                        return
                    }
                } else {
                    Logger.DLog("Cloud function error, unable to convert error to NSError.\(error!)")
                }
                onComplete(nil)
                return
            }
            print(resp?.data)
            onComplete(nil)
        }
    }
}
