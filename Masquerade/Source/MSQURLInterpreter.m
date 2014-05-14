//
//  MSQURLInterpreter.m
//  Masquerade
//
//  Created by Matt Rubin on 5/13/14.
//  Copyright (c) 2014 Matt Rubin. All rights reserved.
//

#import "MSQURLInterpreter.h"


@implementation MSQURLInterpreter

+ (NSString *)urlStringFromInput:(NSString *)input
{
    CFStringRef escapedString = CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                        (__bridge CFStringRef)input,
                                                                        CFSTR("#[]%"),
                                                                        NULL,
                                                                        kCFStringEncodingUTF8);
    return CFBridgingRelease(escapedString);
}

@end
