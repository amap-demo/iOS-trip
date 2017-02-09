//
//  DDSearchViewController.swift
//  iOS_trip
//
//  Created by liubo on 2017/1/23.
//  Copyright © 2017年 yours. All rights reserved.
//

import Foundation

protocol DDSearchViewControllerDelegate {
    func searchViewController(_ searchViewController: DDSearchViewController, didSelectLocation location: DDLocation)
}

class DDSearchViewController: UIViewController, UISearchBarDelegate, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource {
    var delegate: DDSearchViewControllerDelegate?
    
    var text = ""
    var city = ""
    var locations = Array<DDLocation>()
    
    var searchController = UISearchController(searchResultsController: nil)
    var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        initTableView()
        initSearchBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if text.characters.count > 0 {
            searchController.searchBar.placeholder = text
            searchTipsWithKey(text)
        }
        else {
            perform(#selector(self.showKeyboard), with: nil, afterDelay: 0.1)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        searchController.isActive = false
    }
    
    func showKeyboard() {
        searchController.searchBar.becomeFirstResponder()
    }
    
    //MARK: - Initialization
    
    func initTableView() {
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height), style: .plain)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
    }
    
    func initSearchBar() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "请输入关键字"
        searchController.searchBar.sizeToFit()
        
        navigationItem.titleView = searchController.searchBar
    }
    
    //MARK: - Helpers
    
    func searchTipsWithKey(_ key: String) {
        if key.characters.count == 0 {
            return
        }
        
        let request = AMapPOIKeywordsSearchRequest()
        request.requireExtension = true
        request.keywords = key
        
        if self.city.characters.count > 0 {
            request.city = self.city
        }
        
        DDSearchManager.Shared.searchForRequest(request: request, completionBlock: {[weak self] (request: AMapSearchObject, response: AMapSearchObject?, error: NSError?) in
            if let error = error {
                let error = error as NSError
                NSLog("error :%@", error)
                return
            }
            else {
                self?.locations.removeAll()
                
                guard let aResponse = response as? AMapPOISearchResponse else {
                    return
                }
                
                for obj in aResponse.pois {
                    let location = DDLocation()
                    location.name = obj.name
                    location.coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(obj.location.latitude), CLLocationDegrees(obj.location.longitude))
                    location.address = obj.address
                    location.cityCode = obj.citycode
                    self?.locations.append(location)
                }
                
                self?.tableView.reloadData()
            }
        })
    }
    
    //MARK: - UISearchResultsUpdating
    
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        tableView.isHidden = !searchController.isActive
        
        guard let str = searchController.searchBar.text else {
            return
        }
        
        searchTipsWithKey(str)
        
        if searchController.isActive && str.characters.count > 0 {
            searchController.searchBar.placeholder = str
        }
    }
    
    //MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "cellIdentifier"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }
        
        let location = locations[indexPath.row]
        
        cell?.textLabel?.text = location.name
        cell?.detailTextLabel?.text = location.address
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchController.isActive = false
        tableView.deselectRow(at: indexPath, animated: false)
        
        let location = locations[indexPath.row]
        if delegate != nil {
            delegate?.searchViewController(self, didSelectLocation: location)
        }
    }
}
