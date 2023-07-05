import Foundation
import PlaygroundSupport

/// Dispatch workItem
/// - 작업을 클래스화
/// - 작업을 미리 클래스로 정의하고 이 객체를 큐에 제출
/// - 빈약한 '취소 기능' 내장
///     - cancel() 메서드가 존재함 : 작업이 아직 큐에 남아 있는 경우 작업이 제거됨, 작업이 실행 중인 경우 isCancelled 속성이 true로 설정됨(직접적으로 실행중인 작업을 멈추는 것은 아니며 속성 값이 변경되는 것.)
/// - 빈약한 '순서 기능' 내장
///     - 작업이 끝난 후에 실행할 작업을 지정할 수 있음
///     - notify(queue: 실행할 큐, execute: 디스패치 아이템)


let item1 = DispatchWorkItem(qos: .utility) {
    // 여기에 작업
    print("task1")
}

// 취소기능
// 실제 작업이 취소된 것은 아니고 isCanceld 속성 값이 변경되므로 이를 이용해서 사용할 수 있음
//item1.cancel()

let item2 = DispatchWorkItem() {
    print("task2")
}

// queue 생성
let queue = DispatchQueue(label: "com.youable.dispatchworkitem")

queue.async(execute: item1)
queue.async(execute: item2)
// 시리얼 큐에서 실행 했기 때문에 순서대로 작업이 호출됨


// 순서 지정 기능
item1.notify(queue: DispatchQueue.global(), execute: item2)
queue.async(execute: item1)
