function fish_greeting
    set term_cols (tput cols)
    
    if test -n "$term_cols"; and test "$term_cols" -lt 45
        command -v fastfetch &> /dev/null && fastfetch --logo none
        return
    end

    set random_img (random choice ~/.config/fastfetch/pokemon/*.png)
    command -v fastfetch &> /dev/null && fastfetch --logo-type sixel --logo $random_img --logo-width 18 --logo-height 9 --logo-padding-right 3 --key-padding-left 0 --logo-padding-top 0
end