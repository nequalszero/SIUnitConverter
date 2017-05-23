# README
## Brainstorming
For unit strings with parenthesis:

(a*b/(c*d)) * (a/b)

parenthesis: [0, 5, 9, 10, 12, 16]
operators: [2, 4, 7, 11, 14]
open_parens: [0, 5]
paren_groups: [[0, 10], [5, 9], [12, 16]]

0-10: parse(1-9)
  1-9: a*b/parse(5-9)

a*b/
