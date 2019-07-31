//
//  PasswordViewController.swift
//  FPGiOS
//
//  Created by Xlfdll on 2019/07/25.
//  Copyright © 2019 Xlfdll Workstation. All rights reserved.
//

import UIKit

class PasswordViewController: UITableViewController, UITextFieldDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        KeywordUITextField.delegate = self

        if UserDefaults.standard.object(forKey: AppDataKeys.UserUUIDKey) == nil {
            UserDefaults.standard.set(UUID().uuidString, forKey: AppDataKeys.UserUUIDKey)

            let alert = UIAlertController(title: NSLocalizedString("FirstTimeAlert.Title", comment: "First-time alert title"),
                message: NSLocalizedString("FirstTimeAlert.Content", comment: "First-time alert text content"),
                preferredStyle: UIAlertController.Style.alert)

            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"),
                style: UIAlertAction.Style.default))

            self.present(alert, animated: true)
        }

        if UserDefaults.standard.bool(forKey: AppDataKeys.SaveLastUserSaltKey) {
            UserSaltUITextField.text = UserDefaults.standard.string(forKey: AppDataKeys.UserSaltKey)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        KeywordUITextField.text = ""

        if !UserDefaults.standard.bool(forKey: AppDataKeys.SaveLastUserSaltKey) {
            UserSaltUITextField.text = ""
        }

        keywordAndSaltEditingChanged(self)
    }

    @IBAction func keywordAndSaltEditingChanged(_ sender: Any) {
        GeneratePasswordUIButton.isEnabled = !(KeywordUITextField.text ?? "").isEmpty && !(UserSaltUITextField.text ?? "").isEmpty
    }

    @IBAction func copyPasswordAction(_ sender: Any) {
        if !((PasswordUILabel.text ?? "").isEmpty) {
            UIPasteboard.general.string = PasswordUILabel.text
        }
    }

    @IBAction func generatePasswordAction(_ sender: Any) {
        PasswordUILabel.text = PasswordHelper.generatePassword(keyword: KeywordUITextField.text!,
            salt: UserSaltUITextField.text!,
            length: UserDefaults.standard.integer(forKey: AppDataKeys.PasswordLengthKey))
        PasswordUILabel.sizeToFit()

        if UserDefaults.standard.bool(forKey: AppDataKeys.AutoCopyPasswordKey) && !(PasswordUILabel.text ?? "").isEmpty {
            UIPasteboard.general.string = PasswordUILabel.text
        }

        if UserDefaults.standard.bool(forKey: AppDataKeys.SaveLastUserSaltKey) {
            UserDefaults.standard.set(UserSaltUITextField.text, forKey: AppDataKeys.UserSaltKey)
        }

        CopyPasswordUIButton.isEnabled = !(PasswordUILabel.text ?? "").isEmpty
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if GeneratePasswordUIButton.isEnabled {
            generatePasswordAction(textField as Any)
        }

        return textField.resignFirstResponder()
    }

    @IBOutlet weak var KeywordUITextField: UITextField!
    @IBOutlet weak var UserSaltUITextField: UITextField!
    @IBOutlet weak var PasswordUILabel: UILabel!
    @IBOutlet weak var CopyPasswordUIButton: UIButton!
    @IBOutlet weak var GeneratePasswordUIButton: UIButton!
}
