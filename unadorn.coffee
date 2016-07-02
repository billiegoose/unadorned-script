readline = require('readline')

rl = readline.createInterface({
  input: process.stdin
})

prevline = ""
currline = ""

rl.on('line', (nextline) ->
  for rule in rules
    currline = rule(prevline, currline, nextline)

  console.log(currline)
  prevline = currline
  currline = nextline
)
rl.on('close', () ->
  console.log(currline)
  while brace_stack.length > 0
    console.log brace_stack.shift().char

)
brace_stack = []

rules = [
  # CoffeeScript comments
  (p, x, n) -> x.replace(/([^"'])#(.*)$/, '$1//$2')
  # CoffeeScript lambda functions
  (p, x, n) -> x.replace(/(\([\w, ]*\)) -> (.+)/, "function $1 { $2 }")
  # CoffeeScript functions
  (p, x, n) -> x.replace(/(\([\w, ]*\)) ->$/, "function $1 ***")
  # CoffeeScript function expressions
  (p, x, n) -> x.replace(/([\w]+) = function \((.*)$/, "function $1 ($2")
  # CoffeeScript for loop
  (p, x, n) -> x.replace(/^(\s*for) (.+)$/, "$1 ($2) ***")
  # CoffeeScript if statement
  (p, x, n) -> x.replace(/^(\s*if) (.+)$/, "$1 ($2) ***")
  # CoffeeScript while statement
  (p, x, n) -> x.replace(/^(\s*while) (.+)$/, "$1 ($2) ***")
  # CoffeeScript and operator
  (p, x, n) -> x.replace(/ and /, " && ")
  # CoffeeScript or operator
  (p, x, n) -> x.replace(/ or /, " || ")
  # CoffeeScript is operator
  (p, x, n) -> x.replace(/ is /, " === ")
  # CoffeeScript not operator
  (p, x, n) -> x.replace(/ not /, " !")
  # CoffeeScript isnt operator
  (p, x, n) -> x.replace(/ isnt /, " !== ")
  # Open curly braces
  (p, x, n) ->
    if x.endsWith('***')
      x = x.replace(/\*\*\*$/, '{')
      brace_stack.unshift({
        indent: I(x)
        char: '}'
      })

    return x

  # Close curly braces
  (p, x, n) ->
    if x.match(/^[ \)]*$/)
      if brace_stack.length > 0 and I(n) <= brace_stack[0].indent
        b = brace_stack.shift()
        x = indent(b.indent) + b.char + x.trim()


    return x

]

indent = (n) ->
  str = ''
  for i in [0...n]
    str += '  '

  return str


I = (line) ->
  return line.replace(/\S.*/,'').length / 2
