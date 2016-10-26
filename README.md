iOS-trip
========================

类似滴滴叫车的功能演示

### 前述

- [高德官方网站申请key](http://id.amap.com/?ref=http%3A%2F%2Fapi.amap.com%2Fkey%2F).
- 阅读[参考手册](http://api.amap.com/Public/reference/iOS%20API%20v2_3D/).
- 工程基于iOS 3D地图SDK实现
- 运行demo请先执行pod install --repo-update 安装依赖库，完成后打开.xcworkspace 文件

###主要功能类简介

- DDDriverManager 实现获取周边司机数据，请求用车逻辑
```objc
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
```

- MovingAnnotationView 车辆图标显示及移动动画
```objc
/**
 *  可以在路径上进行移动动画的annoationView。
 */
@interface MovingAnnotationView : MAAnnotationView

- (void)addTrackingAnimationForCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count duration:(CFTimeInterval)duration;

@end
```

- DDSearchManager 根据关键字搜索对应的位置信息
```objc
/**
 *  搜索管理类。对高德搜索SDK进行了封装，使用block回调，无需频繁设置代理。
 */
@interface DDSearchManager : NSObject

+ (instancetype)sharedInstance;

- (void)searchForRequest:(id)request completionBlock:(DDSearchCompletionBlock)block;

@end

```
