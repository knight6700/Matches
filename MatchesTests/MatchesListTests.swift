
import Combine
import ComposableArchitecture
import XCTest
import XCTestDynamicOverlay
@testable import Matches
@testable import NetworkHerizon

@MainActor
class MatchesListTests: XCTestCase {

    override  func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func test_initialload_withViewAppearance_dataLoaded() async {
        let store: TestStore = TestStore(
            initialState: .init(),
          reducer: MatchesList()
        )
        @Dependency(\.matchesFiler) var filter
        
        await store.send(.onAppear)
        await store.receive(.load)
        let filterData = filter.sortMatches(Competitions.testValue.matches.map{$0.toDomain})
        await store.receive(.loadedMatches(filterData)) {
            $0.handleLoadedMatches(matches: filterData)
        }
    }
    
    func testHandleLoadedMatches() {
        var state = MatchesList.State()
        @Dependency(\.matchesFiler) var filter
        let filterData = filter.sortMatches(Competitions.testValue.matches.map{$0.toDomain})

        state.handleLoadedMatches(matches: filterData)
        XCTAssertEqual(state.listViewState.viewState, .loaded)
        XCTAssertEqual(state.matchesState.count, 1)

        
    }
}



