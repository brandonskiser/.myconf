(struct_declaration
  name: (identifier) @name
  (#set! "kind" "Struct")) @symbol

(function_declaration
  name: (identifier) @name
  (#set! "kind" "Function")) @symbol

(global_variable_declaration
  (variable_declaration
    (variable_identifier_declaration
      name: (identifier) @name))
  (#set! "kind" "Class")) @symbol

