//
//  CCTool.m
//  CCIntegrationKit
//
//  Created by test on 5/14/14.
//  Copyright (c) 2014 Avenues. All rights reserved.
//

//
//  CCTool.m
//  seamless
//
//  Created by test on 5/14/14.
//  Copyright (c) 2014 Avenues. All rights reserved.
//

#import "CCTool.h"
#include "Base64.h"
#import <openssl/rsa.h>
#import <openssl/pem.h>

#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <dirent.h>
#include <fnmatch.h>

@implementation CCTool

- (NSString *)encryptRSA:(NSString *)raw key:(NSString *)pubKey {
    const char *p = (char *)[pubKey UTF8String];
    
    BIO *bufio;
    NSUInteger byteCount = [pubKey lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    
    bufio = BIO_new_mem_buf((void*)p, byteCount);
    RSA *rsa = PEM_read_bio_RSA_PUBKEY(bufio, 0, 0, 0);
    
    size_t plainTextLen = [raw lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    unsigned char plainText[plainTextLen+1];
    
    size_t cipherTextLen = RSA_size(rsa);
    unsigned char cipherText[cipherTextLen + 1];
    [raw getCString:(char *)plainText maxLength:plainTextLen+1 encoding:NSUTF8StringEncoding];
    
    RSA_public_encrypt(plainTextLen, plainText, cipherText, rsa, RSA_PKCS1_PADDING);
    
    NSData *encrypted = [NSData dataWithBytes:cipherText length:cipherTextLen];
    return [encrypted base64EncodedString];
}

// define missing symbols to support openssl on all iOS devices.

FILE *fopen$UNIX2003( const char *filename, const char *mode )
{
    return fopen(filename, mode);
}

int fputs$UNIX2003(const char *res1, FILE *res2){
    return fputs(res1,res2);
}

int nanosleep$UNIX2003(int val){
    return usleep(val);
}

char* strerror$UNIX2003(int errornum){
    return strerror(errornum);
}

double strtod$UNIX2003(const char *nptr, char **endptr){
    return strtod(nptr, endptr);
}

size_t fwrite$UNIX2003( const void *a, size_t b, size_t c, FILE *d )
{
    return fwrite(a, b, c, d);
}

DIR * opendir$INODE64( char * dirName )
{
    return opendir( dirName );
}

struct dirent * readdir$INODE64( DIR * dir )
{
    return readdir( dir );
}

@end
