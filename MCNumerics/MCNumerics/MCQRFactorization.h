//
//  MCQRFactorization.h
//  MCNumerics
//
//  Created by andrew mcknight on 1/14/14.
//  Copyright (c) 2014 andrew mcknight. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MCMatrix;

/**
 @brief Container class to hold the results of a QR factorization in MCMatrix objects.
 @description The QR factorization decomposes a matrix A into the product QR, where Q is an orthogonal matrix and R is an upper triangular matrix.
 */
@interface MCQRFactorization : NSObject <NSCopying>

/**
 @property q
 @brief An MCMatrix holding the orthogonal matrix Q of the QR factorization.
 */
@property (nonatomic, strong) MCMatrix *q;

/**
 @property r
 @brief An MCMatrix holding the upper triangular matrix R of the QR factorization.
 */
@property (nonatomic, strong) MCMatrix *r;

#pragma mark - Init

/**
 @brief Create a new instance of MCQRFactorization by computing the factorization of the provided matrix.
 @param matrix The MCMatrix object to compute the factorization from.
 @return A new MCQRFactorization object containing the results of factorizing the provided matrix.
 */
- (instancetype)initWithMatrix:(MCMatrix *)matrix;

/**
 @brief Convenience class method to create a new instance of MCQRFactorization by computing the factorization of the provided matrix.
 @param matrix The MCMatrix object to compute the factorization from.
 @return A new MCQRFactorization object containing the results of factorizing the provided matrix.
 */
+ (instancetype)qrFactorizationOfMatrix:(MCMatrix *)matrix;

#pragma mark - Operations

/**
 @brief When factorizing a general m x n matrix (m ≥ n), the resulting Q matrix is m x m and R is m x n upper triangular. The thin factorization takes the first n rows of R and n columns of Q.
 @code 
                  [ R1                 [ R1
 A = Q * R = Q *    0  ] = [Q1, Q2] *    0  ]
 
 A = Q1 * R1 is the thin factorization
 */
- (MCQRFactorization *)thinFactorization;

@end
