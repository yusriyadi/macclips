import Darwin
import Foundation

@MainActor
protocol InstanceLocking {
    func acquire() -> Bool
}

@MainActor
struct SingleInstanceCoordinator {
    let instanceLock: InstanceLocking

    func beginLaunch() -> Bool {
        instanceLock.acquire()
    }
}

@MainActor
final class FileInstanceLock: InstanceLocking {
    private static var retainedDescriptor: Int32 = -1

    private let lockFilePath: String

    init(lockFilePath: String = "/tmp/com.openai.clipboardmanager.lock") {
        self.lockFilePath = lockFilePath
    }

    func acquire() -> Bool {
        if Self.retainedDescriptor != -1 {
            return true
        }

        let descriptor = open(lockFilePath, O_CREAT | O_RDWR, S_IRUSR | S_IWUSR)
        guard descriptor != -1 else {
            return false
        }

        if flock(descriptor, LOCK_EX | LOCK_NB) != 0 {
            close(descriptor)
            return false
        }

        Self.retainedDescriptor = descriptor
        return true
    }
}
