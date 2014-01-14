//
//  Matrix.m
//  AccelerometerPlot
//
//  Created by andrew mcknight on 11/30/13.
//  Copyright (c) 2013 andrew mcknight. All rights reserved.
//

#import <Accelerate/Accelerate.h>
#import "MCMatrix.h"
#import "MCVector.h"
#import "MCSingularValueDecomposition.h"
#import "MCLUFactorization.h"
#import "MCEigendecomposition.h"

@interface MCMatrix ()

/**
 @property values
 @brief A one-dimensional C array of floating point values.
 */
@property (nonatomic, assign) double *values;

@end

@implementation MCMatrix

#pragma mark - Constructors

- (id)initWithRows:(NSUInteger)rows columns:(NSUInteger)columns
{
    self = [super init];
    
    if (self) {
        _rows = rows;
        _columns = columns;
        self.values = malloc(rows * columns * sizeof(double));
        _valueStorageFormat = MCMatrixValueStorageFormatColumnMajor;
    }
    
    return self;
}

- (id)initWithRows:(NSUInteger)rows
           columns:(NSUInteger)columns
valueStorageFormat:(MCMatrixValueStorageFormat)valueStorageFormat
{
    self = [super init];
    
    if (self) {
        _rows = rows;
        _columns = columns;
        self.values = malloc(rows * columns * sizeof(double));
        _valueStorageFormat = valueStorageFormat;
    }
    
    return self;
}

- (id)initWithValues:(double *)values
                rows:(NSUInteger)rows
             columns:(NSUInteger)columns
{
    self = [super init];
    
    if (self) {
        _rows = rows;
        _columns = columns;
        self.values = values;
        _valueStorageFormat = MCMatrixValueStorageFormatColumnMajor;
    }
    
    return self;
}

- (id)initWithValues:(double *)values
                rows:(NSUInteger)rows
             columns:(NSUInteger)columns
  valueStorageFormat:(MCMatrixValueStorageFormat)valueStorageFormat
{
    self = [super init];
    
    if (self) {
        _rows = rows;
        _columns = columns;
        self.values = values;
        _valueStorageFormat = valueStorageFormat;
    }
    
    return self;
}

- (id)initWithColumnVectors:(NSArray *)columnVectors
{
    self = [super init];
    if (self) {
        _columns = columnVectors.count;
        _rows = ((MCVector *)columnVectors.firstObject).length;
        _valueStorageFormat = MCMatrixValueStorageFormatColumnMajor;
        
        self.values = malloc(self.rows * self.columns * sizeof(double));
        [columnVectors enumerateObjectsUsingBlock:^(MCVector *columnVector, NSUInteger column, BOOL *stop) {
            for(int i = 0; i < self.rows; i++) {
                self.values[column * self.rows + i] = [columnVector valueAtIndex:i];
            }
        }];
    }
    return self;
}

- (id)initWithRowVectors:(NSArray *)rowVectors
{
    self = [super init];
    if (self) {
        _rows = rowVectors.count;
        _columns = ((MCVector *)rowVectors.firstObject).length;
        _valueStorageFormat = MCMatrixValueStorageFormatRowMajor;
        
        self.values = malloc(self.rows * self.columns * sizeof(double));
        [rowVectors enumerateObjectsUsingBlock:^(MCVector *rowVector, NSUInteger row, BOOL *stop) {
            for(int i = 0; i < self.rows; i++) {
                self.values[row * self.columns + i] = [rowVector valueAtIndex:i];
            }
        }];
    }
    return self;
}

+ (id)matrixWithColumnVectors:(NSArray *)columnVectors
{
    return [[MCMatrix alloc] initWithColumnVectors:columnVectors];
}

+ (id)matrixWithRowVectors:(NSArray *)rowVectors
{
    return [[MCMatrix alloc] initWithRowVectors:rowVectors];
}

