/*********************************************************************************
* Copyright 2013 appscape gmbh
* Copyright 2014-2015 SPECURE GmbH
* 
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
* 
*   http://www.apache.org/licenses/LICENSE-2.0
* 
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*********************************************************************************/

//
//  RMBTMapViewController.swift
//  RMBT
//
//  Created by Benjamin Pucher on 30.03.15.
//  Copyright (c) 2015 Specure GmbH. All rights reserved.
//

import Foundation

/// These values are passed to map server and are multiplied by 2x on retina displays to get pixel sizes
let kTileSizePoints: CGFloat = 256
let kPointDiameterSizePoints: CGFloat = 8

let kCameraLatKey     = "map.camera.lat"
let kCameraLngKey     = "map.camera.lng"
let kCameraZoomKey    = "map.camera.zoom"
let kCameraBearingKey = "map.camera.bearing"
let kCameraAngleKey   = "map.camera.angle"

///
class RMBTMapViewController : UIViewController, SWRevealViewControllerDelegate, GMSMapViewDelegate, RMBTMapSubViewControllerDelegate {

    ///
    @IBOutlet private var locateMeButton: UIButton!
    
    ///
    @IBOutlet private var toastView: UIView!
    
    ///
    @IBOutlet private var toastTitleLabel: UILabel!
    
    ///
    @IBOutlet private var toastKeysLabel: UILabel!
    
    ///
    @IBOutlet private var toastValuesLabel: UILabel!
    
    ///
    private var settingsBarButtonItem: UIBarButtonItem!
    
    ///
    private var filterBarButtonItem: UIBarButtonItem!
    
    ///
    private var toastBarButtonItem: UIBarButtonItem!

    /// If set, blue pin will be shown at this location and map initially zoomed here. Used to display a test on the map.
    var initialLocation: CLLocation!

    //
    
    ///
    private var mapServer: RMBTMapServer!
    
    ///
    private var mapOptions: RMBTMapOptions!
    
    ///
    private var mapView: GMSMapView!
    
    ///
    private var mapMarker: GMSMarker!
    
    //
    
    ///
    private var mapLayerHeatmap: GMSTileLayer!
    
    ///
    private var mapLayerPoints: GMSTileLayer!
    
    ///
    //private var mapLayerShapes: GMSTileLayer!
    
    ///
    private var mapLayerRegions: GMSTileLayer!
    
    ///
    private var mapLayerMunicipality: GMSTileLayer!
    
    ///
    private var mapLayerSettlements: GMSTileLayer!
    
    ///
    private var mapLayerWhitespots: GMSTileLayer!
    
    //
    
    ///
    private var tileParamsDictionary: NSMutableDictionary!
    
    ///
    private var tileSize: Int!
    
    ///
    private var pointDiameterSize: Int!
    
    ///
//    private var hideOverlayTimer: NSTimer!
    
    //
    
