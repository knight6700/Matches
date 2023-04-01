import SwiftUI
import ComposableArchitecture

struct MatchSectionFeature: ReducerProtocol {
    struct State: Equatable, Identifiable {
        
        init( matches: [MatchDomain],date: Date) {
            self.date = date
            self.rowState.append(contentsOf: matches.map {MatchRowFeature.State(match: $0)})
        }
        var rowState: IdentifiedArrayOf<MatchRowFeature.State> = []
        var date: Date
        var sectionTitle: String = ""
        var id: Date {
            date
        }
        var numberOfMatches: String {
            LocalizationStrings.numberOfMatches(rowState.count)
        }
    }
    
    enum Delegate: Equatable {
        case refresh
    }
    
    enum Action: Equatable {
        case row(id: MatchRowFeature.State.ID, action: MatchRowFeature.Action)
        case onAppear
        case delegate(Delegate)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .row(id: _ , action: .delegate(.refresh)):
                return .send(.delegate(.refresh))
            case .row:
                return .none
            case .onAppear:
                state.sectionTitle = state.date.formatted(.dateTime.day(.twoDigits)) + " " + state.date.formatted(.dateTime.month()) + "," + state.date.formatted(.dateTime.weekday(.wide))

                return .none
            case .delegate(.refresh):
                return .none
            }
        }
        .forEach(\.rowState, action: /Action.row) {
            MatchRowFeature()
        }
    }
}
struct MatchSectionView: View {
    
    let store: StoreOf<MatchSectionFeature>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            Section {
                ForEachStore(
                    self.store
                        .scope(state:\.rowState,
                               action: MatchSectionFeature.Action.row(id:action:)),
                    content: {
                        MatchRowView(store: $0)
                    }
                )
            } header: {
                VStack(alignment: .center) {
                    Text(viewStore.sectionTitle)
                    HStack {
                        Spacer()
                        Text(viewStore.numberOfMatches)
                        Spacer()
                    }
                }
                .foregroundColor(Color.gray)
                .font(.subheadline)
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}
#if DEBUG
struct MatchSectionView_Previews: PreviewProvider {
    static var store: StoreOf<MatchSectionFeature> {
        .init(
            initialState: .init(matches: [.testValue], date: .now),
            reducer: MatchSectionFeature()
        )
    }
    static var previews: some View {
        List {
            MatchSectionView(store: store)
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        
    }
}
#endif
