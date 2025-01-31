import UIKit

@objc
public enum ArticleSource: Int {
    case undefined = 0
    case search = 1
    case history = 4
    case places = 9
}

@objc(WMFArticleCoordinator)
final public class ArticleCoordinator: NSObject, Coordinator {

    // MARK: Coordinator Protocol Properties

    var navigationController: UINavigationController

    // MARK: Properties 

    var theme: Theme
    let dataStore: MWKDataStore
    let articleURL: URL
    let schemeHandler: SchemeHandler?


    init(navigationController: UINavigationController, theme: Theme, dataStore: MWKDataStore, articleURL: URL, schemeHandler: SchemeHandler? = nil) {
        self.navigationController = navigationController
        self.theme = theme
        self.dataStore = dataStore
        self.articleURL = articleURL
        self.schemeHandler = schemeHandler
    }

    func start() {

    }
}
