;; extends

(
  (script_element
    (start_tag
      (attribute
        (attribute_name) @_type
        (quoted_attribute_value (attribute_value) @_javascript)))
    (raw_text) @javascript)
  (#eq? @_type "type")
  (#eq? @_javascript "module")
)
