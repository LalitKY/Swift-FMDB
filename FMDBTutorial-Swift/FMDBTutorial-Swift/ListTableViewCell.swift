//
//  ListTableViewCell.swift
//  FMDBTutorial-Swift
//
//  Created by Lalit Kant on 2/7/17.
//  Copyright © 2017 Lalit Kant. All rights reserved.
//

import UIKit

class ListTableViewCell: UITableViewCell {
    @IBOutlet var titleLabel : UILabel!
    @IBOutlet var dateLabel : UILabel!
    @IBOutlet var timeLabel : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
