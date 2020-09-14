## [1.3.4] - 2020/09/14

* Docs improvement.

## [1.3.3] - 2020/08/31

* RowSuper: `fill` parameter.

## [1.3.2] - 2020/08/13

* Delayed.

## [1.2.0] - 2020/06/25

* Breaking Change: ColumnSuper width is now the max intrinsic width of its children, just like a regular Column. 
  To restore old behavior: `Container(width: double.infinity, child: ColumnSuper(...))`.
* Breaking Change: RowSuper height is now the max intrinsic height of its children, just like a regular Row. 
  To restore old behavior: `Container(height: double.infinity, child: RowSuper(...))`.
* New examples: 
<a href="https://github.com/marcglasberg/assorted_layout_widgets/blob/master/example/lib/main_column_super_playground.dart">ColumnSuper Playground</a> 
and 
<a href="https://github.com/marcglasberg/assorted_layout_widgets/blob/master/example/lib/main_row_super_playground.dart">RowSuper Playground</a>.   

## [1.1.4] - 2020/06/24

* Fix: ColumnSuper intrinsic height, and RowSuper intrinsic width.

## [1.1.3] - 2020/06/15

* Fix: WrapSuper minimum raggedness algorithm now uses the correct JavaScript's `Number.MAX_SAFE_INTEGER`.
* Fix: Divide by zero conditions.

## [1.1.1] - 2020/05/19

* Docs improvement.

## [1.1.0] - 2020/05/06

* Upgraded to Flutter 1.17.

## [1.0.18] - 2020/04/01

* WrapSuper.

## [1.0.15] - 2020/02/01

* Box now has `vertical` and `horizontal` as constructor parameters.

## [1.0.14] - 2019/12/11

* TextOneLine that fixes https://github.com/flutter/flutter/issues/18761.

## [1.0.13] - 2019/12/04

* Alignment fix.

## [1.0.12] - 2019/11/27

* Box.

## [1.0.10] - 2019/11/25

* FitHorizontally.
* RowSpacer.

## [1.0.0] - 2019/11/24

* RowSuper and ColumnSuper.

