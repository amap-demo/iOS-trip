//
//  DDSearchViewController.m
//  TripDemo
//
//  Created by xiaoming han on 15/4/3.
//  Copyright (c) 2015年 AutoNavi. All rights reserved.
//

#import "DDSearchViewController.h"
#import "DDLocation.h"
#import "DDSearchManager.h"

@interface DDSearchViewController ()<UISearchBarDelegate, UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *locations;

@end

@implementation DDSearchViewController

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _text = @"";
        _city = @"";
        _locations = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initTableView];
    [self initSearchBar];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.text.length > 0)
    {
        self.searchController.searchBar.placeholder = self.text;
        [self searchTipsWithKey:self.text];
    }
    else
    {
        [self performSelector:@selector(showKeyboard) withObject:nil afterDelay:0.1];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.searchController.active = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSLog(@"%s", __func__);
}

- (void)showKeyboard
{
    [self.searchController.searchBar becomeFirstResponder];
}

#pragma mark - Initialization

- (void)initSearchBar
{
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    
    self.searchController.searchBar.delegate = self;
    self.searchController.searchBar.placeholder = @"请输入关键字";
    [self.searchController.searchBar sizeToFit];
    
    self.navigationItem.titleView = self.searchController.searchBar;
}

- (void)initTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
}

#pragma mark - Helpers

- (void)searchTipsWithKey:(NSString *)key
{
    if (key.length == 0)
    {
        return;
    }

    AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
    request.requireExtension = YES;
    request.keywords = key;
    
    if (self.city.length > 0)
    {
        request.city = self.city;
    }
    
    __weak __typeof(&*self) weakSelf = self;
    [[DDSearchManager sharedInstance] searchForRequest:request completionBlock:^(id request, id response, NSError *error) {
        if (error)
        {
            NSLog(@"error :%@", error);
        }
        else
        {
            [weakSelf.locations removeAllObjects];
            
            AMapPOISearchResponse *aResponse = (AMapPOISearchResponse *)response;
            [aResponse.pois enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL *stop)
             {
                 DDLocation *location = [[DDLocation alloc] init];
                 location.name = obj.name;
                 location.coordinate = CLLocationCoordinate2DMake(obj.location.latitude, obj.location.longitude);
                 location.address = obj.address;
                 location.cityCode = obj.citycode;
                 [weakSelf.locations addObject:location];
             }];
            
            [weakSelf.tableView reloadData];
        }
    }];
}

#pragma mark - UISearchResultsUpdating

- (void)didPresentSearchController:(UISearchController *)searchController
{
    [searchController.searchBar becomeFirstResponder];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    self.tableView.hidden = !searchController.isActive;
    [self searchTipsWithKey:searchController.searchBar.text];
    
    if (searchController.isActive && searchController.searchBar.text.length > 0)
    {
        searchController.searchBar.placeholder = searchController.searchBar.text;
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.locations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellIdentifier];
    }
    
    DDLocation *location = self.locations[indexPath.row];
    
    cell.textLabel.text = location.name;
    cell.detailTextLabel.text = location.address;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.searchController.active = NO;
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    DDLocation *location = self.locations[indexPath.row];
    if (_delegate && [_delegate respondsToSelector:@selector(searchViewController:didSelectLocation:)])
    {
        [_delegate searchViewController:self didSelectLocation:location];
    }
}

@end
