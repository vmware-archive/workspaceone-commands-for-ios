//
//  DashboardPresenter.swift
//  Commands
//
//  Created by Mohammed Lazim on 25/10/20.
//  Copyright © 2020 VMware. All rights reserved.
//

import UIKit

protocol DashboardPresenter {
    func presentDashboard(animated: Bool)
}

extension DashboardPresenter where Self: UIViewController {
    func presentDashboard(animated: Bool) {
        let screenIdentifier = DashboardViewController.screenIdentifier

        DispatchQueue.main.async { [weak self] in
            /// No need to animate.
            /// Since this VC is there only for a micro-seconds, user should
            /// believe that the first screen is dashboard itself.
            let screen = DashboardViewController.storyboard.instantiateViewController(withIdentifier: screenIdentifier)
            let presentable = UINavigationController(rootViewController: screen)
            presentable.modalPresentationStyle = .fullScreen
            self?.present(presentable, animated: animated, completion: nil)
        }
    }
}
