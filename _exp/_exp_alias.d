import std.stdio;

struct A {

    B *b;

    void A_out(){
        writeln(b.x);
    }
}

struct B {

    A a = A.init;
    
    a.b = &this;
    
    int x = 15;
    
    alias a this;
    
    

    void strB(){
        writeln("A_out");
    }
    
}






int main(string[] args) {


    writefln("\nFile %s is running.\n", args[0]);
    
    B b;
    
    b.strB;
    
    writeln();

    writeln("That's all! Bye bye!");

    return 0;

}

