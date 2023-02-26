local function scan(text)
  local current_index = 1
  local last_matching_at = 0
  local text_length = string.len(text)
  local function at_eof_3f()
    return (current_index > text_length)
  end
  local function yield_buffered_nonmatching()
    if (0 < (current_index - last_matching_at)) then
      return coroutine.yield({kind = nil, value = string.sub(text, (last_matching_at + 1), (current_index - 1))})
    else
      return nil
    end
  end
  local function yield(kind, matched)
    yield_buffered_nonmatching()
    coroutine.yield({kind = kind, value = matched})
    current_index = (current_index + string.len(matched))
    last_matching_at = (current_index - 1)
    return nil
  end
  local function attempt_match(kind, pattern)
    local _2_ = string.match(text, pattern, current_index)
    if (nil ~= _2_) then
      local matched = _2_
      yield(kind, matched)
      return true
    else
      return nil
    end
  end
  local function increment_current_index()
    current_index = (current_index + 1)
    return nil
  end
  local symbol_char = "!%$&#%*%+%-%./:<=>%?%^_%w"
  while not at_eof_3f() do
    do local _ = (attempt_match("comment", "^(;[^\n]*[\n])") or attempt_match("string", "^(\"[^\"]*\")") or attempt_match("keyword", ("^(:[" .. symbol_char .. "]+)")) or attempt_match("number", "^([%+%-]?%d+[xX]?%d*%.?%d?)") or attempt_match("nil", ("^(nil)[^" .. symbol_char .. "]")) or attempt_match("boolean", ("^(true)[^" .. symbol_char .. "]")) or attempt_match("boolean", ("^(false)[^" .. symbol_char .. "]")) or attempt_match("symbol", ("^([" .. symbol_char .. "]+)")) or attempt_match("bracket", "^([%(%)%[%]{}])") or increment_current_index()) end
  end
  return yield_buffered_nonmatching()
end
local function with_symbol_subkind(syntax, _4_)
  local _arg_5_ = _4_
  local token = _arg_5_
  local kind = _arg_5_["kind"]
  local value = _arg_5_["value"]
  if ("symbol" == kind) then
    local _6_ = syntax[value]
    if ((_G.type(_6_) == "table") and ((_6_)["special?"] == true)) then
      token.subkind = "special-symbol"
    elseif ((_G.type(_6_) == "table") and ((_6_)["macro?"] == true)) then
      token.subkind = "macro-symbol"
    elseif ((_G.type(_6_) == "table") and ((_6_)["global?"] == true)) then
      token.subkind = "global-symbol"
    else
      token.subkind = nil
    end
  else
  end
  return token
end
local function token__3ehtml(_9_)
  local _arg_10_ = _9_
  local kind = _arg_10_["kind"]
  local subkind = _arg_10_["subkind"]
  local value = _arg_10_["value"]
  local class = ((kind or "nonmatching") .. " " .. (subkind or ""))
  local escaped_value = string.gsub(string.gsub(value, "&", "&amp;"), "<", "&lt;")
  return ("<span class=\"" .. class .. "\">" .. escaped_value .. "</span>")
end
local function for_html(syntax, code)
  local tokens
  do
    local tbl_17_auto = {}
    local i_18_auto = #tbl_17_auto
    local function _11_()
      return scan((code .. "\n"))
    end
    for token in coroutine.wrap(_11_) do
      local val_19_auto = token__3ehtml(with_symbol_subkind(syntax, token))
      if (nil ~= val_19_auto) then
        i_18_auto = (i_18_auto + 1)
        do end (tbl_17_auto)[i_18_auto] = val_19_auto
      else
      end
    end
    tokens = tbl_17_auto
  end
  return table.concat(tokens)
end
return {["for-html"] = for_html, for_html = for_html}
