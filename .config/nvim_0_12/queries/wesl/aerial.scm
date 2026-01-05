(struct_decl
  name: (identifier) @name
  (#set! "kind" "Struct")) @symbol

(function_decl
  (function_header
      name: (identifier) @name)
  (#set! "kind" "Function")) @symbol

(global_variable_decl
  (variable_decl
      name: (identifier) @name)
  (#set! "kind" "Class")) @symbol


