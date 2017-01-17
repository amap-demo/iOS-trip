//
//  CustomMovingAnnotation.m
//  iOS_movingAnnotation
//
//  Created by shaobin on 17/1/4.
//  Copyright © 2017年 yours. All rights reserved.
//

#import "CustomMovingAnnotation.h"

@implementation CustomMovingAnnotation

- (void)step:(CGFloat)timeDelta {
    [super step:timeDelta];
    
    if(self.stepCallback) {
        self.stepCallback();
    }
}

- (CLLocationDirection)rotateDegree {
    return 0;
}

@end
