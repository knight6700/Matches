
import SwiftUI
import ComposableArchitecture

@main
struct MatchesApp: App {
    let store: StoreOf<TabViewFeature> =
        .init(
        initialState: .init(),
        reducer: TabViewFeature()
        )
    @StateObject var network: Monitor = .init()
    @State var showAlert: Bool = false
    
    var body: some Scene {
        WindowGroup {
            TabViewView(store: store)
                .onChange(of: network) { newValue in
                    switch newValue.status {
                    case .connected:
                        showAlert = false
                    case .disconnected:
                        showAlert = true
                    }
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text("Your internet connection is too slow."), dismissButton: .default(Text("ok")))
                }

        }
    }
}
