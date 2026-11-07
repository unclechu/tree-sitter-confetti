// Confetti 1.0 core grammar. Meaning is assigned by each Confetti application.
// Newlines are significant, so they must not be part of `extras`.

module.exports = grammar({
  name: 'confetti',

  extras: $ => [
    /[ \t\u00a0\u1680\u2000-\u200a\u202f\u205f\u3000]+/,
    $.comment,
    $._line_continuation,
  ],

  externals: $ => [
    $.quoted_string,
    $.triple_quoted_string,
  ],

  conflicts: $ => [[$.simple_directive, $.block_directive]],

  rules: {
    source_file: $ => repeat(choice($.directive, $._newline)),

    directive: $ => choice($.simple_directive, $.block_directive),

    simple_directive: $ => prec.right(seq(
      field('name', $._argument),
      repeat(field('argument', $._argument)),
      optional(choice(';', $._newline)),
    )),

    block_directive: $ => seq(
      field('name', $._argument),
      repeat(field('argument', $._argument)),
      repeat($._newline),
      field('body', $.block),
      optional(';'),
    ),

    block: $ => seq('{', repeat(choice($.directive, $._newline)), '}'),

    _argument: $ => choice($.bare_argument, $.quoted_string, $.triple_quoted_string),

    bare_argument: $ => token(repeat1(choice(
      /[^\s"#;{}\\]+/,
      /\\[^\s]/,
    ))),

    comment: $ => token(/#[^\n\r\v\f\u0085\u2028\u2029]*/),

    _newline: $ => token(/\r\n|[\n\r\v\f\u0085\u2028\u2029]/),

    _line_continuation: $ => token(seq('\\', /\r\n|[\n\r\v\f\u0085\u2028\u2029]/)),
  },
});
