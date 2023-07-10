import Foundation
import PlaygroundSupport

/// 여러 스레드에서 특정 객체에 동시적으로 접근할 가능성이 있음

class TestObject {
    private let serialQueue = DispatchQueue(label: "...")
    private var _count = 0
    
    // 읽기/쓰기가 여러 스레드에서 동시에 일어나는 것은 Thread-Safe하지 않은 상황
    public var count: Int {
        get {
            return serialQueue.sync { // 여러 스레드에서 접근하기 때문에 직렬 큐와 sync 메서드를 사용해서 접근해야 함
                // Global Default Queue에서 Serial Queue로 보낸 작업을 기다린다는 의미 즉, 시리얼 큐에서 기다리는 게 아니라 디폴트 글로벌 큐에서 기다림
                // 메인 스레드에서는 사용하지 않도록 함
                // 모든 스레드가 일관된 값을 얻을 수 있도록 보장 함
                _count
            }
        }
        
        set {
            serialQueue.sync {
                _count = newValue
            }
        }
        
        // => 쓰기도 읽기도 Sync로 이뤄지기 때문에 한번에 많은 작업을 보내더라도 순차적으로 시리얼 큐에 쌓이게 되고 쌓인 순대로 처리됨
        // 즉 종료시점까지 해당 스레드를 block한다는 것. 객체에 한번에 한개의 스레드만 접근 가능하도록 작업 된것
    }
    
    init() { }
}
