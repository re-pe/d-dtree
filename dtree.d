// Written in the D programming language.

/**
JavaScript Object Notation

Synopsis:
----
    //parse a file or string of json into a usable structure
    string s = "{ \"language\": \"D\", \"rating\": 3.14, \"code\": \"42\" }";
    DTree j = parseJSON(s);
    writeln("Language: ", j["language"].String(),
            " Rating: ", j["rating"].Double()
    );

    // j and j["language"] return DTree,
    // j["language"].String returns a string

    //check a type
    long x;
    if (const(DTree)* code = "code" in j) {
        if (code.type() == DType.Long)
            x = code.Long;
        else
            x = to!int(code.String);
    }

    // create a json struct
    DTree jj = [ "language": "D" ];
    // rating doesnt exist yet, so use .Object to assign
    jj.Object["rating"] = DTree(3.14);
    // create an Array to assign to list
    jj.Object["list"] = DTree( ["a", "b", "c"] );
    // list already exists, so .Object optional
    jj["list"].Array ~= DTree("D");

    s = j.toString();
    writeln(s);
----

Copyright: Copyright Jeremie Pelletier 2008 - 2009.
License:   $(WEB www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors:   Jeremie Pelletier, David Herberth
References: $(LINK http://json.org/)
Source:    $(PHOBOSSRC std/_json.d)
*/
/*
         Copyright Jeremie Pelletier 2008 - 2009.
Distributed under the Boost Software License, Version 1.0.
   (See accompanying file LICENSE_1_0.txt or copy at
         http://www.boost.org/LICENSE_1_0.txt)
*/
module dtree;

import std.conv;
import std.range.primitives;
import std.array;
import std.traits;
import std.variant;
import std.exception : enforceEx, enforce;
import std.stdio;

/**
String literals used to represent special float values within JSON strings.
*/
enum DFloatLiteral : string {
    nan         = "NaN",       /// string representation of Double-point NaN
    inf         = "Infinite",  /// string representation of Double-point Infinity
    negativeInf = "-Infinite", /// string representation of Double-point negative Infinity
}

/**
Flags that control how json is encoded and parsed.
*/
enum DOptions {
    none,                       /// standard parsing
    specialFloatLiterals = 0x1, /// encode NaN and Inf float values as strings
}

alias SetTo  = Algebraic!(bool, int, uint, long, ulong, string, DOptions);

/**
JSON type enumeration
*/

