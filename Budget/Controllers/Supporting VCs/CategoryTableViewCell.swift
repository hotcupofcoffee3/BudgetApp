//
//  CategoryTableViewCell.swift
//  Budget
//
//  Created by Adam Moore on 5/3/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var categoryNameLabel: UILabel!
    
    @IBOutlet weak var dueDateLabel: UILabel!
    
    @IBOutlet weak var categoryBudgetedTitleLabel: UILabel!
    
    @IBOutlet weak var categoryBudgetedLabel: UILabel!
    
    @IBOutlet weak var categoryAvailableTitleLabel: UILabel!
    
    @IBOutlet weak var categoryAvailableLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
