//Written in the D programming language
/*
 * Fixed point type.
 *
 * Copyright 2013-2015 Jaypha
 *
 * Distributed under the Boost Software License, Version 1.0.
 * (See http://www.boost.org/LICENSE_1_0.txt)
 *
 * Authors: Jason den Dulk
 */

/*
 * A fixed point number is a number with a fixed number of decimal places. The
 * number of decimal places never varies, unlike floating point types, where the
 * number of decimal places varies depending on the value.
 *
 * Fixed point values are used wherever fractions are needed, but floating point
 * values are undesirable or impractical, eg currencies.
 *
 * Fixed point values are precise (no rounding issues) and are integral in
 * behaviour (division and modulo work the same as they do for integers).
 */

module jaypha.fixed;

import std.string;
import std.math;
import std.conv;

//-----------------------------------------------------------------------------
struct Fixed(uint scale)
//-----------------------------------------------------------------------------
{
  enum factor = 10^^scale;


  private:
    long value;
    static pure nothrow Fixed make(long v) { Fixed fixed; fixed.value = v; return fixed; }

  public:

    // min and max represent the smallest and larget possible values respectively.

    static immutable Fixed min = make(long.min);
    static immutable Fixed max = make(long.max);

    //-----------------------------------------------------

    pure nothrow this(long v) { value = v * factor; }
    nothrow this(double v) { value = lround(v * factor); }
    this(string v) { value = lround(std.conv.to!double(v) * factor); }

    //-----------------------------------------------------
    // Unary operators.

    pure nothrow Fixed opUnary(string s:"++")() { value += factor; return this; }
    pure nothrow Fixed opUnary(string s:"--")() { value -= factor; return this; }

    pure nothrow Fixed opUnary(string s)()  { mixin("return make("~s~"value);"); }

    //-----------------------------------------------------
    // Equality

    pure nothrow bool opEquals(Fixed b) const  { return (value == b.value); }
    pure nothrow bool opEquals(long b)  const  { return (value == b*factor); }
    pure nothrow bool opEquals(double b) const { return ((cast(double)value / factor) == b); }

    //-----------------------------------------------------
    // Comparison

    pure nothrow int opCmp(const Fixed b) const
    {
      if (value < b.value) return -1;
      if (value > b.value) return 1;
      return 0;
    }

    pure nothrow int opCmp(const long b) const
    {
      if (value < b*factor) return -1;
      if (value > b*factor) return 1;
      return 0;
    }

    pure nothrow int opCmp(const double b) const
    {
      if (value < b*factor) return -1;
      if (value > b*factor) return 1;
      return 0;
    }

    //-----------------------------------------------------
    // Assignment

    pure nothrow void opAssign(Fixed v) { value = v.value; }
    pure nothrow void opAssign(long v) { value = v * factor; }
    pure nothrow void opAssign(int v) { value = v * factor; }
    void opAssign(double v) { value = to!long(v * factor); }
    void opAssign(float v) { value = to!long(v * factor); }
    void opAssign(string v)
    { value = lround(std.conv.to!double(v) * factor); } // TODO do this without FP

    //-----------------------------------------------------
    // Operator assignment

    pure nothrow void opOpAssign(string op)(Fixed v)
    {
      mixin("value = (this "~op~" v).value;");
    }

    pure nothrow void opOpAssign(string op)(long v)
    {
      mixin("value = (this "~op~" v).value;");
    }
    nothrow void opOpAssign(string op)(double v)
    {
      mixin("value = (this "~op~" v).value;");
    }

    //-----------------------------------------------------
    // Cast and conversion

    pure nothrow T opCast(T : long)() const
    { return value / factor; }

    pure nothrow T opCast(T : double)() const
    { return (cast(double)value) / factor; }

    pure nothrow auto conv(uint newScale)() const
    {
      static if (newScale >= scale)
        return Fixed!newScale.make(value * 10^^(newScale-scale));
      else
        return Fixed!newScale.make(value / 10^^(scale - newScale));
    }

    pure @property string asString() const
    {
      auto s = std.conv.to!string(value);
      if (value >= factor)
        return std.conv.to!string(value/factor)~"."~format("%0*d",scale,value%factor);
      else
        return format("0.%0*d",scale,value);
    }

    //-----------------------------------------------------
    // Operators for Fixed and Fixed

    pure nothrow Fixed opBinary(string s:"+")(Fixed b) const
    {
      return make(value+b.value);
    }

    pure nothrow Fixed opBinary(string s:"-")(Fixed b) const
    {
      return make(value-b.value);
    }

    pure nothrow Fixed opBinary(string s:"*")(Fixed b) const
    {
      return make(value*b.value/factor);
    }

    pure nothrow Fixed opBinary(string s:"/")(Fixed b) const
    {
      return make((value*factor)/b.value);
    }

    //-----------------------------------------------------
    // Operators for Fixed and long

    pure nothrow Fixed opBinary(string s:"+")(long b) const
    {
      return make(value + b*factor);
    }
    pure nothrow Fixed opBinaryRight(string s:"+")(long b) const
    {
      return make(value + b*factor);
    }
    pure nothrow Fixed opBinary(string s:"-")(long b) const
    {
      return make(value + b*factor);
    }
    pure nothrow Fixed opBinaryRight(string s:"-")(long b) const
    {
      return make(b*factor - value);
    }
    pure nothrow Fixed opBinary(string s:"*")(long b) const
    {
      return make(value*b);
    }
    pure nothrow Fixed opBinaryRight(string s:"*")(long b) const
    {
      return make(b*value);
    }
    pure nothrow Fixed opBinary(string s:"/")(long b) const
    {
      return make(value/b);
    }
    pure nothrow Fixed opBinaryRight(string s:"/")(long b) const
    {
      return make(b/value);
    }
    pure nothrow Fixed opBinary(string s:"%")(long b) const
    {
      return make(value%b);
    }
    pure nothrow Fixed opBinaryRight(string s:"%")(long b) const
    {
      return make(b%value);
    }


    //-----------------------------------------------------
    // Operators for Fixed and double

    nothrow Fixed opBinary(string s:"+")(double b) const
    {
      return make(value + lround(b*factor));
    }
    nothrow Fixed opBinaryRight(string s:"+")(double b) const
    {
      return make(value + lround(b*factor));
    }
    nothrow Fixed opBinary(string s:"-")(double b) const
    {
      return make(value - lround(b*factor));
    }
    nothrow Fixed opBinaryRight(string s:"-")(double b) const
    {
      return make(lround(b*factor) - value);
    }
    nothrow Fixed opBinary(string s:"*")(double b) const
    {
      return make(lround(value*b));
    }
    nothrow Fixed opBinaryRight(string s:"*")(double b) const
    {
      return make(lround(b*value));
    }
    nothrow Fixed opBinary(string s:"/")(double b) const
    {
      return make(lround(value/b));
    }
    nothrow Fixed opBinaryRight(string s:"/")(double b) const
    {
      return make(lround(b/value));
    }
}