enum DType : string {
    Null   = "Null"   ,  /// Indicates the type of a $(D DTree).
    Bool   = "Bool"   ,  /// ditto
    String = "String" ,  /// ditto
    Long   = "Long"   ,  /// ditto
    Ulong  = "Ulong"  ,  /// ditto
    Double = "Double" ,  /// ditto
    Object = "Object" ,  /// ditto
    Array  = "Array"     /// ditto
}
/**
JSON value node
*/
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
    private DValue _value;
    private DType  _type = DType.Null;

    /**
      Returns the DType of the value _valued in this structure.
    */
    @property DType type() const pure nothrow @safe @nogc {
        return _type;
    }
    ///
    unittest {
          string s = `{ "language": "D" }`;
          DTree j = parseJSON(s);
          assert(j.type == DType.Object);
          assert(j["language"].type == DType.String);
    }

    /// Value getter/setter for $(D DType.String).
    /// Throws: $(D DException) for read access if $(D type) is not
    /// $(D DType.String).
    @property bool Bool() const pure @trusted {
        enforce!DException(type == DType.Bool, "DTree value is not a boolean");
        return _value.Bool;
    }
    /// ditto
    @property bool Bool(bool v) pure nothrow @nogc @safe {
        assign(v);
        return v;
    }
    ///
    unittest {
        DTree j = [ "pretty": true ];

        // get value
        assert(j["pretty"].Bool == true);

        // change existing key to new string
        j["pretty"].Bool = false;
        assert(j["pretty"].Bool == false);
    }

    /// Value getter/setter for $(D DType.String).
    /// Throws: $(D DException) for read access if $(D type) is not
    /// $(D DType.String).
    @property string String() const pure /*@safe*/ @trusted {
        enforce!DException(type == DType.String, "DTree value is not a string");
        return _value.String;
    }
    /// ditto
    @property string String(string v) pure nothrow @nogc @safe {
        assign(v);
        return v;
    }
    ///
    unittest {
        DTree j = [ "language": "D" ];

        // get value
        assert(j["language"].String == "D");

        // change existing key to new string
        j["language"].String = "Perl";
        assert(j["language"].String == "Perl");
    }

    /// Value getter/setter for $(D DType.Long).
    /// Throws: $(D DException) for read access if $(D type) is not
    /// $(D DType.Long).
    @property inout(long) Long() inout pure @safe /*@trusted*/ {
        enforce!DException(type == DType.Long, "DTree value is not an long");
        return _value.Long;
    }
    /// ditto
    @property long Long(long v) pure nothrow @safe @nogc {
        assign(v);
        return _value.Long;
    }

    /// Value getter/setter for $(D DType.Ulong).
    /// Throws: $(D DException) for read access if $(D type) is not
    /// $(D DType.Ulong).
    @property inout(ulong) Ulong() inout pure @safe {
        enforce!DException(type == DType.Ulong, "DTree value is not an unsigned long");
        return _value.Ulong;
    }
    /// ditto
    @property ulong Ulong(ulong v) pure nothrow @safe @nogc {
        assign(v);
        return _value.Ulong;
    }

    /// Value getter/setter for $(D DType.Double).
    /// Throws: $(D DException) for read access if $(D type) is not
    /// $(D DType.Double).
    @property inout(double) Double() inout pure @safe {
        enforce!DException(type == DType.Double, "DTree value is not a Double type");
        return _value.Double;
    }
    /// ditto
    @property double Double(double v) pure nothrow @safe @nogc {
        assign(v);
        return _value.Double;
    }

    /// Value getter/setter for $(D DType.Object).
    /// Throws: $(D DException) for read access if $(D type) is not
    /// $(D DType.Object).
    /* Note: this is @system because of the following pattern:
       ---
       auto a = &(json.Object());
       json.Ulong = 0;        // overwrite AA pointer
       (*a)["hello"] = "world";  // segmentation fault
       ---
     */
    @property ref inout(DTree[string]) Object() inout pure /*@system*/ @trusted {
        enforce!DException(type == DType.Object, "DTree value is not an Object");
        return _value.Object;
    }
    /// ditto
    @property DTree[string] Object(DTree[string] v) pure nothrow @nogc @safe {
        assign(v);
        return v;
    }

    /// Value getter for $(D DType.Object).
    /// Unlike $(D Object), this retrieves the Object by value and can be used in @safe code.
    ///
    /// A caveat is that, if the returned value is null, modifications will not be visible:
    /// ---
    /// DTree json;
    /// json.Object = null;
    /// json.objectNoRef["hello"] = DTree("world");
    /// assert("hello" !in json.Object);
    /// ---
    ///
    /// Throws: $(D DException) for read access if $(D type) is not
    /// $(D DType.Object).
    @property inout(DTree[string]) objectNoRef() inout pure @trusted {
        enforce!DException(type == DType.Object, "DTree value is not an Object");
        return _value.Object;
    }

    /// Value getter/setter for $(D DType.Array).
    /// Throws: $(D DException) for read access if $(D type) is not
    /// $(D DType.Array).
    /* Note: this is @system because of the following pattern:
       ---
       auto a = &(json.Array());
       json.Ulong = 0;  // overwrite Array pointer
       (*a)[0] = "world";  // segmentation fault
       ---
     */
    @property ref inout(DTree[]) Array() inout pure @system {
        enforce!DException(type == DType.Array, "DTree value is not an Array");
        return _value.Array;
    }
    /// ditto
    @property DTree[] Array(DTree[] v) pure nothrow @nogc @safe {
        assign(v);
        return v;
    }

    /// Value getter for $(D DType.Array).
    /// Unlike $(D Array), this retrieves the Array by value and can be used in @safe code.
    ///
    /// A caveat is that, if you append to the returned Array, the new values aren't visible in the
    /// DTree:
    /// ---
    /// DTree json;
    /// json.Array = [DTree("hello")];
    /// json.arrayNoRef ~= DTree("world");
    /// assert(json.Array.length == 1);
    /// ---
    ///
    /// Throws: $(D DException) for read access if $(D type) is not
    /// $(D DType.Array).
    @property inout(DTree[]) arrayNoRef() inout pure @trusted {
        enforce!DException(type == DType.Array, "DTree value is not an Array");
        return _value.Array;
    }

    /// Test whether the type is $(D DType.Null)
    @property bool isNull() const pure nothrow @safe @nogc {
        return type == DType.Null;
    }

    private void assign(T)(T arg) @safe {
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
                    aa[key] = DTree(value);
                _value.Object = aa;
            }
        } else static if(isArray!T) {
            _type = DType.Array;
            static if(is(ElementEncodingType!T : DTree)) {
                _value.Array = arg;
            } else {
                DTree[] new_arg = new DTree[arg.length];
                foreach(i, e; arg)
                    new_arg[i] = DTree(e);
                _value.Array = new_arg;
            }
        } else static if(is(T : DTree)) {
            _type = arg.type;
            _value = arg._value;
        } else {
            static assert(false, text(`unable to convert type "`, T.stringof, `" to json`));
        }
    }

    private void assignRef(T)(ref T arg) if(isStaticArray!T) {
        _type = DType.Array;
        static if(is(ElementEncodingType!T : DTree)) {
            _value.Array = arg;
        } else {
            DTree[] new_arg = new DTree[arg.length];
            foreach(i, e; arg)
                new_arg[i] = DTree(e);
            _value.Array = new_arg;
        }
    }

    /**
     * Constructor for $(D DTree). If $(D arg) is a $(D DTree)
     * its value and type will be copied to the new $(D DTree).
     * Note that this is a shallow copy: if type is $(D DType.Object)
     * or $(D DType.Array) then only the reference to the data will
     * be copied.
     * Otherwise, $(D arg) must be implicitly convertible to one of the
     * following types: $(D typeof(null)), $(D string), $(D ulong),
     * $(D long), $(D double), an associative Array $(D V[K]) for any $(D V)
     * and $(D K) i.e. a JSON Object, any Array or $(D bool). The type will
     * be set accordingly.
    */
    this(T)(T arg) if(!isStaticArray!T) {
        assign(arg);
    }
    /// Ditto
    this(T)(ref T arg) if(isStaticArray!T) {
        assignRef(arg);
    }
    /// Ditto
    this(T : DTree)(inout T arg) inout {
        _value = arg._value;
        _type = arg.type;
    }
    ///
    unittest {
        DTree j = DTree( "a string" );
        j = DTree(42);

        j = DTree( [1, 2, 3] );
        assert(j.type == DType.Array);

        j = DTree( ["language": "D"] );
        assert(j.type == DType.Object);
    }

    void opAssign(T)(T arg) if(!isStaticArray!T && !is(T : DTree)) {
        assign(arg);
    }

    void opAssign(T)(ref T arg) if(isStaticArray!T) {
        assignRef(arg);
    }

    /// Array syntax for json arrays.
    /// Throws: $(D DException) if $(D type) is not $(D DType.Array).
    ref inout(DTree) opIndex(size_t i) inout pure @safe {
        auto a = this.arrayNoRef;
        enforceEx!DException(i < a.length,
                                "DTree Array index is out of range");
        return a[i];
    }
    ///
    unittest {
        DTree j = DTree( [42, 43, 44] );
        assert( j[0].Long == 42 );
        assert( j[1].Long == 43 );
    }

    /// Hash syntax for json objects.
    /// Throws: $(D DException) if $(D type) is not $(D DType.Object).
    ref inout(DTree) opIndex(string k) inout pure @safe {
        auto o = this.objectNoRef;
        return *enforce!DException(k in o, "Key not found: " ~ k);
    }
    ///
    unittest {
        DTree j = DTree( ["language": "D"] );
        assert( j["language"].String == "D" );
    }

    /// Operator sets $(D value) for element of JSON Object by $(D key).
    ///
    /// If JSON value is null, then operator initializes it with Object and then
    /// sets $(D value) for it.
    ///
    /// Throws: $(D DException) if $(D type) is not $(D DType.Object)
    /// or $(D DType.Null).
    void opIndexAssign(T)(auto ref T value, string key) pure {
        enforceEx!DException(
            type == DType.Object || type == DType.Null,
            "DTree must be Object or null"
        );
        DTree[string] aa = null;
        if (type == DType.Object) {
            aa = this.objectNoRef;
        }

        aa[key] = value;
        this.Object = aa;
    }
    ///
    unittest {
            DTree j = DTree( ["language": "D"] );
            j["language"].String = "Perl";
            assert( j["language"].String == "Perl" );
    }

    void opIndexAssign(T)(T arg, size_t i) pure {
        auto a = this.arrayNoRef;
        enforceEx!DException(i < a.length, "DTree Array index is out of range");
        a[i] = arg;
        this.Array = a;
    }
    ///
    unittest {
            DTree j = DTree( ["Perl", "C"] );
            j[1].String = "D";
            assert( j[1].String == "D" );
    }

    DTree opBinary(string op : "~", T)(T arg) @safe {
        auto a = this.arrayNoRef;
        static if(isArray!T) {
            return DTree(a ~ DTree(arg).arrayNoRef);
        } else static if(is(T : DTree)) {
            return DTree(a ~ arg.arrayNoRef);
        } else {
            static assert(false, "argument is not an Array or a DTree Array");
        }
    }

    void opOpAssign(string op : "~", T)(T arg) @safe {
        auto a = this.arrayNoRef;
        static if(isArray!T) {
            a ~= DTree(arg).arrayNoRef;
        } else static if(is(T : DTree)) {
            a ~= arg.arrayNoRef;
        } else {
            static assert(false, "argument is not an Array or a DTree Array");
        }
        this.Array = a;
    }

    /**
     * Support for the $(D in) operator.
     *
     * Tests wether a key can be found in an Object.
     *
     * Returns:
     *      when found, the $(D const(DTree)*) that matches to the key,
     *      otherwise $(D null).
     *
     * Throws: $(D DException) if the right hand side argument $(D DType)
     * is not $(D Object).
     */
    auto opBinaryRight(string op : "in")(string k) const @safe {
        return k in this.objectNoRef;
    }
    ///
    unittest {
        DTree j = [ "language": "D", "author": "walter" ];
        string a = ("author" in j).String;
    }

    bool opEquals(const DTree rhs) const @nogc nothrow pure @safe {
        return opEquals(rhs);
    }

    bool opEquals(ref const DTree rhs) const @nogc nothrow pure @trusted {
        // Default doesn't work well since _value is a union.  Compare only
        // what should be in _value.
        // This is @trusted to remain nogc, nothrow, fast, and usable from @safe code.
        if (_type != rhs._type) return false;

        final switch (_type) {
        case DType.Bool:
            return _value.Bool == rhs._value.Bool;
        case DType.String:
            return _value.String == rhs._value.String;
        case DType.Long:
            return _value.Long == rhs._value.Long;
        case DType.Ulong:
            return _value.Ulong == rhs._value.Ulong;
        case DType.Double:
            return _value.Double == rhs._value.Double;
        case DType.Object:
            return _value.Object == rhs._value.Object;
        case DType.Array:
            return _value.Array == rhs._value.Array;
        case DType.Null:
            return true;
        }
    }

    /// Implements the foreach $(D opApply) interface for json arrays.
    int opApply(int delegate(size_t index, ref DTree) dg) @system {
        int result;

        foreach(size_t index, ref value; Array) {
            result = dg(index, value);
            if(result)
                break;
        }

        return result;
    }

    /// Implements the foreach $(D opApply) interface for json objects.
    int opApply(int delegate(string key, ref DTree) dg) @system {
        enforce!DException(type == DType.Object, "DTree value is not an Object");
        int result;

        foreach(string key, ref value; Object) {
            result = dg(key, value);
            if(result)
                break;
        }

        return result;
    }

    /// Implicitly calls $(D toJSON) on this DTree.
    ///
    /// $(I options) can be used to tweak the conversion behavior.
    string toString(in bool typed = false, in bool pretty = false) const @safe {
        return _output(typed, pretty);
    }

