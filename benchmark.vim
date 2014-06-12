" {
"   'nchars':     type(0),
"   'spent_time': type(0.0),
"   'count':      type(0),
" }
function! s:do_benchmark(cnt, nchars)
    let spent_time= 0.0

    for _ in range(1, a:cnt)
        let pipe= vimproc#popen3('perl ./gen-chars.pl ' . a:nchars)
        let buf= ''

        let start_time= reltime()
        while !pipe.stdout.eof
            let buf.= pipe.stdout.read()
        endwhile
        let end_time= reltime()

        unlet buf

        call pipe.waitpid()

        let spent_time+= str2float(reltimestr(reltime(start_time, end_time)))
    endfor

    return {
    \   'nchars':     a:nchars,
    \   'spent_time': spent_time,
    \   'count':      a:cnt,
    \}
endfunction

let ntrials= 10
let nchars_list= [
\   10,
\   100,
\   1000,
\   10000,
\   100000,
\   1000000,
\   10000000,
\]

for nchars in nchars_list
    let result= s:do_benchmark(ntrials, nchars)

    echo printf("%10d\t%f", result.nchars, result.spent_time / result.count)
endfor
