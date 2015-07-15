//
//  JKFancySignatureVideo.m
//  JKFancySignature
//
//  Created by Jayesh Kawli Backup on 7/12/15.
//  Copyright (c) 2015 Jayesh Kawli Backup. All rights reserved.
//

#import "JKFancySignatureVideo.h"


@implementation JKFancySignatureVideo

- (instancetype)initWithDictionary:(NSDictionary *)videoFileAttributesDictionary {
    if (self = [super init]) {
        _fileCreationDateString = videoFileAttributesDictionary[NSFileCreationDate];
        _fileModificationDateString = videoFileAttributesDictionary[NSFileModificationDate];
        _fileSize = [videoFileAttributesDictionary[NSFileSize] doubleValue];
        _fileType = videoFileAttributesDictionary[NSFileType];
        _videoFileStoragePath = videoFileAttributesDictionary[@"storagePath"];
    }
    return self;
}

@end
