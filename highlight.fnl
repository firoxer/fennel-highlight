(fn scan [text]
  (var current-index 1)
  (var last-matching-at 0)

  (local text-length (string.len text))
  (fn at-eof? []
    (> current-index text-length))

  (fn yield-buffered-nonmatching []
    (when (< 0 (- current-index last-matching-at))
      (coroutine.yield {:kind nil
                        :value (string.sub text
                                           (+ last-matching-at 1)
                                           (- current-index 1))})))

  (fn yield [kind matched]
    (yield-buffered-nonmatching)
    (coroutine.yield {:kind kind :value matched})
    (set current-index (+ current-index (string.len matched)))
    (set last-matching-at (- current-index 1)))

  (fn attempt-match [kind pattern]
    (case (string.match text pattern current-index)
      matched (do (yield kind matched)
                  true))) ; To signal success

  (fn increment-current-index []
    (set current-index (+ current-index 1)))

  (local symbol-char "!%$&#%*%+%-%./:<=>%?%^_%w")

  (while (not (at-eof?))
    (or (attempt-match :comment "^(;[^\n]*[\n])")
        (attempt-match :string "^(\"[^\"]*\")")
        (attempt-match :keyword (.. "^(:[" symbol-char "]+)"))
        (attempt-match :number "^([%+%-]?%d+[xX]?%d*%.?%d?)")
        (attempt-match :nil (.. "^(nil)[^" symbol-char "]"))
        (attempt-match :boolean (.. "^(true)[^" symbol-char "]"))
        (attempt-match :boolean (.. "^(false)[^" symbol-char "]"))
        (attempt-match :symbol (.. "^([" symbol-char "]+)"))
        (attempt-match :bracket "^([%(%)%[%]{}])")
        (increment-current-index)))
  (yield-buffered-nonmatching))

(fn with-symbol-subkind [syntax {&as token : kind : value}]
  (when (= :symbol kind)
    (set token.subkind (case (. syntax value)
                         {:special? true} :special-symbol
                         {:macro? true} :macro-symbol
                         {:global? true} :global-symbol)))
  token)

(fn token->html [{: kind : subkind : value}]
  (let [class (.. (or kind "nonmatching") " " (or subkind ""))
        escaped-value (-> value
                          (string.gsub "&" "&amp;")
                          (string.gsub "<" "&lt;"))]
    (.. "<span class=\"" class "\">" escaped-value "</span>")))

(fn for-html [syntax code]
  (let [tokens (icollect [token (coroutine.wrap #(scan (.. code "\n")))]
                 (->> token
                      (with-symbol-subkind syntax)
                      token->html))]
    (table.concat tokens)))

{: for-html :for_html for-html}
