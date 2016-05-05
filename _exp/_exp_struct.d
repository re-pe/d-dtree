import std.stdio;
import std.conv;
import std.variant;
import std.typecons;
//import dtree;
//import djson;

enum DOptions {
    none,                       /// standard parsing
    specialFloatLiterals = 0x1, /// encode NaN and Inf float values as strings
}

alias DValue = Algebraic!(bool, string, long, ulong, double, DTree[], DTree[string]);
alias SetTo = Algebraic!(bool, string, long, ulong, double, DOptions);
//alias Settings = SetTo[string];

enum DType : string {
    Null   = "Null"   ,  /// Indicates the type of a $(D DTree).
    Bool   = "Bool"   ,  /// ditto
    String = "String" ,  /// ditto
    Long   = "Ulong"  ,  /// ditto
    Ulong  = "Long"   ,  /// ditto
    Double = "Double" ,  /// ditto
    Object = "Object" ,  /// ditto
    Array  = "Array"     /// ditto
}


static struct DInfo {
    static TypeInfo Null     = typeid(void)          ;
    static TypeInfo Bool     = typeid(bool)          ;
    static TypeInfo String   = typeid(string)        ; 
    static TypeInfo Ulong    = typeid(ulong)         ;
    static TypeInfo Long     = typeid(long)          ;
    static TypeInfo Double   = typeid(double)        ; 
    static TypeInfo Object   = typeid(DTree[string]) ;  
    static TypeInfo Array    = typeid(DTree[])       ;
};

struct DTree {

    private DValue _value;
    private DType  _type;
    
    this(DValue value){
        if (value.type.toString == DInfo.Null.toString){
            _type = DType.Null;
        } else if (value.type == DInfo.Bool){
            _type = DType.Bool;
        } else if (value.type == DInfo.String){
            _type = DType.String;
        } else if (value.type == DInfo.Ulong){
            _type = DType.Ulong;
        } else if (value.type == DInfo.Long){
            _type = DType.Long;
        } else if (value.type == DInfo.Double){
            _type = DType.Double;
        } else if (value.type == DInfo.Object){
            _type = DType.Object;
        } else if (value.type == DInfo.Array){
            _type = DType.Array;
        }
        _value = value;
    }
    
    @property DType type() const pure nothrow @safe {
        return _type;
    }

    @property string typeStr() const pure nothrow @safe {
        return _type;
    }

    @property DValue value() const pure nothrow @safe {
        return _value;
    }
}

/* static struct DTypeId {
    const typeid(null) : 0,
    const typeid(bool) : 1,
    const typeid(string) : 2,
    const typeid(long) : 3,
    const typeid(ulong) : 4,
    const typeid(double) : 5,
    const typeid(string[string]) : 6,
    const typeid(string[]) : 7,
};
 */
 
class DException : Exception {
    this(string msg, int line = 0, int pos = 0) pure nothrow @safe {
        if(line)
            super(text(msg, " (Line ", line, ":", pos, ")"));
        else
            super(msg);
    }

    this(string msg, string file, size_t line) pure nothrow @safe {
        super(msg, file, line);
    }
}    

int main(string[] args) {


    writefln("\nFile %s is running.\n", args[0]);

    writeln("DInfo.Null.toString => "  , DInfo.Null.toString);
    writeln("DInfo.Bool.toString => "  , DInfo.Bool.toString);
    writeln("DInfo.String.toString => ", DInfo.String.toString);
    writeln("DInfo.Ulong.toString => " , DInfo.Ulong.toString);
    writeln("DInfo.Long.toString => "  , DInfo.Long.toString);
    writeln("DInfo.Double.toString => ", DInfo.Double.toString);
    writeln("DInfo.Object.toString => ", DInfo.Object.toString);
    writeln("DInfo.Array.toString => " , DInfo.Array.toString);
    writeln();

    

    DTree test = DTree(DValue());         writeln(test, ": ", test.type, ", test.type == DType.Null => "  , test.type == DType.Null  );
    test = DTree(DValue(true));           writeln(test, ": ", test.type, ", test.type == DType.Bool => "  , test.type == DType.Bool  );
    test = DTree(DValue("abc"));          writeln(test, ": ", test.type, ", test.type == DType.String => ", test.type == DType.String);
    test = DTree(DValue(15UL));           writeln(test, ": ", test.type, ", test.type == DType.Ulong => " , test.type == DType.Ulong );
    test = DTree(DValue(15L));            writeln(test, ": ", test.type, ", test.type == DType.Long => "  , test.type == DType.Long  );
    test = DTree(DValue(15.0));           writeln(test, ": ", test.type, ", test.type == DType.Double => ", test.type == DType.Double);
    test = DTree(DValue(["" : DTree()])); writeln(test, ": ", test.type, ", test.type == DType.Object => ", test.type == DType.Object);
    test = DTree(DValue([DTree()]));      writeln(test, ": ", test.type, ", test.type == DType.Array => " , test.type == DType.Array );
    writeln();

    
    alias Settings = SetTo[string];
    Settings settings = ["maxDepth" : SetTo(-1L), "pretty" : SetTo(false), "dOptions" : SetTo(DOptions.none)];
    void set(string key, SetTo value){
        import std.exception : enforceEx, enforce;
        enforce!DException(key in settings, "Key " ~ key ~ " doesn't exist!" );
        if (value.type.toString == "bool"){ 
            settings[key] = value.get!bool;
        }
    }
    set("pretty", SetTo(true));
    writeln("settings => ", settings);
    
    writeln("That's all! Bye bye!");

    return 0;

}

