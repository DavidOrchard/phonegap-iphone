//
//  AppStore.m
//
//  Created by David Orchard on 20/09/09.
//  Copyright 2009 Ayogo Inc. All rights reserved.
//

#import "AppStore.h"


@implementation AppStore
@synthesize purchaseCallback, productListCallback;

- (id)init
{
    if (self = [super init])
    {
		purchaseCallback= nil;
		productListCallback = nil;
    }
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
 
    return self;
}


- (void) productList:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options 

{

    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];


    NSUInteger argc = [arguments count];
	
	if (argc > 0) {
		productListCallback = [[arguments objectAtIndex:0] retain];
	} else {
		NSLog(@"AppStore:productList: Missing 1st parameter.");
		return;
	}
    
    NSArray *productIds = [options allValues];
    if( [productIds count] == 0 ) {
        NSLog(@"AppStore:productList: no arguments");
        return;
    }
    
    NSLog(@"AppStore:productList: %d arguments", [productIds count]);
  
    
   
   SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers: [[NSSet alloc] initWithArray:productIds]];
   
   NSLog(@"RequestingProductData");
 
   request.delegate = self;

   [request start];

}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response

{
    NSLog(@"Got ProductData");
    NSArray *myProduct = response.products;
    NSMutableString* jsonArray =  [[[NSMutableString alloc] initWithString:@"["] autorelease];
	NSUInteger count = [myProduct count];
    NSLog(@"got %d items back", count);
    for(int i = 0; i < count ; i++ ) {
             SKProduct *product = [myProduct objectAtIndex:i];
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
            [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            [numberFormatter setLocale:product.priceLocale];
            NSString *formattedString = [numberFormatter stringFromNumber:product.price];
            NSString *productJSON = [[NSString alloc] initWithFormat:@"{ localizedDescription: '%@', localizedTitle:'%@', price:'%@', productIdentifier:'%@'}",
                [product localizedDescription],
                [product localizedTitle],
                formattedString,
                [product productIdentifier]
           ];
           NSLog(@"Adding item %S", productJSON);
           [jsonArray appendString:productJSON];
            if (i+1 != count) {
                [jsonArray appendString:@","];
            }
        }
    [jsonArray appendString:@"]"];
         
    NSString* jsString = [[NSString alloc] initWithFormat:@"%@(%@);", productListCallback, jsonArray];
    NSLog(@"%@", jsString);
	
    [webView stringByEvaluatingJavaScriptFromString:jsString];
		
//	[jsonArray release];

    [request autorelease];

}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions

{

    NSLog(@"In UpdatedTransactions");

    for (SKPaymentTransaction *transaction in transactions)

    {

        switch (transaction.transactionState)

        {

            case SKPaymentTransactionStatePurchased:

                [self completeTransaction:transaction];

                break;

            case SKPaymentTransactionStateFailed:

                [self failedTransaction:transaction];

                break;
// Note: consumable items are never restored by StoreKit
            case SKPaymentTransactionStateRestored:

                [self completeTransaction:transaction];

            default:

                break;

        }

    }

}

- (void) completeTransaction: (SKPaymentTransaction *)transaction

{

    NSLog(@"Completing transaction");
// Your application should implement these two methods.

//    [self recordTransaction: transaction];
    NSString *jsonObjectString = [self encode:(uint8_t *)transaction.transactionReceipt.bytes length:transaction.transactionReceipt.length];     
    NSString *productJSON = [[NSString alloc] initWithFormat:@"{ quantity:'%d', productIdentifier:'%@', transactionReceipt:'%@'}",
                    transaction.payment.quantity, transaction.payment.productIdentifier, jsonObjectString];
            
    NSString* jsString = [[NSString alloc] initWithFormat:@"%@(%@);", purchaseCallback, productJSON];
    NSLog(@"%@", jsString);
	
     [webView stringByEvaluatingJavaScriptFromString:jsString];
	
    // Remove the transaction from the payment queue.

    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];

}

// Note: consumable items are never restored by StoreKit

/*- (void) restoreTransaction: (SKPaymentTransaction *)transaction

{

    [self recordTransaction: transaction];

    [self provideContent: transaction.originalTransaction.payment.productIdentifier];

    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];

}*/

- (void) failedTransaction: (SKPaymentTransaction *)transaction

{

    if (transaction.error.code != SKErrorPaymentCancelled)

    {

        // Optionally, display an error here.

    }
    NSString* jsString = [[NSString alloc] initWithFormat:@"%@({});", purchaseCallback];
    NSLog(@"%@", jsString);
	
     [webView stringByEvaluatingJavaScriptFromString:jsString];


    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];

}

- (void) purchase:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options  {
  NSUInteger argc = [arguments count];
	
	if (argc > 0) {
		purchaseCallback = [[arguments objectAtIndex:0] retain];
	} else {
		NSLog(@"AppStore:purchase: missing callback.");
		return;
	}
    
    if( argc == 1 ) {
        NSLog(@"AppStore:purchase: missing item id");
        return;
    }
    
    NSLog(@"AppStore:purchase: %d arguments", argc);

    SKPayment *payment = [SKPayment paymentWithProductIdentifier:[arguments objectAtIndex:1]];
//    if( argc == 3 ) {
        // then there's an amount as well
//        NSString *amt = (NSString *) [arguments objectAtIndex:2];
//        [ payment setQuantity:[amt intValue]];
//        payment.quantity = [amt intValue];  but this DOESN'T WORK
 //   }

    [[SKPaymentQueue defaultQueue] addPayment:payment];
    NSLog(@"Added payment to the payment Queue");
}

- (NSString*) encode:(const uint8_t*) input length:(NSInteger) length {
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;

    for (NSInteger i = 0; i < length; i += 3) {
        NSInteger value = 0;
        for (NSInteger j = i; j < (i + 3); j++) {
            value <<= 8;

            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }

        NSInteger index = (i / 3) * 4;
        output[index + 0] =                    table[(value >> 18) & 0x3F];
        output[index + 1] =                    table[(value >> 12) & 0x3F];
        output[index + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[index + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }

    return [[[NSString alloc] initWithData:data
                                  encoding:NSASCIIStringEncoding] autorelease];
}

@end
