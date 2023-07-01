import Foundation
import PlaygroundSupport
import UIKit

let group1 = DispatchGroup()

func asyncMethod(_ urlString: String, completion: () -> Void) { }

DispatchQueue.global().async(group: group1) {
    // 비동기 함수 호출 -> 다른 큐로 보내서 다른 스레드에서 일하도록 한다
    // 실질적으로 비동기 함수 호출이 끝나는 시점은 내부의 동기 코드가 끝나는 지점이 아님
    
    print("1") // 1번 실행 후 종료
    asyncMethod("test") {
        // 비동기가 끝나고 호출
        sleep(5) // 3번 실행 후 5초 후 해당 코드 종료
    }
    print("2") // 2번 실행 후 종료
} // -> 내부의 비동기 함수가 끝나기 전에 해당 DispatchQueue가 종료되는 것으로 판단함

DispatchQueue.global().async(group: group1) {
    group1.enter() // -> 1개의 입장
    asyncMethod("test2") {
        group1.leave() // -> 1개의 퇴장
        // 입장과 퇴장의 갯수가 맞으면 종료
    }
}
 

/// # 예시코드

let workingQueue = DispatchQueue(label: "com.youable.concurrent", attributes: .concurrent)
let defaultQueue = DispatchQueue.global()

func fetchImage(urlString: String) -> UIImage {
    sleep(4)
    return UIImage()
}

// 비동기 함수 생성
func asyncFunction(_ urlStirng: String, runQueue: DispatchQueue, completionQueue: DispatchQueue, completion: @escaping (UIImage, Error?) -> Void) {
    runQueue.async {
        var error: Error? = .none
        let result = fetchImage(urlString: urlStirng)
        completionQueue.async {
            completion(result, error)
        }
    }
}

// 비동기 디스패치 그룹함수
/// group을 인자로 받음
/// 기존 비동기 함수에서 디스패치 그룹함수를 추가해 줌
func asyncFunctionGroup(_ urlStirng: String, runQueue: DispatchQueue, completionQueue: DispatchQueue, group: DispatchGroup, completion: @escaping (UIImage, Error?) -> Void) {
    group.enter()
    asyncFunction(urlStirng, runQueue: runQueue, completionQueue: completionQueue) { image, error in
        completion(image, error)
        group.leave()
    }
}


let group = DispatchGroup()
let urlStrings = [
    "http://test/test1.png",
    "http://test/test2.png",
    "http://test/test3.png",
    "http://test/test4.png",
    "http://test/test5.png",
    "http://test/test6.png",
]

urlStrings.forEach {
    asyncFunctionGroup($0, runQueue: workingQueue, completionQueue: defaultQueue, group: group) { image, error in
        print(image)
    }
}

group.notify(queue: defaultQueue) {
    print("작업 종료")
}
