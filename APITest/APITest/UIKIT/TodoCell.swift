//
//  TodoCell.swift
//  APITest
//
//  Created by 황원상 on 4/22/24.
//

import UIKit

class TodoCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    
    @IBOutlet weak var selectionSwitch: UISwitch!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    @IBAction func onEditButtonClicked(_ sender: UIButton) {
    }
    
    @IBAction func onDeleteButtonClicked(_ sender: UIButton) {
    }
}
