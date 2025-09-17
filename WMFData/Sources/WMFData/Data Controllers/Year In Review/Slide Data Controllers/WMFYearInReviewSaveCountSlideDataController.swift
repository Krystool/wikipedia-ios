import CoreData

final class YearInReviewSaveCountSlideDataController: YearInReviewSlideDataControllerProtocol {

    let id = WMFYearInReviewPersonalizedSlideID.saveCount.rawValue
    let year: Int
    var isEvaluated: Bool = false
    static var containsPersonalizedNetworkData = true
    
    private var savedData: SavedArticleSlideData?
    
    private weak var savedSlideDataDelegate: SavedArticleSlideDataDelegate?
    private let yirConfig: YearInReviewFeatureConfig
    
    init(year: Int, yirConfig: YearInReviewFeatureConfig, dependencies: YearInReviewSlideDataControllerDependencies) {
        self.year = year
        self.yirConfig = yirConfig
        self.savedSlideDataDelegate = dependencies.savedSlideDataDelegate
    }

    func populateSlideData(in context: NSManagedObjectContext) async throws {
        
        guard let startDate = yirConfig.dataPopulationStartDate, let endDate = yirConfig.dataPopulationEndDate else {
            return
        }
        
        // await savedSlideDataDelegate?.getSavedArticleSlideData(from: startDate, to: endDate)
        self.savedData = SavedArticleSlideData(savedArticlesCount: 25, articleTitles: ["Polar bear", "Matterhorn", "Arosa"])
        
        guard savedData != nil else { return }
        
        isEvaluated = true
    }

    func makeCDSlide(in context: NSManagedObjectContext) throws -> CDYearInReviewSlide {
        let slide = CDYearInReviewSlide(context: context)
        slide.id = id
        slide.year = Int32(year)

        if let savedData {
            slide.data = try JSONEncoder().encode(savedData)
        }

        return slide
    }

    static func shouldPopulate(from config: YearInReviewFeatureConfig, userInfo: YearInReviewUserInfo) -> Bool {
        return config.isEnabled && config.slideConfig.saveCountIsEnabled
    }
}
