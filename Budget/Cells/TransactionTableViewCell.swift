//
//  TransactionTableViewCell.swift
//  Budget
//
//  Created by Adam Moore on 5/10/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class TransactionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var transactionDateLabel: UILabel!
    
    @IBOutlet weak var transactionCategoryLabel: UILabel!
    
    @IBOutlet weak var transactionNameLabel: UILabel!
    
    @IBOutlet weak var transactionAmountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
