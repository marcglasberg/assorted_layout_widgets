## [4.0.9] - 2021/05/19

* `showDialogSuper` method is identical to the native `showDialog`, except that it lets you define a
  callback for when the dialog is dismissed.

## [4.0.8] - 2021/04/05

* Fixed important bug in `FitHorizontally` widget (and `RowSuper` when using the `fitHorizontally`
  parameter).

## [4.0.7] - 2021/04/13

* `NormalizedOverflowBox` widget.

## [4.0.5] - 2021/04/10

* `WrapSuper.wrapFit` parameter.
* `ButtonBarSuper` parameter.
* New examples:
  <a href="https://github.com/marcglasberg/assorted_layout_widgets/blob/master/example/lib/main_wrap_super_fit.dart">
  WrapSuper WrapFit Example</a>
  and
  <a href="https://github.com/marcglasberg/assorted_layout_widgets/blob/master/example/lib/main_button_bar_super.dart">
  ButtonBarSuper Example</a>

## [4.0.2] - 2021/04/08

* `Pad.copyWith()`.

## [4.0.1] - 2021/03/22

* Fixed NNBD problem: `TextOneLine` as child of an intrinsic size widget.

## [4.0.0] - 2020/11/10

* Nullsafety.
* `RowSuper` horizontal alignment now applied when there are no `RowSpacer`s and `MainAxisSize`
  is `max`.

## [3.0.1] - 2020/11/10

* Breaking change: The `Box` widget now has a `padding` parameter. I recommend you use it with the
  new `Pad` class. For example: `Box(padding: Pad(top: 4.0))`. The `Pad` class solves the verbosity
  problem, and having a `padding` parameter makes `Box` more compatible with `Container` (
  remember `Box` is like a `Container` which can be made `const`, so it's best if their parameters
  are not too different).

* The debugging constructors of the `Box` widget are now marked as deprecated so that you don't
  forget to remove them (they are not really deprecated).

## [2.0.1] - 2020/11/09

* `Pad` class.

## [2.0.0] - 2020/10/02

* Support for Flutter 1.22.

## [1.3.6] - 2020/09/19

* Docs improvement.
* Fixed edge case for `RowSuper`.

## [1.3.4] - 2020/09/14

* Docs improvement.

## [1.3.3] - 2020/08/31

* RowSuper: `fill` parameter.

## [1.3.2] - 2020/08/13

* `Delayed` widget.

## [1.2.0] - 2020/06/25

* Breaking Change: `ColumnSuper` width is now the max intrinsic width of its children, just like a
  regular `Column`. To restore old
  behavior: `Container(width: double.infinity, child: ColumnSuper(...))`.
* Breaking Change: `RowSuper` height is now the max intrinsic height of its children, just like a
  regular `Row`. To restore old behavior: `Container(height: double.infinity, child: RowSuper(...))`
  .
* New examples:
  <a href="https://github.com/marcglasberg/assorted_layout_widgets/blob/master/example/lib/main_column_super_playground.dart">
  ColumnSuper Playground</a>
  and
  <a href="https://github.com/marcglasberg/assorted_layout_widgets/blob/master/example/lib/main_row_super_playground.dart">
  RowSuper Playground</a>.

## [1.1.4] - 2020/06/24

* Fix: `ColumnSuper` intrinsic height, and `RowSuper` intrinsic width.

## [1.1.3] - 2020/06/15

* Fix: `WrapSuper` minimum raggedness algorithm now uses the correct
  JavaScript's `Number.MAX_SAFE_INTEGER`.
* Fix: Divide by zero conditions.

## [1.1.1] - 2020/05/19

* Docs improvement.

## [1.1.0] - 2020/05/06

* Upgraded to Flutter 1.17.

## [1.0.18] - 2020/04/01

* `WrapSuper`.

## [1.0.15] - 2020/02/01

* Box now has `vertical` and `horizontal` as constructor parameters.

## [1.0.14] - 2019/12/11

* `TextOneLine` that fixes https://github.com/flutter/flutter/issues/18761.

## [1.0.13] - 2019/12/04

* Alignment fix.

## [1.0.12] - 2019/11/27

* `Box`.

## [1.0.10] - 2019/11/25

* `FitHorizontally` widget.
* `RowSpacer` widget.

## [1.0.0] - 2019/11/24

* `RowSuper` and `ColumnSuper` widgets.