/*     /// Implicitly calls $(D toJSON) on this DTree, like $(D toString), but
    /// also passes $(I true) as $(I pretty) argument.
    ///
    /// $(I options) can be used to tweak the conversion behavior
    string toPrettyString(bool typed = false) const @safe {
        return toJSON(this, true, options);
    }
 */    
    private string _output(in bool typed = false, in bool pretty = false, int depth = 0) const @trusted {
        string result;
        string space = ""; string nl = ""; string sep = ";"; string tab = ""; 
        if (pretty){
            space = " ";
            nl = "\n";
            sep = "\n";
            tab = "  ";
        }
        if (type == DType.Null){
            result = "null";
        } else if (type == DType.Bool){
            result = to!string(_value.Bool);
        } else if (type == DType.String){
            result = _value.String;
            /*if (!typed)*/ result = "\"" ~ result ~ "\"";
        } else if (type == DType.Long){
            result = to!string(_value.Long);
        } else if (type == DType.Ulong){
            result = to!string(_value.Ulong);
        } else if (type == DType.Double){
            result = to!string(_value.Double);
        } else if (type == DType.Object){
            auto keys = _value.Object.keys;
            import std.algorithm : sort;
            sort(keys);
            ++depth;
            foreach (i, key; keys) {
                if (i > 0) result ~= sep ~ tab.replicate(depth);
                result ~= key ~ ":" ~ space ~ _value.Object[key]._output(typed, pretty, depth);
            }
            --depth;
            if (!typed) result = "(" ~ nl ~ tab.replicate(depth + 1) ~ result ~ nl ~ tab.replicate(depth) ~ ")" ;
        } else if (type == DType.Array){
            ++depth;
            foreach (key, value; _value.Array) {
                if (key > 0) result ~= sep ~ tab.replicate(depth);
                result ~= value._output(typed, pretty, depth);
            }
            --depth;
            if (!typed) result = "(" ~ nl ~ tab.replicate(depth + 1) ~ result ~ nl ~ tab.replicate(depth) ~ ")";
        }
        if (typed) result = _type ~ "("  ~ nl ~ tab.replicate(depth + 1) ~ result  ~ nl ~ tab.replicate(depth) ~ ")";
        return result;
    }
}

