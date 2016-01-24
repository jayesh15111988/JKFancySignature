//
//  JKFancySignatureView.h
//  JKFancySignature
//
//  Created by Jayesh Kawli Backup on 7/10/15.
//  Copyright (c) 2015 Jayesh Kawli Backup. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JKFancySignatureVideo;

enum { SignatureModePlain, SignatureModeImage };
typedef NSInteger SignatureMode;

@interface JKFancySignatureView : UIView

@property (strong, nonatomic) UIColor* signatureFillColor;
@property (strong, nonatomic) NSString* videoFileName;
@property (assign, nonatomic) BOOL usingEraser;

typedef void (^VideoRecordingCompletionBlock) (JKFancySignatureVideo* signatureVideoObject);
@property (strong, nonatomic) VideoRecordingCompletionBlock videoRecordingCompletion;
typedef void (^VideoRecordingErrorBlock) (NSError* error);
@property (strong, nonatomic) VideoRecordingErrorBlock videoRecordingErrorOperation;
@property (assign, nonatomic) SignatureMode selectedSignatureMode;

- (instancetype)initWithStrokeSize:(CGFloat)signatureStrokeSize andSignatureStrokeColor:(UIColor*)signatureStrokeColor;
- (instancetype)initWithStrokeSize:(CGFloat)signatureStrokeSize andSignatureImage:(UIImage*)signatureImage;

- (void)markSignatureDone;
- (UIImage*)outputSignatureImage;
- (void)undoSignature;
- (void)clearPreviousSignature;

- (void)tracePathWithLine;
- (void)tracePathWithPoint;
- (void)createVideoForCurrentSignatureWithCompletionBlock:
            (void (^) (JKFancySignatureVideo* outputVideoObject))completion
                                            andErrorBlock:(void (^) (NSError* error))error;

- (void)updateStrokeColorWithColor:(UIColor*)updatedStrokeColor;
- (void)updateStrokeSizeWithSize:(CGFloat)strokeSize;
- (void)updateSignatureImageWithImage:(UIImage*)signatureImage;

- (void)updateEraserSizeWithValue:(CGFloat)eraserSize;
- (void)updateBackgroundColorWithColor:(UIColor*)backgroundColor;

@end