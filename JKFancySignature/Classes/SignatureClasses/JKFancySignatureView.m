//
//  JKFancySignatureView.m
//  JKFancySignature
//
//  Created by Jayesh Kawli Backup on 7/10/15.
//  Copyright (c) 2015 Jayesh Kawli Backup. All rights reserved.
//

#import "ASScreenRecorder.h"
#import "JKFancySignatureVideo.h"
#import "JKFancySignatureView.h"

@interface JKFancySignatureView ()

@property (strong, nonatomic) NSTimer* timer;
@property (strong, nonatomic) UIActivityIndicatorView* activityIndicator;
@property (strong, nonatomic) NSDate* operationStartDate;
@property (strong, nonatomic) NSDate* operationEndDate;
@property (copy, nonatomic) UIBezierPath* bezierPath;
@property (copy, nonatomic) UIBezierPath* backupBezierPath;
@property (copy, nonatomic) UIBezierPath* originalBezierPath;
@property (copy, nonatomic) UIBezierPath* eraserBezierPath;
@property (strong, nonatomic) CALayer* signatureTraceLayer;
@property (strong, nonatomic) CAShapeLayer* viewLayer;
@property (strong, nonatomic) CAShapeLayer* signatureEraserLayer;
@property (strong, nonatomic) CAShapeLayer* progressLayer;
@property (strong, nonatomic) NSMutableArray* tracedPointsCollection;
@property (strong, nonatomic) NSMutableArray* originalTracedPointsCollection;
@property (strong, nonatomic) UIImage* signatureImage;
@property (strong, nonatomic) UIColor* signatureStrokeColor;
@property (assign, nonatomic) CGFloat signatureStrokeSize;
@property (assign, nonatomic) CGFloat signaturePointsDistanceThreshold;
@property (assign, nonatomic) double totalSignatureTime;
@property (assign, nonatomic) BOOL isCreatingSignatureVideo;
@property (assign, nonatomic) BOOL signatureDone;
@property (assign, nonatomic) LineDashPattern selectedSignatureLineDashPattern;

@end

@implementation JKFancySignatureView

- (void)drawRect:(CGRect)rect {
    for (NSValue* tracedPointValue in self.tracedPointsCollection) {
        CGPoint currentPoint = [tracedPointValue CGPointValue];
        CGRect rectangleToPaint = [self rectFromPoint:currentPoint];
        if (CGRectIntersectsRect (rectangleToPaint, rect)) {
            [self.signatureImage drawInRect:rectangleToPaint];
        }
    }
}