//-----------------------------------------------------------------------------

alias Fixed!1 fix1;
alias Fixed!2 fix2;
alias Fixed!3 fix3;

//-----------------------------------------------------------------------------

unittest
{
  import std.stdio;

  assert(fix2.min.value == long.min);
  assert(fix2.max.value == long.max);

  fix2 amount;
  assert(amount.value == 0);
  assert(amount.asString == "0.00");
  amount = 20;
  assert(amount.value == 2000);

  amount = amount + 14;
  assert(amount.value == 3400);

  amount = 6 + amount;
  assert(amount.value == 4000);

  amount += 5;
  assert(amount.value == 4500);
  assert(amount == 45);
  assert(amount.asString == "45.00");
  assert(cast(long)amount == 45);
  assert(cast(double)amount == 45.0);

  amount = 0.05;
  assert(amount.value == 5);
  assert(amount == 0.05);
  assert(amount.asString == "0.05");
  assert(cast(long)amount == 0);
  assert(cast(double)amount == 0.05);

  amount = 1.05;
  assert(amount.value == 105);
  assert(amount.asString == "1.05");
  assert(cast(long)amount == 1);
  assert(cast(double)amount == 1.05);

  assert((++amount).value == 205);
  assert(amount.value == 205);
  assert((-amount).value == -205);

  amount = 50;
  assert(amount.value == 5000);


  fix2 another = amount * 2;
  assert(another.value == 10000);
  amount *= 3;
  assert(amount.value == 15000);

  amount = "30";
  assert(amount.value == 3000);

  amount = 295;
  amount /= 11;
  assert(amount.value == 2681);
  assert(amount == 26.81);

  amount = 295;
  another = 11;
  assert((amount/another).value == 2681);
  assert((amount/another).asString == "26.81");

  another = amount + 1.3;
  assert(another.value == 29630);

  amount = 30;
  another = 50.2 - amount;
  assert(another.value == 2020);

  another = amount/1.6;
  assert(another.value == 1875);

  another = amount*1.56;
  assert(another.value == 4680);

  another = 30;
  assert(amount == another);
  assert(amount <= another);
  assert(amount >= another);

  amount = 22;
  another == 22.01;
  assert(amount < another);
  assert(amount <= another);
  assert(!(amount > another));
  assert(!(amount >= another));

  fix2 rif = "23";

  assert(rif.value == 2300);

  fix2 raf = rif;
  assert(raf.value == 2300);

  auto raf1 = raf.conv!1();
  assert(raf1.value == 230);

  auto raf3 = raf.conv!3();
  assert(raf3.value == 23000);

  fix1 a = 3.2;
  fix2 b = 1.15;

  assert(a.value == 32);
  assert(b.value == 115);
}
