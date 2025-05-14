import UIKit
import SwiftUI
import WMFComponents
import WMFData
import CocoaLumberjackSwift

final class TabsOverviewCoordinator: Coordinator {
    var navigationController: UINavigationController
    var theme: Theme
    let dataStore: MWKDataStore
    private let dataController: WMFArticleTabsDataController
    
    @discardableResult
    func start() -> Bool {
        if shouldShowEntryPoint() {
            presentTabs()
            return true
        } else {
            return false
        }
    }
    
    func shouldShowEntryPoint() -> Bool {
        return dataController.shouldShowArticleTabs
    }
    
    public init(navigationController: UINavigationController, theme: Theme, dataStore: MWKDataStore) {
        self.navigationController = navigationController
        self.theme = theme
        self.dataStore = dataStore
        guard let dataController = WMFArticleTabsDataController.shared else {
            fatalError("Failed to create WMFArticleTabsDataController")
        }
        self.dataController = dataController
    }
    
    private func presentTabs() {
        
        let didTapTab: (WMFArticleTabsDataController.WMFArticleTab) -> Void = { [weak self] tab in
            self?.tappedTab(tab)
        }
        
        let didTapAddTab: () -> Void = { [weak self] in
            self?.tappedAddTab()
        }
        
        let localizedStrings = WMFArticleTabsViewModel.LocalizedStrings(
            navBarTitleFormat: WMFLocalizedString("tabs-navbar-title-format", value: "{{PLURAL:%1$d|%1$d tab|%1$d tabs}}", comment: "$1 is the amount of tabs. Navigation title for tabs, displaying how many open tabs."),
            mainPageSubtitle: WMFLocalizedString("tabs-main-page-subtitle", value: "Wikipedia’s daily highlights", comment: "Main page subtitle"),
            mainPageDescription: WMFLocalizedString("tabs-main-page-description", value: "Discover featured articles, the latest news, interesting facts, and key stats on Wikipedia’s main page.", comment: "Main page description")
        )
        
        let articleTabsViewModel = WMFArticleTabsViewModel(dataController: dataController, localizedStrings: localizedStrings, didTapTab: didTapTab, didTapAddTab: didTapAddTab)
        let articleTabsView = WMFArticleTabsView(viewModel: articleTabsViewModel)
        
        let hostingController = WMFArticleTabsHostingController(rootView: articleTabsView, viewModel: articleTabsViewModel,
                                                                doneButtonText: CommonStrings.doneTitle)
        let navVC = WMFComponentNavigationController(rootViewController: hostingController, modalPresentationStyle: .overFullScreen)

        navigationController.present(navVC, animated: true, completion: nil)
    }
    
    private func tappedTab(_ tab: WMFArticleTabsDataController.WMFArticleTab) {
        // If navigation controller is already displaying tab, just dismiss without pushing on any more tabs.
        if let displayedArticleViewController = navigationController.viewControllers.last as? ArticleViewController,
           let displayedTabIdentifier = displayedArticleViewController.coordinator?.tabIdentifier {
            if displayedTabIdentifier == tab.identifier {
                navigationController.dismiss(animated: true)
                return
            }
        }
        
        // Workaround that matches Android: remove previous navigation stack, and push on entire history of articles
        
        if dataController.needsAltBehavior {
            if let rootVC = navigationController.viewControllers.first {
                navigationController.setViewControllers([rootVC], animated: false)
            }
            
            for article in tab.articles {
                guard let siteURL = article.project.siteURL,
                      let articleURL = siteURL.wmf_URL(withTitle: article.title) else {
                    return
                }
                
                let tabConfig = ArticleTabConfig.assignParticularTabAndSetToCurrent(WMFArticleTabsDataController.Identifiers(tabIdentifier: tab.identifier, tabItemIdentifier: article.identifier))

                let articleCoordinator = ArticleCoordinator(navigationController: navigationController, articleURL: articleURL, dataStore: MWKDataStore.shared(), theme: theme, needsAnimation: false, source: .undefined, tabConfig: tabConfig)
                let success = articleCoordinator.start()
                
                if success,
                   let lastVC = navigationController.viewControllers.last {
                    if article.title.count > 10 {
                        lastVC.navigationItem.backButtonTitle = article.title.prefix(10) + "..."
                    } else {
                        lastVC.navigationItem.backButtonTitle = article.title
                    }
                }
            }
        } else {
            // Old logic
            // Only push on last article
            if let article = tab.articles.last {
                guard let siteURL = article.project.siteURL,
                      let articleURL = siteURL.wmf_URL(withTitle: article.title) else {
                    return
                }
    
                let tabConfig = ArticleTabConfig.assignParticularTabAndSetToCurrent(WMFArticleTabsDataController.Identifiers(tabIdentifier: tab.identifier, tabItemIdentifier: article.identifier))
    
                let articleCoordinator = ArticleCoordinator(navigationController: navigationController, articleURL: articleURL, dataStore: MWKDataStore.shared(), theme: theme, needsAnimation: false, source: .undefined, tabConfig: tabConfig)
                articleCoordinator.start()
            }
        }
        
        navigationController.dismiss(animated: true)
    }
    
    private func tappedAddTab() {
        guard let siteURL = dataStore.languageLinkController.appLanguage?.siteURL,
              let articleURL = siteURL.wmf_URL(withTitle: "Main Page") else {
            return
        }
        
        let articleCoordinator = ArticleCoordinator(navigationController: navigationController, articleURL: articleURL, dataStore: MWKDataStore.shared(), theme: theme, needsAnimation: false, source: .undefined, tabConfig: .assignNewTabAndSetToCurrent)
        articleCoordinator.start()
        
        navigationController.dismiss(animated: true)
    }
}

extension UIViewController {
    @objc func dismissSelf() {
        self.dismiss(animated: true, completion: nil)
    }
}
