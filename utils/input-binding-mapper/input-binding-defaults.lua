local bindings = {
	key_space = 'key_space',
	key_exclamationmark = 'key_exclamationmark',
	key_doublequote = 'key_doublequote',
	key_hash = 'key_hash',
	key_dollarsign = 'key_dollarsign',
	key_ampersand = 'key_ampersand',
	key_singlequote = 'key_singlequote',
	key_lparen = 'key_lparen',
	key_rparen = 'key_rparen',
	key_asterisk = 'key_asterisk',
	key_plus = 'key_plus',
	key_comma = 'key_comma',
	key_minus = 'key_minus',
	key_period = 'key_period',
	key_slash = 'key_slash',
	key_0 = 'key_0',
	key_1 = 'key_1',
	key_2 = 'key_2',
	key_3 = 'key_3',
	key_4 = 'key_4',
	key_5 = 'key_5',
	key_6 = 'key_6',
	key_7 = 'key_7',
	key_8 = 'key_8',
	key_9 = 'key_9',
	key_colon = 'key_colon',
	key_semicolon = 'key_semicolon',
	key_lessthan = 'key_lessthan',
	key_equals = 'key_equals',
	key_greaterthan = 'key_greaterthan',
	key_questionmark = 'key_questionmark',
	key_at = 'key_at',
	key_a = 'key_a',
	key_b = 'key_b',
	key_c = 'key_c',
	key_d = 'key_d',
	key_e = 'key_e',
	key_f = 'key_f',
	key_g = 'key_g',
	key_h = 'key_h',
	key_i = 'key_i',
	key_j = 'key_j',
	key_k = 'key_k',
	key_l = 'key_l',
	key_m = 'key_m',
	key_n = 'key_n',
	key_o = 'key_o',
	key_p = 'key_p',
	key_q = 'key_q',
	key_r = 'key_r',
	key_s = 'key_s',
	key_t = 'key_t',
	key_u = 'key_u',
	key_v = 'key_v',
	key_w = 'key_w',
	key_x = 'key_x',
	key_y = 'key_y',
	key_z = 'key_z',
	key_lbracket = 'key_lbracket',
	key_rbracket = 'key_rbracket',
	key_backslash = 'key_backslash',
	key_caret = 'key_caret',
	key_underscore = 'key_underscore',
	key_grave = 'key_grave',
	key_lbrace = 'key_lbrace',
	key_rbrace = 'key_rbrace',
	key_pipe = 'key_pipe',
	key_esc = 'key_esc',
	key_f1 = 'key_f1',
	key_f2 = 'key_f2',
	key_f3 = 'key_f3',
	key_f4 = 'key_f4',
	key_f5 = 'key_f5',
	key_f6 = 'key_f6',
	key_f7 = 'key_f7',
	key_f8 = 'key_f8',
	key_f9 = 'key_f9',
	key_f10 = 'key_f10',
	key_f11 = 'key_f11',
	key_f12 = 'key_f12',
	key_up = 'key_up',
	key_down = 'key_down',
	key_left = 'key_left',
	key_right = 'key_right',
	key_lshift = 'key_lshift',
	key_rshift = 'key_rshift',
	key_lctrl = 'key_lctrl',
	key_rctrl = 'key_rctrl',
	key_lalt = 'key_lalt',
	key_ralt = 'key_ralt',
	key_tab = 'key_tab',
	key_enter = 'key_enter',
	key_backspace = 'key_backspace',
	key_insert = 'key_insert',
	key_del = 'key_del',
	key_pageup = 'key_pageup',
	key_pagedown = 'key_pagedown',
	key_home = 'key_home',
	key_end = 'key_end',
	key_numpad_0 = 'key_numpad_0',
	key_numpad_1 = 'key_numpad_1',
	key_numpad_2 = 'key_numpad_2',
	key_numpad_3 = 'key_numpad_3',
	key_numpad_4 = 'key_numpad_4',
	key_numpad_5 = 'key_numpad_5',
	key_numpad_6 = 'key_numpad_6',
	key_numpad_7 = 'key_numpad_7',
	key_numpad_8 = 'key_numpad_8',
	key_numpad_9 = 'key_numpad_9',
	key_numpad_divide = 'key_numpad_divide',
	key_numpad_multiply = 'key_numpad_multiply',
	key_numpad_subtract = 'key_numpad_subtract',
	key_numpad_add = 'key_numpad_add',
	key_numpad_decimal = 'key_numpad_decimal',
	key_numpad_equal = 'key_numpad_equal',
	key_numpad_enter = 'key_numpad_enter',
	key_numpad_numlock = 'key_numpad_numlock',
	key_capslock = 'key_capslock',
	key_scrolllock = 'key_scrolllock',
	key_pause = 'key_pause',
	key_lsuper = 'key_lsuper',
	key_rsuper = 'key_rsuper',
	key_menu = 'key_menu',
	key_back = 'key_back',
	mouse_wheel_up = 'mouse_wheel_up',
	mouse_wheel_down = 'mouse_wheel_down',
	mouse_button_left = 'mouse_button_left',
	mouse_button_middle = 'mouse_button_middle',
	mouse_button_right = 'mouse_button_right',
	mouse_button_1 = 'mouse_button_1',
	mouse_button_2 = 'mouse_button_2',
	mouse_button_3 = 'mouse_button_3',
	mouse_button_4 = 'mouse_button_4',
	mouse_button_5 = 'mouse_button_5',
	mouse_button_6 = 'mouse_button_6',
	mouse_button_7 = 'mouse_button_7',
	mouse_button_8 = 'mouse_button_8',
	touch = 'touch',
	gamepad_lstick_left = 'gamepad_lstick_left',
	gamepad_lstick_right = 'gamepad_lstick_right',
	gamepad_lstick_down = 'gamepad_lstick_down',
	gamepad_lstick_up = 'gamepad_lstick_up',
	gamepad_lstick_click = 'gamepad_lstick_click',
	gamepad_ltrigger = 'gamepad_ltrigger',
	gamepad_lshoulder = 'gamepad_lshoulder',
	gamepad_lpad_left = 'gamepad_lpad_left',
	gamepad_lpad_right = 'gamepad_lpad_right',
	gamepad_lpad_down = 'gamepad_lpad_down',
	gamepad_lpad_up = 'gamepad_lpad_up',
	gamepad_rstick_left = 'gamepad_rstick_left',
	gamepad_rstick_right = 'gamepad_rstick_right',
	gamepad_rstick_down = 'gamepad_rstick_down',
	gamepad_rstick_up = 'gamepad_rstick_up',
	gamepad_rstick_click = 'gamepad_rstick_click',
	gamepad_rtrigger = 'gamepad_rtrigger',
	gamepad_rshoulder = 'gamepad_rshoulder',
	gamepad_rpad_left = 'gamepad_rpad_left',
	gamepad_rpad_right = 'gamepad_rpad_right',
	gamepad_rpad_down = 'gamepad_rpad_down',
	gamepad_rpad_up = 'gamepad_rpad_up',
	gamepad_start = 'gamepad_start',
	gamepad_back = 'gamepad_back',
	gamepad_guide = 'gamepad_guide',
	touch_multi = 'touch_multi',
	text = 'text',
	marked_text = 'marked_text'
}

