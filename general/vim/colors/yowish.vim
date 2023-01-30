" Yowish colorscheme.

" Version      : 0.7.3
" Creation     : 2015-01-09
" Modification : 2017-12-10
" Maintainer   : Kabbaj Amine <amine.kabb@gmail.com>
" License      : This file is placed in the public domain.

" Initialization {{{1
set background=dark
hi clear
if exists('syntax_on')
	syntax reset
endif
let g:colors_name = 'yowish'
" 1}}}

" Get config & colors [hex, term256] {{{1
call yowish#SetConfig()
let s:color = g:yowish.colors
" 1}}}

" Highlighting function {{{1
fun! s:Hi(groupName, bgColor, fgColor, opt)
	let l:bg = type(a:bgColor) ==# type('') ? ['NONE', 'NONE' ] : a:bgColor
	let l:fg = type(a:fgColor) ==# type('') ? ['NONE', 'NONE'] : a:fgColor
	let l:opt = !g:yowish.term_italic && a:opt ==# 'italic' ?
				\ [a:opt, 'NONE'] : [a:opt, a:opt]
	let l:mode = ['gui', 'cterm']
	let l:cmd = 'hi ' . a:groupName
	for l:i in (range(0, len(l:mode)-1))
		let l:cmd .= printf(' %sbg=%s %sfg=%s %s=%s',
					\ l:mode[l:i], l:bg[l:i],
					\ l:mode[l:i], l:fg[l:i],
					\ l:mode[l:i], l:opt[l:i]
				\ )
	endfor
	execute l:cmd
endfun
" 1}}}

" *********************
" Highlighting
" *********************

" Normal syntax groups {{{1
call s:Hi('Constant'  , 'NONE' , s:color.lightRed    , 'NONE')
call s:Hi('PreProc'   , 'NONE' , s:color.lightViolet , 'NONE')
call s:Hi('Statement' , 'NONE' , s:color.lightYellow , 'NONE')
call s:Hi('String'    , 'NONE' , s:color.lightGreen  , 'NONE')
hi! link Character String
" Default {{{1
call s:Hi('ColorColumn'  , s:color.backgroundDark   , s:color.yellow          , 'bold')
if g:yowish.comment_italic
	call s:Hi('Comment'  , 'NONE'                   , s:color.comment         , 'italic')
else
	call s:Hi('Comment'  , 'NONE'                   , s:color.comment         , 'NONE')
endif
call s:Hi('Conceal'      , 'NONE'                   , s:color.backgroundLight , 'NONE')
call s:Hi('CursorLineNr' , 'NONE'                   , s:color.lightYellow     , 'NONE')
call s:Hi('CursorLine'   , s:color.backgroundLight  , 'NONE'                  , 'NONE')
call s:Hi('Cursor'       , s:color.text             , s:color.backgroundDark  , 'NONE')
call s:Hi('DiffAdd'      , s:color.lightGreen       , s:color.backgroundDark  , 'NONE')
call s:Hi('DiffChange'   , s:color.backgroundLight  , s:color.lightYellow     , 'NONE')
call s:Hi('DiffDelete'   , s:color.lightRed         , s:color.backgroundDark  , 'NONE')
call s:Hi('DiffText'     , 'NONE'                   , s:color.textDark        , 'NONE')
call s:Hi('Directory'    , 'NONE'                   , s:color.textDark        , 'NONE')
call s:Hi('ErrorMsg'     , s:color.red              , s:color.text            , 'bold')
call s:Hi('Error'        , 'NONE'                   , s:color.red             , 'bold')
call s:Hi('FoldColumn'   , s:color.columnBackground , s:color.columnElements  , 'NONE')
call s:Hi('Identifier'   , 'NONE'                   , s:color.lightBlue       , 'NONE')
call s:Hi('IncSearch'    , s:color.lightYellow      , s:color.background      , 'NONE')
call s:Hi('LineNr'       , 'NONE'                   , s:color.backgroundLight , 'NONE')
call s:Hi('MatchParen'   , 'NONE'                   , s:color.yellow          , 'bold')
call s:Hi('ModeMsg'      , 'NONE'                   , s:color.yellow          , 'bold')
call s:Hi('Normal'       , s:color.background       , s:color.text            , 'NONE')
call s:Hi('PmenuSbar'    , s:color.selected         , s:color.lightYellow     , 'NONE')
call s:Hi('Pmenu'        , s:color.backgroundLight  , s:color.textDark        , 'NONE')
call s:Hi('PmenuSel'     , s:color.background       , s:color.text            , 'NONE')
call s:Hi('Question'     , 'NONE'                   , s:color.lightGreen      , 'bold')
call s:Hi('Search'       , s:color.yellow           , s:color.backgroundDark  , 'bold')
call s:Hi('SpecialKey'   , 'NONE'                   , s:color.backgroundLight , 'NONE')
call s:Hi('Special'      , 'NONE'                   , s:color.textLight       , 'NONE')

