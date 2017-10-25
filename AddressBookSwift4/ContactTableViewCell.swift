//
//  ContactTableViewCell.swift
//  AddressBookSwift4
//
//  Created by Guillaume Lazaro on 25/10/2017.
//  Copyright © 2017 Guillaume Lazaro. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

    
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
