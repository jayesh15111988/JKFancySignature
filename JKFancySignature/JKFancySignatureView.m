//
//  JKFancySignatureView.m
//  JKFancySignature
//
//  Created by Jayesh Kawli Backup on 7/10/15.
//  Copyright (c) 2015 Jayesh Kawli Backup. All rights reserved.
//

#import "JKFancySignatureView.h"
#import "ASScreenRecorder.h"
#import "JKFancySignatureVideo.h"

@interface JKFancySignatureView ()

@property (strong, nonatomic) NSMutableSet* tracedPointsCollection;
@property (strong, nonatomic) CAShapeLayer* viewLayer;
@property (copy, nonatomic) UIBezierPath* bezierPath;
@property (strong, nonatomic) NSDate* operationStartDate;
@property (strong, nonatomic) NSDate* operationEndDate;
@property (copy, nonatomic) UIBezierPath* originalBezierPath;
@property (strong, nonatomic) CAShapeLayer *progressLayer;
@property (strong, nonatomic) CALayer* signatureTraceLayer;
@property (strong, nonatomic) UIImage* signatureImage;
@property (strong, nonatomic) UIColor* signatureStrokeColor;
@property (assign, nonatomic) CGFloat signatureStrokeSize;
@property (assign, nonatomic) BOOL signatureDone;
@property (assign, nonatomic) double totalSignatureTime;
@property (assign, nonatomic) BOOL isCreatingSignatureVideo;

@end

@implementation JKFancySignatureView

- (void)drawRect:(CGRect)rect {
    for(NSValue* tracedPointValue in self.tracedPointsCollection) {
        CGPoint currentPoint = [tracedPointValue CGPointValue];
        CGRect rectangleToPaint = [self getRectFromPoint:currentPoint];
            if(CGRectIntersectsRect(rectangleToPaint, rect)){
                [self.signatureImage drawInRect:[self getRectFromPoint:currentPoint]];
            }
    }
}

- (CGRect)getRectFromPoint:(CGPoint)inputPoint {
    return CGRectMake(inputPoint.x - self.signatureStrokeSize, inputPoint.y - self.signatureStrokeSize, self.signatureStrokeSize, self.signatureStrokeSize);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    
    if (self.signatureDone) {
        [self createNewSignature];
    }
    
    CGPoint touchBeginPoint = [[touches anyObject] locationInView:self];
    self.operationStartDate = [NSDate date];
    
    if(self.selectedSignatureMode == SignatureModePlain) {
        [self.bezierPath moveToPoint:touchBeginPoint];
    } else {
        [self.tracedPointsCollection addObject:[NSValue valueWithCGPoint:touchBeginPoint]];
    }
}

