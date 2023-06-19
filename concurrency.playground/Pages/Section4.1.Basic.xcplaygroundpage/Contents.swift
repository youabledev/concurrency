import Foundation
import PlaygroundSupport
import UIKit

/// # DispatchGroup의 개념
/// -> 동일한 비동기 작업들을 그룹짓고 각 그룹의 끝을 알고 싶을 때 사용할 수 있음
/// ex) 여러 애니메이션 효과가 겹쳤을 때 애니메이션이 모두 종료된 시점을 알고 싶을 때
/// ex) 스플래쉬(런치 스크린) 애니메이션의 끝남과, 메인 화면에서 필요로 하는 데이터를 모두 다운로드 받는 시점

// 그룹을 생성
let group1 = DispatchGroup()

// async의 group 파라미터로 지정
DispatchQueue.global().async(group: group1) { // 큐로 보낼 때, group1로 지정
    
}

// 그룹으로 묶인 작업이 끝나는 시점을 알려주는 코드
// 이 작업을 어디서 실행할 지 queue로 지정할 수 있음
group1.notify(queue: DispatchQueue.main) { //[weak self] in
//    guard let self = self else { return }
//    self.textLabel.text = "UIKit에서 테스트 하세요!"
}


// ex
// 동시 private queue (어떤 작업이 먼저 끝날 지 알수 없음)
let workingQueue = DispatchQueue(label: "com.concurrent.study", attributes: .concurrent)

let imageUrls = [
    "https://testImageDownload/test1.png",
    "https://testImageDownload/test2.png",
    "https://testImageDownload/test3.png",
    "https://testImageDownload/test4.png",
]

var images = [UIImage]()

func downloadImage(_ urlString: String) -> UIImage {
    sleep(3)
    return UIImage()
}

for url in imageUrls {
    workingQueue.async(group: group1) {
        let image = downloadImage(url)
        images.append(image)
    }
}

// 그룹에 포함되어 있는 테스크가 끝나고 실행할 큐는 global로 지정
let defaultQueue = DispatchQueue.global()
group1.notify(queue: defaultQueue) {
    print("group1 task finished :: \(images)")
}


/// ## 동기적 기다림 (wait 메서드)
/// - 어떤 이유로 그룹의 완료 알림에 비동기적으로 응답할 수 없는 경우
/// - 모든 작업이 완료 될 때까지 현재 대기열을 차단하는 동기적인 방법
/// - 작업이 완료 될 때까지 얼마나 오래 기다릴지 기다리는 시간을 지정하는 선택적 파라미터가 필요. 지정하지 않으면 무제한 대기

group1.wait(timeout: DispatchTime.distantFuture)
// 메인스레드에서 실행 할 경우 블록될 수 있어 앱이 멈춤

if group1.wait(timeout: .now() + 60) == .timedOut {
    print("작업이 60초 안에 종료되지 않음")
    // 작업은 계속 진행되기는 함
}

// 그룹 작업이 다 끝나야만 할 수 있튼 작업이 있는 경우 Wait 메서드를 사용할 수 있음
group1.wait(timeout: DispatchTime.distantFuture)

// wait 메서드는 동기적으로 작동해서 현재의 큐를 block 처리 함
// 그룹 내에서 현재의 큐를 사용하길 원하는 어떤 작업이 있는 경우 deadlock이 발생할 가능성이 있음
