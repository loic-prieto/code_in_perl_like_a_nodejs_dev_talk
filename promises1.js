#!/usr/bin/env nodejs

"use strict";

let rp = require('request-promise');

function do_something_async(){
	return rp('http://www.google.com');
}

console.log("Before calling something async");
do_something_async()
	.then((result)=>{
		console.log("I've received an OK response from google.");
	})
	.catch((error)=>{
		console.log(`I've received an error from google: ${error}`);
	});
	
console.log("After calling something async");