+ (id)matrixWithRows:(NSUInteger)rows columns:(NSUInteger)columns
{
    return [[MCMatrix alloc] initWithRows:rows columns:columns];
}

+ (id)matrixWithRows:(NSUInteger)rows
             columns:(NSUInteger)columns
  valueStorageFormat:(MCMatrixValueStorageFormat)valueStorageFormat
{
    return [[MCMatrix alloc] initWithRows:rows
                                  columns:columns
                       valueStorageFormat:valueStorageFormat];
}

+ (id)matrixWithValues:(double *)values
                  rows:(NSUInteger)rows
               columns:(NSUInteger)columns
{
    return [[MCMatrix alloc] initWithValues:values
                                     rows:rows
                                  columns:columns];
}

+ (id)matrixWithValues:(double *)values
                  rows:(NSUInteger)rows
               columns:(NSUInteger)columns
    valueStorageFormat:(MCMatrixValueStorageFormat)valueStorageFormat
{
    return [[MCMatrix alloc] initWithValues:values
                                       rows:rows
                                    columns:columns
                         valueStorageFormat:valueStorageFormat];
}

+ (id)identityMatrixWithSize:(NSUInteger)size
{
    double *values = malloc(size * size * sizeof(double));
    for (int i = 0; i < size; i++) {
        for (int j = 0; j < size; j++) {
            values[i * size + j] = i == j ? 1.0 : 0.0;
        }
    }
    return [MCMatrix matrixWithValues:values
                                 rows:size
                              columns:size];
}

+ (id)diagonalMatrixWithValues:(double *)values size:(NSUInteger)size
{
    double *allValues = malloc(size * size * sizeof(double));
    for (int i = 0; i < size; i++) {
        for (int j = 0; j < size; j++) {
            allValues[i * size + j] = i == j ? values[i] : 0.0;
        }
    }
    return [MCMatrix matrixWithValues:allValues
                                 rows:size
                              columns:size];
}

//- (void)dealloc
//{
//    if (self.values) {
//        free(self.values);
//    }
//}

#pragma mark - Matrix operations

- (MCMatrix *)transpose
{
    double *aVals = self.values;
    double *tVals = malloc(self.rows * self.columns * sizeof(double));
    
    vDSP_mtransD(aVals, 1, tVals, 1, self.columns, self.rows);
    
    return [MCMatrix matrixWithValues:tVals rows:self.columns columns:self.rows];
}

- (MCMatrix *)matrixWithValuesStoredInFormat:(MCMatrixValueStorageFormat)valueStorageFormat
{
    if (self.valueStorageFormat == valueStorageFormat) {
        return [MCMatrix matrixWithValues:self.values
                                     rows:self.rows
                                  columns:self.columns
                       valueStorageFormat:valueStorageFormat];
    }
    
    double *tVals = malloc(self.rows * self.columns * sizeof(double));
    
    int i = 0;
    for (int j = 0; j < (valueStorageFormat == MCMatrixValueStorageFormatRowMajor ? self.rows : self.columns); j++) {
        for (int k = 0; k < (valueStorageFormat == MCMatrixValueStorageFormatRowMajor ? self.columns : self.rows); k++) {
            int idx = ((i * (valueStorageFormat == MCMatrixValueStorageFormatRowMajor ? self.rows : self.columns)) % (self.columns * self.rows)) + j;
            tVals[i] = self.values[idx];
            i++;
        }
    }
    
    return [MCMatrix matrixWithValues:tVals
                                 rows:self.rows
                              columns:self.columns
                   valueStorageFormat:valueStorageFormat];
}

