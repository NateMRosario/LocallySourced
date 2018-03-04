//
//  TestFavoriteTableViewCell.swift
//  LocallySourced
//
//  Created by C4Q on 3/3/18.
//  Copyright © 2018 TeamLocallySourced. All rights reserved.
//

import UIKit
import FoldingCell
class TestFavoriteTableViewCell: FoldingCell {

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var boroughTitle: UILabel!
    @IBOutlet weak var marketAdInfo: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var marketTitle: UILabel!
    @IBOutlet weak var noteTextView: UITextView!
    
    override func awakeFromNib() {
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true
        super.awakeFromNib()
    }
    
    override func animationDuration(_ itemIndex: NSInteger, type _: FoldingCell.AnimationType) -> TimeInterval {
        let durations = [0.26, 0.2, 0.2]
        return durations[itemIndex]
    }
    func setupCell(from farmersMarket: FarmersMarket){
        self.addressLabel.text = "\(farmersMarket.facilitystreetname ?? ""), \(farmersMarket.facilityzipcode ?? "")"
        marketTitle.text = farmersMarket.facilityname
        marketTitle.font = UIFont.boldSystemFont(ofSize: 30)
        boroughTitle.text = farmersMarket.facilitycity?.rawValue
        marketAdInfo.text = "\(farmersMarket.facilityaddinfo?.components(separatedBy: ".").first ?? "There is no more informaion abou the market") ."
        guard let notes = farmersMarket.notes else {
            noteTextView.text = "You can add you notes here"
            return
        }
        noteTextView.text = notes
    }
    
    @IBAction func saveButtonAction(_ sender: UIButton) {
       noteTextView.resignFirstResponder()
    }
    
    

}


