import SwiftUI
import Foundation
import WMFData

public class WMFArticleTabsHostingController<HostedView: View>: WMFComponentHostingController<HostedView>, WMFNavigationBarConfiguring {
    
    lazy var addTabButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: WMFSFSymbolIcon.for(symbol: .add), style: .plain, target: self, action: #selector(tappedAdd))
        return button
    }()
    
    lazy var overflowButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: WMFSFSymbolIcon.for(symbol: .ellipsisCircle), primaryAction: nil, menu: overflowMenu)
        return button
    }()
    
    private let viewModel: WMFArticleTabsViewModel
    private let doneButtonText: String
    
    public init(rootView: HostedView, viewModel: WMFArticleTabsViewModel, doneButtonText: String) {
        self.viewModel = viewModel
        self.doneButtonText = doneButtonText
        super.init(rootView: rootView)
        
        // Defining format outside the block fixes a retain cycle on WMFArticleTabsViewModel
        let format = viewModel.localizedStrings.navBarTitleFormat
        viewModel.updateNavigationBarTitleAction = { [weak self] numTabs in
            let newNavigationBarTitle = String.localizedStringWithFormat(format, numTabs)
            self?.configureNavigationBar(newNavigationBarTitle)
        }
    }
    
    @MainActor public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureNavigationBar()
        
        let dataController = WMFArticleTabsDataController.shared
        if dataController.shouldShowMoreDynamicTabs {
            navigationItem.rightBarButtonItems = [addTabButton, overflowButton]
        } else {
            navigationItem.rightBarButtonItem = addTabButton
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.loggingDelegate?.logArticleTabsOverviewImpression()

        NotificationCenter.default.addObserver(
                self,
                selector: #selector(userDidTakeScreenshot),
                name: UIApplication.userDidTakeScreenshotNotification,
                object: nil
            )
    }

    private func configureNavigationBar(_ title: String? = nil) {
        let titleConfig = WMFNavigationBarTitleConfig(title: title ?? "", customView: nil, alignment: .centerCompact)
        
        let closeConfig = WMFNavigationBarCloseButtonConfig(text: doneButtonText, target: self, action: #selector(tappedDone), alignment: .leading)

        configureNavigationBar(titleConfig: titleConfig, closeButtonConfig: closeConfig, profileButtonConfig: nil, tabsButtonConfig: nil, searchBarConfig: nil, hideNavigationBarOnScroll: false)
    }
    
    @objc func tappedDone() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func tappedAdd() {
        viewModel.didTapAddTab()
    }

    @objc private func userDidTakeScreenshot() {
        viewModel.loggingDelegate?.logTabsOverviewScreenshot()
    }


    @objc private func tappedOverflow() {
        viewModel.didTapAddTab()
    }
    
    var overflowMenu: UIMenu {
        let tabsPreferences = UIAction(title: viewModel.localizedStrings.tabsPreferencesTitle, image: WMFSFSymbolIcon.for(symbol: .gear), handler: { [weak self] _ in
            self?.openTabsPreferences()
        })
        
        let closeAllTabs = UIAction(title: "Close all tabs", image: WMFSFSymbolIcon.for(symbol: .gear), handler: { [weak self] _ in
            self?.presentAlertExample()
        })
        
        let children: [UIMenuElement] = [tabsPreferences, closeAllTabs]
        let mainMenu = UIMenu(title: String(), children: children)

        return mainMenu
    }
    
    private func openTabsPreferences() {
        viewModel.didTabOpenTabs()

    }
    
    private func presentAlertExample() {
        let alert = UIAlertController(title: "Alert", message: "This is an alert example.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close all tabs", style: .default))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.userDidTakeScreenshotNotification, object: nil)

    }
}
