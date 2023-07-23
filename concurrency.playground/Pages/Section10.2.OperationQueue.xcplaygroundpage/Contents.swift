import UIKit
import Foundation

/// 특징 1 : 몇 개의 스레드를 사용할 것인지 설정 가능
/// default는 -1(시스템이 알아서 스레드의 갯수를 관리함). maxConcurrentOperationCount = 2 (두개의 스레드를 사용하겠다는 뜻)
///
/// 특징 2 : 기본적인 서비스 품질은 background로 설정되어 있으며 변경 가능함
/// userInteractive, userInitiated, default, utility, background
/// 오퍼레이션의 품질을 높게 설정하면 queue의 품질또한 승격될 수 잇음
/// but 가장 앞서서, underlying dispatchQeueue까지 설정 가능하기 때문에 DispatchQeueue의 품질을 가장 우선적으로 적용 함
///
/// 특징3 : 오퍼레이션을 오퍼레이션 큐에 넣어 스레드에 배정되었을 때 isExecuting 상태가 됨. 클래스의 인스턴스가 생성될 때에는 isReady 상태
///
/// 특징4 : 오퍼레이션이 한번 실행되거나 취소되면 오퍼레이션 큐에서 사라짐
///
/// 특징5 : 동기적으로 기다리는 메서드 waitUntilAllOperationsAreFinished() 오퍼레이션 큐에 있는 오퍼레이션이 모두 끝날 때까지 기다림
///
/// 특징6 : 일시중지-재캐 가능
/// isSuspended = true/false 로 설정 가능
class TestOperation: Operation {
    override func main() { }
}
let someQueue = OperationQueue()
let opreation = TestOperation()

// 오퍼레이션 보냄 (start는 동기, oprationQueue에 전달하는 순간은 비동기적으로 동작함)
someQueue.addOperation(opreation)
// addOprations를 통해 배열 전달 가능
someQueue.addOperations([opreation], waitUntilFinished: true) // waitUntilFinished true는 작업 들이 끝날 때까지 동기적으로 기다린다는 뜻

// test
let printerQueue = OperationQueue()
printerQueue.maxConcurrentOperationCount = 4 // 오퍼레이션 큐에 생성할 수 있는 스레드는 4개, 1로 설정하면 시리얼 처럼 동작(순서대로)

// 동시적(비 동기적)으로 실행되기 때문에 어떤 작업이 먼저 실행 될지는 알수 없음
printerQueue.addOperation {
    print("오퍼레이션으로 클로저를 전달 할 수 있음")
}


/// 실습
let images = Array(repeating: UIImage, count: 10)
var filteredImages = [UIImage]()

/// 처리해야 할  Opration을 넣을 큐
let filterQueue = OperationQueue()
/// 동시성 문제 해결을 위한 serial queue
let appendQueue = OperationQueue()
appendQueue.maxConcurrentOperationCount = 1 // 시리얼로 동작

class FilterOperation: Opreation {
    var inputImage: UIImage?
    var outputImage: UIImage?
    override func main() { }
}

for image in images {
    let filterOpration = FilterOperation()
    filterOpration.inputImage = image
    
    filterOpration.completionBlock = {
        guard let output = filterOpration.outputImage else { return }
        appendQueue.addOperation {
            filteredImages.append(output)
        }
    }
    
    filterQueue.addOperation(filterOpration)
}

filterQueue.waitUntilAllOperationsAreFinished() // main thread에서 이런 작업은 하지 않도록 DispatchQueue.global 에서 지정해 줌
