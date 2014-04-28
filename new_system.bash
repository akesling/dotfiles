sudo yum install $(cat install.txt) &&
sudo easy_install pip

mkdir -p ~/.local/dotfiles
touch -p ~/.local/dotfiles/vimrc
touch -p ~/.local/dotfiles/bashrc
touch -p ~/.local/dotfiles/zshrc
