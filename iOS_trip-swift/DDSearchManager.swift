//
//  DDSearchManager.swift
//  iOS_trip
//
//  Created by liubo on 2017/1/23.
//  Copyright © 2017年 yours. All rights reserved.
//

import Foundation

typealias DDSearchCompletionBlock = (_ request: AMapSearchObject, _ response: AMapSearchObject?, _ error: NSError?) -> Void;

class DDSearchManager: NSObject, AMapSearchDelegate {
    let search = AMapSearchAPI()!
    var mapTable = NSMapTable<AnyObject, AnyObject>(keyOptions: [.strongMemory], valueOptions: [.copyIn])
    
    public static let Shared = DDSearchManager()
    private override init(){
        super.init()
        
        search.delegate = self
    }
    
    func searchForRequest(request: AMapSearchObject, completionBlock: DDSearchCompletionBlock) {
        if request is AMapPOIKeywordsSearchRequest {
            search.aMapPOIKeywordsSearch(request as! AMapPOIKeywordsSearchRequest)
        }
        else if request is AMapDrivingRouteSearchRequest {
            search.aMapDrivingRouteSearch(request as! AMapDrivingRouteSearchRequest)
        }
        else if request is AMapInputTipsSearchRequest {
            search.aMapInputTipsSearch(request as! AMapInputTipsSearchRequest)
        }
        else if request is AMapGeocodeSearchRequest {
            search.aMapGeocodeSearch(request as! AMapGeocodeSearchRequest)
        }
        else if request is AMapReGeocodeSearchRequest {
            search.aMapReGoecodeSearch(request as! AMapReGeocodeSearchRequest)
        }
        else {
            NSLog("unsupported request")
            return
        }
        
        mapTable.setObject(completionBlock as AnyObject?, forKey: request)
    }
    
    func performBlock(withRequest request: AMapSearchObject, withResponse response: AMapSearchObject) {
        guard let block = mapTable.object(forKey: request) as? DDSearchCompletionBlock else {
            return
        }
        
        block(request, response, nil)
        
        mapTable.removeObject(forKey: request)
    }
    
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        guard let block = mapTable.object(forKey: request as AnyObject?) as? DDSearchCompletionBlock else {
            return
        }
        
        block(request as! AMapSearchObject, nil, error as NSError?)
        
        mapTable.removeObject(forKey: request as AnyObject?)
    }
    
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        performBlock(withRequest: request, withResponse: response)
    }
    
    func onRouteSearchDone(_ request: AMapRouteSearchBaseRequest!, response: AMapRouteSearchResponse!) {
        performBlock(withRequest: request, withResponse: response)
    }
    
    func onInputTipsSearchDone(_ request: AMapInputTipsSearchRequest!, response: AMapInputTipsSearchResponse!) {
        performBlock(withRequest: request, withResponse: response)
    }
    
    func onGeocodeSearchDone(_ request: AMapGeocodeSearchRequest!, response: AMapGeocodeSearchResponse!) {
        performBlock(withRequest: request, withResponse: response)
    }
    
    func onReGeocodeSearchDone(_ request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
        performBlock(withRequest: request, withResponse: response)
    }
}
