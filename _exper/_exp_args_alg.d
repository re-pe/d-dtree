import std.stdio;
import std.variant;
import std.typecons;
import std.conv;
import std.array;
import core.vararg;

alias DValue = Algebraic!(bool, long, ulong, double, string, This[], This[string]);

static auto settings = tuple!("pretty", "typed")(false, false);

DValue _(...) {
    DValue[] result = new DValue[_arguments.length];
    for (int i = 0; i < _arguments.length; i++) {
        if (_arguments[i] == typeid(DValue)) {
            result[i] = va_arg!(DValue)(_argptr);
        } else if (_arguments[i] == typeid(null)) {
            va_arg!(typeof(null))(_argptr);
            //va_arg(_argptr, _arguments[i]);
            result[i] = DValue();
        } else if (_arguments[i] == typeid(bool)) {
            result[i] = DValue(va_arg!(bool)(_argptr));
        } else if (_arguments[i] == typeid(ubyte)) {
            result[i] = DValue(to!ulong(va_arg!(ubyte)(_argptr)));
        } else if (_arguments[i] == typeid(ushort)) {
            result[i] = DValue(to!ulong(va_arg!(ushort)(_argptr)));
        } else if (_arguments[i] == typeid(uint)) {
            result[i] = DValue(to!ulong(va_arg!(uint)(_argptr)));
        } else if (_arguments[i] == typeid(ulong)) {
            result[i] = DValue(va_arg!(ulong)(_argptr));
        } else if (_arguments[i] == typeid(byte)) {
            result[i] = DValue(to!long(va_arg!(byte)(_argptr)));
        } else if (_arguments[i] == typeid(short)) {
            result[i] = DValue(to!long(va_arg!(short)(_argptr)));
        } else if (_arguments[i] == typeid(int)) {
            result[i] = DValue(to!long(va_arg!(int)(_argptr)));
        } else if (_arguments[i] == typeid(long)) {
            result[i] = DValue(va_arg!(long)(_argptr));
        } else if (_arguments[i] == typeid(float)) {
            result[i] = DValue(to!double(va_arg!(float)(_argptr)));
        } else if (_arguments[i] == typeid(double)) {
            result[i] = DValue(va_arg!(double)(_argptr));
        } else if (_arguments[i] == typeid(char)) {
            result[i] = DValue(to!(string)([va_arg!(char)(_argptr)]));
        } else if (_arguments[i] == typeid(string)) {
            result[i] = DValue(va_arg!(string)(_argptr));
        } else if (_arguments[i] == typeid(DValue[])) {
            result[i] = DValue(va_arg!(DValue[])(_argptr));
        } else if (_arguments[i] == typeid(DValue[string])) {
            result[i] = DValue(va_arg!(DValue[string])(_argptr));
        } else {
            assert(0);
        }
    }
    if (result.length > 1) return DValue(result);
    return result[0];
}

string toString(DValue _value, bool pretty = false, bool typed = false, int depth = 0) {
    //writeln("_value => ", _value);
    //writeln("_value.type => ", _value.type);
    string result, type;
    string space = ""; string nl = ""; string sep = ";"; string tab = "";
    if (pretty){
        space = " ";
        nl = "\n";
        sep = "\n";
        tab = "  ";
    }
    if (_value.type == typeid(void)){
        type = "Null";
        result = "null";
    } else if (_value.type == typeid(bool)){
        type = "Bool";
        result = to!string(_value.get!bool);
    } else if (_value.type == typeid(string)){
        type = "String";
        result = _value.get!string;
        /*if (!typed)*/ result = "\"" ~ result ~ "\"";
    } else if (_value.type == typeid(long)){
        type = "Long";
        result = to!string(_value.get!long);
    } else if (_value.type == typeid(ulong)){
        type = "Ulong";
        result = to!string(_value.get!ulong);
    } else if (_value.type == typeid(double)){
        type = "Double";
        result = to!string(_value.get!double);
    } else if (_value.type == typeid(DValue[string])){
        type = "Object";
        auto temp = _value.get!(DValue[string]);
        auto keys = temp.keys;
        import std.algorithm : sort;
        sort(keys);
        ++depth;
        foreach (i, key; keys) {
            if (i > 0) result ~= sep ~ tab.replicate(depth);
            result ~= key ~ ":" ~ space ~ toString(temp[key], pretty, typed, depth);
        }
        --depth;
        if (!typed) result = "(" ~ nl ~ tab.replicate(depth + 1) ~ result ~ nl ~ tab.replicate(depth) ~ ")" ;
    } else if (_value.type == typeid(DValue[])){
        type = "Array";
        ++depth;
        foreach (key, ref value; _value.get!(DValue[])) {
            if (key > 0) result ~= sep ~ tab.replicate(depth);
            result ~= toString(value, pretty, typed, depth);
        }
        --depth;
        if (!typed) result = "(" ~ nl ~ tab.replicate(depth + 1) ~ result ~ nl ~ tab.replicate(depth) ~ ")";
    }
    if (typed) result = type ~ "("  ~ nl ~ tab.replicate(depth + 1) ~ result  ~ nl ~ tab.replicate(depth) ~ ")";
    return result;
}


int main(string[] args) {


    writefln("\nFile %s is running.\n", args[0]);
    
    //auto test = _(null, false, 1, 1L, 1U, 1UL, 1.1, "abc"/*, _(null, false, 1, 1L, 1U, 1UL, 1.1, "abc")*/ );
    auto test = _(
        null, true, -1, -1L, 1U, 1UL, 1.1, "abc", 
        _(
            null, true, -1, -1L, 1U, 1UL, 1.1, "abc", 
            ["a": _("def")]
        )
    ); 
    
    writeln("test => ", test);
    writeln("toString(test) => ", toString(test));



    writeln();

    writeln("That's all! Bye bye!");

    return 0;

}

