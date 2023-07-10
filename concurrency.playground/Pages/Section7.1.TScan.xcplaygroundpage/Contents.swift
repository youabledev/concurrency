import Foundation

/// Thread-Safety
/// 여러 스레드를 사용하여 접근하여도 한번에 한개의 스레드만 접근 가능하도록 처리
/// (Lock 코드를 구현해서 처리할 수 있지만 교착상황이 생길 가능성이 높음)
///
/// 1) TSan(티싼 : Thread Sanitizer tool) 잠재적 경쟁 상황 찾는 법
/// - 앱스토어 출시전 경쟁 상황이 생기는 지반드시 해야 할 일
/// - editScheme > Run > Diagnotics > Thread Sanitizer 체크
/// - 경쟁상황 발샐할 수 있는 모든 상황을 xCode가 체크. 빌드 시간이 오래 걸릴 수 있으므로 다 사용 후 체크를 해지 하면 됨

