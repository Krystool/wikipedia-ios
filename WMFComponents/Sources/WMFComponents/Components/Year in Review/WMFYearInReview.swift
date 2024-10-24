import SwiftUI

public struct WMFYearInReview: View {
    @ObservedObject var appEnvironment = WMFAppEnvironment.current
    @State private var currentSlide = 0
    @ObservedObject var viewModel: WMFYearInReviewViewModel

    var theme: WMFTheme {
        return appEnvironment.theme
    }

    public var donePressed: (() -> Void)?

    public init(viewModel: WMFYearInReviewViewModel) {
        self.viewModel = viewModel
        UINavigationBar.appearance().backgroundColor = theme.midBackground
    }

    let configuration = WMFSmallButton.Configuration(style: .quiet, trailingIcon: nil)

    public var body: some View {
        NavigationView {
            VStack {
                HStack {
                    if !viewModel.isFirstSlide {
                        WMFYearInReviewDonateButton(viewModel: viewModel)
                    }
                    Spacer()
                    Button(action: {
                        donePressed?()
                    }) {
                        Text(viewModel.localizedStrings.doneButtonTitle)
                            .foregroundStyle(Color(uiColor: theme.link))
                            .font(Font(WMFFont.for(.semiboldHeadline)))
                    }
                }
                .padding()
                if viewModel.isFirstSlide {
                    WMFYearInReviewScrollView(scrollViewContents: scrollViewContent, contents: { AnyView(buttons) })
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack {
                        TabView(selection: $currentSlide) {
                            WMFSlideShow(currentSlide: $currentSlide, slides: viewModel.slides)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 48)
                    }
                    .ignoresSafeArea(edges: .bottom)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .background(Color(uiColor: theme.midBackground))
            .toolbar {
                if !viewModel.isFirstSlide {
                    ToolbarItem(placement: .bottomBar) {
                        HStack(alignment: .center) {
                            Button(action: {
                                // TODO: Implement share
                            }) {
                                HStack(alignment: .center, spacing: 6) {
                                    if let uiImage = WMFSFSymbolIcon.for(symbol: .share, font: .semiboldHeadline) {
                                        Image(uiImage: uiImage)
                                            .foregroundStyle(Color(uiColor: theme.link))
                                    }
                                    Text(viewModel.localizedStrings.shareButtonTitle)
                                        .foregroundStyle(Color(uiColor: theme.link))
                                }
                                .font(Font(WMFFont.for(.semiboldHeadline)))
                            }
                            .frame(maxWidth: .infinity)
                            Spacer()
                            HStack(spacing: 9) {
                                ForEach(0..<viewModel.slides.count, id: \.self) { index in
                                    Circle()
                                        .fill(index == currentSlide ? Color(uiColor: theme.link) : Color(uiColor: theme.link.withAlphaComponent(0.3)))
                                        .frame(width: 7, height: 7)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            Spacer()
                            Button(action: {
                                withAnimation {
                                    currentSlide = (currentSlide + 1) % viewModel.slides.count
                                }
                            }) {
                                Text(viewModel.localizedStrings.nextButtonTitle)
                                    .foregroundStyle(Color(uiColor: theme.link))
                                    .font(Font(WMFFont.for(.semiboldHeadline)))
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            Spacer()
        }
        .background(Color(uiColor: theme.midBackground))
        .navigationViewStyle(.stack)
        .environment(\.colorScheme, theme.preferredColorScheme)
        .frame(maxHeight: .infinity)
    }

    private var scrollViewContent: some View {
        VStack(spacing: 48) {
            VStack(alignment: .leading, spacing: 16) {
                Image("globe", bundle: .module)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 48)
                Text(viewModel.localizedStrings.firstSlideTitle)
                    .font(Font(WMFFont.for(.boldTitle1)))
                Text(viewModel.localizedStrings.firstSlideSubtitle)
                    .font(Font(WMFFont.for(.title3)))
            }
            .foregroundStyle(Color(uiColor: theme.text))
        }
    }

    private var buttons: some View {
        VStack {
            WMFLargeButton(configuration: .primary, title: viewModel.localizedStrings.firstSlideCTA) {
                withAnimation(.easeInOut(duration: 0.75)) {
                    viewModel.getStarted()
                }
            }
            WMFSmallButton(configuration: configuration, title: viewModel.localizedStrings.firstSlideHide) {
                // TODO: Implement hide this feature
            }
        }
    }
}
