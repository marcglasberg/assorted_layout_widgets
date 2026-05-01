import 'dart:async';
import 'dart:math';
import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget [OtpCodeVerificationField] is a verification code field, used for
/// one-time-password (OTP) flows such as confirming an email address or a phone number.
///
/// ## What it does
///
/// A row of [numberOfDigits] rounded boxes is shown side by side. As the
/// user types on the keyboard the characters fill in from left to right,
/// with a blinking cursor in the next empty box and a highlighted border
/// around it. Disallowed characters are silently rejected (see [codeType],
/// [codeLetterSet], and [codeLetterCasing]) and the input is capped at
/// [numberOfDigits] characters.
///
/// Tapping anywhere on the row of boxes opens the keyboard.
///
/// As soon as the last digit is typed, the code is submitted automatically
/// (there is no separate "submit" button) by calling [onSubmit]. The widget
/// then reacts to one of three outcomes:
///
/// - **Correct code** — [onSubmit] returns `true`. The widget does nothing
///   else; the owner is expected to navigate away to the next page.
/// - **Wrong code** — [onSubmit] returns `false`. An "Enter the correct
///   code" message appears below the digits, the boxes are cleared, and
///   focus returns so the user can try again.
/// - **Verification failed** — [onSubmit] throws (e.g. no internet, server
///   error). A "Could not verify the code" message appears below the digits
///   along with a "Retry" button, but the typed digits are kept so the
///   user can resubmit the same code with a single tap.
///
/// In both error cases the message disappears as soon as the user starts
/// typing again.
///
/// ## Optional countdown
///
/// The widget can also show how long the code is still valid for, as a
/// "Code valid for M:SS" line below the digits. When the timer hits zero
/// the digit row is replaced by a "Your code expired" view with a "Go
/// back to try again" button. Tapping it calls [onExpiredGoBack] — the
/// widget itself does not navigate or change state, so the owner decides
/// what happens next (typically: pop the page and request a fresh code).
///
/// ## Customization
///
/// Almost everything visual can be tweaked: digit box look, border colors
/// (with a separate color for the active box), cursor color and size, text
/// styles, the error/expired/countdown messages, and the containers that
/// wrap each piece of text. If you need fully custom buttons (e.g. to
/// match a design system) pass [buttonBuilder] and it will be used for
/// both the "Retry" and "Go back to try again" buttons; otherwise a plain
/// elevated button is used.
///
/// ----
///
/// ## Parameters
///
/// **Required**
///
/// - [onSubmit] — verifies the typed code. Returns `true` for correct,
///   `false` for wrong, or throws on verification failure. The widget
///   dismisses the keyboard before calling it.
/// - [countdownStartDateTime] — the wall-clock time the code was issued
///   at, used as the anchor for the countdown. Pass `null` to disable
///   the countdown (the field then stays active indefinitely).
/// - [onExpiredGoBack] — called when the user taps "Go back to try
///   again" on the expired view. The widget itself does no navigation.
///
/// **Allowed characters**
///
/// All three of [codeType], [codeLetterCasing], and [codeLetterSet] are
/// nullable. `null` means "user didn't say" — the widget infers a
/// reasonable behavior from whichever params *are* set (see "Defaults &
/// inference" below). Mutually-incompatible combinations are caught with
/// asserts in the constructor.
///
/// - [codeType] — what kind of characters are accepted: digits only,
///   letters only, or both. `null` = unspecified.
/// - [codeLetterCasing] — how letters are normalized (forced uppercase,
///   forced lowercase, or kept as typed for `mixed`). `null` = no
///   normalization is applied.
/// - [codeLetterSet] — which alphabet of characters is accepted (a-z/A-Z,
///   Unicode letters, hex, binary, Crockford base32, base62, "all", or a
///   custom set). `null` = unspecified.
/// - [customSet] — when [codeLetterSet] is [OtpCodeLetterSet.custom], the
///   string of characters that can be typed (digits 0-9 are added on top
///   when [codeType] is [OtpCodeType.numbersAndLetters]). Required to be
///   non-empty in that mode; ignored otherwise.
///
/// **Defaults & inference**
///
/// - All three null → digits 0-9 only (= effective `codeType=numbersOnly`).
/// - Only [codeLetterCasing] set → any character allowed (= effective
///   `codeLetterSet=all`); letters are normalized per the casing.
/// - Only [codeLetterSet] set → effective `codeType` defaults to
///   `lettersOnly` for letters-portion sets (`aToZ`, `unicodeLetters`,
///   `custom`); self-contained sets (`binary`, `crockford`, `hexadecimal`,
///   `base62`, `all`) define their own complete alphabet.
/// - Only [codeType] set → effective letter alphabet defaults to
///   `aToZ` (when the type allows letters).
///
/// **Compatibility (asserts at construction)**
///
/// - `aToZ` / `unicodeLetters` / `custom` require `codeType` ∈
///   {`lettersOnly`, `numbersAndLetters`, null}.
/// - `binary` requires `codeType` ∈ {`numbersOnly`, null}.
/// - `crockford` / `hexadecimal` / `base62` require `codeType` ∈
///   {`numbersAndLetters`, null}.
/// - `base62` additionally requires `codeLetterCasing` ∈ {`mixed`, null},
///   since uppercase / lowercase casing would collapse the 62-char alphabet.
/// - `custom` requires `customSet` to be non-empty.
///
/// **Behavior**
///
/// - [numberOfDigits] — how many character boxes to show / how many
///   characters the code has. Must be in `[2, 50]`. Defaults to `6`.
/// - [autoFocus] — whether the keyboard should pop up shortly after the
///   widget is built (waits ~350ms so a route transition does not fight
///   the keyboard appearing). Only checked at `initState`. Defaults to
///   `true`.
/// - [onChanged] — called every time the typed value changes, with the
///   current sanitized text (0 to [numberOfDigits] chars; the exact set
///   of characters depends on [codeType] and [codeLetterSet]).
/// - [showCountdown] — whether the countdown line and expired view are
///   shown at all. When `false` the field stays active forever and the
///   countdown parameters are ignored. Defaults to `true`.
/// - [countdownDuration] — how long the code is valid for, anchored at
///   [countdownStartDateTime]. Defaults to 30 minutes.
/// - [showWrongCodeMessage] — whether the wrong-code message is shown
///   after [onSubmit] returns `false`. The field is still cleared and
///   re-focused either way. Defaults to `true`.
///
/// **Text**
///
/// - [wrongCodeMessage] — shown after a wrong-code attempt. Defaults to
///   `'Enter the correct code'`.
/// - [verificationFailedMessageBuilder] — builds the message shown when [onSubmit]
///   throws. Receives the extracted error message (when [onSubmit] throws a
///   `String` or an object with a `String message`/`msg` field) or `null`.
///   Defaults to [defaultVerificationFailedMessageBuilder], which returns
///   `"Could not verify the code"` when the error message is null/empty and
///   `"Could not verify the code: $errorMessage"` otherwise.
/// - [retryButtonLabel] — label of the retry button. Defaults to
///   `'Retry'`.
/// - [expiredMessage] — headline of the expired view. Defaults to
///   `'Your code expired'`.
/// - [expiredButtonLabel] — label of the expired-view button. Defaults
///   to `'Go back to try again'`.
/// - [countdownTextBuilder] — builds the countdown text from the
///   remaining seconds. Defaults to [defaultCountdownText], which
///   formats as `"Code valid for M:SS"`.
///
/// **Containers and builders**
///
/// - [countdownContainerBuilder] — wraps the countdown text. Defaults
///   to left alignment.
/// - [errorContainerBuilder] — wraps the error messages. Defaults to
///   left alignment.
/// - [digitContainerBuilder] — wraps each digit box. Defaults to a 50x60
///   rounded rectangle with a 1px border that switches between the active
///   and inactive border colors.
/// - [buttonBuilder] — builds the "Retry" and "Go back to try again"
///   buttons. When `null`, a plain elevated button is used.
///
/// **Styles**
///
/// - [digitTextStyle] — typed digits (should include the digit color,
///   as no separate color parameter exists).
/// - [errorTextStyle] — error messages (should include the error
///   color).
/// - [expiredTextStyle] — "Your code expired" headline.
/// - [countdownTextStyle] — countdown line (should include the desired
///   color).
/// - [buttonTextStyle] — shared by the "Retry" and "Go back" buttons.
///   The color is overridden by [buttonTextColor], so this style mostly
///   contributes typography (size, weight, family).
///
/// **Colors**
///
/// - [digitBackgroundColor] — fill color of each digit box.
/// - [digitBorderColor] — border color of inactive digit boxes (boxes
///   other than the one at the current cursor position).
/// - [digitActiveBorderColor] — border color of the digit box at the
///   current cursor position.
/// - [cursorColor] — color of the blinking cursor in the active box.
/// - [cursorSize] — size of the blinking cursor. Defaults to
///   `Size(3, 30)`.
/// - [buttonBackgroundColor] — background of the "Retry" and "Go back"
///   buttons.
/// - [buttonTextColor] — text color of the "Retry" and "Go back"
///   buttons. Applied on top of [buttonTextStyle].
///
/// **Debug**
///
/// - [debugShowTextField] — when `true`, the hidden text field is shown
///   as a normal visible field below the digit boxes so a developer can
///   see what it holds and how the input formatters behave. Must be
///   `false` in production. Defaults to `false`.
class OtpCodeVerificationField extends StatefulWidget {
  //
  /// How many digit boxes to show / how many digits the code has.
  ///
  /// Must be in the range `[2, 50]` (inclusive). Defaults to `6`.
  final int numberOfDigits;