struct DHandler {

    private SetTo[string] _settings;
    private SetTo[string] _defaultSettings;
    private string _format;
    private DTree delegate(string str, in SetTo[string] settings) _parse;
    private string delegate(const DTree tree, in SetTo[string] settings) _generate;

    private bool _concArgs(ref SetTo[string] _settings, SetTo[string] settings){
        foreach (key, value; settings){
            if (value.type == typeid(bool)){
                 _settings[key] = value.get!bool;
                 
            } else if (value.type == typeid(long)){
                 _settings[key] = value.get!long;
                 
            } else if (value.type == typeid(ulong)){
                 _settings[key] = value.get!ulong;
                 
            } else if (value.type == typeid(string)){
                 _settings[key] = value.get!string;
                 
            } else if (value.type == typeid(DOptions)){
                 _settings[key] = value.get!DOptions;
                 
            }
        }
        return true;
    }
    
    DTree tree;
    alias tree this;
    
    this(
        string format,
        SetTo[string] settings,
        DTree delegate(string str, in SetTo[string] settings) parse, 
        string delegate(const DTree tree, in SetTo[string] settings) generate
    ){
        _format = format;
        _defaultSettings = settings;
        _settings = settings;
        _parse = parse;
        _generate = generate;
    }
    
    DHandler opCall(string str){
        tree = _parse(str, _settings);
        return this;
    }

    DHandler opCall(){
        tree = null;
        return this;
    }

    @property string format() const pure nothrow @safe @nogc {
        return _format;
    }
    
    /// Value getter/setter for $(D DType.String).
    /// Throws: $(D DException) for read access if $(D type) is not
    /// $(D DType.String).
    @property ref SetTo[string] settings() pure @trusted {
        return _settings;
    }

    /// ditto
    ref SetTo[string] set() pure nothrow @nogc @safe {
        _settings = _defaultSettings;
        return _settings;
    }

    ref SetTo[string] set(SetTo[string] settings) {
        _concArgs(_settings, settings);
        return _settings;
    }

    ref SetTo set(string key, SetTo setting) {
        enforce!DException(key in settings, "Key " ~ key ~ " doesn't exist!" );
        _settings[key] = setting;
        return _settings[key];
    }

    ref SetTo[string] get() pure @safe {
        return _settings;
    }

    ref SetTo get(string key) pure @safe {
        enforce!DException(key == "", "Key " ~ key ~ " doesn't exist!" );
        return _settings[key];
    }


    /// Value getter/setter for $(D DType.String).
    /// Throws: $(D DException) for read access if $(D type) is not
    /// $(D DType.String).
    
    @property string toFormat() const @trusted {
        return _generate(tree, _settings);
    }

    @property string toPrettyFormat() @trusted {
        this.set("pretty", SetTo(true));
        auto result = _generate(tree, _settings);
        this.set("pretty", SetTo(false));
        return result;
    }
    
    @property ref DHandler toTree(string str) {
        tree = _parse(str, _settings);
        return this;
    }
    
    @property DHandler Tree(T)(T arg) if(!isStaticArray!T && !is(T : DTree)) {
        tree = arg;
        return this;
    }

    @property DHandler Tree(T)(ref T arg) if(isStaticArray!T) {
        tree = arg;
        return this;
    }

    @property DHandler Tree(){
        tree = null;
        return this;
    }

}

