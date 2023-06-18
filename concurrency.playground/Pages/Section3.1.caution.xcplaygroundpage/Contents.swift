import Foundation
import PlaygroundSupport

/// 1) 반드시 메인큐에서 처리해야 하는 작업
///     - UI 관련 로직은 main queue에서 처리
///     -

if let url = URL(string: "") {
    URLSession.shared.dataTask(with: url) { _, _, _ in
        // image download
        
        DispatchQueue.main.async {
            // self.imageView.image = image
        }
    }.resume()
}


/// 2) sync 메서드에 대한 주의사항
///     - 메인큐에서 다른 큐로 보낼 때 sync 메서드 호출 x. UI와 관련되지 않은 오래 걸리는 작업은 다른 스레드에서 작업할 수 있도록 비동기(async) 로 실행해야 함
DispatchQueue.global().sync {
    // 메인 스레드에서 sync를 사용하면 이 작업이 끝날 때까지 main thread를 block 시키기 때문에 UI가 멈춤
}

///     - 현재의 큐에서 현재의 큐로 동기적으로 보내면 교착 상태가 발생함

// main thread
DispatchQueue.global().async {
    // thread2 에서 작업
    DispatchQueue.global().sync {
        // 다시 글로벌 큐로 보냄 -> sync 로 보냈기 때문에 thread2에서 해당 태스크는 block 상태가 됨 -> global queue는 해당 태스크를 다시 thread2로 접근하는 경우 -> dead lock
    }
}
// 직렬 큐는 항상 교착상태가 발생할 수 있고, 동시 큐에서는 교착상태 발생 가능성을 내포하고 있음

/// 3) weak, strong 캡쳐 주의
///     - 작업을 보내는 일은 클로져를 보내는 일 -> 객체에 대한 캡쳐 현상이 발생함

DispatchQueue.global(qos: .utility).async { //[weak self] in
//    guard let self = self else { return }
    
    DispatchQueue.main.async {
        // UI update code
    }
}

/// 4) 비동기 작업에서 컴플리션 핸들러의 존재 이유
///     - 작업이 끝나고 실행되어야 하는 작업
///     - 비동기로 작업이 끝나고 나서 변경된 값에 접근해야 할 경우 비동기 작업이 끝났다는 것을 정확히 알려주는 시점이 completionHandler

/// 5) 동기적 함수를 비동기함수처럼 만드는 방법
///     - 여러번 재활용하기 위해

func longTask(_ a: String) -> String {
    print("작업이 오래 걸리는 함수")
    return "ex"
}

/// 기존 함수에서 아래 파라미터를 정의
/// - Parameter runQueue : 직접적으로 작업을 실행할 큐
/// - Parameter completionQueue : 작업을 마치고 나서의 큐
/// - Parameter completion : 컴플리션 핸들러와 에러처리에 대한 내용 필요
func asyncLognTask(_ a: String, runQueue: DispatchQueue, completionQueue: DispatchQueue, completion: @escaping ((String, Error?) -> ())) {
    
    runQueue.async {
        var error: Error?
        error = .none
        let result = ""
        completionQueue.async {
            completion(result, error)
        }
    }
}

//DispatchQueue.global().async { [weak self] in
//    DispatchQueue.main.async {
//    // => 따로 명시하지 않아도 여기서도 weak self로 정의됨
//    }
//}


/// # ARC (Automatic Reference Counting)
///
/// 1) 객체(클래스의 인스턴스)
///     - 변수를 weak, unowned로 선언
///
/// 2) 클로저
///     - strong reference에서 클로저를 실행할 때 RC +1 -> 클로저 실행이 끝나야 RC -1 되어 메모리에서 제거
///     - 클로저의 캡처리스트내에서 weak, unowned로 선언
///
/// => 인스턴스를 참조하되 RC가 올라가지 않게 하므로 강한 참조 사이클이 일어나지 않음
/// +) heap and stack memory
