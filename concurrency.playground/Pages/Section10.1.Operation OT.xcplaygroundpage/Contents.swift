import Foundation

/// # GCD와 Operation의 차이
/// 1. GCD
/// - 간단한 일
/// - 함수를 사용하는 작업
///
/// 2. Operation
/// - GCD를 기반으로
/// - 취소나 순서 지정, 일시 중지와 같은 기능을 사용할 수 있음
/// - 데이터와 기능을 캡슐화한 객체
///
/// # 언제 Operation이 필요할까?
/// - 이미지 다운로드 작업을 취소하고 싶을 때 Operation Queue를 사용할 수 있음 (진행하고 있는 일을 취소)
