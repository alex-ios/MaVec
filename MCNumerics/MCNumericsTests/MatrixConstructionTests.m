//
//  MatrixConstructionTests.m
//  MCNumerics
//
//  Created by andrew mcknight on 3/8/14.
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

#import "MCMatrix.h"
#import "MCVector.h"

@interface MatrixConstructionTests : XCTestCase

@end

@implementation MatrixConstructionTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testDiagonalMatrixCreation
{
    size_t size = 4 * sizeof(double);
    double *diagonalValues = malloc(size);
    diagonalValues[0] = 1.0;
    diagonalValues[1] = 2.0;
    diagonalValues[2] = 3.0;
    diagonalValues[3] = 4.0;
    MCMatrix *diagonal = [MCMatrix diagonalMatrixWithValues:[NSData dataWithBytes:diagonalValues length:size] order:4];
    
    size = 16 * sizeof(double);
    double *solution = malloc(size);
    solution[0] = 1.0;
    solution[1] = 0.0;
    solution[2] = 0.0;
    solution[3] = 0.0;
    solution[4] = 0.0;
    solution[5] = 2.0;
    solution[6] = 0.0;
    solution[7] = 0.0;
    solution[8] = 0.0;
    solution[9] = 0.0;
    solution[10] = 3.0;
    solution[11] = 0.0;
    solution[12] = 0.0;
    solution[13] = 0.0;
    solution[14] = 0.0;
    solution[15] = 4.0;
    MCMatrix *s = [MCMatrix matrixWithValues:[NSData dataWithBytes:solution length:size] rows:4 columns:4];
    
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            XCTAssertEqual([diagonal valueAtRow:i column:j].doubleValue, [s valueAtRow:i column:j].doubleValue, @"Value at row %u and column %u incorrect", i, j);
        }
    }
}

- (void)testIdentityMatrixCreation
{
    MCMatrix *identity = [MCMatrix identityMatrixOfOrder:4 precision:MCValuePrecisionDouble];
    
    size_t size = 16 * sizeof(double);
    double *solution = malloc(size);
    solution[0] = 1.0;
    solution[1] = 0.0;
    solution[2] = 0.0;
    solution[3] = 0.0;
    solution[4] = 0.0;
    solution[5] = 1.0;
    solution[6] = 0.0;
    solution[7] = 0.0;
    solution[8] = 0.0;
    solution[9] = 0.0;
    solution[10] = 1.0;
    solution[11] = 0.0;
    solution[12] = 0.0;
    solution[13] = 0.0;
    solution[14] = 0.0;
    solution[15] = 1.0;
    MCMatrix *s = [MCMatrix matrixWithValues:[NSData dataWithBytes:solution length:size] rows:4 columns:4];
    
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            XCTAssertEqual([identity valueAtRow:i column:j].doubleValue, [s valueAtRow:i column:j].doubleValue, @"Value at row %u and column %u incorrect", i, j);
        }
    }
}

