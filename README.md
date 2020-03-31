[![pub package](https://img.shields.io/pub/v/assorted_layout_widgets.svg)](https://pub.dartlang.org/packages/assorted_layout_widgets)

# assorted_layout_widgets

Widgets in this package:

* `ColumnSuper`
* `RowSuper`
* `FitHorizontally`
* `Box`
* `WrapSuper`
* `TextOneLine`

I will slowly but surely add interesting widgets to this package.


## ColumnSuper

Given a list of children widgets, this will arrange them in a column.
It can overlap cells, add separators and more.

```dart
ColumnSuper({  
    List<Widget> children,    
    double outerDistance,
    double innerDistance,
    bool invert,
    Alignment alignment,
    Widget separator,
    bool separatorOnTop,
  });
```                   

![](https://github.com/marcglasberg/assorted_layout_widgets/blob/master/example/lib/images/columnSuper.png)

* **`children`** is the list of widgets that represent the column cells, just like in a regular `Column` widget.
However, the list may contain `null`s, which will be ignored.
 
* **`outerDistance`** is the distance in pixels before the first and after the last widget.
It can be negative, in which case the cells will overflow the column.
 
* **`innerDistance`** is the distance in pixels between the cells. 
It can be negative, in which case the cells will overlap.

* **`invert`** if true will paint the cells that come later on top of the ones that came before.
This is specially useful when cells overlap (negative `innerDistance`).

* **`alignment`** will align the cells horizontally if they are smaller than the available horizontal space.

* **`separator`** is a widget which will be put between each cells. Its height doesn't matter,
 since the distance between cells is given by `innerDistance` (in other words, separators don't occupy space).
 The separator will overflow if its width is larger than the column's width.   

* **`separatorOnTop`** if `true` (the default) will paint the separator on top of the cells.
If `false` will paint the separator below the cells.

*Note: This is not a substitute for Flutter's native `Column`, 
it doesn't try to have a similar API, and it doesn't do all that `Column` does.
In special, `Expanded` and `Flexible` widget don't work inside of `ColumnSuper`, 
and it will overflow if the column is not big enough to fit its contents.
`ColumnSuper` is meant only to certain use cases where `Column` won't work, 
like when you need overlapping cells.*

Try running the <a href="https://github.com/marcglasberg/assorted_layout_widgets/blob/master/example/lib/main_column_super.dart">ColumnSuper example</a>.


## RowSuper

Given a list of children widgets, this will arrange them in a row.
It can overlap cells, add separators and more.

```dart
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
(which will overflow if the cells are not big enough to fit their content),
`RowSuper` will resize its cells, **proportionately to the width of the minimum intrinsic width** of each cell content.

Try running the <a href="https://github.com/marcglasberg/assorted_layout_widgets/blob/master/example/lib/main_row_super.dart">RowSuper example</a>.

Most parameters are the same as the ones of `ColumnSuper`, except:

* **`fitHorizontally`** if true will resize the cells content, horizontally only, until the `shrinkLimit` is reached.   

* **`shrinkLimit`** by default is 67%, which means the cell contents will shrink until 67% of their original width,
and then overflow. Make `shrinkLimit` equal to `0.0` if you want the cell contents to shrink with no limits.
Note, if `fitHorizontally` is false, the `shrinkLimit` is not used.

* **`mainAxisSize`** by default is `MainAxisSize.min`, which means the row will occupy no more than its content's width.
Make it `MainAxisSize.max` to expand the row to occupy the whole horizontal space.

You can also use a `RowSpacer` to add empty space (if available) between cells. For example:

```dart
RowSuper(
   children: [
      widget1, 
      RowSpacer(), 
      widget2, 
      widget3,
      ]
   )
);   
```

![](https://github.com/marcglasberg/assorted_layout_widgets/blob/master/example/lib/images/rowSuperWithFirHorizontally.jpg)
 
Try running the <a href="https://github.com/marcglasberg/assorted_layout_widgets/blob/master/example/lib/main_row_super_with_fit_horizontally.dart">RowSuper with FitHorizontally example</a>.

*Note: This is not a substitute for Flutter's native `Row`, 
it doesn't try to have a similar API, and it doesn't do all that `Row` does.
In special, `Expanded` and `Flexible` widget don't work inside of `RowSuper`,
since `RowSuper` will resize cells proportionately when content doesn't fit. 
`RowSuper` is meant only to certain use cases where `Row` won't work, 
like when you need overlapping cells, or when you need to scale the contents
of the cells when they don't fit.*


## FitHorizontally

```dart
FitHorizontally({
    Widget child,  
    double shrinkLimit,
    bool fitsHeight,
    AlignmentGeometry alignment,
  });
```          

![](https://github.com/marcglasberg/assorted_layout_widgets/blob/master/example/lib/images/fitHorizontally.png)           
            

The `child` will be asked to define its own intrinsic height.
If `fitsHeight` is true, the child will be proportionately resized (keeping its aspect ratio)
to fit the available height.

Then, if the child doesn't fit the width, it will be shrinked horizontally
only (not keeping its aspect ratio) until it fits, unless `shrinkLimit` is larger than zero, 
in which case it will shrink only until that limit. 
Note if `shrinkLimit` is 1.0 the child
will not shrink at all. The default is 0.67 (67%).

This is specially useful for text that is displayed in a single line.
When text doesn't fit the container it will shrink only horizontally,
until it reaches the shrink limit. From that point on it will clip,
display ellipsis or fade, according to the text's `Text.overflow` property.

*Note: `FitHorizontally` with `shrinkLimit` 0.0  is **not** the same as `FittedBox` with `BoxFit.fitWidth`,
because `FitHorizontally` will only scale horizontally, while `FittedBox` will maintain the aspect ratio.*

Try running the <a href="https://github.com/marcglasberg/assorted_layout_widgets/blob/master/example/lib/main_fit_horizontally.dart">FitHorizontally example</a>.


## Box

`Box` is something between a `Container` and a `SizedBox`, which is less verbose and can be made `const`.

```dart
const Box({
    bool show,
    Color color,
    double top,
    double right,
    double bottom,
    double left,
    double vertical,
    double horizontal,
    double width,
    double height,
    Alignment alignment,
    Widget child,
  });
```          

Since it can be made `const`, it's good for creating colored boxes,
with or without a child and padding:

```dart
const Box(color: Colors.red, width: 50, height:30);
```
The padding is given by `top`, `right`, `bottom` and `left` values, but they
are only applied if the child is **not null**. 
If the `child`, `width` and `height` are all `null`, this means the box will occupy no space (will be
hidden). **Note:** This will be extended in the future, so that it ignores horizontal
padding when the child has zero width, and ignores vertical padding when the child
has zero height.

If `top` and `bottom` are equal, you can instead provide `vertical`:

```dart                 
// This:
const Box(top: 20, bottom:20, child: ...);

// Is the same as this:
const Box(vertical: 20, child: ...);
```


You can't provide `vertical` and `top` or `bottom` at the same time.
 
Similarly, if `right` and `left` are equal, you can instead provide `horizontal`.
You can't provide `horizontal` and `right` or `left` at the same time. 

You can also hide the box by making the `show` parameter equal to `false`.

#### Clean-Code:

`Box` can be used as a cleaner substitute for `Padding`. For example, this code:

```dart
return Container(
    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
    color: Colors.green,
    child: const Padding(
      padding: EdgeInsets.only(top: 12.0, bottom: 12.0, left: 4.0),      
      child: Text("Hello."),
    ),
  ),
);
```

Is the functional equivalent of this:

```dart
return const Box(
    vertical: 8.0,
    horizontal: 5.0,      
    color: Colors.green,
    child: Box(vertical: 12.0, left: 4.0, child: Text("Hello.")),
);
```

#### Debugging:

* If need to quickly and temporarily add a color to your box so that you can see it,
you can use the constructors `Box.r` for red, `Box.g` for green, `Box.b` for blue, and `Box.y` for yellow.

  ```dart
  Box(child: myChild);
  Box.r(child: myChild);
  Box.g(child: myChild);
  Box.b(child: myChild);
  Box.y(child: myChild);
  ```

* If you want to see rebuilds, you can use the `Box.rand` constructor.
It will then change its color to a random one, whenever its build method is called.

  ```dart
  Box.rand(child: myChild);  
  ```


## WrapSuper

`WrapSuper` is a `Wrap` with a better, minimum raggedness algorithm for line-breaks.   

Just like a regular `Wrap` widget with `direction = Axis.horizontal`, 
`WrapSuper` displays its children in lines. 
It will leave `spacing` horizontal space between each child,
and it will leave `lineSpacing` vertical space between each line.  
Each line will then be aligned according to the `alignment`.

```dart
WrapSuper({
    Key key,
    WrapType wrapType,    
    double spacing,
    double lineSpacing,
    WrapSuperAlignment alignment,        
    List<Widget> children,
  });
```          

`WrapSuper` with `WrapType.fit` is just like `Wrap`.

However, `WrapSuper` with `WrapType.balanced` (the default) follows a more balanced layout.
It will result in a similar number of lines as `Wrap`, 
but lines will tend to be more similar in width.

For example:

![](https://github.com/marcglasberg/assorted_layout_widgets/blob/master/example/lib/images/WrapType.jpg)

- <a href="https://stackoverflow.com/questions/51679895/in-flutter-how-to-balance-the-children-of-the-wrap-widget">Here</a> is my original StackOverflow question that resulted in this widget.

- You can see its algorithm <a href="https://cs.stackexchange.com/questions/123276/whats-the-most-efficient-in-terms-of-time-algorithm-to-calculate-the-minimum">here</a>.

- Add your thumbs up <a href="https://github.com/flutter/flutter/issues/53549">here</a> if you want
regular Text widgets to also allow for better line-breaks.


## TextOneLine

`TextOneLine` is a substitute for `Text` when `maxLines: 1`, to fix this issue:
https://github.com/flutter/flutter/issues/18761 filled by myself a long time ago. 

It uses a special fade-with-ellipsis, which is
much better than the current buggy and ugly-looking ellipsis-that-cuts-the-whole-word.

For example, this:

```dart
Text("This isAVeryLongWordToDemonstrateAProblem", maxLines: 1, softWrap: false);  
```

Will print this in the screen:
```
This ...  
```

While this:

```dart
TextOneLine("This isAVeryLongWordToDemonstrateAProblem");  
```

Will print this:
```
This isAVeryLongWordToDemonst...  
```




This widget probably only makes sense while that issue is not fixed.


## AlignPositioned

See package <a href="https://pub.dev/packages/align_positioned">align_positioned</a>
for widgets `AlignPositioned` and its siblings `AnimatedAlignPositioned` and `AnimChain`.
They should be part of this package, but will remain in their own package for historical reasons.

***

*The Flutter packages I've authored:* 
* <a href="https://pub.dev/packages/async_redux">async_redux</a>
* <a href="https://pub.dev/packages/provider_for_redux">provider_for_redux</a>
* <a href="https://pub.dev/packages/i18n_extension">i18n_extension</a>
* <a href="https://pub.dev/packages/align_positioned">align_positioned</a>
* <a href="https://pub.dev/packages/network_to_file_image">network_to_file_image</a>
* <a href="https://pub.dev/packages/matrix4_transform">matrix4_transform</a> 
* <a href="https://pub.dev/packages/back_button_interceptor">back_button_interceptor</a>
* <a href="https://pub.dev/packages/indexed_list_view">indexed_list_view</a> 
* <a href="https://pub.dev/packages/animated_size_and_fade">animated_size_and_fade</a>
* <a href="https://pub.dev/packages/assorted_layout_widgets">assorted_layout_widgets</a>

<br>_Marcelo Glasberg:_<br>
_https://github.com/marcglasberg_<br>
_https://twitter.com/glasbergmarcelo_<br>
_https://stackoverflow.com/users/3411681/marcg_<br>
_https://medium.com/@marcglasberg_<br>