- (MCMatrix *)minorByRemovingRow:(NSUInteger)row column:(NSUInteger)column
{
    if (row >= self.rows) {
        @throw [NSException exceptionWithName:NSRangeException reason:@"Specified row is outside the range of possible rows." userInfo:nil];
    } else if (column >= self.columns) {
        @throw [NSException exceptionWithName:NSRangeException reason:@"Specified column is outside the range of possible columns." userInfo:nil];
    }
    
    MCMatrix *minor = [MCMatrix matrixWithRows:self.rows - 1 columns:self.columns - 1 valueStorageFormat:self.valueStorageFormat];
    
    for (int i = 0; i < self.rows; i++) {
        for (int j = 0; j < self.rows; j++) {
            if (i != row && j != column) {
                [minor setEntryAtRow:i > row ? i - 1 : i  column:j > column ? j - 1 : j toValue:[self valueAtRow:i column:j]];
            }
        }
    }
    
    return minor;
}

- (double)determinant
{
    double determinant = 0.0;
    
    // TODO: implement
    @throw [NSException exceptionWithName:@"Unimplemented method" reason:@"Method not yet implemented" userInfo:nil];
    
    return determinant;
}

- (void)swapRowA:(NSUInteger)rowA withRowB:(NSUInteger)rowB
{
    if (rowA >= self.rows) {
        @throw [NSException exceptionWithName:NSRangeException reason:@"rowA is outside the range of possible rows." userInfo:nil];
    } else if (rowB >= self.rows) {
        @throw [NSException exceptionWithName:NSRangeException reason:@"rowB is outside the range of possible rows." userInfo:nil];
    }
    
    // TODO: implement using cblas_dswap
    
    for (int i = 0; i < self.columns; i++) {
        double temp = [self valueAtRow:rowA
                                column:i];
        [self setEntryAtRow:rowA
                     column:i
                    toValue:[self valueAtRow:rowB
                                      column:i]];
        [self setEntryAtRow:rowB
                     column:i
                    toValue:temp];
    }
}

- (void)swapColumnA:(NSUInteger)columnA withColumnB:(NSUInteger)columnB
{
    if (columnA >= self.columns) {
        @throw [NSException exceptionWithName:NSRangeException reason:@"columnA is outside the range of possible columns." userInfo:nil];
    } else if (columnB >= self.columns) {
        @throw [NSException exceptionWithName:NSRangeException reason:@"columnB is outside the range of possible columns." userInfo:nil];
    }
    
    // TODO: implement using cblas_dswap
    
    for (int i = 0; i < self.rows; i++) {
        double temp = [self valueAtRow:i column:columnA];
        [self setEntryAtRow:i column:columnA toValue:[self valueAtRow:i column:columnB]];
        [self setEntryAtRow:i column:columnB toValue:temp];
    }
}

- (double)conditionNumber
{
    double conditionNumber = 0.0;
    
    // TODO: implement
    @throw [NSException exceptionWithName:@"Unimplemented method" reason:@"Method not yet implemented" userInfo:nil];
    
    return conditionNumber;
}

- (MCLUFactorization *)luFactorization
{
    NSUInteger size = self.rows * self.columns;
    double *values = malloc(size * sizeof(double));
    for (int i = 0; i < size; i++) {
        values[i] = self.values[i];
    }
    
    long m = self.rows;
    long n = self.columns;
    
    long lda = m;
    
    long *ipiv = malloc(MIN(m, n) * sizeof(long));
    
    long info = 0;
    
    dgetrf_(&m, &n, values, &lda, ipiv, &info);
    
    // extract L from values array
    MCMatrix *l = [MCMatrix matrixWithRows:m columns:n];
    for (int i = 0; i < self.columns; i++) {
        for (int j = 0; j < self.rows; j++) {
            if (j > i) {
                [l setEntryAtRow:j column:i toValue:values[i * self.columns + j]];
            } else if (j == i) {
                [l setEntryAtRow:j column:i toValue:1.0];
            } else {
                [l setEntryAtRow:j column:i toValue:0.0];
            }
        }
    }
    
    // extract U from values array
    MCMatrix *u = [MCMatrix matrixWithRows:n columns:m];
    for (int i = 0; i < self.columns; i++) {
        for (int j = 0; j < self.rows; j++) {
            if (j <= i) {
                [u setEntryAtRow:j column:i toValue:values[i * self.columns + j]];
            } else {
                [u setEntryAtRow:j column:i toValue:0.0];
            }
        }
    }
    
    // exchange rows as defined in ipiv to build permutation matrix
    MCMatrix *p = [MCMatrix identityMatrixWithSize:MIN(m, n)];
    for (int i = MIN(m, n) - 1; i >= 0 ; i--) {
        [p swapRowA:i withRowB:ipiv[i] - 1];
    }
    
    MCLUFactorization *f = [MCLUFactorization luFactorizationWithL:l
                                                                 u:u];
    f.p = p;
    return f;
}

