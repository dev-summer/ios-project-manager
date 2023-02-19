# 📒 프로젝트 매니저

## 목차
1. [프로젝트 소개](#-프로젝트-소개)
2. [실행 화면](#-실행-화면)
3. [프로젝트 구조](#-프로젝트-구조)
4. [고민한 점](#-고민한-점)
5. [참고 링크](#-참고-링크)

---

## 🪧 프로젝트 소개
프로젝트의 이슈사항을 `TODO`/`DOING`/`DONE`으로 관리하는 아이패드 전용 가로모드 앱입니다.

### 개발환경
[![swift](https://img.shields.io/badge/swift-5.6-orange)]() [![xcode](https://img.shields.io/badge/Xcode-14.2-blue)]() [![iOS](https://img.shields.io/badge/iOS-14.5-green)]()

### 프로젝트 주요 경험

- MVC 구조로 구현 후 MVVM 구조로 리팩토링
- Modern Collection View(Compositional Layout) 활용
- DiffableDataSource 활용
- `UIAction` 활용
- `UIDatePicker`, `DateComponents` 활용
- Dynamic Type Size 적용

---

## 📱 실행 화면

| 앱 메인 화면 | 새로운 이슈 생성 |
| :---: | :---: |
| <img src=https://i.imgur.com/dPI0yKk.png width="300"> | <img src=https://i.imgur.com/XONd38r.png width="300"> |

| 기존 이슈 수정 | 이슈 상태 변경 |
| :---: | :---: |
| <img src=https://i.imgur.com/G7MqjBb.gif width="300"> | <img src=https://i.imgur.com/FFaBiTj.gif width="300"> |

| 스와이프로 이슈 삭제 |
| :---: |
| <img src=https://i.imgur.com/zN4e3Wd.gif width="300"> |

---

## 📂 프로젝트 구조

### File Tree
<img src=https://i.imgur.com/67beFDJ.png width="600">

---

## 🤔 고민한 점

### 1. 메인VC 화면 구성
메인VC의 각 섹션은 하나의 헤더 뷰(`TODO`/`DOING`/`DONE`)와 하나의 컬렉션 뷰로 구성되어 있습니다. 동일한 구조를 가진 세 개의 섹션을 구현하는 방법에 대해 다음의 옵션들을 고민해보았습니다.
- 메인VC에 헤더 뷰 3개, 컬렉션 뷰 3개를 각각 구현
- 헤더 뷰 1개, 컬렉션 뷰 1개를 가지는 `UIView`를 구현하고, 해당 뷰의 인스턴스 3개를 메인VC에 넣기
- 헤더 뷰 1개, 컬렉션 뷰 1개를 가지는 `UIViewController`를 구현하고, 해당 뷰컨트롤러의 인스턴스 3개를 메인VC에 child VC로 넣기

세 가지 방법 중에서, **3번째 방법**을 선택했습니다. 그 이유는 다음과 같습니다.
- 첫 번째 방법을 선택할 경우, 메인VC의 역할이 지나치게 많아질 수 있다고 생각했습니다.
- 현재 프로젝트 요구사항에는 없지만, 나중에 동일한 구성의 화면을 재사용해야 할 경우가 생겼을 때 재사용성이 좋기 때문입니다.
<img src=https://i.imgur.com/UyCPuok.png width="400">

### 2. 테이블 뷰 vs 컬렉션 뷰
리스트 형태의 화면을 구현하기 위해 테이블 뷰와 컬렉션 뷰 중 컬렉션 뷰를 사용했습니다. 컬렉션 뷰를 사용한 이유는 추후 리스트 형태가 아닌 다른 레이아웃을 추가/변경하고 싶을 경우 더 유연하게 대응할 수 있기 때문입니다.
요구사항의 `trailingSwipeAction`은 리스트 형태의 레이아웃에서만 지원되기 때문에, `CompositionalLayout.list` 레이아웃을 사용한 컬렉션 뷰를 사용했습니다.

---

## 📎 참고 링크
1. UICollectionViewListCell swipe action
    - [공식문서 - trailingswipeactionconfiguration](https://developer.apple.com/documentation/uikit/uicollectionlayoutlistconfiguration/3650483-trailingswipeactionsconfiguratio)
    - [구현 예제 - DonnyWals Blog](https://www.donnywals.com/how-to-add-custom-swipe-actions-to-a-uicollectionviewlistcell/)
2. UITextField에 padding 주기
    - [Advanced Swift - bound와 inset 활용](https://www.advancedswift.com/uitextfield-with-padding-swift/)
3. UITextField, UITextView에 그림자 넣기
    - 차이점: UITextView의 경우 `clipToBounds = false`를 해줘야 한다!
    - [StackOverflow: UITextFIeld shadow](https://stackoverflow.com/questions/46562752/how-to-add-shadow-on-uitextfield-with-round-corners)
    - [StackOverflow: UITextView shadow](https://stackoverflow.com/questions/34104004/how-to-apply-a-shadow-to-a-uitextview-in-swift)
4. Date()에서 시간 버리고 일/월/년만 가져오기 (DateComponents)
    - dateComponents를 가지고 만든 Calendar.date의 경우 반환값이 옵셔널(`Date?`)이다
    - [StackOverflow - date without time](https://stackoverflow.com/questions/55688517/ios-swift-date-without-time)
    - [NamS 블로그](https://nsios.tistory.com/18)
    - [dateComponents(_: from: to:)](https://www.globalnerdy.com/2020/05/28/how-to-work-with-dates-and-times-in-swift-5-part-3-date-arithmetic/)
5. target-action 대신 UIAction 사용해보기
    - [공식문서 - UIAction](https://developer.apple.com/documentation/uikit/uiaction)
    - [Medium: UIAction closure based UIControl](https://medium.com/doyeona/uibutton-swift-uiaction-closure-based-uicontrol-ios-14-405e255a7640)
    - [공식문서 - BarButtonItem 이니셜라이저 중 UIAction을 인자로 받는 이니셜라이저](https://developer.apple.com/documentation/uikit/uibarbuttonitem/3600776-init)
6. Long Press Gesture
    - [StackOverflow: LongPressGestureRecognizer](https://stackoverflow.com/questions/28058082/swift-long-press-gesture-recognizer-detect-taps-and-long-press)
    - [StackOverflow: CollectionView get indexPath by longPressCell](https://stackoverflow.com/questions/56459262/swift-5-collectionview-get-indexpath-by-longpress-cell)
7. 팝오버 구현하기
    - [공식문서 - Displaying transient content in a popover -](https://developer.apple.com/documentation/uikit/windows_and_screens/displaying_transient_content_in_a_popover)
    - [StackOverflow: collectionView + long press gesture + delete cell](https://stackoverflow.com/questions/49264664/long-press-gesture-action-sheet-delete-cell)
    - [presentation controllers tutorial](https://www.appcoda.com/presentation-controllers-tutorial/)
8. 컬렉션뷰의 DiffableDatasource에서 데이터 삭제하기
    - [구현 예제 - collection view + diffable datasource 에서 선택한 셀의 데이터 삭제하기](https://gist.github.com/nurtugan/18cacdbfdc5aa69a3eada20282fe57aa)
9. 컬렉션뷰에서 셀 선택했을 때 색칠 안되게 하기
    - [guide-to-cell-background-configuration-in-ios-14](https://www.biteinteractive.com/the-developers-guide-to-cell-background-configuration-in-ios-14/)
    - [공식문서 - backgroundConfiguration](https://developer.apple.com/documentation/uikit/uicollectionviewcell/3600947-backgroundconfiguration)
10. UIDatePicker
    - [uikit-date-picker](https://kasroid.github.io/posts/ios/20201030-uikit-date-picker/)
11. Nested VC (child view controller)
    - [avoiding-massive-view-controller-using-containment-view-controller](https://www.alfianlosari.com/posts/avoiding-massive-view-controller-using-containment-view-controller/)
    - [building-complex-screens-with-child-viewcontrollers](https://swiftwithmajid.com/2019/02/27/building-complex-screens-with-child-viewcontrollers/)
    - [managing-view-controllers-with-container-view-controllers](https://cocoacasts.com/managing-view-controllers-with-container-view-controllers/)
    - [공식문서 - ImplementingaContainerViewController](https://developer.apple.com/library/archive/featuredarticles/ViewControllerPGforiPhoneOS/ImplementingaContainerViewController.html#//apple_ref/doc/uid/TP40007457-CH11-SW1)
    - [the-power-of-child-viewcontrollers-in-ios](https://medium.com/@sergkharauzov/the-power-of-child-viewcontrollers-in-ios-da3d58f5a9fe)
