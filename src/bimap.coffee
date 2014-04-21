class BiMap
  klength: 0
  vlength: 0
  kindex: 0
  constructor: (A) ->
    @kv = {}
    @vk = {}
    if A?
      for k, v of A
        @push k, v
  push: (k, v) ->
    @insert k, v, "push"
  appendKey: (k, v) ->
    @insert k, v, "appendKey"
  appendVal: (k, v) ->
    @insert k, v, "appendVal"
  set: (k, v) ->
    @insert k, v, "set"
  type: (a) ->
    t = typeof a
    return "NaN"  if t is "number" and a isnt a
    return t  unless t is "object"
    t = toString.call a
    return "object"  if t is "[object Object]"
    return "array"  if t is "[object Array]"
    return "boolean"  if t is "[object Boolean]"
    return "null"  if t is "[object Null]"
  _assign: (k, v, type = "push", reverse = false) ->
    @kindex++  if k > @kindex
    console.log k, v, type, reverse, @kindex
    dir = if reverse then "vk" else "kv"
    if type is "push"
      unless @[dir][k]?
        #console.log dir, k, v
        @[dir][k] = v
        #console.log @kv
        #console.log @vk
        return true
      else
        return @error "#{dir} mapping for #{k} already exists"
    else if type is "appendVal"
      if reverse
        if @vk[k]?
          if "array" isnt @type @vk[k]
            @vk[k] = [@vk[k]]
          @vk[k][if @type(v) is "array" then "concat" else "push"] v
        else
          @vk[k] = v
        return true
      unless @kv[k]?
        @kv[k] = []
      else if "array" isnt @type @kv[k]
        @kv[k] = [@kv[k]]
      @kv[k][if @type(v) is "array" then "concat" else "push"] v
      if "array" is @type v
        for i in v
          @kv[k].push i
      return true
    else if type is "set"
      @[dir][k] = v
      return true
  insert: (k, v, type = "push") ->
    console.log "insert", k, v, type
    return @error "At least one argument required by insert()"  unless k?
    ktype = @type k
    unless v?
      if "array" is @type k
        return (for v in k
          @insert ++@kindex - 1, v, type
        )
      else if "object" is @type k
        return @traverse k, ((v, path) ->
          @insert path, v, type
        ).bind @
      else
        return @insert ++@kindex - 1, k, type
    else if @type(k) is "number" and k > @kindex
      @kindex = k + 1
    vtype = @type v
    if vtype is "object"
      return @traverse v, ((v, path) ->
        console.log "trcb", k, path, v
        @insert "#{k}.#{path}", v, type
      ).bind @
    else if vtype is "array"
      if ktype is "array"
        @insertArray v, k, type, true
      return @insertArray k, v, type
    else if ktype is "array"
      return @insertArray v, k, type, true
    else
      @_assign v, k, type, true
      return @_assign k, v, type
  insertArray: (k, array, type = "push", reverse = false) ->
    @_assign k, array, type, reverse
    r = for i in array
      @_assign i, k, type, !reverse
    for i in r
      return false  unless i
    true
  traverse: (obj, cb) ->
    path = arguments[2] or ""
    console.log obj
    if "object" is @type obj
      for k, v of obj
        console.log "tr", k, v, path
        npath = path
        npath += "."  if path.length > 0
        npath += k
        @traverse v, cb, npath
    else
      cb obj, path
  error: ->
    false
  remove: (k) ->
    delete @vk[@kv[k]]
    delete @kv[k]
  removeVal: (v) ->
    delete @kv[@vk[v]]
    delete @vk[v]
  key: (k) ->
    @kv[k]
  val: (v) ->
    @vk[v]
!module? or module.exports = BiMap