- (void)testSymmetricMatrixCreation
{
    double solutionValues[9] = {
        1.0, 2.0, 3.0,
        2.0, 5.0, 7.0,
        3.0, 7.0, 12.0
    };
    MCMatrix *solutionMatrix = [MCMatrix matrixWithValues:[NSData dataWithBytes:solutionValues length:9*sizeof(double)] rows:3 columns:3];
    
    // packed row-major upper triangular
    double rowMajorPackedUpperValues[6] = {
        1.0, 2.0, 3.0,
        5.0, 7.0,
        12.0
    };
    MCMatrix *matrix = [MCMatrix symmetricMatrixWithPackedValues:[NSData dataWithBytes:rowMajorPackedUpperValues length:6*sizeof(double)]
                                             triangularComponent:MCMatrixTriangularComponentUpper
                                                leadingDimension:MCMatrixLeadingDimensionRow
                                                           order:3];
    XCTAssert(matrix.isSymmetric, @"Packed row-major symmetric matrix constructed incorrectly.");
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            XCTAssertEqual([solutionMatrix valueAtRow:i column:j].doubleValue, [matrix valueAtRow:i column:j].doubleValue, @"Value at %u, %u incorrect.", i, j);
        }
    }
    
    // packed row-major lower triangular
    double rowMajorPackedLowerValues[6] = {
        1.0,
        2.0, 5.0,
        3.0, 7.0, 12.0
    };
    matrix = [MCMatrix symmetricMatrixWithPackedValues:[NSData dataWithBytes:rowMajorPackedLowerValues length:6*sizeof(double)]
                                   triangularComponent:MCMatrixTriangularComponentLower
                                      leadingDimension:MCMatrixLeadingDimensionRow
                                                 order:3];
    XCTAssert(matrix.isSymmetric, @"Packed row-major symmetric matrix constructed incorrectly.");
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            XCTAssertEqual([solutionMatrix valueAtRow:i column:j].doubleValue, [matrix valueAtRow:i column:j].doubleValue, @"Value at %u, %u incorrect.", i, j);
        }
    }
    
    // packed column-major lower triangular
    double columnMajorPackedLowerValues[6] = {
        1.0, 2.0, 3.0,
        5.0, 7.0,
        12.0
    };
    matrix = [MCMatrix symmetricMatrixWithPackedValues:[NSData dataWithBytes:columnMajorPackedLowerValues length:6*sizeof(double)]
                                   triangularComponent:MCMatrixTriangularComponentLower
                                      leadingDimension:MCMatrixLeadingDimensionColumn
                                                 order:3];
    XCTAssert(matrix.isSymmetric, @"Packed column-major symmetric matrix constructed incorrectly.");
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            XCTAssertEqual([solutionMatrix valueAtRow:i column:j].doubleValue, [matrix valueAtRow:i column:j].doubleValue, @"Value at %u, %u incorrect.", i, j);
        }
    }
    
    // packed column-major upper triangular
    double columnMajorPackedUpperValues[6] = {
        1.0,
        2.0, 5.0,
        3.0, 7.0, 12.0
    };
    matrix = [MCMatrix symmetricMatrixWithPackedValues:[NSData dataWithBytes:columnMajorPackedUpperValues length:6*sizeof(double)]
                                   triangularComponent:MCMatrixTriangularComponentUpper
                                      leadingDimension:MCMatrixLeadingDimensionColumn
                                                 order:3];
    XCTAssert(matrix.isSymmetric, @"Packed column-major symmetric matrix constructed incorrectly.");
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            XCTAssertEqual([solutionMatrix valueAtRow:i column:j].doubleValue, [matrix valueAtRow:i column:j].doubleValue, @"Value at %u, %u incorrect.", i, j);
        }
    }
}

