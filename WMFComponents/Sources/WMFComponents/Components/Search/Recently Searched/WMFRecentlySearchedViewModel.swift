import Foundation

public final class WMFRecentlySearchedViewModel: ObservableObject {

    public struct LocalizedStrings {
        let title: String
        let clearButtonTitle: String

        public init(title: String, clearButtonTitle: String) {
            self.title = title
            self.clearButtonTitle = clearButtonTitle
        }
    }

    public struct SearchTerm: Identifiable {
        let text: String
        
        public init(text: String) {
            self.text = text
        }
        
        public var id: Int {
            return text.hash
        }
    }
    @Published var recentSearchTerms: [SearchTerm] = []
    @Published public var topPadding: CGFloat = 0
    public let localizedStrings: LocalizedStrings

    public init(recentSearchTerms: [SearchTerm], localizedStrings: LocalizedStrings) {
        self.recentSearchTerms = recentSearchTerms
        self.localizedStrings = localizedStrings
    }
    
    
}
