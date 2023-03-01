(fn scan [source rules]
  (var current-index 1)
  (var last-matching-at 0)

  (fn at-eof? []
    (> current-index (string.len source)))

  (fn advance [n]
    (set current-index (+ current-index n)))

  (fn yield-nonmatching []
    (if (< 0 (- current-index last-matching-at))
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

(fn token->html [class value]
  (let [escaped-value (-> value
                        (string.gsub "&" "&amp;")
                        (string.gsub "<" "&lt;"))]
    (string.format "<span class=\"%s\">%s</span>" class escaped-value)))

(local fennel-rules
  (let [symbol-char "!%$&#%*%+%-%./:<=>%?%^_%w"]
    [[:comment "^(;[^\n]*[\n])"]
     [:string "^(\"\")"]
     [:string "^(\".-[^\\]\")"]
     [:keyword (.. "^(:[" symbol-char "]+)")]
     [:number "^([%+%-]?%d+[xX]?%d*%.?%d?)"]
     [:nil (.. "^(nil)[^" symbol-char "]")]
     [:boolean (.. "^(true)[^" symbol-char "]")]
     [:boolean (.. "^(false)[^" symbol-char "]")]
     [:symbol (.. "^([" symbol-char "]+)")]
     [:bracket "^([%(%)%[%]{}])"]]))

(fn fennel->html [syntax source]
  (icollect [class value (coroutine.wrap #(scan source fennel-rules))]
    (let [extra (case (. syntax value)
                  {:special? true} :special
                  {:macro? true} :macro
                  {:global? true} :global)
          class* (if extra
                   (.. class " " extra)
                   class)]
      (token->html class* value))))

{: fennel->html
 :fennel_to_html fennel->html}