- (void)testTriangularMatrixCreation
{
    double upperSolutionValues[9] = {
        1.0,   2.0,   3.0,
        0.0,   5.0,   7.0,
        0.0,   0.0,   12.0
    };
    MCMatrix *upperSolution = [MCMatrix matrixWithValues:[NSData dataWithBytes:upperSolutionValues length:9*sizeof(double)]
                                                    rows:3
                                                 columns:3
                                        leadingDimension:MCMatrixLeadingDimensionRow];
    
    // upper row-major
    double rowMajorUpperValues[6] = {
        1.0, 2.0, 3.0,
        5.0, 7.0,
        12.0
    };
    MCMatrix *matrix = [MCMatrix triangularMatrixWithPackedValues:[NSData dataWithBytes:rowMajorUpperValues length:6*sizeof(double)]
                                            ofTriangularComponent:MCMatrixTriangularComponentUpper
                                                 leadingDimension:MCMatrixLeadingDimensionRow
                                                            order:3];
    XCTAssert([matrix isEqualToMatrix:upperSolution], @"Upper triangular row major matrix incorrectly created.");
    
    // upper column-major
    double columnMajorUpperValues[6] = {
        1.0, 2.0, 5.0,
        3.0, 7.0,
        12.0
    };
    matrix = [MCMatrix triangularMatrixWithPackedValues:[NSData dataWithBytes:columnMajorUpperValues length:6*sizeof(double)]
                                  ofTriangularComponent:MCMatrixTriangularComponentUpper
                                       leadingDimension:MCMatrixLeadingDimensionColumn
                                                  order:3];
    XCTAssert([matrix isEqualToMatrix:upperSolution], @"Upper triangular column major matrix incorrectly created.");
    
    double lowerSolutionValues[9] = {
        1.0,   0.0,   0.0,
        2.0,   5.0,   0.0,
        3.0,   7.0,   12.0
    };
    MCMatrix *lowerSolution = [MCMatrix matrixWithValues:[NSData dataWithBytes:lowerSolutionValues length:9*sizeof(double)]
                                                    rows:3
                                                 columns:3
                                        leadingDimension:MCMatrixLeadingDimensionRow];
    
    // lower row-major
    double rowMajorLowerValues[6] = {
        1.0, 2.0, 5.0,
        3.0, 7.0,
        12.0
    };
    matrix = [MCMatrix triangularMatrixWithPackedValues:[NSData dataWithBytes:rowMajorLowerValues length:6*sizeof(double)]
                                  ofTriangularComponent:MCMatrixTriangularComponentLower
                                       leadingDimension:MCMatrixLeadingDimensionRow
                                                  order:3];
    XCTAssert([matrix isEqualToMatrix:lowerSolution], @"Lower triangular row major matrix incorrectly created.");
    
    // lower column-major
    double columnMajorLowerValues[6] = {
        1.0, 2.0, 3.0,
        5.0, 7.0,
        12.0
    };
    matrix = [MCMatrix triangularMatrixWithPackedValues:[NSData dataWithBytes:columnMajorLowerValues length:6*sizeof(double)]
                                  ofTriangularComponent:MCMatrixTriangularComponentLower
                                       leadingDimension:MCMatrixLeadingDimensionColumn
                                                  order:3];
    XCTAssert([matrix isEqualToMatrix:lowerSolution], @"Lower triangular column major matrix incorrectly created.");
}

