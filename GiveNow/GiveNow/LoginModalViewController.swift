//
//  LoginModalViewController.swift
//  GiveNow
//
//  Created by Evan Waters on 1/12/16.
//  Copyright © 2016 GiveNow. All rights reserved.
//

import UIKit

public enum EntryMode : Int {
    case None = 0
    case PhoneNumber
    case ConfirmationCode
}

protocol LoginModalViewControllerDelegate{
    func successfulLogin(controller:LoginModalViewController)
}

class LoginModalViewController: UIViewController {
    
    var delegate:LoginModalViewControllerDelegate!
    var isModal:Bool!

    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var _entryMode : EntryMode = .None
    
    var phoneNumber:String!
    
    let backend = Backend.sharedInstance()
    
    var entryMode : EntryMode {
        get {
           return _entryMode
        }
        set {
            if newValue != _entryMode {
                _entryMode = newValue
                self.updateViewForEntryMode(_entryMode)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formatButton(backButton, imageName: "arrow-back")
        formatButton(doneButton, imageName: "checkmark")
        entryMode = .PhoneNumber
        configure()
    }
    
    func configure() {
        validateSubmitButton()
        updateViewForEntryMode(entryMode)
        hideActivityIndicator()
        textField?.becomeFirstResponder()
    }
    
    @IBAction func phoneTextFieldEditingChanged(sender: AnyObject) {
        validateSubmitButton()
    }
    
    func formatButton(button: UIButton, imageName: String){
        button.setImage(UIImage(named: imageName)!.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
        button.tintColor = UIColor.whiteColor()
    }
    
    // MARK: User Actions
    
    
    @IBAction func doneButtonTapped(sender: AnyObject) {
        guard let entryText = textField?.text else {
            assert(false, "Entry text is required")
            return
        }
        
        if entryMode == .PhoneNumber {
            validatePhoneNumber(entryText)
        }
        else if entryMode == .ConfirmationCode {
            if let phoneNumber = self.phoneNumber {
                logInWithPhoneNumber(phoneNumber, codeEntry: entryText)
            }
            else {
                assert(false, "Phone number should always be defined")
            }
        }
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        entryMode = .PhoneNumber
        textField.text = phoneNumber
    }
    
    
    // MARK: Private
    
    private func validatePhoneNumber(entryText: String) {
        if backend.isValidPhoneNumber(entryText) {
            sendPhoneNumber(entryText)
        }
        else {
            updateViewForInvalidPhoneNumber()
        }
    }
    
    private func updateViewForEntryMode(entryMode: EntryMode) {
        guard let instructionsLabel = instructionsLabel,
            let textField = textField,
            let detailLabel = detailLabel,
            let backButton = backButton
            else {
                assert(false, "Outlets are required")
        }
        
        switch entryMode {
        case .PhoneNumber:
            if let countryCallingCode = backend.phoneCountryCodeForPhoneNumberCurrentLocale() {
                textField.text = "+\(countryCallingCode)"
            }
            else {
                textField.text = nil
            }
            instructionsLabel.text = NSLocalizedString("Volunteering - Phone Number Modal Title", comment: "")
            detailLabel.text = NSLocalizedString("Volunteering - Phone Number Modal Details", comment: "")
            backButton.hidden = true
        case .ConfirmationCode:
            textField.text = nil
            instructionsLabel.text = NSLocalizedString("Volunteering - Confirmation Number Modal Title", comment: "")
            detailLabel.text = NSLocalizedString("Volunteering - Confirmation Number Modal Details", comment: "")
            backButton.hidden = false
        default:
            print("No action")
        }
    }
    
    private func updateViewForInvalidPhoneNumber() {
        instructionsLabel.text = "Please enter a valid phone number"
        detailLabel.text = "Example: +49 123 456 7890"
        backButton.hidden = true
    }
    
    private func updateViewForInvalidConfirmationCode() {
        instructionsLabel.text = "Confirmation code is invalid"
        detailLabel.text = ""
    }
    
    private func sendPhoneNumber(phoneNumber: String) {
        showActivityIndicator()
        backend.sendCodeToPhoneNumber(phoneNumber, completionHandler: { (success, error) -> Void in
            if let error = error {
                print(error.localizedDescription)
            }
            else {
                self.hideActivityIndicator()
                // hold onto the phone number to use when logging in
                self.phoneNumber = phoneNumber
                self.textField.placeholder = "5555"
                self.entryMode = .ConfirmationCode
            }
        })
    }
    
    func showActivityIndicator() {
        doneButton.hidden = true
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator() {
        doneButton.hidden = false
        activityIndicator.hidden = true
        activityIndicator.stopAnimating()
    }
    
    private func logInWithPhoneNumber(phoneNumber: String, codeEntry: String) {
        showActivityIndicator()
        backend.logInWithPhoneNumber(phoneNumber, codeEntry: codeEntry, completionHandler: { (success, error) -> Void in
            if let error = error {
                self.hideActivityIndicator()
                self.updateViewForInvalidConfirmationCode()
                print(error.localizedDescription)
            }
            else {
                if self.isModal == true {
                    self.dismissViewControllerAnimated(true, completion: {() -> Void in
                        print("Telling them")
                        self.delegate.successfulLogin(self)
                    })
                }
                else {
                    self.delegate.successfulLogin(self)
                }
            }
        })
    }
    
    private func validateSubmitButton() {
        guard let phoneNumberText = textField?.text else {
            disableDoneButton()
            return
        }
        
        // A phone number should include the country code which is 1 for the United States.
        // Typically the country code is assumed so perhaps it can be added automatically.
        
        if entryMode == .PhoneNumber &&
            (phoneNumberText.characters.count >= 10 &&
                phoneNumberText.characters.count <= 12) {
                    enableDoneButton()
        }
        else if entryMode == .ConfirmationCode && phoneNumberText.characters.count == 4 {
            enableDoneButton()
        }
        else {
            disableDoneButton()
        }
    }
    
    private func disableDoneButton() {
        guard let doneButton = doneButton else {
            return
        }
        
        doneButton.enabled = false
        doneButton.titleLabel?.textColor = UIColor.lightGrayColor()
    }
    
    private func enableDoneButton() {
        guard let doneButton = doneButton else {
            return
        }
        
        doneButton.enabled = true
        doneButton.titleLabel?.textColor = UIColor.whiteColor()
    }

}