/**
Exception thrown on JSON errors
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

unittest {
    import std.exception;
    DTree jv = "123";
    assert(jv.type == DType.String);
    assertNotThrown(jv.String);
    //assertThrown!DException(jv.Long);
    assertThrown!DException(jv.Ulong);
    assertThrown!DException(jv.Double);
    assertThrown!DException(jv.Object);
    assertThrown!DException(jv.Array);
    assertThrown!DException(jv["aa"]);
    assertThrown!DException(jv[2]);

    jv = -3;
    assert(jv.type == DType.Long);
    assertNotThrown(jv.Long);

    jv = cast(uint)3;
    assert(jv.type == DType.Ulong);
    assertNotThrown(jv.Ulong);

    jv = 3.0f;
    assert(jv.type == DType.Double);
    assertNotThrown(jv.Double);

    jv = ["key" : "value"];
    assert(jv.type == DType.Object);
    assertNotThrown(jv.Object);
    assertNotThrown(jv["key"]);
    assert("key" in jv);
    assert("notAnElement" !in jv);
    assertThrown!DException(jv["notAnElement"]);
    const cjv = jv;
    assert("key" in cjv);
    assertThrown!DException(cjv["notAnElement"]);

    foreach(string key, value; jv) {
        static assert(is(typeof(value) == DTree));
        assert(key == "key");
        assert(value.type == DType.String);
        assertNotThrown(value.String);
        assert(value.String == "value");
    }

    jv = [3, 4, 5];
    assert(jv.type == DType.Array);
    assertNotThrown(jv.Array);
    assertNotThrown(jv[2]);
    foreach(size_t index, value; jv) {
        static assert(is(typeof(value) == DTree));
        assert(value.type == DType.Long);
        assertNotThrown(value.Long);
        assert(index == (value.Long-3));
    }

    jv = null;
    assert(jv.type == DType.Null);
    assert(jv.isNull);
    jv = "foo";
    assert(!jv.isNull);

    jv = DTree("value");
    assert(jv.type == DType.String);
    assert(jv.String == "value");

    DTree jv2 = DTree("value");
    assert(jv2.type == DType.String);
    assert(jv2.String == "value");

    DTree jv3 = DTree("\u001c");
    assert(jv3.type == DType.String);
    assert(jv3.String == "\u001C");
}

DHandler JSONHandler() {
    SetTo[string] settings = ["maxDepth" : SetTo(-1), "pretty" : SetTo(false), "dOptions" : SetTo(DOptions.none)];

    return DHandler(
        "JSON",
        settings,
        delegate(string jsonStr, in SetTo[string] settings){
            enforce!DException("maxDepth" in settings, "Key maxDepth doesn't exist!" );
            int maxDepth = settings["maxDepth"].get!int;
            enforce!DException("dOptions" in settings, "Key dOptions doesn't exist!" );
            DOptions options = settings["dOptions"].get!DOptions;

            return parseJSON(jsonStr, maxDepth, options);
        },
        delegate(const DTree tree, in SetTo[string] settings){
            enforce!DException("pretty" in settings, "Key pretty doesn't exist!" );
            bool pretty = settings["pretty"].get!bool;
            enforce!DException("dOptions" in settings, "Key dOptions doesn't exist!" );
            DOptions options = settings["dOptions"].get!DOptions;

            return toJSON(tree, pretty, options);
        }
    );
}

/**
Parses a serialized string and returns a tree of JSON values.
Throws: $(XREF json,DException) if the depth exceeds the max depth.
Params:
    json = json-formatted string to parse
    maxDepth = maximum depth of nesting allowed, -1 disables depth checking
    options = enable decoding string representations of NaN/Inf as float values
*/
DTree parseJSON(T)(T json, int maxDepth = -1, DOptions options = DOptions.none) if(isInputRange!T) {
    import std.ascii : isWhite, isDigit, isHexDigit, toUpper, toLower;
    import std.utf : toUTF8;

    DTree root = DTree();
    
    //root._type = DType.Null;

    if(json.empty) return root;

    int depth = -1;
    dchar next = 0;
    int line = 1, pos = 0;

    void error(string msg) {
        throw new DException(msg, line, pos);
    }

    dchar popChar() {
        if (json.empty) error("Unexpected end of data.");
        dchar c = json.front;
        json.popFront();

        if(c == '\n') {
            line++;
            pos = 0;
        } else {
            pos++;
        }

        return c;
    }

    dchar peekChar() {
        if(!next) {
            if(json.empty) return '\0';
            next = popChar();
        }
        return next;
    }

    void skipWhitespace() {
        while(isWhite(peekChar())) next = 0;
    }

    dchar getChar(bool SkipWhitespace = false)() {
        static if(SkipWhitespace) skipWhitespace();

        dchar c;
        if(next) {
            c = next;
            next = 0;
        } else {
            c = popChar();
        }

        return c;
    }

    void checkChar(bool SkipWhitespace = true, bool CaseSensitive = true)(char c) {
        static if(SkipWhitespace) skipWhitespace();
        auto c2 = getChar();
        static if(!CaseSensitive) c2 = toLower(c2);

        if(c2 != c) error(text("Found '", c2, "' when expecting '", c, "'."));
    }

    bool testChar(bool SkipWhitespace = true, bool CaseSensitive = true)(char c) {
        static if(SkipWhitespace) skipWhitespace();
        auto c2 = peekChar();
        static if (!CaseSensitive) c2 = toLower(c2);

        if(c2 != c) return false;

        getChar();
        return true;
    }

    string parseString() {
        auto String = appender!string();

    Next:
        switch(peekChar()) {
            case '"':
                getChar();
                break;

            case '\\':
                getChar();
                auto c = getChar();
                switch(c) {
                    case '"':       String.put('"');   break;
                    case '\\':      String.put('\\');  break;
                    case '/':       String.put('/');   break;
                    case 'b':       String.put('\b');  break;
                    case 'f':       String.put('\f');  break;
                    case 'n':       String.put('\n');  break;
                    case 'r':       String.put('\r');  break;
                    case 't':       String.put('\t');  break;
                    case 'u':
                        dchar val = 0;
                        foreach_reverse(i; 0 .. 4) {
                            auto hex = toUpper(getChar());
                            if(!isHexDigit(hex)) error("Expecting hex character");
                            val += (isDigit(hex) ? hex - '0' : hex - ('A' - 10)) << (4 * i);
                        }
                        char[4] buf;
                        String.put(toUTF8(buf, val));
                        break;

                    default:
                        error(text("Invalid escape sequence '\\", c, "'."));
                }
                goto Next;

            default:
                auto c = getChar();
                appendJSONChar(String, c, &error);
                goto Next;
        }

        return String.data.length ? String.data : "";
    }

    bool tryGetSpecialFloat(string String, out DTree val) {
        switch(String) {
            case DFloatLiteral.nan:
                val.Double = double.nan;
                return true;
            case DFloatLiteral.inf:
                val.Double = double.infinity;
                return true;
            case DFloatLiteral.negativeInf:
                val.Double = -double.infinity;
                return true;
            default:
                return false;
        }
    }

    void parseValue(ref DTree tree) {
        depth++;

        if(maxDepth != -1 && depth > maxDepth) error("Nesting too deep.");

        auto c = getChar!true();

        switch(c) {
            case '{':
                if(testChar('}')) {
                    tree.Object = null;
                    break;
                }

                DTree[string] obj;
                do {
                    checkChar('"');
                    string name = parseString();
                    checkChar(':');
                    DTree member;
                    parseValue(member);
                    obj[name] = member;
                }
                while(testChar(','));
                tree.Object = obj;

                checkChar('}');
                break;

            case '[':
                if(testChar(']')) {
                    tree.Array = [];
                    break;
                }

                DTree[] arr;
                do {
                    DTree element;
                    parseValue(element);
                    arr ~= element;
                }
                while(testChar(','));

                checkChar(']');
                tree.Array = arr;
                break;

            case '"':
                auto str = parseString();

                // if special float parsing is enabled, check if string represents NaN/Inf
                if ((options & DOptions.specialFloatLiterals) && tryGetSpecialFloat(str, tree)) {
                    // found a special float, its tree was placed in tree._value.Double
                    break;
                }

                tree.String = str;
                break;

            case '0': .. case '9':
            case '-':
                auto number = appender!string();
                bool isFloat, isNegative;

                void readInteger() {
                    if(!isDigit(c)) error("Digit expected");

                Next: number.put(c);

                    if(isDigit(peekChar())) {
                        c = getChar();
                        goto Next;
                    }
                }

                if(c == '-') {
                    number.put('-');
                    c = getChar();
                    isNegative = true;
                }

                readInteger();

                if(testChar('.')) {
                    isFloat = true;
                    number.put('.');
                    c = getChar();
                    readInteger();
                }
                if(testChar!(false, false)('e')) {
                    isFloat = true;
                    number.put('e');
                    if(testChar('+')) number.put('+');
                    else if(testChar('-')) number.put('-');
                    c = getChar();
                    readInteger();
                }

                string data = number.data;
                if(isFloat) {
                    tree.Double = parse!double(data);
                } else {
                    long longNum; ulong ulongNum;

                    if (isNegative){
                        longNum = parse!long(data);
                    } else {
                        ulongNum = parse!ulong(data);
                    }
                    
                    if (isNegative){
                        tree.Long = longNum;
                    } else if (ulongNum & (1UL << 63)) {
                        tree.Ulong = ulongNum;
                    } else {
                        tree.Long = ulongNum;
                    }
                    
                }
                break;

            case 't':
            case 'T':
                tree.Bool = true;
                checkChar!(false, false)('r');
                checkChar!(false, false)('u');
                checkChar!(false, false)('e');
                break;

            case 'f':
            case 'F':
                tree.Bool = false;
                checkChar!(false, false)('a');
                checkChar!(false, false)('l');
                checkChar!(false, false)('s');
                checkChar!(false, false)('e');
                break;

            case 'n':
            case 'N':
                tree = null;
                checkChar!(false, false)('u');
                checkChar!(false, false)('l');
                checkChar!(false, false)('l');
                break;

            default:
                error(text("Unexpected character '", c, "'."));
        }

        depth--;
    }

    parseValue(root);
    return root;
}