- (CGRect)rectFromPoint:(CGPoint)inputPoint {
    return CGRectMake (inputPoint.x - self.signatureStrokeSize, inputPoint.y - self.signatureStrokeSize,
                       self.signatureStrokeSize, self.signatureStrokeSize);
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {

    [self.backupBezierPath removeAllPoints];
    if (self.signatureDone) {
        [self clearPreviousSignature];
    }

    self.operationStartDate = [NSDate date];
    CGPoint touchBeginPoint = [[touches anyObject] locationInView:self];

    if (self.selectedSignatureMode == SignatureModePlain) {
        if (_usingEraser) {
            [self.eraserBezierPath moveToPoint:touchBeginPoint];
        } else {
            [self.bezierPath moveToPoint:touchBeginPoint];
        }
    } else {
        [self.tracedPointsCollection addObject:[NSValue valueWithCGPoint:touchBeginPoint]];
    }
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
    CGPoint touchMovePoint = [[touches anyObject] locationInView:self];
    if (self.selectedSignatureMode == SignatureModePlain) {
        if (_usingEraser) {
            [self.eraserBezierPath addLineToPoint:touchMovePoint];
            self.signatureEraserLayer.path = self.eraserBezierPath.CGPath;
        } else {
            [self.bezierPath addLineToPoint:touchMovePoint];
            self.viewLayer.path = self.bezierPath.CGPath;
        }
    } else {
        CGPoint lastPointInCollection = [[self.tracedPointsCollection lastObject] CGPointValue];
        if ([self euclideanDistanceBetweenPoints:lastPointInCollection andSecondPoint:touchMovePoint] >
            self.signaturePointsDistanceThreshold) {
            [self.tracedPointsCollection addObject:[NSValue valueWithCGPoint:touchMovePoint]];
            [self setNeedsDisplayInRect:[self rectFromPoint:touchMovePoint]];
        }
    }
}

- (double)euclideanDistanceBetweenPoints:(CGPoint)firstPoint andSecondPoint:(CGPoint)secondPoint {
    return sqrt (pow (firstPoint.x - secondPoint.x, 2) + pow (firstPoint.y - secondPoint.y, 2));
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
    self.operationEndDate = [NSDate date];
    _totalSignatureTime += [self.operationEndDate timeIntervalSinceDate:self.operationStartDate];
}

- (void)completeSignatureCreationOperation {
    [self markSignatureDone];
}

- (void)markSignatureDone {
    if (!self.signatureDone) {
        self.signatureDone = YES;
        if (self.selectedSignatureMode == SignatureModePlain) {
            self.originalBezierPath = self.bezierPath;
        } else {
            self.originalTracedPointsCollection = [self.tracedPointsCollection mutableCopy];
        }
    }
}

- (void)clearPreviousSignature {

    self.totalSignatureTime = 0;
    self.signatureDone = NO;

    if (self.selectedSignatureMode == SignatureModePlain) {
        [self.bezierPath removeAllPoints];
        [self.originalBezierPath removeAllPoints];
        [self.eraserBezierPath removeAllPoints];
        self.viewLayer.path = self.originalBezierPath.CGPath;
        self.signatureEraserLayer.path = self.eraserBezierPath.CGPath;
    } else {
        [self.tracedPointsCollection removeAllObjects];
        [self.originalTracedPointsCollection removeAllObjects];
        [self setNeedsDisplay];
    }
}

- (void)undoSignatureClear {
    // Undoes the previous signature clear operation. Signature or painting will be redrawn again.
    self.bezierPath = self.backupBezierPath;
    [self.backupBezierPath removeAllPoints];
    self.viewLayer.path = self.bezierPath.CGPath;
}

- (void)tracePathWithLine {
    [self markSignatureCompleteAndClearPreviousDrawing];

    if (!self.progressLayer) {
        [self setupProgressLayer];
    }
    [self updateProgressLayerProperties];

    [self setupAttributesForProgressLayer];
    [self.progressLayer addAnimation:[self animationWithTypeName:@"lineAnimation" andDrawingOnScene:YES] forKey:nil];
}

- (void)setupAttributesForProgressLayer {
    [self.progressLayer setPath:self.originalBezierPath.CGPath];
    [self.progressLayer setStrokeColor:self.signatureStrokeColor.CGColor];
    [self.progressLayer setFillColor:self.signatureFillColor.CGColor];
    [self.progressLayer setLineWidth:self.signatureStrokeSize];
    [self.layer addSublayer:self.progressLayer];
}

- (void)markSignatureCompleteAndClearPreviousDrawing {
    [self completeSignatureCreationOperation];
    [self clearSignature];
}

- (void)undoSignature {
    if (self.selectedSignatureMode == SignatureModePlain) {
        [self markSignatureCompleteAndClearPreviousDrawing];

        if (!self.progressLayer) {
            [self setupProgressLayer];
            [self setupAttributesForProgressLayer];
        } else {
            [self.progressLayer setPath:self.originalBezierPath.CGPath];
            [self.layer addSublayer:self.progressLayer];
        }

        [self updateProgressLayerProperties];

        [self.progressLayer addAnimation:[self animationWithTypeName:@"lineAnimationRemoval" andDrawingOnScene:NO]
                                  forKey:nil];
    } else {
        [self clearPreviousSignature];
    }
}

- (void)updateProgressLayerProperties {
    self.progressLayer.fillColor = self.viewLayer.fillColor;
    self.progressLayer.lineWidth = self.viewLayer.lineWidth;
    self.progressLayer.strokeColor = self.viewLayer.strokeColor;
    self.progressLayer.lineDashPattern = self.viewLayer.lineDashPattern;
    self.progressLayer.lineCap = self.viewLayer.lineCap;
}

- (void)setupProgressLayer {
    self.progressLayer = [[CAShapeLayer alloc] init];
    [self.progressLayer setStrokeStart:0.0];
    [self.progressLayer setStrokeEnd:1.0];
}

- (CABasicAnimation*)animationWithTypeName:(NSString*)type andDrawingOnScene:(BOOL)drawing {
    CABasicAnimation* animateStrokeEnd = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animateStrokeEnd.duration = _totalSignatureTime;

    if (drawing) {
        animateStrokeEnd.fromValue = [NSNumber numberWithFloat:0.0f];
        animateStrokeEnd.toValue = [NSNumber numberWithFloat:1.0f];
    } else {
        animateStrokeEnd.fromValue = [NSNumber numberWithFloat:1.0f];
        animateStrokeEnd.toValue = [NSNumber numberWithFloat:0.0f];
    }

    animateStrokeEnd.removedOnCompletion = YES;
    animateStrokeEnd.delegate = self;
    [animateStrokeEnd setValue:type forKey:@"type"];
    return animateStrokeEnd;
}

- (void)tracePathWithPoint {
    if (self.selectedSignatureMode == SignatureModePlain) {
        [self completeSignatureCreationOperation];
        self.signatureTraceLayer = [CALayer layer];
        self.signatureTraceLayer.frame = CGRectMake (0, 0, self.signatureStrokeSize * 3, self.signatureStrokeSize * 3);
        self.signatureTraceLayer.cornerRadius = self.signatureStrokeSize;
        self.signatureTraceLayer.backgroundColor = [UIColor redColor].CGColor;
        [self.layer addSublayer:self.signatureTraceLayer];

        CABasicAnimation* colorChangeAnimation = [CABasicAnimation animation];
        colorChangeAnimation.keyPath = @"backgroundColor";
        colorChangeAnimation.toValue = (__bridge id)[UIColor blueColor].CGColor;
        colorChangeAnimation.removedOnCompletion = YES;

        // Usually use this approach for perform rotation while animating stuff
        CABasicAnimation* rotationAnimation = [CABasicAnimation animation];
        rotationAnimation.keyPath = @"transform.rotation";
        rotationAnimation.byValue = @(M_PI * 2);
        rotationAnimation.removedOnCompletion = YES;

        CAKeyframeAnimation* animation = [CAKeyframeAnimation animation];
        animation.keyPath = @"position";
        animation.path = self.originalBezierPath.CGPath;
        animation.removedOnCompletion = YES;
        animation.rotationMode = kCAAnimationRotateAuto;

        CAAnimationGroup* animationGroup = [CAAnimationGroup animation];
        animationGroup.animations = @[ animation ];
        animationGroup.duration = _totalSignatureTime * 2;
        animationGroup.delegate = self;
        animationGroup.removedOnCompletion = YES;
        [animationGroup setValue:@"pointAnimation" forKey:@"type"];
        [self.signatureTraceLayer addAnimation:animationGroup forKey:nil];
    }
}

- (void)animationDidStop:(CAAnimation*)animation finished:(BOOL)finished {
    if (finished) {
        if ([[animation valueForKey:@"type"] isEqualToString:@"lineAnimation"]) {
            [self.progressLayer removeFromSuperlayer];
            self.viewLayer.path = self.originalBezierPath.CGPath;
            [self stopRecordingAndProduceVideoOutputFile];
        } else if ([[animation valueForKey:@"type"] isEqualToString:@"pointAnimation"]) {
            [self.signatureTraceLayer removeFromSuperlayer];
        } else if ([[animation valueForKey:@"type"] isEqualToString:@"lineAnimationRemoval"]) {
            [self.progressLayer removeFromSuperlayer];
        }
    }
}

- (void)stopRecordingAndProduceVideoOutputFile {
    if (self.isCreatingSignatureVideo) {
        self.isCreatingSignatureVideo = NO;
        [self.activityIndicator stopAnimating];
        [[ASScreenRecorder sharedInstance] stopRecordingWithCompletion:^(NSString* outputVideoPath) {
          if (self.videoRecordingCompletion) {

              NSError* error;
              NSMutableDictionary* fileAttributes =
                  [[[NSFileManager defaultManager] attributesOfItemAtPath:outputVideoPath error:&error] mutableCopy];
              if (!error) {
                  fileAttributes[@"storagePath"] = outputVideoPath;
                  JKFancySignatureVideo* signatureVideoObject =
                      [[JKFancySignatureVideo alloc] initWithDictionary:fileAttributes];
                  self.videoRecordingCompletion (signatureVideoObject);
              } else {
                  self.videoRecordingErrorOperation (error);
              }
          }
        }];
    }
}

- (void)clearSignature {
    if (self.selectedSignatureMode == SignatureModePlain) {
        if (!self.bezierPath.empty) {
            self.backupBezierPath = self.bezierPath;
            [self.bezierPath removeAllPoints];
            self.viewLayer.path = self.bezierPath.CGPath;
        }

        if (!self.eraserBezierPath.empty) {
            [self.eraserBezierPath removeAllPoints];
            self.signatureEraserLayer.path = self.eraserBezierPath.CGPath;
        }
    } else {
        if (self.tracedPointsCollection.count) {
            [self.tracedPointsCollection removeAllObjects];
        }
        [self setNeedsDisplay];
    }
}

- (void)awakeFromNib {
    // These are all Default values if you are initalizing view directly from storyboard. You can change individual
    // attributes later.
    self.selectedSignatureMode = SignatureModePlain;
    self.signatureStrokeColor = [UIColor blackColor];
    self.signatureStrokeSize = 5.0f;
    [self prepareForStartup];
}

- (instancetype)initWithStrokeSize:(CGFloat)signatureStrokeSize andSignatureStrokeColor:(UIColor*)signatureStrokeColor {
    if (self = [super init]) {
        self.selectedSignatureMode = SignatureModePlain;
        self.signatureStrokeColor = signatureStrokeColor;
        self.signatureStrokeSize = signatureStrokeSize;
        [self prepareForStartup];
    }
    return self;
}

- (instancetype)initWithStrokeSize:(CGFloat)signatureStrokeSize andSignatureImage:(UIImage*)signatureImage {
    if (self = [super init]) {
        NSAssert (signatureImage != nil,
                  @"Initizlier signatureStrokeSize andSignatureImage should be invoked with non-nil signatureImage");
        self.selectedSignatureMode = SignatureModeImage;
        self.signatureImage = signatureImage;
        self.signatureStrokeSize = signatureStrokeSize;
        self.signaturePointsDistanceThreshold = self.signatureStrokeSize;
        [self prepareForStartup];
    }
    return self;
}

- (void)prepareForStartup {
    [self initializeViewLayer];
    [self initializeParameters];
}

- (void)initializeParameters {
    self.signatureDone = NO;
    self.totalSignatureTime = 0;
    self.clipsToBounds = YES;
    self.isCreatingSignatureVideo = NO;
    self.activityIndicator = [UIActivityIndicatorView new];
    self.activityIndicator.hidesWhenStopped = YES;
    self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [self.activityIndicator stopAnimating];
    [self addSubview:self.activityIndicator];
    self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;

    [self addConstraints:[NSLayoutConstraint
                             constraintsWithVisualFormat:@"H:|[_activityIndicator]"
                                                 options:NSLayoutFormatAlignAllLeft
                                                 metrics:nil
                                                   views:NSDictionaryOfVariableBindings (_activityIndicator)]];

    [self addConstraints:[NSLayoutConstraint
                             constraintsWithVisualFormat:@"V:|[_activityIndicator]"
                                                 options:NSLayoutFormatAlignAllTop
                                                 metrics:nil
                                                   views:NSDictionaryOfVariableBindings (_activityIndicator)]];

    UILongPressGestureRecognizer* longPressGestureRecognizer =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector (clearSignature)];
    [self addGestureRecognizer:longPressGestureRecognizer];
    self.tracedPointsCollection = [NSMutableArray new];
    self.bezierPath = [UIBezierPath bezierPath];
    self.eraserBezierPath = [UIBezierPath bezierPath];
    self.lineDashPatternsCollection = @[
        @[],
        @[ @2, @2 ],
        @[ @6, @2 ],
        @[ @8, @2 ],
        @[ @6, @4, @2, @4 ],
        @[ @10, @4, @6, @4 ],
        @[ @8, @4, @2, @4, @2, @4 ],
        @[ @8, @4, @8, @4, @2, @4 ]
    ];
    self.selectedSignatureLineDashPattern = LineDashPatternRegular;
    self.viewLayer.lineDashPattern = self.lineDashPatternsCollection[self.selectedSignatureLineDashPattern];
}

