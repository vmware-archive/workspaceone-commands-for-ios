//
//  ActionCell.swift
//  Action
//
//  Created by Mohammed Lazim on 7/13/19.
//  Copyright © 2020 VMware, Inc. All rights reserved.

import UIKit

struct CellReuseIdentifiers {
    struct DashboardCollection {
        static let action: String = "dashboard.collectioncell.action"
    }
}

struct ActionCellInfo {
    static let wipe = ActionCellInfo(title: "Wipe Device", icon: "devicewipe")
    static let clearPasscode = ActionCellInfo(title: "Clear Passcode", icon: "clearpasscode")
    static let shutdown = ActionCellInfo(title: "Shutdown")
    static let enterpriseWipe = ActionCellInfo(title: "Enterprise Wipe", icon: "enterprisewipe")
    static let reboot = ActionCellInfo(title: "Reboot")
    static let toggleBluetooth = ActionCellInfo(title: "Toggle Bluetooth", icon: "bluetooth")
    static let deviceSync = ActionCellInfo(title: "Sync Device", icon: "syncdevice")

    let title: String
    let icon: String

    init(title: String, icon: String = "default") {
        self.title = title
        self.icon = icon
    }
}

class ActionCell: UICollectionViewCell {
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    func configure(with action: ActionCellInfo) {
        iconView.image = UIImage(named: action.icon)
        titleLabel.text = action.title
    }
}