  /// What kind of characters are accepted into the field: digits only,
  /// letters only, or both. `null` means "not specified" — see the
  /// "Defaults & inference" section in the class doc for what that means
  /// in combination with [codeLetterSet] / [codeLetterCasing].
  final OtpCodeType? codeType;

  /// How letters typed into the field are normalized (forced uppercase,
  /// forced lowercase, or kept as typed for `mixed`). `null` means "no
  /// normalization is applied". See [OtpCodeLetterCasing] and the
  /// "Defaults & inference" section in the class doc.
  final OtpCodeLetterCasing? codeLetterCasing;

  /// Which characters are accepted by the field. `null` means "not
  /// specified" — see [OtpCodeLetterSet] for the available alphabets and
  /// the "Defaults & inference" section in the class doc.
  ///
  /// Some letter sets combine with [codeType] to add digits (`aToZ`,
  /// `unicodeLetters`, `custom`). Others are complete alphabets and
  /// constrain [codeType] (`binary`, `crockford`, `hexadecimal`, `base62`).
  final OtpCodeLetterSet? codeLetterSet;

  /// When [codeLetterSet] is [OtpCodeLetterSet.custom], this string is the
  /// allowed character set: only characters present in [customSet] can be
  /// typed (plus digits 0-9 when [codeType] is
  /// [OtpCodeType.numbersAndLetters]). Required to be non-empty in that
  /// mode; ignored otherwise. Defaults to `''`.
  ///
  /// When [codeLetterCasing] is [OtpCodeLetterCasing.uppercase] or
  /// [OtpCodeLetterCasing.lowercase], matching is case-insensitive — so
  /// `customSet: 'abc'` with [OtpCodeLetterCasing.uppercase] still accepts
  /// `A`, `B`, `C` (and they end up displayed in uppercase). When the
  /// casing is [OtpCodeLetterCasing.mixed] or `null`, matching is
  /// case-sensitive, so `customSet: 'abc'` rejects `A`/`B`/`C`.
  final String customSet;

  /// Whether to automatically focus the field (showing the keyboard) shortly
  /// after the widget is first built. Defaults to `true`.
  ///
  /// When `true`, focus is requested ~350ms after the first frame so a route
  /// transition animating in doesn't fight the keyboard appearing. When
  /// `false`, the field is created without focus and the user must tap on it
  /// to start typing. Only consulted at `initState` — flipping it later has
  /// no effect.
  final bool autoFocus;

  /// Called every time the typed value changes.
  ///
  /// The argument is the current sanitized text (0 to [numberOfDigits]
  /// chars; the exact set of accepted characters depends on [codeType]
  /// and [codeLetterSet]). Optional — pass `null` to ignore typing changes.
  final ValueChanged<String>? onChanged;

