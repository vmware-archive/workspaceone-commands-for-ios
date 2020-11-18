//
//  ConfigurationViewController.swift
//  Commands
//
//  Created by Mohammed Lazim on 24/10/20.
//  Copyright © 2020 VMware. All rights reserved.
//

import UIKit

extension UITextField {
    func showValueInvalid() {
        self.backgroundColor = UIColor(named: "error-red") ?? .systemRed
    }

    func showValueValid() {
        if #available(iOS 13.0, *) {
            self.backgroundColor = .systemBackground
        } else {
            self.backgroundColor = .white
        }
    }
}

class ConfigurationViewController: UIViewController, DashboardPresenter {

    static let screenIdentifier = "com.vmware.action.screen.configuration"
    static let storyboard = UIStoryboard(name: "Main", bundle: nil)

    @IBOutlet weak var hostnameTextField: UITextField!
    @IBOutlet weak var apiKeyTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var deviceIdentifierTextField: UITextField!

    var context: ApplicationContext { return .shared }

    lazy var contextSetupProvider: UserDefaultsContextSetupProvider = StoredConfigurationContextSetupProvider(context: self.context)

    var hostname: String {
        self.hostnameTextField.text ?? ""
    }

    var apiKey: String {
        self.apiKeyTextField.text ?? ""
    }

    var username: String {
        self.usernameTextField.text ?? ""
    }

    var password: String {
        self.passwordTextField.text ?? ""
    }

    var deviceID: String {
        self.deviceIdentifierTextField.text ?? ""
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("[ConfigurationViewController] Loaded")
    }
    
    @IBAction func saveClicked() {
        guard self.validateUserEnteredValues() else {
            print("[ConfigurationViewController] Invalid values")
            return
        }

        // Save the values
        let apiConfig = APIConfiguration(
            hostname: self.hostname,
            tenant: self.apiKey,
            username: self.username,
            password: self.password
        )

        let appConfig = AppConfig.dictionaryRepresentation(
            apiConfig: apiConfig,
            deviceID: self.deviceID,
            supportedActions: [.deviceSync]
        )

        UserDefaults.standard.setValue(appConfig, forKey: StoredConfigurationContextSetupProvider.configurationKey)

        // Setup context with the saved value
        guard case .success = self.contextSetupProvider.setup() else {
            print("[ConfigurationViewController] Failed to setup context with user entered configuration.")
            return
        }

        self.presentDashboard(animated: true)
    }

    private func validateUserEnteredValues() -> Bool {

        func validateEmptyTextField(_ textfield: UITextField) -> Bool {
            guard let value = textfield.text else {
                return false
            }

            guard value.isEmpty == false else {
                textfield.showValueInvalid()
                return false
            }

            textfield.showValueValid()
            return true
        }

        // Validate Hostname
        let validValues =
            validateEmptyTextField(self.hostnameTextField)
            && validateEmptyTextField(self.apiKeyTextField)
            && validateEmptyTextField(self.usernameTextField)
            && validateEmptyTextField(self.passwordTextField)
            && validateEmptyTextField(self.deviceIdentifierTextField)


        return validValues
    }

}
