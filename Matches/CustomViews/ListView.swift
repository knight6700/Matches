import SwiftUI
import ComposableArchitecture

public struct ListViewFeature: ReducerProtocol {
    public init() {}
    public struct State: Equatable {
        public var viewState: ViewState
        public init(viewState: ViewState) {
            self.viewState = viewState
        }
    }
    public enum ViewState: Equatable {
        case loading
        case loaded
        case error(text: String)
        case empty(text: String)
    }
    public enum Action: Equatable {
        case retry
        case refresh
    }
        
    public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        return .none
    }
}




public struct ListView <Content: View>: View {
    let store: StoreOf<ListViewFeature>
    let content: () -> Content
    @AppStorage("isDarkMode") private var isDarkMode: Bool = true
    public init(
        store: StoreOf<ListViewFeature>,
        content: @escaping () -> Content
    ) {
        self.store = store
        self.content = content
    }
    public var body: some View {
        WithViewStore(store) { viewStore in
            switch viewStore.viewState {
            case .loading:
                loadingView(content: content())
            case .loaded:
                List {
                    content()
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
                .refreshable {
                    await viewStore.send(.refresh).finish()
                }
                .listStyle(.plain)
            case let .error(text):
                VStack {
                    Spacer()
                    Text(text)
                    Spacer()
                }
                .multilineTextAlignment(.center)
                
            case let .empty(text):
                VStack {
                    Spacer()
                    Text(text)
                    Spacer()
                }
                .multilineTextAlignment(.center)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing){
                Button(action: {
                    isDarkMode.toggle()
                }, label: {
                    Image(systemName: isDarkMode ? Images.lightMode.rawValue : Images.darkMode.rawValue)
                        .foregroundColor(Color("TextColors"))
                })
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}
extension ListView {
    @MainActor @ViewBuilder
    func loadingView(content: Content) -> some View {
        List(0...10, id: \.self) { _ in
            content
                .redacted(reason: .placeholder)
                .listRowSeparator(.hidden)
                .disabled(true)
        }
        .listStyle(.plain)
    }
}
#if DEBUG
extension ListViewFeature.State {
    static let loading = Self(viewState: .loading)
    static let loaded = Self(viewState: .loaded)
    static let error = Self(viewState: .error(text: "Not loaded"))
}

struct PlaceHolderView_Previews: PreviewProvider {
    static var previews: some View {
        ListView(store: .init(initialState: .loaded, reducer: ListViewFeature()), content: {Text("Hello")})
            .previewDisplayName("Loaded")
        
        ListView(store: .init(initialState: .loading, reducer: ListViewFeature()), content: {Text("Hello")})
            .previewDisplayName("Loading")
        
        ListView(store: .init(initialState: .error, reducer: ListViewFeature()), content: {Text("Hello")})
            .previewDisplayName("Error state")
    }
}
#endif