  /// Called once all [numberOfDigits] characters have been entered, with the typed code.
  /// The widget itself dismisses the keyboard for the duration of the [onSubmit] call.
  ///
  /// [onSubmit] is expected to do whatever verification work is required (e.g.
  /// dispatching an action) and then signal one of three outcomes:
  ///
  /// - Returns `true` on success. The field is left as-is and the owner is
  ///   expected to navigate away from the page to the next one.
  ///
  /// - Returns `false` on incorrect code. The widget shows an
  ///   "Enter the correct code" error, then automatically clears the field
  ///   and re-focuses so the user can try again.
  ///
  /// - Throws on verification failure (no internet, server error, …). The
  ///   widget shows a "Could not verify the code" error and a "Retry" button
  ///   below the digits, keeping the typed digits visible. Tapping "Retry"
  ///   resubmits the same code via [onSubmit] again.
  ///
  /// In all three failure cases the error clears automatically as soon as
  /// the user starts typing again.
  ///
  final Future<bool> Function(String code) onSubmit;

  /// Whether the countdown timer (and its eventual "code expired" view) are
  /// shown at all.
  ///
  /// When `false`, the widget never renders the "Code valid for M:SS" line
  /// below the digits nor the expired view with the [onExpiredGoBack]
  /// button — the field stays in its active "type the [numberOfDigits]
  /// characters" state forever (the wrong-code and verification-failed
  /// errors are still shown as usual). [countdownStartDateTime] and
  /// [countdownDuration] are ignored in this case. Defaults to `true`.
  final bool showCountdown;

  /// Wall-clock time the verification code was issued at, used as the countdown
  /// anchor.
  ///
  /// When `null`, the countdown is not shown and the field stays in its
  /// active state indefinitely. When set (and [showCountdown] is `true`), a
  /// countdown of [countdownDuration] runs from this timestamp; while it is
  /// running the remaining time is displayed below the digits, and once it
  /// reaches zero the field switches to the "code expired" view with the
  /// [onExpiredGoBack] button.
  final DateTime? countdownStartDateTime;

  /// How long the verification code is valid for, anchored at
  /// [countdownStartDateTime].
  ///
  /// While the countdown is running, the remaining time is rendered as
  /// "Code valid for M:SS" below the digits. When it reaches zero, the
  /// widget switches to the expired view. Ignored when [showCountdown] is
  /// `false` or [countdownStartDateTime] is `null`. Defaults to 30 minutes.
  final Duration countdownDuration;

  /// Called when the user taps the "Go back to try again" button on the
  /// expired view.
  ///
  /// The widget itself does no navigation or state mutation — the owner is
  /// responsible for whatever should happen (e.g. popping the route, clearing
  /// the failure state, requesting a fresh code).
  final VoidCallback onExpiredGoBack;

  // -----------------
  // ----- TEXTS -----
  // -----------------

  /// Whether the "Enter the correct code" message is shown below the digits
  /// after [onSubmit] returns `false`. Defaults to `true`.
  ///
  /// When `false`, the message is suppressed but the field is still cleared
  /// and re-focused as usual on a wrong-code attempt. [wrongCodeMessage] is
  /// ignored in this case.
  final bool showWrongCodeMessage;

  /// Message shown below the digits when [onSubmit] returns `false`.
  /// Defaults to `'Enter the correct code'`.
  final String wrongCodeMessage;

  /// Builds the message shown below the digits when [onSubmit] throws.
  ///
  /// The builder receives [errorMessage], which is the message extracted from
  /// the thrown error: the error itself when it is a `String`, or its
  /// `message` / `msg` field when it is an object exposing one. If neither
  /// applies, [errorMessage] is `null`.
  ///
  /// Defaults to [defaultVerificationFailedMessageBuilder], which returns
  /// `"Could not verify the code"` when the message is null or empty and
  /// `"Could not verify the code: $errorMessage"` otherwise.
  final String Function({Object? error}) verificationFailedMessageBuilder;

  /// Label of the button shown after [onSubmit] throws. Tapping it
  /// resubmits the same code via [onSubmit] again. Defaults to `'Retry'`.
  final String retryButtonLabel;

  /// Headline shown on the expired view, above the [onExpiredGoBack]
  /// button. Defaults to `'Your code expired'`.
  final String expiredMessage;

  /// Label of the button shown on the expired view. Defaults to
  /// `'Go back to try again'`.
  final String expiredButtonLabel;

  /// Builds the text shown below the digits while the countdown is running,
  /// from the remaining seconds. Defaults to [defaultCountdownText], which
  /// formats as `"Code valid for M:SS"`.
  final String Function({required int secondsCountdown}) countdownTextBuilder;

  // ----------------------
  // ----- CONTAINERS -----
  // ----------------------

  /// Builds a container for the countdown text. Defaults to
  /// [defaultCountdownContainerBuilder], which aligns to the left.
  final Widget Function({required Widget child}) countdownContainerBuilder;

  /// Builds a container for the error text (the "Enter the correct code" and
  /// "Could not verify the code" messages shown below the digits). Defaults to
  /// [defaultErrorContainerBuilder], which aligns to the left.
  final Widget Function({required Widget child}) errorContainerBuilder;

  /// Builds the container for each digit box, wrapping the digit content
  /// (typed digit, blinking cursor, or empty). Defaults to
  /// [defaultDigitContainerBuilder], which renders a 50x60 rounded rectangle
  /// with a 1px border. The border uses [activeBorderColor] when
  /// [isCurrentDigit] is `true` (the box at the current cursor position) and
  /// [borderColor] otherwise.
  final Widget Function({
    required Color? backgroundColor,
    required bool isCurrentDigit,
    required Color? activeBorderColor,
    required Color? borderColor,
    required Widget child,
  })
  digitContainerBuilder;

  // --------------------
  // ----- BUILDERS -----
  // --------------------

  /// Builder for the both the expired-button (shown when the countdown expires)
  /// and the retry-button (shown if [onSubmit] throws).
  ///
  /// Receives the onTap callback that must be invoked when the button is
  /// tapped, along with other parameters that can be used to customize the button's
  /// appearance.
  ///
  final Widget Function({
    required VoidCallback onTap,
    required String label,
    required TextStyle? textStyle,
    required Color? backgroundColor,
    required Color? textColor,
  })?
  buttonBuilder;

  // ------------------
  // ----- STYLES -----
  // ------------------

