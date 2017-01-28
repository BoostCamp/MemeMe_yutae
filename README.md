#### MemeMe 프로젝트 최 유 태 (yutae)
------------------------------

[![MemeMe Video](https://cloud.githubusercontent.com/assets/14192093/22397102/49ab6f52-e5ad-11e6-93f1-2515538541d6.png)](https://youtu.be/qTB7BmKDdQo "MemeMe Video")
#### ( 위의 사진을 클릭 하시면 Youtube 로 연결됩니다. BGM 있습니다. )
## 추가 기능
#### iOS 기본 어플 사진 앱과의 연동
+ MemeMe 작업한 사진을 "MemeMe" 앨범에 저장
+ 사진 앱과의 동기화 : 사진 앱에서 변경된 사항(저장, 삭제) 존재 할때 MemeMe 앱도 변경
+ Photo Editing Extension Framework - 사진 앱 자체에서 MemeMe 앱을 사용하여 편집 기능

## 예외 처리 및 기술
+ Alert 활용 - 앨범에 등록된 사진이 없을 경우, 사진 또는 카메라 접근 권한이 없을 경우 등
+ Project Structure - 프로젝트 구조화 (Extension, Models, Views,  Controller, Resources)
+ Pattern - Identifier, Wildcard, Delegation, MVC, Singleton
+ Navigation Controller, Modal Controller, Tab Bar Controller
+ UIKit Extension - Theme Color, Date Format
+ Human Interface Guidelines - Navigation Bar item의 이미지 크기, Share Button 가운데 위치 등을 따름
+ Photos Framework - PHObject, PHAsset, PHAssetCollection 등을 활용하여 사진 앱과의 연동
+ PHPhotoLibraryChangeObserver - 사진 앱과의 동기화에 활용
+ PhotosUI - Photo Editing Extension Frameworks 활용하여 MemeMe 앱을 사용하여 편집 기능
+ iOS available 8.0, * - AlertView, openURL/open 등 구별하여 iOS 8.0 이상부터 호환 (8.1 TEST 완료)
+ Data Manager - Singleton Pattern 활용하여 meme 구조체 데이터 관리, PHAsset, PHAssetCollection 관리
+ Constants - struct 를 활용하여 자주 사용되는 property들을 모듈화 하여 static 상수로 메모리 Heap 부분에 Load
+ AppModel - struct 를 활용하여 자주 사용되는 Method들을 모듈화 하여 static 메소드로 메모리 Heap 부분에 Load
+ GCD(Grand Central Dispatch) - Photo Editing Extension 변경된 사진을 Background Thread 비동기 처리 적용, UI 변경은 Main Thread 비동기 처리 적용 등
+ Custom Completion Closer - Custom 함수 작업이 종료 후 Completion Handler 적용 등
+ Apple 기본으로 제공하는 여러 Delegate 사용
+ Custom Delegation - 즐겨찾기를 변경했을 때 Delegation 패턴 활용하여 바뀐 값 전달
+ NotificationCenter - 키보드 Show, Hide 상황에 대한 일부 UI 변경
+ 3D Touch - Detail View 를 3D Touch 효과로 미리보기
+ UserDefaults - FontName을 UserDefaults 활용하여 기본 DB에 기록
+ State Restoration - Editor View의 Textfield Text를 encode, decode ( 앱이 Background 상황일때 기기 메모리 용량 초과로 운영체제가 앱 종료에 대비 )
+ Optional Binding - Optional Variable & Optional Object Manager
+ Optional Chaining, Optional guard else 문 활용
+ Git Branch 전략 - master, developer, feature
