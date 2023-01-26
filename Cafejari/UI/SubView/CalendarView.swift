//
//  CalendarView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/28.
//

import SwiftUI
import UIKit
import FSCalendar


struct CalendarView: UIViewRepresentable {
    
    typealias UIViewType = FSCalendar
    
    @Binding var selectedDate: Date
    @Binding var dateCafeLogs: DateCafeLogs
    
    var calendar = FSCalendar()
    
    let onDateSelected: (Date) -> Void
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, onDateSelected: onDateSelected, dateCafeLogs: dateCafeLogs)
    }
    
    func makeUIView(context: Context) -> FSCalendar {
        
        calendar.delegate = context.coordinator
        calendar.dataSource = context.coordinator
        
        calendar.locale = Locale(identifier: "ko_KR")
        
        calendar.calendarWeekdayView.weekdayLabels[0].text = "일"
        calendar.calendarWeekdayView.weekdayLabels[1].text = "월"
        calendar.calendarWeekdayView.weekdayLabels[2].text = "화"
        calendar.calendarWeekdayView.weekdayLabels[3].text = "수"
        calendar.calendarWeekdayView.weekdayLabels[4].text = "목"
        calendar.calendarWeekdayView.weekdayLabels[5].text = "금"
        calendar.calendarWeekdayView.weekdayLabels[6].text = "토"
        
        calendar.appearance.weekdayTextColor = UIColor.lightGray
        calendar.appearance.weekdayFont = .systemFont(ofSize: 14, weight: .bold)
        calendar.weekdayHeight = 18
        
        calendar.appearance.titlePlaceholderColor = UIColor.clear
        calendar.appearance.titleDefaultColor = UIColor.black
        calendar.appearance.titleTodayColor = UIColor(Color.secondary)
        calendar.appearance.titleFont = .systemFont(ofSize: 14, weight: .regular)
        calendar.appearance.titleWeekendColor = .black
        
        calendar.placeholderType = .none
        calendar.appearance.todayColor = UIColor.white
        calendar.appearance.selectionColor = UIColor(Color.secondary)
        
        calendar.appearance.headerMinimumDissolvedAlpha = 0.1
        calendar.appearance.headerTitleFont = .systemFont(ofSize: 18, weight: .bold)
        calendar.appearance.headerTitleColor = UIColor(Color.primary)
        calendar.appearance.headerDateFormat = "yyyy년 MM월"
        
        calendar.scope = .month
        
        calendar.select(self.selectedDate)
        return calendar
    }
    
    func updateUIView(_ uiView: FSCalendar, context: Context) {
        
    }
    
    class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
        
        var parent: CalendarView
        let onDateSelected: (Date) -> Void
        let dateCafeLogs: DateCafeLogs
        
        init(parent: CalendarView, onDateSelected: @escaping (Date) -> Void, dateCafeLogs: DateCafeLogs) {
            self.parent = parent
            self.onDateSelected = onDateSelected
            self.dateCafeLogs = dateCafeLogs
        }
        
        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            parent.selectedDate = date
            onDateSelected(date)
        }

            
        // 특정 날짜에 이미지 세팅
        func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
            let imageDateFormatter = DateFormatter()
            imageDateFormatter.dateFormat = "yyyyMMdd"
            let dateStr = imageDateFormatter.string(from: date)
            return dateCafeLogs.contains(where: { dateCafeLog -> Bool in
                imageDateFormatter.string(from: dateCafeLog.date) == dateStr
            }) ? UIImage(named: "stamp_icon")?.resizeImageTo(size: CGSize(width: 16, height: 16)) : nil
        }
        

        func maximumDate(for calendar: FSCalendar) -> Date {
            Date.now.addingTimeInterval(86400 * 180)
        }

        func minimumDate(for calendar: FSCalendar) -> Date {
            Date.now.addingTimeInterval(-86400 * 180)
        }
        
    }
}
