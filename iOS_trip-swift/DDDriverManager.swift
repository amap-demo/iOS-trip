//
//  DDDriverManager.swift
//  iOS_trip
//
//  Created by liubo on 2017/1/23.
//  Copyright © 2017年 yours. All rights reserved.
//

import Foundation

protocol DDDriverManagerDelegate {
    func searchDone(inMapRect mapRect: MAMapRect, withDriversResult drivers: Array<DDDriver>, timestamp: TimeInterval)
    func callTaxiDone(withRequest request: DDTaxiCallRequest, taxi: DDDriver)
    func onUpdatingLocations(_ locations: Array<CLLocation>, forDriver deiver: DDDriver)
}

class DDDriverManager {
    var delegate: DDDriverManagerDelegate?
    
    var currentRequest: DDTaxiCallRequest!
    var selectDriver: DDDriver?
    
    var driverPath: Array<Array<CLLocation>>?
    var subpathIdx: Int = 0
    
    func searchDriversWithinMapRect(mapRect: MAMapRect) {
        let randCount = arc4random() % 30 + 10
        
        var drivers = Array<DDDriver>()
        for _ in 0..<randCount {
            let driver = DDDriver(id: "京B****", coordinate: randomPointInMapRect(mapRect: mapRect))!
            
            drivers.append(driver)
        }
        
        self.delegate?.searchDone(inMapRect: mapRect, withDriversResult: drivers, timestamp: NSDate.timeIntervalSinceReferenceDate)
    }
    
    func callTaxiWithRequest(request: DDTaxiCallRequest) -> Bool {
        
        guard request.start != nil, request.end != nil else {
            return false
        }
        
        currentRequest = request
        
        let startAround = MAMapRectForCoordinateRegion(MACoordinateRegionMakeWithDistance(currentRequest.start.coordinate, 500.0, 500.0))
        
        let driverLocation = randomPointInMapRect(mapRect: startAround)
        NSLog("driverLocation : %f %f", driverLocation.latitude, driverLocation.longitude)
        selectDriver = DDDriver(id: "京B****", coordinate: driverLocation)
        
        let deadlineTime = DispatchTime.now() + .seconds(1)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) { [weak self] in
            self?.delegate?.callTaxiDone(withRequest: (self?.currentRequest)!, taxi: (self?.selectDriver)!)
            
            self?.startUpdateLocationForDriver(driver: (self?.selectDriver)!)
        }
        
        return true
    }
    
    func startUpdateLocationForDriver(driver: DDDriver) {
        searchPathFrom(driver.coordinate, to: currentRequest.start.coordinate)
    }
    
    func searchPathFrom(_ from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) {
        let navi = AMapDrivingRouteSearchRequest()
        navi.requireExtension = true
        
        navi.origin = AMapGeoPoint.location(withLatitude: CGFloat(from.latitude), longitude: CGFloat(from.longitude))
        navi.destination = AMapGeoPoint.location(withLatitude: CGFloat(to.latitude), longitude: CGFloat(to.longitude))
        
        DDSearchManager.Shared.searchForRequest(request: navi) { [weak self] (request: AMapSearchObject, response: AMapSearchObject?, error: NSError?) in
            
            guard let naviResponse = response as? AMapRouteSearchResponse else {
                return
            }
            
            guard let naviResponseRoute = naviResponse.route else {
                return
            }
            
            NSLog("%@", naviResponse)
            
            let naviRoute = MANaviRoute(path: naviResponseRoute.paths[0])
            
            self?.driverPath = naviRoute?.path as? Array<Array<CLLocation>>
            self?.subpathIdx = 0
            
            let timer = Timer.scheduledTimer(timeInterval: 1.0, target: self!, selector: #selector(self!.onUpdatingLocation), userInfo: nil, repeats: true)
            timer.fire()
        }
    }
    
    @objc func onUpdatingLocation() {
        
        guard let driverPath = driverPath, let selectDriver = selectDriver else {
            return
        }
        
        if subpathIdx < driverPath.count {
            delegate?.onUpdatingLocations(driverPath[subpathIdx], forDriver: selectDriver)
            subpathIdx += 1
        }
    }
    
    func randomPointInMapRect(mapRect: MAMapRect) -> CLLocationCoordinate2D {
        var result = MAMapPoint()
        result.x = mapRect.origin.x + Double(Int(arc4random()) % Int(mapRect.size.width))
        result.y = mapRect.origin.y + Double(Int(arc4random()) % Int(mapRect.size.height))
        
        return MACoordinateForMapPoint(result)
    }
    
}
