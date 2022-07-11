import CoreGraphics
import CoreLocation

internal final class PanZoomPinchBehavior: PinchBehavior {
    private let initialCameraState: CameraState
    private let initialPinchMidpoint: CGPoint
    private let mapboxMap: MapboxMapProtocol

    internal init(initialCameraState: CameraState,
                  initialPinchMidpoint: CGPoint,
                  mapboxMap: MapboxMapProtocol) {
        self.initialCameraState = initialCameraState
        self.initialPinchMidpoint = initialPinchMidpoint
        self.mapboxMap = mapboxMap
    }

    internal func update(pinchMidpoint: CGPoint, pinchScale: CGFloat, handler: RotateGestureHandler) {
        mapboxMap.performWithoutNotifying {
            mapboxMap.setCamera(
                to: CameraOptions(
                    center: initialCameraState.center,
                    zoom: initialCameraState.zoom,
                    bearing: initialCameraState.bearing))
            print("rrr reset bearing to \(initialCameraState.bearing)")
            mapboxMap.dragStart(for: initialPinchMidpoint)
            let dragOptions = mapboxMap.dragCameraOptions(
                from: initialPinchMidpoint,
                to: pinchMidpoint)
            mapboxMap.setCamera(to: dragOptions)
            mapboxMap.dragEnd()
        }

        let zoomIncrement = log2(pinchScale)
        mapboxMap.setCamera(to: CameraOptions(
            anchor: pinchMidpoint,
            zoom: initialCameraState.zoom + zoomIncrement))
    }
}
