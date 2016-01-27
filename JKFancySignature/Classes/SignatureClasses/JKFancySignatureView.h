//
//  JKFancySignatureView.h
//  JKFancySignature
//
//  Created by Jayesh Kawli Backup on 7/10/15.
//  Copyright (c) 2015 Jayesh Kawli Backup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JKFancySignatureVideo.h"

enum {
    SignatureModePlain,
    SignatureModeImage
};

typedef NSInteger SignatureMode;

typedef NS_ENUM(NSUInteger, LineDashPattern) {
    LineDashPatternRegular, // nil
    LineDashPatternDotted, // @[@2, @2];
    LineDashPatternBrokenLine, //@[@6, @2];
    LineDashPatternLongBrokenLine, //@[@8, @2];
    LineDashPatternCenter, //@[@6, @4, @2, @4];
    LineDashPatternLongCenter, //@[@10, @4, @6, @4];
    LineDashPatternDoubleDotsSingleLine, //@[@8, @4, @2, @4, @2, @4];
    LineDashPatternDoubleLinesSingleDot //@[@8, @4, @8, @4, @2, @4];
};

@interface JKFancySignatureView : UIView

@property (strong, nonatomic) UIColor* signatureFillColor;
@property (strong, nonatomic) NSString* videoFileName;
@property (assign, nonatomic) BOOL usingEraser;
@property (copy, nonatomic) NSArray<NSArray*>* lineDashPatternsCollection;

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

- (void)updateLineCapWithValue:(NSString*)lineCapValue;
- (void)updateLineDashPatternWithPattern:(LineDashPattern)lineDashPattern;
- (void)updateStrokeColorWithColor:(UIColor*)updatedStrokeColor;
- (void)updateStrokeSizeWithSize:(CGFloat)strokeSize;
- (void)updateSignatureImageWithImage:(UIImage*)signatureImage;

- (void)updateEraserSizeWithValue:(CGFloat)eraserSize;
- (void)updateBackgroundColorWithColor:(UIColor*)backgroundColor;

@end