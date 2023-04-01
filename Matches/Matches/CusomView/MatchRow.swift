import SwiftUI
import ComposableArchitecture
extension Status {
    var color: Color {
        switch self {
        case .finished:
            return .green
        case .postponed:
            return .red
        case .scheduled:
            return .yellow
        case .pause:
            return .brown
        case .inPlay:
            return .pink
        }
    }
}
enum Images: String {
    case star 
    case startFill = "star.fill"
    case placeHolder = "sportscourt.fill"
    case darkMode = "moon.fill"
    case lightMode = "sun.max"
}

struct ScoreBuilder: Equatable {
    var score: Score
    
    var fullTime: String {
        guard let home = score.fullTime.homeTeam ,
              let away = score.fullTime.awayTeam else {
            return "- -"
        }
       return "\(home) - \(away)"
    }
}

struct MatchRowFeature: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var id: Int {
            match.id
        }
        var match: MatchDomain
        var homeState: TeamView.ViesState {
            .init(
                image: match.homeTeam.crestUrl,
                name: match.homeTeam.name,
                isWinner: match.score.winner == .homeTeam
            )
        }
        var homeImage: String = Images.placeHolder.rawValue
        var awayImage: String = Images.placeHolder.rawValue
        var awayState: TeamView.ViesState {
            .init(
                image: match.awayTeam.crestUrl,
                name: match.awayTeam.name,
                isWinner: match.score.winner == .awayTeam
            )
        }

        
        var favoriteImage: String {
            match.isFavorite ? Images.startFill.rawValue : Images.star.rawValue
        }
        var score: String {
            ScoreBuilder(score: match.score).fullTime
        }
        var date: String = ""
    }
    
    @Dependency(\.dateFormatter) var dateFormatter
    @Dependency(\.matchesNetwork) var network
    @Dependency(\.matchRepository) var repository

    enum Delegate: Equatable {
            case refresh
    }
    enum Action: Equatable {
        case changeFavorite
        case formateDate
        case onAppear
        case load
        case response(home: Crest, away: Crest)
        case delegate(Delegate)
    }

    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .changeFavorite:
            state.match.isFavorite.toggle()
            return .task { [match = state.match] in
                if match.isFavorite {
                    try await repository.add(match)
                }else {
                    try await repository.remove(match.id)
                }
                return .delegate(.refresh)
            }catch: { error in
                debugPrint(error)
                return .delegate(.refresh)
            }
        case .formateDate:
            let date = dateFormatter.convertStringToDate(state.match.utcDate)
            state.date =  state.match.status == .finished ? date.formatted(.dateTime.day(.twoDigits)) + " " + date.formatted(.dateTime.weekday()) :
            date.formatted(.dateTime.hour(.twoDigits(amPM: .omitted))) + ":" + date.formatted(.dateTime.minute(.twoDigits))
            return .none
        case .onAppear:
            return .run { send in
                await send(.formateDate)
            }
        case .load:
            return .task { [match = state.match] in
                let home = try await network.loadCrests(match.homeTeam.id)
                let away = try await network.loadCrests(match.awayTeam.id)
                return .response(home: home, away: away)
            }catch: { error in
                debugPrint(error)
                return .formateDate
            }
        case let .response(home,away):
            state.homeImage = home.crestURL
            state.awayImage = away.crestURL
            return .none
        case .delegate(.refresh):
            return .none
        }
    }
}

struct MatchRowView: View {
    
    let store: StoreOf<MatchRowFeature>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            GeometryReader { geometryReader in
                ZStack {
                  RoundedRectangle(cornerRadius: 20,style: .continuous)
                        .shadow(color: .gray.opacity(0.3), radius: 5)
                    .frame(height: 110)
                    .foregroundColor(Color("CellBackground"))
                    HStack(alignment: .center){
                        TeamView(viewState: viewStore.awayState)
                      Spacer()
                    VStack{
                        Text(viewStore.score)
                        .font(.title)
                        .bold()
                        Text(viewStore.date)
                            .foregroundColor(viewStore.match.status.color)
                    }
                      Spacer()
                        TeamView(viewState: viewStore.homeState)

                  }
                  .padding(.horizontal)
                    Button {
                        viewStore.send(.changeFavorite, animation: .easeInOut)
                    } label: {
                        Image(systemName: viewStore.favoriteImage)
                            .foregroundColor(.yellow)
                        .offset(x: (geometryReader.size.width / 3) + 40 ,y: -30)
                    }
                }
              .onAppear {
                  viewStore.send(.formateDate)
              }
            }
            .frame(height: 100)
        }
    }
}



extension MatchRowFeature.State {
    static let testValue: Self = Self(match: .testValue)
}
#if DEBUG
struct MatchRowView_Previews: PreviewProvider {
    static var store: StoreOf<MatchRowFeature> {
        .init(
            initialState: .testValue,
            reducer: MatchRowFeature()
        )
    }
    static var previews: some View {
        MatchRowView(store: store)
    }
}

struct MatchRowStateBuilder {
    let state: MatchRowFeature.State = .testValue
    init(builder: (inout MatchRowStateBuilder) -> Void = { _ in }) {
        builder(&self)
    }

    func build() -> MatchRowFeature.State {
        state
    }
}
#endif

