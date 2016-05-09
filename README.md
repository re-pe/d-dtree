## d-dtree
Tool for working with semi-structured data like json or xml in D programming language. Based on std.json
### 1. Creating of dtree:
##### Creating of dtree with constructor:
```D
auto treeBool = DTree(true);
auto treeString = DTree("a");
auto treeLong = DTree(1);
auto treeUlong = DTree(1U);
auto treeDouble = DTree(1.1);
auto treeArray = DTree([1, 2, 3]);
auto treeObject = DTree(["a" : 1, "b" : 2]);
```
##### Creating of dtree by cloning and assigning existing tree structure:
```D
auto newTree = tree("first tree");
assert(&tree != &newTree);
newTree("second tree");
assert(tree != newTree);
```
### 2. Getting values and types of values
##### Getting typed values with special properties:
```D
assert(tree(true).Bool == true); 
assert(tree("abc").String == "abc"); 
assert(tree(11L).Long == 11L); 
assert(tree(20UL).Ulong == 20UL); 
assert(tree(1.23).Double == 1.23); 
assert(tree([1, 2, 3]).Array == [DTree(1), DTree(2), DTree(3)]); 
assert(tree(["a" : 1, "b" : 2, "c" : 3]).Object == ["a" : DTree(1), "b" : DTree(2), "c" : DTree(3)]); 
```
##### Getting type of value:
```D
tree.Type; // => "Null" | "Bool" | "String" | "Long" | "Ulong" | "Double" | "Object" | "Array"
```
### 3. Setting values
##### Setting new value by assigning:
```D
newTree = true;
newTree = "abc";
newTree = 100;
newTree = 15U;
newTree = 3.45159;
newTree = [DTree(true), DTree(7), DTree("piece of text")];
newTree = ["a" : DTree(7), "b" : DTree("this is string")];
newTree =·tree;
```
##### Setting new value by calling:
```D
auto anotherTree = tree;
anotherTree(false);
anotherTree("def");
anotherTree(-19);
anotherTree(7U);
anotherTree(2.5);
anotherTree([100, 200, 300]);
anotherTree(["a" : 15, "b" : 26]);
```
### 4. Indexes
##### Gettings values by index
```D
tree = [15, 16, 17];
assert(tree[0] == DTree(15));
assert(tree[1] == DTree(16));
assert(tree[2] == DTree(17));
tree = ["a" : 15, "b" : 16, "c" : 17];
assert(tree["a"] == DTree(15));
assert(tree["b"] == DTree(16));
assert(tree["c"] == DTree(17));
```

### 2. Methods and properties of dtree

```
import dtree;

DTree tree;

assert(tree(true).toString == `true`); 
assert(tree("abc").toString == `"abc"`); 
assert(tree(11L).toString == `11`); 
assert(tree(20UL).toString == `20`); 
assert(tree(1.23).toString == `1.23`); 
assert(tree([1, 2, 3]).toString == `(1;2;3)`); 
assert(tree(["a" : 1, "b" : 2, "c" : 3]).toString == `(a:1;b:2;c:3)`); 


DTree.settings.typed = true;

assert(tree(true).toString == `Bool(true)`); 
assert(tree("abc").toString == `String("abc")`); 
assert(tree(11L).toString == `Long(11)`); 
assert(tree(20UL).toString == `Ulong(20)`); 
assert(tree(1.23).toString == `Double(1.23)`); 
assert(tree([1, 2, 3]).toString == `Array(Long(1);Long(2);Long(3))`); 
assert(tree(["a" : 1, "b" : 2, "c" : 3]).toString == `Object(a:Long(1);b:Long(2);c:Long(3))`); 
```