unittest {
    enum issue15742objectOfObject = `{ "key1": { "key2": 1 }}`;
    static assert(parseJSON(issue15742objectOfObject).type == DType.Object);

    enum issue15742arrayOfArray = `[[1]]`;
    static assert(parseJSON(issue15742arrayOfArray).type == DType.Array);
}

//unittest { import std.stdio; writeln("1 Testestest!!!!!"); } // Test
unittest { 
    auto a = parseJSON(`{ "key1": { "key2": 1 }}`);
//    writeln(`a["key1"] => `, a["key1"]);
//    writeln(`a["key1"].type => `, a["key1"].type);
//    writeln(`a["key1"]["key2"] => `, a["key1"]["key2"]);
//    writeln(`a["key1"]["key2"].type => `, a["key1"]["key2"].type);
//    writeln(`a["key1"]["key2"].Long => `, a["key1"]["key2"].Long);
//    assert(a.toString == `(key1:(key2:1))`);
//    assert(toJSON(a) ==`{"key1":{"key2":1}}`);  // +Long
}

@safe unittest {
    // Ensure we can parse and use JSON from @safe code
    auto a = `{ "key1": { "key2": 1 }}`.parseJSON;
    assert(toJSON(a) ==`{"key1":{"key2":1}}`);  // +Long
    assert(a["key1"]["key2"].Long == 1);  // +Long
    //import std.stdio;
    //writeln("a.toString => ", a.toString);
    //assert(a.toString == `(key1:(key2:1))`);
}
//unittest { import std.stdio; writeln("2 Testestest!!!!!"); } // Test

unittest {
    // Ensure we can parse JSON from a @system range.
    struct Range {
        string s;
        size_t index;
        @system {
            bool empty() { return index >= s.length; }
            void popFront() { index++; }
            char front() { return s[index]; }
        }
    }
    auto s = Range(`{ "key1": { "key2": 1 }}`);
    auto json = parseJSON(s);
    assert(json["key1"]["key2"].Long == 1);
}

/**
Parses a serialized string and returns a tree of JSON values.
Throws: $(XREF json,DException) if the depth exceeds the max depth.
Params:
    json = json-formatted string to parse
    options = enable decoding string representations of NaN/Inf as float values
*/
DTree parseJSON(T)(T json, DOptions options) if(isInputRange!T) {
    return parseJSON!T(json, -1, options);
}

