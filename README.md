# JKFancySignature
A Custom view to allow users to easily create, store and reproduce signature with fancy effects. Highly customizable to suite to your requirements.

# Fancy Signature view to create dynamic signature and graphics


<b><i>Simple Signature</i></b>


![alt text][FancySignatureViewDemoImage]


<b><i>Custom Signature with image stroke</i></b>

![alt text][FancySignatureViewCustomImageDemoImage]

Fancy Signature view is an innovative way to create signature on screen. Besides, simple signatures with basic functionalities it also offers extended features for advanced apps.

Some typical features are as follows:
  - Ability to change signature stroke color, size and fill color 
  - Trace the signature with animation
  - Create a video of signature creation operation
  - Store signature as an image
  - Erase signature with animation
  - Create singature with image foreground

In order to use this library, there are two ways to initialze this library based on we want regular or image signature :

For regular signature :

``` - (instancetype)initWithStrokeSize:(CGFloat)signatureStrokeSize andSignatureStrokeColor:(UIColor*)signatureStrokeColor; ```

For signature with image foreground :   
``` - (instancetype)initWithStrokeSize:(CGFloat)signatureStrokeSize andSignatureImage:(UIImage*)signatureImage; ```

where,
signatureStrokeSize - Width of the signature
signatureStrokeColor - Color of the signature
signatureImage - Input image to create signature with. Image must be non-nil

You can also update these parameters on the fly with handy methods as follows,
- ```- (void)updateStrokeColorWithColor:(UIColor*)updatedStrokeColor;```
- ```- (void)updateStrokeSizeWithSize:(CGFloat)strokeSize;```
- ```- (void)updateSignatureImageWithImage:(UIImage*)signatureImage;```

Library allows following regular operations :

- ```- (void)markSignatureDone;```  
Method to mark signature creation operation complete

- ```- (UIImage*)outputSignatureImage;```  
     Method to get created signature back as an image

- ```- (void)undoSignature;```  
Method to undo signature. This method does undo created signature with animation by sketching it backwards.
Note that this feature is only available for regular signature.

- ```- (void)clearPreviousSignature;```  
To clear the previously made signature and prepare view for new one.

- ```- (void)tracePathWithLine;```
Animation to basically re-create signature as created by user earlier. Used same bezier path and duration to re-create the scene

- ```- (void)tracePathWithPoint;```  
Simply follows the signature bezier path with bullet point

- ```- (void)createVideoForCurrentSignatureWithCompletionBlock:(void (^)(JKFancySignatureVideo* outputVideoObject))completion andErrorBlock:(void (^)(NSError* error))error;```               
To create a video of signature creation. Can come handy as proof of creating signature. Stored as an .mp4 file and storage path of file is returned back to user

### Version
0.0.1

> A Sample project is included with the library to demonstrate its working. This library is available to integrate into any iOS project with Cocoapods.

[FancySignatureViewDemoImage]: https://github.com/jayesh15111988/JKFancySignature/blob/master/Demo/Signature_Demo.gif "Simple Signature"

[FancySignatureViewCustomImageDemoImage]:
https://github.com/jayesh15111988/JKFancySignature/blob/master/Demo/Custom_Signature_Demo.gif "Custom Image Signature"
