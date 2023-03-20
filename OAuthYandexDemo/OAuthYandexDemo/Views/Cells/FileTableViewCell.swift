//
//  FileTableViewCell.swift
//  OAuthYandexDemo
//
//  Created by Natalia Pashkova on 19.03.2023.
//

import UIKit

protocol FileTableViewCellDelegate{
    func loadImage(stringUrl: String, completion: @escaping ((UIImage?)->Void))
}

class FileTableViewCell: UITableViewCell {
    @IBOutlet weak var fileImageView: UIImageView!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    var delegate: FileTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
