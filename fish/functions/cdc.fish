function cdc
     set dir (find ~/.config /etc /usr/share /opt -type d -iname "*caelestia*" 2>/dev/null | fzf --height 40% --reverse --prompt="Selecciona carpeta de Caelestia: "); if test -n "$dir"; cd $dir; end; 
end