let s:spell_bad_color = yowish#GetColorFor(g:yowish.spell_bad_color)
call s:Hi('SpellBad'     , 'NONE'                   , s:spell_bad_color       , 'undercurl')

call s:Hi('StatusLineNC' , s:color.backgroundLight  , s:color.text            , 'NONE')
call s:Hi('StatusLine'   , s:color.yellow           , s:color.background      , 'NONE')
call s:Hi('TabLineFill'  , 'NONE'                   , s:color.text            , 'NONE')
call s:Hi('TabLine'      , s:color.backgroundLight  , s:color.textDark        , 'NONE')
call s:Hi('TabLineSel'   , s:color.background       , s:color.yellow          , 'bold')
call s:Hi('Title'        , 'NONE'                   , s:color.lightRed        , 'NONE')
call s:Hi('Todo'         , 'NONE'                   , s:color.yellow          , 'NONE')
call s:Hi('Type'         , 'NONE'                   , s:color.textDark        , 'NONE')
call s:Hi('VertSplit'    , 'NONE'                   , s:color.yellow          , 'NONE')
call s:Hi('Visual'       , s:color.selected         , 'NONE'                  , 'NONE')
call s:Hi('WarningMsg'   , 'NONE'                   , s:color.yellow          , 'bold')
call s:Hi('WildMenu'     , s:color.background       , s:color.yellow          , 'NONE')
hi! link CursorColumn CursorLine
hi! link diffAdded DiffAdd
hi! link diffChanged DiffChange
hi! link diffRemoved DiffDelete
hi! link Folded FoldColumn
hi! link NonText Conceal
hi! link qfFileName Comment
hi! link qfLineNr Statement
hi! link qfSeparator qfLineNr
hi! link SignColumn FoldColumn
hi! link VisualNOS Visual
if has('terminal')
	call s:Hi('Terminal', s:color.backgroundDark, s:color.textDark, 'NONE')
