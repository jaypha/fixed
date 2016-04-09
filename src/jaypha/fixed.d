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
 * Contributers: MoodleLadyCow
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
import std.traits;

//-----------------------------------------------------------------------------
struct Fixed(uint scale)
//-----------------------------------------------------------------------------
{
  enum factor = 10^^scale;

  private:
    enum sc = scale;
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
    void opAssign(double v) { value = to!long(v * factor); }
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

    pure nothrow T opCast(T : bool)() const
    { return value != 0; }

    // If newScale is less, then the value is rounded.
    pure nothrow auto conv(uint newScale)() const
    {
      static if (newScale == scale)
        return Fixed!scale.make(value);
      else static if (newScale > scale)
        return Fixed!newScale.make(value * 10^^(newScale-scale));
      else
      {
        auto div = 10^^(scale-newScale);
        auto newValue = value / div;
        if (value%div >= div/2)
          ++newValue;
        return Fixed!newScale.make(newValue);
      }
    }

    pure @property string asString() const
    {
      return toString();
    }

    pure string toString() const
    {
      if (value == long.min || abs(value) >= factor)
        return format("%s.%0*d",std.conv.to!string(value/factor),scale,abs(value%factor));
      else 
      {
        string sign = value >= 0 ? "" : "-";
        return format("%s0.%0*d",sign,scale,abs(value));
      }
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
      return make(value - b*factor);
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
      return make((b*factor*factor)/value);
    }
    pure nothrow Fixed opBinary(string s:"%")(long b) const
    {
      return make(value%(b*factor));
    }
    pure nothrow Fixed opBinaryRight(string s:"%")(long b) const
    {
      return make((b*factor)%value);
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
      return make(lround((b*factor*factor)/value));
    }
}

//-----------------------------------------------------------------------------
// T1 and T2 must be instances of Fixed.

pure nothrow auto mult(T1, T2)(T1 op1, T2 op2)
   if (__traits(isSame,TemplateOf!(T1), Fixed) &&
       __traits(isSame,TemplateOf!(T2), Fixed))
{
  return Fixed!(T1.sc+T2.sc).make(op1.value*op2.value);
}

//-----------------------------------------------------------------------------

alias Fixed!1 fix1;
alias Fixed!2 fix2;
alias Fixed!3 fix3;

//-----------------------------------------------------------------------------

