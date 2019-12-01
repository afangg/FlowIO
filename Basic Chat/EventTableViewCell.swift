//
//  EventTableViewCell.swift
//  FlowIO
//
//  Created by Alisha Fong on 10/13/19.
//  Copyright © 2019 Vanguard Logic LLC. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {

    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var portLabel: UILabel!
    @IBOutlet weak var durationlabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