local hashedInputs = {
	KEY_SPACE = hash('key_space'),
	KEY_EXCLAMATIONMARK = hash('key_exclamationmark'),
	KEY_DOUBLEQUOTE = hash('key_doublequote'),
	KEY_HASH = hash('key_hash'),
	KEY_DOLLARSIGN = hash('key_dollarsign'),
	KEY_AMPERSAND = hash('key_ampersand'),
	KEY_SINGLEQUOTE = hash('key_singlequote'),
	KEY_LPAREN = hash('key_lparen'),
	KEY_RPAREN = hash('key_rparen'),
	KEY_ASTERISK = hash('key_asterisk'),
	KEY_PLUS = hash('key_plus'),
	KEY_COMMA = hash('key_comma'),
	KEY_MINUS = hash('key_minus'),
	KEY_PERIOD = hash('key_period'),
	KEY_SLASH = hash('key_slash'),
	KEY_0 = hash('key_0'),
	KEY_1 = hash('key_1'),
	KEY_2 = hash('key_2'),
	KEY_3 = hash('key_3'),
	KEY_4 = hash('key_4'),
	KEY_5 = hash('key_5'),
	KEY_6 = hash('key_6'),
	KEY_7 = hash('key_7'),
	KEY_8 = hash('key_8'),
	KEY_9 = hash('key_9'),
	KEY_COLON = hash('key_colon'),
	KEY_SEMICOLON = hash('key_semicolon'),
	KEY_LESSTHAN = hash('key_lessthan'),
	KEY_EQUALS = hash('key_equals'),
	KEY_GREATERTHAN = hash('key_greaterthan'),
	KEY_QUESTIONMARK = hash('key_questionmark'),
	KEY_AT = hash('key_at'),
	KEY_A = hash('key_a'),
	KEY_B = hash('key_b'),
	KEY_C = hash('key_c'),
	KEY_D = hash('key_d'),
	KEY_E = hash('key_e'),
	KEY_F = hash('key_f'),
	KEY_G = hash('key_g'),
	KEY_H = hash('key_h'),
	KEY_I = hash('key_i'),
	KEY_J = hash('key_j'),
	KEY_K = hash('key_k'),
	KEY_L = hash('key_l'),
	KEY_M = hash('key_m'),
	KEY_N = hash('key_n'),
	KEY_O = hash('key_o'),
	KEY_P = hash('key_p'),
	KEY_Q = hash('key_q'),
	KEY_R = hash('key_r'),
	KEY_S = hash('key_s'),
	KEY_T = hash('key_t'),
	KEY_U = hash('key_u'),
	KEY_V = hash('key_v'),
	KEY_W = hash('key_w'),
	KEY_X = hash('key_x'),
	KEY_Y = hash('key_y'),
	KEY_Z = hash('key_z'),
	KEY_LBRACKET = hash('key_lbracket'),
	KEY_RBRACKET = hash('key_rbracket'),
	KEY_BACKSLASH = hash('key_backslash'),
	KEY_CARET = hash('key_caret'),
	KEY_UNDERSCORE = hash('key_underscore'),
	KEY_GRAVE = hash('key_grave'),
	KEY_LBRACE = hash('key_lbrace'),
	KEY_RBRACE = hash('key_rbrace'),
	KEY_PIPE = hash('key_pipe'),
	KEY_ESC = hash('key_esc'),
	KEY_F1 = hash('key_f1'),
	KEY_F2 = hash('key_f2'),
	KEY_F3 = hash('key_f3'),
	KEY_F4 = hash('key_f4'),
	KEY_F5 = hash('key_f5'),
	KEY_F6 = hash('key_f6'),
	KEY_F7 = hash('key_f7'),
	KEY_F8 = hash('key_f8'),
	KEY_F9 = hash('key_f9'),
	KEY_F10 = hash('key_f10'),
	KEY_F11 = hash('key_f11'),
	KEY_F12 = hash('key_f12'),
	KEY_UP = hash('key_up'),
	KEY_DOWN = hash('key_down'),
	KEY_LEFT = hash('key_left'),
	KEY_RIGHT = hash('key_right'),
	KEY_LSHIFT = hash('key_lshift'),
	KEY_RSHIFT = hash('key_rshift'),
	KEY_LCTRL = hash('key_lctrl'),
	KEY_RCTRL = hash('key_rctrl'),
	KEY_LALT = hash('key_lalt'),
	KEY_RALT = hash('key_ralt'),
	KEY_TAB = hash('key_tab'),
	KEY_ENTER = hash('key_enter'),
	KEY_BACKSPACE = hash('key_backspace'),
	KEY_INSERT = hash('key_insert'),
	KEY_DEL = hash('key_del'),
	KEY_PAGEUP = hash('key_pageup'),
	KEY_PAGEDOWN = hash('key_pagedown'),
	KEY_HOME = hash('key_home'),
	KEY_END = hash('key_end'),
	KEY_NUMPAD_0 = hash('key_numpad_0'),
	KEY_NUMPAD_1 = hash('key_numpad_1'),
	KEY_NUMPAD_2 = hash('key_numpad_2'),
	KEY_NUMPAD_3 = hash('key_numpad_3'),
	KEY_NUMPAD_4 = hash('key_numpad_4'),
	KEY_NUMPAD_5 = hash('key_numpad_5'),
	KEY_NUMPAD_6 = hash('key_numpad_6'),
	KEY_NUMPAD_7 = hash('key_numpad_7'),
	KEY_NUMPAD_8 = hash('key_numpad_8'),
	KEY_NUMPAD_9 = hash('key_numpad_9'),
	KEY_NUMPAD_DIVIDE = hash('key_numpad_divide'),
	KEY_NUMPAD_MULTIPLY = hash('key_numpad_multiply'),
	KEY_NUMPAD_SUBTRACT = hash('key_numpad_subtract'),
	KEY_NUMPAD_ADD = hash('key_numpad_add'),
	KEY_NUMPAD_DECIMAL = hash('key_numpad_decimal'),
	KEY_NUMPAD_EQUAL = hash('key_numpad_equal'),
	KEY_NUMPAD_ENTER = hash('key_numpad_enter'),
	KEY_NUMPAD_NUMLOCK = hash('key_numpad_numlock'),
	KEY_CAPSLOCK = hash('key_capslock'),
	KEY_SCROLLLOCK = hash('key_scrolllock'),
	KEY_PAUSE = hash('key_pause'),
	KEY_LSUPER = hash('key_lsuper'),
	KEY_RSUPER = hash('key_rsuper'),
	KEY_MENU = hash('key_menu'),
	KEY_BACK = hash('key_back'),
	MOUSE_WHEEL_UP = hash('mouse_wheel_up'),
	MOUSE_WHEEL_DOWN = hash('mouse_wheel_down'),
	MOUSE_BUTTON_LEFT = hash('mouse_button_left'),
	MOUSE_BUTTON_MIDDLE = hash('mouse_button_middle'),
	MOUSE_BUTTON_RIGHT = hash('mouse_button_right'),
	MOUSE_BUTTON_1 = hash('mouse_button_1'),
	MOUSE_BUTTON_2 = hash('mouse_button_2'),
	MOUSE_BUTTON_3 = hash('mouse_button_3'),
	MOUSE_BUTTON_4 = hash('mouse_button_4'),
	MOUSE_BUTTON_5 = hash('mouse_button_5'),
	MOUSE_BUTTON_6 = hash('mouse_button_6'),
	MOUSE_BUTTON_7 = hash('mouse_button_7'),
	MOUSE_BUTTON_8 = hash('mouse_button_8'),
	TOUCH = hash('touch'),
	GAMEPAD_LSTICK_LEFT = hash('gamepad_lstick_left'),
	GAMEPAD_LSTICK_RIGHT = hash('gamepad_lstick_right'),
	GAMEPAD_LSTICK_DOWN = hash('gamepad_lstick_down'),
	GAMEPAD_LSTICK_UP = hash('gamepad_lstick_up'),
	GAMEPAD_LSTICK_CLICK = hash('gamepad_lstick_click'),
	GAMEPAD_LTRIGGER = hash('gamepad_ltrigger'),
	GAMEPAD_LSHOULDER = hash('gamepad_lshoulder'),
	GAMEPAD_LPAD_LEFT = hash('gamepad_lpad_left'),
	GAMEPAD_LPAD_RIGHT = hash('gamepad_lpad_right'),
	GAMEPAD_LPAD_DOWN = hash('gamepad_lpad_down'),
	GAMEPAD_LPAD_UP = hash('gamepad_lpad_up'),
	GAMEPAD_RSTICK_LEFT = hash('gamepad_rstick_left'),
	GAMEPAD_RSTICK_RIGHT = hash('gamepad_rstick_right'),
	GAMEPAD_RSTICK_DOWN = hash('gamepad_rstick_down'),
	GAMEPAD_RSTICK_UP = hash('gamepad_rstick_up'),
	GAMEPAD_RSTICK_CLICK = hash('gamepad_rstick_click'),
	GAMEPAD_RTRIGGER = hash('gamepad_rtrigger'),
	GAMEPAD_RSHOULDER = hash('gamepad_rshoulder'),
	GAMEPAD_RPAD_LEFT = hash('gamepad_rpad_left'),
	GAMEPAD_RPAD_RIGHT = hash('gamepad_rpad_right'),
	GAMEPAD_RPAD_DOWN = hash('gamepad_rpad_down'),
	GAMEPAD_RPAD_UP = hash('gamepad_rpad_up'),
	GAMEPAD_START = hash('gamepad_start'),
	GAMEPAD_BACK = hash('gamepad_back'),
	GAMEPAD_GUIDE = hash('gamepad_guide'),
	TOUCH_MULTI = hash('touch_multi'),
	TEXT = hash('text'),
	MARKED_TEXT = hash('marked_text')
}

return {
  bindings = bindings, 
  hashed = hashedInputs
}