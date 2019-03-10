function fish_prompt
    set_color normal
    echo -n "$USER"(set_color $fish_color_cwd) (prompt_pwd)
    set_color normal
    echo -n ' ) '
end