    ///
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        mapServer = RMBTMapServer()
    }
    
    ///
    override func viewDidLoad() {
        super.viewDidLoad()
        
        revealViewController().delegate = self
        
        if (navigationController?.viewControllers.first as? RMBTMapViewController == self) {
            navigationController?.tabBarItem.selectedImage = UIImage(named: "tab_map_selected")
        }
        
        toastBarButtonItem = UIBarButtonItem(image: UIImage(named: "map_info"), style: .Plain, target: self, action: "toggleToast:")
        toastBarButtonItem.enabled = false
        
        settingsBarButtonItem = UIBarButtonItem(image: UIImage(named: "map_options"), style: .Plain, target: self, action: "showMapOptions")
        settingsBarButtonItem.enabled = false
        
        filterBarButtonItem = UIBarButtonItem(image: UIImage(named: "map_filter"), style: .Plain, target: self, action: "showMapFilter")
        filterBarButtonItem.enabled = false
        
        if (initialLocation == nil) {
            navigationItem.rightBarButtonItems = [toastBarButtonItem, settingsBarButtonItem, filterBarButtonItem]
            
            let revealBarButtonItem = UIBarButtonItem(image: UIImage(named: "reveal-icon"), style: .Plain, target: revealViewController(), action: "revealToggle:")
            navigationItem.leftBarButtonItem = revealBarButtonItem
            
            //view.addGestureRecognizer(revealViewController().panGestureRecognizer())
            view.addGestureRecognizer(revealViewController().edgeGestureRecognizer())
            view.addGestureRecognizer(revealViewController().tapGestureRecognizer())
        }
        
        locateMeButton.setTranslatesAutoresizingMaskIntoConstraints(false)
        let views = [
            "bottom": bottomLayoutGuide,
            "locme": locateMeButton
        ]
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[locme(44)]-10-[bottom]", options: NSLayoutFormatOptions(0), metrics: nil, views: views as [NSObject : AnyObject]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[locme(44)]-10-|", options: NSLayoutFormatOptions(0), metrics: nil, views: views as [NSObject : AnyObject]))
    }
    
    ///
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    ///
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        togglePopGestureRecognizer(false)
        
        // Note that initializing map view for the first time takes few seconds until all resources are initialized,
        // so to appear more responsive we we do it here (instead of viewDidLoad).
        if (mapView == nil) {
            setupMapView()
        }
    }
    
    ///
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        togglePopGestureRecognizer(true)
        //[_mapView stopRendering]; // deprecated
    }
    