endif
" Vim {{{1
call s:Hi('vimAutoEvent' , 'NONE' , s:color.textExtraDark , 'NONE')
call s:Hi('vimCommand'   , 'NONE' , s:color.lightRed      , 'NONE')
call s:Hi('vimContinue'  , 'NONE' , s:color.textDark      , 'NONE')
call s:Hi('vimFuncName'  , 'NONE' , s:color.lightYellow   , 'NONE')
call s:Hi('vimOper'      , 'NONE' , s:color.text          , 'NONE')
hi! link vimCommentString Comment
hi! link vimCommentTitle Comment
hi! link vimEchoHLNone vimOper
hi! link vimFunc vimFuncName
hi! link vimGroup vimFuncName
hi! link vimHiGroup vimFuncName
hi! link vimIsCommand vimCommand
hi! link vimMapModKey vimOper
hi! link vimMapMod vimOper
hi! link vimSep vimOper
hi! link vimUserCmd vimCommand
hi! link vimNotation vimOper
hi! link vimOperParen vimOper
hi! link vimParenSep vimOper
hi! link vimSynType vimFuncName
" Vimhelp {{{1
call s:Hi('helpExample'        , 'NONE' , s:color.textExtraDark , 'NONE')
call s:Hi('helpHyperTextEntry' , 'NONE' , s:color.lightRed      , 'bold')
call s:Hi('helpHyperTextJump'  , 'NONE' , s:color.lightYellow   , 'NONE')
hi! link helpOption helpExample
hi! link helpSectionDelim helpExample
" HTML {{{1
call s:Hi('HtmlArg'         , 'NONE' , s:color.lightYellow , 'NONE')
call s:Hi('HtmlH1'          , 'NONE' , s:color.text        , 'NONE')
call s:Hi('HtmlLink'        , 'NONE' , s:color.text        , 'underline')
call s:Hi('HtmlSpecialChar' , 'NONE' , s:color.textDark    , 'NONE')
call s:Hi('HtmlTagName'     , 'NONE' , s:color.lightRed    , 'NONE')
call s:Hi('HtmlTitle'       , 'NONE' , s:color.text        , 'bold')
call s:Hi('HtmlUnderline'   , 'NONE' , 'NONE'              , 'underline')
" For https://github.com/othree/html5.vim
hi! link HtmlScriptTag HtmlTagName
hi! link HtmlSpecialTagName HtmlTagName
" CSS {{{1
call s:Hi('cssAttr'        , 'NONE' , s:color.lightYellow , 'NONE')
call s:Hi('cssDefinition'  , 'NONE' , s:color.lightBlue   , 'NONE')
call s:Hi('cssFunction'    , 'NONE' , s:color.text        , 'NONE')
call s:Hi('cssIdentifier'  , 'NONE' , s:color.lightViolet , 'bold')
call s:Hi('cssImportant'   , 'NONE' , s:color.lightBlue   , 'italic')
call s:Hi('cssMedia'       , 'NONE' , s:color.textLight   , 'NONE')
call s:Hi('cssProp'        , 'NONE' , s:color.lightBlue   , 'NONE')
call s:Hi('cssPseudoClass' , 'NONE' , s:color.lightRed    , 'NONE')
call s:Hi('cssTagName'     , 'NONE' , s:color.text        , 'bold')
hi! link cssAttrComma cssFunction
hi! link cssBraces cssTagName
hi! link cssClassName cssFunction
hi! link cssColor cssAttr
hi! link cssFunctionComma cssFunction
hi! link cssFunctionName cssFunction
hi! link cssMediaKeyword cssMedia
hi! link cssPseudoClassFn cssPseudoClass
hi! link cssPseudoClassId cssPseudoClass
hi! link cssPseudoClassLAng cssPseudoClass
hi! link cssUnicodeEscape cssAttr
hi! link cssUnitDecorators cssAttr
hi! link cssValueAngle cssAttr
hi! link cssValueFrequency cssAttr
hi! link cssValueInteger cssAttr
hi! link cssValueLength cssAttr
hi! link cssValueNumber cssAttr
hi! link cssValueTime cssAttr
" SASS & SCSS {{{1
call s:Hi('sassCssAttribute' , 'NONE' , s:color.textDark  , 'NONE')
call s:Hi('sassDefault'      , 'NONE' , s:color.lightBlue , 'italic')
call s:Hi('sassInclude'      , 'NONE' , s:color.textLight , 'bold')
call s:Hi('sassVariable'     , 'NONE' , s:color.lightRed  , 'NONE')
hi! link sassClassChar sassClass
hi! link sassClass cssClassName
hi! link sassControl sassInclude
hi! link sassDefinition cssDefinition
hi! link sassFunction cssFunctionName
hi! link sassIdChar sassId
hi! link sassId cssIdentifier
hi! link sassMixing sassInclude
hi! link sassMixin sassInclude
hi! link sassProperty cssProp
" PHP {{{1
call s:Hi('phpIdentifier'       , 'NONE' , s:color.lightRed    , 'NONE')
call s:Hi('phpInclude'          , 'NONE' , s:color.lightYellow , 'bold')
call s:Hi('phpKeyword'          , 'NONE' , s:color.lightViolet , 'NONE')
call s:Hi('phpMemberSelector'   , 'NONE' , s:color.lightYellow , 'NONE')
call s:Hi('phpParent'           , 'NONE' , s:color.textDark    , 'NONE')
call s:Hi('phpRegion'           , 'NONE' , s:color.text        , 'NONE')
call s:Hi('phpType'             , 'NONE' , s:color.lightBlue   , 'NONE')
call s:Hi('phpVarSelector'      , 'NONE' , s:color.lightRed    , 'NONE')
hi! link phpFunctions phpRegion
hi! link phpOperator Delimiter
" For https://github.com/StanAngeloff/php.vim
call s:Hi('phpSuperglobals'   , 'NONE' , s:color.lightRed    , 'bold')
hi! link phpStaticClasses phpSuperglobals
hi! link phpStrEsc phpMemberSelector
" Markdown {{{1
call s:Hi('markdownBlockquote'  , 'NONE' , s:color.lightBlue     , 'NONE')
call s:Hi('markdownCodeBlock'   , 'NONE' , s:color.textExtraDark , 'NONE')
call s:Hi('markdownCode'        , 'NONE' , s:color.lightGreen    , 'NONE')
call s:Hi('markdownH1'          , 'NONE' , s:color.textLight     , 'bold')
call s:Hi('markdownHeadingRule' , 'NONE' , s:color.lightViolet   , 'bold')
call s:Hi('markdownItalic'      , 'NONE' , 'NONE'                , 'italic')
call s:Hi('markdownLinkText'    , 'NONE' , s:color.lightBlue     , 'underline')
call s:Hi('markdownListMarker'  , 'NONE' , s:color.lightRed      , 'NONE')
call s:Hi('markdownUrl'         , 'NONE' , s:color.lightYellow   , 'NONE')
hi! link markdownCodeDelimiter markdownCode
hi! link markdownH2 markdownH1
hi! link markdownH3 markdownH1
hi! link markdownH4 markdownH1
hi! link markdownH5 markdownH1
hi! link markdownH6 markdownH1
hi! link markdownHeadingDelimiter markdownHeadingRule
hi! link markdownIdDeclaration markdownLinkText
hi! link markdownRule markdownCodeBlock
hi! link markdownURLTitleDelimiter markdownUrl
" For https://github.com/gabrielelana/vim-markdown
call s:Hi('markdownLinkReference', 'NONE', s:color.textDark, 'NONE')
hi! link markdownBlockquoteDelimiter markdownBlockquote
hi! link markdownEmoticonKeyword markdownH1
hi! link markdownInlineCode markdownCode
hi! link markdownItemDelimiter markdownListMarker
hi! link markdownLinkUrl markdownUrl
hi! link markdownStrike normal
hi! link markdownXmlElement markdownCode
" Javascript {{{1
call s:Hi('javaScriptBraces'     , 'NONE' , s:color.textLight   , 'bold')
call s:Hi('javaScriptIdentifier' , 'NONE' , s:color.lightYellow , 'NONE')
call s:Hi('javaScriptNumber'     , 'NONE' , s:color.lightRed    , 'NONE')
" For https://github.com/othree/yajs.vim
call s:Hi('JavascriptBlock'    , 'NONE' , s:color.textDark    , 'NONE')
call s:Hi('JavascriptExport'   , 'NONE' , 'NONE'              , 'bold')
call s:Hi('JavascriptOpSymbol' , 'NONE' , s:color.lightViolet , 'NONE')
call s:Hi('javascriptArrowFunc' , 'NONE' , s:color.lightYellow , 'NONE')
hi! link JavascriptDotNotation javaScriptIdentifier
hi! link JavascriptLogicSymbol JavascriptOpSymbol
hi! link JavascriptOpSymbols JavascriptOpSymbol
hi! link javascriptVariable javaScriptIdentifier
" For https://github.com/pangloss/vim-javascript
call s:Hi('JsFuncBlock'     , 'NONE' , s:color.textDark    , 'NONE')
call s:Hi('jsFuncCall'      , 'NONE' , s:color.lightBlue   , 'NONE')
call s:Hi('jsGlobalObjects' , 'NONE' , 'NONE'              , 'bold')
call s:Hi('jsOperator'      , 'NONE' , s:color.lightViolet , 'NONE')
call s:Hi('jsArrowFunction' , 'NONE' , s:color.lightYellow , 'NONE')
hi! link jsFunction javaScriptIdentifier
hi! link jsNoise javaScriptIdentifier
hi! link jsStorageClass javaScriptIdentifier
" Ruby {{{1
call s:Hi('rubyBlock'    , 'NONE' , 'NONE'              , 'bold')
call s:Hi('rubyConstant' , 'NONE' , s:color.lightYellow , 'NONE')
call s:Hi('rubyFunction' , 'NONE' , s:color.lightYellow , 'NONE')
" Pug {{{1
" For https://github.com/digitaltoad/vim-pug
call s:Hi('pugAttributes' , 'NONE' , s:color.text        , 'NONE')
call s:Hi('pugClass'      , 'NONE' , s:color.lightYellow , 'NONE')
call s:Hi('pugTag'        , 'NONE' , s:color.lightRed    , 'NONE')
hi! link pugClassChar pugClass
hi! link pugDoctype comment
hi! link pugIdChar pugId
" NERDtree plugin {{{1
" https://github.com/scrooloose/nerdtree
if g:yowish.nerdtree
	call s:Hi('NERDtreeBookmark'  , 'NONE'                 , s:color.lightBlue     , 'NONE')
	call s:Hi('NERDtreeCWD'       , 'NONE'                 , s:color.lightYellow   , 'NONE')
	call s:Hi('NERDtreeDir'       , 'NONE'                 , s:color.textLight     , 'bold')
	call s:Hi('NERDtreeFile'      , 'NONE'                 , s:color.text          , 'NONE')
	call s:Hi('NERDtreeHelp'      , 'NONE'                 , s:color.lightRed      , 'NONE')
	call s:Hi('NERDtreeToggleOff' , s:color.backgroundDark , s:color.red           , 'bold')
	call s:Hi('NERDtreeToggleOn'  , s:color.backgroundDark , s:color.green         , 'bold')
	call s:Hi('NERDtreeUp'        , 'NONE'                 , s:color.textExtraDark , 'NONE')
	hi! link NERDtreeBookmarkName NERDtreeFile
	hi! link NERDtreeBookmarksHeader NERDtreeCWD
	hi! link NERDtreeClosable NERDtreeDirSlash
	hi! link NERDtreeDirSlash NERDtreeCWD
	hi! link NERDtreeHelpCommand NERDtreeFile
	hi! link NERDtreeHelpKey NERDtreeFile
	hi! link NERDtreeHelpTitle NERDtreeHelp
	hi! link NERDtreeOpenable NERDtreeDirSlash
