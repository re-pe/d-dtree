## d-dtree
Tool for working with semi-structured data like json or xml in D programming language. Based on std.json

##### 1. Creation of dtree:

```
DTree("a").toString => "a"

DTree(1).toString => 1

DTree(1.1).toString => 1.1

DTree([1, 2, 3]) => (1; 2; 3)

DTree(["a" : 1, "b" : 2]) => (a : 1; b : 2)
```

##### 2. Methods and properties of dtree

```
writeln(tree.Type);
// => "Null" | "Bool" | "String" | "Long" | "Ulong" | "Double" | "Object" | "Array"
```
```
tree.Bool = true; 
writeln(tree.toString(PrettyTyped)); // => Bool(true)
```
```
tree.String = "abc"; 
writeln(tree.toString(PrettyTyped)); // => String("abc")
```
```
tree.Long = 11L; 
writeln(tree.toString(PrettyTyped)); // => Long(11)
```
```
tree.Ulong = 20UL; 
writeln(tree.toString(PrettyTyped)); // => Ulong(20)
```
```
tree.Double = 1.23; 
writeln(tree.toString(PrettyTyped)); // => Double(1.23)
```
```
tree.Array = [1, 2, 3]; 
writeln(tree.toString(PrettyTyped)); // => Array(Long(1); Long(2); Long(3))
```
```
tree.Object = ["a" : 1, "b" : 2, "c" : 3]; 
writeln(tree.toString(PrettyTyped)); // => Object(a: Long(1); b: Long(2); c: Long(3))
```
