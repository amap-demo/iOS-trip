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
| MovingAnnotationView | - (void)addTrackingAnimationForCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count duration:(CFTimeInterval)duration; | 控制车辆移动 | n/a |
