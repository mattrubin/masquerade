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
    NSDictionary *testPairs = @{@"http://example.com": @"http://example.com",
                                // Examples from RFC 3986 ( https://tools.ietf.org/html/rfc3986#section-1.1.2 )
                                @"ftp://ftp.is.co.za/rfc/rfc1808.txt": @"ftp://ftp.is.co.za/rfc/rfc1808.txt",
                                @"http://www.ietf.org/rfc/rfc2396.txt": @"http://www.ietf.org/rfc/rfc2396.txt",
                                @"ldap://[2001:db8::7]/c=GB?objectClass?one": @"ldap://[2001:db8::7]/c=GB?objectClass?one",
                                @"mailto:John.Doe@example.com": @"mailto:John.Doe@example.com",
                                @"news:comp.infosystems.www.servers.unix": @"news:comp.infosystems.www.servers.unix",
                                @"tel:+1-816-555-1212": @"tel:+1-816-555-1212",
                                @"telnet://192.0.2.16:80/": @"telnet://192.0.2.16:80/",
                                @"urn:oasis:names:specification:docbook:dtd:xml:4.1.2": @"urn:oasis:names:specification:docbook:dtd:xml:4.1.2",
                                };

    for (NSString *input in testPairs) {
        NSString *expectedResult = testPairs[input];

        NSString *result = [MSQURLInterpreter urlStringFromInput:input];
        XCTAssertEqualObjects(expectedResult, result);
    }
}

@end