  /// Text style used for each typed digit displayed inside the digit boxes.
  ///
  /// Should include the digit color (foreground) since no separate color
  /// parameter is exposed for the digit text.
  final TextStyle? digitTextStyle;

  /// Text style used for the error message shown below the digits — both the
  /// "Enter the correct code" message after a wrong-code attempt and the
  /// "Could not verify the code" message after a verification failure.
  ///
  /// Should include the error color (typically red), since no separate color
  /// parameter is exposed for the error text.
  final TextStyle? errorTextStyle;

  /// Text style used for the "Your code expired" headline on the expired view
  /// (shown above the [onExpiredGoBack] button after the countdown reaches 0).
  final TextStyle? expiredTextStyle;

  /// Text style used for the "Code valid for M:SS" countdown line shown below
  /// the digits while the countdown is running.
  ///
  /// Should include the desired color (typically a dim/muted tone), since no
  /// separate color parameter is exposed for the countdown text.
  final TextStyle? countdownTextStyle;

  /// Text style used for both the "Go back to try again" button label on the
  /// expired view and the "Retry" button shown after a verification failure.
  /// The button's text color is overridden by [buttonTextColor], so
  /// this style mostly contributes typography (size, weight, family).
  final TextStyle? buttonTextStyle;

  /// Fill color for each digit box (the rounded rectangle behind the digit
  /// / cursor / empty state).
  final Color? digitBackgroundColor;

  /// Border color for digit boxes that are NOT at the current cursor position
  /// (i.e. boxes other than the one at index `typed.length`).
  final Color? digitBorderColor;

  /// Border color for the single digit box at the current cursor position
  /// (index `typed.length`). Used to visually highlight where the next digit
  /// will be entered.
  final Color? digitActiveBorderColor;

  /// Color of the blinking cursor drawn inside the active (next-to-fill)
  /// digit box while the user is typing.
  final Color? cursorColor;

  /// Size of the blinking cursor drawn inside the active (next-to-fill)
  /// digit box while the user is typing. Defaults to `Size(3, 30)`.
  final Size? cursorSize;

  /// Background color of the "Go back to try again" button on the expired
  /// view, also used for the "Retry" button shown after a verification
  /// failure.
  final Color? buttonBackgroundColor;

  /// Text/foreground color of the "Go back to try again" and "Retry" button
  /// labels. Applied on top of [buttonTextStyle], so it wins over any
  /// color baked into that style.
  final Color? buttonTextColor;

  /// Must be `false` for production.
  /// Debug aid: when `true`, the underlying [TextField] is rendered as a
  /// normal, visible textfield below the digit boxes (instead of being
  /// hidden behind them via the FittedBox/Stack hack), so a developer can
  /// see exactly what the textfield holds and how the input formatters
  /// behave. Defaults to `false`, which is the production layout — taps
  /// fall through the digit boxes onto the hidden textfield behind them.
  final bool debugShowTextField;

  const OtpCodeVerificationField({
    this.numberOfDigits = 6,
    this.codeType,
    this.codeLetterCasing,
    this.codeLetterSet,
    this.customSet = '',
    this.autoFocus = true,
    this.onChanged,
    required this.onSubmit,
    this.showCountdown = true,
    required this.countdownStartDateTime,
    this.countdownDuration = const Duration(minutes: 30),
    required this.onExpiredGoBack,
    this.showWrongCodeMessage = true,
    this.wrongCodeMessage = 'Enter the correct code',
    this.verificationFailedMessageBuilder = defaultVerificationFailedMessageBuilder,
    this.retryButtonLabel = 'Retry',
    this.expiredMessage = 'Your code expired',
    this.expiredButtonLabel = 'Go back to try again',
    this.countdownTextBuilder = defaultCountdownText,
    this.countdownContainerBuilder = defaultCountdownContainerBuilder,
    this.errorContainerBuilder = defaultErrorContainerBuilder,
    this.digitContainerBuilder = defaultDigitContainerBuilder,
    this.buttonBuilder,
    this.digitTextStyle,
    this.errorTextStyle,
    this.expiredTextStyle,
    this.countdownTextStyle,
    this.buttonTextStyle,
    this.digitBackgroundColor,
    this.digitBorderColor,
    this.digitActiveBorderColor,
    this.cursorColor,
    this.cursorSize = const Size(3, 30),
    this.buttonBackgroundColor,
    this.buttonTextColor,
    this.debugShowTextField = false,
    super.key,
  }) : assert(
         numberOfDigits >= 2 && numberOfDigits <= 50,
         'numberOfDigits must be in [2, 50]',
       ),
       assert(
         codeLetterSet != OtpCodeLetterSet.custom || customSet != '',
         'customSet must be non-empty when codeLetterSet is OtpCodeLetterSet.custom',
       ),
       // aToZ / unicodeLetters / custom are letter-portion sets — they
       // can't be combined with codeType=numbersOnly (no letters allowed).
       assert(
         (codeLetterSet != OtpCodeLetterSet.aToZ &&
                 codeLetterSet != OtpCodeLetterSet.unicodeLetters &&
                 codeLetterSet != OtpCodeLetterSet.custom) ||
             codeType != OtpCodeType.numbersOnly,
         'codeLetterSet aToZ / unicodeLetters / custom requires codeType '
         'to be lettersOnly, numbersAndLetters, or null',
       ),
       // binary is digits-only; codeType must be numbersOnly or null.
       assert(
         codeLetterSet != OtpCodeLetterSet.binary ||
             codeType == null ||
             codeType == OtpCodeType.numbersOnly,
         'codeLetterSet binary requires codeType to be numbersOnly or null',
       ),
       // crockford / hexadecimal / base62 mix digits and letters; codeType
       // must be numbersAndLetters or null.
       assert(
         (codeLetterSet != OtpCodeLetterSet.crockford &&
                 codeLetterSet != OtpCodeLetterSet.hexadecimal &&
                 codeLetterSet != OtpCodeLetterSet.base62) ||
             codeType == null ||
             codeType == OtpCodeType.numbersAndLetters,
         'codeLetterSet crockford / hexadecimal / base62 requires codeType '
         'to be numbersAndLetters or null',
       ),
       // base62 keeps both cases distinct; forced casing would defeat it.
       assert(
         codeLetterSet != OtpCodeLetterSet.base62 ||
             codeLetterCasing == null ||
             codeLetterCasing == OtpCodeLetterCasing.mixed,
         'codeLetterSet base62 requires codeLetterCasing to be mixed or null',
       );

