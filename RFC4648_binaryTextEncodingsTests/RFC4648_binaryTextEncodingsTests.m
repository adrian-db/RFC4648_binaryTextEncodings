//
//  RFC4648_binaryTextEncodingsTests.m
//  RFC4648_binaryTextEncodingsTests
//
//  Created by Adrian Bigland on 19/11/2013.
//  Copyright (c) 2013 Adrian Bigland. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSData+Base64.h"

@interface RFC4648_binaryTextEncodingsTests : XCTestCase

@end

@implementation RFC4648_binaryTextEncodingsTests

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

- (void)checkVectorWithInput:(NSString *)input andExpectedEncodedForm:(NSString *)expected
{
    NSData *inputData = [input dataUsingEncoding:NSASCIIStringEncoding];
    
    NSString *actual = [inputData encodeAsBase64String];
    
    XCTAssertEqualObjects(actual, expected, @"Failed to encode a test vector properly. Expected: \"%@\" but found \"%@\".", expected, actual);
}

- (void)checkVectorWithInput:(NSString *)input andExpectedDecodedForm:(NSString *)expected
{
    NSData *decodedData = [NSData dataDecodedFromBase64String:input];
    
    NSString *actual = [[NSString alloc] initWithBytes:decodedData.bytes length:decodedData.length encoding:NSASCIIStringEncoding];
    
    XCTAssertEqualObjects(actual, expected, @"Failed to decode a base64 encoded string as expected. Expected \"%@\" but found \"%@\".", expected, actual);
}

/*
 * Uses the test vectors in the RFC to test encoding.
 */
- (void)testBase64Encoding_usingTestVectors
{
    [self checkVectorWithInput:@"" andExpectedEncodedForm:@""];
    [self checkVectorWithInput:@"f" andExpectedEncodedForm:@"Zg=="];
    [self checkVectorWithInput:@"fo" andExpectedEncodedForm:@"Zm8="];
    [self checkVectorWithInput:@"foo" andExpectedEncodedForm:@"Zm9v"];
    [self checkVectorWithInput:@"foob" andExpectedEncodedForm:@"Zm9vYg=="];
    [self checkVectorWithInput:@"fooba" andExpectedEncodedForm:@"Zm9vYmE="];
    [self checkVectorWithInput:@"foobar" andExpectedEncodedForm:@"Zm9vYmFy"];
    
    // Another one, from the Wikipedia page example: http://en.wikipedia.org/wiki/Base64
    [self checkVectorWithInput:@"Man" andExpectedEncodedForm:@"TWFu"];
}

/*
 * Uses the test vectors in the RFC to test decoding.
 */
- (void)testBase64Decoding_usingTestVectors
{
    [self checkVectorWithInput:@"" andExpectedDecodedForm:@""];
    [self checkVectorWithInput:@"Zg==" andExpectedDecodedForm:@"f"];
    [self checkVectorWithInput:@"Zm8=" andExpectedDecodedForm:@"fo"];
    [self checkVectorWithInput:@"Zm9v" andExpectedDecodedForm:@"foo"];
    [self checkVectorWithInput:@"Zm9vYg==" andExpectedDecodedForm:@"foob"];
    [self checkVectorWithInput:@"Zm9vYmE=" andExpectedDecodedForm:@"fooba"];
    [self checkVectorWithInput:@"Zm9vYmFy" andExpectedDecodedForm:@"foobar"];
    
    // Another one, from the Wikipedia page example: http://en.wikipedia.org/wiki/Base64
    [self checkVectorWithInput:@"TWFu" andExpectedDecodedForm:@"Man"];
}

@end
