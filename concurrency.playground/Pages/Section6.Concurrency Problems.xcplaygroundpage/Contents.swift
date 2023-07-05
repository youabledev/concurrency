import Foundation
import PlaygroundSupport

/// # 동시성과 관련된 문제들
///  ex )2개 이상의 스레드 -> 동일한 메모리 접근시 발생할 수 있는 문제
/// ## Thread-Safety
///  - 여러개의 스레드를 사용하여 동시 처리를 하면서도 문제가 발생하지 않도록 스레드를 안전하게 사용하는 것을 의미함
/// - 한번의 한개의 스레드만 접근 가능하도록 처리하면 경쟁상황에 문제 없이 사용할 수 있는데 이때 thread-safety
///
/// 비동기 처리는 실행시마다 같은 순서로 발생하는 것이 아니기 때문에 디버깅이 어려움


/// #Race Condition (경제적인 상황)
/// - 두 개 이상의 스레드가 한 곳의 저장공간에 동시에 접근, 값을 사용하려 할 때 문제가 발생
var a = 1 // <- 여러개의 스레드에서 접근하려고 하는 상황

DispatchQueue.global().async {
    sleep(1)
    a += 1
}

DispatchQueue.global().async {
    sleep(1)
    a += 1
}

print(a) // 1

/// #Deadlock (교착상태)
/// 메모리에 접근 하는 동안 다른 스레드에서 해당 메모리에 접근할 수 없도록 lock을 걸음
/// 이때 다른 스레드가 이 메모리에 접근하려는 경우 접근이 block됨
/// 2개 이상의 스레드가 배타적인 자원 사용으로 인해 서로 점유하려고 하면서 자원사용이 막힘
/// - 동기 작업이 현재 스레드를 필요로 하는 경우
/// - 앞선 작업이 현재의 스레드를 필요로 하는 경우
/// - 여러개의 semapore가 존재할 때나 이에 대한 순서를 잘못 설계한 경우
///
/// 해결 방안 :
/// 시리얼 큐를 사용. 작업이 순서대로 진행하기 때문


/// #Priority Inversion (우선 순위의 뒤바뀜)
/// - 낮은 우선 순위의 작업이 자원을 배타적으로 사용하고 있는 경우, 작업의 우선 순위가 바뀔 수 있음
/// - 우선 순위가 더 높은 작업이 배치되면서 우선 순위가 낮은 작업이 일시적으로 멈춤
/// -> 우선 순위가 가장 높은 작업이 자원을 사용하려 메모리에 접근하지만 배타적인 자원이므로 접근 불가. 작업을 진행할 수 없는 상태
/// -> 그 다음 우선 순위의 작업이 재개되어 진행됨
///
/// 발생할 수 있는 사례
/// - 시리얼 큐에서 높은 우선순위 작업이 낮은 우선순위 뒤에 실행되는 경우
/// - 낮은 우선순위의 작업이 높은 우선순위가 필요한 자원을 잠그고 있는 경우 lock 코드, Semapore
/// - 높은 우선 순위 작업이 낮은 우선 순위 작업에 의존하는 경우(높은 우선 순위 작업이 낮은 우선순위 작업을 필요로 하는 경우)
///
/// 해결법
/// - 1차적으로는 GCD가 우선순위를 조정해서 auto로 해결
/// - 공유된 자원 접근시 QoS(Quality of Service)를 사용함
///


// Qos를 다르게 해서 글로벌 동시큐를 정의
let highQueue = DispatchQueue.global(qos: .userInitiated)
let mediumQueue = DispatchQueue.global(qos: .utility)
let lowQueue = DispatchQueue.global(qos: .background)

// 일종의 자원 잠금을 위해 선언
let semaphore = DispatchSemaphore(value: 1)

highQueue.async {
    sleep(3)
    semaphore.wait() // 3초 이후에 세마포어 자원을 잠그는 코드를 실행함
    print("high")
    semaphore.signal()
} // => 우선 순위가 제일 높지만 자원의 lock으로 인해 가장 마지막에 실행됨

for i in 2...11 {
    mediumQueue.async {
        // 자원 lock의 영향을 받지 않고 실행됨
        print("medium \(i)")
        sleep(UInt32(Int.random(in: 1...7)))
    }
}

lowQueue.async {
    semaphore.wait() // 해당 코드가 highQueue보다 먼저 실행되어 우선 순위가 낮은 큐가 먼저 자원에 접근해서 사용하게 됨
    print("low")
    sleep(5)
    semaphore.signal()
}

