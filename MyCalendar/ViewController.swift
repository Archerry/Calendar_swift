//
//  ViewController.swift
//  MyCalendar
//
//  Created by Archer on 2017/9/30.
//  Copyright © 2017年 Archer. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var clickMe : UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        clickMe = UIButton.init(frame: CGRect.init(x: 0, y: 200, width: SCREENWIDTH, height: 50))
        clickMe.setTitleColor(UIColor.white, for: UIControlState.normal)
        clickMe.setTitle("大家好，给大家介绍一下，这是个日历@CalendarView,快按我！！！", for: UIControlState.normal)
        clickMe.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        clickMe.backgroundColor = UIColor.red
        clickMe.addTarget(self, action: #selector(clickBtn), for: UIControlEvents.touchUpInside)
        self.view.addSubview(clickMe)
    }
    
    @objc func clickBtn() {
        self.view.addSubview(WMHCalendarView.init(showFatherView: self.view, confirmBtnClick: { (selectedeDate) in
            print(selectedeDate)
            self.clickMe.setTitle(selectedeDate, for: UIControlState.normal)
        }, confirmStr: "确认"))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