- (void)clearOriginalBezierPathCollection {
    [self.originalBezierPath removeAllPoints];
    self.viewLayer.path = self.originalBezierPath.CGPath;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint touchMovePoint = [[touches anyObject] locationInView:self];
    if(self.selectedSignatureMode == SignatureModePlain) {
        [self.bezierPath addLineToPoint:touchMovePoint];
        self.viewLayer.path = self.bezierPath.CGPath;
    } else {
        [self.tracedPointsCollection addObject:[NSValue valueWithCGPoint:touchMovePoint]];
        [self setNeedsDisplayInRect:[self getRectFromPoint:touchMovePoint]];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.operationEndDate = [NSDate date];
    _totalSignatureTime += [self.operationEndDate timeIntervalSinceDate:self.operationStartDate];
}

- (void)signatureCompleted {
    [self completeSignatureCreationOperation];
}

- (void)completeSignatureCreationOperation {
    if (!self.signatureDone) {
        self.signatureDone = YES;
        self.originalBezierPath = self.bezierPath;
    }
}

- (void)createNewSignature {
    self.totalSignatureTime = 0;
    [self.originalBezierPath removeAllPoints];
    [self.bezierPath removeAllPoints];
    self.viewLayer.path = self.originalBezierPath.CGPath;
    self.signatureDone = NO;
}

- (void)tracePathWithLine {
    [self clearSignature];
    self.progressLayer = [[CAShapeLayer alloc] init];
    [self.progressLayer setPath: self.originalBezierPath.CGPath];
    [self.progressLayer setStrokeColor:self.signatureStrokeColor.CGColor];
    [self.progressLayer setFillColor:self.signatureFillColor.CGColor];
    [self.progressLayer setLineWidth:self.signatureStrokeSize];
    [self.progressLayer setStrokeStart:0.0];
    [self.progressLayer setStrokeEnd:1.0];
    
    [self.layer addSublayer:self.progressLayer];
    
    
    CABasicAnimation *animateStrokeEnd = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animateStrokeEnd.duration  = self.totalSignatureTime;
    animateStrokeEnd.fromValue = [NSNumber numberWithFloat:0.0f];
    animateStrokeEnd.toValue   = [NSNumber numberWithFloat:1.0f];
    animateStrokeEnd.removedOnCompletion = YES;
    animateStrokeEnd.delegate = self;
    [animateStrokeEnd setValue:@"lineAnimation" forKey:@"type"];
    [self.progressLayer addAnimation:animateStrokeEnd forKey:nil];
}

- (void)tracePathWithPoint {
    self.signatureTraceLayer = [CALayer layer];
    self.signatureTraceLayer.frame = CGRectMake(0, 0, self.signatureStrokeSize * 2, self.signatureStrokeSize * 2);
    self.signatureTraceLayer.cornerRadius = self.signatureStrokeSize;
    self.signatureTraceLayer.backgroundColor = [UIColor greenColor].CGColor;
    [self.layer addSublayer:self.signatureTraceLayer];
    
    CABasicAnimation* colorChangeAnimation = [CABasicAnimation animation];
    colorChangeAnimation.keyPath = @"backgroundColor";
    colorChangeAnimation.toValue = (__bridge id) [UIColor blueColor].CGColor;
    
    
    //Usually use this approach for perform rotation while animating stuff
    CABasicAnimation* rotationAnimation = [CABasicAnimation animation];
    rotationAnimation.keyPath = @"transform.rotation";
    rotationAnimation.byValue = @(M_PI*2);
    
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animation];
    animation.keyPath = @"position";
    animation.path = self.originalBezierPath.CGPath;
    animation.removedOnCompletion = YES;
    animation.rotationMode = kCAAnimationRotateAuto;
    
    CAAnimationGroup* animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[colorChangeAnimation, animation];
    animationGroup.duration = self.totalSignatureTime;
    animationGroup.delegate = self;
    [animationGroup setValue:@"pointAnimation" forKey:@"type"];
    [self.signatureTraceLayer addAnimation:animationGroup forKey:nil];
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)finished {
    if (finished) {
        if ([[animation valueForKey:@"type"] isEqualToString:@"lineAnimation"]) {
            [self.progressLayer removeFromSuperlayer];
            self.viewLayer.path = self.originalBezierPath.CGPath;
            
            if (self.isCreatingSignatureVideo) {
                self.isCreatingSignatureVideo = NO;
                [[ASScreenRecorder sharedInstance] stopRecordingWithCompletion:^(NSString *outputVideoPath) {
                    if (self.videoRecordingCompletion) {
                        
                        NSError* error;
                        NSMutableDictionary* fileAttributes = [[[NSFileManager defaultManager] attributesOfItemAtPath:outputVideoPath error:&error] mutableCopy];
                        if (!error) {
                            fileAttributes[@"storagePath"] = outputVideoPath;
                            JKFancySignatureVideo* signatureVideoObject = [[JKFancySignatureVideo alloc] initWithDictionary:fileAttributes];
                            self.videoRecordingCompletion(signatureVideoObject);
                        } else {
                            self.videoRecordingErrorOperation(error);
                        }
                    }
                }];
            }
            
        } else if ([[animation valueForKey:@"type"] isEqualToString:@"pointAnimation"]){
            [self.signatureTraceLayer removeFromSuperlayer];
        }
    }
}

