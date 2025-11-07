# Zoxide needs an event handler, so it can't live in functions

if status is-interactive
    zoxide init fish | source
end