// MARK: map view methods
    
    private func setupMapView() {
        assert(mapView == nil, "Map view already initialized!")
    
        // TODO: correct dispatch once!
        
        // Supply Google Maps API Key only once during whole app lifecycle
        //var onceToken: dispatch_once_t
        //dispatch_once(&onceToken) {
            //GMSServices.provideAPIKey(RMBT_GMAPS_API_KEY)
            //return
        //}
    
        var cam = GMSCameraPosition.cameraWithLatitude(RMBT_MAP_INITIAL_LAT, longitude: RMBT_MAP_INITIAL_LNG, zoom: RMBT_MAP_INITIAL_ZOOM)
        
        // If test coordinates were provided, center map at the coordinates:
        if let initialLocation = self.initialLocation {
            cam = GMSCameraPosition.cameraWithLatitude(initialLocation.coordinate.latitude, longitude: initialLocation.coordinate.longitude, zoom: RMBT_MAP_POINT_ZOOM)
        } else {
            // Otherwise, see if we have user's location available...
            if let location = RMBTLocationTracker.sharedTracker.location {
                // and if yes, then show it on the map
                cam = GMSCameraPosition.cameraWithLatitude(location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: RMBT_MAP_POINT_ZOOM)
            }
        }
        
        mapView = GMSMapView.mapWithFrame(self.view.bounds, camera: cam)
        
        mapView.buildingsEnabled = false
        mapView.myLocationEnabled = true
        
        //_mapView.padding = UIEdgeInsetsMake(60.0f, 10.0f, 60.0f, 10.0f);
        mapView.settings.myLocationButton = false
        mapView.settings.compassButton = false
        mapView.settings.tiltGestures = false
        mapView.settings.rotateGestures = false
        mapView.settings.consumesGesturesInView = false
        
        mapView.delegate = self
        
        let mainScreenScale = UIScreen.mainScreen().scale
        tileSize = Int(kTileSizePoints * mainScreenScale)
        pointDiameterSize = Int(kPointDiameterSizePoints * mainScreenScale)
        
        mapServer.getMapOptionsWithSuccess { response in
            logger.debug("got map options with success: \(response)")
            
            self.mapOptions = response as! RMBTMapOptions
            
            self.settingsBarButtonItem.enabled = true
            self.filterBarButtonItem.enabled = true
            self.toastBarButtonItem.enabled = true

            self.setupMapLayers()
            self.refresh()
        }
        
        // Setup toast (overlay) view
        toastView.hidden = true
        toastView.layer.cornerRadius = 6.0
        
        // Tapping the toast should hide it
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "toggleToast:")
        toastView.addGestureRecognizer(tapRecognizer)
        
        view.insertSubview(mapView, belowSubview: toastView)
        view.insertSubview(locateMeButton, aboveSubview: mapView)
        
        // If test coordinates were provided, show a blue untappable pin at those coordinates
        if let initialLocation = self.initialLocation {
            let marker: GMSMarker = GMSMarker(position: self.initialLocation.coordinate)
            // Approx. HUE_AZURE color from Android
            marker.icon = GMSMarker.markerImageWithColor(UIColor(red: 0.510, green: 0.745, blue: 0.984, alpha: 1)) // TODO: CONFIG
            marker.tappable = false
            marker.map = mapView
        }
    }
    
    ///
    private func setupMapLayers() {
        /*mapLayerShapes = GMSURLTileLayer { (x: UInt, y: UInt, zoom: UInt) -> NSURL! in
            return self.mapServer.tileURLForMapOverlayType(RMBTMapOptionsOverlayShapes.identifier, x: x, y: y, zoom: zoom, params: self.tileParamsDictionary)
        }
    
        mapLayerShapes.tileSize = tileSize
        mapLayerShapes.map = mapView
        mapLayerShapes.zIndex = 100*/
        
        //
        
        mapLayerHeatmap = GMSURLTileLayer { (x: UInt, y: UInt, zoom: UInt) -> NSURL! in
            return self.mapServer.tileURLForMapOverlayType(RMBTMapOptionsOverlayHeatmap.identifier, x: x, y: y, zoom: zoom, params: self.tileParamsDictionary)
        }
    
        mapLayerHeatmap.tileSize = tileSize
        mapLayerHeatmap.map = mapView
        mapLayerHeatmap.zIndex = 101
        
        //
        
        mapLayerPoints = GMSURLTileLayer { (x: UInt, y: UInt, zoom: UInt) -> NSURL! in
            return self.mapServer.tileURLForMapOverlayType(RMBTMapOptionsOverlayPoints.identifier, x: x, y: y, zoom: zoom, params: self.tileParamsDictionary)
        }
    
        mapLayerPoints.tileSize = tileSize
        mapLayerPoints.map = mapView
        mapLayerPoints.zIndex = 102
        
        //
        
        mapLayerRegions = GMSURLTileLayer { (x: UInt, y: UInt, zoom: UInt) -> NSURL! in
            var tileParams = ["shapetype": RMBTMapOptionsOverlayRegions.identifier] as NSMutableDictionary
            tileParams.addEntriesFromDictionary(self.tileParamsDictionary as [NSObject:AnyObject])
            
            return self.mapServer.tileURLForMapOverlayType(RMBTMapOptionsOverlayShapes.identifier, x: x, y: y, zoom: zoom, params: tileParams)
        }

        mapLayerRegions.tileSize = tileSize
        mapLayerRegions.map = mapView
        mapLayerRegions.zIndex = 103
        
        //
        
        mapLayerMunicipality = GMSURLTileLayer { (x: UInt, y: UInt, zoom: UInt) -> NSURL! in
            var tileParams = ["shapetype": RMBTMapOptionsOverlayMunicipality.identifier] as NSMutableDictionary
            tileParams.addEntriesFromDictionary(self.tileParamsDictionary as [NSObject:AnyObject])
            
            return self.mapServer.tileURLForMapOverlayType(RMBTMapOptionsOverlayShapes.identifier, x: x, y: y, zoom: zoom, params: tileParams)
        }
        
        mapLayerMunicipality.tileSize = tileSize
        mapLayerMunicipality.map = mapView
        mapLayerMunicipality.zIndex = 104
        
        //
        
        mapLayerSettlements = GMSURLTileLayer { (x: UInt, y: UInt, zoom: UInt) -> NSURL! in
            var tileParams = ["shapetype": RMBTMapOptionsOverlaySettlements.identifier] as NSMutableDictionary
            tileParams.addEntriesFromDictionary(self.tileParamsDictionary as [NSObject:AnyObject])
            
            return self.mapServer.tileURLForMapOverlayType(RMBTMapOptionsOverlayShapes.identifier, x: x, y: y, zoom: zoom, params: tileParams)
        }
        
        mapLayerSettlements.tileSize = tileSize
        mapLayerSettlements.map = mapView
        mapLayerSettlements.zIndex = 105
        
        //
        
        mapLayerWhitespots = GMSURLTileLayer { (x: UInt, y: UInt, zoom: UInt) -> NSURL! in
            var tileParams = ["shapetype": RMBTMapOptionsOverlayWhitespots.identifier] as NSMutableDictionary
            tileParams.addEntriesFromDictionary(self.tileParamsDictionary as [NSObject:AnyObject])
            
            return self.mapServer.tileURLForMapOverlayType(RMBTMapOptionsOverlayShapes.identifier, x: x, y: y, zoom: zoom, params: tileParams)
        }
        
        mapLayerWhitespots.tileSize = tileSize
        mapLayerWhitespots.map = mapView
        mapLayerWhitespots.zIndex = 106
    }
    
    ///
    private func deselectCurrentMarker() {
        if (mapMarker != nil) {
            mapMarker.map = nil
            mapView.selectedMarker = nil
            mapMarker = nil
        }
    }
    
    ///
    private func refresh() {
        tileParamsDictionary = mapOptions.activeSubtype.paramsDictionary().mutableCopy() as! NSMutableDictionary
        tileParamsDictionary.addEntriesFromDictionary([
            "size":             "\(tileSize)",//String(format: "%lu", tileSize),
            "point_diameter":   "\(pointDiameterSize)"//String(format: "%lu", pointDiameterSize)
        ])
        
        updateLayerVisibility()
        
        //mapLayerShapes.clearTileCache()
        mapLayerPoints.clearTileCache()
        mapLayerHeatmap.clearTileCache()
        
        let toastInfo = mapOptions.toastInfo()
        
        toastTitleLabel.text = toastInfo[RMBTMapOptionsToastInfoTitle]?.first
        
        toastKeysLabel.text = "\n".join(toastInfo[RMBTMapOptionsToastInfoKeys]!)
        toastValuesLabel.text = "\n".join(toastInfo[RMBTMapOptionsToastInfoValues]!)
        
        displayToast(true, withGenieEffect: false)
    }
    
    ///
    private func displayToast(state: Bool, withGenieEffect genie: Bool) {
        if (toastView.hidden != state) {
            return // already displayed/hidden
        }
        
        toastView.hidden = false
        
        if (!genie) {
            toastView.alpha = (state) ? 0.0 : 1.0
            toastView.transform = CGAffineTransformIdentity
        
            UIView.animateWithDuration(0.5, animations: {
                self.toastView.alpha = (state) ? 1.0 : 0.0
            }, completion: { finished in
                self.toastView.hidden = !state
            })
        
            if (state) {
                // autohide
                self.bk_performBlock({ sender in
                    self.displayToast(false, withGenieEffect: true)
                }, afterDelay: 3.0)
            }
        } else {
            //        self.toastBarButtonItem.enabled = NO;
            let buttonRect: CGRect = CGRectMake(320 - 40 - 10, 20, 40, 40)
        
            if (state) {
                self.toastView.genieOutTransitionWithDuration(0.5, startRect: buttonRect, startEdge: BCRectEdge.Bottom, completion: {
                    //                self.toastBarButtonItem.enabled = YES;
                })
            } else {
                toastView.genieInTransitionWithDuration(0.5, destinationRect: buttonRect, destinationEdge: BCRectEdge.Bottom, completion: {
                    self.toastView.hidden = true
                })
            }
        }
    }
    
