//
//  SettingsViewController.swift
//  SharpIcons
//
//  Created by 王文东 on 2017/12/16.
//  Copyright © 2017年 maginawin. All rights reserved.
//

import Cocoa

protocol SettingsViewControllerProtocol {
    func settingsViewControllerDidAppear(_ viewController: SettingsViewController)
    func settingsViewControllerDidDisappear(_ viewController: SettingsViewController)
}

class SettingsViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    @IBOutlet weak var iOSTableView: NSTableView!
    @IBOutlet weak var androidTableView: NSTableView!
    
    var delegate: SettingsViewControllerProtocol? = nil
    
    var androidModels = ListObject.default.androidModels()
    var iOSModels = ListObject.default.iOSModels()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        title = "Settings"
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        delegate?.settingsViewControllerDidAppear(self)
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        
        delegate?.settingsViewControllerDidDisappear(self)
    }
    
    // MARK: NSTableViewDelegate, NSTableViewDataSource
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if isiOS(tableView) {
            return iOSModels.count
        } else if isAndroid(tableView) {
            return androidModels.count
        }
        return 0
    }
    
    // MARK: private
    
    func isiOS(_ tableView: NSTableView) -> Bool {
        return tableView.tag == 101
    }
    
    func isAndroid(_ tableView: NSTableView) -> Bool {
        return tableView.tag == 102
    }
}
