// appstore.js
// Created by David Orchard
// Copyright 2009, Ayogo Games, Inc.
function AppStore(){}

// Prototype for productList available in app purchases from app store through PhoneGap.
// options is the list of product ids that are available in the appstore
// the callback is executed with an array of { localizedDescription: '%@', localizedTitle:'%@', price:'%@', productIdentifier:'%@'}"
AppStore.prototype.productList = function(productListCallback, options){
		__appstore_productListCallback_global_variable = productListCallback;
   PhoneGap.exec("AppStore.productList", "__appstore_productListCallback_global_variable",options);

}

// Prototype for making an inapp purchase through PhoneGap.
// item is the product id being purchased and amount is.... the amount of product id being purchased.
// callback executed with: { quantity:'%d', productIdentifier:'%@', transactionReceipt:'%@'}
AppStore.prototype.purchase = function( purchaseCallback, item, amount) {
		__appstore_purchaseCallback_global_variable = purchaseCallback;
    PhoneGap.exec("AppStore.purchase", "__appstore_purchaseCallback_global_variable", item, typeOf(amount) != "undefined" ? amount : 1);
}