- (void)clearSignature {
    if(self.selectedSignatureMode == SignatureModePlain) {
        [self.bezierPath removeAllPoints];
        self.viewLayer.path = self.bezierPath.CGPath;
    } else {
        if (self.tracedPointsCollection.count) {
            [self.tracedPointsCollection removeAllObjects];
            [self setNeedsDisplay];
        }
    }
}

- (instancetype)initWithStrokeSize:(CGFloat)signatureStrokeSize andSignatureStrokeColor:(UIColor*)signatureStrokeColor {
    if (self = [super init]) {
        self.selectedSignatureMode = SignatureModePlain;
        self.signatureStrokeSize = signatureStrokeSize;
        self.signatureStrokeColor = signatureStrokeColor;
        [self initializeViewLayer];
        [self initializeContainers];
    }
    return self;
}

- (instancetype)initWithStrokeSize:(CGFloat)signatureStrokeSize andSignatureImage:(UIImage*)signatureImage {
    if (self = [super init]) {
        self.selectedSignatureMode = SignatureModeImage;
        NSAssert(signatureImage != nil, @"Initizlier signatureStrokeSize andSignatureImage should be invoked with non-nil signatureImage for signature to appear on the viewport");
        self.signatureStrokeSize = signatureStrokeSize;
        self.signatureImage = signatureImage;
        [self initializeViewLayer];
        [self initializeContainers];
    }
    return self;
}

- (void)initializeContainers {
    self.signatureDone = NO;
    self.totalSignatureTime = 0;
    self.clipsToBounds = YES;
    self.isCreatingSignatureVideo = NO;
    UILongPressGestureRecognizer* longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(clearSignature)];
    [self addGestureRecognizer:longPressGestureRecognizer];
    self.tracedPointsCollection = [NSMutableSet set];
    self.bezierPath = [UIBezierPath bezierPath];
}

- (void)initializeViewLayer {
    CAShapeLayer* drawingLayer = [CAShapeLayer layer];
    drawingLayer.fillColor = [UIColor clearColor].CGColor;
    drawingLayer.lineWidth = self.signatureStrokeSize;
    drawingLayer.strokeColor = self.signatureStrokeColor.CGColor;
    drawingLayer.fillColor = [UIColor clearColor].CGColor;
    self.viewLayer = drawingLayer;
    [self.layer addSublayer:self.viewLayer];
}

- (void)setSignatureFillColor:(UIColor*)signatureFillColor {
    self.viewLayer.fillColor = signatureFillColor.CGColor;
}

- (UIImage*)outputSignatureImage {
    [self completeSignatureCreationOperation];
    CGSize size = [self bounds].size;
    UIGraphicsBeginImageContext(size);
    [[self layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* signatureImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return signatureImage;
}

- (void)createVideoForCurrentSignatureWithCompletionBlock:(void (^)(JKFancySignatureVideo* outputVideoObject))completion andErrorBlock:(void (^)(NSError *))error {
    [self completeSignatureCreationOperation];
    self.videoRecordingCompletion = completion;
    self.videoRecordingErrorOperation = error;
    self.isCreatingSignatureVideo = YES;
    ASScreenRecorder* screenRecorder = [ASScreenRecorder sharedInstance];
    [screenRecorder startRecording];
    
    if (self.selectedSignatureMode == SignatureModePlain) {
        [self tracePathWithLine];
    } else {
        
    }
}

- (void)updateStrokeColorWithColor:(UIColor*)updatedStrokeColor {
    self.signatureStrokeColor = updatedStrokeColor;
    self.viewLayer.strokeColor = self.signatureStrokeColor.CGColor;
}

- (void)updateStrokeSizeWithSize:(CGFloat)strokeSize {
    self.signatureStrokeSize = strokeSize;
    self.viewLayer.lineWidth = self.signatureStrokeSize;
}

- (void)updateSignatureImageWithImage:(UIImage*)signatureImage {
    NSAssert(signatureImage != nil, @"Initizlier signatureStrokeSize andSignatureImage should be invoked with non-nil signatureImage for signature to appear on the viewport");
    self.signatureImage = signatureImage;
}

@end
