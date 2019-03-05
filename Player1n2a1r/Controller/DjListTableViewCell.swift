//
//  DjListTableViewCell.swift
//  Player1n2a1r
//
//  Created by Egor Tkachenko on 06/03/2019.
//  Copyright © 2019 ET. All rights reserved.
//

import UIKit

class DjListTableViewCell: UITableViewCell {

    @IBOutlet weak var djName: UILabel!
    @IBOutlet weak var djImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
