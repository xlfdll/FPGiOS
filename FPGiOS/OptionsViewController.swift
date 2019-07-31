//
//  OptionsViewController.swift
//  FPGiOS
//
//  Created by Xlfdll on 2019/07/25.
//  Copyright © 2019 Xlfdll Workstation. All rights reserved.
//

import UIKit

class OptionsViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        let passwordLength = UserDefaults.standard.integer(forKey: AppDataKeys.PasswordLengthKey)

        PasswordLengthUIPickerView.delegate = self
        PasswordLengthUIPickerView.dataSource = self
        PasswordLengthUIPickerView.selectRow(passwordLength - 4, inComponent: 0, animated: true)

        AutoCopyPasswordUISwitch.isOn = UserDefaults.standard.bool(forKey: AppDataKeys.AutoCopyPasswordKey)
        SaveLastUserSaltUISwitch.isOn = UserDefaults.standard.bool(forKey: AppDataKeys.SaveLastUserSaltKey)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // Edit Random Salt
        if indexPath.row == 0 {
            let alert = UIAlertController(title: NSLocalizedString("RandomSaltAlert.Title", comment: "Edit random salt"),
                message: "",
                preferredStyle: UIAlertController.Style.alert)

            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"),
                style: UIAlertAction.Style.default,
                handler: { (action) in
                    if alert.textFields?[0].text != nil && alert.textFields?[0].text?.isEmpty == false {
                        UserDefaults.standard.set(alert.textFields?[0].text, forKey: AppDataKeys.RandomSaltKey)
                    }
                }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel action"),
                style: UIAlertAction.Style.cancel))

            PasswordLengthDefaultAction = alert.actions[0]

            alert.addTextField { (textField: UITextField) in
                textField.text = String(UserDefaults.standard.string(forKey: AppDataKeys.RandomSaltKey)!)
                textField.placeholder = NSLocalizedString("RandomSaltAlert.Placeholder", comment: "Random salt input placeholder")
                textField.addTarget(self,
                    action: #selector(self.randomSaltValidate(textField:)),
                    for: UITextField.Event.editingChanged)
            }

            self.present(alert, animated: true)
        }
        // Generate New Random Salt
            else if indexPath.row == 1 {
                let alert = UIAlertController(title: NSLocalizedString("GenerateNewRandomSaltAlert.Title", comment: "Generate new random salt"),
                    message: NSLocalizedString("RandomSaltChangeAlert.Message", comment: "Random salt change warning"),
                    preferredStyle: UIAlertController.Style.alert)

                alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Default action"),
                    style: UIAlertAction.Style.default,
                    handler: { (action) in
                        UserDefaults.standard.set(PasswordHelper.generateSalt(length: PasswordHelper.RandomSaltLength),
                            forKey: AppDataKeys.RandomSaltKey)

                        let completeAlert = UIAlertController(title: NSLocalizedString("GenerateNewRandomSaltAlert.Title", comment: "Generate new random salt"),
                            message: NSLocalizedString("GenerateNewRandomSaltCompleteAlert.Message", comment: "Generate new random salt complete message"), preferredStyle: UIAlertController.Style.alert)

                        completeAlert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"),
                            style: UIAlertAction.Style.default))

                        self.present(completeAlert, animated: true)
                    }))
                alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: "Cancel action"),
                    style: UIAlertAction.Style.cancel))

                self.present(alert, animated: true)
        }
        // Backup Random Salt
            else if indexPath.row == 2 {
                PasswordHelper.saveRandomSalt(UserDefaults.standard.string(forKey: AppDataKeys.RandomSaltKey)!)

                var message = String(format: NSLocalizedString("BackupRandomSaltCompleteAlert.Message", comment: "Backup random salt complete message"), PasswordHelper.RandomSaltBackupDataFileName)

                do {
                    let url = PasswordHelper.getRandomSaltFileURL()

                    if url == nil || !FileManager().fileExists(atPath: url!.path) {
                        message = NSLocalizedString("GenericError.Message", comment: "Generic error message")
                    }
                }

                let completeAlert = UIAlertController(title: NSLocalizedString("BackupRandomSaltAlert.Title", comment: "Backup random salt"),
                    message: message,
                    preferredStyle: UIAlertController.Style.alert)

                completeAlert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"),
                    style: UIAlertAction.Style.default))

                self.present(completeAlert, animated: true)
        }
        else if indexPath.row == 3 {
            let alert = UIAlertController(title: NSLocalizedString("RestoreRandomSaltAlert.Title", comment: "Restore random salt"),
                message: NSLocalizedString("RandomSaltChangeAlert.Message", comment: "Random salt change warning"),
                preferredStyle: UIAlertController.Style.alert)

            alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: "Default action"),
                style: UIAlertAction.Style.default,
                handler: { (action) in
                    let randomSalt = PasswordHelper.loadRandomSalt()
                    var message = String(format: NSLocalizedString("RestoreRandomSaltCompleteAlert.Message", comment: "Restore random salt complete message"), PasswordHelper.RandomSaltBackupDataFileName)

                    if randomSalt != nil {
                        UserDefaults.standard.set(randomSalt, forKey: AppDataKeys.RandomSaltKey)
                    }
                    else {
                        message = String(format: NSLocalizedString("RestoreRandomSaltCompleteAlert.Error", comment: "Restore random salt error message"), PasswordHelper.RandomSaltBackupDataFileName)
                    }

                    let completeAlert = UIAlertController(title: NSLocalizedString("RestoreRandomSaltAlert.Title", comment: "Restore random salt"),
                        message: message,
                        preferredStyle: UIAlertController.Style.alert)

                    completeAlert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"),
                        style: UIAlertAction.Style.default))

                    self.present(completeAlert, animated: true)
                }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: "Cancel action"),
                style: UIAlertAction.Style.cancel))

            self.present(alert, animated: true)
        }
    }

    @objc func randomSaltValidate(textField: UITextField) {
        PasswordLengthDefaultAction.isEnabled = (textField.text != nil && textField.text?.isEmpty == false)
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 64 - 4 + 1
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(row + 4)
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let passwordLength = row + 4

        UserDefaults.standard.set(passwordLength, forKey: AppDataKeys.PasswordLengthKey)
    }

    @IBAction func autoCopyPasswordValueChanged(_ sender: Any) {
        UserDefaults.standard.set(AutoCopyPasswordUISwitch.isOn, forKey: AppDataKeys.AutoCopyPasswordKey)
    }

    @IBAction func saveLastUserSaltValueChanged(_ sender: Any) {
        UserDefaults.standard.set(SaveLastUserSaltUISwitch.isOn, forKey: AppDataKeys.SaveLastUserSaltKey)
    }

    @IBOutlet weak var PasswordLengthUIPickerView: UIPickerView!
    @IBOutlet weak var AutoCopyPasswordUISwitch: UISwitch!
    @IBOutlet weak var SaveLastUserSaltUISwitch: UISwitch!

    var PasswordLengthDefaultAction: UIAlertAction!
}
