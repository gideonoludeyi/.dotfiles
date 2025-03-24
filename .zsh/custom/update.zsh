update ()
{
    darwin-rebuild switch --flake "$HOME/.config/nix-darwin#simple" --show-trace -L -v
}
