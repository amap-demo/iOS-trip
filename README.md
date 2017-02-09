iOS-trip
========================

类似滴滴叫车的功能演示

### 前述

- [高德官方网站申请key](http://id.amap.com/?ref=http%3A%2F%2Fapi.amap.com%2Fkey%2F).
- 阅读[参考手册](http://api.amap.com/Public/reference/iOS%20API%20v2_3D/).
- 工程基于iOS 3D地图SDK实现
- 运行demo请先执行pod install --repo-update 安装依赖库，完成后打开.xcworkspace 文件

### 核心类/接口
| 类    | 接口  | 说明   | 版本  |
| -----|:-----:|:-----:|:-----:|
| DDDriverManager | - (void)searchDriversWithinMapRect:(MAMapRect)mapRect; | 模拟获取司机数据 | n/a |
| DDDriverManager | - (BOOL)callTaxiWithRequest:(DDTaxiCallRequest *)request; | 模拟发起用车请求 | n/a |
| DDSearchManager | - (void)searchForRequest:(id)request completionBlock:(DDSearchCompletionBlock)block; | 模拟搜索目的地 | n/a |
| CustomMovingAnnotation | - (void)addMoveAnimationWithKeyCoordinates:count:duration:name:completeCallback | 继承自MAAnimatedAnnotation，为了实现汽车图标的平滑移动 | 4.5.0 |


### 核心难点
`Objective-C`
```
/**
*  司机相关管理类。获取司机数据、发送用车请求等。
*/
@interface DDDriverManager : NSObject

@property (nonatomic, weak) id<DDDriverManagerDelegate> delegate;

//根据mapRect取司机数据
- (void)searchDriversWithinMapRect:(MAMapRect)mapRect;

//发送用车请求：起点终点
- (BOOL)callTaxiWithRequest:(DDTaxiCallRequest *)request;

@end

///有位置更新时，更新汽车图标位置，使之平滑移动。
- (void)onUpdatingLocations:(NSArray *)locations forDriver:(DDDriver *)driver
{
    if ([locations count] > 0) {

        CLLocationCoordinate2D * locs = (CLLocationCoordinate2D *)malloc(sizeof(CLLocationCoordinate2D) * [locations count]);
        [locations enumerateObjectsUsingBlock:^(CLLocation * obj, NSUInteger idx, BOOL *stop) {
            locs[idx] = obj.coordinate;
        }];

        [_selectedDriver addMoveAnimationWithKeyCoordinates:locs count:[locations count] withDuration:5.0 withName:nil completeCallback:^(BOOL isFinished) {

        }];

        free(locs);
    }
}
```

`Swift`
```
/**
*  司机相关管理类。获取司机数据、发送用车请求等。
*/
class DDDriverManager {
	var delegate: DDDriverManagerDelegate?

	func searchDriversWithinMapRect(mapRect: MAMapRect) { ...... }

	func callTaxiWithRequest(request: DDTaxiCallRequest) -> Bool { ...... }
}

///有位置更新时，更新汽车图标位置，使之平滑移动。
func onUpdatingLocations(_ locations: Array<CLLocation>, forDriver deiver: DDDriver) {
    if locations.count > 0 {
        var locs = Array<CLLocationCoordinate2D>()
        for obj in locations {
            locs.append(obj.coordinate)
        }
        
        selectedDriver.addMoveAnimation(withKeyCoordinates: &locs, count: UInt(locations.count), withDuration: 5.0, withName: nil, completeCallback: nil)
    }
}
```