- (MCSingularValueDecomposition *)singularValueDecomposition
{
    double workSize;
    double *work = &workSize;
    long lwork = -1;
    long numSingularValues = MIN(self.rows, self.columns);
    double *singularValues = malloc(numSingularValues * sizeof(double));
    long *iwork = malloc(8 * numSingularValues);
    long info = 0;
    long m = self.rows;
    long n = self.columns;
    
    MCSingularValueDecomposition *svd = [MCSingularValueDecomposition SingularValueDecompositionWithM:self.rows n:self.columns numberOfSingularValues:numSingularValues];
    
    double *values = malloc(m * n * sizeof(double));
    for (int i = 0; i < m * n; i++) {
        values[i] = self.values[i];
    }
    
    // call first with lwork = -1 to determine optimal size of working array
    dgesdd_("A", &m, &n, values, &m, singularValues, svd.u.values, &m, svd.vT.values, &n, work, &lwork, iwork, &info);
    
    lwork = workSize;
    work = malloc(lwork * sizeof(double));
    
    // now run the actual decomposition
    dgesdd_("A", &m, &n, values, &m, singularValues, svd.u.values, &m, svd.vT.values, &n, work, &lwork, iwork, &info);
    
    free(work);
    free(iwork);
    
    // build the sigma matrix
    int idx = 0;
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < m; j++) {
            if (i == j) {
                svd.s.values[idx] = singularValues[i];
            } else {
                svd.s.values[idx] = 0.0;
            }
            idx++;
        }
    }
    
    return info == 0 ? svd : nil;
}

#pragma mark - Inspection
- (MCEigendecomposition *)eigendecomposition
{
    if (self.rows != self.columns) {
        @throw [NSException exceptionWithName:NSRangeException reason:@"Matrix must be square to derive eigendecomposition." userInfo:nil];
    }
    
    if (self.isSymmetric) {
        <#statements-if-true#>
    } else {
        <#statements-if-false#>
    }
}

- (BOOL)isEqualToMatrix:(MCMatrix *)otherMatrix
{
    if (!([otherMatrix isKindOfClass:[MCMatrix class]] && self.rows == otherMatrix.rows && self.columns == otherMatrix.columns)) {
        return NO;
    } else {
        double *otherValues = otherMatrix.values;
        if (self.valueStorageFormat != otherMatrix.valueStorageFormat) {
            MCMatrix *otherMatrixWithSameStorageFormat = [otherMatrix matrixWithValuesStoredInFormat:self.valueStorageFormat];
            otherValues = otherMatrixWithSameStorageFormat.values;
        }
        for(int i = 0; i < self.rows * self.columns; i++) {
            if (self.values[i] != otherValues[i]) {
                return NO;
            }
        }
        return YES;
    }
}

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    } else if (![object isKindOfClass:[MCMatrix class]]) {
        return NO;
    } else {
        return [self isEqualToMatrix:(MCMatrix *)object];
    }
}

