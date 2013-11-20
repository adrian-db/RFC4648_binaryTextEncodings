//
//  NSData+Base64.m
//  RFC4648_binaryTextEncodings
//
//  Created by Adrian Bigland on 19/11/2013.
//  Copyright (c) 2013 Adrian Bigland. All rights reserved.
//

#import "NSData+Base64.h"

@implementation NSData (Base64)

// I'm including the padding character as the 65th element (alphabet[64]), to make it easier in future
// to include alphabets with different padding, if needed.
char alphabet[] = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
                   'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
                   'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
                   'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
                   '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
                   '+', '/',
                   '='};

- (NSString *)encodeAsBase64String
{
    // We work on chunks of 3 bytes at a time, padding at the end if we don't have enough left to make 3.
    char plain[3];
    // We convert the 3 bytes to 4 characters.
    char split[4];
    char encoded[4];
    char pad = alphabet[64];
    
    NSUInteger nChunks = ceil(self.length/3.0);
    NSMutableData *characters = [NSMutableData dataWithCapacity:nChunks * 4];
    
    NSUInteger nBytesInChunk;
    
    int i;
    for (i = 0; i < nChunks; ++i) {
        
        nBytesInChunk = MIN(3, self.length - (i * 3));
        
        // Get the next three bytes to encode.
        [self getBytes:plain range:NSMakeRange(i * 3, nBytesInChunk)];
        
        // Only use the higher 6 bits for the first character.
        split[0] = ((plain[0] & 0xFC) >> 2);
        split[1] = ((plain[0] & 0x03) << 4);
        split[2] = 0;
        split[3] = 0;
        
        if (nBytesInChunk > 1) {
            
            split[1] |= ((plain[1] & 0xF0) >> 4);
            split[2] = ((plain[1] & 0x0F) << 2);
            
        }
        
        if (nBytesInChunk > 2) {
            
            split[2] |= ((plain[2] & 0xC0) >> 6);
            split[3] = (plain[2] & 0x3F);
            
        }
        
        // Now we have split the 3 input bytes into 4 output bytes, encode the bytes
        // into ASCII characters from the alphabet above.
        // They will always index into the range of the alphabet, as we have restricted them to 6 bits in the
        // splitting operation, which will give 2^6 at maximum, which is 64. We have 65 characters.
        encoded[0] = alphabet[split[0]];
        encoded[1] = alphabet[split[1]];
        encoded[2] = nBytesInChunk == 1 ? pad : alphabet[split[2]];
        encoded[3] = nBytesInChunk < 3 ? pad : alphabet[split[3]];
        
        [characters appendBytes:encoded length:4];
        
    }
    
    return [[NSString alloc] initWithData:characters encoding:NSASCIIStringEncoding];
}

+ (char)decodeBase64Char:(char)base64char
{
    if (base64char >= 'A' && base64char <= 'Z') {
        
        return base64char - 'A';
        
    }
    else if (base64char >= 'a' && base64char <= 'z') {
        
        return base64char - 'a' + 26;
        
    }
    else if (base64char >= '0' && base64char <= '9') {
        
        return base64char - '0' + 52;
        
    }
    else if (base64char == '+') {
        
        return 62;
        
    }
    else if (base64char == '/') {
        
        return 63;
        
    }
    else if (base64char == '=') {
        
        return 64;
        
    }
    return 65;
}

+ (NSData *)dataDecodedFromBase64String:(NSString *)base64String
{
    if (base64String == nil) return nil;
    
    NSData *encodedData = [base64String dataUsingEncoding:NSASCIIStringEncoding];
    
    // We must have chunks of exactly 4 ASCII characters to decode.
    if (encodedData.length % 4 != 0) return nil;
    
    NSUInteger nBlocks = encodedData.length/4;
    char encoded[4];
    char split[4];
    char plain[3];
    NSUInteger nBytesInBlock;
    
    char pad = 64;
    
    NSMutableData *plainData = [NSMutableData dataWithCapacity:nBlocks * 3];
    
    for (int i = 0; i < nBlocks; ++i) {
     
        [encodedData getBytes:encoded range:NSMakeRange(i * 4, 4)];
        split[0] = [self decodeBase64Char:encoded[0]];
        split[1] = [self decodeBase64Char:encoded[1]];
        split[2] = [self decodeBase64Char:encoded[2]];
        split[3] = [self decodeBase64Char:encoded[3]];
        
        // We only accept valid characters - the first two characters will never be
        // padded, so must always fall between values 0 and 63.
        if (split[0] > 63 || split[1] > 63) return nil;
        if (split[2] > 64 || split[3] > 64) return nil;
        
        if (i < nBlocks - 1) {
            
            nBytesInBlock = 4;
            
        }
        else {
            
            if (split[2] == pad && split[3] == pad) {
                
                nBytesInBlock = 2;
                
            }
            else if (split[2] == pad && split[3] != pad) {
                
                // If the penultimate character is padding, the last must be as well.
                return nil;
                
            }
            else if (split[3] == pad) {
                
                nBytesInBlock = 3;
                
            }
            else {
                
                nBytesInBlock = 4;
                
            }
            
        }
        
        plain[2] = 0;
        plain[1] = 0;
        plain[0] = ((split[0] & 0x3F) << 2) | ((split[1] & 0x30) >> 4);
        
        if (nBytesInBlock > 2) {
            
            plain[1] = ((split[1] & 0x0F) << 4) | ((split[2] & 0x3C) >> 2);
            
        }
        
        if (nBytesInBlock > 3) {
            
            plain[2] = ((split[2] & 0x03) << 6) | ((split[3] & 0x3F));
            
        }
        
        // Check that any partially filled blocks are padded with zeros - don't decode any that are not,
        // as the RFC lists concerns of supporting hidden backchannel communications this way.
        if (nBytesInBlock == 2 && ((split[1] & 0x0F) != 0)) return nil;
        if (nBytesInBlock == 3 && ((split[2] & 0x03) != 0)) return nil;
        
        // If we have 4 bytes, we get 3 plain characters. 3 bytes -> 2 plain. 2 bytes -> 1 plain.
        [plainData appendBytes:plain length:nBytesInBlock - 1];
        
    }
    
    // Return an immutable copy of the decoded data.
    return [NSData dataWithData:plainData];
}

@end
