//
//  PhoneNumberViewController.swift
//  OpenTrace

import UIKit
import FirebaseAuth
//import GMiDBOXSDK

class PhoneNumberViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var refixPhoneTextField: UITextField!
    @IBOutlet weak var prefixPhoneLb: UILabel!
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var getOTPButton: UIButton!
    let MIN_PHONE_LENGTH = 8
    let PHONE_NUMBER_LENGTH = 15
    var countryPickerView = UIPickerView()
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.phoneNumberField.addTarget(self, action: #selector(self.phoneNumberFieldDidChange), for: UIControl.Event.editingChanged)
        self.phoneNumberFieldDidChange()
        phoneNumberField.delegate = self
        dismissKeyboardOnTap()
        countryPickerView.delegate = self
        countryPickerView.dataSource = self
        refixPhoneTextField.inputView = countryPickerView
        loadPhoneInfo()
//        onSDKConnect()
        self.addDoneButtonOnKeyboard()

    }
    func loadPhoneInfo() {
        if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
            print(countryCode)
            let strCode = Countries.countryFromCountryCode(countryCode: countryCode).phoneExtension
            self.refixPhoneTextField.text = String(format: "+%@", strCode)

        }

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.phoneNumberField.becomeFirstResponder()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    @IBAction func nextButtonClicked(_ sender: Any) {
        getOTPButton.isEnabled = false
        verifyPhoneNumberAndProceed(self.refixPhoneTextField.text!  + self.phoneNumberField.text!)
    }

    @objc
    func phoneNumberFieldDidChange() {
        self.getOTPButton.isEnabled = self.phoneNumberField.text?.count ?? 0 >= MIN_PHONE_LENGTH
        if self.phoneNumberField.text?.count == PHONE_NUMBER_LENGTH {
            self.phoneNumberField.resignFirstResponder()
        }
    }

    func verifyPhoneNumberAndProceed(_ mobileNumber: String) {
        activityIndicator.startAnimating()
        PhoneAuthProvider.provider().verifyPhoneNumber(mobileNumber, uiDelegate: nil) { [weak self] (verificationID, error) in
            if let error = error {
                let errorAlert = UIAlertController(title: "Error verifying phone number", message: error.localizedDescription, preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    NSLog("Unable to verify phone number")
                }))
                self?.present(errorAlert, animated: true)
                Logger.DLog("Phone number verification error: \(error.localizedDescription)")
                return
            }
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            UserDefaults.standard.set(mobileNumber, forKey: "mobileNumber")
            self?.performSegue(withIdentifier: "segueFromNumberToOTP", sender: self)
            self?.activityIndicator.stopAnimating()
        }
    }

    //  limit text field input to 15 characters
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                           replacementString string: String) -> Bool {
        let maxLength = PHONE_NUMBER_LENGTH
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
}

extension PhoneNumberViewController : UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Countries.countries.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(format: "%@ (%@)", Countries.countries[row].name, Countries.countries[row].phoneExtension)
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let country = Countries.countries[row]
        self.refixPhoneTextField.text = String(format: "+%@", country.phoneExtension)
    }
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Done", comment: "Done"), style: .done, target: self, action: #selector(self.doneButtonAction))
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        phoneNumberField.inputAccessoryView = doneToolbar
    }
    @objc func doneButtonAction() {
        phoneNumberField.resignFirstResponder()
    }
}
