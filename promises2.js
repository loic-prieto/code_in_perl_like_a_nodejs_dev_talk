#!/usr/bin/env nodejs

"use strict";

function do_something_async(){
	let promise = new Promise((resolve,reject)=>{
		setTimeout(()=>{
			if(Math.random()>0.50) {
				resolve("All worked great");
			} else {
				reject("YOLO");
			}
		},5000);
	});
	
	return promise;
}

console.log("Before calling something async");
do_something_async()
	.then((result)=>{
		console.log(result);
	})
	.catch((error)=>{
		console.log(error);
	});
	
console.log("After calling something async");