- (void)testBandMatrixCreation
{
    // balanced codiagonals
    double balancedBandValues[15] = {
        0.0,  1.0,  2.0,  3.0,  4.0,
        10.0, 20.0, 30.0, 40.0, 50.0,
        5.0,  6.0,  7.0,  8.0,  0.0
    };
    MCMatrix *matrix = [MCMatrix bandMatrixWithValues:[NSData dataWithBytes:balancedBandValues length:15*sizeof(double)]
                                                order:5
                                     upperCodiagonals:1
                                     lowerCodiagonals:1];
    
    double oddBandwidthSolutionValues[25] = {
        10.0,  1.0,   0.0,   0.0,   0.0,
        5.0,   20.0,  2.0,   0.0,   0.0,
        0.0,   6.0,   30.0,  3.0,   0.0,
        0.0,   0.0,   7.0,   40.0,  4.0,
        0.0,   0.0,   0.0,   8.0,   50.0
    };
    MCMatrix *solution = [MCMatrix matrixWithValues:[NSData dataWithBytes:oddBandwidthSolutionValues length:25*sizeof(double)]
                                               rows:5
                                            columns:5
                                   leadingDimension:MCMatrixLeadingDimensionRow];
    
    for (int row = 0; row < 5; row += 1) {
        for (int col = 0; col < 5; col += 1) {
            XCTAssertEqual([matrix valueAtRow:row column:col].doubleValue, [solution valueAtRow:row column:col].doubleValue, @"Incorrect value at %u, %u in constructed band matrix with balanced codiagonals.", row, col);
        }
    }
    
    // extra upper codiagonal
    double bandValuesWithExtraUpper[20] = {
        0.0,  0.0,  -1.0, -2.0, -3.0,
        0.0,  1.0,  2.0,  3.0,  4.0,
        10.0, 20.0, 30.0, 40.0, 50.0,
        5.0,  6.0,  7.0,  8.0,  0.0
    };
    matrix = [MCMatrix bandMatrixWithValues:[NSData dataWithBytes:bandValuesWithExtraUpper length:20*sizeof(double)]
                                      order:5
                           upperCodiagonals:2
                           lowerCodiagonals:1];
    
    double solutionValuesWithExtraUpper[25] = {
        10.0,  1.0,   -1.0,   0.0,   0.0,
        5.0,   20.0,  2.0,    -2.0,  0.0,
        0.0,   6.0,   30.0,   3.0,   -3.0,
        0.0,   0.0,   7.0,    40.0,  4.0,
        0.0,   0.0,   0.0,    8.0,   50.0
    };
    solution = [MCMatrix matrixWithValues:[NSData dataWithBytes:solutionValuesWithExtraUpper length:25*sizeof(double)]
                                     rows:5
                                  columns:5
                         leadingDimension:MCMatrixLeadingDimensionRow];
    
    for (int row = 0; row < 5; row += 1) {
        for (int col = 0; col < 5; col += 1) {
            XCTAssertEqual([matrix valueAtRow:row column:col].doubleValue, [solution valueAtRow:row column:col].doubleValue, @"Incorrect value at %u, %u in constructed band matrix with extra upper codiagonal.", row, col);
        }
    }
    
    // extra lower codiagonal
    double bandValuesWithExtraLower[20] = {
        0.0,  1.0,  2.0,  3.0,  4.0,
        10.0, 20.0, 30.0, 40.0, 50.0,
        5.0,  6.0,  7.0,  8.0,  0.0,
        -1.0, -2.0, -3.0, 0.0,  0.0
    };
    matrix = [MCMatrix bandMatrixWithValues:[NSData dataWithBytes:bandValuesWithExtraLower length:20*sizeof(double)]
                                      order:5
                           upperCodiagonals:1
                           lowerCodiagonals:2];

    double solutionValuesWithExtraLower[25] = {
        10.0,  1.0,   0.0,   0.0,   0.0,
        5.0,   20.0,  2.0,   0.0,   0.0,
        -1.0,   6.0,   30.0,  3.0,   0.0,
        0.0,   -2.0,   7.0,   40.0,  4.0,
        0.0,   0.0,   -3.0,   8.0,   50.0
    };
    solution = [MCMatrix matrixWithValues:[NSData dataWithBytes:solutionValuesWithExtraLower length:25*sizeof(double)]
                                     rows:5
                                  columns:5
                         leadingDimension:MCMatrixLeadingDimensionRow];
    
    for (int row = 0; row < 5; row += 1) {
        for (int col = 0; col < 5; col += 1) {
            XCTAssertEqual([matrix valueAtRow:row column:col].doubleValue, [solution valueAtRow:row column:col].doubleValue, @"Incorrect value at %u, %u in constructed band matrix with extra lower codiagonal.", row, col);
        }
    }
    
    // two upper, no lower
    double bandValuesWithTwoUpper[15] = {
        0.0,  0.0,  -1.0, -2.0, -3.0,
        0.0,  1.0,  2.0,  3.0,  4.0,
        10.0, 20.0, 30.0, 40.0, 50.0
    };
    matrix = [MCMatrix bandMatrixWithValues:[NSData dataWithBytes:bandValuesWithTwoUpper length:15*sizeof(double)]
                                      order:5
                           upperCodiagonals:2
                           lowerCodiagonals:0];
    
    double solutionValuesWithTwoUpper[25] = {
        10.0,  1.0,   -1.0,   0.0,   0.0,
        0.0,   20.0,  2.0,    -2.0,  0.0,
        0.0,   0.0,   30.0,   3.0,   -3.0,
        0.0,   0.0,   0.0,    40.0,  4.0,
        0.0,   0.0,   0.0,    0.0,   50.0
    };
    solution = [MCMatrix matrixWithValues:[NSData dataWithBytes:solutionValuesWithTwoUpper length:25*sizeof(double)]
                                     rows:5
                                  columns:5
                         leadingDimension:MCMatrixLeadingDimensionRow];
    
    for (int row = 0; row < 5; row += 1) {
        for (int col = 0; col < 5; col += 1) {
            XCTAssertEqual([matrix valueAtRow:row column:col].doubleValue, [solution valueAtRow:row column:col].doubleValue, @"Incorrect value at %u, %u in constructed band matrix with extra lower codiagonal.", row, col);
        }
    }
    
    // two lower, no upper
    double bandValuesWithTwoLower[15] = {
        10.0, 20.0, 30.0, 40.0, 50.0,
        5.0,  6.0,  7.0,  8.0,  0.0,
        -1.0, -2.0, -3.0, 0.0,  0.0
    };
    matrix = [MCMatrix bandMatrixWithValues:[NSData dataWithBytes:bandValuesWithTwoLower length:15*sizeof(double)]
                                      order:5
                           upperCodiagonals:0
                           lowerCodiagonals:2];
    
    double solutionValuesWithTwoLower[25] = {
        10.0,  0.0,   0.0,   0.0,   0.0,
        5.0,   20.0,  0.0,   0.0,   0.0,
        -1.0,  6.0,   30.0,  0.0,   0.0,
        0.0,   -2.0,  7.0,   40.0,  0.0,
        0.0,   0.0,   -3.0,  8.0,   50.0
    };
    solution = [MCMatrix matrixWithValues:[NSData dataWithBytes:solutionValuesWithTwoLower length:25*sizeof(double)]
                                     rows:5
                                  columns:5
                         leadingDimension:MCMatrixLeadingDimensionRow];
    
    for (int row = 0; row < 5; row += 1) {
        for (int col = 0; col < 5; col += 1) {
            XCTAssertEqual([matrix valueAtRow:row column:col].doubleValue, [solution valueAtRow:row column:col].doubleValue, @"Incorrect value at %u, %u in constructed band matrix with extra lower codiagonal.", row, col);
        }
    }
}

