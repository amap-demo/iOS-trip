//
//  iOS_tripUITests.m
//  iOS_tripUITests
//
//  Created by hanxiaoming on 17/1/17.
//  Copyright © 2017年 yours. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface iOS_tripUITests : XCTestCase

@end

@implementation iOS_tripUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    XCUIApplication *app = [[XCUIApplication alloc] init];;
    
    [app.images[@"icon_passenger"] tap];
    
    XCUIElementQuery *annos = [[app.otherElements[@"maannotationcontainer"] childrenMatchingType:XCUIElementTypeOther] matchingIdentifier:@"maannotationview"];
    
    XCTAssert(annos.count > 10, @"annos count must greater than 10");
    
    
    sleep(1);
    [app.buttons[@"选择终点"] tap];
    
    sleep(1);
    XCUIElement *textField = [[app searchFields] element];
    [textField typeText:@"望京\n"];
    
    sleep(1);
    XCUIElement *cell = app.tables.cells.staticTexts[@"望京西(地铁站)"];
    
    if (cell.exists) {
        if (cell.isHittable) {
            [cell tap];
        }
        else {
            XCUICoordinate *coor = [cell coordinateWithNormalizedOffset:CGVectorMake(0.1, 0.1)];
            [coor tap];
        }
    }
    else {
        [self recordFailureWithDescription:@"no search result" inFile:@__FILE__ atLine:__LINE__ expected:NO];
    }

    
    sleep(1);
    [app.buttons[@"马上叫车"] tap];
    
    sleep(15);
    [app.buttons[@"我已上车"] tap];
    
    sleep(1);
    [app.buttons[@"支付"] tap];
    
    sleep(1);
    [app.buttons[@"评价"] tap];

    sleep(2);
}

@end
