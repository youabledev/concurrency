import UIKit
/// # GCD와 Operation의 차이
/// 1. GCD
/// - 간단한 일
/// - 함수를 사용하는 작업
///
/// 2. Operation
/// - GCD를 기반으로 구현 되어 있음
/// - (진행하고 있는 일의 )취소나 순서 지정, 일시 중지와 같은 기능을 사용할 수 있음
/// - 데이터와 기능을 캡슐화한 객체
///
/// # 언제 Operation이 필요할까?
/// - 이미지 다운로드 작업을 취소하고 싶을 때 Operation Queue를 사용할 수 있음 (진행하고 있는 일을 취소)

/// 작업 자체가 클래스가 되어 인스턴스를 이용. Operation -> 어떤 단위적인 작업을 클래스화 하여 기능을 높임.클래스로 만들면 재사용성이 증가 함
/// 기본적으로 동기로 설정 됨
/// 인스턴스화 -> 작업은 한번만 실행 가능. 여러번 원하는 경우 객체를 다시 생성해야 함
/// 취소, 순서 지정(의존성), 상태 체크(state machine), KVO notifications, Qos 수준(우선 순위 가능), completion block 제공(작업 이후의 작업을 설정 가능. 이 기능이 기본적으로 가지고 있음)
/// start() method : 오퍼레이션 시작 메소드
/// cancel() mehtod : 작업 취소 가능
/// 상태 체크 위한 bool 값 변수 : isReady, isExecuting, isCancelled, isFinished (오퍼레이션 큐가 상태를 체크하고 관리)
///
/// Operation Queue를 상속 받으면 input, output, main()을 오버라이드 해서 사용

class TestOperation: Operation {
    var inputImage: UIImage?
    var outputImage: UIImage?
    
    override func main() {
        
    }
}

let inputImage = UIImage(named: "")

let tsOp = TestOperation()
tsOp.inputImage = inputImage

tsOp.start() // 오퍼레이션 큐에 넣지 않고 start*(메서드로 실행 시킬 수 있음

