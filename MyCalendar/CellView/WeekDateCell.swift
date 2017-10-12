//
//  WeekDateCell.swift
//  MyCalendar
//
//  Created by Archer on 2017/10/9.
//  Copyright © 2017年 Archer. All rights reserved.
//

import UIKit

class WeekDateCell: UICollectionViewCell {
    var dateLbl : UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.createCell()
    }
    
    func createCell() {
        dateLbl = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: SCREENWIDTH / 7, height: 45))
        dateLbl.backgroundColor = UIColor.init(red: 240.0 / 255.0, green: 242.0 / 255.0, blue: 247.0 / 255.0, alpha: 1.0)
//        dateLbl.textColor = UIColor.hexadecimalColor(hexadecimal: "#8c8c8c")
        dateLbl.textAlignment = NSTextAlignment.center
        self.addSubview(dateLbl)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
