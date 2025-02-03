import WMFComponents

@objc
public enum ArticleSource: Int {
    case undefined = 0 // temp
    case search = 1
    case history = 4
    case places = 9
}

@objc(WMFArticleCoordinator)
final public class ArticleCoordinator: NSObject, Coordinator {

    // MARK: Coordinator Protocol Properties
    var navigationController: UINavigationController

    // MARK: Properties

    let articleURL: URL
    let dataStore: MWKDataStore
    let theme: Theme
    let source: ArticleSource
    private let schemeHandler: SchemeHandler?
    private let altTextExperimentViewModel: WMFAltTextExperimentViewModel?
    private let needsAltTextExperimentSheet: Bool
    private let altTextBottomSheetViewModel: WMFAltTextExperimentModalSheetViewModel?
    private weak var altTextDelegate: AltTextDelegate?

    // MARK: Lifecycle

    init(navigationController: UINavigationController,
         dataStore: MWKDataStore,
         articleURL: URL,
         theme: Theme,
         source: ArticleSource,
         schemeHandler: SchemeHandler? = nil,
         altTextExperimentViewModel: WMFAltTextExperimentViewModel? = nil,
         needsAltTextExperimentSheet: Bool = false,
         altTextBottomSheetViewModel: WMFAltTextExperimentModalSheetViewModel? = nil,
         altTextDelegate: AltTextDelegate? = nil) {

        self.navigationController = navigationController
        self.dataStore = dataStore
        self.articleURL = articleURL
        self.theme = theme
        self.source = source
        self.schemeHandler = schemeHandler
        self.altTextExperimentViewModel = altTextExperimentViewModel
        self.needsAltTextExperimentSheet = needsAltTextExperimentSheet
        self.altTextBottomSheetViewModel = altTextBottomSheetViewModel
        self.altTextDelegate = altTextDelegate
    }

    func start() {
        let articleVC: ArticleViewController?

        if let altTextExperimentViewModel = altTextExperimentViewModel {
            articleVC = ArticleViewController(
                articleURL: articleURL,
                dataStore: dataStore,
                theme: theme,
                source: source,
                schemeHandler: schemeHandler,
                altTextExperimentViewModel: altTextExperimentViewModel,
                needsAltTextExperimentSheet: needsAltTextExperimentSheet,
                altTextBottomSheetViewModel: altTextBottomSheetViewModel,
                altTextDelegate: altTextDelegate
            )
        } else {

            articleVC = ArticleViewController(
                articleURL: articleURL,
                dataStore: dataStore,
                theme: theme,
                source: source,
                schemeHandler: schemeHandler
            )
        }

        guard let articleViewController = articleVC else {
            debugPrint("Failed to initialize ArticleViewController")
            return
        }

        navigationController.pushViewController(articleViewController, animated: true)
    }
}