// MARK: MapView delegate methods
    
    ///
    func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        // If we're not showing points, ignore this tap
        if (mapLayerPoints.map == nil) {
            return
        }
        
        mapServer.getMeasurementsAtCoordinate(coordinate, zoom: mapView.camera.zoom, params: mapOptions.activeSubtype.markerParamsDictionary()) { (response) -> () in
            let measurements = response as! [RMBTMapMeasurement]
            
            let measurement: RMBTMapMeasurement? = (measurements.count > 0) ? measurements[0] : nil // TODO: support multiple measurements at point?
            self.deselectCurrentMarker()
            
            if let m = measurement {
                var point: CGPoint = self.mapView.projection.pointForCoordinate(m.coordinate)
                point.y = point.y - 180
                
                let camera = GMSCameraUpdate.setTarget(self.mapView.projection.coordinateForPoint(point))
                self.mapView.animateWithCameraUpdate(camera)
                
                self.mapMarker = GMSMarker(position: m.coordinate)
                self.mapMarker.icon = self.emptyMarkerImage()
                self.mapMarker.userData = m
                self.mapMarker.appearAnimation = kGMSMarkerAnimationPop
                self.mapMarker.map = self.mapView
                self.mapView.selectedMarker = self.mapMarker
            }
        }
    }
    
    ///
    func mapView(mapView: GMSMapView!, markerInfoWindow marker: GMSMarker!) -> UIView! {
        return RMBTMapCalloutView.calloutViewWithMeasurement(marker.userData as! RMBTMapMeasurement)
    }
    
    ///
    func mapView(mapView: GMSMapView!, didTapInfoWindowOfMarker marker: GMSMarker!) {
        let m = marker.userData as! RMBTMapMeasurement
        
        mapServer.getURLStringForOpenTestUUID(m.openTestUUID, success: { response in
            let url = response as! String
            
            logger.debug("url: \(url)")
            //if (response != nil) {
            if (url != "nil") {
                self.presentModalBrowserWithURLString(url)
            } else {
                logger.debug("map open test uuid url is nil")
            }
        })
    }
    
    ///
    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
        updateLayerVisibility() // TODO: this is sometimes triggered too fast, leading to EXC_BAD_INSTRUCTION inside of 
                                // updateLayerVisibility. mostly occurs on slow internet connections
    }
    
