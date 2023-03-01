local function scan(source, rules)
  local current_index = 1
  local last_matching_at = 0
  local function at_eof_3f()
    return (current_index > string.len(source))
  end
  local function advance(n)
    current_index = (current_index + n)
    return nil
  end
  local function yield_nonmatching()
    if (0 < (current_index - last_matching_at)) then
      local nonmatching = string.sub(source, (last_matching_at + 1), (current_index - 1))
      return coroutine.yield("nonmatching", nonmatching)
    else
      return nil
    end
  end
  local function yield_and_advance(class, matched)
    yield_nonmatching()
    coroutine.yield(class, matched)
    advance(string.len(matched))
    last_matching_at = (current_index - 1)
    return nil
  end
  local function test_rules(rules0)
    local matching_rule = nil
    for _, _2_ in ipairs(rules0) do
      local _each_3_ = _2_
      local class = _each_3_[1]
      local pattern = _each_3_[2]
      if matching_rule then break end
      local _4_ = string.match(source, pattern, current_index)
      if (nil ~= _4_) then
        local str = _4_
        matching_rule = {class, str}
      else
        matching_rule = nil
      end
    end
    return matching_rule
  end
  while not at_eof_3f() do
    local _6_ = test_rules(rules)
    if ((_G.type(_6_) == "table") and (nil ~= (_6_)[1]) and (nil ~= (_6_)[2])) then
      local class = (_6_)[1]
      local str = (_6_)[2]
      yield_and_advance(class, str)
    elseif true then
      local _ = _6_
      advance(1)
    else
    end
  end
  return yield_nonmatching()
end
local function token__3ehtml(class, value)
  local escaped_value = string.gsub(string.gsub(value, "&", "&amp;"), "<", "&lt;")
  return string.format("<span class=\"%s\">%s</span>", class, escaped_value)
end
local fennel_rules
do
  local symbol_char = "!%$&#%*%+%-%./:<=>%?%^_%w"
  fennel_rules = {{"comment", "^(;[^\n]*[\n])"}, {"string", "^(\"\")"}, {"string", "^(\".-[^\\]\")"}, {"keyword", ("^(:[" .. symbol_char .. "]+)")}, {"number", "^([%+%-]?%d+[xX]?%d*%.?%d?)"}, {"nil", ("^(nil)[^" .. symbol_char .. "]")}, {"boolean", ("^(true)[^" .. symbol_char .. "]")}, {"boolean", ("^(false)[^" .. symbol_char .. "]")}, {"symbol", ("^([" .. symbol_char .. "]+)")}, {"bracket", "^([%(%)%[%]{}])"}}
end
local function fennel__3ehtml(syntax, source)
  local tbl_17_auto = {}
  local i_18_auto = #tbl_17_auto
  local function _8_()
    return scan(source, fennel_rules)
  end
  for class, value in coroutine.wrap(_8_) do
    local val_19_auto
    do
      local extra
      do
        local _9_ = syntax[value]
        if ((_G.type(_9_) == "table") and ((_9_)["special?"] == true)) then
          extra = "special"
        elseif ((_G.type(_9_) == "table") and ((_9_)["macro?"] == true)) then
          extra = "macro"
        elseif ((_G.type(_9_) == "table") and ((_9_)["global?"] == true)) then
          extra = "global"
        else
          extra = nil
        end
      end
      local class_2a
      if extra then
        class_2a = (class .. " " .. extra)
      else
        class_2a = class
      end
      val_19_auto = token__3ehtml(class_2a, value)
    end
    if (nil ~= val_19_auto) then
      i_18_auto = (i_18_auto + 1)
      do end (tbl_17_auto)[i_18_auto] = val_19_auto
    else
    end
  end
  return tbl_17_auto
end
return {["fennel->html"] = fennel__3ehtml, fennel_to_html = fennel__3ehtml}
