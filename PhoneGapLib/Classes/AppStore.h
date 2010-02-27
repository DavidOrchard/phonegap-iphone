//
//  AppStore.h
//
//  Created by David Orchard on 20/09/09.
//  Copyright 2009 Ayogo Inc. All rights reserved.
//

#import <StoreKit/StoreKit.h>

#import "PhoneGapCommand.h"


@interface AppStore : PhoneGapCommand <SKProductsRequestDelegate, SKPaymentTransactionObserver>{
	NSString *productListCallback;
    NSString *purchaseCallback;

}

- (void) productList:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void) purchase:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options;
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions;
- (void) completeTransaction: (SKPaymentTransaction *)transaction;
- (void) failedTransaction: (SKPaymentTransaction *)transaction;
//- (void) restoreTransaction: (SKPaymentTransaction *)transaction;
- (NSString*) encode:(const uint8_t*) input length:(NSInteger) length;

@property (nonatomic, retain) NSString *productListCallback;
@property (nonatomic, retain) NSString *purchaseCallback;

@end
