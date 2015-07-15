//
//  ViewController.m
//  JKFancySignature
//
//  Created by Jayesh Kawli Backup on 7/9/15.
//  Copyright (c) 2015 Jayesh Kawli Backup. All rights reserved.
//

#import "ViewController.h"
#import "JKFancySignatureView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *signatureImageView;
@property (strong, nonatomic) JKFancySignatureView* vi;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.vi = [[JKFancySignatureView alloc] initWithStrokeSize:2.0 andSignatureStrokeColor:[UIColor blackColor]];
    self.vi.videoFileName = @"jayesh";
    //self.vi = [[JKFancySignatureView alloc] initWithStrokeSize:10.0 andSignatureImage:[UIImage imageNamed:@"airlinePlaceholder"]];
    self.vi.translatesAutoresizingMaskIntoConstraints = NO;
    self.vi.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.vi];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_vi]|" options:kNilOptions metrics:kNilOptions views:NSDictionaryOfVariableBindings(_vi)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_vi(200)]" options:kNilOptions metrics:kNilOptions views:NSDictionaryOfVariableBindings(_vi)]];
}

- (IBAction)createNewSignature:(id)sender {
    [self.vi clearPreviousSignature];
}

- (IBAction)signatureImageAction:(id)sender {
    [self.signatureImageView setImage:[self.vi outputSignatureImage]];
}

- (IBAction)createSignatureVideoAction:(id)sender {
    [self.vi createVideoForCurrentSignatureWithCompletionBlock:^(JKFancySignatureVideo* outputVideoObject) {
        
    
    } andErrorBlock:^(NSError *error) {
        
    }];
}

- (IBAction)undoSignature:(id)sender {
    [self.vi undoSignature];
}

- (IBAction)traceSignatureWithPoint:(id)sender {
    [self.vi tracePathWithPoint];
}


@end
