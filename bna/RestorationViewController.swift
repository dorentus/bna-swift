//
//  RestorationViewController.swift
//  bna
//
//  Created by Rox Dorentus on 2014-6-23.
//  Copyright (c) 2014年 rubyist.today. All rights reserved.
//

import UIKit
import Padlock

class RestorationViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var error_label: UILabel!
    @IBOutlet weak var serial_field: UITextField!
    @IBOutlet weak var restorecode_field: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        serial_field.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func dismiss(sender: UIButton!) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func textChanged(sender: UITextField!) {
        validate(textField: sender)
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let valid = validate(textField: textField)

        if textField == serial_field {
            restorecode_field.becomeFirstResponder()
        }
        else if textField == restorecode_field {
            submit()
        }

        return valid
    }

    func validate(#textField: UITextField) -> Bool {
        if textField == serial_field {
            return _validateSerialField()
        }
        else if textField == restorecode_field {
            return _validateRestorecodeField()
        }

        return false
    }

    func submit() {
        MMProgressHUD.show()

        Authenticator.restore(serial: serial_field.text, restorecode: restorecode_field.text) {
            [weak self] authenticator, error in
            if let a = authenticator {
                AuthenticatorStorage.sharedStorage.add(a)
                MMProgressHUD.dismissWithSuccess("success!")
                let pc = self!.presentingViewController as! UINavigationController
                self!.dismissViewControllerAnimated(true) {
                    (pc.topViewController as! MainViewController).reloadAndScrollToBottom()
                }
            }
            else {
                let message = error?.localizedDescription ?? "unknown error"
                MMProgressHUD.dismissWithError(message)
            }
        }
    }

    func _validateSerialField() -> Bool {
        if (Serial.format(serial: serial_field.text) != nil) {

            if AuthenticatorStorage.sharedStorage.exists(serial_field.text) {
                error_label.text = "authenticator already exists"
                return false
            }

            error_label.text = ""
            return true
        }

        error_label.text = "invalid serial"
        return false
    }

    func _validateRestorecodeField() -> Bool {
        if (Restorecode.format(restorecode: restorecode_field.text) != nil) {
            error_label.text = ""
            return true
        }

        error_label.text = "invalid restoration code"
        return false
    }

}
