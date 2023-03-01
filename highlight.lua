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
local function __3ehtml(syntax, rules, source)
  local tbl_17_auto = {}
  local i_18_auto = #tbl_17_auto
  local function _8_()
    return scan(source, rules)
  end
  for class, value in coroutine.wrap(_8_) do
    local val_19_auto
    do
      local extra
      if ("symbol" == class) then
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
      else
        extra = nil
      end
      local extended_class
      if extra then
        extended_class = (class .. " " .. extra)
      else
        extended_class = class
      end
      local escaped_value = string.gsub(string.gsub(value, "&", "&amp;"), "<", "&lt;")
      val_19_auto = string.format("<span class=\"%s\">%s</span>", extended_class, escaped_value)
    end
    if (nil ~= val_19_auto) then
      i_18_auto = (i_18_auto + 1)
      do end (tbl_17_auto)[i_18_auto] = val_19_auto
    else
    end
  end
  return tbl_17_auto
end
local fennel_rules
do
  local symbol_char = "!%$&#%*%+%-%./:<=>%?%^_a-zA-Z0-9"
  fennel_rules = {{"comment", "^(;[^\n]*[\n])"}, {"string", "^(\"\")"}, {"string", "^(\".-[^\\]\")"}, {"keyword", ("^(:[" .. symbol_char .. "]+)")}, {"number", "^([%+%-]?%d+[xX]?%d*%.?%d?)"}, {"nil", ("^(nil)[^" .. symbol_char .. "]")}, {"boolean", ("^(true)[^" .. symbol_char .. "]")}, {"boolean", ("^(false)[^" .. symbol_char .. "]")}, {"symbol", ("^([" .. symbol_char .. "]+)")}, {"bracket", "^([%(%)%[%]{}])"}}
end
local function fennel__3ehtml(syntax, source)
  return __3ehtml(syntax, fennel_rules, source)
end
local lua_keywords = {"and", "break", "do", "else", "elseif", "end", "for", "function", "goto", "if", "in", "local", "not", "or", "repeat", "return", "then", "until", "while"}
local function fennel_syntax__3elua_syntax(fennel_syntax)
  local lua_syntax = {}
  do
    local tbl_14_auto = lua_syntax
    for k, v in pairs(fennel_syntax) do
      local k_15_auto, v_16_auto = nil, nil
      if v["global?"] then
        k_15_auto, v_16_auto = k, v
      else
        k_15_auto, v_16_auto = nil
      end
      if ((k_15_auto ~= nil) and (v_16_auto ~= nil)) then
        tbl_14_auto[k_15_auto] = v_16_auto
      else
      end
    end
  end
  do
    local tbl_14_auto = lua_syntax
    for _, k in ipairs(lua_keywords) do
      local k_15_auto, v_16_auto = k, {["special?"] = true}
      if ((k_15_auto ~= nil) and (v_16_auto ~= nil)) then
        tbl_14_auto[k_15_auto] = v_16_auto
      else
      end
    end
  end
  return lua_syntax
end
local lua_rules
do
  local symbol_char_first = "a-zA-Z_"
  local symbol_char_rest = (symbol_char_first .. "0-9")
  lua_rules = {{"comment", "^(%-%-[^\n]*[\n])"}, {"string", "^(\"\")"}, {"string", "^(\".-[^\\]\")"}, {"number", "^([%+%-]?%d+[xX]?%d*%.?%d?)"}, {"nil", ("^(nil)[^" .. symbol_char_rest .. "]")}, {"boolean", ("^(true)[^" .. symbol_char_rest .. "]")}, {"boolean", ("^(false)[^" .. symbol_char_rest .. "]")}, {"symbol", ("^([" .. symbol_char_first .. "][" .. symbol_char_rest .. "]*)")}, {"bracket", "^([%(%)%[%]{}])"}}
end
local function lua__3ehtml(syntax, source)
  return __3ehtml(fennel_syntax__3elua_syntax(syntax), lua_rules, source)
end
return {["fennel->html"] = fennel__3ehtml, fennel_to_html = fennel__3ehtml, ["lua->html"] = lua__3ehtml, lua_to_html = lua__3ehtml}
