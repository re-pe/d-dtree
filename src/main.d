import std.stdio;
import std.variant;
import dtree;
//import djson;

int main(string[] args) {

    writefln("\nFile %s is running.\n", args[0]);

/*     void test() {
        Variant[string] varArr;
        varArr["vienas"] = "v";
        varArr["du"] = 2;
        varArr["trys"] = [3];
        foreach (key, value; varArr){
            if (value.type == typeid(string)){
                writeln("varArr[\"", key, "\"] => \"", value, "\"");
            } else {
                writeln("varArr[\"", key, "\"] => ", value);
            }
        }
    }
    
    //test();
    
    writeln("long.max => ", long.max);
 */    
    DTree tree_null, tree_bool, tree_str, tree_long, tree_double, tree_array, tree_darray, tree_dobject, tree_json;
/*    
    //tree_null = DTree(null);
    tree_null.value = null;
    writeln("tree_null.value = ", tree_null.value);
    writeln("tree_null.value.type = ", tree_null.value.type);
    writeln("tree_null.type = ", tree_null.type);
    writeln();
     
    //tree_bool = DTree(true);
    tree_bool.value = true;
    writeln("tree_bool.value = ", tree_bool.value);
    writeln("tree_bool.value.type = ", tree_bool.value.type);
    writeln("tree_bool.type = ", tree_bool.type);
    writeln();
    
    //tree_str = DTree("eilutė");
    tree_str.value = "eilutė";
    writeln("tree_str.value = ", tree_str.value);
    writeln("tree_str.value.type = ", tree_str.value.type);
    writeln("tree_str.type = ", tree_str.type);
    writeln();
    
    //tree_long = DTree(11234569L);
    tree_long.value = 11234569L;
    writeln("tree_long.value = ", tree_long.value);
    writeln("tree_long.value.type = ", tree_long.value.type);
    writeln("tree_long.type = ", tree_long.type);
    writeln();
    
    //tree_double = DTree(1.14569);
    tree_double.value = 1.14569;
    writeln("tree_double.value = ", tree_double.value);
    writeln("tree_double.value.type = ", tree_double.value.type);
    writeln("tree_double.type = ", tree_double.type);
    writeln();

    //tree_darray = DTree([tree_str, tree_long, tree_double]);
    tree_darray.value = [tree_str, tree_long, tree_double];
    writeln("tree_darray.value = ", tree_darray.value);
    writeln("tree_darray.value.type = ", tree_darray.value.type);
    writeln("tree_darray.type = ", tree_darray.type);
    writeln();
    
    //tree_dobject = DTree(["string" : tree_str, "long" : tree_long, "double" : tree_double, "darray" : tree_darray]);
    tree_dobject.value = ["string" : tree_str, "long" : tree_long, "double" : tree_double, "darray" : tree_darray];
    writeln("tree_dobject.value = ", tree_dobject.value);
    writeln("tree_dobject.value.type = ", tree_dobject.value.type);
    writeln("tree_dobject.type = ", tree_dobject.type);
    writeln();
 */ 
 /**/
    //writeln("typeid(bool) == DType.Bool => ", typeid(bool) == DType.Bool);
    //writeln("DTree.allowed!bool => ", DTree.allowed!bool);
    //writeln("DTree(5L).convertsTo!(long) => ", DTree(5L).convertsTo!(long));
    //writeln("typeid(\"abc\") => ", typeid("abc"));
    //writeln("typeid(null) => ", typeid(null).toString);
    
    string jsonStr = q"/
        { "numbers" : [9, 1955.3], "language": {"a" : "D"} , "names" : ["Jonas", "Petras"], "mix" : ["abc", 123 ] }
    /";
    writeln("jsonStr => ", jsonStr);
    auto dHandler = DHandler(JSONConv);

 /*     tree_json.value = json.toDTree(jsonStr);
    writeln("tree_json.value => ", tree_json.value);
    writeln("tree_json.value.type => ", tree_json.value.type);
    writeln("tree_json.type => ", tree_json.type);
    writeln("tree_json.type == typeid(DTree[string]) => ", tree_json.type == typeid(DTree[string]));
    writeln();
 */    
    //dHandler.tree(jsonStr);
    dHandler.String = jsonStr;
    writeln("dHandler.toTree(jsonStr).toFormat => ", dHandler.toTree(jsonStr).toFormat);
    writeln("dHandler => ", dHandler);
    auto obj = dHandler.tree.Object;
    writeln("dHandler.tree.toString(false, false) => \n", dHandler.tree.toString(false, false), "\n");
    writeln("dHandler.tree.toString(true, false) => \n", dHandler.tree.toString(true, false), "\n");
    writeln("dHandler.tree.toString(false, true) => \n", dHandler.tree.toString(false, true), "\n");
    writeln("dHandler.tree.toString(true, true) => \n", dHandler.tree.toString(true, true), "\n");
    //writeln("dHandler.tree.value => ", dHandler.tree.value);
    //writeln("dHandler.tree.value.type => ", dHandler.tree.value.type);
    //writeln("dHandler.tree.type => ", dHandler.tree.type);
    writeln(`dHandler.defaultFormat => `, dHandler.defaultFormat);
    writeln(`dHandler.Converter().format => `, dHandler.Converter().format);
    auto conv = dHandler.Converter();
    writeln();
    writeln(`dHandler.defaultFormat("json") => `, dHandler.defaultFormat("json"));
    writeln("dHandler.type => ", dHandler.type);
    writeln("dHandler.tree => ", dHandler.tree);
    writeln();

    writeln("dHandler.toFormat => ", dHandler.toFormat); 
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
    writeln("tree_dobject.value.type = ", tree_dobject.value.type);
    writeln("tree_dobject.type = ", tree_dobject.type);
    writeln();
 */
/*     tree_array = DTree([1, 2, 3]);
    writeln("tree_array.value = ", tree_array.value);
    writeln("tree_array.value.type = ", tree_array.value.type);
    writeln();

    tree_darray = DTree([tree_str, tree_long, tree_double]);
    writeln("tree_darray.value = ", tree_darray.value);
    writeln("tree_darray.value.type = ", tree_darray.value.type);
    writeln();

    
 *//*    //parse a file or string of json into a usable structure
    
     Store store;

    store = "abc";
    writeln("store = ", store);
    
    store = 5;
    writeln("store = ", store);

    store = [Store(5), Store(17), Store("20")];
    writeln("store = ", store);
    writeln("store.type = ", store.type);
    writeln("store[0].type = ", store[0].type);
    writeln("store[2].type = ", store[2].type);

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

    //check a type
    long x;
    if (const(JSONValue)* code = "code" in tree.value){
        if (code.type() == JSON_TYPE.INTEGER){
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

