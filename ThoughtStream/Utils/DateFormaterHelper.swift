import Foundation

class DateFormaterHelper {
    static let shortDateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .none
        return df
    }()
    
    static let relativeShortDateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .none
        df.doesRelativeDateFormatting = true
        return df
    }()
    
    static func shortDate(from date: Date) -> String {
        shortDateFormatter.string(from: date)
    }
    
    static func dayAgo(from date: Date) -> String {
        relativeShortDateFormatter.string(from: date)
    }
}
