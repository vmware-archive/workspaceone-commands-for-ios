//
//  TroubleshootViewController.swift
//  Action
//
//  Created by Mohammed Lazim on 5/18/19.
//  Copyright © 2019-2020 VMware, Inc.

import UIKit

class TroubleshootViewController: UIViewController {

    @IBOutlet weak var rawConfigTextView: UITextView!
    @IBOutlet weak var deviceIDLabel: UILabel!
    @IBOutlet weak var supportedActionsLabel: UILabel!
    @IBOutlet weak var apiHostLabel: UILabel!
    @IBOutlet weak var apiTenantLabel: UILabel!
    @IBOutlet weak var apiCredentialsLabel: UILabel!

    var context: ApplicationContext = .shared
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let userDefaults = UserDefaults.standard
        if let config = userDefaults.dictionary(forKey: "com.apple.configuration.managed") {
            self.rawConfigTextView.text = String(describing: config)
        }

        if let deviceIdentifier = self.context.deviceIdentifier {
            self.deviceIDLabel.text = deviceIdentifier
        }

        let supportedActions = self.context.supportedActions
        if supportedActions.count > 0 {
            let actionTitles = supportedActions.map { $0.actionInfo().title }
            let titlesString = actionTitles.joined(separator: ", ")
            self.supportedActionsLabel.text = titlesString
        }

        if let apiConfiguration = self.context.configuration?.apiConfiguration {
            self.apiHostLabel.text = apiConfiguration.hostname
            self.apiTenantLabel.text = apiConfiguration.tenant
            self.apiCredentialsLabel.text = "\(apiConfiguration.username) / \(apiConfiguration.password)"
        }
    }

    @IBAction func doneButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