- (void)testMatrixCreationFromVectors
{
    MCVector *v1 = [MCVector vectorWithValuesInArray:@[@1.0, @2.0, @3.0]];
    MCVector *v2 = [MCVector vectorWithValuesInArray:@[@4.0, @5.0, @6.0]];
    MCVector *v3 = [MCVector vectorWithValuesInArray:@[@7.0, @8.0, @9.0]];
    
    /* create the matrix
     [ 1  4  7
     2  5  8
     3  6  9 ]
     */
    MCMatrix *a = [MCMatrix matrixWithColumnVectors:@[v1, v2, v3]];
    
    /* create the matrix
     [ 1  2  3
     4  5  6
     7  8  9 ]
     */
    MCMatrix *b = [MCMatrix matrixWithRowVectors:@[v1, v2, v3]];
}

- (void)testRandomDefiniteMatrices
{
    int numberOfTests = 1000;
    
    int positiveDefiniteFails = 0;
    int negativeDefiniteFails = 0;
    int positiveSemidefiniteFails = 0;
    int negativeSemidefiniteFails = 0;
    int indefiniteFails = 0;
    
    MCMatrix *test;
    
    for(int i = 0; i < numberOfTests; i++) {
        int order = 3;
        MCMatrix *positiveDefinite = [MCMatrix randomMatrixOfOrder:order definiteness:MCMatrixDefinitenessPositiveDefinite precision:MCValuePrecisionDouble];
        test = [MCMatrix matrixWithValues:[positiveDefinite valuesWithLeadingDimension:MCMatrixLeadingDimensionColumn] rows:order columns:order];
        if (test.definiteness != MCMatrixDefinitenessPositiveDefinite) {
            positiveDefiniteFails++;
        }
        
        MCMatrix *negativeDefinite = [MCMatrix randomMatrixOfOrder:3 definiteness:MCMatrixDefinitenessNegativeDefinite precision:MCValuePrecisionDouble];
        test = [MCMatrix matrixWithValues:[negativeDefinite valuesWithLeadingDimension:MCMatrixLeadingDimensionColumn] rows:order columns:order];
        if (test.definiteness != MCMatrixDefinitenessNegativeDefinite) {
            negativeDefiniteFails++;
        }
        
        MCMatrix *positiveSemidefinite = [MCMatrix randomMatrixOfOrder:3 definiteness:MCMatrixDefinitenessPositiveSemidefinite precision:MCValuePrecisionDouble];
        test = [MCMatrix matrixWithValues:[positiveSemidefinite valuesWithLeadingDimension:MCMatrixLeadingDimensionColumn] rows:order columns:order];
        if (test.definiteness != MCMatrixDefinitenessPositiveSemidefinite) {
            positiveSemidefiniteFails++;
        }
        
        MCMatrix *negativeSemidefinite = [MCMatrix randomMatrixOfOrder:3 definiteness:MCMatrixDefinitenessNegativeSemidefinite precision:MCValuePrecisionDouble];
        test = [MCMatrix matrixWithValues:[negativeSemidefinite valuesWithLeadingDimension:MCMatrixLeadingDimensionColumn] rows:order columns:order];
        if (test.definiteness != MCMatrixDefinitenessNegativeSemidefinite) {
            negativeSemidefiniteFails++;
        }
        
        MCMatrix *indefinite = [MCMatrix randomMatrixOfOrder:3 definiteness:MCMatrixDefinitenessIndefinite precision:MCValuePrecisionDouble];
        test = [MCMatrix matrixWithValues:[indefinite valuesWithLeadingDimension:MCMatrixLeadingDimensionColumn] rows:order columns:order];
        if (test.definiteness != MCMatrixDefinitenessIndefinite) {
            indefiniteFails++;
        }
    }
    
    XCTAssert(positiveDefiniteFails == 0, @"%i positive definite failures", positiveDefiniteFails);
    XCTAssert(negativeDefiniteFails == 0, @"%i negative definite failures", negativeDefiniteFails);
    XCTAssert(positiveSemidefiniteFails == 0, @"%i positive semidefinite failures", positiveSemidefiniteFails);
    XCTAssert(negativeSemidefiniteFails == 0, @"%i negative semidefinite failures", negativeSemidefiniteFails);
    XCTAssert(indefiniteFails == 0, @"%i indefinite failures", indefiniteFails);
}