- (void)initializeViewLayer {
    CAShapeLayer* drawingLayer = [CAShapeLayer layer];
    drawingLayer.fillColor = [UIColor clearColor].CGColor;
    drawingLayer.lineWidth = self.signatureStrokeSize;
    drawingLayer.strokeColor = self.signatureStrokeColor.CGColor;
    self.viewLayer = drawingLayer;
    [self.layer addSublayer:self.viewLayer];

    CAShapeLayer* eraserLayer = [CAShapeLayer layer];
    eraserLayer.fillColor = [UIColor clearColor].CGColor;
    eraserLayer.lineWidth = 4;
    eraserLayer.strokeColor = [UIColor clearColor].CGColor;
    self.signatureEraserLayer = eraserLayer;
    [self.layer addSublayer:self.signatureEraserLayer];
}

- (UIImage*)outputSignatureImage {
    [self completeSignatureCreationOperation];
    CGSize size = [self bounds].size;
    UIGraphicsBeginImageContext (size);
    [[self layer] renderInContext:UIGraphicsGetCurrentContext ()];
    UIImage* signatureImage = UIGraphicsGetImageFromCurrentImageContext ();
    UIGraphicsEndImageContext ();
    return signatureImage;
}

- (void)createVideoForCurrentSignatureWithCompletionBlock:
            (void (^) (JKFancySignatureVideo* outputVideoObject))completion
                                            andErrorBlock:(void (^) (NSError*))error {
    if (!self.isCreatingSignatureVideo) {
        [self.activityIndicator startAnimating];
        [self completeSignatureCreationOperation];
        self.videoRecordingCompletion = completion;
        self.videoRecordingErrorOperation = error;
        self.isCreatingSignatureVideo = YES;
        ASScreenRecorder* screenRecorder = [ASScreenRecorder sharedInstance];
        [screenRecorder startRecording];
        screenRecorder.videoFileName = self.videoFileName;

        if (self.selectedSignatureMode == SignatureModePlain) {
            [self tracePathWithLine];
        } else {
            if (self.originalTracedPointsCollection.count) {
                [self clearSignature];
                NSTimeInterval timeInterval = self.totalSignatureTime / self.originalTracedPointsCollection.count;
                self.timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval
                                                              target:self
                                                            selector:@selector (drawPath:)
                                                            userInfo:nil
                                                             repeats:YES];
            }
        }
    }
}