  /// Default builder for [verificationFailedMessageBuilder]: returns
  /// `"Could not verify the code"` when [errorMessage] is null or empty, and
  /// `"Could not verify the code: $errorMessage"` otherwise.
  static String defaultVerificationFailedMessageBuilder({Object? error}) {
    String? errorMessage = _extractErrorMessage(error);

    if (errorMessage == null || errorMessage.isEmpty) {
      return "Could not verify the code";
    }
    return "Could not verify the code: $errorMessage";
  }

  /// Extracts a user-facing message from the [error] thrown by [onSubmit].
  /// Returns the error itself when it is a `String`, or its `message` / `msg`
  /// field when it exposes one. Returns `null` if neither applies.
  static String? _extractErrorMessage(Object? error) {
    if (error is String) return error;
    try {
      final dynamic msg = (error as dynamic).message;
      if (msg is String) return msg;
    } catch (_) {}
    try {
      final dynamic msg = (error as dynamic).msg;
      if (msg is String) return msg;
    } catch (_) {}
    return null;
  }

  /// Default formatter for [countdownTextBuilder]: produces `"Code valid for M:SS"`,
  /// where the seconds are zero-padded to 2 digits and the minutes are not padded.
  static String defaultCountdownText({required int secondsCountdown}) =>
      "Code valid for "
      "${secondsCountdown ~/ 60}:${(secondsCountdown % 60).toString().padLeft(2, '0')}";

  /// Default formatter for [countdownContainerBuilder]: simply left-aligns the text.
  static Widget defaultCountdownContainerBuilder({required Widget child}) {
    return Box(alignment: Alignment.centerLeft, child: child);
  }

  /// Default formatter for [errorContainerBuilder]: simply left-aligns the text.
  static Widget defaultErrorContainerBuilder({required Widget child}) {
    return Box(alignment: Alignment.centerLeft, child: child);
  }

  /// Default builder for [digitContainerBuilder]: a 50x60 rounded rectangle
  /// with a 1px border that switches between [activeBorderColor] and
  /// [borderColor] depending on [isCurrentDigit].
  static Widget defaultDigitContainerBuilder({
    required Color? backgroundColor,
    required bool isCurrentDigit,
    required Color? activeBorderColor,
    required Color? borderColor,
    required Widget child,
  }) {
    return Container(
      margin: const Pad(horizontal: 3.0),
      width: 50.0,
      height: 60.0,
      decoration: ShapeDecoration(
        color: backgroundColor ?? Colors.grey[200],
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: (isCurrentDigit
                ? (activeBorderColor ?? Colors.grey[400]!)
                : (borderColor ?? Colors.grey[400]!)),
            width: 1.0,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(6)),
        ),
      ),
      child: child,
    );
  }

  @override
  State<OtpCodeVerificationField> createState() => _OtpCodeVerificationFieldState();
}

/// Which characters are accepted by the [OtpCodeVerificationField].
enum OtpCodeType {
  /// Only digits 0-9.
  numbersOnly,

  /// Only letters. The exact alphabet depends on [OtpCodeLetterSet], and the
  /// casing is normalized according to [OtpCodeLetterCasing].
  lettersOnly,

  /// Digits 0-9 plus letters (subject to [OtpCodeLetterSet] and [OtpCodeLetterCasing]).
  numbersAndLetters,
}

/// How letters typed into the [OtpCodeVerificationField] are normalized.
///
/// A no-op for digits (digits are case-invariant), so picking a casing
/// alongside [OtpCodeType.numbersOnly] / [OtpCodeLetterSet.binary] has no visible
/// effect. When [codeLetterCasing] is the only param set on the widget, an
/// effective [OtpCodeLetterSet.all] is assumed (any character allowed).
enum OtpCodeLetterCasing {
  /// Letters are forced to uppercase, regardless of how they were typed.
  uppercase,

  /// Letters are forced to lowercase, regardless of how they were typed.
  lowercase,

  /// Letters are kept exactly as typed (both cases allowed).
  mixed,
}

/// Which alphabet of characters is accepted by the [OtpCodeVerificationField].
///
/// Some values are letters-portion sets that combine with [OtpCodeType] to add
/// digits (`aToZ`, `unicodeLetters`, `custom`). Others are self-contained
/// alphabets that imply both digits and letters and constrain [OtpCodeType]
/// (`binary`, `crockford`, `hexadecimal`, `base62`, `all`). See the
/// "Compatibility (asserts at construction)" section in the
/// [OtpCodeVerificationField] class doc for the full rules.
enum OtpCodeLetterSet {
  /// English ASCII letters: a-z and A-Z (26 letters).
  aToZ,

  /// Any Unicode letter (Greek, Cyrillic, CJK, etc.).
  unicodeLetters,

  /// Any character accepted by Dart.
  all,

  /// Crockford alphabet: 'ABCDEFGHJKMNPQRSTVWXYZ0123456789' which is base32
  /// without the easily-confused chars 0/O and 1/I/L.
  /// See: https://www.crockford.com/base32.html
  /// Note: A better way to implement this is for you to allow [OtpCodeLetterSet.aToZ] plus
  /// [OtpCodeType.numbersAndLetters] plus [OtpCodeLetterCasing.uppercase], and then you'd
  /// get the resulting code and convert `O` to `0`, and `I`/`L` to `1`.
  crockford,

  /// Only 0 and 1, for binary codes.
  binary,

  /// Digits 0-9 and letters A-F/a-f.
  hexadecimal,

  /// Base62 alphabet: digits 0-9, plus letters A-Z and a-z (62 chars).
  /// Useful for short URL-safe codes. Pair with [OtpCodeLetterCasing.mixed]
  /// to keep both cases distinct.
  base62,

  /// Only chars specified by the [OtpCodeVerificationField.customSet].
  /// If you specify this, you MUST provide a [customSet] string with the allowed
  /// characters, or you'll get an error.
  custom,
}

class _OtpCodeVerificationFieldState extends State<OtpCodeVerificationField> {
  //
  static const _screenWidth = 360.0;

