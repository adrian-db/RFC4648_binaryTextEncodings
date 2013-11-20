//
//  NSData+Base64.h
//  RFC4648_binaryTextEncodings
//
//  Created by Adrian Bigland on 19/11/2013.
//  Copyright (c) 2013 Adrian Bigland. All rights reserved.
//

/*
 * Implements the Base64 encoding and decoding described in RFC 4748.
 * See http://www.ietf.org/rfc/rfc4648.txt
 */

#import <Foundation/Foundation.h>

@interface NSData (Base64)

- (NSString *)encodeAsBase64String;
+ (NSData *)dataDecodedFromBase64String:(NSString *)base64String;

@end
