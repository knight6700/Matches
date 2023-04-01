

import Foundation
protocol Localizable {
    static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String
}

extension Localizable {
    static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
        let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
        return String(format: format, locale: Locale.current, arguments: args)
    }
}

struct LocalizationStrings: Localizable {
    static let matchesTitle = tr("Localizable", "navigation_title_home_matches")
    static let favoriteTitle = tr("Localizable", "navigation_title_favorite_favorite")
    static let noContentError = tr("Localizable", "error_no_content_label")
    static let noFavoriteError = tr("Localizable", "error_no_favorite_label")
    
    static func numberOfMatches(_ p1: Int) -> String {
        tr("Localizable", "number_of_matches", p1)
    }
}



private final class BundleToken {
    static let bundle: Bundle = {
        #if SWIFT_PACKAGE
            return Bundle.module
        #else
            return Bundle(for: BundleToken.self)
        #endif
    }()
}