unittest
{
  //import std.stdio;

  // Fundamentals

  assert(fix1.factor == 10);
  assert(fix2.factor == 100);
  assert(fix3.factor == 1000);
  assert(fix1.min.value == long.min);
  assert(fix1.max.value == long.max);
  assert(fix2.min.value == long.min);
  assert(fix2.max.value == long.max);
  assert(fix3.min.value == long.min);
  assert(fix3.max.value == long.max);

  // Default

  fix2 amount;
  assert(amount.value == 0);
  assert(amount.toString() == "0.00");
  assert(amount.asString == "0.00");

  // Creation

  fix1 v1 = 14;
  assert(v1.value == 140);
  fix2 v2 = -23.45;
  assert(v2.value == -2345);
  fix3 v3 = "134";
  assert(v3.value == 134000);
  fix3 v4 = "134.5";
  assert(v4.value == 134500);

  auto v5 = fix1("22");
  assert(v5.value == 220);

  assert(fix1(62).value == 620);
  assert(fix2(-30).value == -3000);
  assert(fix3("120").value == 120000);
  assert(fix2(24.6).value == 2460);
  assert(fix2(-27.2).value == -2720);
  assert(fix2(16.1f).value == 1610);
  assert(fix2(-87.3f).value == -8730);

  int i1 = 23;
  v2 = i1;
  assert(v2.value == 2300);

  i1 = -15;
  v1 = i1;
  assert(v1.value == -150);

  long l1 = 435;
  v2 = l1;
  assert(v2.value == 43500);

  l1 = -222;
  v3 = l1;
  assert(v3.value == -222000);

  // Assignment

  amount = 20;
  assert(amount.value == 2000);
  amount = -30L;
  assert(amount.value == -3000);
  amount = 13.6f;
  assert(amount.value == 1360);
  amount = 7.3;
  assert(amount.value == 730);
  amount = "-30.7";
  assert(amount.value == -3070);

  // Comparison operators

  amount = 30;

  assert(amount == 30);
  assert(amount != 22);
  assert(amount <= 30);
  assert(amount >= 30);
  assert(amount > 29);
  assert(!(amount > 31));
  assert(amount < 31);
  assert(!(amount < 29));

  amount = 22.34;

  assert(amount == 22.34);
  assert(amount != 15.6);
  assert(amount <= 22.34);
  assert(amount >= 22.34);
  assert(amount > 22.33);
  assert(!(amount > 22.35));
  assert(amount < 22.35);
  assert(!(amount < 22.33));

  fix2 another = 22.34;
  assert(amount == another);
  assert(amount <= another);
  assert(amount >= another);

  another = 22.35;
  assert(amount != another);
  assert(amount < another);
  assert(amount <= another);
  assert(!(amount > another));
  assert(!(amount >= another));
  assert(another > amount);
  assert(another >= amount);
  assert(!(another < amount));
  assert(!(another <= amount));

  // Cast and conversion

  amount = 22;
  long lVal = cast(long)amount;
  assert(lVal == 22);
  double dVal = cast(double)amount;
  assert(dVal == 22.0);
  assert(amount.toString() == "22.00");
  assert(fix2(0.15).toString() == "0.15");
  assert(fix2(-0.02).toString() == "-0.02");
  assert(fix2(-43.6).toString() == "-43.60");
  assert(fix2.min.toString() == "-92233720368547758.08");
  assert(fix2.max.toString() == "92233720368547758.07");
  bool bVal = cast(bool)amount;
  assert(bVal == true);
  assert(amount);
  assert(!fix2(0));

  auto cv1 = amount.conv!1();
  assert(cv1.factor == 10);
  assert(cv1.value == 220);
  auto cv3 = amount.conv!3();
  assert(cv3.factor == 1000);
  assert(cv3.value == 22000);

  fix3 amt3 = 3.752;
  auto amt2 = amt3.conv!2();
  assert(amt2.factor == 100);
  assert(amt2.value == 375);
  auto amt1 = amt3.conv!1();
  assert(amt1.factor == 10);
  assert(amt1.value == 38);
  auto amt0 = amt3.conv!0();
  assert(amt0.factor == 1);
  assert(amt0.value == 4);

  // Arithmmetic operators

  fix2 op1, op2;

  op1 = 5.23;
  op2 = 7.1;

  assert((op1 + op2) == 12.33);
  assert((op1 - op2) == -1.87);
  assert((op1 * op2) == 37.13);
  assert((op1 / op2) == 0.73);

  assert(op1 + 10 == 15.23);
  assert(op1 - 10 == -4.77);
  assert(op1 * 10 == 52.3);
  assert(op1 / 10 == 0.52);
  assert(op1 % 10 == 5.23);

  assert(10 + op1 == 15.23);
  assert(10 - op1 == 4.77);
  assert(10 * op1 == 52.3);
  assert(10 / op1 == 1.91);
  assert(10 % op1 == 4.77);

  assert(op1 + 9.8 == 15.03);
  assert(op1 - 9.8 == -4.57);
  assert(op1 * 9.8 == 51.25);
  assert(op1 / 9.8 == 0.53);

  assert(9.8 + op1 == 15.03);
  assert(9.8 - op1 == 4.57);
  assert(9.8 * op1 == 51.25);

  assert(9.8 / op1 == 1.87);

  assert(op1 != op2);
  assert(op1 == fix2(5.23));
  assert(op2 == fix2("7.1"));
  assert(op2 != fix2("7.09"));
  assert(op2 != fix2("7.11"));

  // Increment, decrement

  amount = 20;
  assert(++amount == 21);
  assert(amount == 21);
  assert(--amount == 20);
  assert(amount == 20);
  assert(-amount == -20);
  assert(amount == 20);

  amount = amount + 14;
  assert(amount.value == 3400);

  amount = 6 + amount;
  assert(amount.value == 4000);

  // Assignment operators.

  amount = 40;

  amount += 5;
  assert(amount.value == 4500);

  amount -= 6.5;
  assert(amount.value == 3850);

  another = -4;

  amount += another;
  assert(amount.value == 3450);

  amount *= 1.5;
  assert(amount.value == 5175);

  amount /= 12;
  assert(amount.value == 431);

  // More tests.

  amount = 0.05;
  assert(amount.value == 5);
  assert(amount == 0.05);
  assert(amount.toString() == "0.05");
  assert(cast(long)amount == 0);
  assert(cast(double)amount == 0.05);

  amount = 1.05;
  assert(amount.value == 105);
  assert(amount == 1.05);
  assert(amount.toString() == "1.05");
  assert(cast(long)amount == 1);
  assert(cast(double)amount == 1.05);

  assert((++amount).value == 205);
  assert(amount.value == 205);
  assert((-amount).value == -205);
  assert(--amount == 1.05);
  assert(amount.value == 105);

  amount = 50;
  assert(amount.value == 5000);


  another = amount * 2;
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
  assert((amount/another).toString() == "26.81");

  another = amount + 1.3;
  assert(another.value == 29630);

  amount = 30;
  another = 50.2 - amount;
  assert(another.value == 2020);
  another -= 50;

  assert(another.value == -2980);
  assert(another == -29.8);

  another = amount/1.6;
  assert(another.value == 1875);

  another = amount*1.56;
  assert(another.value == 4680);

  fix1 a = 3.2;
  fix2 b = 1.15;

  assert(a.value == 32);
  assert(b.value == 115);

  assert(fix2(334) / 15 == 22.26);
  assert(fix2(334) % 10 == 4);

  assert(334 / fix2(15.3) == 21.83);
  assert(334 % fix2(15.3) == 12.7);

  // mult function

  fix2 _v1 = 1.27;
  fix2 _v2 = 3.45;
  auto _v = _v1.mult(_v2);
  assert(_v.sc == 4);
  assert(_v.value == 43815);
}