  late final _inputFormatters = [
    //
    AlwaysAtTheEndTextInputFormatter.instance,
    //
    AllowedCharsTextInputFormatter(_buildAllowedCharsRegex()),
    //
    if (widget.codeLetterCasing == OtpCodeLetterCasing.uppercase)
      CapitalizationTextInputFormatter.uppercase,
    //
    if (widget.codeLetterCasing == OtpCodeLetterCasing.lowercase)
      CapitalizationTextInputFormatter.lowercase,
    //
    LengthLimitingTextInputFormatter(widget.numberOfDigits),
  ];

  /// Builds the single-character regex that [AllowedCharsTextInputFormatter]
  /// uses to filter input, based on [OtpCodeVerificationField.codeType],
  /// [OtpCodeVerificationField.codeLetterSet] and (when applicable)
  /// [OtpCodeVerificationField.customSet].
  RegExp _buildAllowedCharsRegex() {
    //
    final type = widget.codeType;
    final set = widget.codeLetterSet;
    final casing = widget.codeLetterCasing;

    // Both [codeType] and [codeLetterSet] omitted: shortcuts.
    //  - all three null  -> just digits 0-9.
    //  - only casing set -> any character (= OtpCodeLetterSet.all).
    if (type == null && set == null) {
      return RegExp(casing == null ? '[0-9]' : r'[\s\S]');
    }

    // Self-contained alphabets: the alphabet IS the allowed set. The
    // matching constructor asserts already guarantee [codeType] is
    // compatible. Matching is case-insensitive so the user can paste
    // either case and the casing formatter normalizes the displayed result.
    final selfContainedPattern = switch (set) {
      OtpCodeLetterSet.all => r'[\s\S]',
      OtpCodeLetterSet.binary => '[01]',
      OtpCodeLetterSet.hexadecimal => '[0-9A-F]',
      OtpCodeLetterSet.crockford =>
        '[0-9A-HJKMNP-TV-Z]', // base32: 0-9, A-Z minus I/L/O/U.
      OtpCodeLetterSet.base62 => '[0-9A-Za-z]',
      _ => null,
    };
    if (selfContainedPattern != null) {
      return RegExp(selfContainedPattern, caseSensitive: false);
    }

    // Letters-portion sets (aToZ / unicodeLetters / custom), or letterSet
    // null with codeType set. Default the letter alphabet to aToZ when
    // only [codeType] was provided.
    final effectiveSet = set ?? OtpCodeLetterSet.aToZ;

    String letters;
    bool unicode = false;
    switch (effectiveSet) {
      case OtpCodeLetterSet.aToZ:
        letters = 'a-zA-Z';
      case OtpCodeLetterSet.unicodeLetters:
        letters = r'\p{L}';
        unicode = true;
      case OtpCodeLetterSet.custom:
        letters = _escapeForCharClass(widget.customSet);
      case OtpCodeLetterSet.all ||
          OtpCodeLetterSet.binary ||
          OtpCodeLetterSet.hexadecimal ||
          OtpCodeLetterSet.crockford ||
          OtpCodeLetterSet.base62:
        throw StateError('unreachable: self-contained handled above');
    }

    // [codeType] null with letterSet set: default to lettersOnly (just
    // the letters; no implicit digits).
    final effectiveType = type ?? OtpCodeType.lettersOnly;

    final classBody = switch (effectiveType) {
      OtpCodeType.numbersOnly => '0-9',
      OtpCodeType.lettersOnly => letters,
      OtpCodeType.numbersAndLetters => '0-9$letters',
    };

    // Case-insensitive matching when casing is going to force a single case
    // anyway, so the user can paste either case and have it normalized.
    // null casing or `mixed` keep matching case-sensitive.
    return RegExp(
      '[$classBody]',
      unicode: unicode,
      caseSensitive: casing == null || casing == OtpCodeLetterCasing.mixed,
    );
  }

  /// Escapes the characters that have a special meaning inside a regex
  /// character class (`\`, `]`, `^`, `-`), so that [s] can be safely
  /// embedded between square brackets.
  static String _escapeForCharClass(String s) {
    return s.replaceAllMapped(RegExp(r'[\\\]^\-]'), (m) => '\\${m[0]}');
  }

  /// Mobile keyboard type to use for the hidden text field. Numeric keyboard
  /// when only digits are allowed (numbersOnly explicit, binary alphabet,
  /// or all params null = the implicit numbersOnly default). Otherwise the
  /// regular text keyboard.
  TextInputType get _keyboardType {
    final type = widget.codeType;
    final set = widget.codeLetterSet;
    final casing = widget.codeLetterCasing;
    if (set == OtpCodeLetterSet.binary) return TextInputType.number;
    if (type == OtpCodeType.numbersOnly) return TextInputType.number;
    if (type == null && set == null && casing == null) return TextInputType.number;
    return TextInputType.text;
  }

  late final FocusNode _focusNode;
  late final TextEditingController _controller;
  String _typed = "";

  /// True when [onSubmit] returned `false`. Drives the "Enter the correct
  /// code" message. Cleared as soon as the user types again.
  bool _isWrongCode = false;

  /// True when [onSubmit] threw. Drives the "Could not verify the code"
  /// message and the "Retry" button. Cleared as soon as the user types
  /// again, or when "Retry" is tapped.
  bool _isVerificationFailed = false;

  /// Error thrown by [onSubmit]. Passed to [widget.verificationFailedMessageBuilder]
  /// to render the failure text. Cleared alongside [_isVerificationFailed].
  Object? _verificationError;

  bool _fixingSelection = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = TextEditingController();

