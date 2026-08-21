function ls --wraps='eza --icons --group-directories-first -1' --wraps='eza --color=always --icons=always' --description 'alias ls=eza --color=always --icons=always'
    eza --color=always --icons=always $argv
end