// MARK: Layer visibility
    
    ///
    private func setLayer(layer: GMSTileLayer, hidden: Bool) {
        let state = (layer.map == nil)
        if (state == hidden) {
            return
        }
        
        layer.map = (hidden) ? nil : mapView
    }
    
    ///
    private func updateLayerVisibility() {
        if let overlay = mapOptions?.activeOverlay { // prevents EXC_BAD_INSTRUCTION happening sometimes because mapOptions are nil
        
            var heatmapVisible = false
            //var shapesVisible = false
            var pointsVisible = false
            
            var regionsVisible = false
            var municipalityVisible = false
            var settlementsVisible = false
            var whitespotsVisible = false
            
            //if (overlay == RMBTMapOptionsOverlayShapes) {
            //    shapesVisible = true
            /*} else */if (overlay == RMBTMapOptionsOverlayPoints) {
                pointsVisible = true
            } else if (overlay == RMBTMapOptionsOverlayHeatmap) {
                heatmapVisible = true
            } else if (overlay == RMBTMapOptionsOverlayAuto) {
                if (mapOptions.activeSubtype.type.identifier == "browser") {
                    // Shapes
                    //shapesVisible = true
                    regionsVisible = true // TODO: is this correct?
                } else {
                    heatmapVisible = true
                }
                
                pointsVisible = (mapView.camera.zoom >= RMBT_MAP_AUTO_TRESHOLD_ZOOM)
            } else if (overlay == RMBTMapOptionsOverlayRegions) {
                regionsVisible = true
            } else if (overlay == RMBTMapOptionsOverlayMunicipality) {
                municipalityVisible = true
            } else if (overlay == RMBTMapOptionsOverlaySettlements) {
                settlementsVisible = true
            } else if (overlay == RMBTMapOptionsOverlayWhitespots) {
                whitespotsVisible = true
            } else {
                //NSParameterAssert(NO); // does not work when commented in, probably because of new google maps framework
                logger.debug("\(overlay)") // TODO: possible bug because overlay is now null
            }
            
            setLayer(mapLayerHeatmap, hidden: !heatmapVisible)
            setLayer(mapLayerPoints, hidden: !pointsVisible)
            //setLayer(mapLayerShapes, hidden: !shapesVisible)
            
            setLayer(mapLayerRegions, hidden: !regionsVisible)
            setLayer(mapLayerMunicipality, hidden: !municipalityVisible)
            setLayer(mapLayerSettlements, hidden: !settlementsVisible)
            setLayer(mapLayerWhitespots, hidden: !whitespotsVisible)
        }
    }
    
