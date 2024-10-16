//
//  ViewController.swift
//  Sphere Test
//
//  Created by กมลภพ จารุจิตต์ on 3/12/2564 BE.
//

import UIKit
import SphereSDK
import CoreLocation
import SystemConfiguration

protocol MenuDelegate {
    func selectLanguage()
    func setBaseLayer()
    func addLayer()
    func removeTrafficLayer()
    func removeLayer()
    func clearAllLayer()
    func addEventsAndCameras()
    func removeEventsAndCameras()
    func addWMSLayer()
    func addTMSLayer()
    func addWTMSLayer()
    func enableFilter()
    func addURLMarker()
    func addHTMLMarker()
    func addRotateMarker()
    func addSpherePlace()
    func removeMarker()
    func markerList()
    func markerCount()
    func clearAllOverlays()
    func addPopup()
    func addCustomPopup()
    func addHTMLPopup()
    func removePopup()
    func moveMarker()
    func rotateMarker()
    func addLocalTag()
    func addSphereTag()
    func addTagWithOption()
    func removeTag()
    func clearAllTag()
    func addLine()
    func removeLine()
    func addLineWithOption()
    func addDashLine()
    func addPolygon()
    func addCircle()
    func addDot()
    func addDonut()
    func addRectangle()
    func geometryLocation()
    func getRoute()
    func autoReroute()
    func getRouteByCost()
    func getRouteByDistance()
    func getRouteWithoutTollway()
    func getRouteWithMotorcycle()
    func getRouteGuide()
    func clearRoute()
    func searchCentral()
    func searchInEnglish()
    func suggestCentral()
    func clearSearch()
    func getGeoCode()
    func getLatitudeLength()
    func locationEvent()
    func zoomEvent()
    func zoomRangeEvent()
//    func readyEvent()
    func resizeEvent()
    func clickEvent()
    func dragEvent()
    func dropEvent()
    func layerChangeEvent()
    func overlayClickEvent()
    func overlayChangeEvent()
    func overlayDropEvent()
    func setCustomLocation()
    func setGeoLocation()
    func getLocation()
    func setZoom()
    func setLocationAndZoom()
    func setRotate()
    func setPitch()
    func zoomIn()
    func zoomOut()
    func setZoomRange()
    func getZoomRange()
    func setBound()
    func getBound()
    func toggleDPad()
    func toggleZoombar()
    func toggleLayerSelector()
    func toggleCrosshair()
    func toggleScale()
    func toggleTouchAndDrag()
    func toggleDrag()
    func getOverlayType()
    func getDistance()
    func getContain()
    func nearPOI()
    func addHeatMap()
    func addClusterMarker()
    func add3DObject()
}

