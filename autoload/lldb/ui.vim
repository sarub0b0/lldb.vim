scriptencoding utf-8
if exists('g:loaded_lldb_ui_autoload')
    finish
endif
let g:loaded_lldb_ui_autoload = 1

function! lldb#ui#init()
    let l:default_panes = ['breakpoints', 'variables', 'lldb']
    let g:lldb#ui#default_panes = get(g:, 'lldb#ui#default_panes', l:default_panes)
    let g:lldb#ui#created = 0
endfunction

function! lldb#ui#finish() abort
    for l:pane in g:lldb#ui#default_panes
        execute 'bdelete! ' . bufnr(bufname(l:pane))
    endfor
    let g:lldb#ui#created = 0
endfunction

function! lldb#ui#create_panes()
    call s:create_panes()
    call s:check_panes()
    let g:lldb#ui#created = 1
endfunction


function! s:create_panes()
    let l:panes = g:lldb#ui#default_panes[1:]
    let l:base_pane = g:lldb#ui#default_panes[0]
    let l:move_window = "execute bufwinnr(bufnr('" . l:base_pane . "')).'wincmd w'"
    wincmd b
    execute 'belowright vsplit ' . l:base_pane
    execute l:move_window
    call s:buf_options()
    let &l:statusline = "%{'variables'}"
    wincmd L
    for l:pane in l:panes
        execute 'split ' . l:pane
        call s:buf_options()
        let &l:statusline = "%{'" . l:pane . "'}"
    endfor
endfunction

function! s:move_bufname(bufname) abort
    execute "execute bufnr(bufname('" . a:bufname . "')).'wincmd w'"
endfunction

function! s:buf_options()
    setlocal noswapfile
    setlocal buftype=nofile
    " setlocal bufhidden=hide
    setlocal wrap
    setlocal foldcolumn=0
    setlocal foldmethod=manual
    setlocal nofoldenable
    " setlocal nobuflisted
    setlocal nospell
    setlocal nonumber
    setlocal filetype=lldb
    setlocal nomodifiable
endfunction

function! s:check_panes()
    let l:panes = g:lldb#ui#default_panes

    let l:pane_count = 0
    let l:pane_len = len(l:panes)

    while l:pane_count != l:pane_len
        let l:count = 0
        for l:p in l:panes
            let l:cmd = -1
            let l:cmd = "echo bufwinnr(bufnr('" . l:p . "'))"
            if execute(l:cmd) != -1
                let l:count += 1
            else
                break
            endif
        endfor
        let l:pane_count = l:count
    endwhile

endfunction
