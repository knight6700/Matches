import SwiftUI
import ComposableArchitecture

struct FavoriteFeature: ReducerProtocol {
    struct State: Equatable {
        var matchesState: IdentifiedArrayOf<MatchSectionFeature.State> = [.init(matches: [.testValue], date: .now)]
        var alertState: AlertState<Action>?
        var listViewState: ListViewFeature.State = .init(viewState: .loading)
    }
    /// Api Dependancies to handle network fo all env live , test, preview
    @Dependency(\.matchRepository) var repository
    @Dependency(\.matchesFiler) var matchFilter
    enum Action: Equatable {
        case matches(id: MatchSectionFeature.State.ID, action: MatchSectionFeature.Action)
        case onAppear
        case loadedMatches([Date:[MatchDomain]])
        case load
        case dismissAlert
        case error(String)
        case delegate(Delegate)
        case list(ListViewFeature.Action)
    }
    enum Delegate: Equatable {
        case refresh
    }
    // MARK: Reducer
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case  .matches(id: _, action: .delegate(.refresh)):
                return .send(.delegate(.refresh))
            case  .matches:
                return .none
            case  .onAppear:
                return .init(value: .load)
            case let .loadedMatches(matches):
                state.matchesState.removeAll()
                state.listViewState = matches.count < 1 ? .init(viewState: .error(text: LocalizationStrings.noFavoriteError)) : .init(viewState: .loaded)
                let sorted = matches.sorted(by: { $0.key > $1.key })
                state.matchesState .append(contentsOf: sorted.map { key, value in
                    MatchSectionFeature.State(matches: value, date: key)
                })
            case .load:
                state.listViewState = .init(viewState: .loading)
                return .task {
                    let response = try await repository.favoriteMatches()
                    return  .loadedMatches(matchFilter.sortMatches(response))
                }catch: { error in
                    return .error(error.localizedDescription )
                }
            case let .error(error):
                state.listViewState = .init(viewState: .loaded)
                state.alertState = AlertState(
                    title: TextState("Alert!"),
                    message: TextState(error)
                  )
            case .dismissAlert:
                state.alertState = nil
            case .delegate(.refresh):
                state.matchesState.removeAll()
                return .send(.load)
            case .list:
                return .none
            }
            return .none
        }
        .forEach(
            \.matchesState,
             action: /Action.matches,
             element: {
                 MatchSectionFeature()
             }
        )
        
        Scope(
            state: \.listViewState,
            action: /Action.list
        ) {
            ListViewFeature()
        }
    }
    
    
}

struct FavoriteView: View {
    let store: StoreOf<FavoriteFeature>
    @State private var isActive = false

    var body: some View {
        NavigationStack {
            WithViewStore(store) { viewStore in
                ListView(store: store.scope(state: \.listViewState, action: FavoriteFeature.Action.list)) {
                    ForEachStore(
                        self.store
                        .scope(state:
                            \.matchesState,
                            action: FavoriteFeature.Action.matches(id:action:)),
                        content: {
                            MatchSectionView(store: $0)
                        })
                }
                .ignoresSafeArea()
                .scrollIndicators(.hidden)
                .listStyle(.plain)
                .padding(.top, 1)
                .padding(.bottom)
                .alert(
                    self.store.scope(state: \.alertState), dismiss: .dismissAlert
                )
                .onAppear {
                    viewStore.send(.onAppear)
                }//: OnAppear
            }
            .navigationTitle(LocalizationStrings.favoriteTitle)
        }
    }
}


#if DEBUG
struct FavoriteView_Previews: PreviewProvider {
    static var store: StoreOf<FavoriteFeature> {
        .init(
            initialState: .init(),
            reducer: FavoriteFeature()
        )
    }
    static var previews: some View {
        FavoriteView(store: store)
    }
}

struct FavoriteStateBuilder {

    init(builder: (inout FavoriteStateBuilder) -> Void = { _ in }) {
        builder(&self)
    }

    func build() -> FavoriteFeature.State {
        .init()
    }
}
#endif
