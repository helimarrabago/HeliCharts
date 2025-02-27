//
//  Helpers.swift
//  HeliCharts
//
//  Created by Helimar Rabago on 1/8/25.
//

import Foundation

// MARK: - Date Helpers
enum DateHelper {
    static var calendar: Calendar = .current
    static let formatter: DateFormatter = DateFormatter()

    static func getWeeks(from startDate: TimeInterval, for year: Int? = nil) -> [WeekRange] {
        calendar.firstWeekday = 6 // Set Friday as the first day of the week (1 = Sunday, 6 = Friday)

        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = calendar.timeZone

        var weekRanges: [WeekRange] = []
        var currentDate = Date(timeIntervalSince1970: startDate)
        let endDate = Date()

        while currentDate < endDate {
            let weekStart = calendar.date(from: calendar.dateComponents(
                [.yearForWeekOfYear, .weekOfYear],
                from: currentDate))!
            let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart)!
            let weekEndFinalSecond = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: weekEnd)!

            let weekday = calendar.component(.weekday, from: weekStart)
            if weekday == 6 {
                if let year = year {
                    let weekYear = calendar.component(.year, from: weekStart)
                    if weekYear != year {
                        currentDate = calendar.date(byAdding: .weekOfYear, value: 1, to: weekStart)!
                        continue
                    }
                }

                let from = Int(weekStart.timeIntervalSince1970)
                // swiftlint:disable:next identifier_name
                let to = Int(weekEndFinalSecond.timeIntervalSince1970)
                weekRanges.append(WeekRange(from: from, to: to))
            }

            currentDate = calendar.date(byAdding: .weekOfYear, value: 1, to: weekStart)!
        }

        return weekRanges
    }

    static func getYears(from startDate: TimeInterval) -> [Int] {
        let startDate = Date(timeIntervalSince1970: startDate)
        guard let startYear = calendar.dateComponents([.year], from: startDate).year else {
            return []
        }

        let currentYear = calendar.component(.year, from: Date())
        return Array(startYear...currentYear)
    }
}

extension Date {
    func toFormat(_ format: String) -> String {
        let formatter = DateHelper.formatter
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

extension WeekRange {
    func toLongFormat() -> String {
        let fromDate = Date(timeIntervalSince1970: TimeInterval(from))
        let toDate = Date(timeIntervalSince1970: TimeInterval(to))

        let fromString = fromDate.toFormat("MMM d")
        let toString = toDate.toFormat("d")
        let yearString = toDate.toFormat("yyyy")

        return "\(fromString)-\(toString), \(yearString)"
    }

    func isImmediatelyBefore(week: WeekRange) -> Bool {
        return week.from - to == 1
    }

    func isInYear(_ year: Int) -> Bool {
        let toDate = Date(timeIntervalSince1970: TimeInterval(to))
        let dateYear = DateHelper.calendar.component(.year, from: toDate)
        return dateYear == year
    }
}

// MARK: - Number Helpers
enum NumberHelper {
    static let formatter = NumberFormatter()
}

extension Int {
    func toDecimalFormat() -> String {
        let formatter = NumberHelper.formatter
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self))!
    }

    func toShortFormat() -> String {
        let suffixes = ["", "K", "M", "B"]
        var value = Double(self)
        var index = 0

        while value >= 1_000 && index < suffixes.count - 1 {
            value /= 1_000
            index += 1
        }

        let formattedValue = String(format: value.truncatingRemainder(dividingBy: 1) == 0 ? "%.0f" : "%.1f", value)
        return "\(formattedValue) \(suffixes[index])"
    }

    func toOrdinalFormat() -> String {
        let formatter = NumberHelper.formatter
        formatter.numberStyle = .ordinal
        return formatter.string(from: NSNumber(value: self))!
    }
}
