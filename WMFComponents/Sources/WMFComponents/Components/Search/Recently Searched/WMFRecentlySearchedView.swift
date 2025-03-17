import SwiftUI

public struct WMFRecentlySearchedView: View {
    
    @ObservedObject var viewModel: WMFRecentlySearchedViewModel
    @ObservedObject var appEnvironment = WMFAppEnvironment.current

    var theme: WMFTheme {
        return appEnvironment.theme
    }

    public init(viewModel: WMFRecentlySearchedViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        if viewModel.recentSearchTerms.isEmpty {
            Text("No recent searches yet")
                .padding([.top], viewModel.topPadding)
        } else {
            List {
                HStack {
                    Text(viewModel.localizedStrings.title)
                        .font(Font(WMFFont.for(.boldHeadline)))
                        .foregroundStyle(Color(uiColor: theme.text))
                        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    Spacer()
                    Button(viewModel.localizedStrings.clearButtonTitle) {
                        print("click")
                    }
                    .font(Font(WMFFont.for(.headline)))
                    .foregroundStyle(Color(uiColor: theme.link))

                }
                .padding([.top, .bottom], 16)
                ForEach(viewModel.recentSearchTerms) { item in
                    Text(item.text)
                        .swipeActions {
                            Button("Delete") {
                                print("Delete recent search term")
                            }
                        }
                }
            }
            .listStyle(.plain)
            .padding([.top], viewModel.topPadding)
        }
        
    }
}