/**
Takes a tree of JSON values and returns the serialized string.

Any Object types will be serialized in a key-sorted order.

If $(D pretty) is false no whitespaces are generated.
If $(D pretty) is true serialized string is formatted to be human-readable.
Set the $(specialFloatLiterals) flag is set in $(D options) to encode NaN/Infinity as strings.
*/
string toJSON(const ref DTree root, in bool pretty = false, in DOptions options = DOptions.none) @safe {
    auto json = appender!string();

    void toString(string String) @safe {
        json.put('"');

        foreach (dchar c; String) {
            switch(c) {
                case '"':       json.put("\\\"");       break;
                case '\\':      json.put("\\\\");       break;
                case '/':       json.put("\\/");        break;
                case '\b':      json.put("\\b");        break;
                case '\f':      json.put("\\f");        break;
                case '\n':      json.put("\\n");        break;
                case '\r':      json.put("\\r");        break;
                case '\t':      json.put("\\t");        break;
                default:
                    appendJSONChar(json, c,
                                   (msg) { throw new DException(msg); });
            }
        }

        json.put('"');
    }

    void toValue(ref in DTree tree, ulong indentLevel) @safe {
        void putTabs(ulong additionalIndent = 0) {
            if(pretty)
                foreach(i; 0 .. indentLevel + additionalIndent)
                    json.put("    ");
        }
        void putEOL() {
            if(pretty)
                json.put('\n');
        }
        void putCharAndEOL(char ch) {
            json.put(ch);
            putEOL();
        }

        final switch(tree.type) {
            case DType.Object:
                auto obj = tree.objectNoRef;
                if(!obj.length) {
                    json.put("{}");
                } else {
                    putCharAndEOL('{');
                    bool first = true;

                    void emit(R)(R names) {
                        foreach (name; names) {
                            auto member = obj[name];
                            if(!first)
                                putCharAndEOL(',');
                            first = false;
                            putTabs(1);
                            toString(name);
                            json.put(':');
                            if(pretty)
                                json.put(' ');
                            toValue(member, indentLevel + 1);
                        }
                    }

                    import std.algorithm : sort;
                    import std.array;
                    // @@@BUG@@@ 14439
                    // auto names = obj.keys;  // aa.keys can't be called in @safe code
                    auto names = new string[obj.length];
                    size_t i = 0;
                    foreach (k, v; obj) {
                        names[i] = k;
                        i++;
                    }
                    sort(names);
                    emit(names);

                    putEOL();
                    putTabs();
                    json.put('}');
                }
                break;

            case DType.Array:
                auto arr = tree.arrayNoRef;
                if(arr.empty) {
                    json.put("[]");
                } else {
                    putCharAndEOL('[');
                    foreach (i, el; arr) {
                        if(i)
                            putCharAndEOL(',');
                        putTabs(1);
                        toValue(el, indentLevel + 1);
                    }
                    putEOL();
                    putTabs();
                    json.put(']');
                }
                break;

            case DType.String:
                toString(tree.String);
                break;

            case DType.Long:
                json.put(to!string(tree.Long));  // +Long
                break;

            case DType.Ulong:
                json.put(to!string(tree.Ulong));
                break;

            case DType.Double:
                import std.math : isNaN, isInfinity;  

                auto val = tree.Double;

                if (val.isNaN) {
                    if (options & DOptions.specialFloatLiterals) {
                        toString(DFloatLiteral.nan);
                    } else {
                        throw new DException(
                            "Cannot encode NaN. Consider passing the specialFloatLiterals flag."
                        );
                    }
                } else if (val.isInfinity) {
                    if (options & DOptions.specialFloatLiterals) {
                        toString((val > 0) ?  DFloatLiteral.inf : DFloatLiteral.negativeInf);
                    } else {
                        throw new DException(
                            "Cannot encode Infinity. Consider passing the specialFloatLiterals flag."
                        );
                    }
                } else {
                    json.put(to!string(val));
                }
                break;

            case DType.Bool:
                json.put(to!string(tree.Bool));
                break;

            case DType.Null:
                json.put("null");
                break;
        }
    }

    toValue(root, 0);
    return json.data;
}

private void appendJSONChar(ref Appender!string dst, dchar c, scope void delegate(string) error) @safe {
    import std.uni : isControl;

    if(isControl(c)) {
        dst.put("\\u");
        foreach_reverse (i; 0 .. 4) {
            char ch = (c >>> (4 * i)) & 0x0f;
            ch += ch < 10 ? '0' : 'A' - 10;
            dst.put(ch);
        }
    } else {
        dst.put(c);
    }
}



unittest {
    // Bugzilla 11504

    DTree jv = 1;
    assert(jv.type == DType.Long);

    jv.String = "123";
    assert(jv.type == DType.String);
    assert(jv.String == "123");

    jv.Long = 1;
    assert(jv.type == DType.Long);
    assert(jv.Long == 1);

    jv.Ulong = 2u;
    assert(jv.type == DType.Ulong);
    assert(jv.Ulong == 2u);

    jv.Double = 1.5f;
    assert(jv.type == DType.Double);
    assert(jv.Double == 1.5f);

    jv.Object = ["key" : DTree("value")];
    assert(jv.type == DType.Object);
    assert(jv.Object == ["key" : DTree("value")]);

    jv.Array = [DTree(1), DTree(2), DTree(3)];
    assert(jv.type == DType.Array);
    assert(jv.Array == [DTree(1), DTree(2), DTree(3)]);

    jv = true;
    assert(jv.type == DType.Bool);

    jv = false;
    assert(jv.type == DType.Bool);

    enum E{True = true}
    jv = E.True;
    assert(jv.type == DType.Bool);
}

pure unittest {
    // Adding new json element via Array() / Object() directly

    DTree jarr = DTree([10]);
    foreach (i; 0..9)
        jarr.Array ~= DTree(i);
    assert(jarr.Array.length == 10);

    DTree jobj = DTree(["key" : DTree("value")]);
    foreach (i; 0..9)
        jobj.Object[text("key", i)] = DTree(text("value", i));
    assert(jobj.Object.length == 10);
}

pure unittest {
    // Adding new json element without Array() / Object() access

    DTree jarr = DTree([10]);
    foreach (i; 0..9)
        jarr ~= [DTree(i)];
    assert(jarr.Array.length == 10);

    DTree jobj = DTree(["key" : DTree("value")]);
    foreach (i; 0..9)
        jobj[text("key", i)] = DTree(text("value", i));
    assert(jobj.Object.length == 10);

    // No Array alias
    auto jarr2 = jarr ~ [1,2,3];
    jarr2[0] = 999;
    assert(jarr[0] == DTree(10));
}

