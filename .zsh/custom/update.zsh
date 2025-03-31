update ()
{
    darwin-rebuild switch --flake "$HOME/.config/nix-darwin#simple" --show-trace -L -v
    nix-collect-garbage -d --delete-older-than 10d
}
