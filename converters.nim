converter toWideCString*(s: string):WideCString =
  return newWideCString(s)

#template enumToInt*(typ: expr): stmt =
#  converter toUint32*(x: typ): uint32 =
#    return uint32(x)

template enumToInt*(typ: untyped): void =
  converter toUint32*(x: typ): uint32 =
    return uint32(x)
    
#xbehavior
enumToInt(EVENT_GROUPS)
enumToInt(PHASE_MASK)
enumToInt(MOUSE_BUTTONS)
enumToInt(KEYBOARD_STATES)
enumToInt(INITIALIZATION_EVENTS)
enumToInt(DRAGGING_TYPE)
enumToInt(MOUSE_EVENTS)
enumToInt(CURSOR_TYPE)
enumToInt(KEY_EVENTS)
enumToInt(FOCUS_EVENTS)
enumToInt(SCROLL_EVENTS)
enumToInt(SCROLL_SOURCE)
enumToInt(SCROLLBAR_PART)
enumToInt(GESTURE_CMD)
enumToInt(GESTURE_STATE)
enumToInt(GESTURE_TYPE_FLAGS)
enumToInt(EXCHANGE_CMD)
enumToInt(DD_MODES)
enumToInt(DRAW_EVENTS)
enumToInt(CONTENT_CHANGE_BITS)
enumToInt(BEHAVIOR_EVENTS)
enumToInt(CLICK_REASON)
enumToInt(EDIT_CHANGED_REASON)
enumToInt(BEHAVIOR_METHOD_IDENTIFIERS)
#xdef
enumToInt(SC_LOAD_DATA_RETURN_CODES)
enumToInt(SCRIPT_RUNTIME_FEATURES)
enumToInt(GFX_LAYER)
enumToInt(SCITER_RT_OPTIONS)
enumToInt(SCITER_CREATE_WINDOW_FLAGS)
enumToInt(OUTPUT_SUBSYTEMS)
enumToInt(OUTPUT_SEVERITY)
#xdom
enumToInt(ELEMENT_AREAS)
enumToInt(SCITER_SCROLL_FLAGS)
enumToInt(SET_ELEMENT_HTML)
enumToInt(ELEMENT_STATE_BITS)
enumToInt(CTL_TYPE)
enumToInt(NODE_TYPE)
enumToInt(NODE_INS_TARGET)
#xgraphics
enumToInt(GRAPHIN_RESULT)
enumToInt(DRAW_PATH_MODE)
enumToInt(SCITER_LINE_JOIN_TYPE)
enumToInt(SCITER_LINE_CAP_TYPE)
enumToInt(SCITER_TEXT_ALIGNMENT)
enumToInt(SCITER_TEXT_DIRECTION)
# xrequest
enumToInt(REQUEST_RESULT)
enumToInt(REQUEST_RQ_TYPE)
enumToInt(SciterResourceType)
enumToInt(REQUEST_STATE)
#xvalue
enumToInt(VALUE_RESULT)
enumToInt(VTYPE)
enumToInt(VALUE_UNIT_TYPE)
enumToInt(VALUE_UNIT_TYPE_DATE)
enumToInt(VALUE_UNIT_TYPE_OBJECT)
enumToInt(VALUE_UNIT_TYPE_STRING)
enumToInt(VALUE_STRING_CVT_TYPE)

