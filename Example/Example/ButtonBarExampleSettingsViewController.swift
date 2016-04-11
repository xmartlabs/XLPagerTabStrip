//
//  ButtonBarExampleSettingsViewController.swift
//  Example
//
//  Created by Luciano Sugiura on 10/04/16.
//
//

import UIKit
import XLPagerTabStrip

protocol ButtonBarExampleSettingsDelegate: class {
    func buttonBarExampleSettings(isSelectedBarBelow isSelectedBarBelow: Bool)
    func buttonBarExampleSettingsUpdateTapped()
    func buttonBarExampleSettingsIsSelectedBarBelow() -> Bool
}

class ButtonBarExampleSettingsViewController: UITableViewController {
    
    @IBOutlet weak var switchView: UISwitch!
    
    weak var delegate: ButtonBarExampleSettingsDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        switchView.on = delegate?.buttonBarExampleSettingsIsSelectedBarBelow() ?? false
    }
    
    @IBAction func switchIsSelectedBarBelowValueChanged(sender: UISwitch) {
        delegate?.buttonBarExampleSettings(isSelectedBarBelow: sender.on)
    }
    
    @IBAction func btnUpdateTap(sender: UIButton) {
        delegate?.buttonBarExampleSettingsUpdateTapped()
    }
}