unittest {
    import std.exception;

    // An overly simple test suite, if it can parse a serializated string and
    // then use the resulting values tree to generate an identical
    // serialization, both the decoder and encoder works.

    auto jsons = [
        `null`,
        `true`,
        `false`,
        `0`,
        `123`,
        `-4321`,
        `0.23`,
        `-0.23`,
        `""`,
        `"hello\nworld"`,
        `"\"\\\/\b\f\n\r\t"`,
        `[]`,
        `[12,"foo",true,false]`,
        `{}`,
        `{"a":1,"b":null}`,
        `{"goodbye":[true,"or",false,["test",42,{"nested":{"a":23.54,"b":0.0012}}]],"hello":{"Array":[12,null,{}],"json":"is great"}}`,
    ];

    version (MinGW)
        jsons ~= `1.223e+024`;
    else
        jsons ~= `1.223e+24`;

    DTree tree;
    string result;
    foreach (json; jsons) {
        try {
            tree = parseJSON(json);
            enum pretty = false;
            result = toJSON(tree, pretty);
            assert(result == json, text(result, " should be ", json));
        } catch (DException e) {
            import std.stdio : writefln;
            writefln(text(json, "\n", e.toString()));
        }
    }

        // Should be able to correctly interpret unicode entities
    tree = parseJSON(`"\u003C\u003E"`);
    assert(toJSON(tree) == "\"\&lt;\&gt;\"");
    assert(tree.to!string() == "\"\&lt;\&gt;\"");
    tree = parseJSON(`"\u0391\u0392\u0393"`);
    assert(toJSON(tree) == "\"\&Alpha;\&Beta;\&Gamma;\"");
    assert(tree.to!string() == "\"\&Alpha;\&Beta;\&Gamma;\"");
    tree = parseJSON(`"\u2660\u2666"`);
    assert(toJSON(tree) == "\"\&spades;\&diams;\"");
    assert(tree.to!string() == "\"\&spades;\&diams;\"");

    //0x7F is a control character (see Unicode spec)
    tree = parseJSON(`"\u007F"`);
    assert(toJSON(tree) == "\"\\u007F\"");
    //writeln("tree.to!string() => ", tree.to!string(), " != \"\\u007F\"");
    //assert(tree.to!string() == "\"\\u007F\"", "tree.to!string() => " ~ tree.to!string() ~ " != \"\\u007F\""); // Redas

    with(parseJSON(`""`))
        assert(String == "" && String !is null);
    with(parseJSON(`[]`))
        assert(!Array.length);

    // Formatting
    tree = parseJSON(`{"a":[null,{"x":1},{},[]]}`);
    assert(toJSON(tree, true) == `{
    "a": [
        null,
        {
            "x": 1
        },
        {},
        []
    ]
}`);
}

unittest {
  auto json = `"hello\nworld"`;
  auto jh = JSONHandler();
  jh.tree = parseJSON(json);
  assert(jh.toFormat == json);
  assert(jh.toPrettyFormat == json);
}

pure unittest {
    // Bugzilla 12969

    DTree jv;
    jv["int"] = 123;

    assert(jv.type == DType.Object);
    assert("int" in jv);
    assert(jv["int"].Long == 123);  // +Long

    jv["Array"] = [1, 2, 3, 4, 5];

    assert(jv["Array"].type == DType.Array);
    assert(jv["Array"][2].Long == 3); // +Long

    jv["String"] = "D language";
    assert(jv["String"].type == DType.String);
    assert(jv["String"].String == "D language");

    jv["bool"] = false;
    assert(jv["bool"].type == DType.Bool);

    assert(jv.Object.length == 4);

    jv = [5, 4, 3, 2, 1];
    assert( jv.type == DType.Array );
    assert( jv[3].Long == 2 );  // +Long
}

unittest {
    auto s = q"EOF
[
  1,
  2,
  3,
  potato
]
EOF";

    import std.exception;

    auto e = collectException!DException(parseJSON(s));
    assert(e.msg == "Unexpected character 'p'. (Line 5:3)", e.msg);
}

// handling of special float values (NaN, Inf, -Inf)
unittest {
    import std.math      : isNaN, isInfinity;
    import std.exception : assertThrown;

    // expected representations of NaN and Inf
    enum {
        nanString         = '"' ~ DFloatLiteral.nan         ~ '"',
        infString         = '"' ~ DFloatLiteral.inf         ~ '"',
        negativeInfString = '"' ~ DFloatLiteral.negativeInf ~ '"',
    }
    auto jh = JSONHandler;
    // with the specialFloatLiterals option, encode NaN/Inf as strings
    jh.set("dOptions", SetTo(DOptions.specialFloatLiterals));
    assert(jh.Tree(float.nan).toFormat()       == nanString);
    assert(jh.Tree(double.infinity).toFormat() == infString);
    assert(jh.Tree(-real.infinity).toFormat()  == negativeInfString);

    // without the specialFloatLiterals option, throw on encoding NaN/Inf
    jh.set("dOptions", SetTo(DOptions.none));
    assertThrown!DException(jh.Tree(float.nan).toFormat);
    assertThrown!DException(jh.Tree(double.infinity).toFormat);
    assertThrown!DException(jh.Tree(-real.infinity).toFormat);

    // when parsing json with specialFloatLiterals option, decode special strings as floats
    DTree jvNan    = parseJSON(nanString, DOptions.specialFloatLiterals);
    DTree jvInf    = parseJSON(infString, DOptions.specialFloatLiterals);
    DTree jvNegInf = parseJSON(negativeInfString, DOptions.specialFloatLiterals);

    assert(jvNan.Double.isNaN);
    assert(jvInf.Double.isInfinity    && jvInf.Double > 0);
    assert(jvNegInf.Double.isInfinity && jvNegInf.Double < 0);

    // when parsing json without the specialFloatLiterals option, decode special strings as strings
    jvNan    = parseJSON(nanString);
    jvInf    = parseJSON(infString);
    jvNegInf = parseJSON(negativeInfString);

    assert(jvNan.String    == DFloatLiteral.nan);
    assert(jvInf.String    == DFloatLiteral.inf);
    assert(jvNegInf.String == DFloatLiteral.negativeInf);
}

pure nothrow @safe @nogc unittest {
    DTree testVal;
    testVal = "test";
    testVal = 10;
    testVal = 10u;
    testVal = 1.0;
    testVal = (DTree[string]).init;
    testVal = DTree[].init;
    testVal = null;
    assert(testVal.isNull);
}
