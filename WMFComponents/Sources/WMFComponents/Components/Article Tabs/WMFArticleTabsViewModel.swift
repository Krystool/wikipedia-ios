import Foundation
import SwiftUI
import WMFData

public class WMFArticleTabsViewModel: NSObject, ObservableObject {
    // articleTab should NEVER be empty - take care of logic of inserting main page in datacontroller/viewcontroller
    @Published var articleTabs: [ArticleTab]
    @Published var shouldShowCloseButton: Bool
    @Published var count: Int
    
    private let dataController: WMFArticleTabsDataController
    public var onTabCountChanged: ((Int) -> Void)?
    public var updateNavigationBarTitleAction: ((Int) -> Void)?

    public let didTapTab: (WMFArticleTabsDataController.WMFArticleTab) -> Void
    public let didTapAddTab: () -> Void
    
    public let localizedStrings: LocalizedStrings
    
    public init(dataController: WMFArticleTabsDataController,
                localizedStrings: LocalizedStrings,
                didTapTab: @escaping (WMFArticleTabsDataController.WMFArticleTab) -> Void,
                didTapAddTab: @escaping () -> Void) {
        self.dataController = dataController
        self.localizedStrings = localizedStrings
        self.articleTabs = []
        self.shouldShowCloseButton = false
        self.count = 0
        self.didTapTab = didTapTab
        self.didTapAddTab = didTapAddTab
        super.init()
        Task {
            await loadTabs()
        }
    }
    
    public struct LocalizedStrings {
        public let navBarTitleFormat: String
        public let mainPageSubtitle: String
        public let mainPageDescription: String
        
        public init(navBarTitleFormat: String, mainPageSubtitle: String, mainPageDescription: String) {
            self.navBarTitleFormat = navBarTitleFormat
            self.mainPageSubtitle = mainPageSubtitle
            self.mainPageDescription = mainPageDescription
        }
    }
    
    @MainActor
    private func loadTabs() async {
        do {
            let tabs = try await dataController.fetchAllArticleTabs()
            self.articleTabs = tabs.map { tab in
                ArticleTab(
                    image: tab.articles.last?.imageURL,
                    title: tab.articles.last?.title.underscoresToSpaces ?? "",
                    subtitle: tab.articles.last?.description,
                    description: tab.articles.last?.summary,
                    dateCreated: tab.timestamp,
                    data: tab
                )
            }
            self.shouldShowCloseButton = articleTabs.count > 1
            self.count = articleTabs.count
            onTabCountChanged?(count)
            updateNavigationBarTitleAction?(count)
        } catch {
            // Handle error appropriately
            print("Error loading tabs: \(error)")
        }
    }
    
    // MARK: - Public funcs

    public func calculateColumns(for size: CGSize) -> Int {
        // If text is scaled up for accessibility, use single column
        if UIApplication.shared.preferredContentSizeCategory.isAccessibilityCategory {
            return 1
        }

        let isPortrait = size.height > size.width
        let isPad = UIDevice.current.userInterfaceIdiom == .pad

        if isPortrait {
            return isPad ? 4 : 2
        } else {
            return 4
        }
    }
    
    public func closeTab(tab: ArticleTab) {
        Task {
            do {
                try await dataController.deleteArticleTab(identifier: tab.data.identifier)
                await loadTabs()
            } catch {
                print("Error closing tab: \(error)")
            }
        }
    }
    
    public func tabsCount() async throws -> Int {
        return try await dataController.tabsCount()
    }
}

public struct ArticleTab: Identifiable {
    let image: URL?
    let title: String
    let subtitle: String?
    let description: String?
    let dateCreated: Date
    let data: WMFArticleTabsDataController.WMFArticleTab

    public init(image: URL?, title: String, subtitle: String?, description: String?, dateCreated: Date, data: WMFArticleTabsDataController.WMFArticleTab) {
        self.image = image
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.dateCreated = dateCreated
        self.data = data
    }
    
    public var id: String {
        return data.identifier.uuidString
    }
    
    var isMain: Bool {
        return data.articles.last?.isMain ?? false
    }
}
