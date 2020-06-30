//
//  DashboardViewController.swift
//  Action
//
//  Created by Mohammed Lazim on 1/20/19.
//  Updated by Paul Evans on 5/12/20.
//  Copyright © 2020 VMware, Inc. All rights reserved.

import UIKit

class DashboardViewController: UICollectionViewController {

    @IBOutlet weak var settingsButton: UIBarButtonItem!
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var backgroundView: UIImageView!
    
    static let screenIdentifier = "com.vmware.action.screen.dashboard"
    static let storyboard = UIStoryboard(name: "Main", bundle: nil)

    var service: NetworkService?

    var context = ApplicationContext.shared

    lazy var enabledActions = self.context.configuration?.supportedActions ?? [Actions]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let customView = UIView(frame: CGRect(x: 0.0, y: -5.0, width: 200.0, height: 40.0))

        let label = UILabel(frame: CGRect(x: 0.0, y: -5.0, width: 150.0, height: 40.0))
        label.text = "Actions"
        label.textColor = UIColor.black
        label.textAlignment = NSTextAlignment.right
        label.font = UIFont(name: "HelveticaNeue-Bold", size: 34)!
        customView.addSubview(label)
        self.navigationBar.leftBarButtonItem = UIBarButtonItem(customView: customView)

        print("[Dashboard] Loaded")

        guard let configuration = self.context.configuration else {
            print("[Dashboard] ❗️ No configuration available for app")
            return
        }

        guard let apiConfiguration = configuration.apiConfiguration else {
            print("[Dashboard] ❗️ No API configuration available for dashboard")
            return
        }

        guard configuration.deviceIdentifier != nil else {
            print("[Dashboard] ❗️ No device information available")
            return
        }
        
        if self.context.troubleshootingEnabled != nil && self.context.troubleshootingEnabled == true {
            let image = UIImage(named: "settings")?.withRenderingMode(.alwaysOriginal)
            navigationBar.rightBarButtonItem = settingsButton
            navigationBar.rightBarButtonItem?.image = image
            settingsButton.isEnabled = true
        } else {
            navigationBar.rightBarButtonItem = nil
        }
        
        let authProvider = ConsoleAuthorizer(apiConfiguration: apiConfiguration)

        self.service = NetworkService(host: apiConfiguration.hostname, authorizer: authProvider)

        if enabledActions.count < 5 {
            self.collectionView.isScrollEnabled = false
        }
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.enabledActions.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellReuseIdentifiers.DashboardCollection.action,
                                                      for: indexPath)

        cell.backgroundColor = .clear

        if let actionCell = cell as? ActionCell {
            actionCell.configure(with: self.enabledActions[indexPath.row].actionInfo())
        }
    
        return cell
    }

    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let selectedAction = self.enabledActions[indexPath.row]

        guard let service = self.service else {
            print("[Dashboard] ❗️ Network service unavailable")
            self.showAlert(title: "Error", message: "Network service unavailable")
            return
        }

        guard let deviceIdentifier = self.context.deviceIdentifier else {
            print("[Dashboard] ❗️ Device Identifier unavailable")
            self.showAlert(title: "Error", message: "Device Identifier unavailable")
            return
        }

        if let endpoint = selectedAction.actionEndpoint(service: service) {

            //let loadingController = self.showLoadingIndicator()
            
            confirmAction(endpoint: endpoint, udid: deviceIdentifier, confirmationMessage: selectedAction.confirmationMessage())

/*            endpoint.perform(udid: deviceIdentifier, completion: { (success, message, details)  in

                loadingController.dismiss(animated: true, completion: nil);

                print("\n\n\n")
                if success {
                    print("Action succeeded. Showing message: \(message)")
                    self.showAlert(title: "Success", message: message)
                } else {
                    print("[Dashboard] ❗️ Action failed. Showing message: \(message)")
                    print("Debug message: \(details ?? "-")")

                    self.showAlert(title: "Error", message: message)
                }
            })*/
        } else {
            print("[Dashboard] ❗️ Failed to get endpoint for \(selectedAction.actionInfo().title)")
        }

    }
    
    func performAction(endpoint: ConsoleActionsEndpoint, udid: String) {
        let loadingController = self.showLoadingIndicator()
        
        endpoint.perform(udid: udid, completion: { (success, message, details)  in

            DispatchQueue.main.async { [weak self] in
                loadingController.dismiss(animated: true) {
                    if success {
                        print("Action succeeded. Showing message: \(message)")
                        self?.showAlert(title: "Success", message: message)
                    } else {
                        print("[Dashboard] ❗️ Action failed. Showing message: \(message)")
                        print("Debug message: \(details ?? "-")")
                        self?.showAlert(title: "Error", message: message)
                    }
                }
            }
        })
    }
    
    func confirmAction(endpoint: ConsoleActionsEndpoint, udid: String, confirmationMessage: String) {
        
        let dialogMessage = UIAlertController(title: "Confirm", message: confirmationMessage, preferredStyle: .alert)
        
        let yes = UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
            self.performAction(endpoint: endpoint, udid: udid)
        })
        
        // Create Cancel button with action handlder
        let no = UIAlertAction(title: "No", style: .cancel) { (action) -> Void in
        }
        
        //Add OK and Cancel button to dialog message
        dialogMessage.addAction(yes)
        dialogMessage.addAction(no)
        
        // Present dialog message to user
        self.present(dialogMessage, animated: true, completion: nil)
    }

}

extension DashboardViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewSize = collectionView.frame.size
        var drawableSize = collectionViewSize
        if let navigationBarFrame = self.navigationController?.navigationBar.frame {
            drawableSize.height = drawableSize.height - navigationBarFrame.height - navigationBarFrame.origin.y
        }
        
        if #available(iOS 11.0, *) {
            drawableSize.height = drawableSize.height - additionalSafeAreaInsets.bottom - additionalSafeAreaInsets.top
        }

        if self.enabledActions.count == 1 {

            drawableSize.height = drawableSize.height / 1.2
        } else if self.enabledActions.count == 2  {
            drawableSize.height = drawableSize.height / (CGFloat(self.enabledActions.count) + 0.3)
        } else if self.enabledActions.count == 3 || self.enabledActions.count == 4 {
            drawableSize.width = (drawableSize.width / 2 - 5.0)
            drawableSize.height = drawableSize.height / 2.1
        } else {
            drawableSize.width = (drawableSize.width / 2 - 5.0)
            drawableSize.height = drawableSize.height / 3.1
        }
        
        drawableSize.height = drawableSize.height / 2
        
        return drawableSize
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }

}


extension DashboardViewController {
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)

        alert.addAction(okAction)

        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true, completion: nil)
        }
    }

    func showLoadingIndicator() -> UIAlertController {
        let alert = UIAlertController(title: "", message: "Please wait while request is being sent.", preferredStyle: .alert)
        
        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true, completion: nil)
        }
        return alert
    }
}
