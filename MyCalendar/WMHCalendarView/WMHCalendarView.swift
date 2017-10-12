//
//  WMHCalendarView.swift
//  MyCalendar
//
//  Created by Archer on 2017/10/12.
//  Copyright © 2017年 Archer. All rights reserved.
//

import UIKit

let SCREENWIDTH = UIScreen.main.bounds.size.width;
let SCREENHEIGHT = UIScreen.main.bounds.size.height;
let SCREENSCROLL = SCREENWIDTH / 375

class WMHCalendarView: UIView,UICollectionViewDataSource,UICollectionViewDelegate {
    var canShowView : UIView?//该视图可以显示的视图图层
    var sureTitleStr : String?//按钮显示的文字内容
    var lastMonthButton : UIButton!//上个月的按钮
    var calenderLabel : UILabel!//显示当天的时间
    var nextMonthButton : UIButton!//下个月的按钮
    var dateCollection : UICollectionView!//显示日历的所有时间
    var calendarDate : Date?//
    var nowDate : Date?
    var dateArray = NSArray()
    var lastIndex : IndexPath?
    var dateStr : String?
    
    let dateCellIdentifier = "dateIdentifier"//周一至周日的cell
    let calendarCellIdentifier = "calendarIdentifier"//日期的cell
    
    
    //按钮闭包，传入按钮标题
    typealias clickSure = (_ btnTitleStr : String)->Void
    var confirmDate : clickSure?//点击确定选中的时间
    
    init(showFatherView : UIView,confirmBtnClick : @escaping clickSure,confirmStr : String) {
        super.init(frame: CGRect.init(x: 0, y: 0, width: SCREENWIDTH, height: SCREENHEIGHT))
        self.canShowView = showFatherView
        self.confirmDate = confirmBtnClick
        self.calendarDate = Date.init()
        self.nowDate = Date.init()
        self.sureTitleStr = confirmStr
        self.dateArray = ["日","一","二","三","四","五","六"]
        self.createCanlendar()
    }
    
