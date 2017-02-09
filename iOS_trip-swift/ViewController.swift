//
//  ViewController.swift
//  iOS_trip-swift
//
//  Created by liubo on 2017/1/22.
//  Copyright © 2017年 yours. All rights reserved.
//

import UIKit

enum DDState: Int {
    case Init               //初始状态，显示选择终点
    case ConfirmDestination //选定起始点和目的地，显示马上叫车
    case CallTaxi           //正在叫车，显示我已上车
    case OnTaxi             //正在车上状态，显示支付
    case FinishPay          //到达终点，显示评价
}

let locationViewMargin = 20.0
let buttonMargin = 20.0
let buttonHeight = 40.0
let appName = "德德用车"

class ViewController: UIViewController, MAMapViewDelegate, DDSearchViewControllerDelegate, DDDriverManagerDelegate, DDLocationViewDelegate {
    
    var mapView: MAMapView!
    var messageView: UIView?
    
    var driverManager = DDDriverManager()
    var drivers: Array<MAPointAnnotation>?
    var selectedDriver = CustomMovingAnnotation()
    
    let buttonAction = UIButton(type: .custom)
    let buttonCancel = UIButton(type: .custom)
    let buttonLocating = UIButton(type: .custom)
    
    var currentSearchLocation = -1
    var needsFirstLocating = true
    
    var currentLocation: DDLocation?
    var destinationLocation: DDLocation?
    var state = DDState.Init
    
    var locationView: DDLocationView?
    var isLocating = false
    
    //MARK: - search
    
