# herdr config

For that to properly work with nvim navigation the [vim-herdr-navigation](https://github.com/paulbkim-dev/vim-herdr-navigation) is needed.
'''sh
mkdir -p ~/.config/herdr/plugins
git clone https://github.com/paulbkim-dev/vim-herdr-navigation ~/.config/herdr/plugins/vim-herdr-navigation
herdr plugin link ~/.config/herdr/plugins/vim-herdr-navigation
herdr plugin action list --plugin vim-herdr-navigation
'''
