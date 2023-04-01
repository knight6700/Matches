import SwiftUI
import ComposableArchitecture

struct TabViewFeature: ReducerProtocol {
    struct State: Equatable {
        var matchesListState: MatchesList.State = .init()
        var favoriteState: FavoriteFeature.State = .init()
        var selectionId: Int = 0
    }
    
    enum Action: Equatable {
        case matches(MatchesList.Action)
        case favorite(FavoriteFeature.Action)
        case changeSelection(Int)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            return .none
        }
        
        Scope(
            state: \.matchesListState,
            action: /Action.matches
        ) {
            MatchesList()
        }
        
        Scope(
            state: \.favoriteState,
            action: /Action.favorite
        ) {
            FavoriteFeature()
        }
        
    }
}
struct TabViewView: View {
    
    let store: StoreOf<TabViewFeature>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            TabView {
                MatchesListView(
                    store: store.scope(state: \.matchesListState, action: TabViewFeature.Action.matches)
                )
                .tabItem {
                    Image(systemName: Images.placeHolder.rawValue)
                    Text(LocalizationStrings.matchesTitle)
                }
                .tag(0)
                
                FavoriteView(
                    store: store.scope(
                        state: \.favoriteState,
                        action: TabViewFeature.Action.favorite
                    )
                )
                    .tabItem {
                        Image(systemName: "star.fill")
                        Text(LocalizationStrings.favoriteTitle)
                    }
                    .tag(1)
                
            }
        }
    }
}

struct TabViewView_Previews: PreviewProvider {
    static var store: StoreOf<TabViewFeature> {
        .init(
            initialState: .init(),
            reducer: TabViewFeature()
        )
    }
    static var previews: some View {
        TabViewView(store: store)
    }
}
#if DEBUG
struct TabViewStateBuilder {

    init(builder: (inout TabViewStateBuilder) -> Void = { _ in }) {
        builder(&self)
    }

    func build() -> TabViewFeature.State {
        .init()
    }
}
#endif
