// appstore.js
// Created by David Orchard
// Copyright 2009, Ayogo Games, Inc.
function AppStore()
{
    this.productListCallback = function(){alert('productListCallback!');};
    this.purchaseCallback = function(){alert('purchaseCallback!');};
}

// private internal callback method required by Obj-C code
AppStore.prototype._productListCallback = function()
{
    if(this.productListCallback != null)
        this.productListCallback.apply(null,arguments);
}

// private internal callback method required by Obj-C code
AppStore.prototype._purchaseCallback = function()
{
    if(this.purchaseCallback != null)
        this.purchaseCallback.apply(null,arguments);
}



// Prototype for productList available in app purchases from app store through PhoneGap.
// options is the list of product ids that are available in the appstore
// the callback is executed with an array of { localizedDescription: '%@', localizedTitle:'%@', price:'%@', productIdentifier:'%@'}"
AppStore.prototype.productList = function(productListCallback, options){
    this.productListCallback = productListCallback;
   PhoneGap.exec( "__appstore_productListCallback_global_variable",options);

}

// Prototype for making an inapp purchase through PhoneGap.
// item is the product id being purchased and amount is.... the amount of product id being purchased.
// callback executed with: { quantity:'%d', productIdentifier:'%@', transactionReceipt:'%@'}
AppStore.prototype.purchase = function( purchaseCallback, item, amount) {
	this.purchaseCallback = purchaseCallback;
    PhoneGap.exec("AppStore.purchase", item, amount !== undefined ? amount : 1);
}

PhoneGap.addConstructor(
function() 
{
if (typeof navigator.plugins == "undefined")
navigator.plugins = {};
     if (typeof navigator.plugins.appStore == "undefined") 
navigator.plugins.appStore = new AppStore();
}
);

