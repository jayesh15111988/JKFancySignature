//
//  JKFancySignatureVideo.h
//  JKFancySignature
//
//  Created by Jayesh Kawli Backup on 7/12/15.
//  Copyright (c) 2015 Jayesh Kawli Backup. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JKFancySignatureVideo : NSObject

@property (strong, nonatomic) NSString* fileCreationDateString;
@property (strong, nonatomic) NSString* fileModificationDateString;
@property (assign, nonatomic) double fileSize;
@property (strong, nonatomic) NSString* fileType;
@property (strong, nonatomic) NSString* videoFileStoragePath;

- (instancetype)initWithDictionary:(NSDictionary*)videoFileAttributesDictionary;

@end