    func searchReGeocodeWithCoordinate(_ coordinate: CLLocationCoordinate2D) {
        let regeo = AMapReGeocodeSearchRequest()
        regeo.location = AMapGeoPoint.location(withLatitude: CGFloat(coordinate.latitude), longitude: CGFloat(coordinate.longitude))
        regeo.requireExtension = true
        
        DDSearchManager.Shared.searchForRequest(request: regeo, completionBlock: {[weak self] (request: AMapSearchObject, response: AMapSearchObject?, error: NSError?) in
            
            if let error = error {
                let error = error as NSError
                NSLog("error :%@", error)
                return
            }
            else {
                guard let regeoResponse = response as? AMapReGeocodeSearchResponse else {
                    return
                }
                
                if regeoResponse.regeocode != nil {
                    if regeoResponse.regeocode.pois.count > 0 {
                        let poi = regeoResponse.regeocode.pois[0]
                        
                        self?.currentLocation?.coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(poi.location.latitude), CLLocationDegrees(poi.location.longitude))
                        self?.currentLocation?.name = poi.name
                        self?.currentLocation?.address = poi.address
                    }
                    else {
                        self?.currentLocation?.coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(regeoResponse.regeocode.addressComponent.streetNumber.location.latitude), CLLocationDegrees(regeoResponse.regeocode.addressComponent.streetNumber.location.longitude))
                        
                        self?.currentLocation?.name = String(format: "%@%@%@%@%@", regeoResponse.regeocode.addressComponent.township, regeoResponse.regeocode.addressComponent.neighborhood, regeoResponse.regeocode.addressComponent.streetNumber.street, regeoResponse.regeocode.addressComponent.streetNumber.number, regeoResponse.regeocode.addressComponent.building)
                        
                        self?.currentLocation?.address = regeoResponse.regeocode.addressComponent.citycode
                    }
                    
                    self?.currentLocation?.cityCode = regeoResponse.regeocode.addressComponent.citycode
                    self?.isLocating = false
                }
                
            }
        })
    }
    
    //MARK: - mapView delegate
    
    func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
        if needsFirstLocating && updatingLocation {
            actionLocating(sender: buttonLocating)
            needsFirstLocating = false
        }
    }
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        
        /* 自定义userLocation对应的annotationView. */
        if annotation is MAUserLocation {
            let userLocationStyleReuseIndetifier = "userLocationReuseIndetifier"
            
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: userLocationStyleReuseIndetifier)
            if annotationView == nil {
                annotationView = MAAnnotationView(annotation: annotation, reuseIdentifier: userLocationStyleReuseIndetifier)
            }
            
            annotationView?.image = UIImage(named: "icon_passenger")
            annotationView?.centerOffset = CGPoint(x: 0, y: -22)
            annotationView?.canShowCallout = true
            
            return annotationView!
        }
        
        if annotation is MAPointAnnotation {
            let pointReuseIndetifier = "driverReuseIndetifier"
            
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: pointReuseIndetifier)
            if annotationView == nil {
                annotationView = MAAnnotationView(annotation: annotation, reuseIdentifier: pointReuseIndetifier)
            }
            
            annotationView?.image = UIImage(named: "icon_taxi")
            annotationView?.centerOffset = CGPoint(x: 0, y: -22)
            annotationView?.canShowCallout = true
            
            return annotationView!
        }
        
        return nil
    }
    
    //MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = appName
        
        mapView = MAMapView(frame: view.bounds)
        mapView.showsCompass = false
        mapView.isShowsIndoorMap = false
        mapView.isRotateEnabled = false
        mapView.showsScale = false
        
        mapView.customizeUserLocationAccuracyCircleRepresentation = true
        view.addSubview(mapView)
        
        driverManager.delegate = self
        
        buttonAction.backgroundColor = UIColor(colorLiteralRed: 13.0/255.0, green: 79.0/255.0, blue: 139.0/255/0, alpha: 1.0)
        buttonAction.layer.cornerRadius = 6
        buttonAction.layer.shadowColor = UIColor.black.cgColor
        buttonAction.layer.shadowOffset = CGSize(width: 1, height: 1)
        buttonAction.layer.shadowOpacity = 0.5
        
        view.addSubview(buttonAction)
        
        buttonCancel.backgroundColor = UIColor(white: 0.25, alpha: 1.0)
        buttonCancel.layer.cornerRadius = 6
        buttonCancel.layer.shadowColor = UIColor.black.cgColor
        buttonCancel.layer.shadowOffset = CGSize(width: 1, height: 1)
        buttonCancel.layer.shadowOpacity = 0.5
        buttonCancel.setTitle("取消", for: .normal)
        buttonCancel.addTarget(self, action: #selector(self.actionCancel(sender:)), for: .touchUpInside)
        
        view.addSubview(buttonCancel)
        
        buttonLocating.setImage(UIImage(named: "location"), for: .normal)
        buttonLocating.backgroundColor = UIColor.white
        buttonLocating.layer.cornerRadius = 6
        buttonLocating.layer.shadowColor = UIColor.black.cgColor
        buttonLocating.layer.shadowOffset = CGSize(width: 1, height: 1)
        buttonLocating.layer.shadowOpacity = 0.5
        buttonLocating.addTarget(self, action: #selector(self.actionLocating(sender:)), for: .touchUpInside)
        
        view.addSubview(buttonLocating)
        
        currentLocation = DDLocation()
        locationView = DDLocationView(frame: CGRect(x: locationViewMargin, y: 66 + locationViewMargin, width: Double(view.bounds.width) - locationViewMargin * 2, height: 44))
        locationView?.delegate = self
        locationView?.startLocation = currentLocation
        
        view.addSubview(locationView!)
        
        setState(.Init)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mapView.delegate = self
        mapView.showsUserLocation = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        mapView.showsUserLocation = false
        mapView.delegate = nil
    }
    
    override func viewDidLayoutSubviews() {
        mapView.frame = view.bounds
        
        buttonCancel.frame = CGRect(x: buttonMargin, y: Double(view.bounds.height) - buttonMargin - buttonHeight, width: Double(view.bounds.maxX) - buttonMargin * 2, height: buttonHeight)
        
        buttonAction.frame = CGRect(x: buttonMargin, y: Double(buttonCancel.frame.minY) - buttonMargin/2.0 - buttonHeight, width: Double(view.bounds.maxX) - buttonMargin*2, height: buttonHeight)
        
        buttonLocating.frame = CGRect(x: buttonMargin, y: Double(buttonAction.frame.minY) - buttonMargin - buttonHeight, width: buttonHeight, height: buttonHeight)
    }
    
    //MARK: - Action
    
    func actionAddEnd(sender: UIButton) {
        NSLog("actionAddEnd")
        
        if currentLocation?.cityCode.characters.count == 0 {
            NSLog("the city have not been located")
            return
        }
        
        currentSearchLocation = 1
        let searchController = DDSearchViewController()
        searchController.delegate = self
        searchController.city = (currentLocation?.cityCode)!
        
        navigationController?.pushViewController(searchController, animated: true)
    }
    
    func actionCancel(sender: UIButton) {
        NSLog("actionCancel")
        setState(.Init)
    }
    
    func actionCallTaxi(sender: UIButton) {
        NSLog("actionCallTaxi")
        if currentLocation != nil && destinationLocation != nil {
            let request = DDTaxiCallRequest(start: currentLocation, to: destinationLocation)
            _ = driverManager.callTaxiWithRequest(request: request!)
            
            messageView = mapView.forMessage("正在呼叫司机...", title: nil, image: nil)
            messageView?.center = mapView.centerPoint(forPosition: "center", withToast: messageView)
            mapView.addSubview(messageView!)
        }
    }
    
    func actionLocating(sender: UIButton) {
        NSLog("actionLocating")
        
        // 只有初始状态下才可以进行定位。
        if self.state != .Init {
            view.makeToast("重新请求需先取消用车", duration: 1.0, position: "center")
            return
        }
        
        if !isLocating {
            isLocating = true
            
            searchReGeocodeWithCoordinate(mapView.userLocation.location.coordinate)
            resetMapToCenter(mapView.userLocation.location.coordinate)
            updatingDrivers()
        }
    }
    
    func actionOnTaxi(sender: UIButton) {
        NSLog("actionOnTaxi")
        setState(.OnTaxi)
    }
    
    func actionOnPay(sender: UIButton) {
        NSLog("actionOnPay")
        setState(.FinishPay)
    }
    
    func actionOnEvaluate(sender: UIButton) {
        NSLog("actionOnEvaluate")
        setState(.Init)
    }
    
    //MARK: - drivers
    
    func updatingDrivers() {
        let rect = MAMapRectForCoordinateRegion(MACoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000.0, 1000.0))
        
        if rect.size.width > 0 && rect.size.height > 0 {
            driverManager.searchDriversWithinMapRect(mapRect: rect)
        }
    }
    
    //MARK: - driversManager delegate
    
    func searchDone(inMapRect mapRect: MAMapRect, withDriversResult drivers: Array<DDDriver>, timestamp: TimeInterval) {
        mapView.removeAnnotations(self.drivers)
        
        var currDrivers = Array<MAPointAnnotation>()
        for obj in drivers {
            let driver = MAPointAnnotation()
            driver.coordinate = obj.coordinate
            driver.title = obj.idInfo
            currDrivers.append(driver)
        }
        
        mapView.addAnnotations(currDrivers)
        
        self.drivers = currDrivers
    }
    
    func callTaxiDone(withRequest request: DDTaxiCallRequest, taxi: DDDriver) {
        mapView.removeAnnotations(drivers)
        drivers = nil
        
        selectedDriver = CustomMovingAnnotation()
        selectedDriver.coordinate = taxi.coordinate
        selectedDriver.title = taxi.idInfo
        mapView.addAnnotation(selectedDriver)
        
        messageView?.removeFromSuperview()
        mapView.makeToast(String(format: "已选择司机%@", taxi.idInfo), duration: 0.5, position: "center")
        
        setState(.CallTaxi)
    }
    
    func onUpdatingLocations(_ locations: Array<CLLocation>, forDriver deiver: DDDriver) {
        if locations.count > 0 {
            var locs = Array<CLLocationCoordinate2D>()
            for obj in locations {
                locs.append(obj.coordinate)
            }
            
            selectedDriver.addMoveAnimation(withKeyCoordinates: &locs, count: UInt(locations.count), withDuration: 5.0, withName: nil, completeCallback: nil)
        }
    }
    
    //MARK: - DDSearchViewControllerDelegate
    
    func searchViewController(_ searchViewController: DDSearchViewController, didSelectLocation location: DDLocation) {
        _ = navigationController?.popViewController(animated: true)
        if currentSearchLocation == 0 {
            currentLocation = location
            locationView?.startLocation = location
        }
        else if currentSearchLocation == 1 {
            destinationLocation = location
            locationView?.endLocation = location
        }
        currentSearchLocation = -1
        
        // 起点终点都确认
        if currentLocation != nil && destinationLocation != nil {
            setState(.ConfirmDestination)
        }
    }
    
    //MARK: - Utility
    
    func requestPathInfo() {
        //检索所需费用
        let navi = AMapDrivingRouteSearchRequest()
        navi.requireExtension = true
        
        guard let currentLocation = self.currentLocation else {
            return
        }
        
        guard let destinationLocation = self.destinationLocation else {
            return
        }
        
        /* 出发点. */
        navi.origin = AMapGeoPoint.location(withLatitude: CGFloat(currentLocation.coordinate.latitude), longitude: CGFloat(currentLocation.coordinate.longitude))
        
        /* 目的地. */
        navi.destination = AMapGeoPoint.location(withLatitude: CGFloat(destinationLocation.coordinate.latitude), longitude: CGFloat(destinationLocation.coordinate.longitude))
        
        DDSearchManager.Shared.searchForRequest(request: navi, completionBlock: {[weak self](request: AMapSearchObject, response: AMapSearchObject?, error: NSError?) in
            
            guard let naviResponse = response as? AMapRouteSearchResponse else {
                return
            }
            
            if naviResponse.route == nil {
                self?.locationView?.info = "获取路径失败"
                return
            }
            
            guard let path = naviResponse.route.paths.first else {
                return
            }
            self?.locationView?.info = String(format: "预估费用%.2f元  距离%.1f km  时间%.1f分钟", naviResponse.route.taxiCost, Double(path.distance)/1000.0, Double(path.duration)/60.0)
            
        })
    }
    
    func setState(_ state: DDState) {
        self.state = state
        switch self.state {
        case .Init:
            reset()
            buttonAction.setTitle("选择终点", for: .normal)
            buttonAction.removeTarget(self, action: nil, for: .touchUpInside)
            buttonAction.addTarget(self, action: #selector(self.actionAddEnd(sender:)), for: .touchUpInside)
        case .ConfirmDestination:
            requestPathInfo()
            buttonAction.setTitle("马上叫车", for: .normal)
            buttonAction.removeTarget(self, action: nil, for: .touchUpInside)
            buttonAction.addTarget(self, action: #selector(self.actionCallTaxi(sender:)), for: .touchUpInside)
        case .CallTaxi:
            buttonAction.setTitle("我已上车", for: .normal)
            buttonAction.removeTarget(self, action: nil, for: .touchUpInside)
            buttonAction.addTarget(self, action: #selector(self.actionOnTaxi(sender:)), for: .touchUpInside)
        case .OnTaxi:
            buttonAction.setTitle("支付", for: .normal)
            buttonAction.removeTarget(self, action: nil, for: .touchUpInside)
            buttonAction.addTarget(self, action: #selector(self.actionOnPay(sender:)), for: .touchUpInside)
        case .FinishPay:
            buttonAction.setTitle("评价", for: .normal)
            buttonAction.removeTarget(self, action: nil, for: .touchUpInside)
            buttonAction.addTarget(self, action: #selector(self.actionOnEvaluate(sender:)), for: .touchUpInside)
        }
        
        // 设置locationView是否响应交互。
        locationView?.isUserInteractionEnabled = (state.rawValue < DDState.CallTaxi.rawValue)
        buttonCancel.isHidden = (state == .Init)
    }
    
    func reset() {
        mapView.removeAnnotations(drivers)
        drivers = nil
        mapView.removeAnnotation(selectedDriver)
        
        destinationLocation = nil
        locationView?.endLocation = nil
        locationView?.info = nil
    }
    
    func resetMapToCenter(_ coordinate: CLLocationCoordinate2D) {
        // 使得userLocationView在最前。
        mapView.selectAnnotation(mapView.userLocation, animated: false)
        
        mapView.centerCoordinate = coordinate
        mapView.zoomLevel = 16.1
    }
    
    //MARK: - DDLocationViewDelegate
    
    func didClickStartLocation(_ locationView: DDLocationView!) {
        currentSearchLocation = 0
        let searchController = DDSearchViewController()
        searchController.delegate = self
        searchController.text = locationView.startLocation.name
        searchController.city = locationView.startLocation.cityCode
        
        navigationController?.pushViewController(searchController, animated: true)
    }
    
    func didClickEndLocation(_ locationView: DDLocationView!) {
        currentSearchLocation = 1
        let searchController = DDSearchViewController()
        searchController.delegate = self
        searchController.text = locationView.endLocation.name
        searchController.city = locationView.endLocation.cityCode
        
        navigationController?.pushViewController(searchController, animated: true)
    }

}