endif
" CtrlP plugin {{{1
" https://github.com/ctrlpvim/ctrlp.vim (An active fork)
if g:yowish.ctrlp
	call s:Hi('CtrlPLinePre'   , 'NONE' , s:color.text        , 'NONE')
	call s:Hi('CtrlPMatch'     , 'NONE' , s:color.lightYellow , 'bold')
	call s:Hi('CtrlPMode1'     , 'NONE' , s:color.textDark    , 'NONE')
	call s:Hi('CtrlPNoEntries' , 'NONE' , s:color.red         , 'bold')
	call s:Hi('CtrlPPrtCursor' , 'NONE' , s:color.lightYellow , 'underline')
	hi! link CtrlPPrtBase CtrlPMatch
endif
" Agit plugin {{{1
" https://github.com/cohama/agit.vim
if g:yowish.agit
	call s:Hi('agitStatAdded'   , 'NONE' , s:color.green , 'NONE')
	call s:Hi('agitStatFile'    , 'NONE' , s:color.text  , 'bold')
	call s:Hi('agitStatRemoved' , 'NONE' , s:color.red   , 'NONE')
	hi! link agitDiffAdd diffAdd
	hi! link agitDiffAddMerge agitDiffAdd
	hi! link agitDiffFileName agitDiffIndex
	hi! link agitDiffIndex WarningMsg
	hi! link agitDiffRemove diffDelete
	hi! link agitDiffRemoveMerge agitDiffRemove
	hi! link agitHeader Identifier
endif
" Unite plugin {{{1
" https://github.com/shougo/unite.vim
if g:yowish.unite
	call s:Hi('uniteCandidateIcon'  , 'NONE' , s:color.textExtraDark , 'NONE')
	call s:Hi('uniteInputLine'      , 'NONE' , s:color.lightYellow   , 'bold')
	call s:Hi('uniteQuickMatchText' , 'NONE' , s:color.lightRed      , 'bold')
	hi! link uniteCandidateInputKeyword uniteInputLine
	hi! link uniteInputPrompt uniteInputLine
	hi! link uniteSource__GrepPattern uniteInputLine
endif
" Signjk plugin {{{1
" https://github.com/haya14busa/vim-signjk-motion
if g:yowish.signjk
	call s:Hi('SignjkTarget2' , s:color.backgroundDark  , s:color.yellow , 'NONE')
	call s:Hi('SignjkTarget'  , s:color.backgroundLight , s:color.yellow , 'bold')
endif
" 1}}}

" Cleaning {{{1
unlet s:color
delfunction s:Hi
" 1}}}

" vim:ft=vim:fdm=marker:fmr={{{,}}}:
