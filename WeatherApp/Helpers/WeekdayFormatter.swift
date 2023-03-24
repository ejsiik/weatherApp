import Foundation

class WeekdayFormatter : DateFormatter {
    override init() {
        super.init()
        self.dateFormat = "EEEE"
        self.locale = Locale(identifier: "en_US")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
