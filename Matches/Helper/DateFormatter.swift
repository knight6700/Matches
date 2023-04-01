import Foundation
import Dependencies

struct DateFormatterDependency {
    var convertStringToDate: (String) -> Date
}
extension DateFormatterDependency: DependencyKey {
    static var liveValue: DateFormatterDependency {
        let formatter = DateFormatter()
        return .init { date in
            let formatted =  "yyyy-MM-dd'T'HH:mm:ssZ"
            formatter.dateFormat = formatted
            formatter.locale = .current
            formatter.timeZone = .current
            return formatter.date(from: date) ?? .now
        }
    }
}

extension DateFormatterDependency: TestDependencyKey {
    static var testValue: DateFormatterDependency {
        .liveValue
    }
}

extension DependencyValues {
    var dateFormatter: DateFormatterDependency {
        get { self[DateFormatterDependency.self] }
        set { self[DateFormatterDependency.self] = newValue }
    }
}