    //MARK:------------------createUI------------------
    func createCanlendar() {
        //遮罩
        let backBtn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: SCREENWIDTH, height: SCREENHEIGHT))
        backBtn.backgroundColor = UIColor.init(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 0.0 / 255.0, alpha: 0.5)
        backBtn.addTarget(self, action: #selector(WMHCalendarView.clickBackBtn), for: UIControlEvents.touchUpInside)
        self.addSubview(backBtn)
        
        let backView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: backBtn.frame.size.width, height: 80))
        backView.backgroundColor = UIColor.white
        backBtn.addSubview(backView)
        
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: backBtn.frame.size.width, height: 80))
        headerView.backgroundColor = UIColor.white
        backView.addSubview(headerView)
        
        let titleLbl = UILabel.init(frame: CGRect.init(x: 15, y: 10, width: 20, height: 20))
        titleLbl.text = "选择日期"
        titleLbl.font = UIFont.systemFont(ofSize: 15)
        titleLbl.textColor = UIColor.black
        titleLbl.sizeToFit()
        titleLbl.frame = CGRect.init(x: 15, y: 10, width: titleLbl.frame.size.width, height: titleLbl.frame.size.height)
        headerView.addSubview(titleLbl)
        
        let closeBtn = UIButton.init(frame: CGRect.init(x: headerView.frame.size.width - 40, y: 10, width: 30, height: 30))
        closeBtn.setImage(UIImage.init(named: "icon_delete_tcqblb"), for: UIControlState.normal)
        closeBtn.addTarget(self, action: #selector(WMHCalendarView.clickBackBtn), for: UIControlEvents.touchUpInside)
        headerView.addSubview(closeBtn)
        
        calenderLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 20, height: 20))
        calenderLabel.textAlignment = NSTextAlignment.center
        calenderLabel.font = UIFont.systemFont(ofSize: 15)
        calenderLabel.textColor = UIColor.black
        calenderLabel.text = String(self.year(date: calendarDate!)) + "年" + String(self.month(date: calendarDate!)) + "月"
        calenderLabel.sizeToFit()
        calenderLabel.frame = CGRect.init(x: (backBtn.frame.size.width - 100) / 2, y: titleLbl.frame.maxY + 10, width: 100, height: calenderLabel.frame.size.height)
        headerView.addSubview(calenderLabel)
        
        lastMonthButton = UIButton.init(frame: CGRect.init(x: calenderLabel.frame.minX - 20, y: calenderLabel.frame.origin.y, width: 15, height: 15))
        lastMonthButton.setImage(UIImage.init(named: "icon_zjt_xzrq"), for: UIControlState.normal)
        lastMonthButton.addTarget(self, action: #selector(WMHCalendarView.pressLastMonth(sender:)), for: UIControlEvents.touchUpInside)
        headerView.addSubview(lastMonthButton)
        
        nextMonthButton = UIButton.init(frame: CGRect.init(x: calenderLabel.frame.maxX + 5, y: calenderLabel.frame.origin.y, width: 15, height: 15))
        nextMonthButton.setImage(UIImage.init(named: "icon_jr_jkzx"), for: UIControlState.normal)
        nextMonthButton.addTarget(self, action: #selector(WMHCalendarView.pressNextMonth(sender:)), for: UIControlEvents.touchUpInside)
        headerView.addSubview(nextMonthButton)
        
        headerView.frame = CGRect.init(x: 0, y: 0, width: backBtn.frame.size.width, height: calenderLabel.frame.maxY + 10)
        
        let itemWidth = SCREENWIDTH / 7
        let itemHeight = 45
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize.init(width: itemWidth, height: CGFloat(itemHeight))
        layout.sectionInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        dateCollection = UICollectionView.init(frame: CGRect.init(x: 0, y: headerView.frame.maxY, width: SCREENWIDTH, height: 315), collectionViewLayout: layout)
        dateCollection.backgroundColor = UIColor.white
        dateCollection.dataSource = self
        dateCollection.delegate = self
        dateCollection.register(CalendarDateCell.self, forCellWithReuseIdentifier: calendarCellIdentifier)
        dateCollection.register(WeekDateCell.self, forCellWithReuseIdentifier: dateCellIdentifier)
        backView.addSubview(dateCollection)
        
        let confirmBtn = UIButton.init(frame: CGRect.init(x: 0, y:SCREENHEIGHT - 45, width: backBtn.frame.size.width, height: 45))
        confirmBtn.backgroundColor = UIColor.init(red: 254.0 / 255.0, green: 67.0 / 255.0, blue: 101.0 / 255.0, alpha: 1.0)
        confirmBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        confirmBtn.setTitle(sureTitleStr, for: UIControlState.normal)
        confirmBtn.setTitleColor(UIColor.white, for: UIControlState.normal)
        confirmBtn.addTarget(self, action: #selector(pressReservation), for: UIControlEvents.touchUpInside)
        backBtn.addSubview(confirmBtn)
        
        backView.frame = CGRect.init(x: 0, y: SCREENHEIGHT - dateCollection.frame.maxY - 45, width: backBtn.frame.size.width, height: dateCollection.frame.maxY)
    }
    
    //MARK:------------------Action------------------
    //销毁本视图
    @objc func clickBackBtn() {
        self.removeFromSuperview()
    }
    
    @objc func pressLastMonth(sender : UIButton) {
        lastIndex = nil
        UIView.transition(with: dateCollection, duration: 0.5, options: UIViewAnimationOptions.transitionCurlUp, animations: {
            self.calendarDate = self.lastMonth(date: self.calendarDate!)
            self.calenderLabel.text = String(self.year(date: self.calendarDate!)) + "年" + String(self.month(date: self.calendarDate!)) + "月"
        }) { (nil) in
            self.dateCollection.reloadData()
        }
    }
    
    @objc func pressNextMonth(sender : UIButton) {
        lastIndex = nil
        UIView.transition(with: dateCollection, duration: 0.5, options: UIViewAnimationOptions.transitionCurlUp, animations: {
            self.calendarDate = self.nextMonth(date: self.calendarDate!)
            self.calenderLabel.text = String(self.year(date: self.calendarDate!)) + "年" + String(self.month(date: self.calendarDate!)) + "月"
        }) { (nil) in
            self.dateCollection.reloadData()
        }
    }
    
    @objc func pressReservation() {
        if confirmDate != nil {
            if dateStr != nil {
                confirmDate!(dateStr!)
                self.removeFromSuperview()
            }else{
                self.removeFromSuperview()
            }
        }
    }
    
    //MARK:------------------collectionDelegate------------------
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return dateArray.count
        }else{
            return 42
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: dateCellIdentifier, for: indexPath) as! WeekDateCell
            cell.dateLbl.text = dateArray[indexPath.row] as? String
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: calendarCellIdentifier, for: indexPath) as! CalendarDateCell
            let daysInThisMonth = self.totalDaysInThisMonth(date: calendarDate!)
            let firstWeekDay = self.firstWeekDayInThisMonth(date: calendarDate!)
            var day = 0
            let i = indexPath.row
            
            cell.calenderBtn.backgroundColor = self.returnBackColor(index: i)
            
            let nowMonth = self.month(date: calendarDate!)
            let nowYear = self.year(date: calendarDate!)
            
            var lastMonth = 0
            var lastYear = 0
            
            if nowMonth == 1 {
                lastMonth = 12
                lastYear = nowYear - 1
            }else{
                lastMonth = nowMonth - 1
                lastYear = nowYear
            }
            
            let lastTotalDays = self.getDaysInMonth(year: lastYear, month: lastMonth)
            
            if i < firstWeekDay {
                cell.calenderLbl.text = String(lastTotalDays - firstWeekDay + 1 + indexPath.row)
                cell.calenderLbl.textColor = UIColor.lightGray
                cell.calenderBtn.backgroundColor = UIColor.white
            }else if i > firstWeekDay + daysInThisMonth - 1 {
                cell.calenderLbl.text = String(i - firstWeekDay - daysInThisMonth + 1)
                cell.calenderLbl.textColor = UIColor.lightGray
                cell.calenderBtn.backgroundColor = UIColor.white
            }else{
                day = i - firstWeekDay + 1
                if firstWeekDay == 0 {
                    if i + 1 == self.day(date: nowDate!) && (self.month(date: nowDate!) == self.month(date: calendarDate!)) && (self.year(date: nowDate!) == self.year(date: calendarDate!)){
                        cell.calenderBtn.backgroundColor = UIColor.red
                    }
                }else{
                    if i == self.day(date: nowDate!) && (self.month(date: nowDate!) == self.month(date: calendarDate!)) && (self.year(date: nowDate!) == self.year(date: calendarDate!)){
                        cell.calenderBtn.backgroundColor = UIColor.red
                    }
                }
                cell.calenderLbl.text = String(day)
                cell.calenderLbl.textColor = UIColor.white
            }
            return cell
        }
    }
    
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize{
        if indexPath.section == 0 {
            return CGSize.init(width: SCREENWIDTH / 7, height: 35)
        }else{
            return CGSize.init(width: SCREENWIDTH / 7, height: 45)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if lastIndex != nil {
            let cell = collectionView.cellForItem(at: indexPath) as! CalendarDateCell
            
            let oldCell = collectionView.cellForItem(at: lastIndex!) as! CalendarDateCell
            let firstWeekDay = self.firstWeekDayInThisMonth(date: calendarDate!)
            let daysInThisMonth = self.totalDaysInThisMonth(date: calendarDate!)
            
            if firstWeekDay == 0 {
                if (lastIndex?.item)! + 1 == self.day(date: nowDate!) && (self.month(date: nowDate!) == self.month(date: calendarDate!)) && (self.year(date: nowDate!) == self.year(date: calendarDate!)){
                    oldCell.calenderBtn.backgroundColor = UIColor.red
                    oldCell.calenderLbl.textColor = UIColor.white
                }else{
                    if (lastIndex?.item)! > firstWeekDay + daysInThisMonth - 1 || (lastIndex?.item)! < firstWeekDay{
                        oldCell.calenderBtn.backgroundColor = UIColor.white
                        oldCell.calenderLbl.textColor = UIColor.lightGray
                    }else{
                        oldCell.calenderBtn.backgroundColor = self.returnBackColor(index: (lastIndex?.item)!)
                        oldCell.calenderLbl.textColor = UIColor.white
                    }
                }
            }else{
                if lastIndex?.item == self.day(date: nowDate!) && (self.month(date: nowDate!) == self.month(date: calendarDate!)) && (self.year(date: nowDate!) == self.year(date: calendarDate!)){
                    oldCell.calenderBtn.backgroundColor = UIColor.red
                    oldCell.calenderLbl.textColor = UIColor.white
                }else{
                    if (lastIndex?.item)! > firstWeekDay + daysInThisMonth - 1 || (lastIndex?.item)! < firstWeekDay{
                        oldCell.calenderBtn.backgroundColor = UIColor.white
                        oldCell.calenderLbl.textColor = UIColor.lightGray
                    }else{
                        oldCell.calenderBtn.backgroundColor = self.returnBackColor(index: (lastIndex?.item)!)
                        oldCell.calenderLbl.textColor = UIColor.white
                    }
                }
            }
            
            lastIndex = indexPath
            cell.calenderBtn.backgroundColor = UIColor.black
            cell.calenderLbl.textColor = UIColor.white
            
            var dayStr = cell.calenderLbl.text!
            var monthStr = ""
            let month = self.month(date: calendarDate!)
            
            if Int(dayStr)! < 10 {
                dayStr = "0" + dayStr
            }
            
            if month < 10 {
                monthStr = "0" + String(month)
            }else{
                monthStr = String(self.month(date: calendarDate!))
            }
            
            dateStr = String(self.year(date: calendarDate!)) + "-" + monthStr + "-" + dayStr
        }else{
            let cell = collectionView.cellForItem(at: indexPath) as! CalendarDateCell
            
            lastIndex = indexPath
            cell.calenderBtn.backgroundColor = UIColor.black
            cell.calenderLbl.textColor = UIColor.white
            var dayStr = cell.calenderLbl.text!
            var monthStr = ""
            let month = self.month(date: calendarDate!)
            
            if Int(dayStr)! < 10 {
                dayStr = "0" + dayStr
            }
            
            if month < 10 {
                monthStr = "0" + String(month)
            }else{
                monthStr = String(self.month(date: calendarDate!))
            }
            
            dateStr = String(self.year(date: calendarDate!)) + "-" + monthStr + "-" + dayStr
        }
    }
    
    func returnBackColor(index : NSInteger) -> UIColor {
        switch index % 7 {
        case 0:do {
            return UIColor.init(red: 3.0 / 255.0, green: 54.0 / 255.0, blue: 73.0 / 255.0, alpha: 1.0)
            }
        case 1:do {
            return UIColor.init(red: 3.0 / 255.0, green: 74.0 / 255.0, blue: 93.0 / 255.0, alpha: 1.0)
            }
        case 2:do {
            return UIColor.init(red: 3.0 / 255.0, green: 94.0 / 255.0, blue: 113.0 / 255.0, alpha: 1.0)
            }
        case 3:do {
            return UIColor.init(red: 3.0 / 255.0, green: 114.0 / 255.0, blue: 133.0 / 255.0, alpha: 1.0)
            }
        case 4:do {
            return UIColor.init(red: 3.0 / 255.0, green: 134.0 / 255.0, blue: 153.0 / 255.0, alpha: 1.0)
            }
        case 5:do {
            return UIColor.init(red: 3.0 / 255.0, green: 154.0 / 255.0, blue: 173.0 / 255.0, alpha: 1.0)
            }
        case 6:do {
            return UIColor.init(red: 3.0 / 255.0, green: 174.0 / 255.0, blue: 193.0 / 255.0, alpha: 1.0)
            }
        case 7:do {
            return UIColor.init(red: 3.0 / 255.0, green: 194.0 / 255.0, blue: 213.0 / 255.0, alpha: 1.0)
            }
        default:
            return UIColor.white
        }
    }
    
    //MARK:------------------dateCalculate------------------
    //计算当前月的几号
    func day(date : Date) -> NSInteger {
        
        //        let nowDate = Date.init()
        let calendar = Calendar.current
        let componentsSet = Set<Calendar.Component>([.year, .month, .day,])
        var componentss = calendar.dateComponents(componentsSet, from: date)
        
        return componentss.day!
    }
    
    //计算当前第几月
    func month(date : Date) -> NSInteger {
        //        let nowDate = Date.init()
        let calendar = Calendar.current
        let componentsSet = Set<Calendar.Component>([.year, .month, .day,])
        var componentss = calendar.dateComponents(componentsSet, from: date)
        
        return componentss.month!
    }
    
    //计算当前年
    func year(date : Date) -> NSInteger {
        //        let nowDate = Date.init()
        let calendar = Calendar.current
        let componentsSet = Set<Calendar.Component>([.year, .month, .day,])
        var componentss = calendar.dateComponents(componentsSet, from: date)
        
        return componentss.year!
    }
    
    //计算每个月1号对应周几
    func firstWeekDayInThisMonth(date : Date) -> NSInteger {
        //        let nowDate = Date.init()
        var calendar = Calendar.current
        let componentsSet = Set<Calendar.Component>([.year, .month, .day,])
        var componentss = calendar.dateComponents(componentsSet, from: date)
        
        calendar.firstWeekday = 1
        componentss.day = 1
        let first = calendar.date(from: componentss)
        let firstWeekDay = calendar.ordinality(of: .weekday, in: .weekOfMonth, for: first!)
        
        return firstWeekDay! - 1
    }
    
    //计算当前月份天数
    func totalDaysInThisMonth(date : Date) -> NSInteger {
        let totalDays : Range = Calendar.current.range(of: .day, in: .month, for: date)!
        return totalDays.count
    }
    
    //计算指定月天数
    func getDaysInMonth( year: Int, month: Int) -> Int{
        let dateFor = DateFormatter.init()
        dateFor.dateFormat = "yyyy-MM"
        
        var monthStr = ""
        if month < 10 {
            monthStr = "0" + String(month)
        }else{
            monthStr = String(month)
        }
        
        let dateStr = String(year) + "-" + monthStr
        let date = dateFor.date(from: dateStr)
        let calenDar = Calendar.init(identifier: Calendar.Identifier.gregorian)
        let totaldays : Range = calenDar.range(of: .day, in: .month, for: date!)!
        
        return totaldays.count
    }
    
    //上一个月
    func lastMonth(date : Date) -> Date {
        var dateComponents = DateComponents.init()
        dateComponents.month = -1
        let newDate = Calendar.current.date(byAdding: dateComponents, to: date)
        return newDate!
    }
    
    //下一个月
    func nextMonth(date : Date) -> Date {
        var dateComponents = DateComponents.init()
        dateComponents.month = +1
        let newDate = Calendar.current.date(byAdding: dateComponents, to: date)
        return newDate!
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


