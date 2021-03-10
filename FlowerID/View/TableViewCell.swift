//
//  TableViewCell.swift
//  FlowerID
//
//  Created by Krzysztof Pacholak on 10/03/2021.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var cellLabel: UILabel!
    

    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
