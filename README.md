## d-dtree
Tool for working with semi-structured data like json or xml in D programming language. Based on std.json

##### 1. Creation of dtree:

```D
DTree("a").toString => "a"

DTree(1).toString => 1

DTree(1.1).toString => 1.1

DTree([1, 2, 3]) => (1; 2; 3)

DTree(["a" : 1, "b" : 2]) => (a : 1; b : 2)
```

##### 2. Methods and properties of dtree

```D
writeln(tree.Type);
// => "Null" | "Bool" | "String" | "Long" | "Ulong" | "Double" | "Object" | "Array"

tree = true; 
writeln(tree.toString(cTyped)); // Bool(True)
writeln(tree.Bool == true);     // true

tree = "abc"; 
writeln(tree.toString(cTyped)); // String("abc")
writeln(tree.String == "abc");  // true

tree = 11L; 
writeln(tree.toString(cTyped)); // Long(11)
writeln(tree.Long == 11L);      // true

tree = 20UL; 
writeln(tree.toString(cTyped)); // Ulong(20)
writeln(tree.Ulong == 20UL);    // true

tree = 1.23; 
writeln(tree.toString(cTyped)); // Double(1.23)
writeln(tree.Double == 1.23);   // true

tree = [1, 2, 3]; 
writeln(tree.toString(cTyped)); // Array(Long(1); Long(2); Long(3))
writeln(tree.Array == [DTree(1), DTree(2), DTree(3)]); // true

tree = ["a" : 1, "b" : 2, "c" : 3]; 
writeln(tree.toString(cTyped)); // Object(a: Long(1); b: Long(2); c: Long(3) )
writeln(tree.Object == ["a" : DTree(1), "b" : DTree(2), "c" : DTree(3)]); // true
```
