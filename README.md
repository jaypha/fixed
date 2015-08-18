Fixed
=====

Defines a fixed point type.

A fixed point number is a number with a fixed number of decimal places. The number of decimal places never varies, unlike floating point types, where the number of decimal places varies depending on the value.

Fixed point values are used wherever fractions are needed, but floating point values are undesirable or impractical, eg currencies.

Fixed point values are precise (no rounding issues) and are integral in behaviour (division and modulo work the same as they do for integers).

Usage
-----

Import `jaypha.fixed` into your project. Instantiate with the desired scale.

Example:
```
auto v = Fixed!2(23); // Creates a value with 2 decimal places.
```

`Fixed` implements all the arithmetic, comparison and assignment operators, as well as casting to long and double types.

In addition the following methods/proerties are defined

```
pure nothrow auto conv(uint newScale)()
````

Converts to a different number of decimal places.

````
@property string asString()
````

Convert to a string. Includes the full number of decimal places.

```
Fixed.min;
Fixed.max;

```
Minimum and maximum possible values respectively for the implementation.
Declared as static immutables.

`fix1`, `fix2` and `fix3` are defined as aliases of `Fixed!1`, `Fixed!2` and `Fixed!3` respectively.

Example
````
fix3 value = 21.44;
value += 12;
assert(value.asString == "33.440");
````
License
-------

Distributed under the Boost License.

Contact
-------

jason@jaypha.com.au

Todo
----

Perhaps change the string -> fixed algorithm to avoid using floating point. Not sure if it is worth the effort.

I am not certian how modulo is supposed to behave for fixed point. At the moment it returns the remainder after subtracting a whole number of dividors from the divisee. If this is incorrect and anyone knows the real behaviour, please inform me. Thanks.