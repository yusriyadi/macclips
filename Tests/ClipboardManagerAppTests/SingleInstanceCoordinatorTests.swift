import Testing
@testable import ClipboardManagerApp

struct SingleInstanceCoordinatorTests {
    @Test
    @MainActor
    func launchesWhenLockIsAvailable() {
        let lock = TestInstanceLock(acquireResult: true)
        let coordinator = SingleInstanceCoordinator(instanceLock: lock)

        #expect(coordinator.beginLaunch() == true)
        #expect(lock.acquireCallCount == 1)
    }

    @Test
    @MainActor
    func blocksLaunchWhenAnotherInstanceOwnsLock() {
        let lock = TestInstanceLock(acquireResult: false)
        let coordinator = SingleInstanceCoordinator(instanceLock: lock)

        #expect(coordinator.beginLaunch() == false)
        #expect(lock.acquireCallCount == 1)
    }
}

private final class TestInstanceLock: InstanceLocking {
    private let acquireResult: Bool
    private(set) var acquireCallCount = 0

    init(acquireResult: Bool) {
        self.acquireResult = acquireResult
    }

    func acquire() -> Bool {
        acquireCallCount += 1
        return acquireResult
    }
}
