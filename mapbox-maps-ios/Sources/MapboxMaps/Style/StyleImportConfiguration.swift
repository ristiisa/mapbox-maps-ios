/// Defines the available light presets in the Mapbox Standard Style.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
@_spi(Experimental)
public struct StandardLightPreset: RawRepresentable, Hashable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public static let day = StandardLightPreset(rawValue: "day")
    public static let night = StandardLightPreset(rawValue: "night")
    public static let dusk = StandardLightPreset(rawValue: "dusk")
    public static let dawn = StandardLightPreset(rawValue: "dawn")
}

/// Specifies configuration parameters for style imports.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
@_spi(Experimental)
public struct StyleImportConfiguration: Equatable {
    /// Style import identifier.
    public var importId: String

    /// JSON dictionary of parameters.
    public var config: JSONObject

    /// Creates a configuration.
    /// - Parameters:
    ///   - importId: A style import id to which the configuration will be applied. If not specified, the import configuration will be applied to `basemap` style import (root style).
    ///   - config: Style import configuration parameters.
    public init(importId: String?, config: JSONObject) {
        self.importId = importId ?? "basemap"
        self.config = config
    }

    /// Creates a configuration for the Mapbox Standard Style.
    public static func standard(
        importId: String?,
        lightPreset: StandardLightPreset? = nil,
        font: String? = nil,
        showPointOfInterestLabels: Bool? = nil,
        showTransitLabels: Bool? = nil,
        showPlaceLabels: Bool? = nil,
        showRoadLabels: Bool? = nil
    ) -> StyleImportConfiguration {
        var config = JSONObject()
        if let lightPreset {
            config["lightPreset"] = .string(lightPreset.rawValue)
        }
        if let font {
            config["font"] = .string(font)
        }
        if let showPointOfInterestLabels {
            config["showPointOfInterestLabels"] = .boolean(showPointOfInterestLabels)
        }
        if let showPointOfInterestLabels {
            config["showPointOfInterestLabels"] = .boolean(showPointOfInterestLabels)
        }
        if let showTransitLabels {
            config["showTransitLabels"] = .boolean(showTransitLabels)
        }
        if let showPlaceLabels {
            config["showPlaceLabels"] = .boolean(showPlaceLabels)
        }
        if let showRoadLabels {
            config["showRoadLabels"] = .boolean(showRoadLabels)
        }

        return StyleImportConfiguration(importId: importId, config: config)
    }
}
