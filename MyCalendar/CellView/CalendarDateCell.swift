//
//  CalendarDateCell.swift
//  MyCalendar
//
//  Created by Archer on 2017/10/9.
//  Copyright © 2017年 Archer. All rights reserved.
//

import UIKit

class CalendarDateCell: UICollectionViewCell {
    var calenderBtn : UIButton!
    var calenderLbl : UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.createCell()
    }
    
    func createCell() {
        calenderBtn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: SCREENWIDTH / 7, height: 45))
        calenderBtn.backgroundColor = UIColor.white
        calenderBtn.isUserInteractionEnabled = false
        self.contentView.addSubview(calenderBtn)
        
        calenderLbl = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: calenderBtn.frame.size.width, height: calenderBtn.frame.size.height - 0.5))
        calenderLbl.font = UIFont.systemFont(ofSize: 13)
        calenderLbl.textAlignment = NSTextAlignment.center
//        calenderLbl.textColor = UIColor.hexadecimalColor(hexadecimal: "#8c8c8c")
        calenderBtn.addSubview(calenderLbl)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
