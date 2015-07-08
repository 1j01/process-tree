
# process-tree

> like [ps-tree](https://www.npmjs.com/package/ps-tree), but cross-platform, and providing sub-children

Get a tree of processes starting from the children of a given PID.

```js
require("process-tree")(pid, function(err, children){
	if(err){
		console.error(err);
	}else{
		console.log(JSON.stringify(children, null, 4));
		console.assert(children[0].ppid === pid);
		console.log(children[0].children[0].pid);
		console.log(children[0].name); // "Name" from wmic, "comm" from ps
	}
});
```