// MARK: Segues
    
    ///
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "show_map_options" || segue.identifier == "show_map_filter") {
            let optionsVC = segue.destinationViewController as! RMBTMapSubViewController
            optionsVC.delegate = self
            optionsVC.mapOptions = mapOptions
        }
    }
    
    ///
    func mapSubViewController(viewController: RMBTMapSubViewController, willDisappearWithChange change: Bool) {
        if (change) {
            logger.debug("Map options changed, refreshing...")
            mapOptions.saveSelection()
            refresh()
        }
        
        switch(mapOptions.mapViewType) {
            case .Hybrid:       mapView.mapType = kGMSTypeHybrid
            case .Satellite:    mapView.mapType = kGMSTypeSatellite
            default:            mapView.mapType = kGMSTypeNormal
        }
    }
    
    ///
    private func togglePopGestureRecognizer(state: Bool) {
        // Temporary fix for http://code.google.com/p/gmaps-api-issues/issues/detail?id=5772 on iOS7
        navigationController?.interactivePopGestureRecognizer.enabled = state
    }
    
// MARK: Button actions
    
    ///
    func showMapOptions() {
        performSegueWithIdentifier("show_map_options", sender: self)
    }
    
    ///
    func showMapFilter() {
        performSegueWithIdentifier("show_map_filter", sender: self)
    }
    
    ///
    @IBAction func toggleToast(sender: AnyObject) {
        displayToast(toastView.hidden, withGenieEffect: true)
    }
    
    ///
    @IBAction func locateMe(sender: AnyObject) {
        if (RMBTLocationTracker.sharedTracker.location == nil) {
            return
        }
        
        let camera = GMSCameraUpdate.setTarget(mapView.myLocation.coordinate)
        mapView.animateWithCameraUpdate(camera)
    }
    
// MARK: Helpers
    
    ///
    private func emptyMarkerImage() -> UIImage { // TODO: dispatch_once
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, 1), false, 0.0)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
    
// MARK: SWRevealViewControllerDelegate
    
    ///
    func revealControllerPanGestureBegan(revealController: SWRevealViewController!) {
        mapView.settings.setAllGesturesEnabled(false)
    }
    
    ///
    func revealControllerPanGestureEnded(revealController: SWRevealViewController!) {
        mapView.settings.setAllGesturesEnabled(true)
    }
    
    ///
    func revealController(revealController: SWRevealViewController!, didMoveToPosition position: FrontViewPosition) {
        let isPosLeft = position == .Left
        
        mapView.settings.setAllGesturesEnabled(isPosLeft)
        
        let revealVC = revealViewController()
        
        if (isPosLeft) {
            view.removeGestureRecognizer(revealVC.panGestureRecognizer())
            view.addGestureRecognizer(revealVC.edgeGestureRecognizer())
        } else {
            if (view != nil && revealVC != nil && revealVC.edgeGestureRecognizer() != nil) { // fix for crash of build 3, version 0.1.0
                view.removeGestureRecognizer(revealVC.edgeGestureRecognizer())
                view.addGestureRecognizer(revealVC.panGestureRecognizer())
            }
        }
    }

// MARK: state preservation / restoration
    
    ///
    override func encodeRestorableStateWithCoder(coder: NSCoder) {
        logger.debug("\(__FUNCTION__)")
        
        super.encodeRestorableStateWithCoder(coder)
    }
    
    ///
    override func decodeRestorableStateWithCoder(coder: NSCoder) {
        logger.debug("\(__FUNCTION__)")
        
        super.decodeRestorableStateWithCoder(coder)
    }
    
    ///
    override func applicationFinishedRestoringState() {
        logger.debug("\(__FUNCTION__)")

        revealViewController().delegate = self
    }
}