    _controller.addListener(() {
      if (_fixingSelection) return;

      final textLength = _controller.text.length;
      final selection = _controller.selection;

      if (!selection.isCollapsed || selection.baseOffset != textLength) {
        _fixingSelection = true;
        _controller.selection = TextSelection.collapsed(offset: textLength);
        _fixingSelection = false;
      }
    });

    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 350), () {
          if (mounted) FocusScope.of(context).requestFocus(_focusNode);
        });
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onCodeChanged(String text) {
    setState(() {
      _typed = text;
      // Guarded with `isNotEmpty` so the programmatic clear that follows a
      // wrong-code attempt doesn't wipe the error before the user sees it.
      if (text.isNotEmpty) {
        _isWrongCode = false;
        _isVerificationFailed = false;
        _verificationError = null;
      }
    });
    widget.onChanged?.call(text);
    if (text.length == widget.numberOfDigits) _submit();
  }

  Future<bool> Function(String code) get onSubmit => widget.onSubmit;

  /// Called when the user has entered all the [OtpCodeVerificationField.numberOfDigits] characters:
  /// - The keyboard is dismissed.
  /// - Submits the code to the owner via [onSubmit].
  /// - On `true`: field left as-is (caller is expected to navigate away).
  /// - On `false`: shows "Enter the correct code", clears the field and
  ///   re-focuses so the user can try again.
  /// - On throw: shows "Could not verify the code" and a "Retry" button below
  ///   the digits. The typed characters are kept so the user can re-submit
  ///   them via "Retry" (or edit them and submit again).
  Future<void> _submit() async {
    String code = _typed;
    _focusNode.unfocus();

    bool success;
    try {
      success = await widget.onSubmit(code);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isVerificationFailed = true;
        _verificationError = error;
      });
      return;
    }

    if (success || !mounted) return;

    setState(() {
      _isWrongCode = true;
    });

    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      _controller.clear();
      FocusScope.of(context).requestFocus(_focusNode);
      setState(() {
        _typed = '';
      });
    });
  }

  void _retry() {
    setState(() {
      _isVerificationFailed = false;
      _verificationError = null;
    });
    _submit();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showCountdown || widget.countdownStartDateTime == null) {
      return _activeView(context, 0, showCountdown: false);
    }
    return TimeBuilder.countdown(
      start: widget.countdownStartDateTime!,
      seconds: widget.countdownDuration.inSeconds,
      builder:
          ({
            required BuildContext context,

            /// The time of the current tick. Same as the current time (or very similar).
            required DateTime currentTickTime,

            /// The time when the [TimeBuilder] was created.
            required DateTime initialTime,

            /// The number of ticks since the timer started.
            required int ticks,

            /// This is false during the countdown, and becomes true as soon as it ends.
            required bool isFinished,

            /// Number of secs still remaining in the countdown.
            required int countdown,
          }) => Center(
            child: AnimatedBetween(
              // fadeDuration: AnimatedBetween.defaultFadeDuration * 10,
              modeShorterChild: AnimatedBetweenMode.fit,
              modeLargerChild: AnimatedBetweenMode.fit,
              child: isFinished
                  ? _yourCodeExpired(context)
                  : _activeView(context, countdown, showCountdown: true),
            ),
          ),
    );
  }

  Widget _activeView(BuildContext context, int countdown, {required bool showCountdown}) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FittedBox(
          fit: BoxFit.contain,
          child: Stack(
            children: [
              // Production layout: the hidden textfield sits behind the
              // digit boxes so taps fall through onto it. In debug mode
              // we drop it from the Stack and render a normal, visible
              // textfield below the digits instead.
              if (!widget.debugShowTextField) Positioned.fill(child: _textfield()),
              Opacity(
                opacity: 1,
                child: IgnorePointer(ignoring: true, child: _digitsRow()),
              ),
            ],
          ),
        ),
        //
        if (widget.debugShowTextField) ...[const Box.gap(8), _debugTextfield()],
        //
        const Box.gap(4),
        _footer(countdown, showCountdown),
      ],
    );
  }

  /// Visible debug variant of [_textfield]: a plain Material [TextField]
  /// that shares the same focus node, controller, formatters, and onChanged
  /// handler, but skips the hide-behind-FittedBox hacks so its content and
  /// cursor are visible. Only mounted when [OtpCodeVerificationField.debugShowTextField]
  /// is `true`.
  Widget _debugTextfield() {
    return TextField(
      focusNode: _focusNode,
      controller: _controller,
      enableInteractiveSelection: false,
      keyboardType: _keyboardType,
      textInputAction: TextInputAction.done,
      inputFormatters: _inputFormatters,
      onChanged: _onCodeChanged,
      decoration: const InputDecoration(labelText: 'debug: textfield'),
    );
  }

  Widget _footer(int countdown, bool showCountdown) => Padding(
    padding: const Pad(left: 3),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedBetween.showHide(
          fadeDuration: const Duration(milliseconds: 150),
          show: _isWrongCode && widget.showWrongCodeMessage,
          child: Padding(
            padding: const Pad(top: 6),
            child: widget.errorContainerBuilder(
              child: Text(
                widget.wrongCodeMessage,
                style: widget.errorTextStyle ?? TextStyle(color: Colors.red[700]),
              ),
            ),
          ),
        ),
        //
        if (_isVerificationFailed) _verificationFailedView(),
        //
        if (showCountdown) ...[const Box.gap(12.0), _codeValidFor(countdown)],
      ],
    ),
  );

  Widget _verificationFailedView() {
    return Box(
      padding: const Pad(top: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          widget.errorContainerBuilder(
            child: Text(
              widget.verificationFailedMessageBuilder(error: _verificationError),
              style: widget.errorTextStyle ?? TextStyle(color: Colors.red[700]),
            ),
          ),
          const Box.gap(8),
          widget.buttonBuilder?.call(
                onTap: _retry,
                label: widget.retryButtonLabel,
                textStyle: widget.buttonTextStyle,
                backgroundColor: widget.buttonBackgroundColor,
                textColor: widget.buttonTextColor,
              ) ??
              _Button(
                onTap: _retry,
                label: widget.retryButtonLabel,
                textStyle: widget.buttonTextStyle,
                backgroundColor: widget.buttonBackgroundColor,
                textColor: widget.buttonTextColor,
              ),
        ],
      ),
    );
  }

  Widget _codeValidFor(int countdown) {
    return widget.countdownContainerBuilder(
      child: Text(
        widget.countdownTextBuilder(secondsCountdown: max(0, countdown)),
        style: widget.countdownTextStyle,
      ),
    );
  }

  /// The textfield doesn't appear, as it's behind the widget with the six digits, in a
  /// Stack. The six-digit widget ignores pointers, so that if the user tries to click
  /// on it, he actually clicks on the textfield, making the textfield open.
  /// The textfield cursor doesn't appear, but its "drop" does. The drop is like a second
  /// cursor in the shape of a teardrop, which is placed in the Overlay, and therefore
  /// appears above everything. I noticed the drop is affected by the fitted box, and
  /// created a hack that uses this to hide it: Through the decoration, we make the
  /// textfield very tall vertically, and then we compress it with a FittedBox until the
  /// drop becomes so compressed that it disappears. Horizontally, we need to add a lot
  /// of space on the right, so that when the user clicks on the textfield, it always
  /// selects the end of the input (rightmost).
  Widget _textfield() {
    return FittedBox(
      fit: BoxFit.fill,
      child: Box(
        width: _screenWidth,
        child: TextField(
          focusNode: _focusNode,
          controller: _controller,
          decoration: const InputDecoration(
            contentPadding: Pad(right: 10_000, top: 10_000, bottom: 1_600),
          ),
          showCursor: false,
          style: const TextStyle(fontSize: 5),
          keyboardType: _keyboardType,
          textInputAction: TextInputAction.done,
          inputFormatters: _inputFormatters,
          onChanged: _onCodeChanged,
        ),
      ),
    );
  }

  Widget _digitsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [for (int i = 0; i < widget.numberOfDigits; i++) _digitField(i)],
    );
  }

  Widget _digitField(int index) {
    return _DigitField(
      index: index,
      controllerPosition: _typed.length,
      number: charAtPosition(_typed, index),
      backgroundColor: widget.digitBackgroundColor,
      borderColor: widget.digitBorderColor,
      activeBorderColor: widget.digitActiveBorderColor,
      cursorColor: widget.cursorColor,
      cursorSize: widget.cursorSize,
      textStyle: widget.digitTextStyle,
      digitContainerBuilder: widget.digitContainerBuilder,
    );
  }

  String? charAtPosition(String typed, int pos) =>
      (pos < 0 || pos >= typed.length) ? null : typed.substring(pos, pos + 1);

  Widget _yourCodeExpired(BuildContext context) {
    return Padding(
      padding: const Pad(top: 12, left: 3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(widget.expiredMessage, style: widget.expiredTextStyle),
          const Box.gap(12),
          widget.buttonBuilder?.call(
                onTap: widget.onExpiredGoBack,
                label: widget.expiredButtonLabel,
                textStyle: widget.buttonTextStyle,
                backgroundColor: widget.buttonBackgroundColor,
                textColor: widget.buttonTextColor,
              ) ??
              _Button(
                onTap: widget.onExpiredGoBack,
                label: widget.expiredButtonLabel,
                textStyle: widget.buttonTextStyle,
                backgroundColor: widget.buttonBackgroundColor,
                textColor: widget.buttonTextColor,
              ),
        ],
      ),
    );
  }
}

