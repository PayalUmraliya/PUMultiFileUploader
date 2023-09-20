//
//  UploadingDocCell.swift
//  Activ Health
//
//  Created by Munnabhai Baraiya on 12/09/23.
//  Copyright © 2023 Aditya Birla. All rights reserved.
//

import UIKit
import Alamofire
class UploadingDocCell: UITableViewCell {

    @IBOutlet weak var imgSelected: UIImageView!
    @IBOutlet weak var lblDocname: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var uploadProgress: UIProgressView!
    @IBOutlet weak var btnReUploading: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
