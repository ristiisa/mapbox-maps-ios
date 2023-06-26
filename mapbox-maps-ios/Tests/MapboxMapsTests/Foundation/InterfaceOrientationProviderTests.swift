import Foundation
@testable import MapboxMaps
import XCTest

final class DefaultInterfaceOrientationProviderTests: XCTestCase {
    var notificationCenter: MockNotificationCenter!
    var device: MockUIDevice!
    var orientationProvider: DefaultInterfaceOrientationProvider!
    @MutableRef var userInterfaceOrientationView: UIView?

    override func setUp() {
        super.setUp()

        notificationCenter = MockNotificationCenter()
        device = MockUIDevice()
        orientationProvider = DefaultInterfaceOrientationProvider(
            userInterfaceOrientationView: $userInterfaceOrientationView,
            notificationCenter: notificationCenter,
            device: device)
    }

    override func tearDown() {
        super.tearDown()

        notificationCenter = nil
        device = nil
        orientationProvider = nil
        userInterfaceOrientationView = nil
    }

    func testOrientationIsTakenFromWindowSceneOrDevice() throws {
        // given
        let deviceOrientation = UIDeviceOrientation.portraitUpsideDown
        device.$orientation.getStub.defaultReturnValue = deviceOrientation

        let view = UIView()
        let window = UIWindow()
        let viewController = UIViewController()
        viewController.view.addSubview(view)
        userInterfaceOrientationView = view
        window.rootViewController = viewController
        window.makeKeyAndVisible()

        // when
        let orientation = orientationProvider.interfaceOrientation

        // then
        if #available(iOS 13, *) {
            // the default value for iOS 13+ is .unknown, otherwise the orientation is taken from the window scene
            XCTAssertNotNil(view.window?.windowScene?.interfaceOrientation)
            XCTAssertEqual(orientation, view.window?.windowScene?.interfaceOrientation)
        } else {
            // on iOS 12 the orientation is taken from UIDevice.orientation
            XCTAssertEqual(orientation, UIInterfaceOrientation(deviceOrientation: deviceOrientation))
        }
    }

    func testBeginGeneratingDeviceOrientationNotificationsIsCalledWhenUpdating() {
        // when
        let token = orientationProvider.onInterfaceOrientationChange.observe { _ in }

        XCTAssertEqual(device.beginGeneratingDeviceOrientationNotificationsStub.invocations.count, 1)
        XCTAssertEqual(device.endGeneratingDeviceOrientationNotificationsStub.invocations.count, 0)
        _ = token
    }

    func testEndGeneratingDeviceOrientationNotificationsIsCalledWhenNotUpdating() {
        // when
        do {
            _ =  orientationProvider.onInterfaceOrientationChange.observe { _ in }
        }

        // then
        XCTAssertEqual(device.beginGeneratingDeviceOrientationNotificationsStub.invocations.count, 1)
        XCTAssertEqual(device.endGeneratingDeviceOrientationNotificationsStub.invocations.count, 1)
    }

    func testDeviceOrientationDidChangeSubscribedWhenUpdating() {
        // when
        let token = orientationProvider.onInterfaceOrientationChange.observe { _ in }

        // then
        XCTAssertEqual(notificationCenter.addObserverStub.invocations.count, 1)
        XCTAssertIdentical(notificationCenter.addObserverStub.invocations.first?.parameters.observer as? AnyObject, orientationProvider)
        XCTAssertEqual(notificationCenter.addObserverStub.invocations.first?.parameters.name, UIDevice.orientationDidChangeNotification)
        _ = token
    }

    func testDeviceOrientationDidChangeUnsubscribedWhenInactive() {
        // when
        _ = orientationProvider.onInterfaceOrientationChange.observe { _ in }

        // then
        XCTAssertEqual(notificationCenter.removeObserverStub.invocations.count, 1)
        XCTAssertIdentical(notificationCenter.removeObserverStub.invocations.first?.parameters.observer as? AnyObject, orientationProvider)
        XCTAssertEqual(notificationCenter.removeObserverStub.invocations.first?.parameters.name, UIDevice.orientationDidChangeNotification)
    }

    func testHeadingOrientationIsUpdatedWhenDeviceOrientationDidChange() {
        // given
        @Stubbed var orientation: UIInterfaceOrientation?
        let token = orientationProvider.onInterfaceOrientationChange.observe { orientation = $0 }
        $orientation.setStub.reset()

        // when
        notificationCenter.post(name: UIDevice.orientationDidChangeNotification, object: nil)

        // then
        XCTAssertEqual($orientation.setStub.invocations.count, 1)
        _ = token
    }
}