class _DigitField extends StatelessWidget {
  //
  final int? index;
  final int? controllerPosition;
  final String? number;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? activeBorderColor;
  final Color? cursorColor;
  final Size? cursorSize;
  final TextStyle? textStyle;
  final Widget Function({
    required Color? backgroundColor,
    required bool isCurrentDigit,
    required Color? activeBorderColor,
    required Color? borderColor,
    required Widget child,
  })
  digitContainerBuilder;

  const _DigitField({
    this.index,
    this.controllerPosition,
    this.number,
    required this.backgroundColor,
    required this.borderColor,
    required this.activeBorderColor,
    required this.cursorColor,
    required this.cursorSize,
    required this.textStyle,
    required this.digitContainerBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return digitContainerBuilder(
      backgroundColor: backgroundColor,
      isCurrentDigit: controllerPosition == index,
      activeBorderColor: activeBorderColor,
      borderColor: borderColor,
      child: _digitFieldContent(),
    );
  }

  Widget _digitFieldContent() {
    //
    // 1) Typed number:
    if (number != null)
      return Center(child: Text(number!, style: textStyle));
    //
    // 2) Blinking cursor for the next number:
    else if (controllerPosition == index)
      return Center(
        child: _BlinkingCursor(
          color: cursorColor ?? Colors.black54,
          child: SizedBox(
            width: cursorSize?.width ?? 3,
            height: cursorSize?.height ?? 30,
          ),
        ),
      );
    //
    // 3) Following digits, empty.
    else
      return const Box();
  }
}

class _Button extends StatelessWidget {
  //
  final String label;
  final VoidCallback? onTap;
  final Color? textColor, backgroundColor;

  final TextStyle? textStyle;

  const _Button({
    required this.label,
    this.onTap,
    this.textColor,
    this.backgroundColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        visualDensity: VisualDensity.standard,
        minimumSize: const Size(92, 40),
        padding: const Pad(vertical: 10, horizontal: 24),
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
      ),
      onPressed: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              key: ValueKey(label),
              label,
              style: textStyle,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Blinks if [ifBlinks]. If not, still applies topPadding, alignment, etc.
class _BlinkingCursor extends StatefulWidget {
  //
  final bool ifBlinks;

  final Color color;

  final int millisDuration;

  final Widget? child;

  final bool sizeToChild;

  final double? topPadding;

  final AlignmentGeometry alignment;

  const _BlinkingCursor({
    this.ifBlinks = true,
    this.color = const Color(0x55555555),
    this.millisDuration = 250,
    this.child,
    this.sizeToChild = false,
    this.topPadding,
    this.alignment = Alignment.centerLeft,
  });

  @override
  BlinkingCursorState createState() => BlinkingCursorState();
}

class BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  Timer? timer;

  @override
  void initState() {
    super.initState();
    if (widget.ifBlinks) _turnOnTimer();
  }

  void _turnOnTimer() {
    timer = Timer.periodic(Duration(milliseconds: widget.millisDuration), (_) {
      setState(() {});
    });
  }

  void _turnOffTimer() {
    timer?.cancel();
  }

  @override
  void didUpdateWidget(_BlinkingCursor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.ifBlinks && !oldWidget.ifBlinks) _turnOnTimer();
    if (!widget.ifBlinks && oldWidget.ifBlinks) _turnOffTimer();
  }

  @override
  void dispose() {
    _turnOffTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //
    Widget? child = widget.child;

    if (widget.topPadding != null || widget.ifBlinks)
      child = Box(
        padding: widget.topPadding == null ? null : Pad(top: widget.topPadding!),
        color: widget.ifBlinks ? (timer!.tick % 2 == 1 ? null : widget.color) : null,
        child: widget.child,
      );

    if (widget.sizeToChild)
      return Align(
        alignment: widget.alignment,
        widthFactor: 1.0,
        heightFactor: 1.0,
        child: child,
      );
    else
      return child ?? const SizedBox.shrink();
  }
}
