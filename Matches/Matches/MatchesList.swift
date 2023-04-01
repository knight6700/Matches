
import SwiftUI
import ComposableArchitecture
import SwiftUINavigation

struct MatchesList: ReducerProtocol {
    /// Store all values for presentation Layer
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
        case list(ListViewFeature.Action)
        case error(String)
    }
    
    // MARK: Reducer
    var body: some ReducerProtocol<State, Action> {
        Scope(
            state: \.listViewState,
            action: /Action.list
        ) {
            ListViewFeature()
        }
        
        Reduce { state, action in
            switch action {
            case  .matches(id: _, action: _):
                return .none
            case  .onAppear:
                return .init(value: .load)
            case let .loadedMatches(matches):
                state.handleLoadedMatches(matches: matches)
            case .load:
                state.listViewState = .init(viewState: .loading)
                return .task {
                    let response = try await repository.fetchMatches()
                    return  .loadedMatches(matchFilter.sortMatches(response))
                }catch: { error in
                    return .error(error.localizedDescription )
                }
            case let .error(error):
                state.listViewState = .init(viewState: .error(text: error))
                state.alertState = AlertState(
                    title: TextState("Alert!"),
                    message: TextState(error)
                  )
            case .dismissAlert:
                state.alertState = nil
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
        
        
    }
}
extension MatchesList.State {
    mutating func handleLoadedMatches(matches: [Date : [MatchDomain]]) {
        matchesState.removeAll()
        listViewState = matches.count < 1 ? .init(viewState: .error(text: LocalizationStrings.noContentError)) : .init(viewState: .loaded)
        let sorted = matches.sorted(by: { $0.key > $1.key })
        matchesState.append(contentsOf: sorted.map { key, value in
            MatchSectionFeature.State(matches: value, date: key)
        })

    }
}

struct MatchesListView: View {
    let store: StoreOf<MatchesList>
    @State private var isActive = false

    var body: some View {
        NavigationStack {
            WithViewStore(store) { viewStore in
                ListView(
                    store: store.scope(
                        state: \.listViewState,
                        action: MatchesList.Action.list
                    ),
                    content: {
                        ForEachStore(
                            self.store
                                .scope(state:
                                        \.matchesState,
                                       action: MatchesList.Action.matches(id:action:)),
                            content: {
                                MatchSectionView(store: $0)
                            }
                        )
                    }
                )//: LIST
                .ignoresSafeArea()
                .scrollIndicators(.hidden)
                .listStyle(.plain)
                .padding(.top, 1)
                .alert(
                    self.store.scope(state: \.alertState), dismiss: .dismissAlert
                )
                .onAppear {
                    viewStore.send(.onAppear)
                }//: OnAppear
            }
            .navigationTitle(LocalizationStrings.matchesTitle)
        }
    }
}

#if DEBUG
struct MatchesListView_Previews: PreviewProvider {
   static let store: StoreOf<MatchesList> =
        .init(
        initialState: .init(),
        reducer: MatchesList()
        )
    static var previews: some View {
        MatchesListView(store: store)
    }
}
#endif
