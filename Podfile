source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '10.0'
use_frameworks!

inhibit_all_warnings!

target 'FairInterviewApp' do

  # Swift pods
  pod 'SwiftyJSON'
  pod 'RxSwift'
  pod 'RxDataSources'
  pod 'RxCocoa'
  pod 'NSObject+Rx'
  pod 'Moya/RxSwift', '= 8.0.0-beta.4'
  pod 'PureLayout'

  target 'FairInterviewAppTests' do
    inherit! :search_paths

    pod 'FBSnapshotTestCase'
    pod 'Nimble-Snapshots'
    pod 'Quick'
    pod 'Nimble'
    pod 'Forgeries'
    pod 'RxBlocking'

  end
end
