import Foundation
import PlaygroundSupport

class TestClass {
    // 객체 내부에 thread safe 처리해야함
    private let concurrentQueue = DispatchQueue(label: "com.dispatch.barrier", attributes: .concurrent)
    
    private var _count = 0
    public var count: Int {
        get {
            return concurrentQueue.sync {
                _count // 단순 읽어 오는 작업은 동시(sync) 제대로 읽어온 다음 작업을 하기 위해서 
            }
        } set {
            /// concurrent 큐 임에도 불구하고 여러 스레드 중 "barrier 작업"을 실행할 경우 한 개의 스레드만 사용해 serial 로 실행 가능하도록 함
            /// 베리어 작업 자체는 한번에 하나만 실행 됨. 배리어 작업이 끝나면 다른 작업들은 다시 동시적으로 실행됨
            /// 읽기 작업은 동시적으로 실행하고 쓰기 작업은 배리어 작업을 통해 다른 스레드에서 접근하지 못하도록 상호 배제 함
            concurrentQueue.async(flags: .barrier) { [unowned self] in
                self._count = newValue // 쓰는 작업은 다른 스레드가 접근 하지 못하도록 DispatchBarrier를 사용 할 수 있음
            }
        }
    }
}

// wwdc thread safe 참고
