import Foundation
import PlaygroundSupport

/// 각 Queue마다 특성이 있고 해당 Queue에 task를 보내면 Queue는 자동으로 스레드에 task를 배정함
///
/// 1) 메인 큐
///     - 유일한 큐, 시리얼로 동작, 메인 스레드
///     - ```DispatchQueue.main.async { }```
///

print("print something")

// 의미적으로 위와 아래 코드가 같음

DispatchQueue.main.async {
    print("print something")
}

DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
    
}

/// 2) globalQueue
///     - 종류가 여러개
///     - 기본설정은 Concurrent로 되어 있음: 여러개의 스레드에서 분산 처리하도록 되어 있음 -> 순서가 중요하지 않은 작업을 보내야 하는 이유
///     - QoS (Quality of Service 6종류)

/// <QoS: 큐의 서비스 품질>
/// - 먼저 적힌 순으로 중요도 높음
/// - 우선적으로 중요한 일일 경우 스레드에 우선순위를 매겨 더 여러개의 스레드에 배치하게 됨

DispatchQueue.global(qos: .userInteractive)
// => 유저와 직접적으로 관련된 것. UI 업데이트, 애니메이션, 사용자와의 상호작용
// => 거의 즉시 실행됨

DispatchQueue.global(qos: .userInitiated)
// => 몇 초
// => 유저가 즉시 필요하지만 비동기적으로 처리된 작업
// => 파일을 여는 몇 초 정도의 작업

DispatchQueue.global()
// => default
// => 일반적인 작업

DispatchQueue.global(qos: .utility)
// => 몇 초에서 몇분
// => 보통 처리하는데 긴 작업으로 Progress Indicator를 필요로 할때, 계산, IO, Networking, 지속적인 Feeds

DispatchQueue.global(qos: .background)
// => 속도 < 에너지 효율성 중시
// => 유저가 직접적으로 인지 x, 데이터 미리 가져오기, DB 유지
// => 몇 분 이상 걸림

DispatchQueue.global(qos: .unspecified)
// => legacy API
// => 사용 x

let queue = DispatchQueue.global(qos: .background) // 생성된 큐는 백그라운드로 정의
// 작업을 보낼 때 파라미터를 유틸리티로 설정
queue.async(qos: .utility) {
    // task1
    // 큐가 작업의 영향을 받아서 품질이 utility로 상승함
}


/// 3) private (custom) queue
/// - default는 serial
/// - concurrent 설정 가능
/// - QoS 설정 가능, OS가 QoS를 알아서 추론
///

let customQueue = DispatchQueue(label: "com.youable.serial") // 레이블을 붙여 생성함
queue.async {
    // 비동기적으로 작업 보낼 수 있음
}

let concurrentCustomQueue = DispatchQueue(label: "com.youable.concurrent", attributes: .concurrent)

// ## Example

func task1() {
    sleep(2)
    print("task1 끝남")
}

func task2() {
    sleep(2)
    print("task2 끝남")
}

func task3() {
    sleep(2)
    print("task3 끝남")
}

let defaultQueue = DispatchQueue.global()

defaultQueue.async(qos: .background) {
    task1()
    print("default queue 1")
}

defaultQueue.async {
    task2()
    print("default queue 2")
}

defaultQueue.async(qos: .userInteractive) {
    task3()
    print("default queue 3")
}

// => defaultQueue를 생성하고 백그라운드 태스크 실행 -> default 태스크 실행 -> userInteractive 태스크 실행할 시
// background가 가장 늦게 처리 되며 default의 태스크가 끝나고 userInteractive 가 끝이남
// 순서대로 시작했지만 끝나는 시간은 알 수 없음. default 큐는 "동시적인 큐이기 때문에" 여러개의 스레드를 생성했기 때문에 어떤 작업이 먼저 끝날 것인지는 장담할 수 없음
let privateQueue = DispatchQueue(label: "com.youable.serial")

privateQueue.async {
    task1()
    print("Private Queue1")
}

privateQueue.async {
    task2()
    print("Private Queue2")
}

privateQueue.async {
    task3()
    print("Private Queue3")
}

// serial Queue이기 때문에 task1 -> task2 -> task3 순으로 실행됨

let privateConcurrentQueue = DispatchQueue(label: "com.youable.concurrent", attributes: .concurrent)

privateConcurrentQueue.async {
    task1()
    print("privateConcurrentQueue1")
}

privateConcurrentQueue.async {
    task2()
    print("privateConcurrentQueue2")
}

privateConcurrentQueue.async {
    task3()
    print("privateConcurrentQueue3")
}