- (NSString *)description
{
    double max = DBL_MIN;
    for (int i = 0; i < self.rows * self.columns; i++) {
        max = MAX(max, self.values[i]);
    }
    int padding = floor(log10(max)) + 5;
    
    NSMutableString *description = [@"\n" mutableCopy];
    
    int i = 0;
    for (int j = 0; j < self.rows; j++) {
        NSMutableString *line = [NSMutableString string];
        for (int k = 0; k < self.columns; k++) {
            int idx;
            
            if (self.valueStorageFormat == MCMatrixValueStorageFormatRowMajor) {
                idx = j * self.rows + k;
            } else {
                idx = ((i++ * self.rows) % (self.columns * self.rows)) + j;
            }
            
            NSString *string = [NSString stringWithFormat:@"%.1f", self.values[idx]];
            [line appendString:[string stringByPaddingToLength:padding withString:@" " startingAtIndex:0]];
        }
        [description appendFormat:@"%@\n", line];
    }
    
    return description;
}

- (double)valueAtRow:(NSUInteger)row column:(NSUInteger)column
{
    if (row >= self.rows) {
        @throw [NSException exceptionWithName:NSRangeException reason:@"Specified row is outside the range of possible rows." userInfo:nil];
    } else if (column >= self.columns) {
        @throw [NSException exceptionWithName:NSRangeException reason:@"Specified column is outside the range of possible columns." userInfo:nil];
    }
    
    if (self.valueStorageFormat == MCMatrixValueStorageFormatRowMajor) {
        return self.values[row * self.columns + column];
    } else {
        return self.values[column * self.rows + row];
    }
}

- (BOOL)isSymmetric
{
    if (self.rows != self.columns) {
        return NO;
    }
    
    for (int i = 0; i < self.rows; i++) {
        for (int j = i + 1; j < self.columns; j++) {
            if ([self valueAtRow:i column:j] != [self valueAtRow:j column:i]) {
                return NO;
            }
        }
    }
    
    return YES;
}

#pragma mark - Mutation

- (void)setEntryAtRow:(NSUInteger)row column:(NSUInteger)column toValue:(double)value
{
    if (row >= self.rows) {
        @throw [NSException exceptionWithName:NSRangeException reason:@"Specified row is outside the range of possible rows." userInfo:nil];
    } else if (column >= self.columns) {
        @throw [NSException exceptionWithName:NSRangeException reason:@"Specified column is outside the range of possible columns." userInfo:nil];
    }
    
    if (self.valueStorageFormat == MCMatrixValueStorageFormatRowMajor) {
        self.values[row * self.columns + column] = value;
    } else {
        self.values[column * self.rows + row] = value;
    }
}

#pragma mark - Class-level matrix operations

+ (MCMatrix *)productOfMatrixA:(MCMatrix *)matrixA andMatrixB:(MCMatrix *)matrixB
{
    if (matrixA.columns != matrixB.rows) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"matrixA does not have an equal amount of columns as rows in matrixB" userInfo:nil];
    }
    
    double *aVals = [matrixA matrixWithValuesStoredInFormat:MCMatrixValueStorageFormatRowMajor].values;
    double *bVals = [matrixB matrixWithValuesStoredInFormat:MCMatrixValueStorageFormatRowMajor].values;
    double *cVals = malloc(matrixA.rows * matrixB.columns * sizeof(double));
    
    vDSP_mmulD(aVals, 1, bVals, 1, cVals, 1, matrixA.rows, matrixB.columns, matrixA.columns);
    
    return [MCMatrix matrixWithValues:cVals rows:matrixA.rows columns:matrixB.columns valueStorageFormat:MCMatrixValueStorageFormatRowMajor];
}

+ (MCMatrix *)sumOfMatrixA:(MCMatrix *)matrixA andMatrixB:(MCMatrix *)matrixB
{
    if (matrixA.rows != matrixB.rows) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Matrices have mismatched amounts of rows." userInfo:nil];
    } else if (matrixA.columns != matrixB.columns) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Matrices have mismatched amounts of columns." userInfo:nil];
    }
    
    MCMatrix *sum = [MCMatrix matrixWithRows:matrixA.rows columns:matrixA.columns];
    for (int i = 0; i < matrixA.rows; i++) {
        for (int j = 0; j < matrixA.columns; j++) {
            [sum setEntryAtRow:i column:j toValue:[matrixA valueAtRow:i column:j] + [matrixB valueAtRow:i column:j]];
        }
    }
    
    return sum;
}

