//
//  SVDImageCompressionViewController.m
//  MCNumerics
//
//  Created by andrew mcknight on 3/30/14.
//  Copyright (c) 2014 andrew mcknight. All rights reserved.
//

#import "SVDImageCompressionViewController.h"

#import "MCMatrix.h"
#import "MCVector.h"
#import "MCSingularValueDecomposition.h"

@interface SVDImageCompressionViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UISlider *compressionSlider;
@property (strong, nonatomic) IBOutlet UILabel *compressionLabel;

@property (strong, nonatomic) IBOutlet UIView *progressView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) MCSingularValueDecomposition *imageSVD;

@property (assign, nonatomic) int currentAmountOfSingularValues;

@end

@implementation SVDImageCompressionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
}

#pragma mark - Actions

- (IBAction)takePhotoPressed:(id)sender
{
    ((UIButton *)sender).enabled = NO;
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    
    imagePicker.delegate = self;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (IBAction)compressionSliderValueChanged:(id)sender
{
    int singularValues = ((UISlider *)sender).value;
    self.compressionLabel.text = [NSString stringWithFormat:@"Singular values: %d/%d", singularValues, self.imageSVD.s.diagonalValues.length];
}

- (IBAction)compressionSliderFinishedChangingValue:(id)sender
{
    int singularValues = ((UISlider *)sender).value;
    if (self.currentAmountOfSingularValues != singularValues) {
        self.currentAmountOfSingularValues = singularValues;
        __weak typeof(self) wself = self;
        [self setProgressViewVisible:YES completion:^{
            wself.imageView.image = [wself compressedImageWithSingularValues:singularValues];
            [wself setProgressViewVisible:NO completion:nil];
        }];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *grayscaleImage = [self getGrayscaleImageFromImage:image];
    UIImage *croppedGrayscaleImage = [self cropImage:grayscaleImage];
    
    self.imageView.image = croppedGrayscaleImage;
    
    MCMatrix *grayscaleValues = [self getGrayscalePixelValuesFromImage:croppedGrayscaleImage];
    self.imageSVD = [MCSingularValueDecomposition singularValueDecompositionWithMatrix:grayscaleValues];
    
    MCVector *singularValues = self.imageSVD.s.diagonalValues;
    self.compressionSlider.minimumValue = 1;
    self.compressionSlider.maximumValue = singularValues.length;
    self.currentAmountOfSingularValues = singularValues.length;
    self.compressionSlider.enabled = YES;
    [self.compressionSlider setValue:singularValues.length animated:YES];
    self.compressionLabel.text = [NSString stringWithFormat:@"Singular values: %d/%d", singularValues.length, self.imageSVD.s.diagonalValues.length];
}

#pragma mark - Private interface

// adapted from http://stackoverflow.com/questions/448125/how-to-get-pixel-data-from-a-uiimage-cocoa-touch-or-cgimage-core-graphics
- (MCMatrix *)getGrayscalePixelValuesFromImage:(UIImage*)image
{
    // First get the image into your data buffer
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceCreateDeviceGray();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    // Now your rawData contains the image data in the RGBA8888 pixel format.
    NSUInteger numberOfPixels = height * width;
    double *grayscaleValues = calloc(numberOfPixels, sizeof(double));
    NSUInteger z = 0;
    for (NSUInteger i = 0 ; i < numberOfPixels ; i++) {
        grayscaleValues[i] = (rawData[z] * 1.0) / 255.0;
        z += 4;
    }
    
    free(rawData);
    
    MCMatrix *grayscaleMatrix = [MCMatrix matrixWithValues:grayscaleValues rows:(int)height columns:(int)width];
    
    return grayscaleMatrix;
}

// adapted from http://stackoverflow.com/questions/1298867/convert-image-to-grayscale
- (UIImage *)getGrayscaleImageFromImage:(UIImage *)image
{
    UIGraphicsBeginImageContextWithOptions(image.size, YES, 1.0);
    CGRect imageRect;
    imageRect.origin = CGPointZero;
    imageRect.size = image.size;
    
    // Draw the image with the luminosity blend mode.
    // On top of a white background, this will give a black and white image.
    [image drawInRect:imageRect blendMode:kCGBlendModeLuminosity alpha:1.0];
    
    // Get the resulting image.
    UIImage *filteredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return filteredImage;
}

// adapted from http://stackoverflow.com/questions/158914/cropping-a-uiimage
- (UIImage *)cropImage:(UIImage *)image
{
    CGFloat squareSize = 300;
    CGRect imageRect = CGRectMake((image.size.width - squareSize) / 2, (image.size.height - squareSize) / 2, squareSize, squareSize);
    CGImageRef croppedImageRef = CGImageCreateWithImageInRect(image.CGImage, imageRect);
    UIImage *croppedImage = [UIImage imageWithCGImage:croppedImageRef scale:1 orientation:UIImageOrientationUp];
    CGImageRelease(croppedImageRef);
    
    return croppedImage;
}

// adapted from http://stackoverflow.com/questions/4545237/creating-uiimage-from-raw-rgba-data
- (UIImage *)compressedImageWithSingularValues:(int)singularValues
{
    MCVector *partialSum = [MCVector productOfVector:[self.imageSVD.u columnVectorForColumn:0] scalar:[self.imageSVD.s.diagonalValues valueAtIndex:0]];
    MCMatrix *leftMultiplicand = [MCMatrix matrixWithValues:partialSum.values rows:partialSum.length columns:1];
    MCVector *rightMultiplicandVector = [self.imageSVD.vT rowVectorForRow:0];
    MCMatrix *rightMultiplicand = [MCMatrix matrixWithValues:rightMultiplicandVector.values rows:1 columns:rightMultiplicandVector.length];
    MCMatrix *sum = [MCMatrix productOfMatrixA:leftMultiplicand andMatrixB:rightMultiplicand];
    for (int i = singularValues - 1; i >= 0; i--) {
        partialSum = [MCVector productOfVector:[self.imageSVD.u columnVectorForColumn:i] scalar:[self.imageSVD.s.diagonalValues valueAtIndex:i]];
        leftMultiplicand = [MCMatrix matrixWithValues:partialSum.values rows:partialSum.length columns:1];
        rightMultiplicandVector = [self.imageSVD.vT rowVectorForRow:i];
        rightMultiplicand = [MCMatrix matrixWithValues:rightMultiplicandVector.values rows:1 columns:rightMultiplicandVector.length];
        sum = [MCMatrix sumOfMatrixA:sum andMatrixB:[MCMatrix productOfMatrixA:leftMultiplicand andMatrixB:rightMultiplicand]];
    }
    
    int size = sum.rows * sum.columns;
    unsigned char *pixelValues = malloc(size * 4);
    for (int i = 0; i < size; i++) {
        double grayscaleValue = sum.values[i];
        pixelValues[4 * i] = grayscaleValue * 255;
        pixelValues[4 * i + 1] = grayscaleValue * 255;
        pixelValues[4 * i + 2] = grayscaleValue * 255;
        pixelValues[4 * i + 3] = 255;
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, pixelValues, size * 4, NULL);
    CGImageRef imageRef = CGImageCreate(sum.columns,
                                        sum.rows,
                                        8,
                                        32,
                                        4 * sum.columns,
                                        CGColorSpaceCreateDeviceRGB(),
                                        kCGBitmapByteOrderDefault,
                                        provider,
                                        NULL,
                                        NO,
                                        kCGRenderingIntentDefault);
    
    UIImage *compressedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return compressedImage;
}

- (void)setProgressViewVisible:(BOOL)visible completion:(void(^)())completion
{
    if (visible) {
        [self.activityIndicator startAnimating];
        self.progressView.hidden = NO;
    }
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.progressView.alpha = visible ? 0.5f : 0.f;
                     }
                     completion:^(BOOL finished) {
                         if (!visible) {
                             self.progressView.hidden = YES;
                             [self.activityIndicator stopAnimating];
                         }
                         if (completion) {
                             completion();
                         }
                     }];
}

@end
