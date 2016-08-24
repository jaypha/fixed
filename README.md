# Fixed

Defines a fixed point (decimal) type for the D language.

A fixed point number is a number with a fixed number of decimal places. The number of decimal places never varies, unlike floating point types, where the number of decimal places varies depending on the value.

Fixed point values are used wherever fractions are needed, but floating point values are undesirable or impractical, eg currencies.

Fixed point values are precise (no rounding issues) and are integral in behaviour (division and modulo work the same as they do for integers).

In this module, Fixed is based on the long type.

## Usage

Import `jaypha.fixed` into your project. Instantiate with the desired scale.

Example:

    auto v = Fixed!2(23); // Creates a value with 2 decimal places.

`Fixed` implements all the arithmetic, comparison and assignment operators, as well as casting to long and double types.

In addition, the following methods/properties are defined

    pure nothrow auto Fixed.conv(uint newScale)()

Converts to a different number of decimal places. If the number of decimal places is reduced, then the value is rounded.

    pure string Fixed.toString() const

Convert to a string. Includes the full number of decimal places.

    static immutable Fixed.min;
    static immutable Fixed.max;

Minimum and maximum possible values respectively for the implementation.

    pure nothrow auto mult(T1, T2)(T1 op1, T2 op2)

Multiplies two instances of Fixed and gives back a new `Fixed` with a scale sufficient to hold the new value. The scale of the returned value is the sum of the scales of the operands.

Example:

    fix1 op1 = 1.7;
    fix2 op2 = 24.56;
    auto r = mult(op1,op2);
    assert(r == 41.752);
    assert(r.factor == 1000); // scale of 3

`fix1`, `fix2` and `fix3` are defined as aliases of `Fixed!1`, `Fixed!2` and `Fixed!3` respectively.

Example:

    fix3 value = 21.44;
    value += 12;
    assert(value.toString() == "33.440");

License
-------

Distributed under the Boost License.

Todo
----

Perhaps change the string -> fixed algorithm to avoid using floating point. Not sure if it is worth the effort.

I am not certain how modulo is supposed to behave for fixed point. At the moment it returns the remainder after subtracting a whole number of divisors from the divisee. If this is incorrect and anyone knows the real behaviour, please inform me. Thanks.
