[![pub package](https://img.shields.io/pub/v/assorted_layout_widgets.svg)](https://pub.dartlang.org/packages/assorted_layout_widgets)

# assorted_layout_widgets

I'm always adding widgets, classes and methods to this package, not only related to layout:

| Layout                                                                                                                | Behavioral                                                                                                                                             | Special                                                                                                                                  | Formatting and Styling                                                                                                                                               |
|-----------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [ColumnSuper](#columnsuper) for column layout. It does things the original Column can't do.                           | [Delayed](#delayed) gives a widget some initial value, then change it to another value after some delay.                                               | [Button](#button) turns any widget into a button, with configurable click-area and the visual feedback.                                  | [MaskFunctionTextInputFormatter](#maskfunctiontextinputformatter) formats the text to a mask, as the user types, but the mask may change according to what is typed. |
| [RowSuper](#rowsuper) for row layout. It does things the original Row can't do.                                       | [CaptureGestures](#capturegestures) captures gestures, preventing its parent to feel them.                                                             | [CircleButton](#circlebutton) is a circular icon-button that lets you have a larger click-area and prolong the visual feedback.          | [NonUniformOutlineInputBorder](#nonuniformoutlineinputborder) can be used to style the borders of TextFields and Containers, but hiding some of the borders.         |
| [WrapSuper](#wrapsuper) is similar to the original Wrap, but you can choose different algorithms for the line-breaks. | [KeyboardDismiss](#keyboarddismiss) implements iOS and Android keyboard dismissing behavior.                                                           | [ButtonBarSuper](#buttonbarsuper) is a button-bar that places its buttons differently.                                                   | [NonUniformRoundedRectangleBorder](#nonuniformroundedrectangleborder) can be used to style the borders of Buttons and Containers, but hiding some of the borders.    |
| [Box](#box) is between a Container and a SizedBox, but is less verbose and can be made const.                         | [showDialogSuper](#showdialogsuper-and-showCupertinodialogsuper) creates a dialog with a callback for when the dialog is dismissed.                    | [GlobalValueKey](#globalvaluekey-and-globalstringkey) is a global key that uses equality instead of identity. Like ValueKey, but global. | [FitHorizontally](#fithorizontally) shrinks its child horizontally only, until a shrink limit is reached.                                                            |
| [Pad](#pad) is an EdgeInsetsGeometry which is easier to type and remember.                                            | [showCupertinoDialogSuper](#showdialogsuper-and-showCupertinodialogsuper) creates a Cupertino dialog with a callback for when the dialog is dismissed. | [GlobalStringKey](#globalvaluekey-and-globalstringkey) is a global key created from a String.                                            | [TextOneLine](#textoneline) fixes this issue: https://github.com/flutter/flutter/issues/18761                                                                        |
| [SideBySide](#sidebyside) disposes 2 widgets horizontally. It does things Row and RowSuper can't do.                  | [TimeBuilder](#timebuilder) lets you implement clocks, countdowns, stopwatches etc, the right way.                                                     |                                                                                                                                          |                                                                                                                                                                      |
| [NormalizedOverflowBox](#normalizedoverflowbox) is an OverflowBox that throws no errors and is easier to use.         |                                                                                                                                                        |                                                                                                                                          |                                                                                                                                                                      |

> _Note: The widgets you don't use will be removed by Flutter's tree shaking. So feel free to add
the library even if you want to use only one of them._

<br>

# ColumnSuper

Given a list of children widgets, this will arrange them in a column. It can overlap cells, add
separators and more.

```
ColumnSuper({
  List<Widget> children,
  double outerDistance,
  double innerDistance,
  bool invert,
  Alignment alignment,
  Widget separator,
  bool separatorOnTop,  
  bool removeChildrenWithNoHeight,
});
```                   

![](https://github.com/marcglasberg/assorted_layout_widgets/blob/master/example/lib/images/columnSuper.png)

* **`children`** is the list of widgets that represent the column cells, just like in a
  regular `Column` widget. However, the list may contain `null`s, which will be ignored.

* **`outerDistance`** is the distance in pixels before the first and after the last widget. It can
  be negative, in which case the cells will overflow the column (without any overflow warnings).

* **`innerDistance`** is the distance in pixels between the cells. It can be negative, in which case
  the cells will overlap.

* **`invert`** if true will paint the cells that come later on top of the ones that came before.
  This is specially useful when cells overlap (negative `innerDistance`).

* **`alignment`** will align the cells horizontally if they are smaller than the available
  horizontal space.

* **`separator`** is a widget which will be painted between each cell. Its height doesn't matter,
  since the distance between cells is given by `innerDistance` (in other words, separators don't
  occupy space). The separator may overflow if its width is larger than the column's width.

* **`separatorOnTop`** if `true` (the default) will paint the separator on top of the cells.
  If `false` will paint the separator below the cells.

* **`removeChildrenWithNoHeight`** if true, children with zero height will not result in an
  extra `innerDistance` and `separator`. If all children have zero height, the `outerDistance` will
  also be removed. In other words, it's as if children with zero height are removed, except for the
  fact they still occupy width. The default is false.
  See <a href="https://github.com/marcglasberg/assorted_layout_widgets/blob/master/example/lib/main_column_removing_zero_height.dart">
  this interactive example</a>.

*Note: This is not a substitute for Flutter's native `Column`, it doesn't try to have a similar API,
and it doesn't do all that `Column` does. In special, `Expanded` and `Flexible` widgets don't work
inside of `ColumnSuper`, and it will overflow if the column is not big enough to fit its contents.
`ColumnSuper` is meant only for certain use cases where `Column` won't work, like when you need
overlapping cells or separators.*

Try running
the <a href="https://github.com/marcglasberg/assorted_layout_widgets/blob/master/example/lib/main_column_super.dart">
ColumnSuper example</a>.

Also,
try <a href="https://github.com/marcglasberg/assorted_layout_widgets/blob/master/example/lib/main_column_super_playground.dart">
ColumnSuper Playground</a>.

<br>

# RowSuper

Given a list of children widgets, this will arrange them in a row. It can overlap cells, add
separators and more.

```
RowSuper({
  List<Widget> children,
  double outerDistance,
  double innerDistance,
  bool invert,
  Alignment alignment,
  Widget separator,
  bool separatorOnTop,
  bool fitHorizontally,
  double shrinkLimit,
  MainAxisSize mainAxisSize,
});
```                      

On contrary to `ColumnSuper` and the native `Row`
(which will overflow if the children are too large to fit the available free space),
`RowSuper` may resize its children **proportionately to their minimum intrinsic width**.

![](https://github.com/marcglasberg/assorted_layout_widgets/blob/master/example/lib/images/rowXRowSuperComparison.png)

Try running
the <a href="https://github.com/marcglasberg/assorted_layout_widgets/blob/master/example/lib/main_row_super.dart">
RowSuper example</a>.

Also,
try <a href="https://github.com/marcglasberg/assorted_layout_widgets/blob/master/example/lib/main_row_super_playground.dart">
RowSuper Playground</a>.

Most parameters are the same as the ones of `ColumnSuper`, except:

* **`fill`** if true will force the children to **grow their widths proportionately** to their
  minimum intrinsic width, so that they fill the whole row width. This parameter is only useful if
  the children are not wide enough to fill the whole row width. In case the children are larger than
  the row width, they will always **shrink proportionately**
  to their minimum intrinsic width, and the `fill` parameter will be ignored.
  See: <a href="https://github.com/marcglasberg/assorted_layout_widgets/blob/master/example/lib/main_row_super_fill.dart">
  RowSuper Fill example</a>.

* **`fitHorizontally`** if true will shrink the children, horizontally only, until the `shrinkLimit`
  is reached. This parameter is only useful if the children are too wide to fit the row width.
  row width. Avoid using `fitHorizontally` together with `fill: true`.

* **`shrinkLimit`** by default is 67%, which means the cell contents will shrink until 67% of their
  original width, and then overflow. Make `shrinkLimit` equal to `0.0` if you want the cell contents
  to shrink with no limits. Note, if `fitHorizontally` is false, the `shrinkLimit` is not used.

* **`mainAxisSize`** by default is `MainAxisSize.min`, which means the row will occupy no more than
  its content's width. Make it `MainAxisSize.max` to expand the row to occupy the whole horizontal
  space.

You can also use a `RowSpacer` to add empty space (if available) between cells. For example:

```
RowSuper(
  children: [
    widget1,
    RowSpacer(),
    widget2,
    widget3,
    ],
);   
```

![](https://github.com/marcglasberg/assorted_layout_widgets/blob/master/example/lib/images/rowSuperWithFitHorizontally.jpg)

Try running
the <a href="https://github.com/marcglasberg/assorted_layout_widgets/blob/master/example/lib/main_row_super_with_fit_horizontally.dart">
RowSuper with FitHorizontally example</a>.

*Note: This is not a substitute for Flutter's native `Row`, it doesn't try to have a similar API,
and it doesn't do all that `Row` does. In special, `Expanded` and `Flexible` widgets don't work
inside of `RowSuper`, since `RowSuper` will resize cells proportionately when content doesn't fit.
`RowSuper` is meant only for certain use cases where `Row` won't work, like when you need
overlapping cells, or when you need to scale the contents of the cells when they don't fit.*

<br>

# FitHorizontally

```
FitHorizontally({
  Widget child,
  double shrinkLimit,
  bool fitsHeight,
  AlignmentGeometry alignment,
});
```          

![](https://github.com/marcglasberg/assorted_layout_widgets/blob/master/example/lib/images/fitHorizontally.png)

The `child` will be asked to define its own intrinsic height. If `fitsHeight` is true, the child
will be proportionately resized (keeping its aspect ratio)
to fit the available height.

Then, if the child doesn't fit the width, it will be shrinked horizontally only (not keeping its
aspect ratio) until it fits, unless `shrinkLimit` is larger than zero, in which case it will shrink
only until that limit. Note if `shrinkLimit` is 1.0 the child will not shrink at all. The default is
0.67 (67%).

This is specially useful for text that is displayed in a single line. When text doesn't fit the
container it will shrink only horizontally, until it reaches the shrink limit. From that point on it
will clip, display ellipsis or fade, according to the text's `Text.overflow` property.

*Note: `FitHorizontally` with `shrinkLimit` 0.0 is **not** the same as `FittedBox`
with `BoxFit.fitWidth`, because `FitHorizontally` will only scale horizontally, while `FittedBox`
will maintain the aspect ratio.*

Try running
the <a href="https://github.com/marcglasberg/assorted_layout_widgets/blob/master/example/lib/main_fit_horizontally.dart">
FitHorizontally example</a>.

<br>

# Box

`Box` is a widget between a `Container`, a `SizedBox` and a `ColoredBox`:

<ul>
<li>Unlike a `Container` it can be `const`.</li>
<li>Unlike a `ColoredBox` it can have size and padding.</li>
<li>Unlike a `SizedBox` it can have color and padding.</li>
</ul>

```
const Box({
  bool show = true,
  Color color,
  EdgeInsetsGeometry padding,
  double width,
  double height,
  Alignment alignment,
  Widget child,
});
```          

Usage example:

```
const Box(color: Colors.red, width: 50, height:30);
```                            

`Box` allows you to make `const` large blocks of code. For example, the following code couldn't
be `const` if we were to use a `Container`, a `SizedBox` or a `ColoredBox`:

```
static const progressIndicator =
  Opacity(
    opacity: 0.6,
    child: Box( // Can't use Container, SizedBox or ColoredBox. 
      color: Colors.blue,
      alignment: Alignment.center,
      child: Padding(
          padding: Pad(all: 5.0),
          child: AspectRatio(
              aspectRatio: 1,
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))),),);}
```                            

Note: Const objects are final/immutable and created in compile time. So you don't waste time
creating them. Also, all const objects of the same type with the same parameters are the same
instance. So you don't waste memory creating more than one of them. In other words, const objects
make your program faster and more memory efficient. They can also be used as default values in
constructors, and they work well with hot-reload, while `final` values do not.

### Extra Box features

* You can hide the box and its contents, by making the `show: false`.

* If you make `removePaddingWhenNoChild: true`, the `padding` is only applied if the child is **not
  null**. If the `child` is `null` and `width` and `height` are also `null`, this means the box will
  occupy no space (will be hidden).

* Note: You can use the `Pad` class (provided in this package) for the `padding`, instead
  of `EdgeInsets`. For example:

  ```
  Box(padding: Pad(horizontal: 8, top: 20));
  ```

* You can change a box with the `copyWith` method. For example:

  ```
  myBox.copyWith(color: Colors.blue);
  ```

* You can create boxes by adding a `Box` to one these types:
  `bool`, `Color`, `EdgeInsetsGeometry`, `AlignmentGeometry`, or `Widget`:

  ```
  // To hide the box:
  Box(...) + false;
  
  // To show the box:
  Box(...) + true;
  
  // To change the box color:
  Box(...) + Colors.green;
  
  // To change the box padding:
  Box(...) + Pad(all: 10);
  
  // To substitute the box child:
  Box(...) + Text('abc');
  
  // To put a box inside of another:
  Box(...) + Box(...);
  ```

  Note: If you add `null`, that's not an error. It will simply return the same Box. However, if you
  add an invalid type it will throw an error in RUNTIME.

  ```
  // Not an error:
  Box(...) + null;
  
  // Throws:
  Box(...) + MyObj();
  ```

* Methods to change width and height of the box: `add`, `subtract`.

### Debugging:

* If you need to quickly and temporarily add a color to your box so that you can see it, you can use
  the constructors `Box.r` for red, `Box.g` for green, `Box.b` for blue, and `Box.y` for yellow.

  ```
  Box(child: myChild);
  Box.r(child: myChild);
  Box.g(child: myChild);
  Box.b(child: myChild);
  Box.y(child: myChild);
  ```

* If you want to see rebuilds, you can use the `Box.rand` constructor. It will then change its color
  to a random one, whenever its build method is called.

  ```
  Box.rand(child: myChild);  
  ```  

All these debugging constructors are marked as _deprecated_ so that you don't forget to remove them.

<br>

# WrapSuper

`WrapSuper` is similar to the native `Wrap` widget with `direction = Axis.horizontal`, but it allows
you to choose different algorithms for the
<a href="https://en.wikipedia.org/wiki/Line_wrap_and_word_wrap">line-breaks</a>.

`WrapSuper` displays its children in lines. It will leave `spacing` horizontal space between each
child, and it will leave `lineSpacing` vertical space between each line. The contents of each line
will then be aligned according to the `alignment`. The algorithm for the line-breaks is chosen
by `wrapType`.

```
WrapSuper({
  Key key,
  WrapType wrapType,
  double spacing,
  double lineSpacing,
  WrapSuperAlignment alignment,
  List<Widget> children,
});
```          

`WrapSuper` with `WrapType.fit` uses a
<a href="https://en.wikipedia.org/wiki/Greedy_algorithm">greedy algorithm</a> for line breaks, which
is the same one used by the native `Wrap` widget.

However, `WrapSuper` with `WrapType.balanced` (the default) uses a
<a href="https://en.wikipedia.org/wiki/Line_wrap_and_word_wrap#Minimum_raggedness">minimum
raggedness algorithm</a>
for line breaks. It will position its child widgets in the same number of lines as the greedy
algorithm, but these lines will tend to be more similar in width.

For example:

![](https://github.com/marcglasberg/assorted_layout_widgets/blob/master/example/lib/images/wrapType.jpg)

- <a href="https://stackoverflow.com/questions/51679895/in-flutter-how-to-balance-the-children-of-the-wrap-widget">
  Here</a> is my original StackOverflow question that resulted in this widget.

- The algorithm I used was based on <a href="https://xxyxyz.org/line-breaking/">this one</a>
  (Divide and Conquer), which always considers `spacing: 1.0`. It was changed (with the help
  of <a href="https://cs.stackexchange.com/users/114242/codechef">CodeChef</a>)
  to allow for other spacings.

- Add your thumbs up <a href="https://github.com/flutter/flutter/issues/53549">here</a> if you want
  native `Text` widgets to also allow for better line-breaks.

## WrapFit

After `WrapSuper` distributes its children in each line, the `wrapFit` parameter defines the width
of the widgets:

* **`min`** (the default) will keep each widget's original width.

* **`divided`** will make widgets fit all the available horizontal space. All widgets in a line will
  have the same width, even if it makes them smaller that their original width.

* **`proportional`** will make widgets larger, so that they fit all the available space. Each widget
  width will be proportional to their original width.

* **`larger`** will make widgets larger, so that they fit all the available space. Will try to make
  all widgets the same width, but won't make any widgets smaller than their original width. In more
  detail: 1) First, divide the available line width by the number of widgets in the line. That is
  the preferred width. 2) Keep the width of all widgets larger than that preferred width. 3)
  Calculate the remaining width and divide it equally by the remaining widgets.

Some examples:

![](https://github.com/marcglasberg/assorted_layout_widgets/blob/master/example/lib/images/wrapFit1.png)

![](https://github.com/marcglasberg/assorted_layout_widgets/blob/master/example/lib/images/wrapFit2.png)

![](https://github.com/marcglasberg/assorted_layout_widgets/blob/master/example/lib/images/wrapFit3.png)

![](https://github.com/marcglasberg/assorted_layout_widgets/blob/master/example/lib/images/wrapFit4.png)

Try running
the <a href="https://github.com/marcglasberg/assorted_layout_widgets/blob/master/example/lib/main_wrap_super_fit.dart">
WrapFit example</a>.

<br>

# ButtonBarSuper

`ButtonBarSuper` has a similar API to a regular `ButtonBar`, but will distribute its buttons by
using a `WrapSuper`.

![](https://github.com/marcglasberg/assorted_layout_widgets/blob/master/example/lib/images/buttonBar.png)

The default (which may be changed) is `WrapType.balanced` and `WrapFit.larger`, which means it will
distribute the buttons in as little lines as possible in a balanced way; will make the buttons fill
all the available horizontal space; and will try to make buttons have similar width in each line,
without reducing their widths.

Try running
the <a href="https://github.com/marcglasberg/assorted_layout_widgets/blob/master/example/lib/main_button_bar_super.dart">
ButtonBarSuper example</a>.

<br>

# TextOneLine

`TextOneLine` is a substitute for `Text` when `maxLines: 1`, to fix this issue:
https://github.com/flutter/flutter/issues/18761 filled by myself a long time ago.

It renders ellipsis as expected, much better than the current/ buggy and ugly-looking ellipsis of
the native `Text` widget, which cuts the whole word.

For example, this:

```
Text("This isAVeryLongWordToDemonstrateAProblem", maxLines: 1, softWrap: false);  
```

Will print this in the screen:

```
This ...  
```

While this:

```
TextOneLine("This isAVeryLongWordToDemonstrateAProblem");  
```

Will print this:

```
This isAVeryLongWordToDemonst...  
```

<br>

# Delayed

`Delayed` can be used to give a widget some initial value, and then, after some delay, change it to
another value. As we'll see, `Delayed` is specially useful when used with *implicitly animated
widgets*.

As soon as `Delayed` is inserted into the tree, it will build the widget returned by `builder`
with `initialized==false`. Then:

* If `delay` is `null`, it will rebuild with `initialized==true`
  in the next frame (usually 16 milliseconds later).

* If `delay` is NOT null, it will rebuild with `initialized==true`
  after that delay.

<br>

For example, this shows a widget after a 2 seconds delay:

```
Delayed(delay: const Duration(seconds: 2),
  builder: (context, bool initialized) =>
    initialized
      ? Container(color: Colors.red, width: 50, height: 50)
      : SizedBox()));
```                                   

<br>

For example, this changes a widget color after a 3 seconds delay:

```
Delayed(delay: const Duration(seconds: 3),
  builder: (context, bool initialized) =>
    Container(color: initialized ? Colors.red : Colors.blue,
              width: 50, 
              height: 50)
    )
)
```                                   

<br>

For example, this will fade-in a widget as soon as it enters the screen:

```
Delayed(
  builder: (context, bool initialized) =>
    AnimatedOpacity(opacity: initialized ? 1.0 : 0.0,
                    duration: const Duration(seconds: 1),
                    child: MyWidget()
    )
);
```                                   

<br>

For example, this will fade-in a widget 300 milliseconds after it enters the screen:

```
Delayed(delay: const Duration(milliseconds: 300),
  builder: (context, bool initialized) =>
    AnimatedOpacity(opacity: initialized ? 1.0 : 0.0,
                    duration: const Duration(seconds: 1),
                    child: MyWidget()
    )
);
```                                   

Try running
the <a href="https://github.com/marcglasberg/assorted_layout_widgets/blob/master/example/lib/main_delayed.dart">
Delayed example</a>.

<br>

# Pad

`Pad` is an `EdgeInsetsGeometry` which is easy to type and remember.

For example, instead of writing `padding: EdgeInsets.symmetric(vertical: 12)`
you can write simply `padding: Pad(vertical: 12)`.

```
// Instead of EdgeInsets.all(12)
padding: Pad(all: 12)

// Instead of EdgeInsets.only(top: 8, bottom: 8, left: 4, right: 2)
padding: Pad(top: 8, bottom: 8, left: 4, right: 2)

// Instead of EdgeInsets.symmetric(vertical: 12)
padding: Pad(vertical: 12)

// Instead of EdgeInsets.symmetric(vertical: 12, horizontal: 6)
padding: Pad(vertical: 12, horizontal: 6)
```

You can also compose paddings. For example, if you want 40 pixels of padding in all directions,
except the top with 50 pixels: `padding: Pad(all: 40, top: 10)`.

During development, you sometimes need to temporarily remove the padding, for debugging reasons.
Unfortunately you can't just comment the padding parameter, because the
`Padding` widget doesn't accept `null` padding. But you can just add `.x` to the
`Pad` class to remove it. It's marked as `deprecated` so that you don't forget to change it back to
normal:

```
// This is the same as Pad.zero.
padding: Pad.x(top: 8, bottom: 8, left: 4)
```

<br>

# NormalizedOverflowBox

A `NormalizedOverflowBox` is a widget that imposes different constraints on its child than it gets
from its parent, possibly allowing the child to overflow the parent.

A `NormalizedOverflowBox` is similar to an `OverflowBox`. However, then `OverflowBox` may throw
errors if it gets constraints which are incompatible with its own constraints. For example, if an
`OverflowBox` is inside a container with `maxWidth` 100, and its own `minWidth` is 150, it will
throw:

```
The following assertion was thrown during performLayout():
BoxConstraints has non-normalized width constraints. 
```

The `NormalizedOverflowBox`, on the other hand, will just make sure `maxWidth` is also 150 in the
above example, and throw no errors. In other words, a `NormalizedOverflowBox` is safer to use, and
in my opinion has the behavior `OverflowBox` should have had.

Try running
the <a href="https://github.com/marcglasberg/assorted_layout_widgets/blob/master/example/lib/main_normalized_overflow_box.dart">
NormalizedOverflowBox Example</a>. Then substitute the `NormalizedOverflowBox`s with
regular `OverflowBox`es and see where it fails.

<br>

# showDialogSuper and showCupertinoDialogSuper

Functions `showDialogSuper` and `showCupertinoDialogSuper` are identical to the native `showDialog`
and `showCupertinoDialog`, except that they let you define an `onDismissed` callback for when the
dialog is dismissed:

```
showDialogSuper(
   context: context,
   onDismissed: (dynamic result) { print("Dialog dismissed"); }
   builder: ...
} 
```

Usually there are 3 ways to close a dialog:

1) Pressing some button on the dialog that closes it (usually by calling `Navigator.pop(context)`).
2) Tapping the barrier.
3) Pressing the Android back button.

All three ways will result in the `onDismissed` callback being called.

However, when the dialog is popped by `Navigator.of(context).pop(result)` you will get the `result`
in the `onDismissed` callback. That way you can differentiate between the dialog being dismissed by
an Ok or a Cancel button. The `result` is `null` when the dialog is dismissed by tapping the barrier
or pressing BACK in Android. Example:

```                                                                             
showDialogSuper<int>(
...
  actions: [
    ElevatedButton( onPressed: (){Navigator.pop(context, 1);}, child: const Text("OK"),
    ElevatedButton( onPressed: (){Navigator.pop(context, 2);}, child: const Text("CANCEL"),        
  ]
  ...
  onDismissed: (int? result) {
    if (result == 1) print("Pressed the OK button.");
    else if (result == 2) print("Pressed the CANCEL button.");
    else if (result == null) print("Dismissed with BACK or tapping the barrier.");  
  });  
```

This method was created to solve this issue: https://github.com/flutter/flutter/issues/26542
filled by myself a long time ago.

Try running
the <a href="https://github.com/marcglasberg/assorted_layout_widgets/blob/master/example/lib/main_show_dialog_super.dart">
showDialogSuper Example</a>.

<br>

# TimeBuilder

If you need some widget to change periodically (clocks, countdowns, stopwatches etc.), one way of
implementing this is using a `Timer` to rebuild it. This is, however, very inefficient and may make
your app slow.

The `TimeBuilder` widget gives you the correct implementation of periodic rebuilds. It's based on
<a href="https://gist.github.com/rrousselGit/beaf7442a20ea7e2ed3f13bbd40984a8">Remi Rousselet's
code</a> and you can <a href="https://dash-overflow.net/articles/why_vsync/">read all about it
here</a>.

Apart from better performance, using the `TimeBuilder` widget has the following advantages:

* Compatible with DevTools "slow animations", which reduce the speed of `AnimationController`s.

* Compatible with `Clock` changes, allowing for testing (skip frames to target a specific moment in
  time).

* The `TimeBuilder` widget animation is "muted" when the widget is not visible. For example, when
  the widget is a route that is currently not visible, or because of an ancestor widget such
  as `Visibility`.

Let's see some examples.

## Periodical

To create a clock that ticks once per second, you can use the `.eachSecond` constructor:

```
TimeBuilder.eachSecond(
   builder: (BuildContext context, DateTime now, int ticks, bool isFinished) 
                => MyClock(now),
);
```

If you want the rebuilds to stop after 30 seconds you can add the `seconds` parameter:

```
TimeBuilder.eachSecond(
   seconds: 30,
   builder: (BuildContext context, DateTime now, int ticks, bool isFinished) 
                => MyClock(now),
);
```

There are also `.eachMillisecond`, `.eachMinute` and `.eachHour` constructors.

## Countdown

You can also create a seconds **countdown** from a certain `DateTime`:

```
// 100 seconds countdown.
TimeBuilder.countdown(
   start: DateTime.now(),
   seconds: 15,
   builder: (BuildContext context, DateTime now, int ticks, bool isFinished,
      {required int countdown}) 
         => Text(isFinished ? "FINISHED" : countdown.toString()),
);
```

## General animation

You can also create a general animation with the `.animate` constructor:

```
TimeBuilder.animate(
   builder: (BuildContext context, DateTime now, int ticks, bool isFinished) 
                => MyWidget(now),
   isFinished: ({required DateTime currentTime, required DateTime lastTime, required int ticks,})
                => currentTime.difference(initialTime) > Duration(seconds: 100),               
);
```

## Creating your own

And, finally, you can also create your own `TimeBuilder` using the default constructor:

```
const TimeBuilder({
   Key? key,
   required this.builder,
   required this.ifRebuilds,
   this.isFinished,
}) : super(key: key);
```

You must provide the `builder` and `ifRebuilds` callbacks.

For each frame, Flutter will first call your `ifRebuilds` callback, which may return `true`
or `false`:

```
typedef IfRebuilds = bool Function({

  /// The current time.
  required DateTime currentTime,

  /// The time of the last tick.
  required DateTime lastTime,

  /// The number of ticks since the timer started.
  required int ticks,
});
```

Only when it returns `true`, the `builder` will be asked to generate a widget. The `builder`
callback is of type `TimerWidgetBuilder`:

```
typedef TimerWidgetBuilder = Widget Function(
  BuildContext context,

  /// The time of the current tick.
  DateTime dateTime,

  /// The number of ticks since the timer started.
  int ticks,

  /// This is false while the timer is on, and becomes true as soon as it ends.
  bool isFinished,
);
```

There is also an optional `isFinished` callback. Returning `true` here will generate one last
rebuild, and then stop the animation for good (no more rebuilds).

<br>

# GlobalValueKey and GlobalStringKey

For **local** keys, Flutter provides `ObjectKey` and `ValueKey`. But for **global** keys, it
provides only `GlobalObjectKey`, which compares by **identity**:

```
Key keyA = GlobalObjectKey('1' + '23');
Key keyB = GlobalObjectKey('12' + '3');

keyA == keyA; // true
keyA == keyB; // false   
```

This package provides a `GlobalValueKey` to compare by **equality** (using `operator ==`).

For example:

```
Key keyA = GlobalValueKey('1' + '23');
Key keyB = GlobalValueKey('12' + '3');

keyA == keyA; // true
keyA == keyB; // also true   
```

If your key value is a `String`, you can also use a `GlobalStringKey`:

```
Key keyA = GlobalStringKey('1' + '23');
Key keyB = GlobalStringKey('12' + '3');

keyA == keyA; // true
keyA == keyB; // also true   
```

## Advanced

There are many use cases for the `GlobalValueKey`, but I'd like to point out two in particular:

### 1) Creating keys inside the build method

Flutter's documentation for global keys states that:

```
/// Creating a new GlobalKey on every build will throw away the state of the
/// subtree associated with the old key and create a new fresh subtree for the
/// new key. Besides harming performance, this can also cause unexpected
/// behavior in widgets in the subtree. For example, a [GestureDetector] in the
/// subtree will be unable to track ongoing gestures since it will be recreated
/// on each build.
///
/// Instead, a good practice is to let a State object own the GlobalKey, and
/// instantiate it outside the build method, such as in [State.initState].
```

However, this is only correct for Flutter's native `GlobalObjectKey`. The keys provided here in this
package can indeed be recreated on every build with no problems (as long, of course, as the value
you use to create the key has a well-behaved `operator ==`).

### 2) Global keys from data classes

Suppose you want to derive keys from data classes, and then find widgets that correspond to them.
For example, you have a `User` data class:

```
class User {
  final String name;
  User(this.name);  
  bool operator ==(Object other) => identical(this, other) || other is User && runtimeType == other.runtimeType && name == other.name;
  int get hashCode => name.hashCode;
}
```

Then you create a widget class from it:

```
class UserWidget extends StatefulWidget {
  final User user;
  UserWidget({required this.user});
  State<UserWidget> createState() => UserWidgetState();
}

class UserWidgetState extends State<UserWidget> {
  Widget build(BuildContext context) => Text(widget.user.name);  
}
```

To be able to find the user widget in the tree, modify your constructor as to create keys
automatically, from the user:

```
UserWidget({required this.user}) : super(key: GlobalValueKey<UserWidgetState>(user));
```

And then, create a `static` method for easy access to the widget state:

```
static UserWidgetState? currentState(User user) =>
  GlobalValueKey<UserWidgetState>(user).currentState; 
```

You now have easy access to your widget state, from anywhere: `UserWidget.currentState(someUser)`

You can find a <a href="https://github.com/marcglasberg/global_keys/example/lib/main.dart">complete
working example here</a>.

### Some thoughts about global keys

Global keys much more powerful than local keys, but in general, should not be used extensively. They
are workarounds. I guess that's why Flutter does not provide a `GlobalValueKey` out of the box: Not
to make global keys even more useful. Flutter has this philosophy that things that are useful, but
can be used wrong, should be made difficult. In any case, I found that `GlobalValueKey` can
sometimes make complex code orders of magnitude simpler.

<br>

# MaskFunctionTextInputFormatter

The `MaskFunctionTextInputFormatter` is a special `TextInputFormatter` that lets you format the text
in a `TextField` or `TextFormField` as the user types, according to a mask; as well as also change
that mask according to what is typed.

To use it, create your formatter and pass it to a `TextField` or `TextFormField`:

```
TextField(
  inputFormatters: [myFormatter],
);
```

This code is adapted from another package
called <a href="https://pub.dev/packages/mask_text_input_formatter">mask_text_input_formatter</a>
by <a href="https://github.com/siqwin">Sergey</a>. The difference here is that instead of providing
a `mask`, you provide a `maskFunction` that can change the mask automatically as the user types.

The `maskFunction` is of type `MaskFunction`:

```
typedef MaskFunction = String? Function({
   required TextEditingValue oldValue,
   required TextEditingValue newValue,
});
```

For example, suppose you want to format the text as `######` (where each `#` is a number) while the
user typed less than 7 numbers, but you want to format it as `###.###.###-##` for more chars than
that:

```
var myFormatter = MaskFunctionTextInputFormatter(mask: _myFormatter);

String? _myFormatter({
   required TextEditingValue oldValue,
   required TextEditingValue newValue,
}) {
   if (newValue.text.length <= 6) return '######';
   else return '###.###.###-##';
}
```

When you create the formatter, you can also provide a `filter` parameter, to define the possible
characters in the mask. If you don't provide the `filter` parameter, the default is that `#` matches
a number, and `A` matches a letter:

```
var myFormatter = MaskFunctionTextInputFormatter(
   mask: _myFormatter,
   filter: {"#": RegExp('[0-9]'), "A": RegExp('[^0-9]')});
```

The `getMaskedText` and `getUnmaskedText` methods can be used if necessary:

```
// Get masked text:
print(maskFormatter.getMaskedText()); // -> "+0 (123) 456-78-90"

// Get unmasked text:
print(maskFormatter.getUnmaskedText()); // -> 01234567890
```

**Important:** Once again, please note all the above code is based
upon <a href="https://pub.dev/packages/mask_text_input_formatter">mask_text_input_formatter</a>
by <a href="https://github.com/siqwin">Sergey</a>. The ONLY thing I added was the possibility of
using a function that changes the mask. All the rest is from the original package, and credit
belongs to their authors.

<br>

# SideBySide

The `SideBySide` widget disposes 2 widgets horizontally, while achieving a layout which is
impossible for both the native `Row` and the `RowSuper` widgets.

* The `startChild` will be on the left, and will occupy as much space as it wants, up to the
  available horizontal space.

* The `endChild` will be on the right of the `startChild` widget, and it will occupy the rest of the
  available space. Note: This means, if the `startChild` widget occupies all the available space,
  then `endChild` widget will not be displayed (since it will be sized as `0` width).

For example, suppose you want to create a title with a divider that occupies the rest of the space:

```
return SideBySide(
  startChild: Text("First Chapter", textWidthBasis: TextWidthBasis.longestLine),
  endChild: Divider(color: Colors.grey),
  innerDistance: 8,
  minEndChildWidth: 20,
);
```

![](https://github.com/marcglasberg/assorted_layout_widgets/blob/master/example/lib/images/sideBySide.png)

You can add an `innerDistance`, in pixels, between the `startChild` and `endChild`. The default is
zero. It can be negative, in which case the widgets will overlap. The `innerDistance` is only used
if the `endChild` is actually displayed.

You can define the `minEndChildWidth`, which is the minimum width, in pixels, that the `endChild`
should occupy. The default is zero.

The `crossAxisAlignment` parameter specifies how to align the `startChild` and `endChild`
vertically. The default is to center them. At the moment, only
`CrossAxisAlignment.start`, `CrossAxisAlignment.end` and `CrossAxisAlignment.center` work.

Try running
the <a href="https://github.com/marcglasberg/assorted_layout_widgets/blob/master/example/lib/main_side_by_side.dart">
SideBySide example</a>.

<br>

# Button

The `Button` widget transforms any widget into a button with some immediate visual response to a
tap. It provides you with a `builder`, and the `isPressed` boolean which tells you if the widget is
being touched or not. It can also expand the click-area, show the click-area (for debug purposes),
sustain the visual effect of the tap for some duration, and accepts a throttle period between taps:

```
Button(
    onTap: () {...},
    minVisualTapDuration: Duration(milliseconds: 200),
    tapThrottle: Duration(milliseconds: 500),
    clickAreaMargin: const Pad(horizontal: 40.0, vertical: 20),
    debugShowClickableArea: true,
    builder: ({required bool isPressed}) => 
      Text('Click Me', style: TextStyle(color: isPressed ? Colors.black : Colors.white)),        
);
```

* When the user taps the button, the `isPressed` boolean will be true for at least
  `minVisualTapDuration`.

* The widget will only feel another tap if `tapThrottle` duration has passed since the last tap.

* The click-area can be expanded by a margin given by `clickAreaMargin`, thus making the widget
  easier to tap.

* If `debugShowClickableArea` is true, the click-area will be shown in red.

Try running
the <a href="https://github.com/marcglasberg/assorted_layout_widgets/blob/master/example/lib/main_button_and_circle_button.dart">
Button and CircleButton example</a>.

<br>

# CircleButton

The `CircleButton` is similar to Flutter's native `IconButton`, but with a few differences.
Since circular buttons are small, the user's finger usually hides it during the tap. For this
reason, the `CircleButton` will:

* Show an immediate visual feedback to a tap, and then sustain that feedback for about 100
  milliseconds, enough time for the user to remove the finger and see it.
* You can expand the click-area, to make the button easier to tap and improve usability. You can
  also show the click-area, for debug purposes.

```
CircleButton(
    onTap: () {...},
    icon: Icon(Icons.shopping_cart, color: Colors.white),
    clickAreaMargin: const Pad(left: 30, right: 50, vertical: 20),
    debugShowClickableArea: true,
    backgroundColor: Colors.white30,
    tapColor: Colors.black,
    border: Border.all(width: 1, color: Colors.black),
    size: 56,                
);
```

* When the user taps the button, the `isPressed` boolean will be true for at least
  `minVisualTapDuration`.

* The widget will only feel another tap if `tapThrottle` duration has passed since the last tap.

* The click-area can be expanded by a margin given by `clickAreaMargin`, thus making the widget
  easier to tap.

* If `debugShowClickableArea` is true, the click-area will be shown in red.

Try running
the <a href="https://github.com/marcglasberg/assorted_layout_widgets/blob/master/example/lib/main_button_and_circle_button.dart">
Button and CircleButton example</a>.

<br>

# CaptureGestures

A widget that captures gestures, preventing its parent (and ascending subtree) to feel them.

How is this different from `IgnorePointer` and `AbsorbPointer`?

`IgnorePointer` makes itself and its **child** (and the descending subtree) invisible to touches.
This means, for example, if you put the `IgnorePointer` and its child above some widget inside a
Stack, the touches will "pass through" the `IgnorePointer` and be felt by the widget below it.
The gesture can also be felt by the `IgnorePointer`'s parent.

`AbsorbPointer` also makes its **child** invisible to touches, but it will also prevent the touch to
be felt by widgets below it in a Stack. But the gesture can be felt by the `AbsorbPointer`'s parent.

As you can see, `IgnorePointer` and `AbsorbPointer` act on their children and on widgets below them
in a Stack. However, in both cases the gesture can be felt by their parents.

For example, if you put `IgnorePointer` or `AbsorbPointer` inside a `ListView`, none of them will
prevent the `ListView` to be scrolled, because the `ListView` is in the **ascending** subtree).

The `CaptureGestures` however, will let its child feel the touches it cares about,
and then capture and cancel other touches that reach the `CaptureGestures` itself. This means
the `CaptureGestures` **parent** (and all the ascending subtree) will not feel the touches below
the `CaptureGestures` area.

The parameters for the `CaptureGestures.only()` constructor are:

* **`capturingTap`** turns on/off the capturing of tap gestures.
* **`capturingDoubleTap`** turns on/off the capturing of double-tap gestures.
* **`capturingLongPress`**  turns on/off the capturing of long-press gestures.
* **`capturingVerticalDrag`**  turns on/off the capturing of vertical-drag gestures.
* **`capturingHorizontal`**  turns on/off the capturing of horizontal-drag gestures.
* **`capturingForcePress`**  turns on/off the capturing of force-press gestures.
* **`display`** prints the captured events to the console (for debug reasons only).

The `CaptureGestures.all()` constructor will capture all gestures.

The `CaptureGestures.tap()` constructor will capture only single tap gestures.

### Preventing scroll

The `CaptureGestures.scroll()` constructor will capture only drag gestures (preventing both vertical
and horizontal scroll).

Consider this code:

```
ListView(
   children: [
      CaptureGestures.scroll(child: ElevatedButton(...)),
      ...   
      ...   
   ]
);   
```

Here, the `ElevatedButton` can feel the `onTap` gesture that it cares about. But the user cannot
scroll the list by touching the button and dragging it up or down, because the drag gestures are
getting captured by the `CaptureGestures`, never reaching the `ListView`.

Note: Setting the scrollable's physics to `NeverScrollableScrollPhysics()` is also an option, but
sometimes you can't do that. Also, `CaptureGestures` allows you to choose just a part of the
widget tree to cancel the scroll.

Try running
the <a href="https://github.com/marcglasberg/assorted_layout_widgets/blob/master/example/lib/main_capture_gestures.dart">
CaptureGestures example</a>.

<br>

# NonUniformOutlineInputBorder

Can be used to style **text-fields** and **containers**.

Similar to Flutter's native `OutlineInputBorder` but you can hide some of the sides, by
setting `hideTopSide`, `hideBottomSide`, `hideRightSide` and `hideLeftSide` to true.

Usage for text-fields:

```
TextField(
   decoration: InputDecoration(
      enabledBorder: NonUniformOutlineInputBorder(hideLeftSide: true, ...),
      ...
```

Usage for containers:

```
Container(
   decoration: ShapeDecoration(
      shape: NonUniformOutlineInputBorder(
         hideLeftSide: true,
         borderSide: BorderSide(width: 10),
         borderRadius: BorderRadius.only(
            topRight: Radius.circular(15),
            bottomRight: Radius.circular(35),
         ),          
   ...
```

Try running
the <a href="https://github.com/marcglasberg/assorted_layout_widgets/blob/master/example/lib/main_non_uniform_outline_input_border.dart">
NonUniformOutlineInputBorder example</a>.

<br>

# NonUniformRoundedRectangleBorder

This may be used to style **buttons** and **containers**.

Similar to Flutter's native `RoundedRectangleBorder` but you can hide some of the sides, by
setting `hideTopSide`, `hideBottomSide`, `hideRightSide` and `hideLeftSide` to false.

Usage for buttons:

```
ElevatedButton(
   style: ElevatedButton.styleFrom(
      shape: NonUniformRoundedRectangleBorder(
         hideLeftSide: true,
         side: BorderSide(color: Colors.black87, width: 15.0),
         borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            bottomLeft: Radius.circular(10),
         ), 
      ...
```

Usage for containers:

```
Container(
   decoration: ShapeDecoration(
      shape: NonUniformRoundedRectangleBorder(...)),
   ...
```

![](https://github.com/marcglasberg/assorted_layout_widgets/blob/master/example/lib/images/non_uniform_borders.png)

Try running
the <a href="https://github.com/marcglasberg/assorted_layout_widgets/blob/master/example/lib/main_non_uniform_rounded_rectangle_border.dart">
NonUniformRoundedRectangleBorder example</a>.

<br>

# KeyboardDismiss

Wrap your widget tree with a `KeyboardDismiss` so that:

1) In iOS, if parameter `iOS` is true (the default), the keyboard will follow iOS's default
   behavior:

- Keyboard closes when the user taps an empty area of the screen.
- Keyboard closes when the user swipes down from just above the keyboard edge.
- Any focused element will lose focus.

2) In Android, the default behavior is that the keyboard only closes when the user taps
   the back button or executes the back gesture. However, if you want, you can force the
   Android to follow some iOS behaviors:

- Pass `androidCloseWhenTap` true, if you want the keyboard to close when the user taps an
  empty area of the screen.
- Pass `androidCloseWhenSwipe` true, if you want the keyboard to close when the user swipes
  down from just above the keyboard edge.
- Pass `androidLoseFocus` true, if you want any focused element will lose focus.

### Placement

The `KeyboardDismiss` widget must be put in a place where it has the same size of the screen.
For example, if you use a `Scaffold`, the `KeyboardDismiss` should be **above** the scaffold, and
not inside the scaffold's body.

A good place to put the `KeyboardDismiss` widget is in the `MaterialApp.builder` method, like so:

```
MaterialApp(
   builder: (BuildContext context, Widget? child) => KeyboardDismiss(child: child);
```

<br>

# AlignPositioned

See package <a href="https://pub.dev/packages/align_positioned">align_positioned</a>
for widgets `AlignPositioned` and its siblings `AnimatedAlignPositioned` and `AnimChain`. They
should be part of this package, but will remain in their own package for historical reasons.

<br>

***

*The Flutter packages I've authored:*

* <a href="https://pub.dev/packages/async_redux">async_redux</a>
* <a href="https://pub.dev/packages/fast_immutable_collections">fast_immutable_collections</a>
* <a href="https://pub.dev/packages/provider_for_redux">provider_for_redux</a>
* <a href="https://pub.dev/packages/i18n_extension">i18n_extension</a>
* <a href="https://pub.dev/packages/align_positioned">align_positioned</a>
* <a href="https://pub.dev/packages/network_to_file_image">network_to_file_image</a>
* <a href="https://pub.dev/packages/image_pixels">image_pixels</a>
* <a href="https://pub.dev/packages/matrix4_transform">matrix4_transform</a>
* <a href="https://pub.dev/packages/back_button_interceptor">back_button_interceptor</a>
* <a href="https://pub.dev/packages/indexed_list_view">indexed_list_view</a>
* <a href="https://pub.dev/packages/animated_size_and_fade">animated_size_and_fade</a>
* <a href="https://pub.dev/packages/assorted_layout_widgets">assorted_layout_widgets</a>
* <a href="https://pub.dev/packages/weak_map">weak_map</a>
* <a href="https://pub.dev/packages/themed">themed</a>
* <a href="https://pub.dev/packages/bdd_framework">bdd_framework</a>

*My Medium Articles:*

* <a href="https://medium.com/flutter-community/https-medium-com-marcglasberg-async-redux-33ac5e27d5f6">
  Async Redux: Flutter’s non-boilerplate version of Redux</a> (
  versions: <a href="https://medium.com/flutterando/async-redux-pt-brasil-e783ceb13c43">
  Português</a>)
* <a href="https://medium.com/flutter-community/i18n-extension-flutter-b966f4c65df9">
  i18n_extension</a> (
  versions: <a href="https://medium.com/flutterando/qual-a-forma-f%C3%A1cil-de-traduzir-seu-app-flutter-para-outros-idiomas-ab5178cf0336">
  Português</a>)
* <a href="https://medium.com/flutter-community/flutter-the-advanced-layout-rule-even-beginners-must-know-edc9516d1a2">
  Flutter: The Advanced Layout Rule Even Beginners Must Know</a> (
  versions: <a href="https://habr.com/ru/post/500210/">русский</a>)
* <a href="https://medium.com/flutter-community/the-new-way-to-create-themes-in-your-flutter-app-7fdfc4f3df5f">
  The New Way to create Themes in your Flutter App</a> 

*My article in the official Flutter documentation*:

* <a href="https://flutter.dev/docs/development/ui/layout/constraints">Understanding constraints</a>

<br>_Marcelo Glasberg:_<br>
_https://github.com/marcglasberg_<br>
_https://linkedin.com/in/marcglasberg/_<br>
_https://twitter.com/glasbergmarcelo_<br>
_https://stackoverflow.com/users/3411681/marcg_<br>
_https://medium.com/@marcglasberg_<br>

