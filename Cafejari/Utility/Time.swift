//
//  Time.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/26.
//

import Foundation

struct Time {
    
}

extension Time {
    
    // Date는 싹다 UTC로 계산
    // String으로 변환시 KST
    // db에서는 한국 시간 자체를 보내줌
    
    func translateFromStringToDate(timeString: String) -> Date {
        if timeString.count < 19 {
            return Date.now
        } else {
            let yearString = self.parseYearFrom(timeString: timeString)
            let monthString = self.parseMonthFrom(timeString: timeString)
            let dayString = self.parseDayFrom(timeString: timeString)
            let hourString = self.parseHourFrom(timeString: timeString)
            let minuteString = self.parseMinuteFrom(timeString: timeString)
            let secondString = timeString[String.Index(utf16Offset: 17, in: timeString)...String.Index(utf16Offset: 18, in: timeString)]
            
            var dateComponents = DateComponents()
            
            dateComponents.year = Int(yearString)
            dateComponents.month = Int(monthString)
            dateComponents.day = Int(dayString)
            dateComponents.hour = Int(hourString)
            dateComponents.minute = Int(minuteString)
            dateComponents.second = Int(secondString)

            let calendar = Calendar(identifier: .gregorian)
            
            if let res = calendar.date(from: dateComponents) {
                return res
            } else {
                return Date.now
            }
        }
    }

    func isPast(timeString: String) -> Bool {
        return Date() > self.translateFromStringToDate(timeString: timeString)
    }
    
    func getPassingDayFrom(timeString: String) -> Int {
        if let day = Calendar.current.dateComponents(
            [.day], from: self.translateFromStringToDate(timeString: timeString), to: Date.now
        ).day {
            return day
        }
        return 0
    }
    
    func getPassingHourMinuteStringFrom(timeString: String) -> String {
        if let hour = Calendar.current.dateComponents(
            [.hour], from: self.translateFromStringToDate(timeString: timeString), to: Date.now
        ).hour {
            if let minute = Calendar.current.dateComponents(
                [.minute], from: self.translateFromStringToDate(timeString: timeString), to: Date.now
            ).minute {
                return hour == 0 ? "\(minute)분" : "\(hour)시간 \(minute - hour * 60)분"
            }
        }
        return ""
    }
    
    func getAMPMHourMinuteStringFrom(timeString: String) -> String {
        let hour = Int(self.parseHourFrom(timeString: timeString))
        let minute = self.parseMinuteFrom(timeString: timeString)
        
        guard let hour = hour else { return "" }
        
        return "\(hour.getAMPM()) \(hour.getHour()):\(minute)"
    }
    
    func getPassingHourMinuteStringFromTo(timeStringFrom: String, timeStringTo: String) -> String {
        if let hour = Calendar.current.dateComponents(
            [.hour],
            from: self.translateFromStringToDate(timeString: timeStringFrom),
            to: self.translateFromStringToDate(timeString: timeStringTo)
        ).hour {
            if let minute = Calendar.current.dateComponents(
                [.minute],
                from: self.translateFromStringToDate(timeString: timeStringFrom),
                to: self.translateFromStringToDate(timeString: timeStringTo)
            ).minute {
                return hour == 0 ? "\(minute)분" : "\(hour)시간 \(minute - hour * 60)분"
            }
        }
        return ""
    }
    
    func getPassingHourMinuteStringFromSeconds(seconds: Int) -> String {
        let hour = seconds / 3600
        let minute = (seconds % 3600) / 60
        return hour == 0 ? "\(minute)분" : "\(hour)시간 \(minute)분"
    }
    
    func parseYearFrom(timeString: String) -> String {
        if timeString.count < 19 {
            return ""
        } else {
            return String(timeString[String.Index(utf16Offset: 0, in: timeString)...String.Index(utf16Offset: 3, in: timeString)])
        }
    }
    
    func parseMonthFrom(timeString: String) -> String {
        if timeString.count < 19 {
            return ""
        } else {
            return String(timeString[String.Index(utf16Offset: 5, in: timeString)...String.Index(utf16Offset: 6, in: timeString)])
        }
    }
    
    func parseDayFrom(timeString: String) -> String {
        if timeString.count < 19 {
            return ""
        } else {
            return String(timeString[String.Index(utf16Offset: 8, in: timeString)...String.Index(utf16Offset: 9, in: timeString)])
        }
    }
    
    func parseHourFrom(timeString: String) -> String {
        if timeString.count < 19 {
            return ""
        } else {
            return String(timeString[String.Index(utf16Offset: 11, in: timeString)...String.Index(utf16Offset: 12, in: timeString)])
        }
    }
    
    func parseMinuteFrom(timeString: String) -> String {
        if timeString.count < 19 {
            return ""
        } else {
            return String(timeString[String.Index(utf16Offset: 14, in: timeString)...String.Index(utf16Offset: 15, in: timeString)])
        }
    }
}
