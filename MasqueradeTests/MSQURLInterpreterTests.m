//
//  MSQURLInterpreterTests.m
//  Masquerade
//
//  Created by Matt Rubin on 5/13/14.
//  Copyright (c) 2014 Matt Rubin. All rights reserved.
//

@import XCTest;
#import "MSQURLInterpreter.h"


@interface MSQURLInterpreterTests : XCTestCase

@end


@implementation MSQURLInterpreterTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


#pragma mark -

- (void)testURLStringFromInput
{
    NSDictionary *testPairs = @{@"http://example.com": @"http://example.com"};

    for (NSString *input in testPairs) {
        NSString *expectedResult = testPairs[input];

        NSString *result = [MSQURLInterpreter urlStringFromInput:input];
        XCTAssertEqualObjects(expectedResult, result);
    }
}

@end
