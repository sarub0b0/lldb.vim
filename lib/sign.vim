
" let s:sign_bp_name
" let s:sign_pc_sel_name
" let s:sign_pc_unsel_name
function! lldb#sign#init()

    let s:bp_symbol = get(g:, 'lldb#bp_symbol', '>>')
    let s:pc_symbol = get(g:, 'lldb#pc_symbol', '>>')

    highlight default link LLBreakpointSign Text
    highlight default link LLBreakpointLine DiffText
    highlight default link LLUnselectedPCSign NonType
    highlight default link LLUnselectedPCLine DiffChange
    highlight default link LLSelectedPCSign Debug
    highlight default link LLSelectedPCLine DiffText

    execute 'sign define llsign_bp text=' . s:bp_symbol . ' texthl=LLBreakpointSign linehl=LLBreakpointLine'
    execute 'sign define llsign_pc_sel text=' . s:pc_symbol . ' texthl=LLSelectedPCSign linehl=LLSelectedPCLine'
    execute 'sign define llsign_pc_unsel text=' . s:pc_symbol . ' texthl=LLUnselectedPCSign linehl=LLUnselectedPCLine'

endfunction

let s:bp_counter = 0
let s:bp_place_id = 1
let s:bp_list = []
function! lldb#sign#bp_set(file, line)
    " if 0 < s:bp_counter
    "    " call lldb#sign#bp_unset()
    " endif

    let l:is_equal = v:false
    let l:rm_idx = 0
    let l:rm_id = 0
    for p in s:bp_list
        let l:id = p['id']
        let l:line = p['line']
        let l:file = p['file']
        " let l:file = split(p['file'], '/')
        " let l:file = l:file[-1]
        echomsg l:id . ' ' . l:line . ' ' .  l:file
        if l:file == a:file && l:line == a:line
            execute 'sign unplace ' . l:id
            let l:is_equal = v:true
            let l:rm_id = l:id
            break
        endif
        let l:rm_idx += 1
    endfor
    if l:is_equal
        echomsg string(s:bp_list)
        call remove(s:bp_list, l:rm_idx)
        echomsg string(s:bp_list)
        let s:bp_counter -= 1
        call lldb#operate#send('breakpoint delete ' . l:rm_id)
        call lldb#operate#breakpoints()
    else

        let g:lldb#operate#buftype = 'lldb'
        execute 'sign place ' . s:bp_place_id . ' line=' . a:line . ' name=llsign_bp file=' . a:file

        call add (s:bp_list, {'id': s:bp_place_id, 'line': a:line, 'file': a:file})
        let s:bp_place_id += 1
        call lldb#operate#send('breakpoint set -f ' . a:file . ' -l ' . a:line)
        call lldb#operate#breakpoints()
        echomsg string(s:bp_list)
        let s:bp_counter += 1
    endif
    if 0 < s:bp_counter
        let g:lldb#operate#is_breakpoints = v:true
    else
        let g:lldb#operate#is_breakpoints = v:false
    endif
endfunction


function! lldb#sign#reset() abort
    for p in s:bp_list
        let l:id = p['id']
        let l:line = p['line']
        let l:file = p['file']
        execute 'sign place ' . l:id . ' line=' . l:line . ' name=llsign_bp file=' . l:file
    endfor
endfunction

function! lldb#sign#clean() abort
    for p in s:bp_list
        let l:id = p['id']
        execute 'sign unplace ' . l:id
        call lldb#operate#send('breakpoint delete ' . l:id)
    endfor
    call lldb#operate#breakpoints()
    let s:bp_counter = 0
    let s:bp_list = []
    let g:lldb#operate#is_breakpoints = v:false
endfunction
function! lldb#sign#zero() abort
    let s:bp_place_id = 0
endfunction


function! lldb#sign#check_pc(msg)
    let l:param = []
    let l:param = s:pickup_param(a:msg)
    if l:param == []
        return 0
    endif
    echomsg string(l:param)
    " ['test.c', '7']

    let l:id = -1
    let l:line = ''
    let l:file = ''
    echomsg string(s:bp_list)
    for p in s:bp_list
        let l:id = p['id']
        let l:line = p['line']
        let l:file = split(p['file'], '/')
        let l:file = l:file[-1]
        echomsg l:id . ' ' . l:line . ' ' .  l:file
        echomsg string(l:param)
        if l:file == l:param[0] && l:line == l:param[1]
            echomsg 'pc_sel'
            execute 'sign place ' . l:id . ' line=' . l:line . ' name=llsign_pc_sel file=' . l:file
        else
            echomsg 'pc_unsel'
            execute 'sign place ' . l:id . ' line=' . l:line . ' name=llsign_pc_unsel file=' . l:file
        endif
    endfor
    " execute 'sign place ' . l:id . ' line=' . l:line . ' name=llsign_pc_sel file=' . l:file
endfunction

function! s:pickup_param(msg)
    for l:str in a:msg
        let l:match = matchstr(l:str, '[0-9A-Za-z_]\+\.[0-9A-Za-z_]\+:[0-9]\+')
        if l:match !=# ''
            return split(l:match, ':')
        endif
    endfor
    return []
endfunction

