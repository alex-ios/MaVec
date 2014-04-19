//
//  MCNumericsTests.m
//  MCNumericsTests
//
//  Created by andrew mcknight on 12/2/13.
//
//  Copyright (c) 2014 Andrew Robert McKnight
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import <XCTest/XCTest.h>
#import <Accelerate/Accelerate.h>
#import "MCMatrix.h"
#import "MCVector.h"
#import "MCSingularValueDecomposition.h"
#import "MCLUFactorization.h"
#import "MCTribool.h"
#import "MCEigendecomposition.h"
#import "MCQRFactorization.h"

@interface MCNumericsTests : XCTestCase

@end

@implementation MCNumericsTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testMultiplyingMatrixByVector
{
    size_t aSize = 16 * sizeof(double);
    size_t bSize = 4 * sizeof(double);
    double *aVals = malloc(aSize);
    double *bVals = malloc(bSize);
    aVals[0] = 8.0;
    aVals[1] = 0.0;
    aVals[2] = 0.0;
    aVals[3] = 0.0;
    aVals[4] = 0.0;
    aVals[5] = 4.0;
    aVals[6] = 0.0;
    aVals[7] = 0.0;
    aVals[8] = 0.0;
    aVals[9] = 0.0;
    aVals[10] = 4.0;
    aVals[11] = 0.0;
    aVals[12] = 0.0;
    aVals[13] = 0.0;
    aVals[14] = 0.0;
    aVals[15] = 4.0;
    
    bVals[0] = -1.95;
    bVals[1] = -0.7445;
    bVals[2] = -2.5594;
    bVals[3] = 1.125;
    MCMatrix *a = [MCMatrix matrixWithValues:[NSData dataWithBytes:aVals length:aSize] rows:4 columns:4];
    MCVector *b = [MCVector vectorWithValues:[NSData dataWithBytes:bVals length:bSize] length:4];
    
    MCVector *product = [MCMatrix productOfMatrix:a andVector:b];
    
    double *solution = malloc(bSize);
    solution[0] = -15.6;
    solution[1] = -2.9778;
    solution[2] = -10.2376;
    solution[3] = 4.5;
    MCVector *s = [MCVector vectorWithValues:[NSData dataWithBytes:solution length:bSize] length:4];
    
    for (int i = 0; i < 4; i++) {
        XCTAssertEqualWithAccuracy([s valueAtIndex:i].doubleValue, [product valueAtIndex:i].doubleValue, 0.0005, @"Coefficient %u incorrect", i);
    }
}

@end