+ (MCMatrix *)differenceOfMatrixA:(MCMatrix *)matrixA andMatrixB:(MCMatrix *)matrixB
{
    if (matrixA.rows != matrixB.rows) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Matrices have mismatched amounts of rows." userInfo:nil];
    } else if (matrixA.columns != matrixB.columns) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Matrices have mismatched amounts of columns." userInfo:nil];
    }
    
    MCMatrix *sum = [MCMatrix matrixWithRows:matrixA.rows columns:matrixA.columns];
    for (int i = 0; i < matrixA.rows; i++) {
        for (int j = 0; j < matrixA.columns; j++) {
            [sum setEntryAtRow:i column:j toValue:[matrixA valueAtRow:i column:j] - [matrixB valueAtRow:i column:j]];
        }
    }
    
    return sum;
}

+ (MCMatrix *)solveLinearSystemWithMatrixA:(MCMatrix *)A
                                 valuesB:(MCMatrix*)B
{
    if (A.rows == A.columns) {
        // solve for square matrix A
        
        long n = A.rows;
        long nrhs = 1;
        long lda = n;
        long ldb = n;
        long info;
        long *ipiv = malloc(n * sizeof(long));
        double *a = malloc(n * n * sizeof(double));
        for (int i = 0; i < n * n; i++) {
            a[i] = A.values[i];
        }
        int nb = B.rows;
        double *b = malloc(nb * sizeof(double));
        for (int i = 0; i < nb; i++) {
            b[i] = B.values[i];
        }
        
        dgesv_(&n, &nrhs, a, &lda, ipiv, b, &ldb, &info);
        
        if (info != 0) {
            return nil;
        } else {
            MCMatrix *solution = [MCMatrix matrixWithRows:n columns:1];
            solution.values = malloc(n * sizeof(double));
            for (int i = 0; i < n; i++) {
                solution.values[i] = b[i];
            }
            return solution;
        }
    } else {
        // solve for general m x n rectangular matrix A
        
        long m = A.rows;
        long n = A.columns;
        long nrhs = 1;
        long lda = A.rows;
        long ldb = A.rows;
        long info;
        long lwork = -1;
        double wkopt;
        double* work;
        double *a = malloc(m * n * sizeof(double));
        for (int i = 0; i < m * n; i++) {
            a[i] = A.values[i];
        }
        int nb = B.rows;
        double *b = malloc(nb * sizeof(double));
        for (int i = 0; i < nb; i++) {
            b[i] = B.values[i];
        }
        // get the optimal workspace
        dgels_("No transpose", &m, &n, &nrhs, a, &lda, b, &ldb, &wkopt, &lwork, &info);
        
        lwork = (int)wkopt;
        work = (double*)malloc(lwork * sizeof(double));
        
        // solve the system of equations
        dgels_("No transpose", &m, &n, &nrhs, a, &lda, b, &ldb, work, &lwork, &info);
        
        /*
         if  m >= n, rows 1 to n of b contain the least
            squares solution vectors; the residual sum of squares for the
            solution in each column is given by the sum of squares of
            elements N+1 to M in that column;
         if  m < n, rows 1 to n of b contain the
            minimum norm solution vectors;
         */
        if (info != 0) {
            return nil;
        } else {
            MCMatrix *solution = [MCMatrix matrixWithRows:n columns:1];
            solution.values = malloc(n * sizeof(double));
            for (int i = 0; i < n; i++) {
                solution.values[i] = b[i];
            }
            return solution;
        }
    }
}

@end
