import std.stdio;
import std.variant;
import dtree;
//import djson;

int main(string[] args) {

    writefln("\nFile %s is running.\n", args[0]);

    DTree tree;

    tree = true; 
    writeln(tree.toString(cTyped)); 
    writeln(tree.Bool == true); 

    tree = "abc"; 
    writeln(tree.toString(cTyped)); 
    writeln(tree.String == "abc"); 

    tree = 11L; 
    writeln(tree.toString(cTyped)); 
    writeln(tree.Long == 11L); 

    tree = 20UL; 
    writeln(tree.toString(cTyped)); 
    writeln(tree.Ulong == 20UL); 

    tree = 1.23; 
    writeln(tree.toString(cTyped)); 
    writeln(tree.Double == 1.23); 

    tree = [1, 2, 3]; 
    writeln(tree.toString(cTyped)); 
    writeln(tree.Array == [DTree(1), DTree(2), DTree(3)]); 

    tree = ["a" : 1, "b" : 2, "c" : 3]; 
    writeln(tree.toString(cTyped)); 
    writeln(tree.Object == ["a" : DTree(1), "b" : DTree(2), "c" : DTree(3)]); 

    DTree tree_null, tree_bool, tree_str, tree_long, tree_double, tree_array, tree_darray, tree_dobject, tree_json;
/*    
    //tree_null = DTree(null);
    tree_null.value = null;
    writeln("tree_null.value = ", tree_null.value);
    writeln("tree_null.value.Type = ", tree_null.value.Type);
    writeln("tree_null.Type = ", tree_null.Type);
    writeln();
     
    //tree_bool = DTree(true);
    tree_bool.value = true;
    writeln("tree_bool.value = ", tree_bool.value);
    writeln("tree_bool.value.Type = ", tree_bool.value.Type);
    writeln("tree_bool.Type = ", tree_bool.Type);
    writeln();
    
    //tree_str = DTree("eilutė");
    tree_str.value = "eilutė";
    writeln("tree_str.value = ", tree_str.value);
    writeln("tree_str.value.Type = ", tree_str.value.Type);
    writeln("tree_str.Type = ", tree_str.Type);
    writeln();
    
    //tree_long = DTree(11234569L);
    tree_long.value = 11234569L;
    writeln("tree_long.value = ", tree_long.value);
    writeln("tree_long.value.Type = ", tree_long.value.Type);
    writeln("tree_long.Type = ", tree_long.Type);
    writeln();
    
    //tree_double = DTree(1.14569);
    tree_double.value = 1.14569;
    writeln("tree_double.value = ", tree_double.value);
    writeln("tree_double.value.Type = ", tree_double.value.Type);
    writeln("tree_double.Type = ", tree_double.Type);
    writeln();

    //tree_darray = DTree([tree_str, tree_long, tree_double]);
    tree_darray.value = [tree_str, tree_long, tree_double];
    writeln("tree_darray.value = ", tree_darray.value);
    writeln("tree_darray.value.Type = ", tree_darray.value.Type);
    writeln("tree_darray.Type = ", tree_darray.Type);
    writeln();
    
    //tree_dobject = DTree(["string" : tree_str, "long" : tree_long, "double" : tree_double, "darray" : tree_darray]);
    tree_dobject.value = ["string" : tree_str, "long" : tree_long, "double" : tree_double, "darray" : tree_darray];
    writeln("tree_dobject.value = ", tree_dobject.value);
    writeln("tree_dobject.value.Type = ", tree_dobject.value.Type);
    writeln("tree_dobject.Type = ", tree_dobject.Type);
    writeln();
 */ 
 /**/
    //writeln("typeid(bool) == DType.Bool => ", typeid(bool) == DType.Bool);
    //writeln("DTree.allowed!bool => ", DTree.allowed!bool);
    //writeln("DTree(5L).convertsTo!(long) => ", DTree(5L).convertsTo!(long));
    //writeln("typeid(\"abc\") => ", typeid("abc"));
    //writeln("typeid(null) => ", typeid(null).toString);
    
    auto dHandler = DHandler(JSONConv);
    
    writeln("dHandler.Tree(15U).Type => ", dHandler.Tree(15U).Type);
    string jsonStr = q"/
        { "numbers" : [9, 1955.3], "language": {"a" : "D"} , "names" : ["Jonas", "Petras"], "mix" : ["abc", 123 ] }
    /";
    writeln("jsonStr => ", jsonStr);

 /*     tree_json.value = json.toDTree(jsonStr);
    writeln("tree_json.value => ", tree_json.value);
    writeln("tree_json.value.Type => ", tree_json.value.Type);
    writeln("tree_json.Type => ", tree_json.Type);
    writeln("tree_json.Type == typeid(DTree[string]) => ", tree_json.Type == typeid(DTree[string]));
    writeln();
 */    
    //dHandler.tree(jsonStr);
    dHandler.String = jsonStr;
    writeln("dHandler.Parse(jsonStr).Output => ", dHandler.Parse(jsonStr).Output);
    writeln("dHandler => ", dHandler);
    auto obj = dHandler.tree.Object;
    writeln("dHandler.tree.toString => \n", dHandler.tree.toString, "\n");
    writeln("dHandler.tree.toString(0) => \n", dHandler.tree.toString(0), "\n");
    writeln("dHandler.tree.toString(cPretty) => \n", dHandler.tree.toString(cPretty), "\n");
    writeln("dHandler.tree.toString(cTyped) => \n", dHandler.tree.toString(cTyped), "\n");
    writeln("dHandler.tree.toString(cPrettyTyped) => \n", dHandler.tree.toString(cPrettyTyped), "\n");
    //writeln("dHandler.tree.value => ", dHandler.tree.value);
    //writeln("dHandler.tree.value.Type => ", dHandler.tree.value.Type);
    //writeln("dHandler.tree.Type => ", dHandler.tree.Type);
    writeln(`dHandler.Format => `, dHandler.Format);
    writeln(`dHandler.Converter.Format => `, dHandler.Converter.Format);
    auto conv = dHandler.Converter;
    writeln();
    writeln(`dHandler.Format("json") => `, dHandler.Format("json"));
    writeln("dHandler.Type => ", dHandler.Type);
    writeln("dHandler.tree => ", dHandler.tree);
    writeln();

    writeln("dHandler.Output => ", dHandler.Output); 
    //writeln("dHandler.set([\"pretty\" : SetTo(true)];");
    //dHandler.set(["pretty" : SetTo(true)]);
    write("dHandler.set(\"pretty\", SetTo(true)) => ");
    //writeln(dHandler.set("pretty", SetTo(true)));
   // writeln("dHandler.toFormat => ", dHandler.toFormat); 
    //writeln("dHandler.set();");
    //dHandler.set();
    //writeln("dHandler.toFormat => ", dHandler.toFormat); 
    //writeln();
    
/**/
/*     //tree_dobject = DTree(["string" : tree_str, "long" : tree_long, "double" : tree_double, "darray" : tree_darray]);
    tree_dobject.value = ["string" : tree_str, "long" : tree_long, "double" : tree_double, "darray" : tree_darray];
    writeln("tree_dobject.value = ", tree_dobject.value);
    writeln("tree_dobject.value.Type = ", tree_dobject.value.Type);
    writeln("tree_dobject.Type = ", tree_dobject.Type);
    writeln();
 */
/*     tree_array = DTree([1, 2, 3]);
    writeln("tree_array.value = ", tree_array.value);
    writeln("tree_array.value.Type = ", tree_array.value.Type);
    writeln();

    tree_darray = DTree([tree_str, tree_long, tree_double]);
    writeln("tree_darray.value = ", tree_darray.value);
    writeln("tree_darray.value.Type = ", tree_darray.value.Type);
    writeln();

    
 *//*    //parse a file or string of json into a usable structure
    
     Store store;

    store = "abc";
    writeln("store = ", store);
    
    store = 5;
    writeln("store = ", store);

    store = [Store(5), Store(17), Store("20")];
    writeln("store = ", store);
    writeln("store.Type = ", store.Type);
    writeln("store[0].Type = ", store[0].Type);
    writeln("store[2].Type = ", store[2].Type);

    store = 5;
    writeln("store = ", store);
 */
 
 
/*     string s = q"/
{
    "language": "D", 
    "rating": 3.14, 
    "code": "42" 
}
/";
    writeln("s1 = ", s);
    
    JSONValue jsval = parseJSON(s);
    writeln("jsval = ", jsval);
    jsval = ["a" : 1, "b" : 2, "c" : 3];
    writeln("jsval = ", jsval);

    auto tree = DTree(s);
    writeln("{ Language: ", tree.value["language"],
        ", Rating: " , tree.value["rating"], " }" );

    s = q"/
{
    "kalba": "D", 
    "reitingas": 3.14, 
    "kodas": "42" 
}
/";
    writeln("s2 = ", s);

    tree(s);
    auto tree2 = tree();
    writeln("tree.value == ", tree.value);
    writeln("tree2.value == ", tree2.value);
    
    DTree tree3;
    
    tree3 = q"/
{
    "kalba": "ReLang", 
    "reitingas": 6.28, 
    "kodas": "82" 
}
/";
    writeln("tree3 = ", tree3);
    writeln("tree3.value[\"kalba\"] == ", tree3.value["kalba"]);
    
    auto tree4 = DTree();
    
    tree4.value = JSONValue(["namas" : "stogas"]); 
    writeln("tree4 = ", tree4);
    writeln("tree4.value[\"namas\"] == ", tree4.value["namas"]);

    DTree tree5 = ["namas" : "stogas"]; 
    writeln("tree5 = ", tree5);
    writeln("tree5.value[\"namas\"] == ", tree5.value["namas"]);

 *//*     writeln("{ Kalba: ", tree2.value["kalba"].str(),
        ", Reitingas: " , tree2.value["reitingas"].floating(), " }"
    );
 */    
/*     // j and j["language"] return JSONValue,
    // j["language"].str returns a string

    //check a Type
    long x;
    if (const(JSONValue)* code = "code" in tree.value){
        if (code.Type() == JSON_TYPE.INTEGER){
            x = code.integer;
        } else {
            x = to!int(code.str);
        }
    }

    // create a json struct
    DTree tree3;

    tree3.value = [ "language": "D" ];
    // rating doesnt exist yet, so use .object to assign
    tree3.value.object["rating"] = JSONValue( 3.14 );
    // create an array to assign to list
    tree3.value.object["list"] = JSONValue( ["a", "b", "c"] );
    // list already exists, so .object optional
    tree3.value["list"].Array ~= JSONValue( "D" );

    s = tree3.value.toString();
    writeln(s);
 */
    writeln("That's all! Bye bye!");

    return 0;

}