class ViewController: UIViewController, MenuDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var map: Sphere!
    @IBOutlet weak var displayTextField: UITextField!
    let locationManager = CLLocationManager()
    var loc = CLLocationCoordinate2D(latitude: 13.7, longitude: 100.5)
    var trackLocation = false
    var currentLocationMarker: Sphere.SphereObject?
    var home: Sphere.SphereObject?
    var marker: Sphere.SphereObject?
    var layer: Sphere.SphereObject?
    var popup: Sphere.SphereObject?
    var geom: Sphere.SphereObject?
    var object: Sphere.SphereObject?
    var searchPoi: [Sphere.SphereObject] = []
    var moveTimer: Timer?
    var rotateTimer: Timer?
    var followPathTimer: Timer?
    var guideTimer: Timer?
    var currentMethod: String?

    override func viewDidLoad() {
        super.viewDidLoad()
#warning("Please insert your Sphere API key.")
        map.apiKey = ""
        map.options.layer = map.createSphereStatic("Layers", with: "STREETS")
        map.options.location = loc
        map.options.zoomRange = 1...18
        map.options.zoom = 10
        locationManager.delegate = self
        readyEvent()
        map.render()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        if currentMethod == "location" {
            if currentLocationMarker == nil, let img = UIImage(named: "location.north.circle.fill") {
                self.currentLocationMarker = self.map.createSphereObject("Marker", with: [
                    location.coordinate,
                    [
                        "title": "Marker",
                        "icon": [
                            "url": img,
                            "size": CGSizeMake(24, 24)
                        ]
                    ]
                ])
                let _ = self.map.call(method: "Overlays.add", args: [self.currentLocationMarker!])
            }
            else {
                let _ = self.map.objectCall(sphereObject: self.currentLocationMarker!, method: "move", args: [
                    location.coordinate,
                    true
                ])
            }
            if trackLocation {
                trackLocation = false
                let _ = self.map.call(method: "goTo", args: [[
                    "center": location.coordinate,
                    "zoom": 14
                ]])
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if currentLocationMarker != nil {
            let _ = map.objectCall(sphereObject: currentLocationMarker!, method: "update", args: [
                ["rotate": newHeading.trueHeading >= 0 ? newHeading.trueHeading : newHeading.magneticHeading]
            ])
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    @IBAction func selectMenu() {
        performSegue(withIdentifier: "menu", sender: nil)
    }
    
    @IBAction func clearAll() {
        let _ = map.call(method: "Layers.setBase", args: [map.createSphereStatic("Layers", with: "STREETS")])
        let _ = map.call(method: "language", args: [SphereLocale.Thai])
        let _ = map.call(method: "Ui.Mouse.enableDrag", args: [true])
        let _ = map.call(method: "zoomRange", args: [1...18])
        let _ = map.call(method: "rotate", args: [0, true])
        let _ = map.call(method: "pitch", args: [0])
        let _ = map.call(method: "enableFilter", args: [
            map.createSphereStatic("Filter", with: "None")
        ])
        map.isUserInteractionEnabled = true
        displayTextField.isHidden = true
        displayTextField.text = ""
        clearAllLayer()
        clearAllOverlays()
        clearAllTag()
        removeEventsAndCameras()
        clearRoute()
        unbind()
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
        currentLocationMarker = nil
    }
    
    func alert(message: String, placeholder: String?, completionHandler: ((String) -> Void)?) {
        let alert = UIAlertController(
            title: NSLocalizedString("Sphere", comment: ""),
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: NSLocalizedString("OK", comment: ""),
            style: .default
        ) { action -> Void in
            if let c = completionHandler {
                let firstTextField = alert.textFields!.first
                c(firstTextField?.text ?? "")
            }
        })
        if let p = placeholder {
            alert.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = p
            }
        }
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Map Layers
    func selectLanguage() {
        let _ = map.call(method: "language", args: [SphereLocale.English])
    }
    
    func setBaseLayer() {
        let _ = map.call(method: "Layers.setBase", args: [map.createSphereStatic("Layers", with: "HYBRID")])
        
        let _ = self.map.call(method: "goTo", args: [[
            "center": CLLocationCoordinate2D(latitude: 13.7, longitude: 100.5),
            "zoom": 10
        ]])
    }
    
    func addLayer() {
        if isConnectedToNetwork() {
            let _ = map.call(method: "Layers.add", args: [map.createSphereStatic("Layers", with: "TRAFFIC")])
            
            let _ = self.map.call(method: "goTo", args: [[
                "center": CLLocationCoordinate2D(latitude: 13.7, longitude: 100.5),
                "zoom": 10
            ]])
        }
    }
    
    func removeTrafficLayer() {
        let _ = map.call(method: "Layers.remove", args: [map.createSphereStatic("Layers", with: "TRAFFIC")])
    }
    
    func clearAllLayer() {
        let _ = map.call(method: "Layers.clear", args: nil)
    }
    
    func addEventsAndCameras() {
        if isConnectedToNetwork() {
            let _ = map.call(method: "Overlays.load", args: [map.createSphereStatic("Overlays", with: "events")])
            let _ = map.call(method: "Overlays.load", args: [map.createSphereStatic("Overlays", with: "cameras")])
            
            let _ = self.map.call(method: "goTo", args: [[
                "center": CLLocationCoordinate2D(latitude: 13.71, longitude: 100.53),
                "zoom": 12
            ]])
        }
    }
    
    func removeEventsAndCameras() {
        let _ = map.call(method: "Overlays.unload", args: [map.createSphereStatic("Overlays", with: "events")])
        let _ = map.call(method: "Overlays.unload", args: [map.createSphereStatic("Overlays", with: "cameras")])
    }
    
    func addWMSLayer() {
        if isConnectedToNetwork() {
            layer = map.createSphereObject("Layer", with: [
                "bluemarble_terrain",
                [
                    "type": map.createSphereStatic("LayerType", with: "WMS"),
                    "url": "https://ms.longdo.com/mapproxy/service",
                    "zoomRange": 1...9,
                    "refresh": 180,
                    "opacity": 0.5,
                    "weight": 10,
                    "bound": [
                        "minLon": 100,
                        "minLat": 10,
                        "maxLon": 105,
                        "maxLat": 20
                    ]
                ]
            ])
            let _ = map.call(method: "Layers.add", args: [layer!])
            
            let _ = self.map.call(method: "goTo", args: [[
                "center": CLLocationCoordinate2D(latitude: 13.7, longitude: 100.5),
                "zoom": 8
            ]])
        }
    }
    
    func addTMSLayer() {
        if isConnectedToNetwork() {
            layer = map.createSphereObject("Layer", with: [
                "",
                [
                    "type": map.createSphereStatic("LayerType", with: "TMS"),
                    "url": "https://ms.longdo.com/mapproxy/tms/1.0.0/bluemarble_terrain/EPSG3857",
                    "bound": [
                        "minLon": 100.122195,
                        "minLat": 14.249463,
                        "maxLon": 100.533496,
                        "maxLat": 14.480279
                    ]
                ]
            ])
            let _ = map.call(method: "Layers.add", args: [layer!])
            
            let _ = self.map.call(method: "goTo", args: [[
                "center": CLLocationCoordinate2D(latitude: 14.35, longitude: 100.3),
                "zoom": 7
            ]])
        }
    }
    
    func addWTMSLayer() {
        if isConnectedToNetwork() {
            layer = map.createSphereObject("Layer", with: [
                "bluemarble_terrain",
                [
                    "type": map.createSphereStatic("LayerType", with: "WMTS_REST"),
                    "url": "https://ms.longdo.com/mapproxy/wmts",
                    "srs": "GLOBAL_WEBMERCATOR",
                ]
            ])
            let _ = map.call(method: "Layers.add", args: [layer!])
            
            let _ = self.map.call(method: "goTo", args: [[
                "center": CLLocationCoordinate2D(latitude: 14.35, longitude: 100.3),
                "zoom": 10
            ]])
        }
    }
    
    func enableFilter() {
        let _ = map.call(method: "enableFilter", args: [
            map.createSphereStatic("Filter", with: "Dark")
        ])
    }
    
    func removeLayer() {
        if let l = layer {
            let _ = map.call(method: "Layers.remove", args: [l])
        }
    }
    
    // MARK: - Marker
    func addURLMarker() {
        DispatchQueue.main.async {
            self.marker = self.map.createSphereObject("Marker", with: [
                CLLocationCoordinate2D(latitude: 12.8, longitude: 101.2),
                [
                    "title": "Marker",
                    "icon": [
                        "url": UIImage(named: "pin_mark") ?? "https://map.longdo.com/mmmap/images/pin_mark.png",
                        "offset": [
                            "x": 12,
                            "y": 45
                        ]
                    ],
                    "detail": "Drag me",
                    "visibleRange": 7...9,
                    "draggable": true
                ]
            ])
            let _ = self.map.call(method: "Overlays.add", args: [self.marker!])
            
            let _ = self.map.call(method: "goTo", args: [[
                "center": CLLocationCoordinate2D(latitude: 12.8, longitude: 101.2),
                "zoom": 8
            ]])
        }
    }
    
    func addHTMLMarker() {
        marker = map.createSphereObject("Marker", with: [
            CLLocationCoordinate2D(latitude: 14.25, longitude: 99.35),
            [
                "title": "Custom Marker",
                "icon": [
                    "html": "<div style=\"font-size: 36px; border: 1px solid #000;\">♨</div>",
                    "offset": [
                        "x": 0,
                        "y": 0
                    ]
                ],
                "popup": [
                    "html": "<div style=\"font-size: 24px; background: #eef;\">Onsen</div>"
                ]
            ]
        ])
        let _ = map.call(method: "Overlays.add", args: [marker!])
        
        let _ = self.map.call(method: "goTo", args: [[
            "center": CLLocationCoordinate2D(latitude: 14.25, longitude: 99.35),
            "zoom": 8
        ]])
    }
    
    func addRotateMarker() {
        marker = map.createSphereObject("Marker", with: [
            CLLocationCoordinate2D(latitude: 13.84, longitude: 100.41),
            [
                "title": "Rotate Marker",
                "rotate": 90
            ]
        ])
        let _ = map.call(method: "Overlays.add", args: [marker!])
        
        let _ = self.map.call(method: "goTo", args: [[
            "center": CLLocationCoordinate2D(latitude: 13.84, longitude: 100.41),
            "zoom": 8
        ]])
    }
    
    func addSpherePlace() {
        if isConnectedToNetwork() {
            object = map.createSphereObject("Overlays.Object", with: [
                "P00250996"
            ])
            let _ = map.call(method: "Overlays.load", args: [object!])
            
            let _ = self.map.call(method: "goTo", args: [[
                "center": CLLocationCoordinate2D(latitude: 13.8449, longitude: 100.5782),
                "zoom": 14
            ]])
        }
    }
    
    func removeMarker() {
        if let m = marker {
            moveTimer?.invalidate()
            rotateTimer?.invalidate()
            followPathTimer?.invalidate()
            let _ = map.call(method: "Overlays.remove", args: [m])
        }
    }
    
    func markerList() {
        let result = map.call(method: "Overlays.list", args: nil)
        alert(message: "\(result ?? "no result")", placeholder: nil, completionHandler: nil)
    }
    
    func markerCount() {
        let result = map.call(method: "Overlays.size", args: nil)
        alert(message: "\(result ?? "no result")", placeholder: nil, completionHandler: nil)
    }
    
    func clearAllOverlays() {
        moveTimer?.invalidate()
        rotateTimer?.invalidate()
        followPathTimer?.invalidate()
        let _ = map.call(method: "Overlays.clear", args: nil)
    }
    
    func addHeatMap(){
        if isConnectedToNetwork() {
            layer = map.createSphereObject("Layer", with:[
                [
                    "sources": [
                        "earthquakes": [
                            "type": "geojson",
                            "data": "https://docs.mapbox.com/mapbox-gl-js/assets/earthquakes.geojson",
                        ],
                    ],
                    "layers": [
                        [
                            "id": "earthquakes-heat",
                            "type": "heatmap",
                            "source": "earthquakes",
                            "maxzoom": 9,
                            "paint": [
                                // Increase the heatmap weight based on frequency and property magnitude
                                "heatmap-weight": [
                                    "interpolate",
                                    ["linear"],
                                    ["get", "mag"],
                                    0,
                                    0,
                                    6,
                                    1,
                                ],
                                // Increase the heatmap color weight weight by zoom level
                                // heatmap-intensity is a multiplier on top of heatmap-weight
                                "heatmap-intensity": [
                                    "interpolate",
                                    ["linear"],
                                    ["zoom"],
                                    0,
                                    1,
                                    9,
                                    3,
                                ],
                                // Color ramp for heatmap.  Domain is 0 (low) to 1 (high).
                                // Begin color ramp at 0-stop with a 0-transparancy color
                                // to create a blur-like effect.
                                "heatmap-color": [
                                    "interpolate",
                                    ["linear"],
                                    ["heatmap-density"],
                                    0,
                                    "rgba(33,102,172,0)",
                                    0.2,
                                    "rgb(103,169,207)",
                                    0.4,
                                    "rgb(209,229,240)",
                                    0.6,
                                    "rgb(253,219,199)",
                                    0.8,
                                    "rgb(239,138,98)",
                                    1,
                                    "rgb(178,24,43)",
                                ],
                                // Adjust the heatmap radius by zoom level
                                "heatmap-radius": [
                                    "interpolate",
                                    ["linear"],
                                    ["zoom"],
                                    0,
                                    2,
                                    9,
                                    20,
                                ],
                                // Transition from heatmap to circle layer by zoom level
                                "heatmap-opacity": [
                                    "interpolate",
                                    ["linear"],
                                    ["zoom"],
                                    7,
                                    1,
                                    9,
                                    0,
                                ],
                            ],
                        ],
                        "waterway-label",
                    ],
                ]
            ])
            let _ = map.call(method: "Layers.add", args: [layer!])
            
            let _ = self.map.call(method: "goTo", args: [[
                "center": CLLocationCoordinate2D(latitude: 35.5, longitude: -135.2),
                "zoom": 2
            ]])
        }
    }
    
    func addClusterMarker() {
        if isConnectedToNetwork() {
            layer = map.createSphereObject("Layer", with:[
                [
                    "sources": [
                        "earthquakes": [
                            "type": "geojson",
                            "data": "https://maplibre.org/maplibre-gl-js/docs/assets/earthquakes.geojson",
                            "cluster": true,
                            "clusterMaxZoom": 14, // Max zoom to cluster points on
                            "clusterRadius": 50, // Radius of each cluster when clustering points (defaults to 50)
                        ]
                    ],
                    "layers": [
                        [
                            "id": "clusters",
                            "type": "circle",
                            "source": "earthquakes",
                            "filter": ["has", "point_count"],
                            "paint": [
                                "circle-color": [
                                    "step",
                                    ["get", "point_count"],
                                    "#51bbd6", 100,
                                    "#f1f075", 750,
                                    "#f28cb1",
                                ],
                                "circle-radius": ["step", ["get", "point_count"], 20, 100, 30, 750, 40],
                            ],
                        ],
                        [
                            "id": "cluster-count",
                            "type": "symbol",
                            "source": "earthquakes",
                            "filter": ["has", "point_count"],
                            "layout": [
                                "text-field": "{point_count_abbreviated}",
                                "text-font": ["OCJ"],
                                "text-size": 12,
                            ],
                        ],
                        [
                            "id": "unclustered-point",
                            "type": "circle",
                            "source": "earthquakes",
                            "filter": ["!", ["has", "point_count"]],
                            "paint": [
                                "circle-color": "#11b4da",
                                "circle-radius": 4,
                                "circle-stroke-width": 1,
                                "circle-stroke-color": "#fff",
                            ],
                        ],
                    ]
                ]
            ])
            let _ = map.call(method: "Layers.add", args: [layer!])
            
            let _ = self.map.call(method: "goTo", args: [[
                "center": CLLocationCoordinate2D(latitude: 45.58, longitude: 94.65),
                "zoom": 1
            ]])
        }
    }
    
    func addPopup() {
        popup = map.createSphereObject("Popup", with: [
            CLLocationCoordinate2D(latitude: 14, longitude: 99),
            [
                "title": "Popup",
                "detail": "Simple popup"
            ]
        ])
        let _ = map.call(method: "Overlays.add", args: [popup!])
        
        let _ = self.map.call(method: "goTo", args: [[
            "center": CLLocationCoordinate2D(latitude: 14, longitude: 99),
            "zoom": 8
        ]])
    }
    
    func addCustomPopup() {
        popup = map.createSphereObject("Popup", with: [
            CLLocationCoordinate2D(latitude: 14, longitude: 101),
            [
                "title": "Popup",
                "detail": "Popup detail...",
                "loadDetail": map.createSphereFunction("e => setTimeout(() => e.innerHTML = 'Content changed', 1000)"),
                "size": [
                    "width": 200,
                    "height": 200
                ],
                "closable": false
            ]
        ])
        let _ = map.call(method: "Overlays.add", args: [popup!])
        
        let _ = self.map.call(method: "goTo", args: [[
            "center": CLLocationCoordinate2D(latitude: 14, longitude: 101),
            "zoom": 8
        ]])
    }
    
    func addHTMLPopup() {
        popup = map.createSphereObject("Popup", with: [
            CLLocationCoordinate2D(latitude: 14, longitude: 102),
            [
                "html": "<div style=\"background: #eeeeff;\">popup</div>"
            ]
        ])
        let _ = map.call(method: "Overlays.add", args: [popup!])
        
        let _ = self.map.call(method: "goTo", args: [[
            "center": CLLocationCoordinate2D(latitude: 14, longitude: 102),
            "zoom": 8
        ]])
    }
    
    func removePopup() {
        if let p = popup {
            let _ = map.call(method: "Overlays.remove", args: [p])
        }
    }
    
    func moveMarker() {
        marker = map.createSphereObject("Marker", with: [
            CLLocationCoordinate2D(latitude: 15.525007, longitude: 100.643005)
        ])
        let _ = map.call(method: "Overlays.add", args: [marker!])
        moveOut()
        
        let _ = self.map.call(method: "goTo", args: [[
            "center": CLLocationCoordinate2D(latitude: 15, longitude: 102),
            "zoom": 6
        ]])
    }
    
    @objc func moveOut() {
        let _ = map.objectCall(sphereObject: marker!, method: "move", args: [
            CLLocationCoordinate2D(latitude: 15, longitude: 102),
            true
        ])
        moveTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.moveBack), userInfo: nil, repeats: false)
    }
    
    @objc func moveBack() {
        let _ = map.objectCall(sphereObject: marker!, method: "move", args: [
            CLLocationCoordinate2D(latitude: 15.525007, longitude: 100.643005),
            true
        ])
        moveTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.moveOut), userInfo: nil, repeats: false)
    }
    
    func rotateMarker() {
        marker = map.createSphereObject("Marker", with: [
            CLLocationCoordinate2D(latitude: 15.525007, longitude: 100.643005)
        ])
        let _ = map.call(method: "Overlays.add", args: [marker!])
        rotateTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.rotateClockwise), userInfo: nil, repeats: true)
        
        let _ = self.map.call(method: "goTo", args: [[
            "center": CLLocationCoordinate2D(latitude: 15.525007, longitude: 100.643005),
            "zoom": 8
        ]])
    }
    
    @objc func rotateClockwise() {
        let _ = map.objectCall(sphereObject: marker!, method: "update", args: [
            ["rotate": (Date().timeIntervalSince1970.truncatingRemainder(dividingBy: 60)) * 6]
        ])
    }
    
    @objc func followPath() {
        let line = map.createSphereObject("Polyline", with: [
            CLLocationCoordinate2D(latitude: 18, longitude: 102),
            CLLocationCoordinate2D(latitude: 17, longitude: 98),
            CLLocationCoordinate2D(latitude: 14, longitude: 99),
            CLLocationCoordinate2D(latitude: 15.525007, longitude: 101.643005)
        ])
        let _ = map.call(method: "Overlays.pathAnimation", args: [
            marker!,
            line
        ])
    }
    
    // MARK: - Tag
    func addLocalTag() {
        let _ = map.call(method: "Tags.add", args: [
            { (tile: [String: Any], zoom: Int) -> Void in
                if let bbox = tile["bbox"] as? [String: Double] {
                    for _ in 1...3 {
                        let m = self.map.createSphereObject("Marker", with: [
                                CLLocationCoordinate2D(
                                    latitude: Double.random(in: bbox["south"]!...bbox["north"]!),
                                    longitude: Double.random(in: bbox["west"]!...bbox["east"]!)
                                ),
                                [
                                    "visibleRange": zoom...zoom
                                ]
                            ])
                        let _ = self.map.call(method: "Overlays.add", args: [m])
                    }
                }
            }
        ])
        
        let _ = self.map.call(method: "goTo", args: [[
            "center": CLLocationCoordinate2D(latitude: 13.7, longitude: 100.5),
            "zoom": 12
        ]])
    }
    
    func addSphereTag() {
        let _ = map.call(method: "Tags.add", args: ["hotel"])
        
        let _ = self.map.call(method: "goTo", args: [[
            "center": CLLocationCoordinate2D(latitude: 13.7, longitude: 100.5),
            "zoom": 12
        ]])
    }
    
    func addTagWithOption() {
        let _ = map.call(method: "Tags.add", args: [
            "hotel",
            [
                "visibleRange": 10...20,
                "icon": [
                    "url": UIImage(named: "pin_mark") ??  "https://map.longdo.com/mmmap/images/pin_mark.png",
                    "offset": [
                        "x": 12,
                        "y": 45
                    ]
                ]
            ]
        ])
        
        let _ = self.map.call(method: "goTo", args: [[
            "center": CLLocationCoordinate2D(latitude: 13.7, longitude: 100.5),
            "zoom": 12
        ]])
    }
    
    func removeTag() {
        let _ = map.call(method: "Tags.remove", args: ["hotel"])
        let _ = map.call(method: "Tags.remove", args: ["shopping"])
    }
    
    func clearAllTag() {
        let _ = map.call(method: "Tags.clear", args: nil)
    }
    
    // MARK: - Geometry
    func addLine() {
        geom = map.createSphereObject("Polyline", with: [[
            CLLocationCoordinate2D(latitude: 15, longitude: 100),
            CLLocationCoordinate2D(latitude: 10, longitude: 100)
        ]])
        let _ = map.call(method: "Overlays.add", args: [geom!])
        
        let _ = self.map.call(method: "goTo", args: [[
            "center": CLLocationCoordinate2D(latitude: 13.7, longitude: 100.5),
            "zoom": 6
        ]])
    }
    
    func removeLine() {
        if let g = geom {
            let _ = map.call(method: "Overlays.remove", args: [g])
        }
    }
    
    func addLineWithOption() {
        geom = map.createSphereObject("Polyline", with: [
            [
                CLLocationCoordinate2D(latitude: 14, longitude: 100),
                CLLocationCoordinate2D(latitude: 15, longitude: 101),
                CLLocationCoordinate2D(latitude: 14, longitude: 102)
            ],
            [
                "title": "Polyline",
                "detail": "-",
                "label": "Polyline",
                "lineWidth": 4,
                "lineColor": UIColor.systemRed
            ]
        ])
        let _ = map.call(method: "Overlays.add", args: [geom!])
        
        let _ = self.map.call(method: "goTo", args: [[
            "center": CLLocationCoordinate2D(latitude: 15, longitude: 101),
            "zoom": 6
        ]])
    }
    
    func addDashLine() {
        geom = map.createSphereObject("Polyline", with: [
            [
                CLLocationCoordinate2D(latitude: 14, longitude: 99),
                CLLocationCoordinate2D(latitude: 15, longitude: 100),
                CLLocationCoordinate2D(latitude: 14, longitude: 101)
            ],
            [
                "title": "Dashline",
                "detail": "-",
                "label": "Dashline",
                "lineWidth": 4,
                "lineColor": UIColor.systemGreen,
                "lineStyle": map.createSphereStatic("LineStyle", with: "Dashed")
            ]
        ])
        let _ = map.call(method: "Overlays.add", args: [geom!])
        
        let _ = self.map.call(method: "goTo", args: [[
            "center": CLLocationCoordinate2D(latitude: 15, longitude: 100),
            "zoom": 6
        ]])
    }
    
    func addPolygon() {
        geom = map.createSphereObject("Polygon", with: [
            [
                CLLocationCoordinate2D(latitude: 14, longitude: 99),
                CLLocationCoordinate2D(latitude: 13, longitude: 100),
                CLLocationCoordinate2D(latitude: 13, longitude: 102),
                CLLocationCoordinate2D(latitude: 14, longitude: 103)
            ],
            [
                "title": "Polygon",
                "detail": "-",
                "label": "Polygon",
                "lineWidth": 2,
                "lineColor": UIColor.black,
                "fillColor": UIColor.init(red: 1, green: 0, blue: 0, alpha: 0.4),
                "visibleRange": 6...18,
                "editable": true
            ]
        ])
        let _ = map.call(method: "Overlays.add", args: [geom!])
        
        let _ = self.map.call(method: "goTo", args: [[
            "center": CLLocationCoordinate2D(latitude: 13, longitude: 101),
            "zoom": 6
        ]])
    }
    
    func addCircle() {
        geom = map.createSphereObject("Circle", with: [
            CLLocationCoordinate2D(latitude: 15, longitude: 101),
            1,
            [
                "title": "Geom 3",
                "detail": "-",
                "lineWidth": 2,
                "lineColor": UIColor.red.withAlphaComponent(0.8),
                "fillColor": UIColor.red.withAlphaComponent(0.4)
            ]
        ])
        let _ = map.call(method: "Overlays.add", args: [geom!])
        
        let _ = self.map.call(method: "goTo", args: [[
            "center": CLLocationCoordinate2D(latitude: 15, longitude: 101),
            "zoom": 6
        ]])
    }
    
    func addDot() {
        geom = map.createSphereObject("Dot", with: [
            CLLocationCoordinate2D(latitude: 12.5, longitude: 100.5),
            [
                "lineWidth": 20,
                "draggable": true
            ]
        ])
        let _ = map.call(method: "Overlays.add", args: [geom!])
        
        let _ = self.map.call(method: "goTo", args: [[
            "center": CLLocationCoordinate2D(latitude: 12.5, longitude: 100.5),
            "zoom": 6
        ]])
    }
    
    func addDonut() {
        geom = map.createSphereObject("Polygon", with: [
            [
                CLLocationCoordinate2D(latitude: 15, longitude: 101),
                CLLocationCoordinate2D(latitude: 15, longitude: 105),
                CLLocationCoordinate2D(latitude: 12, longitude: 103),
                nil,
                CLLocationCoordinate2D(latitude: 14.9, longitude: 103),
                CLLocationCoordinate2D(latitude: 13.5, longitude: 102.1),
                CLLocationCoordinate2D(latitude: 13.5, longitude: 103.9)
            ],
            [
                "label": 20,
                "clickable": true
            ]
        ])
        let _ = map.call(method: "Overlays.add", args: [geom!])
        
        let _ = self.map.call(method: "goTo", args: [[
            "center": CLLocationCoordinate2D(latitude: 13.5, longitude: 103),
            "zoom": 6
        ]])
    }
    
    func addRectangle() {
        geom = map.createSphereObject("Rectangle", with: [
            CLLocationCoordinate2D(latitude: 17, longitude: 97),
            [
                "width": 2,
                "height": 1
            ],
            [
                "editable": true
            ]
        ])
        let _ = map.call(method: "Overlays.add", args: [geom!])
        
        let _ = self.map.call(method: "goTo", args: [[
            "center": CLLocationCoordinate2D(latitude: 16, longitude: 97.5),
            "zoom": 6
        ]])
    }
    
    func geometryLocation() {
        if let g = geom {
            let location = map.objectCall(sphereObject: g, method: "location", args: nil)
            alert(message: "\(location ?? "N/A")", placeholder: nil, completionHandler: nil)
        }
    }
    
    // MARK: - Route
    func getRoute() {
        if isConnectedToNetwork() {
            marker = map.createSphereObject("Marker", with: [
                CLLocationCoordinate2D(latitude: 13.764953, longitude: 100.538316),
                [
                    "title": "Victory monument",
                    "detail": "I'm here"
                ]
            ])
            let _ = map.call(method: "Route.add", args: [marker!])
            let _ = map.call(method: "Route.add", args: [
                CLLocationCoordinate2D(latitude: 15, longitude: 100)
            ])
            let _ = map.call(method: "Route.search", args: nil)
            
            let _ = self.map.call(method: "goTo", args: [[
                "center": CLLocationCoordinate2D(latitude: 14.48, longitude: 100.36),
                "zoom": 8
            ]])
        }
    }
    
    func autoReroute() {
        clearRoute()
        getRoute()
        let _ = map.call(method: "Route.auto", args: [true])
    }
    
    func getRouteByCost() {
        clearRoute()
        let _ = map.call(method: "Route.mode", args: [map.createSphereStatic("RouteMode", with: "Cost")])
        getRoute()
    }
    
    func getRouteByDistance() {
        clearRoute()
        let _ = map.call(method: "Route.mode", args: [map.createSphereStatic("RouteMode", with: "Distance")])
        getRoute()
    }
    
    func getRouteWithoutTollway() {
        clearRoute()
        let _ = map.call(method: "Route.enableRoute", args: [
            map.createSphereStatic("RouteType", with: "Tollway"),
            false
        ])
        getRoute()
    }
    
    func getRouteWithMotorcycle() {
        clearRoute()
        let _ = map.call(method: "Route.enableRestrict", args: [
            map.createSphereStatic("RouteRestrict", with: "Bike"),
            true
        ])
        getRoute()
    }
    
    func getRouteGuide() {
        clearRoute()
        unbind()
        let _ = map.call(method: "Event.bind", args: [
            map.createSphereStatic("EventName", with: "RouteComplete"),
            {
                (guide: Any?) -> Void in
                print(guide ?? "no data")
                if let g = guide as? [[String: Any]], g.count > 0,
                    let turn = g[0]["guide"] as? [[String: Any?]],
                    let data = g[0]["data"] as? [String: Any] {
                    var str = ["ออกจาก จุดเริ่มต้น \(round(data["fdistance"] as? Double ?? 0) / 1000) กม."]
                    let turnText = ["เลี้ยวซ้ายสู่", "เลี้ยวขวาสู่", "เบี่ยงซ้ายสู่", "เบี่ยงขวาสู่", "ไปตาม", "ตรงไปตาม", "เข้าสู่", "", "", "ถึง", "", "", "", "", ""]
                    for i in turn {
                        str.append("\(turnText[(i["turn"] as? SphereTurn ?? .Unknown).rawValue]) \(i["name"] as? String ?? "") \(round(i["distance"] as? Double ?? 0) / 1000) กม.")
                    }
                    str.append("รวมระยะทาง \(round(data["distance"] as? Double ?? 0) / 1000) กม. เวลา \(Int(floor((data["interval"] as? Double ?? 0) / 3600))) ชม. \(Int(ceil(Double((data["interval"] as? Int ?? 0) % 3600) / 60))) น.")
                    self.alert(message: "\(str.joined(separator: "\n"))", placeholder: nil, completionHandler: nil)
                }
            }
        ])
        getRoute()
    }
    
    func clearRoute() {
        let _ = map.call(method: "Route.clear", args: nil)
        let _ = map.call(method: "Route.clearPath", args: nil)
        clearAllOverlays()
    }
    
    // MARK: - Search
    func searchCentral() {
        if isConnectedToNetwork() {
            let _ = self.map.call(method: "goTo", args: [[
                "center": CLLocationCoordinate2D(latitude: 13.813, longitude: 100.546),
                "zoom": 11
            ]])
            
            let _ = map.call(method: "Search.search", args: [
                "central",
                [
                    "tag": "hotel",
                    "span": "2000km",
                    "limit": 10
                ]
            ])
            {
                (data: Any?) -> Void in
                if let result = data as? [String: Any?], let poi = result["data"] as? [[String: Any?]] {
                    self.searchPoi = []
                    for i in poi {
                        if let lat = i["lat"] as? Double, let lon = i["lon"] as? Double {
                            let poiMarker = self.map.createSphereObject("Marker", with: [
                                CLLocationCoordinate2D(latitude: lat, longitude: lon),
                                [
                                    "title": i["name"],
                                    "detail": i["address"]
                                ]
                            ])
                            self.searchPoi.append(poiMarker)
                            if let newPoi = self.searchPoi.last {
                                let _ = self.map.call(method: "Overlays.add", args: [newPoi])
                            }
                        }
                    }
                }
            }
        }
    }
    
    func searchInEnglish() {
        let _ = map.call(method: "Search.language", args: [SphereLocale.English])
        searchCentral()
    }
    
    func suggestCentral() {
        if isConnectedToNetwork() {
            let _ = map.call(method: "Search.suggest", args: [
                "central"
            ])
            {
                (data: Any?) -> Void in
                if let result = data as? [String: Any?], let poi = result["data"] as? [[String: Any?]] {
                    var str: [String] = []
                    for i in poi {
                        if let word = i["name"] as? String {
                            str.append("- \(word)")
                        }
                    }
                    self.alert(message: str.joined(separator: "\n"), placeholder: nil, completionHandler: nil)
                }
            }
        }
    }
    
    func clearSearch() {
        for m in searchPoi {
            let _ = map.call(method: "Overlays.remove", args: [m])
        }
    }
    
    // MARK: - Conversion
    func getGeoCode() {
        if isConnectedToNetwork() {
            if let pos = map.call(method: "location", args: nil) {
                let _ = map.call(method: "Search.address", args: [pos])
                {
                    (data: Any?) -> Void in
                    self.alert(message: "\(data ?? "no data")", placeholder: nil, completionHandler: nil)
                }
            }
            else {
                self.alert(message: "no location", placeholder: nil, completionHandler: nil)
            }
        }
    }
    
    func getLatitudeLength() {
        if let pos = map.call(method: "location", args: nil) as? CLLocationCoordinate2D {
            if let radian = map.call(method: "Util.latitudeLength", args: [pos.latitude]) {
                self.alert(message: "Distance for 1 radian at latitude \(pos.latitude) = \(radian) metres.", placeholder: nil, completionHandler: nil)
            }
            else {
                self.alert(message: "no data", placeholder: nil, completionHandler: nil)
            }
        }
        else {
            self.alert(message: "no location", placeholder: nil, completionHandler: nil)
        }
    }
    
    // MARK: - Events
    func locationEvent() {
        displayTextField.isHidden = false
        unbind()
        let _ = map.call(method: "Event.bind", args: [
            map.createSphereStatic("EventName", with: "Location"),
            {
                () -> Void in
                if let pos = self.map.call(method: "location", args: nil) {
                    self.displayTextField.text = "\(pos)"
                }
            }
        ])
    }
    
    func zoomEvent() {
        displayTextField.isHidden = false
        unbind()
        let _ = map.call(method: "Event.bind", args: [
            map.createSphereStatic("EventName", with: "Zoom"),
            {
                () -> Void in
                if let zoom = self.map.call(method: "zoom", args: nil) {
                    self.displayTextField.text = "\(zoom)"
                }
            }
        ])
    }
    
    func zoomRangeEvent() {
        displayTextField.isHidden = false
        unbind()
        let _ = map.call(method: "Event.bind", args: [
            map.createSphereStatic("EventName", with: "ZoomRange"),
            {
                () -> Void in
                if let zr = self.map.call(method: "zoomRange", args: nil) {
                    self.displayTextField.text = "\(zr)"
                }
            }
        ])
        let _ = map.call(method: "zoomRange", args: [1...10])
    }
    
    func readyEvent() {
        //Call before map.render()
        map.options.onReady = {
            () -> Void in
            self.alert(message: "Map is ready.", placeholder: nil, completionHandler: nil)
        }
    }
    
    func resizeEvent() {
        displayTextField.isHidden = false
        unbind()
        let _ = self.map.call(method: "Event.bind", args: [
            map.createSphereStatic("EventName", with: "Resize"),
            {
                () -> Void in
                if let bound = self.map.call(method: "bound", args: nil) {
                    self.displayTextField.text = "\(bound)"
                }
            }
        ])
    }
    
    func clickEvent() {
        unbind()
        let _ = self.map.call(method: "Event.bind", args: [
            map.createSphereStatic("EventName", with: "Click"),
            {
                (result: Any?) -> Void in
                if let pos = result as? [String: Double] {
                    DispatchQueue.main.async {
                        self.marker = self.map.createSphereObject("Marker", with: [pos])
                        let _ = self.map.call(method: "Overlays.add", args: [self.marker!])
                    }
                }
            }
        ])
    }
    
    func dragEvent() {
        displayTextField.isHidden = false
        unbind()
        let _ = self.map.call(method: "Event.bind", args: [
            map.createSphereStatic("EventName", with: "Drag"),
            {
                (result: Any?) -> Void in
                self.displayTextField.text = "Drag event triggered."
            }
        ])
    }
    
    func dropEvent() {
        displayTextField.isHidden = false
        unbind()
        let _ = self.map.call(method: "Event.bind", args: [
            map.createSphereStatic("EventName", with: "Drop"),
            {
                (result: Any?) -> Void in
                self.displayTextField.text = "Drop event triggered."
            }
        ])
    }
    
    func layerChangeEvent() {
        unbind()
        let _ = self.map.call(method: "Event.bind", args: [
            map.createSphereStatic("EventName", with: "LayerChange"),
            {
                (result: Any?) -> Void in
                self.alert(message: "\(result ?? "no data")", placeholder: nil, completionHandler: nil)
            }
        ])
        addLayer()
    }
    
    func overlayClickEvent() {
        unbind()
        let _ = self.map.call(method: "Event.bind", args: [
            map.createSphereStatic("EventName", with: "OverlayClick"),
            {
                (result: Any?) -> Void in
                self.alert(message: "\(result ?? "no data")", placeholder: nil, completionHandler: nil)
            }
        ])
        addURLMarker()
    }
    
    func overlayChangeEvent() {
        unbind()
        let _ = self.map.call(method: "Event.bind", args: [
            map.createSphereStatic("EventName", with: "OverlayChange"),
            {
                (result: Any?) -> Void in
                self.alert(message: "\(result ?? "no data")", placeholder: nil, completionHandler: nil)
            }
        ])
        addURLMarker()
    }
    
    func overlayDropEvent() {
        unbind()
        let _ = self.map.call(method: "Event.bind", args: [
            map.createSphereStatic("EventName", with: "OverlayDrop"),
            {
                (result: Any?) -> Void in
                self.alert(message: "\(result ?? "no data")", placeholder: nil, completionHandler: nil)
            }
        ])
        addURLMarker()
    }
    
    ///Note:
    ///> The `handler` parameter is not available. All handlers for the selected event name will be unbound.
    func unbind() {
        let event = ["RouteComplete", "Location", "Zoom", "ZoomRange", "Resize", "Click", "Drag", "Drop", "LayerChange", "OverlayClick", "OverlayChange", "OverlayLoad", "OverlayDrop"]
        for i in event {
            let _ = self.map.call(method: "Event.unbind", args: [map.createSphereStatic("EventName", with: i)])
        }
    }
    
    // MARK: - User Interface
    func setCustomLocation() {
        let _ = self.map.call(method: "location", args: [
            CLLocationCoordinate2D(latitude: 16, longitude: 100),
            true
        ])
    }
    
    func setGeoLocation() {
        currentMethod = "location"
        trackLocation = true
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        //see func locationManager
    }
    
    func getLocation() {
        let location = map.call(method: "location", args: nil)
        alert(message: "\(location ?? "no data")", placeholder: nil, completionHandler: nil)
    }
    
    func setZoom() {
        let _ = map.call(method: "zoom", args: [14, true])
    }
    
    func setLocationAndZoom() {
        let _ = map.call(method: "goTo", args: [[
            "center": CLLocationCoordinate2D(latitude: 16, longitude: 100),
            "zoom": 13
        ]])
    }
    
    func setRotate() {
        let _ = map.call(method: "rotate", args: [30, true])
    }
    
    func setPitch() {
        let _ = map.call(method: "pitch", args: [60])
    }
    
    func zoomIn() {
        let _ = map.call(method: "zoom", args: [true, true])
    }
    
    func zoomOut() {
        let _ = map.call(method: "zoom", args: [false, true])
    }
    
    func setZoomRange() {
        let _ = map.call(method: "zoomRange", args: [1...5])
    }
    
    func getZoomRange() {
        let zoomRange = map.call(method: "zoomRange", args: nil)
        alert(message: "\(zoomRange ?? "no data")", placeholder: nil, completionHandler: nil)
    }
    
    func setBound() {
        let _ = map.call(method: "bound", args: [[
            "minLat": 13,
            "maxLat": 14,
            "minLon": 100,
            "maxLon": 101
        ]])
    }
    
    func getBound() {
        let bound = map.call(method: "bound", args: nil)
        alert(message: "\(bound ?? "no data")", placeholder: nil, completionHandler: nil)
    }
    
    func toggleDPad() {
        let _ = map.call(method: "Ui.DPad.visible", args: [
            !(map.call(method: "Ui.DPad.visible", args: nil) as? Bool ?? false)
        ])
    }
    
    func toggleZoombar() {
        let _ = map.call(method: "Ui.Zoombar.visible", args: [
            !(map.call(method: "Ui.Zoombar.visible", args: nil) as? Bool ?? false)
        ])
    }
    
    func toggleLayerSelector() {
        let _ = map.call(method: "Ui.LayerSelector.visible", args: [
            !(map.call(method: "Ui.LayerSelector.visible", args: nil) as? Bool ?? false)
        ])
    }
    
    func toggleCrosshair() {
        let _ = map.call(method: "Ui.Crosshair.visible", args: [
            !(map.call(method: "Ui.Crosshair.visible", args: nil) as? Bool ?? false)
        ])
    }
    
    func toggleScale() {
        let _ = map.call(method: "Ui.Scale.visible", args: [
            !(map.call(method: "Ui.Scale.visible", args: nil) as? Bool ?? false)
        ])
    }
    
    func toggleTouchAndDrag() {
        map.isUserInteractionEnabled = !map.isUserInteractionEnabled
    }
    
    func toggleDrag() {
        let _ = map.call(method: "Ui.Mouse.enableDrag", args: [
            !(map.call(method: "Ui.Mouse.enableDrag", args: nil) as? Bool ?? false)
        ])
    }
    
    // MARK: - Etc.
    func getOverlayType() {
        unbind()
        let _ = self.map.call(method: "Event.bind", args: [
            map.createSphereStatic("EventName", with: "OverlayClick"),
            {
                (result: Any?) -> Void in
                if let overlay = result as? [Any], let object = overlay[0] as? Sphere.SphereObject {
                    self.alert(message: "\(object.type)", placeholder: nil, completionHandler: nil)
                }
            }
        ])
        DispatchQueue.main.async {
            self.marker = self.map.createSphereObject("Marker", with: [
                CLLocationCoordinate2D(latitude: 12.8, longitude: 101.2)
            ])
            let _ = self.map.call(method: "Overlays.add", args: [self.marker!])
        }
        
        let _ = self.map.call(method: "goTo", args: [[
            "center": CLLocationCoordinate2D(latitude: 12.8, longitude: 101.2),
            "zoom": 12
        ]])
    }
    
    func getDistance() {
        var markerCar1: Sphere.SphereObject?
        var markerCar2: Sphere.SphereObject?
        var geom1: Sphere.SphereObject?
        
        unbind()
        let _ = self.map.call(method: "Event.bind", args: [
            map.createSphereStatic("EventName", with: "OverlayDrop"),
            {
                (result: Any?) -> Void in
                let _ = self.map.call(method: "Overlays.remove", args: [geom1!])
                geom1 = self.map.createSphereObject("Polyline", with: [
                    [
                        self.map.objectCall(sphereObject: markerCar1!, method: "location", args: nil),
                        self.map.objectCall(sphereObject: markerCar2!, method: "location", args: nil)
                    ],
                    [
                        "lineColor": UIColor.blue.withAlphaComponent(0.6)
                    ]
                ])
                let _ = self.map.call(method: "Overlays.add", args: [geom1!])
                if let distance = self.map.objectCall(sphereObject: markerCar1!, method: "distance", args: [markerCar2!]) as? Double {
                    self.alert(message: "ระยะกระจัด \(round(distance) / 1000.0) กิโลเมตร", placeholder: nil, completionHandler: nil)
                }
            }
        ])
        DispatchQueue.main.async {
            markerCar1 = self.map.createSphereObject("Marker", with: [
                CLLocationCoordinate2D(latitude: 13.686867, longitude: 100.426157),
                [
                    "draggable": true
                ]
            ])
            markerCar2 = self.map.createSphereObject("Marker", with: [
                CLLocationCoordinate2D(latitude: 13.712259, longitude: 100.457989),
                [
                    "draggable": true
                ]
            ])
            geom1 = self.map.createSphereObject("Polyline", with: [
                [
                    self.map.objectCall(sphereObject: markerCar1!, method: "location", args: nil),
                    self.map.objectCall(sphereObject: markerCar2!, method: "location", args: nil)
                ],
                [
                    "lineColor": UIColor.blue.withAlphaComponent(0.6)
                ]
            ])
            let _ = self.map.call(method: "Overlays.add", args: [markerCar1!])
            let _ = self.map.call(method: "Overlays.add", args: [markerCar2!])
            let _ = self.map.call(method: "Overlays.add", args: [geom1!])
            if let distance = self.map.objectCall(sphereObject: markerCar1!, method: "distance", args: [markerCar2!]) as? Double {
                self.alert(message: "ระยะกระจัด \(round(distance) / 1000.0) กิโลเมตร", placeholder: nil, completionHandler: nil)
            }
        }
        
        let _ = self.map.call(method: "goTo", args: [[
            "center": CLLocationCoordinate2D(latitude: 13.7, longitude: 100.45),
            "zoom": 12
        ]])
    }
    
    func getContain() {
        var dropMarker: Sphere.SphereObject?
        var geom1: Sphere.SphereObject?
        var geom2: Sphere.SphereObject?
        
        unbind()
        let _ = self.map.call(method: "Event.bind", args: [
            map.createSphereStatic("EventName", with: "OverlayDrop"),
            {
                (result: Any?) -> Void in
                if let c = self.map.objectCall(sphereObject: geom1!, method: "contains", args: [dropMarker!]) as? Bool, c {
                    self.alert(message: "In yellow area.", placeholder: nil, completionHandler: nil)
                }
                else if let c = self.map.objectCall(sphereObject: geom2!, method: "contains", args: [dropMarker!]) as? Bool, c {
                    self.alert(message: "In red area.", placeholder: nil, completionHandler: nil)
                }
                else {
                    self.alert(message: "Outside selected area.", placeholder: nil, completionHandler: nil)
                }
            }
        ])
        DispatchQueue.main.async {
            dropMarker = self.map.createSphereObject("Marker", with: [
                CLLocationCoordinate2D(latitude: 13.78, longitude: 100.43),
                [
                    "draggable": true
                ]
            ])
            geom1 = self.map.createSphereObject("Polygon", with: [
                [
                    CLLocationCoordinate2D(latitude: 13.94, longitude: 100.2),
                    CLLocationCoordinate2D(latitude: 13.94, longitude: 100.45),
                    CLLocationCoordinate2D(latitude: 13.62, longitude: 100.45),
                    CLLocationCoordinate2D(latitude: 13.62, longitude: 100.2)
                ],
                [
                    "title": "Yellow",
                    "lineWidth": 1,
                    "lineColor": UIColor.black.withAlphaComponent(0.7),
                    "fillColor": UIColor.init(red: 246 / 255.0, green: 210 / 255.0, blue: 88 / 255.0, alpha: 0.6),
                    "label": "Yellow"
                ]
            ])
            geom2 = self.map.createSphereObject("Polygon", with: [
                [
                    CLLocationCoordinate2D(latitude: 13.94, longitude: 100.7),
                    CLLocationCoordinate2D(latitude: 13.94, longitude: 100.45),
                    CLLocationCoordinate2D(latitude: 13.62, longitude: 100.45),
                    CLLocationCoordinate2D(latitude: 13.62, longitude: 100.7)
                ],
                [
                    "title": "Red",
                    "lineWidth": 1,
                    "lineColor": UIColor.black.withAlphaComponent(0.7),
                    "fillColor": UIColor.init(red: 209 / 255.0, green: 47 / 255.0, blue: 47 / 255.0, alpha: 0.6),
                    "label": "Red"
                ]
            ])
            let _ = self.map.call(method: "Overlays.add", args: [dropMarker!])
            let _ = self.map.call(method: "Overlays.add", args: [geom1!])
            let _ = self.map.call(method: "Overlays.add", args: [geom2!])
            let _ = self.map.call(method: "bound", args: [[
                "minLat": 13.57,
                "maxLat": 13.99,
                "minLon": 100.15,
                "maxLon": 100.75
            ]])
        }
    }
    
    func nearPOI() {
        if isConnectedToNetwork() {
            if let loc = map.call(method: "location", args: nil) {
                let _ = map.call(method: "Search.nearPoi", args: [loc])
                {
                    (data: Any?) -> Void in
                    if let result = data as? [String: Any?], let poi = result["data"] as? [[String: Any?]] {
                        self.searchPoi = []
                        for i in poi {
                            if let lat = i["lat"] as? Double, let lon = i["lon"] as? Double {
                                let poiMarker = self.map.createSphereObject("Marker", with: [
                                    CLLocationCoordinate2D(latitude: lat, longitude: lon),
                                    [
                                        "title": i["name"],
                                        "detail": i["address"]
                                    ]
                                ])
                                self.searchPoi.append(poiMarker)
                                if let newPoi = self.searchPoi.last {
                                    let _ = self.map.call(method: "Overlays.add", args: [newPoi])
                                }
                            }
                        }
                        self.locationBound()
                    }
                }
            }
        }
    }
    
    func locationBound() {
        var bound: [String: Double] = [
            "minLat": 90,
            "minLon": 180,
            "maxLat": -90,
            "maxLon": -180
        ]
        for poi in self.searchPoi {
            if let loc = self.map.objectCall(sphereObject: poi, method: "location", args: nil) as? CLLocationCoordinate2D {
                if loc.latitude < bound["minLat"]! {
                    bound["minLat"] = loc.latitude
                }
                if loc.latitude > bound["maxLat"]! {
                    bound["maxLat"] = loc.latitude
                }
                if loc.longitude < bound["minLon"]! {
                    bound["minLon"] = loc.longitude
                }
                if loc.longitude > bound["maxLon"]! {
                    bound["maxLon"] = loc.longitude
                }
            }
        }
        let difLat = (bound["maxLat"]! - bound["minLat"]!) * 0.1
        let difLon = (bound["maxLon"]! - bound["minLon"]!) * 0.1
        bound["minLat"] = bound["minLat"]! - difLat
        bound["maxLat"] = bound["maxLat"]! + difLat
        bound["minLon"] = bound["minLon"]! - difLon
        bound["maxLon"] = bound["maxLon"]! + difLon
        let _ = self.map.call(method: "bound", args: [bound])
    }
    
    func add3DObject() {
        if isConnectedToNetwork() {
            let layer = map.call(method: "Layers.setBase", args: [map.createSphereStatic("Layers", with: "STREETS")]) as? Sphere.SphereObject
            let scale = 100
            let data = """
        [{
            coordinates: [100.5, 13.7, 0],
            color: [255, 0, 0, 255],
            scale: [\(scale), \(scale), \(scale)],
            translation: [0, 0, \(scale)/ 2]
        }]
        """
            let _ = map.objectCall(sphereObject: layer!, method: "insert", args: ["", map.createSphereFunction(
        """
            new deck.MapboxLayer({
                id: 'scenegraph-layer',
                type: deck.ScenegraphLayer,
                data: \(data),
                scenegraph: 'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Models/master/2.0/Box/glTF-Binary/Box.glb',
                getPosition: d => d.coordinates,
                getColor: d => d.color,
                getScale: d => d.scale,
                getTranslation: d => d.translation,
                opacity: 0.5,
                _lighting: 'pbr',
                parameters: { depthTest: false }
            })
        """)])
            let _ = map.call(method: "goTo", args: [[
                "center": CLLocationCoordinate2D(latitude: 13.699123, longitude: 100.500136),
                "zoom": 16,
                "pitch": 60
            ]])
        }
    }
    
    func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        if !ret {
            print("Internet connection is required for this feature.")
        }
        return ret
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "menu" {
            guard let vc = segue.destination as? MenuTableViewController else { return }
            vc.delegate = self
        }
    }
}

