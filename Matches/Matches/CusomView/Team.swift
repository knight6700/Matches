import SwiftUI


struct TeamView: View {
    struct ViesState: Equatable {
        var image: URL?
        var name: String
        var isWinner: Bool
        
        var crestState: CrestView.ViewState {
            .init(
                image: image,
                width: 25,
                height: 25
            )
        }
    }
    
    let viewState: ViesState
    
    var body: some View {
        VStack {
            CrestView(viewState: viewState.crestState)
            Text(viewState.name)
                .font(viewState.isWinner ? .headline : .body)
                .minimumScaleFactor(0.75)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(width: 100)
                  .lineLimit(2)
            Spacer()
        }
        .padding(.top)
    }
}
#if DEBUG
extension TeamView.ViesState {
    static let testValue: Self = Self(image: URL(string: "https://crests.football-data.org/57.png"), name: "Arsenal", isWinner: true)
}
struct TeamView_Previews: PreviewProvider {
    static var previews: some View {
        TeamView(viewState: .testValue)
    }
}
#endif