- (void)drawPath:(NSTimer*)timer {
    if (self.originalTracedPointsCollection.count) {
        NSValue* pointValue = [self.originalTracedPointsCollection firstObject];
        [self.tracedPointsCollection addObject:pointValue];
        [self setNeedsDisplayInRect:[self rectFromPoint:[pointValue CGPointValue]]];
        [self.originalTracedPointsCollection removeObjectAtIndex:0];
    } else {
        [self.timer invalidate];
        self.timer = nil;
        self.originalTracedPointsCollection = [self.tracedPointsCollection mutableCopy];
        [self.tracedPointsCollection removeAllObjects];
        [self stopRecordingAndProduceVideoOutputFile];
    }
}

- (void)setSignatureFillColor:(UIColor*)signatureFillColor {
    self.viewLayer.fillColor = signatureFillColor.CGColor;
}

- (void)updateStrokeColorWithColor:(UIColor*)updatedStrokeColor {
    self.signatureStrokeColor = updatedStrokeColor;
    self.viewLayer.strokeColor = self.signatureStrokeColor.CGColor;
}

- (void)updateLineCapWithValue:(NSString*)lineCapValue {
    self.viewLayer.lineCap = lineCapValue;
}

- (void)updateLineDashPatternWithPattern:(LineDashPattern)lineDashPattern {
    NSArray* selectedDashPattern = self.lineDashPatternsCollection[lineDashPattern];
    NSMutableArray* updatedLineDashPatternArray = [NSMutableArray new];
    for (NSNumber* lineDashPatternNumber in selectedDashPattern) {
        NSNumber* updatedDashPattern = @((self.signatureStrokeSize / 0.75) * [lineDashPatternNumber integerValue]);
        [updatedLineDashPatternArray addObject:updatedDashPattern];
    }
    self.selectedSignatureLineDashPattern = lineDashPattern;
    self.viewLayer.lineDashPattern = updatedLineDashPatternArray;
}

- (void)updateBackgroundColorWithColor:(UIColor*)backgroundColor {
    self.backgroundColor = backgroundColor;
    self.signatureEraserLayer.strokeColor = backgroundColor.CGColor;
}

- (void)updateStrokeSizeWithSize:(CGFloat)strokeSize {
    self.signatureStrokeSize = strokeSize;
    self.viewLayer.lineWidth = self.signatureStrokeSize;
    self.signaturePointsDistanceThreshold = self.signatureStrokeSize;
    [self updateLineDashPatternWithPattern:self.selectedSignatureLineDashPattern];
}

- (void)updateEraserSizeWithValue:(CGFloat)eraserSize {
    self.signatureEraserLayer.lineWidth = eraserSize;
}

- (void)updateSignatureImageWithImage:(UIImage*)signatureImage {
    NSAssert (signatureImage != nil, @"Initizlier signatureStrokeSize andSignatureImage should be invoked with non-nil "
                                     @"signatureImage for signature to appear on the viewport");
    self.signatureImage = signatureImage;
}

@end
