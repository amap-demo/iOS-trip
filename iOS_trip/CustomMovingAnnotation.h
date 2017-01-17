//
//  CustomMovingAnnotation.h
//  iOS_movingAnnotation
//
//  Created by shaobin on 17/1/4.
//  Copyright © 2017年 yours. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>

typedef void (^CustomMovingAnnotationCallback)();

@interface CustomMovingAnnotation : MAAnimatedAnnotation

@property (nonatomic, copy) CustomMovingAnnotationCallback stepCallback;

- (CLLocationDirection)rotateDegree;

@end
