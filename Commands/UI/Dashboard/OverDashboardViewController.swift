//
//  OverDashboardViewController.swift
//  VMware Action
//
//  Created by Paul Evans on 5/13/20.
//  Copyright © 2020 VMware. All rights reserved.
//

import UIKit

class OverDashboardViewController: UIViewController {
    
    let actionDashboardView = DashboardViewController()

    @IBOutlet weak var settingsButton: UIBarButtonItem!
    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    static let screenIdentifier = "com.vmware.action.screen.dashboard"
    static let storyboard = UIStoryboard(name: "Main", bundle: nil)

    var service: NetworkService?

    var context = ApplicationContext.shared

    lazy var enabledActions = self.context.configuration?.supportedActions ?? [Actions]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
