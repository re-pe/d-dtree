import std.stdio;
import std.variant;
import std.typecons;
import std.traits;
import std.conv;
import std.array;
import core.vararg;

//alias DValue = Algebraic!(bool, long, ulong, double, string, This[], This[string]);

enum DType : string {
    Null   = "Null"   ,  /// Indicates the Type of a $(D DTree).
    Bool   = "Bool"   ,  /// ditto
    String = "String" ,  /// ditto
    Long   = "Long"   ,  /// ditto
    Ulong  = "Ulong"  ,  /// ditto
    Double = "Double" ,  /// ditto
    Object = "Object" ,  /// ditto
    Array  = "Array"     /// ditto
}


alias DTree _;

struct DTree {

    union DValue {
        bool                        Bool;
        string                      String;
        long                        Long;
        ulong                       Ulong;
        double                      Double;
        DTree[string]               Object;
        DTree[]                     Array;
    }
    import std.typecons;
    static auto settings = tuple!("pretty", "typed")(false, false);
    
    private DValue _value;
    private DType  _type = DType.Null;

    this(T...)(T args) {
        
        DTree[] result = new DTree[args.length];
        foreach (key, value; args){
            result[key] = value;
        }
        
        if (result.length > 1) {
            _value = DTree(result)._value;
            _type  = DTree(result)._type;
        } else if (result.length > 0){
            _value = result[0]._value;
            _type  = result[0]._type;
        } 
    }
    
    void opAssign(T)(T arg) if(!isStaticArray!T && !is(T : DTree)) {
        _assign(arg);
    }

    void opAssign(T)(ref T arg) if(isStaticArray!T) {
        _assignRef(arg);
    }

    
    private void _assign(T)(T arg) @safe {
        static if(is(T : typeof(null))) {
            _type = DType.Null;
            //_value = DValue();
        } else static if(is(T : string)) {
            _type = DType.String;
            _value.String = arg;
        } else static if(is(T : bool)) {
            _type = DType.Bool;
            _value.Bool = arg;
        } else static if(is(T : ulong) && isUnsigned!T) {
            _type = DType.Ulong;
            _value.Ulong = arg;
        } else static if(is(T : long)) {
            _type = DType.Long;
            _value.Long = arg;
        } else static if(isFloatingPoint!T) {
            _type = DType.Double;
            _value.Double = arg;
        } else static if(is(T : Value[Key], Key, Value)) {
            static assert(is(Key : string), "AA key must be string");
            _type = DType.Object;
            static if(is(Value : DTree)) {
                _value.Object = arg;
            } else {
                DTree[string] aa;
                foreach(key, value; arg)
                    aa[key] = value;
                _value.Object = aa;
            }
        } else static if(isArray!T) {
            _type = DType.Array;
            static if(is(ElementEncodingType!T : DTree)) {
                _value.Array = arg;
            } else {
                DTree[] new_arg = new DTree[arg.length];
                foreach(i, e; arg)
                    new_arg[i] = e;
                _value.Array = new_arg;
            }
        } else static if(is(T : DTree)) {
            _type = arg._type;
            _value = arg._value;
        } else {
            static assert(false, text(`unable to convert Type "`, T.stringof, `" to json`));
        }
    }

    private void _assignRef(T)(ref T arg) if(isStaticArray!T) {
        _type = DType.Array;
        static if(is(ElementEncodingType!T : DTree)) {
            _value.Array = arg;
        } else {
            DTree[] new_arg = new DTree[arg.length];
            foreach(i, e; arg)
                new_arg[i] = e;
            _value.Array = new_arg;
        }
    }

    
    string toString(bool pretty = false, bool typed = false, int depth = 0) {
        string result, type;
        string space = ""; string nl = ""; string sep = ";"; string tab = "";
        if (pretty){
            space = " ";
            nl = "\n";
            sep = "\n";
            tab = "  ";
        }
        if (_type == DType.Null){
            result = "null";
        } else if (_type == DType.Bool){
            result = to!string(_value.Bool);
        } else if (_type ==DType.String){
            result = _value.String;
            /*if (!typed)*/ result = "\"" ~ result ~ "\"";
        } else if (_type == DType.Long){
            result = to!string(_value.Long);
        } else if (_type == DType.Ulong){
            result = to!string(_value.Ulong);
        } else if (_type == DType.Double){
            result = to!string(_value.Double);
        } else if (_type == DType.Object){
            auto temp = _value.Object;
            auto keys = temp.keys;
            import std.algorithm : sort;
            sort(keys);
            ++depth;
            foreach (i, key; keys) {
                if (i > 0) result ~= sep ~ tab.replicate(depth);
                result ~= key ~ ":" ~ space ~ temp[key].toString(pretty, typed, depth);
            }
            --depth;
            if (!typed) result = "(" ~ nl ~ tab.replicate(depth + 1) ~ result ~ nl ~ tab.replicate(depth) ~ ")" ;
        } else if (_type == DType.Array){
            type = "Array";
            ++depth;
            foreach (key, ref value; _value.Array) {
                if (key > 0) result ~= sep ~ tab.replicate(depth);
                result ~= value.toString(pretty, typed, depth);
            }
            --depth;
            if (!typed) result = "(" ~ nl ~ tab.replicate(depth + 1) ~ result ~ nl ~ tab.replicate(depth) ~ ")";
        }
        if (typed) result = _type ~ "("  ~ nl ~ tab.replicate(depth + 1) ~ result  ~ nl ~ tab.replicate(depth) ~ ")";
        return result;
    }
}


void print(A...)(A a) {
    foreach(t; a) {
        writeln(t);
    }
}

int main(string[] args) {


    writefln("\nFile %s is running.\n", args[0]);
    
    print(null, true, -1, -1L, 1U, 1UL, 1.1, "abc");
    
    auto test = _(
        null, true, -1, -1L, 1U, 1UL, 1.1, "abc", 
        _(
            null, true, -1, -1L, 1U, 1UL, 1.1, "abc", 
            ["a": "def"]
        )
    ); 
    
    writeln("test => ", test);
    writeln("test.toString => ", test.toString);

    //test = _([_(5)]);
    test = DTree(["a" : 5]);

    
    writeln("test => ", test);
    writeln("test.toString => ", test.toString);

    writeln();

    writeln("That's all! Bye bye!");

    return 0;

}

