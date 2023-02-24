import SwiftUI
import Turf
@_spi(Experimental) import MapboxMapsSwiftUI

extension Point: Identifiable {
    public var id: String { "\(coordinates)" }
}

@available(iOS 14.0, *)
struct ViewAnnotationsExample: View {
    @State var camera = CameraState(center: .helsinki, zoom: 5)
    @State var points: [Point] = []
    @State var allowOverlap: Bool = false
    @State var anchor: ViewAnnotationAnchor = .bottom

    var body: some View {
        MapReader { proxy in
            Map(camera: $camera, annotationItems: points) { point in
                ViewAnnotation(
                    point.coordinates,
                    size: CGSize(width: 150, height: 50),
                    allowOverlap: allowOverlap,
                    anchor: anchor
                ) {
                    ViewAnnotationContent(point: point, anchor: anchor) {
                        points.removeAll(where: { $0 == point })
                    }
                }
            }
            .styleURI(.streets, darkMode: .dark)
            .onMapTapGesture { point in
                guard let map = proxy.map else { return }

                let coordinate = map.coordinate(for: point)
                points.append(Point(coordinate))
            }
            .ignoresSafeArea(edges: [.leading, .trailing, .bottom])
            .safeOverlay(alignment: .bottom) {
                VStack(spacing: 10) {
                    Toggle("Allow overlap", isOn: $allowOverlap)
                    HStack {
                        Text("Anchor")
                        Spacer()
                        Picker("Anchor", selection: $anchor) {
                            Text("Bottom").tag(ViewAnnotationAnchor.bottom)
                            Text("Center").tag(ViewAnnotationAnchor.center)
                            Text("Top").tag(ViewAnnotationAnchor.top)
                            Text("Left").tag(ViewAnnotationAnchor.left)
                            Text("Right").tag(ViewAnnotationAnchor.right)
                        }.pickerStyle(.segmented)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .floating(RoundedRectangle(cornerRadius: 10))
                .padding(.bottom, 30)
            }
        }
    }
}

@available(iOS 14.0, *)
private struct ViewAnnotationContent: View {
    var point: Point
    var anchor: ViewAnnotationAnchor
    var onRemove: () -> Void

    @State var appeared = false

    var body: some View {
        VStack {
            if anchor == .bottom {
                Spacer()
            }
            let latlon = String(format: "%.2f, %.2f", point.coordinates.latitude, point.coordinates.longitude)
            HStack(alignment: .firstTextBaseline) {
                Text("(\(latlon))")
                    .font(.safeMonospaced)
                Image(systemName: "clear.fill")
                    .onTapGesture(perform: onRemove)
            }
            .padding(5)
            .background(Color.blue)
            .foregroundColor(.white)
            .fixedSize() // Allows annotation to grow out of specified size.
            .opacity(appeared ? 1 : 0)
            .scaleEffect(appeared ? 1 : 0.2)
            .animation(.spring(), value: appeared)
            if anchor == .top {
                Spacer()
            }
        }.onAppear {
            appeared = true
        }
    }
}

@available(iOS 14.0, *)
struct ViewAnnotationsExample_Previews: PreviewProvider {
    static var previews: some View {
        ViewAnnotationsExample()
    }
}
