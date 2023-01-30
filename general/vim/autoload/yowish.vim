" Modification: 2017-09-12

function! yowish#SetConfig() abort " {{{1
	if !exists('g:yowish')
		let g:yowish = {}
	endif
	let g:yowish = {
				\ 'term_italic'     : !has_key(g:yowish, 'term_italic')     ? 0      : g:yowish.term_italic,
				\ 'comment_italic'  : !has_key(g:yowish, 'comment_italic')  ? 0      : g:yowish.comment_italic,
				\ 'spell_bad_color' : !has_key(g:yowish, 'spell_bad_color') ? 'NONE' : g:yowish.spell_bad_color,
				\ 'ctrlp'           : !has_key(g:yowish, 'ctrlp')           ? 1      : g:yowish.ctrlp,
				\ 'nerdtree'        : !has_key(g:yowish, 'nerdtree')        ? 1      : g:yowish.nerdtree,
				\ 'agit'            : !has_key(g:yowish, 'agit')            ? 1      : g:yowish.agit,
				\ 'unite'           : !has_key(g:yowish, 'unite')           ? 1      : g:yowish.unite,
				\ 'signjk'          : !has_key(g:yowish, 'signjk')          ? 1      : g:yowish.signjk,
				\ 'colors'          : !has_key(g:yowish, 'colors')          ? {}     : g:yowish.colors
			\ }
	let g:yowish.colors = extend({
				\ 'background'       : ['#222222','235'],
				\ 'backgroundDark'   : ['#0e0e0e','232'],
				\ 'backgroundLight'  : ['#393939','236'],
				\ 'comment'          : ['#6e6e6e','242'],
				\ 'green'            : ['#2acf2a','40'],
				\ 'lightBlue'        : ['#6699cc','67'],
				\ 'lightGreen'       : ['#99cc99','108'],
				\ 'lightRed'         : ['#f2777a','203'],
				\ 'lightViolet'      : ['#d09cea','171'],
				\ 'lightYellow'      : ['#ffcc66','222'],
				\ 'red'              : ['#f01d22','160'],
				\ 'selected'         : ['#373b41','234'],
				\ 'text'             : ['#cbcbcb','251'],
				\ 'textDark'         : ['#bebebe','249'],
				\ 'textExtraDark'    : ['#8c8c8c','244'],
				\ 'textLight'        : ['#ebebeb','255'],
				\ 'yellow'           : ['#ffbe3c','215'],
			\ }, g:yowish.colors, 'force')
	let g:yowish.colors.columnBackground = g:yowish.colors.background
	let g:yowish.colors.columnElements = g:yowish.colors.comment
endfunction
" 1}}}

function! yowish#GetColorFor(name) abort " {{{1
	if has_key(g:yowish.colors, a:name)
		return g:yowish.colors[a:name]
	endif

	return 'NONE'
endfunction
" 1}}}

" vim:ft=vim:fdm=marker:fmr={{{,}}}:
