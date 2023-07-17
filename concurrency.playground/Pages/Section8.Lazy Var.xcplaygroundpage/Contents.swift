import Foundation
import UIKit

/// lazy var에서도 Thread safe 하지 않은 상황을 만날 수 있음

/// # 메모리에 여러개의 객체가 생성되는 경우
/// - 원래는 하나의 객체에 하나의 변수에 대해 같은 공간의 메모리가 할당되지만 lazy var을 사용함으로서 시간 차에 의해 하나의 변수애 대한 값이 여러개 생겨남

// 디스패치 커스텀 동시큐의 생성
let queue = DispatchQueue(label: "test", qos: .default, attributes:[.initiallyInactive, .concurrent])

// 디스패치그룹 생성
let group = DispatchGroup()

class UIViewController {
    // 여러개의 작업이 lazy var에 접근 했을 때
    // 여러 스레드에서 객체내에 메모리에 접근함
    // lazy 작업 - 쓰기 작업과 유사하게 메모리에 로딩되는 시간이 조금 걸리는 작업
    lazy var image = {
        return UIImage()
    }()
}

let instance = UIViewController()

// 실제 비동기 작업 실행
for i in 0 ..< 10 {
    group.enter()
    queue.async(group: group) {
        // 0 에서 99 중 랜덤 숫자가 10개 생겨 남
        // 같은 객체이지만 여러개의 지역 변수가 생성된 것을 알 수 있음
        print("id:\(i), image:\(instance.image)")
        group.leave()
    }
}

group.notify(queue: DispatchQueue.global()){
    print("lazy var 이슈가 생기는 모든 작업의 완료.")
}

queue.activate()
group.wait()

/// id:4, image:<UIImage:0x600001b3e520 anonymous {0, 0} renderingMode=automatic(original)>
/// id:5, image:<UIImage:0x600001b30120 anonymous {0, 0} renderingMode=automatic(original)>
/// id:6, image:<UIImage:0x600001b28090 anonymous {0, 0} renderingMode=automatic(original)>
/// id:7, image:<UIImage:0x600001b34090 anonymous {0, 0} renderingMode=automatic(original)>
/// ... 생략
/// 각 다른 객체가 생성된 것을 확인할 수 있음


print("----------------------------Thread-Safe처리-----------------------------")
/// # Thread-Safe처리
class UIViewController2 {
    // 객체 내부에서는 시리얼 큐이기 때문에 순서대로 동작
    let serialQueue = DispatchQueue(label: "com.serial.queue")
    
    lazy var image = {
       return UIImage()
    }()
    
    // 읽을 때 시리얼 큐로
    var readImage: UIImage {
        serialQueue.sync {
            return image
        }
    }
}

let group2 = DispatchGroup()
let instance2 = UIViewController()

// 실제 비동기 작업 실행
for i in 0 ..< 10 {
    group2.enter()
    queue.async(group: group2) {
        // 0 에서 99 중 랜덤 숫자가 10개 생겨 남
        // 같은 객체이지만 여러개의 지역 변수가 생성된 것을 알 수 있음
        print("id:\(i), image:\(instance2.image)")
        group2.leave()
    }
}

group2.notify(queue: DispatchQueue.global()){
    print("lazy var 이슈가 생기는 모든 작업의 완료.")
}

group2.activate()
group2.wait()

//id:0, image:<UIImage:0x6000026e8000 anonymous {0, 0} renderingMode=automatic(original)>
//id:1, image:<UIImage:0x6000026e8000 anonymous {0, 0} renderingMode=automatic(original)>
//id:2, image:<UIImage:0x6000026e8000 anonymous {0, 0} renderingMode=automatic(original)>
//id:3, image:<UIImage:0x6000026e8000 anonymous {0, 0} renderingMode=automatic(original)>
//id:4, image:<UIImage:0x6000026e8000 anonymous {0, 0} renderingMode=automatic(original)>
//id:5, image:<UIImage:0x6000026e8000 anonymous {0, 0} renderingMode=automatic(original)>
//id:6, image:<UIImage:0x6000026e8000 anonymous {0, 0} renderingMode=automatic(original)>
//id:7, image:<UIImage:0x6000026e8000 anonymous {0, 0} renderingMode=automatic(original)>
//id:8, image:<UIImage:0x6000026e8000 anonymous {0, 0} renderingMode=automatic(original)>
//id:9, image:<UIImage:0x6000026e8000 anonymous {0, 0} renderingMode=automatic(original)>


print("-------------------------Dispatch Barrier--------------------------")
class UIViewController3 {
    lazy var image = {
        return UIImage()
    }()
}

let group3 = DispatchGroup()
let instance3 = UIViewController3()

for i in 0 ..< 10 {
    group3.enter()
    // group이 아닌 flag를 보냄
    // 각각의 작업에 대해 Barrier 처리
    queue.async(flags: .barrier) {
        // 0 에서 99 중 랜덤 숫자가 10개 생겨 남
        // 같은 객체이지만 여러개의 지역 변수가 생성된 것을 알 수 있음
        print("id:\(i), image:\(instance3.image)")
        group3.leave()
    }
}

group3.notify(queue: DispatchQueue.global()){
    print("lazy var 이슈가 생기는 모든 작업의 완료.")
}


print("----------------------Semaphore-----------------------")
class UIViewController4 {
    lazy var image = {
        return UIImage()
    }()
}

let group4 = DispatchGroup()
let instance4 = UIViewController4()
let semaphore = DispatchSemaphore(value: 1) // 한번에 처리할 수 있는 태스크의 갯수를 1로 설정

for i in 0 ..< 10 {
    group4.enter()
    semaphore.wait()
    queue.async(group: group4) {
        print("id:\(i), image:\(instance4.image)")
        group4.leave()
        semaphore.signal()
    }
}

group4.notify(queue: DispatchQueue.global()){
    print("lazy var 이슈가 생기는 모든 작업의 완료.")
}

/// Lazy var의 Thread-safe 처리 방법
/// 1. 명확하게 lazy 변수 생성 후 작업
/// 2. 시리얼큐 + Sync로 작업
/// 3. Dispatch Barrier로 작업
/// 4. 세마포어 이용. 작업의 동시 실행 갯수 제한
