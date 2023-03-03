(fn scan [source rules]
  (var current-index 1)
  (var last-matching-at -1)

  (fn at-eof? []
    (> current-index (string.len source)))

  (fn advance [n]
    (set current-index (+ current-index n)))

  (fn yield-nonmatching []
    (if (> current-index (+ 1 last-matching-at))
        (let [nonmatching (string.sub source
                                      (+ last-matching-at 1)
                                      (- current-index 1))]
          (coroutine.yield :nonmatching nonmatching))))

  (fn yield-and-advance [class matched]
    (yield-nonmatching)
    (coroutine.yield class matched)
    (advance (string.len matched))
    (set last-matching-at (- current-index 1)))

  (fn test-rules [rules]
    (accumulate [matching-rule nil
                 _ [class pattern] (ipairs rules)
                 &until matching-rule]
      (case (string.match source pattern current-index)
        str [class str])))

  (while (not (at-eof?))
    (case (test-rules rules)
      [class str] (yield-and-advance class str)
      _ (advance 1)))
  (yield-nonmatching)) ; To release any final characters

(fn ->html [syntax rules source]
  (icollect [class value (coroutine.wrap #(scan source rules))]
    (let [extra (if (= :symbol class)
                    (case (. syntax value)
                      {:special? true} :special
                      {:macro? true} :macro
                      {:global? true} :global))
          extended-class (if extra
                             (.. class " " extra)
                             class)
          escaped-value (-> value
                        (string.gsub "&" "&amp;")
                        (string.gsub "<" "&lt;"))]
      (string.format "<span class=\"%s\">%s</span>" extended-class escaped-value))))

(local fennel-rules
  (let [symbol-char "!%$&#%*%+%-%./:<=>%?%^_a-zA-Z0-9"]
    [[:comment "^(;[^\n]*[\n])"]
     [:string "^(\"\")"]
     [:string "^(\".-[^\\]\")"]
     [:keyword (.. "^(:[" symbol-char "]+)")]
     [:number "^([%+%-]?%d+[xX]?%d*%.?%d?)"]
     [:nil (.. "^(nil)[^" symbol-char "]")]
     [:boolean (.. "^(true)[^" symbol-char "]")]
     [:boolean (.. "^(false)[^" symbol-char "]")]
     [:symbol (.. "^([" symbol-char "]+)")]
     [:bracket "^([%(%)%[%]{}])"]
     [:whitespace "^([ \n\t]+)"]]))

(fn fennel->html [syntax source]
  (->html syntax fennel-rules source))

(local lua-keywords [:and :break :do :else :elseif :end :for :function :goto :if
                     :in :local :not :or :repeat :return :then :until :while])

(fn fennel-syntax->lua-syntax [fennel-syntax]
  (local lua-syntax {})
  (collect [k v (pairs fennel-syntax) &into lua-syntax]
    (if (or v.global? v.special?)
        (values k v)))
  (collect [_ k (ipairs lua-keywords) &into lua-syntax]
    (values k {:special? true}))
  lua-syntax)

(local lua-rules
  (let [symbol-char-first "a-zA-Z_"
        symbol-char-rest (.. symbol-char-first "0-9%.")]
    [[:comment "^(%-%-%[===%[.-]===])"]
     [:comment "^(%-%-%[==%[.-]==])"]
     [:comment "^(%-%-%[=%[.-]=])"]
     [:comment "^(%-%-%[%[.-]])"]
     [:comment "^(%-%-[^\n]*[\n])"]
     [:string "^(\"\")"]
     [:string "^(%[%[.-]])"]
     [:string "^(\".-[^\\]\")"]
     [:string "^('.-[^\\]')"]
     [:number "^(0[xX][0-9a-fA-F]?%.[0-9a-fA-F]+[eE][+-]?[0-9]?)"]
     [:number "^(0[xX][0-9a-fA-F]+[eE][+-]?[0-9]?)"]
     [:number "^(0[xX][0-9a-fA-F]?%.[0-9a-fA-F]+)"]
     [:number "^(0[xX][0-9a-fA-F]+)"]
     [:number "^([0-9]?%.[0-9]+[eE][+-]?[0-9]?)"]
     [:number "^([0-9]+[eE][+-]?[0-9]?)"]
     [:number "^([0-9]?%.[0-9]+)"]
     [:number "^([0-9]+)"]
     [:nil (.. "^(nil)[^" symbol-char-rest "]")]
     [:boolean (.. "^(true)[^" symbol-char-rest "]")]
     [:boolean (.. "^(false)[^" symbol-char-rest "]")]
     [:symbol (.. "^([" symbol-char-first "][" symbol-char-rest "]*)")]
     [:symbol "^(<=)"]
     [:symbol "^(>=)"]
     [:symbol "^(==)"]
     [:symbol "^(~=)"]
     [:symbol "^(%.%.)"]
     [:symbol "^([%+%-%*/%^<>=#])"]
     [:bracket "^([%(%)%[%]{}])"]
     [:whitespace "^([ \n\t]+)"]]))

(fn lua->html [syntax source]
  (->html (fennel-syntax->lua-syntax syntax)
          lua-rules
          source))

{: fennel->html
 :fennel_to_html fennel->html
 : lua->html
 :lua_to_html lua->html}
