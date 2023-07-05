import Foundation
import PlaygroundSupport
import UIKit

/// # Semaphore 수기 신호
/// 공유 리소스에 접근 가능한 작업 수를 제한
/// ex: 한번에 다운로드 가능한 숫자를 지정할 때

// 공유 리소스에 접근 가능한 작업수를 4개로 제한함
let semaphore = DispatchSemaphore(value: 3)

let group = DispatchGroup()
let queue = DispatchQueue.global(qos: .userInteractive)

func downloadImage(_ urlString: String, completion: (UIImage) -> Void) {
    sleep(3)
    completion(UIImage())
}

for _ in 1...10 {
    queue.async(group: group) {
        group.enter()
        semaphore.wait() // 작업 제한이 있으므로 기다려 semaphore count -1
        downloadImage("test.com") { image in
            print(image)
            group.leave()
            semaphore.signal() // 작업이 끝났음을 알림 semaphore count +1
        }
    }
}
// 육안으로 볼 때는 3개 단위로 작업이 시작되고 끝나는 것을 확인 할 수 있음

group.notify(queue: DispatchQueue.global()) {
    print("모든 작업이 끝남")
}

// 만약 semaphore에서 제한하는 갯수가 3이고
// 현재 모든 스레드에서 작업 중인 태스크의 갯수가 3개이면 wait또한 3번 호출되어야 함
// 처리 중 3번의 제한 갯수를 넘지 못하므로 다른 태스크는 큐에서 대기
// 이후 signal이 불리면 현재 스레드에서 작업 중이 테스크 중 일부가 종료되었다는 것을 의미
// 현재 스레드에서 작업 중인 태스크의 갯수가 3개 미만인 경우 대기 중인 태스크를 실행할 수 있게 됨
// 따라서 semaphore의 wait과 signal 함수를 적절한 타이밍에 호출해 주어야 함.