- (void)testRandomSingularMatrices
{
    int numberOfTests = 97;
    
    int singularFails = 0;
    
    MCMatrix *test;
    
    int order = 3;
    for(int i = 0; i < numberOfTests; i++) {
        MCMatrix *singular = [MCMatrix randomSingularMatrixOfOrder:order precision:MCValuePrecisionDouble];
        test = [MCMatrix matrixWithValues:[singular valuesWithLeadingDimension:MCMatrixLeadingDimensionColumn] rows:order columns:order];
        if ([test.determinant compare:@0.0] != NSOrderedSame) {
            singularFails++;
        }
        order++;
    }
    
    XCTAssert(singularFails == 0, @"%i singular failures", singularFails);
}

- (void)testRandomNonsingularMatrices
{
    int numberOfTests = 97;
    
    int nonsingularFails = 0;
    
    MCMatrix *test;
    
    int order = 3;
    for(int i = 0; i < numberOfTests; i++) {
        MCMatrix *singular = [MCMatrix randomNonsigularMatrixOfOrder:order precision:MCValuePrecisionDouble];
        test = [MCMatrix matrixWithValues:[singular valuesWithLeadingDimension:MCMatrixLeadingDimensionColumn] rows:order columns:order];
        if ([test.determinant compare:@0.0] == NSOrderedSame) {
            nonsingularFails++;
        }
        order++;
    }
    
    XCTAssert(nonsingularFails == 0, @"%i nonsingular failures", nonsingularFails);
}

@end
