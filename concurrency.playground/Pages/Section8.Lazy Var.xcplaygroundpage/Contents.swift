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

